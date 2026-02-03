#!/bin/bash
# Flow-Pilot 配置脚本 - 通过 marketplace 安装
# 用法:
#   curl -fsSL https://raw.githubusercontent.com/JasonSTong/flow-pilot/main/install-from-github.sh | bash

set -e

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🚀 Flow-Pilot Marketplace 配置"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# GitHub 仓库信息
GITHUB_REPO="JasonSTong/flow-pilot"
GITHUB_BRANCH="main"

# 获取最新 commit SHA（用于缓存破坏）
echo "🔍 获取最新版本..."
LATEST_SHA=$(curl -s "https://api.github.com/repos/$GITHUB_REPO/commits/$GITHUB_BRANCH" 2>/dev/null | grep -o '"sha": "[^"]*"' | head -1 | cut -d'"' -f4 | cut -c1-7)

if [ -z "$LATEST_SHA" ]; then
    echo "⚠️  无法获取版本信息，使用默认 URL"
    MARKETPLACE_URL="https://raw.githubusercontent.com/$GITHUB_REPO/$GITHUB_BRANCH/.claude-plugin/marketplace.json"
else
    echo "✅ 最新版本: $LATEST_SHA"
    MARKETPLACE_URL="https://raw.githubusercontent.com/$GITHUB_REPO/$GITHUB_BRANCH/.claude-plugin/marketplace.json?v=$LATEST_SHA"
fi

echo ""
echo "📦 配置 marketplace"
echo "仓库: $GITHUB_REPO"
echo ""

# 路径定义
GLOBAL_CONFIG="$HOME/.claude/settings.json"
KNOWN_MARKETPLACES="$HOME/.claude/plugins/known_marketplaces.json"
CLAUDE_DIR="$HOME/.claude"
PLUGINS_DIR="$HOME/.claude/plugins"

# 检查 jq
if ! command -v jq &> /dev/null; then
    echo "❌ 需要 jq 工具"
    echo ""
    echo "安装方法："
    echo "  macOS:   brew install jq"
    echo "  Ubuntu:  sudo apt-get install jq"
    echo ""
    exit 1
fi

# 创建目录
mkdir -p "$CLAUDE_DIR"
mkdir -p "$PLUGINS_DIR"

# 配置 marketplace
if [ -f "$GLOBAL_CONFIG" ]; then
    echo "📝 更新配置..."
    cp "$GLOBAL_CONFIG" "$GLOBAL_CONFIG.backup"

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
            "knownMarketplaces": (
                (.knownMarketplaces // {}) + {
                    "anthropic": {
                        "enabled": true
                    }
                }
            )
        }
    ' "$GLOBAL_CONFIG.backup" > "$GLOBAL_CONFIG"

    if jq empty "$GLOBAL_CONFIG" 2>/dev/null; then
        rm "$GLOBAL_CONFIG.backup"
        echo "✅ 配置已更新"
    else
        mv "$GLOBAL_CONFIG.backup" "$GLOBAL_CONFIG"
        echo "❌ 配置更新失败"
        exit 1
    fi
else
    echo "📝 创建配置..."
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
  "knownMarketplaces": {
    "anthropic": {
      "enabled": true
    }
  }
}
EOF

    if jq empty "$GLOBAL_CONFIG" 2>/dev/null; then
        echo "✅ 配置已创建"
    else
        echo "❌ 配置创建失败"
        exit 1
    fi
fi

# 配置 known_marketplaces.json
echo ""
echo "📦 注册 marketplace..."

CURRENT_TIME=$(date -u +"%Y-%m-%dT%H:%M:%S.000Z")

if [ -f "$KNOWN_MARKETPLACES" ]; then
    cp "$KNOWN_MARKETPLACES" "$KNOWN_MARKETPLACES.backup"

    jq --arg url "$MARKETPLACE_URL" --arg time "$CURRENT_TIME" '
        . + {
            "flow-pilot-marketplace": {
                "source": {
                    "source": "url",
                    "url": $url
                },
                "lastUpdated": $time
            }
        }
    ' "$KNOWN_MARKETPLACES.backup" > "$KNOWN_MARKETPLACES"

    if jq empty "$KNOWN_MARKETPLACES" 2>/dev/null; then
        rm "$KNOWN_MARKETPLACES.backup"
        echo "✅ Marketplace 已注册"
    else
        mv "$KNOWN_MARKETPLACES.backup" "$KNOWN_MARKETPLACES"
        echo "❌ Marketplace 注册失败"
        exit 1
    fi
else
    cat > "$KNOWN_MARKETPLACES" << EOF
{
  "flow-pilot-marketplace": {
    "source": {
      "source": "url",
      "url": "$MARKETPLACE_URL"
    },
    "lastUpdated": "$CURRENT_TIME"
  }
}
EOF

    if jq empty "$KNOWN_MARKETPLACES" 2>/dev/null; then
        echo "✅ Marketplace 已注册"
    else
        echo "❌ Marketplace 注册失败"
        exit 1
    fi
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Marketplace 配置完成"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📝 接下来的步骤："
echo ""
echo "1. 启动 Claude Code"
echo "   claude"
echo ""
echo "2. 打开插件管理"
echo "   /plugin"
echo ""
echo "3. 切换到 Discover 标签"
echo "   → 找到 flow-pilot"
echo "   → 点击 'Install for you (user scope)'"
echo ""
echo "4. 重启 Claude Code"
echo "   exit"
echo "   claude"
echo ""
echo "5. 使用插件"
echo "   /flow-pilot <你的需求>"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📖 文档: https://github.com/$GITHUB_REPO"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
