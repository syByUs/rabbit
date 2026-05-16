/// 视频转换服务使用示例
///
/// 这个文件展示了如何使用 VideoConversionService 进行视频格式转换

import 'video_conversion_service.dart';

/// 示例 1: 基本转换（自动生成输出路径）
Future<void> basicConversionExample() async {
  try {
    final inputPath = '/Users/xxx/视频/test.mkv';

    // 转换视频，输出路径自动生成为 /Users/xxx/视频/test_h264.mp4
    final outputPath = await VideoConversionService.convertToH264(
      inputPath: inputPath,
    );

    print('转换成功！输出文件: $outputPath');
  } catch (e) {
    print('转换失败: $e');
  }
}

/// 示例 2: 指定输出路径
Future<void> customOutputPathExample() async {
  try {
    final inputPath = '/Users/xxx/视频/test.mkv';
    final outputPath = '/Users/xxx/视频/out_h264_g711.mp4';

    // 转换视频到指定路径
    final result = await VideoConversionService.convertToH264(
      inputPath: inputPath,
      outputPath: outputPath,
    );

    print('转换成功！输出文件: $result');
  } catch (e) {
    print('转换失败: $e');
  }
}

/// 示例 3: 带进度回调的转换
Future<void> conversionWithProgressExample() async {
  try {
    final inputPath = '/Users/xxx/视频/test.mkv';

    // 转换视频并监听进度
    final outputPath = await VideoConversionService.convertToH264(
      inputPath: inputPath,
      onProgress: (progress) {
        print('转换进度: ${progress.toStringAsFixed(1)}%');
      },
    );

    print('转换成功！输出文件: $outputPath');
  } catch (e) {
    print('转换失败: $e');
  }
}

/// 示例 4: 检查视频是否需要转换
Future<void> checkConversionNeededExample() async {
  try {
    final videoPath = '/Users/xxx/视频/test.mkv';

    // 检查视频编码格式
    final needsConversion = await VideoConversionService.needsConversion(
      videoPath,
    );

    if (needsConversion) {
      print('视频需要转换为 H.264 格式');

      // 执行转换
      final outputPath = await VideoConversionService.convertToH264(
        inputPath: videoPath,
      );

      print('转换完成: $outputPath');
    } else {
      print('视频已是 H.264 格式，无需转换');
    }
  } catch (e) {
    print('操作失败: $e');
  }
}

/// 示例 5: 获取视频信息
Future<void> getVideoInfoExample() async {
  try {
    final videoPath = '/Users/xxx/视频/test.mkv';

    // 获取视频信息
    final info = await VideoConversionService.getVideoInfo(videoPath);

    print('视频信息:');
    print('  时长: ${info['duration']}');
    print('  视频编码: ${info['videoCodec']}');
    print('  音频编码: ${info['audioCodec']}');
  } catch (e) {
    print('获取视频信息失败: $e');
  }
}
