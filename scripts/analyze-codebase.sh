#!/bin/bash
# analyze-codebase.sh - 分析代码库规模和结构

# 统计文件数量
total_files=$(find . -type f \( -name "*.py" -o -name "*.js" -o -name "*.ts" -o -name "*.tsx" -o -name "*.go" -o -name "*.rs" \) 2>/dev/null | wc -l)

# 统计代码行数
total_lines=$(find . -type f \( -name "*.py" -o -name "*.js" -o -name "*.ts" -o -name "*.tsx" -o -name "*.go" -o -name "*.rs" \) -exec wc -l {} + 2>/dev/null | tail -1 | awk '{print $1}')

# 判断项目阶段
if [ "$total_files" -lt 5 ]; then
  echo "项目阶段: 从 0 到 1（新项目）"
  echo "文件数: $total_files"
elif [ "$total_files" -lt 50 ]; then
  echo "项目阶段: 早期阶段"
  echo "文件数: $total_files, 代码行数: $total_lines"
else
  echo "项目阶段: 成熟项目"
  echo "文件数: $total_files, 代码行数: $total_lines"
fi

# 检查是否有测试
if [ -d "tests" ] || [ -d "test" ] || find . -name "*test*.py" -o -name "*test*.js" -o -name "*test*.ts" 2>/dev/null | grep -q .; then
  echo "测试: 已有测试文件"
else
  echo "测试: 无测试文件"
fi

# 检查是否有 CI/CD
if [ -d ".github/workflows" ] || [ -f ".gitlab-ci.yml" ] || [ -f ".travis.yml" ]; then
  echo "CI/CD: 已配置"
else
  echo "CI/CD: 未配置"
fi
