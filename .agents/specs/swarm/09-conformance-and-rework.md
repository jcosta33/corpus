# Swarm Kernel Specification v0.1 — Part 09: Conformance and rework

<!-- Part 09 of the Swarm Kernel Specification (§32–§35). All parts share one section numbering (§0–§35 + Appendices A–G); cross-references of the form “§N” resolve via the index in [README.md](./README.md). -->

## 32. The conformance contract

### 32.1 Purpose and placement

This section specifies the machine-readable conformance encoding that a Swarm repository MUST ship under `scaffold/.agents/conformance/`. The encoding is **inert versioned DATA**: it is the precise, testable definition that a future checker would honour, and the artifact a human uses to validate a repository by hand today. Per Invariant 1 (NO RUNTIME, see §2), nothing under `scaffold/.agents/conformance/` executes; Swarm ships the contract, never the checker (§32.7).

The conformance directory MUST contain exactly:

| Path | Kind | Role |
|---|---|---|
| `scaffold/.agents/conformance/conformance.yaml` | manifest (data) | the task-file schema, command rows, placeholder set, lint scheme, required-suite matrix |
| `scaffold/.agents/conformance/README.md` | prose | states inertness, provenance, and the "checker is deferred" framing |
| `scaffold/.agents/conformance/fixtures/` | fixture suite | the golden corpus (§33) |

Rationale: ADR 0026 makes the conformance contract a framework artifact; SARIF precedent (an OASIS JSON-schema contract independent of any analyzer) establishes that a contract is publishable and useful without a shipped tool.

### 32.2 The conformance DEFINITION (restated from §20, normative)

A repository is **Swarm-conformant** if and only if it satisfies all four clauses below. This restates §20; §32 is the machine-readable encoding of clauses (b)–(d).

| # | Clause | Checkable evidence |
|---|---|---|
| (a) | **Language references present** | the kernel-required language/reference docs exist: SOL ref, APS ref, the lint/error taxonomy (`SOL-<LAYER>NNN`), source-authority, promotion-protocol, distillation-loss-budget |
| (b) | **The 7 core templates exist** | `spec.swarm.md`, `task.md`, `trace.md`, `review.md`, `finding.md`, `adr.md`, `memory/INDEX.md` are present as copyable templates |
| (c) | **Populated `AGENTS.md` bootloader** | `AGENTS.md` exists, is ≤200 lines / ≤25 KB, and its `Commands` table binds at least the required command rows (§32.4) |
| (d) | **version file present** | the framework/package version file exists with a valid semver — `scaffold/.agents/.swarm-version` (framework-dev) or `.swarm/VERSION` (adopted project, §20.5.1) (ADR 0015) |

A repo that fails any clause is **non-conformant**. The checker (§32.7) consumes this definition; the `conformance.yaml` manifest encodes the mechanically-checkable parts of (b)–(d).

### 32.3 The task-file schema (`conformance.yaml > task_file`)

The manifest MUST encode, as inert data, the structural and content rules a well-formed `task.md` satisfies. The schema is keyed to the §21 `task.md` template.

```yaml
# conformance.yaml — task-file schema (excerpt; inert data, Swarm runs nothing)
version: 0.1.0
language: SOL/0.1                 # the discriminator this manifest targets (§25, meta.language)
task_file:
  required_sections:             # H2 headings that MUST be present (the §21.3.1 task.md contract)
    - Parent contract
    - Scope
    - Assigned obligations
    - Constraints and invariants
    - Implementation or pass trace
    - Verification matrix
    - Promotion queue
    - Self-review
  content_rules:
    - id: non-empty-paste
      applies_to: "Verification matrix"
      rule: >-
        every required paste slot holds non-empty, non-placeholder text — a fenced
        command-output block, or `n/a` with a one-line reason — never a bare
        `[Paste output]` placeholder.
    - id: no-open-critical
      applies_to: "(whole task: frontmatter status + any QUESTION block)"
      rule: "no blocking QUESTION remains unresolved anywhere in the task when frontmatter status is the terminal value done."
```

A conformant `task.md` MUST present every `required_sections` heading and MUST satisfy every `content_rules` entry. `content_rules.non-empty-paste` is the single most load-bearing rule: it surfaces the hallucinated-completion hole (a "tests passed" claim with no pasted output is an invalid proof, per §15 and Invariant 5 — schema-valid output is NOT verification).

### 32.4 Required command rows (`conformance.yaml > agents_md`)

The manifest MUST enumerate the `AGENTS.md > Commands` rows a conformant repo binds. `<adapter>` slots in SOL `VERIFY BY` bindings resolve through this table (§15); a binding whose adapter has no row is unresolvable.

```yaml
agents_md:
  required_command_rows: [cmdValidate, cmdTest, cmdFormat]
  extended_command_rows: [cmdInstall, cmdTypecheck, cmdLint, cmdBuild, cmdValidateDeps, cmdBenchmark]
  out_of_contract:       [cmdMarkdownLint, cmdLinkCheck, cmdCitationCheck]
```

| Tier | `cmd*` slots (§31.3) | Conformance force |
|---|---|---|
| required | `cmdValidate`, `cmdTest`, `cmdFormat` | MUST be present; absence is non-conformant. These are the `cmd*` slots that VERIFY BY adapters in §15.3 MUST be able to resolve. |
| extended | `cmdInstall`, `cmdTypecheck`, `cmdLint`, `cmdBuild`, `cmdValidateDeps`, `cmdBenchmark` | SHOULD be present when the project's required-suite (§32.6) references them BECAUSE an unbound adapter makes the suite unresolvable |
| out-of-contract | `cmdMarkdownLint`, `cmdLinkCheck`, `cmdCitationCheck` | MAY be present; never required |

For the full `cmd*` slot vocabulary and resolver contract see §31.3 and §15.3.

### 32.5 The legal placeholder set (`conformance.yaml > placeholders`)

Templates use placeholder tokens (e.g. `{{cmdTest}}`) that a runner substitutes. The manifest MUST encode the legal placeholder namespaces.

```yaml
placeholders:
  legal_prefixes: ["cmd", "", "swarm:", "project:"]   # "" = framework scaffolding names
  rule: >-
    a runner substitutes every required placeholder and leaves unrecognised ones
    untouched; it does not introduce names in the cmd*/no-prefix namespace without an ADR.
```

| Namespace | Example | Status |
|---|---|---|
| `cmd*` | `{{cmdValidate}}`, `{{cmdTest}}` | reserved; resolves to an `AGENTS.md > Commands` row; new `cmd*` names require an ADR (ADR 0005/0018) |
| `""` (no prefix) | `{{title}}`, `{{slug}}` | framework scaffolding names; reserved as above |
| `swarm:` | `{{swarm:version}}` | framework-owned values |
| `project:` | `{{project:name}}` | consumer-owned values; free to define |
| `vendor:` (any other prefix) | `{{vendor:frobnicate}}` | legal vendor extension; a runner leaves it untouched |

A template introducing a new `cmd*` or no-prefix name without an ADR is non-conformant (illegal-placeholder class, §33).

### 32.6 The unified lint scheme and required-suite matrix

The manifest MUST encode the unified lint scheme (§8) as inert data so the checker and corpus reference one namespace: a single prefix `SOL`, five layers, form `SOL-<LAYER>NNN`. Every diagnostic record has the shape `{code, severity, layer, span, message, suggest}`.

```yaml
lint:
  scheme: "SOL-<LAYER>NNN"
  layers: { S: SYNTAX, P: PROSE, M: SEMANTIC, V: VERIFICATION, O: ORCHESTRATION }
  record_shape: [code, severity, layer, span, message, suggest]
  catalogue_ref: docs/language/errors.md      # the full catalogue is the source of truth (Appendix B)
  retired_prefixes: [APS-]                     # APS- is no longer a code prefix
```

The manifest MUST also encode the per-task-type required verification suite (the `(proof-type, phase)` defaults of §15, resolving to `cmd*` slots). The canonical matrix lives in `docs/reference/flow-graph.md`; the manifest is its machine-readable shadow. Bare entries are `cmd*` adapter slots (§31, resolved through `AGENTS.md > Commands`); `gate:<name>` entries are equivalence/coverage gates whose checks `flow-graph.md` defines (`acceptance-criteria-coverage`, `regression-test`, `behaviour-preservation`, `scope-disjointness`, `merge-intent`); a `merged:` prefix means the slot runs on the post-integration merged result.

