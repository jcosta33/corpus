# ADR 0025: The orchestration coordination artifact — ownership, hand-off, liveness, merge-intent

## Status

Accepted

## Context

The [agents-as-compiler readiness audit](../../.agents/audits/agents-as-compiler-readiness.md) found the multi-agent path — the framework's highest-stakes work — the least conditioned:

- **No self-activating surface (Finding 5):** orchestration shipped no skill, so in a no-always-loaded-skills world ([0017](./0017-no-always-load-skills.md)) an agent handed multiple source docs had nothing to fire the Lead Engineer discipline.
- **No recorded ownership (Finding 6):** the disjoint-file-scope rule the entire write-side-parallel safety argument rests on lived only as prose; the worker tracker had no owned-paths field.
- **No hand-off contract (Finding 7):** spawned workers inherited a generic task file, not lead-authored boundaries/objective/acceptance-bar — "vague subtask descriptions" is the field's named #1 multi-agent failure mode.
- **No liveness (Finding 8):** the tracker's status enum was terminal-stages only; a worker hung `in-progress` or silently diverging was an invisible state.
- **Unverified merges (Finding 9):** the merge protocol was ordering advice; a conflict resolution was re-tested only by a suite the docs admit can miss the interaction.

## Decision

Two changes make multi-agent coordination conditioned and auditable:

1. **The Lead Engineer ships as a skill** — `persona-lead-engineer` — with a directive `description` that self-activates on "multiple source docs / decompose and delegate / merge parallel branches." Orchestration is no longer the one task type with no in-session conditioning surface.
2. **The orchestration artifact records the coordination contract.** `task-orchestration.md`'s worker tracker carries per-worker **owned / forbidden paths** (the disjoint-scope contract — pairwise non-overlapping, confirmed before spawning), an **expected-deliverable / acceptance-bar** (the hand-off contract, inherited into each worker's `## Parent contract` in `task-base.md`), and a **last-progress** marker with a `stalled` status and a documented stall→re-plan/re-scope/escalate/abandon action. The merge log carries an **intent-preserved proof** column for non-trivial conflicts.

These are recorded fields a reviewer (or a checker, [0026](./0026-conformance-contract.md)) can read — not a runtime. The disjoint-scope invariant becomes re-derivable from the artifact rather than held in the lead's head; a stalled worker becomes a detectable state; a hand-off becomes a contract.

## Consequences

- Positive: decomposition correctness (the property that makes parallel writes safe) is auditable and reconstructable from the task file alone.
- Positive: the highest-stakes path is conditioned by the same self-activation mechanism as every single-agent path.
- Positive: reopens nothing in [0010](./0010-write-side-single-threaded.md) — single-threaded *writes* still hold; this records *how the lead decomposes and merges* them.
- Negative: more fields for the lead to maintain by hand; until a harness/checker validates them, disjointness and liveness are still lead-attested (the serial-merge + per-merge-validation backstop remains the safety net).

## Alternatives rejected

- **Keep orchestration skill-less, discipline in the flat template only.** The audit's Finding 5 — the multi-agent path is the only one with no in-session self-activation.
- **Record coordination state outside the task file (a separate ledger).** Splits the resumption record; the task file is the single canonical record by [0004](./0004-task-files-are-gitignored.md)'s logic.
- **A runtime scheduler that detects stalls automatically.** Violates Principle 1 (no runtime); the framework records the *contract* (a liveness marker + threshold + action) a runtime could later automate.
