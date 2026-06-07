# `status` — the observed-state read-model

A **status** artifact records whether the code currently *satisfies* a spec and where it has *drifted* from it. For exactly one `*.swarm.md` source spec it projects, per obligation, the latest judged verdict, the obligations that have gone stale or contradicted, and which obligations carry a passing proof. It is the persisted read-model the merge gate and the drift check consult — never a second place where intent is authored. Among the obligations it is the observed-state mirror of the spec's desired-state: the spec says what the code must do; the status says what the code is observed to do *right now*.

Swarm ships **no runtime** (see the [artifacts README](README.md)). Every verdict, hash, and coverage figure a status carries is a content-hash *contract* a future tool computes; today the status is rebuilt by a human or an agent following the verify, review, and promote step guides, reading from the trace record and the review verdicts.

## Purpose & epistemic stance

A status asserts one kind of knowledge: **observed satisfaction over time**. Its stance is **derived projection** — it states, for each obligation, the *latest* verdict that some review step already rendered, plus the drift the staleness rule already detected. It discovers nothing new and decides nothing new: it is downstream of every fact it carries.

The workspace deliberately separates **desired state** from **observed state** as two distinct artifacts so neither corrupts the other. A `spec.swarm.md` is the desired truth — the obligations the author step committed, immutable as intent until an explicit amendment moves it. Whether the codebase currently meets that intent is a different, time-varying fact, and it MUST NOT be recorded by editing the spec. A spec that were continuously annotated with pass/fail marks and drift notes would (a) churn the obligation source-hash on every verification cycle — falsely tripping the staleness rule for obligations whose *intent* never moved — and (b) blur the source-authority line by letting observed reality masquerade as authored intent. The status artifact exists to absorb that observed, time-varying fact so the spec can stay a stable statement of intent beside it.

What a status MUST NOT do:

- **It MUST NOT redefine intent.** A status MUST NOT introduce, modify, weaken, or strengthen any `REQ`, `CONSTRAINT`, `INVARIANT`, or `INTERFACE`. The only authoritative source of intent is the `spec.swarm.md` it observes. A status may *falsify* an assumption — surfacing a `CONTRADICTED` or a stale binding that routes an amendment back to the spec — but it does not author the amendment, and it never rewrites the obligation it observes.
- **It MUST NOT re-judge.** A status records the *latest* verdict per obligation; it does not re-evaluate the oracle, re-run a proof, or override a review. Each row mirrors a verdict that a `review.md` already rendered. The status is the projection the merge gate is evaluated *over*, not a re-computation of the gate.
- **It MUST NOT be the only home of any fact.** A status is rebuildable from the spec, the trace-provenance schema, and the review verdict record. Every row it carries traces back to a verdict block and a recorded proof. A fact that exists only in the status — never written to a trace or a review — is a defect: the status would then be authoring, not observing.
- **It MUST NOT be hand-edited as intent.** It is regenerated or updated by the verify, review, and promote steps; a human or agent may rewrite it from the upstream record, but never to inject a verdict no proof produced or to silence a drift the staleness rule fired.

This stance is held by the source-authority discipline, not by a runtime tool: a conformant repository MUST NOT ship a tool whose job is to police whether a status has overstepped into authoring.

## Filename & placement

A status is a **working artifact**, not a Swarm-format source. Swarm partitions every Swarm-tracked file by whether its name carries the literal `.swarm.` infix before the final extension:

- The human-authored, Swarm-format spec is `*.swarm.md` — the only hand-written file that carries the infix.
- Emitted, contract-shaped outputs are `*.swarm.*` (e.g. `*.swarm.ir.json`, `*.swarm.trace.md`).
- Working artifacts governed by an artifact contract rather than the SOL grammar are plain `.md` with **no** `.swarm.` infix.

A status is the latter: it is named `*.status.md` (plain `.md`, no `.swarm.` infix). It MUST NOT be named `*.swarm.md` — that would mark an observation as a Swarm-format source spec and is a placement defect, exactly the corruption the desired/observed split exists to prevent.

