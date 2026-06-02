# The `lower` pass and the typed IR

> Authoritative source: 03-compiler-pipeline.md §11 (the `lower` pass) + §12 (the typed IR it emits). This is a reference projection; where it and the spec disagree, the spec governs.

`lower` is the fourth of the **nine passes** of the Swarm compiler pipeline (`author -> lint -> improve -> lower -> decompose -> implement -> verify -> review -> promote`). This page is the short reference view for that single pass and the **intermediate representation (IR)** it produces; the long-form contract is the spec.

Like every Swarm pass, `lower` has **no runtime**: it is a contract a human, an agent following a pass guide, or a future tool performs. The IR is specified as a versioned data contract — this repository ships **no emitter, no parser, and no validator** for it, and the only legal producer of an `.ir.json` file is a future compiler (§12.1, Invariant 1). `lower` is one of the four passes (`author`, `improve`, `lower`, `verify`) that ship **no stdlib pass guide** in v0.1.

## Where `lower` sits: the `LOWER` phase has two passes

`LOWER` is the **phase** that turns a normalized, approved spec into machine-shaped work. Two distinct **passes** occupy it:

- **`lower`** — SOL surface (`spec.swarm.md`) → IR obligation graph (`*.swarm.ir.json`).
- **`decompose`** — IR → task-sized work packets (`task.md`).

They are separate because they have different inputs, outputs, and failure modes; conflating them would mix graph construction with work partitioning. This page is about `lower` and the IR; `decompose` (which consumes the IR) is covered only where it bounds `lower`'s output.

Throughout `LOWER` the **distillation-loss discipline** (§24) is in force: lowering MUST preserve every obligation, modality, actor, trigger, response, constraint, invariant, verification binding, and the **authority** of each obligation (§22). Dropping any of these is a **distillation error** — a hard failure of the pass, not a lint warning to triage later (§11.4).

## What the `lower` pass does

`lower` consumes an approved `spec.swarm.md` and produces `*.swarm.ir.json` (the IR envelope of §12). It is **mostly deterministic**. The pass MUST perform, **in order** (§11.1):

1. **Assign IR node ids.** Each surface block (short per-type id, e.g. `AC-001`) becomes an IR node whose id MAY be namespaced as `REQ.<spec>.AC-001`. Surface ids remain stable; the namespaced form is IR-only and the surface id MUST be recoverable from it.
2. **Build typed edges.** Relationships are emitted as `edges[]` entries `{from, to, type, hard}`. Edges are the **single source of relationship truth** — a relationship MUST NOT be duplicated as a node scalar (§12.5.1).
3. **Normalize `verify_by`.** Each surface `VERIFY BY <type>:<adapter>:<artifact>[#selector]` clause becomes a normalized IR record `{type, adapter, ref, selector, gate}` (§15). The `<adapter>` is recorded as written; it resolves through AGENTS.md > Commands at `verify` time, **not** at lowering time.
4. **Emit the two derived graphs.** `lower` MUST emit (a) a **dependency DAG** from the `depends_on` edges and (b) a **write-surface conflict graph** from `WRITES`/`SURFACE` declarations and the `READS`/`WRITES` conflict rule (§11.5). These are the substrate the safe-parallelism predicate runs on (§18): `lower` *produces* them, `decompose` *consumes* them.

### Edge derivation detail (step 2)

The surface-clause → edge-type mapping `lower` applies:

| Surface input | Becomes |
|---|---|
| `DEPENDS ON` | a `depends_on` edge |
| `AFFECTS <node-id>` | an `affects` edge to that node |
| `AFFECTS <surface>` (a surface, not a node) | stays in the node's `affects` **scope set**; contributes `conflicts_with` edges per §18 — never an `affects` edge (§12.5.1) |
| `WRITES` overlap (two nodes share a write surface) | `conflicts_with` edges |
| each `VERIFY BY` | a `verified_by` edge |

### AND THE chaining (G3, R-CHAIN)

A `REQ` MAY chain obligations with `[AND THE <actor> <MODAL> <response>]*`. `lower` MUST split each chained clause into a **distinct IR obligation node**, one per `THE`/`AND THE` clause, each inheriting the parent's bindings unless overridden (§11.1.1).

