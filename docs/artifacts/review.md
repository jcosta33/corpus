# The `review.md` artifact

`review.md` is the verdict record of the Swarm obligation graph: the working artifact that renders one typed `VERDICT` per required proof binding and decides, for a whole change set, whether the merge gate opens. It is the single place in the framework where the question "did this actually get done?" is answered, and it is the artifact the `promote` pass reads before any change advances.

## Purpose and epistemic stance

A review asserts **adjudication**: it compares the implementation claims recorded in a `trace.md` against the obligations those claims purport to satisfy, weighs them against the recorded verification evidence, and records the verdict. Its epistemic stance is *judgment* — the durable outcome of weighing evidence against intent — not intent itself and not raw observation.

Three discipline lines define what `review.md` is and is not:

- **A `VERDICT` is a SOL block, never a file.** The kernel ships **no** `verdict.md`, and no tool may emit one. A verdict is the *output* of the review pass — exactly as a result lives inside its run and never as a free-standing file — so its only home is a `VERDICT` block inside `review.md`. A repository that records verdicts in a standalone `verdict.md` is non-conformant. The reference documentation of the `VERDICT` block and the verdict taxonomy is documentation, not a copyable template.
- **A review MUST NOT carry its own obligation blocks.** It adjudicates obligations; it does not author them. A `review.md` MUST NOT contain `REQ`, `CONSTRAINT`, `INVARIANT`, or `INTERFACE` blocks of its own intent. If review uncovers a gap in what *should* have been required, that discovery is queued for promotion into a spec via the `author` pass — it does not become an obligation by being written down in the review.
- **A review judges; it does not implement and it does not amend.** A `VERDICT` may falsify an obligation (record `FAIL`), but it MUST NOT silently rewrite the obligation's intent to make a change pass. Where two proofs disagree, the review records `CONTRADICTED` and routes to reconciliation rather than picking the convenient result. Reconciliation that changes intent is an `author`-pass act, not a review act.

## Filename and placement

`review.md` is a **working artifact**: its filename MUST NOT carry the `.swarm.` infix and uses a plain `.md` extension. The infix is the sole discriminator a conformant tool uses to decide what to parse or emit:

| Class | Rule | This artifact |
| --- | --- | --- |
| Compiler-visible | filename carries the `.swarm.` infix before its final extension (e.g. `auth.swarm.md`, `auth.swarm.ir.json`); parsed or emitted by the compiler against the SOL grammar or the IR/plan schemas | not this artifact |
| Working artifact | filename has **no** `.swarm.` infix and uses plain `.md`; governed by an artifact contract, not the SOL grammar, though it MAY embed SOL blocks (here, `VERDICT`) as quoted data | **`review.md`** |

The only human-authored `.swarm.` artifact is the source spec, `*.swarm.md`; emitted compiler artifacts carry the `*.swarm.*` shape (e.g. `*.swarm.ir.json`, `*.swarm.trace.md`). A review is neither — it is hand- or agent-populated structured markdown that *quotes* `VERDICT` blocks as data.

In an adopted project's `.swarm/` workspace, `review.md` lives under **`generated/`** — specifically `.swarm/generated/reviews/` — because a review is derived execution material, recreatable from the sources and the recorded evidence, and compacted into `.swarm/ledger/` on completion. It is **not** a source artifact: nothing under `.swarm/sources/` (the desired-truth obligation store) is a review, and nothing under `.swarm/memory/` (durable recall) is a review. The companion observed-state satisfaction report it informs lives under `.swarm/status/`; the review that produced the judgment stays in `generated/`.

## Required sections and fields, in order

A conformant `review.md` MUST carry YAML frontmatter and the following sections, in this order.

### Frontmatter contract

| Field | Meaning |
| --- | --- |
| `type` | `review` (names the artifact class). |
| `id` | the review's stable id (e.g. `{slug}-review`). |
| `source_trace` | the `trace.md` whose claims this review adjudicates. |
| `source_spec` | the `*.swarm.md` source whose obligations are being judged. |
| `reviewed_output` | the output / change set under review. |
| `pass` | `review`. |
| `profile` | the heuristic profile applied to the pass (e.g. `skeptic`). |
| `created` | creation timestamp. |

