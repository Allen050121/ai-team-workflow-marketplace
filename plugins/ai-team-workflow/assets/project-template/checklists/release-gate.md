---
title: Release Gate Checklist
tags:
  - ai-team/checklist
  - release
status: active
---

# Release Gate Checklist

Use before deployment, release tagging, publishing, or any production-facing external action.

Also use when `.ai-team/memory/production-mode.md` triggers Production mode.

## Core Release Checks

- [ ] Human Lead approved the release or production-facing action.
- [ ] Production Mode triggers were checked and documented in the task card or handoff.
- [ ] Deployment, publishing, cloud, database, or git push commands were classified and approval evidence is recorded.
- [ ] Build and required project checks passed.
- [ ] Required environment variables are documented with safe placeholders.
- [ ] No real secrets, tokens, cookies, or private keys are committed.
- [ ] Smoke test steps are documented and can be repeated after release.
- [ ] Rollback path is clear enough for the project scale.

## Data And Services

- [ ] Database migrations or schema changes have a rollback or recovery note.
- [ ] Auth, permissions, user data, payment, or external service changes passed Security Gate.
- [ ] Paid services, cloud resources, or production data operations were explicitly approved.

## Scale-Appropriate Evidence

- [ ] S/MVP: local production build and main user flow smoke test are enough.
- [ ] M/real product: CI, key integration checks, and basic deployment verification are recorded.
- [ ] L/high-risk product: monitoring, error signals, and rollback owner are documented.
