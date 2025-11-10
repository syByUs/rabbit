import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/themes/app_theme.dart';
import '../../../core/models/resource_model.dart';
import '../../../core/models/audio_segment_model.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/models/resource_model.dart';
import '../../learning/learning_screen.dart';
import 'loading_indicator.dart';

class SegmentListWidget extends ConsumerStatefulWidget {
  final AudioResource resource;
  final bool shouldReload;

  const SegmentListWidget({
    super.key,
    required this.resource,
    this.shouldReload = false,
  });

  @override
  ConsumerState<SegmentListWidget> createState() => _SegmentListWidgetState();
}

class _SegmentListWidgetState extends ConsumerState<SegmentListWidget> {
  bool isLoading = false;
  List<AudioSegment>? segments;

  @override
  void initState() {
    super.initState();
    _loadSegments();
  }

  @override
  void didUpdateWidget(SegmentListWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    print('✅ didUpdateWidget 被调用, old.shouldReload=${oldWidget.shouldReload}, new.shouldReload=${widget.shouldReload}');

    // 当资源ID改变时，重新加载数据
    if (oldWidget.resource.id != widget.resource.id) {
      print('📁 资源ID改变，重新加载数据');
      _loadSegments();
    }
    // 当 shouldReload 改变时，重新加载数据（无论 true/false）
    if (oldWidget.shouldReload != widget.shouldReload) {
      print('🔥 shouldReload 改变，重新加载数据 (旧值: ${oldWidget.shouldReload}, 新值: ${widget.shouldReload})');
      _loadSegments();
    }
  }

  Future<void> _loadSegments() async {
    setState(() {
      isLoading = true;
    });

    print('📥 开始加载分割数据，资源ID: ${widget.resource.id}');

    try {
      await StorageService.instance.initialize();
      final loadedSegments = await StorageService.instance.loadSegments(widget.resource.id);

      print('📤 加载完成，找到 ${loadedSegments?.length ?? 0} 个分割');

      if (mounted) {
        setState(() {
          segments = loadedSegments;
          isLoading = false;
        });
      }
    } catch (e) {
      print('❌ 加载失败: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void refreshSegments() {
    _loadSegments();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '学习单元',
                  style: const TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (segments != null && segments!.isNotEmpty)
                  Text(
                    '${segments!.where((s) => !s.isSilence).length} 单元',
                    style: TextStyle(
                      fontSize: 14.0,
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          if (isLoading)
            const Center(
              child: LoadingIndicator(message: '正在加载分割数据...'),
            )
          else if (segments == null || segments!.isEmpty)
            Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: AppColors.neutral0,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                boxShadow: AppShadows.small,
              ),
              child: Column(
                children: [
                  Text(
                    '🎧',
                    style: TextStyle(
                      fontSize: 48.0,
                      color: AppColors.textSecondary.withOpacity(0.5),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    '此音频尚未分割',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    '点击上方"通过静音点自动分割"按钮开始',
                    style: TextStyle(
                      fontSize: 14.0,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else
            _buildSegmentList(),
        ],
      ),
    );
  }

  Widget _buildSegmentList() {
    // 过滤掉静音片段，只显示非静音的学习单元
    final learningSegments = segments!.where((segment) => !segment.isSilence).toList();

    if (learningSegments.isEmpty) {
      return const Text(
        '没有可用的学习单元',
        style: TextStyle(color: AppColors.textSecondary),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: learningSegments.length,
      itemBuilder: (context, index) {
        final segment = learningSegments[index];
        return _SegmentItem(
          segment: segment,
          index: index + 1,
          onTap: () => _openSegment(segment),
        );
      },
    );
  }

  void _openSegment(AudioSegment segment) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => LearningScreen(
          segment: LearningSegment(
            id: 'segment_${segment.start}',
            title: '片段 ${segment.start.toStringAsFixed(1)}s - ${segment.end.toStringAsFixed(1)}s',
            startTime: Duration(seconds: segment.start.toInt()),
            endTime: Duration(seconds: segment.end.toInt()),
            transcript: '音频片段内容 - 时间: ${segment.timeRange}',
            isCompleted: false,
          ),
        ),
      ),
    );
  }
}

class _SegmentItem extends StatelessWidget {
  final AudioSegment segment;
  final int index;
  final VoidCallback onTap;

  const _SegmentItem({
    required this.segment,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.md),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.neutral0,
              borderRadius: BorderRadius.circular(AppRadius.md),
              boxShadow: AppShadows.small,
              border: Border.all(color: AppColors.neutral200),
            ),
            child: Row(
              children: [
                Container(
                  width: 40.0,
                  height: 40.0,
                  decoration: BoxDecoration(
                    color: AppColors.primary50,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: Center(
                    child: Text(
                      '$index',
                      style: const TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '片段 $index',
                        style: const TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs / 2),
                      Text(
                        segment.timeRange,
                        style: TextStyle(
                          fontSize: 14.0,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs / 2),
                      Text(
                        '时长: ${segment.duration.toStringAsFixed(1)}秒',
                        style: TextStyle(
                          fontSize: 12.0,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 32.0,
                  height: 32.0,
                  decoration: BoxDecoration(
                    color: AppColors.primary500,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.play_arrow,
                      size: 16.0,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
