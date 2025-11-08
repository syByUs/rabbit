import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

/// 音频文件缓存服务
/// 将 assets 中的音频文件复制到本地缓存，供 FFmpeg 使用
class AudioCacheService {
  static AudioCacheService? _instance;
  static AudioCacheService get instance => _instance ??= AudioCacheService._();

  late Directory _cacheDir;
  bool _initialized = false;

  AudioCacheService._();

  /// 初始化缓存目录
  Future<void> initialize() async {
    if (_initialized) return;

    _cacheDir = Directory('${(await getApplicationDocumentsDirectory()).path}/audio_cache');

    // 创建缓存目录
    if (!await _cacheDir.exists()) {
      await _cacheDir.create(recursive: true);
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
}
