# Figma 设计规范文档
## 🇯🇵 日语精听App (Rabbit) PRO版
**版本**: 1.0.0 | **创建日期**: 2025-11-08 | **设计师**: Claude Code AI

---

## 📋 文档体系

### 核心设计哲学
**设计理念**: 简约和魂·智慧精进
> 融合日本传统美学的侘寂（Wabi-Sabi）与现代极简主义，营造专注、静谧、高效的学习氛围

**核心价值**:
- 专注性：减少视觉噪音，突出学习内容
- 温度感：温暖的交互反馈，人性化的情感设计
- 精进感：体现持续进步的学习旅程

---

## 🎨 视觉设计系统

### 色彩系统 (Color System)

#### 主色调 Primary Palette
| Token | Value | Usage | Example |
|-------|-------|-------|---------|
| `primary-50` | `#f0f7ff` | 背景-浅 | 卡片背景 |
| `primary-100` | `#e0f0ff` | 背景-中 | 选中态背景 |
| `primary-500` | **#1e40af** | **主品牌色** | CTA按钮、强调 |
| `primary-600` | `#1e3a8a` | 主色-悬停 | 按钮按压 |
| `primary-700` | `#1e3a8a` | 主色-深 | 文字链接 |

#### 辅助色 Secondary Palette
| Token | Value | Usage |
|-------|-------|-------|
| `secondary-500` | `#f472b6` | 樱花粉 - PRO标识、成就 |
| `secondary-600` | `#ec4899` | PRO按钮悬停 |
| `Accent-500` | `#60a5fa` | 天空蓝 - 学习进度 |
| `success-500` | `#10b981` | 新绿 - 完成任务 |
| `warning-500` | `#f59e0b` | 金茶 - 警告提示 |

#### 中性色 Neutral Palette
| Token | Value | Usage |
|-------|-------|-------|
| `neutral-0` | `#ffffff` | 纯白背景 |
| `neutral-50` | `#f9fafb` | 页面背景 |
| `neutral-100` | `#f3f4f6` | 分割线区域 |
| `neutral-200` | `#e5e7eb` | 分割线 |
| `neutral-500` | `#6b7280` | 辅助文字 |
| `neutral-900` | `#111827` | 主要文字 |

#### 语义色 Semantic Colors
```css
/* 学习状态 */
--status-not-started: #9ca3af;   /* 灰 */
--status-learning: #60a5fa;      /* 蓝 */
--status-mastered: #10b981;      /* 绿 */

/* PRO 主题 */
--pro-gold: #f59e0b;
--pro-dark-gold: #d97706;
```

### 字体系统 (Typography)

#### 字体族 Font Family
```css
/* 主字体 */
--font-primary: 'Noto Sans JP', '-apple-system', 'BlinkMacSystemFont', 'Segoe UI', 'Roboto', sans-serif;

/* 标题字体 */
--font-display: 'Noto Serif JP', 'Georgia', 'Times New Roman', serif;

/* 代码字体 */
--font-mono: 'SF Mono', 'Monaco', 'Cascadia Code', monospace;
```

*
*字体说明**:
- Noto Sans JP: 专业的日文支持，现代无衬线
- Noto Serif JP: 衬线字体，用于标题和强调内容
- 确保跨平台一致渲染

#### 字阶 Type Scale
| 层级 | 字体大小 | 行高 | 字重 | 用途 |
|------|----------|------|------|------|
| `h1` | 32px (2rem) | 40px | 700 | 页面标题 |
| `h2` | 24px (1.5rem) | 32px | 600 | 区块标题 |
| `h3` | 20px (1.25rem) | 28px | 600 | 卡片标题 |
| `body-lg` | 18px (1.125rem) | 28px | 400 | 大正文 |
| `body` | 16px (1rem) | 24px | 400 | 标准正文 |
| `body-sm` | 14px (0.875rem) | 20px | 400 | 辅助信息 |
| `caption` | 12px (0.75rem) | 16px | 400 | 标签、提示 |

