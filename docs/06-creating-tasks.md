# Creating tasks

*Works today — plain markdown plus your agent; no Swarm tooling required.*

A task is a packet of bounded work for one agent or one developer: which
requirements to implement, which files the work touches, what must not change,
and how each requirement gets verified. The spec says what should be true;
the task hands one slice of it to one pair of hands.

The packet matters because the handoff is where agent work goes wrong.
Ambiguous or incomplete task input measurably degrades agent code correctness
[[ORCHID]](research/sources.md#ORCHID)
[[HUMANEVALCOMM]](research/sources.md#HUMANEVALCOMM), and preliminary evidence places the planner-to-coder
handoff as the dominant failure surface in multi-agent code generation
[[PLANCODER]](research/sources.md#PLANCODER). A task packet is that handoff,
written down where you can inspect it.

## The template

Copy [`templates/task.md`](https://github.com/jcosta33/swarm-starter-kit/blob/main/templates/task.md) and save it under
`tasks/` in your workspace (see [Where files live](03-where-files-live.md)).
The template is the format — this page only explains what each part is for:

| Section            | What it carries                                                                                 |
| ------------------ | ----------------------------------------------------------------------------------------------- |
| Source             | The spec the task implements — and the change plan, when it executes one of its waves           |
| Scope              | "Implement or preserve": the requirement and guarantee ids this task owns                       |
| Do not change      | The scope wall (below)                                                                          |
| Affected areas     | The files you expect to change — what keeps parallel tasks apart                                |
| Verify             | One runnable command per requirement                                                            |
| Agent instructions | The standing rules every agent follows; they ship in the template — don't rewrite them per task |
| Findings           | Anything durable discovered along the way, saved to `findings/` at Close                        |
| Run summary        | The handoff digest filled at the end of the run — changed files, per-command results citing the Verify pastes, out-of-scope edits, blocked questions; it cites the Verify evidence, never re-pastes it |

## Sources and scope

A task's `source` names a spec, a change plan, or both. Its `scope` lists the
ids it is responsible for:

- **From a spec** — requirement ids (`AC-001`, `AC-002`): behavior to _implement_.
- **From a [change plan](05-brownfield-and-change-plans.md)** — preservation
  guarantee ids: behavior to _preserve_ while the structure underneath changes.

A task never adds requirements of its own. If the work turns out to need
something no listed requirement covers, the agent's instruction is to stop and
say why — the fix is a spec amendment, not mid-task improvisation.

Fill Verify with real commands, not intentions. Executable acceptance criteria
are the part an agent benefits from most — a runnable check outperforms prose plans as task input (preliminary evidence)
[[ORACLESWE]](research/sources.md#ORACLESWE): a requirement whose check the
agent can actually run is the one most likely to come back done. Where no command can exist —
a physical-rig check, a visual pass — name the manual check; at review its evidence is a named
human's recorded observation (who judged, what they saw).

Two cases need a word before you write the Verify line:

- **A rare runtime state** (a stall, a race, an error path that's hard to trigger) needs a
  **simulation or fixture strategy** named in the task — how the agent will induce the state.
  Without one, the agent can only inspect code, and the row is honestly Blocked, not Pass. The
  states that bite hardest and most often ship uninduced: **browser-extension lifecycle** (install,
  update, a permission prompt), **local model loading** (a slow or failed WebLLM/WebGPU init), a
  **streaming** response mid-flight, a **stall or timeout**, a **denied permission**, and a
  **failure-then-recovery** path. When the behavior lives in the real runtime, say so in the Verify
  line and induce it — code inspection is not proof the state was reached
  ([Reviewing output](08-reviewing-output.md) holds the row Unverified until the runtime evidence is attached).
- **A check with a foundational precondition** (the extension must register before any popup
  assertion; the service must boot before any endpoint test) makes that precondition **its own
  first requirement**, so a dependent check reads Blocked — truth unknown — rather than a
  misleading Fail when the precondition isn't met.

If the task may run a repo-wide auto-fixer (formatter, import sorter, codemod), say so, and have
the worker land a **mechanical-only commit before any behaviour-bearing change** — otherwise the
fix arrives as one large mixed diff the reviewer can't read. Most tasks should not run repo-wide
fixers at all; that is a "Do not change" by default.

## "Do not change" is the scope wall

The most valuable lines in a task packet are often the ones about what _not_
to do. Name the things that are adjacent and tempting: the shared utility the
agent will want to "improve while in there", the public interface that looks
refactorable, the config that belongs to another team.

The wall is a convention — nothing in this repo enforces it. The
[review packet](08-reviewing-output.md) backs it up as a checklist item:
out-of-scope changes are one of its standing exception triggers, so a breach
is routed to a human instead of merged quietly.

## Splitting work across tasks

One task goes to one agent. When you want two tasks running at the same time,
keep them **write-disjoint**: two parallel tasks should not touch the same
files. Compare their Affected areas before you start — if they overlap, or
both need a shared file (a schema, a route table, a central config), the
shared part serializes: one task goes first, the other waits for its merge.

That is the whole rule in plain language. The formal version — read/write
conflict rules, dependency ordering, when "different file names" still
collide — lives in [the advanced lifecycle](reference/advanced-lifecycle.md);
you don't need it for a handful of tasks.

In a multi-repo workspace, an Affected-areas entry may carry a **context prefix** — exactly a
Commands sub-heading's context name (`### Commands (web)` → `web: src/checkout/…`) — binding
the task to that sub-table for its Verify commands. A task names at most one context; entries
that would span contexts are the signal to split. The prefix is task-body content owned by
your workspace — not one of the placeholder namespaces in the checks contract.

For change plans, split by **wave**: the plan's Task split table already names
one or more tasks per wave, and each wave leaves the codebase green before the
next begins. Don't pull tasks forward across waves — the ordering is the plan's
safety mechanism.

## How big should a task be?

**A task an agent can finish in one sitting.** One session, one branch, one
review. Signs it's too big — split it:

- Scope lists more than a handful of requirements.
- Affected areas span unrelated parts of the codebase.
- You can't name a Verify command without saying "and then…".

Too much packet is also a cost: forcing clarification onto already-clear work
measurably hurts [[HUMANEVALCOMM]](research/sources.md#HUMANEVALCOMM)
[[ASKORASSUME]](research/sources.md#ASKORASSUME). A small cleanup is still a
task — but a one-line Scope, one Verify command, and an empty "Do not change"
is a complete packet, not a lazy one.

**The thin path — scale the artifact set to the risk.** The smallest work earns the smallest
record. A reproduced defect rides the [bug-fix shape](examples/bug-fix.md) — a spec *check* (amend
the existing spec, don't author a new one) plus a regression test that runs red first — and a
one-line mechanical cleanup is the one-Scope task above. A separate spec, an
[inventory, or a change plan](05-brownfield-and-change-plans.md) is **earned by risk or spread**,
not written by default. The test is always the same: write exactly enough that a reviewer can map
evidence to intent — no more. Over-papering a two-line fix is the same failure as under-specifying
a migration, pointed the other way.

## Next

Hand the packet to an agent: [Running agents](07-running-agents.md).
