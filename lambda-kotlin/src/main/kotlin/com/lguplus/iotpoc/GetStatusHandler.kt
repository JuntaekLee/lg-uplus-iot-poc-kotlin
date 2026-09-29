package com.lguplus.iotpoc

import com.amazonaws.services.lambda.runtime.Context
import com.amazonaws.services.lambda.runtime.RequestHandler
import software.amazon.awssdk.services.iotdataplane.model.GetThingShadowRequest
import software.amazon.awssdk.services.iotdataplane.model.ResourceNotFoundException

class GetStatusHandler : RequestHandler<Map<String, Any?>, Map<String, Any?>> {
    init {
        IotClientFactory.warmUp()
    }

    override fun handleRequest(event: Map<String, Any?>, context: Context): Map<String, Any?> {
        @Suppress("UNCHECKED_CAST")
        val query = event["queryStringParameters"] as? Map<String, Any?>
        val deviceId = query?.get("device_id") as? String

        if (deviceId.isNullOrBlank()) {
            return jsonResponse(400, mapOf("error" to "device_id query parameter is required"), "GET,OPTIONS")
        }

        return try {
            val resp = IotClientFactory.client.getThingShadow(
                GetThingShadowRequest.builder().thingName(deviceId).build()
            )
            @Suppress("UNCHECKED_CAST")
            val payload = mapper.readValue(resp.payload().asByteArray(), Map::class.java) as Map<String, Any?>
            @Suppress("UNCHECKED_CAST")
            val state = payload["state"] as? Map<String, Any?> ?: emptyMap()

            val body = mapOf(
                "thing_name" to deviceId,
                "reported" to (state["reported"] ?: emptyMap<String, Any?>()),
                "desired" to (state["desired"] ?: emptyMap<String, Any?>()),
                "shadow_updated_at" to payload["timestamp"],
            )
            jsonResponse(200, body, "GET,OPTIONS")
        } catch (e: ResourceNotFoundException) {
            jsonResponse(
                200,
                mapOf(
                    "thing_name" to deviceId,
                    "reported" to emptyMap<String, Any?>(),
                    "desired" to emptyMap<String, Any?>(),
                ),
                "GET,OPTIONS",
            )
        }
    }
}
