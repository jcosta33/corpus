# Step bars — what good output looks like

*Works today — plain markdown plus your agent; no Swarm tooling required.*

Every step of the loop has a bar: a small set of **checkable boolean predicates** over the
step's **input artifact** and **output artifact**. A predicate either holds or it does not, and
it is decidable by reading the two files alone. **A single failing predicate fails the step.**

Bars exist because a well-formed file is not a well-performed step. A task packet can match
[the template](../../starter-kit/templates/task.md) perfectly and still pull a requirement its
spec never stated; a review packet can have every column filled and still rest on the agent's
own summary. The [checks catalogue](checks.md) covers format and hygiene; the bars grade the
**transformation between the files** — fidelity, honesty, and the unbroken chain from
requirement to result.

Two uses, one page: a reviewer applies a bar to a step's output — yours, a teammate's, an
agent's — and this repository applies the same bars to its own examples and fixtures when a
guide or template changes. Every predicate is a **checklist**-level rule: a scorer decides it
by reading; nothing here runs or enforces anything. Where a predicate is toolable, the line
says so and names the swarm-cli command.

## How to score a step

1. Read the step's input artifact and its output artifact.
2. Decide each predicate as a boolean, citing the span that decides it.
3. Re-check the cross-step predicates listed for that step.
4. Report the failing predicates. Any failing predicate fails the step.

Because every predicate is decided from the files alone, the score is reproducible by hand
today and automatable later without trusting the agent under test. The
[checks fixtures](../../checks/README.md) are pinned test data to score against.

## Pull — faithful capture

> The bar: the intake file is a faithful snapshot of what was actually asked — copied verbatim,
> fully attributed, free of interpretation. **Input:** the upstream source. **Output:** the
> intake file.

| # | Predicate | Holds when | Fails when |
|---|---|---|---|
| P1 | **Verbatim snapshot** | The body is the upstream content as written — copied, not retold. | The content is summarized, reordered, trimmed, or "cleaned up"; part of the source is silently dropped. |
| P2 | **Provenance present** | The frontmatter carries a real `source`, `url`, and `captured` date. | Any of the three is missing, or still a placeholder. |
| P3 | **No editorializing** | The capture adds no interpretation, opinion, priority call, or requirement of its own. | Commentary is woven into the source text, or the capture states something the source never said. |

The decisive comparison for P1 is source-minus-intake: any span present upstream but absent or
altered is a failure — an ugly, rambling ticket captured exactly is a *passing* intake. P3 cuts
the other way (intake-minus-source): a reworded ask or an added "this is really about X"
belongs in the spec, where it is visible as interpretation. Whether the request is clear or
worth doing is the Spec bar's problem.

## Spec — faithful interpretation

> The bar: every requirement is identifiable and checkable, every claim traces to a source or
> is marked a decision, every ambiguity is surfaced instead of silently resolved. **Input:**
> the intake file(s) and supporting documents. **Output:** the spec.

| # | Predicate | Holds when | Fails when |
|---|---|---|---|
| S1 | **Requirement form** | Every requirement has an `AC-NNN` id and a `Verify with:` line (or the structured-requirements equivalent under `format: sol`). | A requirement has no id, or no verification method. |
| S2 | **Stance preserved** | What a source asks for stays a requirement; what a source merely observes stays context. An observation becomes a requirement only by explicit restatement under its own AC id. | A source's stance is flipped — an observation silently acquires binding force, or an ask is demoted to background prose. |
| S3 | **Uncertainty surfaced** | Every ambiguity in the sources lands under Open questions or as a recorded interpretation; a spec with unresolved open questions not marked non-blocking is not `status: ready`. | An ambiguity is resolved silently, or left buried in prose where no one will answer it. |
| S4 | **Nothing invented as sourced** | Every requirement traces to a named source or is visibly an authoring decision; deliberate omissions land under "Dropped from sources". | A requirement asserts behavior no source asked for, reading as if the ticket demanded it. |

