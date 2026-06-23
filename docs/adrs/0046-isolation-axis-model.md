---
type: adr
id: 0046-isolation-axis-model
status: accepted
created: 2026-06-05
updated: 2026-06-06
supersedes:
superseded_by:
---

# ADR-0046: A task implementing a spec gets a worktree+branch; ad-hoc work stays in-place

## Context

Corpus specified worktree/branch/merge only inside the parallel-decomposition coordination record. The
single-task load path (`AGENTS.md` → `task.md` → `implement.md`) carried **no isolation signal**, so
"implement this spec" gave an agent no reason to leave the base branch — and the per-kind templates gave
the inverse cue (the spec-bearing kinds had no Branch field while a few others did). The fix is one small
rule on the load path, not a new subsystem.

## Decision

Isolation is a **binary**, decided by reading the task frame; a frame `isolation:` field overrides it, and
it is **orthogonal to `parallel_group`** (a single non-parallel task can still need a worktree):

- **A code task implementing a spec or audit-remediation** (it has a `source:` `*.md` / audit-derived
  spec) → a **worktree + branch off the base**. The branch is named for what it implements:
  `swarm/<spec-slug>` for a whole spec, `swarm/<spec-slug>/<task-slug>` for one obligation or a fan-out
  worker (one grammar — single-task and parallel reconcile). `base:` records the merge target (default
  `main`; the dev's HEAD when handed off mid-branch). **A spec is implemented off the base, never on it.**
- **Anything else** — a quick ad-hoc edit with no spec, a doc/source-only authoring task, a read-only
  review → **in-place**. No ceremony; the absence of a source artifact is the signal.

This lives where the agent reads it: the `## Isolation` section of `implement.md` (both twins) and the
`isolation:`/`base:` fields on the `task.md` frame, with a one-line trigger in the `starter-kit/AGENTS.md`
startup. Merge + cleanup are the orchestration lifecycle at worker-count 1 (the cross-worker disjointness
condition is vacuous for one writer); an in-flight worktree is recorded under `.swarm/status/worktrees/`.

Refines [0039](./0039-write-surface-model.md) (which scoped isolation to parallel decomposition only) and
operationalizes the single-fork clause of [0010](./0010-write-side-single-threaded.md).

## Alternatives considered

| Alternative | Why rejected |
| --- | --- |
| Leave isolation specified only for parallel decomposition | The status quo — the single-task path has no signal, so a spec lands on the base by default. |
| A multi-rung axis / step-ladder / per-`task_kind` matrix | Over-built for a binary; the extra rungs had no real occupant and didn't cover every kind. The binary + an explicit override is sufficient. |
| Key isolation off `parallel_group` | Conflates two orthogonal axes; a single non-parallel spec task still needs a worktree. |

## Consequences

- An agent can decide worktree-or-not deterministically with **no runtime**, and name the branch for the
  spec it implements; a quick ad-hoc edit stays zero-ceremony.
- **NO RUNTIME means nothing enforces it** — an agent *can* ignore the rule and land a spec on the base.
  This is specification completeness, the same soft-control limit as every Corpus gate; a future launcher
  reads the rule.
- No canonical closed set changes; the merge gate and write-surface model are untouched.

## Status

Accepted (v0.1).

## Affected obligations / constraints

- Adds: the isolation binary + the `isolation:`/`base:` frame fields + the branch-naming convention;
  isolation is orthogonal to `parallel_group`.
- Modifies: `implement.md` (a `## Isolation` section), the `task.md` frame, the `starter-kit/AGENTS.md` startup.
- Refines: [0039](./0039-write-surface-model.md); operationalizes [0010](./0010-write-side-single-threaded.md).
- Does NOT change: the merge gate, the write-surface conflict model, any canonical closed set.

> **Ledger note (2026-06-11):** refined by ADR-0068 (a change-plan wave decomposes into worktree-isolated tasks; isolation rule unchanged).
