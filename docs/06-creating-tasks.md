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

Copy [`templates/task.md`](../starter-kit/templates/task.md) and save it under
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

## Next

Hand the packet to an agent: [Running agents](07-running-agents.md).
