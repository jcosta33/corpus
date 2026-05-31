# {{title}}

## Metadata

- Slug: {{slug}}
- Agent: {{agent}}
- Branch: {{branch}}
- Base: {{baseBranch}}
- Worktree: {{worktreePath}}
- Created: {{createdAt}}
- Status: active
- Type: orchestration

---

> ⚠️ **ORCHESTRATION SESSION** — You are managing other agents, not writing code yourself. Your output is the merged result and the trail showing how it got there. Never merge a branch without verifying it empirically.
>
> **MINDSET:** Orchestration carries the **Lead Engineer** mindset — load `.agents/skills/persona-lead-engineer/SKILL.md` (decompose with disjoint ownership, delegate via the hand-off contract, detect stalls, merge in a verified order). For every review pass, also load `.agents/skills/persona-skeptic/SKILL.md` and run the diff hostile to the worker's word; drop the Skeptic again when delegating or merging.
>
> **AGENTS.md:** `{{cmdValidate}}` / `{{cmdTest}}` / `{{cmdInstall}}` resolve from `AGENTS.md > Commands`. Non-contract values (`{{cmdBenchmark}}`, `{{cmdValidateDeps}}`, `{{cmdTypecheck}}`) — ask the user. If `AGENTS.md` is missing, ask before substituting.

---

## Objective

What outcome the orchestration must produce, decomposed from the human's ask. One paragraph maximum.

---

## Linked docs

- Source documents (one per worker): `<paths>`
- Triggering ask: `{{specFile}}`

---

## Worker tracker

<worker_tracker>

Each worker is a sub-task in its own worktree. Track everything here; this is the canonical record.

| Slug | Source doc | Task type | Persona | Owned paths | Forbidden paths | Expected deliverable / acceptance bar | Branch | Status | Last progress | Last review verdict |
| ---- | ---------- | --------- | ------- | ----------- | --------------- | ------------------------------------- | ------ | ------ | ------------- | ------------------- |
|      |            |           |         |             |                 |                                       |        |        |               |                     |

Status values: `not-started`, `in-progress`, `stalled`, `awaiting-review`, `kicked-back`, `merged`, `abandoned`.

- **Owned / Forbidden paths** are the disjoint-scope contract: every worker's owned paths must be pairwise **non-overlapping** — that is what makes parallel writes safe. If two sub-tasks need the same file they are not independent; sequence them, don't parallelise.
- **Expected deliverable / acceptance bar** is the per-worker **hand-off contract** — what the worker must produce and what you will review it against. A spawned worker inherits these into its task file's `## Parent contract`.
- **Last progress** is the **liveness marker**: update it each time you check the worker. A worker whose Last progress has not advanced across two consecutive checks is `stalled` (see Constraints).

</worker_tracker>

---

## Kickback queue

<kickback_queue>

Workers whose branches were rejected at review and need revision. Each kickback names the worker, the reason, and the specific files/lines that must change.

| Worker slug | Reason | Files / lines | Re-review status |
| ----------- | ------ | ------------- | ---------------- |
|             |        |               |                  |

</kickback_queue>

---

## Merge log

<merge_log>

The order branches were merged, conflicts encountered, and how they were resolved. Reconstructable history.

| Order | Worker slug | Merged into | Conflicts | Resolution | Intent-preserved proof |
| ----- | ----------- | ----------- | --------- | ---------- | ---------------------- |
|       |             |             |           |            |                        |

For any non-trivial conflict resolution, **Intent-preserved proof** is the evidence that both branches' behaviour survived the merge — a re-run of the affected tests, or (stronger) a property/differential check on the conflicted region. "Tests pass on the merged branch" is necessary but — where the suite may not cover the interaction — not sufficient; say which you relied on.

</merge_log>

---

## Constraints

- Work only inside this worktree
- Do not write feature code yourself — delegate
- Do not merge a branch without empirical verification (paste worker-branch validation output)
- Load `.agents/skills/persona-skeptic/SKILL.md` for every review pass; do not approve on the worker's word
- Kickback feedback must cite files and lines; vague rejections waste worker time
- Document the merge protocol used (order, conflict resolution)
- **Disjoint scopes:** assign each worker non-overlapping owned paths in the tracker and confirm no two overlap *before* spawning — this invariant is what the parallel-write safety rests on, so it must be recorded, not held in your head
- **Liveness:** update each worker's `Last progress` when you check it; a worker showing no progress across two consecutive checks is `stalled` — re-plan, re-scope, escalate, or abandon it (record which in `## Decisions`). A silent or diverging worker is a failure mode to detect, not a wait
- Recursive sub-orchestration is permitted up to the project's configured limit
- **Proactively research and read related docs.** Browse `.agents/specs/`, `.agents/research/`, `.agents/audits/`, `docs/`, `AGENTS.md`, and the project skills directory as needed.

