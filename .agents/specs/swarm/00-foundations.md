# Swarm Kernel Specification v0.1 — Part 00: Foundations & architecture

<!-- Part 00 of the Swarm Kernel Specification (§0–§4). All parts share one section numbering (§0–§35 + Appendices A–G); cross-references of the form “§N” resolve via the index in [README.md](./README.md). -->

## 0. Preamble, status, and how to read this document

### 0.1 Status

| Field | Value |
|-------|-------|
| Title | Swarm — The Kernel Specification |
| Language version | SOL/0.1 (and APS 0.1) |
| Document status | **Accepted** |
| Document role | Single canonical kernel; the source the entire repository is reworked from |
| Supersedes | The four source files listed in §0.2 |
| Resolution log | this specification |

This document is **Accepted** as the v0.1 kernel. Once accepted, every Swarm document, template, scaffold artifact, pass guide, profile, and ADR MUST be consistent with this specification; where any existing repository file disagrees, this specification governs and that file MUST be reworked to conform (§34).

### 0.2 Provenance and consolidation

This specification is the **single, self-contained source of truth** for Swarm. It consolidates and supersedes all prior Swarm working material — earlier research drafts on the obligation language and the compiler model, an intent-level design brief, and a parallel independently-authored specification — none of which is retained as a separate document. Every contradiction across that prior material was resolved once, globally, and each resolution is recorded **here**: in the normative text of the sections below, in the canonical vocabulary of §4, and in the residual-gap judgment calls of Appendix E. There is no external decision log and no companion file to consult; a settled decision lives in this document. A change to any settled decision is an amendment that MUST be recorded as a new ADR (§30) and, if it touches the language, MUST bump the language version (§25).

### 0.3 The meta-convention: two layers of modal language

This document operates on two distinct languages, and the reader MUST keep them separate.

- **The meta-language** is the language *this specification* speaks about conformant Swarm repositories, tools, and authors. Its normative keywords — **MUST, MUST NOT, SHOULD, SHOULD NOT, MAY, REQUIRED, OPTIONAL** — are to be interpreted per RFC 2119 and RFC 8174, and carry force *only* when in uppercase. Example: "An `INTERFACE` block MUST carry a `VERIFY BY contract:` binding."
- **The object-language** is SOL itself — the language Swarm authors write inside `*.swarm.md` files. SOL has its own modals (MUST, MUST NOT, SHOULD, SHOULD NOT, MAY; §4.2) which decorate obligations. When this document quotes SOL, those modals are **data being specified**, not directives of this document. Example: in the SOL line `THE client MUST clear the local session`, the word `MUST` is an SOL token whose semantics §6 defines; it is not a requirement levied on the reader of this specification.

To reduce ambiguity, every SOL fragment, grammar production, JSON shape, and template skeleton in this document appears inside a fenced code block tagged `sol`, `ebnf`, `json`, or `text`. Modal words appearing in such fences are object-language. Modal words in running prose are meta-language.

### 0.4 Reading order

This document is exhaustive and may be read front to back, but the following order builds the mental model fastest:

1. **§1–§3** — the thesis ("spec as code, agents as compiler"), the five invariants, and the layer-cake architecture. Read these first; they frame everything else.
2. **§4** — the canonical vocabulary. This is the reference card every later section points to. Skim it, then return as needed.
3. **§5–§8** — the surface: SOL syntax, the seven block types, the APS prose standard, and the unified lint taxonomy.
4. **§9–§13** — the machinery: phases, passes, the improve operation set, lowering/decomposition, the IR, and the plan.
5. **§14–§17** — truth and control: verdicts, the proof taxonomy, drift, and the soft/hard control boundary.
6. **§18–§24** — orchestration, the artifact set, conformance, source authority, memory, and the distillation loss budget.
7. **§25–§35** — versioning, the recast subsystems (skills, personas, task types, documents, ADRs, the bootloader), the conformance contract, the golden corpus, acceptance criteria, and non-goals.
8. **Appendices A–F** — the consolidated grammar, the full lint catalogue, the IR schema, the auth-refresh worked example, the residual-gap judgment calls, and the glossary.

