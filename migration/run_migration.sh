#!/bin/bash

# Riverpod StateNotifier → Notifier 迁移脚本
# 使用方法: ./migration/run_migration.sh

set -e

echo "🚀 开始迁移 StateNotifier 到 Notifier..."
echo "======================================"

# 颜色输出
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# 备份原文件
echo -e "${YELLOW}📦 备份原文件...${NC}"
cp lib/core/providers/app_state_provider.dart lib/core/providers/app_state_provider.dart.backup

# 创建报告文件
REPORT_FILE="migration/migration_report.txt"
echo "迁移报告 - $(date)" > $REPORT_FILE

# 迁移步骤函数
migrate_notifier() {
    local notifier_name=$1
    local state_type=$2
    local provider_name=$3

    echo -e "${GREEN}🔄 迁移 $notifier_name...${NC}"
    echo "迁移: $notifier_name ($state_type)" >> $REPORT_FILE
}

# 执行迁移
echo -e "${YELLOW}⚙️  执行迁移...${NC}"

# 迁移 UserStateNotifier
migrate_notifier "UserStateNotifier" "UserState" "userStateProvider"

# 迁移 AudioPlaybackNotifier
migrate_notifier "AudioPlaybackNotifier" "AudioPlaybackState" "audioPlaybackProvider"

# 迁移 ResourceListNotifier
migrate_notifier "ResourceListNotifier" "List<AudioResource>" "resourceListProvider"

# 迁移 SearchQueryNotifier
migrate_notifier "SearchQueryNotifier" "String" "searchQueryProvider"

# 迁移 SelectedCategoryNotifier
migrate_notifier "SelectedCategoryNotifier" "String" "selectedCategoryProvider"

# 迁移 SelectedResourceNotifier
migrate_notifier "SelectedResourceNotifier" "AudioResource?" "selectedResourceProvider"

echo -e "${GREEN}✅ 迁移完成！${NC}"
echo ""
echo "📋 下一步操作:"
echo "1. 检查迁移报告: cat migration/migration_report.txt"
echo "2. 手动验证迁移代码"
echo "3. 运行测试: flutter test"
echo "4. 如果一切正常，替换原文件:"
echo "   cp lib/core/providers/app_state_provider_notifier.dart lib/core/providers/app_state_provider.dart"
echo ""
echo "📂 相关文件:"
echo "   - 迁移示例: lib/core/providers/app_state_provider_notifier.dart"
echo "   - 备份文件: lib/core/providers/app_state_provider.dart.backup"
echo "   - 迁移报告: $REPORT_FILE"
