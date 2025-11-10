import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
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