A newcomer who reads only §1–§4 should be able to hold the whole framework in their head; the remaining sections make every construct precise.

### 0.5 The two version axes (labelling convention)

Swarm carries **two independent version numbers**, and this document is versioned on the first of them. This convention is normative throughout and specified in full in §25.

- **Language version** — the SOL+APS grammar, block set, modal set, clause keywords, and lint codes. Slow-moving: `0.1` (this document), then `0.2`, `1.0`. Carried in `*.swarm.md` frontmatter as the discriminator `swarm_language: SOL/0.1` and in the IR as `meta.language`.
- **Framework / package version** — the scaffold, templates, pass guides, and profiles, versioned as semver in `.agents/.swarm-version`. Fast-moving and independent.

This document is **language v0.1**. The framework package that delivers it carries its own semver. The one-way trigger (§25): any language change forces at least a framework MINOR release; the framework MAY release many versions without changing the language version.

### 0.6 Settled assumptions and scope boundaries

This specification deliberately leaves a small set of environment and process variables **unspecified** rather than choosing a default, because Swarm is provider-neutral and runtime-free (§2.1–§2.2): pinning these would couple the language to a model, tool, stack, or org chart it must outlive. The table is normative — a conformant repository or tool MUST NOT read a hidden default into any row below, and MUST treat each as an explicit open variable that the adopting repository binds locally (e.g., through `AGENTS.md` and its `Commands` table for adapters, §4 and §22).

| Assumption area | Kernel assumption |
|-----------------|-------------------|
| Target LLM family | **Unspecified / model-native.** The kernel assumes no particular model or vendor; SOL, APS, and every pass MUST remain interpretable by any capable agent. No prompt, token, or context-window characteristic of a specific model is normative. |
| Agent runner / IDE | **Unspecified / plain-markdown.** The kernel MUST work with plain markdown and ordinary repository files; it assumes no specific harness, editor, or agent framework. Anything a runner adds is a local convenience, never a conformance dependency. |
| Parser / CLI / LSP | **Out of scope for v0.1; contracts only.** No parser, linter, planner, scheduler, differ, or language server is shipped or required. This spec defines the *contracts* such tools MUST satisfy so future tooling can target them (the no-runtime invariant, §2.1). |
| Programming language / stack | **Unspecified.** Swarm governs requirements, tasks, proofs, reviews, and memory — not the application's language, framework, or build system. The stack surfaces only through `VERIFY BY` adapters resolved in `AGENTS.md > Commands`. |
| Repo host / VCS / forge | **Unspecified.** Examples assume git-compatible workflows (branches, diffs, merge gates) but require no specific forge; nothing in the spec depends on a named host's APIs, review UI, or permission model. |
| Human approval roles | **Unspecified — the spec defines *which* changes need approval, not *who* grants it.** The amendment and source-authority rules (§22) determine which edits are mere normalization versus intent changes that require sign-off; the identity, title, and headcount of approvers are a local org decision the adopting repository binds. |
| Legacy inventory | **Target-state, not file-by-file conversion.** This spec defines the normative target state and the migration rules to reach it; it does not enumerate or convert specific pre-existing repository files. Conformance work MUST converge on the target state defined here, not attempt to reconstruct or preserve guessed legacy contents. |

## 1. What Swarm is — the specification-compiler thesis

### 1.1 The thesis

Swarm treats a **specification as source code** and a **fleet of agents as the compiler**. Human intent is written as a controlled-markdown specification; that specification is compiled — through an ordered, named sequence of transformations — into work that is implemented, verified against the original obligations, and promoted into durable project knowledge, at an extremely high and *evidenced* level of confidence.

> **Swarm is an obligation-centered specification compiler framework for agentic software engineering. It turns human intent into verifiable obligations, lowers those obligations into bounded agent tasks, verifies traces against obligations, and promotes durable discoveries back into project memory.**

The pipeline, end to end:

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

