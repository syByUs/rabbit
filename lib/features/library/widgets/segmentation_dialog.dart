import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/audio_segment_model.dart';
import '../../../core/themes/app_theme.dart';
import '../../../core/services/audio_segmentation_service.dart';
import '../../../core/providers/app_state_provider.dart';
import '../../../core/models/resource_model.dart';
import '../../../core/database/database_helper.dart';

class SegmentationDialog extends ConsumerStatefulWidget {
  final AudioResource resource;

  const SegmentationDialog({super.key, required this.resource});

  @override
  ConsumerState<SegmentationDialog> createState() => _SegmentationDialogState();
}

class _SegmentationDialogState extends ConsumerState<SegmentationDialog> {
  double silenceDuration = 0.5;
  double silenceThreshold = -40.0;
  bool isProcessing = false;
  String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      child: Container(
        padding: const EdgeInsets.all(24.0),
        width: 320,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('音频分割设置', style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            Text(widget.resource.title, style: TextStyle(fontSize: 14.0, color: AppColors.textSecondary)),
            const SizedBox(height: 24),
            Text('静音时长阈值', style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            Slider.adaptive(
              value: silenceDuration,
              min: 0.3,
              max: 2.0,
              divisions: 17,
              label: '${silenceDuration.toStringAsFixed(1)}秒',
              onChanged: isProcessing ? null : (value) => setState(() => silenceDuration = value),
            ),
            const SizedBox(height: 16),
            Text('静音分贝阈值', style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            Slider.adaptive(
              value: -silenceThreshold,
              min: 30,
              max: 60,
              divisions: 30,
              label: '${silenceThreshold}dB',
              onChanged: isProcessing
                  ? null
                  : (value) {
                      setState(() => silenceThreshold = -value);
                    },
            ),
            if (errorMessage != null) ...[
              const SizedBox(height: 16),
              Text(errorMessage!, style: TextStyle(fontSize: 14.0, color: AppColors.warning500)),
            ],
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(onPressed: isProcessing ? null : () => Navigator.pop(context), child: const Text('取消')),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: isProcessing ? null : () => _startSegmentation(),
                  child: isProcessing
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('开始分割'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _startSegmentation() async {
    setState(() {
      isProcessing = true;
      errorMessage = null;
    });

    try {
      // 检查资源是否有文件路径
      if (widget.resource.filePath == null || widget.resource.filePath!.isEmpty) {
        throw Exception('资源没有关联的音频文件');
      }

      // 更新资源状态为处理中
      final resources = ref.read(resourceListNotifierProvider);
      final updatedResource = widget.resource.copyWith(
        segmentationStatus: SegmentationStatus.segmenting,
      );
      ref.read(resourceListNotifierProvider.notifier).updateResource(updatedResource);

      // 获取音频文件的完整路径
      final audioPath = await DatabaseHelper.buildAudioFilePath(widget.resource.filePath!);

      // 执行分割
      final segments = await AudioSegmentationService.detectSilencePoints(
        audioPath: audioPath,
        silenceDuration: silenceDuration,
        silenceThreshold: silenceThreshold,
      );

      if (mounted) {
        Navigator.pop(context);

        // 更新资源状态（所有片段都是非静音）
        if (segments.isNotEmpty) {
          final segmentedResource = widget.resource.copyWith(
            segmentationStatus: SegmentationStatus.segmented,
            segments: segments,
          );
          ref.read(resourceListNotifierProvider.notifier).updateResource(segmentedResource);

          // 显示结果
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('分割完成！找到 ${segments.length} 个段落')),
          );
        } else {
          final failedResource = widget.resource.copyWith(
            segmentationStatus: SegmentationStatus.notSegmented,
          );
          ref.read(resourceListNotifierProvider.notifier).updateResource(failedResource);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('未检测到适合的分割点')),
          );
        }
      }
    } catch (e) {
      setState(() {
        errorMessage = '分割失败: ${e.toString()}';
        print(errorMessage);
        isProcessing = false;
      });

      // 恢复状态
      final failedResource = widget.resource.copyWith(
        segmentationStatus: SegmentationStatus.failed,
      );
      ref.read(resourceListNotifierProvider.notifier).updateResource(failedResource);
    }
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
      filePath: filePath, // 保留原有的 filePath
    );
  }
}