```yaml
required_suite:
  feature:            [cmdValidate, cmdTest, cmdValidateDeps, gate:acceptance-criteria-coverage]
  fix:                [cmdValidate, cmdTest, gate:regression-test]
  refactor:           [cmdValidateDeps, cmdTypecheck, cmdTest, gate:behaviour-preservation]
  # … one row per task_kind; full matrix mirrors flow-graph.md …
  orchestration:      [merged:cmdValidate, merged:cmdTest, gate:scope-disjointness, gate:merge-intent]
```

### 32.7 The CLI command surface and the toolchain↔agent-CLI boundary (documented contract only, not shipped)

Swarm documents the verb set a future **Swarm toolchain** would expose. Per Invariant 1 (NO RUNTIME), this is **what a future toolchain would expose**, never **a tool Swarm provides**: the surface is a contract a future launcher builds against, and until one exists a human validates a repo against it by hand. The surface MUST appear in `docs/language/` as a one-page "tooling contract (not shipped)" note carrying that banner.

This subsection fixes the boundary between that Swarm toolchain and the **agent CLIs** it would coordinate. The boundary is **design rationale**, grounded in two empirical anchors: an orchestrator coordinates workers, and coding tasks parallelize poorly and need shared context `[ANTHROPIC-MA]`; and a single-threaded worker holding full context outperforms naive fan-out, because actions carry implicit decisions and conflicting decisions compound `[COGNITION]`. The toolchain therefore **prepares and reconciles** work; the agent CLI **performs the coding loop**. Swarm coordinates workers; it does not replace them.

#### 32.7.1 The verb set the toolchain would drive

| Verb | Phase(s) it would drive | Documented contract |
|---|---|---|
| `init` | (adoption) | install/refresh the kernel payload into a project's `.swarm/kernel/` and adopt `AGENTS.md` (the framework ships the payload under `scaffold/`; see §20.0) |
| `lint` | PARSE, NORMALIZE | emit `diagnostics[]` of `SOL-<LAYER>NNN` records against a `*.swarm.md` source |
| `format` | NORMALIZE | apply the canonical surface form (§4.10) without changing intent (§28 pure-normalization class) |
| `improve` | AUTHOR/IMPROVE | apply intent-preserving edits (the `improve` pass predicate, §32 acceptance set) |
| `build-ir` | PARSE → NORMALIZE | emit `*.swarm.ir.json` (the §12 envelope) |
| `lower` / `plan` | LOWER | emit `*.swarm.plan.json` (the §13 plan): the schedulable projection of the IR |
| `decompose` | LOWER → DECOMPOSE | partition the plan into work packets, one per disjoint write surface (§18) |
| `verify` | VERIFY | run resolved `cmd*` adapters, record core verdicts + lifecycle decorators |
| `review` | REVIEW | prepare the review packet from trace + obligation set; record the §14 verdict |
| `promote` | PROMOTE | apply the §23 promotion protocol to findings; update `memory/INDEX.md` |

```text
# Tooling contract (NOT SHIPPED). Swarm is markdown-only (Invariant 1).
# This is the surface a future Swarm toolchain would build against, not a tool Swarm provides.
swarm init                                 -> install/refresh .swarm/kernel/ + AGENTS.md
swarm lint      <spec>.swarm.md            -> diagnostics[] (SOL-<LAYER>NNN)
swarm format    <spec>.swarm.md            -> canonical surface form (intent-preserving)
swarm improve   <spec>.swarm.md            -> intent-preserving edits
swarm build-ir  <spec>.swarm.md            -> <spec>.swarm.ir.json
swarm lower     <spec>.swarm.ir.json       -> <spec>.swarm.plan.json
swarm decompose <spec>.swarm.plan.json     -> work packets (1 per disjoint write surface)
swarm verify    <task>.md                  -> verdicts (core + lifecycle)
swarm review    <task>.md                  -> review packet + §14 verdict
swarm promote   <finding>.md               -> memory/INDEX.md update
```

The checker that would consume `conformance.yaml` is itself part of this deferred surface (a `swarm conform`-class verb). Until a launcher exists, the contract still serves: a human validates a repo against it by hand, and the fixtures (§33) pin the expected verdicts independently of any tool.

#### 32.7.2 What the Swarm toolchain OWNS

The toolchain owns the **intent-structure and reconciliation** lane: everything that prepares work from obligations and judges work against obligations. A future toolchain MUST scope itself to these concerns:

```text
init                  install/refresh the kernel payload into .swarm/kernel/
lint                  emit SOL-<LAYER>NNN diagnostics against a .swarm.md source
format                apply the canonical surface form without changing intent
improve               apply intent-preserving spec edits
lower                 project the IR into a schedulable plan
decompose             partition the plan into disjoint-surface work packets
task generation       emit generated task frames under .swarm/generated/tasks/
worktree creation     create the per-task worktree (one worktree ↔ one task)
branch naming         derive the branch name from spec/task context
agent-adapter invocation   launch an agent CLI as a worker via its adapter (§32.7.4)
trace validation      check the emitted trace against assigned obligations (§15)
review preparation     assemble the review packet from trace + obligation set
promotion handling     apply the §23 promotion protocol to durable findings
status reporting       report observed satisfaction/drift (.swarm/status/)
drift detection        would detect declared-write content-hash staleness (§16, §23.3)
merge gating          would gate via the §14.4 merge gate before a task may merge
```

This is **design rationale**, not an empirical claim: it places the toolchain exactly where a spec-driven framework adds value — at the obligation boundary on either side of the coding loop. It is the contract analogue of the kernel's own scope (§18.1: the kernel owns a coordination contract, not a scheduler).

#### 32.7.3 What the Swarm toolchain does NOT own

The toolchain MUST NOT own the **model-execution** lane. These concerns belong to the agent CLI it invokes as a worker, never to Swarm:

```text
the LLM chat / conversation UI
the model reasoning loop
agent file-editing mechanics (how an agent reads, patches, writes files)
provider auth (model/provider credentials and token exchange)
the MCP runtime
the tool-calling runtime
prompt-streaming UX
```

A Swarm toolchain that absorbed any of the above would **become an agent CLI** — which Invariant 1 (NO RUNTIME) forecloses for this repo and which the boundary forbids for any future toolchain. The rationale is empirical: coding tasks are mostly *not* parallelizable and need shared context, so the value of a coordinator is in framing and reconciliation, not in re-implementing the worker's reasoning loop `[ANTHROPIC-MA]`; and a single-threaded agent that holds full context is the unit that performs the loop well `[COGNITION]`. Swarm MUST NOT become an agent CLI.

#### 32.7.4 Agent CLIs are worker backends (the adapter contract)

Claude Code, Codex, OpenCode, Aider, Cursor, and similar tools are **worker backends**. A future Swarm toolchain MAY invoke an existing agent CLI as a worker via a per-agent **adapter** — a documented record, not a running process this repo ships. The adapter has three load-bearing fields: the `command` to launch, a `working_directory` that MUST be the task's own worktree (the one-worktree-↔-one-task mapping of §19/§32.7.2), and a `startup_instruction` that points the worker at `AGENTS.md` and its generated task frame.

```yaml
# Adapter contract (NOT SHIPPED). Documented record a future toolchain would consume.
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
  aider:
    command: aider
    working_directory: task_worktree
    startup_instruction: "Read the Swarm task file first."
```

The division of labor is fixed by one rule:

```text
Swarm prepares the work.    (init/lower/decompose/task generation/worktree/branch/adapter invocation)
The agent CLI performs the coding loop.    (the model loop, file edits, tool/MCP/provider runtime — §32.7.3)
Swarm validates trace / review / promotion.    (trace validation/review prep/merge gate/promotion — §32.7.2)
```

This "prepare → delegate → reconcile" split is the toolchain projection of the kernel's static coordination contract (§18.1, §19): the orchestrator coordinates workers but does not perform their work `[ANTHROPIC-MA]`, and each worker runs single-threaded with full context for its packet `[COGNITION]`. Because the worker performs the actual coding loop, **Swarm MUST NOT become an agent CLI**; it remains a toolchain that prepares and reconciles obligation-bounded work, and the entire surface of this subsection is a documented contract a future tool builds against, never shipped here (Invariant 1).

