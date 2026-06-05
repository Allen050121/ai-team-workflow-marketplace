---
title: Human Lead Profile
tags:
  - ai-team/memory
  - human-lead
status: active
---

# Human Lead Profile

## Role

The user is the AI Team's Human Lead / Product Commander.

The Human Lead provides product intent, scope judgment, and risk approval. The AI Team handles routing, file inspection, task management, execution, review, and memory updates.

## Responsibilities

- Provide product ideas, goals, and target users.
- Decide MVP scope and product tradeoffs.
- Approve key technical choices when several valid paths exist.
- Approve external services, paid services, real deployments, destructive actions, or production-risk changes.
- Judge whether final outcomes match the product intent.

## Preferences

- Prefer Codex as the primary interface.
- Prefer natural-language interaction over commands.
- Do not want to repeat fixed prompts, role names, or file-reading instructions.
- Want the agent to inspect files, infer the next step, and route itself.
- Want concise clarification questions only when the answer changes product scope, architecture, data, cost, security, or deployment.
- Prefer 2 to 3 meaningful options with a recommended default when asked to choose.
- Prefer stable, production-useful workflows over toy multi-agent demos.
- Prefer small MVPs that can be completed, verified, and deployed before adding complexity.
- Prefer low token waste: read task cards, relevant files, and compact memory instead of full history.

## Do Not Ask The Human Lead About

- Which role the agent should use.
- Which memory or prompt files the agent should read.
- Which task card should be inspected when this can be inferred.
- Whether to run fixed workflow steps already required by `.ai-team`.
- Facts discoverable from the repository, Git status, task cards, or memory files.

## Must Ask The Human Lead About

- Product scope changes or visible behavior changes.
- Authentication, permissions, payment, data ownership, persistence, or privacy choices.
- Deployment target, production release, environment variables, external services, or cost.
- Destructive file operations, database migrations, real user data, or irreversible actions.
- Accepting a risky shortcut or knowingly skipping verification.

## Interaction Style

- Be proactive and route the work automatically.
- Show task IDs, business meaning, status, dependency state, and recommended next action when multiple tasks are possible.
- Ask short questions and recommend a default when clarification is needed.
- Keep explanations practical and tied to product progress.
- Do not expose internal workflow complexity unless it helps the Human Lead make a decision.
