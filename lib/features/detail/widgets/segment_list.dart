import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/themes/app_theme.dart';
import '../../../core/models/resource_model.dart';
import '../../learning/learning_screen.dart';

class SegmentListWidget extends ConsumerStatefulWidget {
  final AudioResource resource;

  const SegmentListWidget({
    super.key,
    required this.resource,
  });

  @override
  ConsumerState<SegmentListWidget> createState() => _SegmentListWidgetState();
}

class _SegmentListWidgetState extends ConsumerState<SegmentListWidget> {
  bool showGeneratedSegments = false;

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
                if (showGeneratedSegments)
                  Text(
                    '5 单元',
                    style: TextStyle(
                      fontSize: 14.0,
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          if (!showGeneratedSegments)
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
                    '点击下方按钮开始将其拆解为学习单元',
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
    final segments = _generateSampleSegments();

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: segments.length,
      itemBuilder: (context, index) {
        final segment = segments[index];
        return _SegmentItem(
          segment: segment,
          onTap: () => _openSegment(segment),
        );
      },
    );
  }

  List<LearningSegment> _generateSampleSegments() {
    return [
      LearningSegment(
        id: '1',
        title: '片段 1',
        startTime: const Duration(seconds: 0),
        endTime: const Duration(seconds: 7),
        transcript: '日本銀行の植田和男総裁は',
        isCompleted: true,
      ),
      LearningSegment(
        id: '2',
        title: '片段 2',
        startTime: const Duration(seconds: 8),
        endTime: const Duration(seconds: 15),
        transcript: '金融政策決定会合で',
        isCompleted: false,
      ),
      LearningSegment(
        id: '3',
        title: '片段 3',
        startTime: const Duration(seconds: 16),
        endTime: const Duration(seconds: 24),
        transcript: '追加の利上げを見送ることを',
        isCompleted: false,
      ),
      LearningSegment(
        id: '4',
        title: '片段 4',
        startTime: const Duration(seconds: 25),
        endTime: const Duration(seconds: 32),
        transcript: '決定しました',
        isCompleted: false,
      ),
    ];
  }

  void _openSegment(LearningSegment segment) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => LearningScreen(segment: segment),
      ),
    );
  }

  void toggleSegments() {
    setState(() {
      showGeneratedSegments = true;
    });
  }
}

class _SegmentItem extends StatelessWidget {
  final LearningSegment segment;
  final VoidCallback onTap;

  const _SegmentItem({
    required this.segment,
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
                      segment.id,
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
                        segment.title,
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
                    ],
                  ),
                ),
                Container(
                  width: 32.0,
                  height: 32.0,
                  decoration: BoxDecoration(
                    color: segment.isCompleted
                        ? AppColors.success500
                        : AppColors.neutral200,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: Center(
                    child: Icon(
                      segment.isCompleted ? Icons.check : Icons.arrow_forward,
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