> **Integrity (→ §17.5).** `AGENTS.md`, the `.agents/` compatibility mirror, and `.swarm/config.yaml` are auto-loaded instruction/config surfaces, and the adapter `startup_instruction` above propagates `AGENTS.md` into every worker — so the untrusted-source boundary of §17.5 applies to all of them: non-printing / bidirectional / homoglyph bytes are rejected (`SOL-S013`), and an externally-authored source is approval-required before it can govern (§17.5.2).

### 32.8 Conformance maturity ladder

§32.2 / §20.4 give conformance as a single binary predicate. That predicate is the *terminal* judgement, but a repository adopting Swarm passes through observable intermediate states, and the incremental-adoption stance (a repo MAY install the kernel incrementally) needs a vocabulary for "how far in" a repository is without overloading the word *conformant*. This subsection defines a five-tier ladder. Each tier is named, each is BOUND to checkable clauses already specified elsewhere in this document (so the ladder introduces no new obligations), and each is a strict superset of the tier below it — a repository at tier *n* satisfies tiers `1..n`. The tiers are diagnostic labels for adoption progress; the only tier that coincides with the normative `Swarm-conformant` predicate is **Swarm-verifiable** (tier 4), stated explicitly below.

| Tier | Meaning | Minimum acceptance criteria |
|---|---|---|
| **1 — Swarm-readable** | The canonical structure is installed: a human or agent can read the repository as a Swarm repository. Nothing is yet checked for correctness. | The six Tier-2 language/reference docs (§20.3.2) and the seven Tier-1 core templates (§20.3.1) are present and copyable — i.e. acceptance checks `A3`/`A5` (§34.2) pass and clauses (a)/(b) of §32.2 hold. Equivalent to conformance-definition clauses (a) and (b) satisfied; clauses (c)/(d) MAY still be unmet. |
| **2 — Swarm-lintable** | Authored specs are structurally and prose-valid: the obligation language parses and carries no blocking surface/prose defect. | Every approved `*.swarm.md` emits **zero blocking `SOL-S*` and zero blocking `SOL-P*`** diagnostics (§8; the `SOL-<LAYER>NNN` scheme of §32.6), where *blocking* is the `ERROR` severity field. `SOL-M*`/`SOL-V*`/`SOL-O*` are not gated at this tier. (`APS` is the prose-standard NAME, not a code prefix — its violations surface as `SOL-P*`.) |
| **3 — Swarm-compilable** | Approved specs can be lowered into tasks deterministically: every lowering precondition is present. | For every approved obligation: a stable ID (`AC-NNN`/`C-NNN`/`I-NNN`/`IF-NNN`, §4), a proof binding (`VERIFY BY <type>:<adapter>:<artifact>`, §15 — a bare ref is advisory but a binding MUST exist), declared non-goals/scope, the referenced `INTERFACE` blocks, and `DEPENDS ON` edges resolve; **no unresolved blocking `QUESTION` reaches lowering** (the `SOL-O003` blocking-QUESTION-at-lowering check, §33.3.3). This is exactly the `lower`/`decompose` pass precondition set (§13). |
| **4 — Swarm-verifiable** | For implemented work, trace and review are complete and every completion claim is tied to evidence. | `trace.md` and `review.md` exist for the implemented obligations; each `IMPLEMENTS`/`PRESERVES`/`PROOF` claim carries content-hashed evidence and a core verdict (§15); every completion claim binds to pasted proof output, never a bare "tests passed" claim (the `content_rules.non-empty-paste` rule, §32.3; Invariant 5 — schema-valid ≠ verified). **This tier is, exactly, the §20.4 / §32.2 `Swarm-conformant` if-and-only-if definition**: a repository is Swarm-verifiable iff it is Swarm-conformant. The tiers above (5) and below (1–3) are adoption labels; tier 4 is the normative line. |
| **5 — Swarm-orchestratable** | Work can be partitioned across agents and sequenced safely: the static coordination contract is complete. | §18 and §19 are fully satisfied: declared write surfaces (named `SURFACE`s, no `locks` primitive, §18.3) with the safe-parallelism predicate holding (no `SOL-O001`, §18.5/§18.7); preserved obligation IDs across the source→execution tiers; the §19 coordination-artifact hand-off fields (owned/forbidden paths, status, parent contract); liveness/stall states; and the promotion queue (§23). Per Invariant 1 (NO RUNTIME) this tier certifies the *contract*, not a live scheduler — the scheduler is a deferred launcher concern (§35.1 N5). |

A repository MAY sit at any tier; the incremental-adoption stance means tiers 3–5 are optional adoption depth, not a defect when unmet. A tool or human reporting a repository's standing SHOULD report the highest fully-satisfied tier (see the §34.7 replacement below), and MUST NOT report a higher tier than is fully satisfied BECAUSE a partially-satisfied tier is, within that tier, non-conformant (§34.7).

## 33. The golden corpus

### 33.1 Purpose and placement

The golden corpus is the conformance suite that pins expected verdicts **independent of any tool**, satisfying compiler-conformance practice (SuperTest/OpenJDK/SpecTest: a suite needs both allowed and disallowed productions whose conformity is known without the tool under test). It MUST ship in two locations:

| Location | Holds | Audience |
|---|---|---|
| `scaffold/.agents/conformance/fixtures/` | positive + negative fixtures with expected verdicts | the checker's regression suite (§32) |
| `docs/examples/` | the three pipeline-complete positive walkthroughs | human readers / authors learning the pipeline |

The corpus is built on the three recurring domains — **auth-refresh**, **checkout**, **payment-5xx** — each with positive (must-compile) and negative (must-be-rejected) fixtures.

### 33.2 The full pipeline chain (every positive fixture)

Each positive domain fixture MUST ship the complete pipeline chain, one file per stage, so the corpus exercises the whole `intent → promotion` arc:

```text
spec.swarm.md  →  expected obligation list  →  task frame  →  trace  →  verdict  →  promotion
```

| Stage | Fixture file | Asserts |
|---|---|---|
| source spec | `<domain>.swarm.md` | parses clean; only `MUST`-class modals; INVARIANT present |
| expected obligations | `<domain>.expected-obligations.md` | the obligation list a correct `build-ir` would emit (ids, kinds, edges) |
| task frame | `<domain>.task.md` | assigned obligations, write surfaces, verification bindings |
| trace | `<domain>.swarm.trace.md` | `IMPLEMENTS`/`PRESERVES`/`PROOF` claims with content hashes |
| verdict | `<domain>.review.md` | per-obligation `VERDICT` blocks; final verdict reaches the merge gate |
| promotion | `<domain>.finding.md` | the durable finding the pass promotes |

The expected end-state verdict is recorded in the spec fixture's header and is known independent of any tool.

### 33.3 Canonical defect class per domain

Each domain carries one canonical defect class (or small cluster), encoded with unified `SOL-<LAYER>NNN` codes (§8). The positive variant proves the obligation the negative violates.

#### 33.3.1 auth-refresh — dangling condition, SHOULD-without-BECAUSE, missing verification

| Variant | Construct | Expected |
|---|---|---|
| negative | dangling condition (trigger with no modal consequence) | reject, `SOL-S001` |
| negative | `SHOULD` with no `BECAUSE`/`EXCEPT` | reject, `SOL-S006` |
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

#### 33.3.2 checkout — bundled obligation atomized, write-surface conflict marked parallel

| Variant | Construct | Expected |
|---|---|---|
| negative | one REQ bundling multiple obligations | reject, `SOL-P004`; `ATOMIZE` repair |
| negative | two obligations sharing a write surface marked parallel | reject, `SOL-O001` |
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

The positive variant splits `AC-010` into three single-obligation REQs and gives `AC-011`/`AC-012` disjoint write surfaces (or a `DEPENDS ON` edge serializing them), satisfying the §18 safe-parallelism predicate.

#### 33.3.3 payment-5xx — blocking QUESTION, MUST-vs-MUST-NOT contradiction, high-risk word

| Variant | Construct | Expected |
|---|---|---|
| negative | a `blocking` `QUESTION` still unresolved at lowering | reject, `SOL-O003` (orchestration; blocking QUESTION reaching lowering) |
| negative | `MUST` and `MUST NOT` on the same trigger | reject, `SOL-M002` (contradiction) |
| negative | "handle failures gracefully" with no observable criterion | reject, `SOL-P005` (vague-quality high-risk word) |
| positive | the QUESTION resolved, contradiction deconflicted, the vague clause concretized | PASS |

