# AI Team Workflow 插件

<p align="center">
  <a href="./README.md">English</a> · <strong>简体中文</strong>
</p>

这是一个打包成本地插件的 Codex-first AI 开发团队工作流。

## 它提供什么

- 全局 Human Lead 人设。
- 全局 `.ai-team` 项目模板。
- Codex 自然语言路由规则。
- 任务卡、记忆文件、提示词和质量门禁。
- 规模、质量、性能门禁，避免屎山代码和过度设计。
- 与任务卡融合的轻量 GitHub PR、CI、安全门禁。
- 代码地图和结构化任务状态，让“继续”更可靠。

## 安装全局模板

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/Install-AiTeamWorkflow.ps1
```

## 初始化项目

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "$env:USERPROFILE\.codex\ai-team\Initialize-AiTeamProject.ps1"
```

## Codex 日常使用

```text
我想做一个产品：xxx。遇到关键选择先问我。
```

后续直接说：

```text
继续
```