- **Sub-id production:** the *n*-th clause (counting the leading `THE` as 1, each `AND THE` thereafter) lowers to IR node id `<surface-id>.<n>` — e.g. `AC-001.1`, `AC-001.2`.
- A surface `TRACE`/`VERDICT` targeting the parent id `AC-001` **distributes** over all split sub-obligations; the merge gate (§14.4) requires every split sub-obligation to carry a `PASS`/`WAIVED` verdict, inherited from the parent target or recorded per sub-id.
- **R-CHAIN warning:** when one block chains **more than two** obligations (three or more `THE …`/`AND THE …` clauses), `lower` MUST emit a `SOL-P004`-adjacent **warning** (bundled-obligation smell) suggesting `ATOMIZE` (§10). It MUST NOT be a hard error — chaining is permitted. Two chained clauses → no warning; a third trips it.

So a two-clause `REQ AC-001` lowers to `AC-001.1` and `AC-001.2`, both carrying the `verified_by` edge to the block's named test, with no warning.

### Lowering preserves obligations, bindings, and authority (§11.4)

- If lowering drops an obligation id, modality, actor, trigger, response, constraint, invariant, or verification binding, that is a **distillation error** (hard failure), not a deferrable lint warning.
- **Authority** (§22) MUST be carried onto each lowered node so a downstream conflict can be resolved by the two-axis source-authority rule **without re-reading the surface spec**.
- **Verification bindings** MUST survive lowering intact so `verify` has a `verified_by` edge for every required obligation. An obligation reaching `decompose` with no `verify_by` is a `SOL-V001`-class defect that `BIND` (§10) should have answered during `improve`.

## The gates bracketing `LOWER`

`LOWER` is bracketed by two **pipeline gates**. A gate is **not a transformation** — it transforms nothing and writes no artifact; it is a precondition predicate over already-emitted state. The pipeline MUST NOT advance the affected obligation past the gate while its predicate is unsatisfied. Both gates are **contracts checkable today by review and enforced by a future tool** — there is no runtime that runs them (Invariant 1). Neither gate is a new pass; both reuse the existing pass surface and the existing `SOL-<LAYER>NNN` namespace.

| Gate | Boundary | Predicate (MUST hold to advance) | Surfaced as | Carrier (manual today) |
|---|---|---|---|---|
| **CLARIFY gate** | `NORMALIZE` → `LOWER` (before `lower`) | No open `[blocking]` `QUESTION`, no blocking `SOL-M002`, no unresolved `SOL-P008` on an in-scope obligation | `SOL-O003` / `SOL-M002` / `SOL-P008` (existing codes) | `lint` (Skeptic, §9.4) |
| **COVERAGE gate** | `LOWER` → `EXECUTE` (after `decompose`, before `implement`) | Every obligation covered by exactly one `implement` packet; every TRACE/verdict target resolves | `SOL-O007` (uncovered), `SOL-O008` (double-owned), `SOL-M003` (orphan target) | `decompose` (Lead Engineer, §9.4) |

### The CLARIFY gate (pre-`lower`, R-CLARIFY-GATE)

`lower` MUST NOT proceed for any obligation while, for that obligation, any of these holds (§11.6.1):

- an unresolved `[blocking]` `QUESTION` (§6.5) `AFFECTS` it — answered, or downgraded to `[non-blocking]` with rationale, clears it;
- a blocking `SOL-M002` (contradiction) names it;
- an unresolved `SOL-P008` (uncaptured behavioral ambiguity) attaches to it.

A spec carrying any of these for an in-scope obligation is **not lowerable**; lowering past it would commit a guess as an obligation. This is the **named generalization** of R-BLOCKING-Q (§11.1.2): a `[blocking]` `QUESTION` still unresolved when it reaches `lower` halts lowering and emits the orchestration error `SOL-O003`; R-CLARIFY-GATE lifts that single rule into a three-condition checkpoint that *also* catches unresolved contradiction and uncaptured ambiguity. The codes are unchanged — a tripped gate surfaces as the **existing** code for the condition that tripped it; the gate aggregates them, it is not a new diagnostic.