#### 字体颜色层级
```css
/* 文字颜色层级 */
--text-primary: #111827;    /* 主要文字 #111827 */
--text-secondary: #6b7280;  /* 次要文字 #6b7280 */
--text-tertiary: #9ca3af;   /* 辅助文字 #9ca3af */
--text-link: #1e40af;       /* 链接 #1e40af */
--text-pro: #f59e0b;        /* PRO标识 #f59e0b */
```

### 阴影系统 (Shadow System)
```css
/* 层级阴影 */
--shadow-sm: 0 1px 2px 0 rgba(0, 0, 0, 0.05);
--shadow-md: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
--shadow-lg: 0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05);
--shadow-xl: 0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 10px 10px -5px rgba(0, 0, 0, 0.04);
--shadow-2xl: 0 25px 50px -12px rgba(0, 0, 0, 0.25);

/* 内阴影 */
--shadow-inner: inset 0 2px 4px 0 rgba(0, 0, 0, 0.06);
```

### 圆角系统 (Border Radius)
```css
--radius-sm: 6px;    /* 小按钮、标签 */
--radius-md: 10px;   /* 卡片、输入框 */
--radius-lg: 14px;   /* 大图、模态框 */
--radius-xl: 20px;   /* FAB、大按钮 */
--radius-full: 9999px; /* 圆形按钮 */
```

---

## 📐 布局系统 (Layout System)

### 网格系统 Grid System
```css
/* 容器 */
--container-padding-mobile: 16px;
--container-padding-tablet: 24px;
--container-max-width: 420px;

/* 间距系统 (8px基础单位) */
--space-xs: 4px;    /* 图标配文字 */
--space-sm: 8px;    /* 组件内间距 */
--space-md: 16px;   /* 组件间间距 */
--space-lg: 24px;   /* 区块间间距 */
--space-xl: 32px;   /* 大区块间距 */
--space-2xl: 48px;  /* 页面级间距 */
```

### 组件间距规则
```css
/* 卡片内边距 */
.card-padding: var(--space-md);      /* 16px */

/* 列表项间距 */
.list-gap: var(--space-md);          /* 16px */

/* 按钮内边距 */
.button-padding: var(--space-sm) var(--space-lg);  /* 8px 16px */
```

---

## 🧩 组件库 (Component Library)

### 1. 按钮组件 (Button Components)

#### 主按钮 Primary Button
```css
/* 基础样式 */
.primary-button {
  height: 48px;
  padding: 0 var(--space-lg);
  background: linear-gradient(135deg, var(--primary-500) 0%, var(--primary-600) 100%);
  border-radius: var(--radius-md);
  color: white;
  font-size: var(--body);
  font-weight: 600;
  border: none;
  cursor: pointer;
  transition: all 0.2s ease;
}

/* 状态变化 */
.primary-button:hover {
  transform: translateY(-1px);
  box-shadow: var(--shadow-lg);
}
.primary-button:active {
  transform: translateY(0);
}
.primary-button:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}
```

#### 图标按钮 Icon Button
```css
.icon-button {
  width: 40px;
  height: 40px;
  border-radius: var(--radius-full);
  background: transparent;
  border: none;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  transition: all 0.2s ease;
}
.icon-button:hover {
  background: var(--primary-50);
}
```

#### PRO按钮 PRO Button
```css
.pro-button {
  background: linear-gradient(135deg, var(--pro-gold) 0%, var(--pro-dark-gold) 100%);
  color: white;
  position: relative;
  overflow: hidden;
}
.pro-button::before {
  content: '';
  position: absolute;
  top: 0;
  left: -100%;
  width: 100%;
  height: 100%;
  background: linear-gradient(90deg, transparent, rgba(255,255,255,0.2), transparent);
  transition: left 0.5s;
}
.pro-button:hover::before {
  left: 100%;
}
```

### 2. 卡片组件 (Card Components)