### Required sections

| Section | What it means |
| --- | --- |
| `## Claimed coverage` | Which trace step claims which obligation, with the evidence ref it claims. One row per claim — this is what the per-obligation verdicts adjudicate against. |
| `## Per-obligation verdicts` | One `VERDICT` block per judged obligation (one per required `VERIFY BY` binding), using the canonical verdict line plus `REASON` and one or more `EVIDENCE` clauses. |
| `## Obligation-verdict matrix` | A compact table of every judged obligation: id → core verdict → lifecycle → evidence checked. |
| `## Constraint and invariant verdicts` | The same verdict grammar and matrix, for `C-` / `I-` (and `IF-`) surface ids. |
| `## Unauthorized changes` | Every change not traceable to an authorizing obligation, with its "authorized by" id (`AC`/`C`/`I`/`IF` id, or `none`), judged `allowed` / `suspect` / `reject`. |
| `## Final verdict` | The change-set merge-gate result: `PASS` or `BLOCKED`. |
| `## Promotion queue` | Items to promote, with target + status. |

### The verdict vocabulary the blocks record

A verdict is **exactly seven values**, partitioned into two disjoint roles. A verdict carries exactly **one CORE** value and **zero or more LIFECYCLE** decorators.

The **four CORE run results** are mutually exclusive — one bound proof, one run, lands in exactly one:

| CORE | Meaning |
| --- | --- |
| `PASS` | A bound proof ran and its result satisfies the obligation. |
| `FAIL` | A bound proof ran and its result contradicts the obligation. |
| `BLOCKED` | A bound proof could not run (missing prerequisite, tool, adapter, environment, or fixture). The truth is *unknown*, not false. |
| `UNVERIFIED` | No acceptable proof was bound, or a binding exists but no run was attempted. |

`BLOCKED` and `UNVERIFIED` MUST NOT be conflated — `BLOCKED` is an environment fix, `UNVERIFIED` is a binding/execution gap — and a reviewer who cannot tell which applies MUST record `UNVERIFIED` (the weaker, more honest claim).

The **three LIFECYCLE decorators** annotate a core value with a governance fact arising after or around the run:

| LIFECYCLE | Decorates | Mandatory fields |
| --- | --- | --- |
| `WAIVED` | `FAIL` or `UNVERIFIED` only | authority, reason, expiry |
| `STALE` | a prior `PASS` only | prior-verdict ref, changed-surface |
| `CONTRADICTED` | any core value | two conflicting evidence refs |

`WAIVED` MUST decorate only `FAIL`/`UNVERIFIED` (there is no reason to waive a `PASS`); `STALE` MUST decorate only a prior `PASS` (a `FAIL`/`BLOCKED`/`UNVERIFIED` was never trusted, so it cannot go stale); `CONTRADICTED` MAY decorate any core, because contradiction is a relationship between *two* evidence sources. There are **no permanent waivers**: a `WAIVED` carries a mandatory expiry and auto-expires on the next source-hash change of the waived obligation, reverting to its underlying blocking core value.

### The verdict line grammar

```
VERDICT <id>: <CORE> [(<lifecycle> by <authority>: <reason>[; <fields>])]
REASON <why this core verdict>
EVIDENCE <proof artifact / output reference>
```

`<id>` reuses the judged obligation's surface id (`AC-001`, `C-001`, `I-001`, `IF-001`). The block carries one `REASON` line and one or more `EVIDENCE` lines. A `QUESTION` is never judged; a `TRACE` is the *input* to judgment; a `VERDICT` *is* the recorded judgment.

### The merge gate (the one normative predicate)

The **`## Final verdict`** section records the merge gate — the single predicate that decides promotion, evaluated over every required obligation (`REQ`, `CONSTRAINT`, `INVARIANT`, `INTERFACE` in scope) and its required `VERIFY BY` bindings.

