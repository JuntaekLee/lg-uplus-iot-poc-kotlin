# lg-uplus-iot-poc-kotlin

LG유플러스 홈IoT 클라우드 이관 설계(`interview/lg-uplus/migration-plan.md`)의 일부를
실제 AWS에 구현한 PoC. 스마트플러그·조명·에어컨 3개 기기를 IoT Core에 등록하고,
API Gateway + Lambda(Kotlin)로 제어하며, "잠들기 전에"·"기상하고 나서" 씬으로 세 기기를
한 번에 제어하는 모바일 웹 데모를 CloudFront로 서빙한다.

## 구조

```
terraform/       AWS 인프라 전체(IoT Core·API Gateway·Lambda·DynamoDB·CloudFront 등)
lambda-kotlin/   Lambda 5개(get_status·set_command·get_device_metadata·
                 virtual_device·auto_control)를 담은 Gradle Kotlin 프로젝트.
                 함수마다 별도 jar가 아니라, 하나의 fat jar에 클래스 5개를
                 담고 Terraform이 함수별로 handler(진입 클래스)만 다르게 지정한다.
web/             데모 프론트(정적 HTML, templatefile로 API URL·기기 목록 주입)
```

## 빌드 · 배포

```bash
cd lambda-kotlin
./gradlew shadowJar        # build/libs/lambda-all.jar 생성

cd ../terraform
terraform init
terraform plan
terraform apply
```

`terraform apply`는 jar의 해시(`filebase64sha256`)로 변경을 감지하므로,
Lambda 코드를 고칠 때마다 `shadowJar`를 먼저 다시 돌려야 한다.

## 참고

- Lambda 런타임은 `java21`, 메모리는 512MB(JVM 콜드스타트 완화용으로 기본값 128MB에서 올림).
- 최초 요청(콜드 스타트)은 1~2초 정도 걸릴 수 있다. 데모 페이지를 열어두면
  5초 주기 폴링이 알아서 함수들을 계속 warm 상태로 유지한다.