#### 资源卡片 Resource Card
```css
/* 基础样式 */
.resource-card {
  background: white;
  border-radius: var(--radius-lg);
  padding: var(--space-md);
  box-shadow: var(--shadow-sm);
  border-left: 4px solid transparent;
  transition: all 0.3s ease;
  cursor: pointer;
}

/* 状态标识 */
.resource-card--not-started {
  border-left-color: var(--status-not-started);
}
.resource-card--learning {
  border-left-color: var(--status-learning);
}
.resource-card--mastered {
  border-left-color: var(--status-mastered);
}

/* 悬停效果 */
.resource-card:hover {
  transform: translateY(-2px);
  box-shadow: var(--shadow-md);
}
```

#### 音频卡片 Audio Player Card
```css
.audio-card {
  background: linear-gradient(135deg, #f0f7ff 0%, #e0f0ff 100%);
  border-radius: var(--radius-lg);
  padding: var(--space-lg);
  text-align: center;
  position: relative;
  overflow: hidden;
}

/* 音频波形可视化 */
.audio-visualizer {
  height: 60px;
  background: url('data:image/svg+xml,...');
  margin: var(--space-md) 0;
  border-radius: var(--radius-sm);
}
```

### 3. 表单组件 (Form Components)

#### 输入框 Input Field
```css
.input-field {
  width: 100%;
  height: 48px;
  padding: 0 var(--space-md);
  border: 1px solid var(--neutral-200);
  border-radius: var(--radius-md);
  font-size: var(--body);
  transition: all 0.2s ease;
}
.input-field:focus {
  outline: none;
  border-color: var(--primary-500);
  box-shadow: 0 0 0 3px var(--primary-100);
}
```

#### 滑动条 Slider
```css
.slider {
  width: 100%;
  height: 6px;
  border-radius: 3px;
  background: var(--neutral-200);
  outline: none;
  -webkit-appearance: none;
}
.slider::-webkit-slider-thumb {
  -webkit-appearance: none;
  width: 20px;
  height: 20px;
  border-radius: 50%;
  background: var(--primary-500);
  cursor: pointer;
  box-shadow: var(--shadow-sm);
}
```

### 4. 反馈组件 (Feedback Components)

#### 徽章 Badge
```css
.badge {
  display: inline-flex;
  align-items: center;
  padding: 2px var(--space-sm);
  border-radius: var(--radius-full);
  font-size: var(--caption);
  font-weight: 600;
  text-transform: uppercase;
}

.badge--pro {
  background: linear-gradient(135deg, var(--pro-gold) 0%, var(--pro-dark-gold) 100%);
  color: white;
}
.badge--new {
  background: var(--secondary-500);
  color: white;
}
```

#### 标签 Tag
```css
.tag {
  display: inline-flex;
  align-items: center;
  padding: var(--space-xs) var(--space-sm);
  border-radius: var(--radius-sm);
  font-size: var(--caption);
  background: var(--primary-50);
  color: var(--primary-700);
  border: 1px solid var(--primary-100);
}
```

### 5. 导航组件 (Navigation Components)

#### 底部导航 Bottom Navigation
```css
.bottom-nav {
  position: fixed;
  bottom: 0;
  left: 0;
  right: 0;
  height: 80px;
  background: white;
  border-top: 1px solid var(--neutral-200);
  display: flex;
  align-items: center;
  justify-content: space-around;
  padding-bottom: env(safe-area-inset-bottom);
  backdrop-filter: blur(10px);
}

.bottom-nav__item {
  flex: 1;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: var(--space-xs);
  color: var(--text-secondary);
  transition: color 0.2s ease;
}
.bottom-nav__item--active {
  color: var(--primary-500);
}
```

---

## 📱 页面设计规范 (Page Specifications)

### Page A: 资源库首页

#### 页面结构
```css
/* 布局结构 */
.page-a__header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: var(--space-md);
  border-bottom: 1px solid var(--neutral-200);
}

.page-a__search {
  padding: var(--space-md);
}

.page-a__filters {
  display: flex;
  gap: var(--space-sm);
  padding: 0 var(--space-md);
  overflow-x: auto;
}

.page-a__list {
  padding: var(--space-md);
}

.page-a__fab {
  position: fixed;
  bottom: calc(80px + var(--space-md)); /* 底部导航高度 + 间距 */
  right: var(--space-md);
}
```