Why these carry weight: ambiguous or incomplete task input measurably degrades agent code
correctness [[ORCHID]](../research/sources.md#ORCHID)
[[HUMANEVALCOMM]](../research/sources.md#HUMANEVALCOMM), and models usually code anyway instead
of asking [[HUMANEVALCOMM]](../research/sources.md#HUMANEVALCOMM)
[[HILBENCH]](../research/sources.md#HILBENCH) — which is why S3 fails a spec for *burying* an
ambiguity even when every requirement is otherwise well-formed. The `Verify with:` line S1
demands is the highest-value line in the file: a runnable check outperforms prose plans as
task input (preliminary evidence) [[ORACLESWE]](../research/sources.md#ORACLESWE).

Not graded here: whether the requirements are *satisfiable*, and whether the eventual change
meets them — those surface at the Run and Review bars. The form half of S1 is toolable —
swarm-cli's `swarm spec check` flags a requirement with no
id or verification method; the fidelity half (S2–S4) needs the sources open beside the spec.
The conditional steps produce authored documents too: score an inventory or change plan with
these same predicates against its own template, reading "sources" as the codebase observed
(inventory) or the spec plus inventory (change plan).

## Task — faithful bounding

> The bar: the packet's scope is drawn entirely from its named sources, its boundaries are
> stated, and every scoped requirement has a check the agent can run. **Input:** the source
> spec (and change plan, if any). **Output:** the task packet.

| # | Predicate | Holds when | Fails when |
|---|---|---|---|
| T1 | **Scope drawn from the source** | Every requirement id in the packet's scope exists in the named spec or change plan. | The scope carries an id its sources never defined, or an id from a document the packet does not name. |
| T2 | **Boundaries declared** | "Do not change" is present and substantive — it names real areas the agent must leave alone. | The section is missing, empty, or boilerplate that bounds nothing. |
| T3 | **Checks mapped** | Every scoped requirement has a Verify item the agent can run (or an explicit manual check with its observation recorded), and every Verify item names a scoped requirement id. | A scoped requirement has nothing that checks it, or a Verify item checks nothing in scope. |

A packet that invents a requirement, omits its boundaries, or leaves a requirement uncheckable
hands the agent exactly the ambiguity the spec existed to remove — and preliminary evidence
places the handoff into the coding agent as the dominant multi-agent failure surface
[[PLANCODER]](../research/sources.md#PLANCODER). Not graded here: whether the agent honored
the packet — a perfect packet ignored at Run fails the Run bar, not this one.

## Run — honest record

> The bar: the agent's summary is an honest record — every changed file named, every check run
> with its real output pasted, every departure from scope declared. **Input:** the task packet
> and the diff. **Output:** the agent's run summary.

This bar does not grade the code; it grades the **record**, because the record is what Review
judges. An honest record of a failed run scores better here than a glossy record of a hidden
one.

| # | Predicate | Holds when | Fails when |
|---|---|---|---|
| R1 | **Changed files complete** | The summary names every file the diff touches. | The diff touches a file the summary omits — the run claims a smaller footprint than reality. |
| R2 | **Real output pasted** | Every Verify item in the packet was run, and the summary carries the command with its real output. | A check is skipped silently, or reported as a bare "tests passed" with no output — a claim without output counts as unverified. |
| R3 | **Out-of-scope edits declared** | Every edit outside the packet's scope or inside its "Do not change" areas is declared in the summary with a reason. | An out-of-bounds hunk goes unmentioned. |
| R4 | **Stuck means stop** | A requirement that could not be met as written is reported with why. | The agent improvised around the requirement and reported success. |

R1's decisive set is diff-minus-summary: a non-empty remainder is the dangerous direction —
understating the footprint hides edits from review. R3 does not forbid out-of-scope edits; it
forbids *silent* ones — declared, they become a Human attention row at Review.

## Review — evidence-backed judgment

> The bar: every scoped requirement has a coverage row, every result matches its evidence,
> every exception is routed to a human, the suggested decision follows the table, and the
> reviewer spot-checked at least one green row. **Input:** the source spec, the diff or PR,
> and the run summary. **Output:** the review packet.

| # | Predicate | Holds when | Fails when |
|---|---|---|---|
| V1 | **Coverage complete** | Every requirement in the task's scope has a row in the coverage table — plus one row per preservation guarantee when the task executes a change plan. | A scoped requirement has no row; it can neither pass nor route to a human. |
| V2 | **Empty evidence means Unverified** | Every Pass row carries pasted output, a CI link, or a named human's recorded observation (manual method); a row with an empty Evidence cell is recorded Unverified, never Pass. | A Pass stands on no evidence — "tests passed" with nothing under it is not evidence. |
| V3 | **Exceptions routed** | Every exception trigger present in the work has a Human attention entry (the trigger list is in the review template). | A triggering condition exists in the inputs with no entry routing it. |
| V4 | **Gate honest** | The packet's status and Suggested decision follow the table: no merge suggestion past a Fail or unrouted Unverified without a recorded waiver (who · which rows · why · expiry). | The decision contradicts the table — asserted past a Fail or an unrouted Unverified with no waiver on record. |
| V5 | **Spot-check recorded** | The reviewer re-checked at least one green row's evidence and the packet says so. | No spot-check is recorded — the table was rubber-stamped. |

Independence is the spine of V2–V4: results are judged against the spec, the diff, and the
pasted evidence — never against the run summary's self-assessment alone. Reviewers favor their
own and agent output without structure [[SELFPREFER]](../research/sources.md#SELFPREFER)
[[JUDGEBIAS]](../research/sources.md#JUDGEBIAS); V5 is the standing countermeasure. A Blocked
row is honest, not a defect — what V4 forbids is treating Blocked as Pass. Not graded here:
whether findings were saved and the board updated — that is the Close bar. Drafting the packet
and computing the gate is toolable — a future `swarm review` in swarm-cli.

## Close — durable memory

> The bar: everything durable the task discovered now lives as a finding, the workboard tells
> the truth about the new state, and nothing is left pending invisibly. **Input:** the finished
> task's record. **Output:** the workspace after close — `findings/`, `status.md`, any spec
> amendment.

| # | Predicate | Holds when | Fails when |
|---|---|---|---|
| C1 | **Durable discoveries became findings** | Every durable discovery in the task's record — a fact, a decision, a pattern, a gotcha — exists as a finding file. | A lesson that outlives the task survives only in a packet or a transcript, where the next session will never see it. |
| C2 | **Board updated** | `status.md` reflects the close: the task's state moved, the spec's state updated, and every "done" or "verified" claim on the board links its review packet. | The board still shows the task running, or carries a done claim with no packet behind it. |
| C3 | **Nothing pending** | No blocked question, open exception, or accepted-but-unapplied change is left dangling — each is resolved, or carried forward as a visible board item. | Close happens over a pending item that is now invisible to everyone. |

C1 cuts both ways: scan the record for discovery-shaped statements ("turns out…", "X breaks
when Y") and check each reached a finding — *and* check that what reached `findings/` is
durable; scratch notes saved as findings pollute the set the next session loads. Where review
feedback changed what a requirement should say, the spec is amended in place under its existing
AC id — an unamended spec the review contradicted is a C3 pending item. Not graded here: the
merge decision itself — that was the Review bar's gate; Close is graded on what the workspace
remembers afterwards.

## The cross-step predicates

Four predicates assert loop-wide invariants, scored wherever the relevant artifact appears.

| Predicate | What it asserts | Scored at |
|---|---|---|
| **Re-parses clean** | Every file a step writes still reads as its `type:` — frontmatter fields and required sections per its template, so a second reader reconstructs the same artifact. | Pull, Spec, Task, Review, Close |
| **Chain unbroken** | The requirement → task → review chain holds end to end: every scoped requirement reaches a review row, and every task scope item, verify item, and review row names a requirement that exists upstream. | Task, Run, Review |
| **Result consistent with evidence** | Every recorded result matches what its evidence actually shows: a Pass carries pasted output, a CI link, or a named human's recorded observation (manual method); an empty Evidence cell means Unverified, never Pass. | Run, Review |
| **Drift surfaced** | A mismatch between what the spec says and what was built is named somewhere visible — a coverage row, a Human attention entry, a board item — never silently passed. | Review, Close |

## Bars for the advanced lifecycle

Teams running the [nine-step lifecycle](advanced-lifecycle.md) explicitly on high-risk work
score the finer steps as follows; the six bars above keep applying at their loop positions
(Spec covers `author`–`improve`, Task covers `lower`–`decompose`, Run covers
`implement`–`verify`, Review covers `review`, Close covers `promote`). This section may use the
reference-tier names — the [glossary](glossary.md) maps them back.

- **`author`** — scored by the Spec bar against whichever document the step writes, each read
  against its own template.
- **`lint`** — every defect from the [checks catalogue](checks.md) present in the document is
  reported with its code and severity; every **blocking** defect is caught (partial recall on
  advisory checks is tolerable, a missed blocker is not); not one character of the document
  changes. Toolable: `swarm spec check`.
- **`improve`** — no edit changes what any requirement asks (actor, trigger, behavior,
  strength); no id, requirement, or `Verify with:` line is dropped or weakened; every edit is
  attributable to one of the [improve operations](advanced-lifecycle.md#the-improve-operations);
  every blocking defect from `lint` is repaired or explicitly carried forward; a
  meaning-changing edit escalates as an amendment, never lands silently as a repair.
- **`lower`** — every requirement survives into the structured form with its id, verification
  method, dependencies, and touchable files; no invented dependency; nothing is emitted while a
  blocking open question stands.
- **`decompose`** — parallel tasks have pairwise-disjoint written files or an explicit
  dependency serializes them; the partition respects dependency order, no cycles; every
  in-scope requirement is assigned to exactly one task; each task carries its requirements as
  stated, not paraphrased. When several agents run at once, any coordination record's owned
  paths are pairwise disjoint across workers, confirmed before anyone spawns. One platform
  carve-out: the same requirement may scope to N platform tasks when each verifies it on its
  own platform — it reads green at spec level only when every platform task shows Pass.
- **`implement`** — scored by the Run bar, sharpened by one scope predicate: the diff stays
  inside the task's affected areas, and the recorded changed-file set is never narrower than
  the diff.
- **`verify`** — every named verification method is run; every scoped requirement gets exactly
  one recorded result; a method that cannot run records **Blocked, never a silent Pass**; every
  result cites the command and its real output. `verify` gathers; `review` judges.
- **`review`** — scored by the Review bar, extended by the full result model: the lifecycle
  values applied wherever their condition holds, with their required fields — **Waived** (on
  Fail or Unverified only — who, why, expiry), **Stale** (on a prior Pass whose text or
  exercised code changed), **Contradicted** (two pieces of evidence disagree). The merge gate
  follows the rule in plain words: merge only when every requirement in scope shows Pass or a
  live Waived. An empty scope never passes by vacuity.
- **`promote`** — scored by the Close bar, sharpened by: every saved finding carries its
  provenance and its applies / does-not-apply limits; a finding that contradicts a requirement
  is surfaced for reconciliation, never silently outranks the spec; nothing ephemeral is saved
  as durable.

The four cross-step predicates apply unchanged — the chain simply gains links (requirement →
structured item → task → result → review row), and "chain unbroken" is scored across all of
them.

## Related

- [Basic workflow](../02-basic-workflow.md) — the loop these bars grade.
- [Checks](checks.md) — the format and hygiene catalogue the bars build on.
- [Templates](../../starter-kit/templates/) — the frozen artifact formats every bar reads against.
- [The advanced lifecycle](advanced-lifecycle.md) — the finer steps and the full result model.
