#!/bin/bash
# detect-project.sh - 检测项目类型和技术栈

output=""

# 检测后端
if [ -f "pyproject.toml" ] || [ -f "requirements.txt" ]; then
  output="后端: Python"
  [ -d "app" ] && output="$output (FastAPI)"
  [ -d "myproject" ] && [ -f "manage.py" ] && output="$output (Django)"
  [ -f "setup.py" ] && output="$output (Package)"
elif [ -f "package.json" ]; then
  if grep -q "express" package.json 2>/dev/null; then
    output="后端: Node.js (Express)"
  elif grep -q "nestjs" package.json 2>/dev/null; then
    output="后端: Node.js (NestJS)"
  fi
elif [ -f "go.mod" ]; then
  output="后端: Go"
elif [ -f "Cargo.toml" ]; then
  output="后端: Rust"
fi

# 检测前端
if [ -f "package.json" ]; then
  if grep -q "react" package.json 2>/dev/null; then
    output="$output | 前端: React"
    grep -q "next" package.json 2>/dev/null && output="$output (Next.js)"
  elif grep -q "vue" package.json 2>/dev/null; then
    output="$output | 前端: Vue"
    grep -q "nuxt" package.json 2>/dev/null && output="$output (Nuxt)"
  elif grep -q "angular" package.json 2>/dev/null; then
    output="$output | 前端: Angular"
  elif grep -q "svelte" package.json 2>/dev/null; then
    output="$output | 前端: Svelte"
  fi
fi

# 检测数据库
if [ -f "alembic.ini" ]; then
  output="$output | 数据库: PostgreSQL + Alembic"
elif [ -d "prisma" ] || grep -q "prisma" package.json 2>/dev/null; then
  output="$output | 数据库: Prisma"
elif [ -f "knexfile.js" ]; then
  output="$output | 数据库: Knex.js"
fi

# 输出结果
if [ -z "$output" ]; then
  echo "项目类型: 未检测到（可能是新项目）"
else
  echo "$output"
fi
