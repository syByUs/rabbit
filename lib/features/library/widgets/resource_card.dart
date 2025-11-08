import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/themes/app_theme.dart';
import '../../../core/models/resource_model.dart';
import '../../../core/providers/app_state_provider.dart';
import '../../../core/utils/audio_helper.dart';
import '../../detail/detail_screen.dart';

class ResourceCard extends ConsumerWidget {
  final AudioResource resource;

  const ResourceCard({
    super.key,
    required this.resource,
  });

  void _togglePlayback(WidgetRef ref) {
    final playbackState = ref.read(audioPlaybackProvider);
    final isCurrent = playbackState.isCurrentResource(resource.id);
    final isPlaying = isCurrent && playbackState.isPlaying;

    if (isPlaying) {
      // 当前正在播放，暂停
      AudioHelper.pause();
      ref.read(audioPlaybackProvider.notifier).pause();
    } else {
      // 停止当前音频（如果有），播放新音频
      if (playbackState.currentResourceId != null) {
        AudioHelper.stop();
      }

      String assetPath = 'audio/${resource.title}';
      AudioHelper.playAsset(assetPath);
      ref.read(audioPlaybackProvider.notifier).startPlaying(resource.id);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playbackState = ref.watch(audioPlaybackProvider);
    final isCurrent = playbackState.isCurrentResource(resource.id);
    final isPlaying = isCurrent && playbackState.isPlaying;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: AppDecorations.cardDecoration,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          onTap: () => _openResource(context, resource),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: resource.getStatusColor(),
                  width: 4.0,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(isPlaying, ref),
                const SizedBox(height: AppSpacing.sm),
                _buildMeta(),
                const SizedBox(height: AppSpacing.md),
                _buildProgress(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isPlaying, WidgetRef ref) {
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
        // 环形进度条
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
              resource.status == LearningStatus.learning && resource.lastStudied != null
                  ? '最近学习: ${_formatDate(resource.lastStudied!)}'
                  : LearningStatusStyle.getStatusText(resource.status.value),
              style: TextStyle(
                fontSize: 12.0,
                color: AppColors.textTertiary,
              ),
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
      MaterialPageRoute(
        builder: (context) => DetailScreen(resource: resource),
      ),
    );
  }
}

/// ============================================
/// 环形进度条绘制
/// ============================================

class ProgressRingPainter extends CustomPainter {
  final double progress;
  final Color color;

  const ProgressRingPainter({
    required this.progress,
    required this.color,
  });

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
