import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/themes/app_theme.dart';
import '../../../core/models/resource_model.dart';
import '../../../core/providers/app_state_provider.dart';
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
  bool showSegments = false;

  void _splitAudio() {
    final isPro = ref.read(isProUserProvider);
    if (!isPro) {
      _showPaywall();
      return;
    }

    setState(() {
      isSplitting = true;
    });

    // 模拟分割过程
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;

      setState(() {
        isSplitting = false;
        showSegments = true;
      });

      _showMessage('音频分割完成！已生成5个学习单元');
    });
  }

  void _showPaywall() {
    showDialog(
      context: context,
      builder: (context) => const PaywallModal(),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
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
              child: const Text('通过静音点自动分割'),
            ),
          const SizedBox(height: AppSpacing.sm),
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
