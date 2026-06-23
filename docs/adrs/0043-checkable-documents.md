---
type: adr
id: 0043-checkable-documents
status: proposed
created: 2026-06-04
updated: 2026-06-06
supersedes:
superseded_by:
---

# ADR-0043: Checkable documents — what is lintable, and with what

## Context

Corpus has a controlled obligation language (SOL, [0027](./0027-sol-is-the-obligation-language.md)) and a blocking `lint` pass ([0029](./0029-nine-pass-compiler-model.md), [0034](./0034-unified-lint-namespace.md)), both scoped to `spec.md`. A recurring design question — swept with live web verification and recorded in [`.agents/lintable-docs-improvement-plan.md`](././.agents/lintable-docs-improvement-plan.md) — is whether the lintable / structured-checkability discipline should extend to the **other agent-interpreted artifacts**: the source documents (`audit.md`, `research.md`, `bug-report.md`), the working artifacts (`finding.md`, the prose of `review.md`, `memory/`), and the repo-context files (`AGENTS.md`, the `SKILL.md` set).

The naïve reading — "extend lintable structure to those docs ⇒ more structure ⇒ more reliable" — is **contradicted by the strongest, most recent measured evidence**, which converges on a sharper partition: structure helps when it is *typed answer-slots and checkable evidence binding on the frame*; it hurts when it is *more prose or rigid schema wrapped around free reasoning*; and the reliability lever is a *deterministic external check*, never the model judging or voting on itself. This ADR records that partition so future passes know what to add — and, more load-bearingly, what **not** to add.

## Decision

The lintable surface is partitioned as follows.

