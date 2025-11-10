import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

/// 音频文件缓存服务
/// 将 assets 中的音频文件复制到本地缓存，供 FFmpeg 使用
class AudioCacheService {
  static AudioCacheService? _instance;
  static AudioCacheService get instance => _instance ??= AudioCacheService._();

  late Directory _cacheDir;
  late Directory _segmentsDir;
  bool _initialized = false;

  AudioCacheService._();

  /// 初始化缓存目录
  Future<void> initialize() async {
    if (_initialized) return;

    final appDir = await getApplicationDocumentsDirectory();
    _cacheDir = Directory('${appDir.path}/audio_cache');
    _segmentsDir = Directory('${appDir.path}/audio_segments');

    // 创建缓存目录
    if (!await _cacheDir.exists()) {
      await _cacheDir.create(recursive: true);
    }

    // 创建分割音频目录
    if (!await _segmentsDir.exists()) {
      await _segmentsDir.create(recursive: true);
    }

    _initialized = true;
  }

  /// 获取音频文件的本地路径
  /// 如果文件已缓存则返回缓存路径，否则从 assets 复制
  Future<String> getAudioFilePath(String assetPath) async {
    await initialize();

    // 确保路径以 'assets/' 开头
    final normalizedPath = assetPath.startsWith('assets/') ? assetPath : 'assets/$assetPath';

    // 从 assetPath 中提取文件名
    final fileName = normalizedPath.split('/').last;
    final cachedFile = File('${_cacheDir.path}/$fileName');

    // 如果文件已存在，直接返回
    if (await cachedFile.exists()) {
      print('音频文件缓存：使用已缓存的文件: ${cachedFile.path}');
      return cachedFile.path;
    }

    print('音频文件缓存：正在从 assets 加载文件: $normalizedPath');

    // 从 assets 复制文件到缓存目录
    try {
      final byteData = await rootBundle.load(normalizedPath);
      final buffer = byteData.buffer;
      await cachedFile.writeAsBytes(buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

      print('音频文件缓存：成功缓存文件，大小: ${await cachedFile.length()} 字节');
      return cachedFile.path;
    } catch (e) {
      throw Exception('无法从 assets 加载音频文件 "$normalizedPath": $e');
    }
  }

  /// 清理缓存
  Future<void> clearCache() async {
    await initialize();

    if (await _cacheDir.exists()) {
      await _cacheDir.delete(recursive: true);
      await _cacheDir.create(recursive: true);
    }
  }

  /// 获取缓存大小（字节）
  Future<int> getCacheSize() async {
    await initialize();

    if (!await _cacheDir.exists()) return 0;

    int totalSize = 0;
    await for (var entity in _cacheDir.list()) {
      if (entity is File) {
        totalSize += await entity.length();
      }
    }
    return totalSize;
  }

  /// 获取分割音频片段的缓存路径
  /// 
  /// [resourceId] 资源ID
  /// [segmentIndex] 片段索引（从0开始）
  /// @returns 分割音频文件的完整路径
  String getSegmentPath(String resourceId, int segmentIndex) {
    return '${_segmentsDir.path}/${resourceId}_segment_$segmentIndex.mp3';
  }

  /// 检查分割音频片段是否已缓存
  /// 
  /// [resourceId] 资源ID
  /// [segmentIndex] 片段索引
  /// @returns 如果文件存在返回true，否则返回false
  Future<bool> hasSegment(String resourceId, int segmentIndex) async {
    await initialize();
    final segmentPath = getSegmentPath(resourceId, segmentIndex);
    return await File(segmentPath).exists();
  }

  /// 清理指定资源的所有分割音频片段
  /// 
  /// [resourceId] 资源ID
  Future<void> clearSegments(String resourceId) async {
    await initialize();

    var index = 0;
    while (true) {
      final segmentPath = getSegmentPath(resourceId, index);
      final segmentFile = File(segmentPath);

      if (await segmentFile.exists()) {
        await segmentFile.delete();
        index++;
      } else {
        break;
      }
    }
    print('🗑️ 已清理资源 $resourceId 的 $index 个音频片段');
  }

  /// 获取分割音频目录路径
  String get segmentsDirectory => _segmentsDir.path;
}
