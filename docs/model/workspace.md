# Workspace Model

> Where Swarm's files and a project's source artifacts live. Swarm is a **spec-repo discipline** with **no
> runtime and no filing cabinet**: intent lives in a spec repo; code repos stay pristine. ([ADR-0050](../adrs/0050-swarm-is-a-spec-repo-discipline.md))

This page describes the **adopted project** (the product), distinct from the framework-dev repo (the
producer: `docs/`, `examples/`, `evals/`, and the starter kit). Adoption depends on the repo's **role**:

- A **spec / documentation repo** is where Swarm lives — intent is authored and reviewed here (the
  *desired truth*).
- A **code repo** implements against specs and stays clean — it holds the *reality*.
- **Co-located** (solo / single repo) plays both roles in one repo.

The intent/reality split *is* the repo boundary: spec repo = desired truth; code = reality; a coverage
record (the spec repo, or the PRs that satisfy obligations) = observed satisfaction.

## No runtime (Invariant 1)

Swarm ships inert markdown — skills, templates, reference cards, and the language. There is no process it
runs. Every "the X pass writes Y" below is a **contract a human or a future toolchain fulfils**, never
something Swarm executes. So Swarm prescribes only the folders a pass run **today** actually reads or
durably writes; anything that would serve only a future tool is created lazily, never stamped empty at
install. The goal is the goldilocks middle: enough structure to be intuitive out of the box, no filing
cabinet for a clerk who doesn't exist yet.

## The spec repo — a small folder set under `.agents/`

A spec repo holds Swarm under `.agents/` — the cross-tool agent directory — prescribing only the folders
the authoring flow uses:

```text
.agents/
  skills/      # install — the authoring kit (author/lint/improve/lower/decompose/review/promote + personas)
  reference/   # install — the rule cards (sol.md, proofs.md, ir.md) the authoring skills name
  templates/   # install — artifact skeletons (spec, prd, rfc, audit, finding, adr, …)
  specs/       # the *.swarm.md sources (the `author` pass writes here) — desired truth
  memory/      # durable recall the `promote` pass writes — INDEX.md + findings/patterns
AGENTS.md      # repo root — the bootloader; fill its Commands table + project facts
```

The three *install* folders are re-copied on upgrade (`pass-*`/`persona-*`/`write-*` names can't collide
with your own; that naming is the whole upgrade story). If your CLI scans a fixed skills dir (Claude Code →
`.claude/skills/`), skills go there instead — no separate home, no symlink bridge. Other intent artifacts —
PRDs, RFCs, audits, findings, ADRs — are normal `type:`-tagged docs kept under `.agents/` however suits you;
Swarm reads the **frontmatter**, not a mandated path. There is **no version file** (the framework version is
a producer release tag) and **no `.swarm/` mount**.

## The code repo — pristine

A code repo that *consumes* specs keeps **almost nothing**: a great SOL spec is self-legible, so no
reference cards and no specs belong here. At most the developer copies the one `implement-and-verify` skill
(the trust backbone for parallel worktree runs) and appends the kit's `.gitignore.additions`. Everything an
agent generates while implementing (task frames, transient traces) is **gitignored**; the **PR** (naming the
obligation ids, with CI + review) is the trace and verdict; anything durable flows **back to the spec repo
as a linked PR**. Nothing litters the code repo.

## Why the spec repo prescribes these folders (and not the rest)

