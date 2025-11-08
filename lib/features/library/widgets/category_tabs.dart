import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/themes/app_theme.dart';
import '../../../core/providers/app_state_provider.dart';

class CategoryTabsWidget extends ConsumerWidget {
  const CategoryTabsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategory = ref.watch(selectedCategoryProvider);

    return Container(
      height: 48.0,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isActive = selectedCategory == category.id;

          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: _CategoryTab(
              title: category.title,
              isActive: isActive,
              onTap: () {
                ref.read(selectedCategoryProvider.notifier).state = category.id;
              },
            ),
          );
        },
      ),
    );
  }

  List<CategoryItem> get categories => [
        CategoryItem(id: 'all', title: '全部'),
        CategoryItem(id: 'jlpt', title: 'JLPT'),
        CategoryItem(id: 'news', title: '新闻'),
        CategoryItem(id: 'dialogue', title: '对话'),
        CategoryItem(id: 'custom', title: '自定义'),
      ];
}

class CategoryItem {
  final String id;
  final String title;

  const CategoryItem({required this.id, required this.title});
}

class _CategoryTab extends StatelessWidget {
  final String title;
  final bool isActive;
  final VoidCallback onTap;

  const _CategoryTab({
    required this.title,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary500 : AppColors.neutral100,
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: Border.all(
            color: isActive ? AppColors.primary500 : AppColors.neutral200,
          ),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.w500,
              color: isActive ? Colors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}