# --- 과열 자동 차단/복구 (migration-plan.md "제어 규칙 자동화 엔진" 매핑) ---
# 원래 IoT Events로 구현했으나, AWS가 2026-05-20부로 IoT Events 서비스를 완전히
# 종료했다(DNS 자체가 사라짐 - iotevents.<region>.amazonaws.com이 모든 리전에서
# NXDOMAIN, terraform apply 중 발견). 같은 효과(온도 임계치 넘으면 자동 차단,
# 식으면 자동 복구)를 IoT Core에 이미 내장된 규칙(IoT Rule)만으로 재구현한다 -
# 별도 서비스가 아니라 SELECT 문에 WHERE 조건 하나 건 IoT 토픽 규칙 2개로 충분하다.
#
# SQL의 SELECT 절에서 Lambda가 기대하는 페이로드({is_on, reason, device_id})를
# 직접 만들어주므로, auto_control Lambda 코드는 IoT Events 때 그대로 재사용한다.

# lambda_exec 역할을 재사용한다 (이미 이 Thing의 UpdateThingShadow 권한을 갖고 있음)
resource "aws_lambda_function" "auto_control" {
  function_name    = "${var.project_name}-auto-control"
  role             = aws_iam_role.lambda_exec.arn
  handler          = "com.lguplus.iotpoc.AutoControlHandler::handleRequest"
  runtime          = "java21"
  filename         = local.lambda_jar_path
  source_code_hash = local.lambda_jar_hash
  timeout          = 10
  memory_size      = 512

  environment {
    variables = {
      THING_NAME   = aws_iot_thing.device["smart_plug"].name
      IOT_ENDPOINT = data.aws_iot_endpoint.data_ats.endpoint_address
    }
  }
}

resource "aws_iot_topic_rule" "auto_shutoff_overheat" {
  name        = replace("${var.project_name}_auto_shutoff_overheat", "-", "_")
  enabled     = true
  sql         = "SELECT false as is_on, 'overheat_auto_shutoff' as reason, device_id FROM 'lguplus/iot/telemetry/${aws_iot_thing.device["smart_plug"].name}' WHERE temperature_c > 30"
  sql_version = "2016-03-23"

  lambda {
    function_arn = aws_lambda_function.auto_control.arn
  }
}

resource "aws_iot_topic_rule" "auto_restore_cooldown" {
  name        = replace("${var.project_name}_auto_restore_cooldown", "-", "_")
  enabled     = true
  sql         = "SELECT true as is_on, 'auto_restore_after_cooldown' as reason, device_id FROM 'lguplus/iot/telemetry/${aws_iot_thing.device["smart_plug"].name}' WHERE temperature_c <= 27"
  sql_version = "2016-03-23"

  lambda {
    function_arn = aws_lambda_function.auto_control.arn
  }
}

resource "aws_lambda_permission" "iot_invoke_auto_shutoff" {
  statement_id  = "AllowIoTInvokeAutoShutoff"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.auto_control.function_name
  principal     = "iot.amazonaws.com"
  source_arn    = aws_iot_topic_rule.auto_shutoff_overheat.arn
}

resource "aws_lambda_permission" "iot_invoke_auto_restore" {
  statement_id  = "AllowIoTInvokeAutoRestore"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.auto_control.function_name
  principal     = "iot.amazonaws.com"
  source_arn    = aws_iot_topic_rule.auto_restore_cooldown.arn
}
