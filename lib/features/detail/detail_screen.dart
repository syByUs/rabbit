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
  final ValueNotifier<bool> _reloadNotifier = ValueNotifier(false);

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
            const SizedBox(height: AppSpacing.md),

            // 音频播放器
            AudioPlayerWidget(resource: widget.resource),

            const SizedBox(height: AppSpacing.lg),

            // 分割功能
            SplitSectionWidget(
              resource: widget.resource,
              onSegmentsGenerated: () {
                // 触发 SegmentListWidget 刷新
                print('📊 ValueNotifier 触发，当前值: ${_reloadNotifier.value} → ${!_reloadNotifier.value}');
                _reloadNotifier.value = !_reloadNotifier.value;
              },
            ),

            const SizedBox(height: AppSpacing.xl),

            // 学习单元列表
            ValueListenableBuilder<bool>(
              valueListenable: _reloadNotifier,
              builder: (context, value, child) {
                print('🎯 ValueListenableBuilder 重建, shouldReload=$value');
                return SegmentListWidget(
                  resource: widget.resource,
                  shouldReload: value,
                );
              },
            ),

            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }
}