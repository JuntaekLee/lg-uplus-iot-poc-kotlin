package com.lguplus.iotpoc

import com.amazonaws.services.lambda.runtime.Context
import com.amazonaws.services.lambda.runtime.RequestHandler
import software.amazon.awssdk.services.dynamodb.DynamoDbClient
import software.amazon.awssdk.services.dynamodb.model.AttributeValue
import software.amazon.awssdk.services.dynamodb.model.GetItemRequest
import software.amazon.awssdk.services.dynamodb.model.PutItemRequest

private val dynamo: DynamoDbClient = DynamoDbClient.builder().build()
private val tableName: String by lazy { System.getenv("TABLE_NAME") ?: error("TABLE_NAME environment variable is required") }

@Suppress("UNCHECKED_CAST")
private val deviceRegistry: Map<String, Any?> by lazy {
    System.getenv("DEVICE_REGISTRY")?.let { mapper.readValue(it, Map::class.java) as Map<String, Any?> } ?: emptyMap()
}

class GetDeviceMetadataHandler : RequestHandler<Map<String, Any?>, Map<String, Any?>> {
    override fun handleRequest(event: Map<String, Any?>, context: Context): Map<String, Any?> {
        @Suppress("UNCHECKED_CAST")
        val query = event["queryStringParameters"] as? Map<String, Any?>
        val deviceId = query?.get("device_id") as? String

        if (deviceId.isNullOrBlank()) {
            return jsonResponse(400, mapOf("error" to "device_id query parameter is required"), "GET,OPTIONS")
        }

        val getResp = dynamo.getItem(
            GetItemRequest.builder()
                .tableName(tableName)
                .key(mapOf("device_id" to AttributeValue.builder().s(deviceId).build()))
                .build()
        )

        val item: Map<String, Any?> = if (getResp.hasItem()) {
            attributeMapToPlain(getResp.item())
        } else {
            @Suppress("UNCHECKED_CAST")
            val defaults = deviceRegistry[deviceId] as? Map<String, Any?> ?: mapOf("device_type" to "unknown")
            val seeded = mapOf(
                "device_id" to deviceId,
                "registered_at" to (System.currentTimeMillis() / 1000),
            ) + defaults
            dynamo.putItem(
                PutItemRequest.builder()
                    .tableName(tableName)
                    .item(plainMapToAttributeMap(seeded))
                    .build()
            )
            seeded
        }

        return jsonResponse(200, item, "GET,OPTIONS")
    }
}
