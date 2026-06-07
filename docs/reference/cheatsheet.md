# The Flow Graph: Canonical Counts and the Default-Suite Matrix

> Swarm's reference for the flow graph: the canonical cardinalities of every closed set (block types, modals, verdicts, proof types, phases, steps, improve operations, lint layers) and the per-task-kind default-suite matrix that ties them together.

Swarm is markdown-only, provider-neutral, and has **no runtime**. Nothing on this page is shipped code: the parser, linter, structured-form builder, scheduler, proof runner, and the `swarm` CLI are all **contracts** a future tool would build against, never code this repo ships (Invariant 1, NO RUNTIME). A "pass" is a transformation a human or agent performs by hand today, following a pass guide; a "gate" is a check a reviewer applies by reading evidence.

This is the **count-reconciliation hub**. Every closed set in Swarm has exactly one cardinality, and that number MUST be identical wherever it appears — in the SOL language reference, the structured-form schema, the lint catalogue, the pass guides, and the conformance manifest. Conformance pins these as acceptance checks A10–A16: a count that differs between any two documents is a failing check. This page is where the numbers are gathered, cross-linked, and laid against each other.

## Canonical counts

Each row is a **closed set**: the conformance contract forbids adding, removing, or reordering its members in v0.1. The "Acceptance check" column is the reconciliation anchor a conformance review cites. The "Reference" column links the sibling framework page that defines that set's members in full.

| Closed set | Count | Members (in canonical order) | Acceptance check | Reference |
| --- | --- | --- | --- | --- |
| Block types | **7** | `REQ`, `CONSTRAINT`, `INVARIANT`, `INTERFACE`, `QUESTION`, `TRACE`, `VERDICT` | A10 | [SOL](../language/SOL.md) |
| Modals | **5** | `MUST`, `MUST NOT`, `SHOULD`, `SHOULD NOT`, `MAY` | A11 | [SOL](../language/SOL.md) |
| Verdicts | **7** (4 core + 3 lifecycle) | core: `PASS`, `FAIL`, `BLOCKED`, `UNVERIFIED` · lifecycle: `WAIVED`, `STALE`, `CONTRADICTED` | A12 | [proof types](proof-types.md) |
| Proof types | **9** | `static`, `test`, `contract`, `property`, `model`, `perf`, `security`, `manual`, `monitor` | A13 | [proof types](proof-types.md) |
| Phases | **7** | `PARSE`, `NORMALIZE`, `LOWER`, `EXECUTE`, `VERIFY`, `REVIEW`, `PROMOTE` | A14 | (this page, §Phases and steps) |
| Steps | **9** | `author`, `lint`, `improve`, `lower`, `decompose`, `implement`, `verify`, `review`, `promote` | A14 | (this page, §Phases and steps) |
| Improve operations | **10** | `NORMALIZE`, `ATOMIZE`, `CONCRETIZE`, `QUANTIFY`, `BIND`, `SCOPE`, `CLARIFY`, `DECONFLICT`, `COMPRESS`, `PROMOTE` | A15 | (this page) |
| Lint layers | **5** (S/P/M/V/O) | `S` SYNTAX, `P` PROSE, `M` SEMANTIC, `V` VERIFICATION, `O` ORCHESTRATION | A16 | [errors](../language/errors.md) |

Notes that prevent miscounting:

- **Block types: 7, not 10.** `TASK-MAP`, `FINDING`, and `ADR` are downstream artifacts, not SOL block types. Three block types carry binding force (the *obligation blocks* `REQ`, `CONSTRAINT`, `INVARIANT`); the other four declare a boundary (`INTERFACE`), mark ambiguity (`QUESTION`), claim implementation (`TRACE`), or judge an obligation (`VERDICT`).
- **Modals: 5, not 7.** `SHALL`/`SHALL NOT` are not modals and are forbidden in binding clauses (flagged `SOL-P058`); `CAN`/`WILL` are *non-modal* and likewise forbidden (`SOL-P003`). Only the five uppercase modals bind.
- **Proof types: exactly 9.** The set is closed. `unit`/`integration`/`e2e` are scope *qualifiers* under `test` (written `test:unit:`, etc.), not types; `runtime` is not a type and maps to `monitor`. An unknown `<type>` is `SOL-V009`.
- **Phases vs steps: 7 vs 9 — do not conflate.** A *phase* is a conceptual stage (a fixed-order taxonomy of *where* work sits); a *step* is a schedulable transformation (the unit a human/agent/tool actually runs). Several steps may map to one phase.
- **Improve operations: exactly 10, closed.** "Improve the spec" with no named operation is not a valid request; an improve pass MUST NOT invent operations outside the set. Note `NORMALIZE` and `PROMOTE` name *both* an improve operation and (separately) a phase / a step — same word, different layer.
- **Lint layers: 5.** One prefix `SOL`, five layers, form `SOL-<LAYER>NNN`. APS prose violations surface as `SOL-P###` codes within this single namespace.

## Phases and steps

The seven phases are a single fixed order; a conformant description MUST present them in exactly this order and MUST NOT add, remove, or reorder them in v0.1:

```text
PARSE -> NORMALIZE -> LOWER -> EXECUTE -> VERIFY -> REVIEW -> PROMOTE
```

The nine steps are the schedulable transformations, listed in flow order. A launcher MAY interleave steps across specs, but for a single obligation the partial order MUST hold (an obligation cannot be `verify`-ed before `implement`, nor `implement`-ed before `lower`):

```text
author -> lint -> improve -> lower -> decompose -> implement -> verify -> review -> promote
```

### Pass → phase mapping

| Pass | Phase(s) | Lint layer(s) it owns | Note |
| --- | --- | --- | --- |
| `author` | entry (pre-`PARSE`) | — | First Swarm-visible artifact (`spec.swarm.md`); not itself analyzable. |
| `lint` | `PARSE` + `NORMALIZE` | S, P, M, V, O | Non-mutating; the only pass that straddles two phases (well-formedness + smell detection). |
| `improve` | `NORMALIZE` | answers the codes mapped to the 10 improve operations | Runs only after `lint`; strictly semantics-preserving (R-IMPROVE). |
| `lower` | `LOWER` | O | Emits the structured form (the obligations) and the two derived graphs; needs a lint-clean, approved spec. |
| `decompose` | `LOWER` | O | Partitions the structured form into write-disjoint work packets; consumes the structured form, not the surface prose. |
| `implement` | `EXECUTE` | — | Produces the change for assigned obligations only; records TRACE claims. |
| `verify` | `VERIFY` | V | The only profile-independent pass; one verdict per `VERIFY BY` binding. |
| `review` | `REVIEW` | M, V | Judges claims, applies lifecycle decorators, computes the merge gate. |
| `promote` | `PROMOTE` | — | Moves durable discoveries into provenance-anchored artifacts. |