The goal is **spec-as-code with verifiable output**. Swarm is explicitly *not* a chat assistant, not a prompt library, and not a set of canned instructions: it is a manual-to-automatable *compiler architecture* whose output is required behavior that has been proven, not merely asserted.

### 1.2 The obligation graph is the central object

The single object every part of Swarm reads and writes is the **obligation graph**: a typed graph whose nodes are *obligations* (and the judgments rendered on them) and whose edges are the *relationships* among them. The graph is the SOL specification's intermediate representation (the IR, §12). Every role in the framework reduces to an operation on this graph:

```text
Specs           produce obligations.
The compiler    lowers obligations into a plan and tasks.
Tasks           implement obligations.
Traces          claim obligations were implemented.
Verification    proves obligations (or fails to).
Reviews         judge obligations (render verdicts).
Memory          records durable discoveries about obligations.
Orchestration   schedules obligations without write-conflict.
```

Because the graph — not prose, and not any agent's recollection — is the source of truth, every pass can be checked against it, and the final merge gate (§14) reduces to a property of the graph: *every required obligation carries a passing verdict.*

### 1.3 "Unitary at rest, modular in execution"

Swarm's organizing slogan is **"unitary at rest, modular in execution."**

- **Unitary at rest** — Swarm installs as one coherent framework. The language, artifact contracts, passes, templates, pass guides, and memory model arrive together and are internally consistent. There is no menu of disconnected features to assemble.
- **Modular in execution** — at run time, only the pass, profile, and context a single task needs are loaded. A task names the pass guide and profile it requires; nothing else is in context. This protects instruction-adherence and token cost (§2.10) without fragmenting the framework.

### 1.4 What this supersedes: the buffet framing is retired

Earlier Swarm framing presented the system as a **buffet** — a pick-your-own library of skills, personas, task types, and templates, adopted incrementally, "until it stops earning its keep." That framing is **superseded**. Skills, personas, and task types are no longer independent products to be selected; they are unified under the compiler model:

| Earlier (buffet) framing | Kernel (compiler) framing | Specified in |
|--------------------------|---------------------------|--------------|
| Skills you pick à la carte | **Pass guides** — reusable methods for executing a named pass | §26 |
| Personas / characters | **Heuristic profiles** — cognitive stances parameterizing a pass | §27 |
| 18 task types | **Pass frames** — a `task_kind` enum that parameterizes `implement`/`author` | §28 |
| 4 core docs + extended types | One **unified artifact set** centered on the obligation graph | §29 |
| "Recommended routing" prose | Deterministic **lowering** + a **plan** the launcher executes | §11, §13 |

Adoption may still be incremental at the *repository* level (a team may vendor a subset), but the *conceptual model* is unitary: every piece is a component of one compiler, not an independent gadget. A skill never owns language semantics (§26.2); a persona is never a character (§27); a task type is never an open-ended prompt log (§28).

### 1.5 What Swarm is not

| Swarm is | Swarm is not |
|----------|--------------|
| A specification compiler whose output is verified, promoted work | A chat assistant or autonomous "magic" |
| A markdown-only set of contracts a future tool builds against | A CLI, SDK, scheduler, or runtime this repo ships (§2.6) |
| Provider-neutral (no assumption about which model/agent runs it) | Tied to any specific agent tool or vendor |
| A formal spine (SOL) inside readable markdown | A general-purpose programming language |

## 2. Foundational principles and invariants

Five invariants hold in **every** section of this document; no later section may contradict them. They are followed by the standing principles this specification relies on. Each is stated tightly: name, rationale (one clause), and the one-line consequence for authors and tools.

### 2.1 The five invariants

#### 2.1.1 Invariant 1 — NO RUNTIME

Swarm is **markdown-only**. Everything that "runs" — parser, normalizer, planner, scheduler, differ, checker, CLI — is documented as a **contract a future tool builds against**, and is never shipped by this repository.

- *Rationale:* the repository is documentation and scaffold; shipping a runtime would couple Swarm to one environment and contradict provider-neutrality.
- *Consequence:* any section describing tool behavior MUST frame it as "the contract a future tool builds against," never as "a tool Swarm provides." No file MAY claim a CLI is required or that automation already exists.

