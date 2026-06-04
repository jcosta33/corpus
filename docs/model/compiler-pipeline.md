# The Compiler Pipeline

> Swarm's reference for the compiler pipeline: the end-to-end journey from human intent to durable memory, the seven-layer architecture it flows through, and the two-level phase/pass model that schedules it.

Swarm models the journey from a human-authored specification to a promoted, verified change as a **compiler pipeline**. Nothing here is shipped code: there is no runtime that runs these passes (Invariant 1). Every pass, gate, and emitter named below is a **contract** — checkable today by a human or agent following a written pass guide, and enforced by a future tool. A conformant repository MUST frame any emitted artifact (IR, plan) as "the contract a future tool emits," never as the output of shipped tooling.

This document keeps the counts, the closed sets, and the normative rules exact. It states the reasoning behind a rule inline as design rationale where that grounding is load-bearing.

---

## 0. The thesis: spec-as-code with verifiable output

Swarm treats a **specification as source code** and a **fleet of agents as the compiler**. Human intent is written as a controlled-markdown specification; that specification is compiled — through an ordered, named sequence of transformations — into work that is implemented, verified against the original obligations, and promoted into durable project knowledge, at an extremely high and *evidenced* level of confidence.

> **Swarm is an obligation-centered specification compiler framework for agentic software engineering. It turns human intent into verifiable obligations, lowers those obligations into bounded agent tasks, verifies traces against obligations, and promotes durable discoveries back into project memory.**

The goal is **spec-as-code with verifiable output**. Swarm is explicitly *not* a chat assistant, not a prompt library, and not a set of canned instructions: it is a manual-to-automatable *compiler architecture* whose output is required behavior that has been **proven, not merely asserted**.

> Design rationale: treating the written specification — not the code — as the artifact tooling consumes is the established pattern of industry interface and configuration languages. OpenAPI, Terraform, and Smithy each make a written spec the authoritative source from which servers, clients, SDKs, and documentation are generated; Kubernetes objects carry a desired-state `spec` reconciled against an observed-state `status`. Swarm extends that pattern from interface shapes to behavioral obligations, and closes the loop with verification and promotion.

### 0.1 The end-to-end pipeline (ten stages)

The full journey is an ordered chain of ten artifact transitions. Each arrow is a transformation a pass performs (§2); each box is an artifact that the next stage consumes:

```text
human intent
  → source artifacts (research / audit / bug-report)
  → *.swarm.md specification (prose + SOL blocks)
  → obligation graph (the IR)
  → plan
  → task frames (bounded work packets)
  → agent execution
  → trace
  → verification (proofs → verdicts)
  → review verdict
  → promotion
  → durable memory update
```

Read it as a single sentence: *capture intent as a spec, compile the spec into an obligation graph and a plan, partition the plan into bounded task frames, let agents do the work and record what they did as a trace, prove the trace against the obligations, judge it into a review verdict, then fold durable discoveries back into memory.* The chain is what makes the output **verifiable**: nothing is "done" until a bound proof has produced inspectable evidence and a verdict has been rendered against the originating obligation (Invariant 5 — shape is not truth).

| Stage | Artifact | What it establishes |
| --- | --- | --- |
| 1 | human intent | The raw goal, ambiguity and all. |
| 2 | source artifacts (`research.md` / `audit.md` / `bug-report.md`) | Pre-spec grounding: what is known, what was found, what is broken. |
| 3 | `*.swarm.md` specification | APS prose + SOL obligation blocks — the desired-state intent artifact. |
| 4 | obligation graph (the IR, `*.swarm.ir.json`) | The typed graph of obligations and their relationships; the central object every pass reads and writes. |
| 5 | plan (`*.swarm.plan.json`) | The schedulable projection of the IR: bounded work packets, ordering, write-disjointness. |
| 6 | task frames (`task.md`) | One bounded work packet, one pass, assigned obligations only. |
| 7 | agent execution | An agent does the bounded work and records its claims. |
| 8 | trace (`*.swarm.trace.md`) | TRACE blocks claiming which obligations were implemented/preserved, with proof references. |
| 9 | verification → review verdict (`review.md`) | Bound proofs run (proofs → core verdicts); claims judged; lifecycle decorators applied; merge gate computed. |
| 10 | promotion → durable memory | Durable discoveries become `finding.md` / `adr.md` / memory entries / spec amendments. |

The obligation graph (stage 4) is the **central object**: specs produce obligations, the compiler lowers obligations into a plan and tasks, tasks implement obligations, traces claim obligations, verification proves obligations, reviews judge obligations, and memory records durable discoveries about obligations. Because the graph — not prose, and not any agent's recollection — is the source of truth, the final merge gate reduces to a property of the graph: *every required obligation carries a passing verdict.*

---

## 1. The layer cake: seven layers