**Gate vs improve-op (do not conflate):** the CLARIFY *gate* (this section) and the `CLARIFY` *improve operation* (§10.2, op 7) are distinct. The op is a **local edit** in `NORMALIZE` that lifts one buried prose ambiguity (`SOL-P008`) into an explicit interpretation or a `QUESTION`. The gate is the **pipeline checkpoint** at the `NORMALIZE`→`LOWER` boundary that refuses to advance while such a question is still open and blocking. The op *creates* the QUESTION; the gate *waits on* it.

*Rationale (cited).* The planner→coder handoff is the dominant failure surface in multi-agent code generation — the planner-coder gap "accounts for 75.3% of failures" [PLANCODER] — and agents do not reliably ask: with messy/ambiguous specs the best model solves only ~24% of tasks even when handed a tool to ask for help [HILBENCH]. Ambiguous descriptions drop Pass@1 by 25–30% and contradictory ones by up to 40% [AMBIGCODE], with >30% degradation across a 1,304-task benchmark [ORCHID]; conversely a clarify-then-generate loop raises GPT-4 Pass@1 from 70.96% to 80.80% [CLARIFYGPT].

### The COVERAGE gate (pre-`implement`, R-COVERAGE-GATE)

After `decompose` emits work packets and before any `implement` pass runs, this MUST hold over the lowered IR and the plan (§11.6.2):

1. **Total coverage.** Every lowered obligation node (`REQ`/`CONSTRAINT`/`INVARIANT`/`INTERFACE`, including each `AND THE`-split sub-obligation) is assigned to **exactly one `implement` packet** — none unassigned (uncovered) and none assigned to two (double-owned). (An obligation legitimately appears in its `implement`, `verify`, and `review` packets across passes; the count is per `implement` packet.)
2. **No orphan targets.** Every `verified_by` edge and every TRACE `implements`/`preserves` edge resolves to a real node id present in `nodes[]`. An unresolved target is an orphan and MUST NOT be admitted.

Codes: an uncovered obligation is **`SOL-O007`** (BLOCKING, resolves by `SCOPE`); a double-owned obligation is **`SOL-O008`**; an orphan TRACE/VERDICT target is **`SOL-M003`** (unbound-cross-reference, surfaced at `review`). The COVERAGE gate is the structural complement of the distillation-loss discipline: distillation-loss forbids *dropping* an obligation during lowering (§11.4); the COVERAGE gate forbids *stranding* one afterward. Together they make the lowered work a **bijection over obligations** — nothing lost in lowering, nothing left uncovered or pointed at a phantom.

## The typed IR `lower` emits

The **IR** is the typed, machine-checkable form of a SOL spec: a single JSON document re-expressing every obligation, relationship, diagnostic, and provenance fact in one `*.swarm.md` source. The surface is what a human authors; the IR is what a tool would reason over (§3 makes the surface-vs-IR split the master architectural distinction). A structured intermediate measurably beats free prose for downstream code work: structured chain-of-thought beats free-form by up to 13.79% Pass@1 [SCOT] — the empirical support for binding analysis to a typed IR. The file is named with the `.swarm.` infix: `auth-refresh.swarm.md` lowers to `auth-refresh.swarm.ir.json`.

### Top-level envelope: exactly five keys, in order

```json
{ "meta": {}, "nodes": [], "edges": [], "diagnostics": [], "provenance": {} }
```

| Key | JSON type | Cardinality | Purpose |
|---|---|---|---|
| `meta` | object | exactly 1 | Spec-level identity, language discriminator, version, status, ownership, imports |
| `nodes` | array | 0..n | The merged obligation records — one per surface block |
| `edges` | array | 0..n | The typed relationships — the single source of relationship truth |
| `diagnostics` | array | 0..n | SARIF-shaped lint/compile findings keyed to `SOL-<LAYER>NNN` |
| `provenance` | object | exactly 1 | Emission facts: source hash, compiler version, compile timestamp |

A conformant IR MUST contain all five keys; an empty spec still emits `nodes/edges/diagnostics: []` with fully-populated `meta` and `provenance`. **No additional top-level keys** are permitted in SOL/0.1, and unknown top-level keys MUST be rejected by a validating consumer. The IR layer is **snake_case throughout**: every UPPERCASE space-separated surface keyword maps to a snake_case field (`VERIFY BY`→`verify_by`, `DEPENDS ON`→`depends_on`, `OWNED BY`→`owner`, `WRITES`→`writes`, `READS`→`reads`, `AFFECTS`→`affects`). This casing split is normative and never mixed (§4).