```sol
# payment-5xx.swarm.md — NEGATIVE (expected: REJECTED)

QUESTION Q-001: blocking
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

### 33.4 Negative fixtures: task-file classes and one syntax negative per error family

Beyond the domain defects, the corpus MUST include the ADR 0026 task-file classes and one SOL syntax negative per error-code family.

| Class | Fixture | Rule broken | Expected |
|---|---|---|---|
| empty paste | a `task.md` whose `Verification outputs` slots are bare | `content_rules.non-empty-paste` | FAIL |
| missing required verification slot | a `refactor` task with no `behaviour-preservation` evidence | `required_suite.refactor` | FAIL |
| illegal placeholder | a template introducing `{{cmdFrobnicate}}` without an ADR | `placeholders.rule` | FAIL |
| missing `Commands` row | an `AGENTS.md` omitting `Format` | `agents_md.required_command_rows` | FAIL |
| unresolved blocking QUESTION at close | `status: done` with an open blocking QUESTION | `content_rules.no-open-critical` | FAIL |

Additionally, the corpus MUST ship at least one minimal syntax negative for each `SOL-S` error family (e.g. `SOL-S001` dangling condition, `SOL-S003` actor clause with no modal, `SOL-S005` prefix↔type mismatch, `SOL-S006` SHOULD-without-BECAUSE), so every error-code family has a guarding fixture.

### 33.5 Prose precision/recall baseline (G12)

The `SOL-P` prose rules are heuristic and so carry a measurable false-positive risk. The corpus MUST ship a **labeled good/bad prose fixture set** so the high-risk-word list's accuracy is measurable. The baseline targets are normative for v0.1:

| Metric | Target | Meaning |
|---|---|---|
| precision | ≥ 0.90 | of spans a `SOL-P` rule flags, ≥90% are true defects (few false positives) |
| recall | ≥ 0.85 | of true prose defects present, ≥85% are flagged (few misses) |

For honest calibration: field deployments of lightweight requirement-smell detection report only ≈59% average precision at ≈82% average recall, with high variation (prototype Smella, three industrial contexts [SMELLS]). The ≥0.90/≥0.85 figures above are **gold-corpus** targets — a curated, labeled fixture is a more controlled setting than open field text — so the corpus MUST be curated to that standard rather than assuming a generic heuristic run reaches it.

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

The labeled set lets a future linter's precision/recall be computed against ground truth without running on production specs; until a linter exists, the labels document the intended accuracy bar. Because the `SOL-P` grader is itself an LLM judge today (not a deterministic detector), the gold set MUST record an inter-annotator agreement floor (Cohen's κ ≥ 0.6), and these targets are measured against that gold set — never asserted of an LLM grader at runtime: single-judge scores are not internally reliable and SHOULD be replicated/aggregated `[TRUSTJUDGE]` (strong judges reach ~80% agreement with humans `[MTBENCH]`). The deterministic `SOL-S` family is exempt from this caveat; only the heuristic `SOL-P` family needs it.

### 33.6 Pass-output rubrics

The fixtures of §33.1–§33.5 pin *what a correct pipeline produces*; the **pass-output rubrics** are the scoring criteria the eval suite (this §33) runs *against a candidate pass's actual output* to decide whether the agent-as-compiler performed the pass correctly. They exist because schema-validity is not correctness (Invariant 4, §2): a `task.md` can be perfectly well-formed and still drop an obligation; a `review.md` can carry every required `VERDICT` block and still be summary-only. Each rubric is therefore a small set of **checkable predicates** — boolean assertions over the pass's output keyed to that pass's output contract (§9.3) — and **NOT** a Likert/quality score. A predicate either holds or does not; the eval suite reports the count of failing predicates per pass, and a single failing predicate fails the pass. These rubrics grade *compiler behaviour* (did the transformation preserve the obligations, bindings, scopes, and verdicts it was contracted to preserve), not grammar (which §33.4 and the `SOL-S###` family already cover).

Every predicate below is decidable against the pass's input artifact plus its output artifact alone — no runtime, no tool under test is presumed. A future eval harness MAY automate them; today a reviewer checks them by hand against the fixtures. Where a predicate restates a normative rule from elsewhere in this spec, the source section is cited; the rubric is the *measurement*, the cited section is the *law*.

| Pass | Output-grading predicates (each MUST hold; any failing predicate fails the pass) |
| --- | --- |
| `author` | **Source fidelity:** every obligation in the draft `spec.swarm.md` traces to an upstream source span (chat, `research.md`, `audit.md`, `bug-report.md`) or is marked an explicit authoring decision; no behavior is invented and presented as sourced fact. **Stance preserved:** an observation-only source (`audit`/`research`) is not silently rendered as intent — it appears as a re-stated obligation with its own id, modality, and binding, never as borrowed prose (§24.4). **Uncertainty surfaced:** every behavioral ambiguity in the source is lifted to a `QUESTION` block or an explicit interpretation, not buried in prose. |
| `lint` | **Parse-validity decided:** every `SOL-S###` well-formedness defect present in the fixture is reported with its correct code and span; zero false "clean" on a known-defective fixture. **Blocking recall complete:** every blocking `SOL-S`, `SOL-M`, `SOL-V`, and blocking `SOL-P` (the position-sensitive binding-clause rules, §8) in the fixture is detected — a missed blocking defect fails the pass. **Non-mutating:** the spec text and semantics are byte-identical to the input (lint MUST NOT rewrite, §9.3.1); any edit fails the pass. **Severity-correct:** each diagnostic's `severity` field matches the catalogue, and an advisory-in-commentary code is not reported as blocking (§8). |
| `improve` | **Intent preserved:** no edit changes the **actor, trigger/state, modality, response, non-goal, or interface** of any obligation — the only approval-free semantic-diff class is *pure normalization* (§10.1, R-IMPROVE; the semantic-diff classes graded under `review` below). **No distillation loss:** no obligation id, modality, or `VERIFY BY` binding is dropped or weakened by a "cleanup" (§24.2). **Closed operation set:** every edit is attributable to one of the ten operations (§10.2); an edit outside the set fails the pass. **Lint answered, not masked:** each blocking lint code the input carried is either resolved by its mapped operation or carried forward — none is silently deleted while the defect remains. **Escalation honored:** any edit the author flags as intent-changing is routed to amendment with `requires approval: yes`, never applied as improve (§10.1). |
| `lower` | **Total obligation preservation:** every `REQ`/`CONSTRAINT`/`INVARIANT`/`INTERFACE` obligation of the approved spec appears as an IR node with its id, modality, actor, trigger, and response intact (§11.4) — a dropped obligation, modality, or binding is a distillation error and a hard fail (§24.2). **Binding preservation:** every `VERIFY BY` binding survives onto its obligation; none is lost in lowering. **Authority preserved:** each obligation's domain/artifact authority and `WRITES`/`READS`/`AFFECTS` scope survives (§22, §18). **Halts on blocker:** the pass produces NO IR when a blocking diagnostic or a blocking `QUESTION` remains unresolved — emitting a lowered graph past an open blocking `QUESTION` is an orchestration error (`SOL-O003`, §9.3.1, §11.4) and fails the pass. **Edges sound:** every emitted dependency edge derives from a `DEPENDS ON`, a shared interface, or a preserved constraint/invariant — no invented edge. |
| `decompose` | **Write-disjoint packets:** task scopes planned to run in parallel have disjoint `WRITES` surfaces; any shared write surface without a serializing `DEPENDS ON` edge is a `SOL-O001` and fails the pass (§18). **Dependency-ordered:** the task partition respects the obligation DAG — no task is ordered before a task it depends on, and the partition contains no cycle. **Total coverage:** every lowered obligation is assigned to exactly one task; an unassigned or doubly-owned obligation fails the pass. **Ownership ⊆ writes:** each task's `OWNED` set is a subset of its declared `WRITES` (the lowering tie, `SOL-O005`, §19.7). **Context complete:** each `task.md` carries its exact assigned obligation blocks, preserved constraints/invariants, and verification bindings — not paraphrases. |
| `implement` | **Scope-faithful:** the diff changes only files inside the task's declared `WRITES` surface; any out-of-scope change is an unauthorized change and fails the pass. **Obligation coverage:** the trace records an `IMPLEMENTS` claim for every assigned obligation and a `PRESERVES` claim for every preserved constraint/invariant. **Trace honesty:** each TRACE claim names the changed files and a `PROOF` artifact; the claimed scope is not narrower than the diff actually touches (the unauthorized-change probe, §16). **No premature completion:** the trace does not assert an obligation done with no evidence gathered. |
| `verify` | **Proof-result completeness:** every **required** `VERIFY BY` binding has exactly one core verdict (`PASS`/`FAIL`/`BLOCKED`/`UNVERIFIED`); a required binding with no verdict is `SOL-V008` and fails the pass (§15.7). **No unverifiable completion claim:** no obligation is reported satisfied on a binding that resolved to no proof artifact — a green-but-unbound claim is rejected (schema-valid ≠ verified, Invariant 4). **Adapter-resolved:** each binding's adapter resolved through `AGENTS.md > Commands` (§15.2); an unresolved adapter yields `UNVERIFIED`, not a silent `PASS`. **Provenance recorded:** each verdict cites the proof type and artifact it ran, so the result is reconstructable. |
| `review` | **Verdict completeness:** every **required** obligation carries a `VERDICT` in `review.md` (§14, §15.7); a required obligation with no verdict fails the pass. **Verdict-correctness:** each core verdict matches the recorded evidence (a `PASS` over `FAIL`-evidence, or a `PASS` with no proof, fails), and lifecycle decorators (`WAIVED`/`STALE`/`CONTRADICTED`) are applied where their condition holds. **Sceptical independence:** the review judges trace claims against the source spec, the diff, and the proof evidence — not against the trace's self-report; a verdict justified only by the implementer's summary is **summary-only evidence** and fails the pass. **Unauthorized-change caught:** any diff hunk outside the task's `WRITES` surface is listed in the unauthorized-change set. **Gate computed:** the merge-gate result follows the §14 rule (all required verdicts `PASS`/`WAIVED`) and is not asserted past a `FAIL`/`UNVERIFIED`. |
| `promote` | **Nothing durable left task-local:** every discovery that outlives the task (a reusable finding, a decision, a drift observation) is promoted to a `finding.md`/`adr.md`/`audit.md`/spec amendment/`memory/INDEX.md` entry — a durable fact left only in the transcript fails the pass (§23.4). **Provenance complete:** each promoted artifact carries its mandatory provenance (source pass, evidence, applicability, §23.3); a finding with no provenance fails. **Stance & authority honored:** the promotion routes through source authority (§22) — an observation promotes into intent by explicit re-statement, never by silently outranking an approved spec (§24.4). **No spurious promotion:** task-local execution chatter is NOT promoted; only durable claims are. |

