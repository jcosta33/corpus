# Conformance

> Swarm's reference for conformance: what makes a repository Swarm-conformant (the four-clause definition), the inert conformance manifest that encodes it, and the five-tier maturity ladder for adoption progress.

Swarm is markdown-only and has **no runtime**. Nothing in this page executes. The "checker" that would consume a conformance manifest is a *contract* a future Swarm toolchain would build against — it is never shipped here. Until such a launcher exists, the same contract still serves: a human validates a repository against it by hand, and the golden corpus pins the expected verdicts independently of any tool.

This page answers two questions: *what makes a repository Swarm-conformant?* (a single binary predicate) and *how far along the adoption path is a repository?* (a five-tier ladder of diagnostic labels). The manifest is the inert, versioned data that encodes the mechanically checkable parts of the definition.

## The conformance definition

A repository is **Swarm-conformant if and only if** all four clauses hold. Omit any one and the repository MUST NOT be described as Swarm-conformant.

| # | Clause | Checkable evidence |
|---|---|---|
| (a) | **Language references present** | A self-contained copy of all six Tier-2 language/reference docs exists: the SOL reference, the APS reference, the lint/error taxonomy (the `SOL-<LAYER>NNN` catalogue), source-authority, the promotion protocol, and the distillation-loss-budget. |
| (b) | **The seven core templates exist** | A copyable template is present for each of the seven Tier-1 core artifacts — `spec.swarm.md`, `task.md`, `trace.md`, `review.md`, `finding.md`, `adr.md`, `memory/INDEX.md` — and each template satisfies its [source-artifact contract](source-artifacts.md). |
| (c) | **Populated `AGENTS.md` bootloader** | `AGENTS.md` exists (not an empty placeholder), stays within the density cap of ≤200 lines / ≤25 KB, and its `Commands` table binds at least the required command rows. |

(There is **no version-file clause** — per [ADR-0050](../adrs/0050-swarm-is-a-spec-repo-discipline.md) an adopted project keeps no per-repo version marker; the only load-bearing version is the per-spec `swarm_language` in frontmatter.) **Conformance is graded per role.** The clauses above describe a **spec / authoring repo** (where Swarm lives); a **code repo** that only *consumes* specs has a near-zero footprint — at most one opt-in skill, with Swarm scratch gitignored — and is not measured against (a)/(b).

A spec repo that fails a clause is **non-conformant**. Conditional artifacts (Tier 3 stdlib source-doc templates) and the reserved `.swarm.*.json` contract files are **not** required for conformance. Clauses (b)–(c) are the parts a manifest can mechanically encode; clause (a) is presence of the reference docs.

## The conformance contract (the manifest)

A Swarm repository ships a machine-readable conformance encoding under `starter-kit/.agents/conformance/`. It is **inert versioned data**: the precise, testable definition a future checker would honour, and the artifact a human uses to validate a repository by hand today. Per the no-runtime invariant, nothing under this directory executes — Swarm ships the contract, never the checker.

The conformance directory contains exactly three things:

| Path | Kind | Role |
|---|---|---|
| `starter-kit/.agents/conformance/conformance.yaml` | manifest (data) | the task-file schema, command rows, placeholder set, lint scheme, and required-suite matrix |
| `starter-kit/.agents/conformance/README.md` | prose | states inertness, provenance, and the "checker is deferred" framing |
| `starter-kit/.agents/conformance/fixtures/` | fixture suite | the golden corpus |

*Design rationale.* A contract is publishable and useful without a shipped tool: a static-analysis result format, for instance, is a versioned interchange schema that stands on its own, independent of whichever analyzer produces or consumes it. The conformance contract is, by the same logic, a framework artifact in its own right.

The manifest declares the `language` discriminator it targets (e.g. `SOL/0.1`) so a checker and the corpus reference one versioned definition. Its load-bearing sections are below.

### Task-file schema

The manifest encodes, as inert data, the structural and content rules a well-formed `task.md` satisfies, keyed to the [`task.md` template contract](source-artifacts.md):

- **Required sections** — the H2 headings that MUST be present: *Parent contract*, *Scope*, *Assigned obligations*, *Constraints and invariants*, *Implementation or pass trace*, *Verification matrix*, *Promotion queue*, *Self-review*.
- **Content rules** — chiefly:
  - `non-empty-paste` (on the *Verification matrix*): every required paste slot holds non-empty, non-placeholder text — a fenced command-output block, or `n/a` with a one-line reason — never a bare `[Paste output]` placeholder.
  - `no-open-critical`: no blocking `QUESTION` remains unresolved anywhere in the task when its frontmatter status is the terminal value `done`.