#### 2.1.2 Invariant 2 — SOFT vs HARD control

Prose, SOL, APS, skills, profiles, and `AGENTS.md` are **SOFT control** (context and guidance). They MUST NOT be presented as enforcement. Anything that must hold *regardless of the model* requires a **deterministic check OUTSIDE the model** (a hook, CI step, permission rule, or schema validator) — the **HARD control** lane.

- *Rationale:* model adherence is probabilistic (prompt-format sensitivity, multi-turn decay, context-rot; §2.10); only an external deterministic check can guarantee a property.
- *Consequence:* the spec maps each `CONSTRAINT`, `INVARIANT`, stop-rule, and secret-redaction need to its eventual deterministic home (§17), and states plainly that **today the hard lane is aspirational/manual** (no runtime). No file MAY claim Swarm enforces behavior through code.

#### 2.1.3 Invariant 3 — Surface-vs-IR layering

Swarm has two layers: a **human surface** (English-shaped UPPERCASE space-separated keywords inside `*.swarm.md`) and a **machine IR/JSON layer** (snake_case fields). The surface is authored; the IR is emitted.

- *Rationale:* the surface optimizes for human readability and model comprehension; the IR optimizes for deterministic analysis — conflating them produces fragile syntax.
- *Consequence:* surface keywords are space-separated uppercase (`VERIFY BY`, `DEPENDS ON`, `OWNED BY`, `WRITES`, `READS`, `AFFECTS`); IR fields are snake_case (`verify_by`, `depends_on`, `writes`, `reads`, `affects`); surface ids are short (`AC-001`), IR node ids MAY be namespaced (`REQ.<spec>.AC-001`). See §4.10.

#### 2.1.4 Invariant 4 — CODE IS REALITY

Code and tests are implementation **reality**: they can **falsify** an obligation, but they MUST NOT **silently amend** intent.

- *Rationale:* a passing or failing test is evidence about whether intent was met, not a re-statement of what intent *is*; intent lives only in obligations.
- *Consequence:* when code disagrees with an obligation, the verdict is `STALE` or `CONTRADICTED` and the conflict MUST route to an explicit three-way reconcile — re-run the proof, amend/supersede the obligation, or fix the code — never a silent re-bless of either (§16, §22).

#### 2.1.5 Invariant 5 — Schema-valid output is NOT verification

A structurally valid artifact (schema-valid IR, well-formed trace) is **not** a verified one. **Shape is not truth.**

- *Rationale:* structured output constrains form but cannot prove that values are correct; "tests passed" without observable output is not a proof.
- *Consequence:* every completion claim MUST map to independent deterministic or evidentiary verification (§14, §15); a `VERDICT` of `PASS` requires a bound proof that actually ran and produced inspectable evidence, not the mere existence of a syntactically valid trace.

### 2.2 Provider-neutral

Swarm makes **no assumption about which model or agent** executes it (not Claude, Codex, Cursor, Gemini, Aider, or any specific tool).

- *Rationale:* the contracts must outlive any single vendor and any single capability ceiling.
- *Consequence:* no section MAY hard-code provider-specific behavior, and capability claims MUST be dated and treated as evidence, not as load-bearing assumptions.

### 2.3 Markdown-only with a self-contained scaffold

Swarm is delivered as markdown, and the scaffold MUST be **self-contained**: the scaffold's SOL and APS references MUST NOT depend on the repository's `docs/` tree.

- *Rationale:* a vendored scaffold travels into a foreign repository where `docs/` will not exist.
- *Consequence:* the language references are duplicated into the scaffold (§20, §21), and the duplication is kept consistent by the conformance contract (§32).

### 2.4 Edges are the single source of relationship truth

In the IR, **relationships live only on `edges[]`** — never duplicated as node scalars.

