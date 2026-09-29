package com.lguplus.iotpoc

import com.amazonaws.services.lambda.runtime.Context
import com.amazonaws.services.lambda.runtime.RequestHandler
import software.amazon.awssdk.core.SdkBytes
import software.amazon.awssdk.services.iotdataplane.model.GetThingShadowRequest
import software.amazon.awssdk.services.iotdataplane.model.PublishRequest
import software.amazon.awssdk.services.iotdataplane.model.ResourceNotFoundException
import software.amazon.awssdk.services.iotdataplane.model.UpdateThingShadowRequest
import kotlin.random.Random

// 기기가 하나도 desired를 받은 적 없을 때(최초 틱)의 기본 on/off. 실제로는
// 첫 set_command 호출 이후로는 이 값이 안 쓰인다.
private val defaultIsOn = mapOf(
    "smart-plug" to true,
    "mood-light" to true,
    "aircon" to false,
)

class VirtualDeviceHandler : RequestHandler<Map<String, Any?>, Map<String, Any?>> {
    init {
        IotClientFactory.warmUp()
    }

    override fun handleRequest(event: Map<String, Any?>, context: Context): Map<String, Any?> {
        val thingName = event["thing_name"] as String
        val telemetryTopic = event["telemetry_topic"] as String
        val deviceType = event["device_type"] as? String ?: "unknown"

        val desired = getDesired(thingName)
        val telemetry = buildTelemetry(thingName, deviceType, desired)

        IotClientFactory.client.updateThingShadow(
            UpdateThingShadowRequest.builder()
                .thingName(thingName)
                .payload(SdkBytes.fromUtf8String(mapper.writeValueAsString(mapOf("state" to mapOf("reported" to telemetry)))))
                .build()
        )

        IotClientFactory.client.publish(
            PublishRequest.builder()
                .topic(telemetryTopic)
                .qos(1)
                .payload(SdkBytes.fromUtf8String(mapper.writeValueAsString(telemetry)))
                .build()
        )

        return mapOf("ok" to true, "telemetry" to telemetry)
    }

    private fun getDesired(thingName: String): Map<String, Any?> {
        return try {
            val resp = IotClientFactory.client.getThingShadow(GetThingShadowRequest.builder().thingName(thingName).build())
            @Suppress("UNCHECKED_CAST")
            val payload = mapper.readValue(resp.payload().asByteArray(), Map::class.java) as Map<String, Any?>
            @Suppress("UNCHECKED_CAST")
            val state = payload["state"] as? Map<String, Any?> ?: emptyMap()
            @Suppress("UNCHECKED_CAST")
            (state["desired"] as? Map<String, Any?>) ?: emptyMap()
        } catch (e: ResourceNotFoundException) {
            emptyMap()
        }
    }

    private fun buildTelemetry(thingName: String, deviceType: String, desired: Map<String, Any?>): Map<String, Any?> {
        val isOn = (desired["is_on"] as? Boolean) ?: defaultIsOn[deviceType] ?: true
        val telemetry = mutableMapOf<String, Any?>(
            "device_id" to thingName,
            "is_on" to isOn,
            "ts" to System.currentTimeMillis(),
        )

        when (deviceType) {
            "smart-plug" -> {
                // 자기 자신(플러그)의 내부 온도 - overheat_control.tf가 이 필드로
                // 30도 초과 시 자동 차단, 27도 이하 복구를 판단한다.
                telemetry["power_w"] = if (isOn) round1(Random.nextDouble(5.0, 60.0)) else 0.0
                telemetry["temperature_c"] = round1(Random.nextDouble(18.0, 32.0))
            }
            "aircon" -> {
                telemetry["mode"] = desired["mode"] as? String ?: "normal"
                val setTemp = (desired["temp_c"] as? Number)?.toDouble() ?: 24.0
                telemetry["current_temp_c"] = if (isOn) round1(setTemp + Random.nextDouble(-0.5, 0.5)) else null
            }
            // mood-light는 on/off 외에 별도 텔레메트리가 없다.
        }

        return telemetry
    }

    private fun round1(v: Double): Double = kotlin.math.round(v * 10) / 10.0
}
