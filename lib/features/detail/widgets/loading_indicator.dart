import 'package:flutter/material.dart';
import '../../../core/themes/app_theme.dart';

class LoadingIndicator extends StatelessWidget {
  final String message;

  const LoadingIndicator({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const _Dot(),
          const SizedBox(width: AppSpacing.xs),
          const _Dot(),
          const SizedBox(width: AppSpacing.xs),
          const _Dot(),
          const SizedBox(width: AppSpacing.md),
          Text(
            message,
            style: TextStyle(
              fontSize: 14.0,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _Dot extends StatefulWidget {
  const _Dot();

  @override
  State<_Dot> createState() => _DotState();
}

class _DotState extends State<_Dot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final curved = Curves.easeInOut.transform(
          (_controller.value * 3) % 1.0,
        );
        return Container(
          width: 8.0,
          height: 8.0,
          decoration: BoxDecoration(
            color: AppColors.primary500.withOpacity(
              0.5 + (0.5 * curved),
            ),
            borderRadius: BorderRadius.circular(AppRadius.full),
          ),
        );
      },
    );
  }
}