- *Rationale:* a relationship recorded in two places will drift; one canonical location keeps graph analyses (topo-sort, cycle detection, write-conflict, traceability) sound.
- *Consequence:* `depends_on`, `blocks`, `conflicts_with`, `verified_by`, `affects`, `implements`, and `preserves` are edge types; a node MUST NOT also carry the same relationship as a scalar field (§12).

### 2.5 Distillation discipline

Meaning MUST be **preserved across every lowering**. Each downstream transformation has a fixed budget of *permitted* loss and a fixed set of *forbidden* loss.

- *Rationale:* a compiler that drops obligations, modalities, or verification bindings during lowering produces work that does not match intent.
- *Consequence:* dropping an obligation id, modality, actor, trigger, response, constraint, invariant, or verification binding during lowering is a **distillation error** (§24).

### 2.6 Load-bearing meaning lives only in SOL + IR

**All load-bearing meaning** — modality, actor, trigger/state, verification binding, authority order, conflict resolution, trace schema — lives in **SOL and the typed IR**, and never in prose, skills, personas, or `AGENTS.md`.

- *Rationale:* prose-delivered semantics are unreliable under **prompt-format sensitivity** (±40% on identical content), **multi-turn reliability decay** (~−39%), and **lost-in-the-middle / context-rot** (20–50% degradation); Anthropic gives "no guarantee of strict compliance" for always-loaded prose.
- *Consequence:* prose and skills are non-authoritative *delivery* layers; a regression check (§32) MUST confirm that **no skill, persona, or `AGENTS.md` section defines modality, authority order, or verification semantics**. Always-loaded normative prose is capped (≤200 lines / ≤25 KB; §17, §31), with everything procedural moved to lazily-loaded pass guides and profiles — to minimize always-on density and protect adherence and cost, *not* because models "cannot follow many instructions."

## 3. Architecture overview — the obligation graph and the layer cake

### 3.1 The layer cake

Swarm is a stack of layers. Each layer is produced from the one above it by a named pass (§9) and consumed by the one below it. The surface is human-authored; the middle layers are machine-emitted (today, by an agent following a documented contract; later, by a tool); the JSON layers are contract-only (reserved names, no shipped emitter — Invariant 1).

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

### 3.2 Which layers are authored, emitted, or contract-only

| Layer | Artifact(s) | Origin |
|-------|-------------|--------|
| Surface | `*.swarm.md` | **Human-authored** (the only human-authored `.swarm.` artifact) |
| IR | `*.swarm.ir.json` | **Machine-emitted; contract-only name** (reserved; no shipped emitter — Invariant 1) |
| Plan | `*.swarm.plan.json` | **Machine-emitted; contract-only name** (reserved; no shipped emitter) |
| Execution | `task.md` | **Human/agent working artifact** (plain `.md`) |
| Trace | `*.swarm.trace.md` | **Machine-emitted instance** (template `trace.md` is human-copyable) |
| Verdict | `review.md` | **Human/agent working artifact** (VERDICT is a language block; `review.md` is its container — there is no `verdict.md`) |
| Promotion | `finding.md`, `adr.md`, `memory/INDEX.md`, `memory/patterns/*.md` | **Human/agent working artifacts** |

The `.swarm.` infix is the discriminator: a `.swarm.` filename is parsed or emitted by the compiler; a plain `.md` filename is a human/agent working artifact (§4.7, §20).

### 3.3 The obligation graph is what every pass reads and writes

The IR layer is the **obligation graph**: `nodes[]` are obligations and the judgments rendered on them; `edges[]` are the relationships among them (Invariant 4 — edges are the single source of relationship truth). Every pass is an operation on this graph: `lint` annotates it with diagnostics, `improve` rewrites nodes without changing their meaning, `lower`/`decompose` derive the plan's DAG and conflict graph from it, `implement` produces traces that attach to its obligation nodes, `verify`/`review` attach verdicts to those nodes, and `promote` reads the judged graph to emit durable artifacts. The final merge gate (§14) is a predicate over the graph: every required obligation node carries a verdict of `PASS` or `WAIVED`, and none is `STALE`, `CONTRADICTED`, `FAIL`, `BLOCKED`, or `UNVERIFIED`.

