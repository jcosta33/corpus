# Brownfield work and change plans

*Works today — plain markdown plus your agent; no Swarm tooling required.*

Two artifacts join the loop only when the work is structural or brownfield — refactors,
rewrites, migrations, dependency upgrades, performance and schema work, or any change to code
nobody fully remembers:

```text
Pull → (Inventory) → Spec → (Change Plan) → Task → Run → Review → Close
```

An **inventory** maps what exists before anyone draws new boundaries. A **change plan** says how
the codebase will change, safely. Most feature work needs neither, and writing them
indiscriminately recreates the ceremony the skip-paths exist to avoid
[[HUMANEVALCOMM]](research/sources.md#HUMANEVALCOMM)
[[ASKORASSUME]](research/sources.md#ASKORASSUME). Both artifacts — and every when-to-write
threshold on this page — are conventions: nothing in this repo enforces them, and no controlled
study of the documents themselves exists. The rationale is design experience, not measurement:
mature migration ecosystems — codemod suites, framework upgrade guides, large-scale refactoring
tools — independently converge on the same ingredients these templates carry: staged waves,
before/after examples, rollback and cutover guidance, and an explicit list of what must not change.

## Inventory — map the terrain first

Brownfield change fails predictably when nobody reconstructs the current contract before moving
code. The other artifacts don't cover this: a spec describes desired behavior, an audit observes
problems — **an inventory maps the terrain.** What modules exist, who calls which interface and
under what observed contract, which behaviors are visibly relied on (each with evidence: a test,
a `file:line`, an output), what tests already cover the area, and — most valuable — what you
_cannot_ see from here. It observes and maps; it never judges (that's an audit) and never
prescribes (that's the change plan it feeds).

The format is frozen in the kit —
[`templates/inventory.md`](https://github.com/jcosta33/swarm-starter-kit/blob/main/templates/inventory.md).

**Write one before:** a major refactor or rewrite, a migration, a module split or subsystem
replacement, a wide dependency upgrade, or sending an agent into unfamiliar brownfield code.

**Skip it for:** a simple feature, a small fix, a single-file cleanup, test-only updates.

## Change plan — how the codebase changes

A change plan answers the question a spec deliberately doesn't:

|                       | Spec                            | Change plan                                     |
| --------------------- | ------------------------------- | ----------------------------------------------- |
| Answers               | What should the system do?      | How should the codebase change?                 |
| Behavior              | Defines new or changed behavior | Mostly preserves behavior while structure moves |
| Cut into tasks by     | requirement                     | wave                                            |
| Reviewer reads it for | acceptance criteria             | risk focus and what must not break              |

(This table lives only here — other pages link to it.)

The plan's `kind` names the transformation: refactor · rewrite · migration · dependency-upgrade ·
performance · test-infra · mechanical-cleanup · architecture-cleanup · schema-change. The kind
lives on the plan; the task packet keeps one shape regardless.

**Write one when** the work is primarily internal structure, spans modules, must preserve
behavior while touching risky code, changes a public interface, needs sequencing, splits across
several agents, or will land as a diff too large to interpret without a map.

**Skip it for** a small cleanup, a tiny rename, formatting, an obvious bug fix.

## Walking the template

The format is frozen in the kit —
[`templates/change-plan.md`](https://github.com/jcosta33/swarm-starter-kit/blob/main/templates/change-plan.md). The
load-bearing sections:

- **Baseline → Target state.** What the code does today (cite the inventory, don't re-derive
  it) and what it looks like after — including what explicitly stays unchanged. A reviewer who
  can't diff these two sections in their head can't judge the waves.
- **Behavioral preservation guarantees.** The heart of the plan: a table — `ID | Behavior |
Verify with` — of everything that must still behave exactly as before, each row with the same
  verification line a requirement gets.
- **Transformation waves.** The sequence. Each wave leaves the codebase green and names its
  verify step; where external consumers exist, a wave ships a bridge release rather than a flag
  day. A wave that can't state how it's verified isn't a wave yet — it's a hope.
- **Cutover conditions and Rollback criteria.** What must hold before the change counts as
  landed, and the observable conditions that send it back. Decided now, while nobody is
  defending a half-landed migration.
- **Task split.** One row per task: which wave, which guarantee and requirement IDs. Each task
  then runs isolated like any other — see [Running agents](07-running-agents.md).

## Enumerate what you preserve

The trap in "no behavior change" is Hyrum's Law: with enough users, **every observable behavior
of your system will be depended on by somebody** — including behavior you never promised.
Sort order of an unsorted endpoint, the exact text of an error message, timing someone's retry
loop calibrated against. So a change plan never gestures at "no behavior change"; it
_enumerates_ the behaviors it preserves, as guarantee rows.

Guarantee rows reuse the spec's own requirement IDs through the plan's `preserves:` frontmatter.
A guarantee with no spec ID to point at gets its own `PG-NNN` — and usually signals a spec
amendment is owed: you just found a behavior someone depends on that no spec records.

## How it reviews

Preservation guarantees review exactly like requirements. The review packet's **Change-plan
coverage** table gives each guarantee the same `ID | Result | Evidence | Human attention` row,
and "nothing broke" needs pasted output like any other Pass — see
[Reviewing output](08-reviewing-output.md). The plan's **Review focus** section is the
reviewer's starting exception list, written by the person who knew where the risk was before
the diff existed.

## Next

- [Creating tasks](06-creating-tasks.md) — a task may implement a spec, execute a change-plan
  wave, or both; its scope reads "implement or preserve".
- [Writing specs](04-writing-specs.md) — the behavior side of the division table.
- Deeper planning technique — equivalence checks beyond a green suite, behavior-delta tables
  for rewrites, baseline/target measurement for performance work — lives in the
  [`write-change-plan`](https://github.com/jcosta33/swarm-starter-kit/blob/main/.agents/skills/write-change-plan/SKILL.md)
  agent guide, shipped in the kit.
