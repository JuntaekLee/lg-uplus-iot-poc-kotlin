<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>우리집 - 홈IoT 클라우드 이관 PoC</title>
<style>
  :root {
    --accent: #6E5A7E;
    --accent-soft: #EDE7F3;
    --bg: #F6F2F0;
    --card: #FFFFFF;
    --text: #2A2530;
    --muted: #8A8290;
    --off: #DCD7DC;
  }
  * { box-sizing: border-box; }
  body {
    margin: 0;
    font-family: 'Apple SD Gothic Neo', 'Pretendard', 'Malgun Gothic', sans-serif;
    background: var(--bg);
    color: var(--text);
  }
  .app {
    width: 100%;
    max-width: 430px;
    margin: 0 auto;
    min-height: 100vh;
    padding-bottom: 32px;
  }
  .appbar {
    padding: 20px 20px 4px;
    font-size: 20px;
    font-weight: 700;
  }
  .section {
    padding: 20px 20px 4px;
  }
  .section h2 {
    font-size: 16px;
    font-weight: 700;
    margin: 0 0 2px;
  }
  .section .hint {
    font-size: 12px;
    color: var(--muted);
    margin: 0 0 12px;
  }
  .scene-card {
    background: var(--card);
    border-radius: 16px;
    padding: 14px 16px;
    display: flex;
    align-items: center;
    gap: 12px;
    box-shadow: 0 1px 2px rgba(42,37,48,0.06);
  }
  .scene-icon {
    width: 40px;
    height: 40px;
    border-radius: 999px;
    background: var(--accent-soft);
    display: flex;
    align-items: center;
    justify-content: center;
    flex-shrink: 0;
  }
  .scene-body { flex-grow: 1; }
  .scene-title { font-size: 15px; font-weight: 600; }
  .scene-sub { font-size: 12px; color: var(--muted); }
  .scene-run {
    flex-shrink: 0;
    border: none;
    background: var(--accent);
    color: #FFFFFF;
    font-size: 13px;
    font-weight: 600;
    padding: 8px 16px;
    border-radius: 999px;
    cursor: pointer;
  }
  .scene-run:disabled { opacity: 0.6; cursor: default; }
  .scene-card + .scene-card { margin-top: 10px; }

  .devices {
    padding: 20px;
  }
  .grid {
    display: grid;
    grid-template-columns: repeat(2, minmax(0, 1fr));
    gap: 12px;
  }
  .device-card {
    background: var(--card);
    border-radius: 16px;
    padding: 16px;
    box-shadow: 0 1px 2px rgba(42,37,48,0.06);
  }
  .device-card.wide {
    grid-column: span 2;
    display: flex;
    align-items: center;
    gap: 14px;
  }
  .device-icon {
    width: 36px;
    height: 36px;
    border-radius: 10px;
    background: var(--accent-soft);
    display: flex;
    align-items: center;
    justify-content: center;
    flex-shrink: 0;
  }
  .device-card.wide .device-icon { background: #EFEFF2; }
  .device-top {
    display: flex;
    align-items: flex-start;
    justify-content: space-between;
  }
  .device-name { font-size: 15px; font-weight: 600; }
  .device-status { font-size: 12px; color: var(--muted); margin-top: 2px; }
  .device-status.on { color: var(--accent); }
  .device-info { flex-grow: 1; }

  .toggle {
    width: 44px;
    height: 26px;
    border-radius: 999px;
    border: none;
    position: relative;
    flex-shrink: 0;
    background: var(--off);
    cursor: pointer;
    padding: 0;
  }
  .toggle .knob {
    position: absolute;
    top: 3px;
    left: 3px;
    width: 20px;
    height: 20px;
    border-radius: 999px;
    background: #FFFFFF;
    transition: left 0.15s;
  }
  .toggle.on { background: var(--accent); }
  .toggle.on .knob { left: 21px; }
  .toggle:disabled { opacity: 0.6; cursor: default; }
</style>
</head>
<body>
<div class="app">

  <div class="appbar">우리집</div>

  <div class="section">
    <h2>우리집 동시 모드</h2>
    <div class="hint">자주 쓰는 상황을 한 번에 실행해요</div>
    <div class="scene-card">
      <div class="scene-icon">
        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#6E5A7E" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 12.79A9 9 0 1 1 11.21 3 7 7 0 0 0 21 12.79z"/></svg>
      </div>
      <div class="scene-body">
        <div class="scene-title">잠들기 전에</div>
        <div class="scene-sub">무드등 끄기 · 에어컨 취침모드 · 대기전력 차단</div>
      </div>
      <button id="scene-run-sleep" class="scene-run" onclick="runSceneSleep()">실행하기</button>
    </div>
    <div class="scene-card">
      <div class="scene-icon">
        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#6E5A7E" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="5"/><line x1="12" y1="1" x2="12" y2="3"/><line x1="12" y1="21" x2="12" y2="23"/><line x1="4.22" y1="4.22" x2="5.64" y2="5.64"/><line x1="18.36" y1="18.36" x2="19.78" y2="19.78"/><line x1="1" y1="12" x2="3" y2="12"/><line x1="21" y1="12" x2="23" y2="12"/><line x1="4.22" y1="19.78" x2="5.64" y2="18.36"/><line x1="18.36" y1="5.64" x2="19.78" y2="4.22"/></svg>
      </div>
      <div class="scene-body">
        <div class="scene-title">기상하고 나서</div>
        <div class="scene-sub">무드등 끄기 · 에어컨 끄기 · 대기전력 재개</div>
      </div>
      <button id="scene-run-morning" class="scene-run" onclick="runSceneMorning()">실행하기</button>
    </div>
  </div>

  <div class="devices">
    <h2 style="margin-bottom: 12px;">우리집 기기</h2>
    <div class="grid">

      <div class="device-card" data-device="mood_light">
        <div class="device-top">
          <div class="device-icon">
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#6E5A7E" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M9 18h6M10 22h4M12 2a6 6 0 0 0-4 10.472V15a1 1 0 0 0 1 1h6a1 1 0 0 0 1-1v-2.528A6 6 0 0 0 12 2z"/></svg>
          </div>
          <button class="toggle" data-device="mood_light" aria-label="무드등 전원" aria-pressed="false" onclick="toggleDevice('mood_light')"><span class="knob"></span></button>
        </div>
        <div class="device-name" data-name="mood_light">무드등</div>
        <div class="device-status" data-status="mood_light">-</div>
      </div>

      <div class="device-card" data-device="aircon">
        <div class="device-top">
          <div class="device-icon" style="background: #EFEFF2;">
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#6B6570" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 2v20M2 12h20M4.93 4.93l14.14 14.14M19.07 4.93 4.93 19.07"/></svg>
          </div>
          <button class="toggle" data-device="aircon" aria-label="에어컨 전원" aria-pressed="false" onclick="toggleDevice('aircon')"><span class="knob"></span></button>
        </div>
        <div class="device-name" data-name="aircon">에어컨</div>
        <div class="device-status" data-status="aircon">-</div>
      </div>

      <div class="device-card wide" data-device="smart_plug">
        <div class="device-icon">
          <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#6B6570" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M9 2v4M15 2v4M7 8h10l-1 6a4 4 0 0 1-8 0L7 8z"/><path d="M12 18v4"/></svg>
        </div>
        <div class="device-info">
          <div class="device-name" data-name="smart_plug">스마트플러그</div>
          <div class="device-status" data-status="smart_plug">-</div>
        </div>
        <button class="toggle" data-device="smart_plug" aria-label="스마트플러그 전원" aria-pressed="false" onclick="toggleDevice('smart_plug')"><span class="knob"></span></button>
      </div>

    </div>
  </div>

</div>

<script>
const API_BASE = "${api_base_url}";
const DEVICES = ${devices_json};
const DEVICE_KEYS = Object.keys(DEVICES);
const STATE = {};

function statusText(alias, reported) {
  const isOn = !!reported.is_on;
  if (alias === "aircon") {
    if (!isOn) return "꺼짐";
    if (reported.mode === "sleep") return "취침모드" + (reported.current_temp_c !== undefined ? " · " + reported.current_temp_c + "°C" : "");
    return reported.current_temp_c !== undefined ? reported.current_temp_c + "°C" : "켜짐";
  }
  if (alias === "smart_plug") {
    return isOn ? "켜짐" : "꺼짐 · 대기전력 차단";
  }
  // mood_light
  return isOn ? "켜짐 · 은은하게" : "꺼짐";
}

function renderDevice(alias, reported) {
  const isOn = !!reported.is_on;
  const toggle = document.querySelector('.toggle[data-device="' + alias + '"]');
  toggle.classList.toggle("on", isOn);
  toggle.setAttribute("aria-pressed", isOn ? "true" : "false");

  const statusEl = document.querySelector('[data-status="' + alias + '"]');
  statusEl.textContent = statusText(alias, reported);
  statusEl.classList.toggle("on", isOn);
}

async function refreshDevice(alias) {
  const thingName = DEVICES[alias].thing_name;
  try {
    const res = await fetch(API_BASE + "status?device_id=" + encodeURIComponent(thingName));
    const data = await res.json();
    STATE[alias] = data.reported || {};
    renderDevice(alias, STATE[alias]);
  } catch (e) {
    // 다음 폴링에서 다시 시도
  }
}

async function refreshAll() {
  await Promise.all(DEVICE_KEYS.map(refreshDevice));
}

async function setDevice(alias, desired) {
  await fetch(API_BASE + "command", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ device_id: DEVICES[alias].thing_name, desired: desired }),
  });
}

