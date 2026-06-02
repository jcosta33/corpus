# 📋 Task: orchestration

> **TL;DR.** Decompose a complex ask into independent sub-tasks, delegate each to a worker (in their own worktree), review each branch as the Skeptic, and merge in a chosen order. Lead persona is The Lead Engineer, which ships as the `persona-lead-engineer` skill (orchestration has no workflow skill, so the coordination mindset itself is the discipline — [ADR 0025](../adrs/0025-orchestration-coordination-artifact.md)). The orchestration task file is the canonical record — anyone reading it can reconstruct what happened.

> 📦 **This page is documentation.** The actual task template lives at [`/scaffold/.agents/templates/task-orchestration.md`](../../scaffold/.agents/templates/task-orchestration.md).

---

## 🎯 When to use

An `orchestration` task is right when:

- The ask spans multiple source documents (5 specs, an audit + 3 follow-up specs, etc.).
- A single complex spec warrants decomposition.
- Disjoint scopes can be worked in parallel by separate workers.

If the ask doesn't decompose into disjoint scopes, collapse to a single-agent task. The framework's response: there is no shame in single-threaded work; coordination cost on coupled work is too high.

---

## 🧬 Metadata

| Field                | Value                                              |
| -------------------- | -------------------------------------------------- |
| **Source docs**      | Multiple (one per worker)                          |
| **Lead persona**     | [The Lead Engineer](../personas/the-lead-engineer.md), becoming [The Skeptic](../personas/the-skeptic.md) for each review |
| **Output**           | Merged result + worker tracker + merge log         |
| **Recommended skills** | `persona-lead-engineer` (the coordination mindset; self-activates on "multiple source docs / decompose and delegate / merge parallel branches"), `adversarial-review` (for review pass), `empirical-proof`, `persona-skeptic` (for each branch review) |
| **Verification gate slots** | `cmdInstall` (pre), per-worker review (`cmdValidate`/`cmdTest` run by Lead Engineer), final merged-branch `cmdValidate`/`cmdTest` (post) |
| **Confidence tier** | Orchestration is the *independently-reviewed* tier ([ADR 0024](../adrs/0024-confidence-tiers.md)): the Lead Engineer re-runs each worker's validation/tests in a fresh worktree under `adversarial-review`, so merged code clears the bar a solo (self-reviewed) task does not |

---

## Canonical template (agent artefact)

The verbatim Markdown template (persona directive, placeholders, gated `Self-review`) lives under **`/scaffold/.agents/templates/`**. Install by copying [`/scaffold`](../../scaffold/README.md); do not paste large template bodies from framework docs into downstream repos — that guarantees drift.

### Why these structural clusters exist

Every task template shares the same structural clusters; see [Why these structural clusters exist](README.md#why-these-structural-clusters-exist) in the task-type overview for the shared rationale.

### The coordination contract the artifact records

Per [ADR 0025](../adrs/0025-orchestration-coordination-artifact.md), the orchestration artifact records the coordination contract as readable fields a reviewer (or a checker) can reconstruct — not a runtime. The worker tracker and merge log carry:

- **Owned / forbidden paths per worker** — the disjoint-scope contract that makes write-side parallelism safe ([ADR 0010](../adrs/0010-write-side-single-threaded.md)). Pairwise non-overlapping, confirmed before spawning. The invariant is re-derivable from the artifact rather than held in the lead's head.
- **Expected-deliverable / acceptance-bar per worker** — the hand-off contract, inherited into each worker's `## Parent contract` in `task-base.md`. This is what defeats "vague subtask descriptions," the field's named #1 multi-agent failure mode.
- **A liveness marker (last-progress) + `stalled` status + re-plan trigger** — a worker hung `in-progress` or silently diverging becomes a detectable state, with a documented stall → re-plan / re-scope / escalate / abandon action.
- **An intent-preserved proof per non-trivial conflict** — the merge log shows that a conflict resolution kept both sides' intent, not just that the suite passed (the suite can miss the interaction).

---

## ⚠️ Common anti-patterns

- Merging on the worker's word
- Kicking back with vague notes
- Doing the work yourself
- Spawning workers with overlapping scopes
- Skipping integrated validation
- Letting kickback loops exceed 3 rounds without escalation

---

## See also

- [`personas/the-lead-engineer.md`](../personas/the-lead-engineer.md)
- [`personas/the-skeptic.md`](../personas/the-skeptic.md) — your alter-ego for review passes
- [`concepts/08-recursion-and-delegation.md`](../concepts/08-recursion-and-delegation.md)
- [`concepts/10-subagent-strategy.md`](../concepts/10-subagent-strategy.md) — write-side single-threaded
- [`tasks/kickback.md`](kickback.md) — what kickback tasks look like