---

## Progress checklist

- [ ] Decompose the human's ask into N sub-tasks; one source doc per sub-task
- [ ] Assign disjoint owned paths per worker and confirm no two overlap
- [ ] Set each worker's expected deliverable + acceptance bar (the hand-off contract)
- [ ] Fill in the worker tracker
- [ ] Spawn each worker (own worktree, own branch, conditioned task file)
- [ ] As each worker completes: load `persona-skeptic`, review the branch, paste verification output
- [ ] Approve or kick back; if kicked back, fill in the kickback queue
- [ ] Re-review revised branches
- [ ] Merge approved branches in the order documented in the merge log
- [ ] Resolve any merge conflicts; document each resolution
- [ ] Run `{{cmdValidate}}` on the merged result; paste output
- [ ] Run `{{cmdTest}}` on the merged result; paste output
- [ ] Self-review: Verification outputs pasted
- [ ] Self-review: Per-worker review answered
- [ ] Self-review: Kickback specificity answered
- [ ] Self-review: Merge integrity answered
- [ ] Self-review: Trail reconstructibility answered

---

## Decisions

Significant choices made during orchestration: how the work was decomposed, how conflicts were resolved, why a worker was abandoned (if any).

- ***

## Findings

Cross-cutting issues that surfaced across multiple workers — patterns suggesting a deeper architectural concern. Move durable findings to an audit.

- ***

## Assumptions

- [pending]

---

## Blockers

- ***

## Next steps

Concrete starting points for the next session if this one ends incomplete. The next session should be able to identify which workers are merged vs pending from this file alone.

- ***

## Self-review

<self_review>

Stop. Orchestration fails when a worker's word is taken as proof, when a kickback is too vague to act on, or when merges happen out of order and break the integration. Load `.agents/skills/persona-skeptic/SKILL.md` and act as a senior engineer about to ship the merged result, hostile to all three.

> **Hard gate.** The task is not complete until every question below has a written answer directly beneath it.

### Verification outputs (paste actual command output — do not paraphrase)

- `git status` →
- Per-worker review: `git diff <worker-branch>` (representative sample) and `{{cmdValidate}}` output run by you, not the worker
- Final merged-branch `{{cmdValidate}}` (last 2 lines):
- Final merged-branch `{{cmdTest}}` (last 2 lines):

### Per-worker review

- Did you run validation locally for every worker, not trust their pasted output? Did you read each diff under `persona-skeptic`? Are review verdicts in the tracker accurate?
  Answer:

### Kickback specificity

- For every kicked-back branch, does the kickback queue cite specific files and lines and what must change? Did the worker need to come back and ask "what do you mean" — if so, the kickback was insufficient.
  Answer:

### Merge integrity

- Does the merge log show the order branches were merged and how conflicts were resolved? Did the merged result pass full validation, not just per-worker validation? Are there latent integration issues that worked in isolation but break together?
  Answer:

### Trail reconstructibility

- Could a fresh agent reconstruct what happened from this task file alone — which workers ran, which were kicked back, which merged in what order? If not, the trail is incomplete.
  Answer:

### Scope disjointness

- Were worker owned-paths recorded and pairwise non-overlapping? If any two workers touched the same file, was that sequenced rather than parallelised — and can you point at the tracker to prove it?
  Answer:

### Liveness

- Did every worker's `Last progress` advance between checks? Was any worker `stalled` — and if so, is the re-plan / re-scope / escalate / abandon decision recorded? A worker silently stuck `in-progress` is an unverified state.
  Answer:

### Final Polish

- Did you ask yourself: "Did I rubber-stamp any worker's review? Did the merged result actually integrate, or did I declare done at the per-worker level?" Do not leave the work without this final adversarial pass.
  Answer:

Only when every answer above is written is this task complete.

</self_review>
