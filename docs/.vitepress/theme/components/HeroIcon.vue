<template>
  <div class="tech-icon">
    <div class="tech-icon-inner">
    <!-- 外圈旋转光环 -->
    <div class="tech-ring outer-ring"></div>
    <div class="tech-ring mid-ring"></div>
    <div class="tech-ring inner-ring"></div>
    
    <!-- 六边形主体 -->
    <div class="hex-body">
      <div class="hex-fill"></div>
      <!-- 电路线 -->
      <div class="circuit-line cl-top"></div>
      <div class="circuit-line cl-left"></div>
      <div class="circuit-line cl-right"></div>
      <div class="circuit-line cl-bottom"></div>
    </div>

    <!-- 眼睛 -->
    <div class="eyes">
      <div class="eye eye-left"></div>
      <div class="eye eye-right"></div>
    </div>

    <!-- 触角 -->
    <div class="antennae">
      <div class="antenna ant-left"><div class="ant-node"></div></div>
      <div class="antenna ant-right"><div class="ant-node"></div></div>
    </div>

    <!-- 数据节点 -->
    <div class="data-node dn-1"></div>
    <div class="data-node dn-2"></div>
    <div class="data-node dn-3"></div>
    <div class="data-node dn-4"></div>
    <div class="data-node dn-5"></div>
    <div class="data-node dn-6"></div>

    <!-- 扫描线 -->
    <div class="scan-line"></div>
    </div>
  </div>
</template>

<script setup lang="ts">
// Pure CSS tech icon
</script>

<style scoped>
/* 外层由 global CSS 控制定位，这里只设置最小尺寸 */
.tech-icon {
  width: 320px;
  height: 320px;
}

/* 内层是实际的图标布局容器 */
.tech-icon-inner {
  position: relative;
  width: 100%;
  height: 100%;
}

/* ========== 旋转光环 ========== */
.tech-ring {
  position: absolute;
  border-radius: 50%;
  border: 1px solid transparent;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
}

