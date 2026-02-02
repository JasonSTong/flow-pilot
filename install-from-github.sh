#!/bin/bash
# Flow-Pilot GitHub 直接安装脚本
# 用法:
#   方式 1: curl -fsSL https://raw.githubusercontent.com/JasonSTong/flow-pilot/main/install-from-github.sh | bash
#   方式 2: bash install-from-github.sh

set -e

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🚀 Flow-Pilot GitHub 安装"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# GitHub 仓库信息
GITHUB_REPO="JasonSTong/flow-pilot"
GITHUB_BRANCH="main"
MARKETPLACE_URL="https://raw.githubusercontent.com/$GITHUB_REPO/$GITHUB_BRANCH/.claude-plugin/marketplace.json"

echo "📦 从 GitHub 安装 Flow-Pilot"
echo "仓库: $GITHUB_REPO"
echo ""

# 全局配置文件路径
GLOBAL_CONFIG="$HOME/.claude/settings.json"
mkdir -p "$HOME/.claude"

# 配置插件到全局
if [ -f "$GLOBAL_CONFIG" ]; then
    echo "📝 更新全局配置..."

    if command -v jq &> /dev/null; then
        # 使用 jq 更新配置
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

        rm "$GLOBAL_CONFIG.backup"
        echo "✅ 全局配置已更新（所有项目都可使用）"
    else
        echo "⚠️  未检测到 jq，请手动添加以下配置到 $GLOBAL_CONFIG:"
        echo ""
        echo '  "extraKnownMarketplaces": {'
        echo '    "flow-pilot-marketplace": {'
        echo '      "source": {'
        echo '        "source": "url",'
        echo "        \"url\": \"$MARKETPLACE_URL\""
        echo '      }'
        echo '    }'
        echo '  },'
        echo '  "enabledPlugins": {'
        echo '    "flow-pilot@flow-pilot-marketplace": true'
        echo '  }'
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
    echo "✅ 全局配置已创建（所有项目都可使用）"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🎉 安装完成！"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📝 下一步："
echo ""
echo "1. 在任意项目中启动 Claude Code"
echo "   cd /path/to/your/project"
echo "   claude"
echo ""
echo "2. 使用插件"
echo "   /flow-pilot <你的需求>"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📖 文档: https://github.com/$GITHUB_REPO"
echo "🐛 问题: https://github.com/$GITHUB_REPO/issues"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