### 3.4 Phases vs passes at a glance

Swarm distinguishes **phases** (conceptual compiler *stages*, fixed and ordered) from **passes** (schedulable *transformations*, in pipeline order). Several passes may share one phase. The full mapping and per-pass detail are in §9.

```text
PHASES (7, conceptual stages):
  PARSE → NORMALIZE → LOWER → EXECUTE → VERIFY → REVIEW → PROMOTE

PASSES (9, schedulable):
  author → lint → improve → lower → decompose → implement → verify → review → promote

mapping:
  author     → (entry, pre-parse)
  lint       → PARSE + NORMALIZE
  improve    → NORMALIZE
  lower      → LOWER
  decompose  → LOWER
  implement  → EXECUTE
  verify     → VERIFY
  review     → REVIEW
  promote    → PROMOTE
```

A newcomer's mental model: *write a spec (surface) → check and tidy it (lint, improve) → compile it into a graph and a plan (lower, decompose) → do the bounded work (implement) → prove and judge it (verify, review) → fold what you learned back into memory (promote).*

## 4. Canonical vocabulary (normative)

This section is the document's canonical reference card. It reproduces this specification's vocabulary cheat-sheet exactly. Every other section points here; where two layers use different spellings for the same construct, this section's split (surface vs IR) governs. Each group ends with a "see §N" pointer to the section that specifies it in full.

### 4.1 Block types (7)

| Type | Surface id prefix | Role | Carries binding force? |
|------|-------------------|------|------------------------|
| `REQ` | `AC-NNN` | Required behavior (obligation) | **Yes** |
| `CONSTRAINT` | `C-NNN` | Restriction on how obligations may be satisfied | **Yes** |
| `INVARIANT` | `I-NNN` | Property that must remain preserved | **Yes** |
| `INTERFACE` | `IF-NNN` | Declares a boundary / API / schema / contract | No (declares) |
| `QUESTION` | `Q-NNN` | Marks unresolved ambiguity | No (marks) |
| `TRACE` | `T-NNN` | Claims obligations were implemented | No (claims) |
| `VERDICT` | reuses the judged obligation's id | Judges an obligation | No (judges) |

Header form: `TYPE PREFIX-NNN:` — the trailing colon is **mandatory**. The **obligation blocks** that carry binding force are `REQ`, `CONSTRAINT`, and `INVARIANT` only. *See §6.*

### 4.2 Modals (5)

| Modal | Force | Requirement |
|-------|-------|-------------|
| `MUST` | Required | — |
| `MUST NOT` | Forbidden | — |
| `SHOULD` | Strong default | Requires an accompanying `BECAUSE` or `EXCEPT` |
| `SHOULD NOT` | Strong prohibition | Requires an accompanying `BECAUSE` or `EXCEPT` |
| `MAY` | Optional | — |

Uppercase only. **Removed:** `SHALL`, `SHALL NOT` (redundant with `MUST`/`MUST NOT`). **Forbidden in binding clauses** (lint warning): `CAN`, `WILL` (non-modal). Lowercase `must`/`should`/`may` carry no force (plain prose). *See §5.4, §6.*

### 4.3 Clause keywords by block (uppercase, case-sensitive)

| Block | Ordered clause keywords |
|-------|-------------------------|
| `REQ` | `WHERE` → `WHILE` → `WHEN` → `IF [THEN]` → `THE <actor> <MODAL> <response>` → `[AND THE <actor> <MODAL> <response>]*` → `[BECAUSE]` → `[EXCEPT]` → `VERIFY BY` → trailing metadata `DEPENDS ON / TOUCHES / WRITES / READS / AFFECTS / RISK <low\|medium\|high\|critical>` |
| `INVARIANT` | `<property> MUST\|MUST NOT <hold>` (no `ALWAYS`/`NEVER`) |
| `INTERFACE` | `RETURNS`, `ACCEPTS`, `ERRORS`, `OWNED BY` |
| `QUESTION` | `[blocking\|non-blocking]` tag, `AFFECTS` |
| `TRACE` | `IMPLEMENTS`, `PRESERVES`, `CHANGED`, `PROOF` |
| `VERDICT` | `REASON`, `EVIDENCE` |

