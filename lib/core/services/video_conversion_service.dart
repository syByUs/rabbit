import 'dart:io';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import 'package:path/path.dart' as path;

/// 视频转换服务
/// 使用 ffmpeg_kit 将视频文件转换为 H.264 编码的 MP4 格式
class VideoConversionService {
  /// 将 MKV 或其他格式的视频转换为 H.264 编码的 MP4
  ///
  /// [inputPath] 输入视频文件路径
  /// [outputPath] 输出文件路径（可选，默认在同目录生成 _h264.mp4）
  /// [onProgress] 进度回调函数，参数为进度百分比 (0-100)
  /// @returns 转换后的文件路径
  static Future<String> convertToH264({
    required String inputPath,
    String? outputPath,
    Function(double progress)? onProgress,
  }) async {
    try {
      // 检查输入文件是否存在
      final inputFile = File(inputPath);
      if (!await inputFile.exists()) {
        throw Exception('输入文件不存在: $inputPath');
      }

      // 生成输出路径
      final output = outputPath ?? _generateOutputPath(inputPath);

      // 确保输出目录存在
      final outputDir = Directory(path.dirname(output));
      if (!await outputDir.exists()) {
        await outputDir.create(recursive: true);
      }

      print('🎬 开始视频转换');
      print('   输入: $inputPath');
      print('   输出: $output');

      // 构建 ffmpeg 命令
      // -y: 覆盖输出文件
      // -i: 输入文件
      // -c:v libx264: 使用 H.264 视频编码
      // -preset fast: 编码速度预设（fast 平衡速度和质量）
      // -c:a copy: 音频流直接复制，不重新编码
      // final command =
      //     '-y -i "$inputPath" -c:v libx264 -preset fast -c:a copy "$output"';

      final command = '-y -i "${inputPath}" -c:v libx264 -preset fast -c:a aac "${output}"';
      print('   FFmpeg命令: ffmpeg $command');

      // 执行转换
      final session = await FFmpegKit.executeAsync(
        command,
        (session) async {
          final returnCode = await session.getReturnCode();
          if (ReturnCode.isSuccess(returnCode)) {
            print('✅ 视频转换成功: $output');
            onProgress?.call(100.0);
          } else {
            final failStackTrace = await session.getFailStackTrace();
            final output = await session.getOutput();
            print('❌ 视频转换失败: ${failStackTrace ?? output}');
          }
        },
        null, // log callback
        (statistics) {
          // 处理进度统计
          if (onProgress != null) {
            final time = statistics.getTime();
            // 这里需要知道视频总时长才能计算准确进度
            // 简化处理：每秒更新一次进度提示
            if (time > 0) {
              print('⏱️ 处理中... 已处理 ${(time / 1000).toStringAsFixed(1)}秒');
            }
          }
        },
      );

      // 等待转换完成
      final returnCode = await session.getReturnCode();

      if (ReturnCode.isSuccess(returnCode)) {
        // 验证输出文件是否存在
        final outputFile = File(output);
        if (await outputFile.exists()) {
          final fileSize = await outputFile.length();
          print(
            '✅ 转换完成，文件大小: ${(fileSize / 1024 / 1024).toStringAsFixed(2)} MB',
          );
          return output;
        } else {
          throw Exception('转换完成但输出文件不存在');
        }
      } else {
        final failStackTrace = await session.getFailStackTrace();
        final sessionOutput = await session.getOutput();
        throw Exception('FFmpeg 执行失败: ${failStackTrace ?? sessionOutput}');
      }
    } catch (e) {
      print('❌ 视频转换失败: $e');
      throw Exception('视频转换失败: $e');
    }
  }

  /// 生成输出文件路径
  ///
  /// [inputPath] 输入文件路径
  /// @returns 输出文件路径（在同目录下，文件名添加 _h264 后缀）
  static String _generateOutputPath(String inputPath) {
    final dir = path.dirname(inputPath);
    final filename = path.basenameWithoutExtension(inputPath);
    return path.join(dir, '${filename}_h264.mp4');
  }

  /// 获取视频信息（时长、编码格式等）
  ///
  /// [videoPath] 视频文件路径
  /// @returns 包含视频信息的 Map
  static Future<Map<String, dynamic>> getVideoInfo(String videoPath) async {
    try {
      final command = '-i "$videoPath"';
      final session = await FFmpegKit.execute(command);
      final logs = await session.getAllLogs();

      String? duration;
      String? videoCodec;
      String? audioCodec;

      for (var log in logs) {
        final message = log.getMessage();

        // 提取时长
        if (message.contains('Duration:')) {
          final match = RegExp(
            r'Duration:\s*(\d+:\d+:\d+\.\d+)',
          ).firstMatch(message);
          if (match != null) {
            duration = match.group(1);
          }
        }

        // 提取视频编码
        if (message.contains('Video:')) {
          final match = RegExp(r'Video:\s*(\w+)').firstMatch(message);
          if (match != null) {
            videoCodec = match.group(1);
          }
        }

        // 提取音频编码
        if (message.contains('Audio:')) {
          final match = RegExp(r'Audio:\s*(\w+)').firstMatch(message);
          if (match != null) {
            audioCodec = match.group(1);
          }
        }
      }

      return {
        'duration': duration,
        'videoCodec': videoCodec,
        'audioCodec': audioCodec,
      };
    } catch (e) {
      print('❌ 获取视频信息失败: $e');
      return {};
    }
  }

  /// 检查视频是否需要转换
  ///
  /// [videoPath] 视频文件路径
  /// @returns true 表示需要转换，false 表示不需要
  static Future<bool> needsConversion(String videoPath) async {
    try {
      final info = await getVideoInfo(videoPath);
      final videoCodec = info['videoCodec'] as String?;

      // 如果视频编码不是 h264，则需要转换
      if (videoCodec != null && videoCodec.toLowerCase() != 'h264') {
        print('📹 视频编码: $videoCodec，需要转换为 H.264');
        return true;
      }

      print('✅ 视频已是 H.264 编码，无需转换');
      return false;
    } catch (e) {
      print('⚠️ 无法检测视频编码，建议转换: $e');
      return true; // 无法检测时，建议转换
    }
  }
}
