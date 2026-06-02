# ADR 0013: Iron-law + red-flags persona format

## Status

Accepted

## Context

Soft guidance bullet lists degrade under LLM optimisation — models reinterpret "should avoid" as "unless inconvenient".

Borrowing clarity from hostile-review pattern libraries, Swarm personas pair **Hard constraints / Forbidden actions** (**iron-law style absolutes**) with explicit **Red flags** tables mapping rationalisations to refusals.

## Decision

Canonical persona payloads live inside the seven individual persona skills at [`/scaffold/.agents/skills/persona-<slug>/SKILL.md`](../../scaffold/.agents/skills/) (architect, auditor, janitor, migrator, performance-surgeon, skeptic, surveyor) — not a single consolidated `personas/SKILL.md`. Each refined persona body uses the fixed shape **Role / Mindset / Hard constraints / Forbidden actions / Red flags / Persona discipline**: the iron-law absolutes land in *Hard constraints* and *Forbidden actions*, the rationalisation→refusal table is the *Red flags* section, and *Persona discipline* is the cross-cutting guard against softening or persona-switching mid-task. Documentation **explains** why this shape works (see [`docs/concepts/04-personas.md`](../concepts/04-personas.md)).

## Consequences

- Positive: mechanistic refusal of comforting shortcuts; aligns with empirical gates.
- Negative: verbosity — compensated by skim-friendly TL;DR at each profile head.
