package com.lguplus.iotpoc

import com.amazonaws.services.lambda.runtime.Context
import com.amazonaws.services.lambda.runtime.RequestHandler
import software.amazon.awssdk.core.SdkBytes
import software.amazon.awssdk.services.iotdataplane.model.UpdateThingShadowRequest

class AutoControlHandler : RequestHandler<Map<String, Any?>, Map<String, Any?>> {
    init {
        IotClientFactory.warmUp()
    }

    override fun handleRequest(event: Map<String, Any?>, context: Context): Map<String, Any?> {
        // IoT Rule(overheat_control.tf)이 SQL SELECT에서 이 페이로드를 직접 만들어 호출한다:
        // {is_on, reason, device_id}. device_id는 지금은 기기가 하나뿐이라 안 쓰지만,
        // 여러 기기로 늘어나도 코드를 안 고치고 THING_NAME 매핑만 늘리면 되도록 남겨둔다.
        val thingName = System.getenv("THING_NAME") ?: error("THING_NAME environment variable is required")
        val isOn = event["is_on"] as? Boolean ?: false
        val reason = event["reason"] as? String ?: "auto_control"

        val shadowUpdate = mapOf(
            "state" to mapOf(
                "desired" to mapOf("is_on" to isOn),
                "reported" to mapOf("is_on" to isOn, "auto_control_reason" to reason),
            )
        )

        IotClientFactory.client.updateThingShadow(
            UpdateThingShadowRequest.builder()
                .thingName(thingName)
                .payload(SdkBytes.fromUtf8String(mapper.writeValueAsString(shadowUpdate)))
                .build()
        )

        return mapOf("ok" to true, "is_on" to isOn, "reason" to reason)
    }
}
