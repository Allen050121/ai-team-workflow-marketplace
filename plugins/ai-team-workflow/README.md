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
- Production Mode policy for real users, durable data, auth, payments, deployment, and external services.
- Lightweight GitHub PR, CI, and security gates integrated with task cards.
- Repo map and structured task state for more reliable "continue" behavior.
- Project Intake Gate that detects new projects, existing codebases, AI Team projects, mixed directories, and unclear directories before planning.
- Compact run evidence in `.ai-team/state/runs.json`, so execution and review results do not disappear into chat history.
- Command safety policy for dependency, data, deployment, git push, and external-service actions.
- Lightweight command risk classifier for `safe`, `approval_required`, and `forbidden` decisions.
- Diff boundary checker that compares changed files with each task card's `Allowed To Modify` section.
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

## Check A Project

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .ai-team/scripts/Test-AiTeamProject.ps1
```

This gives a quick local health check for the AI Team workflow files.

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

For unfamiliar directories, Codex should first apply the Project Intake Gate. You can simply say "I want to add subscriptions" or "I want to build a bookkeeping app"; Codex should detect whether it is in a new project, existing codebase, AI Team project, mixed/notes directory, or unclear directory, then ask only decision-changing questions before writing code.

## Production Guardrails

- Executors stay inside task boundaries and record compact run evidence.
- Dispatcher classifies work as Prototype, MVP, or Production before choosing architecture and gates.
- Reviewers check diffs, verification, command risk classification, policy, and task evidence before passing work.
- Integration uses GitHub/CI gates when available and release gate for deployment or publishing.
- Production-facing actions still require Human Lead approval.
