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

The installable payload — the **kernel** — lives in this repo under [`kernel/`](./kernel/). On adoption it installs to **`.swarm/kernel/`** in the consuming project, and `kernel/AGENTS.md` becomes the project's `AGENTS.md` **bootloader** (how an agent starts; short, capped at ≤200 lines / ≤25 KB). Nothing executes during or after this copy — the kernel is inert reference data and copyable templates.

In an adopted project, `.swarm/` is the canonical Swarm workspace, separating **desired** state from **observed** state from **generated** material:

- `.swarm/kernel/` — the installed payload (`language/`, `templates/`, `passes/`, `skills/`, `profiles/`, `overlays/`).
- `.swarm/sources/` — desired truth: `*.swarm.md` specs plus PRDs, RFCs, research, audits, bugs, findings, ADRs, interfaces, NFRs.
- `.swarm/status/` — observed satisfaction and drift; records whether code satisfies the spec, never redefines intent.
- `.swarm/generated/` — execution packets (task frames, traces, reviews, generated tests/docs); recreatable from sources.
- `.swarm/memory/`, `.swarm/ledger/`, `.swarm/archive/`, `.swarm/tmp/` — durable recall, compact reconciled history, retired artifacts, and scratch.

`.agents/` is only an agent-tool **compatibility surface** — a one-directional mirror so a third-party agent CLI can find loadable instructions — never the canonical home of project intent. The governing placement rule: *defines/tracks/reconciles intent → `.swarm/`; exists only so an agent CLI can load instructions → `.agents/`; starts an agent correctly → `AGENTS.md`.*

## The NO-RUNTIME invariant

Swarm holds five invariants in every part of the framework; the governing one is **NO RUNTIME**. The repository is documentation and kernel payload. Every "runs" verb resolves to a future-tool contract:

1. **No runtime** — markdown-only; everything that "runs" is a contract a future tool builds against, never shipped.
2. **Soft vs hard control** — prose, SOL, APS, skills, and `AGENTS.md` are soft guidance; anything that must hold regardless of the model needs a deterministic check *outside* the model (today that hard lane is aspirational/manual).
3. **Surface-vs-IR layering** — the human surface is UPPERCASE space-separated keywords; the IR is snake_case fields.
4. **Code is reality** — code and tests can falsify an obligation but never silently amend intent.
5. **Schema-valid is not verified** — shape is not truth; a `PASS` verdict requires a bound proof that actually ran and produced inspectable evidence, not merely a structurally valid trace.

## Where the docs live

- [`docs/language/`](./docs/language/) — the SOL and APS references, error catalogue, and versioning regime.
- [`docs/model/`](./docs/model/) — the compiler pipeline, source artifacts, source authority, and conformance.
- [`docs/passes/`](./docs/passes/) — one page per pass (`author`, `lint`, `improve`, `lower`, `decompose`, `implement`, `verify`, `review`, `promote`).
- [`docs/reference/`](./docs/reference/) — the flow graph, proof types, promotion protocol, distillation loss budget, and glossary.
- [`kernel/`](./kernel/) — the installable payload (the templates, language references, passes, skills, and profiles that install to `.swarm/kernel/`).

These are the reference projections. The single authoritative, long-form source of truth is the **kernel specification** at [`.agents/specs/swarm/`](./.agents/specs/swarm/) — start with its [`README.md`](./.agents/specs/swarm/README.md), then Part 00 (Foundations). Where any file disagrees with the spec, the spec governs.