In an adopted project, a status is **observed state**, distinct from both the desired sources and the recreatable execution packets. In a **code repo** this read-model is the spec repo's lightweight coverage record (the PR's CI + review approval being the per-change verdict it aggregates); a structured `*.status.md` is the contract shape that read-model satisfies when one is kept:

- A status asserts no durable intent, so it is **not** a committed source-doc (the spec it observes lives in its feature folder as `specs/<feature>/spec.swarm.md`).
- It projects the verdicts a `review.md` renders, but it is not itself one of the recreatable execution packets (tasks, traces, reviews) — it accumulates the *latest* verdict per obligation across passes.
- Its name mirrors the spec it observes: a status is the observed-state twin of the one spec whose satisfaction it projects.

A status observes **exactly one** spec. It is neither a durable source-doc (it asserts no durable intent) nor a one-step execution packet (it accumulates the *latest* verdict per obligation across passes).

A status has **no copyable template among the starter-kit artifact skeletons**: unlike an audit, a finding, or a task, you do not start one from a blank skeleton you fill in. It is generated — emitted and updated from the trace and review record by the verify, review, and promote steps. The shape below is its contract; the values are observed, never authored.

## Required sections / fields, in order

### Frontmatter contract

YAML frontmatter delimited by `---`, with at minimum:

| Field | Meaning |
| --- | --- |
| `type: status` | Names the artifact class. Required. |
| `id` | A stable slug identifying this status (conventionally `{{slug}}-status`). Required. |
| `spec` | The `spec.swarm.md` id this status observes — the one spec whose satisfaction it projects (e.g. `{{spec-id}}.swarm.md`). Required. |
| `updated` | Freshness: the timestamp of the last regeneration. Required — a stale `updated` is itself a signal that observation has fallen behind change. |

### Body sections, in order

| Section | Required content | Stance rule |
| --- | --- | --- |
| `# Status: <title>` + provenance note | The title, then a one-line reminder that this file is regenerated by the verify / review / promote steps from the trace and review record — never hand-authored as intent — and that the authoritative obligations live in the spec it observes. | Sets the reader's frame; the note is part of the contract. |
| `## Obligation status` | One row per obligation, carrying the **latest** verdict: a core value (`PASS` / `FAIL` / `BLOCKED` / `UNVERIFIED`), the lifecycle decorator if any (`WAIVED` / `STALE` / `CONTRADICTED`, or `—`), and the proof/evidence reference that justifies it. | Mirrors the obligation-verdict matrix. It records the latest judgment; it does not re-judge. |
| `## Drift` | One row per obligation whose latest verdict carries a `STALE` or `CONTRADICTED` decorator, with the staleness reason and the prior-verdict reference. | The persisted output of the staleness rule. A `STALE` row cites the changed `WRITES`/exercised-`READS` surface or rebound adapter that triggered it; a `CONTRADICTED` row cites its two conflicting evidence references. |
| `## Coverage` | One row per obligation marking whether it is covered — its latest verdict is `PASS` with no blocking lifecycle decorator — and the bound proof reference. Aggregate coverage and the drift-coverage metric MAY be summarized here. | Carries the denominator for the drift-coverage metric (`STALE` obligations / required obligations). |

Two consistency rules bind the body to the verdict and drift models:

