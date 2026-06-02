# ADR 0014: User prose says "delegation"; internals may say "recursion"

## Status

Accepted

## Context

"Swarm recursion" invited marketing caricature (**Swarm-inside-Swarm**) and distracted from mechanics: deterministic sub-task spawning with merge ordering.

Stakeholders resonate with engineering language (**delegating** scoped units of work) without losing the DAG mental model.

## Decision

Documentation defaults to **delegation**, **sub-orchestration**, or **Lead Engineer pattern** externally. Specifications of the routing graph may still call the mechanism **recursive conditioning** internally.

Behaviour unchanged — naming only.

## Consequences

- Positive: clearer intent for audit/compliance audiences.
- Negative: glossary must clarify synonyms ([`reference/glossary.md`](../reference/glossary.md)).
