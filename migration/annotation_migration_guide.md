# Riverpod 注解迁移指南

## 概述

使用 `@riverpod` 注解实现自动代码生成，简化 provider 定义。

## 创建的文件

- **新文件**: `lib/core/providers/app_providers_with_annotations.dart`
  - 使用 `@riverpod` 注解定义所有 Notifier
  - 需要运行代码生成器生成 `.g.dart` 文件

## 使用步骤

### 1. 运行代码生成器

```bash
# 方式1：一次性生成
flutter pub run build_runner build --delete-conflicting-outputs

# 方式2：监听模式（自动重新生成）
flutter pub run build_runner watch --delete-conflicting-outputs
```

### 2. 生成的文件

运行后会在同一目录生成：
- `app_providers_with_annotations.g.dart`

### 3. 更新导入

在使用这些 provider 的文件中，需要更新导入：

**原来的导入（旧文件）:**
```dart
import '../core/providers/app_state_provider.dart';

// 使用方式
ref.read(userStateProvider.notifier).upgradeToPro();
ref.watch(userStateProvider);
```

**新的导入（注解版本）:**
```dart
import '../core/providers/app_providers_with_annotations.dart';

// 使用方式（自动生成的 provider）
ref.read(userStateNotifierProvider.notifier).upgradeToPro();
ref.watch(userStateNotifierProvider);
```

### 4. 使用方代码更新

Provider 名称会自动添加后缀：

| 旧名称 | 新生成的名称 |
|--------|------------|
| `userStateProvider` | `userStateNotifierProvider` |
| `audioPlaybackProvider` | `audioPlaybackNotifierProvider` |
| `resourceListProvider` | `resourceListNotifierProvider` |
| `searchQueryProvider` | `searchQueryNotifierProvider` |
| `selectedCategoryProvider` | `selectedCategoryNotifierProvider` |
| `selectedResourceProvider` | `selectedResourceNotifierProvider` |

## 注解版本的优势

✅ **自动生成代码** - 无需手动定义 Provider
✅ **更好的类型安全** - 编译时检查
✅ **更简洁** - 只需关注业务逻辑
✅ **支持参数** - 可以轻松创建带参数的 provider

## 未完成的部分

### SegmentationNotifier 的 Family Provider

目前 `SegmentationNotifier` 仍使用 `StateNotifierProvider.family`，因为 Riverpod Generator 对 Family Notifier 的支持需要特殊处理。

如果需要迁移，可以：

1. **保持现状** - 继续使用 `StateNotifierProvider.family`
2. **迁移到支持参数的 @riverpod**
   ```dart
   @riverpod
   SegmentationNotifier segmentationNotifier(
     SegmentationNotifierRef ref,
     String resourceId,  // 添加参数
   ) {
     return SegmentationNotifier();
   }
   ```

## 迁移清单

- [ ] 运行代码生成器: `flutter pub run build_runner build`
- [ ] 验证生成了 `.g.dart` 文件
- [ ] 更新所有导入语句
- [ ] 在 IDE 中查找所有旧的 provider 名称并替换
- [ ] 运行应用测试
- [ ] 删除旧的 `app_state_provider.dart`（确认无误后）

## 代码对比

### Before（手动定义）:
```dart
class UserStateNotifier extends Notifier<UserState> {
  @override
  UserState build() { ... }
}

final userStateProvider = NotifierProvider<UserStateNotifier, UserState>(...);
```

### After（使用注解）:
```dart
@riverpod
class UserStateNotifier extends _$UserStateNotifier {
  @override
  UserState build() { ... }
}
// 自动生成: final userStateNotifierProvider = ...
```

## 注意事项

⚠️ **不要直接修改 `.g.dart` 文件** - 这些文件会被自动生成覆盖

⚠️ **运行生成器后再使用** - 注解不会直接工作，需要先生成代码

⚠️ **清理旧的 import** - 确保移除对旧 provider 文件的引用

