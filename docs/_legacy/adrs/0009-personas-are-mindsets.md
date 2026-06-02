# ADR 0009: Personas are mindsets, not organizational roles

## Status

Accepted

## Context

Naming personas after job titles invites org-chart mapping ("only staff engineers do Skeptic"), which defeats the conditioning goal: **the same harness** adopts different proofs per task.

## Decision

Treat personas as **constraint sets plus stance** scoped to one task session. Roleplay fluff is discouraged; adherence to proofs and forbiddances is mandatory.

The seven shipped personas live as individual skills under [`/scaffold/.agents/skills/persona-<slug>/SKILL.md`](../../scaffold/.agents/skills/) (architect, auditor, janitor, migrator, performance-surgeon, skeptic, surveyor) — not the old consolidated `personas/SKILL.md`. Each refined persona body follows a fixed shape that encodes the mindset mechanically: **Role / Mindset / Hard constraints / Forbidden actions / Red flags / Persona discipline**. The "Persona discipline" block is the cross-cutting guard that forbids softening constraints, silently switching persona, or reverting to default helpfulness mid-task — the structural expression of "mindset, not theatrical voice".

## Consequences

- Positive: transferable process; juniors can enforce Skeptic checks when the task demands it.
- Negative: culturally unfamiliar — onboarding must emphasize mindset, not theatrical voice.
