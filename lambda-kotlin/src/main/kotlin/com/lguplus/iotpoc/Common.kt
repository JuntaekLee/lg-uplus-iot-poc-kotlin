package com.lguplus.iotpoc

import com.fasterxml.jackson.databind.ObjectMapper
import com.fasterxml.jackson.module.kotlin.registerKotlinModule
import software.amazon.awssdk.services.iotdataplane.IotDataPlaneClient
import java.net.URI

val mapper: ObjectMapper = ObjectMapper().registerKotlinModule()

/** API Gateway HTTP API(payload format 2.0)가 기대하는 프록시 응답 형태. */
fun jsonResponse(statusCode: Int, body: Any, allowMethods: String): Map<String, Any?> {
    val headers = mapOf(
        "Access-Control-Allow-Origin" to "*",
        "Access-Control-Allow-Headers" to "Content-Type",
        "Access-Control-Allow-Methods" to allowMethods,
        "Content-Type" to "application/json",
    )
    return mapOf(
        "statusCode" to statusCode,
        "headers" to headers,
        "body" to mapper.writeValueAsString(body),
    )
}

/** get_status·set_command·virtual_device·auto_control이 공유하는 IoT Data Plane 클라이언트.
 * IOT_ENDPOINT는 이 4개 함수 전부에 env로 주입된다(devices.tf/lambda.tf 참고). */
object IotClientFactory {
    val client: IotDataPlaneClient by lazy {
        val endpoint = System.getenv("IOT_ENDPOINT")
            ?: error("IOT_ENDPOINT environment variable is required")
        IotDataPlaneClient.builder()
            .endpointOverride(URI.create("https://$endpoint"))
            .build()
    }
}
