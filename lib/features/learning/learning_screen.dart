import 'package:flutter/material.dart';
import '../../../core/themes/app_theme.dart';
import '../../../core/models/resource_model.dart';
import '../../../core/models/audio_segment_model.dart';
import 'widgets/control_display.dart';
import 'widgets/analysis_panel.dart';

class LearningScreen extends StatefulWidget {
  final AudioResource resource;
  final List<AudioSegment> segments;
  final int initialIndex;

  const LearningScreen({
    super.key,
    required this.resource,
    required this.segments,
    required this.initialIndex,
  });

  @override
  State<LearningScreen> createState() => _LearningScreenState();
}

class _LearningScreenState extends State<LearningScreen> {
  bool isAnalysisVisible = false;
  late int _currentIndex;
  late AudioSegment _currentSegment;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _currentSegment = widget.segments[_currentIndex];
  }

  void _showAnalysis() {
    setState(() {
      isAnalysisVisible = true;
    });
  }

  void _navigateToPrevious() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _currentSegment = widget.segments[_currentIndex];
      });
    }
  }

  void _navigateToNext() {
    if (_currentIndex < widget.segments.length - 1) {
      setState(() {
        _currentIndex++;
        _currentSegment = widget.segments[_currentIndex];
      });
    }
  }

  bool get _hasPrevious => _currentIndex > 0;
  bool get _hasNext => _currentIndex < widget.segments.length - 1;

  @override
  Widget build(BuildContext context) {
    final title = '片段 ${(_currentIndex + 1)}/${widget.segments.length}';

    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(widget.resource.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.sm),

            // 导航指示器
            Container(
              margin: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.neutral0,
                borderRadius: BorderRadius.circular(AppRadius.md),
                boxShadow: AppShadows.small,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.sm),

            // 字幕显示
            ControlDisplayWidget(
              segment: _currentSegment,
              onPrevious: _hasPrevious ? _navigateToPrevious : null,
              onNext: _hasNext ? _navigateToNext : null,
            ),

            const SizedBox(height: AppSpacing.sm),

            // 词法分析面板
            AnalysisPanelWidget(
              isVisible: isAnalysisVisible,
              onShowAnalysis: _showAnalysis,
            ),

            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}