1. **Obligation-blocks and the blocking obligation-lint gate stay spec-only.** Only `spec.md` carries `REQ`/`CONSTRAINT`/`INVARIANT`/`INTERFACE`/`QUESTION` blocks, and only it is subject to the blocking `SOL-S`/`SOL-M`/`SOL-V`/`SOL-O` layers and the blocking `SOL-P001`–`P008` set behind the CLARIFY gate (§8, §9, §11.6). **No obligation grammar runs on an audit, finding, research doc, or review.** This is the regime where typed structure measurably *helps* — typed answer-slots and output contracts ([[FORMATFREE]](../research/sources.md#FORMATFREE), [[SCOT]](../research/sources.md#SCOT)) — and pushing it into free-reasoning documents is the regime where it *hurts*, and would collapse the epistemic-stance partition ([0030](./0030-unified-artifact-set.md), §29.1).

2. **Other agent-interpreted artifacts are checkable along a *subtractive + checkable* dimension — never additive structure.** The checkable properties are integrity properties of the *frame*, not new prose schema: **provenance-resolution** (a fact-shaped claim carries a *resolving* evidence anchor), **evidence-before-conclusion ordering**, **staleness / conflict**, and **minimality / anti-bloat**. Adding structured agent prose is a measured liability: over-specified context files reduce success and raise cost ([[AGENTSMD-HARM]](../research/sources.md#AGENTSMD-HARM)), and most added skill docs are inert with some actively harmful via staleness ([[SWESKILLS]](../research/sources.md#SWESKILLS)). What helps is machine-*checkable* / executable, not machine-*readable* ([[ORACLESWE]](../research/sources.md#ORACLESWE), [[EVIBOUND]](../research/sources.md#EVIBOUND)).

3. **Structure binds the frame and metadata; the reasoning body stays free-form.** An agent reasons free-form, then **emits** the structured artifact (decouple — never format while reasoning): format restriction degrades reasoning purely by ordering the answer before the reason, and decoupling recovers the loss ([[FORMATFREE]](../research/sources.md#FORMATFREE), [[FORMATTAX]](../research/sources.md#FORMATTAX)). Evidence precedes the claim it supports ([[ATTRFIRST]](../research/sources.md#ATTRFIRST)); a conclusion-slot (e.g. a `VERDICT` line) is the *output* a pass emits after it has reasoned — the "classification" regime where structure is safe.

4. **Enforcement is deterministic, never an LLM judge or a vote.** A document-integrity check either **resolves a referent** (the `file:line` exists, the citation/URL resolves, the `content_hash` still matches) or it is an **advisory smell**. Agent agreement, self-consistency, and LLM self-critique are **not** correctness signals: judge agreement collapses without a reference ([[NOFREE]](../research/sources.md#NOFREE)), voting amplifies correlated errors ([[CORRELATED]](../research/sources.md#CORRELATED), [[CONSENSUS]](../research/sources.md#CONSENSUS)), and models cannot reliably self-correct without external feedback ([[SELFCORRECT]](../research/sources.md#SELFCORRECT)). This is the deterministic-check spine the framework already rests on (`VERIFY BY`, [0038](./0038-verify-by-adapters-through-commands.md); empirical-proof, [0008](./0008-empirical-proof-as-framework-primitive.md)).

5. **Namespace and severity.** These checks join the **one** unified `SOL-<LAYER><NNN>` namespace as **`SOL-P` (prose-layer) codes applied across the artifact set** — there is **no sixth layer** ([0034](./0034-unified-lint-namespace.md)'s five-layers↔passes invariant is preserved). A document-integrity check **MAY block only when it is backed by a deterministic resolving check** (an unresolved provenance anchor, a `content_hash`-detected staleness); a heuristic / requirements-smell check is **advisory only**, because lexical smell detection is precision-bounded (~48–59%, [[SMELLS]](../research/sources.md#SMELLS)). The blocking *obligation-lint* gate of point 1 is untouched and stays spec-only.

This record **refines, and does not supersede,** ADRs [0027](./0027-sol-is-the-obligation-language.md), [0028](./0028-aps-is-the-prose-standard.md), [0030](./0030-unified-artifact-set.md), [0032](./0032-memory-model.md), [0034](./0034-unified-lint-namespace.md), [0035](./0035-seven-value-verdict-model.md), and [0037](./0037-load-what-the-task-names.md). It is the **gate** for the implementing passes (provenance-enforced lint; the evidence-before-conclusion rule; the staleness/conflict lint; the minimality discipline; the inter-agent contract) catalogued in [`.agents/lintable-docs-improvement-plan.md`](././.agents/lintable-docs-improvement-plan.md); this ADR settles *what* and *with what*, not the individual code assignments, which each implementing pass fixes against §8.

## Alternatives considered

| Alternative | Why rejected |
| --- | --- |
| Extend the SOL obligation grammar (blocks) into audits / findings / research | The harmful regime: rigid schema around free reasoning degrades it ([[FORMATFREE]](../research/sources.md#FORMATFREE)); it blurs the epistemic-stance boundary the memory-injection literature motivates ([[MINJA]](../research/sources.md#MINJA)) and collapses the stance partition ([0030](./0030-unified-artifact-set.md), §29.1). |
| Raise reliability by adding richer structured agent prose / context files | Measured net-negative: over-specified context costs more for less ([[AGENTSMD-HARM]](../research/sources.md#AGENTSMD-HARM)); most added skill docs are inert and some harmful ([[SWESKILLS]](../research/sources.md#SWESKILLS)). The win condition for extending the lint is *subtractive*. |
| Grade agent docs with an LLM judge or a multi-agent vote | Not a verifier: judge agreement collapses without a reference ([[NOFREE]](../research/sources.md#NOFREE)); voting amplifies correlated errors that *grow* with capability ([[CORRELATED]](../research/sources.md#CORRELATED), [[CONSENSUS]](../research/sources.md#CONSENSUS)). |
| Add a sixth lint layer for documents | Breaks the five-layers↔passes invariant ([0034](./0034-unified-lint-namespace.md)); document-integrity checks fit the existing `SOL-P` prose layer as advisory codes. |
| Leave every non-spec artifact unchecked | The artifacts agents read most (findings, audits, memory, `AGENTS.md`) carry exactly the staleness and unresolved-provenance failure modes ([[SWESKILLS]](../research/sources.md#SWESKILLS), [[CITECHECK]](../research/sources.md#CITECHECK)); a cheap deterministic check there is high-leverage. |

## Consequences

### Positive

- The framework states **what not to add**, which is the load-bearing result: future passes cannot drift toward additive document schema in the name of "more rigor."
- A cheap, deterministic, mostly-advisory check surface for the most-read artifacts (provenance resolves, nothing stale, evidence before claim, minimal) — without touching the obligation-lint gate or the stance partition.
- Aligns the document layer with the framework's validated spine: an external deterministic check is the lever ([0038](./0038-verify-by-adapters-through-commands.md), [0008](./0008-empirical-proof-as-framework-primitive.md)), matching where the multi-agent-failure evidence puts the leverage (the system-design/specification and verification layers together ≈ 63% of failures, [[MAST]](../research/sources.md#MAST); contracts + verification cut failures 64–70%, [[SEMAP]](../research/sources.md#SEMAP)).

### Negative

- The `SOL-P` advisory catalogue grows (append-only with tombstoning, §8.1.1); authors meet a few more advisory codes.
- "Frame structured, reasoning free" is a boundary a reviewer or future tool applies by judgment; only the *resolving* checks (provenance, staleness) are fully mechanical. The ordering and minimality checks are partly heuristic and therefore advisory.

### Neutral / tradeoffs

- This is scope + severity guidance, not a new construct. The blocking obligation-lint gate, the five lint layers, the seven block types, the artifact set, the verdict set, and every canonical count are **unchanged**.

## Evidence and its limits (§0.7)

- **Stance separation is threat-motivated design, not a measured reliability gain.** [[MINJA]](../research/sources.md#MINJA) measures the *attack* (memory injection); Corpus's provenance/stance defense is sound, field-aligned design — its reliability delta is not separately measured. Claimed as design, not result.
- **No controlled "spec-first measurably wins" study exists** in the confirmed sources; the only hands-on numbers show heavyweight spec-driven development is *slower*. The discipline this ADR gates must stay **cheap and load-bearing, never ceremonial.**
- **Smell-style prose checks are advisory only** (~40%+ false-positive floor, [[SMELLS]](../research/sources.md#SMELLS)); blocking precision is reachable only against the defined SOL grammar (point 1), which is exactly why obligation-lint stays spec-only.
- Every **preprint**-grounded point above is corroboration of a direction, not the grounding of a `MUST` (the load-bearing claims rest on the peer-reviewed entries).

## Status

**Proposed / parked (not yet in force).** This records the *direction* for a checkable-document layer;
**no document-integrity lint rule has been built** — `lint.md` still scopes the `SOL-P` layer to
spec prose only. Nothing here modifies the live lint pass yet. The design note + backlog live in
`.agents/lintable-docs-improvement-plan.md`; promote this to `accepted` only when (and if) the rules land.

## Affected obligations / constraints

- Proposes (not yet applied): the lintable-document partition; the *subtractive-not-additive* doctrine for non-spec artifacts; the *deterministic-not-judge* enforcement rule; the *frame-structured / reasoning-free + reason-then-emit* rule.
- Would modify (when implemented, not yet): the `SOL-P` advisory layer's **scope** (spec-prose-only → the artifact set) and its **severity rule** (a document-integrity check blocks only when backed by a deterministic resolving check).
- Refines: [0027](./0027-sol-is-the-obligation-language.md), [0028](./0028-aps-is-the-prose-standard.md), [0030](./0030-unified-artifact-set.md), [0032](./0032-memory-model.md), [0034](./0034-unified-lint-namespace.md), [0035](./0035-seven-value-verdict-model.md), [0037](./0037-load-what-the-task-names.md). Relates to §8, §9, §11.6, §20.3 / §29.1, §23, §26.
- Does NOT change: the obligation grammar, the blocking obligation-lint gate (spec-only), the five lint layers, the seven block types, the verdict set, or any canonical count.

> **Ledger note (2026-06-11):** refined by ADR-0063.
