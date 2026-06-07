---
type: adr
id: 0001-adopt-swarm
status: accepted
created: 2026-06-07
updated: 2026-06-07
supersedes:
superseded_by:
---

# ADR-0001: Adopt Swarm for this repo

*Lives in: `decisions/` — project-wide decisions, sequentially numbered (`0001-`, `0002-`, …), one per file, superseded rather than rewritten.*

> This is a **seed** ADR — an example showing what `decisions/` is for and the shape an ADR takes. Keep it (it
> genuinely records the decision to adopt Swarm) or replace it with your own first decision.

## Context

This repo is the place our intent lives. We want specs that AI agents can build from reliably, with every
obligation bound to a check and a clear trail from requirement to evidence — rather than ad-hoc prompts.

## Decision

Adopt the Swarm framework. Specs and their supporting docs live in per-feature folders under `specs/<feature>/`;
project-wide decisions live here in `decisions/`; Swarm tooling (skills, reference cards, templates, memory)
lives under `.agents/`; the repo-root `AGENTS.md` is the always-loaded bootloader.

## Alternatives considered

| Alternative | Why rejected |
| --- | --- |
| Keep authoring specs ad-hoc in prose | No obligation/verification structure; agents build unreliably, and there's no requirement→evidence trail. |
| Invent our own spec format | Swarm already provides the obligation language (SOL), the steps, and the artifact set; reinventing them is cost without benefit. |

## Consequences

### Positive

- Every feature has one home for its contract and its supporting evidence.
- Obligations bind to proofs; reviews render verdicts against them.

### Negative

- A short ramp: contributors learn the artifact homes and the SOL clause shape.

### Neutral / tradeoffs

- Intent now lives as structured Markdown, committed alongside the work.

## Status

accepted

## Affected obligations / constraints

- Adds: none (a process decision, not an obligation).