- The `## Obligation status` rows MUST be the **latest** verdict per obligation, consistent with the merge-gate predicate: an obligation passes the gate iff its row is `PASS` or `WAIVED` and no required row is `STALE` / `CONTRADICTED` / `FAIL` / `BLOCKED` / `UNVERIFIED`. The status does not evaluate the gate; it is the projection the gate reads. A reader (or a future deterministic check outside the model) evaluates the gate by scanning these rows rather than re-reading every review.
- A `STALE` or `CONTRADICTED` row in `## Drift` MUST carry the same mandatory fields its source verdict block carries: a `STALE` row needs its prior-verdict reference and the changed surface (a declared write surface, or a `READS` surface that lay on the proof's evidence path, or a rebound adapter); a `CONTRADICTED` row needs its two conflicting evidence references. A drift row without its grounding reference is an ungrounded, fact-shaped claim — a defect.

A `STALE` row blocks the merge gate and forces an explicit **3-way reconcile**: re-run the proof (intent and code still agree), amend or supersede the obligation (intent changed — routed to the spec, never silently re-blessed), or fix the code (intent stands, code drifted). The status surfaces the stale binding; it does not choose the resolution. Re-stamping a recorded hash without a genuine re-run is forbidden — it manufactures a false `PASS`.

### Observed shape

The contract shape a regenerating step emits (values observed, never authored):

```markdown
---
type: status
id: {{slug}}-status
spec: {{spec-id}}.swarm.md
updated: {{updatedAt}}
---

# Status: {{title}}

Observed satisfaction of `sources/specs/{{ctx}}/{{slug}}.swarm.md`.
Regenerated by the verify / review / promote steps — never hand-authored as
intent. The authoritative obligations live in the spec; this file records only
the latest observed verdict, drift, and coverage.

## Obligation status

| ID     | Core verdict                       | Lifecycle                         | Evidence / proof ref |
| ------ | ---------------------------------- | --------------------------------- | -------------------- |
| AC-001 | PASS / FAIL / BLOCKED / UNVERIFIED | — / WAIVED / STALE / CONTRADICTED |                      |
| C-001  |                                    | —                                 |                      |
| I-001  |                                    | —                                 |                      |
| IF-001 |                                    | —                                 |                      |

## Drift

| ID | Lifecycle            | Reason (changed surface / adapter / conflicting refs) | Prior-verdict ref |
| -- | -------------------- | ----------------------------------------------------- | ----------------- |
|    | STALE / CONTRADICTED |                                                       |                   |

## Coverage

| ID     | Covered (latest = PASS, no blocking lifecycle) | Bound proof |
| ------ | ---------------------------------------------- | ----------- |
| AC-001 | yes / no                                       |             |

<!-- drift_coverage = (count latest-verdict STALE) / (count required obligations) -->
```

## Copyable template

**There is no copyable skeleton for this artifact.** A status is not started from a blank template you fill in — it is *generated* and *updated* from upstream records (the trace provenance and the review verdicts) by the verify, review, and promote steps, and its name mirrors the spec it observes (`<ctx>/<slug>.status.md`). The observed shape above is the **contract** every generated status MUST satisfy; this page is that contract. Do not hand-author a status as intent, and do not introduce a `*.status.swarm.md` form — the status is observed state, never a Swarm-format source.

## Related

- [`spec.md`](spec.md) — the desired-state source a status observes; the only authoritative home of the obligations a status projects, and the artifact a status MUST NOT redefine.
- [`trace.md`](trace.md) — the implementation-claim artifact whose recorded provenance hashes feed the drift detection a status surfaces; a status row is always downstream of a trace.
- [`review.md`](review.md) — the artifact that renders the authoritative verdicts; a status projects the *latest* of these per obligation. There is no separate `verdict` artifact — the review records the judgment, the status records its latest projection.
- [The `verify` step](../passes/verify.md) — re-runs the bound proofs and recomputes staleness; one of the steps that regenerates a status.
- [The `review` step](../passes/review.md) — emits the verdicts a status mirrors.
- [The `promote` step](../passes/promote.md) — routes a falsified assumption (a `CONTRADICTED` or persistent `STALE`) toward an amendment and updates the status accordingly.
- [The workspace layout](../model/workspace.md) — the `sources/` / `generated/` / `status/` split this artifact sits in, and the desired-state/observed-state separation it embodies.
- [Source artifacts and the `.swarm.` infix partition](../model/source-artifacts.md) — the full artifact set and the two-class partition that places a status among working artifacts.
