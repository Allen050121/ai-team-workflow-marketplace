---
title: Scale Gate Checklist
tags:
  - ai-team/checklist
  - scale
status: active
---

# Scale Gate Checklist

Use during planning before choosing architecture.

- [ ] Classify the project as S, M, or L.
- [ ] State expected users, data durability needs, deployment target, and risk level.
- [ ] Pick the simplest stack that satisfies the current scale.
- [ ] List any new dependency or external service and why it is necessary.
- [ ] Reject overengineering unless scale/risk clearly justifies it.
- [ ] Reject underengineering when auth, durable data, permissions, payments, or production traffic are required.
