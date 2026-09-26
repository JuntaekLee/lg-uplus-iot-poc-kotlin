# --- Device Defender: 기기 보안 감사 ---
resource "aws_iam_role" "device_defender_audit" {
  name = "${var.project_name}-device-defender-audit"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "iot.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "device_defender_audit" {
  role       = aws_iam_role.device_defender_audit.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSIoTDeviceDefenderAudit"
}

# Terraform AWS 프로바이더(5.100.0)에는 아직 aws_iot_account_audit_configuration /
# aws_iot_scheduled_audit 리소스가 없다 (Device Defender Audit API를 아직 안 감쌌음).
# 그래서 IAM 역할까지는 Terraform으로 선언하고, 실제 감사 설정은 같은 역할을 참조하는
# AWS CLI 호출로 붙인다. provider 커버리지 밖일 때의 실무적 우회다.
# 주의: terraform destroy로는 이 두 설정이 자동 정리되지 않는다 (별도 aws iot
# delete-account-audit-configuration / delete-scheduled-audit 필요).
resource "terraform_data" "device_defender_audit_configuration" {
  triggers_replace = [
    aws_iam_role_policy_attachment.device_defender_audit.id
  ]

  provisioner "local-exec" {
    command = <<-EOT
      aws iot update-account-audit-configuration \
        --region ${var.aws_region} \
        --role-arn ${aws_iam_role.device_defender_audit.arn} \
        --audit-check-configurations '{"DEVICE_CERTIFICATE_EXPIRING_CHECK":{"enabled":true},"REVOKED_DEVICE_CERTIFICATE_STILL_ACTIVE_CHECK":{"enabled":true},"IOT_POLICY_OVERLY_PERMISSIVE_CHECK":{"enabled":true},"LOGGING_DISABLED_CHECK":{"enabled":true},"CONFLICTING_CLIENT_IDS_CHECK":{"enabled":true}}'
    EOT
  }
}

resource "terraform_data" "device_defender_scheduled_audit" {
  depends_on = [terraform_data.device_defender_audit_configuration]

  triggers_replace = [
    terraform_data.device_defender_audit_configuration.id
  ]

  provisioner "local-exec" {
    command = <<-EOT
      aws iot create-scheduled-audit \
        --region ${var.aws_region} \
        --frequency WEEKLY \
        --day-of-week SUN \
        --target-check-names DEVICE_CERTIFICATE_EXPIRING_CHECK REVOKED_DEVICE_CERTIFICATE_STILL_ACTIVE_CHECK IOT_POLICY_OVERLY_PERMISSIVE_CHECK LOGGING_DISABLED_CHECK CONFLICTING_CLIENT_IDS_CHECK \
        --scheduled-audit-name ${var.project_name}-weekly-audit || true
    EOT
  }
}
