# ADR 0010: Write-side single-threading

## Status

Accepted

## Context

Parallel autonomous writers collide on merges, violating determinism and bypassing coherent review narratives.

## Decision

Parallelism is acceptable on **read paths** / research; writes that land in one branch must serialize through orchestration (**Lead Engineer** pattern) unless human explicitly forks work with merge policy.

Encoded in recursion limits and orchestration semantics ([`docs/concepts/10-subagent-strategy.md`](../concepts/10-subagent-strategy.md)).

## Consequences

- Positive: merges stay reviewable; fewer conflict-induced silent behaviour changes.
- Negative: throughput cap — tackled via batching orchestration waves, not uncontrolled agents.
