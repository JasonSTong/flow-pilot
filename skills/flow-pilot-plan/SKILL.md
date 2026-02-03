---
name: flow-pilot-plan
description: 生成或查看执行计划
version: 1.0.4
disable-model-invocation: false
allowed-tools: Read, Write, Bash, AskUserQuestion, Skill(flow-pilot-exec)
---

# Flow-Pilot 计划生成器

## 调用方式

### 方式 1：被 flow-pilot 主流程调用
```bash
/flow-pilot-plan pilot-20250130-143522
```

### 方式 2：独立使用
```bash
# 为现有 Pilot 生成计划
/flow-pilot-plan pilot-20250130-143522

# 查看现有计划
/flow-pilot-plan pilot-20250130-143522 --view

# 修改现有计划
/flow-pilot-plan pilot-20250130-143522 --modify
```

---

## 输入

**Pilot ID**: $0

**操作模式**: $1 (可选: --view, --modify, --regenerate)

**必需文件**: `.claude/pilots/$0/context.json`

---

## 输出

**生成文件**: `.claude/pilots/$0/plan.md`

**返回**: 计划摘要（展示给用户）

---

## 执行逻辑

### 1. 读取需求上下文

```bash
pilot_id=$0
context_file=".claude/pilots/$pilot_id/context.json"

if [ ! -f "$context_file" ]; then
  echo "错误：Pilot $pilot_id 不存在"
  echo "请先运行：/flow-pilot {需求描述}"
  exit 1
fi
```

### 2. 生成计划

基于 `context.json` 中的：
- `requirements`: 需求详情
- `config.tdd_mode`: TDD 模式
- `config.permissions`: 授权的权限
- `tech_stack`: 技术栈

**生成 `plan.md`：**

包含：
- 执行摘要
- 分阶段任务清单
- TDD 任务分解（如果是 strict 模式）
- 依赖命令列表
- 风险和注意事项
- 成功标准

### 3. 展示计划并询问用户

展示计划摘要：

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ 计划已生成
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📋 Pilot: 用户认证系统
📁 文件: .claude/pilots/pilot-20250130-143522/plan.md

共 5 个阶段，预计任务：
- Phase 1: 数据库设计（5 个任务）
- Phase 2: 认证工具（8 个 TDD 循环）
- Phase 3: API 端点（9 个 TDD 循环）
- Phase 4: 前端集成（4 个任务）
- Phase 5: 测试部署（4 个任务）

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

然后使用 `AskUserQuestion` 询问下一步：

```javascript
AskUserQuestion({
  questions: [
    {
      header: "下一步",
      question: "计划已生成，接下来？",
      multiSelect: false,
      options: [
        {
          label: "开始执行",
          description: "立即开始 Phase 1"
        },
        {
          label: "查看详情",
          description: "显示完整计划内容"
        },
        {
          label: "修改计划",
          description: "调整某些阶段或任务"
        },
        {
          label: "稍后执行",
          description: "计划已保存，以后用 /flow-pilot-exec 开始"
        }
      ]
    }
  ]
})
```

### 4. 根据用户选择调用后续流程

**选择 "开始执行":**
```bash
/flow-pilot-exec pilot-20250130-143522
```

**选择 "查看详情":**
```bash
# 读取并展示完整计划
cat .claude/pilots/pilot-20250130-143522/plan.md
```

**选择 "修改计划":**

使用 `AskUserQuestion` 进一步询问：
```javascript
AskUserQuestion({
  questions: [
    {
      header: "修改内容",
      question: "你想调整什么？",
      multiSelect: true,
      options: [
        {
          label: "调整阶段顺序",
          description: "改变执行的先后顺序"
        },
        {
          label: "增加/删除任务",
          description: "添加遗漏的任务或删除不需要的"
        },
        {
          label: "修改 TDD 模式",
          description: "调整某些阶段的测试策略"
        },
        {
          label: "重新规划",
          description: "重新生成整个计划"
        }
      ]
    }
  ]
})
```

**选择 "稍后执行":**
```
好的，计划已保存。

稍后执行时使用：
/flow-pilot-exec pilot-20250130-143522
```

---

## 计划生成策略

### 后端 Pilot

**典型阶段：**
1. **数据库设计** - 模型、迁移
2. **核心业务逻辑** - 服务层、工具函数
3. **API 端点** - 路由、请求/响应处理
4. **测试和质量** - 单元测试、集成测试

### 前端 Pilot

**典型阶段：**
1. **组件结构** - 组件骨架、类型定义
2. **UI 实现** - 样式、布局
3. **状态和逻辑** - 状态管理、事件处理
4. **集成和测试** - API 集成、组件测试

### 全栈 Pilot

**策略：**
- **后端优先：** 先实现 API → 前端调用
- **前端优先：** 先 Mock 数据做 UI → 后端对接
- **并行开发：** 前后端交替

---

## TDD 模式的影响

### strict 模式

每个任务分为 3 个子任务：
```
- [ ] 1.1-RED: 编写测试（失败）
- [ ] 1.1-GREEN: 实现代码（通过）
- [ ] 1.1-REFACTOR: 重构优化
```

### reminder 模式

测试作为独立阶段放在最后：
```
Phase 3: 测试补充
- [ ] 补充单元测试
- [ ] 补充集成测试
```

### none 模式

不包含测试任务。

---

## 调用契约

### 输入契约
```json
{
  "pilot_id": "pilot-20250130-143522",  // 必需
  "mode": "generate",                   // generate | view | modify
  "required_files": [
    ".claude/pilots/{pilot_id}/context.json"
  ]
}
```

### 输出契约
```json
{
  "success": true,
  "generated_file": ".claude/pilots/{pilot_id}/plan.md",
  "summary": {
    "phases": 5,
    "total_tasks": 30,
    "tdd_mode": "strict"
  },
  "next_action": "awaiting_user_decision"
}
```

---

## 记住

你是**计划专家**，不是执行者：
- 🎯 聚焦于**制定清晰的计划**
- 📝 提供**可追踪的任务清单**
- 🔄 支持**计划的查看和修改**
- 📋 使用 **AskUserQuestion** 进行所有用户交互
- 🚀 完成后**引导用户进入执行阶段**
