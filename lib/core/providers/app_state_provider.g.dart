// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_state_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$isProUserHash() => r'd3b85fc20a2b192c0155cf31d77ea724f6123507';

/// PRO用户状态
///
/// Copied from [isProUser].
@ProviderFor(isProUser)
final isProUserProvider = AutoDisposeProvider<bool>.internal(
  isProUser,
  name: r'isProUserProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$isProUserHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef IsProUserRef = AutoDisposeProviderRef<bool>;
String _$currentResourceSegmentationHash() =>
    r'838623ebc2c85a5a4b3cc4602e199eab1aed483e';

/// 当前资源分割状态Provider
///
/// Copied from [currentResourceSegmentation].
@ProviderFor(currentResourceSegmentation)
final currentResourceSegmentationProvider =
    AutoDisposeProvider<SegmentationState>.internal(
  currentResourceSegmentation,
  name: r'currentResourceSegmentationProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentResourceSegmentationHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef CurrentResourceSegmentationRef
    = AutoDisposeProviderRef<SegmentationState>;
String _$userStateNotifierHash() => r'8bfb606cf0a893de2c0cb5e0dc21470d4d9436a0';

/// 应用状态Notifier
///
/// Copied from [UserStateNotifier].
@ProviderFor(UserStateNotifier)
final userStateNotifierProvider =
    AutoDisposeNotifierProvider<UserStateNotifier, UserState>.internal(
  UserStateNotifier.new,
  name: r'userStateNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$userStateNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$UserStateNotifier = AutoDisposeNotifier<UserState>;
String _$audioPlaybackNotifierHash() =>
    r'dc053277c4e1c843bd8e41d6208300246fb923fa';

/// 音频播放状态管理
///
/// Copied from [AudioPlaybackNotifier].
@ProviderFor(AudioPlaybackNotifier)
final audioPlaybackNotifierProvider = AutoDisposeNotifierProvider<
    AudioPlaybackNotifier, AudioPlaybackState>.internal(
  AudioPlaybackNotifier.new,
  name: r'audioPlaybackNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$audioPlaybackNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AudioPlaybackNotifier = AutoDisposeNotifier<AudioPlaybackState>;
String _$resourceListNotifierHash() =>
    r'c25570be1c90fd9d1b1b7043cb7e79a0635db274';

/// ============================================
/// 资源列表状态
/// ============================================
/// 资源列表管理
///
/// Copied from [ResourceListNotifier].
@ProviderFor(ResourceListNotifier)
final resourceListNotifierProvider = AutoDisposeNotifierProvider<
    ResourceListNotifier, List<AudioResource>>.internal(
  ResourceListNotifier.new,
  name: r'resourceListNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$resourceListNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ResourceListNotifier = AutoDisposeNotifier<List<AudioResource>>;
String _$searchQueryNotifierHash() =>
    r'a487ac6634f1c443a42ba05b645ad25fde546747';

/// ============================================
/// 搜索和筛选状态
/// ============================================
/// 搜索查询状态
///
/// Copied from [SearchQueryNotifier].
@ProviderFor(SearchQueryNotifier)
final searchQueryNotifierProvider =
    AutoDisposeNotifierProvider<SearchQueryNotifier, String>.internal(
  SearchQueryNotifier.new,
  name: r'searchQueryNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$searchQueryNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SearchQueryNotifier = AutoDisposeNotifier<String>;
String _$selectedCategoryNotifierHash() =>
    r'951d6a9a0c75c5c9698469ce36d8df5a41e55a42';

/// 选中的分类
///
/// Copied from [SelectedCategoryNotifier].
@ProviderFor(SelectedCategoryNotifier)
final selectedCategoryNotifierProvider =
    AutoDisposeNotifierProvider<SelectedCategoryNotifier, String>.internal(
  SelectedCategoryNotifier.new,
  name: r'selectedCategoryNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$selectedCategoryNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SelectedCategoryNotifier = AutoDisposeNotifier<String>;
String _$selectedResourceNotifierHash() =>
    r'321f1661172f5fe05be39a2268302781dbb8791e';

/// 当前选中的音频
///
/// Copied from [SelectedResourceNotifier].
@ProviderFor(SelectedResourceNotifier)
final selectedResourceNotifierProvider = AutoDisposeNotifierProvider<
    SelectedResourceNotifier, AudioResource?>.internal(
  SelectedResourceNotifier.new,
  name: r'selectedResourceNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$selectedResourceNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SelectedResourceNotifier = AutoDisposeNotifier<AudioResource?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