The pipeline flows through a stack of **seven layers**. Each layer is produced from the one above it by a named pass (§2) and consumed by the one below it. The surface is human-authored; the middle layers are machine-emitted (today, by an agent following a documented contract; later, by a tool); the JSON layers are contract-only — reserved names with no shipped emitter (Invariant 1).

```text
        ┌─────────────────────────────────────────────────────────────┐
HUMAN   │  SURFACE                                                      │
AUTHORED│  *.swarm.md  =  APS prose  +  SOL blocks                      │
        │  (REQ, CONSTRAINT, INVARIANT, INTERFACE, QUESTION, TRACE,     │
        │   VERDICT)                                                    │
        └─────────────────────────────────────────────────────────────┘
                         │  lint  (PARSE + NORMALIZE)   →  diagnostics
                         │  improve (NORMALIZE)         →  semantics-preserving repair
                         ▼
        ┌─────────────────────────────────────────────────────────────┐
MACHINE │  IR  —  THE OBLIGATION GRAPH                                  │
EMITTED │  *.swarm.ir.json = { meta, nodes[], edges[], diagnostics[],   │
(contract)│                     provenance }                            │
        └─────────────────────────────────────────────────────────────┘
                         │  lower + decompose (LOWER)
                         ▼
        ┌─────────────────────────────────────────────────────────────┐
MACHINE │  PLAN                                                         │
EMITTED │  *.swarm.plan.json = dependency DAG + write-conflict graph    │
(contract)│                     + bounded work packets                 │
        └─────────────────────────────────────────────────────────────┘
                         │  implement (EXECUTE)
                         ▼
        ┌─────────────────────────────────────────────────────────────┐
HUMAN/  │  EXECUTION                                                    │
AGENT   │  task.md  —  one bounded work packet, one pass               │
        └─────────────────────────────────────────────────────────────┘
                         │  (agent does the work; records claims)
                         ▼
        ┌─────────────────────────────────────────────────────────────┐
MACHINE │  TRACE                                                        │
EMITTED │  *.swarm.trace.md  —  TRACE blocks: IMPLEMENTS / PRESERVES /  │
        │                       CHANGED / PROOF                         │
        └─────────────────────────────────────────────────────────────┘
                         │  verify + review (VERIFY + REVIEW)
                         ▼
        ┌─────────────────────────────────────────────────────────────┐
HUMAN/  │  VERDICT                                                      │
AGENT   │  review.md  —  VERDICT blocks (PASS/FAIL/BLOCKED/UNVERIFIED   │
        │                + lifecycle) + merge gate                      │
        └─────────────────────────────────────────────────────────────┘
                         │  promote (PROMOTE)
                         ▼
        ┌─────────────────────────────────────────────────────────────┐
HUMAN/  │  PROMOTION                                                    │
AGENT   │  finding.md · adr.md · memory/INDEX.md · memory/patterns/*    │
        └─────────────────────────────────────────────────────────────┘
```

### 1.1 The seven layers and each layer's role

| Layer | Artifact(s) | Origin | Role |
| --- | --- | --- | --- |
| **Surface** | `*.swarm.md` | **Human-authored** (the only human-authored `.swarm.` artifact) | Captures intent as APS prose + SOL obligation blocks. |
| **IR** | `*.swarm.ir.json` | **Machine-emitted; contract-only name** (reserved; no shipped emitter — Invariant 1) | The obligation graph: nodes are obligations + judgments, edges are relationships. The central object every pass reads and writes. |
| **Plan** | `*.swarm.plan.json` | **Machine-emitted; contract-only name** (reserved; no shipped emitter) | The schedulable projection of the IR: dependency DAG + write-conflict graph + bounded work packets. |
| **Execution** | `task.md` | **Human/agent working artifact** (plain `.md`) | One bounded work packet, one pass — the unit handed to a single agent in a single lane. |
| **Trace** | `*.swarm.trace.md` | **Machine-emitted instance** (template `trace.md` is human-copyable) | TRACE blocks: IMPLEMENTS / PRESERVES / CHANGED / PROOF — the agent's claims about which obligations it discharged. |
| **Verdict** | `review.md` | **Human/agent working artifact** (`VERDICT` is a language block; `review.md` is its container — there is no `verdict.md`) | VERDICT blocks (core + lifecycle) + the merge gate. |
| **Promotion** | `finding.md`, `adr.md`, `memory/INDEX.md`, `memory/patterns/*.md` | **Human/agent working artifacts** | Durable discoveries anchored with provenance. |

The `.swarm.` infix is the discriminator: a `.swarm.` filename is parsed or emitted by the compiler; a plain `.md` filename is a human/agent working artifact. The IR layer — the **obligation graph** — is what every pass operates on: `lint` annotates it with diagnostics, `improve` rewrites nodes without changing their meaning, `lower`/`decompose` derive the plan's DAG and conflict graph from it, `implement` produces traces that attach to its obligation nodes, `verify`/`review` attach verdicts to those nodes, and `promote` reads the judged graph to emit durable artifacts. The final merge gate is a predicate over the graph: every required obligation node carries a verdict of `PASS` or `WAIVED`, and none is `STALE`, `CONTRADICTED`, `FAIL`, `BLOCKED`, or `UNVERIFIED`.

