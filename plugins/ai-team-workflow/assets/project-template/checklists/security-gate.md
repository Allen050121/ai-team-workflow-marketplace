---
title: Security Gate Checklist
tags:
  - ai-team/checklist
  - security
status: active
---

# Security Gate Checklist

Use when a task touches auth, permissions, user data, secrets, dependencies, deployment, or external services.

- [ ] No real secrets, tokens, cookies, or private keys are committed.
- [ ] Environment variables are documented with safe placeholder values.
- [ ] User data is scoped to the correct owner or tenant.
- [ ] Protected routes/API paths enforce authentication and authorization.
- [ ] Inputs are validated before persistence or privileged operations.
- [ ] New dependencies are justified and checked with the project security command when available.
- [ ] Logs and errors do not expose sensitive data.
- [ ] External services, paid services, or production actions were approved by the Human Lead.
- [ ] Approval-required commands followed `.ai-team/policies/command-policy.md`.
- [ ] Command risk classification evidence is recorded for dependency, data, deployment, secret, or external-service commands.
