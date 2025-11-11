import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'audio_resource_schema.dart';

/// 数据库操作帮助类
class DatabaseHelper {
  static Isar? _instance;

  static Future<Isar> get instance async {
    if (_instance == null) {
      _instance = await _initIsar();
    }
    return _instance!;
  }

  static Future<Isar> _initIsar() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final isarDir = Directory('${directory.path}/isar');
      if (!await isarDir.exists()) {
        await isarDir.create(recursive: true);
      }

      // 确保音频文件目录存在
      await _ensureAudioDirectory();

      return await Isar.open(
        [AudioResourceIsarSchema],
        directory: isarDir.path,
        inspector: !kReleaseMode,
      );
    } catch (e) {
      debugPrint('Failed to initialize Isar database: $e');
      rethrow;
    }
  }

  /// 获取音频文件存储目录
  static Future<Directory> getAudioDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final audioDir = Directory('${appDir.path}/audio_files');
    if (!await audioDir.exists()) {
      await audioDir.create(recursive: true);
    }
    return audioDir;
  }

  /// 确保音频文件目录存在
  static Future<void> _ensureAudioDirectory() async {
    await getAudioDirectory();
  }

  /// 将音频文件复制到应用私有目录
  static Future<String?> copyAudioFileToAppDirectory(String sourcePath, String fileName) async {
    try {
      final audioDir = await getAudioDirectory();
      final fileNameWithoutPath = path.basename(fileName);
      final destinationPath = path.join(audioDir.path, fileNameWithoutPath);

      final sourceFile = File(sourcePath);
      if (!await sourceFile.exists()) {
        debugPrint('Source audio file does not exist: $sourcePath');
        return null;
      }

      final destinationFile = await sourceFile.copy(destinationPath);
      debugPrint('Audio file copied to: ${destinationFile.path}');
      // 只返回文件名，不返回完整路径
      return fileNameWithoutPath;
    } catch (e) {
      debugPrint('Failed to copy audio file: $e');
      return null;
    }
  }

  /// 获取音频文件的本地路径
  static Future<String?> getAudioFilePath(String fileName) async {
    try {
      final audioDir = await getAudioDirectory();
      final filePath = path.join(audioDir.path, path.basename(fileName));
      final file = File(filePath);

      if (await file.exists()) {
        return filePath;
      }
      return null;
    } catch (e) {
      debugPrint('Failed to get audio file path: $e');
      return null;
    }
  }

  /// 根据文件名构建完整路径（不检查文件是否存在）
  static Future<String> buildAudioFilePath(String fileName) async {
    final audioDir = await getAudioDirectory();
    return path.join(audioDir.path, path.basename(fileName));
  }

  /// 获取所有音频资源
  static Future<List<AudioResourceIsar>> getAllAudioResources() async {
    final isar = await instance;
    return await isar.audioResourceIsars.where().findAll();
  }

  /// 保存音频资源到数据库
  static Future<void> saveAudioResource(AudioResourceIsar resource) async {
    final isar = await instance;
    await isar.writeTxn(() async {
      await isar.audioResourceIsars.put(resource);
    });
  }

  /// 批量保存音频资源
  static Future<void> saveAudioResources(List<AudioResourceIsar> resources) async {
    final isar = await instance;
    await isar.writeTxn(() async {
      await isar.audioResourceIsars.putAll(resources);
    });
  }

  /// 删除音频资源
  static Future<void> deleteAudioResource(Id id) async {
    final isar = await instance;
    await isar.writeTxn(() async {
      await isar.audioResourceIsars.delete(id);
    });
  }

  /// 删除所有音频资源
  static Future<void> deleteAllAudioResources() async {
    final isar = await instance;
    await isar.writeTxn(() async {
      await isar.audioResourceIsars.clear();
    });
  }

  /// 通过resourceId查找音频资源
  static Future<AudioResourceIsar?> getAudioResourceById(String resourceId) async {
    final isar = await instance;
    return await isar.audioResourceIsars
        .where()
        .resourceIdEqualTo(resourceId)  // @Index 注解会生成这个方法
        .findFirst();
  }

  /// 更新音频资源的最后学习时间
  static Future<void> updateLastStudied(String resourceId) async {
    final isar = await instance;
    final resource = await getAudioResourceById(resourceId);

    if (resource != null) {
      resource.lastStudied = DateTime.now();
      await saveAudioResource(resource);
    }
  }

  /// 更新音频资源的分割状态
  static Future<void> updateSegmentationStatus(
      String resourceId, String status) async {
    final isar = await instance;
    final resource = await getAudioResourceById(resourceId);

    if (resource != null) {
      resource.segmentationStatus = status;
      await saveAudioResource(resource);
    }
  }

  /// 关闭数据库连接
  static Future<void> close() async {
    if (_instance != null) {
      await _instance!.close();
      _instance = null;
    }
  }
}
