# The basic workflow

_Works today — plain markdown plus your agent; no Corpus tooling required._

Six steps. Two more — Inventory and Change Plan — switch on only when the work is structural
or brownfield:

```
Pull → (Inventory) → Spec → (Change Plan) → Task → Run → Review → Close
        optional             optional
```

Every artifact below is a markdown file in your workspace. Where each lives:
[03-where-files-live.md](03-where-files-live.md).

New to the loop? **[Walk it once, hands-on](tutorial/README.md)** — a guided build that
produces each artifact on one small change.

## 1 · Pull — capture what was asked

Work starts in a tracker, an issue, a doc, a conversation — or with you. When it starts
outside, copy the ticket **verbatim** into an intake file: unedited, uninterpreted. The spec
interprets later. The intake preserves what was actually asked, so the spec keeps its anchor
when the upstream item changes or disappears. Recommended for external work, never required.
(`corpus pull` snapshots it for you; by hand, copy-paste into the template.)

Artifact: [intake](https://github.com/jcosta33/corpus-starter-kit/blob/main/templates/intake.md) → `intake/`.

## (Inventory) — map before you move _(brownfield work only)_

Before cutting new boundaries through code you didn't write, map what exists: modules,
interfaces and their callers, observed behavior with evidence, existing tests, the unknowns.
An inventory observes. It never judges or prescribes.

Artifact: [inventory](https://github.com/jcosta33/corpus-starter-kit/blob/main/templates/inventory.md) → `inventory/`. When to write one:
[05-brownfield-and-change-plans.md](05-brownfield-and-change-plans.md).

## 2 · Spec — interpret it into requirements

Turn the ask into intent, non-goals, and requirements — one `AC-NNN` per requirement, each
with a `Verify with:` line. That line is the highest-value line in the file. A runnable
acceptance check beats prose plans as task input (preliminary evidence) [[ORACLESWE]](research/sources.md#ORACLESWE).
Record open questions; a spec with open questions is not ready.

Artifact: [spec](https://github.com/jcosta33/corpus-starter-kit/blob/main/templates/spec.md) → `specs/<feature>/spec.md`. How to write one:
[04-writing-specs.md](04-writing-specs.md).

## (Change Plan) — plan what must survive _(structural work only)_

For a refactor, migration, or rewrite the question isn't "what behavior should exist" but
"how does the codebase change safely." A change plan lists the behavior that must be
preserved — each with a way to verify it. It also fixes the order of changes, cutover
conditions, and rollback criteria.

Artifact: [change plan](https://github.com/jcosta33/corpus-starter-kit/blob/main/templates/change-plan.md) → `change-plans/`. When to
write one: [05-brownfield-and-change-plans.md](05-brownfield-and-change-plans.md).

## 3 · Task — bound the agent's work

Split the spec (or one change-plan step) into agent-sized packets. Each names the source it
implements, the requirement IDs in scope (implement or preserve), a "Do not change" list, the
verify commands, and the agent instructions — including the order to re-read its own diff as a
skeptic before declaring done.

Artifact: [task](https://github.com/jcosta33/corpus-starter-kit/blob/main/templates/task.md) → `tasks/`. How to split work:
[06-creating-tasks.md](06-creating-tasks.md).

## 4 · Run — let the agent work, isolated

Hand the packet to your agent on its own branch and worktree. It implements and runs every
Verify item, pasting the real output — a claim without output is unverified. Then it fills the
packet's `## Run summary`: changed files, results citing the Verify pastes, anything learned.

How: [07-running-agents.md](07-running-agents.md).

## 5 · Review — read the evidence, not the whole diff

Fill the review packet: one row per requirement with a result — Pass, Fail, Unverified, or
Blocked — and its evidence. A Pass needs pasted output, a CI link, or, for a manual Verify
method, a named human's recorded observation (who judged, what they saw). An empty Evidence
cell means Unverified, never Pass. Then route the exceptions — failed or unverified rows,
out-of-scope changes, risky files — to human attention. You don't re-read every line.

Artifact: [review](https://github.com/jcosta33/corpus-starter-kit/blob/main/templates/review.md) → `reviews/`. How:
[08-reviewing-output.md](08-reviewing-output.md).

## 6 · Close — merge, record, keep the lesson

Merge or block. Save anything durable — a fact, a decision, a gotcha — as a finding, so the
next session doesn't re-learn it. The sessions keep the board honest. The finishing agent
flips its task's row; the reviewing session closes it. You read it.

Artifacts: [finding](https://github.com/jcosta33/corpus-starter-kit/blob/main/templates/finding.md) → `findings/`,
[status board](https://github.com/jcosta33/corpus-starter-kit/blob/main/templates/status.md) → `status.md`. How:
[09-saving-findings.md](09-saving-findings.md).

## Pick the flow for the shape of the work

| Shape             | Flow                                                                                                |
| ----------------- | --------------------------------------------------------------------------------------------------- |
| **Feature**       | the six steps                                                                                       |
| **Refactor**      | Inventory/Audit (a present-state inspection — advanced) → Change Plan → Task → Run → Review → Close |
| **Bug**           | Pull → Spec amend → Task → Run → Review → Close                                                     |
| **Rewrite**       | Inventory → Audit → Spec + Change Plan → Tasks → …                                                  |
| **Small cleanup** | Task → Run → Review → Close                                                                         |
| **Spike**         | Question → Research (an options survey — advanced) → decision                                       |

_Spec amend_: find the spec the bug contradicts and amend it if the bug reveals a gap. Most
bugs don't need a new spec. A bug with **no covering spec** takes the arrives-as-code path in
[08-reviewing-output.md](08-reviewing-output.md). Performance work runs the Bug or Refactor
flow with a numeric target and baseline-first discipline (the `write-performance` guide in
[the corpus-skills catalog](https://github.com/jcosta33/corpus-skills)). _Audit_ and _Research_
are advanced artifacts; see [reference/artifact-formats.md](reference/artifact-formats.md).

## When to skip steps

Skipping is design, not concession. Forcing clarification onto already-clear tasks measurably
hurts the result [[HUMANEVALCOMM]](research/sources.md#HUMANEVALCOMM)
[[ASKORASSUME]](research/sources.md#ASKORASSUME). The skip-paths:

- **Skip Pull** when the work originates with you — there's no upstream item to preserve.
- **Skip Inventory** when you know the territory. A single-file cleanup never needs one.
- **Skip a new Spec** when an existing spec covers the behavior. A bug fix usually amends a spec rather than authoring one.
- **Skip the Spec for a self-evident micro-feature.** A small net-new change with obvious acceptance criteria nobody has to _agree_ on goes straight to a thin task that inlines its two or three ACs (the one-line test in [Writing specs](04-writing-specs.md)). The review still runs, against the task's own ACs.
- **Skip Change Plan** for an obvious bug fix or a purely additive feature. It earns its keep only when existing behavior must provably survive a structural change.
- **Skip Spec and Change Plan both** for a small cleanup — the task packet alone bounds it.
- **Skip the board for trivial work** — a one-line cleanup needs no status row; the PR is enough.
- **Skip the board when a tracker owns task state** (Jira, Linear). Keep the review-packet links in the tracker rows instead. The board earns its keep where it is the single surface.
- **A spike skips nearly everything.** None of the six steps run until its outcome becomes a spec or a change plan. Ask the question, do the research, record the decision.

What code-changing work never skips: Run with verification, and Review with evidence. These
skip rules are conventions — nothing in this repo enforces them.

## Going deeper

Every step has a bar: the predicates that say whether its output was faithfully produced, not
just well-formatted ([reference/step-bars.md](reference/step-bars.md)). High-risk changes have a
more granular lifecycle ([reference/advanced-lifecycle.md](reference/advanced-lifecycle.md)).
The six steps are the default.
