plugins {
    kotlin("jvm") version "2.0.20"
    id("com.gradleup.shadow") version "8.3.5"
}

group = "com.lguplus.iotpoc"
version = "1.0.0"

repositories {
    mavenCentral()
}

val awsSdkVersion = "2.28.11"
val jacksonVersion = "2.17.2"

dependencies {
    implementation("com.amazonaws:aws-lambda-java-core:1.2.3")
    implementation("software.amazon.awssdk:iotdataplane:$awsSdkVersion")
    implementation("software.amazon.awssdk:dynamodb:$awsSdkVersion")
    implementation("com.fasterxml.jackson.module:jackson-module-kotlin:$jacksonVersion")

    testImplementation(kotlin("test"))
}

kotlin {
    jvmToolchain(21)
}

tasks.shadowJar {
    archiveFileName.set("lambda-all.jar")
}

tasks.test {
    useJUnitPlatform()
}
