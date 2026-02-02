#!/bin/bash
# Flow-Pilot 安装脚本 - 使用 CLI 命令，不修改配置文件
# 用法:
#   方式 1: bash install.sh (在任意位置运行)
#   方式 2: bash /path/to/flow-pilot/install.sh

set -e

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🚀 Flow-Pilot 安装程序"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 获取插件路径（安装脚本所在目录）
PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "📁 插件路径: $PLUGIN_DIR"
echo ""

# 检查是否已安装
echo "🔍 检查是否已安装..."
if claude plugin list 2>/dev/null | grep -q "flow-pilot@flow-pilot-marketplace"; then
    echo "✅ Flow-Pilot 已经安装"
    echo ""
    read -p "是否重新安装以更新到最新版本? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "❌ 取消安装"
        exit 0
    fi

    echo "🔄 卸载旧版本..."
    claude plugin uninstall flow-pilot@flow-pilot-marketplace 2>/dev/null || true
    echo "🗑️  移除旧 marketplace..."
    claude plugin marketplace remove flow-pilot-marketplace 2>/dev/null || true
fi

# 检查 marketplace 配置文件
MARKETPLACE_FILE="$PLUGIN_DIR/.claude-plugin/marketplace.json"
if [ ! -f "$MARKETPLACE_FILE" ]; then
    echo "❌ 错误: 未找到 marketplace.json"
    echo "   路径: $MARKETPLACE_FILE"
    exit 1
fi

# 验证 marketplace.json 格式
echo "📋 验证配置文件..."
if ! command -v jq &> /dev/null; then
    echo "⚠️  警告: 未安装 jq，跳过验证"
else
    if ! jq empty "$MARKETPLACE_FILE" 2>/dev/null; then
        echo "❌ 错误: marketplace.json 格式不正确"
        exit 1
    fi

    # 检查 source 字段
    SOURCE=$(jq -r '.plugins[0].source' "$MARKETPLACE_FILE")
    if [ "$SOURCE" = "." ]; then
        echo "🔧 修复 marketplace.json 中的 source 字段..."
        jq '.plugins[0].source = "./"' "$MARKETPLACE_FILE" > "$MARKETPLACE_FILE.tmp"
        mv "$MARKETPLACE_FILE.tmp" "$MARKETPLACE_FILE"
    fi
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📦 开始安装..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 1. 添加 marketplace（全局）
echo "1️⃣  添加 Flow-Pilot marketplace..."
if claude plugin marketplace add "$PLUGIN_DIR" 2>&1; then
    echo "   ✅ Marketplace 添加成功"
else
    echo "   ❌ Marketplace 添加失败"
    exit 1
fi

echo ""

# 2. 安装插件（全局）
echo "2️⃣  安装 Flow-Pilot 插件..."
if claude plugin install flow-pilot@flow-pilot-marketplace 2>&1; then
    echo "   ✅ 插件安装成功"
else
    echo "   ❌ 插件安装失败"
    exit 1
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🎉 安装完成！"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📝 下一步："
echo ""
echo "1. 重启 Claude Code（如果当前正在运行）"
echo "   exit"
echo "   claude"
echo ""
echo "2. 使用插件"
echo "   /flow-pilot <你的需求>"
echo ""
echo "3. 查看已安装的插件"
echo "   /plugin"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📖 文档: https://github.com/JasonSTong/flow-pilot"
echo "🐛 问题反馈: https://github.com/JasonSTong/flow-pilot/issues"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
