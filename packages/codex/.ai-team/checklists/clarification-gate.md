---
title: Clarification Gate Checklist
tags:
  - ai-team/checklist
  - clarification
status: active
---

# Clarification Gate Checklist

Ask the user before proceeding when the answer changes product scope, architecture, data ownership, cost, security, or deployment risk.

## Ask When

- Multiple valid product behaviors exist and the user has not chosen one.
- Authentication, payment, data storage, permissions, or deployment target is unclear.
- A task can be executed in multiple incompatible technical directions.
- The next action could overwrite, delete, deploy, expose secrets, or change production data.
- More than one unfinished task is available and none is clearly next by dependency order.

## How To Ask

- Ask 1 to 3 short questions.
- Include task IDs and plain business meaning when asking the user to choose.
- Recommend a default when one option is safer or simpler.
- Do not ask about facts the agent can discover from files, code, or Git state.

## Do Not Ask When

- The answer can be discovered by reading the repository.
- The choice is low-risk and matches existing project patterns.
- The task card already states the required behavior.
