---
title: Performance Gate Checklist
tags:
  - ai-team/checklist
  - performance
status: active
---

# Performance Gate Checklist

Use scale-appropriate performance checks.

## S / MVP

- [ ] Build succeeds.
- [ ] Manual smoke test covers main flow.
- [ ] Simple data-volume check if lists/tables are central.

## M / Real Product

- [ ] Critical UI remains usable with realistic data volume.
- [ ] Key API/database paths have basic latency or load checks.
- [ ] Obvious N+1, repeated fetch, and large re-render issues were checked.

## L / High-Risk Product

- [ ] Define target throughput, latency, and error rate.
- [ ] Run load tests for critical flows.
- [ ] Check database, cache, queue, and external-service bottlenecks.
- [ ] Document monitoring and rollback signals.
