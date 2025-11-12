import 'package:flutter/material.dart';
import '../themes/app_theme.dart';
import 'dart:math';
import 'audio_segment_model.dart';

/// ============================================
/// 音频资源模型
/// ============================================

enum ResourceCategory {
  jlpt('JLPT'),
  news('新闻'),
  dialogue('对话'),
  custom('自定义');

  final String label;
  const ResourceCategory(this.label);
}

enum LearningStatus {
  notStarted('not-started'),
  learning('learning'),
  mastered('mastered');

  final String value;
  const LearningStatus(this.value);
}

enum SegmentationStatus {
  notSegmented('未分割'),
  segmenting('分割中'),
  segmented('已分割'),
  failed('分割失败');

  final String label;
  const SegmentationStatus(this.label);
}

class AudioResource {
  final String id;
  final String title;
  final String duration;
  final int progress; // 0-100
  final LearningStatus status;
  final ResourceCategory category;
  final SegmentationStatus segmentationStatus;
  final DateTime? lastStudied;
  final List<AudioSegment>? segments;
  final String? filePath; // 存储文件名，不是完整路径（例如: "audio.mp3"）

  AudioResource({
    required this.id,
    required this.title,
    required this.duration,
    required this.progress,
    required this.status,
    required this.category,
    this.segmentationStatus = SegmentationStatus.notSegmented,
    this.lastStudied,
    this.segments,
    this.filePath,
  });

  /// 生成环形进度条路径
  String getProgressPath() {
    final circumference = 2 * pi * 10; // r=10
    final offset = circumference - (progress / 100) * circumference;
    return offset.toStringAsFixed(2);
  }

  /// 获取状态颜色
  Color getStatusColor() {
    switch (status) {
      case LearningStatus.notStarted:
        return AppColors.statusNotStarted;
      case LearningStatus.learning:
        return AppColors.statusLearning;
      case LearningStatus.mastered:
        return AppColors.statusMastered;
    }
  }

  /// 获取状态图标
  IconData getStatusIcon() {
    switch (status) {
      case LearningStatus.notStarted:
        return Icons.circle_outlined;
      case LearningStatus.learning:
        return Icons.circle;
      case LearningStatus.mastered:
        return Icons.check_circle;
    }
  }

  /// 获取分类图标
  IconData getCategoryIcon() {
    switch (category) {
      case ResourceCategory.jlpt:
        return Icons.school;
      case ResourceCategory.news:
        return Icons.article;
      case ResourceCategory.dialogue:
        return Icons.record_voice_over;
      case ResourceCategory.custom:
        return Icons.folder;
    }
  }
}

/// 词法分析模型
class WordAnalysis {
  final String word;
  final String reading;
  final String meaning;
  final String? partOfSpeech;

  WordAnalysis({
    required this.word,
    required this.reading,
    required this.meaning,
    this.partOfSpeech,
  });
}
