# Swarm — the starter kit

This directory is what an agent integrates into your repo to adopt Swarm. It is inert markdown
(**NO RUNTIME** — every artifact is a contract a future tool builds against). Hand this folder to your
coding agent and point it at [`../docs/ADOPTING.md`](../docs/ADOPTING.md); it adapts the relevant subset into
your repo under `.agents/`.

**What you take depends on the repo's role** (see [ADR-0050](../docs/adrs/0050-swarm-is-a-spec-repo-discipline.md)):

- A **spec / documentation repo** — where intent is authored and reviewed — takes the **authoring kit**.
- A **code repo** — where developers implement — stays *pristine* and takes at most the tiny **implementing
  kit** (optional). Co-located (one repo plays both roles) takes both.

## Authoring kit (→ a spec repo's `.agents/`)

The full set, for writing and reviewing high-quality specs:

```text
starter-kit/.agents/skills/      →  <skills dir>        # author + lint/improve/lower/decompose/review/promote + personas
starter-kit/.agents/reference/   →  .agents/reference/  # the rule cards: sol.md, proofs.md, ir.md (used while authoring)
starter-kit/.agents/templates/   →  .agents/templates/  # artifact skeletons (spec, prd, rfc, audit, finding, adr, …)
starter-kit/AGENTS.md            →  AGENTS.md           # repo-root bootloader (fill Commands + project facts)
```

Specs live in `.agents/specs/` (`*.swarm.md`); other intent artifacts (PRDs, RFCs, ADRs, audits, findings)
are normal `type:`-tagged docs under `.agents/`. `.agents/memory/` holds durable recall the `promote` pass
writes. No `.swarm/` mount, no symlink bridge, no version file.

## Implementing kit (→ a code repo, optional)

A code repo needs **nothing required**. A good SOL spec is self-legible — a capable agent reads its
obligations without a grammar manual, so **no SOL reference cards and no specs** belong in the code repo.
The one thing worth taking (the trust backbone for parallel agents) is a single skill:

```text
starter-kit/.agents/skills/implement-and-verify/  →  <skills dir>   # implement an obligation + prove it; optional
```

Optionally a `persona-*` stance the developer likes. Everything an agent generates while implementing
(task frames, scratch) is **gitignored**; the **PR** (referencing obligation ids, with CI + review) is the
trace and verdict; durable outcomes go **back to the spec repo as a linked PR** — nothing litters the code
repo. Append [`.gitignore.additions`](./.gitignore.additions) to keep the scratch out.

## What does NOT install (reference, kept here)

`starter-kit/.agents/{passes,language,conformance}` and `starter-kit/overlays/` are **not** copied into any
adopter. The skills carry their procedure inline and the `reference/` cards carry the shared rules, so an
adopter needs none of the full manuals or the golden corpus; project conventions go in `AGENTS.md`. These
stay here as the framework's human reference / derived twins / corpus.

## Folder contents

| Path | Goes to | What it is |
| --- | --- | --- |
| `.agents/skills/` | spec repo (full) / code repo (`implement-and-verify` only) | Pass guides, per-kind implement & author guides, cross-cutting fragments, `persona-*` stances — lazily loaded. |
| `.agents/reference/` | spec repo | The rule cards the authoring skills name: `sol.md`, `proofs.md`, `ir.md`. |
| `.agents/templates/` | spec repo | Skeletons — `spec.swarm.md`, `prd.md`, `rfc.md`, `audit.md`, `finding.md`, `adr.md`, `review.md`, `memory/INDEX.md`, … No `verdict.md` (a `VERDICT` is a block inside `review.md`). |
| `.agents/language/`, `.agents/passes/` | not installed | Full SOL/APS references + the nine pass contracts — human reference; the skills + cards are derived from them. |
| `.agents/conformance/` | not installed | The inert conformance contract + golden-corpus `fixtures/` — test data for a future checker. |
| `.agents/memory/` | spec repo (seed) | The recall seed (`INDEX.md`, `glossary.md`) a spec repo grows. |

## Adopting

**The full guide (with a copy-paste agent prompt, per role) is [`../docs/ADOPTING.md`](../docs/ADOPTING.md).**
Conformance is graded **per role** — a spec repo's bar (the authoring kit + a populated `AGENTS.md`) differs
from a code repo's near-zero footprint. Nothing is enforced at runtime (there is none); the contract in
[`.agents/conformance/conformance.yaml`](./.agents/conformance/conformance.yaml) is what a future launcher honours.
