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
import 'dart:math' as math;

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

              // 1. (关键修复) 用 ClipRect 包裹
              child: ClipRect(
                // 2. ClipRect 会阻止 child (Container)
                //    向 AnimatedSize 报告其"溢出"的宽度。
                //    AnimatedSize 将始终使用 Column 提供的有限宽度。
                child: Container(
                  width: double.infinity, // 3. 这个 Container 现在会正确地
                  //    获取 Column 的有限宽度
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
            )
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

  Widget buildMD() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.of(context).size.width;

        // 如果内容包含表格，允许宽度扩展到至少 800（可根据需要调整）
        final bool hasTable = (markdownContent ?? '').contains(RegExp(r'^\s*\|.+\|', multiLine: true));
        final double targetWidth = hasTable ? math.max(availableWidth, 800.0) : availableWidth;

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            // 关键：同时设置 minWidth 和 maxWidth 为有限值，避免子 ListView 收到 unbounded width
            constraints: BoxConstraints(minWidth: targetWidth, maxWidth: targetWidth),
            child: SizedBox(
              width: targetWidth,
              child: MarkdownWidget(
                data: markdownContent ?? '',
                markdownGenerator: myGenerator,
                config: myConfig,
                padding: const EdgeInsets.all(8.0),
              ),
            ),
          ),
        );
      },
    );
  }

}
