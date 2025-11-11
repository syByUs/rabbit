import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/audio_segment_model.dart';
import '../models/resource_model.dart';
import '../database/database_helper.dart';
import '../database/audio_resource_schema.dart';

part 'app_state_provider.g.dart';

/// ============================================
/// 应用状态管理（使用 @riverpod 注解）
/// ============================================

/// PRO用户状态
class UserState {
  final bool isProUser;

  UserState({required this.isProUser});

  UserState copyWith({bool? isProUser}) {
    return UserState(
      isProUser: isProUser ?? this.isProUser,
    );
  }
}

/// 应用状态Notifier
@riverpod
class UserStateNotifier extends _$UserStateNotifier {
  @override
  UserState build() {
    return UserState(isProUser: false);
  }

  void upgradeToPro() {
    state = state.copyWith(isProUser: true);
  }
}

/// PRO用户状态
@riverpod
bool isProUser(IsProUserRef ref) {
  // todo release环境下需要将代码注释
  return true;
  return ref.watch(userStateNotifierProvider).isProUser;
}

/// ============================================
/// 音频播放状态
/// ============================================

class AudioPlaybackState {
  final String? currentResourceId;
  final bool isPlaying;
  final Duration? duration;
  final Duration? position;

  AudioPlaybackState({
    this.currentResourceId,
    required this.isPlaying,
    this.duration,
    this.position,
  });

  AudioPlaybackState copyWith({
    String? currentResourceId,
    bool? isPlaying,
    Duration? duration,
    Duration? position,
  }) {
    return AudioPlaybackState(
      currentResourceId: currentResourceId ?? this.currentResourceId,
      isPlaying: isPlaying ?? this.isPlaying,
      duration: duration ?? this.duration,
      position: position ?? this.position,
    );
  }

  bool isCurrentResource(String resourceId) {
    return currentResourceId == resourceId;
  }
}

/// 音频播放状态管理
@riverpod
class AudioPlaybackNotifier extends _$AudioPlaybackNotifier {
  @override
  AudioPlaybackState build() {
    return AudioPlaybackState(isPlaying: false);
  }

  void startPlaying(String resourceId) {
    state = AudioPlaybackState(
      currentResourceId: resourceId,
      isPlaying: true,
    );
  }

  void pause() {
    state = state.copyWith(isPlaying: false);
  }

  void resume() {
    state = state.copyWith(isPlaying: true);
  }

  void stop() {
    state = AudioPlaybackState(isPlaying: false);
  }
}

/// ============================================
/// 资源列表状态
/// ============================================

/// 资源列表管理
@riverpod
class ResourceListNotifier extends _$ResourceListNotifier {
  @override
  List<AudioResource> build() {
    // 初始返回空列表，然后在初始化方法中加载数据
    _loadResources();
    return sampleResources;
  }

  Future<void> _loadResources() async {
    // 加载数据库中的资源
    final resources = await DatabaseHelper.getAllAudioResources();
    if (resources.isNotEmpty) {
      state = resources.map((e) => e.toAudioResource()).toList();
    }
  }

  Future<void> updateResource(AudioResource updatedResource) async {
    // 更新数据库中的资源
    final isarResource = await DatabaseHelper.getAudioResourceById(updatedResource.id);
    if (isarResource != null) {
      final newResource = AudioResourceIsar.fromAudioResource(updatedResource);
      newResource.id = isarResource.id; // 保持原始ID
      await DatabaseHelper.saveAudioResource(newResource);
    }

    // 更新状态
    state = [
      for (final resource in state)
        resource.id == updatedResource.id ? updatedResource : resource
    ];
  }

  Future<void> addResource(AudioResource newResource, String sourceFilePath) async {
    // 将音频文件复制到应用私有目录
    final String? appFilePath = await DatabaseHelper.copyAudioFileToAppDirectory(
      sourceFilePath,
      newResource.title,
    );

    if (appFilePath == null) {
      debugPrint('Failed to copy audio file, resource will not be added');
      return;
    }

    // 保存到数据库（包含文件路径）
    final isarResource = AudioResourceIsar.fromAudioResource(
      newResource,
      filePath: appFilePath,
      originalFileName: newResource.title,
    );
    await DatabaseHelper.saveAudioResource(isarResource);

    // 更新状态
    state = [newResource, ...state];
  }

  Future<void> deleteResource(String resourceId) async {
    // 删除数据库中的资源
    final isarResource = await DatabaseHelper.getAudioResourceById(resourceId);
    if (isarResource != null) {
      await DatabaseHelper.deleteAudioResource(isarResource.id);
    }

    // 更新状态
    state = state.where((r) => r.id != resourceId).toList();
  }

  Future<void> refresh() async {
    try {
      final resources = await DatabaseHelper.getAllAudioResources();
      state = resources.map((e) => e.toAudioResource()).toList();
    } catch (e, stack) {
      // 保持当前状态或设置为错误状态
      debugPrint('Failed to refresh resources: $e');
    }
  }
}

/// ============================================
/// 搜索和筛选状态
/// ============================================

/// 搜索查询状态
@riverpod
class SearchQueryNotifier extends _$SearchQueryNotifier {
  @override
  String build() {
    return '';
  }

  void update(String query) {
    state = query;
  }

  void clear() {
    state = '';
  }
}

/// 选中的分类
@riverpod
class SelectedCategoryNotifier extends _$SelectedCategoryNotifier {
  @override
  String build() {
    return 'all';
  }

  void select(String category) {
    state = category;
  }
}

/// 当前选中的音频
@riverpod
class SelectedResourceNotifier extends _$SelectedResourceNotifier {
  @override
  AudioResource? build() {
    return null;
  }

  void select(AudioResource resource) {
    state = resource;
  }

  void clear() {
    state = null;
  }
}

/// ============================================
/// 分割状态管理 (保持原始实现)
/// ============================================

/// 音频分割状态
class SegmentationState {
  final bool isSegmenting;
  final List<AudioSegment>? segments;
  final String? error;

  SegmentationState({
    required this.isSegmenting,
    this.segments,
    this.error,
  });

  SegmentationState copyWith({
    bool? isSegmenting,
    List<AudioSegment>? segments,
    String? error,
  }) {
    return SegmentationState(
      isSegmenting: isSegmenting ?? this.isSegmenting,
      segments: segments ?? this.segments,
      error: error ?? this.error,
    );
  }
}

/// 音频分割状态管理 (暂时保持 StateNotifier，因为 Family Notifier 需要 special handling)
class SegmentationNotifier extends StateNotifier<SegmentationState> {
  SegmentationNotifier() : super(SegmentationState(isSegmenting: false));

  void startSegmenting() {
    state = SegmentationState(isSegmenting: true);
  }

  void completeSegmenting(List<AudioSegment> segments) {
    state = SegmentationState(
      isSegmenting: false,
      segments: segments,
    );
  }

  void failSegmenting(String error) {
    state = SegmentationState(
      isSegmenting: false,
      error: error,
    );
  }

  void clearSegments() {
    state = SegmentationState(isSegmenting: false);
  }
}

/// 资源分割状态Provider（按资源ID存储）
final resourceSegmentationProvider = StateNotifierProvider.family<SegmentationNotifier, SegmentationState, String>((ref, resourceId) {
  return SegmentationNotifier();
});

/// 当前资源分割状态Provider
@riverpod
SegmentationState currentResourceSegmentation(CurrentResourceSegmentationRef ref) {
  final resource = ref.watch(selectedResourceNotifierProvider);
  if (resource == null) {
    return SegmentationState(isSegmenting: false);
  }
  return ref.watch(resourceSegmentationProvider(resource.id));
}
