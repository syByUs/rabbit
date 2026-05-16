import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/themes/app_theme.dart';
import '../../../core/models/resource_model.dart';
import '../../../core/providers/app_state_provider.dart';
import '../../../core/utils/audio_helper.dart';
import '../../../core/database/database_helper.dart';
import '../../../core/services/video_conversion_service.dart';
import '../../detail/detail_screen.dart';
import 'segmentation_dialog.dart';

class ResourceCard extends ConsumerWidget {
  final AudioResource resource;

  const ResourceCard({super.key, required this.resource});

  void _togglePlayback(WidgetRef ref) async {
    final playbackState = ref.read(audioPlaybackNotifierProvider);
    final isCurrent = playbackState.isCurrentResource(resource.id);
    final isPlaying = isCurrent && playbackState.isPlaying;

    if (isPlaying) {
      AudioHelper.pause();
      ref.read(audioPlaybackNotifierProvider.notifier).pause();
    } else {
      if (playbackState.currentResourceId != null) {
        AudioHelper.stop();
      }

      try {
        // 必须有 filePath 才能播放
        if (resource.filePath == null || resource.filePath!.isEmpty) {
          debugPrint('无法播放: 资源没有关联的音频文件');
          return;
        }

        // 使用文件名构建当前的完整路径
        final localFilePath = await DatabaseHelper.buildAudioFilePath(
          resource.filePath!,
        );
        final file = File(localFilePath);

        if (await file.exists()) {
          // 从本地文件播放
          debugPrint('Playing from local file: $localFilePath');
          await AudioHelper.playFile(localFilePath);
          ref
              .read(audioPlaybackNotifierProvider.notifier)
              .startPlaying(resource.id);
        } else {
          debugPrint('文件不存在: $localFilePath');
        }
      } catch (e, stackTrace) {
        debugPrint('播放错误: $e');
        debugPrint('堆栈跟踪: $stackTrace');
      }
    }
  }

  void _showSegmentationDialog(BuildContext context) async {
    if (resource.title.endsWith('mkv')) {
      debugPrint('检测到 MKV 文件: ${resource.title}');
      debugPrint('文件路径: ${resource.filePath}');

      final videoPath = await DatabaseHelper.buildAudioFilePath(
        resource.filePath!,
      );
      debugPrint('完整路径: $videoPath');

      // 显示转换确认对话框
      _showConversionDialog(context, videoPath);
    } else {
      showDialog(
        context: context,
        builder: (_) => SegmentationDialog(resource: resource),
      );
    }
  }

  /// 显示视频转换对话框
  void _showConversionDialog(BuildContext context, String videoPath) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _VideoConversionDialog(
        videoPath: videoPath,
        resourceTitle: resource.title,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playbackState = ref.watch(audioPlaybackNotifierProvider);
    final isCurrent = playbackState.isCurrentResource(resource.id);
    final isPlaying = isCurrent && playbackState.isPlaying;

    bool showSegmentation =
        resource.segmentationStatus != SegmentationStatus.notSegmented;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: AppDecorations.cardDecoration,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          onTap: () => _openResource(context, resource),
          onLongPress: () => _showSegmentationDialog(context),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(color: resource.getStatusColor(), width: 4.0),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(isPlaying, ref, context),
                if (showSegmentation) const SizedBox(height: AppSpacing.sm),
                if (showSegmentation) _buildSegmentationStatus(),
                const SizedBox(height: AppSpacing.md),
                _buildMeta(),
                // const SizedBox(height: AppSpacing.md),
                // _buildProgress(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isPlaying, WidgetRef ref, BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            resource.title,
            style: const TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        IconButton(
          icon: Icon(
            resource.segmentationStatus == SegmentationStatus.segmenting
                ? Icons.hourglass_empty
                : resource.segmentationStatus == SegmentationStatus.segmented
                ? Icons.check_circle
                : resource.segmentationStatus == SegmentationStatus.failed
                ? Icons.error
                : Icons.cut,
            color: AppColors.primary500,
            size: 20.0,
          ),
          onPressed: () => _showSegmentationDialog(context),
          tooltip: '分割音频',
        ),
        const SizedBox(width: AppSpacing.sm),
        IconButton(
          onPressed: () => _togglePlayback(ref),
          icon: Icon(
            isPlaying ? Icons.pause_circle_filled : Icons.play_circle_outline,
            size: 32.0,
            color: AppColors.primary500,
          ),
          splashRadius: 24.0,
          tooltip: isPlaying ? '暂停' : '播放',
        ),
      ],
    );
  }

  Widget _buildSegmentationStatus() {
    Color statusColor;
    String statusText;

    switch (resource.segmentationStatus) {
      case SegmentationStatus.segmenting:
        statusColor = AppColors.warning500;
        statusText = '分割中...';
        break;
      case SegmentationStatus.segmented:
        statusColor = AppColors.success500;
        statusText = '已分割 (${resource.segments?.length ?? 0}段)';
        break;
      case SegmentationStatus.failed:
        statusColor = AppColors.warning500;
        statusText = '分割失败';
        break;
      default:
        statusColor = AppColors.textSecondary;
        statusText = '未分割';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            resource.segmentationStatus == SegmentationStatus.segmenting
                ? Icons.hourglass_empty
                : resource.segmentationStatus == SegmentationStatus.segmented
                ? Icons.check_circle
                : Icons.error,
            size: 14.0,
            color: statusColor,
          ),
          const SizedBox(width: 4.0),
          Text(
            statusText,
            style: TextStyle(
              fontSize: 12.0,
              color: statusColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMeta() {
    return Row(
      children: [
        Icon(
          resource.getCategoryIcon(),
          size: 16.0,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(
          resource.category.label,
          style: const TextStyle(
            fontSize: 14.0,
            color: AppColors.textSecondary,
          ),
        ),
        const Spacer(),
        Text(
          '时长: ${resource.duration}',
          style: const TextStyle(
            fontSize: 14.0,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildProgress() {
    return Row(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 40.0,
              height: 40.0,
              child: CustomPaint(
                painter: ProgressRingPainter(
                  progress: resource.progress.toDouble(),
                  color: resource.getStatusColor(),
                ),
              ),
            ),
            Icon(
              resource.getStatusIcon(),
              size: 16.0,
              color: resource.getStatusColor(),
            ),
          ],
        ),
        const SizedBox(width: AppSpacing.md),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '进度: ${resource.progress}%',
              style: const TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.xs / 2),
            Text(
              resource.status == LearningStatus.learning &&
                      resource.lastStudied != null
                  ? '最近学习: ${_formatDate(resource.lastStudied!)}'
                  : LearningStatusStyle.getStatusText(resource.status.value),
              style: TextStyle(fontSize: 12.0, color: AppColors.textTertiary),
            ),
          ],
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}天前';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}小时前';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}分钟前';
    } else {
      return '刚刚';
    }
  }

  void _openResource(BuildContext context, AudioResource resource) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => DetailScreen(resource: resource)),
    );
  }
}

