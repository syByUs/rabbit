import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  bool isCurrentResource(String resourceId) {
    return state.currentResourceId == resourceId;
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
