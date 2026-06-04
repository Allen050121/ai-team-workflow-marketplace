# AI Team Workflow 插件

<p align="center">
  <a href="./README.md">English</a> | <strong>简体中文</strong>
</p>

这是一个 Codex 优先的 AI 开发团队工作流插件，用来把全局标准和项目内 `.ai-team` 模板安装到你的开发环境里。

## 它实现了什么

- 全局 Human Lead 画像。
- 全局 `.ai-team` 项目模板。
- Codex 自然语言路由规则。
- Project Intake Gate：在规划前自动识别新项目、已有代码库、已有 AI Team 项目、混合/笔记目录或不清晰目录。
- Workflow Modes：`light`、`standard`、`strict`、`parallel`，让小任务更快，高风险任务更稳。
- 保守的 workflow mode 自动分类器，用于任务创建和健康检查。
- Compact context：默认使用紧凑上下文，只有缺信息时才升级，降低 token 消耗。
- 结构化 Review Report：汇总改动文件、边界检查、状态机检查、运行证据和建议结论。
- 状态机检查：约束 review/done 状态和 strict 任务证据。
- 任务卡、记忆文件、提示词和质量门禁。
- 规模、质量、性能门禁，避免粗糙临时代码和过度设计。
- Production Mode 策略，用于真实用户、持久化数据、登录、支付、部署和外部服务。
- 与任务卡融合的轻量 GitHub PR、CI、安全门禁。
- 代码地图和结构化任务状态，让“继续”更可靠。
- `.ai-team/state/runs.json` 运行证据账本，执行和审核结果不会散落在聊天记录里。
- 命令安全策略，用于依赖安装、数据操作、部署、git push 和外部服务动作。
- 轻量命令风险分类器，用于判断 `safe`、`approval_required`、`forbidden`。
- Diff 边界检查器：自动对比实际改动文件和任务卡的 `Allowed To Modify` 边界。
- 发布门禁，用于部署、回滚、烟测和生产审批检查。

## 安装全局模板

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/Install-AiTeamWorkflow.ps1
```

## 初始化项目

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "$env:USERPROFILE\.codex\ai-team\Initialize-AiTeamProject.ps1"
```

## 更新已有项目

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "$env:USERPROFILE\.codex\ai-team\Update-AiTeamProject.ps1"
```

它只更新工作流管理的文件，例如 scripts、prompts、checklists、policies、hooks 和模板文件。项目记忆、任务卡、任务状态、repo map 和 commands 会被保留。

## 检查项目

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .ai-team/scripts/Test-AiTeamProject.ps1
```

这会快速检查当前项目里的 AI Team 工作流文件是否完整可用。

## Codex 日常使用

直接说真实需求：

```text
我想做一个产品：xxx。遇到关键选择先问我。
```

或者在老项目里直接说：

```text
我要在这个项目里加会员订阅功能。
```

Codex 应该先应用 Project Intake Gate，自动判断当前目录是新项目、已有代码库、已有 AI Team 项目、混合/笔记目录，还是不清晰目录。它不会盲信你的说法；如果目录信号和你的描述冲突，它会按证据提醒你，并只问真正影响产品、架构、数据、成本、安全或部署的问题。

后续直接说：

```text
继续
```

Codex 应该自动读取 `.ai-team/tasks/`、`.ai-team/state/tasks.json` 和 `.ai-team/state/runs.json`，判断下一步应该进入 Dispatcher、Executor、Reviewer、Integration 还是 Memory Curator。正常使用时，你不需要粘贴固定角色提示词或状态命令。

## 稳定性与成本策略

- 小而低风险的任务走 `light`，避免无意义的流程和 token 消耗。
- 普通产品任务走 `standard`，保留任务卡、执行证据和审核。
- 涉及生产、数据、登录、支付、依赖、部署、安全的任务走 `strict`。
- 只有文件边界清晰且没有共享状态冲突时才走 `parallel`。
- Executor 默认使用 compact context，只有说明缺少什么信息时才升级上下文。

## 生产级约束

- Executor 在任务边界内实现，并记录简洁运行证据。
- Dispatcher 先判断工作属于 Prototype、MVP 还是 Production，再选择架构和门禁。
- Reviewer 在通过前检查 diff、验证结果、workflow mode、命令风险分类、命令安全策略和任务证据。
- Integration 在可用时使用 GitHub/CI 门禁，部署或发布前使用 Release Gate。
- 涉及生产、外部服务、付费资源或高风险命令时，仍然需要 Human Lead 批准。
