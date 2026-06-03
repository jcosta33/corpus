# The Golden Corpus

> Swarm's reference for the golden corpus: the inert fixture suite that pins the expected verdict of every pass on every fixture, so a conformant tool — or a human reviewer — can be checked against a known-correct oracle without trusting the tool under test.

Swarm is markdown-only, provider-neutral, and has **no runtime**. The golden corpus is **inert versioned data**: every fixture is a file, every expected verdict is recorded in that file's own header, and nothing here runs. The linter, the IR builder, the proof runner, and any future eval harness are all **contracts** a tool builds against; the corpus is the regression suite those contracts are measured against. Today a human validates a repository against it by hand; a future eval harness MAY automate the same checks — but the corpus itself never executes.

The corpus exists because a conformance suite needs both allowed and disallowed productions whose conformity is **known without the tool under test** — the same discipline compiler conformance suites (SuperTest, the OpenJDK TCK, WebAssembly's SpecTest) enforce. A fixture that compiles cleanly proves the tool accepts what it must; a fixture that is rejected with a specific `SOL-<LAYER>NNN` code proves the tool rejects what it must, and for the right reason. Because the expected verdict is pinned in data — not computed by the checker — the corpus can catch a checker that passes everything (or rejects everything) just as readily as one with a subtle bug.

## Where the corpus ships

The corpus ships in two locations, each serving a different audience:

| Location | Holds | Audience |
| --- | --- | --- |
| `kernel/.agents/conformance/fixtures/` | positive + negative fixtures, each carrying its expected verdict in its header | the conformance regression suite — the artifacts a checker (or hand-review) is run against |
| `docs/examples/` | the three pipeline-complete positive walkthroughs | human readers and authors learning the pipeline end to end |

The fixtures directory is the oracle; `docs/examples/` is the same three positive chains rendered as readable walkthroughs. The corpus is one of three inert-data artifacts that together encode the conformance contract: the [conformance manifest](../model/conformance.md) (`kernel/.agents/conformance/conformance.yaml`) encodes the schema and rules, the [lint catalogue](../language/errors.md) encodes every `SOL-<LAYER>NNN` code, and the golden corpus pins the verdicts. This page is the corpus's contract: what it must contain and what each fixture asserts.

## The three recurring domains

The corpus is built on three recurring problem domains, chosen because each cleanly carries a distinct, common authoring failure while remaining small enough to read in full:

- **auth-refresh** — silent token refresh on a 401, exercising surface and verification defects.
- **checkout** — cart submission, exercising obligation-bundling and write-surface-conflict defects.
- **payment-5xx** — payment-processor 5xx handling, exercising semantic-contradiction, orchestration, and vague-prose defects.

Each domain ships **positive** fixtures (must-compile) and **negative** fixtures (must-be-rejected). The positive variant of a domain always proves the very obligation its negative variant violates, so the pair brackets the defect from both sides.

## The full pipeline chain (every positive fixture)

Each positive domain fixture ships the **complete pipeline chain** — one file per stage — so the corpus exercises the whole `intent → promotion` arc rather than a single transformation. The chain is the data that the three `docs/examples/` walkthroughs render in prose.

```text
spec.swarm.md  →  expected obligations  →  task frame  →  trace  →  verdict  →  promotion
```

| Stage | Fixture file | Asserts |
| --- | --- | --- |
| source spec | `<domain>.swarm.md` | parses clean; only `MUST`-class modals; the `INVARIANT` is present |
| expected obligations | `<domain>.expected-obligations.md` | the obligation list a correct `build-ir` emits (ids, kinds, edges) |
| task frame | `<domain>.task.md` | assigned obligations, write surfaces, verification bindings |
| trace | `<domain>.swarm.trace.md` | `IMPLEMENTS` / `PRESERVES` / `PROOF` claims with content hashes |
| verdict | `<domain>.review.md` | per-obligation `VERDICT` blocks; the final verdict reaches the merge gate |
| promotion | `<domain>.finding.md` | the durable finding the `promote` pass produces |

The expected end-state verdict is recorded in the spec fixture's header, so the chain's correctness is known independent of any tool. The auth-refresh chain is documented stage-by-stage in [the compiler-pipeline reference](../model/compiler-pipeline.md) as the canonical worked example; that chain is exactly the positive auth-refresh fixture rendered for reading.

## Per-domain canonical defect classes

Each domain carries one canonical defect class (or a small cluster), encoded with unified `SOL-<LAYER>NNN` codes from the [lint catalogue](../language/errors.md). The negative fixture trips the defect; the positive fixture proves the obligation it violated.

> **Fixture notation.** Inside the fenced fixtures below, an inline `# … -> SOL-Xxxx` comment is **editorial commentary, not part of the SOL** — each fixture's expected verdict is pinned in its metadata header, never parsed from comment text — and the indentation of block-body lines is **non-semantic** (leading whitespace is permitted and stripped before parsing). Stripping the annotations and indentation yields the bare-header SOL the grammar generates.

### auth-refresh — dangling condition, SHOULD-without-BECAUSE, missing verification

| Variant | Construct | Expected |
| --- | --- | --- |
| negative | dangling condition (a trigger with no modal consequence) | reject, `SOL-S001` |
| negative | `SHOULD` with no `BECAUSE` / `EXCEPT` | reject, `SOL-S006` |
| negative | obligation with no `VERIFY BY` | reject, `SOL-V001` |
| positive | a bound `VERIFY BY test:…` proving a no-unbounded-retry `INVARIANT` | PASS |

```sol
# auth-refresh.swarm.md — NEGATIVE (expected: REJECTED)

REQ AC-001:
  WHEN the refresh token is expired      # dangling: trigger with no THE <actor> <MODAL> consequence
                                         # -> SOL-S001 (precondition with no actor clause)

REQ AC-002:
  WHEN a 401 is returned
  THE client SHOULD retry the request    # SHOULD with no BECAUSE/EXCEPT -> SOL-S006
  VERIFY BY test:cmdTest:auth.retry.test

REQ AC-003:
  WHEN the access token is refreshed
  THE client MUST persist the new token  # no VERIFY BY -> SOL-V001 (no verification path)
```

```sol
# auth-refresh.swarm.md — POSITIVE (expected: PASS)

INVARIANT I-001:
  the number of automatic refresh attempts per request MUST NOT exceed 1
  VERIFY BY test:cmdTest:auth.refresh.bounded.test#no_unbounded_retry

REQ AC-001:
  WHEN the access token is expired AND a request is attempted
  THE client MUST refresh the token once before retrying
  BECAUSE an unbounded retry loop drains the auth service
  VERIFY BY test:cmdTest:auth.refresh.test#single_attempt
```

### checkout — bundled obligation, write-surface conflict marked parallel

| Variant | Construct | Expected |
| --- | --- | --- |
| negative | one `REQ` bundling multiple obligations | reject, `SOL-P004`; `ATOMIZE` repair |
| negative | two obligations sharing a write surface, planned parallel | reject, `SOL-O001` |
| positive | the same obligations atomized + serialized on the shared surface | PASS |

```sol
# checkout.swarm.md — NEGATIVE (expected: REJECTED)

REQ AC-010:
  WHEN the cart is submitted
  THE service MUST validate the cart AND charge the card AND email the receipt
  # bundled/overloaded: 3 obligations in one -> SOL-P004 (ATOMIZE into AC-010/011/012)
  VERIFY BY test:cmdTest:checkout.test

REQ AC-011:
  THE service MUST write the order record
  WRITES db/orders
REQ AC-012:
  THE service MUST write the inventory ledger
  WRITES db/orders          # same write surface as AC-011, planned parallel -> SOL-O001
```

The positive variant splits `AC-010` into three single-obligation REQs and gives `AC-011` / `AC-012` disjoint write surfaces (or a `DEPENDS ON` edge serializing them), satisfying the safe-parallelism predicate: write surfaces planned to run in parallel must be pairwise disjoint.

### payment-5xx — blocking QUESTION, MUST-vs-MUST-NOT contradiction, high-risk word

| Variant | Construct | Expected |
| --- | --- | --- |
| negative | a `blocking` `QUESTION` still unresolved at lowering | reject, `SOL-O003` (orchestration; blocking QUESTION reaching lowering) |
| negative | `MUST` and `MUST NOT` on the same trigger | reject, `SOL-M002` (contradiction) |
| negative | "handle failures gracefully" with no observable criterion | reject, `SOL-P005` (vague-quality high-risk word) |
| positive | the QUESTION resolved, the contradiction deconflicted, the vague clause concretized | PASS |

```sol
# payment-5xx.swarm.md — NEGATIVE (expected: REJECTED)

QUESTION Q-001 [blocking]:
  Should a 503 from the processor be retried or surfaced to the user?
  AFFECTS AC-020                       # blocking QUESTION reaching lowering -> SOL-O003

REQ AC-020:
  WHEN the processor returns a 5xx
  THE service MUST retry the charge
  AND THE service MUST NOT retry the charge   # MUST vs MUST NOT, one trigger -> SOL-M002
  VERIFY BY test:cmdTest:payment.5xx.test

REQ AC-021:
  WHEN a payment fails
  THE service MUST handle failures gracefully  # "gracefully" -> SOL-P005 (no observable criterion)
  VERIFY BY test:cmdTest:payment.fail.test
```

The `SOL-<LAYER>NNN` codes span all five lint layers across the three domains — `SOL-S` (syntax), `SOL-P` (prose), `SOL-M` (semantic), `SOL-V` (verification), and `SOL-O` (orchestration) — so a tool that silently drops one layer fails some negative fixture and is caught.

## Task-file violation classes

Beyond the domain defects, the corpus ships fixtures for each task-file violation class — the structural and content rules a well-formed `task.md` satisfies — and one minimal SOL syntax negative per error-code family.

| Class | Fixture | Rule broken | Expected |
| --- | --- | --- | --- |
| empty paste | a `task.md` whose verification-output slots are bare | non-empty-paste content rule | FAIL |
| missing required verification slot | a `refactor` task with no `behaviour-preservation` evidence | the `refactor` required-suite | FAIL |
| illegal placeholder | a template introducing `{{cmdFrobnicate}}` without an ADR | the legal-placeholder rule | FAIL |
| missing `Commands` row | an `AGENTS.md` omitting `cmdFormat` | the required command-row set | FAIL |
| unresolved blocking QUESTION at close | `status: done` with an open blocking `QUESTION` | the no-open-critical content rule | FAIL |

The **empty-paste** class is the single most load-bearing fixture: it guards the hallucinated-completion hole. A `task.md` can present every required heading and still claim "tests passed" with no pasted output — schema-valid, but not verified. Every completion claim must bind to actual pasted proof output (or an honest `n/a` with a one-line reason), never a bare `[Paste output]` placeholder. This is the corpus's encoding of the principle that schema-valid output is **not** verification [[REFLEXION]](../research/sources.md#REFLEXION).

Additionally, the corpus ships at least one minimal syntax negative for **each `SOL-S` error family** (for example `SOL-S001` dangling condition, `SOL-S003` actor clause with no modal, `SOL-S005` prefix↔type mismatch, `SOL-S006` SHOULD-without-BECAUSE), so every error-code family has a guarding fixture and no family can silently regress.

## The labeled prose corpus and the precision/recall baseline

The `SOL-P` prose rules are heuristic, so they carry a measurable false-positive risk that the deterministic `SOL-S` family does not. To make that risk measurable, the corpus ships a **labeled good/bad prose fixture set** — inert data pairing each candidate span with its ground-truth label and expected code:

```yaml
# fixtures/prose/labels.yaml — labeled SOL-P corpus (inert data)
- id: P-001
  text: "THE service MUST handle failures gracefully"
  label: bad
  expect: SOL-P005      # high-risk word, no observable criterion
- id: P-002
  text: "THE service MUST return HTTP 503 within the 30s budget"
  label: good
  expect: none          # observable criterion present on the same line
```

The baseline targets are **design targets** for this curated, labeled set — chosen acceptance bars, not a measurement claimed of any deployed detector:

| Metric | Target | Meaning |
| --- | --- | --- |
| precision | ≥ 0.90 | of the spans a `SOL-P` rule flags, at least 90% are true defects (few false positives) |
| recall | ≥ 0.85 | of the true prose defects present, at least 85% are flagged (few misses) |

These bars are deliberately higher than what lightweight requirement-smell detection reaches on open field text (where reported figures sit nearer ~59% precision at ~82% recall, with wide variation). A curated, labeled gold corpus is a far more controlled setting than production prose, so the corpus must be **curated to that standard** rather than assuming a generic heuristic run reaches it. The labels let a future linter's precision and recall be computed against ground truth without ever running on production specs; until a linter exists, the labels document the intended accuracy bar.

Because the `SOL-P` grader is itself an LLM judge today — not a deterministic detector — the labeled set records an inter-annotator agreement floor (Cohen's κ ≥ 0.6), and the precision/recall targets are measured against that gold set, never asserted of an LLM grader at runtime. Single-judge scores are not internally reliable and should be replicated or aggregated. The deterministic `SOL-S` family is exempt from this caveat; only the heuristic `SOL-P` family carries it.

## The nine pass-output rubrics

The fixtures above pin *what a correct pipeline produces*. The **pass-output rubrics** are the scoring criteria the suite runs *against a candidate pass's actual output* to decide whether the agent-as-compiler performed the pass correctly. They exist because schema-validity is not correctness: a `task.md` can be perfectly well-formed and still drop an obligation; a `review.md` can carry every required `VERDICT` block and still be summary-only.

Each rubric is a small set of **checkable predicates** — boolean assertions over the pass's output, keyed to that pass's output contract — and **not** a Likert/quality score. A predicate either holds or does not; the suite reports the count of failing predicates per pass, and a single failing predicate fails the pass. Every predicate is decidable against the pass's input artifact plus its output artifact alone — no runtime, no tool under test is presumed. These rubrics grade **compiler behaviour** (did the transformation preserve the obligations, bindings, scopes, and verdicts it was contracted to preserve), not grammar — the `SOL-S` family and the task-file classes already cover grammar.

| Pass | Output-grading predicates (each MUST hold; any failing predicate fails the pass) |
| --- | --- |
| `author` | **Source fidelity:** every obligation traces to an upstream source span (chat, `research.md`, `audit.md`, `bug-report.md`) or is marked an explicit authoring decision — no behavior is invented and presented as sourced fact. **Stance preserved:** an observation-only source is re-stated as an obligation with its own id, modality, and binding, never borrowed as prose. **Uncertainty surfaced:** every behavioral ambiguity is lifted to a `QUESTION` or an explicit interpretation, not buried in prose. |
| `lint` | **Parse-validity decided:** every `SOL-S###` defect in the fixture is reported with its correct code and span; zero false "clean" on a known-defective fixture. **Blocking recall complete:** every blocking `SOL-S`, `SOL-M`, `SOL-V`, and blocking `SOL-P` defect is detected. **Non-mutating:** the spec text and semantics are byte-identical to the input (lint never rewrites). **Severity-correct:** each diagnostic's `severity` matches the catalogue. |
| `improve` | **Intent preserved:** no edit changes the actor, trigger/state, modality, response, non-goal, or interface of any obligation — the only approval-free semantic-diff class is pure normalization. **No distillation loss:** no obligation id, modality, or `VERIFY BY` binding is dropped or weakened. **Closed operation set:** every edit is attributable to one of the ten improve operations. **Lint answered, not masked:** each blocking lint code is resolved or carried forward, never silently deleted while its defect remains. **Escalation honored:** any intent-changing edit is routed to amendment, never applied as improve. |
| `lower` | **Total obligation preservation:** every obligation appears as an IR node with id, modality, actor, trigger, and response intact — a dropped obligation, modality, or binding is a hard fail. **Binding preservation:** every `VERIFY BY` binding survives onto its obligation. **Authority preserved:** each obligation's domain/artifact authority and `WRITES` / `READS` / `AFFECTS` scope survives. **Halts on blocker:** the pass produces NO IR while a blocking diagnostic or blocking `QUESTION` is unresolved (`SOL-O003`). **Edges sound:** every dependency edge derives from a `DEPENDS ON`, a shared interface, or a preserved constraint/invariant — no invented edge. |
| `decompose` | **Write-disjoint packets:** parallel task scopes have disjoint `WRITES` surfaces; a shared write surface with no serializing `DEPENDS ON` is `SOL-O001`. **Dependency-ordered:** the partition respects the obligation DAG and contains no cycle. **Total coverage:** every lowered obligation is assigned to exactly one task. **Ownership ⊆ writes:** each task's `OWNED` set is a subset of its declared `WRITES` (`SOL-O005`). **Context complete:** each `task.md` carries its exact assigned obligation blocks, preserved constraints/invariants, and verification bindings — not paraphrases. |
| `implement` | **Scope-faithful:** the diff changes only files inside the task's declared `WRITES` surface. **Obligation coverage:** the trace records an `IMPLEMENTS` claim for every assigned obligation and a `PRESERVES` claim for every preserved constraint/invariant. **Trace honesty:** each claim names the changed files and a `PROOF` artifact, and the claimed scope is not narrower than the diff actually touches. **No premature completion:** the trace does not assert an obligation done with no evidence gathered. |
| `verify` | **Proof-result completeness:** every required `VERIFY BY` binding has exactly one core verdict (`PASS` / `FAIL` / `BLOCKED` / `UNVERIFIED`); a required binding with no verdict is `SOL-V008`. **No unverifiable completion claim:** no obligation is reported satisfied on a binding that resolved to no proof artifact. **Adapter-resolved:** each binding's adapter resolved through `AGENTS.md > Commands`; an unresolved adapter yields `UNVERIFIED`, not a silent `PASS`. **Provenance recorded:** each verdict cites the proof type and artifact it ran. |
| `review` | **Verdict completeness:** every required obligation carries a `VERDICT` in `review.md`. **Verdict-correctness:** each core verdict matches the recorded evidence, and lifecycle decorators (`WAIVED` / `STALE` / `CONTRADICTED`) are applied where their condition holds. **Sceptical independence:** the review judges trace claims against the source spec, the diff, and the proof evidence — not against the trace's self-report; a verdict justified only by the implementer's summary is summary-only evidence and fails. **Unauthorized-change caught:** any diff hunk outside the `WRITES` surface is listed. **Gate computed:** the merge-gate result follows the merge-gate rule (all required verdicts `PASS` / `WAIVED`) and is not asserted past a `FAIL` / `UNVERIFIED`. |
| `promote` | **Nothing durable left task-local:** every discovery that outlives the task is promoted to a `finding.md` / `adr.md` / `audit.md` / spec amendment / `memory/INDEX.md` entry — a durable fact left only in the transcript fails. **Provenance complete:** each promoted artifact carries its mandatory provenance (source pass, evidence, applicability). **Stance & authority honored:** promotion routes through source authority — an observation promotes into intent by explicit re-statement, never by silently outranking an approved spec. **No spurious promotion:** task-local execution chatter is not promoted. |

### Cross-pass predicates scored at every stage

Four predicates are not owned by a single pass; the suite scores them wherever the relevant artifact appears, because they are the pipeline-wide correctness invariants the corpus exists to defend:

| Cross-pass predicate | What it asserts | Where the suite checks it |
| --- | --- | --- |
| **Parse-validity** | Every emitted SOL artifact re-parses clean against the grammar; no pass emits a structurally invalid block. | output of `author`, `improve`, `lower`, `decompose`, `promote` |
| **Trace-completeness** | The backward chain `obligation → task → trace → verdict` is unbroken: every assigned obligation reaches a verdict, and every verdict names an obligation that exists upstream. | output of `decompose`, `implement`, `verify`, `review` |
| **Verdict-correctness** | Each `VERDICT` is consistent with its evidence and the 7-value verdict model (4 core + 3 lifecycle decorators); no decorator is applied without its condition, no core verdict contradicts its proof result. | output of `verify`, `review` |
| **Drift-detection** | The pass classifies and surfaces each drift class — **stale spec drift** (approved obligation with no matching evidence), **undocumented implementation drift** (observed behavior with no approved obligation), **stale proof drift** (a passing binding that no longer exercises its obligation), and **memory drift** (a memory item contradicted by a higher-authority source) — rather than silently passing it. | output of `review`, `promote`; the stale-memory / unauthorized-change fixtures |

Drift-detection is defined without a runtime: drift is found by the `review` and `promote` passes comparing the approved obligation set against the recorded evidence and the higher-authority sources, never by observing a running system. A pass that fails to flag a drift class present in its fixture fails the drift-detection predicate even if every other predicate holds.

## Evaluation hygiene: held-out and mutated variants

A corpus that ships only the canonical fixtures has a latent failure of its own. Once the fixtures and their expected verdicts are public — and they are, in `kernel/.agents/conformance/fixtures/`, read by every adopter — an agent-as-compiler can be tuned (by training, by an over-stuffed instruction file, or simply by an author copying the corpus) to reproduce the **labels** without performing the **passes**. That is benchmark contamination: memorizing the evaluation data yields a recognized string, not a measurement of capability. The corpus must therefore be designed so that a passing verdict evidences a correctly executed pass, not a recognized label.

### Held-out and mutated-variant fixtures

Alongside each canonical domain fixture, the corpus ships at least one **held-out mutated variant** whose obligation text has been *regenerated* — paraphrased triggers and responses, renamed obligation ids, reordered blocks, substituted actors and interface names — while preserving the identical semantic structure, the identical canonical defect class, and the identical expected verdict. **The mutated variant is the conformance gate; the canonical fixture is the documented walkthrough.** A pass that resolves the canonical fixture but not its semantically equivalent mutated twin has memorized the label, not executed the transformation, and is scored a fail on that pass.

Concretely:

- The mutated variant **must not reuse the canonical label strings** (for example, not the literal `"THE service MUST handle failures gracefully"` of the `SOL-P005` prose fixture) yet **must still trip the same `SOL-<LAYER>NNN` code on the same construct**.
- The mutated variant's expected obligation list, trace, and `VERDICT` set are derived from its own text, never copied from the canonical fixture's `<domain>.expected-obligations.md`.
- A reviewer checks the variant by hand exactly as for the canonical fixture; a future eval harness MAY hold the mutated variants out of any material an agent-as-compiler is conditioned on. The corpus header **marks which fixtures are held-out** so a tool cannot silently fold them back into the visible set.

### Benchmark-hygiene practice

The corpus SHOULD follow established benchmark-building hygiene so its measurements are reproducible and auditable. Each fixture SHOULD record **documented provenance** (which domain, defect class, and which part of the conformance contract it exercises, and whether it is canonical or mutated); the corpus SHOULD carry an explicit **data-QA** note per fixture (the expected verdict was confirmed by a human, not assumed); and the fixtures SHOULD remain **open** for human inspection while the mutated-variant gate keeps openness from becoming a contamination vector. These are SHOULDs rather than MUSTs because Swarm has no runtime: the hygiene practice is a contract a future eval harness builds against, and until that harness exists the provenance and data-QA notes are documentation a manual reviewer reads.

## The research-fanout fixture

The corpus ships one fixture no per-domain chain covers: **research-fanout**, the corpus's only **fan-out provenance** fixture. It exercises the property that one research artefact MAY feed many downstream artefacts. A single `research.md` evidence source is promoted by the `author` pass into **multiple** `*.swarm.md` specs plus one `adr.md`, and every derived obligation cites the originating research span by its cross-file id.

**Provenance-id grammar.** A `research.md` tags citable evidence spans with ids `R-001`, `R-002`, … (the `R-` prefix marks an evidence span — parallel to the SOL block-id prefixes, but for a non-SOL evidence source). A derived obligation cites a span with the cross-file reference `research#R-NNN` in its `BECAUSE` clause — for example a derived `payments.swarm.md#AC-001` carrying `BECAUSE research#R-003`. This is a provenance reference, not a cross-spec obligation reference: `research` is an evidence-source stem (not a declared spec id) and `R-` is a provenance prefix (not a SOL block prefix). A citation whose span id is absent from the named `research.md`, or whose stem names no shipped source, is a provenance failure.

| Fixture file | Holds | Asserts |
| --- | --- | --- |
| `research-fanout/research.md` | one detached evidence source with citable spans `R-001…R-NNN` | observation/evidence stance — it promotes rather than governs |
| `research-fanout/<spec-a>.swarm.md` | derived obligations citing `research#R-…` | every obligation resolves to a research span; bare-header SOL parses clean |
| `research-fanout/<spec-b>.swarm.md` | further derived obligations citing the same source | the source feeds more than one spec (the fan-out property) |
| `research-fanout/<decision>.adr.md` | a decision whose constraints cite `research#R-…` | the source also feeds a decision artefact, not only specs |

**Expected verdict: PASS.** The pass criterion is provenance resolution, not a verdict on the research itself: every derived obligation in every `*.swarm.md` and every `adr.md` constraint must resolve backward to exactly one `research#R-NNN` span in the single `research.md`, and that backward chain must be unbroken (the trace-completeness and `author` source-fidelity predicates). The `research.md` artefact itself yields **no `VERDICT`** — it is an evidence source, not an obligation-bearing spec, so it carries no `REQ` / `CONSTRAINT` / `INVARIANT` to verify and never reaches the merge gate; only the obligations it was promoted into do. A fixture in which a derived obligation cites no source span, or cites a span absent from `research.md`, is the negative companion and must be rejected as a source-fidelity / provenance failure. As with every hygiene fixture, research-fanout also ships a held-out mutated variant — regenerated research-span text and obligation ids, the same fan-out topology, the same PASS verdict.

## Related references

- [The conformance contract](../model/conformance.md) — the `conformance.yaml` manifest (task-file schema, command rows, placeholder set, lint scheme, required-suite matrix) the corpus is checked against, and the conformance maturity ladder.
- [The lint catalogue](../language/errors.md) — every `SOL-<LAYER>NNN` code the negative fixtures trip, with its `{code, severity, layer, span, message, suggest}` record shape.
- [The flow graph](./flow-graph.md) — the canonical counts (7 blocks, 5 modals, 7 verdicts, 9 proof types, 7 phases / 9 passes, 10 improve operations, 5 lint layers) and the per-task-kind default-suite matrix the rubrics cite.
- [The compiler pipeline](../model/compiler-pipeline.md) — the auth-refresh chain rendered as the canonical stage-by-stage worked example; the positive auth-refresh fixture in readable form.
- [Drift and staleness](./drift-and-staleness.md) — the trace-provenance schema and the four staleness conditions the drift-detection cross-pass predicate scores.
- [Proof types and the `VERIFY BY` binding](./proof-types.md) — the nine closed proof types the verification bindings in every fixture draw from.
