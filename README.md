# AI Team Workflow Marketplace

Local/Git marketplace for the `ai-team-workflow` Codex plugin.

## Plugin

- `ai-team-workflow`: Codex-first AI development team workflow with a global Human Lead profile, project-local `.ai-team` task system, natural-language routing, repo map, structured task state, scale-aware quality gates, and lightweight GitHub PR/CI/security gates.

## Install On Another Computer

Clone this repository:

```powershell
git clone <your-repo-url> ai-team-workflow-marketplace
```

Then add this marketplace in Codex using the repository root or marketplace file, depending on the Codex UI/version.

Marketplace file:

```text
ai-team-workflow-marketplace/marketplace.json
```

After installing the plugin, sync the global template:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\plugins\ai-team-workflow\scripts\Install-AiTeamWorkflow.ps1 -Force
```

## Initialize A Project

From any project directory:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "$env:USERPROFILE\.codex\ai-team\Initialize-AiTeamProject.ps1"
```

Then use Codex naturally:

```text
我想做一个产品：xxx。遇到关键选择先问我。
```

## 中文说明

这是一个给 Codex 用的 AI 开发团队工作流插件。全局目录保存你的工作标准和 Human Lead 人设；每个项目目录保存自己的 `.ai-team` 项目记忆、任务卡、状态和代码地图。

### 安装到另一台电脑

```powershell
git clone https://github.com/Allen050121/ai-team-workflow-marketplace.git
cd ai-team-workflow-marketplace
powershell -NoProfile -ExecutionPolicy Bypass -File .\plugins\ai-team-workflow\scripts\Install-AiTeamWorkflow.ps1 -Force
```

### 初始化一个项目

在项目根目录运行：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "$env:USERPROFILE\.codex\ai-team\Initialize-AiTeamProject.ps1"
```

然后在 Codex 里直接说：

```text
我想做一个产品：xxx。MVP 包含 xxx。遇到关键选择先问我。
```

### 日常使用

- 说“继续”，Codex 会读取 `.ai-team/state/tasks.json` 和任务卡判断下一步。
- 说“审核刚才的任务”，Codex 会走 Review / Quality / Security / PR Gate。
- 说“部署前检查”，Codex 会走 Integration Gate，但不会在未批准时真正上线。
