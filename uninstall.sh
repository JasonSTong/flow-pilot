#!/bin/bash
# Flow-Pilot 卸载脚本（改进版）
# 用法: bash uninstall.sh

set -e

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🗑️  Flow-Pilot 卸载程序（改进版）"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 路径定义
GLOBAL_CONFIG="$HOME/.claude/settings.json"
KNOWN_MARKETPLACES="$HOME/.claude/plugins/known_marketplaces.json"
CLAUDE_DIR="$HOME/.claude"
PLUGINS_DIR="$CLAUDE_DIR/plugins"
PLUGIN_INSTALL_DIR="$PLUGINS_DIR/flow-pilot"
MARKETPLACES_DIR="$PLUGINS_DIR/marketplaces"
CACHE_DIR="$PLUGINS_DIR/cache"

# 检查 jq 是否安装
if ! command -v jq &> /dev/null; then
    echo "⚠️  警告：未检测到 jq，将使用手动清理模式"
    echo ""
    USE_JQ=false
else
    USE_JQ=true
fi

# 检查是否已安装
echo "🔍 检查安装状态..."
INSTALLED=false

if [ -f "$GLOBAL_CONFIG" ] && [ "$USE_JQ" = true ]; then
    if jq -e '.enabledPlugins["flow-pilot"]' "$GLOBAL_CONFIG" &>/dev/null || \
       jq -e '.enabledPlugins["flow-pilot@flow-pilot-marketplace"]' "$GLOBAL_CONFIG" &>/dev/null; then
        INSTALLED=true
    fi
elif [ -f "$GLOBAL_CONFIG" ]; then
    if grep -q "flow-pilot" "$GLOBAL_CONFIG"; then
        INSTALLED=true
    fi
fi

# 同时检查插件目录
if [ -d "$PLUGIN_INSTALL_DIR" ]; then
    INSTALLED=true
fi

if [ "$INSTALLED" = false ]; then
    echo "ℹ️  Flow-Pilot 未安装或已卸载"
    echo ""
    # 即使未安装，也清理可能残留的文件
    echo "🧹 清理可能的残留文件..."
else
    echo "✅ 检测到已安装的 Flow-Pilot"
    echo ""
fi

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

# 1. 从配置文件中移除
if [ -f "$GLOBAL_CONFIG" ] && [ "$USE_JQ" = true ]; then
    echo "1️⃣  从配置文件中移除 Flow-Pilot..."

    # 备份配置
    cp "$GLOBAL_CONFIG" "$GLOBAL_CONFIG.backup"

    # 移除 enabledPlugins 中的条目（两种格式都删除）
    jq 'del(.enabledPlugins["flow-pilot"]) | del(.enabledPlugins["flow-pilot@flow-pilot-marketplace"])' "$GLOBAL_CONFIG.backup" > "$GLOBAL_CONFIG.tmp1"

    # 移除 extraKnownMarketplaces 中的条目
    jq 'del(.extraKnownMarketplaces["flow-pilot-marketplace"])' "$GLOBAL_CONFIG.tmp1" > "$GLOBAL_CONFIG"

    # 验证 JSON 格式
    if jq empty "$GLOBAL_CONFIG" 2>/dev/null; then
        rm "$GLOBAL_CONFIG.backup" "$GLOBAL_CONFIG.tmp1"
        echo "   ✅ 配置文件已更新"
    else
        echo "   ⚠️  配置文件更新失败，恢复备份"
        mv "$GLOBAL_CONFIG.backup" "$GLOBAL_CONFIG"
        rm -f "$GLOBAL_CONFIG.tmp1"
    fi
else
    echo "1️⃣  跳过配置文件更新（未检测到 jq 或配置文件不存在）"
    echo "   ⚠️  请手动编辑 $GLOBAL_CONFIG"
    echo "   移除 flow-pilot@flow-pilot-marketplace 相关配置"
fi

# 从 known_marketplaces.json 中移除
if [ -f "$KNOWN_MARKETPLACES" ] && [ "$USE_JQ" = true ]; then
    echo ""
    echo "   📝 从 known_marketplaces.json 中移除..."

    # 备份配置
    cp "$KNOWN_MARKETPLACES" "$KNOWN_MARKETPLACES.backup"

    # 移除 flow-pilot-marketplace
    jq 'del(.["flow-pilot-marketplace"])' "$KNOWN_MARKETPLACES.backup" > "$KNOWN_MARKETPLACES"

    # 验证 JSON 格式
    if jq empty "$KNOWN_MARKETPLACES" 2>/dev/null; then
        rm "$KNOWN_MARKETPLACES.backup"
        echo "   ✅ known_marketplaces.json 已更新"
    else
        echo "   ⚠️  known_marketplaces.json 更新失败，恢复备份"
        mv "$KNOWN_MARKETPLACES.backup" "$KNOWN_MARKETPLACES"
    fi
fi

echo ""

# 2. 清理插件文件
echo "2️⃣  清理插件文件..."
CLEANED=false

