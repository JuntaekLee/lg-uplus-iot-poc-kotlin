package com.lguplus.iotpoc

import com.fasterxml.jackson.databind.ObjectMapper
import com.fasterxml.jackson.module.kotlin.registerKotlinModule
import software.amazon.awssdk.services.iotdataplane.IotDataPlaneClient
import software.amazon.awssdk.http.urlconnection.UrlConnectionHttpClient
import software.amazon.awssdk.regions.Region
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
 * IOT_ENDPOINT는 이 4개 함수 전부에 env로 주입된다(devices.tf/lambda.tf 참고).
 *
 * 콜드스타트 단축: 핸들러 클래스의 init 블록에서 [warmUp]을 불러 클라이언트 생성과 Jackson
 * 로딩을 첫 요청이 아니라 Lambda Init 단계(CPU를 더 받는다)에서 끝낸다. HTTP 클라이언트는
 * 무거운 Apache 대신 URLConnection 기반을 쓰고, 리전·자격증명은 Lambda가 주입하는 env를
 * 직접 지정해 기본 체인 탐색을 건너뛴다. */
object IotClientFactory {
    val client: IotDataPlaneClient = run {
        val endpoint = System.getenv("IOT_ENDPOINT")
            ?: error("IOT_ENDPOINT environment variable is required")
        IotDataPlaneClient.builder()
            .endpointOverride(URI.create("https://$endpoint"))
            .region(Region.of(System.getenv("AWS_REGION")))
            .httpClient(UrlConnectionHttpClient.create())
            .build()
    }

    fun warmUp() = warmJson()
}

/** Jackson 직렬화·역직렬화 경로를 미리 로딩한다. IoT 클라이언트가 필요 없는 함수(get_device_metadata)도 쓴다. */
fun warmJson() {
    mapper.writeValueAsString(mapOf("warm" to listOf(1, "a", null)))
    mapper.readValue("""{"a":{"b":1}}""", Map::class.java)
}