### `nodes[]` — the merged obligation record (§12.4)

Each node is one **merged obligation record**: the fully normalized form of a single surface block — one of the **seven block types** (`REQ`, `CONSTRAINT`, `INVARIANT`, `INTERFACE`, `QUESTION`, `TRACE`, `VERDICT`). "Merged" means every clause, modal, scope set, proof binding, status, and source span is collected into one record; only its *relationships* live elsewhere, in `edges[]`.

Key node fields (full table in §12.4.1):

| Field | Required | Meaning |
|---|---|---|
| `id` | MUST | IR node id; MAY be `<KIND>.<spec>.<surface-id>`; surface id MUST be recoverable |
| `kind` | MUST | One of the 7 block types |
| `authority` | MUST for obligation kinds | Resolved domain-authority rank (`security`, `architecture`, `product`, …); MAY be `null` for QUESTION/TRACE |
| `modality` | MUST for REQ/CONSTRAINT/INVARIANT | One of the **5 modals** (below); `null` for INTERFACE/QUESTION/TRACE/VERDICT; mirrors `clauses.modal` |
| `clauses` | MUST | Structured control sentence (below) |
| `owner`, `risk` | SHOULD / MAY | Surface `OWNED BY`; `RISK` ∈ `low`/`medium`/`high`/`critical` |
| `reads`, `writes`, `affects` | MUST (MAY be empty) | The three **scope sets** (below) |
| `verify_by` | MUST (MAY be empty) | Normalized proof bindings (below) |
| `status` | MUST | The **core** verdict (4 values, below) |
| `lifecycle` | MUST (MAY be empty) | Subset of `{WAIVED, STALE, CONTRADICTED}` (the 3 lifecycle decorators) |
| `source` | MUST | `{file, line_start, line_end, content_hash}` — `content_hash` is what the drift model joins against (§16) |
| `provenance` | MUST (MAY be empty) | Per-node trail: prior verdicts, lowering ancestry, promotion lineage |

The **5 modals**: `MUST`, `MUST NOT`, `SHOULD`, `SHOULD NOT`, `MAY`.

**`clauses{}`** is the structured form of the control sentence; every key is present, an absent surface clause is `null`: `where` (`WHERE`), `while` (`WHILE`), `trigger` (`WHEN`/`IF [THEN]` → `{kw, expr}`), `subject` (`THE <actor>`), `modal`, `predicate` (`<response>`), and `timing`. **`timing` is RESERVED and MUST be `null` in SOL/0.1** — timing keywords (`WITHIN`/`BEFORE`/`UNTIL`/`IMMEDIATELY`/`EVENTUALLY`) are deferred to v0.2 (§4, §35). An INVARIANT lowers `<property> MUST|MUST NOT <hold>` into `subject` = property, `predicate` = held condition; an INTERFACE has no `subject`/`modal`/`predicate` and lowers `RETURNS`/`ACCEPTS`/`ERRORS` into pinned slots with the `contract` proof binding MUST-present in `verify_by`.

### `verify_by[]` — normalized proof bindings (the 9 proof types)

Each surface `VERIFY BY <type>:<adapter>:<artifact>[#selector]` normalizes to `{type, adapter, ref, selector, gate}`:

- **`type`** — one of the **9 closed proof types**: `static`, `test`, `contract`, `property`, `model`, `perf`, `security`, `manual`, `monitor` (§15). Test scope qualifiers (`test:unit`, `test:integration`, `test:e2e`) are carried verbatim in `type`.
- **`adapter`** — the AGENTS.md > Commands slot the type resolves through (a `cmd*` placeholder, e.g. `cmdTest`, `cmdLint`).
- **`ref`** — the project artifact (test file, contract file, model, checklist id).
- **`selector`** (MAY be `null`) — the `#selector` fragment (a specific case/property within `ref`).
- **`gate`** — `required` or `advisory`; `required` bindings participate in the merge gate (§14).

### `status` — the 7-value verdict model, carried as two orthogonal fields

