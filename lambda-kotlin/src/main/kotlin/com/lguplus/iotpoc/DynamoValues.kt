package com.lguplus.iotpoc

import software.amazon.awssdk.services.dynamodb.model.AttributeValue

/** Python판의 DecimalEncoder와 동일한 규칙 - 정수면 정수로, 아니면 실수로 되돌린다. */
fun toAttributeValue(value: Any?): AttributeValue = when (value) {
    null -> AttributeValue.builder().nul(true).build()
    is String -> AttributeValue.builder().s(value).build()
    is Boolean -> AttributeValue.builder().bool(value).build()
    is Number -> AttributeValue.builder().n(value.toString()).build()
    else -> AttributeValue.builder().s(value.toString()).build()
}

fun fromAttributeValue(value: AttributeValue): Any? = when {
    value.nul() != null && value.nul() -> null
    value.s() != null -> value.s()
    value.bool() != null -> value.bool()
    value.n() != null -> {
        val d = value.n().toDouble()
        if (d % 1.0 == 0.0) d.toLong() else d
    }
    else -> null
}

fun plainMapToAttributeMap(map: Map<String, Any?>): Map<String, AttributeValue> =
    map.mapValues { (_, v) -> toAttributeValue(v) }

fun attributeMapToPlain(map: Map<String, AttributeValue>): Map<String, Any?> =
    map.mapValues { (_, v) -> fromAttributeValue(v) }
