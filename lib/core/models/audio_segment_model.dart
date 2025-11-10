/// 音频片段模型
/// 只包含非静音的学习单元片段
class AudioSegment {
  final double start; // 开始时间（秒）
  final double end; // 结束时间（秒）

  AudioSegment({
    required this.start,
    required this.end,
  });

  /// 获取片段时长
  double get duration => end - start;

  /// 获取格式化的时间范围字符串
  String get timeRange {
    final startStr = _formatTime(start);
    final endStr = _formatTime(end);
    return '$startStr - $endStr';
  }

  /// 格式化时间显示
  static String _formatTime(double seconds) {
    final minutes = (seconds ~/ 60).toInt();
    final secs = (seconds % 60).toInt();
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }
}

/// 音频分割任务模型
class SegmentationTask {
  final String audioPath;
  final List<AudioSegment> segments;
  final DateTime createdAt;
  final TaskStatus status;

  SegmentationTask({
    required this.audioPath,
    required this.segments,
    required this.createdAt,
    required this.status,
  });

  /// 获取非静音片段的数量（现在所有片段都是非静音）
  int get nonSilenceSegmentCount {
    return segments.length;
  }

  /// 获取总时长
  double get totalDuration {
    return segments.isNotEmpty ? segments.last.end : 0;
  }
}

/// 分割任务状态
enum TaskStatus {
  pending,
  processing,
  completed,
  failed;

  String get label {
    switch (this) {
      case TaskStatus.pending:
        return '待处理';
      case TaskStatus.processing:
        return '处理中';
      case TaskStatus.completed:
        return '已完成';
      case TaskStatus.failed:
        return '失败';
    }
  }
}
