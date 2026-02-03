# Flow-Pilot

🚀 **智能 AI 工作流系统** - 让 Claude Code 以更规范、更高效的方式引导你的开发工作。

[![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)](https://github.com/JasonSTong/flow-pilot)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![GitHub Stars](https://img.shields.io/github/stars/JasonSTong/flow-pilot?style=social)](https://github.com/JasonSTong/flow-pilot/stargazers)
[![GitHub Issues](https://img.shields.io/github/issues/JasonSTong/flow-pilot)](https://github.com/JasonSTong/flow-pilot/issues)

---

## ✨ 核心特性

### 🎯 智能需求收集
- **目标驱动**：无固定轮数，需求清楚就停
- **适配项目**：自动识别新项目/新功能/修改功能
- **深度理解**：基于代码库分析，减少重复提问

### 📋 灵活计划生成
- **分阶段执行**：自动分解为可管理的阶段和任务
- **TDD 支持**：strict（严格 TDD）/ reminder（智能提醒）/ none（无测试）
- **可视化进度**：实时跟踪每个任务的状态

### 🔄 TDD 工作流
- **RED → GREEN → REFACTOR**：完整的 TDD 循环支持
- **多语言支持**：Python / TypeScript / JavaScript / Go / Rust
- **智能测试生成**：自动推断测试文件路径和场景

### 📤 跨端协作文档
- **前端调用文档**：后端开发完 API 后自动生成
- **后端需求文档**：前端设计好交互后自动生成
- **TypeScript 类型**：包含完整的类型定义和示例代码

### 📊 实时状态查看
- **进度可视化**：进度条、百分比、任务清单
- **历史追踪**：查看所有 Pilot 的执行历史
- **统计分析**：代码行数、测试覆盖率、用时等

---

## 📦 安装

### 前置要求

- **Claude Code CLI** (>= 2.0.0)

### 安装步骤

1. **在 Claude Code 中打开插件管理**
   ```bash
   claude
   /plugin
   ```

2. **切换到 Marketplaces 标签**，点击 `+ Add Marketplace`

3. **输入 marketplace URL**：
   ```
   https://raw.githubusercontent.com/JasonSTong/flow-pilot/main/.claude-plugin/marketplace.json
   ```

4. **切换到 Discover 标签**，找到 `flow-pilot` 并安装

5. **重启 Claude Code**
   ```bash
   exit
   claude
   ```

6. **使用插件**
   ```bash
   /flow-pilot <你的需求>
   ```

---

## 🚀 快速开始

### 创建你的第一个 Pilot

```bash
# 在 Claude Code 中输入
/flow-pilot 实现用户认证功能
```

**Flow-Pilot 会自动：**

1. **分析项目**：检测项目类型和技术栈
2. **需求收集**：智能对话，理解你的需求
3. **配置工作模式**：询问 TDD 模式、权限、下一步
4. **生成计划**：创建分阶段执行计划
5. **开始执行**：根据计划逐步实现

### 示例对话流程

```
用户: /flow-pilot 实现用户登录功能

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🚀 启动 Flow-Pilot
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

检测到项目：
- 后端：Python (FastAPI)
- 数据库：PostgreSQL + Alembic
- 前端：React (TypeScript)

项目阶段：老项目新功能

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

开始需求收集...

━━━ Round 1 ━━━

我看到项目已有用户相关代码（models/user.py），关于登录功能：

1. 登录方式：邮箱密码 / 手机号 / 第三方登录？
2. 认证机制：JWT / Session？
3. 现有 User 模型需要扩展吗？

用户: 邮箱密码，JWT，扩展 User 表加 password_hash

━━━ Round 2 ━━━

明白了。技术细节：

1. JWT 配置：Token 有效期？
2. 密码安全：使用 bcrypt？
3. 前端集成：Token 存储在哪里？

用户: 24小时，bcrypt，localStorage

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ 需求收集完成（共 2 轮对话）
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[显示配置选项：TDD 模式 + 权限 + 下一步]

用户选择: 严格TDD + 授权(database, dependencies, testing) + 生成详细计划

[生成计划，开始执行...]
```

---

## 📖 Skills 说明

### 1. `/flow-pilot` - 主流程

**功能：** 需求收集、配置决策、流程编排

**使用：**
```bash
/flow-pilot 实现用户认证
/flow-pilot 优化查询性能
/flow-pilot 添加导出功能
```

**特点：**
- 智能对话，无固定轮数
- 自动识别项目阶段
- 生成跨端协作文档

---

### 2. `/flow-pilot-plan` - 计划生成

**功能：** 生成详细的分阶段执行计划

**使用：**
```bash
/flow-pilot-plan pilot-20250130-143522
/flow-pilot-plan pilot-20250130-143522 --view
```

**输出：**
- `.claude/pilots/{pilot-id}/plan.md`
- 分阶段任务清单
- TDD 任务分解
- 风险和注意事项

---

### 3. `/flow-pilot-exec` - 执行引擎

**功能：** 按计划执行开发任务

**使用：**
```bash
/flow-pilot-exec pilot-20250130-143522
/flow-pilot-exec pilot-20250130-143522 --phase 2
/flow-pilot-exec pilot-20250130-143522 --resume
```

**特点：**
- 支持 TDD 模式（strict/reminder/none）
- 实时进度跟踪
- 智能错误处理
- 自动调用 flow-pilot-test

---

### 4. `/flow-pilot-test` - TDD 助手

**功能：** 测试驱动开发助手

**使用：**
```bash
/flow-pilot-test src/auth.py
/flow-pilot-test src/components/Button.tsx
```

**特点：**
- RED → GREEN → REFACTOR 循环
- 多语言支持（Python/TS/JS/Go/Rust）
- 智能测试生成
- 覆盖率统计

---

### 5. `/flow-pilot-status` - 状态查看

**功能：** 查看 Pilot 状态和进度

**使用：**
```bash
/flow-pilot-status                          # 当前 Pilot
/flow-pilot-status --list                   # 所有 Pilot
/flow-pilot-status pilot-20250130-143522    # 指定 Pilot
/flow-pilot-status --history                # 历史记录
```

**输出：**
- 进度可视化（进度条、百分比）
- 统计信息（文件、测试、覆盖率）
- 时间分析（用时、预估剩余）

---

## 🎯 使用场景

### 场景 1：后端 API 开发（严格 TDD）

```bash
/flow-pilot 实现订单管理 API

配置：
- TDD: strict（先写测试）
- 权限: database, dependencies, testing
- 下一步: 生成详细计划

结果：
- 自动生成 frontend-integration.md
- 包含完整的 API 文档和调用示例
- 前端同事可以直接参考
```

---

### 场景 2：前端组件开发（智能提醒）

```bash
/flow-pilot 实现商品列表页面

配置：
- TDD: reminder（代码后补测试）
- 权限: dependencies, testing
- 下一步: 直接开始执行

结果：
- 自动生成 backend-requirements.md
- 说明需要哪些 API 支持
- 后端同事可以据此实现
```

---

### 场景 3：修改现有功能

```bash
/flow-pilot 优化登录流程性能

Flow-Pilot 会：
1. 自动定位相关代码（login.py, auth.py）
2. 分析影响范围（3个文件会受影响）
3. 询问向后兼容性
4. 生成重构计划
5. 包含回归测试
```

---

## 📂 目录结构

```
flow-pilot/
├── install.sh                  # 安装脚本
├── README.md                   # 本文件
├── LICENSE                     # MIT 许可证
├── skills/                     # Skills 目录
│   ├── flow-pilot/             # 主流程
│   │   └── SKILL.md
│   ├── flow-pilot-plan/        # 计划生成
│   │   └── SKILL.md
│   ├── flow-pilot-exec/        # 执行引擎
│   │   └── SKILL.md
│   ├── flow-pilot-test/        # TDD 助手
│   │   └── SKILL.md
│   └── flow-pilot-status/      # 状态查看
│       └── SKILL.md
└── scripts/                    # 共享脚本
    ├── detect-project.sh
    ├── analyze-codebase.sh
    ├── create-pilot-id.sh
    └── get-active-pilot.sh
```

---

## 🔧 配置说明

### TDD 模式对比

| 模式 | 适用场景 | 行为 |
|------|---------|------|
| **strict** | API 端点、业务逻辑 | 先写测试（RED）→ 实现代码（GREEN）→ 重构（REFACTOR） |
| **reminder** | UI 组件、工具函数 | 实现代码 → 友好提醒补充测试 |
| **none** | 文档、配置 | 不检查测试 |

### 权限类型

- `database`: 数据库迁移（alembic, prisma）
- `dependencies`: 依赖安装（pip, npm）
- `testing`: 测试执行（pytest, jest）
- `quality`: 代码检查（ruff, eslint）
- `build`: 构建打包（docker build）
- `deployment`: 部署操作（kubectl apply）

---

## 📝 文档输出

### 前端调用文档（frontend-integration.md）

**后端开发完 API 后自动生成，包含：**
- API 端点列表
- 请求/响应格式
- TypeScript 类型定义
- Axios 调用示例
- 错误码说明
- 测试建议

### 后端需求文档（backend-requirements.md）

**前端设计好交互后自动生成，包含：**
- 需要的 API 端点
- 业务需求说明
- 期望的请求/响应格式
- 性能要求
- 数据库设计建议
- API 开发优先级

---

## 🤝 贡献

欢迎贡献！

1. Fork 本仓库
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 提交 Pull Request

---

## 📝 许可证

MIT License - 详见 [LICENSE](LICENSE)

---

## 🙏 致谢

- [Claude Code](https://claude.ai/code) - Anthropic 官方 CLI 工具
- 所有为 Flow-Pilot 提供反馈的开发者

---

## 📧 联系方式

如有问题或建议，欢迎：
- 提交 [Issue](https://github.com/JasonSTong/flow-pilot/issues)
- 发送邮件至 chensitongc@gmail.com

---

**🎉 享受 Flow-Pilot 带来的智能开发体验！**
