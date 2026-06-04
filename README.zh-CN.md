# AI Team Workflow Marketplace

<p align="center">
  <a href="./README.md">English</a> | <strong>简体中文</strong>
</p>

`ai-team-workflow` 是一个 Codex 优先的 AI 开发团队工作流插件。

它提供一套可复用的全局标准，并在每个项目中创建项目级 `.ai-team` 文件，用于产品规划、项目接管、任务卡、代码地图、结构化任务状态、运行证据、命令风险检查、diff 边界检查、审核门禁，以及轻量级 GitHub PR/CI/安全检查。

## 它提供什么

- 全局 Human Lead 画像。
- 干净的项目级 `.ai-team` 模板。
- Codex 自然语言路由。
- Project Intake Gate：自动识别新项目、已有代码库、已有 AI Team 项目、混合/笔记目录或不清晰目录。
- 任务卡、项目记忆、代码地图和结构化任务状态。
- Workflow Modes：`light`、`standard`、`strict`、`parallel`，用于平衡稳定性、效率和 token 消耗。
- Compact context：默认只加载紧凑上下文，需要时才升级到 standard/full。
- Diff 边界检查：对比实际改动文件和任务卡允许修改范围。
- 规模、质量、性能、安全、PR 和集成门禁。
- Production Mode、命令安全、发布门禁和简洁运行证据。
- 轻量 GitHub issue/PR 模板，不强制使用 GitHub Projects。

## 在另一台电脑安装

克隆这个仓库：

```powershell
git clone https://github.com/Allen050121/ai-team-workflow-marketplace.git
cd ai-team-workflow-marketplace
```

在 Codex 里添加这个 marketplace，指向仓库根目录或 `marketplace.json`：

```text
ai-team-workflow-marketplace/marketplace.json
```

安装插件后，同步全局模板：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\plugins\ai-team-workflow\scripts\Install-AiTeamWorkflow.ps1 -Force
```

## 初始化一个项目

在任意项目根目录运行：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "$env:USERPROFILE\.codex\ai-team\Initialize-AiTeamProject.ps1"
```

然后在 Codex 里自然表达需求：

```text
我想做一个产品：xxx。遇到关键产品或技术选择先问我。
```

## 日常使用

在 Codex 里直接说：

```text
继续
```

```text
审核刚才的任务
```

```text
继续到部署前检查，但不要真正部署生产环境。
```

Codex 应该读取全局标准，检查当前项目的 `.ai-team`，应用 Project Intake Gate，并自动路由后续工作。小任务走 `light`，普通任务走 `standard`，生产/安全/数据/依赖/部署相关任务走 `strict`，只有边界清晰的独立任务才走 `parallel`。