---

## 2. Two levels: phases and passes

The pipeline is described at **two levels of granularity that MUST NOT be conflated** (§9):

- A **phase** is a *conceptual compiler stage*. The seven phases are a fixed-order taxonomy naming *where in the pipeline* a piece of work sits. Phases are descriptive grouping, **not schedulable units**.
- A **pass** is a *schedulable transformation*. The nine passes are the concrete units of work an author, agent, or future tool actually runs; each consumes one or more artifacts and produces one or more artifacts.

Several passes MAY map to one phase (both `lower` and `decompose` sit in `LOWER`). No pass spans two phases except `lint`, which the mapping table assigns to two (`PARSE` + `NORMALIZE`) because it is partly well-formedness detection and partly normalization of detected smells.

> Design rationale (§9): compiler theory distinguishes phase (a stage) from pass (a traversal). Swarm inverts the common case so the small fixed phase taxonomy is the stable conceptual spine and the larger pass set is the schedulable surface.

### 2.1 The seven phases (fixed order)

A conformant description MUST present them in exactly this order and MUST NOT add, remove, or reorder them in v0.1 (§9.1):

```text
PARSE -> NORMALIZE -> LOWER -> EXECUTE -> VERIFY -> REVIEW -> PROMOTE
```

| Phase | What the phase establishes | Nature |
| --- | --- | --- |
| `PARSE` | Surface SOL is recognized; blocks, ids, clauses, modals identified; well-formedness (`SOL-S###`) decided. | Deterministic |
| `NORMALIZE` | The recognized spec is brought into canonical, smell-free, semantics-preserving form. | Deterministic + heuristic |
| `LOWER` | The normalized spec becomes the IR obligation graph and is partitioned into task-sized work packets. | Mostly deterministic |
| `EXECUTE` | Code, docs, and tests are produced against the lowered work packets. | Heuristic |
| `VERIFY` | Each bound proof is run; each obligation receives a core verdict. | Deterministic |
| `REVIEW` | Trace claims judged against obligations, diffs, evidence; lifecycle decorators applied; merge gate computed. | Hybrid |
| `PROMOTE` | Durable discoveries become findings, ADRs, memory, or spec amendments. | Hybrid but routable |

### 2.2 The nine passes (pipeline order)

```text
author -> lint -> improve -> lower -> decompose -> implement -> verify -> review -> promote
```

This is the default sequencing. A launcher MAY interleave passes across multiple specs, but **for a single obligation the partial order MUST be respected** — an obligation cannot be `verify`-ed before it is `implement`-ed, nor `implement`-ed before `lower`-ed (§9.2). There is no runtime: each pass is a contract performed today by a human or agent following a pass guide.

### 2.3 Pass-to-phase mapping (normative)

| Pass | Phase(s) | Input → Output | What it does | Lint layer touched (§8) |
| --- | --- | --- | --- | --- |
| `author` | entry (pre-`PARSE`) | chat / `research.md` / `audit.md` / `bug-report.md` / prior spec → `spec.swarm.md` draft | Captures human intent as SOL obligations + APS prose. | — (produces input to lint) |
| `lint` | `PARSE` + `NORMALIZE` | `spec.swarm.md` → lint report + blocking status | Detects defects **without changing semantics**; decides well-formedness, surfaces smells. | S / P / M / V / O |
| `improve` | `NORMALIZE` | spec + lint report → normalized spec + improvement report | Applies the closed 10-operation set (§3), strictly semantics-preserving. | answers the codes mapped in §3 |
| `lower` | `LOWER` | approved spec → `*.swarm.ir.json` | Assigns IR node ids, builds typed edges, normalizes `verify_by`, emits the two derived graphs. | `SOL-O###` |
| `decompose` | `LOWER` | `*.swarm.ir.json` → `task.md` packets (+ `*.swarm.plan.json`) | Partitions the graph into write-disjoint work packets. | `SOL-O###` (e.g. `SOL-O005`) |
| `implement` | `EXECUTE` | `task.md` → code/docs/tests + `trace.md` | Produces the change for assigned obligations only; records TRACE claims, gathers evidence. | — (claims feed verify/review) |
| `verify` | `VERIFY` | `trace.md` + bound proofs + `AGENTS.md > Commands` → per-obligation core verdict | Runs each `VERIFY BY` binding through its resolved adapter; one verdict per binding. | `SOL-V###` |
| `review` | `REVIEW` | spec + `trace.md` + diff + evidence → `review.md` | Judges claims; applies lifecycle decorators; computes the merge gate. | `SOL-M###`, `SOL-V###` |
| `promote` | `PROMOTE` | discoveries + `trace.md` + `review.md` + source authority → `finding.md` / `adr.md` / amendment / memory update | Moves durable discoveries into provenance-anchored artifacts. | — (routes through source authority §22) |

