# AI Team Workflow Marketplace

<p align="center">
  <a href="./README.md">English</a> | <strong>简体中文</strong>
</p>

`ai-team-workflow` 是一个 AI 开发团队工作流插件。它提供一套共享的 `.ai-team` 工作流核心，并分别提供 Codex 和 Claude Code 的独立入口包。

## 下载包

预构建 zip 包在 `dist/`：

- `ai-team-workflow-codex-v0.5.0.zip`：给 Codex 项目使用。
- `ai-team-workflow-claude-v0.5.0.zip`：给 Claude Code 项目使用。

两个包共享同一套 `.ai-team` 工作流核心，但平台入口文件彼此隔离，避免 Codex 和 Claude 的逻辑打架。

## 核心能力

- 任务卡、项目记忆、代码地图和结构化任务状态。
- Workflow Modes：`light`、`standard`、`strict`、`parallel`。
- 自动 workflow mode 分类器。
- Compact context 和 context budget 检查，减少 token 消耗。
- Diff 边界检查、状态机检查、Review Report 和 run evidence。
- 项目更新时记录模板版本和 migration report。
- 质量、安全、性能、PR、发布和集成门禁。

## Codex 安装

下载并解压：

```text
dist/ai-team-workflow-codex-v0.5.0.zip
```

把内容放到 Codex 项目根目录，保留：

- `.ai-team/`
- `AGENTS.md`
- `Initialize-AiTeamProject.ps1`
- `Update-AiTeamProject.ps1`

## Claude 安装

下载并解压：

```text
dist/ai-team-workflow-claude-v0.5.0.zip
```

把内容放到 Claude Code 项目根目录，保留：

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
