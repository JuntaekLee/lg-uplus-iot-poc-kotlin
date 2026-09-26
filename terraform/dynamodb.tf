# Timestream for LiveAnalytics는 2025-06-20부로 신규 계정 가입이 막혀 이 계정에서
# 영구적으로 접근 불가(AccessDeniedException: Only existing Timestream for
# LiveAnalytics customers can access the service). 텔레메트리 저장소를 DynamoDB로
# 대체한다 - device_id를 파티션 키, ts(ms epoch)를 정렬 키로 써서 시계열처럼 조회하고,
# expires_at TTL로 오래된 레코드를 자동 정리한다.
resource "aws_dynamodb_table" "telemetry" {
  name         = "${var.project_name}-telemetry"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "device_id"
  range_key    = "ts"

  attribute {
    name = "device_id"
    type = "S"
  }

  attribute {
    name = "ts"
    type = "N"
  }

  ttl {
    attribute_name = "expires_at"
    enabled        = true
  }
}

# 기기 DB(자격증명·메타데이터). 설계 문서(migration-plan.md)의 매핑은 RDS(Aurora
# MySQL)지만, RDS는 인스턴스를 켜두는 시간만큼 상시 과금되고 VPC·보안그룹·전용
# Lambda까지 필요해 PoC 규모에는 안 맞았다. Timestream을 DynamoDB로 대체한 것과
# 같은 이유(비용 관리)로, 기기 DB도 서버리스인 DynamoDB로 구현한다.
resource "aws_dynamodb_table" "device_metadata" {
  name         = "${var.project_name}-device-metadata"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "device_id"

  attribute {
    name = "device_id"
    type = "S"
  }
}
