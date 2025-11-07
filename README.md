# rabbit

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

已完成的工作：

1. 依赖更新 (pubspec.yaml)

- flutter_riverpod (状态管理)
- dio (网络请求)
- freezed、json_serializable (代码生成)
- build_runner、riverpod_generator (构建工具)

2. 网络层架构 (lib/core/network/)

- dio_client.dart - 封装的 Dio 客户端，支持 GET/POST/PUT/DELETE/PATCH，自动错误处理
- api_constants.dart - API 基础 URL 和端点常量

3. Riverpod 配置

- lib/core/providers/dio_provider.dart - DioClient 的全局 provider
- lib/main.dart - 使用 ProviderScope 包裹应用，Widget 改为 ConsumerWidget

4. 项目结构

- lib/features/ - 特性模块目录（按功能组织代码）
- lib/core/ - 核心基础设施

5. 文档更新

- 更新了 CODEBUDDY.md，包含新的架构说明、代码生成命令、依赖信息

使用示例：

// 在 provider 中使用 Dio
@riverpod
Future<User> fetchUser(FetchUserRef ref, String id) async {
final dio = ref.read(dioClientProvider);
final response = await dio.get('/users/$id');
return User.fromJson(response.data);
}

// 在 widget 中使用 provider
class UserScreen extends ConsumerWidget {
@override
Widget build(BuildContext context, WidgetRef ref) {
final userAsync = ref.watch(fetchUserProvider('123'));

      return userAsync.when(
        data: (user) => Text(user.name),
        loading: () => CircularProgressIndicator(),
        error: (err, stack) => Text('Error: $err'),
      );
    }
}

