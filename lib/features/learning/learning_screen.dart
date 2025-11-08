import 'package:flutter/material.dart';
import '../../../core/themes/app_theme.dart';
import '../../../core/models/resource_model.dart';
import 'widgets/subtitle_display.dart';
import 'widgets/analysis_panel.dart';

class LearningScreen extends StatefulWidget {
  final LearningSegment segment;

  const LearningScreen({
    super.key,
    required this.segment,
  });

  @override
  State<LearningScreen> createState() => _LearningScreenState();
}

class _LearningScreenState extends State<LearningScreen> {
  bool isAnalysisVisible = false;

  void _showAnalysis() {
    setState(() {
      isAnalysisVisible = true;
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
        title: Text(widget.segment.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.md),

            // 字幕显示
            SubtitleDisplayWidget(segment: widget.segment),

            const SizedBox(height: AppSpacing.lg),

            // 词法分析面板
            AnalysisPanelWidget(
              isVisible: isAnalysisVisible,
              onShowAnalysis: _showAnalysis,
            ),

            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }
}