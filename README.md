# AI Team Workflow Marketplace

<p align="center">
  <strong>简体中文</strong> | <a href="./README.en.md">English</a>
</p>

`ai-team-workflow` 是一个面向 Codex 和 Claude Code 的 AI 产品交付工作流插件。它的重点不是模拟很多角色，而是让一个 Agent 稳定地带你从产品想法走到可部署版本。

它会把需求拆成可追踪的任务卡，并在关键节点先问清楚你的选择：目标用户是谁、MVP 做到哪里、产品应该做成网站/App/小程序/插件还是 API、技术栈是否匹配用户规模、前端怎么设计、后端接口从哪些页面交互反推、部署服务器是否够用。

## 它解决什么问题

很多 AI 编程流程会在需求还没想清楚时直接写代码，结果越改越偏：

- 产品受众和核心场景没有确认。
- 技术栈选择过轻或过度设计。
- 后端接口先写了一堆，前端用不上。
- 页面不好看，用户第一眼留不住。
- 后端缺少架构边界，后期难维护。
- 部署前没有估算并发、预算、备份和扩容路径。

AI Team Workflow 把这些高风险决策前置成任务卡和门禁，让 Agent 先规划、再确认、最后实现。

## 工作方式

默认是单 Agent 串行交付：

```text
产品澄清
 -> 产品形态
 -> 技术栈与规模
 -> 架构边界
 -> 前端设计
 -> API 映射
 -> 实现
 -> 质量检查
 -> 部署容量
 -> 发布
```

并行模式仍然保留，但只在任务边界非常清晰、不会碰共享模型/认证/迁移/公共 API 时使用。

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

## 推荐用法

在 Codex 里直接说真实需求即可：

```text
我想做一个产品：个人任务管理 Web App。请用 AI Team Workflow 先做产品澄清，不要直接写代码。
```

继续推进时可以说：

```text
继续下一张任务卡
```

审核当前工作时可以说：

```text
审核当前任务卡
```

## 下载

请从 GitHub Release 下载最新 zip 包：

- [下载 Codex 版本](https://github.com/Allen050121/ai-team-workflow-marketplace/releases/download/v0.5.0/ai-team-workflow-codex-v0.5.0.zip)
- [下载 Claude Code 版本](https://github.com/Allen050121/ai-team-workflow-marketplace/releases/download/v0.5.0/ai-team-workflow-claude-v0.5.0.zip)

两个包共享同一套 `.ai-team` 工作流核心，但平台入口文件彼此隔离，避免 Codex 和 Claude Code 的项目指令互相冲突。

## Codex 安装

下载并解压：

```text
ai-team-workflow-codex-v0.5.0.zip
```

把内容放到 Codex 项目根目录，保留：

- `.ai-team/`
- `AGENTS.md`
- `Initialize-AiTeamProject.ps1`
- `Update-AiTeamProject.ps1`

## Claude Code 安装

下载并解压：

```text
ai-team-workflow-claude-v0.5.0.zip
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

打 tag 后会自动创建 Release 并上传 zip 包。先把模板版本和插件版本更新到目标版本，再打同名 tag：

```powershell
git tag v0.5.1
git push origin v0.5.1
```
