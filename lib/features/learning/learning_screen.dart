import 'package:flutter/material.dart';
import '../../../core/themes/app_theme.dart';
import '../../../core/models/resource_model.dart';
import '../../../core/models/audio_segment_model.dart';
import '../../../core/services/audio_cache_service.dart';
import '../../../core/services/audio_segmentation_service.dart';
import '../../../core/utils/audio_helper.dart';
import '../../../core/database/database_helper.dart';
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
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _currentSegment = widget.segments[_currentIndex];
    _setupAudioListeners();
  }

  @override
  void dispose() {
    AudioHelper.stop();
    super.dispose();
  }

  void _setupAudioListeners() {
    AudioHelper.player.onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() {
          _isPlaying = false;
        });
      }
    });
  }

  void _showAnalysis() {
    setState(() {
      isAnalysisVisible = true;
    });
  }

  Future<void> _togglePlay() async {
    if (_isPlaying) {
      await AudioHelper.pause();
      setState(() {
        _isPlaying = false;
      });
    } else {
      await _playCurrentSegment();
    }
  }

  Future<void> _playCurrentSegment() async {
    try {
      final segmentIndex = _currentIndex;
      final resourceId = widget.resource.id;
      final segment = _currentSegment;

      print('🎵 准备播放片段 $segmentIndex: ${segment.timeRange}');

      // 检查音频片段是否已缓存
      final hasCache = await AudioCacheService.instance.hasSegment(resourceId, segmentIndex);

      if (hasCache) {
        // 直接播放已缓存的音频
        print('✅ 使用缓存的音频片段');
        final segmentPath = AudioCacheService.instance.getSegmentPath(resourceId, segmentIndex);

        setState(() {
          _isPlaying = true;
        });

        await AudioHelper.playFile(segmentPath);
        print('🔊 开始播放缓存音频: $segmentPath');
      } else {
        // 需要先分割音频
        print('⚙️ 音频片段未缓存，开始分割...');

        // 检查资源是否有文件路径
        if (widget.resource.filePath == null || widget.resource.filePath!.isEmpty) {
          throw Exception('资源没有关联的音频文件');
        }

        // 1. 获取原始音频文件路径
        final originalAudioPath = await DatabaseHelper.buildAudioFilePath(widget.resource.filePath!);
        print('📂 原始音频路径: $originalAudioPath');

        // 2. 使用 FFmpeg 分割音频片段
        final outputPath = AudioCacheService.instance.getSegmentPath(resourceId, segmentIndex);
        await AudioSegmentationService.exportSingleSegment(
          inputPath: originalAudioPath,
          outputPath: outputPath,
          segment: segment,
        );

        print('✅ 音频分割完成，准备播放');

        // 3. 播放分割后的音频
        setState(() {
          _isPlaying = true;
        });

        await AudioHelper.playFile(outputPath);
        print('🔊 开始播放新分割的音频: $outputPath');
      }
    } catch (e) {
      print('❌ 播放失败: $e');
      _showMessage('播放失败: $e');
      setState(() {
        _isPlaying = false;
      });
    }
  }

  void _navigateToPrevious() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _currentSegment = widget.segments[_currentIndex];
        _isPlaying = false;
      });
      // 可选：自动播放上一段
      _playCurrentSegment();
    }
  }

  void _navigateToNext() {
    if (_currentIndex < widget.segments.length - 1) {
      setState(() {
        _currentIndex++;
        _currentSegment = widget.segments[_currentIndex];
        _isPlaying = false;
      });
      // 可选：自动播放下一段
      _playCurrentSegment();
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
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
              isPlaying: _isPlaying,
              onPrevious: _hasPrevious ? _navigateToPrevious : null,
              onNext: _hasNext ? _navigateToNext : null,
              onPlayToggle: _togglePlay,
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