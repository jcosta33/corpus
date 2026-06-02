# ADR 0002: Personas pair 1:1 with task types

## Status

Superseded by [0020](./0020-activation-by-self-assessment.md) (and informed by [0019](./0019-personas-ship-as-individual-skills.md)).

The 1:1 task-type → persona pairing now stands as a **suggested default route**, not a deterministic assignment. The agent may re-assess and load a different persona skill when the work in front of it doesn't match the suggested default (recording the divergence in its task file's `## Decisions`). Determinism is **no longer gatekeeper-enforced** — the flow graph is recommended routing (a launcher *may* apply it deterministically, but nothing in-session blocks a re-assessment). The original decision text below is kept as history.

## Context

Free-form persona choice lets models pick whichever stance flatters continuation bias ("helpful reviewer who approves"). That collapses empirical discipline and mixes incompatible proofs in one session.

## Decision

Every **task type** maps to **exactly one default lead persona**. The launcher sets persona from task type + flow graph; the agent does not self-assign.

Overlay personas remain **project-local** additions; they extend, not splinter, the canonical map.

## Consequences

- Positive: deterministic conditioning; Skeptic proofs never blend with Builder improvisation in the same task by default.
- Negative: occasional misfit when reality straddles types — resolved by **re-tasking**, not persona blending mid-session.