async function toggleDevice(alias) {
  const toggle = document.querySelector('.toggle[data-device="' + alias + '"]');
  const nextOn = !(STATE[alias] && STATE[alias].is_on);
  toggle.disabled = true;
  try {
    await setDevice(alias, { is_on: nextOn });
    await refreshDevice(alias);
  } finally {
    toggle.disabled = false;
  }
}

async function runScene(buttonId, commands) {
  const btn = document.getElementById(buttonId);
  btn.disabled = true;
  const prevText = btn.textContent;
  btn.textContent = "실행 중...";
  try {
    await Promise.all(commands.map(([alias, desired]) => setDevice(alias, desired)));
    await refreshAll();
  } finally {
    btn.disabled = false;
    btn.textContent = prevText;
  }
}

function runSceneSleep() {
  return runScene("scene-run-sleep", [
    ["mood_light", { is_on: false }],
    ["aircon", { is_on: true, mode: "sleep", temp_c: 26 }],
    ["smart_plug", { is_on: false }],
  ]);
}

function runSceneMorning() {
  return runScene("scene-run-morning", [
    ["mood_light", { is_on: false }],
    ["aircon", { is_on: false }],
    ["smart_plug", { is_on: true }],
  ]);
}

refreshAll();
setInterval(refreshAll, 5000);
</script>
</body>
</html>
