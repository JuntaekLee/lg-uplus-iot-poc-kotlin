package com.lguplus.iotpoc

import com.amazonaws.services.lambda.runtime.Context
import com.amazonaws.services.lambda.runtime.RequestHandler
import software.amazon.awssdk.core.SdkBytes
import software.amazon.awssdk.services.iotdataplane.model.UpdateThingShadowRequest

class SetCommandHandler : RequestHandler<Map<String, Any?>, Map<String, Any?>> {
    init {
        IotClientFactory.warmUp()
    }

    override fun handleRequest(event: Map<String, Any?>, context: Context): Map<String, Any?> {
        val rawBody = event["body"] as? String
        @Suppress("UNCHECKED_CAST")
        val body: Map<String, Any?> = if (rawBody.isNullOrBlank()) {
            emptyMap()
        } else {
            mapper.readValue(rawBody, Map::class.java) as Map<String, Any?>
        }

        val deviceId = body["device_id"] as? String
        @Suppress("UNCHECKED_CAST")
        val desired = body["desired"] as? Map<String, Any?>

        if (deviceId.isNullOrBlank() || desired == null) {
            return jsonResponse(400, mapOf("error" to "device_id and desired (object) are required"), "POST,OPTIONS")
        }

        // reported도 함께 갱신 - 데모에서 명령이 다음 스케줄(최대 1분)까지 기다리지 않고
        // 바로 반영되도록. Device Shadow는 여기 없는 키는 그대로 두고 보낸 키만 갱신한다.
        val shadowUpdate = mapOf("state" to mapOf("desired" to desired, "reported" to desired))

        IotClientFactory.client.updateThingShadow(
            UpdateThingShadowRequest.builder()
                .thingName(deviceId)
                .payload(SdkBytes.fromUtf8String(mapper.writeValueAsString(shadowUpdate)))
                .build()
        )

        return jsonResponse(200, mapOf("thing_name" to deviceId, "desired" to desired), "POST,OPTIONS")
    }
}
