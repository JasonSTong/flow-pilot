#!/bin/bash
# Flow-Pilot 真正的一键安装脚本
# 用法:
#   curl -fsSL https://raw.githubusercontent.com/JasonSTong/flow-pilot/main/install-from-github.sh | bash

set -e

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🚀 Flow-Pilot 一键安装"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# GitHub 仓库信息
GITHUB_REPO="JasonSTong/flow-pilot"
GITHUB_BRANCH="main"
PLUGIN_NAME="flow-pilot"
PLUGIN_VERSION="1.0.0"

# 路径定义
GLOBAL_CONFIG="$HOME/.claude/settings.json"
CLAUDE_DIR="$HOME/.claude"
PLUGINS_DIR="$CLAUDE_DIR/plugins"
PLUGIN_INSTALL_DIR="$PLUGINS_DIR/$PLUGIN_NAME"
TEMP_DIR="/tmp/flow-pilot-install-$$"

echo "📦 准备安装 Flow-Pilot"
echo "仓库: $GITHUB_REPO"
echo "版本: $PLUGIN_VERSION"
echo ""

# 检查依赖
echo "🔍 检查依赖..."
if ! command -v curl &> /dev/null; then
    echo "❌ 错误：未检测到 curl"
    exit 1
fi

if ! command -v tar &> /dev/null; then
    echo "❌ 错误：未检测到 tar"
    exit 1
fi

if ! command -v jq &> /dev/null; then
    echo "❌ 错误：未检测到 jq"
    echo ""
    echo "jq 是必需的 JSON 处理工具，请先安装："
    echo "macOS:   brew install jq"
    echo "Ubuntu:  sudo apt-get install jq"
    echo "CentOS:  sudo yum install jq"
    echo ""
    exit 1
fi

echo "✅ 依赖检查通过"
echo ""

# 创建必要目录
echo "📁 创建安装目录..."
mkdir -p "$CLAUDE_DIR"
mkdir -p "$PLUGINS_DIR"
mkdir -p "$TEMP_DIR"

# 清理旧版本
if [ -d "$PLUGIN_INSTALL_DIR" ]; then
    echo "🧹 清理旧版本..."
    rm -rf "$PLUGIN_INSTALL_DIR"
fi

# 下载插件
echo "⬇️  下载插件..."
TARBALL_URL="https://github.com/$GITHUB_REPO/archive/refs/heads/$GITHUB_BRANCH.tar.gz"

if curl -fsSL "$TARBALL_URL" -o "$TEMP_DIR/plugin.tar.gz"; then
    echo "✅ 下载完成"
else
    echo "❌ 下载失败"
    rm -rf "$TEMP_DIR"
    exit 1
fi

# 解压
echo "📦 解压插件..."
cd "$TEMP_DIR"
tar -xzf plugin.tar.gz
EXTRACTED_DIR=$(find . -maxdepth 1 -type d -name "${PLUGIN_NAME}-*" | head -1)

if [ -z "$EXTRACTED_DIR" ]; then
    echo "❌ 解压失败"
    rm -rf "$TEMP_DIR"
    exit 1
fi

# 移动到插件目录
echo "📥 安装插件文件..."
mv "$EXTRACTED_DIR" "$PLUGIN_INSTALL_DIR"
rm -rf "$TEMP_DIR"

echo "✅ 插件文件已安装到: $PLUGIN_INSTALL_DIR"
echo ""

# 配置全局设置
echo "⚙️  配置 Claude Code..."

if [ -f "$GLOBAL_CONFIG" ]; then
    echo "   更新全局配置..."
    cp "$GLOBAL_CONFIG" "$GLOBAL_CONFIG.backup"

    # 只需要启用插件，不需要 marketplace
    jq --arg plugin_path "$PLUGIN_INSTALL_DIR" '
        . + {
            "enabledPlugins": (
                (.enabledPlugins // {}) + {
                    "flow-pilot": true
                }
            )
        }
    ' "$GLOBAL_CONFIG.backup" > "$GLOBAL_CONFIG"

    if jq empty "$GLOBAL_CONFIG" 2>/dev/null; then
        rm "$GLOBAL_CONFIG.backup"
        echo "   ✅ 配置已更新"
    else
        echo "   ⚠️  配置更新失败，恢复备份"
        mv "$GLOBAL_CONFIG.backup" "$GLOBAL_CONFIG"
    fi
else
    echo "   创建全局配置..."
    cat > "$GLOBAL_CONFIG" << EOF
{
  "enabledPlugins": {
    "flow-pilot": true
  }
}
EOF

    if jq empty "$GLOBAL_CONFIG" 2>/dev/null; then
        echo "   ✅ 配置已创建"
    else
        echo "   ⚠️  配置创建失败"
    fi
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🎉 安装完成！"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📝 下一步："
echo ""
echo "1. 启动或重启 Claude Code"
echo "   exit          # 如果正在运行"
echo "   claude        # 启动"
echo ""
echo "2. 验证安装"
echo "   /flow-pilot   # 应该能看到命令"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📖 文档: https://github.com/$GITHUB_REPO"
echo "🐛 问题: https://github.com/$GITHUB_REPO/issues"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "✨ 可用命令："
echo "   /flow-pilot           - 启动智能工作流"
echo "   /flow-pilot-plan      - 查看/生成计划"
echo "   /flow-pilot-exec      - 执行计划"
echo "   /flow-pilot-test      - TDD 测试助手"
echo "   /flow-pilot-status    - 查看状态"
echo ""
