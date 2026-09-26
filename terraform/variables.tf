variable "aws_region" {
  # AWS Timestream은 서울(ap-northeast-2)에 없다 (실제로 apply해보고 확인함,
  # ingest.timestream.ap-northeast-2.amazonaws.com DNS 자체가 없음).
  # IoT Core Rule의 Timestream 액션은 같은 리전이어야 해서 도쿄로 전체를 옮김.
  description = "AWS region"
  type        = string
  default     = "ap-northeast-1"
}

variable "project_name" {
  description = "Resource name prefix"
  type        = string
  default     = "lguplus-iot-poc"
}
