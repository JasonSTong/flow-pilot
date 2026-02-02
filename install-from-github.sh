#!/bin/bash
# Flow-Pilot GitHub 直接安装脚本（改进版）
# 用法:
#   方式 1: curl -fsSL https://raw.githubusercontent.com/JasonSTong/flow-pilot/main/install-from-github.sh | bash
#   方式 2: bash install-from-github.sh

set -e

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🚀 Flow-Pilot GitHub 安装（改进版）"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# GitHub 仓库信息
GITHUB_REPO="JasonSTong/flow-pilot"
GITHUB_BRANCH="main"

# 获取最新 commit SHA（用于缓存破坏）
echo "🔍 获取最新版本信息..."
LATEST_SHA=$(curl -s "https://api.github.com/repos/$GITHUB_REPO/commits/$GITHUB_BRANCH" | grep -o '"sha": "[^"]*"' | head -1 | cut -d'"' -f4 | cut -c1-7)

if [ -z "$LATEST_SHA" ]; then
    echo "⚠️  无法获取最新版本，使用默认配置"
    MARKETPLACE_URL="https://raw.githubusercontent.com/$GITHUB_REPO/$GITHUB_BRANCH/.claude-plugin/marketplace.json"
else
    echo "✅ 最新版本: $LATEST_SHA"
    # 使用 cache_bust 参数强制刷新 GitHub CDN 缓存
    MARKETPLACE_URL="https://raw.githubusercontent.com/$GITHUB_REPO/$GITHUB_BRANCH/.claude-plugin/marketplace.json?cache_bust=$LATEST_SHA"
fi

echo ""
echo "📦 从 GitHub 安装 Flow-Pilot"
echo "仓库: $GITHUB_REPO"
echo "分支: $GITHUB_BRANCH"
echo ""

# 全局配置文件路径
GLOBAL_CONFIG="$HOME/.claude/settings.json"
CLAUDE_DIR="$HOME/.claude"
PLUGINS_DIR="$CLAUDE_DIR/plugins"
MARKETPLACES_DIR="$PLUGINS_DIR/marketplaces"

# 创建必要目录
mkdir -p "$CLAUDE_DIR"
mkdir -p "$PLUGINS_DIR"
mkdir -p "$MARKETPLACES_DIR"

# 清理可能存在的错误文件（从之前安装失败留下的）
echo "🧹 清理旧的安装残留..."
if [ -f "$MARKETPLACES_DIR/flow-pilot-marketplace" ]; then
    echo "   删除错误的 marketplace 文件"
    rm -f "$MARKETPLACES_DIR/flow-pilot-marketplace"
fi

# 检查 jq 是否安装
if ! command -v jq &> /dev/null; then
    echo "❌ 错误：未检测到 jq"
    echo ""
    echo "jq 是必需的 JSON 处理工具，请先安装："
    echo ""
    echo "macOS:   brew install jq"
    echo "Ubuntu:  sudo apt-get install jq"
    echo "CentOS:  sudo yum install jq"
    echo ""
    exit 1
fi

# 配置插件到全局
if [ -f "$GLOBAL_CONFIG" ]; then
    echo "📝 更新全局配置..."

    # 备份原配置
    cp "$GLOBAL_CONFIG" "$GLOBAL_CONFIG.backup"

    # 使用 jq 更新配置
    jq --arg url "$MARKETPLACE_URL" '
        . + {
            "extraKnownMarketplaces": (
                (.extraKnownMarketplaces // {}) + {
                    "flow-pilot-marketplace": {
                        "source": {
                            "source": "url",
                            "url": $url
                        }
                    }
                }
            ),
            "enabledPlugins": (
                (.enabledPlugins // {}) + {
                    "flow-pilot@flow-pilot-marketplace": true
                }
            ),
            "knownMarketplaces": (
                (.knownMarketplaces // {}) + {
                    "anthropic": {
                        "enabled": true
                    }
                }
            )
        }
    ' "$GLOBAL_CONFIG.backup" > "$GLOBAL_CONFIG"

    # 验证 JSON 格式
    if jq empty "$GLOBAL_CONFIG" 2>/dev/null; then
        rm "$GLOBAL_CONFIG.backup"
        echo "✅ 全局配置已更新"
    else
        echo "❌ 配置文件格式错误，恢复备份"
        mv "$GLOBAL_CONFIG.backup" "$GLOBAL_CONFIG"
        exit 1
    fi
else
    echo "📝 创建全局配置..."
    cat > "$GLOBAL_CONFIG" << EOF
{
  "extraKnownMarketplaces": {
    "flow-pilot-marketplace": {
      "source": {
        "source": "url",
        "url": "$MARKETPLACE_URL"
      }
    }
  },
  "enabledPlugins": {
    "flow-pilot@flow-pilot-marketplace": true
  },
  "knownMarketplaces": {
    "anthropic": {
      "enabled": true
    }
  }
}
EOF

    # 验证 JSON 格式
    if jq empty "$GLOBAL_CONFIG" 2>/dev/null; then
        echo "✅ 全局配置已创建"
    else
        echo "❌ 配置文件创建失败"
        exit 1
    fi
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🎉 安装完成！"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📝 下一步："
echo ""
echo "1. 退出当前 Claude Code 会话（如果正在运行）"
echo "   exit"
echo ""
echo "2. 在任意项目中启动 Claude Code"
echo "   cd /path/to/your/project"
echo "   claude"
echo ""
echo "3. 进入插件管理安装插件"
echo "   /plugin"
echo "   → 选择 Marketplaces 标签"
echo "   → 点击 Update marketplace"
echo "   → 切换到 Discover 标签"
echo "   → 找到 flow-pilot 并安装"
echo ""
echo "4. 重启后使用插件"
echo "   exit"
echo "   claude"
echo "   /flow-pilot <你的需求>"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📖 文档: https://github.com/$GITHUB_REPO"
echo "🐛 问题: https://github.com/$GITHUB_REPO/issues"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "💡 提示："
echo "   - 如果遇到 marketplace 加载失败，等待 5-10 分钟后重试"
echo "   - GitHub CDN 缓存可能需要时间更新"
echo "   - 使用 /plugin 命令管理插件"
echo ""