#### 资源卡片详细设计
```css
/* 资源卡片内容布局 */
.resource-card__header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: var(--space-sm);
}

.resource-card__title {
  font-size: var(--h3);
  font-weight: 600;
  color: var(--text-primary);
  margin: 0;
}

.resource-card__meta {
  display: flex;
  gap: var(--space-lg);
  color: var(--text-secondary);
  font-size: var(--body-sm);
}

.resource-card__progress {
  margin-top: var(--space-md);
}

.progress-ring {
  width: 40px;
  height: 40px;
}
```

### Page B: 音频详情页

#### 音频播放器设计
```css
.audio-player {
  background: linear-gradient(135deg, var(--primary-50) 0%, white 100%);
  border-radius: var(--radius-xl);
  padding: var(--space-lg);
  margin: var(--space-md);
  box-shadow: var(--shadow-md);
}

.audio-player__title {
  font-size: var(--h2);
  font-weight: 700;
  text-align: center;
  margin-bottom: var(--space-md);
}

.audio-player__waveform {
  height: 100px;
  background: rgba(30, 64, 175, 0.1);
  border-radius: var(--radius-sm);
  margin: var(--space-md) 0;
  position: relative;
  overflow: hidden;
}

/* 波形动画 */
.waveform-bar {
  position: absolute;
  bottom: 0;
  width: 2px;
  background: var(--primary-500);
  animation: wave 1s ease-in-out infinite;
}

@keyframes wave {
  0%, 100% { height: 20%; }
  50% { height: 80%; }
}
```

#### 学习单元列表
```css
.segment-list__header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: var(--space-md);
  border-top: 1px solid var(--neutral-200);
}

.segment-item {
  display: grid;
  grid-template-columns: 60px 1fr 100px;
  gap: var(--space-md);
  padding: var(--space-md);
  border-bottom: 1px solid var(--neutral-100);
  cursor: pointer;
  transition: background 0.2s ease;
}

.segment-item:hover {
  background: var(--primary-50);
}

.segment-item__number {
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: var(--h3);
  font-weight: 700;
  color: var(--primary-500);
}
```

### Page C: 精听学习页

#### 字幕同步显示
```css
.transcript-container {
  background: white;
  border-radius: var(--radius-lg);
  padding: var(--space-lg);
  margin: var(--space-md);
  box-shadow: var(--shadow-sm);
  min-height: 200px;
}

.transcript-line {
  font-size: var(--body-lg);
  line-height: 1.8;
  margin-bottom: var(--space-sm);
  opacity: 0.6;
  transition: opacity 0.3s ease;
  position: relative;
  padding: var(--space-xs) var(--space-sm);
  border-radius: var(--radius-sm);
}

.transcript-line--active {
  opacity: 1;
  background: var(--primary-50);
  font-weight: 500;
}
```

#### 词法分析面板
```css
.analysis-panel {
  background: white;
  border-radius: var(--radius-lg);
  margin: var(--space-md);
  overflow: hidden;
  box-shadow: var(--shadow-sm);
}

.analysis-panel__header {
  padding: var(--space-md);
  border-bottom: 1px solid var(--neutral-200);
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.analysis-item {
  padding: var(--space-md);
  border-bottom: 1px solid var(--neutral-100);
}

.analysis-item:last-child {
  border-bottom: none;
}

.analysis-item__word {
  font-size: var(--h3);
  font-weight: 700;
  color: var(--text-primary);
  margin-bottom: var(--space-xs);
}

.analysis-item__reading {
  font-size: var(--body-sm);
  color: var(--text-secondary);
  margin-bottom: var(--space-sm);
}
```

---

## 🎭 交互与动效 (Interaction & Animation)

### 转场动画 Transition Effects

