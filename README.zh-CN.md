# AI Team Workflow Marketplace

<p align="center">
  <strong>简体中文</strong> | <a href="./README.md#english">English</a>
</p>

`ai-team-workflow` 是一个面向 Codex 和 Claude Code 的 AI 产品交付工作流插件。它提供共享的 `.ai-team` 工作流核心，并分别打包 Codex / Claude Code 的入口文件。

## 下载

请从 GitHub Release 下载最新 zip 包：

- [下载 Codex 版本](https://github.com/Allen050121/ai-team-workflow-marketplace/releases/download/v0.5.0/ai-team-workflow-codex-v0.5.0.zip)
- [下载 Claude Code 版本](https://github.com/Allen050121/ai-team-workflow-marketplace/releases/download/v0.5.0/ai-team-workflow-claude-v0.5.0.zip)

两个包共享同一套 `.ai-team` 工作流核心，但平台入口文件彼此隔离，避免 Codex 和 Claude Code 的项目指令互相冲突。

## 核心能力

- 任务卡、项目记忆、仓库地图和结构化任务状态。
- 默认单 Agent 产品交付流，必要时才使用并行模式。
- 产品发现、产品形态、前端设计、API 映射和部署容量门禁。
- Workflow Modes：`light`、`standard`、`strict`、`parallel`。
- 自动 workflow mode 分类。
- Compact context 和 context budget 检查，减少 token 消耗。
- Diff 边界检查、状态机检查、Review Report 和 run evidence。
- 项目更新时记录模板版本和 migration report。
- 质量、安全、性能、PR、发布和集成门禁。

## Codex 安装

下载并解压 `ai-team-workflow-codex-v0.5.0.zip`，把内容放到 Codex 项目根目录，保留：

- `.ai-team/`
- `AGENTS.md`
- `Initialize-AiTeamProject.ps1`
- `Update-AiTeamProject.ps1`

## Claude Code 安装

下载并解压 `ai-team-workflow-claude-v0.5.0.zip`，把内容放到 Claude Code 项目根目录，保留：

- `.ai-team/`
- `.claude/`
- `CLAUDE.md`
- `Initialize-AiTeamProject.ps1`
- `Update-AiTeamProject.ps1`

## 验证

在项目根目录运行：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .ai-team/scripts/Test-AiTeamProject.ps1
```

## 重新构建下载包

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/Build-AiTeamPackages.ps1 -Version 0.5.0 -Clean
```

打 tag 后会自动创建 Release 并上传 zip 包：

```powershell
git tag v0.5.1
git push origin v0.5.1
```