#### 33.6.1 Cross-pass predicates the suite scores at every stage

Four predicates are not owned by a single pass but are scored wherever the relevant artifact appears, because they are the pipeline-wide correctness invariants the corpus exists to defend:

| Cross-pass predicate | What it asserts | Where the suite checks it |
| --- | --- | --- |
| **Parse-validity** | Every emitted SOL artifact re-parses clean against the grammar (§4–§6); no pass emits a structurally invalid block. | output of `author`, `improve`, `lower`, `decompose`, `promote` |
| **Trace-completeness** | The backward chain `obligation → task → trace → verdict` is unbroken: every assigned obligation reaches a verdict and every verdict names an obligation that exists upstream (§16, §22.5). | output of `decompose`, `implement`, `verify`, `review` |
| **Verdict-correctness** | Each `VERDICT` is consistent with its evidence and with §14's verdict model (4 core + 3 lifecycle decorators); no decorator is applied without its condition, no core verdict contradicts its proof result. | output of `verify`, `review` |
| **Drift-detection** | The pass correctly classifies and surfaces each drift class — **stale spec drift** (approved obligation with no matching evidence), **undocumented implementation drift** (observed behavior with no approved obligation), **stale proof drift** (a passing binding that no longer exercises its obligation), **memory drift** (a memory item contradicted by a higher-authority source, §22) — rather than silently passing it. | output of `review`, `promote`; the `stale-memory`/`unauthorised-change` fixtures (§33.4) |

Drift-detection is defined without a runtime: drift is found by the `review` and `promote` passes comparing the approved obligation set against the recorded evidence and the higher-authority sources, never by observing a running system. A pass that fails to flag a drift class present in its fixture fails the drift-detection predicate even if every other predicate holds.

### 33.7 Evaluation hygiene: contamination and held-out fixtures

A golden corpus that ships only the canonical fixtures of §33.1–§33.6 has a latent failure mode of its own: once the fixtures and their expected verdicts are public (they live in `scaffold/.agents/conformance/fixtures/` and are read by every adopter), an agent-as-compiler can be tuned — by training, by an over-stuffed instruction file, or simply by an author copying the corpus — to reproduce the *labels* without performing the *passes*. This is benchmark data contamination: training on (or memorizing) the evaluation data yields "inaccurate or unreliable performance" rather than a measurement of capability [BDCSURVEY]. The risk is not hypothetical for this corpus specifically — benchmark-building rigor is broadly deficient: the HOW2BENCH survey finds that roughly 70% of code benchmarks took no data-quality-assurance measures, and applies a 55-item lifecycle checklist precisely because contamination, duplicated samples, and unreproducible provenance are the norm, not the exception [HOW2BENCH]. The corpus must therefore be designed so that a passing verdict evidences a correctly executed pass, not a recognized string.

Two further design pressures sharpen this. First, the §33.6 pass-output rubrics grade *compiler behaviour*, and the cheapest way to fake that behaviour is to memorize the expected-obligation lists and `VERDICT` blocks the fixtures pin verbatim. Second, the corpus must test the kernel's own "curate, don't dump" stance, not just happy-path lowering: over-specified context and instruction files have been shown to *reduce* task success versus no context at all and to raise inference cost by more than 20% [AGENTSMD-HARM] (corroborated by the preliminary, not-yet-peer-reviewed [SKILLSBENCH] and [AGENTREADMES]). A corpus that only rewards completeness would push authors toward exactly the bloated specs that harm agents; the hygiene fixtures below make the harm measurable.

#### 33.7.1 Held-out and mutated-variant fixtures (normative)

The golden corpus MUST ship, alongside each canonical domain fixture (§33.2–§33.3), at least one **held-out mutated variant** whose obligation text has been *regenerated* — paraphrased triggers/responses, renamed obligation ids, reordered blocks, substituted actors and interface names — while preserving the identical semantic structure, the identical canonical defect class, and the identical expected verdict. The mutated variant is the conformance gate; the canonical fixture is the documented walkthrough. This mirrors the survey's Data Refactoring mitigation (data regeneration plus content filtering) against contamination [BDCSURVEY]: a pass that resolves the canonical fixture but not its semantically equivalent mutated twin has memorized the label, not executed the transformation, and MUST be scored a fail on that pass. Concretely:

- The mutated variant MUST NOT reuse the canonical label strings (e.g. not the literal `"THE service MUST handle failures gracefully"` of §33.5/P-001) yet MUST still trip the same `SOL-<LAYER>NNN` code on the same construct.
- The mutated variant's expected obligation list, trace, and `VERDICT` set (the 4-core + 3-lifecycle model, §14) MUST be derived from its own text, never copied from the canonical fixture's `<domain>.expected-obligations.md`.
- A reviewer (today) checks the variant by hand exactly as in §33.6; a future eval harness MAY hold the mutated variants out of any material an agent-as-compiler is conditioned on. The corpus header MUST mark which fixtures are held-out so a tool cannot silently fold them back into the visible set.

#### 33.7.2 Benchmark-hygiene practice (recommended)

The corpus SHOULD follow established benchmark-building hygiene so its measurements are reproducible and auditable [HOW2BENCH]: each fixture SHOULD record **documented provenance** (which domain, defect class, and §-anchor it exercises, and whether it is canonical or mutated); the corpus SHOULD carry an explicit **data-QA** note per fixture (the expected verdict was confirmed by a human against the spec, not assumed); and the fixtures SHOULD remain **open** for human inspection in `scaffold/.agents/conformance/fixtures/` while the mutated-variant gate keeps openness from becoming a contamination vector. These are SHOULDs, not MUSTs, because Swarm is NO-RUNTIME: the hygiene practice is a contract a future eval harness builds against, and until that harness exists the provenance and data-QA notes are documentation that a manual reviewer reads.

#### 33.7.3 The missing `research-fanout` fixture (normative addition)

