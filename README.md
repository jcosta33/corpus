# Swarm

**Swarm is a markdown-only, provider-neutral, obligation-centered specification compiler for agentic software engineering.**

You write human intent as a controlled-markdown specification. A fleet of agents acts as the compiler that turns it into proven work. The specification — not the code — is the authoritative source, the same pattern industry interface and configuration languages already use (OpenAPI, Terraform, Smithy, and Kubernetes' desired-state `spec` reconciled against observed `status`).

This repository ships **markdown only**. Everything described here that "runs" — a parser, linter, planner, scheduler, differ, checker, LSP, or CLI — is defined as a **contract a future tool builds against**, never as software this repository provides.

## The core idea: spec-as-source-code, agents-as-compiler

- A **controlled-markdown specification is source code.** Load-bearing meaning is carried as **SOL obligations** (the Swarm Obligation Language) inside ordinary `*.swarm.md` files.
- A **fleet of agents is the compiler.** Intent is compiled, through an ordered and named sequence of transformations, into work that is implemented, verified against the original obligations, and promoted into durable project knowledge.
- The central object is the **obligation graph**: a typed graph whose nodes are obligations (and the judgments rendered on them) and whose edges are the relationships among them. Every role reduces to an operation on this graph, and the final merge gate is a property of the graph — *every required obligation carries a passing verdict.*

Swarm is **unitary at rest** (language, artifact contracts, passes, templates, pass guides, and memory model install together as one coherent whole) and **modular in execution** (each task loads only the pass guide, profile, and context it needs).

Swarm is *not* a chat assistant, a prompt library, a set of canned instructions, an agent runtime, or an agent CLI. It is a toolchain that coordinates existing agent CLIs as worker backends; it owns the intent structure and never owns the model loop, chat UI, tool-calling runtime, or provider auth.

## The components

Swarm is one compiler assembled from a small set of components — each a part of the whole, not an independently adopted gadget:

| Component | What it is | Reference |
|---|---|---|
| **Pass guides** | Reusable methods for executing a named pass. | [`docs/library/`](./docs/library/) |
| **Heuristic profiles** | Cognitive stances that parameterize a pass — *what an agent looks for and refuses*, never a character. | [`docs/library/`](./docs/library/) |
| **Pass frames** | A `task_kind` enum that parameterizes `implement` / `author`. | [`docs/artifacts/`](./docs/artifacts/) |
| **The artifact set** | One unified set of artifacts centered on the obligation graph. | [`docs/artifacts/`](./docs/artifacts/) |
| **Lowering + plan** | Deterministic lowering of obligations into a plan the launcher executes. | [`docs/passes/`](./docs/passes/) |

The conceptual model is unitary: every piece is a component of one compiler. A pass guide never owns language semantics; a profile is never a character; a task kind is never an open-ended prompt log. Adoption may still be incremental at the *repository* level — a team may vendor a subset — but each piece remains a component of the compiler, not an independent product.

## The fixed pipeline

The settled pipeline is fixed and end-to-end:

```text
sources  →  SOL obligations  →  lower  →  task frames  →  implement  →  trace  →  review/verdict  →  promote
```

- **sources** — upstream research, audits, and bug reports are normalized into a `*.swarm.md` specification (APS prose + SOL blocks).
- **SOL obligations** — the spec's load-bearing meaning is carried as obligations and lowered into the obligation graph (the IR).
- **lower** — the graph is lowered and decomposed into a plan: a dependency DAG plus a write-conflict graph.
- **task frames** — the plan yields bounded work packets, one pass each.
- **implement** — agents do the bounded work and emit a trace.
- **trace** — the trace claims which obligations were implemented, what changed, and binds proof.
- **review / verdict** — verification and review render verdicts against the original obligations.
- **promote** — durable discoveries fold back into project memory.

The framework distinguishes **7 phases** (conceptual, fixed-order stages: `PARSE → NORMALIZE → LOWER → EXECUTE → VERIFY → REVIEW → PROMOTE`) from **9 passes** (schedulable transformations: `author → lint → improve → lower → decompose → implement → verify → review → promote`).

The surface is exactly **7 block types** (`REQ`, `CONSTRAINT`, `INVARIANT`, `INTERFACE`, `QUESTION`, `TRACE`, `VERDICT`) decorated by **5 modals** (`MUST`, `MUST NOT`, `SHOULD`, `SHOULD NOT`, `MAY` — no canonical `SHALL`). Obligations bind proof with `VERIFY BY <type>:<adapter>:<artifact>`, across **9 proof types** (`static`, `test`, `contract`, `property`, `model`, `perf`, `security`, `manual`, `monitor`). Review renders one of **7 verdicts** (`PASS`, `FAIL`, `BLOCKED`, `UNVERIFIED`, plus the lifecycle verdicts `WAIVED`, `STALE`, `CONTRADICTED`). Semantics-preserving repair uses **10 improve operations** (`NORMALIZE`, `ATOMIZE`, `CONCRETIZE`, `QUANTIFY`, `BIND`, `SCOPE`, `CLARIFY`, `DECONFLICT`, `COMPRESS`, `PROMOTE`).

## How it is adopted

**→ [`docs/ADOPTING.md`](docs/ADOPTING.md) is the step-by-step guide** — a copy-paste prompt that hands the adoption to the coding agent you already use (or a human runs the same steps).

Swarm lives in a **spec / documentation repo** — that's where intent is authored and reviewed. **Code repos stay pristine.** The starter kit lives in this repo under [`starter-kit/`](./starter-kit/); adoption hands it to your coding agent, which integrates the *right subset for the repo's role* under `.agents/` (the cross-tool agent directory). Nothing executes — the files are inert reference data and copyable templates. ([ADR-0050](docs/adrs/0050-swarm-is-a-spec-repo-discipline.md))

- A **spec repo** takes the **authoring kit** — the `author`/`lint`/`improve`/`review` skills, the rule cards, the templates — and holds the specs (`.agents/specs/`) and durable memory (`.agents/memory/`). Desired truth lives here, and one spec can govern **many** code repos (obligation ids are namespaced; `spec-id#AC-001` cross-references them).
- A **code repo** takes **almost nothing**: a good SOL spec is self-legible, so no reference cards and no specs go here. At most the one optional `implement-and-verify` skill, plus a `.gitignore` line so Swarm scratch never lands. The **PR** (naming the obligation ids it satisfies, with CI + review) is the trace and verdict; durable outcomes flow back to the spec repo as linked PRs.
- **Co-located** (solo / single repo) does both in one repo.

No `.swarm/` mount, no version file, no filing cabinet — the framework version is a producer release tag, and you re-copy the kit to upgrade.

## The NO-RUNTIME invariant

Swarm holds five invariants in every part of the framework; the governing one is **NO RUNTIME**. The repository is documentation and kernel payload. Every "runs" verb resolves to a future-tool contract:

1. **No runtime** — markdown-only; everything that "runs" is a contract a future tool builds against, never shipped.
2. **Soft vs hard control** — prose, SOL, APS, pass guides, profiles, and `AGENTS.md` are soft guidance; anything that must hold regardless of the model needs a deterministic check *outside* the model (today that hard lane is aspirational/manual).
3. **Surface-vs-IR layering** — the human surface is UPPERCASE space-separated keywords; the IR is snake_case fields.
4. **Code is reality** — code and tests can falsify an obligation but never silently amend intent.
5. **Schema-valid is not verified** — shape is not truth; a `PASS` verdict requires a bound proof that actually ran and produced inspectable evidence, not merely a structurally valid trace [[REFLEXION]](docs/research/sources.md#REFLEXION).

## Where the docs live

- [`docs/language/`](./docs/language/) — the SOL and APS references, error catalogue, and versioning regime.
- [`docs/model/`](./docs/model/) — the compiler pipeline, source artifacts, source authority, and conformance.
- [`docs/passes/`](./docs/passes/) — one page per pass (`author`, `lint`, `improve`, `lower`, `decompose`, `implement`, `verify`, `review`, `promote`).
- [`docs/reference/`](./docs/reference/) — the flow graph, proof types, promotion protocol, distillation loss budget, and glossary.
- [`starter-kit/`](./starter-kit/) — the installable files (the templates, reference cards, and skills — including the persona-* profile stances — an adopter copies into `.agents/`).

Each area is the authoritative reference for what it covers; together with the [`starter-kit/`](./starter-kit/) files, the `docs/` tree **is** Swarm. The references here are complete — there is no separate document a reader must defer to.

- [`docs/artifacts/`](./docs/artifacts/) — the contract for each artifact (spec, task, trace, review, finding, ADR, and the source-document types).
- [`docs/library/`](./docs/library/) — pass guides, heuristic profiles, and overlays (the layers that parameterize a pass).
- [`docs/adrs/`](./docs/adrs/) — the architecture decision ledger.
- [`docs/PRINCIPLES.md`](./docs/PRINCIPLES.md) and [`docs/NON-GOALS.md`](./docs/NON-GOALS.md) — the invariants and the deliberate boundaries.

---

Swarm **v0.1** · language **SOL/0.1**, **APS 0.1** · the framework package is versioned independently as semver (see [`docs/language/versioning.md`](./docs/language/versioning.md)). This specification is Accepted; it is one self-contained framework.
