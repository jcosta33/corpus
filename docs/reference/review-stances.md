# Review stances

*Advanced design note — internal rationale; not needed to use Corpus.*

A **review stance** is an optional reading posture an agent or person adopts while performing a
step. It tilts attention — what the reader looks for, what evidence they demand, what they refuse
to accept — without changing what the step means or what its artifact looks like. Every step is
fully defined with no stance loaded; a stance sharpens it. A stance is a frame of mind, never a
character: it is named for what it refuses (`skeptic`, `auditor`), not for a persona to inhabit.
(The glossary's internal name for a stance is a *profile*.)

## The contract shape

A stance is written as seven sections, in this order:

| Section | Carries |
|---|---|
| Prevents | the one failure class this stance exists to catch — a single clause. |
| Default questions | the questions the stance forces while the step runs. |
| Required evidence | what the stance demands before it accepts a claim. |
| Refuses | the red-flag table: each row a pattern rejected on sight, paired with the action taken. |
| Self-review delta | what the agent additionally checks in its own work when the stance is active. |
| Applies | the work this stance fits. |
| Does-not-apply | the work it must not be loaded for — the guard against misapplication. |

The **Refuses** table is the heart: an enumerated refusal set, auditable row by row, rather than
one sweeping rule. The Skeptic's table, for instance, refuses "tests passed" with no command, exit
code, or output (record Unverified) and an implementer judging their own change (require an
independent reviewer).

The carrier is incidental: a stance may ship as a standalone guide or be folded into the guide for
the step it sharpens — what matters is that the seven sections are present and crisp. The kit's
guides carry the folded forms, and that fold is the **single source** for the stances that map to one
kind of work — architect, auditor, researcher, documentarian no longer ship a standalone copy
([ADR-0093](../adrs/0093-collapse-1to1-personas.md)). Only the **cross-cutting** stances — skeptic,
challenger, surveyor — also ship standalone as a `persona-*` skill in
[the swarm-skills catalog](https://github.com/jcosta33/swarm-skills), for loading a posture without
its host guide. This is a convention; nothing in this repo enforces it.

## The stances

### Architect — folded into the `write-spec` guide

Intent, not implementation. Prevents specs that smuggle in an algorithm where a requirement
belongs. Demands that every requirement be verifiable as written, and a survey of what already
exists before a new boundary is invented. Refuses a requirement no one could check, and a "how"
dressed as a "what". Ships inside the kit's `.agents/skills/write-spec/`.

### Skeptic — folded into the `review-output` guide

Refute by default: a completion claim is unproven until evidence forces the opposite conclusion.
Prevents rubber-stamped reviews. Demands re-run checks and pasted output; refuses a worker's
summary as proof, a green row with an empty evidence cell, and any softening of a finding to avoid
blocking. Ships inside the kit's `.agents/skills/review-output/`, and also standalone as
`persona-skeptic` in the swarm-skills catalog — and, turned on one's own diff before handoff, it is
the self-review posture the `implement-task` guide ends on (that yields fixes and a recorded critique,
never a self-issued result).

### Surveyor — standalone

Breadth-first inventory: what prevails across many examples — market, UX, and common-practice
surveys. Prevents pattern claims built on one example. Demands at least three named instances per
asserted pattern and a hard line between observation and claim; refuses inferring behavior from
marketing copy and closing on a recommendation no spec could transcribe. Its breadth discipline does
not fold cleanly into any single write-guide; ships standalone as `persona-surveyor` in
[the swarm-skills catalog](https://github.com/jcosta33/swarm-skills).

### Challenger — standalone

Pressure-test a live proposal *before* it is committed. Prevents building on an unexamined assumption,
or dismissing the rejected option as a strawman. Demands that every challenge ground in an external
referent — a counterexample, a runnable check, a cited source, an observable consequence — never
unaided second-guessing, and that the discarded alternative be steelmanned before the chosen one is
attacked; refuses re-deciding the proposal here (pressure the idea; the call is a separate step). It
precedes any single artifact, so it folds into no one guide; ships standalone as `persona-challenger`
in [the swarm-skills catalog](https://github.com/jcosta33/swarm-skills).

### Auditor — folded into the `write-audit` guide

Observation, not prescription. Prevents audits that editorialize or quietly fix. Demands a
file-and-line reference per finding and severity calibrated by blast radius, not a flat list;
refuses prescribing fixes inline and asserting a structural claim nobody grepped for. Ships inside
the kit's `write-audit`.

### Researcher — folded into the `write-research` guide

Depth inquiry against primary sources, committing to no decision. Prevents research that hardens
into a recommendation or lets a claim outrun its evidence. Demands checkable primary sources and a
visible seam between what was observed and what is asserted; refuses citing a blog post without its
primary source. Ships inside the kit's `write-research`.

### Documentarian — folded into the documentation guide

Human-facing docs for a reader with one question who has not read the code. Prevents docs that
drift from the system they describe. Demands one documentation frame held throughout, every example
run as written, and every behavior claim traceable to source; refuses hedging ("should", "might")
where the system has one actual behavior. Ships with the catalog's `write-documentation`.

## Judge independence

When a review result is rendered by a model's *judgment* — rather than read off a deterministic
check — three rules apply. They exist because the failure modes are measured, not assumed. These
are checklist rules: the reviewer inspects who rendered each judgment; nothing enforces them.

1. **Implementer ≠ reviewer.** An evaluator scores its own output higher than it merits, and the
   bias grows with its ability to recognize that output as its own
   [[SELFPREFER]](../research/sources.md#SELFPREFER). The agent that made the change does not judge
   the change. A deterministic check the implementer runs is fine — the check is the judge, not the
   implementer.
2. **No shared lineage.** A judge that shares model lineage with the generator inflates its own
   kin [[CORRELATED]](../research/sources.md#CORRELATED). Use an unrelated model or a human.
3. **Dual judges at high risk.** Judge bias is directional and predictable — toward the earlier,
   the longer, and the more familiar-styled answer
   [[JUDGEBIAS]](../research/sources.md#JUDGEBIAS) — so a single judgment is not reliable enough
   alone where the stakes are high. For security-sensitive or otherwise high-risk requirements, use
   two independent judges (two unrelated models, or a model plus a human). If they disagree, the
   result is Contradicted and follows the
   [contradiction handling in the advanced lifecycle](advanced-lifecycle.md#when-evidence-disagrees-contradicted).

The shape of all three: when the oracle is a model, name it, isolate it, and double it where the
risk is highest.

## Distinct lenses, not a repeated read

When more than one reviewer runs, give each a **different aim** rather than the same pass twice:
correctness · maintainability/design · security+reproduction. Most of what review catches is the
maintainability/design layer tests cannot see, so that lens earns a dedicated reviewer
([reviewing output](../08-reviewing-output.md), ADR-0095). The default is two independent,
distinct-lens reviewers; add a third for a high-risk or high-diffusion change. The stances above are
the lenses — assign the Skeptic to correctness, an Auditor-eyed reviewer to maintainability, and so
on; this is checklist-level — nothing enforces the count or the assignment.

## Related

- [Advanced lifecycle](advanced-lifecycle.md) — the steps these stances sharpen, the full
  review-result model, and contradiction handling.
- [Reviewing output](../08-reviewing-output.md) — the review packet the Skeptic stance fills.
- [Agent guides](agent-guides.md) — the guide model the folded stances live inside.
- The kit guides themselves:
  [`.agents/skills/`](https://github.com/jcosta33/swarm-starter-kit/tree/main/.agents/skills)
  in the swarm-starter-kit repo; the standalone stances:
  [the swarm-skills catalog](https://github.com/jcosta33/swarm-skills).
