# Swarm — The Kernel Specification (v0.1)

This document is the single authoritative, consolidated **kernel specification** for Swarm: an obligation-centered specification-compiler framework for agentic software engineering. It defines the Swarm Obligation Language (SOL), the Agent Prose Semantics standard (APS), the unified lint taxonomy, the phase/pass model, the lowering and intermediate-representation contracts, the verification and verdict model, the orchestration and coordination contracts, the artifact set and conformance definition, the source-authority and memory models, and the versioning regime. It is the artifact the entire Swarm repository will be reworked from. It is a *specification of contracts*, not a runtime: Swarm ships markdown only, and everything described here as something that "runs" (a parser, planner, scheduler, differ, checker, or CLI) is defined as a contract a future tool builds against — never as software this repository provides.

## How this specification is organized

This specification is **one document, split across an indexed set of part files** for navigability. All parts share a single section numbering (**§0–§35** plus **Appendices A–G**); a cross-reference of the form **“§N”** refers to that section wherever it lives — use the map below to find its file. This `README.md` is the front door: it carries the abstract, the executive summary, and the map. Read the parts in order for a full pass, or jump via the map.


## Executive summary

Swarm is a markdown-only, provider-neutral, obligation-centred **specification-compiler** for agentic software engineering: human intent is written as controlled markdown, and a fleet of agents acts as the compiler that turns it into proven work. The framework is **unitary at rest** (language, artifact contracts, passes, templates, pass guides, and memory model install together as one coherent whole) and **modular in execution** (each task loads only the pass guide, profile, and context it needs; §1.3). Its settled pipeline is fixed: upstream **sources** (research, audit, bug-report) are normalized into a `spec.swarm.md` whose load-bearing meaning is carried as **SOL obligations**; the spec is **lowered** into an obligation graph and then into bounded **task frames**; agents **implement** those frames and emit a **trace**; verification and **review** render **verdicts** against the original obligations; and durable discoveries are **promoted** into project memory (sources → SOL obligations → lower → task frames → implement → trace → review/verdict → promote). The headline language decisions are deliberate and final: SOL uses **bare-header blocks** (`TYPE PREFIX-NNN:` at column 0) rather than fenced or header-heavy forms; proof is bound with **`VERIFY BY <type>:<adapter>:<artifact>`**; the surface is exactly **7 block types** (`REQ`, `CONSTRAINT`, `INVARIANT`, `INTERFACE`, `QUESTION`, `TRACE`, `VERDICT`) decorated by **5 modals** (`MUST`, `MUST NOT`, `SHOULD`, `SHOULD NOT`, `MAY`) with **no `SHALL`** as a canonical form (it is a recognized deprecated alias only); the human review artifact is **`review.md`**, never a separate `verdict.md` (a `VERDICT` is an SOL block inside it); skills become **pass guides**, personas become **heuristic profiles**, and `AGENTS.md` is a **short bootloader**, not a behavior manual. In an adopted project, `.swarm/` is the canonical Swarm workspace (kernel, sources, status, generated, memory, ledger), `.agents/` is only an agent-tool compatibility surface, and Swarm is a **toolchain that coordinates agent CLIs as workers**, never an agent CLI itself (§2.7–§2.11, §20.5). These decisions rest on an explicit evidence base — EARS and NASA's FRET for controlled requirement English, RFC 2119 / RFC 8174 for strict uppercase modal semantics, requirement-smell and ambiguity-repair research for the lint taxonomy, current Anthropic agent guidance for context-file and instruction discipline, and SemVer for the versioning regime; two further design choices rest on established engineering practice rather than a cited study — requirements-traceability (RTM) for the obligation-to-proof spine and conflict-serializability for the orchestration write-surface contract. The governing invariant over all of it is **no runtime**: everything described here that "runs" — parser, planner, scheduler, differ, checker, LSP, CLI — is a *contract a future tool builds against*, never software this repository ships (§2.1).

## Document map

| Part | Sections | Topic | File |
| --- | --- | --- | --- |
| 00 | §0–§4 | Foundations & architecture | [`00-foundations.md`](./00-foundations.md) |
| 01 | §5–§6 | The SOL language | [`01-sol-language.md`](./01-sol-language.md) |
| 02 | §7–§8 | APS and the lint taxonomy | [`02-aps-and-lint.md`](./02-aps-and-lint.md) |
| 03 | §9–§13 | The compiler pipeline (phases, passes, IR) | [`03-compiler-pipeline.md`](./03-compiler-pipeline.md) |
| 04 | §14–§17 | Verification | [`04-verification.md`](./04-verification.md) |
| 05 | §18–§19 | Orchestration & parallelism | [`05-orchestration.md`](./05-orchestration.md) |
| 06 | §20–§21 | Artifacts and templates | [`06-artifacts.md`](./06-artifacts.md) |
| 07 | §22–§25 | Governance, memory, versioning | [`07-governance-memory.md`](./07-governance-memory.md) |
| 08 | §26–§31 | Recasting the framework | [`08-recast.md`](./08-recast.md) |
| 09 | §32–§35 | Conformance and rework | [`09-conformance-and-rework.md`](./09-conformance-and-rework.md) |
| 10 | App. A–G | Appendices A–G | [`10-appendices.md`](./10-appendices.md) |


## Reading order

1. **Part 00 — Foundations** (§0–§4): the thesis, the invariants, the architecture, and the **canonical vocabulary (§4)** every other part points to. Read first.
2. **Parts 01–02** (§5–§8): the SOL language, the APS prose standard, and the lint taxonomy.
3. **Part 03** (§9–§13): phases, passes, the improve operations, lowering, and the IR.
4. **Part 04** (§14–§17): verdicts, the proof taxonomy, drift, and the soft/hard control boundary.
5. **Parts 05–07** (§18–§25): orchestration, artifacts, governance, memory, and versioning.
6. **Parts 08–09** (§26–§35): the recast of skills/personas/tasks/documents/ADRs, conformance, the golden corpus, and the rework acceptance gate.
7. **Part 10** (Appendices A–G): the consolidated grammar, the full lint catalogue, the IR JSON Schema, the auth-refresh worked example, the residual-gap judgment calls, the glossary, and the copy-paste rework brief.

A newcomer who reads Part 00 alone should be able to hold the whole framework in mind; the remaining parts make every construct precise. The full preamble, status, and provenance are in **§0** (Part 00).
