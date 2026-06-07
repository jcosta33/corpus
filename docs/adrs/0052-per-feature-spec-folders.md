---
type: adr
id: 0052-per-feature-spec-folders
status: accepted
created: 2026-06-07
updated: 2026-06-07
supersedes:
superseded_by:
---

# ADR-0052: One artifact-home model — per-feature spec folders, one `decisions/`, memory for recall

## Context

[ADR-0051](./0051-complete-the-spec-repo-pivot.md) put specs top-level but left the *home* of every other
artifact under-specified — and the framework ended up **contradicting itself on where artifacts live**:

- `docs/model/workspace.md`, `docs/ADOPTING.md`, and `starter-kit/{README,AGENTS,specs/README}.md` prescribed
  a flat `specs/` **plus an open-ended top-level cloud** — `adrs/ audits/ findings/ …`, "type:-tagged, kept
  how you like."
- `docs/passes/promote.md` instead routed ADRs / audits / bug-reports / findings **"under `.agents/`"**.
- `docs/artifacts/memory.md` said findings + ADRs are **"committed source-docs"** (i.e. *not* under `.agents/`).

Three docs, three homes for the same artifact. Meanwhile the kit shipped a home for **only** `specs/` while
carrying templates for ADR, audit, bug-report, prd, rfc, research, review, threat-model, finding — every one
of them homeless. The "where" was an unbounded "…", which reads as incoherence to an adopter.

Two facts already in the repo make the fix small rather than new machinery: `docs/artifacts/` **already
classifies each type's scope** (spec/audit/bug-report/prd/rfc/threat-model/review are feature-scoped; ADR is
project-wide and sequentially numbered; finding is durable recall), and every artifact **already carries a
required `type:` frontmatter envelope** with obligation-blocks already spec-only.

