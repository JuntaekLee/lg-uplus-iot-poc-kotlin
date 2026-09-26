data "aws_iot_endpoint" "data_ats" {
  endpoint_type = "iot:Data-ATS"
}

output "iot_endpoint" {
  value = data.aws_iot_endpoint.data_ats.endpoint_address
}

output "thing_names" {
  value = { for k, t in aws_iot_thing.device : k => t.name }
}

output "telemetry_topics" {
  value = { for k, t in aws_iot_thing.device : k => "lguplus/iot/telemetry/${t.name}" }
}

output "telemetry_table" {
  value = aws_dynamodb_table.telemetry.name
}

output "device_certificate_pem" {
  value     = { for k, c in aws_iot_certificate.device_cert : k => c.certificate_pem }
  sensitive = true
}

output "device_private_key" {
  value     = { for k, c in aws_iot_certificate.device_cert : k => c.private_key }
  sensitive = true
}
