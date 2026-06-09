---
title: API Mapping Gate
tags:
  - ai-team/checklist
  - api
status: active
---

# API Mapping Gate

Use after frontend design and before backend implementation.

## For Each Endpoint Or Action

- [ ] Source screen or system trigger.
- [ ] Triggering button, form, card action, scheduled job, or integration.
- [ ] Request fields and validation.
- [ ] Response shape.
- [ ] Error states shown to the user.
- [ ] Authentication and permission requirement.
- [ ] Data ownership and privacy rule.
- [ ] Logging, audit, or analytics need when relevant.

## Rules

- Do not create endpoints that have no mapped frontend interaction, integration, or operational need.
- Keep API scope minimal for the MVP.
- Shared schemas, auth, migrations, and common API contracts are serial tasks by default.

## Output

Create an API map in the task card or project docs with:

- endpoint/action
- source UI or trigger
- business rule
- data contract
- error handling
- verification

