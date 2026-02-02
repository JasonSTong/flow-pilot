# Changelog

All notable changes to Flow-Pilot will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.1] - 2026-02-02

### Fixed
- 🔧 修复 marketplace 名称不匹配问题
  - 统一 marketplace 名称为 `flow-pilot-marketplace`
  - 更新所有安装脚本中的引用
  - 修复插件无法正确加载的错误
- 🔧 **修复默认 Anthropic marketplace 被覆盖问题**
  - 安装脚本现在会保留 Claude Code 官方 marketplace
  - 添加 `knownMarketplaces.anthropic.enabled: true` 配置
  - 确保用户可以同时使用官方插件和 Flow-Pilot

### Added
- ⭐ **GitHub 官方源支持**（默认仓库）
  - 新增 `install-from-github.sh` 脚本，支持从 GitHub URL 直接安装
  - 新增 `marketplace-github.json` 配置文件
  - 无需本地下载，自动获取最新版本
  - 配置后全局可用，跨项目通用
- 📝 更新 README.md，添加 GitHub 官方源安装方式

### Changed
- 🔄 优化安装流程，提供多种安装方式选择
  - 方式 0: GitHub 官方源（推荐，自动更新）
  - 方式 1: 本地安装（离线可用）
  - 方式 2: 下载安装包
  - 方式 3: 克隆仓库

## [1.0.0] - 2025-01-30

### Added
- 🎯 智能需求收集系统（目标驱动，无固定轮数）
- 📊 项目阶段自动识别（新项目/新功能/修改功能）
- 🔄 完整 TDD 工作流支持（RED → GREEN → REFACTOR）
- 📤 跨端协作文档自动生成
  - 前端调用文档（frontend-integration.md）
  - 后端需求文档（backend-requirements.md）
- 📈 实时进度跟踪和可视化
- 🛠️ 5 个模块化 Skills：
  - `/flow-pilot` - 主流程（需求收集 + 配置）
  - `/flow-pilot-plan` - 计划生成
  - `/flow-pilot-exec` - 执行引擎
  - `/flow-pilot-test` - TDD 助手
  - `/flow-pilot-status` - 状态查看
- 🌐 多语言支持（Python/TypeScript/JavaScript/Go/Rust）
- 🔐 权限管理系统（database/dependencies/testing/quality/build/deployment）
- 📝 决策记录系统（decisions.md）
- 🎨 可视化进度条和状态图标
- 📊 统计分析（代码行数、测试覆盖率、用时等）

### Features
- 智能对话：基于代码库分析，减少重复提问
- 灵活配置：每个 Pilot 独立配置 TDD 模式和权限
- 模块化设计：Skills 可独立使用或组合调用
- 状态持久化：progress.json 实时保存执行进度
- 错误恢复：支持暂停、恢复、跳过任务
- 历史追踪：查看所有 Pilot 的执行历史和趋势

### Documentation
- 📖 完整的 README.md（使用指南）
- 📋 详细的 SKILL.md（每个 Skill 的文档）
- 📜 MIT 许可证
- 🔧 安装脚本（install.sh）

[1.0.0]: https://github.com/JasonSTong/flow-pilot/releases/tag/v1.0.0
