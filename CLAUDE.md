# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 项目概述

这是一个名为 "rabbit" 的 Flutter 应用，使用 Dart SDK ^3.10.0-88.0.dev。项目采用 Riverpod 进行状态管理，Dio 进行网络请求，并使用 Freezed 进行不可变数据模型和代码生成。

## 常用命令

### 运行应用
```bash
# 运行 Flutter 应用
flutter run

# 以特定设备运行
flutter run -d <设备ID>
```

### 构建
```bash
# 构建 Android APK
flutter build apk

# 构建 Android App Bundle
flutter build appbundle

# 构建 iOS
flutter build ios

# 构建 Web
flutter build web
```

### 测试
```bash
# 运行所有测试
flutter test

# 运行特定测试文件
flutter test test/widget_test.dart

# 带覆盖率运行测试
flutter test --coverage
```

### 代码质量
```bash
# 静态分析
flutter analyze

# 获取依赖
flutter pub get

# 更新依赖
flutter pub upgrade
```

### 代码生成
```bash
# 运行代码生成（Freezed、JSON 序列化、Riverpod）
flutter pub run build_runner build

# 运行代码生成并删除冲突文件
flutter pub run build_runner build --delete-conflicting-outputs

# 监听文件变化并自动生成代码
flutter pub run build_runner watch
```

### 热重载
当通过 `flutter run` 运行应用时，使用：
- `r` 热重载（保留应用状态）
- `R` 热重启（重置应用状态）

## 架构概览

### 项目结构
```
lib/
├── main.dart              # 应用入口（包裹在 ProviderScope 中）
├── core/                  # 核心基础设施
│   ├── network/          # 网络层
│   │   ├── dio_client.dart    # Dio HTTP 客户端封装
│   │   └── api_constants.dart # API 常量
│   ├── providers/        # 全局 providers
│   │   ├── dio_provider.dart  # DioClient provider
│   │   └── providers.dart     # 导出所有 providers
│   └── utils/            # 工具类
│       └── audio_helper.dart  # 音频播放工具
└── features/             # 功能模块（按功能组织代码）
assets/                    # 应用资源
├── audio/                 # 音频文件（mp3、wav、m4a、aac、ogg）
test/                      # 测试文件
```

### 应用入口
应用在 `lib/main.dart:4` 通过 ProviderScope 启动（Riverpod 必需）。MyApp 是一个 ConsumerWidget，配置 MaterialApp 和主题设置。

### 状态管理（Riverpod）
- 需要访问状态的 Widget 应继承 ConsumerWidget 或 ConsumerStatefulWidget
- 通过 ref.watch()、ref.read() 或 ref.listen() 访问 providers
- 全局 providers 定义在 `lib/core/providers/`
- 功能特定的 providers 应在 `lib/features/{feature_name}/providers/` 中

### 网络层
**DioClient** (`lib/core/network/dio_client.dart`) 提供：
- 基于拦截器的请求/响应日志
- 自动错误处理和自定义异常
- 支持 GET、POST、PUT、DELETE、PATCH 方法

**API 常量** (`lib/core/network/api_constants.dart`) - 定义基础 URL 和端点

**Dio Provider** (`lib/core/providers/dio_provider.dart`) - DioClient 实例的 Riverpod provider

在 providers/services 中访问 HTTP 客户端：
```dart
final dio = ref.read(dioClientProvider);
```

### 音频播放
**AudioHelper** (`lib/core/utils/audio_helper.dart`) - 音频文件播放工具类
- 支持从 assets 和 URL 播放
- 提供播放控制（暂停、恢复、停止、音量调节）

## 功能模块模式

创建新功能时，按以下结构组织：
```
lib/features/{feature_name}/
├── models/          # 使用 Freezed 的数据模型
├── providers/       # Riverpod providers 和状态管理器
├── screens/         # UI 页面
└── widgets/         # 功能相关的可复用 widget
```

## 关键依赖

- **flutter_riverpod** (^2.6.1) - 状态管理
- **dio** (^5.7.0) - HTTP 网络请求
- **audioplayers** (^6.1.0) - 音频播放
- **freezed** (^2.5.7) - 不可变类的代码生成
- **json_serializable** (^6.8.0) - JSON 序列化/反序列化
- **riverpod_generator** (^2.6.2) - 使用 @riverpod 注解自动生成 providers

## 开发注意事项

- 使用 `analysis_options.yaml` 中的 `package:flutter_lints/flutter.yaml` 配置 lint
- 使用 Material Design，颜色方案从 Colors.deepPurple 生成
- 项目标记为 `publish_to: 'none'` - 这是私有应用，不发布到 pub.dev
- 资源文件放在 `assets/audio/` 目录