> **Merge gate.** A change set MAY be promoted **if and only if**, for **every required `VERIFY BY` binding** of every required obligation, the binding's latest verdict is `PASS` or `WAIVED`, **and none** is `STALE`, `CONTRADICTED`, `FAIL`, `BLOCKED`, or `UNVERIFIED`.

There is **one `VERDICT` per required binding**: an obligation with three required bindings contributes three verdicts, and all must pass-or-waive. The node-level status is the aggregate over an obligation's bindings (blocking if any binding blocks, else `PASS`). Per-value disposition:

| Latest verdict | Disposition |
| --- | --- |
| `PASS` (no lifecycle) | **Passes** the gate. |
| `WAIVED` (on `FAIL`/`UNVERIFIED`, fields valid, not expired) | **Passes** the gate. |
| `FAIL` | Blocks. Fix code or amend the obligation. |
| `BLOCKED` | Blocks. Fix the environment/adapter, then re-run. |
| `UNVERIFIED` | Blocks. Bind a proof and run it, or `WAIVE`. |
| `PASS (STALE)` | Blocks. Forces a reconcile against the changed surface. |
| any `(CONTRADICTED)` | Blocks. Routes to review with the stronger oracle authoritative. |

Because everything Swarm ships is markdown with **no runtime**, this gate is a contract a deterministic check OUTSIDE the model enforces when one exists (a CI gate, a PreToolUse hook, or a merge-blocking status) and is **manual today**. The contract MUST NOT be described as automatically enforced.

### The verdict-hygiene lint floor

Three diagnostics in the `SOL-V` (VERIFICATION) lint layer keep a `review.md` well-formed. Each is enforced by hand or via the lint pass today, with a deterministic home in a `review.md` schema validator when a harness exists:

| Code | Severity | Condition |
| --- | --- | --- |
| `SOL-V005` | BLOCKING | core is not one of `PASS`/`FAIL`/`BLOCKED`/`UNVERIFIED`, or a lifecycle decorator is missing its mandatory fields. |
| `SOL-V007` | BLOCKING | `WAIVED` decorates a `PASS`/`BLOCKED`, or `STALE` decorates anything other than a prior `PASS`. |
| `SOL-V008` | BLOCKING | a required obligation has no `VERDICT` at the merge gate (counts as `UNVERIFIED`). |

What a review MUST reject as a non-proof (never `PASS`): schema-valid output (shape is not truth), "tests passed" with no command / exit-code / output, and a `manual` verdict with no recorded reasoning.

## Copyable template

The copyable skeleton is `starter-kit/.agents/templates/review.md`. That template is the starting point you copy and fill; **this page is its contract** — it states what each section means and which rules a built `review.md` MUST satisfy. A built review MUST NOT leave a `VERDICT` core or a lifecycle field as a `{{...}}` placeholder; an empty status cell in a built matrix is treated as `UNVERIFIED`.

## Related

- [docs/passes/review.md](../passes/review.md) — the `review` pass that produces this artifact, including the `CONTRADICTED` resolution protocol and the model-judge discipline.
- [docs/passes/verify.md](../passes/verify.md) — the pass that records the verification evidence the verdicts adjudicate.
- [docs/passes/promote.md](../passes/promote.md) — the pass that consumes the merge-gate result and advances a passing change set.
- [docs/artifacts/trace.md](./trace.md) — the implementation-claims artifact whose claims a review adjudicates (the `source_trace`).
- [docs/artifacts/spec.md](./spec.md) — the source spec whose obligations a review judges (the `source_spec`).
- [docs/adrs/0035-seven-value-verdict-model.md](../adrs/0035-seven-value-verdict-model.md) — the decision establishing the 4-core + 3-lifecycle verdict taxonomy and the merge-gate predicate.
- [docs/model/source-artifacts.md](../model/source-artifacts.md) — the `.swarm.` infix partition and the tiered artifact set this artifact sits in.
