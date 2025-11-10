import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import 'package:rabbit/core/themes/app_theme.dart';
import '../../core/providers/app_state_provider.dart';
import '../../core/models/resource_model.dart';
import '../../core/utils/audio_helper.dart';
import 'widgets/resource_card.dart';
import 'widgets/search_bar.dart';
import 'widgets/category_tabs.dart';

class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resources = ref.watch(resourceListNotifierProvider);
    final searchQuery = ref.watch(searchQueryNotifierProvider);
    final selectedCategory = ref.watch(selectedCategoryNotifierProvider);

    // 筛选资源
    final filteredResources = resources.where((resource) {
      final matchesSearch = resource.title
          .toLowerCase()
          .contains(searchQuery.toLowerCase());
      final matchesCategory = selectedCategory == 'all' ||
          resource.category == selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        title: const Text('资源库'),
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 20.0,
          fontWeight: FontWeight.w700,
        ),
        actions: [
          Consumer(
            builder: (context, ref, child) {
              final isPro = ref.watch(isProUserProvider);
              return Padding(
                padding: const EdgeInsets.only(right: AppSpacing.md),
                child: ElevatedButton(
                  onPressed: () => _showPaywall(context, ref),
                  style: isPro ? AppTheme.proButtonStyle : AppTheme.freeButtonStyle,
                  child: Text(isPro ? '💎 PRO版' : '💎 免费版'),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 搜索栏
          // const SearchBarWidget(),

          // 分类标签
          const CategoryTabsWidget(),

          // 资源列表
          Expanded(
            child: filteredResources.isEmpty
                ? const EmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    itemCount: filteredResources.length,
                    itemBuilder: (context, index) {
                      final resource = filteredResources[index];
                      return ResourceCard(resource: resource);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showImportDialog(context),
        backgroundColor: AppColors.primary500,
        child: const Icon(Icons.add, size: 28.0),
      ),
    );
  }

  void _showPaywall(BuildContext context, WidgetRef ref) {
    final isPro = ref.read(isProUserProvider);
    if (isPro) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('您已经是PRO用户！')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => const PaywallModal(),
    );
  }

  void _showImportDialog(BuildContext context) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['mp3', 'wav', 'm4a', 'aac', 'ogg', 'flac'],
        allowMultiple: true,
      );

      if (result == null || result.files.isEmpty) {
        return;
      }

      // 显示导入状态
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('正在导入音频文件...')),
      );

      // 处理导入的文件
      final ref = ProviderScope.containerOf(context);
      for (var file in result.files) {
        final fileName = file.name;
        final filePath = file.path!;

        try {
          // 获取音频时长
          Duration? durationValue = await AudioHelper.getAudioDuration(filePath);
          final durationText = durationValue != null
              ? _formatDuration(durationValue)
              : '未知';

          // 创建新的音频资源
          final newResource = AudioResource(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            title: path.basenameWithoutExtension(fileName),
            duration: durationText,
            progress: 0,
            status: LearningStatus.notStarted,
            category: ResourceCategory.custom,
          );

          // 添加到资源列表
          ref
              .read(resourceListNotifierProvider.notifier)
              .addResource(newResource);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('成功导入: $fileName')),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('导入失败: $fileName - $e')),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('文件选择出错: $e')),
      );
    }
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '🎵',
            style: TextStyle(fontSize: 48.0, color: AppColors.textSecondary.withOpacity(0.5)),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            '暂无音频资源',
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '点击下方按钮开始导入音频',
            style: TextStyle(
              fontSize: 14.0,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class PaywallModal extends StatelessWidget {
  const PaywallModal({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Container(
        width: 320.0,
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '💎 解锁PRO版',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '享受极致的日语精听体验',
              style: TextStyle(
                fontSize: 16.0,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            _buildFeatureItem('✓', '高级分割设置 (自定义静音时长)'),
            _buildFeatureItem('✓', 'AI词法分析 (逐句语法详解)'),
            _buildFeatureItem('✓', '无限制导入音频'),
            _buildFeatureItem('✓', '云端同步'),
            const SizedBox(height: AppSpacing.lg),
            Text(
              '¥68/年',
              style: TextStyle(
                fontSize: 32.0,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '7天免费试用，可随时取消',
              style: TextStyle(
                fontSize: 14.0,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton(
              onPressed: () => _upgradeToPro(context),
              style: AppTheme.proButtonStyle.copyWith(
                minimumSize: const WidgetStatePropertyAll<Size>(
                  Size(double.infinity, 48.0),
                ),
              ),
              child: const Text('立即升级'),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('以后再说'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(color: AppColors.success500)),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 14.0, color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  void _upgradeToPro(BuildContext context) {
    Navigator.of(context).pop();
    // 这里应该调用升级API
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('🎉 恭喜！您已升级为PRO用户！')),
    );
  }
}
