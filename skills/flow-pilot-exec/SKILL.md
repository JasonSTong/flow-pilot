---
name: flow-pilot-exec
description: 执行开发任务（支持 TDD）
version: 1.0.6
disable-model-invocation: false
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

## 全自动模式详解

### 什么是"全自动"？

**全自动模式（execution_mode: "auto" + 权限已授权）= 完全无需用户干预**

当用户选择：
1. ✅ 执行模式：自动连续执行
2. ✅ 权限授权：勾选了 dependencies、database、testing

**系统行为：**
```
Phase 1: 数据库设计
  ├─ Task 1.1: 扩展 User 模型 ✅
  ├─ Task 1.2: 创建迁移脚本 ✅
  ├─ [需要安装 sqlalchemy]
  │   └─ ✅ 有 dependencies 权限 → 自动执行：pip install sqlalchemy
  ├─ Task 1.3: 执行迁移 ✅
  │   └─ ✅ 有 database 权限 → 自动执行：alembic upgrade head
  └─ Task 1.4: 运行测试 ✅
      └─ ✅ 有 testing 权限 → 自动执行：pytest

Phase 1 完成 ✅
🚀 自动开始 Phase 2...（无需用户说"继续"）

Phase 2: 核心服务层
  ├─ Task 2.1: ScraperService 实现 ✅
  ├─ [需要安装 scrapegraph-ai]
  │   └─ ✅ 有 dependencies 权限 → 自动执行：pip install scrapegraph-ai
  ├─ Task 2.2: 数据处理流程 ✅
  └─ Task 2.3: 集成测试 ✅

Phase 2 完成 ✅
🚀 自动开始 Phase 3...

...一直到所有 Phases 完成，无需任何用户输入 ✅
```

---

### 半自动模式 vs 全自动模式

#### ❌ 半自动模式（旧行为，错误）

```
Phase 1 完成 ✅
[暂停，等待用户确认]

系统: 告诉我"继续 Phase 2"或"开始 Phase 2"来继续执行！

[需要安装依赖]
系统: 是否安装 sqlalchemy？
用户: 是

Phase 2 开始...
[又需要安装依赖]
系统: 是否安装 fastapi？
用户: 是

↑ 这是错误的！即使选了自动模式 + 授权了权限，仍在不断询问
```

#### ✅ 全自动模式（正确行为）

```
Phase 1 完成 ✅
🚀 自动开始 Phase 2...

[需要安装依赖]
📦 自动检测虚拟环境：.venv
📦 自动安装：sqlalchemy fastapi
✅ 依赖安装完成

Phase 2 Task 2.1 完成 ✅
Phase 2 Task 2.2 完成 ✅

[需要执行迁移]
🔄 自动执行：alembic upgrade head
✅ 数据库迁移完成

Phase 2 完成 ✅
🚀 自动开始 Phase 3...

↑ 完全不打扰用户，一气呵成！
```

---

### 何时会询问用户？

**仅在以下 3 种情况询问：**

#### 1. 遇到错误且无法自动恢复

```
⚠️  执行中断
Phase 2, Task 2.2: 数据处理流程
错误: ImportError: No module named 'pandas'

已尝试自动安装但失败。

[使用 AskUserQuestion 询问：
 - 重试安装
 - 手动处理
 - 跳过此任务]
```

#### 2. 需要权限但未授权

```
⚠️  需要权限
即将执行：alembic upgrade head

当前无 database 权限。

[使用 AskUserQuestion 询问：
 - 授权并执行
 - 跳过此步骤]
```

#### 3. 手动模式下的 Phase 切换

```
✅ Phase 1 完成

[使用 AskUserQuestion 询问：
 - 继续 Phase 2
 - 暂停执行
 - 切换到自动模式]
```

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
execution_mode=$(jq -r '.config.execution_mode' $context_file)
permissions=$(jq -r '.config.permissions[]' $context_file)

# 显示执行模式
if [ "$execution_mode" == "auto" ]; then
  echo "🚀 执行模式：自动连续执行"
else
  echo "👆 执行模式：手动确认"
fi
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
  ├─ 完成阶段后，根据 execution_mode 决定：
  │   ├─ auto: 直接继续下一个 Phase
  │   └─ manual: 使用 AskUserQuestion 等待用户确认
  └─ 继续下一个 Phase（如果有）
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

根据 `execution_mode` 配置决定下一步行为：

#### 自动模式（execution_mode: "auto"）

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

🚀 自动开始 Phase 2: 认证工具实现...
```

**直接进入下一个 Phase，无需等待用户确认。**

---

#### 手动模式（execution_mode: "manual"）

展示完成信息后，使用 `AskUserQuestion` 询问：

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
```

然后调用 AskUserQuestion：

```javascript
AskUserQuestion({
  questions: [
    {
      header: "下一步",
      question: "Phase 1 已完成，接下来？",
      multiSelect: false,
      options: [
        {
          label: "继续 Phase 2",
          description: "开始执行：认证工具实现"
        },
        {
          label: "暂停执行",
          description: "保存当前进度，稍后继续"
        },
        {
          label: "查看详细信息",
          description: "查看 Phase 1 的详细执行结果"
        },
        {
          label: "切换到自动模式",
          description: "剩余 Phases 自动连续执行"
        }
      ]
    }
  ]
})
```

**等待用户选择后再继续。**

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