The reconciliation claimed a `research-fanout` golden-corpus fixture that the spec then omitted; the corpus MUST ship it. It is the corpus's only **fan-out provenance** fixture: a single `research.md` evidence source (§20.3.4) promoted by `author` passes into **multiple** `*.swarm.md` specs plus one `adr.md`, where every derived obligation cites the originating research span by its cross-file id (`research#R-NNN`, e.g. a derived `payments.swarm.md#AC-001` carrying `BECAUSE research#R-003`). It exercises the "one research artefact MAY feed many downstream artefacts" property (§20.3.4, §29) that no per-domain fixture covers.

**Provenance-id grammar (normative).** A `research.md` tags citable evidence spans with ids `R-001`, `R-002`, … (the `R-` prefix marks an evidence span — parallel to the §4.1 block-id prefixes, but for a non-SOL evidence source). A derived obligation cites a span with the cross-file reference `research#R-NNN` — the `<source-stem>#<span-id>` form of the §5.7 cross-spec reference grammar (file stem `research`, span id `R-NNN`) — in its `BECAUSE` clause. A citation whose `<span-id>` is absent from the named `research.md`, or whose stem names no shipped source, is a provenance failure.

| Fixture file | Holds | Asserts |
|---|---|---|
| `research-fanout/research.md` | one detached evidence source with citable spans `R-001…R-NNN` | observation/evidence stance; promotes rather than governs (§20.2.2, §29) |
| `research-fanout/<spec-a>.swarm.md` | derived obligations citing `research#R-…` | every obligation resolves to a research span; bare-header SOL parses clean |
| `research-fanout/<spec-b>.swarm.md` | further derived obligations citing the same source | the source feeds more than one spec (the fan-out property) |
| `research-fanout/<decision>.adr.md` | a decision whose constraints cite `research#R-…` | the source also feeds a decision artefact, not only specs |

Expected verdict: **PASS**. The pass criterion is provenance resolution, not a verdict on the research itself: every derived obligation in every `*.swarm.md` and every `adr.md` constraint MUST resolve backward to exactly one `research#R-NNN` span in the single `research.md`, and that backward chain MUST be unbroken (the Trace-completeness / source-fidelity predicates, §33.6 `author`, §22.5). The `research.md` artefact itself yields **no `VERDICT`** — it is an evidence source, not an obligation-bearing spec, so it carries no `REQ`/`CONSTRAINT`/`INVARIANT` to verify and never reaches the merge gate (§14); only the obligations it was promoted into do. A fixture in which a derived obligation cites no source span, or cites a span absent from `research.md`, is the negative companion and MUST be rejected as a source-fidelity / provenance failure. As with every §33.7 fixture, `research-fanout` MUST also ship a held-out mutated variant per §33.7.1 (regenerated research-span text and obligation ids, same fan-out topology, same PASS verdict).

## 34. Acceptance criteria for the repo rework

This section is the checkable acceptance checklist for when this specification drives the repository rework. Each item is phrased as a verifiable check (a search, a file-existence test, or a count reconciliation). The rework is complete only when every check passes.

### 34.0 Migration waves

The rework proceeds as seven ordered waves. Each wave has a single goal and a fixed set of mandatory outputs; a wave MUST NOT begin until the prior wave's outputs exist, because every later wave reads the artifacts the earlier one froze (the canonical docs gate the payload, the payload gates the doc reframe, and so on). The A1–A28 acceptance gate (§34.7) is the per-wave *and* final acceptance check: each wave MUST satisfy the subset of A1–A28 that its outputs touch before the next wave starts, and all of A1–A28 — plus the AW1–AW9 workspace checks (§34.8) — MUST pass once Wave 7 completes. The order below is normative.

| Wave | Goal | Mandatory outputs |
|---|---|---|
| 1 | **Freeze the canonical kernel** — pin the language, artifacts, passes, and reference docs so every later wave reads a stable target | `docs/language/` (SOL surface grammar, modals, the 7 block types, the `SOL-<LAYER>NNN` catalogue), `docs/artifacts/` (the `.swarm.` infix rule and per-class filenames, §20), `docs/passes/` (the 7-phase / 9-pass model and 10 improve ops, §9), `docs/reference/` (flow-graph + reconciled counts, §34.4) |
| 2 | **Install the payload** — lay down the copyable kernel under `scaffold/.agents/` (the installable payload; a v0.2 ADR MAY rename `scaffold/` → `kernel/`) | `scaffold/AGENTS.md` (the bootloader, §31), `scaffold/.agents/language/` (language reference copies), `scaffold/.agents/templates/` (the 7 core templates, §20.3.1), and pass-guide + profile skeletons under `scaffold/.agents/` |
| 3 | **Reframe top-level docs** — recast the repo's front matter onto the kernel framing | root `README`, the principles doc (the invariants of §2), and the non-goals doc (§35) restated in kernel vocabulary, with no surviving "CLI required" / "tests passed" framing (§26) |
| 4 | **Recast legacy skills and personas** — map the legacy subsystems onto the kernel without letting them own semantics | skills → pass-guide mappings (one per pass, §26), personas → heuristic-profile mappings (§27), any overlay mappings, and the bootloader simplification that moves every procedure out of `AGENTS.md` into a lazily-loaded guide (§31.2) |
| 5 | **Migrate live sources** — convert the repository's own working material to the kernel artifact set | every live spec converted to `*.swarm.md` (bare-header SOL, §6), research detached into plain `research.md` source artifacts that promote rather than govern (§20.2.2, §29), and review artifacts added as `review.md` with VERDICT blocks (§14, §21.5) |
| 6 | **Add examples and evals** — ship the conformance evidence | the golden corpus and fixtures under `scaffold/.agents/conformance/fixtures/` (§33), the three pipeline-complete walkthroughs under `docs/examples/` (§34.3), and the review/profile rubrics |
| 7 | **Remove deprecated aliases** — drive the surviving-construct count to zero | no canonical `SHALL`, `VERIFY_BY` (underscore), `TASK-MAP`, or fenced `:::`-delimited SOL anywhere in shipped files; each removal is one of the §34.6 regression greps (A19–A28) returning no matches |

### 34.1 Source-file reconciliation

| # | Check | How to verify |
|---|---|---|
| A1 | Every reconciled decision is applied | the spec reflects each per-question reconciliation from the prior research, build brief, and parallel spec; no file retains a superseded construct |
| A2 | The four cross-cluster conflicts are resolved one way each | one lint namespace, one verdict set, one `VERIFY BY` form, surface/IR casing split appear consistently across all docs |

### 34.2 Template and catalogue existence

| # | Check | How to verify |
|---|---|---|
| A3 | The 7 core templates exist in `scaffold/.agents/templates/` | `spec.swarm.md`, `task.md`, `trace.md`, `review.md`, `finding.md`, `adr.md`, `memory/INDEX.md` are each present and copyable |
| A4 | No `verdict.md` template exists anywhere in the scaffold | a search for `verdict.md` returns no scaffold template; VERDICT lives as a block inside `review.md` |
| A5 | The lint catalogue is published | `docs/language/errors.md` lists every `SOL-<LAYER>NNN` code with `{code, severity, layer, span, message, suggest}` and the legacy translation table (Appendix B) |

### 34.3 Conformance and corpus shipping

| # | Check | How to verify |
|---|---|---|
| A6 | The conformance manifest ships | `scaffold/.agents/conformance/conformance.yaml` encodes the task-file schema, command rows, placeholder set, lint scheme, and required-suite matrix (§32) |
| A7 | The golden corpus ships | `scaffold/.agents/conformance/fixtures/` holds positive + negative fixtures for auth-refresh, checkout, payment-5xx, plus the task-file classes (§33) |
| A8 | The three pipeline-complete positives ship | `docs/examples/` holds the full `spec → obligations → task → trace → verdict → promotion` chain for each of the three domains |
| A9 | The labeled prose corpus ships with stated targets | a good/bad `SOL-P` fixture set exists with the 0.90 precision / 0.85 recall baseline recorded (§33.5, G12) |

### 34.4 Count reconciliation

Every enumerated count MUST reconcile identically across the language docs, the skills/pass-guide docs, and `docs/reference/flow-graph.md`.

