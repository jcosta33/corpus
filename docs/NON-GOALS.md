# Non-Goals

> Swarm's reference for what is deliberately out of scope: the standing non-goals, the settled scope boundaries, and the "is / is not" line that separates the framework from a runtime.

Swarm is a **specification-compiler kernel**: a controlled-markdown spec is the *source code*, a fleet of agents is the *compiler*, and everything that "runs" — parser, linter, checker, scheduler, differ, CLI — is a **contract a future tool builds against**, never software this repository ships. The non-goals below are not omissions to be filled in later. They are deliberate boundaries that follow directly from the invariants: **NO RUNTIME** (Invariant 1) and **SOFT control is context, not enforcement** (Invariant 2). A non-goal is reopened only by a future ADR, never by drift.

## What Swarm is / is not

This single line separates the framework from the things people most often mistake it for. Each row is a boundary, not a feature to be added later.

| Swarm is | Swarm is not |
|----------|--------------|
| A specification compiler whose output is verified, promoted work | A chat assistant or autonomous "magic" |
| A markdown-only set of contracts a future tool builds against | A CLI, SDK, scheduler, or runtime this repo ships |
| Provider-neutral (no assumption about which model/agent runs it) | Tied to any specific agent tool or vendor |
| A formal spine (SOL) inside readable markdown | A general-purpose programming language |

## The standing non-goals (N1–N6)