`THEN` after `IF` is a **deprecated migration token**: it is recognized on input but carries no semantics (the `THE <actor>` line is the consequence), is stripped by the `NORMALIZE` improve op (§10), and is never emitted by any template nor used in canonical sources. **Deferred to v0.2** (timing): `WITHIN`, `BEFORE`, `UNTIL`, `IMMEDIATELY`, `EVENTUALLY`. *See §5, §6.*

### 4.4 Verdicts (7 = 4 core + 3 lifecycle)

| Kind | Value | Meaning |
|------|-------|---------|
| Core | `PASS` | Bound proof ran and succeeded |
| Core | `FAIL` | Bound proof ran and failed |
| Core | `BLOCKED` | Proof could not run (prereq/tool/env missing) |
| Core | `UNVERIFIED` | No acceptable proof bound or none executed |
| Lifecycle | `WAIVED` | A `FAIL`/`UNVERIFIED` accepted with named authority + reason + expiry |
| Lifecycle | `STALE` | Prior `PASS` whose evidence no longer matches the current source/surface hash |
| Lifecycle | `CONTRADICTED` | Two proofs disagree, or trace/code disagrees with the obligation |

Verdict line: `VERDICT <id>: <CORE> [(<lifecycle> by <authority>: <reason>)]`. **Merge gate:** merge iff every required obligation is `PASS` or `WAIVED`; none `STALE`/`CONTRADICTED`/`FAIL`/`BLOCKED`/`UNVERIFIED`. *See §14.*

### 4.5 Proof types (9, closed)

| Type | Notes |
|------|-------|
| `static` | resolves to `cmdLint`/`cmdTypecheck`/`cmdValidate` |
| `test` | scope qualifiers: `test:unit:`, `test:integration:`, `test:e2e:` |
| `contract` | **required** for every `INTERFACE` block |
| `property` | preferred for `INVARIANT` |
| `model` | model-checking or economical proof |
| `perf` | resolves to `cmdBenchmark` |
| `security` | integration-boundary commands |
| `manual` | the honest escape hatch |
| `monitor` | (was `runtime`) |

Binding clause: `VERIFY BY <type>:<adapter>:<artifact>[#selector]`. The `<adapter>` resolves through `AGENTS.md` > Commands (the `cmd*` placeholder slots are the adapters). Proof-strength order (CONTRADICTED tie-break): `model > property/contract > test > static > manual/monitor`. *See §15.*

### 4.6 Phases, passes, and improve operations

| Group | Members |
|-------|---------|
| **Phases (7, conceptual, fixed order)** | `PARSE → NORMALIZE → LOWER → EXECUTE → VERIFY → REVIEW → PROMOTE` |
| **Passes (9, schedulable, pipeline order)** | `author → lint → improve → lower → decompose → implement → verify → review → promote` |
| **Stdlib pass guides (5, first tooled — a subset)** | `lint`, `decompose`, `implement`, `review[profile: skeptic]`, `promote` |
| **Improve ops (10, closed, strictly semantics-preserving)** | `NORMALIZE · ATOMIZE · CONCRETIZE · QUANTIFY · BIND · SCOPE · CLARIFY · DECONFLICT · COMPRESS · PROMOTE` |

`decompose` is a **pass**, not an improve op. Any intent change routes to amendment/review, never to `improve`. *See §9 (phases/passes), §10 (improve ops).*

### 4.7 Artifact filenames

| Category | Files |
|----------|-------|
| Compiler-visible (`.swarm.` infix) | `*.swarm.md` (the source spec — the **only** human-authored `.swarm.` artifact) · `*.swarm.ir.json` (emitted IR) · `*.swarm.plan.json` (emitted plan) · `*.swarm.trace.md` (emitted trace) |
| Plain `.md` working artifacts | `task.md · review.md · finding.md · adr.md · audit.md · research.md · bug-report.md · memory/INDEX.md · memory/glossary.md · memory/patterns/*.md` |
| Kernel-required core templates (7) | `spec.swarm.md · task.md · trace.md · review.md · finding.md · adr.md · memory/INDEX.md` |

