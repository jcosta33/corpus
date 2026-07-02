---
type: adr
id: adr-0121
status: accepted
created: 2026-07-01
updated: 2026-07-02
---

# ADR-0121 — Evidence-gating is the load-bearing mechanic: ungrounded model judgment is not a review signal

## Context

Suspec's spine is evidence-first. "No evidence, no acceptance" is the review
model's participation gate ([ADR-0095](./0095-review-model-grounding.md)); the
harness is reconcile-only and captures already-run evidence rather than judging
([ADR-0077](./0077-suspec-cli-reconcile-only-harness.md) D8); adversarial
self-review re-reads the diff as a skeptic before done
([ADR-0056](./0056-adversarial-self-review-completion-discipline.md)). These were
adopted as disciplines — the right way to work.

A July 2026 deep-research pass verifying the suspec-works roadmap (#74–#86)
against primary sources found something stronger: the single most-replicated
result in the current agent literature is that **ungrounded model self-critique
measurably degrades correctness**, and the fix is grounding the critique on a
reliable, actionable, already-run signal. That converts Suspec's spine from a
stylistic preference into an empirically load-bearing mechanic — and it
constrains the roadmap's new critique surfaces (Revolver Review, Bulletproof),
which must not re-introduce ungrounded or consensus-based judgment.

## Decision

**A judgment on work — a review result, an accepted finding, or any critique a
Suspec surface renders — is gated on reliable, actionable, already-run evidence,
not on model confidence, agreement/consensus, or persona.** The participation
gate ([ADR-0095](./0095-review-model-grounding.md)) is not ceremony; it is the
highest-value lever the evidence identifies.

- **Ungrounded self-critique degrades.** In a matched ablation, tool-grounded
  critiquing gives **+2.1** solve-rate on GSM8k while the no-tool variant gives
  **−1.8** — self-critique falls *below* the initial answer
  ([[CRITIC-TOOL]](../research/sources.md#CRITIC-TOOL)); intrinsic
  self-correction degrades across rounds
  ([[NOSELFCORRECT]](../research/sources.md#NOSELFCORRECT)); an ungrounded
  "are you sure?" challenge drops accuracy **~17%** with a **46%** answer-flip
  rate ([[FLIPFLOP]](../research/sources.md#FLIPFLOP)). This is consistent with
  the existing canon: reliability needs an external signal
  ([[SELFCORRECT]](../research/sources.md#SELFCORRECT)), agreement is not a
  correctness signal ([[CORRELATED]](../research/sources.md#CORRELATED)), a model
  favors its own output ([[SELFPREFER]](../research/sources.md#SELFPREFER)).
- **The lever is reliable, *actionable* feedback — not the mere presence of a
  tool.** A raw check result earns its keep only when it is surfaced as an
  interpretable, structured signal a reviewer can act on; a tool trace nobody
  reads is not grounding.
- **Corollary (persona-free critique).** Because the lever is evidence, not
  identity, a critique surface drops the identity persona and keeps the explicit
  reasoning procedure — role framing helps only via its reasoning scaffold, not
  the role ([[ZHENG-PERSONA]](../research/sources.md#ZHENG-PERSONA),
  [[KONG-ROLEPLAY]](../research/sources.md#KONG-ROLEPLAY)); this is already
  [ADR-0093](./0093-collapse-1to1-personas.md).
- **Boundary preserved (reconcile-only).** Suspec gates on already-run evidence;
  it does not spawn the checks. Running the project's build/test commands stays a
  non-goal ([ADR-0077](./0077-suspec-cli-reconcile-only-harness.md) D8,
  [ADR-0086](./0086-deterministic-review-scanning-decision.md) Decision 5): the
  reviewer or worker runs the checks, Suspec reconciles the pasted result.
  "Evidence-gating" is therefore not "Suspec executes commands."

_Level: convention — a positioning and doctrine commitment; it names no new tool.
The partial mechanization already ships: suspec-cli's reconcile pass flags
empty-evidence Pass rows
([ADR-0086](./0086-deterministic-review-scanning-decision.md)), which stays the
toolable edge; the doctrine itself is convention._

## Consequences

- **Positioning.** Suspec's evidence-first spine is its empirically-backed
  differentiator, not overhead — the docs and site may say so, cited to the
  primary sources now recorded in `docs/research/sources.md`.
- **The roadmap inherits the gate.** Any critique surface the roadmap adds —
  Revolver Review (suspec-works #77/#85) and Bulletproof (#86) — gates its
  findings on reliable, actionable evidence, never on consensus or persona, and
  speaks of *reconciling already-run evidence* rather than *running a pre-gate*.
- **The evidence bibliography grows honestly.** New verified claims land in
  `docs/research/sources.md` at the tier the honesty framework
  ([ADR-0063](./0063-honesty-framework-and-tooling-boundary.md)) assigns —
  peer-reviewed findings load-bearing, 2026 preprints preliminary only.

## Status

Accepted (2026-07-02). Refines [ADR-0095](./0095-review-model-grounding.md) (participation
gate) and [ADR-0056](./0056-adversarial-self-review-completion-discipline.md)
(adversarial self-review); honors
[ADR-0063](./0063-honesty-framework-and-tooling-boundary.md),
[ADR-0077](./0077-suspec-cli-reconcile-only-harness.md) D8, and
[ADR-0086](./0086-deterministic-review-scanning-decision.md) Decision 5; relates
[ADR-0093](./0093-collapse-1to1-personas.md) (persona collapse) and
[ADR-0119](./0119-independent-review-invariant.md) (independent-review
invariant).
