---
title: Review Gate Checklist
tags:
  - ai-team/checklist
  - review
status: active
---

# Review Gate Checklist

Use after an Executor finishes and before integration.

- [ ] Changed file list matches the task card.
- [ ] `.ai-team/scripts/Test-AiTeamDiffBoundary.ps1` passed when available, or any boundary change was approved in the task card.
- [ ] Diff has no unrelated formatting, metadata, or drive-by edits.
- [ ] Implementation satisfies the task goal.
- [ ] No recorded pitfall is repeated.
- [ ] Existing project patterns are followed unless the task explains why not.
- [ ] Security-sensitive paths were reviewed carefully.
- [ ] Verification command was run or a waiver is documented.
- [ ] Commands were selected from `.ai-team/commands.json` when available.
- [ ] Risky or unclear commands were classified with `.ai-team/scripts/Test-AiTeamCommand.ps1` when available.
- [ ] Approval-required command classifications have Human Lead approval recorded.
- [ ] No forbidden command classification was ignored.
- [ ] PR Gate passed when GitHub is used.
- [ ] Handoff notes list changed files, verification result, risks, and follow-ups.
- [ ] Reviewer result is pass, request changes, or blocked.