`non-empty-paste` closes the hallucinated-completion hole: a "tests passed" claim with no pasted output is an invalid proof — schema-valid output is not verification [[REFLEXION]](../research/sources.md#REFLEXION).

### Required command rows

`<adapter>` slots in SOL `VERIFY BY` bindings resolve through the `AGENTS.md > Commands` table; a binding whose adapter has no row is unresolvable. The manifest enumerates three tiers of `cmd*` slots:

| Tier | Slots | Conformance force |
|---|---|---|
| **required** | `cmdValidate`, `cmdTest`, `cmdFormat` | MUST be present; absence is non-conformant. These are the slots `VERIFY BY` adapters MUST be able to resolve. |
| **extended** | `cmdInstall`, `cmdTypecheck`, `cmdLint`, `cmdBuild`, `cmdValidateDeps`, `cmdBenchmark` | SHOULD be present when the project's required-suite references them, because an unbound adapter makes the suite unresolvable. |
| **out-of-contract** | `cmdMarkdownLint`, `cmdLinkCheck`, `cmdCitationCheck` | MAY be present; never required. |

### Legal placeholder set

Templates use placeholder tokens (e.g. `{{cmdTest}}`) that a runner substitutes. The manifest fixes the legal namespaces; a runner substitutes every required placeholder and leaves unrecognised ones untouched.

| Namespace | Example | Status |
|---|---|---|
| `cmd*` | `{{cmdValidate}}` | reserved; resolves to an `AGENTS.md > Commands` row; new `cmd*` names require an ADR |
| `""` (no prefix) | `{{title}}` | framework scaffolding names; reserved as above |
| `swarm:` | `{{swarm:version}}` | framework-owned values |
| `project:` | `{{project:name}}` | consumer-owned values; free to define |
| `vendor:` (any other prefix) | `{{vendor:frobnicate}}` | legal vendor extension; a runner leaves it untouched |

Introducing a new `cmd*` or no-prefix name without an ADR is non-conformant (the illegal-placeholder defect class).

### Lint scheme

The manifest carries the unified lint scheme as inert data so the checker and the corpus reference one namespace: a single prefix `SOL`, **five layers**, and the form `SOL-<LAYER>NNN`. Every diagnostic record has the shape `{code, severity, layer, span, message, suggest}`.

| Layer letter | Layer |
|---|---|
| `S` | SYNTAX |
| `P` | PROSE |
| `M` | SEMANTIC |
| `V` | VERIFICATION |
| `O` | ORCHESTRATION |

`APS` is the prose-standard's *name*, not a code prefix — APS violations surface as `SOL-P*` codes within the single unified `SOL` namespace. The full catalogue is the source of truth; the manifest only references it.

### Count acceptance checks (A10–A16)

The manifest's closed-set cardinalities are pinned as the **count acceptance checks A10–A16**: every closed set has exactly one cardinality, and a count that differs between any two documents (the SOL reference, the IR schema, the lint catalogue, the pass guides, and this manifest) is a failing check. The canonical members of each set are enumerated in the [flow graph](../reference/flow-graph.md) — the count-reconciliation hub — which this manifest shadows:

| Check | Closed set | Count |
|---|---|---|
| A10 | block types | 7 |
| A11 | modals | 5 |
| A12 | verdicts | 7 (4 core + 3 lifecycle) |
| A13 | proof types | 9 |
| A14 | phases / passes | 7 / 9 |
| A15 | improve operations | 10 |
| A16 | lint layers | 5 (S/P/M/V/O) |

## The required verification-suite matrix

The manifest also encodes the per-task-kind **required verification suite**: the proof-type/phase defaults that resolve to `cmd*` slots, so the question *"for a task of this kind, what proof MUST exist before it may merge?"* has one machine-readable answer. The canonical, human-readable matrix is the [flow graph](../reference/flow-graph.md) (the `(proof-type @ phase)` view); the manifest's `required_suite` is its shadow, with one row per task kind, resolving each recommendation to concrete adapter slots and named gates. The two MUST agree row-for-row.

Each entry in a row is one of three slot kinds:

| Slot kind | Form | Resolves to |
|---|---|---|
| **adapter slot** | `cmdTest`, `cmdValidate`, … | a `cmd*` row in `AGENTS.md > Commands`; an unbound adapter makes the suite unresolvable |
| **merged slot** | `merged:cmdValidate` | the same adapter, but run on the **post-integration merged result** (after workers' branches combine), not on a single worker's branch |
| **gate** | `gate:<name>` | an equivalence/coverage check, not a command — defined below |

The five gate tokens (defined here, mirrored by the flow graph):

- `acceptance-criteria-coverage` — every acceptance criterion of the obligation maps to a passing proof.
- `regression-test` — a test that failed before the change and passes after.
- `behaviour-preservation` — a property / differential / metamorphic check that the change preserves prior behaviour.
- `scope-disjointness` — the merged workers' OWNED paths are pairwise disjoint.
- `merge-intent` — each merge-conflict resolution preserves both obligations' intent.

### Per-task-kind rows

The manifest carries one row per `task_kind`. Representative rows (the full set mirrors the flow graph):

| `task_kind` | Required suite (adapter slots · gates) |
|---|---|
| `feature` | `cmdValidate`, `cmdTest`, `cmdValidateDeps`, `gate:acceptance-criteria-coverage` |
| `fix` | `cmdValidate`, `cmdTest`, `gate:regression-test` |
| `refactor` | `cmdValidateDeps`, `cmdTypecheck`, `cmdTest`, `gate:behaviour-preservation` |
| `orchestration` | `merged:cmdValidate`, `merged:cmdTest`, `gate:scope-disjointness`, `gate:merge-intent` |

The `orchestration` row is the one that uses `merged:` slots, because an orchestration task is *about* combining workers: its proofs run on the integrated whole, and its gates assert the workers were disjoint (`scope-disjointness`) and that conflict resolution preserved both sides' intent (`merge-intent`).

### Periodic vs post checks

A suite entry's *phase* (carried in the flow-graph view) fixes **when** the proof runs, and the entries fall into two timing classes:

- **Post checks** — the default. The proof runs once, *after* the change is made, at the obligation's bound phase (`cmdTest` at `VERIFY`, `gate:scope-disjointness` at `LOWER`, a `manual` judgement at `REVIEW`). Its verdict is a point-in-time fact about that change; `merged:` slots are post-checks deferred to post-*integration*.
- **Periodic checks** — a `monitor`-type binding. The proof is a standing runtime/production observation (logs, metrics, canary) that is re-sampled over time rather than settled once at merge. A periodic check's evidence has a freshness horizon: a previously-passing `monitor` binding whose observation window has lapsed is treated as `STALE`, not as a durable `PASS`.

The distinction matters for conformance because the `non-empty-paste` rule applies to *both*: a periodic check still binds to pasted observation evidence, never to a bare "monitored in production" claim. Per the no-runtime invariant, neither class executes here — a post check is a command a future toolchain would run once, and a periodic check is one it would re-sample on a schedule; today both are validated by a human reading the pasted evidence.

## The conformance maturity ladder

The definition above is a single *binary* predicate — the terminal judgement. But a repository adopting Swarm passes through observable intermediate states, and because adoption MAY be incremental, Swarm needs a vocabulary for "how far in" a repository is *without overloading the word conformant*. The **five-tier ladder** below answers that. Each tier is named, each is bound to checkable clauses already specified elsewhere on this page (the ladder introduces **no new obligations**), and each is a strict superset of the tier below it — a repository at tier *n* satisfies tiers `1..n`. The tiers are diagnostic labels for adoption progress; the only tier that coincides with the normative `Swarm-conformant` predicate is tier 4, **Swarm-verifiable**.

| Tier | Name | What it means | Bound to |
|---|---|---|---|
| **1** | **Swarm-readable** | The canonical structure is installed: a human or agent can read the repository as a Swarm repository. Nothing is yet checked for correctness. | Conformance clauses (a) and (b) hold — the six Tier-2 docs and seven Tier-1 templates are present and copyable. Clauses (c)/(d) MAY still be unmet. |
| **2** | **Swarm-lintable** | Authored specs are structurally and prose-valid: the obligation language parses and carries no blocking surface/prose defect. | Every approved `*.swarm.md` emits **zero blocking `SOL-S*` and zero blocking `SOL-P*`** diagnostics (blocking = the `severity` field's `BLOCKING` value, which lowers to IR `level` `error`). `SOL-M*`/`SOL-V*`/`SOL-O*` are not gated here. |
| **3** | **Swarm-compilable** | Approved specs can be lowered into tasks deterministically: every lowering precondition is present. | For every approved obligation: a stable ID, a proof binding (`VERIFY BY <type>:<adapter>:<artifact>` — a bare ref is advisory but a binding MUST exist), declared non-goals/scope, resolvable referenced `INTERFACE` blocks, and resolvable `DEPENDS ON` edges; and **no unresolved blocking `QUESTION` reaches lowering**. This is exactly the `lower`/`decompose` precondition set. |
| **4** | **Swarm-verifiable** | For implemented work, trace and review are complete and every completion claim is tied to evidence. | `trace.md` and `review.md` exist for the implemented obligations; each `IMPLEMENTS`/`PRESERVES`/`PROOF` claim carries content-hashed evidence and a core verdict; every completion claim binds to pasted proof output, never a bare "tests passed" claim (the `non-empty-paste` rule). |
| **5** | **Swarm-orchestratable** | Work can be partitioned across agents and sequenced safely: the static coordination contract is complete. | The orchestration coordination contract is fully satisfied: declared write surfaces (named `SURFACE`s — there is no `locks` primitive) with the safe-parallelism predicate holding (no `SOL-O001`), obligation IDs preserved across the source→execution tiers, the coordination hand-off fields (owned/forbidden paths, status, parent contract), liveness/stall states, and the promotion queue. |

**Tier 4 is the normative line.** A repository is *Swarm-verifiable if and only if it is Swarm-conformant* — tier 4 is exactly the four-clause definition at the top of this page. Tiers 1–3 below it and tier 5 above it are adoption labels, not the conformance predicate. The reserved label **Swarm-conformant** is the predicate name itself; it is not a sixth rung — it is the normative judgement that tier 4 coincides with, and a repository earns it by satisfying tier 4, never by satisfying tier 5 (which adds orchestration depth on top of, not in place of, conformance).

A repository MAY sit at any tier. Because adoption is incremental, tiers 3–5 are optional adoption *depth*, not a defect when unmet. When reporting a repository's standing, a tool or human SHOULD report the **highest fully-satisfied tier**, and MUST NOT report a higher tier than is fully satisfied — a partially satisfied tier is, within that tier, non-conformant. Per the no-runtime invariant, tier 5 certifies the *contract*, not a live scheduler; the scheduler is a deferred launcher concern.

## The toolchain boundary

The conformance contract, the suite matrix, and the ladder all describe artifacts a *future Swarm toolchain* would consume. That toolchain is not shipped here — per the no-runtime invariant, Swarm is markdown-only and the toolchain is a contract a future launcher builds against. This section fixes that contract's edges: the verb set the toolchain would expose, the boundary between the toolchain and the agent CLIs it would coordinate, and the adapter record a launcher binds to drive a worker.

The boundary is **design rationale**, not an empirical claim. It rests on two observations about how coding agents actually work: an orchestrator coordinates workers but does not replace them, and coding tasks parallelize poorly because actions carry implicit decisions that compound when fanned out — a single worker holding full context for its packet outperforms naive fan-out. The toolchain therefore **prepares and reconciles** obligation-bounded work; the agent CLI **performs the coding loop**. Swarm coordinates workers; it does not become one.

### The toolchain verb set

A future toolchain would expose this verb set. Each verb is a transformation a human or agent performs by hand today, following a pass guide; none executes here.

| Verb | Phase(s) it drives | What it would do |
|---|---|---|
| `init` | adoption | starter-kit/refresh the kernel payload into a project's `.swarm/kernel/` and adopt `AGENTS.md` |
| `lint` | PARSE, NORMALIZE | emit `SOL-<LAYER>NNN` diagnostics against a `*.swarm.md` source |
| `format` | NORMALIZE | apply the canonical surface form without changing intent |
| `improve` | NORMALIZE | apply intent-preserving spec edits (the closed improve-operation set) |
| `build-ir` | PARSE → NORMALIZE | emit the IR envelope (`*.swarm.ir.json`) |
| `lower` / `plan` | LOWER | emit the schedulable plan projection of the IR (`*.swarm.plan.json`) |
| `decompose` | LOWER | partition the plan into work packets, one per disjoint write surface |
| `verify` | VERIFY | run resolved `cmd*` adapters, record core verdicts + lifecycle decorators |
| `review` | REVIEW | assemble the review packet from trace + obligation set; record the verdict |
| `promote` | PROMOTE | apply the promotion protocol to findings; update `memory/INDEX.md` |

The checker that would consume `conformance.yaml` is itself part of this deferred surface (a `swarm conform`-class verb). Until a launcher exists the contract still serves: a human validates a repository against it by hand, and the golden corpus pins the expected verdicts independently of any tool.

### What the toolchain owns vs what the agent CLI owns

The toolchain owns the **intent-structure and reconciliation** lane — everything that prepares work from obligations and judges work against obligations. A future toolchain MUST scope itself here:

| The toolchain OWNS (prepare + reconcile) |
|---|
| `init`, `lint`, `format`, `improve`, `lower`, `decompose` |
| task generation (emitting generated task frames) |
| worktree creation (one worktree ↔ one task) and branch naming |
| agent-adapter invocation (launching an agent CLI as a worker) |
| trace validation, review preparation, merge gating |
| promotion handling, status reporting, drift detection |

It MUST NOT own the **model-execution** lane. These concerns belong to the agent CLI it invokes, never to Swarm:

| The agent CLI OWNS (perform the coding loop) |
|---|
| the LLM chat / conversation UI |
| the model reasoning loop |
| file-editing mechanics (how an agent reads, patches, writes files) |
| provider auth (model/provider credentials and token exchange) |
| the MCP runtime and the tool-calling runtime |
| prompt-streaming UX |

A toolchain that absorbed any model-execution concern would **become an agent CLI** — which the no-runtime invariant forecloses for this repo and which the boundary forbids for any future toolchain. The placement is the toolchain projection of the kernel's own scope: the [kernel owns a coordination contract, not a scheduler](../artifacts/task-orchestration.md), and a future toolchain owns the obligation boundary on either side of the coding loop, not the loop itself.

### The agent-CLI adapter contract

Claude Code, Codex, OpenCode, Aider, Cursor, and similar tools are **worker backends**. A future toolchain MAY invoke an existing agent CLI as a worker via a per-agent **adapter** — a documented record, not a running process this repo ships. The adapter has three load-bearing fields:

| Field | Meaning |
|---|---|
| `command` | the executable to launch the agent CLI |
| `working_directory` | MUST be the task's own worktree — the one-worktree-↔-one-task mapping |
| `startup_instruction` (startup probe) | the bootstrap pointer that aims the worker at `AGENTS.md` and its generated task frame |

```yaml
# Adapter contract (NOT SHIPPED). A documented record a future toolchain would consume.
agents:
  claude:
    command: claude
    working_directory: task_worktree
    startup_instruction: "Read AGENTS.md, then read the Swarm task file."
  codex:
    command: codex
    working_directory: task_worktree
    startup_instruction: "Read AGENTS.md, then read the Swarm task file."
  opencode:
    command: opencode
    working_directory: task_worktree
    startup_instruction: "Read the Swarm task file first."
```

The division of labour reduces to one rule: **Swarm prepares the work** (init / lower / decompose / task generation / worktree / branch / adapter invocation), **the agent CLI performs the coding loop** (the model loop, file edits, tool/MCP/provider runtime), and **Swarm validates trace / review / promotion**. This "prepare → delegate → reconcile" split is why Swarm MUST NOT become an agent CLI: the worker does the actual coding, and the entire surface of this section is a documented contract a future tool builds against, never shipped here.

> **Integrity.** `AGENTS.md`, the `.agents/` compatibility mirror, and `.swarm/config.yaml` are auto-loaded instruction/config surfaces, and the adapter `startup_instruction` propagates `AGENTS.md` into every worker — so the untrusted-source boundary applies to all of them: non-printing / bidirectional / homoglyph bytes are rejected (`SOL-S013`), and an externally-authored source is approval-required before it can govern.

## Related

- [SOL](../language/SOL.md) — the obligation language whose `VERIFY BY` bindings and `SURFACE`/`QUESTION` constructs the ladder tiers gate.
- [Errors](../language/errors.md) — the full `SOL-<LAYER>NNN` lint/error catalogue the manifest references.
- [APS](../language/APS.md) — the prose standard whose violations surface as `SOL-P*` codes.
- [Flow graph](../reference/flow-graph.md) — the human-readable required-verification-suite matrix the manifest shadows.
- [Source artifacts](source-artifacts.md) — the seven Tier-1 core artifacts and their template contracts.
- [Compiler pipeline](compiler-pipeline.md) — the `lower`/`decompose` lowering preconditions that tier 3 (Swarm-compilable) binds to.
- [Task orchestration](../artifacts/task-orchestration.md) — the static coordination contract the toolchain owns one side of (prepare/reconcile) and tier 5 (Swarm-orchestratable) binds to.