In the IR the verdict is **two fields, never fused** (§12.4.4): `status` is the **core** verdict (one of four mutually-exclusive values) and `lifecycle[]` is the set of decorators in effect. This keeps the merge gate and verdict lint closed over the four core values while lifecycle state evolves independently. The **7 verdicts = 4 core + 3 lifecycle**:

| Value | Class | Meaning |
|---|---|---|
| `PASS` | core | A bound required proof ran and succeeded |
| `FAIL` | core | A bound proof ran and failed |
| `BLOCKED` | core | A bound proof could not run (missing prereq/tool/env) |
| `UNVERIFIED` | core | No acceptable proof bound, or none executed |
| `WAIVED` | lifecycle | A FAIL/UNVERIFIED accepted with authority + reason + expiry (§14) |
| `STALE` | lifecycle | A prior PASS whose evidence no longer matches current hashes (§16) |
| `CONTRADICTED` | lifecycle | Two proofs disagree, or trace/code disagrees with the obligation (§14, §16) |

A freshly-lowered, never-executed obligation has `status: UNVERIFIED` and an empty `lifecycle`. The canonical machine form is the VERDICT node the obligation is `verified_by` (§12.5).

### `edges[]` — the single source of relationship truth (the 7 edge types)

Every relationship between two nodes is a typed directed edge `{from, to, type, hard}` (`hard: true` = mandatory ordering / hard conflict / required proof; `false` = soft/advisory). The **7 closed edge types**:

| `type` | Derived from | Direction semantics |
|---|---|---|
| `depends_on` | `DEPENDS ON` | `from` requires `to` first (dependency DAG; merge ordering) |
| `blocks` | inverse / explicit | `from` blocks `to` (scheduling; blocking-QUESTION gating) |
| `conflicts_with` | write-surface overlap, `AFFECTS`, read/write overlap | symmetric conflict (write-conflict graph; safe-parallelism) |
| `verified_by` | `VERIFY BY` / VERDICT | obligation `from` verified by proof/verdict `to` |
| `affects` | `AFFECTS` | `from` impacts `to` (impact analysis; conflict derivation) |
| `implements` | TRACE `IMPLEMENTS` | trace `from` claims to implement obligation `to` |
| `preserves` | TRACE `PRESERVES` | trace `from` claims to preserve invariant `to` |

**Relationship truth vs scope sets (§12.5.1, normative).** A relationship MUST be represented **exactly once, as an edge**, never duplicated as a node scalar — there is *no* `depends_on`/`blocks`/`conflicts_with`/`verified_by`/`implements`/`preserves` field on a node, and a consumer MUST read `edges[]` rather than reconstruct relationships from node fields (rationale: a relationship stored twice can disagree; one representation cannot). This is distinct from the three **scope sets** (`reads`, `writes`, `affects`), which answer "what region does this one obligation touch?" — intrinsic node data, unordered sets of opaque SURFACE identifiers, correctly on the node. `lower` *derives* `conflicts_with` and `affects` edges *from* scope sets (e.g. two nodes that both `WRITES web.http.client` get a `conflicts_with` edge): the set is the raw declaration, the edge is the computed relationship, kept apart so the derivation is auditable and the two never silently disagree. Note the special case — `affects` exists *both* as a node scope set (declared impact region) *and* as an edge type (one resolved node→node consequence); not duplicates.

The three **scope sets** (§12.6): `reads` (read/read parallel-safe, read/write a conflict), `writes` (shared write surface ⇒ `conflicts_with` ⇒ not parallel-safe; names are SURFACE ids, **there is no `locks` field**), `affects` (indirect blast radius; contributes conflict edges, does not itself imply a write). All are opaque strings to the IR; resolution to files/globs is an orchestration concern (§18).

### `diagnostics[]` — SARIF-shaped findings

Each diagnostic is `{code, level, node|source, message}` (§8 owns the taxonomy, §12.8 the IR shape): `code` is a unified `SOL-<LAYER>NNN` where `<LAYER>` ∈ the **5 lint layers** `{S, P, M, V, O}`; `level` is the SARIF level `error`/`warning`/`note` (BLOCKING ⇒ `error`, ADVISORY ⇒ `warning`; `note` is informational / waiver-downgraded). **`off` is not a level** — a waiver demoting a code to `off` *suppresses* the diagnostic (omitted from `diagnostics[]` entirely). One of `node`/`source` MUST be present. Diagnostics live only in `diagnostics[]`; they are **never** folded into a node's `status` (status is the verdict, not the lint state).

