import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../models/audio_segment_model.dart';

/// 音频分割存储服务
/// 保存分割结果到本地文件
class StorageService {
  static StorageService? _instance;
  static StorageService get instance => _instance ??= StorageService._();

  late Directory _appDir;
  late Directory _segmentsDir;
  bool _initialized = false;

  StorageService._();

  /// 初始化存储目录
  Future<void> initialize() async {
    if (_initialized) return;

    _appDir = await getApplicationDocumentsDirectory();
    _segmentsDir = Directory('${_appDir.path}/audio_segments');

    // 创建分割音频目录
    if (!await _segmentsDir.exists()) {
      await _segmentsDir.create(recursive: true);
    }

    _initialized = true;
  }

  /// 获取分割信息文件路径
  String _getSegmentInfoPath(String resourceId) {
    return '${_segmentsDir.path}/${resourceId}_segments.json';
  }

  /// 获取分割音频文件路径
  String _getSegmentAudioPath(String resourceId, int segmentIndex) {
    return '${_segmentsDir.path}/${resourceId}_segment_$segmentIndex.mp3';
  }

  /// 保存分割信息
  Future<void> saveSegments(String resourceId, List<AudioSegment> segments) async {
    await initialize();

    final infoPath = _getSegmentInfoPath(resourceId);
    
    // 只保存非静音片段的索引映射
    final nonSilenceSegments = segments.where((s) => !s.isSilence).toList();
    
    final data = {
      'resourceId': resourceId,
      'segments': segments.map((s) => {
        'start': s.start,
        'end': s.end,
        'isSilence': s.isSilence,
      }).toList(),
      'nonSilenceCount': nonSilenceSegments.length,
      'timestamp': DateTime.now().toIso8601String(),
    };

    await File(infoPath).writeAsString(jsonEncode(data));
  }

  /// 加载分割信息
  Future<List<AudioSegment>?> loadSegments(String resourceId) async {
    await initialize();

    final infoPath = _getSegmentInfoPath(resourceId);
    final file = File(infoPath);

    if (!await file.exists()) {
      return null;
    }

    try {
      final content = await file.readAsString();
      final data = jsonDecode(content);
      final segmentsData = data['segments'] as List<dynamic>;

      return segmentsData.map((s) => AudioSegment(
        start: s['start'] as double,
        end: s['end'] as double,
        isSilence: s['isSilence'] as bool,
      )).toList();
    } catch (e) {
      print('加载分割信息失败: $e');
      return null;
    }
  }

  /// 检查是否存在分割信息
  Future<bool> hasSegments(String resourceId) async {
    await initialize();
    final infoPath = _getSegmentInfoPath(resourceId);
    return await File(infoPath).exists();
  }

  /// 删除分割信息
  Future<void> deleteSegments(String resourceId) async {
    await initialize();

    final infoPath = _getSegmentInfoPath(resourceId);
    final file = File(infoPath);

    if (await file.exists()) {
      await file.delete();
    }

    // 删除相关的音频文件
    var index = 0;
    while (true) {
      final audioPath = _getSegmentAudioPath(resourceId, index);
      final audioFile = File(audioPath);

      if (await audioFile.exists()) {
        await audioFile.delete();
        index++;
      } else {
        break;
      }
    }
  }

  /// 导出分割音频（可选，用于导出分割后的音频文件）
  Future<String> exportSegmentAudio(String resourceId, int segmentIndex) async {
    // 这里需要实现音频切片的逻辑
    // 使用 FFmpeg 将原始音频按时间范围切片
    final outputPath = _getSegmentAudioPath(resourceId, segmentIndex);
    return outputPath;
  }

  /// 检查分割音频文件是否存在
  /// 
  /// [resourceId] 资源ID
  /// [segmentIndex] 非静音片段的索引（从0开始）
  Future<bool> hasSegmentAudio(String resourceId, int segmentIndex) async {
    await initialize();
    final audioPath = _getSegmentAudioPath(resourceId, segmentIndex);
    return await File(audioPath).exists();
  }

  /// 获取所有已导出的分割音频文件路径
  /// 
  /// [resourceId] 资源ID
  /// @returns 所有存在的分割音频文件路径列表
  Future<List<String>> getExportedSegmentPaths(String resourceId) async {
    await initialize();
    
    final paths = <String>[];
    var index = 0;
    
    while (true) {
      final audioPath = _getSegmentAudioPath(resourceId, index);
      if (await File(audioPath).exists()) {
        paths.add(audioPath);
        index++;
      } else {
        break;
      }
    }
    
    return paths;
  }
}