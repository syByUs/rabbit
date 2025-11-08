# Riverpod 迁移指南：StateNotifier → Notifier

## 迁移概述

将代码库中的 `StateNotifier` + `StateNotifierProvider` 迁移到 `Notifier` + `NotifierProvider`。

## 📊 迁移统计

**总共需要迁移：** 6 个 Notifier

## 🔄 迁移步骤

### 阶段 1: 准备工作 (30分钟)

```bash
# 1. 确保依赖最新
flutter pub get

# 2. 创建备份
cp lib/core/providers/app_state_provider.dart lib/core/providers/app_state_provider.dart.backup

# 3. 创建迁移脚本
chmod +x migration/run_migration.sh
./migration/run_migration.sh
```

### 阶段 2: 手动迁移 (2小时)

参考迁移示例：`lib/core/providers/app_state_provider_notifier.dart`

#### Notifier 类变更

**Before:**
```dart
class UserStateNotifier extends StateNotifier<UserState> {
  UserStateNotifier() : super(UserState(isProUser: false));

  void upgradeToPro() {
    state = state.copyWith(isProUser: true);
  }
}
```

**After:**
```dart
class UserStateNotifier extends Notifier<UserState> {
  @override
  UserState build() {
    return UserState(isProUser: false);
  }

  void upgradeToPro() {
    ref.state = ref.state.copyWith(isProUser: true);
  }
}
```

#### Provider 变更

**Before:**
```dart
final userStateProvider = StateNotifierProvider<UserStateNotifier, UserState>((ref) {
  return UserStateNotifier();
});
```

**After:**
```dart
final userStateProvider = NotifierProvider<UserStateNotifier, UserState>(() {
  return UserStateNotifier();
});
```

### 阶段 3: 影响文件检查 (1小时)

检查并测试以下使用了 provider 的文件：

```bash
# 查找使用这些 provider 的文件
find lib -name "*.dart" -type f | xargs grep -l "userStateProvider\|audioPlaybackProvider\|resourceListProvider\|searchQueryProvider\|selectedCategoryProvider\|selectedResourceProvider"
```

**文件列表**：
- `lib/core/utils/audio_helper.dart`
- `lib/features/library/library_screen.dart`
- `lib/features/library/widgets/resource_card.dart`
- `lib/features/library/widgets/segmentation_dialog.dart`
- `lib/features/detail/widgets/split_section.dart`

### 阶段 4: 测试与验证 (1小时)

```bash
# 运行静态分析
flutter analyze

# 运行测试（如果存在）
flutter test

# 在模拟器/真机上测试应用
flutter run
```

### 阶段 5: 提交与清理 (30分钟)

```bash
# 删除备份（确认迁移成功后）
rm lib/core/providers/app_state_provider.dart.backup
rm lib/core/providers/app_state_provider_notifier.dart
```

## ⚠️ 注意事项

### 1. 状态更新语法变更

- `state = newState` → `ref.state = newState`
- 只修改类内部的状态赋值
- **不要修改参数名或局部变量名为 state 的情况**

### 2. 初始化方式变更

- 构造函数初始化 → `build()` 方法
- `super(initialState)` → `return initialState;`

### 3. ref 对象访问

- Notifier 和 AsyncNotifier 有内置的 `ref` 属性
- 可用于读取其他 providers、监听变化等

### 4. Family Provider 的迁移

**Before:**
```dart
final resourceSegmentationProvider = StateNotifierProvider.family<
  SegmentationNotifier, SegmentationState, String
>((ref, resourceId) {
  return SegmentationNotifier();
});
```

**After:**
```dart
final resourceSegmentationProvider = NotifierProvider.family<
  SegmentationNotifier, SegmentationState, String
>(() {
  return SegmentationNotifier();
});
```

## 🔍 验证清单

- [ ] 所有 StateNotifier 类已迁移为 Notifier
- [ ] 所有 StateNotifierProvider 已迁移为 NotifierProvider
- [ ] 状态更新语句已改为 `ref.state = ...`
- [ ] 构造函数已改为 `build()` 方法
- [ ] Flutter analyze 无错误
- [ ] 应用能够正常启动
- [ ] 所有功能测试通过
- [ ] Family Provider 正常工作
- [ ] 备份文件已删除

## ⏱️ 总时间估算

- **准备工作**：30 分钟
- **手动迁移**：2 小时（逐个 Notifier）
- **测试验证**：1 小时
- **总计**：约 3.5 小时

## 📚 相关资源

- [Riverpod 官方文档 - Notifier](https://riverpod.dev/docs/concepts/providers/notifier_provider)
- [Riverpod 迁移指南](https://riverpod.dev/docs/migration/from_state_notifier)
- 迁移示例：`lib/core/providers/app_state_provider_notifier.dart`
