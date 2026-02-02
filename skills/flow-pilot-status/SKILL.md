---
name: flow-pilot-status
description: 查看 Flow-Pilot 的状态和进度。可以查看当前活跃 Pilot、所有 Pilot 列表、详细进度信息。完全独立使用，只读不修改。
version: 1.0.0
disable-model-invocation: true
allowed-tools: Read, Bash
---

# Flow-Pilot 状态查看

## 调用方式

### 快速查看当前 Pilot
```bash
/flow-pilot-status
```

### 查看所有 Pilot 列表
```bash
/flow-pilot-status --list
```

### 查看指定 Pilot 详情
```bash
/flow-pilot-status pilot-20250130-143522
```

### 查看历史 Pilot
```bash
/flow-pilot-status --history
```

---

## 参数

**Pilot ID**: $0（可选）

**可选参数**:
- `--list`: 显示所有 Pilot 列表
- `--history`: 显示已完成的 Pilot
- `--active`: 仅显示活跃的 Pilot
- `--detailed`: 详细模式（显示所有任务）
- `--json`: JSON 格式输出

---

## 输出格式

### 1. 默认输出（当前活跃 Pilot）

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📊 Flow-Pilot 当前状态
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🚀 活跃 Pilot: 用户认证系统

ID: pilot-20250130-143522
状态: 执行中 (Executing)
创建时间: 2025-01-30 14:35:22
运行时长: 45 分钟

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📋 执行进度

Phase 1: 数据库设计                 [████████████] 100% ✅
  ✅ 1.1 扩展 User 模型
  ✅ 1.2 创建 Alembic 迁移脚本
  ✅ 1.3 执行迁移
  ✅ 1.4 验证数据库变更

Phase 2: 认证工具实现               [████████░░░░]  67% 🔄
  ✅ 2.1 hash_password 函数
  ✅ 2.2 verify_password 函数
  🔄 2.3 create_access_token 函数  ← 当前
  ⏳ 2.4 verify_token 函数

Phase 3: API 端点实现               [░░░░░░░░░░░░]   0% ⏳
Phase 4: 前端集成                   [░░░░░░░░░░░░]   0% ⏳
Phase 5: 测试部署                   [░░░░░░░░░░░░]   0% ⏳

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📊 统计信息

总体进度: 33.3% (10/30 任务)
完成阶段: 1/5
测试覆盖率: 95.2%

文件变更:
  • 新增: 8 个文件
  • 修改: 2 个文件

测试状态:
  • 通过: 12 个测试
  • 失败: 0 个测试

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⚙️  工作模式

TDD: 严格模式（RED → GREEN → REFACTOR）
自动化: 自动执行
权限: database, dependencies, testing

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📂 相关文件

需求: .claude/pilots/pilot-20250130-143522/context.json
计划: .claude/pilots/pilot-20250130-143522/plan.md
进度: .claude/pilots/pilot-20250130-143522/progress.json
前端文档: .claude/pilots/pilot-20250130-143522/frontend-integration.md

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

💡 提示

• 继续执行: /flow-pilot-exec pilot-20250130-143522
• 查看详情: /flow-pilot-status pilot-20250130-143522 --detailed
• 暂停执行: 告诉我"暂停"

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

### 2. 列表模式（所有 Pilot）

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📋 所有 Pilot 列表
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🔄 执行中 (1)
───────────────────────────────────────────
pilot-20250130-143522  用户认证系统
  进度: 33% (10/30 任务)
  运行: 45 分钟
  创建: 2025-01-30 14:35

⏸️  暂停中 (1)
───────────────────────────────────────────
pilot-20250129-092145  订单管理系统
  进度: 60% (18/30 任务)
  暂停: 1 天前
  原因: 等待设计稿

✅ 已完成 (3)
───────────────────────────────────────────
pilot-20250128-163022  支付接口集成
  完成: 2 天前
  用时: 3 小时 20 分钟

pilot-20250127-145530  数据导出功能
  完成: 3 天前
  用时: 1 小时 45 分钟

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

统计:
  • 总计: 5 个 Pilot
  • 执行中: 1 个
  • 暂停中: 1 个
  • 已完成: 3 个

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

### 3. JSON 格式输出