- **`specs/`** — `author` produces the `*.swarm.md` source; intent has to live somewhere findable.
- **`memory/`** — `promote` lifts durable findings and patterns out of throwaway task state so a later
  session **recalls** them instead of re-deriving them. Externalising state to disk rather than holding it
  in a context window is what makes multi-session work tractable [[CTXENG]](../research/sources.md#CTXENG);
  writing intermediate steps down is itself what makes multi-step work succeed
  [[SCRATCHPAD]](../research/sources.md#SCRATCHPAD); a written self-reflection between attempts, not extra
  model capability, is what lets an agent improve [[REFLEXION]](../research/sources.md#REFLEXION); and
  persisting task state with explicit dependencies mirrors a pattern validated at vendor
  scale [[CCTASKS]](../research/sources.md#CCTASKS).

What is **not** prescribed (created lazily by a future tool, breaks no pass run today): a `status/` drift
read-model, a `generated/` packet tree, an append-only `ledger/`, `archive/`, `tmp/`, and the on-disk
`.json` IR/plan files. These remain documented contracts (see the reconciliation design below); they are
simply not stamped into a repo to adopt Swarm.

## Project conventions

Project-specific rules — architecture boundaries, extra refusals, local command bindings — go in your
`AGENTS.md`, the file that already carries standing project facts and the `Commands` table. There is no
separate overlays directory; a convention is a fact about the project, and project facts live in the
bootloader an agent already reads first.

## Intent, reality, and the reconciliation between them (the design contract)

Swarm's value is keeping three things distinct and reconciled. This is **design** — realised by hand today,
by a future toolchain later — **not** a set of directories you create up front:

- **Desired truth** — what the project intends: the spec / source artifact. Primary for *intent*.
- **Implementation reality** — the code. **Invariant 4: code is reality**, reconciled implementation, not a
  build product of the spec.
- **Observed satisfaction + drift** — whether the code satisfies the intent, recorded by trace / review /
  verdicts. It records reality against intent and **never redefines** intent.

A toolchain that tracks satisfaction, emits task / trace / review packets, or keeps a compacted history MAY
write them under conventional paths (e.g. `status/`, `generated/`, `ledger/`) — **each created on first
write**, and gitignored when recreatable from the source. The kernel fixes the *shape* of those records
(the obligation graph, the verdict model, the coverage a history entry must preserve), not a directory you
must materialise to adopt. Recreatable execution state (task frames, scratch) is throwaway; the durable
record is the source artifact, the memory, and whatever compacted history a tool keeps.

## Source-code surface policies

The reconciliation has a per-path projection over the codebase. A code region declares **exactly one**
policy from a closed set of five — recording which side of the intent-versus-reality reconciliation it sits
on (this follows from Invariant 4):

| Policy | Meaning | Manual edits |
| --- | --- | --- |
| `generated` | Emitted from a **named source artifact** (an OpenAPI doc, a schema, an interface spec) — the artifact is the truth, the file is its emission. | **Forbidden** — edit the source and regenerate; a hand-edit is overwritten and is a finding. |
| `governed` | Reconciled implementation under an obligation: a spec owns intent, the code owns realization, trace/review reconcile them. | **Allowed only with an obligation trace** — every change carries an obligation id and emits a trace. |
| `observed` | Existing code not yet governed — pre-existing reality with no obligation behind it. | Allowed, but the surface needs an audit + a spec before it becomes `governed`. |
| `external` | Vendor / third-party code you do not own. | **Do not modify** — changes belong upstream or in an owned wrapper. |
| `deprecated` | Scheduled for removal or migration; retained until cutover. | Discouraged; permitted edits SHOULD be migration/removal steps, not new behavior. |

`observed` is the **honest default** for brownfield adoption: real code no obligation yet claims. It is the
on-ramp — an audit plus a spec promote `observed` → `governed`; it is never silently treated as already
governed. The set **rejects** the doctrine that code is disposable or "regenerated from specs": only a
surface explicitly marked `generated` is emitted from a source, and even then only from a named artifact.
The surface map is a contract a future tool reads (a `surfaces:` map of `path → {policy, source}` in your
Swarm config); computing and enforcing it is a future-tool concern, the **map shape is the contract today**.

## The CLI / agent boundary

Swarm coordinates agent-CLI workers and **prepares and validates** work; it does **not** own the model loop,
the file-editing mechanics, or the provider/MCP runtime, and it MUST NOT replace an agent CLI. The future
launcher is a contract a toolchain builds against — it would scaffold task frames, bind `VERIFY BY` adapters
through `AGENTS.md > Commands`, serialize write surfaces, and reconcile history — consistent with the
orchestrator-worker, single-threaded-writes boundary. Every "runs" verb resolves to that contract
(Invariant 1); nothing here makes Swarm an agent runtime.

## Monorepo: nested `AGENTS.md` (closest-wins)

In a multi-package repo more than one `AGENTS.md` may coexist: the repo-root file carries shared bindings
and conventions; a per-workspace file (e.g. `packages/api/AGENTS.md`) adds to or overrides them. An agent
reads the **closest** `AGENTS.md` up the tree — nearest wins, root as fallback; a workspace with no file
inherits the root. Only the `## Commands` bindings and standing facts differ per workspace; the installed
skills are shared. This is purely a bootloader-resolution rule; it changes nothing about the obligation model.

## Related

- [Source artifacts](source-artifacts.md) — the durable source-artifact types and what each carries.
- [Source authority](source-authority.md) — how intent governs implementation reality.
- [Compiler pipeline](compiler-pipeline.md) — the passes that produce traces, reviews, verdicts, and memory.
- [Adopting Swarm](../ADOPTING.md) — the install steps.
