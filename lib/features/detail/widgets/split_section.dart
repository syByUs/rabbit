import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/themes/app_theme.dart';
import '../../../core/models/resource_model.dart';
import '../../../core/models/audio_segment_model.dart';
import '../../../core/providers/app_state_provider.dart';
import '../../../core/services/audio_segmentation_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/services/audio_cache_service.dart';
import 'loading_indicator.dart';

class SplitSectionWidget extends ConsumerStatefulWidget {
  final AudioResource resource;

  const SplitSectionWidget({
    super.key,
    required this.resource,
  });

  @override
  ConsumerState<SplitSectionWidget> createState() => _SplitSectionWidgetState();
}

class _SplitSectionWidgetState extends ConsumerState<SplitSectionWidget> {
  bool isSplitting = false;

  @override
  void initState() {
    super.initState();
    _checkIfAlreadySegmented();
  }

  Future<void> _checkIfAlreadySegmented() async {
    // 初始化存储服务
    await StorageService.instance.initialize();

    final hasSegments = await StorageService.instance.hasSegments(widget.resource.id);
    if (hasSegments && mounted) {
      // 如果已经有分割数据，加载并更新到 provider
      final segments = await StorageService.instance.loadSegments(widget.resource.id);
      if (segments != null && mounted) {
        ref.read(resourceSegmentationProvider(widget.resource.id).notifier)
            .completeSegmenting(segments);
      }
    }
  }

  Future<void> _clearSegmentation() async {
    final isPro = ref.read(isProUserProvider);
    if (!isPro) {
      _showPaywall();
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清空分割数据'),
        content: const Text('确定要删除此音频的分割数据吗？此操作无法撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('确定'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      isSplitting = true;
    });

    try {
      await StorageService.instance.initialize();
      await StorageService.instance.deleteSegments(widget.resource.id);

      // 更新资源状态
      final updatedResource = widget.resource.copyWith(
        segmentationStatus: SegmentationStatus.notSegmented,
      );

      if (mounted) {
        ref.read(resourceListNotifierProvider.notifier).updateResource(updatedResource);

        setState(() {
          isSplitting = false;
        });

        _showMessage('已清空分割数据');

        // Riverpod 会自动通知所有监听器刷新
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isSplitting = false;
        });
        _showMessage('清空失败: ${e.toString()}');
      }
    }
  }

  Future<void> _splitAudio() async {
    final isPro = ref.read(isProUserProvider);
    if (!isPro) {
      _showPaywall();
      return;
    }

    setState(() {
      isSplitting = true;
    });

    // 设置分割状态为进行中
    ref.read(resourceSegmentationProvider(widget.resource.id).notifier).startSegmenting();

    try {
      // 初始化存储服务和缓存服务
      await StorageService.instance.initialize();
      await AudioCacheService.instance.initialize();

      print('开始分割音频: ${widget.resource.title}');

      // 获取音频文件的本地缓存路径
      final audioPath = await AudioCacheService.instance.getAudioFilePath(
        'audio/${widget.resource.title}',
      );

      print('音频文件已缓存到: $audioPath');
      print('文件是否存在: ${File(audioPath).existsSync()}');

      // 执行分割
      print('执行 FFmpeg 静音检测...');
      final segments = await AudioSegmentationService.detectSilencePoints(
        audioPath: audioPath,
        silenceDuration: 0.6,
        silenceThreshold: -40.0,
      );

      print('分割完成，检测到 ${segments.length} 个片段');

      if (segments.isNotEmpty) {
        // 保存分割信息
        await StorageService.instance.saveSegments(widget.resource.id, segments);

        // 更新资源状态
        final nonSilenceSegments = segments.where((s) => !s.isSilence && s.duration > 1.0).toList();
        final updatedResource = widget.resource.copyWith(
          segmentationStatus: SegmentationStatus.segmented,
        );

        if (mounted) {
          ref.read(resourceListNotifierProvider.notifier).updateResource(updatedResource);

          // 更新分割状态 - 这里会触发SegmentListWidget的UI刷新
          ref.read(resourceSegmentationProvider(widget.resource.id).notifier).completeSegmenting(segments);

          setState(() {
            isSplitting = false;
          });

          _showMessage('音频分割完成！已生成 ${nonSilenceSegments.length} 个学习单元');

          // Riverpod 会自动通知所有监听器刷新
        }
      } else {
        if (mounted) {
          setState(() {
            isSplitting = false;
          });
          _showMessage('未检测到适合的分割点');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isSplitting = false;
        });
        _showMessage('分割失败: ${e.toString()}');
      }
    }
  }

  void _showPaywall() {
    showDialog(
      context: context,
      builder: (context) => const PaywallModal(),
    );
  }

  void _showMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.neutral0,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadows.small,
        border: Border.all(color: AppColors.neutral200),
      ),
      child: Column(
        children: [
          if (isSplitting)
            const Center(
              child: LoadingIndicator(message: '正在分析音频...'),
            )
          else
            ElevatedButton(
              onPressed: _splitAudio,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56.0),
                backgroundColor: AppColors.primary500,
                foregroundColor: Colors.white,
                textStyle: const TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                elevation: 4.0,
              ),
              child: const Text('静音分割'),
            ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GestureDetector(
                onTap: _showPaywall,
                child: Text(
                  '高级设置 💎',
                  style: TextStyle(
                    color: AppColors.textPro,
                    fontSize: 14.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Container(
                width: 1,
                height: 16,
                color: AppColors.neutral200,
              ),
              GestureDetector(
                onTap: _clearSegmentation,
                child: Text(
                  '清空分割',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 14.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class PaywallModal extends StatelessWidget {
  const PaywallModal({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Container(
        width: 320.0,
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '💎 解锁PRO版',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '享受极致的日语精听体验',
              style: TextStyle(
                fontSize: 16.0,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            _buildFeatureItem('✓', '高级分割设置 (自定义静音时长)'),
            _buildFeatureItem('✓', 'AI词法分析 (逐句语法详解)'),
            _buildFeatureItem('✓', '无限制导入音频'),
            _buildFeatureItem('✓', '云端同步'),
            const SizedBox(height: AppSpacing.lg),
            Text(
              '¥68/年',
              style: TextStyle(
                fontSize: 32.0,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '7天免费试用，可随时取消',
              style: TextStyle(
                fontSize: 14.0,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: AppTheme.proButtonStyle.copyWith(
                minimumSize: const WidgetStatePropertyAll<Size>(
                  Size(double.infinity, 48.0),
                ),
              ),
              child: const Text('立即升级'),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('以后再说'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(color: AppColors.success500)),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 14.0, color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}

extension on AudioResource {
  AudioResource copyWith({
    SegmentationStatus? segmentationStatus,
    List<AudioSegment>? segments,
  }) {
    return AudioResource(
      id: id,
      title: title,
      duration: duration,
      progress: progress,
      status: status,
      category: category,
      segmentationStatus: segmentationStatus ?? this.segmentationStatus,
      lastStudied: lastStudied,
      segments: segments ?? this.segments,
    );
  }
}
