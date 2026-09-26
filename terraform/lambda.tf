# --- Lambda 실행 역할 (최소 권한: 이 Thing의 Shadow/토픽만) ---
resource "aws_iam_role" "lambda_exec" {
  name = "${var.project_name}-lambda-exec"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic_logs" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "lambda_iot_access" {
  name = "${var.project_name}-lambda-iot-access"
  role = aws_iam_role.lambda_exec.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "iot:GetThingShadow",
          "iot:UpdateThingShadow"
        ]
        Resource = [for t in aws_iot_thing.device : "arn:aws:iot:${var.aws_region}:${data.aws_caller_identity.current.account_id}:thing/${t.name}"]
      },
      {
        Effect   = "Allow"
        Action   = "iot:Publish"
        Resource = [for t in aws_iot_thing.device : "arn:aws:iot:${var.aws_region}:${data.aws_caller_identity.current.account_id}:topic/lguplus/iot/telemetry/${t.name}"]
      }
    ]
  })
}

# --- 패키징 ---
# Kotlin/Gradle 빌드 산출물(파이썬 zip과 달리 5개 함수가 전부 같은 fat jar를 공유하고,
# handler만 클래스별로 다르다) - 배포 전 `cd lambda-kotlin && gradle shadowJar`로 먼저
# 빌드해야 한다(README 참고). archive_file 데이터 소스가 알아서 감지하던 소스코드
# 변경을 이제는 filemd5로 직접 감지한다.
locals {
  lambda_jar_path = "${path.module}/../lambda-kotlin/build/libs/lambda-all.jar"
  lambda_jar_hash = filebase64sha256(local.lambda_jar_path)
}

# --- 기기 메타데이터(DynamoDB) 조회 Lambda 전용 역할: 로그 권한 + 이 테이블에
# 대한 최소 권한만 있으면 되고, IoT 관련 권한은 필요 없다(get_status·set_command와
# 역할을 분리한 이유) ---
resource "aws_iam_role" "lambda_device_metadata_exec" {
  name = "${var.project_name}-lambda-device-metadata-exec"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_device_metadata_logs" {
  role       = aws_iam_role.lambda_device_metadata_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "lambda_device_metadata_dynamodb" {
  name = "${var.project_name}-lambda-device-metadata-dynamodb"
  role = aws_iam_role.lambda_device_metadata_exec.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["dynamodb:GetItem", "dynamodb:PutItem"]
        Resource = aws_dynamodb_table.device_metadata.arn
      }
    ]
  })
}

# get_status·set_command·virtual_device는 이제 기기 3개를 공유하는 함수라
# THING_NAME을 env로 고정하지 않는다 - 프론트가 device_id(Thing 이름)를
# 요청마다 넘기고, virtual_device는 EventBridge 타겟의 input으로 기기별 값을
# 받는다(schedule.tf 참고). auto_control은 스마트플러그 전용이라 자기 env를
# 따로 갖는다(overheat_control.tf).
locals {
  lambda_env = {
    IOT_ENDPOINT = data.aws_iot_endpoint.data_ats.endpoint_address
  }
}

resource "aws_lambda_function" "get_status" {
  function_name    = "${var.project_name}-get-status"
  role             = aws_iam_role.lambda_exec.arn
  handler          = "com.lguplus.iotpoc.GetStatusHandler::handleRequest"
  runtime          = "java21"
  filename         = local.lambda_jar_path
  source_code_hash = local.lambda_jar_hash
  timeout          = 10
  memory_size      = 512

  environment {
    variables = local.lambda_env
  }
}

resource "aws_lambda_function" "set_command" {
  function_name    = "${var.project_name}-set-command"
  role             = aws_iam_role.lambda_exec.arn
  handler          = "com.lguplus.iotpoc.SetCommandHandler::handleRequest"
  runtime          = "java21"
  filename         = local.lambda_jar_path
  source_code_hash = local.lambda_jar_hash
  timeout          = 10
  memory_size      = 512

  environment {
    variables = local.lambda_env
  }
}

resource "aws_lambda_function" "virtual_device" {
  function_name    = "${var.project_name}-virtual-device"
  role             = aws_iam_role.lambda_exec.arn
  handler          = "com.lguplus.iotpoc.VirtualDeviceHandler::handleRequest"
  runtime          = "java21"
  filename         = local.lambda_jar_path
  source_code_hash = local.lambda_jar_hash
  timeout          = 10
  memory_size      = 512

  environment {
    variables = local.lambda_env
  }
}

# DynamoDB는 관리형 API(IAM 인증)라 VPC가 필요 없다 - RDS였다면 필요했던
# VPC 연결·보안그룹·NAT/엔드포인트 고민이 이 선택으로 전부 사라진다.
resource "aws_lambda_function" "get_device_metadata" {
  function_name    = "${var.project_name}-get-device-metadata"
  role             = aws_iam_role.lambda_device_metadata_exec.arn
  handler          = "com.lguplus.iotpoc.GetDeviceMetadataHandler::handleRequest"
  runtime          = "java21"
  filename         = local.lambda_jar_path
  source_code_hash = local.lambda_jar_hash
  timeout          = 10
  memory_size      = 512

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.device_metadata.name
      # device_id(Thing 이름)별 기본값 - 메타데이터가 아직 없는 기기를 처음
      # 조회할 때 이 값으로 시딩한다.
      DEVICE_REGISTRY = jsonencode({
        for k, t in aws_iot_thing.device : t.name => {
          device_type  = local.devices[k].device_type
          display_name = local.devices[k].display_name
          room         = local.devices[k].room
        }
      })
    }
  }
}