| # | Count | Value | Reconciles across |
|---|---|---|---|
| A10 | block types | 7 | SOL ref, IR schema, conformance manifest |
| A11 | modals | 5 | SOL ref, APS ref, lint catalogue |
| A12 | verdicts | 7 (4 core + 3 lifecycle) | SOL ref, review template, IR `status` enum |
| A13 | proof types | 9 | proof taxonomy, `VERIFY BY` grammar, flow-graph |
| A14 | phases / passes | 7 / 9 | pass model, flow-graph, skills README |
| A15 | improve operations | 10 | improve-op set, improve pass guide, lint mapping |
| A16 | lint layers | 5 (S/P/M/V/O) | lint catalogue, conformance manifest, IR `diagnostics[]` |

A count that differs between any two of these documents is a failing check.

### 34.5 ADR ledger

| # | Check | How to verify |
|---|---|---|
| A17 | The ADR ledger is updated per §30 | `docs/adrs/README.md` carries rows for every kept/amended/superseded/new ADR; amended ADRs show only a "Superseded by ADR-00XX" status line, bodies immutable (Nygard) |
| A18 | New kernel ADRs (0027+) are recorded | SOL-as-obligation-language, APS-as-prose-standard, the 9-pass model, the artifact set, source-authority, memory model, golden corpus, the unified lint namespace, and the 7-value verdict model each have an ADR |

### 34.6 Zero surviving retired constructs

Each retired construct MUST have zero surviving instances. Each row is a search that MUST return no matches in any shipped file.

| # | Retired construct | Search pattern (MUST return nothing) | Replaced by |
|---|---|---|---|
| A19 | `SHALL` / `SHALL NOT` | `\bSHALL\b` | `MUST` / `MUST NOT` |
| A20 | `ALWAYS` / `NEVER` in invariants | `\b(ALWAYS\|NEVER)\b` in INVARIANT clauses | `MUST` / `MUST NOT` |
| A21 | fenced `:::END` / `:::TYPE` SOL blocks | `:::END` and `:::REQ`/`:::CONSTRAINT`/… | bare-header `TYPE PREFIX-NNN:` form |
| A22 | `VERIFY_BY` underscore (surface) | `VERIFY_BY` outside IR/JSON context | `VERIFY BY` (two words) |
| A23 | `APS-` lint-code prefix | `APS-[A-Z]?[0-9]` | `SOL-<LAYER>NNN` |
| A24 | `POLICY` / `INV` block types | `\b(POLICY\|INV)\b` as a block header | `CONSTRAINT` / `INVARIANT` (full words) |
| A25 | `locks` primitive | `\blocks\b` as a SOL/IR field | named `SURFACE` write groups |
| A26 | `verdict.md` artifact | `verdict\.md` | VERDICT block inside `review.md` |
| A27 | "kickback task type" | `kickback` as a task type | re-entry of `implement` after FAIL/UNVERIFIED |
| A28 | "CLI required" / "tests passed" framing | the §26 forbidden-framing list | "future launcher / not shipped"; pasted proof output |

### 34.7 Acceptance gate

The rework MUST satisfy A1–A28 and the workspace checks AW1–AW9 (§34.8). The gate is the merge-gate analogue (§14): every check is the conformance equivalent of a required obligation, and the rework promotes only when all are satisfied. **Conformance is binary *within* a tier** — at any one tier of the §32.8 maturity ladder there is no partial-conformance state: a single failing check for that tier blocks acceptance at it. Across tiers, conformance is graduated: **a repository's conformance level is its highest fully-satisfied tier** (§32.8), and a repo MAY deliberately target a tier below Swarm-orchestratable. The acceptance gate therefore applies *at the tier a repository targets*: a repo targeting tier *n* MUST pass every A-check that the clauses of tiers 1..*n* bind, and is accepted at tier *n* iff all pass; the unmet checks of higher tiers are out of scope for that repo, not failures. *Swarm-conformant* (§20.4, §32.2) remains reserved for tier 4 (Swarm-verifiable).

### 34.8 Workspace-model migration

These acceptance checks fix the adopted-project workspace model (§20.5, §31): that `.swarm/` is the canonical Swarm workspace, `.agents/` is only an agent-tool compatibility surface, and `AGENTS.md` is a short bootloader. They are the regression searches of the approved workspace spec, reframed as binary A-checks (each is a search, a file-existence test, or a doc-presence test); they carry the same per-wave-and-final force as A1–A28 (§34.7). All are **design rationale** — the workspace/compatibility/bootloader split is a layout decision — and introduce **no new empirical claim**.

| # | Check | How to verify |
|---|---|---|
| AW1 | No canonical reference to `.agents/specs`, `.agents/tasks`, or `.agents/memory` | `grep -R "\.agents/\(specs\|tasks\|memory\|sources\|findings\|adrs\|audits\|bugs\|research\|nfrs\|interfaces\)"` returns no match in any shipped canonical file; the only permitted matches are lines explicitly marked **compatibility** or **migration** |
| AW2 | `.swarm/` is named as the canonical Swarm workspace | a canonical page states `.swarm/` is the workspace and partitions `sources/ status/ generated/ memory/ ledger/ archive/ kernel/ tmp/` as distinct categories (§20.5) |
| AW3 | `.agents/` is named as a compatibility surface | a canonical page states `.agents/` is an agent-tool compatibility surface, never the Swarm source-of-truth root; mirrored skills/profiles point back to `.swarm/kernel/` |
| AW4 | `AGENTS.md` is short and inlines no SOL/APS manual | `AGENTS.md` is within the §31.1 density cap and a search for an inlined `SOL`/`APS` manual (`AGENTS\.md` against the §31.1 forbidden-inline rule) returns nothing; at most a one-line language pointer to `.swarm/kernel/language/` survives |
| AW5 | Surface policies are documented | a canonical page defines the source-code surface policy set `generated` / `governed` / `observed` / `external` / `deprecated` (§20.5), establishing that code is reconciled implementation reality, not disposable generated output |
| AW6 | The source/status/generated split is documented | a canonical page separates `sources/` (desired truth), `status/` (observed satisfaction/drift), and `generated/` (task frames, traces, reviews) as distinct workspace categories (§20.5) |
| AW7 | The ledger is documented | a canonical page defines `.swarm/ledger/` as the compact reconciled history (obligation coverage, changed surfaces, proof, verdicts, promotion results) that prevents permanent task-scratchpad accumulation (§20.5) |
| AW8 | The CLI/agent boundary is documented | a canonical page documents the future-launcher boundary — Swarm coordinates agent-CLI workers and prepares/validates work but does not own the model loop, file-editing mechanics, or provider/MCP runtime, and MUST NOT replace an agent CLI (a contract a future toolchain builds against, NO RUNTIME — Invariant 1) |
| AW9 | No canonical page implies Swarm is an agent runtime | a search for "Swarm is an agent CLI" / "agent runtime" framing returns no canonical match; every "runs" verb resolves to a future-launcher contract (§35.1 N1), consistent with the orchestrator-worker single-threaded-writes boundary |

A failing AW-check blocks acceptance at the tier whose clauses bind it, identically to A1–A28 (§34.7).

## 35. Non-goals and deferred-to-v0.2

### 35.1 Non-goals (out of scope for every version unless a future ADR reopens them)

These are not omissions to be filled later; they are deliberate boundaries that follow from the invariants (§2).

