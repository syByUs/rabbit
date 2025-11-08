import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/audio_segment_model.dart';
import '../models/resource_model.dart';

/// ============================================
/// 应用状态管理
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
class UserStateNotifier extends StateNotifier<UserState> {
  UserStateNotifier() : super(UserState(isProUser: false));

  void upgradeToPro() {
    state = state.copyWith(isProUser: true);
  }
}

/// 音频播放状态
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
class AudioPlaybackNotifier extends StateNotifier<AudioPlaybackState> {
  AudioPlaybackNotifier() : super(AudioPlaybackState(isPlaying: false));

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

/// 资源列表状态
class ResourceListNotifier extends StateNotifier<List<AudioResource>> {
  ResourceListNotifier() : super(sampleResources);

  void updateResource(AudioResource updatedResource) {
    state = state.map((resource) {
      return resource.id == updatedResource.id ? updatedResource : resource;
    }).toList();
  }

  void addResource(AudioResource newResource) {
    state = [...state, newResource];
  }
}

/// 搜索查询状态
class SearchQueryNotifier extends StateNotifier<String> {
  SearchQueryNotifier() : super('');

  void update(String query) {
    state = query;
  }

  void clear() {
    state = '';
  }
}

/// 选中的分类
class SelectedCategoryNotifier extends StateNotifier<String> {
  SelectedCategoryNotifier() : super('all');

  void select(String category) {
    state = category;
  }
}

/// 当前选中的音频
class SelectedResourceNotifier extends StateNotifier<AudioResource?> {
  SelectedResourceNotifier() : super(null);

  void select(AudioResource resource) {
    state = resource;
  }

  void clear() {
    state = null;
  }
}

/// ============================================
/// Providers
/// ============================================

/// 用户状态Provider
final userStateProvider = StateNotifierProvider<UserStateNotifier, UserState>((ref) {
  return UserStateNotifier();
});

/// PRO用户状态
final isProUserProvider = Provider<bool>((ref) {
  // todo release环境下需要将代码注释
  return true;
  return ref.watch(userStateProvider).isProUser;
});

/// 音频播放状态Provider
final audioPlaybackProvider = StateNotifierProvider<AudioPlaybackNotifier, AudioPlaybackState>((ref) {
  return AudioPlaybackNotifier();
});

/// 资源列表Provider
final resourceListProvider = StateNotifierProvider<ResourceListNotifier, List<AudioResource>>((ref) {
  return ResourceListNotifier();
});

/// 搜索查询Provider
final searchQueryProvider = StateNotifierProvider<SearchQueryNotifier, String>((ref) {
  return SearchQueryNotifier();
});

/// 选中分类Provider
final selectedCategoryProvider = StateNotifierProvider<SelectedCategoryNotifier, String>((ref) {
  return SelectedCategoryNotifier();
});

/// 当前选中资源Provider
final selectedResourceProvider = StateNotifierProvider<SelectedResourceNotifier, AudioResource?>((ref) {
  return SelectedResourceNotifier();
});

/// ============================================
/// 分割状态管理
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

/// 音频分割状态管理
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
final currentResourceSegmentationProvider = Provider<SegmentationState>((ref) {
  final resource = ref.watch(selectedResourceProvider);
  if (resource == null) {
    return SegmentationState(isSegmenting: false);
  }
  return ref.watch(resourceSegmentationProvider(resource.id));
});
