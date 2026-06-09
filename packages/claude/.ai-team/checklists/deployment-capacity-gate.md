---
title: Deployment Capacity Gate
tags:
  - ai-team/checklist
  - deployment
status: active
---

# Deployment Capacity Gate

Use before choosing deployment infrastructure, releasing to users, or adding paid external services.

## Must Know

- [ ] Expected users, daily active users, and peak concurrency.
- [ ] Region needs, domestic access needs, compliance, and filing constraints when relevant.
- [ ] Budget range.
- [ ] Data durability, backup, and restore expectations.
- [ ] File/object storage, CDN, email/SMS/payment/external service needs.
- [ ] Monitoring, logs, alerts, and rollback plan.
- [ ] Scale-up path if traffic grows.

## Rules

- Do not recommend Kubernetes, microservices, queues, Redis, or expensive managed services unless scale or risk justifies them.
- Do not deploy production or connect paid services without Human Lead approval.
- Match infrastructure to the confirmed product scale. Avoid both underpowered servers and wasteful overcapacity.

## Output

- deployment target
- estimated capacity
- monthly cost range
- required environment variables and secrets
- backup/monitoring plan
- rollback plan