There is **no `verdict.md`**: `VERDICT` is a language block and `review.md` is its container. *See §20, §21.*

### 4.8 Lint namespace (one prefix, five layers)

`SOL-<LAYER><NNN>`, each layer a 100-block, append-only with tombstoning:

| Layer | Letter | Scope |
|-------|--------|-------|
| Syntax | `S` | Parser-detectable well-formedness |
| Prose | `P` | Controlled-prose / requirement-smell (the former APS layer; also absorbs old `SOL-L` codes) |
| Semantic | `M` | Cross-reference: duplicate id, contradiction, unbound ref |
| Verification | `V` | Proof-binding: missing / stale / non-observable proof |
| Orchestration | `O` | Planning / parallelism: write-conflict-marked-parallel, dep cycle, blocking QUESTION reaching lowering |

`APS-` is retired as a *code* prefix (APS survives only as the name of the prose standard). Every diagnostic record is `{code, severity, layer, span, message, suggest}`. *See §8, Appendix B.*

### 4.9 IR envelope

```json
{ "meta": {}, "nodes": [], "edges": [], "diagnostics": [], "provenance": {} }
```

| Component | Notes |
|-----------|-------|
| `edges[].type` | `depends_on · blocks · conflicts_with · verified_by · affects · implements · preserves` — the **single source of relationship truth** (relationships are NOT also node scalars) |
| `meta.language` | the SOL discriminator, e.g. `SOL/0.1` |
| `meta.version` | spec content version |
| `provenance.compiler_version` | tool version when one exists |

The three version fields are distinct and MUST NOT be merged. *See §12, Appendix C.*

### 4.10 Surface-vs-IR casing

| Surface (in `*.swarm.md`) | IR (in `*.swarm.ir.json`) |
|---------------------------|---------------------------|
| `VERIFY BY` | `verify_by` |
| `DEPENDS ON` | `depends_on` |
| `OWNED BY` | `owned_by` |
| `WRITES` | `writes` |
| `READS` | `reads` |
| `AFFECTS` | `affects` |
| surface id `AC-001` | IR node id MAY be `REQ.<spec>.AC-001` |

Surface = English-shaped UPPERCASE space-separated keywords. IR = snake_case. Lock groups are named `SURFACE`s (`SURFACE <name> = …`); there is **no `locks` primitive**. *See §5, §12, §18.*

### 4.11 Version axes (2)

| Axis | What it versions | Where it lives | Cadence |
|------|------------------|----------------|---------|
| **Language** | SOL+APS grammar, blocks, modals, lint codes | frontmatter `swarm_language: SOL/0.1` (+ `aps_version`); IR `meta.language` | Slow: `0.1`, `0.2`, `1.0` |
| **Framework / package** | scaffold, templates, pass guides, profiles | `.agents/.swarm-version` (semver) | Fast |

**One-way trigger:** any language change forces at least a framework MINOR release; the framework MAY release many versions without touching the language version. *See §25.*

### 4.12 The five invariants

| # | Name | One-line statement |
|---|------|--------------------|
| 1 | **No runtime** | Markdown-only; everything that "runs" is a contract a future tool builds against, never shipped. |
| 2 | **Soft vs hard control** | Prose/SOL/APS/skills/`AGENTS.md` are soft guidance; anything that must hold needs a deterministic check outside the model (today aspirational/manual). |
| 3 | **Surface-vs-IR layering** | Human surface = UPPERCASE space-separated keywords; IR = snake_case fields. |
| 4 | **Code is reality** | Code/tests can falsify an obligation but never silently amend intent. |
| 5 | **Schema-valid is not verified** | Shape is not truth; every completion claim maps to independent verification. |

*Specified in full in §2; consequences for the control lane in §17, for verification in §14–§15, for drift in §16.*