### 权限控制逻辑

**关键原则：权限已授权 = 直接执行，不询问**

```bash
# 检查是否有权限
has_permission() {
  local perm=$1
  jq -r '.config.permissions[]' $context_file | grep -q "^$perm$"
}

# 依赖安装
if needs_install_dependencies; then
  if has_permission "dependencies"; then
    # ✅ 有权限：直接执行，不询问
    echo "📦 安装依赖..."
    install_dependencies
  else
    # ❌ 无权限：询问用户是否授权
    AskUserQuestion({
      questions: [{
        header: "权限请求",
        question: "需要安装依赖，是否授权？",
        options: [...]
      }]
    })
  fi
fi
```

**适用范围：**
- ✅ 依赖安装（dependencies）
- ✅ 数据库迁移（database）
- ✅ 测试执行（testing）
- ✅ Git 操作（git）

---

### 智能虚拟环境检测

**安装 Python 依赖时自动检测并使用虚拟环境：**

```bash
install_python_dependencies() {
  local packages=$1

  # 1. 检测虚拟环境
  if [ -d ".venv" ]; then
    venv_path=".venv"
  elif [ -d "venv" ]; then
    venv_path="venv"
  elif [ -f "poetry.lock" ]; then
    # Poetry 项目
    echo "📦 使用 Poetry 安装依赖..."
    poetry add $packages
    return
  elif [ -f "Pipfile" ]; then
    # Pipenv 项目
    echo "📦 使用 Pipenv 安装依赖..."
    pipenv install $packages
    return
  fi

  # 2. 使用检测到的虚拟环境
  if [ -n "$venv_path" ]; then
    echo "📦 使用虚拟环境：$venv_path"
    source "$venv_path/bin/activate"
    pip install $packages
  else
    # 3. 没有虚拟环境，创建一个
    echo "⚠️  未检测到虚拟环境，创建 .venv"
    python -m venv .venv
    source .venv/bin/activate
    pip install $packages
  fi
}

# 使用示例
install_python_dependencies "fastapi uvicorn sqlalchemy"
```

**支持的虚拟环境类型：**
- `.venv` / `venv` - 标准虚拟环境
- `poetry` - Poetry 项目
- `pipenv` - Pipenv 项目
- `conda` - Conda 环境（检测 environment.yml）

---

### Node.js 依赖智能安装

**检测包管理器并使用对应命令：**

```bash
install_node_dependencies() {
  local packages=$1

  if [ -f "pnpm-lock.yaml" ]; then
    echo "📦 使用 pnpm 安装依赖..."
    pnpm add $packages
  elif [ -f "yarn.lock" ]; then
    echo "📦 使用 yarn 安装依赖..."
    yarn add $packages
  elif [ -f "package-lock.json" ]; then
    echo "📦 使用 npm 安装依赖..."
    npm install $packages
  else
    # 默认使用 npm
    npm install $packages
  fi
}
```

---

### 自动调用 flow-pilot-test

在 strict TDD 模式下，自动调用：
```bash
/flow-pilot-test src/utils/auth.py --mode red
/flow-pilot-test src/utils/auth.py --mode green
/flow-pilot-test src/utils/auth.py --mode refactor
```

---

### 智能错误恢复

```bash
if [ $? -ne 0 ]; then
  echo "测试失败，分析错误..."
  error_log=$(pytest --last-failed --tb=short 2>&1)

  if echo "$error_log" | grep -q "ImportError"; then
    echo "检测到导入错误，可能是依赖问题"
    # 如果有 dependencies 权限，尝试安装缺失的包
    if has_permission "dependencies"; then
      echo "尝试安装缺失的依赖..."
      # 解析错误信息并安装
    fi
  fi
fi
```

---

## 记住

你是**执行专家**，不是规划者：

### 核心原则

- 🎯 **严格按照计划执行**
- 🔄 **根据 TDD 模式调整流程**
- 📊 **实时更新进度跟踪**

### 权限和自动化

- ✅ **权限已授权 = 直接执行**（不询问用户）
  - dependencies 权限 → 直接安装依赖
  - database 权限 → 直接执行迁移
  - testing 权限 → 直接运行测试

- ❌ **权限未授权 = 询问用户**（使用 AskUserQuestion）

### 执行模式

- 🚀 **自动模式（execution_mode: "auto"）**
  - Phase 完成后自动开始下一个
  - 有权限的操作直接执行
  - 真正的全自动，无需用户干预

- 👆 **手动模式（execution_mode: "manual"）**
  - Phase 完成后等待用户确认
  - 有权限的操作仍然直接执行
  - 只在 Phase 切换时询问

### 智能检测

- 🐍 **Python**: 检测 .venv、poetry、pipenv
- 📦 **Node.js**: 检测 pnpm、yarn、npm
- 🛡️ **错误处理**: 智能分析并尝试自动修复

### 交互时机

- **只在以下情况询问用户：**
  1. 遇到错误且无法自动恢复
  2. 需要权限但未授权
  3. 手动模式下的 Phase 切换

- **不要询问的情况：**
  1. ❌ 已有权限的操作（直接执行）
  2. ❌ 自动模式下的 Phase 切换（直接继续）
  3. ❌ 常规的任务执行（按计划进行）

### 记录决策

- 📝 **记录重要决策和异常处理**到 decisions.md