The fix is grounded in the field's convergent convention (web-verified, June 2026): the two leading
spec-driven tools both organize **per-feature folders** — GitHub Spec Kit scaffolds `specs/<NNN-feature>/`
(spec + plan + tasks + research co-located) [[SPECKIT]](../research/sources.md#SPECKIT); Amazon Kiro uses
`.kiro/specs/<feature>/` and writes requirements in **EARS**, Swarm's SOL clause shape
[[KIRO]](../research/sources.md#KIRO). ADRs have a settled home: a sequentially-numbered in-repo
`decisions/` directory [[ADR-CONV]](../research/sources.md#ADR-CONV). Co-locating a feature's supporting
artifacts with its contract is exactly what closes the requirements↔output traceability gap that 2025 SE
research names as the dominant failure mode [[REDEFO]](../research/sources.md#REDEFO).

## Decision

**One artifact-home model, three homes, one rule.** A feature is the unit of organization; an artifact lives
with the thing it serves.

1. **Feature-scoped artifacts live in a per-feature folder, `specs/<NNN-feature-slug>/`.** The folder holds
   the contract `spec.swarm.md` plus any of its feature-scoped supporting docs co-located beside it — `audit`,
   `research`, `bug-report`, `prd`, `rfc`, `threat-model` (each a `type:`-tagged Markdown file). A pre-spec
   input (e.g. a research note with no spec yet) simply *starts* the feature folder it explores. This replaces
   ADR-0051's flat `specs/*.swarm.md` and **eliminates the open-ended top-level type-folder cloud** — the
   supporting docs are homed by co-location, not by a parallel `audits/ findings/ …` sprawl. (Execution
   scratch — task frames, traces, reviews — stays gitignored or the linked PR per
   [ADR-0050](./0050-swarm-is-a-spec-repo-discipline.md); a deliberately-kept review lands in the feature
   folder.)
2. **Project-wide decisions live in `decisions/`** — sequentially-numbered ADRs (`0001-<slug>.md`), one
   decision per immutable file, superseded rather than rewritten [[ADR-CONV]](../research/sources.md#ADR-CONV).
   This is the single home for the one artifact that is genuinely cross-cutting, not feature-bound.
3. **Durable recall lives in `.agents/memory/`** — `finding`s, `patterns/`, `glossary`, and `INDEX.md` (the
   load-*when* map). This is unchanged; it is where promotion already targets. The memory `INDEX` may point at
   ADRs in `decisions/` by path (the index spans recall + the decision ledger).
4. **This resolves the contradiction:** ADR → `decisions/`; finding → `.agents/memory/`; every other
   supporting artifact → `specs/<feature>/`. The `promote.md` "under `.agents/`" routing for ADRs/audits/
   bug-reports is **wrong and removed**; `workspace.md`/`ADOPTING.md`'s "top-level type-folder cloud" is
   **replaced** by this model.
5. **Lint scope is unchanged.** Obligation blocks stay spec-only and the semantic lint stays spec-only —
   the only reliable machine-check for a non-spec artifact is structural (its `type:` envelope + required
   sections), because prose-smell precision is bounded ~48–59% [[SMELLS]](../research/sources.md#SMELLS). The
   subtractive/advisory document-check direction is already parked in
   [ADR-0043](./0043-checkable-documents.md); this ADR does not extend it.

This **refines** [0051](./0051-complete-the-spec-repo-pivot.md) (specs are now per-feature folders, not flat
files; the type-folder cloud is gone) and [0050](./0050-swarm-is-a-spec-repo-discipline.md) (unchanged:
code repos stay pristine, the PR is the default trace/verdict — a *kept* review in a spec repo lands in the
feature folder; in a code repo it stays gitignored scratch or the linked PR). It **aligns with**
[0032](./0032-memory-model.md) (findings → memory) and [0043](./0043-checkable-documents.md) (lint scope).
It changes **no** closed set, the SOL grammar, the nine steps, the verdicts, or the reconciliation design.

## Alternatives considered

| Alternative | Why rejected |
| --- | --- |
| Keep flat `specs/*.swarm.md` + give each other type its own top-level folder (`audits/`, `research/`, …) | This is the status quo's cloud with names. It cannot **co-locate** a feature's audit/research with its spec, so traceability stays a cross-folder lookup; and it grows an unbounded top-level surface — the exact incoherence being removed. |
| Keep everything top-level, "type:-tagged, kept how you like" (ADR-0051 as written) | Self-contradicted by `promote.md` and `memory.md`; homes nothing concretely; an adopter can't tell where an audit goes. |
| Route supporting artifacts + ADRs "under `.agents/`" (promote.md as written) | `.agents/` is **tooling**, not content. ADRs/audits/research are product intent humans read; burying them in the agent-tooling dir conflates the two and contradicts the spec-repo discipline. |
| Split the spec into per-feature `spec.md`+`plan.md`+`tasks.md` like Spec Kit / Kiro | Swarm's distinctive choice is the **single self-contained SOL contract** (obligations + `VERIFY BY` in one file); the plan is *derived* by `decompose`, not hand-authored. Adopt their per-feature *folder*, not their multi-file split. |

## Consequences

- **Positive:** every template has exactly one home; an adopter copying the kit gets a working skeleton with
  `specs/<feature>/`, `decisions/`, and `.agents/` — nothing prescribed-but-missing. A feature's contract and
  its evidence sit together (traceability by co-location). The framework stops contradicting itself.
- **Negative:** a doctrine sweep across ~12 prose files (workspace, ADOPTING, promote, the artifact pages,
  author/decompose) plus the scaffold restructure (`git mv` the example spec into a feature folder, add
  `decisions/`, add a "Lives in:" line to each template) and a `swarm-cli` realignment. Done as part of this
  change.
- **Neutral:** all closed sets, the SOL grammar, the nine steps, and the artifact taxonomy itself are
  unchanged — only *where files live* changes, and it changes to match where the docs already said the
  artifacts' *scope* was.

## Status

Accepted (v0.1). Restructure: `starter-kit/specs/example.swarm.md` → `specs/001-example-feature/spec.swarm.md`
(+ a co-located supporting doc), `starter-kit/decisions/` seeded with `0001-adopt-swarm.md`; the model/adoption
docs and `promote.md` routing reconciled to the three-home model; each template carries a "Lives in:" line;
`swarm-cli` (co-located) realigned.

## Affected obligations / constraints

- Refines: [0051](./0051-complete-the-spec-repo-pivot.md) (per-feature folders replace flat specs; the
  top-level type-folder cloud is removed), [0050](./0050-swarm-is-a-spec-repo-discipline.md) (artifact homes;
  PR-as-trace unchanged).
- Aligns with: [0032](./0032-memory-model.md) (findings → `.agents/memory/`),
  [0043](./0043-checkable-documents.md) (lint stays spec-only; no document-lint built here).
- Grounded by: [[SPECKIT]](../research/sources.md#SPECKIT), [[KIRO]](../research/sources.md#KIRO),
  [[ADR-CONV]](../research/sources.md#ADR-CONV), [[SMELLS]](../research/sources.md#SMELLS),
  [[REDEFO]](../research/sources.md#REDEFO).
- Does NOT change: the obligation grammar, any closed set, the nine steps, the verdicts, or the artifact
  taxonomy.
