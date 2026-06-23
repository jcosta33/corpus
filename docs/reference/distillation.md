# Distillation — the loss budget

_Advanced design note — internal rationale; not needed to use Corpus._

Every step of the loop compresses: a ticket becomes a spec, a spec becomes task packets, an
agent run becomes a review packet, a task becomes a finding. Compression is the point — but
some detail must never be compressed away. The **loss budget** names what may be dropped at
each crossing and what must survive every one of them.

The bright line: a compression that drops a requirement, its strength word, or its
`Verify with:` line has not summarized the spec — it has **changed what gets built**.

## What may be dropped

None of this carries binding force; each piece survives somewhere, linked rather than copied.

| Droppable                        | Where it survives instead                   |
| -------------------------------- | ------------------------------------------- |
| Commentary and narrative prose   | The source artifact, linked.                |
| Redundant restatements           | The single canonical statement.             |
| Rationale already recorded       | The ADR, finding, or research it came from. |
| Rejected options and digressions | The research file.                          |
| Step-by-step execution logs      | The task packet and the agent run summary.  |

## What must survive

Dropping or weakening any of these at any crossing is a distillation error — checklist level
(review inspects it); toolable for the structural cases — corpus-cli's `corpus check` can
flag a task packet missing a requirement ID its source spec declares.

| Must survive                                                    | Why                                                                            |
| --------------------------------------------------------------- | ------------------------------------------------------------------------------ |
| The requirement ID                                              | The traceability key; lose it and nothing maps back.                           |
| Its strength word (must / must not / should / should not / may) | The strength _is_ the binding force.                                           |
| Its `Verify with:` line                                         | A requirement with no verification path reviews as Unverified.                 |
| Its scope — owner, affected areas, do-not-change bounds         | Dropping a bound silently widens the work.                                     |
| Constraints, non-goals, unresolved open questions               | These limit the build; a dropped non-goal is scope creep with no fingerprints. |

## The per-boundary budget

| From               | To            | May drop                               | Must carry                                                                      |
| ------------------ | ------------- | -------------------------------------- | ------------------------------------------------------------------------------- |
| intake / ticket    | spec          | Upstream phrasing, duplicates          | Every asked-for behavior, or a line in **Dropped from sources** saying why not  |
| research           | spec          | Rejected options, low-confidence notes | Constraints found, unresolved ambiguity, decision-changing evidence             |
| audit              | spec          | Low-priority cleanup detail            | Observed risks that affect the target behavior                                  |
| bug report         | task packet   | Failed reproduction attempts           | The reliable reproduction, expected vs actual, root-cause evidence              |
| spec / change plan | task packet   | Rationale not needed to execute        | Requirement IDs, strength words, verify commands, non-goals, do-not-change list |
| agent run          | review packet | Implementation chatter                 | The claim, the pasted evidence, the result and its reason                       |
| task               | finding       | The execution log                      | The one durable claim and the evidence that grounds it                          |

The spec template's **Dropped from sources** section is this budget made visible: the author
records what the ticket asked for that the spec deliberately leaves out, so the loss is
auditable rather than accidental. An entry has to be specific enough to challenge — "dropped:
implementation details" is a category, not a record; "dropped: the CSV export option (only JSON
consumers exist)" is a decision someone can contest. That section is a convention — nothing in
this repo checks it.

## Forbidden compositions

The dangerous loss is not a missing detail — it is a silent change of **stance**: an
observation-only artifact read as if it were intent.

- An audit observes present state; it is not a spec.
- Research surveys options; it is not a decision.
- A bug report diagnoses; it is not authorization to fix things beyond the diagnosis.

The only way an observation becomes intent is an explicit authoring act: someone re-states it
as a requirement with its own ID, strength word, and `Verify with:` line, in a spec whose owner
approves the change ([source authority](source-authority.md) governs who). There is no path by
which audit prose becomes binding on its own — if a build appears to follow an audit the spec
contradicts, that is a conflict to route, not a shortcut to keep.

A worked example: an audit notes "the refresh endpoint currently accepts rotated tokens." That
is an observation. To affect the build, someone writes `C-014 — the refresh endpoint must not
accept a rotated token`, with a `Verify with:` line, into the auth spec — and the spec's owner
approves it. The observation stays labeled an observation until an author deliberately turns it
into intent; the stance survives the crossing because the crossing is explicit.

## Related

- [Source authority](source-authority.md) — the ranking that stops a lower artifact silently amending a higher one.
- [Checks](checks.md) — the structural checks that catch dropped IDs and missing verification lines.
- [Writing specs](../04-writing-specs.md) — where the **Dropped from sources** habit is taught.
