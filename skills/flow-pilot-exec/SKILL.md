---
name: flow-pilot-exec
description: 执行开发任务（支持 TDD）
version: 1.0.3
disable-model-invocation: true
allowed-tools: Read, Write, Edit, Bash, AskUserQuestion, Skill(flow-pilot-test)
---

# Flow-Pilot 执行引擎

## 调用方式

### 被主流程调用
```bash
/flow-pilot-exec pilot-20250130-143522
```

### 独立使用
```bash
# 执行指定 Pilot
/flow-pilot-exec pilot-20250130-143522

# 从指定阶段开始
/flow-pilot-exec pilot-20250130-143522 --phase 2

# 自动生成计划后执行
/flow-pilot-exec pilot-20250130-143522 --auto-plan

# 恢复暂停的 Pilot
/flow-pilot-exec pilot-20250130-143522 --resume
```

---

## 输入

**Pilot ID**: $0

**可选参数**: $1 (--auto-plan | --phase N | --resume)

**必需文件**:
- `.claude/pilots/$0/context.json`（需求上下文）
- `.claude/pilots/$0/plan.md`（执行计划，除非 --auto-plan）

---

## 输出

**生成文件**:
- `.claude/pilots/$0/progress.json`（实时更新进度）
- `.claude/pilots/$0/decisions.md`（记录执行中的决策）

**副作用**:
- 创建/修改源代码文件
- 执行命令（数据库迁移、测试等）

---

## 执行逻辑

### 1. 加载 Pilot 上下文

```bash
pilot_id=$0
context_file=".claude/pilots/$pilot_id/context.json"

# 检查 Pilot 是否存在
if [ ! -f "$context_file" ]; then
  echo "❌ Pilot $pilot_id 不存在"
  exit 1
fi

# 读取配置
tdd_mode=$(jq -r '.config.tdd_mode' $context_file)
permissions=$(jq -r '.config.permissions[]' $context_file)
```

### 2. 初始化进度跟踪

```json
// .claude/pilots/{pilot-id}/progress.json
{
  "pilot_id": "pilot-20250130-143522",
  "status": "executing",
  "current_phase": 1,
  "phases": [
    {
      "number": 1,
      "name": "数据库设计",
      "status": "in_progress",
      "tasks": [
        {
          "id": "1.1",
          "title": "扩展 User 模型",
          "status": "completed",
          "tdd_cycle": {"red": true, "green": true, "refactor": true},
          "completed_at": "2025-01-30T15:10:22Z"
        }
      ]
    }
  ],
  "started_at": "2025-01-30T15:00:00Z",
  "updated_at": "2025-01-30T15:15:22Z"
}
```

### 3. 执行阶段循环

```
对于每个 Phase:
  ├─ 显示阶段开始信息
  ├─ 对于每个 Task:
  │   ├─ 更新状态为 in_progress
  │   ├─ 根据 TDD 模式执行
  │   │   ├─ strict: RED → GREEN → REFACTOR
  │   │   ├─ reminder: 实现 → 提醒测试
  │   │   └─ none: 直接实现
  │   ├─ 更新状态为 completed
  │   └─ 保存进度
  └─ 继续下一个 Phase
```

---

## TDD 模式执行

### Strict 模式（严格 TDD）

```
Phase 2: 认证工具实现
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Task 2.1: hash_password 函数

🔴 RED 阶段：编写测试

[创建文件 tests/utils/test_auth.py]
[运行测试] ❌ 测试失败（符合预期）

🟢 GREEN 阶段：实现代码

[创建文件 src/utils/auth.py]
[运行测试] ✅ 测试通过

🔵 REFACTOR 阶段：优化代码

[添加类型注解、文档、错误处理]
[补充边界测试]
[运行测试] ✅ 所有测试通过（3 passed）

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ Task 2.1 完成
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Reminder 模式（智能提醒）

```
Task 3.1: POST /api/auth/register

[实现注册接口]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ 注册接口实现完成
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

💡 测试建议（Reminder 模式）

检测到源代码变更：routes/auth.py

建议补充测试：
- 推荐测试文件：tests/routes/test_auth.py

