import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import '../../../core/themes/app_theme.dart';
import '../../../core/models/resource_model.dart';
import '../../../core/models/audio_segment_model.dart';
import '../../../core/providers/app_state_provider.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/services/audio_cache_service.dart';
import '../../../core/services/audio_segmentation_service.dart';
import '../../../core/utils/audio_helper.dart';
import '../../../core/database/database_helper.dart';
import '../../learning/learning_screen.dart';
import 'loading_indicator.dart';

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
  bool isLoading = false;
  List<AudioSegment>? segments;
  int? playingSegmentIndex; // 当前正在播放的片段索引
  int? preparingSegmentIndex; // 正在准备播放的片段索引（延迟期间）
  Set<int> segmentingIndexes = {}; // 正在分割的片段索引集合
  StreamSubscription? _playerCompleteSubscription;
  StreamSubscription? _playerStateSubscription;
  
  // 循环播放相关状态
  int? loopingSegmentIndex; // 正在循环播放的片段索引
  int loopCount = 0; // 当前循环播放的次数
  int totalLoops = 3; // 总循环次数
  bool isLooping = false; // 是否正在循环播放中
  bool loopPaused = false; // 循环是否暂停

  @override
  void initState() {
    super.initState();
    _loadSegments();
    _setupAudioListeners();
  }

  @override
  void dispose() {
    // 清理音频播放器状态和监听器
    _playerCompleteSubscription?.cancel();
    _playerStateSubscription?.cancel();
    AudioHelper.stop();
    super.dispose();
  }

  /// 设置音频监听器
  void _setupAudioListeners() {
    // 监听播放完成事件
    _playerCompleteSubscription = AudioHelper.player.onPlayerComplete.listen((_) async {
      print('🎵 音频播放完成');
      
      if (mounted) {
        // 检查是否在循环播放中
        if (isLooping && !loopPaused) {
          loopCount++;
          print('🔁 循环播放：第 $loopCount/$totalLoops 次完成');
          
          if (loopCount < totalLoops) {
            // 继续下一次循环
            print('⏳ 等待 1000ms 后继续循环...');
            await Future.delayed(const Duration(milliseconds: 1000));
            
            if (mounted && isLooping && !loopPaused && loopingSegmentIndex != null) {
              // 重新播放
              _playLoopIteration(loopingSegmentIndex!);
            }
          } else {
            // 循环完成
            print('✅ 循环播放完成！');
            setState(() {
              isLooping = false;
              loopingSegmentIndex = null;
              loopCount = 0;
              playingSegmentIndex = null;
            });
          }
        } else {
          // 普通播放完成
          setState(() {
            playingSegmentIndex = null;
          });
        }
      }
    });

    // 监听播放状态变化
    _playerStateSubscription = AudioHelper.player.onPlayerStateChanged.listen((state) {
      print('🎵 音频状态变化: $state');
      if (mounted) {
        // 如果状态变为停止，清除播放索引（但保留循环状态）
        if (state == PlayerState.stopped && !isLooping) {
          setState(() {
            playingSegmentIndex = null;
          });
        }
      }
    });
  }

  @override
  void didUpdateWidget(SegmentListWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 当资源ID改变时，重新加载数据
    if (oldWidget.resource.id != widget.resource.id) {
      print('📁 资源ID改变，重新加载数据');
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
    // 监听 Riverpod 状态变化 - ref.listen 必须在 build 方法中调用
    ref.listen(resourceSegmentationProvider(widget.resource.id), (previous, next) {
      print('🔄 分割状态变化: segments=${next.segments?.length}, isSegmenting=${next.isSegmenting}');
      
      // 如果状态被清空，同步清空本地状态
      if (next.segments == null && previous?.segments != null) {
        print('🗑️ 检测到分割数据被清空，清理本地状态');
        if (mounted) {
          setState(() {
            segments = null;
          });
        }
      }
      
      // 如果有新的分割数据，同步到本地状态
      if (next.segments != null && next.segments != segments) {
        print('✅ 检测到新的分割数据，更新本地状态');
        if (mounted) {
          setState(() {
            segments = next.segments;
          });
        }
      }
    });

    // 获取当前状态
    final segmentationState = ref.watch(resourceSegmentationProvider(widget.resource.id));
    
    // 优先使用 Riverpod 的数据，如果没有则使用本地加载的 segments
    final displaySegments = segmentationState.segments ?? segments;

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
                if (displaySegments != null && displaySegments.isNotEmpty)
                  Text(
                    '${displaySegments.length} 单元',  // 所有片段都是学习单元
                    style: TextStyle(
                      fontSize: 14.0,
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          if (isLoading || segmentationState.isSegmenting)
            const Center(
              child: LoadingIndicator(message: '正在加载分割数据...'),
            )
          else if (displaySegments == null || displaySegments.isEmpty)
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
                    '点击上方"静音分割"按钮开始',
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
            _buildSegmentList(displaySegments),
        ],
      ),
    );
  }

  Widget _buildSegmentList(List<AudioSegment> displaySegments) {
    // 所有片段都是非静音的学习单元，无需过滤
    final learningSegments = displaySegments;

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
        
        // 现在索引直接对应，无需区分 ListView 索引和原始索引
        final isPlaying = playingSegmentIndex == index;
        final isPreparing = preparingSegmentIndex == index;
        final isSegmenting = segmentingIndexes.contains(index);
        final isLoopingThis = loopingSegmentIndex == index;
        
        return _SegmentItem(
          segment: segment,
          index: index + 1,  // 显示用的序号（1-based）
          isPlaying: isPlaying,
          isPreparing: isPreparing,
          isSegmenting: isSegmenting,
          isLooping: isLoopingThis,
          loopPaused: loopPaused,
          currentLoop: isLoopingThis ? loopCount + 1 : 0,
          totalLoops: totalLoops,
          onTap: () => _playSegment(segment, index),
          onDetailTap: () => _openSegment(segment),
          onPlayTap: () => _playSegment(segment, index),
          onLoopTap: () => _startLoopPlay(segment, index),
          onLoopTogglePause: _toggleLoopPause,
          onLoopStop: _stopLoopPlay,
        );
      },
    );
  }

  /// 播放音频片段
  Future<void> _playSegment(AudioSegment segment, int index) async {
    try {
      // 如果点击的是当前正在播放的片段，则暂停
      if (playingSegmentIndex == index) {
        print('⏸️ 暂停当前播放的片段 $index');
        await AudioHelper.pause();
        setState(() {
          playingSegmentIndex = null;
        });
        return;
      }

      // 如果正在播放其他片段，先停止
      if (playingSegmentIndex != null) {
        print('⏹️ 停止其他片段的播放');
        await AudioHelper.stop();
      }

      print('🎵 准备播放片段 $index: ${segment.timeRange}');

      // 检查是否已有缓存的分割音频
      final hasCache = await AudioCacheService.instance.hasSegment(widget.resource.id, index);
      
      if (hasCache) {
        // 直接播放已缓存的音频
        print('✅ 使用缓存的音频片段');
        final segmentPath = AudioCacheService.instance.getSegmentPath(widget.resource.id, index);
        
        setState(() {
          preparingSegmentIndex = index; // 设置准备状态
        });
        
        // 延迟 500ms 给用户准备时间
        print('⏳ 等待 500ms 让用户准备...');
        await Future.delayed(const Duration(milliseconds: 500));
        
        // 检查是否仍然应该播放（用户可能在等待期间取消了）
        if (preparingSegmentIndex == index && mounted) {
          setState(() {
            preparingSegmentIndex = null;
            playingSegmentIndex = index;
          });
          
          await AudioHelper.playFile(segmentPath);
          print('🔊 开始播放缓存音频: $segmentPath');
        } else {
          // 用户取消了播放
          setState(() {
            preparingSegmentIndex = null;
          });
        }
      } else {
        // 需要先分割音频
        print('⚙️ 音频片段未缓存，开始分割...');
        
        setState(() {
          segmentingIndexes.add(index);
        });

        try {
          // 检查资源是否有文件路径
          if (widget.resource.filePath == null || widget.resource.filePath!.isEmpty) {
            throw Exception('资源没有关联的音频文件');
          }

          // 1. 获取原始音频文件路径
          final originalAudioPath = await DatabaseHelper.buildAudioFilePath(widget.resource.filePath!);
          print('📂 原始音频路径: $originalAudioPath');

          // 2. 使用 FFmpeg 分割音频片段
          final outputPath = AudioCacheService.instance.getSegmentPath(widget.resource.id, index);
          await AudioSegmentationService.exportSingleSegment(
            inputPath: originalAudioPath,
            outputPath: outputPath,
            segment: segment,
          );

          print('✅ 音频分割完成，准备播放');

          // 3. 更新状态为准备中
          setState(() {
            segmentingIndexes.remove(index);
            preparingSegmentIndex = index;
          });
          
          // 延迟 500ms 给用户准备时间
          print('⏳ 等待 500ms 让用户准备...');
          await Future.delayed(const Duration(milliseconds: 500));
          
          // 检查是否仍然应该播放
          if (preparingSegmentIndex == index && mounted) {
            setState(() {
              preparingSegmentIndex = null;
              playingSegmentIndex = index;
            });
            
            await AudioHelper.playFile(outputPath);
            print('🔊 开始播放新分割的音频: $outputPath');
          } else {
            // 用户取消了播放
            setState(() {
              preparingSegmentIndex = null;
            });
          }
        } catch (e) {
          print('❌ 分割音频失败: $e');
          setState(() {
            segmentingIndexes.remove(index);
          });
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('音频分割失败: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    } catch (e) {
      print('❌ 播放失败: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('播放失败: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// 播放单次循环迭代（内部使用）
  Future<void> _playLoopIteration(int index) async {
    if (segments == null || index >= segments!.length) return;
    
    final segment = segments![index];
    final segmentPath = AudioCacheService.instance.getSegmentPath(widget.resource.id, index);
    
    setState(() {
      playingSegmentIndex = index;
    });
    
    await AudioHelper.playFile(segmentPath);
    print('🔊 循环播放中 ($loopCount/$totalLoops): $segmentPath');
  }

  /// 开始循环播放
  Future<void> _startLoopPlay(AudioSegment segment, int index) async {
    try {
      // 先确保音频已分割并缓存
      final hasCache = await AudioCacheService.instance.hasSegment(widget.resource.id, index);
      
      if (!hasCache) {
        // 需要先分割音频
        print('⚙️ 循环播放前先分割音频...');
        setState(() {
          segmentingIndexes.add(index);
        });

        try {
          // 检查资源是否有文件路径
          if (widget.resource.filePath == null || widget.resource.filePath!.isEmpty) {
            throw Exception('资源没有关联的音频文件');
          }

          final originalAudioPath = await DatabaseHelper.buildAudioFilePath(widget.resource.filePath!);
          final outputPath = AudioCacheService.instance.getSegmentPath(widget.resource.id, index);
          await AudioSegmentationService.exportSingleSegment(
            inputPath: originalAudioPath,
            outputPath: outputPath,
            segment: segment,
          );
          
          setState(() {
            segmentingIndexes.remove(index);
          });
        } catch (e) {
          print('❌ 分割音频失败: $e');
          setState(() {
            segmentingIndexes.remove(index);
          });
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('音频分割失败，无法循环播放: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }
      }

      // 显示循环次数设置对话框
      final selectedLoops = await showDialog<int>(
        context: context,
        builder: (context) => _LoopCountDialog(initialCount: totalLoops),
      );

      if (selectedLoops == null) return;

      // 开始循环播放
      setState(() {
        totalLoops = selectedLoops;
        loopCount = 0;
        isLooping = true;
        loopPaused = false;
        loopingSegmentIndex = index;
      });

      print('🔁 开始循环播放：共 $totalLoops 次');
      
      // 延迟 500ms 给用户准备时间
      await Future.delayed(const Duration(milliseconds: 500));
      
      if (mounted && isLooping && !loopPaused) {
        _playLoopIteration(index);
      }
    } catch (e) {
      print('❌ 循环播放失败: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('循环播放失败: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// 暂停/继续循环播放
  void _toggleLoopPause() {
    if (!isLooping) return;
    
    setState(() {
      loopPaused = !loopPaused;
    });
    
    if (loopPaused) {
      print('⏸️ 暂停循环播放');
      AudioHelper.pause();
    } else {
      print('▶️ 继续循环播放');
      AudioHelper.resume();
    }
  }

  /// 停止循环播放
  void _stopLoopPlay() {
    print('⏹️ 停止循环播放');
    setState(() {
      isLooping = false;
      loopPaused = false;
      loopingSegmentIndex = null;
      loopCount = 0;
      playingSegmentIndex = null;
    });
    AudioHelper.stop();
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
  final bool isPlaying;
  final bool isPreparing;
  final bool isSegmenting;
  final bool isLooping;
  final bool loopPaused;
  final int currentLoop;
  final int totalLoops;
  final VoidCallback onTap;
  final VoidCallback onDetailTap;
  final VoidCallback onPlayTap;
  final VoidCallback onLoopTap;
  final VoidCallback onLoopTogglePause;
  final VoidCallback onLoopStop;

  const _SegmentItem({
    required this.segment,
    required this.index,
    required this.isPlaying,
    required this.isPreparing,
    required this.isSegmenting,
    required this.isLooping,
    required this.loopPaused,
    required this.currentLoop,
    required this.totalLoops,
    required this.onTap,
    required this.onDetailTap,
    required this.onPlayTap,
    required this.onLoopTap,
    required this.onLoopTogglePause,
    required this.onLoopStop,
  });

  @override
  Widget build(BuildContext context) {
    // 确定当前状态的颜色和样式
    final Color backgroundColor;
    final Color borderColor;
    final double borderWidth;
    final Color numberBgColor;
    final Color numberTextColor;
    final Color titleColor;
    
    if (isPlaying) {
      backgroundColor = AppColors.primary50;
      borderColor = AppColors.primary500;
      borderWidth = 2.0;
      numberBgColor = AppColors.primary100;
      numberTextColor = AppColors.primary700;
      titleColor = AppColors.primary700;
    } else if (isPreparing) {
      backgroundColor = AppColors.warning50;
      borderColor = AppColors.warning400;
      borderWidth = 2.0;
      numberBgColor = AppColors.warning100;
      numberTextColor = AppColors.warning700;
      titleColor = AppColors.warning700;
    } else {
      backgroundColor = AppColors.neutral0;
      borderColor = AppColors.neutral200;
      borderWidth = 1.0;
      numberBgColor = AppColors.primary50;
      numberTextColor = AppColors.primary500;
      titleColor = AppColors.textPrimary;
    }
    
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
              color: backgroundColor,
              borderRadius: BorderRadius.circular(AppRadius.md),
              boxShadow: AppShadows.small,
              border: Border.all(
                color: borderColor,
                width: borderWidth,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40.0,
                  height: 40.0,
                  decoration: BoxDecoration(
                    color: numberBgColor,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: Center(
                    child: Text(
                      '$index',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w700,
                        color: numberTextColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '片段 $index',
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.w600,
                              color: titleColor,
                            ),
                          ),
                          if (isPreparing) ...[
                            const SizedBox(width: AppSpacing.xs),
                            Text(
                              '准备中...',
                              style: TextStyle(
                                fontSize: 12.0,
                                color: AppColors.warning600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ],
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
                // 按钮组：详情按钮 + 循环播放按钮 + 普通播放按钮
                Row(
                  children: [
                    // 详情按钮（仅在非循环状态显示）
                    if (!isLooping) ...[
                      GestureDetector(
                        onTap: onDetailTap,
                        child: Container(
                          width: 32.0,
                          height: 32.0,
                          decoration: BoxDecoration(
                            color: AppColors.neutral400,
                            borderRadius: BorderRadius.circular(AppRadius.full),
                          ),
                          child: const Icon(
                            Icons.info_outline,
                            size: 16.0,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8.0),
                    ],
                    // 循环播放按钮
                    if (isLooping) ...[
                      // 循环播放中的控制按钮
                      GestureDetector(
                        onTap: onLoopTogglePause,
                        child: Container(
                          width: 32.0,
                          height: 32.0,
                          decoration: BoxDecoration(
                            color: loopPaused ? AppColors.warning500 : AppColors.success500,
                            borderRadius: BorderRadius.circular(AppRadius.full),
                          ),
                          child: Icon(
                            loopPaused ? Icons.play_arrow : Icons.pause,
                            size: 16.0,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16.0),
                      // 停止循环按钮
                      GestureDetector(
                        onTap: onLoopStop,
                        child: Container(
                          width: 32.0,
                          height: 32.0,
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(AppRadius.full),
                          ),
                          child: const Icon(
                            Icons.stop,
                            size: 16.0,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16.0),
                      // 循环次数显示
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8.0,
                          vertical: 4.0,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.success50,
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                          border: Border.all(color: AppColors.success500),
                        ),
                        child: Text(
                          '$currentLoop/$totalLoops',
                          style: TextStyle(
                            fontSize: 12.0,
                            fontWeight: FontWeight.w600,
                            color: AppColors.success500,
                          ),
                        ),
                      ),
                    ] else ...[
                      // 循环播放按钮
                      GestureDetector(
                        onTap: (isSegmenting || isPreparing) ? null : onLoopTap,
                        child: Container(
                          width: 32.0,
                          height: 32.0,
                          decoration: BoxDecoration(
                            color: (isSegmenting || isPreparing)
                                ? AppColors.neutral400
                                : AppColors.secondary500,
                            borderRadius: BorderRadius.circular(AppRadius.full),
                          ),
                          child: const Icon(
                            Icons.repeat,
                            size: 16.0,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      // 普通播放按钮
                      GestureDetector(
                        onTap: (isSegmenting || isPreparing) ? null : onPlayTap,
                        child: Container(
                          width: 32.0,
                          height: 32.0,
                          decoration: BoxDecoration(
                            color: isSegmenting 
                                ? AppColors.neutral400
                                : isPreparing
                                    ? AppColors.warning500
                                    : (isPlaying ? AppColors.primary600 : AppColors.primary500),
                            borderRadius: BorderRadius.circular(AppRadius.full),
                          ),
                          child: Center(
                            child: (isSegmenting || isPreparing)
                                ? const SizedBox(
                                    width: 16.0,
                                    height: 16.0,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.0,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : Icon(
                                    isPlaying ? Icons.pause : Icons.play_arrow,
                                    size: 16.0,
                                    color: Colors.white,
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// 循环次数设置对话框
class _LoopCountDialog extends StatefulWidget {
  final int initialCount;

  const _LoopCountDialog({required this.initialCount});

  @override
  State<_LoopCountDialog> createState() => _LoopCountDialogState();
}

class _LoopCountDialogState extends State<_LoopCountDialog> {
  late int loopCount;

  @override
  void initState() {
    super.initState();
    loopCount = widget.initialCount;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        width: 300,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(Icons.repeat, color: AppColors.secondary500, size: 24.0),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  '循环播放设置',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              '选择循环播放次数',
              style: TextStyle(
                fontSize: 14.0,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            // 循环次数选择器
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: loopCount > 1
                      ? () => setState(() => loopCount--)
                      : null,
                  icon: const Icon(Icons.remove_circle_outline),
                  color: AppColors.secondary500,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.secondary50,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: AppColors.secondary500),
                  ),
                  child: Text(
                    '$loopCount 次',
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.w700,
                      color: AppColors.secondary500,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: loopCount < 10
                      ? () => setState(() => loopCount++)
                      : null,
                  icon: const Icon(Icons.add_circle_outline),
                  color: AppColors.secondary500,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '每次播放间隔 1000 毫秒',
              style: TextStyle(
                fontSize: 12.0,
                color: AppColors.textTertiary,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('取消'),
                ),
                const SizedBox(width: AppSpacing.sm),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, loopCount),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary500,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('开始循环'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
