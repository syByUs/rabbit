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
                  minimumSize: const MaterialStatePropertyAll<Size>(
                    Size(double.infinity, 30.0),
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
                    padding: const MaterialStatePropertyAll(
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
        // 只保留合法的 TableConfig 字段（示例：边框）
        border: TableBorder.all(color: Colors.grey.shade300, width: 1),
      ),
    ],
  );

  /// 将 markdownContent 按块拆分为 table / non-table 块
  List<Map<String, dynamic>> _splitMarkdownIntoBlocks(String src) {
    final lines = src.split('\n');
    final List<Map<String, dynamic>> blocks = [];
    final buffer = <String>[];
    bool inCodeFence = false;
    bool currentIsTable = false;

    bool lineLooksLikeTable(String line) {
      final t = line.trim();
      // 表格行通常以 '|' 开头，或者是表格分隔行（--- 在 | 中）
      final sep = RegExp(r'^\s*\|?.*:-{1,}.*\|.*$');
      return t.startsWith('|') || t.contains('|') && (t.contains('--') || sep.hasMatch(line));
    }

    void flush() {
      if (buffer.isEmpty) return;
      blocks.add({
        'isTable': currentIsTable,
        'text': buffer.join('\n'),
      });
      buffer.clear();
    }

    for (var line in lines) {
      if (line.trim().startsWith('```')) {
        // 切换 code fence 状态，并该行作为普通内容保留（避免把 code block 错误识别为表格）
        buffer.add(line);
        inCodeFence = !inCodeFence;
        continue;
      }

      if (inCodeFence) {
        buffer.add(line);
        continue;
      }

      final isTableLine = lineLooksLikeTable(line);

      if (buffer.isEmpty) {
        // start new block
        currentIsTable = isTableLine;
        buffer.add(line);
      } else if (isTableLine == currentIsTable) {
        buffer.add(line);
      } else {
        // type changed -> flush and start new
        flush();
        currentIsTable = isTableLine;
        buffer.add(line);
      }
    }

    flush();
    return blocks;
  }

  Widget buildMD() {
    final mdContent = markdownContent ?? '';
    // 如果为空，直接返回空容器
    if (mdContent.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    final blocks = _splitMarkdownIntoBlocks(mdContent);

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.of(context).size.width;

        // 列表在外层已经被固定高度包裹（_buildAnalysisResults 中的 SizedBox），
        // 这里使用 ListView 作为纵向滚动容器，避免嵌套可滚动冲突。
        return ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: blocks.length,
          itemBuilder: (context, index) {
            final block = blocks[index];
            final bool isTable = block['isTable'] as bool;
            final String text = block['text'] as String;

            if (isTable) {
              // 给表格块提供可横向滚动且有限宽度的容器
              final double minTableWidth = math.max(availableWidth, 800.0);
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: minTableWidth, maxWidth: minTableWidth),
                    child: SizedBox(
                      width: minTableWidth,
                      child: MarkdownWidget(
                        data: text,
                        markdownGenerator: myGenerator,
                        config: myConfig,
                        padding: const EdgeInsets.all(8.0),

                        // 关键：内部不滚动，按内容包裹高度，避免嵌套滚动冲突
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                      ),
                    ),
                  ),
                ),
              );
            } else {
              // 普通块按纵向流式渲染
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: MarkdownWidget(
                  data: text,
                  markdownGenerator: myGenerator,
                  config: myConfig,
                  padding: const EdgeInsets.all(8.0),

                  // 关键：内部不滚动，按内容包裹高度，避免嵌套滚动冲突
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                ),
              );
            }
          },
        );
      },
    );
  }

}