#### 页面切换
```css
.page-enter {
  opacity: 0;
  transform: translateX(100px);
}

.page-enter-active {
  opacity: 1;
  transform: translateX(0);
  transition: opacity 0.3s ease, transform 0.3s ease;
}

.page-exit {
  opacity: 1;
  transform: translateX(0);
}

.page-exit-active {
  opacity: 0;
  transform: translateX(-100px);
  transition: opacity 0.3s ease, transform 0.3s ease;
}
```

#### 卡片交互
```css
.card-hover {
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}

.card-hover:hover {
  transform: translateY(-4px);
  box-shadow: 0 10px 25px rgba(0, 0, 0, 0.15);
}
```

### 微交互 Micro-Interactions

#### 按钮点击反馈
```css
.button-ripple {
  position: relative;
  overflow: hidden;
}

.button-ripple::after {
  content: '';
  position: absolute;
  top: 50%;
  left: 50%;
  width: 0;
  height: 0;
  border-radius: 50%;
  background: rgba(255, 255, 255, 0.5);
  transform: translate(-50%, -50%);
  transition: width 0.6s, height 0.6s;
}

.button-ripple:active::after {
  width: 300px;
  height: 300px;
}
```

#### 进度环动画
```css
.progress-ring {
  transform: rotate(-90deg);
}

.progress-ring__circle {
  stroke: var(--primary-500);
  stroke-linecap: round;
  transition: stroke-dasharray 0.5s ease;
  filter: drop-shadow(0 0 4px rgba(30, 64, 175, 0.3));
}
```

### 加载状态 Loading States

#### 骨架屏
```css
.skeleton {
  background: linear-gradient(90deg, var(--neutral-100) 25%, var(--neutral-200) 50%, var(--neutral-100) 75%);
  background-size: 200% 100%;
  animation: loading 1.5s infinite;
}

@keyframes loading {
  0% { background-position: 200% 0; }
  100% { background-position: -200% 0; }
}
```

#### 音频加载
```css
.audio-loading {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: var(--space-xs);
}

.audio-loading__dot {
  width: 8px;
  height: 8px;
  border-radius: 50%;
  background: var(--primary-500);
  animation: pulse 1.5s ease-in-out infinite;
}

.audio-loading__dot:nth-child(2) {
  animation-delay: 0.2s;
}

.audio-loading__dot:nth-child(3) {
  animation-delay: 0.4s;
}

@keyframes pulse {
  0%, 100% { transform: scale(0.8); opacity: 0.5; }
  50% { transform: scale(1.2); opacity: 1; }
}
```

---

## 🎯 状态管理 (State Management)

### 用户状态 User States

#### 免费用户 Free User
- 基础功能完整体验
- PRO功能展示为锁定状态
- 渐进式引导升级

#### PRO用户 PRO User
- 全功能解锁
- 专属标识和主题
- 优先体验新功能

### 学习状态 Learning States

#### 资源状态 Resource States
```css
/* 未开始 */
.status-not-started {
  --status-color: var(--neutral-500);
}

/* 学习中 (0-99%) */
.status-learning {
  --status-color: var(--primary-500);
}

/* 已完成 (100%) */
.status-completed {
  --status-color: var(--success-500);
}
```

#### 学习进度可视化
```css
.progress-visual {
  display: flex;
  align-items: center;
  gap: var(--space-sm);
}

.progress-ring__background {
  fill: none;
  stroke: var(--neutral-200);
}

.progress-ring__progress {
  fill: none;
  stroke: var(--status-color);
  stroke-linecap: round;
  transition: stroke-dashoffset 0.5s ease;
}
```

---

## 📐 响应式设计 (Responsive Design)

### 断点系统 Breakpoints
```css
/* 移动端 Mobile */
@media (max-width: 428px) {
  --container-padding: var(--space-md);
  --font-scale: 1;
}

/* 平板横屏 Tablet Landscape */
@media (min-width: 768px) {
  --container-max-width: 600px;
  --container-padding: var(--space-lg);

  /* 横屏布局 */
  .landscape-layout {
    display: grid;
    grid-template-columns: 1fr 400px;
    gap: var(--space-lg);
  }
}
```