| # | Non-goal | Rationale |
|---|---|---|
| N1 | **No shipped CLI, runtime, scheduler, differ, or parser** | Invariant 1 (NO RUNTIME). Everything that "runs" is documented as a contract a future tool builds against (§32.7), never shipped by this repo. The toolchain↔agent-CLI boundary (§32.7.2–§32.7.4) is part of this non-goal: a future Swarm toolchain would *prepare and reconcile* obligation-bounded work and *coordinate* agent-CLI workers via adapters, but MUST NOT itself become an agent CLI (own the model loop, chat UI, file-editing, provider auth, or the MCP/tool-calling runtime) `[ANTHROPIC-MA]`, `[COGNITION]` |
| N2 | **No checker shipped** | the conformance contract (§32) and corpus (§33) are inert data; the checker is a deferred launcher concern |
| N3 | **Provider-neutral** | the spec makes no assumption about which model or agent runs it; SOFT control is context, not enforcement (Invariant 2). No section names a vendor as load-bearing |
| N4 | **Generative reproducibility is a non-goal; verdict stability is an obligation** | Two layers, deliberately split. **(a) Generative reproducibility** — identical token streams from the model on identical inputs — remains a NON-GOAL: sampling, temperature, and inference determinism are launcher concerns, and current evidence holds that this nondeterminism is an *engineering choice* (it stems from lack of batch-invariance, not inherent randomness; batch-invariant kernels gave 1 unique output across 1,000 completions vs 80 for standard inference) `[DETERMINISM]` (lab blog, not peer-reviewed) — so Swarm specifies obligations and proofs, not the generative process that satisfies them. **(b) Verdict stability**, by contrast, *is* in scope, because the merge gate (§14.4) is the one normative predicate and it can flip on agent-rendered passes: `verify`/`review` render verdicts, and a `manual` proof is recorded agent/human judgment with no executable oracle (§15.1). Normative clarification: a `verify`/`review`/`manual` verdict on **unchanged inputs** (same obligation surface-text, same evidence refs, same source/surface hashes — §16) SHOULD be **stable** across runs; a verdict that **flips across runs on identical inputs** is itself a `CONTRADICTED` condition (§14.1.2), routed through the existing §14 machinery — the two conflicting run results are recorded as the two mandatory conflicting evidence refs, and the gate blocks per §14.4 / §17.4. This adds **no runtime requirement**: like every gate disposition it is a contract, enforced by a deterministic check outside the model where one exists and manual today (§14.4, §17.1). |
| N5 | **No live multi-agent orchestration** | the kernel ships the static coordination contract (declarations + two graphs + the safe-parallelism predicate + the artifact schema, §18); live scheduling, stall detection, and inter-agent wire protocols (A2A/MCP) are launcher concerns |
| N6 | **No enforcement claim** | Invariant 2: prose/SOL/APS/skills/`AGENTS.md` are SOFT control and MUST NOT be presented as enforcement; the deterministic enforcement lane (§17) is today aspirational/manual |

### 35.2 Deferred to v0.2 (recorded now, specified later)

These features are explicitly deferred. v0.1 conformance MUST NOT depend on them, and a v0.1 spec MUST NOT use the deferred surface syntax (it is a syntax error today).

| # | Deferred feature | Why deferred | v0.2 direction |
|---|---|---|---|
| D1 | **Timing semantics** — `WITHIN`, `BEFORE`, `UNTIL`, `IMMEDIATELY`, `EVENTUALLY` | sound timing needs real temporal-logic semantics, not opaque keywords | FRETish-style temporal logic binding to proofs (needs the §15 proof model); established precedent: FRET→Ogma→Copilot generates real-time C runtime monitors from structured natural language [FRETMON] |
| D2 | **Expression sublanguage for conditions** | v0.1 treats the `WHERE`/`WHILE`/`WHEN`/`IF` condition body as opaque text | a typed expression grammar so conditions are machine-evaluable |
| D3 | **Cross-spec ID import syntax** | v0.1 qualifies a cross-spec reference inline as `spec-id#AC-001` but has no import declaration | a declared import/namespace mechanism |
| D4 | **The fenced `:::TYPE` editor alias** | bare-header `TYPE PREFIX-NNN:` is the only normative form; fenced blocks are fragile to parse | an OPTIONAL editor-robustness alias that lowers to the bare form |
| D5 | **Memory automation** — embedding/dense retrieval, LRU eviction, automatic staleness hashing, cross-session identity, dashboards | Invariant 1 (NO RUNTIME); the kernel ships the provenance/staleness *fields* (§23), automation needs a runtime | a launcher that computes hashes, evicts, and retrieves against the shipped fields |

The following deferred rows EXTEND the D1–D5 table above. They are recorded for the same reason: v0.1 conformance MUST NOT depend on them, and a v0.1 spec MUST NOT use any deferred surface they imply.

| # | Deferred feature | Why deferred | v0.2 direction |
|---|---|---|---|
| D6 | **Per-pass COST/TELEMETRY schema** — a declared, machine-readable cost record attached to each pass run | Invariant 1 (NO RUNTIME): the kernel has no execution loop to meter, and the load-bearing standard is still experimental. The OpenTelemetry GenAI semantic conventions expose `gen_ai.usage.input_tokens` / `gen_ai.usage.output_tokens` and the `gen_ai.client.token.usage` metric, with **no first-class cost attribute** and a status of "Development" (names may still change) [OTELGENAI] | a telemetry block that records token usage per pass *from which cost is computed*, bound to the GenAI conventions once they freeze; pinning the field names today would couple the kernel to an unstable standard |
| D7 | **Test-time-compute budgeting for hard passes** — allowing a pass to declare more inference/search budget for harder obligations rather than escalating to a larger model | needs an execution model the kernel does not have (Invariant 1), and the supporting evidence is agent-specific, not a general law: external TTC (budget=8) raised a 32B SWE-Reasoner from 37.60% to 46.00% on SWE-bench Verified, but this is **SWE-agent-specific, not a general scaling law** [TTC] | a per-pass budget hint (e.g. on `implement`/`verify`) that a launcher MAY honor; v0.2 MUST treat it as a SOFT control hint, never an enforced limit (Invariant 2) |
| D8 | **Behavioral / embedding DRIFT detection** — drift signals beyond the declared-write `content_hash` staleness already shipped (§23.3, §16) | **OPEN: no verified general source.** The kernel today detects only *declared-write* drift via hashing; behavioral or embedding-space degradation has no verified, citable general definition in `sources.md`. RIVA is Infrastructure-as-Code configuration drift only and MUST NOT be cited for representation drift | left open. v0.2 authors MUST supply a verified `sources.md` entry before specifying any behavioral/embedding drift signal; until then this row is a recorded gap, not a design commitment |
| D9 | **Assurance-case / uncertainty-quantification layer for verdicts** — attaching a calibrated confidence or structured assurance argument to the 4-core + 3-lifecycle verdict model (§14) | v0.1 verdicts are categorical (`PASS`/`FAIL`/…); a confidence or assurance-case layer is a research surface with no settled kernel contract, and adding it would change the verdict model — a one-way version trigger (§25) | a per-verdict assurance/UQ annotation (claim → evidence → confidence) that refines, but does not replace, the categorical verdict; design rationale only, pending a verified evidence base |
| D10 | **Concurrent-write memory governance for parallel `implement`** — extending the single-writer rule to the `memory/INDEX.md` promotion surface | the v0.1 single-writer / safe-parallelism predicate (§18.5, ADR-0010) serializes by *declared write surface*; it does not yet model concurrent promotion writes to the shared `memory/INDEX.md` index (§23.1.1) when multiple `implement` tasks run in parallel | a memory-governance rule that treats `memory/INDEX.md` as a single-writer surface (or specifies a merge/append discipline) so parallel promotion cannot corrupt the index; extends, not relaxes, the §18.5 predicate |
| D11 | **SOL/APS internationalization** — non-English keyword/diagnostic surfaces for the language and the `SOL-<LAYER><NNN>` lint namespace | v0.1 fixes the English keyword set and the S/P/M/V/O lint layers as the single normative surface; localizing keywords or diagnostic text is a language change (one-way version trigger, §25) and risks ambiguity in the obligation graph | an OPTIONAL localized presentation layer that lowers to the canonical English keywords and `SOL-<LAYER><NNN>` codes, leaving the normative form unchanged |
| D12 | **Project `LICENSE` and `GOVERNANCE` files** — repository-level legal/governance surfaces for the spec itself | these are repository-meta files, not part of the kernel's obligation/proof/memory contracts; deferring them keeps v0.1 scoped to the language and pipeline | add `LICENSE` and `GOVERNANCE.md` at the repository root, governing contribution and amendment authority (§22) without altering any normative kernel surface |

Each row obeys the §25 one-way trigger: any deferred surface that adds language, verdict-model, or lint-namespace structure (D7–D11 as applicable) forces at least a framework MINOR release when specified. D8's drift signal in particular MUST NOT be specified until a verified `sources.md` entry grounds it — the same "no astrology for agents" discipline that governs every empirical claim in this spec (§0, Evidence base).

```sol
# v0.2-DEFERRED syntax — REJECTED in a v0.1 spec (illustrative)
REQ AC-099:
  WHEN a 503 is returned
  THE service MUST retry WITHIN 200ms     # WITHIN is timing -> deferred (D1); SOL-S syntax error in v0.1
  VERIFY BY test:cmdTest:retry.test
```

Each deferred feature is recorded so v0.2 authors inherit the intent without reopening a settled v0.1 decision (§30). The one-way version trigger (§25) applies: adding any of D1–D4 is a language change that forces at least a framework MINOR release.

---