Of the nine steps, the six analysis steps — `lint`, `improve`, `lower`, `decompose`, `review`, `promote` — each ship a **dedicated pass guide**; `implement` is served by **nine per-`task_kind` implement guides**, `author` by **six author guides**, and `verify` by the `empirical-proof` cross-cutting fragment (ADR-0042/0051). Every pass now has a guide, but a guide is an optional aid, not a conformance gate — the pass contract is the binding artifact. Pass guides are SOFT control: they MUST NOT define SOL/APS semantics, modality, authority order, or verification meaning [[SKILLBP]](../research/sources.md#SKILLBP). The authoring guides ship in the starter kit; the implement-side guides are `docs/library/code-skills/` reference (ADR-0051).

## The proof-type × phase default-suite matrix

Each task kind (the `task_kind:` enum) carries a **default suite**: a set of `(proof-type @ phase)` requirements recommending which proofs SHOULD be bound and at which phase they run. The suites are **recommendations**, not a closed law — an author MAY override per obligation, and a binding-completeness check (the `SOL-V` layer) verifies coverage or an explicit justification for any omission. See [proof types](proof-types.md) for the binding grammar.

| `task_kind` | Default suite — `(proof-type @ phase)` |
| --- | --- |
| `feature` | `test @ VERIFY`, `static @ VERIFY`; `contract @ VERIFY` if any `INTERFACE` touched |
| `fix` | `test @ VERIFY` (regression test reproducing the defect), `static @ VERIFY` |
| `refactor` | `test @ VERIFY` (behaviour-preservation), `property\|contract @ VERIFY` for invariants/boundaries |
| `rewrite` | `test @ VERIFY`, `static @ VERIFY`; `contract @ VERIFY` if any `INTERFACE` touched |
| `migration` | `test @ VERIFY`, `static @ VERIFY`, `contract @ VERIFY` (boundary conformance) |
| `upgrade` | `test @ VERIFY`, `static @ VERIFY`, `contract @ VERIFY` (dependency contracts) |
| `performance` | `perf @ VERIFY`, `test @ VERIFY`, `static @ VERIFY` |
| `testing` | `test @ VERIFY`, `static @ VERIFY` |
| `documentation` | `static @ VERIFY` (lint/APS); `manual @ REVIEW` for accuracy |
| `integration` | `contract @ VERIFY`, `test @ VERIFY`, `static @ VERIFY` |
| `spec-writing` | `static @ NORMALIZE` (lint/APS); no executable suite (no code yet) |
| `research-writing` | `static @ NORMALIZE` (lint/APS); no executable suite |
| `audit-writing` | `static @ NORMALIZE` (lint/APS); no executable suite |
| `bug-report-writing` | `static @ NORMALIZE` (lint/APS); no executable suite |
| `deepen-audit` | `static @ NORMALIZE` (lint/APS); `manual @ REVIEW` for evidence |
| `review` | `manual @ REVIEW` over recorded evidence; re-run of bound `cmd*` proofs |
| `orchestration` | `static @ LOWER` (disjointness check); `manual @ REVIEW` |

How to read the matrix:

- The **phase** in each cell is where the proof runs. Code-producing kinds run their executable proofs at `VERIFY`; the document-producing kinds (`*-writing`, `deepen-audit`) have no executable suite and only lint at `NORMALIZE`; `orchestration` checks write-surface disjointness at `LOWER`.
- A `manual @ REVIEW` entry is the honest escape hatch where no executable oracle exists (`manual` MUST still carry a `REASON` and an `EVIDENCE` ref — see [proof types](proof-types.md)).
- `property\|contract` means *either* type satisfies the row.

### The conformance-manifest shadow (`cmd*` slots and gates)

The conformance manifest encodes the same matrix as the machine-readable `required_suite` in `conformance.yaml`, resolving each `(proof-type @ phase)` recommendation to concrete `cmd*` adapter slots (looked up through `AGENTS.md > Commands`) plus named equivalence/coverage gates. The proof-type matrix above is the human-readable canonical view; the YAML is its shadow. The five gate tokens are defined here so the matrix is self-contained:

| Gate token | Check |
| --- | --- |
| `acceptance-criteria-coverage` | Every acceptance criterion of the obligation maps to a passing proof. |
| `regression-test` | A test that failed before the change and passes after. |
| `behaviour-preservation` | A property/differential/metamorphic check that the change preserves prior behaviour. |
| `scope-disjointness` | The merged workers' `OWNED` paths are pairwise disjoint. |
| `merge-intent` | Each merge-conflict resolution preserves both obligations' intent. |

A `merged:` prefix on a slot means it runs on the post-integration merged result. Illustrative manifest rows (the full set mirrors this page row-for-row):

```yaml
required_suite:
  feature:        [cmdValidate, cmdTest, cmdValidateDeps, gate:acceptance-criteria-coverage]
  fix:            [cmdValidate, cmdTest, gate:regression-test]
  refactor:       [cmdValidateDeps, cmdTypecheck, cmdTest, gate:behaviour-preservation]
  orchestration:  [merged:cmdValidate, merged:cmdTest, gate:scope-disjointness, gate:merge-intent]
```

## The verdict model (7 = 4 core + 3 lifecycle)

A verdict carries **exactly one** core value and **zero or more** lifecycle decorators. The four core values are mutually exclusive; a single bound proof on a single run lands in exactly one.

| Role | Value | Meaning |
| --- | --- | --- |
| Core | `PASS` | A bound proof ran and its result satisfies the obligation. |
| Core | `FAIL` | A bound proof ran and its result contradicts the obligation. |
| Core | `BLOCKED` | A bound proof could not run (missing prerequisite/tool/adapter/env/fixture); truth unknown, not false. |
| Core | `UNVERIFIED` | No acceptable proof was bound, or a binding exists but no run was attempted. |
| Lifecycle | `WAIVED` | Decorates `FAIL` or `UNVERIFIED`: explicitly accepted as an exception (authority, reason, expiry). |
| Lifecycle | `STALE` | Decorates a prior `PASS`: its evidence no longer matches current source/surface hashes (drift — see [drift and staleness](drift-and-staleness.md)). |
| Lifecycle | `CONTRADICTED` | Decorates any core: two proofs disagree, or a `TRACE`/code disagrees with the obligation. |

`BLOCKED` and `UNVERIFIED` MUST NOT be conflated (they route differently — an environment fix vs. a binding/execution gap). The merge gate expects **one verdict per required `VERIFY BY` binding**, and all required bindings must be `PASS`/`WAIVED` to merge.

When two proofs disagree (`CONTRADICTED`), the tie-break uses a fixed proof-strength order over the nine types:

```text
model  >  property | contract  >  test  >  static  >  manual | monitor
```

A reconciliation caveat: only the **counts** are frozen, not every row of the default-suite matrix. The suites are recommendations — an author MAY override per obligation, and a kind's suite may evolve without a language-version change. Likewise the `cmd*` slot names in the manifest shadow (`cmdValidate`, `cmdValidateDeps`, etc.) are project-resolved through `AGENTS.md > Commands`; their exact spelling is a manifest convention, while the proof-type matrix above is the canonical layer.

## Artifact homes (where everything lives)

An artifact is homed by **scope**, not by type ([ADR-0052](../adrs/0052-per-feature-spec-folders.md)): a
feature is the unit of organization, and feature-scoped artifacts co-locate with the spec they serve. One
table, so "where does X go?" is answerable in one place.

| Artifact | Scope | Home |
| --- | --- | --- |
| `spec.swarm.md` | feature | `specs/<feature>/spec.swarm.md` |
| `audit` · `research` · `bug-report` · `prd` · `rfc` · `threat-model` | feature | `specs/<feature>/` — co-located beside the spec |
| `adr` | project-wide | `decisions/` — sequentially numbered, one per file |
| `finding` | durable recall | `.agents/memory/findings/<slug>.md` |
| `memory/INDEX.md` · `glossary.md` · `patterns/` | durable recall | `.agents/memory/` |
| `task` · `trace` · `review` · `status` · `task-orchestration` | execution scratch | gitignored (`.agents/tasks/`) or the linked PR — a *kept* review may land in `specs/<feature>/` |

The asymmetry — `specs/` is per-feature folders, `decisions/` is flat numbered files — is deliberate: an ADR
is the one genuinely project-wide artifact, not bound to a single feature. The `.swarm.` infix marks the
**Swarm-format** files (the spec + emitted `*.swarm.*`); everything else is a plain-`.md` working artifact.

## Related

- [SOL](../language/SOL.md) — the block-type and modal semantics behind their counts here.
- [proof types](proof-types.md) — the `VERIFY BY` binding grammar, adapter resolution, proof-type → `cmd*` mapping, and verdict mechanics.
- [errors](../language/errors.md) — the five lint layers and the `SOL-<LAYER>NNN` code catalogue.
- [drift and staleness](drift-and-staleness.md) — how a prior `PASS` becomes `STALE` and the maturity ladder.
- [structured form](structured-form.md) — where the obligations and the two derived graphs emitted by `lower` are defined.
