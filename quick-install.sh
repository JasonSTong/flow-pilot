#!/bin/bash
# Flow-Pilot 一键安装脚本
# 用法: curl -fsSL https://raw.githubusercontent.com/JasonSTong/flow-pilot/main/quick-install.sh | bash
#
# 此脚本会：
# 1. 下载 Flow-Pilot 到 ~/.claude/plugins/flow-pilot
# 2. 配置全局设置（所有项目都可使用）

set -e

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🚀 Flow-Pilot 一键安装"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 插件安装位置
PLUGIN_DIR="$HOME/.claude/plugins/flow-pilot"
MARKETPLACE_DIR="$HOME/.claude/plugins/marketplaces/flow-pilot-marketplace"

echo "📁 插件安装位置: $PLUGIN_DIR"
echo "📁 市场安装位置: $MARKETPLACE_DIR"
echo ""

# 创建目录
mkdir -p "$HOME/.claude/plugins"
mkdir -p "$HOME/.claude/plugins/marketplaces"

# 检查是否已安装插件
if [ -d "$PLUGIN_DIR" ]; then
    echo "ℹ️  检测到已安装的 Flow-Pilot"
    read -p "是否更新到最新版本? (Y/n): " -n 1 -r </dev/tty
    echo
    if [[ $REPLY =~ ^[Nn]$ ]]; then
        echo "❌ 取消安装"
        exit 0
    fi

    echo "🔄 更新 Flow-Pilot..."
    cd "$PLUGIN_DIR"

    if [ -d ".git" ]; then
        git pull origin main
    else
        echo "⚠️  现有安装不是 git 仓库，删除后重新安装..."
        cd "$HOME/.claude/plugins"
        rm -rf flow-pilot
        git clone https://github.com/JasonSTong/flow-pilot.git
    fi
else
    echo "📥 下载 Flow-Pilot..."
    cd "$HOME/.claude/plugins"

    # 检查是否有 git
    if command -v git &> /dev/null; then
        git clone https://github.com/JasonSTong/flow-pilot.git
    else
        echo "⚠️  未检测到 git，使用 curl 下载..."
        mkdir -p flow-pilot
        cd flow-pilot
        curl -fsSL https://github.com/JasonSTong/flow-pilot/archive/refs/tags/v1.0.0.tar.gz | tar -xz --strip-components=1
    fi
fi

echo ""
echo "📦 创建 marketplace 结构..."

# 创建 marketplace 目录
mkdir -p "$MARKETPLACE_DIR/.claude-plugin"
mkdir -p "$MARKETPLACE_DIR/plugins"

# 创建 marketplace.json
cat > "$MARKETPLACE_DIR/.claude-plugin/marketplace.json" << 'EOF'
{
  "$schema": "https://anthropic.com/claude-code/marketplace.schema.json",
  "name": "flow-pilot-marketplace",
  "description": "Flow-Pilot plugin marketplace",
  "owner": {
    "name": "Jason Chen",
    "email": "chensitongc@gmail.com"
  },
  "plugins": [
    {
      "name": "flow-pilot",
      "version": "1.0.0",
      "description": "智能 AI 工作流系统 - 让 Claude Code 以更规范、更高效的方式引导你的开发工作",
      "author": {
        "name": "Jason Chen",
        "email": "chensitongc@gmail.com"
      },
      "source": "./plugins/flow-pilot",
      "category": "development",
      "homepage": "https://github.com/JasonSTong/flow-pilot"
    }
  ]
}
EOF

# 创建到实际插件的符号链接
rm -f "$MARKETPLACE_DIR/plugins/flow-pilot"
ln -s "$PLUGIN_DIR" "$MARKETPLACE_DIR/plugins/flow-pilot"

echo "✅ Marketplace 结构已创建"

echo ""
echo "⚙️  配置全局设置..."

# 全局配置文件路径
GLOBAL_CONFIG="$HOME/.claude/settings.json"

# 配置插件到全局
if [ -f "$GLOBAL_CONFIG" ]; then
    echo "📝 更新全局配置..."

    if command -v jq &> /dev/null; then
        # 使用 jq 更新配置
        cp "$GLOBAL_CONFIG" "$GLOBAL_CONFIG.backup"

        jq --arg path "$MARKETPLACE_DIR" '
            . + {
                "extraKnownMarketplaces": (
                    (.extraKnownMarketplaces // {}) + {
                        "flow-pilot-marketplace": {
                            "source": {
                                "source": "directory",
                                "path": $path
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
        echo '        "source": "directory",'
        echo "        \"path\": \"$MARKETPLACE_DIR\""
        echo '      }'
        echo '    }'
        echo '  },'
        echo '  "enabledPlugins": {'
        echo '    "flow-pilot@flow-pilot-marketplace": true'
        echo '  }'
    fi
else
    echo "📝 创建全局配置..."
    mkdir -p "$HOME/.claude"
    cat > "$GLOBAL_CONFIG" << EOF
{
  "extraKnownMarketplaces": {
    "flow-pilot-marketplace": {
      "source": {
        "source": "directory",
        "path": "$MARKETPLACE_DIR"
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
echo "📖 文档: https://github.com/JasonSTong/flow-pilot"
echo "🐛 问题: https://github.com/JasonSTong/flow-pilot/issues"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
