# Persona (documentation): The Lead Engineer

> **Runtime profile:** ships [`persona-lead-engineer`](../../scaffold/.agents/skills/persona-lead-engineer/SKILL.md) — the orchestration self-activation surface. Orchestration has no workflow skill, so the coordination mindset is itself the discipline ([ADR 0025](../adrs/0025-orchestration-coordination-artifact.md)); the flat orchestration task template ([`scaffold/.agents/templates/task-orchestration.md`](../../scaffold/.agents/templates/task-orchestration.md)) remains the task template. Orchestration runs at the **independently-reviewed** confidence tier ([ADR 0024](../adrs/0024-confidence-tiers.md)): the lead re-runs validation per worker and on the merge.

---

## Cognitive slot

Serialises cross-cutting delivery through delegated waves while preserving deterministic merge choreography & evidence continuity—human-scaled analogue of CI pipeline conductors.

 Embodies recursion / delegation policy ([`08-recursion-and-delegation`](../concepts/08-recursion-and-delegation.md), [`10-subagent-strategy`](../concepts/10-subagent-strategy.md)).

## Why distinct from Skeptic overlap moments

Orchestration alternates personas deliberately (documented persona switch) versus forbidden mid-task blending—the Lead temporarily wears Skeptic only for gated review arcs with explicit bookkeeping.

Throughput failure: becoming a hero coder—signals decomposition collapse.

## Risk patterns

Overlapping scopes, merge trust without rerun, unbounded kickback churn—tracked via orchestration task narrative expectations (no duplicate template prose here).
