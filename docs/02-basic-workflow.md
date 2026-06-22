# The basic workflow

*Works today — plain markdown plus your agent; no Swarm tooling required.*

Swarm's workflow is six steps. Two more — Inventory and Change Plan — switch on only when the
work is structural or brownfield, and stay off otherwise:

```
Pull → (Inventory) → Spec → (Change Plan) → Task → Run → Review → Close
        optional             optional
```

Every artifact below is a markdown file in your workspace — where each one lives is
[03-where-files-live.md](03-where-files-live.md).

New to the loop? **[Walk it once, hands-on](tutorial/README.md)** — a guided build that produces
each of these artifacts on one small change.

## 1 · Pull — capture what was asked

Work originates in an external tool **or with you** — a tracker, an issue, a doc, a
conversation, or your own idea. When it starts outside, copy the ticket, issue, or page
**verbatim** into an intake file — unedited, uninterpreted. The spec will interpret; the intake
preserves what was actually asked, so when the upstream item changes or disappears, the spec
keeps its anchor.
Recommended whenever work originates in an external tool; never required. (The optional
`swarm pull` captures this snapshot for you; by hand you copy-paste into the template.)

Artifact: [intake](https://github.com/jcosta33/swarm-starter-kit/blob/main/templates/intake.md) → `intake/`.

## (Inventory) — map before you move _(brownfield work only)_

Before drawing new boundaries through code you didn't write, map what exists: current modules,
interfaces and their callers, observed behavior with evidence, existing tests, and the unknowns.
An inventory observes — it never judges or prescribes.

Artifact: [inventory](https://github.com/jcosta33/swarm-starter-kit/blob/main/templates/inventory.md) → `inventory/`. When to write one:
[05-brownfield-and-change-plans.md](05-brownfield-and-change-plans.md).

## 2 · Spec — interpret it into requirements

Turn the ask into intent, non-goals, and requirements — one `AC-NNN` per requirement, each with
a `Verify with:` line. That line is the highest-value line in the file: a runnable acceptance
check outperforms prose plans as task input (preliminary evidence) [[ORACLESWE]](research/sources.md#ORACLESWE).
Record open questions; a spec with open questions is not ready.

Artifact: [spec](https://github.com/jcosta33/swarm-starter-kit/blob/main/templates/spec.md) → `specs/<feature>/spec.md`. How to write one:
[04-writing-specs.md](04-writing-specs.md).

## (Change Plan) — plan what must survive _(structural work only)_

For a refactor, migration, or rewrite, the question is not "what behavior should exist" but "how
does the codebase change safely". A change plan enumerates the behavior that must be preserved —
each item with a way to verify it — plus the order of changes, cutover conditions, and rollback
criteria.

Artifact: [change plan](https://github.com/jcosta33/swarm-starter-kit/blob/main/templates/change-plan.md) → `change-plans/`. When to
write one: [05-brownfield-and-change-plans.md](05-brownfield-and-change-plans.md).

## 3 · Task — bound the agent's work

Split the spec (or one step of a change plan) into agent-sized packets: the source it implements,
the requirement IDs in scope ("implement or preserve"), a "Do not change" list, the verify
commands, and the agent instructions — including the instruction to re-read its own diff as a
skeptic before declaring done.

Artifact: [task](https://github.com/jcosta33/swarm-starter-kit/blob/main/templates/task.md) → `tasks/`. How to split work:
[06-creating-tasks.md](06-creating-tasks.md).

## 4 · Run — let the agent work, isolated

Hand the packet to your agent on its own branch and worktree. The agent implements, runs every
Verify item and pastes the real output — a claim without output counts as unverified — and fills
the packet's `## Run summary` section: changed files, results citing the Verify pastes, anything
learned.

How: [07-running-agents.md](07-running-agents.md).

## 5 · Review — read the evidence, not the whole diff

Fill the review packet: one row per requirement with a result — Pass, Fail, Unverified, or
Blocked — and its evidence. A Pass needs pasted output, a CI link, or, for a manual Verify method, a named human's recorded observation
(who judged, what they saw); an empty Evidence cell means Unverified, never Pass. Then route the exceptions (failed or unverified rows, out-of-scope
changes, risky files) to human attention instead of re-reading every line.

Artifact: [review](https://github.com/jcosta33/swarm-starter-kit/blob/main/templates/review.md) → `reviews/`. How:
[08-reviewing-output.md](08-reviewing-output.md).

## 6 · Close — merge, record, keep the lesson

Merge or block, and save anything durable — a fact, a decision, a gotcha — as a finding so the
next session doesn't re-learn it. The sessions keep the board honest — the finishing agent flips
its task's row, the reviewing session closes it — you read it.

Artifacts: [finding](https://github.com/jcosta33/swarm-starter-kit/blob/main/templates/finding.md) → `findings/`,
[status board](https://github.com/jcosta33/swarm-starter-kit/blob/main/templates/status.md) → `status.md`. How:
[09-saving-findings.md](09-saving-findings.md).

## Pick the flow for the shape of the work

| Shape             | Flow                                                        |
| ----------------- | ----------------------------------------------------------- |
| **Feature**       | the six steps                                               |
| **Refactor**      | Inventory/Audit (a present-state inspection — advanced) → Change Plan → Task → Run → Review → Close |
| **Bug**           | Pull → Spec amend → Task → Run → Review → Close             |
| **Rewrite**       | Inventory → Audit → Spec + Change Plan → Tasks → …          |
| **Small cleanup** | Task → Run → Review → Close                                 |
| **Spike**         | Question → Research (an options survey — advanced) → decision                              |

_Spec amend_ means: find the spec the bug contradicts and amend it if the bug reveals a gap —
most bugs don't need a new spec. A bug with **no covering spec** at all takes the
arrives-as-code path in [08-reviewing-output.md](08-reviewing-output.md). Performance work runs
the Bug or Refactor flow with a numeric target and baseline-first discipline (the
`write-performance` guide in [the swarm-skills catalog](https://github.com/jcosta33/swarm-skills)). _Audit_ and _Research_ are advanced
artifacts; see [reference/artifact-formats.md](reference/artifact-formats.md).

## When to skip steps

Not every task needs every step — and this is not a concession. Forcing clarification onto
already-clear tasks measurably hurts the result (the document analogue is this framework's
design judgment)
[[HUMANEVALCOMM]](research/sources.md#HUMANEVALCOMM)
[[ASKORASSUME]](research/sources.md#ASKORASSUME). The skip-paths are part of the design:

- **Skip Pull** when the work originates with you — there is no upstream item to preserve.
- **Skip Inventory** when you already know the territory. A single-file cleanup never needs one.
- **Skip writing a new Spec** when an existing spec covers the behavior — a bug fix usually
  amends a spec rather than authoring one.
- **Skip the Spec for a self-evident micro-feature** — a small net-new change whose acceptance
  criteria are obvious and that no one has to *agree* on goes straight to a thin task that inlines
  its two or three ACs (the one-line test in [Writing specs](04-writing-specs.md)). The review still
  runs, against the task's own ACs.
- **Skip Change Plan** for an obvious bug fix or a purely additive feature — it earns its keep
  only when existing behavior must provably survive a structural change.
- **Skip Spec and Change Plan both** for a small cleanup — the task packet alone bounds it.
- **Trivial work skips the board too:** a one-line cleanup needs no status row — the PR is enough.
- **The board is optional when a tracker owns task state** (Jira, Linear): keep the
  review-packet links in the tracker rows instead — the board earns its keep where it is the
  single surface.
- **A spike skips nearly everything** — it is the degenerate flow: none of the six steps
  run until its outcome becomes a spec or a change plan. In the table: ask the question, do the research, record the decision.

What code-changing work never skips: Run with verification and Review with evidence. These skip
rules are conventions — nothing in this repo enforces them.

## Going deeper

Every step has a bar — the predicates that say whether its output was faithfully produced,
not just well-formatted: [reference/step-bars.md](reference/step-bars.md). And there is a more
granular lifecycle for high-risk changes — see
[reference/advanced-lifecycle.md](reference/advanced-lifecycle.md). The six steps are the default.