**Pass contract notes (§9.3.1):**

- `author` precedes `PARSE`: its output is the first compiler-visible artifact and is not itself analyzable.
- `lint` is **non-mutating** — diagnostics only. The **only** pass permitted to rewrite the spec is `improve`, and only semantics-preservingly.
- `improve` runs **only after** `lint`; with no lint findings to answer it is a no-op.
- `lower` requires an **approved, lint-clean** spec. An unresolved BLOCKING diagnostic or a blocking `QUESTION` MUST NOT be lowered (see §4.5).
- `decompose` consumes the **IR**, not the surface spec, so packet boundaries come from the typed graph.
- `verify` is the **only profile-independent pass** — deterministic evidence-gathering; no heuristic profile (§27) alters whether a run `PASS`-es.

### 2.4 The shipped pass guides, implement & author guides, fragments, and profiles

A **pass guide** is a lazily-loaded procedural document (the kernel's term for what the broader agent ecosystem calls a "skill"). Pass guides are SOFT control (Invariant 2): they MUST NOT define SOL/APS semantics, modality, authority order, or verification meaning — those live only in SOL and the IR. The kernel ships its conditioning layer as the pass guides, per-kind implement & author guides, cross-cutting fragments, and 13 profiles that ship under `kernel/.agents/skills/`, every one carried as a `SKILL.md` (ADR-0042). Across the nine passes: `author` is served by **six author guides** (`write-spec`, `write-audit`, `write-research`, `write-bug-report`, `write-prd`, `write-rfc`); `lint`, `decompose`, `review`, and `promote` each have a pass guide (`pass-lint-spec`, `pass-decompose-spec`, `pass-review-trace`, `pass-promote-findings`); `implement` is served by **nine per-kind implement guides** (`write-feature`, `write-fix`, `write-refactor`, `write-rewrite`, `write-migration`, `write-performance`, `write-testing`, `write-documentation`, plus the narrow `fix-flaky-test`); `verify` is served by the `empirical-proof` fragment; and `improve` and `lower` ship **no guide** (contract-only). A guide-less pass is **not** a conformance gap: the pass contract is the binding artifact. (Naming note: adversarial review is not its own guide — it is `review[profile: skeptic]`, where `skeptic` is one of the 13 `persona-*` profiles.) Pass-guide bodies follow the established skill-authoring discipline — a ~500-line body cap, a third-person description, progressive disclosure, and an explain-the-WHY pattern [[SKILLBP]](../research/sources.md#SKILLBP).

---

## 3. The improve operation set (§10)

`improve` is the `NORMALIZE`-phase pass that rewrites a spec to satisfy SOL and APS. It is a **closed set of exactly ten operations** — a conformant pass MUST NOT invent operations outside it, and "improve the spec" with no named operation is not a valid request.

```text
NORMALIZE  ATOMIZE  CONCRETIZE  QUANTIFY  BIND  SCOPE  CLARIFY  DECONFLICT  COMPRESS  PROMOTE
```

### 3.1 The hard rule: improve is semantics-preserving

> **R-IMPROVE.** Every improve operation MUST be strictly semantics-preserving. It MUST NOT add, remove, weaken, strengthen, or otherwise change the **intent** of any obligation. Any intent change — a new requirement, a relaxed constraint, a different actor, a changed trigger or response — MUST route to **amendment/review**, never to `improve`.

Two corollaries (§10.1):

- The improvement report MUST carry a *Semantic changes* row, flagged `requires approval: yes`, for any edit the author is unsure preserves intent; such edits belong to amendment, not `improve`.
- **R-DECOMPOSE-NOT-IMPROVE.** `decompose` is a *pass* (§4), not an improve operation — it changes the artifact partition, not the prose. `ATOMIZE` is distinct: it splits one bundled obligation into multiple obligations *within the same spec*, preserving the spec as the unit.

### 3.2 The ten operations (normative)

Each operation is triggered by one or more lint codes, with a precondition and a postcondition. Trigger codes use the unified `SOL-<LAYER>###` namespace; APS violations surface as `SOL-P###` codes (§10.2).

| # | Operation | Trigger code(s) | Repairs |
| --- | --- | --- | --- |
| 1 | `NORMALIZE` | `SOL-P003`, `SOL-V###` | Informal/lowercase modal or non-canonical phrasing → approved uppercase modal in canonical clause order; no meaning changed. |
| 2 | `ATOMIZE` | `SOL-P004` | One block bundling ≥2 separable obligations → each its own block with its own id; bindings distributed. |
| 3 | `CONCRETIZE` | `SOL-P005` | Vague-quality word with no observable criterion → replaced by **observable behavior** (actor + action + object). |
| 4 | `QUANTIFY` | `SOL-P005` | Unbounded quality with no measurable threshold → carries a **measurable threshold** or named measurable criterion. |
| 5 | `BIND` | `SOL-V001`, `SOL-V###` | Obligation lacking a binding/source/interface/trace → valid `VERIFY BY <type>:<adapter>:<artifact>` + required references (covers both the proof binding and its trace references). |
| 6 | `SCOPE` | `SOL-O###` | Missing non-goals / applicability / write surfaces / exclusions → explicit `Non-goals` / applicability / `WRITES` / exclusions present. |
| 7 | `CLARIFY` | `SOL-P008` | Behavioral uncertainty buried in prose → an explicit interpretation **OR** a `QUESTION` block. |
| 8 | `DECONFLICT` | `SOL-M002` | Two obligations (or obligation vs higher artifact) contradict → resolved per source authority (§22), or raised to amendment. |
| 9 | `COMPRESS` | `SOL-P054`, `SOL-P055` | Non-load-bearing noise / redundancy → removed; text interpreted consistently (covers both redundancy removal and consistent-reading stabilization). |
| 10 | `PROMOTE` | promotion protocol (§23) | Durable fact in task-local state → moved to `finding.md` / `spec.swarm.md` / `adr.md` / memory with provenance. |

`CONCRETIZE` and `QUANTIFY` share trigger `SOL-P005` but differ in repair: `CONCRETIZE` substitutes *observable behavior* (qualitative), `QUANTIFY` a *measurable threshold* (quantitative). The author picks whichever the obligation's nature requires; both exit the same code (§10.2).

### 3.3 Semantic-diff classification (the operational test)

Every spec edit reaching `improve` or `review` MUST be classified into **exactly one of twelve closed categories** (§10.4). An edit fitting none is itself a defect (an unanalyzable diff) and MUST be split until each part classifies. The classification converts a free-form text diff into a typed change whose approval requirement is then mechanical.

Categories 1–11 are all **amendments** that MUST route to approval (§22.6): added obligation, removed obligation, changed trigger, changed actor, changed modality, changed response, changed proof binding, changed non-goal, changed interface, changed invariant, changed question status. **Category 12 — pure normalization** (formatting, casing, keyword form, canonical clause order, dead-link/proof-ref completion, redundancy compression, with **no** change to any obligation's actor/trigger/modality/response/binding/non-goal/interface/invariant/question status) is the **only auto-approved class**.

> **R-SEMDIFF.** Pure normalization is the only auto-approved class. An unclassified edit MUST NOT be promoted. An edit that *combines* normalization with any of categories 1–11 is classified by its **strongest (non-normalization) category** — normalization never "absorbs" a semantic change ridden in alongside it.

This is the operational test behind R-IMPROVE: an improve operation is legitimate **iff** every edit it makes classifies as category 12. The moment an edit classifies as 1–11, the work has left `improve` and entered amendment.

---

## 4. Lowering and decomposition (§11)

`LOWER` turns a normalized, approved spec into machine-shaped work. Two passes occupy it: `lower` (SOL surface → IR obligation graph) and `decompose` (IR → task-sized work packets). They are separate passes — different inputs, outputs, and failure modes; conflating them would mix graph construction with work partitioning. Throughout `LOWER`, the **distillation-loss discipline** (§24) is in force: lowering MUST preserve every obligation, modality, actor, trigger, response, constraint, invariant, verification binding, and the authority of each obligation. Dropping any is a **distillation error**, not an optimization.

### 4.1 The `lower` pass — four steps, in order

`lower` consumes an approved `spec.swarm.md` and produces `*.swarm.ir.json`. Mostly deterministic. It MUST, in order (§11.1):

1. **Assign IR node ids.** Each surface block (e.g. `AC-001`) becomes an IR node; the id MAY be namespaced as `REQ.<spec>.AC-001`. Surface ids stay stable; the namespaced form is IR-only.
2. **Build typed edges.** Relationships are emitted as `edges[]` `{from, to, type, hard}` with `type ∈ {depends_on, blocks, conflicts_with, verified_by, affects, implements, preserves}`. Edges are the **single source of relationship truth** — a relationship MUST NOT be duplicated as a node scalar. (`AFFECTS <node-id>` → `affects` edge; `AFFECTS <surface>` contributes `conflicts_with` edges per §18 (never an `affects` edge) and is not stored as a node scope set; `WRITES` overlap → `conflicts_with`; each `VERIFY BY` → `verified_by`.)
3. **Normalize `verify_by`.** Each surface `VERIFY BY <type>:<adapter>:<artifact>[#selector]` becomes `{type, adapter, ref, selector, gate}`. The adapter is recorded as written and resolves through `AGENTS.md > Commands` **at verify time**, not at lowering time.
4. **Emit the two derived graphs.** (a) a **dependency DAG** from `depends_on` edges; (b) a **write-surface conflict graph** from `WRITES`/`SURFACE` declarations and the READS/WRITES conflict rule. These are the substrate the safe-parallelism predicate runs on (§18): `lower` produces them, `decompose` consumes them.

### 4.2 AND THE chaining (G3)

A `REQ` MAY chain obligations with `[AND THE <actor> <MODAL> <response>]*`. `lower` MUST split each chained clause into a **distinct IR obligation node**, one per `THE`/`AND THE` clause, each inheriting the parent's bindings unless overridden. The *n*-th clause (the leading `THE` is 1, each `AND THE` thereafter) lowers to id `<surface-id>.<n>` (e.g. `AC-001.1`, `AC-001.2`). A surface `TRACE`/`VERDICT` targeting the parent distributes over all split sub-obligations; the merge gate (§14.4) requires **every** split sub-obligation to carry `PASS`/`WAIVED`.

> **R-CHAIN.** Chained obligations lower into multiple distinct IR obligations. When one block chains **more than two** obligations (three or more clauses), `lower` MUST emit a `SOL-P004`-adjacent **warning** (bundled-obligation smell) suggesting `ATOMIZE`. It MUST NOT be a hard error — chaining is permitted; two chained clauses → no warning.

### 4.3 The `decompose` pass

`decompose` consumes `*.swarm.ir.json` and produces `task.md` work packets. It is the machinery that partitions the obligation graph into bounded, write-disjoint work — a deliberate decomposition of the task rather than a single flat pass [[TREEOFTHOUGHTS]](../research/sources.md#TREEOFTHOUGHTS). It MUST (§11.2):

1. **Partition obligations into work packets**, each carrying its assigned obligations, constraints/invariants in force, interfaces touched, write surfaces, and verification bindings (the `task.md` contract, §21).
2. **Project owned paths** for each packet as the file/glob projection of its assigned obligations' `WRITES` surfaces.
3. **Compute merge order** from `depends_on` edges as a partial order, and **prove** owned paths of any two parallel-scheduled packets are pairwise disjoint via the write-surface conflict graph (§18).

### 4.4 Key lowering rules

- **Owned-path containment (G7) — R-OWNED-SUBSET.** An execution-tier owned path MUST be a subset of the union of its assigned obligations' `WRITES` surfaces. A path touching a file outside any assigned obligation's declared write surface is lint code **`SOL-O005`**.
- **Distillation-loss (§11.4).** Dropping an obligation id, modality, actor, trigger, response, constraint, invariant, or verification binding during lowering is a **hard failure** of the pass, not a triageable warning. Authority (§22) MUST ride onto each lowered node so a downstream conflict resolves without re-reading the surface. An obligation reaching `decompose` with no `verify_by` is a `SOL-V001`-class defect that `BIND` should have answered during `improve`.
- **READS/WRITES conflict rule (§11.5).** Conflict-serializability: `READS`/`READS` on the same surface is parallel-safe (no edge); `READS`/`WRITES` or `WRITES`/`WRITES` on the same surface is a conflict (`conflicts_with` edge). A `SURFACE` MAY carry an attribute (`append-only`, `integration`, `shared`) so shared/global/append-only surfaces aren't treated as ordinary write conflicts. `lower` only emits the edges; the full predicate is §18.

### 4.5 The two `LOWER` gates

`LOWER` is bracketed by two **pipeline gates**. A gate is **not a transformation** — it writes no artifact; it is a precondition predicate over already-emitted state. Both are contracts checkable today by review and enforced by a future tool (no runtime). A future tool MUST compute both predicates mechanically from `nodes[]`, `edges[]`, and the plan `packets[]`; until one ships, a conformant repo MUST state both as review-checkable contracts and MUST NOT claim either is tool-enforced.

> **Gate vs improve-op (normative).** The CLARIFY *gate* and the `CLARIFY` *improve operation* (§3, op 7) are distinct and MUST NOT be conflated. The op is a **local edit** in `NORMALIZE` that lifts one buried ambiguity (`SOL-P008`) into an interpretation or a `QUESTION`. The gate is a **checkpoint** at the `NORMALIZE`→`LOWER` boundary that refuses to advance while any such question is open and blocking. The op *creates* the QUESTION; the gate *waits on* it.

**CLARIFY gate (pre-`lower`) — R-CLARIFY-GATE.** `lower` MUST NOT proceed for an obligation while any of these hold for it:
- an unresolved `[blocking]` `QUESTION` `AFFECTS` it (answered, or downgraded to `[non-blocking]` with rationale, clears it);
- a blocking `SOL-M002` (contradiction) names it;
- an unresolved `SOL-P008` (uncaptured behavioral ambiguity) attaches to it.

This is the **named generalization** of R-BLOCKING-Q (§11.1.2): a `[blocking]` `QUESTION` reaching `lower` is orchestration error `SOL-O003`; R-CLARIFY-GATE lifts that into a three-condition checkpoint that also catches `SOL-M002` and `SOL-P008`. The codes are unchanged — a tripped gate surfaces as the *existing* code for whichever condition tripped it; the gate aggregates, it is not a new diagnostic.

> Design rationale: the CLARIFY gate sits where it does because the planner-to-coder handoff is the dominant multi-agent failure surface — ambiguity that survives into lowering is what later strands a coder. Ambiguous task descriptions sharply depress first-pass correctness and contradictory ones depress it further; a clarify-then-generate loop that resolves the ambiguity *before* generation recovers most of that loss. The gate makes that loop structural: it refuses to advance an obligation into `LOWER` while a blocking question, a contradiction, or an uncaptured behavioral ambiguity still attaches to it, so the ambiguity is forced to resolve at the cheapest point rather than the most expensive one.

**COVERAGE gate (pre-`implement`) — R-COVERAGE-GATE.** Before any `implement` pass runs:
1. **Total coverage.** Every lowered obligation node (every `REQ`/`CONSTRAINT`/`INVARIANT`/`INTERFACE`, including each `AND THE`-split sub-obligation) is assigned to **exactly one `implement` packet**. Uncovered = `SOL-O007` (BLOCKING; resolves by `SCOPE`). Double-owned = `SOL-O008` (BLOCKING). (An obligation legitimately appears in its `implement`, `verify`, and `review` packets across passes; the count is per `implement` packet.)
2. **No orphan targets.** Every `verified_by` edge and every TRACE `implements`/`preserves` edge resolves to a real node id in `nodes[]`. An unresolved target is `SOL-M003` (unbound-cross-reference, surfaced at `review`).

The COVERAGE gate is the structural complement of distillation-loss: distillation-loss forbids *dropping* an obligation during lowering; COVERAGE forbids *stranding* one afterward. Together they make the lowered work a bijection over obligations — nothing lost (§11.4), nothing left uncovered or pointed at a phantom (§11.6.2).

| Gate | Boundary | Predicate (MUST hold to advance) | Surfaced as | Carrier (manual today) |
| --- | --- | --- | --- | --- |
| CLARIFY | `NORMALIZE` → `LOWER` | No open `[blocking]` `QUESTION`, no blocking `SOL-M002`, no unresolved `SOL-P008` on an in-scope obligation | `SOL-O003` / `SOL-M002` / `SOL-P008` (existing codes) | `lint` (Skeptic) |
| COVERAGE | `LOWER` → `EXECUTE` | Every obligation covered by exactly one packet; every TRACE/verdict target resolves | `SOL-O007` (uncovered), `SOL-O008` (double-owned), `SOL-M003` (orphan) | `decompose` (Lead Engineer) |

Neither gate is a new pass; both reuse the existing pass surface and the `SOL-<LAYER><NNN>` namespace, adding only the two new orchestration codes `SOL-O007` and `SOL-O008`.

---

## 5. The plan (§13)

The **plan** is the **schedulable projection of the IR**: it takes the obligation graph (nodes + edges) and groups the work to discharge those obligations into **work packets** — units a launcher could hand to one agent in one lane. Where the IR answers "what must hold and how do the obligations relate," the plan answers "what units of work exist, in what order, on which surfaces, and which are safe to run at the same time." The plan is the kernel's **static coordination contract** (§18) — *not* a running scheduler. The file uses the compiler-visible infix: `auth-refresh.swarm.ir.json` plans to `auth-refresh.swarm.plan.json`.

> **Contract, not executor (normative, §13.1).** The plan schema is **documented, versioned data**. **Plan derivation is the `decompose` pass** — there is no separate "planner" step. What is **out of the kernel** is the **scheduler/harness** that would execute the packets live across agents (a launcher concern, §18.8). This repository ships **no running emitter and no scheduler** (Principle 1): frame any `.swarm.plan.json` as "the contract a future tool emits and a future launcher consumes."

### 5.1 Resolution method (G8)

Two source files disagreed on the plan shape. G8 resolves with the **same method as the IR** — a graph envelope plus a rich per-unit payload, snake_case throughout — with two normative subtractions (§13.2):

- **Drop `locks` entirely.** A lock group is a named coarse write `SURFACE`; lock-set analysis *is* write-set analysis at surface granularity (§18). The plan carries `writes[]`, never a `locks` field.
- **Reconcile the two payloads** into one work-packet record carrying both the *pass/profile* dimension and the *scope/dependency* dimension (`writes`/`reads`/`depends_on`/`merge_safe`).

### 5.2 Top-level envelope

A plan document MUST be a single JSON object with **exactly four keys**: `meta` (×1, plan identity + the spec/IR it derives from + the three version fields), `packets` (0..n work-packet objects), `edges` (0..n; the *same* single-source-of-relationship-truth rule as the IR), `provenance` (×1; same shape as §12.9). Relationships between packets live **only** in `edges[]` (never duplicated as packet scalars); the per-packet `depends_on[]` array is the declaration, and `decompose` MUST also emit a `depends_on`-type edge for each so ordering is computable from the graph (§13.3).

### 5.3 Work packets

A **work packet** is one schedulable unit: a single pass applied (under an optional profile) to a selected set of obligations, with declared scope, ordering, and a merge-safety verdict (§13.5).

| Field | Required | Meaning |
| --- | --- | --- |
| `id` | MUST | Packet identifier, unique within the plan. |
| `pass` | MUST | One of the **9 passes** (§2.2). |
| `profile` | MAY | Heuristic profile parameterizing the pass (e.g. `skeptic` on `review`); `null` = default. |
| `inputs` | MUST | Node ids (obligations/questions/traces) this packet consumes. |
| `outputs` | MUST | Artifacts expected (code paths, `*.swarm.trace.md`, `review.md`, `finding.md`, …). |
| `writes` | MUST (MAY be empty) | Write SURFACE ids, derived from the `writes` scope sets of its `inputs`; each MUST be a subset of its obligations' declared `WRITES` (lint `SOL-O005`). No `locks` field. |
| `reads` | MUST (MAY be empty) | Read surfaces touched. |
| `depends_on` | MUST (MAY be empty) | Packet ids that MUST complete first (the merge-order partial order); each MUST also appear as a `depends_on` edge. |
| `lane` | MAY | Suggested execution lane/worker label; launcher hint, no effect on safety. |
| `batch` | MAY | Suggested wave/round index; launcher hint only. |
| `merge_safe` | MUST | The kernel's verdict on whether this packet may run concurrently with its batch-mates. |

Inter-packet edges use the same `{from, to, type, hard}` object as the IR; the relevant types for a plan are `depends_on` (ordering) and `conflicts_with` (a shared write surface, or a read/write conflict on one surface). `conflicts_with` edges are what make a packet `merge_safe: false` against its conflict-mates (§13.5.1).

### 5.4 The safe-parallelism predicate

`merge_safe` is the surface of the kernel's single canonical safe-parallelism predicate, defined normatively in §18 and restated for the plan (§13.6):

> Two work packets MAY run in parallel **iff** they are **dependency-independent** (neither reachable from the other along `depends_on` edges) **AND write-disjoint** (their `writes` sets share no SURFACE, no read/write conflict on a shared surface, no shared interface/migration node). Anything unscoped or sharing a surface **serializes by default** (G7).

A packet's `merge_safe` MUST be `false` if it has any unresolved `conflicts_with` edge to a packet in the same `batch`, or if any input is unscoped (empty `writes` where a write is implied). `merge_safe` is the kernel's **static** verdict; a launcher MAY further serialize but MUST NOT parallelize two packets the plan marks unsafe.

> Design rationale (§13.6): review entropy and merge collisions, not agent count, are the binding constraint on safe parallelism.

A document is a conformant SOL/0.1 plan iff it has exactly the four top-level keys, populates every required field, carries no `locks` field anywhere, uses only the closed 9-pass set in `packets[].pass` and the closed edge-type set in `edges[]`, represents inter-packet relationships once (as edges), and keeps the three version fields distinct. The formal JSON Schema for the plan is Appendix C.3 (§13.8).

---

## Related

Other framework pages that this pipeline reads, writes, or hands off to:

- **The nine passes in depth** — one page per pass: [`author`](../passes/author.md), [`lint`](../passes/lint.md), [`improve`](../passes/improve.md), [`lower`](../passes/lower.md), [`decompose`](../passes/decompose.md), [`implement`](../passes/implement.md), [`verify`](../passes/verify.md), [`review`](../passes/review.md), [`promote`](../passes/promote.md).
- **The surface layer** — the obligation language and prose standard the spec is authored in: [SOL](../language/SOL.md), [APS](../language/APS.md), and the [lint catalogue](../language/errors.md).
- **Truth and judgment** — what `verify`/`review` render: [proof types](../reference/proof-types.md) and the [seven-value verdict model](../adrs/0035-seven-value-verdict-model.md).
- **Promotion and memory** — where durable discoveries land: the [promotion protocol](../reference/promotion-protocol.md).
- **Distillation discipline** — the loss budget that lowering MUST respect: [distillation loss budget](../reference/distillation-loss-budget.md).
- **Coordination** — the workspace and authority model the plan and promotion sit inside: [workspace](./workspace.md) and [source authority](./source-authority.md).
- **Conformance** — what makes a repository a faithful Swarm implementation of this pipeline: [conformance](./conformance.md).