# 清理直接安装的插件
if [ -d "$PLUGIN_INSTALL_DIR" ]; then
    rm -rf "$PLUGIN_INSTALL_DIR"
    echo "   ✅ 插件目录已删除: $PLUGIN_INSTALL_DIR"
    CLEANED=true
fi

# 清理缓存
if [ -d "$CACHE_DIR/flow-pilot-marketplace" ]; then
    rm -rf "$CACHE_DIR/flow-pilot-marketplace"
    echo "   ✅ 缓存已删除"
    CLEANED=true
fi

if [ "$CLEANED" = false ]; then
    echo "   ℹ️  未找到插件文件"
fi

echo ""

# 3. 清理 marketplace 残留文件
echo "3️⃣  清理 marketplace 残留..."
# 删除可能错误创建的文件
if [ -f "$MARKETPLACES_DIR/flow-pilot-marketplace" ]; then
    rm -f "$MARKETPLACES_DIR/flow-pilot-marketplace"
    echo "   ✅ 删除错误的 marketplace 文件"
fi

# 删除正确的目录
if [ -d "$MARKETPLACES_DIR/flow-pilot-marketplace" ]; then
    rm -rf "$MARKETPLACES_DIR/flow-pilot-marketplace"
    echo "   ✅ marketplace 目录已删除"
fi

if [ ! -f "$MARKETPLACES_DIR/flow-pilot-marketplace" ] && [ ! -d "$MARKETPLACES_DIR/flow-pilot-marketplace" ]; then
    echo "   ℹ️  未找到 marketplace 文件"
fi

echo ""

# 4. 清理项目数据（如果用户选择）
if [ "$KEEP_DATA" = false ]; then
    echo "4️⃣  清理项目数据..."
    echo "   ⚠️  警告：即将删除所有项目中的 .claude/pilots/ 目录"
    echo "   这将删除所有 Pilot 的需求、计划和进度数据"
    echo ""
    read -p "确认删除所有项目数据? (y/N): " -n 1 -r </dev/tty
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo ""
        echo "   搜索范围选项："
        echo "   1) 仅搜索常见项目目录 (~/Projects, ~/Documents, ~/Desktop, ~/Downloads)"
        echo "   2) 搜索整个用户目录 (可能很慢)"
        echo "   3) 手动输入项目路径"
        echo ""
        read -p "   请选择 (1/2/3): " -n 1 -r </dev/tty
        echo

        case $REPLY in
            1)
                # 搜索常见项目目录
                echo "   搜索常见项目目录..."
                SEARCH_PATHS=("$HOME/Projects" "$HOME/Documents" "$HOME/Desktop" "$HOME/Downloads" "$HOME/Code" "$HOME/Dev" "$HOME/Workspace")
                pilots_dirs=""
                for path in "${SEARCH_PATHS[@]}"; do
                    if [ -d "$path" ]; then
                        found=$(find "$path" -maxdepth 5 -path "*/.claude/pilots" -type d 2>/dev/null || true)
                        if [ -n "$found" ]; then
                            pilots_dirs="$pilots_dirs$found"$'\n'
                        fi
                    fi
                done
                ;;
            2)
                # 搜索整个用户目录
                echo "   ⚠️  搜索整个用户目录（这可能需要几分钟）..."
                pilots_dirs=$(find ~ -path "*/.claude/pilots" -type d 2>/dev/null || true)
                ;;
            3)
                # 手动输入
                echo ""
                read -p "   请输入项目目录路径: " project_path </dev/tty
                if [ -d "$project_path/.claude/pilots" ]; then
                    pilots_dirs="$project_path/.claude/pilots"
                else
                    echo "   ⚠️  未找到 $project_path/.claude/pilots"
                    pilots_dirs=""
                fi
                ;;
            *)
                echo "   ⏭️  跳过"
                pilots_dirs=""
                ;;
        esac

        if [ -n "$pilots_dirs" ]; then
            echo "   找到以下 Pilot 数据目录："
            echo "$pilots_dirs" | grep -v '^$' | sed 's/^/   - /'
            echo ""
            echo "   正在删除..."
            echo "$pilots_dirs" | grep -v '^$' | while read -r dir; do
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
    echo "4️⃣  保留项目数据（跳过）"
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
echo ""
echo "1. 重启 Claude Code 以使更改生效（如果当前正在运行）"
echo "   exit"
echo "   claude"
echo ""
echo "2. 验证卸载（可选）"
echo "   /plugin"
echo "   → 检查 Installed 标签页，确认 flow-pilot 已移除"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "💭 如需重新安装："
echo ""
echo "方式 1（GitHub 直接安装）："
echo "   curl -fsSL https://raw.githubusercontent.com/JasonSTong/flow-pilot/main/install-from-github.sh | bash"
echo ""
echo "方式 2（本地安装）："
echo "   bash /path/to/flow-pilot/install.sh"
echo ""
echo "方式 3（快速安装）："
echo "   curl -fsSL https://raw.githubusercontent.com/JasonSTong/flow-pilot/main/quick-install.sh | bash"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
