# FFmpeg Kit Flutter 安装和配置指南

## 错误说明

`MissingPluginException` 错误表示 Flutter 无法找到原生平台的 FFmpeg Kit 实现。这通常发生在：

1. 插件未正确安装
2. 需要重新构建应用
3. iOS/Android 平台配置问题

## 解决方案

### 步骤 1: 清理项目

```bash
# 清理构建缓存
flutter clean

# 重新获取依赖
flutter pub get
```

### 步骤 2: iOS 平台配置

对于 iOS，需要在 `ios/Podfile` 中添加 FFmpeg Kit 配置：

```ruby
# 在 Podfile 顶部添加
platform :ios, '12.0'

# 在 target 块中添加
target 'Runner' do
  use_frameworks!
  use_modular_headers!

  # 添加这一行
  pod 'ffmpeg-kit-react-native', :subspecs => ['audio'], :podspec => 'https://raw.githubusercontent.com/arthenica/ffmpeg-kit/main/react-native/ffmpeg-kit-react-native-audio.podspec'

  flutter_install_all_ios_pods File.dirname(File.realpath(__FILE__))
end
```

然后运行：
```bash
cd ios
pod install
pod update ffmpeg_kit_flutter_new_audio
cd ..
```

### 步骤 3: Android 平台配置

对于 Android，需要在 `android/app/build.gradle` 中添加：

```gradle
android {
    compileSdkVersion 33

    defaultConfig {
        minSdkVersion 24
        targetSdkVersion 33

        // 添加这一行
        ndk {
            abiFilters 'armeabi-v7a', 'arm64-v8a', 'x86', 'x86_64'
        }
    }

    packagingOptions {
        pickFirst 'lib/armeabi-v7a/libc++_shared.so'
        pickFirst 'lib/arm64-v8a/libc++_shared.so'
        pickFirst 'lib/x86/libc++_shared.so'
        pickFirst 'lib/x86_64/libc++_shared.so'
    }
}
```

### 步骤 4: 重新构建应用

完全停止应用并重新启动（重要！）：

```bash
# 停止所有 Dart/Flutter 进程
flutter clean

# 重新获取依赖
flutter pub get

# 重新运行应用
flutter run
```

## 验证安装

创建一个测试文件来验证 FFmpeg Kit 是否工作：

```dart
import 'package:ffmpeg_kit_flutter_new_audio/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new_audio/return_code.dart';

Future<void> testFFmpeg() async {
  try {
    final session = await FFmpegKit.execute('-version');
    final returnCode = await session.getReturnCode();

    if (ReturnCode.isSuccess(returnCode)) {
      print('✅ FFmpeg Kit 已成功安装！');
    } else {
      print('❌ FFmpeg Kit 安装失败');
    }
  } catch (e) {
    print('❌ 错误: $e');
  }
}
```

## 常见问题

### 1. iOS 构建失败

如果 `pod install` 失败，尝试：
```bash
cd ios
rm -rf Pods Podfile.lock
pod install --repo-update
cd ..
```

### 2. Android 构建失败

如果 Gradle 同步失败，确保你的 `android/build.gradle` 中有：

```gradle
allprojects {
    repositories {
        google()
        mavenCentral()
        maven { url 'https://jitpack.io' }  // 添加这一行
    }
}
```

### 3. 完全重新安装

如果以上方法都无效，尝试完全删除并重建：

```bash
# 删除所有构建文件
rm -rf build/
rm -rf ios/Pods
rm -rf ios/Podfile.lock
rm -rf .dart_tool/

# 重新安装
flutter pub get
cd ios && pod install && cd ..

# 运行
flutter run
```

## 替代方案

如果仍然无法解决，可以考虑使用其他音频处理库：

1. **audioplayers** (已集成) - 用于音频播放
2. **flutter_ffmpeg** (旧版本) - 另一个 FFmpeg 封装
3. **just_audio** + **audio_service** - 用于音频处理

但是，FFmpeg Kit 是功能最完整的选择，强烈建议按照上述步骤正确配置。