### The three version fields (never merged) and `provenance`

The IR echoes three distinct version axes (§12.7), in three distinct fields a consumer MUST NOT collapse, merge, or infer one from another:

| Field | Axis | Answers | Example |
|---|---|---|---|
| `meta.language` | LANGUAGE | Which SOL+APS grammar / block set / modal set / lint codes apply | `SOL/0.1` |
| `meta.version` | SPEC CONTENT | Which revision of this spec's obligations | `0.1.0` |
| `provenance.compiler_version` | TOOL | Which emitter produced this IR | `null` in this repo (no shipped tool) |

`provenance` carries `{hash, compiler_version, compiled_at}`: `hash` is the whole-source digest at emission; `compiler_version` and `compiled_at` are **`null` in this repository** because no emitter ships (§12.1).

### Conformance

A document is a conformant SOL/0.1 IR iff it (§12.10): (1) has exactly the five top-level keys; (2) populates every field Appendix C marks `required` and supplies the documented `default` for any optional field omitted; (3) uses only the closed enumerations (**7 kinds, 5 modals, 9 proof types, 7 edge types, 7 verdict values**, the `SOL-<LAYER>NNN` code space); (4) represents every relationship once, as an edge; (5) keeps the three version fields distinct. The normative machine-readable form is the **JSON Schema in Appendix C**; where this prose and Appendix C disagree, Appendix C governs the shape and §12 governs the intent.

## Preserved / Dropped / Still-uncertain

**Preserved** (projected faithfully from §11 + §12):

- The two-pass structure of the `LOWER` phase (`lower` vs `decompose`) and the four ordered steps of `lower` (§11.1), including the surface→edge derivation map.
- AND THE chaining / G3 sub-id production (`<surface-id>.<n>`), verdict distribution over splits, and the R-CHAIN >2-clause `SOL-P004`-adjacent warning (§11.1.1).
- The distillation-loss discipline as it binds `lower`: authority and verification bindings carried intact, dropping ⇒ distillation error (§11.4).
- Both gates that bracket `LOWER` — CLARIFY (pre-`lower`, R-CLARIFY-GATE, generalizing R-BLOCKING-Q) and COVERAGE (pre-`implement`, R-COVERAGE-GATE) — their predicates, surfaced codes (`SOL-O003`/`SOL-M002`/`SOL-P008`; `SOL-O007`/`SOL-O008`/`SOL-M003`), carriers, gate-vs-improve-op distinction, and the cited rationale (§11.6).
- The full IR envelope and every sub-structure of §12: the five top-level keys, `nodes[]` field reference, `clauses{}` (incl. RESERVED `timing`), `verify_by[]` (9 proof types), the 7-value verdict split (4 core + 3 lifecycle), `edges[]` (7 edge types) with relationship-truth-vs-scope-sets, the three scope sets (no `locks`), `diagnostics[]` (5 lint layers), the three version fields, `provenance`, and conformance.

**Dropped** (out of scope here; the spec governs):

- The `decompose` pass internals — packet partitioning, owned-path projection, merge-order computation (§11.2) — covered only as the consumer that bounds `lower`'s output.
- The owned-path containment rule G7 / `SOL-O005` (§11.3) and the full `READS`/`WRITES` conflict predicate and `SURFACE` attribute mechanism (§11.5, §18) — `lower` only emits the edges; §18 owns the predicate.
- The plan (`*.swarm.plan.json`) and its envelope (§13), the merge gate and verification model in detail (§14, §15), and the drift model (§16) — referenced, not reproduced.
- Appendix C's literal JSON Schema and the pinned INTERFACE `clauses` slots — named as the governing shape, not transcribed.

**Still-uncertain** (left to the spec; not pinned here):

- Whether `lower` (one of the four passes with no v0.1 stdlib pass guide) gains one in a later framework release without a language-version change (§9.4, §25).
- The exact deterministic procedure a future emitter uses for each step (`lower` is "mostly deterministic"; the spec fixes the contract, not a reference algorithm).
- The minimal pinned shape of per-node `provenance[]` objects, deferred by §12.4.1 to the trace-provenance schema of §16.
