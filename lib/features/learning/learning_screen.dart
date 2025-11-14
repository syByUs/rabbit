import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rabbit/core/utils/toast.dart';
import '../../../core/themes/app_theme.dart';
import '../../../core/models/resource_model.dart';
import '../../../core/models/audio_segment_model.dart';
import '../../../core/services/audio_cache_service.dart';
import '../../../core/services/audio_segmentation_service.dart';
import '../../../core/utils/audio_helper.dart';
import '../../../core/database/database_helper.dart';
import '../../../core/providers/app_state_provider.dart';
import 'widgets/control_display.dart';
import 'widgets/analysis_panel.dart';

class LearningScreen extends ConsumerStatefulWidget {
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
  ConsumerState<LearningScreen> createState() => _LearningScreenState();
}

class _LearningScreenState extends ConsumerState<LearningScreen> {
  bool isAnalysisVisible = false;
  late int _currentIndex;
  late AudioSegment _currentSegment;
  StreamSubscription? _playerCompleteSubscription;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _currentSegment = widget.segments[_currentIndex];

    // 初始化播放状态
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifier = ref.read(audioPlaybackNotifierProvider.notifier);
      notifier.updateSegmentIndex(_currentIndex);
    });

    _setupAudioListeners();
  }

  @override
  void dispose() {
    _playerCompleteSubscription?.cancel();
    AudioHelper.stop();
    super.dispose();
  }

  void _setupAudioListeners() {
    _playerCompleteSubscription = AudioHelper.player.onPlayerComplete.listen((_) async {
      print('🎵 音频播放完成');
      if (!mounted) return;

      final playbackState = ref.read(audioPlaybackNotifierProvider);

      // 添加延迟确保播放器状态已经稳定
      await Future.delayed(Duration(milliseconds: 100));

      if (playbackState.isLoopEnabled) {
        print('🔁 进入循环模式，准备播放下一首');
        await _navigateAndPlayNext();
      } else if (playbackState.isRandomEnabled) {
        print('🎲 进入随机模式，准备随机播放');
        await _playRandomSegment();
      } else {
        // 普通模式：停止播放
        ref.read(audioPlaybackNotifierProvider.notifier).stop();
      }
    });
  }

  void _showAnalysis() {
    setState(() {
      isAnalysisVisible = true;
    });
  }

  Future<void> _togglePlay() async {
    final notifier = ref.read(audioPlaybackNotifierProvider.notifier);
    final playbackState = ref.read(audioPlaybackNotifierProvider);

    if (playbackState.isPlaying) {
      await AudioHelper.pause();
      notifier.pause();
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

      // 更新播放状态
      ref.read(audioPlaybackNotifierProvider.notifier).startPlaying(resourceId, segmentIndex);

      // 检查音频片段是否已缓存
      final hasCache = await AudioCacheService.instance.hasSegment(resourceId, segmentIndex);

      if (hasCache) {
        // 直接播放已缓存的音频
        print('✅ 使用缓存的音频片段');
        final segmentPath = AudioCacheService.instance.getSegmentPath(resourceId, segmentIndex);

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
        await AudioHelper.playFile(outputPath);
        print('🔊 开始播放新分割的音频: $outputPath');
      }
    } catch (e) {
      print('❌ 播放失败: $e');
      _showMessage('播放失败: $e');
      ref.read(audioPlaybackNotifierProvider.notifier).stop();
    }
  }

  void _navigateToPrevious() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _currentSegment = widget.segments[_currentIndex];
      });

      ref.read(audioPlaybackNotifierProvider.notifier).updateSegmentIndex(_currentIndex);

      // 可选：自动播放上一段
      // _playCurrentSegment();
    }
  }

  void _navigateToNext() {
    if (_currentIndex < widget.segments.length - 1) {
      setState(() {
        _currentIndex++;
        _currentSegment = widget.segments[_currentIndex];
      });

      ref.read(audioPlaybackNotifierProvider.notifier).updateSegmentIndex(_currentIndex);

      // 可选：自动播放下一段
      // _playCurrentSegment();
    }
  }

  void _showMessage(String message) {
    showMessage(message, context);
  }

  void _toggleLoop() {
    ref.read(audioPlaybackNotifierProvider.notifier).toggleLoop();
    final isEnabled = ref.read(audioPlaybackNotifierProvider).isLoopEnabled;
    _showMessage(isEnabled ? '循环播放已开启' : '循环播放已关闭');
  }

  void _toggleRandom() {
    ref.read(audioPlaybackNotifierProvider.notifier).toggleRandom();
    final isEnabled = ref.read(audioPlaybackNotifierProvider).isRandomEnabled;
    _showMessage(isEnabled ? '随机播放已开启' : '随机播放已关闭');
  }

  Future<void> _navigateAndPlayNext() async {
    print('⏭️ _navigateAndPlayNext: 当前索引=$_currentIndex，总长度=${widget.segments.length}');

    if (widget.segments.length <= 1) {
      print('📌 只有一个片段，重复播放');
      await _playCurrentSegment(); // 只有一个片段时重复播放
      return;
    }

    setState(() {
      _currentIndex = (_currentIndex + 1) % widget.segments.length;
      _currentSegment = widget.segments[_currentIndex];
    });

    ref.read(audioPlaybackNotifierProvider.notifier).updateSegmentIndex(_currentIndex);

    print('🎯 新索引=$_currentIndex，准备播放片段: ${_currentSegment.timeRange}');

    await _playCurrentSegment();
  }

  Future<void> _playRandomSegment() async {
    if (widget.segments.length <= 1) {
      await _playCurrentSegment(); // 只有一个片段时重复播放
      return;
    }

    final random = Random();
    int newIndex;
    do {
      newIndex = random.nextInt(widget.segments.length);
    } while (newIndex == _currentIndex && widget.segments.length > 1);

    setState(() {
      _currentIndex = newIndex;
      _currentSegment = widget.segments[_currentIndex];
    });

    ref.read(audioPlaybackNotifierProvider.notifier).updateSegmentIndex(_currentIndex);

    await _playCurrentSegment();
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
          icon: const Icon(Icons.arrow_back_ios_new_sharp),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(widget.resource.title + ' - $title'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.sm),

            ControlDisplayWidget(
              segment: _currentSegment,
              isPlaying: ref.watch(audioPlaybackNotifierProvider).isPlaying,
              isLoopEnabled: ref.watch(audioPlaybackNotifierProvider).isLoopEnabled,
              isRandomEnabled: ref.watch(audioPlaybackNotifierProvider).isRandomEnabled,
              onPrevious: _hasPrevious ? _navigateToPrevious : null,
              onNext: _hasNext ? _navigateToNext : null,
              onPlayToggle: _togglePlay,
              onLoopToggle: _toggleLoop,
              onRandomToggle: _toggleRandom,
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
