# The `decompose` pass

> Authoritative source: 03-compiler-pipeline.md §13 (the plan) + 05-orchestration.md §18 (the safe-parallelism predicate, §18.5/§18.5.1) and 03-compiler-pipeline.md §11.6.2 (the COVERAGE gate). This is a reference projection; where it and the spec disagree, the spec governs.

`decompose` is the fifth of the **nine passes** of the Swarm compiler pipeline (`author -> lint -> improve -> lower -> decompose -> implement -> verify -> review -> promote`). It shares the `LOWER` phase with `lower`: where `lower` builds the IR obligation graph, `decompose` partitions that graph into schedulable **work packets**. This page is the short reference view for that single pass; the long-form contract is the spec.

Like every Swarm pass, `decompose` has **no runtime**: it is a contract a human, an agent following a pass guide, or a future tool performs. The plan it produces is documented, versioned data — the shape a launcher would consume — never the output of a shipped emitter, and never a live scheduler (§13.1).

## What the pass does

The `decompose` pass **partitions the obligation graph into task-sized, write-disjoint work packets** with their assigned obligations, write surfaces, and verification bindings.

| Aspect | Value (from §9.3) |
|---|---|
| Phase(s) | **`LOWER`** (shared with `lower`) |
| Input artifact | `*.swarm.ir.json` (the IR obligation graph + the two derived graphs) |
| Output artifact | `task.md` work packets; and, named-as-contract, `*.swarm.plan.json` (`auth-refresh.swarm.ir.json` → `auth-refresh.swarm.plan.json`, §20) |
| Typical carrier profile (§27) | Lead Engineer |
| Lint layer (§8) | `SOL-O###` (orchestration: scope/ownership, e.g. `SOL-O005`, `SOL-O007`, `SOL-O008`) |

`decompose` is **one of the five passes that ship a stdlib pass guide in v0.1** (`lint`, `decompose`, `implement`, `review[profile: skeptic]`, `promote`; §9.4), carried by the Lead Engineer profile — it is the new machinery the legacy task-type model lacked, and it gates safe parallelism (§18).

`decompose` consumes the **IR, not the surface spec** (§9.3.1): it MUST operate on `*.swarm.ir.json` so that work-packet boundaries are computed from the typed graph (the two derived graphs of §18), not re-parsed from prose.

## The three obligations of the pass (§11.2)

The pass MUST:

1. **Partition obligations into work packets** — each packet carrying its assigned obligations, the constraints/invariants in force, the interfaces it touches, its write surfaces, and its verification bindings (the `task.md` contract, §21). Each produced `task.md` is "the lowered work packet for one pass" — the unit a single `implement` run owns.
2. **Project owned paths** for each packet as the file/glob projection of its assigned obligations' `WRITES` surfaces. Owned paths MUST be a subset of that union — the owned-path containment rule (§11.3, lint `SOL-O005`); an owned path touching a file outside any assigned obligation's declared write surface is the disjoint-scope violation.
3. **Compute merge order** from the `depends_on` edges (the dependency DAG) as a partial order, and **prove pairwise disjointness** of the owned paths of any two packets scheduled in parallel, using the write-surface conflict graph (§18).

`decompose` is bound by the distillation-loss discipline (§11.4, §24): the two `LOWER` passes MUST NOT drop an obligation id, modality, actor, trigger, response, constraint, invariant, verification binding, or authority. An obligation reaching `decompose` with no `verify_by` is a `SOL-V001`-class defect that `BIND` should have answered during `improve`.

## The plan: the schedulable projection of the IR (§13)

The **plan** takes the IR obligation graph and groups the work needed to discharge those obligations into work packets. Where the IR answers "what must hold and how do the obligations relate," the plan answers **"what units of work exist, in what order, on which surfaces, and which of them are safe to run at the same time."** The plan is the kernel's static coordination contract; it is *not* a running scheduler.

> **Contract, not executor (normative, §13.1).** Plan derivation *is* the `decompose` pass — there is no separate "planner" step. What is **out of the kernel** is the scheduler/harness that would execute the plan's packets live across agents (a launcher concern, §18.8). A conformant repository MUST include the documented plan schema and MUST frame any `.swarm.plan.json` as "the contract a future tool emits and a future launcher consumes," never as the output of a shipped tool (Principle 1).

### Top-level envelope (§13.3)

A SOL plan document MUST be a single JSON object with **exactly four keys**, reusing the IR's structural discipline:

| Key | JSON type | Cardinality | Purpose |
|---|---|---|---|
| `meta` | object | exactly 1 | Plan-level identity; the IR it derives from; the three distinct version fields. |
| `packets` | array of work-packet objects | 0..n | The schedulable work units (§13.5). |
| `edges` | array of edge objects | 0..n | Inter-packet relationships — the single-source-of-relationship-truth rule (same as the IR, §12.5.1). |
| `provenance` | object | exactly 1 | Emission facts; same shape as the IR's `provenance` (§12.9). |

Relationships between packets live **only** in `edges[]`, never duplicated as packet scalars; the per-packet `depends_on[]` array is the *declaration*, and `decompose` MUST also emit a matching `depends_on`-type edge so ordering is computable from the graph.

### `meta` (§13.4)

`meta` carries `id` (matches the source IR's `meta.id`), `derived_from` (path to the `*.swarm.ir.json`), `language` (`SOL/0.1`), `version` (the spec content version), and an optional `max_parallel` (`integer|null`). `max_parallel` is an **advisory parallelism hint for a launcher**; `null` = unspecified. The kernel computes *safety* (§13.6); concurrency *limits* are launcher policy, not kernel concern.

### `packets[]` — work packets (§13.5)

A **work packet** is one schedulable unit: a single pass applied (under an optional profile) to a selected set of obligations, with declared scope, ordering, and a merge-safety verdict.

| Field | Required | Meaning |
|---|---|---|
| `id` | MUST | Packet identifier, unique within the plan. |
| `pass` | MUST | One of the 9 passes (`author`, `lint`, `improve`, `lower`, `decompose`, `implement`, `verify`, `review`, `promote`). |
| `profile` | MAY | Heuristic profile parameterizing the pass (e.g. `skeptic` on `review`, `lead-engineer` on `decompose`); `null` = the pass's default. |
| `inputs` | MUST | The node ids (obligations/questions/traces) this packet consumes. |
| `outputs` | MUST | The artifacts it produces (code paths, `*.swarm.trace.md`, `review.md`, `finding.md`, …). |
| `writes` | MUST (MAY be empty) | The write SURFACE ids it modifies, derived from its inputs' `writes` scope sets. Every write surface here MUST be a subset of its obligations' declared `WRITES` (lint `SOL-O005`). |
| `reads` | MUST (MAY be empty) | The read surfaces it touches. |
| `depends_on` | MUST (MAY be empty) | Packet ids that MUST complete first — the merge-order partial order. Each entry MUST also appear as a `depends_on` edge. |
| `lane` | MAY | Suggested execution lane/worker label. Launcher hint only; absence does not affect safety. |
| `batch` | MAY | Suggested wave/round index for staged fan-out. Launcher hint only. |
| `merge_safe` | MUST | The kernel's verdict on whether the packet may run concurrently with its batch-mates (§13.6). |

Two normative subtractions resolve the source disagreement (G8, §13.2): there is **no `locks` field anywhere** (a lock group *is* a named write SURFACE, so lock-set analysis reduces to write-set analysis at surface granularity, §18.3); and the two competing payloads are reconciled into one record carrying both the *pass/profile* dimension and the *scope/dependency* dimension.

Inter-packet edges (§13.5.1) use the IR edge object `{from, to, type, hard}`. The relevant types are `depends_on` (ordering) and `conflicts_with` (a shared write surface, or a read/write conflict — §18). A `conflicts_with` edge to a batch-mate is what forces `merge_safe: false`.

## The safe-parallelism predicate (single, canonical — §18.5)

`merge_safe` is the surface of the kernel's **one** safe-parallelism predicate. Conformant tools and authors MUST use it verbatim; no alternative or relaxed predicate is permitted in v0.1.

> **Two work packets MAY run in parallel if and only if they are dependency-independent AND write-disjoint** — neither is reachable from the other in the dependency DAG, **and** they share no write surface and no shared boundary node (a shared `INTERFACE` referenced via `DEPENDS ON`/`AFFECTS`, or a shared `integration`/`shared` surface). Anything unscoped or shared **serializes by default**.

Formally (§18.5):

```text
parallel_safe(a, b)  ⇔
      ¬reachable_DAG(a, b) ∧ ¬reachable_DAG(b, a)   # dependency-independent
   ∧  writes(a) ∩ writes(b) = ∅                     # no shared write surface
   ∧  ¬shares_interface_or_migration(a, b)          # no shared boundary node
   ∧  ¬readwrite_conflict(a, b)                      # §18.6
```

Two defaults are normative and MUST NOT be weakened:

- **Unscoped serializes.** An obligation with no `WRITES` clause is treated as conflicting with *every* other obligation (its write set is unknown, hence assumed maximal) and MUST NOT be co-scheduled in a parallel batch — a missing scope is a hidden conflict, and the write side stays single-threaded by default (ADR 0010).
- **Shared serializes.** Any obligation touching a `shared` or `integration` SURFACE, or any `INTERFACE` referenced via `DEPENDS ON`/`AFFECTS`, MUST serialize (§18.3.1).

Read-only passes (`lint`, `review`, and any pass declaring only `READS`) MAY run broadly in parallel, because read/read never conflicts (§18.6).

`merge_safe` MUST be `false` if a packet has any unresolved `conflicts_with` edge to a batch-mate, or if any of its inputs is unscoped (empty `writes` where a write is implied). It is the kernel's *static* verdict: a launcher MAY further serialize for its own reasons but **MUST NOT parallelize two packets the plan marks unsafe.** The binding constraint on safe parallelism is review entropy and merge collisions, not agent count (§18).

### Surface comparison semantics (§18.5.1)

The predicate's set operations are defined **syntactically over path patterns**, never against a live filesystem (Principle 1):

- **Surface resolution.** Each `SURFACE` name resolves to its declared repo-relative path patterns; a raw path/glob in `WRITES`/`READS` is its own singleton pattern set. The glob dialect is a fixed POSIX-style subset: `**` matches any number of path segments, `*` matches exactly one segment (never `/`), `?` matches one character; every other character is literal.
- **Overlap** (`writes(a) ∩ writes(b) ≠ ∅`). Two surfaces overlap iff their pattern *languages* intersect (e.g. `src/auth/**` overlaps `src/auth/client.ts`). **String inequality does NOT imply disjointness.**
- **Subset** (OWNED ⊆ WRITES, `SOL-O005`). An owned pattern set is a subset of a `WRITES` pattern set iff every path it matches is also matched by the `WRITES` set, under the same semantics.
- **Boundary nodes** (`shares_interface_or_migration`). Two packets share a boundary node iff both reference the same `INTERFACE` id via `DEPENDS ON`/`AFFECTS` (an INTERFACE has no `WRITES`, so it enters the conflict graph only through these edges), or both write an `integration`/`shared` surface (the "migration node" case).

A conformant tool MUST compute overlap and subset over this pattern lattice, so that **two implementations derive the identical conflict graph from the same spec.**

## The COVERAGE gate (pre-`implement` — §11.6.2)

`decompose` is the carrier (manual today, tool-enforced later) of the **COVERAGE gate**, the checkpoint at the `LOWER → EXECUTE` boundary, after `decompose` emits packets and before any `implement` pass runs. A gate transforms nothing and writes no artifact: it is a precondition predicate over already-emitted state (the IR `nodes[]`/`edges[]` and the plan `packets[]`).

> **R-COVERAGE-GATE.** Before `implement`, for the lowered spec:
> 1. **Total coverage.** Every lowered obligation node (`REQ`/`CONSTRAINT`/`INVARIANT`/`INTERFACE`, including each `AND THE`-split sub-obligation, §11.1.1) is assigned to **exactly one `implement` packet** — none unassigned (uncovered), none assigned to two `implement` packets (double-owned). (An obligation legitimately recurs across its `implement`, `verify`, and `review` packets; the coverage count is *per `implement` packet*.)
> 2. **No orphan targets.** Every `verified_by` edge and every TRACE `implements`/`preserves` edge resolves to a real obligation node id present in `nodes[]`. A TRACE/VERDICT whose target id does not resolve is an orphan and MUST NOT be admitted.

The gate aggregates three existing codes:

| Condition | Code | Layer | Status | Resolves by |
|---|---|---|---|---|
| Obligation covered by no packet | `SOL-O007` (uncovered obligation) | ORCHESTRATION | **BLOCKING** | `SCOPE` — assign to a packet, or record as an explicit non-goal |
| Obligation assigned to two `implement` packets | `SOL-O008` (double-owned obligation) | ORCHESTRATION | **BLOCKING** | re-assign to exactly one packet |
| TRACE/VERDICT target id absent from `nodes[]` | `SOL-M003` (unbound-cross-reference) | SEMANTIC (surfaced at `review`) | — | bind the reference to a real node |

```text
COVERAGE gate (manual today, tool-enforced later):
  for each node N in IR.nodes where N.kind ∈ {REQ, CONSTRAINT, INVARIANT, INTERFACE} (incl. AND THE-split sub-obligations):
      count = | { p in plan.packets : p.pass == "implement" ∧ N.id in p.inputs } |
      count == 0  -> SOL-O007  (uncovered obligation)        [BLOCKING]
      count > 1   -> SOL-O008  (double-owned obligation)     [BLOCKING]
  for each verified_by / implements / preserves edge E:
      E.to NOT in IR.nodes  -> orphan target (SOL-M003 unbound-cross-reference, at review)
```

The COVERAGE gate is the **structural complement of distillation-loss** (§11.4, §24): distillation-loss forbids *dropping* an obligation during lowering; the COVERAGE gate forbids *stranding* one afterward. Together they make the lowered work a **bijection over obligations** — nothing lost in lowering, nothing left uncovered or pointed at a phantom.

## Worked fragment (§13.7)

For the `auth-refresh` spec (one `INTERFACE`, one `REQ` depending on it, one `INVARIANT`), a conformant plan groups the work into three packets:

- **WP-001** (`implement` the interface contract, `writes: api.auth.contract`, `batch: 0`) is **`merge_safe: false`** — it freezes a shared interface contract, so consumers serialize behind it.
- **WP-002** (`implement`, depends on WP-001, `writes: web.http.client`, `reads: api.auth.contract`, `batch: 1`) is **`merge_safe: true`** — write-disjoint from its batch-mates and depending only on a completed prior batch.
- **WP-003** (`verify`, depends on WP-002, `writes: web.http.tests`, `batch: 2`) is **`merge_safe: true`** for the same reasons.

The two `depends_on` packet arrays are mirrored as `depends_on` edges in `edges[]`. The full end-to-end pipeline for this spec is Appendix D; the formal plan JSON Schema is Appendix C.3.

## Conformance (§13.8)

A document is a conformant SOL/0.1 plan iff it: (1) has exactly the four top-level keys; (2) populates every required field (defaulting optional fields); (3) carries **no `locks` field anywhere**; (4) uses only the closed 9-pass set in `packets[].pass` and the closed edge-type set in `edges[]`; (5) represents inter-packet relationships **once**, as edges; (6) keeps the three version fields distinct. The plan schema is documented data only — no running emitter or scheduler ships.

## Preserved / Dropped / Still-uncertain

**Preserved** (projected faithfully from the named sections):

- The plan as `decompose`'s output and the kernel's static coordination contract: the four-key envelope (§13.3), `meta` with advisory `max_parallel` (§13.4), the work-packet record and its required/optional fields (§13.5), packet edges (§13.5.1), the worked auth-refresh fragment (§13.7), and the six-clause conformance test (§13.8) — including the no-`locks` and closed-pass-set rules (G8, §13.2).
- The single canonical safe-parallelism predicate verbatim, its formal four-conjunct form, and the two non-weakenable defaults (unscoped serializes, shared serializes) (§18.5); plus the syntactic surface-comparison semantics — glob dialect, pattern-language overlap/subset, boundary nodes (§18.5.1).
- The COVERAGE gate as `decompose`'s pre-`implement` checkpoint: total coverage, no orphan targets, the `SOL-O007`/`SOL-O008`/`SOL-M003` aggregation, BLOCKING status, and the bijection-with-distillation-loss framing (§11.6.2).
- The three pass obligations of §11.2 and the owned-path containment rule (§11.3, `SOL-O005`).

**Dropped** (out of scope for this single-pass projection; lives in the spec):

- The `lower` pass internals — IR node-id assignment, typed-edge construction, `verify_by` normalization, `AND THE` chaining (R-CHAIN), R-BLOCKING-Q (§11.1, §11.1.1, §11.1.2) — referenced only where `decompose` consumes their output.
- The CLARIFY gate (the *other* `LOWER` gate, at `NORMALIZE → LOWER`) and its empirical citations (§11.6.1, §11.6.3) — `decompose` carries the COVERAGE gate, not the CLARIFY gate.
- The full IR shape (§12), the broader orchestration scope split, SURFACE-attribute staleness treatment, the orchestration lint-code catalogue beyond what `decompose` raises, the coordination artifact `task-orchestration.md` (§19), and the out-of-kernel launcher concerns (§18.8) — referenced for orientation, not reproduced.
- The full nine-pass / seven-phase model, the improve operation set, verification, and review/promote — other passes' reference pages own those.

**Still-uncertain** (the spec governs; not pinned here):

- The exact decomposition *heuristic* — how a Lead Engineer partitions a given obligation graph into the smallest set of write-disjoint packets — is a pass-guide/profile concern (§26, §27), not fixed by the kernel; the kernel fixes only the predicate the partition must satisfy.
- How a launcher chooses `lane`, `batch`, and `max_parallel` values, and any live scheduling/replanning over the plan — explicitly out of the kernel (§13.1, §18.8).
- The formal plan JSON Schema is deferred to Appendix C.3 (and the full worked pipeline to Appendix D), outside the sections projected here.
