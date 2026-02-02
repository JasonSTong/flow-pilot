#!/bin/bash
# Flow-Pilot 打包脚本
# 用法: bash package.sh

set -e

VERSION="1.0.0"
PACKAGE_NAME="flow-pilot-v${VERSION}"
ARCHIVE_NAME="${PACKAGE_NAME}.tar.gz"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📦 Flow-Pilot 打包程序"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 获取脚本所在目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# 创建临时目录
TEMP_DIR=$(mktemp -d)
PACKAGE_DIR="$TEMP_DIR/$PACKAGE_NAME"

echo "📁 创建打包目录: $PACKAGE_DIR"
mkdir -p "$PACKAGE_DIR"

# 复制必要文件
echo "📋 复制文件..."
cp -r skills "$PACKAGE_DIR/"
cp -r scripts "$PACKAGE_DIR/"
cp -r .claude-plugin "$PACKAGE_DIR/"
cp README.md "$PACKAGE_DIR/"
cp CHANGELOG.md "$PACKAGE_DIR/"
cp LICENSE "$PACKAGE_DIR/"
cp install.sh "$PACKAGE_DIR/"
cp .gitignore "$PACKAGE_DIR/"

# 确保脚本可执行
chmod +x "$PACKAGE_DIR/install.sh"
chmod +x "$PACKAGE_DIR/scripts/"*.sh

# 创建安装说明
cat > "$PACKAGE_DIR/INSTALL.txt" << 'EOF'
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🚀 Flow-Pilot 安装说明
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

快速安装（推荐）
═══════════════

1. 解压到任意目录：
   tar -xzf flow-pilot-v1.0.0.tar.gz

2. 进入你的项目目录：
   cd /path/to/your/project

3. 运行安装脚本：
   bash /path/to/flow-pilot-v1.0.0/install.sh

4. 重启 Claude Code，测试：
   /flow-pilot

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

使用 Claude Code 插件命令（更快）
═══════════════════════════════

1. 解压文件：
   tar -xzf flow-pilot-v1.0.0.tar.gz

2. 在你的项目中打开 Claude Code，运行：
   /plugin install /path/to/flow-pilot-v1.0.0

3. 测试：
   /flow-pilot

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

手动安装
═══════════════

1. 解压文件
2. 在你的项目中创建 .claude/settings.local.json：

{
  "plugins": [
    {
      "name": "flow-pilot",
      "path": "/path/to/flow-pilot-v1.0.0"
    }
  ]
}

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⚠️  注意事项
═══════════

- 不要在 flow-pilot-v1.0.0 目录中运行 install.sh
- 请在你的实际项目目录中运行安装脚本
- 或者使用 /plugin install 命令更方便

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

文档: https://github.com/JasonSTong/flow-pilot
问题反馈: https://github.com/JasonSTong/flow-pilot/issues

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF

# 创建压缩包
echo "📦 创建压缩包..."
cd "$TEMP_DIR"
tar -czf "$SCRIPT_DIR/$ARCHIVE_NAME" "$PACKAGE_NAME"

# 计算 SHA256
echo "🔐 计算校验和..."
cd "$SCRIPT_DIR"
if command -v shasum &> /dev/null; then
    shasum -a 256 "$ARCHIVE_NAME" > "${ARCHIVE_NAME}.sha256"
elif command -v sha256sum &> /dev/null; then
    sha256sum "$ARCHIVE_NAME" > "${ARCHIVE_NAME}.sha256"
fi

# 清理临时文件
rm -rf "$TEMP_DIR"

# 显示结果
FILE_SIZE=$(du -h "$ARCHIVE_NAME" | cut -f1)

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ 打包完成！"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📦 压缩包: $ARCHIVE_NAME"
echo "📊 大小: $FILE_SIZE"
if [ -f "${ARCHIVE_NAME}.sha256" ]; then
    echo "🔐 校验和: ${ARCHIVE_NAME}.sha256"
fi
echo ""
echo "📤 发布步骤："
echo "   1. 在 GitHub 创建 Release (v${VERSION})"
echo "   2. 上传 $ARCHIVE_NAME"
if [ -f "${ARCHIVE_NAME}.sha256" ]; then
    echo "   3. 上传 ${ARCHIVE_NAME}.sha256"
fi
echo ""
