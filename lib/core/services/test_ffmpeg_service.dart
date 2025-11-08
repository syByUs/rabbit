import 'dart:io';

import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import '../services/audio_cache_service.dart';

/// FFmpeg 测试服务
class TestFFmpegService {
  /// 测试 FFmpeg 是否能正确读取音频文件
  static Future<void> testAudioFile() async {
    final audioCacheService = AudioCacheService.instance;
    await audioCacheService.initialize();

    // 测试第一个音频文件
    final audioPath = await audioCacheService.getAudioFilePath('audio/getvoice1.mp3');

    print('=== FFmpeg 音频文件测试 ===');
    print('音频文件路径: $audioPath');
    print('文件是否存在: ${File(audioPath).existsSync()}');

    try {
      // 1. 先测试 FFmpeg 是否能读取文件信息
      final infoCommand = '-i "$audioPath"';
      print('\n1. 测试获取音频信息...');
      print('执行命令: $infoCommand');

      final infoSession = await FFmpegKit.execute(infoCommand);
      final infoReturnCode = await infoSession.getReturnCode();
      final infoOutput = await infoSession.getOutput();

      if (ReturnCode.isSuccess(infoReturnCode)) {
        print('✅ 音频信息读取成功');
      } else {
        print('❌ 音频信息读取失败');
        print('输出: $infoOutput');
      }

      // 2. 测试静音检测，使用极低阈值
      print('\n2. 测试静音检测（超敏感模式）...');
      final silenceCommand =
          '-i "$audioPath" -af "silencedetect=n=-20dB:d=0.1" -f null -';
      print('执行命令: $silenceCommand');

      final silenceSession = await FFmpegKit.execute(silenceCommand);
      final silenceReturnCode = await silenceSession.getReturnCode();
      final logs = await silenceSession.getLogs();
      final output = await silenceSession.getOutput();

      if (ReturnCode.isSuccess(silenceReturnCode)) {
        print('✅ 静音检测执行成功');
        print('日志数量: ${logs.length}');

        // 打印所有日志
        for (var log in logs) {
          final message = log.getMessage();
          if (message != null && (message.contains('silence') || message.contains('Input') || message.contains('Duration'))) {
            print('  > $message');
          }
        }

        // 统计静音点
        final silenceStartCount = logs.where((log) {
          final msg = log.getMessage();
          return msg != null && msg.contains('silence_start:');
        }).length;

        final silenceEndCount = logs.where((log) {
          final msg = log.getMessage();
          return msg != null && msg.contains('silence_end:');
        }).length;

        print('\n静音检测统计:');
        print('  - 静音开始点: $silenceStartCount');
        print('  - 静音结束点: $silenceEndCount');

        if (silenceStartCount == 0 && silenceEndCount == 0) {
          print('\n💡 诊断：未检测到任何静音点');
          print('  可能原因:');
          print('  1. 音频质量太好，完全没有静音');
          print('  2. 音频长度太短（<0.2秒）');
          print('  3. 音频可能是纯静音或有噪音');
        } else {
          print('\n🎉 成功检测到静音点！');
        }
      } else {
        print('❌ 静音检测执行失败');
        print('输出: $output');
      }

    } catch (e) {
      print('❌ 测试过程中发生错误: $e');
    }
  }

  /// 测试其他参数组合
  static Future<void> testParameterCombination() async {
    final audioCacheService = AudioCacheService.instance;
    await audioCacheService.initialize();
    final audioPath = await audioCacheService.getAudioFilePath('audio/getvoice1.mp3');

    print('\n=== 参数组合测试 ===');

    final configs = [
      {'threshold': -20.0, 'duration': 0.1},
      {'threshold': -30.0, 'duration': 0.2},
      {'threshold': -40.0, 'duration': 0.3},
      {'threshold': -50.0, 'duration': 0.4},
    ];

    for (var config in configs) {
      final threshold = config['threshold'];
      final duration = config['duration'];
      print('\n测试参数: threshold=${threshold}dB, duration=${duration}s');

      final command = '-i "$audioPath" -af "silencedetect=n=${threshold}dB:d=$duration" -f null -';
      final session = await FFmpegKit.execute(command);
      final logs = await session.getLogs();

      final silenceCount = logs.where((log) {
        final msg = log.getMessage();
        return msg != null && msg.contains('silence_start:');
      }).length;

      print('  检测到 $silenceCount 个静音开始点');
    }
  }
}
