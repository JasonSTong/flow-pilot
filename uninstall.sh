#!/bin/bash
# Flow-Pilot 卸载脚本 - 使用 CLI 命令，不修改配置文件
# 用法: bash uninstall.sh

set -e

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🗑️  Flow-Pilot 卸载程序"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 检查是否已安装
echo "🔍 检查安装状态..."
if ! claude plugin list 2>/dev/null | grep -q "flow-pilot@flow-pilot-marketplace"; then
    echo "ℹ️  Flow-Pilot 未安装"
    exit 0
fi

echo "✅ 检测到已安装的 Flow-Pilot"
echo ""

# 询问是否保留项目数据
echo "❓ 是否保留项目中的 Pilot 数据？"
echo "   (保留后，你的项目中的 .claude/pilots/ 目录不会被删除)"
echo ""
read -p "保留项目数据? (Y/n): " -n 1 -r </dev/tty
echo
KEEP_DATA=true
if [[ $REPLY =~ ^[Nn]$ ]]; then
    KEEP_DATA=false
fi

echo ""
echo "🗑️  开始卸载..."
echo ""

# 1. 卸载插件
echo "1️⃣  卸载 Flow-Pilot 插件..."
if claude plugin uninstall flow-pilot@flow-pilot-marketplace 2>&1; then
    echo "   ✅ 插件卸载成功"
else
    echo "   ⚠️  插件卸载失败（可能已经卸载）"
fi

echo ""

# 2. 移除 marketplace
echo "2️⃣  移除 Flow-Pilot marketplace..."
if claude plugin marketplace remove flow-pilot-marketplace 2>&1; then
    echo "   ✅ Marketplace 移除成功"
else
    echo "   ⚠️  Marketplace 移除失败（可能已经移除）"
fi

echo ""

# 3. 清理项目数据（如果用户选择）
if [ "$KEEP_DATA" = false ]; then
    echo "3️⃣  清理项目数据..."
    echo "   ⚠️  警告：即将删除所有项目中的 .claude/pilots/ 目录"
    echo "   这将删除所有 Pilot 的需求、计划和进度数据"
    echo ""
    read -p "确认删除所有项目数据? (y/N): " -n 1 -r </dev/tty
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        # 查找并列出所有 pilots 目录
        echo "   搜索项目数据..."
        pilots_dirs=$(find ~ -path "*/.claude/pilots" -type d 2>/dev/null || true)

        if [ -n "$pilots_dirs" ]; then
            echo "$pilots_dirs" | while read -r dir; do
                echo "   删除: $dir"
                rm -rf "$dir"
            done
            echo "   ✅ 已删除项目数据"
        else
            echo "   ℹ️  未找到项目数据"
        fi
    else
        echo "   ⏭️  跳过删除项目数据"
    fi
else
    echo "3️⃣  保留项目数据（跳过）"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ 卸载完成！"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if [ "$KEEP_DATA" = true ]; then
    echo "ℹ️  项目数据已保留"
    echo "   如需删除，请手动删除各项目中的 .claude/pilots/ 目录"
    echo ""
fi

echo "📝 下一步："
echo "   重启 Claude Code 以使更改生效（如果当前正在运行）"
echo "   exit"
echo "   claude"
echo ""
echo "💭 如需重新安装："
echo "   bash /path/to/flow-pilot/install.sh"
echo "   或"
echo "   curl -fsSL https://raw.githubusercontent.com/JasonSTong/flow-pilot/main/quick-install.sh | bash"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