.outer-ring {
  width: 280px;
  height: 280px;
  border-color: color-mix(in srgb, var(--vp-c-brand-1, #3a8fd4) 25%, transparent);
  animation: rotate-ring 20s linear infinite;
  box-shadow: 0 0 40px color-mix(in srgb, var(--vp-c-brand-1, #3a8fd4) 10%, transparent);
}

.mid-ring {
  width: 210px;
  height: 210px;
  border-color: color-mix(in srgb, var(--vp-c-brand-1, #3a8fd4) 30%, transparent);
  border-style: dashed;
  border-width: 1.5px;
  animation: rotate-ring 15s linear infinite reverse;
}

.inner-ring {
  width: 150px;
  height: 150px;
  border-color: color-mix(in srgb, var(--vp-c-brand-1, #3a8fd4) 40%, transparent);
  border-width: 1.5px;
  animation: rotate-ring 10s linear infinite;
  box-shadow: 0 0 30px color-mix(in srgb, var(--vp-c-brand-1, #3a8fd4) 15%, transparent);
}

/* ========== 六边形主体 ========== */
.hex-body {
  position: absolute;
  width: 85px;
  height: 98px;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  z-index: 2;
}

.hex-fill {
  position: absolute;
  inset: 0;
  background: linear-gradient(135deg, 
    color-mix(in srgb, var(--vp-c-bg-soft, #1e1e20) 70%, var(--vp-c-brand-1, #3a8fd4) 30%),
    color-mix(in srgb, var(--vp-c-bg-soft, #1e1e20) 85%, var(--vp-c-brand-1, #3a8fd4) 15%)
  );
  clip-path: polygon(50% 0%, 100% 25%, 100% 75%, 50% 100%, 0% 75%, 0% 25%);
  border: 1.5px solid color-mix(in srgb, var(--vp-c-brand-1, #3a8fd4) 60%, transparent);
  box-shadow: 0 0 20px color-mix(in srgb, var(--vp-c-brand-1, #3a8fd4) 25%, transparent);
  animation: hex-border-pulse 4s ease-in-out infinite;
  overflow: hidden;
}

.hex-fill::after {
  content: '';
  position: absolute;
  inset: 0;
  background: linear-gradient(180deg, 
    transparent 30%, 
    color-mix(in srgb, var(--vp-c-brand-1, #3a8fd4) 15%, transparent) 50%, 
    transparent 70%
  );
  animation: hex-scan 5s linear infinite;
}

/* 电路连接线 */
.circuit-line {
  position: absolute;
  height: 1px;
  background: linear-gradient(90deg, transparent, var(--vp-c-brand-1, #3a8fd4), transparent);
  opacity: 0.7;
}

.cl-top    { width: 28px; top: -14px; left: 50%; transform: translateX(-50%); }
.cl-bottom { width: 28px; bottom: -14px; left: 50%; transform: translateX(-50%); }
.cl-left   { width: 28px; top: 50%; left: -38px; transform: translateY(-50%) rotate(60deg); }
.cl-right  { width: 28px; top: 50%; right: -38px; transform: translateY(-50%) rotate(-60deg); }

/* ========== 眼睛 ========== */
.eyes {
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -62%);
  z-index: 3;
  display: flex;
  gap: 16px;
}

.eye {
  width: 14px;
  height: 9px;
  background: var(--vp-c-brand-1, #3a8fd4);
  border-radius: 50%;
  box-shadow: 
    0 0 8px var(--vp-c-brand-1, #3a8fd4),
    0 0 18px color-mix(in srgb, var(--vp-c-brand-1, #3a8fd4) 60%, transparent),
    0 0 30px color-mix(in srgb, var(--vp-c-brand-1, #3a8fd4) 30%, transparent);
  animation: eye-glow 2s ease-in-out infinite;
  position: relative;
}

.eye::after {
  content: '';
  position: absolute;
  width: 3px;
  height: 3px;
  background: #fff;
  border-radius: 50%;
  top: 3px;
  right: 2px;
}

.eye-right { animation-delay: 0.3s; }

/* ========== 触角 ========== */
.antennae {
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  z-index: 1;
}

.antenna {
  position: absolute;
  width: 1.5px;
  height: 42px;
  background: linear-gradient(to top, var(--vp-c-brand-1, #3a8fd4), color-mix(in srgb, var(--vp-c-brand-1, #3a8fd4) 20%, transparent));
  border-radius: 1px;
  bottom: 32px;
}

.ant-left {
  left: -10px;
  transform: rotate(-22deg);
  transform-origin: bottom center;
  animation: ant-wave-left 3s ease-in-out infinite;
}

.ant-right {
  right: -10px;
  transform: rotate(22deg);
  transform-origin: bottom center;
  animation: ant-wave-right 3s ease-in-out infinite;
}

.ant-node {
  position: absolute;
  top: -5px;
  left: 50%;
  transform: translateX(-50%);
  width: 5px;
  height: 5px;
  background: var(--vp-c-brand-1, #3a8fd4);
  border-radius: 50%;
  box-shadow: 0 0 8px var(--vp-c-brand-1, #3a8fd4), 0 0 16px color-mix(in srgb, var(--vp-c-brand-1, #3a8fd4) 40%, transparent);
  animation: node-pulse 2s ease-in-out infinite;
}

.ant-right .ant-node { animation-delay: 0.5s; }

/* ========== 数据节点 ========== */
.data-node {
  position: absolute;
  border-radius: 50%;
  background: var(--vp-c-brand-1, #3a8fd4);
  box-shadow: 0 0 6px var(--vp-c-brand-1, #3a8fd4), 0 0 12px color-mix(in srgb, var(--vp-c-brand-1, #3a8fd4) 40%, transparent);
  animation: float-node 4s ease-in-out infinite;
  z-index: 1;
  opacity: 0.8;
}

.dn-1 { width: 4px; height: 4px; top: 20%; left: 28%; animation-delay: 0s; }
.dn-2 { width: 3px; height: 3px; top: 25%; right: 24%; animation-delay: 0.6s; }
.dn-3 { width: 4px; height: 4px; bottom: 24%; left: 22%; animation-delay: 1.2s; }
.dn-4 { width: 3px; height: 3px; bottom: 22%; right: 26%; animation-delay: 1.8s; }
.dn-5 { width: 5px; height: 5px; top: 50%; left: 8%; animation-delay: 2.4s; }
.dn-6 { width: 5px; height: 5px; top: 48%; right: 8%; animation-delay: 3s; }

/* ========== 扫描线 ========== */
.scan-line {
  position: absolute;
  width: 90px;
  height: 1.5px;
  background: linear-gradient(90deg, transparent, var(--vp-c-brand-1, #3a8fd4), transparent);
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  z-index: 4;
  animation: scan-move 3s ease-in-out infinite;
  opacity: 0.8;
}

/* ========== 动画关键帧 ========== */
@keyframes rotate-ring {
  from { transform: translate(-50%, -50%) rotate(0deg); }
  to   { transform: translate(-50%, -50%) rotate(360deg); }
}

@keyframes hex-border-pulse {
  0%, 100% { box-shadow: 0 0 15px color-mix(in srgb, var(--vp-c-brand-1, #3a8fd4) 20%, transparent); }
  50%      { box-shadow: 0 0 30px color-mix(in srgb, var(--vp-c-brand-1, #3a8fd4) 40%, transparent); }
}

@keyframes hex-scan {
  0%   { transform: translateY(-100%); }
  100% { transform: translateY(100%); }
}

@keyframes eye-glow {
  0%, 100% { opacity: 0.7; }
  50%      { opacity: 1; }
}

@keyframes ant-wave-left {
  0%, 100% { transform: rotate(-22deg); }
  50%      { transform: rotate(-30deg); }
}

@keyframes ant-wave-right {
  0%, 100% { transform: rotate(22deg); }
  50%      { transform: rotate(30deg); }
}

@keyframes node-pulse {
  0%, 100% { opacity: 0.5; transform: translateX(-50%) scale(1); }
  50%      { opacity: 1; transform: translateX(-50%) scale(1.5); }
}

@keyframes float-node {
  0%, 100% { opacity: 0.4; transform: translateY(0); }
  50%      { opacity: 0.9; transform: translateY(-6px); }
}

@keyframes scan-move {
  0%, 100% { opacity: 0.2; width: 70px; }
  50%      { opacity: 0.9; width: 110px; }
}

/* ========== 响应式 ========== */
@media (min-width: 640px) {
  .tech-icon { width: 380px; height: 380px; }
  .outer-ring { width: 340px; height: 340px; }
  .mid-ring { width: 260px; height: 260px; }
  .inner-ring { width: 190px; height: 190px; }
  .hex-body { width: 95px; height: 110px; }
  .eye { width: 16px; height: 10px; }
  .antenna { height: 48px; bottom: 36px; }
}

@media (min-width: 960px) {
  .tech-icon { width: 320px; height: 320px; }
  .outer-ring { width: 290px; height: 290px; }
  .mid-ring { width: 220px; height: 220px; }
  .inner-ring { width: 160px; height: 160px; }
}
</style>
