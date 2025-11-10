import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/themes/app_theme.dart';
import '../../core/models/resource_model.dart';
import '../../core/providers/app_state_provider.dart';
import '../learning/learning_screen.dart';
import 'widgets/audio_player.dart';
import 'widgets/segment_list.dart';
import 'widgets/split_section.dart';

class DetailScreen extends ConsumerStatefulWidget {
  final AudioResource resource;

  const DetailScreen({
    super.key,
    required this.resource,
  });

  @override
  ConsumerState<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends ConsumerState<DetailScreen> {
  @override
  void initState() {
    super.initState();
    // 延迟到 Widget 构建完成后再执行
    Future.delayed(Duration.zero, () {
      if (mounted) {
        ref.read(selectedResourceNotifierProvider.notifier).select(widget.resource);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // 监听分割状态变化，当分割完成时自动刷新列表
    final segmentationState = ref.watch(resourceSegmentationProvider(widget.resource.id));

    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.resource.title,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.lg),

            // 分割功能
            SplitSectionWidget(
              resource: widget.resource,
            ),

            const SizedBox(height: AppSpacing.xl),

            // 学习单元列表 - 直接使用，无需 ValueListenableBuilder
            SegmentListWidget(
              resource: widget.resource,
              key: ValueKey(segmentationState.segments?.length ?? 0), // 使用 key 强制重建
            ),

            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }
}