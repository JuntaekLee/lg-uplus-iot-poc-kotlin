resource "aws_cloudwatch_event_rule" "virtual_device_tick" {
  name                = "${var.project_name}-virtual-device-tick"
  schedule_expression = "rate(1 minute)"
}

# 기기 3개가 같은 1분 틱을 공유한다 - 타겟마다 input으로 어느 기기를
# 시뮬레이션할지 넘기고, virtual_device 핸들러가 그 값으로 분기한다.
resource "aws_cloudwatch_event_target" "virtual_device_tick" {
  for_each  = local.devices
  rule      = aws_cloudwatch_event_rule.virtual_device_tick.name
  target_id = each.key
  arn       = aws_lambda_function.virtual_device.arn

  input = jsonencode({
    thing_name      = aws_iot_thing.device[each.key].name
    telemetry_topic = "lguplus/iot/telemetry/${aws_iot_thing.device[each.key].name}"
    device_type     = each.value.device_type
  })
}

resource "aws_lambda_permission" "eventbridge_virtual_device" {
  statement_id  = "AllowEventBridgeInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.virtual_device.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.virtual_device_tick.arn
}
