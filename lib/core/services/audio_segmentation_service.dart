
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';


import '../models/audio_segment_model.dart';

/// 音频分割服务
/// 使用 ffmpeg_kit 检测静音点并分割音频
class AudioSegmentationService {
  /// 检测音频文件中的静音点
  ///
  /// [audioPath] 音频文件路径（可以是 assets 或本地文件）
  /// [silenceDuration] 静音时长阈值（秒），默认 0.5 秒
  /// [silenceThreshold] 静音分贝阈值，默认 -40dB
  /// @returns 返回检测到的音频片段列表，如果未检测到静音点则返回空列表
  static Future<List<AudioSegment>> detectSilencePoints({
    required String audioPath,
    double silenceDuration = 0.5,
    double silenceThreshold = -40,
  }) async {
    try {
      // 使用 ffmpeg 的 silencedetect 滤镜检测静音点
      final command =
          '-i "$audioPath" -af "silencedetect=noise=${silenceThreshold}dB:d=$silenceDuration" -f null -';
      print('command: ${command}');

      // 使用 execute 代替 executeAsync，同步等待结果
      final session = await FFmpegKit.execute(command);
      final returnCode = await session.getReturnCode();

      if (ReturnCode.isSuccess(returnCode)) {
        // 获取输出日志
        final logs = await session.getLogs();
        final segments = _parseSilencePoints(logs);

        if (segments.isEmpty) {
          print('未检测到静音点，直接返回空列表');
        }

        return segments;
      } else {
        final failStackTrace = await session.getFailStackTrace();
        final output = await session.getOutput();
        throw Exception('FFmpeg 执行失败: ${failStackTrace ?? output}');
      }
    } catch (e) {
      throw Exception('静音检测失败: $e');
    }
  }

  /// 解析 ffmpeg 输出日志中的静音点
  static List<AudioSegment> _parseSilencePoints(List<dynamic> logs) {
    final segments = <AudioSegment>[];
    final List<double> silenceStarts = [];
    final List<double> silenceEnds = [];
    print('logs: ${logs}');
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
    // [silencedetect @ 0x14fa84840] silence_start: 3.891188
    // silence_start:

    // [silencedetect @ 0x14d097420] silence_end: 0.826375 | silence_duration: 0.826375
    // silence_end:
    RegExp regExp = RegExp(prefix + r'\s*([0-9.]+)');
    Match? match = regExp.firstMatch(message);

    if (match != null) {
      double value = double.parse(match.group(1)!);
      print('提取到的数值是: $value');
      return value;
    } else {
      print('未找到匹配的数值');
      return null;
    }

  }

  /// 按时间均匀分割音频文件（备用方案）
  ///
  /// [audioPath] 音频文件路径
  /// [segmentDuration] 每个片段的时长（秒）
  static Future<List<AudioSegment>> _splitByTime({
    required String audioPath,
    required double segmentDuration,
  }) async {
    try {
      // 使用 ffprobe 获取音频总时长
      final infoCommand = '-i "$audioPath"';
      final infoSession = await FFmpegKit.execute(infoCommand);
      final logs = await infoSession.getLogs();

      // 查找时长信息
      final durationLine = logs.firstWhere(
        (log) {
          final message = log.getMessage() as String?;
          return message != null && message.contains('Duration:');
        },
        orElse: () => throw Exception('无法获取音频时长'),
      );

      final message = durationLine.getMessage() as String;
      // Duration: 00:00:05.12, start: 0.000000, bitrate: 128 kb/s
      final durationMatch = RegExp(r'Duration: (\d+):(\d+):(\d+\.\d+)').firstMatch(message);

      if (durationMatch == null) {
        throw Exception('无法解析音频时长');
      }

      // 解析时长
      final hours = int.parse(durationMatch.group(1)!);
      final minutes = int.parse(durationMatch.group(2)!);
      final seconds = double.parse(durationMatch.group(3)!);
      final totalDuration = hours * 3600 + minutes * 60 + seconds;

      print('音频总时长: ${totalDuration}s，将按 ${segmentDuration}s 分割');

      // 创建均匀分割的片段
      final segments = <AudioSegment>[];
      double currentStart = 0.0;

      while (currentStart < totalDuration) {
        final currentEnd = (currentStart + segmentDuration) < totalDuration
            ? currentStart + segmentDuration
            : totalDuration;

        if (currentEnd > currentStart) {
          segments.add(AudioSegment(
            start: currentStart,
            end: currentEnd,
            isSilence: false,
          ));
        }

        currentStart = currentEnd;
      }

      print('备用分割方案：生成 ${segments.length} 个均匀片段');
      return segments;
    } catch (e) {
      print('备用分割方案失败: $e');
      // 如果备用方案也失败，返回一个包含整个音频的片段（默认30秒）
      return [AudioSegment(
        start: 0.0,
        end: 30.0,
        isSilence: false,
      )];
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

          // 使用同步执行
          final session = await FFmpegKit.execute(command);
          final returnCode = await session.getReturnCode();

          if (ReturnCode.isSuccess(returnCode)) {
            outputPaths.add(outputPath);
          }
        }
      }
    } catch (e) {
      throw Exception('音频分割失败: $e');
    }

    return outputPaths;
  }
}