测试场景建议：
  ✓ 成功注册
  ✓ 邮箱重复
  ✓ 邮箱格式错误
  ✓ 密码太短

小贴士：可以稍后一起补充测试

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### None 模式（无测试）

直接实现，无测试提醒。

---

## 进度更新

### 每完成一个任务

```bash
# 更新 progress.json
jq '.phases[0].tasks[0].status = "completed"' progress.json > tmp.json
mv tmp.json progress.json

# 记录决策（如有重要决策）
echo "
## Task 2.1 - hash_password 实现

**决策**: 使用 bcrypt
**理由**: 成熟，Python 支持好
**时间**: 2025-01-30 15:25:00
" >> .claude/pilots/$pilot_id/decisions.md
```

### 每完成一个阶段

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ Phase 1 完成：数据库设计
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

完成任务：
  ✅ 1.1 扩展 User 模型
  ✅ 1.2 创建 Alembic 迁移脚本
  ✅ 1.3 执行迁移
  ✅ 1.4 验证数据库变更

测试覆盖率：
  src/models/user.py: 100%

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

进入 Phase 2: 认证工具实现...
```

---

## 错误处理和暂停

### 遇到错误时

显示错误信息并使用 `AskUserQuestion` 询问用户：

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⚠️  执行中断
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Phase 2, Task 2.2: verify_password 函数
错误: pytest 测试失败

已保存当前进度。
```

然后调用 AskUserQuestion：

```javascript
AskUserQuestion({
  questions: [
    {
      header: "错误处理",
      question: "执行中断，如何继续？",
      multiSelect: false,
      options: [
        {
          label: "修复错误并继续",
          description: "分析错误并修复，然后继续执行"
        },
        {
          label: "暂停 Pilot",
          description: "保存当前进度，稍后恢复"
        },
        {
          label: "跳过此任务",
          description: "标记任务为失败，继续下一个任务"
        }
      ]
    }
  ]
})
```

### 用户选择"暂停"

```json
// 更新 progress.json
{
  "status": "paused",
  "paused_at": "2025-01-30T15:30:00Z",
  "paused_reason": "用户请求暂停",
  "resume_from": {"phase": 2, "task": "2.2"}
}
```

---

## 完成后总结

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🎉 Pilot 执行完成！
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Pilot: 用户认证系统
用时: 2 小时 15 分钟

完成情况：
  ✅ Phase 1: 数据库设计（5/5 任务）
  ✅ Phase 2: 认证工具（4/4 任务）
  ✅ Phase 3: API 端点（3/3 任务）
  ✅ Phase 4: 前端集成（4/4 任务）
  ✅ Phase 5: 测试部署（4/4 任务）

总计：20/20 任务完成

代码统计：
  新增文件: 12 个
  修改文件: 3 个
  代码行数: +856 -12

测试覆盖率：
  src/: 95.2%

生成文档：
  ✅ frontend-integration.md

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

下一步建议：
1. 查看前端文档
2. 运行完整测试: pytest --cov
3. 提交代码
4. 部署

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## 智能特性

### 自动调用 flow-pilot-test

在 strict TDD 模式下，自动调用：
```bash
/flow-pilot-test src/utils/auth.py --mode red
/flow-pilot-test src/utils/auth.py --mode green
/flow-pilot-test src/utils/auth.py --mode refactor
```

### 自动检测依赖安装

```bash
if grep -q "pip install" plan.md; then
  if has_permission "dependencies"; then
    pip install passlib[bcrypt] pyjwt
  else
    echo "⚠️  需要依赖安装权限"
  fi
fi
```

### 智能错误恢复

```bash
if [ $? -ne 0 ]; then
  echo "测试失败，分析错误..."
  error_log=$(pytest --last-failed --tb=short 2>&1)

  if echo "$error_log" | grep -q "ImportError"; then
    echo "检测到导入错误，可能是依赖问题"
  fi
fi
```

---

## 记住

你是**执行专家**，不是规划者：
- 🎯 严格按照计划执行
- 🔄 根据 TDD 模式调整流程
- 📊 实时更新进度跟踪
- 🛡️ 遇到错误智能处理
- 📋 使用 **AskUserQuestion** 处理错误和异常情况
- 📝 记录重要决策
