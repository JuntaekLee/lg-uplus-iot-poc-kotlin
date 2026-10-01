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
  .device-card.tappable { cursor: pointer; }

  /* 에어컨 상세 화면 */
  .detail-bar {
    display: flex;
    align-items: center;
    gap: 4px;
    padding: 14px 12px 4px 8px;
  }
  .back {
    width: 36px;
    height: 36px;
    border: none;
    background: transparent;
    border-radius: 999px;
    display: flex;
    align-items: center;
    justify-content: center;
    cursor: pointer;
    padding: 0;
  }
  .detail-wrap { padding: 8px 20px 0; }
  .hero {
    background: var(--card);
    border-radius: 20px;
    padding: 18px 20px 20px;
    box-shadow: 0 1px 2px rgba(42,37,48,0.06);
  }
  .hero-top {
    display: flex;
    align-items: center;
    justify-content: space-between;
  }
  .pill {
    display: inline-flex;
    align-items: center;
    gap: 6px;
    font-size: 12px;
    font-weight: 600;
    color: var(--accent);
    background: var(--accent-soft);
    border-radius: 999px;
    padding: 5px 10px;
  }
  .pill .dot { width: 6px; height: 6px; border-radius: 999px; background: var(--accent); }
  .pill.off { color: var(--muted); background: #EFEFF2; }
  .pill.off .dot { background: var(--off); }
  .hero-label { font-size: 12px; color: var(--muted); margin-top: 22px; }
  .hero-temp {
    font-size: 64px;
    font-weight: 700;
    letter-spacing: -2px;
    line-height: 1.05;
    margin-top: 2px;
  }
  .hero-temp .unit { font-size: 24px; font-weight: 600; letter-spacing: 0; margin-left: 2px; color: var(--muted); }
  .hero-temp.dim { color: var(--off); }
  .hero-sub { font-size: 13px; color: var(--muted); margin-top: 6px; }

  .panel {
    background: var(--card);
    border-radius: 16px;
    padding: 16px;
    margin-top: 12px;
    box-shadow: 0 1px 2px rgba(42,37,48,0.06);
  }
  .panel-title { font-size: 13px; font-weight: 600; color: var(--muted); margin-bottom: 12px; }
  .stepper {
    display: flex;
    align-items: center;
    justify-content: space-between;
  }
  .step-btn {
    width: 48px;
    height: 48px;
    border-radius: 999px;
    border: none;
    background: var(--accent-soft);
    display: flex;
    align-items: center;
    justify-content: center;
    cursor: pointer;
    padding: 0;
  }
  .step-btn:disabled { opacity: 0.4; cursor: default; }
  .step-value { font-size: 30px; font-weight: 700; }
  .step-value .unit { font-size: 15px; font-weight: 600; color: var(--muted); margin-left: 1px; }
  .modes {
    display: grid;
    grid-template-columns: repeat(4, minmax(0, 1fr));
    gap: 8px;
  }
  .mode-chip {
    border: none;
    background: #F3F0F4;
    color: var(--text);
    border-radius: 14px;
    padding: 12px 0 10px;
    font-family: inherit;
    font-size: 12px;
    font-weight: 600;
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 6px;
    cursor: pointer;
  }
  .mode-chip svg { stroke: var(--muted); }
  .mode-chip.active { background: var(--accent); color: #FFFFFF; }
  .mode-chip.active svg { stroke: #FFFFFF; }
  .mode-chip:disabled { opacity: 0.4; cursor: default; }
  .info-row {
    display: flex;
    justify-content: space-between;
    font-size: 14px;
    padding: 6px 0;
  }
  .info-row span:first-child { color: var(--muted); }

  /* 조명 · 스마트플러그 상세 */
  .panel-head {
    display: flex;
    align-items: baseline;
    justify-content: space-between;
    margin-bottom: 14px;
  }
  .panel-head .panel-title { margin-bottom: 0; }
  .panel-value { font-size: 15px; font-weight: 700; }
  .slider {
    -webkit-appearance: none;
    appearance: none;
    width: 100%;
    height: 8px;
    border-radius: 999px;
    outline: none;
    margin: 6px 0;
    background: linear-gradient(to right, var(--accent) 0%, var(--accent) var(--fill, 100%), var(--off) var(--fill, 100%), var(--off) 100%);
  }
  .slider::-webkit-slider-thumb {
    -webkit-appearance: none;
    appearance: none;
    width: 26px;
    height: 26px;
    border-radius: 999px;
    background: #FFFFFF;
    border: 1px solid #D5CFD8;
    box-shadow: 0 1px 4px rgba(42,37,48,0.25);
    cursor: pointer;
  }
  .slider::-moz-range-thumb {
    width: 24px;
    height: 24px;
    border-radius: 999px;
    background: #FFFFFF;
    border: 1px solid #D5CFD8;
    box-shadow: 0 1px 4px rgba(42,37,48,0.25);
    cursor: pointer;
  }
  .slider:disabled { opacity: 0.4; }
  .slider-scale {
    display: flex;
    justify-content: space-between;
    font-size: 11px;
    color: var(--muted);
    margin-top: 6px;
  }
  .swatches {
    display: grid;
    grid-template-columns: repeat(3, minmax(0, 1fr));
    gap: 8px;
  }
  .swatch-chip {
    border: none;
    background: #F3F0F4;
    color: var(--text);
    border-radius: 14px;
    padding: 12px 0 10px;
    font-family: inherit;
    font-size: 12px;
    font-weight: 600;
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 6px;
    cursor: pointer;
  }
  .swatch-chip .sw {
    width: 26px;
    height: 26px;
    border-radius: 999px;
    border: 1px solid rgba(42,37,48,0.12);
  }
  .swatch-chip .kelvin { font-size: 10px; font-weight: 500; color: var(--muted); margin-top: -3px; }
  .swatch-chip.active { background: var(--accent); color: #FFFFFF; }
  .swatch-chip.active .kelvin { color: rgba(255,255,255,0.8); }
  .swatch-chip:disabled { opacity: 0.4; cursor: default; }
  .tiles {
    display: grid;
    grid-template-columns: repeat(2, minmax(0, 1fr));
    gap: 12px;
    margin-top: 12px;
  }
  .tile {
    background: var(--card);
    border-radius: 16px;
    padding: 16px;
    box-shadow: 0 1px 2px rgba(42,37,48,0.06);
  }
  .tile-label { font-size: 12px; color: var(--muted); }
  .tile-value { font-size: 26px; font-weight: 700; margin-top: 6px; }
  .tile-value .unit { font-size: 14px; font-weight: 600; color: var(--muted); margin-left: 2px; }
  .note { font-size: 13px; line-height: 1.55; color: var(--muted); margin: 0; }

  /* 설정이 반영됐을 때 잠깐 뜨는 알림 */
  .toast {
    position: fixed;
    left: 50%;
    bottom: 28px;
    transform: translate(-50%, 12px);
    max-width: calc(100% - 40px);
    background: rgba(42,37,48,0.92);
    color: #FFFFFF;
    font-size: 14px;
    font-weight: 500;
    padding: 12px 18px;
    border-radius: 999px;
    opacity: 0;
    pointer-events: none;
    transition: opacity 0.2s, transform 0.2s;
    z-index: 10;
  }
  .toast.show { opacity: 1; transform: translate(-50%, 0); }
  .toast.error { background: rgba(160,52,64,0.95); }
</style>
</head>
<body>
<div class="app" id="view-home">

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
        <div class="scene-sub">조명 끄기 · 에어컨 취침모드 · 대기전력 차단</div>
      </div>
      <button id="scene-run-sleep" class="scene-run" onclick="runSceneSleep()">실행하기</button>
    </div>
    <div class="scene-card">
      <div class="scene-icon">
        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#6E5A7E" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="5"/><line x1="12" y1="1" x2="12" y2="3"/><line x1="12" y1="21" x2="12" y2="23"/><line x1="4.22" y1="4.22" x2="5.64" y2="5.64"/><line x1="18.36" y1="18.36" x2="19.78" y2="19.78"/><line x1="1" y1="12" x2="3" y2="12"/><line x1="21" y1="12" x2="23" y2="12"/><line x1="4.22" y1="19.78" x2="5.64" y2="18.36"/><line x1="18.36" y1="5.64" x2="19.78" y2="4.22"/></svg>
      </div>
      <div class="scene-body">
        <div class="scene-title">기상하고 나서</div>
        <div class="scene-sub">조명 켜기 · 에어컨 끄기 · 대기전력 재개</div>
      </div>
      <button id="scene-run-morning" class="scene-run" onclick="runSceneMorning()">실행하기</button>
    </div>
  </div>

  <div class="devices">
    <h2 style="margin-bottom: 12px;">우리집 기기</h2>
    <div class="grid">

      <div class="device-card tappable" data-device="mood_light" onclick="openDetail('mood_light')">
        <div class="device-top">
          <div class="device-icon">
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#6E5A7E" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M9 18h6M10 22h4M12 2a6 6 0 0 0-4 10.472V15a1 1 0 0 0 1 1h6a1 1 0 0 0 1-1v-2.528A6 6 0 0 0 12 2z"/></svg>
          </div>
          <button class="toggle" data-device="mood_light" aria-label="조명 전원" aria-pressed="false" onclick="event.stopPropagation(); toggleDevice('mood_light')"><span class="knob"></span></button>
        </div>
        <div class="device-name" data-name="mood_light">조명</div>
        <div class="device-status" data-status="mood_light">-</div>
      </div>

      <div class="device-card tappable" data-device="aircon" onclick="openDetail('aircon')">
        <div class="device-top">
          <div class="device-icon" style="background: #EFEFF2;">
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#6B6570" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 2v20M2 12h20M4.93 4.93l14.14 14.14M19.07 4.93 4.93 19.07"/></svg>
          </div>
          <button class="toggle" data-device="aircon" aria-label="에어컨 전원" aria-pressed="false" onclick="event.stopPropagation(); toggleDevice('aircon')"><span class="knob"></span></button>
        </div>
        <div class="device-name" data-name="aircon">에어컨</div>
        <div class="device-status" data-status="aircon">-</div>
      </div>

      <div class="device-card wide tappable" data-device="smart_plug" onclick="openDetail('smart_plug')">
        <div class="device-icon">
          <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#6B6570" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M9 2v4M15 2v4M7 8h10l-1 6a4 4 0 0 1-8 0L7 8z"/><path d="M12 18v4"/></svg>
        </div>
        <div class="device-info">
          <div class="device-name" data-name="smart_plug">스마트플러그</div>
          <div class="device-status" data-status="smart_plug">-</div>
        </div>
        <button class="toggle" data-device="smart_plug" aria-label="스마트플러그 전원" aria-pressed="false" onclick="event.stopPropagation(); toggleDevice('smart_plug')"><span class="knob"></span></button>
      </div>

    </div>
  </div>

</div>

<div class="app" id="view-aircon" hidden>

  <div class="detail-bar">
    <button class="back" onclick="closeDetail()" aria-label="뒤로">
      <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="#2A2530" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><polyline points="15 18 9 12 15 6"/></svg>
    </button>
    <span style="font-size: 20px; font-weight: 700;">에어컨</span>
  </div>

  <div class="detail-wrap">

    <div class="hero">
      <div class="hero-top">
        <span class="pill off" id="ac-pill"><span class="dot"></span><span id="ac-pill-text">-</span></span>
        <button class="toggle" data-device="aircon" aria-label="에어컨 전원" aria-pressed="false" onclick="toggleDevice('aircon')"><span class="knob"></span></button>
      </div>
      <div class="hero-label">현재 온도</div>
      <div class="hero-temp dim" id="ac-current">--<span class="unit">°C</span></div>
      <div class="hero-sub" id="ac-sub">-</div>
    </div>

    <div class="panel">
      <div class="panel-title">설정 온도</div>
      <div class="stepper">
        <button class="step-btn" id="ac-minus" aria-label="온도 낮추기" onclick="stepTemp(-1)">
          <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#6E5A7E" stroke-width="2.4" stroke-linecap="round"><line x1="5" y1="12" x2="19" y2="12"/></svg>
        </button>
        <div class="step-value"><span id="ac-set">--</span><span class="unit">°C</span></div>
        <button class="step-btn" id="ac-plus" aria-label="온도 높이기" onclick="stepTemp(1)">
          <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#6E5A7E" stroke-width="2.4" stroke-linecap="round"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
        </button>
      </div>
    </div>

    <div class="panel">
      <div class="panel-title">운전 모드</div>
      <div class="modes">
        <button class="mode-chip" data-mode="cool" onclick="setMode('cool')">
          <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 2v20M2 12h20M4.93 4.93l14.14 14.14M19.07 4.93 4.93 19.07"/></svg>
          냉방
        </button>
        <button class="mode-chip" data-mode="dry" onclick="setMode('dry')">
          <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 2.5S5 10 5 15a7 7 0 0 0 14 0c0-5-7-12.5-7-12.5z"/></svg>
          제습
        </button>
        <button class="mode-chip" data-mode="fan" onclick="setMode('fan')">
          <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M3 8h11a3 3 0 1 0-3-3M3 12h16a3 3 0 1 1-3 3M3 16h8a3 3 0 1 1-3 3"/></svg>
          송풍
        </button>
        <button class="mode-chip" data-mode="sleep" onclick="setMode('sleep')">
          <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 12.79A9 9 0 1 1 11.21 3 7 7 0 0 0 21 12.79z"/></svg>
          취침
        </button>
      </div>
    </div>

    <div class="panel">
      <div class="info-row"><span>연결 상태</span><span id="ac-conn">-</span></div>
      <div class="info-row"><span>마지막 동기화</span><span id="ac-synced">-</span></div>
    </div>

  </div>

</div>

<div class="app" id="view-mood_light" hidden>

  <div class="detail-bar">
    <button class="back" onclick="closeDetail()" aria-label="뒤로">
      <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="#2A2530" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><polyline points="15 18 9 12 15 6"/></svg>
    </button>
    <span style="font-size: 20px; font-weight: 700;">조명</span>
  </div>

  <div class="detail-wrap">

    <div class="hero">
      <div class="hero-top">
        <span class="pill off" id="ml-pill"><span class="dot"></span><span id="ml-pill-text">-</span></span>
        <button class="toggle" data-device="mood_light" aria-label="조명 전원" aria-pressed="false" onclick="toggleDevice('mood_light')"><span class="knob"></span></button>
      </div>
      <div class="hero-label">밝기</div>
      <div class="hero-temp dim" id="ml-bright">--<span class="unit">%</span></div>
      <div class="hero-sub" id="ml-sub">-</div>
    </div>

    <div class="panel">
      <div class="panel-head">
        <div class="panel-title">밝기 조절</div>
        <div class="panel-value" id="ml-bright-value">--%</div>
      </div>
      <input type="range" class="slider" id="ml-slider" min="10" max="100" step="5" value="100" aria-label="밝기"
             oninput="previewBrightness(this.value)" onchange="commitBrightness(this.value)">
      <div class="slider-scale"><span>10%</span><span>100%</span></div>
    </div>

    <div class="panel">
      <div class="panel-title">색온도</div>
      <div class="swatches">
        <button class="swatch-chip" data-tone="warm" onclick="setTone('warm')">
          <span class="sw" style="background:#FFC987;"></span>
          전구색
          <span class="kelvin">2700K</span>
        </button>
        <button class="swatch-chip" data-tone="neutral" onclick="setTone('neutral')">
          <span class="sw" style="background:#FFEBC7;"></span>
          주백색
          <span class="kelvin">4000K</span>
        </button>
        <button class="swatch-chip" data-tone="cool" onclick="setTone('cool')">
          <span class="sw" style="background:#E3F0FF;"></span>
          주광색
          <span class="kelvin">6500K</span>
        </button>
      </div>
    </div>

    <div class="panel">
      <div class="info-row"><span>연결 상태</span><span id="ml-conn">-</span></div>
      <div class="info-row"><span>마지막 동기화</span><span id="ml-synced">-</span></div>
    </div>

  </div>

</div>

<div class="app" id="view-smart_plug" hidden>

  <div class="detail-bar">
    <button class="back" onclick="closeDetail()" aria-label="뒤로">
      <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="#2A2530" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round"><polyline points="15 18 9 12 15 6"/></svg>
    </button>
    <span style="font-size: 20px; font-weight: 700;">스마트플러그</span>
  </div>

  <div class="detail-wrap">

    <div class="hero">
      <div class="hero-top">
        <span class="pill off" id="sp-pill"><span class="dot"></span><span id="sp-pill-text">-</span></span>
        <button class="toggle" data-device="smart_plug" aria-label="스마트플러그 전원" aria-pressed="false" onclick="toggleDevice('smart_plug')"><span class="knob"></span></button>
      </div>
      <div class="hero-label">현재 소비전력</div>
      <div class="hero-temp dim" id="sp-power">--<span class="unit">W</span></div>
      <div class="hero-sub" id="sp-sub">-</div>
    </div>

    <div class="tiles">
      <div class="tile">
        <div class="tile-label">플러그 온도</div>
        <div class="tile-value" id="sp-temp">--<span class="unit">°C</span></div>
      </div>
      <div class="tile">
        <div class="tile-label">대기전력</div>
        <div class="tile-value" id="sp-standby">-</div>
      </div>
    </div>

    <div class="panel">
      <div class="panel-title">대기전력 차단</div>
      <p class="note">전원을 끄면 연결된 기기의 대기전력까지 차단해요. 다시 켜면 바로 전력을 공급해요.</p>
    </div>

    <div class="panel">
      <div class="info-row"><span>연결 상태</span><span id="sp-conn">-</span></div>
      <div class="info-row"><span>마지막 동기화</span><span id="sp-synced">-</span></div>
    </div>

  </div>

</div>

<div class="toast" id="toast" role="status" aria-live="polite"></div>

<script>
const API_BASE = "${api_base_url}";
const DEVICES = ${devices_json};
const DEVICE_KEYS = Object.keys(DEVICES);
const STATE = {};
const HOLD = {};   // 방금 바꾼 값이 5초 폴링에 덮여 되돌아가 보이지 않게 잠시 붙잡아 둔다
const TIMERS = {};
const MODE_LABEL = { cool: "냉방", dry: "제습", fan: "송풍", sleep: "취침" };
const TONE_LABEL = { warm: "전구색", neutral: "주백색", cool: "주광색" };
const TEMP_MIN = 18;
const TEMP_MAX = 30;
const BRIGHT_MIN = 10;
const BRIGHT_MAX = 100;

function el(id) { return document.getElementById(id); }
function pad2(n) { return n < 10 ? "0" + n : "" + n; }
function later(key, fn, ms) { clearTimeout(TIMERS[key]); TIMERS[key] = setTimeout(fn, ms); }

/* ---------- 토스트 ---------- */
let toastTimer;
function showToast(message, isError) {
  const t = el("toast");
  t.textContent = message;
  t.classList.toggle("error", !!isError);
  t.classList.add("show");
  clearTimeout(toastTimer);
  toastTimer = setTimeout(function () { t.classList.remove("show"); }, 2200);
}

/* ---------- 렌더링 ---------- */
function statusText(alias, reported) {
  const isOn = !!reported.is_on;
  if (alias === "aircon") {
    if (!isOn) return "꺼짐";
    const label = MODE_LABEL[reported.mode];
    const temp = typeof reported.current_temp_c === "number" ? reported.current_temp_c + "°C" : null;
    if (label && temp) return label + (reported.mode === "sleep" ? "모드" : "") + " · " + temp;
    return temp || "켜짐";
  }
  if (alias === "smart_plug") {
    return isOn ? "켜짐" : "꺼짐 · 대기전력 차단";
  }
  // mood_light (표시명: 조명)
  if (!isOn) return "꺼짐";
  return typeof reported.brightness === "number" ? "켜짐 · " + reported.brightness + "%" : "켜짐";
}

function setSynced(id, r) {
  if (typeof r.ts !== "number") return;
  const d = new Date(r.ts);
  el(id).textContent = pad2(d.getHours()) + ":" + pad2(d.getMinutes()) + ":" + pad2(d.getSeconds());
}

function setPill(prefix, isOn, onText, offText) {
  el(prefix + "-pill").classList.toggle("off", !isOn);
  el(prefix + "-pill-text").textContent = isOn ? onText : offText;
}

function renderDevice(alias, reported) {
  const isOn = !!reported.is_on;
  document.querySelectorAll('.toggle[data-device="' + alias + '"]').forEach(function (toggle) {
    toggle.classList.toggle("on", isOn);
    toggle.setAttribute("aria-pressed", isOn ? "true" : "false");
  });

  const statusEl = document.querySelector('[data-status="' + alias + '"]');
  statusEl.textContent = statusText(alias, reported);
  statusEl.classList.toggle("on", isOn);

  if (alias === "aircon") renderAircon(reported);
  else if (alias === "mood_light") renderLight(reported);
  else if (alias === "smart_plug") renderPlug(reported);
}

function renderAircon(r) {
  const isOn = !!r.is_on;
  const setTemp = typeof r.temp_c === "number" ? r.temp_c : 24;
  const hasCurrent = isOn && typeof r.current_temp_c === "number";

  setPill("ac", isOn, "작동 중", "꺼짐");

  const cur = el("ac-current");
  cur.classList.toggle("dim", !hasCurrent);
  cur.firstChild.textContent = hasCurrent ? r.current_temp_c.toFixed(1) : "--";

  const modeName = MODE_LABEL[r.mode];
  el("ac-sub").textContent = !isOn ? "전원이 꺼져 있어요" : (modeName ? modeName + " 모드로 운전 중이에요" : "운전 중이에요");

  el("ac-set").textContent = isOn ? setTemp : "--";
  el("ac-minus").disabled = !isOn || setTemp <= TEMP_MIN;
  el("ac-plus").disabled = !isOn || setTemp >= TEMP_MAX;
  document.querySelectorAll(".mode-chip").forEach(function (chip) {
    chip.disabled = !isOn;
    chip.classList.toggle("active", isOn && chip.dataset.mode === r.mode);
  });

  el("ac-conn").textContent = "연결됨";
  setSynced("ac-synced", r);
}

function paintSlider(value) {
  const s = el("ml-slider");
  s.style.setProperty("--fill", ((value - BRIGHT_MIN) / (BRIGHT_MAX - BRIGHT_MIN) * 100) + "%");
}

function renderLight(r) {
  const isOn = !!r.is_on;
  const bright = typeof r.brightness === "number" ? r.brightness : BRIGHT_MAX;
  const tone = TONE_LABEL[r.color_tone] ? r.color_tone : "neutral";

  setPill("ml", isOn, "켜짐", "꺼짐");

  const big = el("ml-bright");
  big.classList.toggle("dim", !isOn);
  big.firstChild.textContent = isOn ? bright : "--";
  el("ml-sub").textContent = isOn ? TONE_LABEL[tone] + " 조명이 켜져 있어요" : "꺼져 있어요";

  const slider = el("ml-slider");
  slider.disabled = !isOn;
  if (document.activeElement !== slider) {
    slider.value = bright;
    paintSlider(bright);
    el("ml-bright-value").textContent = isOn ? bright + "%" : "--%";
  }
  document.querySelectorAll(".swatch-chip").forEach(function (chip) {
    chip.disabled = !isOn;
    chip.classList.toggle("active", isOn && chip.dataset.tone === tone);
  });

  el("ml-conn").textContent = "연결됨";
  setSynced("ml-synced", r);
}

function renderPlug(r) {
  const isOn = !!r.is_on;
  const power = isOn && typeof r.power_w === "number" ? r.power_w : 0;

  setPill("sp", isOn, "켜짐", "꺼짐");

  const big = el("sp-power");
  big.classList.toggle("dim", !isOn);
  big.firstChild.textContent = power.toFixed(1);
  el("sp-sub").textContent = isOn ? "연결된 기기에 전력을 공급하고 있어요" : "대기전력을 차단하고 있어요";

  el("sp-temp").firstChild.textContent = typeof r.temperature_c === "number" ? r.temperature_c.toFixed(1) : "--";
  el("sp-standby").textContent = isOn ? "공급 중" : "차단됨";

  el("sp-conn").textContent = "연결됨";
  setSynced("sp-synced", r);
}

/* ---------- API ---------- */
async function refreshDevice(alias, force) {
  if (!force && HOLD[alias] && HOLD[alias] > Date.now()) return;
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
  await Promise.all(DEVICE_KEYS.map(function (k) { return refreshDevice(k); }));
}

async function setDevice(alias, desired) {
  try {
    const res = await fetch(API_BASE + "command", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ device_id: DEVICES[alias].thing_name, desired: desired }),
    });
    return res.ok;
  } catch (e) {
    return false;
  }
}

// 명령을 보내고, 서버에 반영된 값을 다시 읽어 온 뒤 토스트로 알린다
async function apply(alias, desired, message) {
  HOLD[alias] = Date.now() + 1500;
  const ok = await setDevice(alias, desired);
  await refreshDevice(alias, true);
  showToast(ok ? message : "변경하지 못했어요. 잠시 후 다시 시도해 주세요", !ok);
  return ok;
}

function patchLocal(alias, patch) {
  HOLD[alias] = Date.now() + 1500;
  STATE[alias] = Object.assign({}, STATE[alias], patch);
  renderDevice(alias, STATE[alias]);
}

/* ---------- 조작 ---------- */
async function toggleDevice(alias) {
  const toggles = document.querySelectorAll('.toggle[data-device="' + alias + '"]');
  const nextOn = !(STATE[alias] && STATE[alias].is_on);
  toggles.forEach(function (t) { t.disabled = true; });
  try {
    await apply(alias, { is_on: nextOn }, DEVICES[alias].display_name + " 전원을 " + (nextOn ? "켰어요" : "껐어요"));
  } finally {
    toggles.forEach(function (t) { t.disabled = false; });
  }
}

function stepTemp(delta) {
  const r = STATE.aircon || {};
  const cur = typeof r.temp_c === "number" ? r.temp_c : 24;
  const next = Math.min(TEMP_MAX, Math.max(TEMP_MIN, cur + delta));
  if (next === cur) return;
  patchLocal("aircon", { temp_c: next });
  // 연타하는 동안은 화면만 바꾸고, 멈추면 한 번만 보낸다
  later("ac-temp", function () {
    const value = STATE.aircon.temp_c;
    apply("aircon", { temp_c: value }, "설정 온도를 " + value + "°C로 변경했어요");
  }, 500);
}

function setMode(mode) {
  patchLocal("aircon", { mode: mode });
  return apply("aircon", { mode: mode }, MODE_LABEL[mode] + " 모드로 변경했어요");
}

function previewBrightness(value) {
  const n = Number(value);
  paintSlider(n);
  el("ml-bright-value").textContent = n + "%";
  el("ml-bright").firstChild.textContent = n;
}

function commitBrightness(value) {
  const n = Number(value);
  patchLocal("mood_light", { brightness: n });
  return apply("mood_light", { brightness: n }, "밝기를 " + n + "%로 변경했어요");
}

function setTone(tone) {
  patchLocal("mood_light", { color_tone: tone });
  return apply("mood_light", { color_tone: tone }, "색온도를 " + TONE_LABEL[tone] + "으로 변경했어요");
}

async function runScene(buttonId, label, commands) {
  const btn = el(buttonId);
  btn.disabled = true;
  const prevText = btn.textContent;
  btn.textContent = "실행 중...";
  try {
    commands.forEach(function (c) { HOLD[c[0]] = Date.now() + 1500; });
    const results = await Promise.all(commands.map(function (c) { return setDevice(c[0], c[1]); }));
    await Promise.all(commands.map(function (c) { return refreshDevice(c[0], true); }));
    const ok = results.every(Boolean);
    showToast(ok ? "'" + label + "'를 실행했어요" : "일부 기기에 반영하지 못했어요", !ok);
  } finally {
    btn.disabled = false;
    btn.textContent = prevText;
  }
}

function runSceneSleep() {
  return runScene("scene-run-sleep", "잠들기 전에", [
    ["mood_light", { is_on: false }],
    ["aircon", { is_on: true, mode: "sleep", temp_c: 26 }],
    ["smart_plug", { is_on: false }],
  ]);
}

function runSceneMorning() {
  return runScene("scene-run-morning", "기상하고 나서", [
    ["mood_light", { is_on: true }],
    ["aircon", { is_on: false }],
    ["smart_plug", { is_on: true }],
  ]);
}

/* ---------- 화면 전환 ---------- */
function openDetail(alias) { location.hash = alias; }
function closeDetail() { location.hash = ""; }

function syncView() {
  const key = location.hash.slice(1);
  const inDetail = DEVICE_KEYS.indexOf(key) >= 0;
  el("view-home").hidden = inDetail;
  DEVICE_KEYS.forEach(function (k) { el("view-" + k).hidden = k !== key; });
  window.scrollTo(0, 0);
}

window.addEventListener("hashchange", syncView);
syncView();
refreshAll();
setInterval(refreshAll, 5000);
</script>
</body>
</html>
