# --- Thing: 시뮬레이션할 기기 3대 (스마트플러그·무드등·에어컨) ---
resource "aws_iot_thing" "device" {
  for_each = local.devices
  name     = "${var.project_name}-${each.value.suffix}"
}

# --- Certificate: AWS가 키 쌍을 직접 발급 (CSR 없이), 기기당 1개 ---
resource "aws_iot_certificate" "device_cert" {
  for_each = local.devices
  active   = true
}

resource "aws_iot_thing_principal_attachment" "attach" {
  for_each  = local.devices
  thing     = aws_iot_thing.device[each.key].name
  principal = aws_iot_certificate.device_cert[each.key].arn
}

# --- Policy: 각 기기는 자기 자신의 토픽에만 connect/publish 가능 (최소 권한) ---
resource "aws_iot_policy" "device_policy" {
  for_each = local.devices
  name     = "${var.project_name}-${replace(each.key, "_", "-")}-device-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "iot:Connect"
        Resource = "arn:aws:iot:${var.aws_region}:${data.aws_caller_identity.current.account_id}:client/${aws_iot_thing.device[each.key].name}"
      },
      {
        Effect   = "Allow"
        Action   = "iot:Publish"
        Resource = "arn:aws:iot:${var.aws_region}:${data.aws_caller_identity.current.account_id}:topic/lguplus/iot/telemetry/${aws_iot_thing.device[each.key].name}"
      }
    ]
  })
}

resource "aws_iot_policy_attachment" "attach_policy" {
  for_each = local.devices
  policy   = aws_iot_policy.device_policy[each.key].name
  target   = aws_iot_certificate.device_cert[each.key].arn
}

# --- IoT Rule이 DynamoDB에 쓰기 위해 assume하는 역할 ---
# (원래 Timestream 대상이었으나 2025-06-20부로 신규 계정에 영구 차단되어 DynamoDB로 대체)
resource "aws_iam_role" "iot_dynamodb_role" {
  name = "${var.project_name}-iot-dynamodb-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "iot.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "iot_dynamodb_write" {
  name = "${var.project_name}-iot-dynamodb-write"
  role = aws_iam_role.iot_dynamodb_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "dynamodb:PutItem"
        Resource = aws_dynamodb_table.telemetry.arn
      }
    ]
  })
}

# --- Topic Rule: 텔레메트리 토픽 -> DynamoDB ---
resource "aws_iot_topic_rule" "telemetry_to_dynamodb" {
  name        = replace("${var.project_name}_telemetry_to_dynamodb", "-", "_")
  enabled     = true
  sql         = "SELECT * FROM 'lguplus/iot/telemetry/+'"
  sql_version = "2016-03-23"

  dynamodbv2 {
    role_arn = aws_iam_role.iot_dynamodb_role.arn

    put_item {
      table_name = aws_dynamodb_table.telemetry.name
    }
  }
}
