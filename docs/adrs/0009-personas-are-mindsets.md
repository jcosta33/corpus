# ADR 0009: Personas are mindsets, not organizational roles

## Status

Superseded by [0036](./0036-heuristic-profile-model.md) — personas are recast as **heuristic profiles** that parameterize a pass (§27); "mindset, not org role" is preserved and made explicit. The original decision text below is kept as history (Nygard, §30.1: an accepted ADR is never edited in place; only this status line is added).

## Context

Naming personas after job titles invites org-chart mapping ("only staff engineers do Skeptic"), which defeats the conditioning goal: **the same harness** adopts different proofs per task.

## Decision

Treat personas as **constraint sets plus stance** scoped to one task session. Roleplay fluff is discouraged; adherence to proofs and forbiddances is mandatory.

The seven shipped personas live as individual skills under `/scaffold/.agents/skills/persona-<slug>/SKILL.md` (architect, auditor, janitor, migrator, performance-surgeon, skeptic, surveyor), each a standalone unit rather than a single consolidated `personas/SKILL.md`. Each refined persona body follows a fixed shape that encodes the mindset mechanically: **Role / Mindset / Hard constraints / Forbidden actions / Red flags / Persona discipline**. The "Persona discipline" block is the cross-cutting guard that forbids softening constraints, silently switching persona, or reverting to default helpfulness mid-task — the structural expression of "mindset, not theatrical voice".

## Consequences

- Positive: transferable process; juniors can enforce Skeptic checks when the task demands it.
- Negative: culturally unfamiliar — onboarding must emphasize mindset, not theatrical voice.
