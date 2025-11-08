import 'package:ffmpeg_kit_flutter_new_audio/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new_audio/return_code.dart';
import '../models/audio_segment_model.dart';

/// 音频分割服务
/// 使用 ffmpeg_kit 检测静音点并分割音频
class AudioSegmentationService {
  /// 检测音频文件中的静音点
  ///
  /// [audioPath] 音频文件路径（可以是 assets 或本地文件）
  /// [silenceDuration] 静音时长阈值（秒），默认 0.5 秒
  /// [silenceThreshold] 静音分贝阈值，默认 -40dB
  static Future<List<AudioSegment>> detectSilencePoints({
    required String audioPath,
    double silenceDuration = 0.5,
    double silenceThreshold = -40,
  }) async {
    final segments = <AudioSegment>[];

    try {
      // 使用 ffmpeg 的 silencedetect 滤镜检测静音点
      final command =
          '-i "$audioPath" -af "silencedetect=n=${silenceThreshold}dB:d=$silenceDuration" -f null -';

      await FFmpegKit.executeAsync(command, (session) async {
        final returnCode = await session.getReturnCode();

        if (ReturnCode.isSuccess(returnCode)) {
          // 获取输出日志
          final logs = await session.getLogs();
          final silencePoints = _parseSilencePoints(logs);
          segments.addAll(silencePoints);
        } else {
          throw Exception('FFmpeg 执行失败: ${await session.getFailStackTrace()}');
        }
      });
    } catch (e) {
      throw Exception('静音检测失败: $e');
    }

    return segments;
  }

  /// 解析 ffmpeg 输出日志中的静音点
  static List<AudioSegment> _parseSilencePoints(List<dynamic> logs) {
    final segments = <AudioSegment>[];
    final List<double> silenceStarts = [];
    final List<double> silenceEnds = [];

    for (var log in logs) {
      final message = log.getMessage() as String;

      // 解析静音开始时间
      if (message.contains('silence_start:')) {
        final startTime = _extractTime(message, 'silence_start:');
        if (startTime != null) {
          silenceStarts.add(startTime);
        }
      }

      // 解析静音结束时间
      if (message.contains('silence_end:')) {
        final endTime = _extractTime(message, 'silence_end:');
        if (endTime != null) {
          silenceEnds.add(endTime);
        }
      }
    }

    // 创建音频片段
    double currentStart = 0.0;
    for (int i = 0; i < silenceStarts.length; i++) {
      final segmentEnd = silenceStarts[i];

      if (segmentEnd > currentStart) {
        segments.add(AudioSegment(
          start: currentStart,
          end: segmentEnd,
          isSilence: false,
        ));
      }

      // 添加静音片段
      if (i < silenceEnds.length) {
        segments.add(AudioSegment(
          start: segmentEnd,
          end: silenceEnds[i],
          isSilence: true,
        ));
        currentStart = silenceEnds[i];
      }
    }

    return segments;
  }

  /// 从日志消息中提取时间值
  static double? _extractTime(String message, String prefix) {
    try {
      final startIndex = message.indexOf(prefix) + prefix.length;
      final endIndex = message.indexOf(' ', startIndex);
      final timeStr = message.substring(startIndex, endIndex > 0 ? endIndex : null).trim();
      return double.tryParse(timeStr);
    } catch (e) {
      return null;
    }
  }

  /// 使用检测到的静音点分割音频文件
  ///
  /// [inputPath] 输入音频文件路径
  /// [outputDir] 输出目录
  /// [segments] 分割点列表
  static Future<List<String>> segmentAudio({
    required String inputPath,
    required String outputDir,
    required List<AudioSegment> segments,
  }) async {
    final outputPaths = <String>[];

    try {
      // 为每个非静音片段创建单独的音频文件
      int segmentIndex = 0;
      for (var segment in segments) {
        if (!segment.isSilence && segment.duration > 1.0) {
          // 只导出非静音片段且时长大于1秒的
          final outputPath = '$outputDir/segment_${segmentIndex++}.mp3';

          final command =
              '-i "$inputPath" -ss ${segment.start} -t ${segment.duration} -acodec copy "$outputPath"';

          await FFmpegKit.executeAsync(command, (session) async {
            final returnCode = await session.getReturnCode();
            if (ReturnCode.isSuccess(returnCode)) {
              outputPaths.add(outputPath);
            }
          });
        }
      }
    } catch (e) {
      throw Exception('音频分割失败: $e');
    }

    return outputPaths;
  }
}
