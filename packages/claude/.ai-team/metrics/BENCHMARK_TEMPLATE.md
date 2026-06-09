---
benchmark_id: "{{BENCHMARK_ID}}"
project_name: "{{PROJECT_NAME}}"
date: "{{DATE}}"
workflow_mode: standard
status: planned
---

# Benchmark: {{PROJECT_NAME}}

Use this file to compare AI Team Workflow against an ordinary AI coding flow on a real product task. Keep notes short and evidence-based.

## Product Task

- Audience:
- Product surface:
- MVP scope:
- Tech stack:
- Deployment target:

## Baseline Flow

- Tool or workflow used:
- Total conversation turns:
- Approximate elapsed time:
- Rework count:
- User corrections:
- Verification commands:
- Final result:

## AI Team Workflow Flow

- Task cards created:
- Gates used:
- Total conversation turns:
- Approximate elapsed time:
- Rework count:
- User corrections:
- Verification commands:
- Final result:

## Context And Token Budget

Record output from:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .ai-team/scripts/Measure-AiTeamContext.ps1
```

- Baseline estimated tokens:
- AI Team estimated tokens:
- Largest context source:
- Repeated context avoided:

## Quality Notes

- Product direction stayed aligned:
- Frontend was designed before backend:
- APIs mapped to UI/actions:
- Architecture matched scale:
- Deployment capacity was considered:

## Lessons

- What reduced drift:
- What wasted tokens:
- What should be automated:
- What should become a pitfall or pattern:
