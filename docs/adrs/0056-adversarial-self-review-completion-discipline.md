---
type: adr
id: 0056-adversarial-self-review-completion-discipline
status: accepted
created: 2026-06-08
updated: 2026-06-08
supersedes:
superseded_by:
---

# ADR-0056: Adversarial self-review is a mandatory completion discipline

## Context

Corpus has two relevant mechanisms, and a gap between them:

- The **`## Self-review`** block on a task (`docs/passes/implement.md`, the task template) — but it is a
  *checklist*: "did I do only this step; preserve semantics; map every claim to evidence." A checklist catches
  **omissions**; it does not catch the **plausible-but-wrong** — the confident green summary that is simply
  incorrect, which is the dominant agent failure mode.
- The **`persona-skeptic`** profile (refute-by-default) — but it is scoped to **independent** review: its own
  card says *"Never judge a change you authored."* So the one stance built to catch the plausible-but-wrong is
  explicitly withheld from the actor's own work.

The result: nothing in the framework requires an implementer to **adversarially** review their *own* output
before declaring it done. Self-critique measurably improves agent output [[REFLEXION]](../research/sources.md#REFLEXION),
and the implementer is precisely the actor most prone to over-trusting their own result — yet the discipline
was absent. (Raised in dogfooding: the operator asked that finishing *any* work include an adversarial
self-review as the skeptic.)

## Decision

**Adversarial self-review is a mandatory completion discipline.** Before any work is marked `done`, the actor
MUST adopt the **skeptic stance over their own output** — refute-by-default — and record it in `## Self-review`:
actively try to make each completion claim *fail* (re-run the bound proofs from a clean state; hunt the
unexercised path — edge/error/concurrency — especially for `RISK high|critical`; check for scope creep and
silent semantic drift; treat your own confident prose as a confession, not a proof), then fix what it surfaces.

**It is necessary but NOT sufficient — and it is NOT the gate.** This reconciles with `implementer ≠ reviewer`
(the self-preference hazard, `docs/passes/review.md`): adversarial self-review produces **fixes + a recorded
self-critique**, never a gate **verdict**. A self-issued `PASS` remains inadmissible; the independent `review`
step still renders the merge gate. The skeptic persona's "never judge a change you authored" continues to bar
the implementer from *issuing the verdict* — it does not excuse them from *attacking their own work first*.
Self-review is the cheap pre-handoff pass that catches your own holes before an independent reviewer (or the
gate) has to; the two are complementary, not substitutes.

**Scope:** every completed deliverable. For `implement`/`fix`, refute the proofs and the scope/semantics
boundary. For an authoring/analysis deliverable (spec, audit, research, bug-report, or a framework change like
this one), the adversarial pass is *try to refute your own obligations / findings / claims* before declaring
the artifact done.

## Alternatives considered

| Alternative | Why rejected |
| --- | --- |
| Keep the checklist `## Self-review` | A checklist catches omissions, not the plausible-but-wrong; that is exactly what the skeptic stance — and [REFLEXION]-style self-critique — exists to catch. |
| Let the skeptic persona self-judge the gate on its own work | Breaks `implementer ≠ reviewer` and the self-preference hazard. A self-issued verdict is not independent. Self-review must produce fixes + a critique, never a verdict. |
| A brand-new step in the 9-step flow | Out of scope and unnecessary — it strengthens an existing block (`## Self-review`) and an existing profile (`persona-skeptic`); it changes no closed set. |

## Consequences

- **Positive:** the plausible-but-wrong is attacked at the cheapest point — by the author, before handoff;
  the discipline is **standing**, not ad hoc; the skeptic stance is no longer withheld from one's own work.
- **Negative:** one more pass on every task — proportionate, since a defect caught at self-review is the
  cheapest defect to fix.
- **Neutral:** no closed set, grammar, step, verdict, or artifact change; `implementer ≠ reviewer` and the
  independent gate are untouched (explicitly reaffirmed).

## Status

Accepted (v0.1). The `## Self-review` strengthening, the task-template prompts, the `persona-skeptic` +
`implement-and-verify` updates, and the universal-rule addition are this change.

## Affected obligations / constraints

- **Refines:** the `implement` step (`docs/passes/implement.md` `## Self-review`), `persona-skeptic`, the
  `implement-and-verify` skill, and the universal working rules (`AGENTS.md`).
- **Reaffirms (does not change):** `implementer ≠ reviewer` and the independent merge gate (`docs/passes/review.md`).
- **Grounded by:** [[REFLEXION]](../research/sources.md#REFLEXION) (self-critique improves output) + the
  self-preference hazard already cited in `review`.
- **Does NOT change:** any closed set, the SOL grammar, the nine steps, the verdict model, or the artifact set.

> **Ledger note (2026-06-11):** refined by ADR-0064 (self-review carried inside the implement-task guide).
