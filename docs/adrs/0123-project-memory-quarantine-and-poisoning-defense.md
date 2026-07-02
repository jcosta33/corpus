---
type: adr
id: adr-0123
status: accepted
created: 2026-07-01
updated: 2026-07-02
---

# ADR-0123 — Project Memory: a quarantine state and a poisoning-defense framing, extending the accepted memory model

## Context

Suspec already has a memory model: [ADR-0032](./0032-memory-model.md) makes memory two-tier,
provenance-anchored, and promotion-gated — a durable fact becomes `accepted`/`promoted` only with
mandatory provenance (claim, evidence, origin, reviewer, timestamp, content hash, confidence, scope
envelope) — and [ADR-0067](./0067-memory-tiering.md) ships the core as `findings/` with
`status: candidate|accepted|stale`. The suspec-works roadmap (#80–#84) proposes a Project Memory system
that largely **re-derives this model** and, in places, forks it.

A July 2026 deep-research pass verifying that roadmap against primary sources found the model right but
three framings needing correction. **Provenance-first, promotion-gated, quarantined-candidate memory is
well-grounded specifically as a poisoning defense** — memory poisoning is real and low-footprint
([[AGENTPOISON]](../research/sources.md#AGENTPOISON) reaches high attack-success at well under 1% poisoned
context; [[MEMGRAFT]](../research/sources.md#MEMGRAFT); [[MINJA]](../research/sources.md#MINJA)), and
conservative write/promotion is the **design-favored** mitigation these attacks motivate — the attacks
are measured, the defense is a design lever, not a measured delta. **The memory-improves-outcomes claim is
not grounded**: the Mem0/Zep benchmark is non-reproducible — its judge accepts a majority of
intentionally-wrong answers, and full context can beat the memory system on its own data
([[MEMBENCH-CAVEAT]](../research/sources.md#MEMBENCH-CAVEAT)). And #83 **bundles** a grounded long-context
claim (accuracy degrades with input length despite full retrieval —
[[CTXLENHURTS]](../research/sources.md#CTXLENHURTS)) with an **unmeasured** "stale docs degrade agent
output" claim. This ADR extends ADR-0032/0067 with the narrow, genuinely-new additions and drops the
overclaims.

## Decision

**Extend the accepted memory model — do not fork it.**

1. **Add a `quarantined` state, additively.** The record lifecycle gains exactly one new value —
   **`quarantined`**, a candidate that is suspicious, conflicting, unsupported, or security-sensitive —
   alongside the accepted `candidate | accepted | stale` finding enum ([ADR-0067](./0067-memory-tiering.md);
   "active" reads as `accepted`, the trusted state). A quarantine reason is recorded; a quarantined
   record is never retrieved as active. This is an additive extension of
   [ADR-0032](./0032-memory-model.md)/[ADR-0067](./0067-memory-tiering.md), not a new or forked schema.
   _Level: convention._

2. **Provenance-before-active is a poisoning defense, not a performance lever.** ADR-0032 already mandates
   full provenance before `accepted`; this ADR states the *reason* explicitly: a generated or
   agent-proposed record enters as `candidate` and cannot become active without source references and a
   promotion rationale, **because conservative promotion is the design-favored poisoning mitigation these
   attacks motivate** ([[AGENTPOISON]](../research/sources.md#AGENTPOISON),
   [[MEMGRAFT]](../research/sources.md#MEMGRAFT)) — the attacks are measured; the defense is a design
   lever, not a measured delta. It carries **no** memory-outcome/accuracy claim — the
   supporting benchmark is broken ([[MEMBENCH-CAVEAT]](../research/sources.md#MEMBENCH-CAVEAT)). The
   promotion threshold and quarantine window are **tunable trade-offs**, not hardcoded constants (guard
   the over-conservative failure mode — too strict a threshold can reject legitimate records; design
   rationale, not a measured result). Cryptographic
   provenance signing is an **option** to consider, not a requirement (the signing mechanism is an
   unreviewed preprint). _Level: convention._

3. **Pre-action memory gates are a checklist convention (#82).** Before a risky action — editing a fragile
   file, restarting a failed repair loop, a high-diffusion change — a checklist convention surfaces the
   **provenance-visible** records scoped to that path/subsystem. No hidden ambient injection into prompts;
   memory that is missing or disabled degrades **visibly**, not silently. A future `suspec` grep over
   fragile-file/failure-pattern records is the toolable edge; the checklist is the convention today.
   _Level: checklist._

4. **Source-visible retrieval is a convention (#84).** Records handed to a review agent are a **minimal,
   source-visible packet** carrying record ids, states, and source references; **stale and quarantined
   records are excluded or visibly marked**; and memory is **never the sole evidence** for an accepted
   finding. Reading another agent's raw output can induce conformity
   ([[CONSENSUSCOST]](../research/sources.md#CONSENSUSCOST), measured on debate peers); the same caution —
   external context steering a model — motivates minimal, provenance-visible memory packets over ambient
   dumps (a design extension of that finding to retrieval, not a measured memory result).
   _Level: convention._

5. **Unbundle #83: keep long-context detection, reframe stale-memory.** Long-context / context-rot
   detection is kept as grounded — accuracy degrades with input length despite full retrieval
   ([[CTXLENHURTS]](../research/sources.md#CTXLENHURTS)). Stale-memory detection is **reframed** as an
   inconsistency-hygiene flag on the **existing drift machinery**
   ([ADR-0107](./0107-fast-track-staleness-detection.md) staleness signal /
   [ADR-0120](./0120-re-baselining-reconcile-drift.md) re-baselining): tools flag, humans resolve. The
   premise that a stale `AGENTS.md`/memory **degrades agent output** is measured by no primary source and
   is **dropped as a requirement** — it survives only as a hypothesis to validate. _Level: convention._

## Alternatives considered

| Alternative | Why rejected |
| --- | --- |
| A new/forked Project Memory store + schema | Duplicates the accepted ADR-0032/0067 model; a second source of truth is exactly what memory governance exists to prevent. Extend, don't fork. |
| Justify memory by measured outcome gains | The supporting benchmark is non-reproducible ([[MEMBENCH-CAVEAT]](../research/sources.md#MEMBENCH-CAVEAT)); the claim would overstate the evidence. Justify by provenance/security. |
| Mandate cryptographic signing of provenance | The signing mechanism is an unreviewed 2026 preprint; ship it as an option, not a requirement. |
| Assert stale docs/memory degrade agent output | No primary source measures the output effect; only prevalence is known. Keep it a hypothesis, handle staleness as hygiene. |
| Hard runtime block on a failed pre-action gate | No runtime, and a hard block frustrates legitimate change; a checklist that degrades visibly is the honest form. |

## Consequences

- **No new store, no forked schema, no performance claim.** The `quarantined` state and the framing are
  additive to ADR-0032/0067; memory stays a provenance-first derived artifact.
- **The finding template gains `quarantined` additively** (kit `templates/finding.md`), with a
  provenance-before-active note; the frozen sections are otherwise unchanged.
- **The drift machinery is reused, not rebuilt** — #83's stale-memory half rides ADR-0107/0120.
- **Honesty travels with the claim** — poisoning evidence is cited where it is load-bearing; the
  broken-benchmark caveat is recorded; the staleness-degrades-output claim is labeled a hypothesis.

## Status

Accepted (2026-07-02). **Extends** [ADR-0032](./0032-memory-model.md) and [ADR-0067](./0067-memory-tiering.md) (adds
the `quarantined` state + the poisoning-defense framing). **Honors**
[ADR-0063](./0063-honesty-framework-and-tooling-boundary.md) (levels),
[ADR-0107](./0107-fast-track-staleness-detection.md)/[ADR-0120](./0120-re-baselining-reconcile-drift.md)
(the drift machinery the stale-memory half reuses), and
[ADR-0121](./0121-evidence-gating-load-bearing-mechanic.md) (evidence-gating). **Relates**
[ADR-0113](./0113-product-vs-docs-boundary.md).