/// ============================================
/// 环形进度条绘制
/// ============================================

class ProgressRingPainter extends CustomPainter {
  final double progress;
  final Color color;

  const ProgressRingPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const radius = 10.0;
    const strokeWidth = 3.0;

    // 背景圆
    final backgroundPaint = Paint()
      ..color = AppColors.neutral200
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius, backgroundPaint);

    // 进度圆
    if (progress > 0) {
      final progressPaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      final angle = 2 * pi * (progress / 100);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -pi / 2, // 从顶部开始
        angle,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(ProgressRingPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}

/// ============================================
/// 视频转换对话框
/// ============================================

class _VideoConversionDialog extends StatefulWidget {
  final String videoPath;
  final String resourceTitle;

  const _VideoConversionDialog({
    required this.videoPath,
    required this.resourceTitle,
  });

  @override
  State<_VideoConversionDialog> createState() => _VideoConversionDialogState();
}

class _VideoConversionDialogState extends State<_VideoConversionDialog> {
  bool _isConverting = false;
  double _progress = 0.0;
  String? _outputPath;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('视频格式转换'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '文件: ${widget.resourceTitle}',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 16),
          if (!_isConverting && _outputPath == null && _errorMessage == null)
            const Text(
              '检测到 MKV 格式视频，需要转换为 H.264 编码的 MP4 格式以确保兼容性。',
              style: TextStyle(fontSize: 14),
            ),
          if (_isConverting) ...[
            const Text('正在转换中，请稍候...'),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: _progress > 0 ? _progress / 100 : null,
            ),
            const SizedBox(height: 8),
            Text(
              '进度: ${_progress.toStringAsFixed(0)}%',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
          if (_outputPath != null) ...[
            const Icon(
              Icons.check_circle,
              color: AppColors.success500,
              size: 48,
            ),
            const SizedBox(height: 8),
            const Text('转换成功！'),
            const SizedBox(height: 8),
            Text(
              '输出文件: $_outputPath',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
          if (_errorMessage != null) ...[
            const Icon(Icons.error, color: AppColors.warning500, size: 48),
            const SizedBox(height: 8),
            Text(
              '转换失败: $_errorMessage',
              style: const TextStyle(color: AppColors.warning500),
            ),
          ],
        ],
      ),
      actions: [
        if (!_isConverting && _outputPath == null && _errorMessage == null) ...[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: _startConversion,
            child: const Text('开始转换'),
          ),
        ],
        if (_outputPath != null || _errorMessage != null)
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('关闭'),
          ),
      ],
    );
  }

  /// 开始视频转换
  Future<void> _startConversion() async {
    setState(() {
      _isConverting = true;
      _progress = 0.0;
      _errorMessage = null;
    });

    try {
      final outputPath = await VideoConversionService.convertToH264(
        inputPath: widget.videoPath,
        onProgress: (progress) {
          setState(() {
            _progress = progress;
          });
        },
      );

      setState(() {
        _isConverting = false;
        _outputPath = outputPath;
      });
    } catch (e) {
      setState(() {
        _isConverting = false;
        _errorMessage = e.toString();
      });
    }
  }
}
