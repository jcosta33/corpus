# ADR 0019: Personas ship as individual skills

## Status

Superseded by [0036](./0036-heuristic-profile-model.md) — a standalone file becomes **one carrier option** for a profile (§27.1), not the only shipping form. The original decision text below is kept as history (Nygard, §30.1: an accepted ADR is never edited in place; only this status line is added).

## Context

The persona catalogue describes **13 mindsets** ([`docs/personas/`](../personas/)). One option is to pack the canonical persona payloads into a single consolidated `personas/SKILL.md`. But that single file would force a consumer to load all personas to get any one of them, contradicting selective vendoring, and it would carry mindsets that duplicate a workflow skill — a "Builder" persona says little that `write-feature` doesn't already say.

With no always-loaded skills ([0017](./0017-no-always-load-skills.md)) and activation by self-assessment ([0020](./0020-activation-by-self-assessment.md)), each persona that ships needs its own directive `description` so the agent can load *that* mindset when the work calls for it — which a consolidated file cannot provide.

## Decision

A persona ships as a standalone skill **only when its mindset adds something beyond the matching workflow skill**. By that test, **8 of the 13 mindsets ship** as individual skills at `/scaffold/.agents/skills/persona-<slug>/SKILL.md`:

- persona-architect, persona-auditor, persona-janitor, persona-migrator, persona-performance-surgeon, persona-skeptic, persona-surveyor, persona-lead-engineer.

The other **5 mindsets do not ship as skills** — each is carried by the matching workflow skill, where the mindset and the procedure are the same thing:

- Builder → `write-feature`; Bug Hunter → `write-bug-report`; Documentarian → `write-documentation`; Test Author → `write-testing`; Researcher → `write-research`.

**Lead Engineer ships** (`persona-lead-engineer`) precisely *because* it has no workflow skill — orchestration ships none — so the coordination mindset (disjoint-scope decomposition, the hand-off contract, liveness, verified merge) *is* the discipline and clears the bar. See [0025](./0025-orchestration-coordination-artifact.md).

The [`docs/personas/`](../personas/) catalogue still documents all 13 mindsets and marks which 7 ship as skills. Each shipped persona body uses the fixed shape from [0013](./0013-iron-law-red-flags-pattern.md): Role / Mindset / Hard constraints / Forbidden actions / Red flags / Persona discipline.

## Consequences

- Positive: a consumer vendors only the persona mindsets their work needs; each self-activates on its own `description`.
- Positive: no duplication between a persona and a workflow skill — the mindset lives in exactly one place.
- Negative: "13 mindsets, 8 skills" needs explaining so nobody hunts for a `persona-builder` skill — handled by the catalogue marking which mindsets ship and which ride a workflow skill.

## Alternatives rejected

- **Ship all 13 as persona skills.** Five would be near-duplicates of their workflow skill, doubling the surface for no added discipline.
- **Keep one consolidated `personas/SKILL.md`.** Forces all-or-nothing loading and can't give each mindset the directive `description` that self-assessment activation depends on.