| # | Non-goal | Rationale |
|---|---|---|
| **N1** | **No shipped CLI, runtime, scheduler, differ, or parser.** | This is Invariant 1 (NO RUNTIME) stated as scope. Everything described in the kernel as something that "runs" is documented as a contract a future tool builds against, never shipped by this repository. The boundary extends to the toolchain↔agent-CLI split: a future Swarm toolchain would *prepare and reconcile* obligation-bounded work and *coordinate* agent-CLI workers through adapters, but MUST NOT itself become an agent CLI — it does not own the model loop, the chat UI, file-editing mechanics, provider auth, or the MCP/tool-calling runtime. Swarm coordinates agent CLIs as workers; it is not one. (Design rationale: an agent CLI already owns the model loop and tool runtime; a coordinator that absorbed those would couple Swarm to one harness and forfeit provider-neutrality.) |
| **N2** | **No checker shipped.** | The conformance contract and the golden corpus are **inert data** — the precise, testable definition a future checker would honour, plus the fixtures that pin the expected verdicts. The checker itself is a deferred launcher concern. A human validates a repository against the contract by hand today; the corpus makes that judgment reproducible without any tool. |
| **N3** | **Provider-neutral.** | The kernel makes no assumption about which model or which agent runs it. SOFT control (prose, SOL, APS, skills/pass-guides, `AGENTS.md`) is *context*, not *enforcement* — this is Invariant 2. No section of the spec names a vendor as load-bearing, so no provider is required to author, compile, or verify a Swarm spec. |
| **N4** | **Generative reproducibility is a non-goal; verdict stability is an obligation.** | Two layers, deliberately split. **(a) Generative reproducibility** — identical token streams from the model on identical inputs — is a NON-GOAL: sampling, temperature, and inference determinism are launcher concerns. Current evidence treats this nondeterminism as an *engineering choice* rather than inherent randomness — it stems from lack of batch-invariance in the inference kernels, not from sampling per se, and batch-invariant kernels have been shown to make repeated completions on identical inputs converge to a single output — so Swarm specifies obligations and proofs, not the generative process that satisfies them. **(b) Verdict stability** *is* in scope, because the merge gate is the one normative predicate and it can flip on agent-rendered passes: `verify`/`review` render verdicts, and a `manual` proof is recorded agent/human judgment with no executable oracle. Normative clarification: a `verify`/`review`/`manual` verdict on **unchanged inputs** (same obligation surface-text, same evidence refs, same source/surface hashes) SHOULD be **stable** across runs; a verdict that **flips across runs on identical inputs** is itself a `CONTRADICTED` condition, routed through the existing verification machinery (the two conflicting run results become the two mandatory conflicting evidence refs, and the gate blocks). This adds **no runtime requirement**: like every gate disposition, it is a contract — enforced by a deterministic check outside the model where one exists, and manual today. |
| **N5** | **No live multi-agent orchestration.** | The kernel ships only the **static coordination contract**: the declarations, the two graphs, the safe-parallelism predicate, and the artifact schema. Live scheduling, stall detection, and inter-agent wire protocols (A2A/MCP) are launcher concerns. The contract is complete and checkable at rest; the runtime that would act on it is deferred. |
| **N6** | **No enforcement claim.** | Invariant 2 again: prose, SOL, APS, skills/pass-guides, and `AGENTS.md` are SOFT control and MUST NOT be presented as enforcement. The deterministic enforcement lane exists in the contract but is, today, **aspirational/manual** — a contract a future tool honours, not a guarantee this repository makes. A "tests passed" message is not, by itself, proof of an obligation; proof is bound explicitly to obligations through the proof model. [[REFLEXION]](research/sources.md#REFLEXION) |

## Settled scope boundaries

Beyond the standing non-goals above, Swarm deliberately leaves a small set of environment and process variables **unspecified** rather than choosing a default. Pinning any of these would couple the language to a model, tool, stack, or org chart it must outlive. This table is normative: a conformant repository or tool MUST NOT read a hidden default into any row below, and MUST treat each as an explicit open variable that the **adopting repository binds locally** (for example, through `AGENTS.md` and its `Commands` table for adapters).

| Assumption area | Kernel assumption |
|-----------------|-------------------|
| Target LLM family | **Unspecified / model-native.** The kernel assumes no particular model or vendor; SOL, APS, and every pass MUST remain interpretable by any capable agent. No prompt, token, or context-window characteristic of a specific model is normative. |
| Agent runner / IDE | **Unspecified / plain-markdown.** The kernel MUST work with plain markdown and ordinary repository files; it assumes no specific harness, editor, or agent framework. Anything a runner adds is a local convenience, never a conformance dependency. |
| Parser / CLI / LSP | **Out of scope for v0.1; contracts only.** No parser, linter, planner, scheduler, differ, or language server is shipped or required. The framework defines only the *contracts* such tools MUST satisfy so future tooling can target them (the NO RUNTIME invariant). |
| Programming language / stack | **Unspecified.** Swarm governs requirements, tasks, proofs, reviews, and memory — not the application's language, framework, or build system. The stack surfaces only through `VERIFY BY` adapters resolved in `AGENTS.md > Commands`. |
| Repo host / VCS / forge | **Unspecified.** Examples assume git-compatible workflows (branches, diffs, merge gates) but require no specific forge; nothing depends on a named host's APIs, review UI, or permission model. |
| Human approval roles | **Unspecified — Swarm defines *which* changes need approval, not *who* grants it.** The amendment and source-authority rules determine which edits are mere normalization versus intent changes that require sign-off; the identity, title, and headcount of approvers are a local org decision the adopting repository binds. |
| Pre-existing repository files | **Target-state, not file-by-file conversion.** Swarm defines the normative target state and the conformance rules to reach it; it does not enumerate or convert the specific files an adopting repository already holds. Conformance work MUST converge on the target state, not attempt to reconstruct or preserve a guessed inventory of pre-existing files. |

## What this is not saying

These boundaries are about *scope*, not capability. Swarm is not an agent CLI and is not an agent runtime; it is the markdown source-of-truth and the contracts a future toolchain would build against. Reframing a "runs" verb as shipped behavior — claiming a CLI is required, treating a bare "tests passed" as proof, or describing Swarm as the thing that executes agents — contradicts N1, N2, N4, and N6 at once and is forbidden framing.

A deferred feature is one v0.1 conformance MUST NOT depend on; a non-goal is one no version pursues unless an ADR reopens it. The deferred set is recorded below.

## Deferred to v0.2 (D1–D12)

These features are explicitly deferred — recorded now, specified later. **v0.1 conformance MUST NOT depend on any of them, and a v0.1 spec MUST NOT use the deferred surface syntax** (using it is a syntax error today). Each obeys the one-way version trigger: any deferred surface that adds language, verdict-model, or lint-namespace structure forces at least a framework MINOR release when it is specified.

| # | Deferred feature | Why deferred | v0.2 direction |
|---|---|---|---|
| D1 | **Timing semantics** — `WITHIN`, `BEFORE`, `UNTIL`, `IMMEDIATELY`, `EVENTUALLY` | sound timing needs real temporal-logic semantics, not opaque keywords | temporal-logic binding to proofs (needs the proof model) |
| D2 | **Expression sublanguage for conditions** | v0.1 treats the `WHERE`/`WHILE`/`WHEN`/`IF` condition body as opaque text | a typed expression grammar so conditions are machine-evaluable |
| D3 | **Cross-spec ID import syntax** | v0.1 qualifies a cross-spec reference inline as `spec-id#AC-001` but has no import declaration | a declared import/namespace mechanism |
| D4 | **The fenced `:::TYPE` editor alias** | bare-header `TYPE PREFIX-NNN:` is the only normative form; fenced blocks are fragile to parse | an OPTIONAL editor-robustness alias that lowers to the bare form |
| D5 | **Memory automation** — embedding/dense retrieval, LRU eviction, automatic staleness hashing, cross-session identity, dashboards | Invariant 1 (NO RUNTIME); the kernel ships the provenance/staleness *fields*, automation needs a runtime | a launcher that computes hashes, evicts, and retrieves against the shipped fields |
| D6 | **Per-pass COST/TELEMETRY schema** — a machine-readable cost record per pass run | no execution loop to meter (Invariant 1), and the load-bearing telemetry standard is still in "Development" with no first-class cost attribute | a telemetry block recording token usage per pass, bound to the GenAI conventions once they freeze |
| D7 | **Test-time-compute budgeting for hard passes** | needs an execution model the kernel does not have; the supporting evidence is agent-specific, not a general scaling law | a per-pass budget *hint* a launcher MAY honor; always a SOFT control hint, never an enforced limit (Invariant 2) |
| D8 | **Behavioral / embedding DRIFT detection** (beyond declared-write `content_hash` staleness) | **OPEN: no verified general source.** Behavioral/embedding-space degradation has no verified, citable general definition | left open — a v0.2 author MUST supply a verified source before specifying any signal; until then a recorded gap, not a commitment (the "no astrology" discipline) |
| D9 | **Assurance-case / uncertainty-quantification layer for verdicts** | v0.1 verdicts are categorical; a confidence/assurance layer would change the verdict model (one-way trigger) | a per-verdict assurance/UQ annotation (claim → evidence → confidence) that *refines*, never replaces, the categorical verdict |
| D10 | **Concurrent-write memory governance for parallel `implement`** | the v0.1 safe-parallelism predicate serializes by declared write surface; it does not yet model concurrent promotion writes to the shared `memory/INDEX.md` | a rule treating `memory/INDEX.md` as a single-writer surface (or a merge/append discipline); extends, not relaxes, the predicate |
| D11 | **SOL/APS internationalization** — non-English keyword/diagnostic surfaces | v0.1 fixes the English keyword set and the S/P/M/V/O lint layers as the single normative surface; localizing is a language change | an OPTIONAL localized presentation layer that lowers to the canonical English keywords and `SOL-<LAYER><NNN>` codes |
| D12 | **Project `LICENSE` and `GOVERNANCE` files** | repository-meta files, not part of the kernel's obligation/proof/memory contracts | add `LICENSE` and `GOVERNANCE.md` at the repository root, governing contribution and amendment authority |
