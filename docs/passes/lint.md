# The `lint` pass

> Swarm's reference for the `lint` pass: the non-mutating diagnostic pass, its unified `SOL-<LAYER><NNN>` taxonomy, the BLOCKING/ADVISORY model, the CLARIFY gate, and severity waivers.

## What `lint` is

`lint` is one of Swarm's nine compiler passes. It consumes a `spec.swarm.md` and emits a **lint report** — an array of diagnostic records plus an overall blocking status — without changing a single character of the spec. It is the highest-leverage pass because it catches defects *before any work is committed* (§9.4).

There is **no runtime** that runs `lint`. Like every pass, it is a **contract** a future tool will build against; today a human or an agent following the `lint` stdlib pass guide performs it by hand (§9.2). This repository ships no parser, linter, or checker — only the specification of what one must do (Invariant 1).

`lint` is **non-mutating** (§9.3.1). It MUST NOT change spec semantics or text; it only emits diagnostics. The one pass permitted to rewrite the spec is `improve`, and only semantics-preservingly. `improve` runs *after* `lint`, because each `improve` operation is triggered by one or more lint codes — running `improve` with no lint findings to answer is a no-op.

### Where `lint` sits in the pipeline

`lint` is the only pass that **straddles two phases**. It maps to both `PARSE` and `NORMALIZE` (§9.3): it is partly well-formedness detection (`PARSE`) and partly the surfacing of detected smells for normalization (`NORMALIZE`). The default pass order is:

```text
author -> lint -> improve -> lower -> decompose -> implement -> verify -> review -> promote
```

| Property | Value (§9.3) |
| --- | --- |
| Input artifact | `spec.swarm.md` |
| Output artifact | lint report `{code, severity, layer, span, message, suggest}[]` + blocking status |
| Phase(s) | `PARSE` + `NORMALIZE` |
| Carrier profile | Skeptic |
| Mutating? | No — emits diagnostics only |

`lint` ships a **dedicated stdlib pass guide** (§9.4); the guide is SOFT control (it tells an agent how to lint well) and MUST NOT define SOL/APS semantics, modality, authority order, or verification meaning — those live only in SOL and the IR. (`lint`, `decompose`, `review`, and `promote` each ship a dedicated pass guide; `implement` is served by the nine per-`task_kind` guides and `author` by the six author guides; `improve` and `lower` ship no guide; `verify` is served by the `empirical-proof` fragment — see ADR-0042.)

## What `lint` emits: the unified taxonomy

Every diagnostic uses one namespace: `SOL-<LAYER><NNN>` — the literal prefix `SOL`, a hyphen, one uppercase **layer letter**, and a three-digit number (§8.1.1). There are **exactly five layers**, each mirroring a compiler pass 1:1, each a 100-block, **append-only with tombstoning** (a retired code is tombstoned in Appendix B and its number is never reused).

| Layer | Letter | Domain | Mirrors pass / phase | Block range |
| --- | --- | --- | --- | --- |
| SYNTAX | `S` | Parser-detectable well-formedness | `lint` / `PARSE` | `SOL-S001…` |
| PROSE | `P` | Controlled-prose / requirement-smell, single-obligation-local (the APS prose layer) | `lint` / `NORMALIZE` | `SOL-P001…` |
| SEMANTIC | `M` | Cross-reference: duplicate id, contradiction, unbound ref | `improve` / `NORMALIZE` | `SOL-M001…` |
| VERIFICATION | `V` | Proof-binding: missing / stale / non-observable proof | `verify` / `VERIFY` | `SOL-V001…` |
| ORCHESTRATION | `O` | Planning / parallelism: write-conflict, dep cycle, blocking `QUESTION` reaching lowering | `decompose` / `LOWER` | `SOL-O001…` |

A code's letter indicates the phase it belongs to and which guide repairs it. Note that although the `O` layer is *raised* by any LOWER-phase pass (`lower` or `decompose`), it is *surfaced by the `lint` gate* (§8.1.1) — the layers and the passes are 1:1 by domain, not by who reports them.

`APS` is the *name* of the prose standard, not a code prefix (§8.5): prose-layer diagnostics surface as `SOL-P###` codes in the unified namespace, never as an `APS-` code. Tools and authors MUST cite only the unified `SOL-<LAYER>###` codes.

### The diagnostic record shape

Every emitted diagnostic MUST be the object `{ code, severity, layer, span, message, suggest }` (§8.1.2):

