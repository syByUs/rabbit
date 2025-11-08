import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/themes/app_theme.dart';
import '../../../core/providers/app_state_provider.dart';

class AnalysisPanelWidget extends ConsumerStatefulWidget {
  final bool isVisible;
  final VoidCallback onShowAnalysis;

  const AnalysisPanelWidget({
    super.key,
    required this.isVisible,
    required this.onShowAnalysis,
  });

  @override
  ConsumerState<AnalysisPanelWidget> createState() => _AnalysisPanelWidgetState();
}

class _AnalysisPanelWidgetState extends ConsumerState<AnalysisPanelWidget> {
  bool isLoading = false;

  void _showAnalysis(BuildContext context) {
    final isPro = ref.read(isProUserProvider);
    if (!isPro) {
      _showPaywall(context);
      return;
    }

    setState(() {
      isLoading = true;
    });

    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      widget.onShowAnalysis();
      setState(() {
        isLoading = false;
      });
    });
  }

  void _showPaywall(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
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
              const SizedBox(height: AppSpacing.md),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: AppTheme.proButtonStyle.copyWith(
                  minimumSize: const WidgetStatePropertyAll<Size>(
                    Size(double.infinity, 48.0),
                  ),
                ),
                child: const Text('立即升级'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.neutral0,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadows.small,
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '词法分析',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _showAnalysis(context),
                  style: AppTheme.freeButtonStyle.copyWith(
                    padding: const WidgetStatePropertyAll(
                      EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    ),
                  ),
                  child: const Text('解锁PRO功能'),
                ),
              ],
            ),
          ),

          if (widget.isVisible || isLoading)
            AnimatedSize(
              duration: AppDuration.normal,
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: isLoading
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : Column(
                        children: _buildAnalysisResults(),
                      ),
              ),
            ),
        ],
      ),
    );
  }

  List<Widget> _buildAnalysisResults() {
    final analysisData = [
      {
        'word': '日本銀行',
        'reading': 'にほんぎんこう',
        'meaning': '[名词] 日本银行 (日本的中央银行)',
      },
      {
        'word': '総裁',
        'reading': 'そうさい',
        'meaning': '[名词] 总裁, 行长',
      },
      {
        'word': '金融政策',
        'reading': 'きんゆうせいさく',
        'meaning': '[名词] 货币政策, 金融政策',
      },
      {
        'word': '決定会合',
        'reading': 'けっていかいごう',
        'meaning': '[名词] (政策)决定会议',
      },
    ];

    return analysisData.map<Widget>((data) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.neutral200, width: 1.0),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              data['word']!,
              style: const TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              data['reading']!,
              style: TextStyle(
                fontSize: 14.0,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              data['meaning']!,
              style: const TextStyle(
                fontSize: 16.0,
                color: AppColors.textPrimary,
                height: 1.5,
              ),
            ),
          ],
        ),
      );
    }).toList();
  }
}
