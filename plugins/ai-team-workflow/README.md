# AI Team Workflow Plugin

<p align="center">
  <strong>English</strong> | <a href="./README.zh-CN.md">简体中文</a>
</p>

Codex-first AI development team workflow packaged as a local plugin.

## What It Provides

- Global Human Lead profile.
- Global project template for `.ai-team`.
- Natural-language routing rules for Codex.
- Task cards, memory files, prompts, and quality gates.
- Scale, quality, and performance gates to avoid both messy code and overengineering.
- Lightweight GitHub PR, CI, and security gates integrated with task cards.
- Repo map and structured task state for more reliable "continue" behavior.
- Compact run evidence in `.ai-team/state/runs.json`, so execution and review results do not disappear into chat history.
- Command safety policy for dependency, data, deployment, git push, and external-service actions.
- Release gate for deployment, rollback, smoke test, and production approval checks.

## Install Global Template

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/Install-AiTeamWorkflow.ps1
```

## Initialize A Project

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "$env:USERPROFILE\.codex\ai-team\Initialize-AiTeamProject.ps1"
```

## Update An Existing Project

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "$env:USERPROFILE\.codex\ai-team\Update-AiTeamProject.ps1"
```

This updates workflow-managed files such as scripts, prompts, checklists, policies, hooks, and templates. It preserves project memory, task cards, task state, repo map, and commands.

## Normal Codex Use

Say the real product work:

```text
I want to build a product: xxx. Ask me before key choices.
```

Then continue naturally:

```text
Continue
```

Codex should inspect `.ai-team/tasks/`, `.ai-team/state/tasks.json`, and `.ai-team/state/runs.json` to decide the next role and action. You should not need to paste fixed role prompts or status commands during normal use.

## Production Guardrails

- Executors stay inside task boundaries and record compact run evidence.
- Reviewers check diffs, verification, command policy, and task evidence before passing work.
- Integration uses GitHub/CI gates when available and release gate for deployment or publishing.
- Production-facing actions still require Human Lead approval.