| Field | Type | Meaning |
| --- | --- | --- |
| `code` | string | A `SOL-<LAYER><NNN>` code from this taxonomy / Appendix B |
| `severity` | enum | `BLOCKING` \| `ADVISORY` (a recorded waiver, §8.6, demotes the IR `level` to `warning` or suppresses to `off`) |
| `layer` | enum | `S` \| `P` \| `M` \| `V` \| `O` (redundant with the code's letter; explicit for filtering) |
| `span` | object | Source location `{ file, block, line, col }` (minimally `{ file, block }`) |
| `message` | string | One-line human-readable defect statement |
| `suggest` | string \| null | The named repair — an `improve` op (§10) or a concrete fix; `null` if none |

The IR lowers the same data SARIF-shaped into `diagnostics[]`: `severity`→`level` (`BLOCKING`→`error`, `ADVISORY`→`warning`), `span`→`source { file, line_start, line_end }`, with `code` identical across both. The `level` vocabulary deliberately follows the SARIF static-analysis result format, so the IR's diagnostics map onto an industry-standard shape that existing tooling already understands.

```json
{
  "code": "SOL-P005",
  "severity": "BLOCKING",
  "layer": "P",
  "span": { "file": "auth-refresh.swarm.md", "block": "AC-001", "line": 22, "col": 9 },
  "message": "Vague-quality word 'gracefully' in a binding clause with no same-line observable criterion.",
  "suggest": "CONCRETIZE: replace with actor+action+object, or bind a VERIFY BY target."
}
```

## BLOCKING vs ADVISORY

The severity model is **strictly binary** (§8.2): every surface code lowers to `error` (BLOCKING) or `warning` (ADVISORY). The third IR `level` value, `note`, has **no surface producer in v0.1** — it is reserved for a future emitter and MUST NOT be produced by a conformant v0.1 checker.

- A rule is **BLOCKING** *if and only if* its defect changes **what gets built** — the obligation is incomplete, non-binding, untestable, ambiguous, contradictory, or unsafe to parallelize. A blocking diagnostic MUST be resolved before the artifact advances past the gate its layer is checked at (S/P/M block at the lint→`lower` gates of §11.6; V/O block at the merge gate of §14); none may remain unresolved at promotion unless waived.
- A rule is **ADVISORY** *if and only if* its defect affects only **how it reads** — style, length, voice, redundancy — without changing built behavior. It emits `warning` and does not block on its own.

The binding-clause vs commentary boundary (§7.2) re-classifies position-sensitive codes: `SOL-P056` (comparative without baseline) is BLOCKING inside an obligation block and ADVISORY in commentary; the high-risk-word rules (§7.3–§7.4) are BLOCKING only inside binding clauses.

*Design rationale:* whether a defect changes what gets built is detectable cheaply *before* generation — a focused classifier can separate build-changing defects from style noise more reliably than a general-purpose model, and under-specification is consistently the most severe class. That cheap-to-detect, high-cost-if-missed profile is exactly why actor/object incompleteness (`SOL-M001`) and uncaptured ambiguity (`SOL-P008`) carry BLOCKING status.

### Principal BLOCKING codes (§8.3)

**S layer — well-formedness:**

| Code | Defect |
| --- | --- |
| `SOL-S001` | Precondition (`WHEN`/`IF`/`WHILE`) with no actor clause / no modal consequence (dangling condition). |
| `SOL-S003` | Actor clause (`THE <actor> …`) with no modal verb. |
| `SOL-S005` | ID prefix does not match block type (e.g. `REQ C-001:`). |
| `SOL-S006` | `SHOULD` / `SHOULD NOT` used without an accompanying `BECAUSE` or `EXCEPT`. |
| `SOL-S012` | A `spec.swarm.md` missing a required top-level section, or sections out of mandated order (document-level companion of `SOL-O004`). |

**P layer — controlled prose (the blocking set `SOL-P001`–`SOL-P008`):**

| Code | Defect |
| --- | --- |
| `SOL-P001` | Dangling condition: trigger present, no modal consequence (prose companion of `SOL-S001`). |
| `SOL-P002` | Missing actor: an action with no `THE <actor>` subject. |
| `SOL-P003` | Missing / informal modality (e.g. lowercase `should` where a binding modal is intended). |
| `SOL-P004` | Bundled / overloaded obligation: separable obligations joined by `and`/`or`/`and/or` in one clause. |
| `SOL-P005` | Vague-quality / high-risk word in a binding clause with no same-line observable criterion (§7.3–§7.4). |
| `SOL-P006` | Undefined term used in a binding clause (no `TERM` / `memory/glossary.md` definition). |
| `SOL-P007` | Negation ambiguity: bare `MUST NOT` not paired with the affirmative behavior that should happen instead. |
| `SOL-P008` | Uncaptured behavioral uncertainty: an ambiguity stated in prose that should be lifted to a `QUESTION` block. |

**M layer — semantic:**

| Code | Defect |
| --- | --- |
| `SOL-M001` | Actor / object incompleteness: the obligation names a modal but not a resolvable actor *and* object. |
| `SOL-M002` | Contradiction: two obligations share a contradiction key (normalized actor + trigger/state + the `affects[]`/`writes[]` surface set) with opposed modalities — **exact-key match only in v0.1**. |

**V layer — verification:**

| Code | Defect |
| --- | --- |
| `SOL-V001` | Missing verification path: a binding obligation (`REQ`/`CONSTRAINT`/`INVARIANT`) or `INTERFACE` with no `VERIFY BY` (§15). |

**O layer — orchestration:**

| Code | Defect |
| --- | --- |
| `SOL-O001` | Write-conflict marked parallel: two work packets sharing a write surface scheduled in parallel (§18). |
| `SOL-O005` | Owned path outside declared write surface: an owned path not a subset of the assigned obligations' `WRITES` (§18, §19). |

### Principal ADVISORY codes (§8.4)

The advisory prose set is `SOL-P050`–`SOL-P058`; they emit `warning` and never block on their own (unless promoted by strict mode, §8.6).

| Code | Defect (style only) |
| --- | --- |
| `SOL-P050` | Pronoun / vague reference without a unique antecedent. |
| `SOL-P051` | Passive voice where an active actor+action is clearer. |
| `SOL-P052` | Sentence length exceeds ~20 words. |
| `SOL-P053` | Non-present or non-active tense. |
| `SOL-P054` | Prose noise: a decorative phrase that adds no constraint, context, or evidence. |
| `SOL-P055` | Redundancy: repeated context that adds no new constraint. |
| `SOL-P056` | Comparative / superlative without a baseline — **advisory in commentary, blocking in a binding clause** (§7.2). |
| `SOL-P057` | Terminology drift: a term used inconsistently with its `memory/glossary.md` definition (still resolves, so not the blocking `SOL-P006`). |
| `SOL-P058` | Deprecated modal alias: `SHALL`/`SHALL NOT` used as a modal (a recognized alias of `MUST`/`MUST NOT`, §5.4). |

## How a code maps to a fix

Each lint code names its repair in the `suggest` field, and the repair is one of the closed set of ten `improve` operations (§10). The trigger relationships the spec fixes (§10.2) include:

- `SOL-P003` (+ `SOL-V###`) → **NORMALIZE**
- `SOL-P004` → **ATOMIZE**
- `SOL-P005` → **CONCRETIZE** or **QUANTIFY** (same trigger; CONCRETIZE substitutes observable behavior, QUANTIFY substitutes a measurable threshold)
- `SOL-V001` (+ `SOL-V###`) → **BIND**
- `SOL-O###` → **SCOPE**
- `SOL-P008` → **CLARIFY** (the *operation* — see the gate distinction below)
- `SOL-M002` → **DECONFLICT**
- `SOL-P054`, `SOL-P055` → **COMPRESS**

`lint` only *names* the repair; applying it is the `improve` pass, which MUST be strictly semantics-preserving (R-IMPROVE, §10.1). If a proposed edit would change obligation intent, it leaves `improve` entirely and routes to amendment/review.

## The CLARIFY gate (where `lint`'s codes become a pre-`lower` checkpoint)

The `LOWER` phase is bracketed by two **pipeline gates**. A gate is *not a pass and not a transformation*: it writes no artifact, it is a **precondition predicate** over already-emitted state, and the pipeline MUST NOT advance an obligation past it while the predicate is unsatisfied (§11.6). The first of the two — the **CLARIFY gate** — sits at the `NORMALIZE`→`LOWER` boundary (before `lower`) and is decided by the `lint` carrier (§11.6.3).

> **R-CLARIFY-GATE (§11.6.1).** The `lower` pass MUST NOT proceed for any obligation while, *for that obligation*, any of the following holds:
> - an unresolved `[blocking]` `QUESTION` `AFFECTS` it — answered, or downgraded to `[non-blocking]` with rationale, clears it;
> - a blocking `SOL-M002` (contradiction) names it;
> - an unresolved `SOL-P008` (uncaptured behavioral ambiguity) attaches to it.
>
> A spec carrying any of these for an in-scope obligation is **not lowerable**; lowering past it would commit a guess as an obligation.

Three points keep this faithful to the spec:

1. **The gate introduces no new diagnostic.** A tripped CLARIFY gate surfaces as the *existing* code for the condition that tripped it — `SOL-O003` for the blocking question, `SOL-M002` for the contradiction, `SOL-P008` for the buried ambiguity. The gate aggregates these three conditions into one checkpoint; it is not a fourth code.
2. **It is the named generalization of R-BLOCKING-Q** (§11.1.2), which says a `[blocking]` `QUESTION` reaching `lower` is the orchestration error `SOL-O003`. R-CLARIFY-GATE lifts that single rule into a three-condition checkpoint that *also* catches unresolved contradiction and uncaptured ambiguity.
3. **Gate ≠ improve-op (§11.6, reconciliation).** The CLARIFY *gate* and the `CLARIFY` *improve operation* (§10.2, op 7) are distinct and MUST NOT be conflated. The op is a local `NORMALIZE`-phase edit that *creates* an explicit interpretation or `QUESTION` block from one buried `SOL-P008` ambiguity; the gate is the precondition that *waits on* such questions being discharged. The op is the repair; the gate is the check that the repair happened.

Both gates are **contracts checkable today by review and enforced by a future tool** — there is no runtime (Invariant 1). Today the `lint` carrier verifies the predicate by hand against the IR; a future compiler computes it from `nodes[]` and `edges[]`. A conformant repository MUST state the gate as a review-checkable contract and MUST NOT claim it is enforced by shipped tooling.

*Design rationale:* the planner→coder handoff is the dominant failure surface in multi-agent code generation — the gap between what a planner specifies and what a coder builds accounts for the majority of end-to-end failures — and agents do not reliably ask for help on their own: on messy, ambiguous specs even the strongest models solve only a small fraction of tasks, and do not improve much even when handed an explicit tool to ask clarifying questions. The cost of ambiguity is large and measurable: ambiguous descriptions sharply degrade first-attempt success, and contradictory ones degrade it further still, whereas a clarify-then-generate loop materially raises success. Clarifying *before* lowering is therefore a precondition for safe handoff, resolving ambiguity at the point where it is cheapest to fix.

## Severity overrides and waivers

Default severities are fixed by the spec (§8.6). A project MAY adjust them only through one configuration surface (a root `swarm.config.json`/`.yaml`, or the `lint:` section of an adopted project's `.swarm/config.yaml`), and only in two legal ways:

1. **Promote (strict mode):** raise an ADVISORY code to `error`. Always permitted; no record beyond the config entry.
2. **Demote (waiver):** lower a BLOCKING code to `warning` or `off`. Permitted **only** with a recorded waiver carrying an authority, a reason, and an expiry. A demotion without a complete waiver record is itself a conformance defect.

A `swarm.config` MUST NOT redefine, rename, or invent codes, MUST NOT change a code's `layer`, and MUST NOT demote a blocker by any means other than a waiver record. The waiver fields are `code`, `scope`, `to` (`warning` | `off`), `authority`, `reason`, `expiry`, `recorded_at` — all required. `to: off` suppresses the diagnostic entirely from the IR `diagnostics[]` array (it is not an IR `level`). A waiver **auto-expires** at its `expiry` date *and* on the next change to the waived obligation's source content-hash, whichever comes first, preventing zombie waivers.

A lint-layer demotion is distinct from a `WAIVED` verdict at the verification layer (§14): the former silences a *diagnostic*, the latter accepts a *failing proof* — both require the same authority + reason + expiry discipline.

## Related

- [The `improve` pass](improve.md) — the closed set of ten semantics-preserving operations each lint code routes to, with the full per-op preconditions and the semantic-diff classification.
- [The `lower` pass](lower.md) — the `LOWER` phase the CLARIFY gate brackets, and the COVERAGE gate that is the CLARIFY gate's sibling at the other LOWER boundary.
- [The `decompose` pass](decompose.md) — owner of the `O` (orchestration) layer: write-conflict, dependency-cycle, and the blocking-`QUESTION`-reaching-lowering codes.
- [The `verify` pass](verify.md) — owner of the `V` (verification) layer and the merge-gate where `V`/`O` blockers and `WAIVED` verdicts are decided.
- [SOL — the spec language](../language/SOL.md) and [APS — the controlled-prose standard](../language/APS.md) — the grammar and prose rules the `S` and `P` layers detect against.
- [Diagnostic codes (errors)](../language/errors.md) — the full per-layer code catalogue for the unified `SOL-<LAYER>###` namespace.
