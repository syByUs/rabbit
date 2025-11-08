import 'package:flutter/material.dart';
import 'dart:math';
import '../../../core/themes/app_theme.dart';

class AudioWaveformWidget extends StatefulWidget {
  const AudioWaveformWidget({super.key});

  @override
  State<AudioWaveformWidget> createState() => _AudioWaveformWidgetState();
}

class _AudioWaveformWidgetState extends State<AudioWaveformWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final int barCount = 50;
  late List<double> barHeights;
  late List<Animation<double>> barAnimations;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    // Generate random heights
    barHeights = List.generate(barCount, (_) {
      return Random().nextDouble() * 60 + 20;
    });

    // Create staggered animations
    barAnimations = List.generate(barCount, (index) {
      return Tween<double>(begin: 0, end: barHeights[index]).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(
            (index / barCount) * 0.5,
            1.0,
            curve: Curves.easeInOut,
          ),
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80.0,
      decoration: BoxDecoration(
        color: AppColors.primary50.withOpacity(0.5),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(barCount, (index) {
          return AnimatedBuilder(
            animation: barAnimations[index],
            builder: (context, child) {
              final height = barAnimations[index].value;
              return Container(
                width: 2.0,
                height: height,
                decoration: BoxDecoration(
                  color: AppColors.primary500,
                  borderRadius: BorderRadius.circular(1.0),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}