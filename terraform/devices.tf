# 3개 기기 정의 - 우리집 동시모드(잠들기 전에) 홈 화면 재설계로 스마트플러그
# 1대에서 3대로 늘리며 for_each 구조로 전환했다. device_type은 virtual_device
# 시뮬레이터가 텔레메트리 필드를 분기하는 데 쓰고, display_name·room은
# get_device_metadata 최초 시딩에 쓴다. display_name은 웹 프론트 표시에도
# 쓰지만, room은 화면에 노출하지 않는다(방별 제어 기능은 없고 ON/OFF만 가능).
locals {
  devices = {
    smart_plug = {
      suffix       = "smart-plug-01"
      device_type  = "smart-plug"
      display_name = "스마트플러그"
      room         = "서재"
    }
    mood_light = {
      suffix       = "mood-light-01"
      device_type  = "mood-light"
      display_name = "조명"
      room         = "안방"
    }
    aircon = {
      suffix       = "aircon-01"
      device_type  = "aircon"
      display_name = "에어컨"
      room         = "거실"
    }
  }
}