### 自适应组件

#### 横屏音频播放器
```css
@media (orientation: landscape) {
  .audio-player--landscape {
    position: sticky;
    top: var(--space-md);
    height: fit-content;
  }

  .transcript-container {
    max-height: 60vh;
    overflow-y: auto;
  }
}
```

---

## ♿ 无障碍设计 (Accessibility)

### 颜色对比
- 所有文字与背景对比度 ≥ 4.5:1
- 大文字对比度 ≥ 3:1
- 色盲友好配色方案

### 字体可读性
- 最小字体12px (1rem)
- 支持动态字体缩放
- 行高 ≥ 1.5倍字体大小

### 交互可操作
- 点击区域 ≥ 44px × 44px
- 支持键盘导航
- 屏幕阅读器标签完整

### 动效偏好
```css
/* 尊重用户动效偏好 */
@media (prefers-reduced-motion: reduce) {
  * {
    animation-duration: 0.01ms !important;
    animation-iteration-count: 1 !important;
    transition-duration: 0.01ms !important;
  }
}
```

---

## 🎪 品牌元素 (Brand Elements)

### Logo设计规范
```css
.logo {
  font-family: var(--font-display);
  font-weight: 700;
  font-size: 24px;
  color: var(--primary-500);
  position: relative;
  display: inline-block;
}

.logo::after {
  content: '🐰';
  position: absolute;
  right: -30px;
  top: -5px;
  font-size: 20px;
  animation: bounce 2s infinite;
}

@keyframes bounce {
  0%, 100% { transform: translateY(0); }
  50% { transform: translateY(-5px); }
}
```

### PRO专属标识
```css
.pro-badge {
  background: linear-gradient(135deg, var(--pro-gold) 0%, var(--pro-dark-gold) 100%);
  color: white;
  padding: 2px 8px;
  border-radius: var(--radius-full);
  font-size: 10px;
  font-weight: 700;
  text-transform: uppercase;
  box-shadow: 0 2px 4px rgba(245, 158, 11, 0.3);
}
```

---

## 📊 设计交付物 (Design Deliverables)

### Figma文件结构
```
Rabbit_App_Design_System.fig
├── 📁 01_设计基础知识
│   ├── 色彩系统
│   ├── 字体系统
│   └── 效果系统
├── 📁 02_组件库
│   ├── 按钮组件
│   ├── 卡片组件
│   ├── 导航组件
│   └── 反馈组件
├── 📁 03_页面设计
│   ├── 页面A_资源库
│   ├── 页面B_详情页
│   └── 页面C_学习页
├── 📁 04_交互原型
│   ├── 页面切换流程
│   ├── 学习流程
│   └── 升级流程
└── 📁 05_资源素材
    ├── 图标库
    └── 插画素材
```

### 切图资源清单
- [ ] App图标 (iOS/Android/网页)
- [ ] 功能图标 (SVG格式)
- [ ] 插画素材 (PNG/SVG)
- [ ] 启动画面素材
- [ ] PRO标识素材

### 开发交接清单
- [ ] 完整CSS变量系统
- [ ] 组件代码片段
- [ ] 动画参数说明
- [ ] 响应式断点说明
- [ ] 无障碍设计规范

---

## 🔮 未来迭代规划 (Future Iterations)

### 短期 (1-2个月)
1. 暗黑模式主题
2. 学习报告可视化
3. 社区分享功能

### 中期 (3-6个月)
1. AI个性化推荐
2. 多人协作学习
3. 云端同步优化

### 长期 (6个月以上)
1. 多语言支持
2. 语音识别集成
3. 智能学习路径规划

---

**文档维护**: 每月更新一次设计规范，与开发版本同步
**版本控制**: 使用Figma的版本历史功能
**反馈收集**: 定期收集团队反馈，持续优化设计系统

*本设计系统遵循 Material Design 3 规范，并结合日语学习App特性进行了定制优化*
