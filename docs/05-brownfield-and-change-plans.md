# Brownfield work and change plans

_Works today — plain markdown plus your agent; no Corpus tooling required._

Two artifacts join the loop only when the work is structural or brownfield: refactors, rewrites,
migrations, dependency upgrades, performance and schema work, or any change to code nobody fully
remembers.

```text
Pull → (Inventory) → Spec → (Change Plan) → Task → Run → Review → Close
```

An **inventory** maps what exists before anyone draws new boundaries. A **change plan** says how
the codebase changes, safely. Most feature work needs neither. Writing them indiscriminately
recreates the ceremony the skip-paths avoid
[[HUMANEVALCOMM]](research/sources.md#HUMANEVALCOMM)
[[ASKORASSUME]](research/sources.md#ASKORASSUME).

Both artifacts — and every when-to-write threshold here — are conventions. Nothing enforces them,
and no controlled study of the documents exists. The rationale is design experience. Mature
migration ecosystems — codemod suites, framework upgrade guides, large-scale refactoring tools —
converge independently on the ingredients these templates carry: staged waves, before/after
examples, rollback and cutover guidance, an explicit list of what must not change.

## Inventory — map the terrain first

Brownfield change fails predictably when nobody reconstructs the current contract before moving
code. A spec describes desired behavior. An audit observes problems. **An inventory maps the
terrain.** What modules exist; who calls which interface and under what observed contract; which
behaviors are visibly relied on (each with evidence: a test, a `file:line`, an output); what tests
cover the area; and — most valuable — what you _cannot_ see from here. It observes and maps. It
never judges (that's an audit) and never prescribes (that's the change plan it feeds).

The format is frozen in the kit —
[`templates/inventory.md`](https://github.com/jcosta33/corpus-starter-kit/blob/main/templates/inventory.md).

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
lives on the plan. The task packet keeps one shape regardless.

**Write one when** the work is primarily internal structure, spans modules, preserves behavior
while touching risky code, changes a public interface, needs sequencing, splits across agents, or
will land as a diff too large to interpret without a map.

**Skip it for** a small cleanup, a tiny rename, formatting, an obvious bug fix.

## Walking the template

The format is frozen in the kit —
[`templates/change-plan.md`](https://github.com/jcosta33/corpus-starter-kit/blob/main/templates/change-plan.md). The
load-bearing sections:

- **Baseline → Target state.** What the code does today (cite the inventory, don't re-derive it)
  and what it looks like after, including what explicitly stays unchanged. A reviewer who can't
  diff these two in their head can't judge the waves.
- **Behavioral preservation guarantees.** The heart of the plan. A table — `ID | Behavior |
Verify with` — of everything that must still behave exactly as before. Each row carries the
  verification line a requirement gets.
- **Transformation waves.** The sequence. Each wave leaves the codebase green and names its verify
  step. Where external consumers exist, it ships a bridge release, not a flag day. A wave that can't
  say how it's verified isn't a wave yet — it's a hope.
- **Cutover conditions and Rollback criteria.** What must hold before the change counts as landed,
  and the observable conditions that send it back. Decide both now, while nobody is defending a
  half-landed migration.
- **Task split.** One row per task: which wave, which guarantee and requirement IDs. Each runs
  isolated like any other — see [Running agents](07-running-agents.md).

For a signature- or interface-level change, the **affected surfaces are the edit site plus every
caller of that signature.** Pull that fan-out from the inventory's `Current interfaces → Callers`
column; don't just list the files you touch. The template's Affected surfaces section prompts for
it. A convention — nothing counts the callers for you.

## Enumerate what you preserve

The trap in "no behavior change" is Hyrum's Law: with enough users, **every observable behavior of
your system will be depended on by somebody** — including behavior you never promised. The sort
order of an unsorted endpoint. The exact text of an error message. The timing a retry loop is
calibrated against. So a change plan never gestures at "no behavior change." It _enumerates_ what it
preserves, as guarantee rows.

Guarantee rows reuse the spec's own requirement IDs through the plan's `preserves:` frontmatter. A
guarantee with no spec ID to point at gets its own `PG-NNN`. That usually signals a spec amendment
is owed: you just found a depended-on behavior no spec records.

## How it reviews

Preservation guarantees review exactly like requirements. The review packet's **Change-plan
coverage** table gives each guarantee the same `ID | Result | Evidence | Human attention` row.
"Nothing broke" needs pasted output like any other Pass — see
[Reviewing output](08-reviewing-output.md). The plan's **Review focus** section is the reviewer's
starting exception list, written by whoever knew where the risk was before the diff existed.

**Platform hazards belong in Review focus too.** When the change leans on an external platform — a
quota, a permission boundary, a rate limit, a runtime or sandbox constraint — name those hazards
there. Bind the ones that must hold as preservation guarantees or spec requirements with a
runnable check (the runtime-proof evidence rule in [Reviewing output](08-reviewing-output.md), per
[ADR-0076](adrs/0076-worker-provenance-and-adoption-conventions.md)'s runtime-isolation caution).

## Weight review by risk — not by "greenfield vs brownfield"

It is tempting to review net-new code lightly and existing-code changes heavily. The discriminator
is not new-vs-old but **diffusion, churn, and change-type**:

- **Change-type.** Fault-fixes are disproportionately fault-inducing — roughly 40% of fault-fix
  changes introduce a new defect, against under ~4% for a one-line change
  [[PURUSHOTHAMAN05]](research/sources.md#PURUSHOTHAMAN05). A modification to working code earns more
  scrutiny than the same volume of isolated new code.
- **Diffusion.** A change's chance of inducing a failure rises with the files, modules, and
  subsystems it touches [[MOCKUS00]](research/sources.md#MOCKUS00). So concentrate on the
  **connective tissue** wiring new code into the existing system, not the new leaf code.
- **Churn.** Faults cluster where code changes often; change-count predicts faults better than size
  [[GRAVES00]](research/sources.md#GRAVES00). A high-churn locus is a standing risk.

A lighter lane for net-new code is reasonable **only when it is also small and low-diffusion**, and
even then demands genuine engagement on the risky seams — never a rubber stamp. Once size and total
changes are controlled, "new feature vs modification" has no significant effect on later defects
[[HINDLE11]](research/sources.md#HINDLE11). So **"it's greenfield" never justifies skipping review
on a large or high-diffusion change.** A checklist convention; nothing enforces it
([ADR-0094](adrs/0094-decomposition-and-risk-weighted-review.md)).

## Next

- [Creating tasks](06-creating-tasks.md) — a task may implement a spec, execute a change-plan wave,
  or both; its scope reads "implement or preserve".
- [Writing specs](04-writing-specs.md) — the behavior side of the division table.
- Deeper planning technique lives in the kit's
  [`write-change-plan`](https://github.com/jcosta33/corpus-starter-kit/blob/main/.agents/skills/write-change-plan/SKILL.md)
  agent guide: equivalence checks beyond a green suite, behavior-delta tables for rewrites,
  baseline/target measurement for performance work.
