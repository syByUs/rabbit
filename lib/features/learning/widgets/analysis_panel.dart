import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:markdown_widget/config/all.dart';
import 'package:markdown_widget/config/toc.dart';
import 'package:markdown_widget/widget/blocks/container/table.dart';
import 'package:markdown_widget/widget/markdown.dart';
import 'package:markdown_widget/widget/markdown_block.dart';
import '../../../core/themes/app_theme.dart';
import '../../../core/providers/app_state_provider.dart';
import 'package:markdown/markdown.dart' as md;

class AnalysisPanelWidget extends ConsumerStatefulWidget {
  final bool isVisible;
  final VoidCallback onShowAnalysis;

  const AnalysisPanelWidget({
    super.key,
    required this.isVisible,
    required this.onShowAnalysis,
  });

  @override
  ConsumerState<AnalysisPanelWidget> createState() => _AnalysisPanelWidgetState();
}

class _AnalysisPanelWidgetState extends ConsumerState<AnalysisPanelWidget> {
  bool isLoading = false;
  String? markdownContent;

  void _showAnalysis(BuildContext context) async {
    final isPro = ref.read(isProUserProvider);
    if (!isPro) {
      _showPaywall(context);
      return;
    }

    setState(() {
      isLoading = true;
    });

    // 加载markdown文件
    try {
      final String content = await rootBundle.loadString('assets/markdown/chunk_002.md');
      if (mounted) {
        setState(() {
          markdownContent = content;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          markdownContent = '# 加载失败\n\n无法加载分析内容：\`${e.toString()}\`';
          isLoading = false;
        });
      }
    }

    widget.onShowAnalysis();
  }

  void _showPaywall(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
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
              const SizedBox(height: AppSpacing.md),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: AppTheme.proButtonStyle.copyWith(
                  minimumSize: const WidgetStatePropertyAll<Size>(
                    Size(double.infinity, 48.0),
                  ),
                ),
                child: const Text('立即升级'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.neutral0,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadows.small,
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '词法分析',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _showAnalysis(context),
                  style: AppTheme.freeButtonStyle.copyWith(
                    padding: const WidgetStatePropertyAll(
                      EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
                    ),
                  ),
                  child: const Text('解锁PRO功能'),
                ),
              ],
            ),
          ),

          if (widget.isVisible || isLoading)
            AnimatedSize(
              duration: AppDuration.normal,
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: isLoading
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : markdownContent != null
                        ? _buildAnalysisResults()
                        : const SizedBox.shrink(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAnalysisResults() {
    return SizedBox(
      height: 400, // 设置一个固定高度
      child: buildMD(),
    );
  }
  final tocController = TocController();
  // 2. (关键) 创建一个配置好 GFM 扩展的 MarkdownGenerator 实例
  final MarkdownGenerator myGenerator = MarkdownGenerator(
    // 3. (关键) 使用 'extensionSet' (单数) 参数
    // 传入 'm.ExtensionSet.gitHubFlavored' 实例
    extensionSet: md.ExtensionSet.gitHubFlavored,
  );

  // 3. 创建样式配置
  final MarkdownConfig myConfig = MarkdownConfig(
    configs: [
      TableConfig(
        // 在这里定义表格样式，例如边框、内边距等
        border: TableBorder.all(color: Colors.grey.shade300, width: 1),
      ),
    ],
  );

  Widget buildMD() => MarkdownWidget( // <--- 移除 SingleChildScrollView
    data: markdownContent ?? '',
    markdownGenerator: myGenerator,
    config: myConfig,
    padding: const EdgeInsets.all(8.0), // <--- 将 padding 直接传给 MarkdownWidget
  );

}