```json
{
  "id": "pilot-20250130-143522",
  "title": "用户认证系统",
  "status": "executing",
  "type": "existing_project_new_feature",
  "focus": "backend",
  "timestamps": {
    "created_at": "2025-01-30T14:35:22Z",
    "started_at": "2025-01-30T14:40:15Z",
    "updated_at": "2025-01-30T15:20:30Z",
    "duration_minutes": 45
  },
  "progress": {
    "overall_percent": 33.3,
    "phases_completed": 1,
    "phases_total": 5,
    "tasks_completed": 10,
    "tasks_total": 30,
    "current_phase": 2,
    "current_task": "2.3"
  },
  "statistics": {
    "files_created": 8,
    "files_modified": 2,
    "tests_passed": 12,
    "tests_failed": 0,
    "test_coverage": 95.2
  },
  "config": {
    "tdd_mode": "strict",
    "automation": "auto",
    "permissions": ["database", "dependencies", "testing"]
  }
}
```

---

## 实现逻辑

### 读取 Pilot 数据

```bash
pilot_id=$1
pilots_dir=".claude/pilots"

# 读取基本信息
context_file="$pilots_dir/$pilot_id/context.json"
progress_file="$pilots_dir/$pilot_id/progress.json"

# 提取数据
title=$(jq -r '.title' $context_file)
status=$(jq -r '.status' $progress_file)

# 计算进度
tasks_completed=$(jq '[.phases[].tasks[] | select(.status == "completed")] | length' $progress_file)
tasks_total=$(jq '[.phases[].tasks | length] | add' $progress_file)
percent=$(echo "scale=1; $tasks_completed * 100 / $tasks_total" | bc)
```

### 进度条渲染

```bash
render_progress_bar() {
  local percent=$1
  local width=12

  local filled=$(echo "$percent * $width / 100" | bc)
  local empty=$(echo "$width - $filled" | bc)

  printf "["
  for ((i=0; i<$filled; i++)); do printf "█"; done
  for ((i=0; i<$empty; i++)); do printf "░"; done
  printf "]"
}

# 使用
render_progress_bar 67  # 输出: [████████░░░░]
```

### 状态图标

```bash
get_status_icon() {
  local status=$1

  case $status in
    completed) echo "✅" ;;
    in_progress) echo "🔄" ;;
    pending) echo "⏳" ;;
    paused) echo "⏸️" ;;
    error) echo "❌" ;;
    *) echo "❓" ;;
  esac
}
```

---

## 调用契约

### 输入契约
```json
{
  "pilot_id": "pilot-20250130-143522",  // 可选
  "mode": "default",                    // default | list | detailed | json | history
  "filters": {                          // 可选
    "status": "executing",              // executing | paused | completed
    "type": "backend"                   // backend | frontend | fullstack
  }
}
```

### 输出契约
```json
{
  "success": true,
  "mode": "detailed",
  "data": {
    "pilot_id": "pilot-20250130-143522",
    "title": "用户认证系统",
    "status": "executing",
    "progress": {...},
    "statistics": {...},
    "config": {...}
  }
}
```

---

## 智能特性

### 1. 自动检测活跃 Pilot

如果用户没有指定 pilot-id，自动查找：
- 查找 status = "executing" 的 Pilot
- 如果没有，查找 "paused" 的 Pilot
- 如果都没有，显示最近修改的 Pilot

### 2. 性能统计

```bash
# 计算平均每任务用时
avg_per_task=$(echo "$total_minutes / $tasks_completed" | bc)

# 预估剩余时间
estimated_remaining=$(echo "$remaining_tasks * $avg_per_task" | bc)
```

### 3. 趋势分析

```bash
# 分析本周完成的 Pilot 趋势
for day in {1..7}; do
  date=$(date -d "$day days ago" +%Y-%m-%d)
  count=$(find $pilots_dir -name "progress.json" | xargs grep "$date" | wc -l)
  echo "$(date -d "$day days ago" +%a): $count 个"
done
```

---

## 记住

你是**信息展示专家**，不是执行者：
- 📊 清晰展示进度和状态
- 🎨 使用可视化（进度条、图标）
- 📈 提供统计和趋势分析
- 🔍 支持多种查看模式
- 📋 只读不修改（绝不改变 Pilot 状态）
