---
type: adr
id: adr-0122
status: accepted
created: 2026-07-01
updated: 2026-07-02
---

# ADR-0122 — Revolver Review: a bounded, named form of the lead-orchestrated review panel

## Context

[ADR-0099](./0099-review-orchestration-and-role-routing.md) established the review model: a review
lead chooses at least three distinct lenses, runs them as independent subreviewers that return
findings + evidence only, reconciles into one packet, and the human owns the verdict. The
suspec-works roadmap (#77/#78/#79/#85) proposes **Revolver Review** — a named strategy that adds a
"stance wheel", a candidate-finding schema, a deterministic-check/context-slicing policy, and a fixed
configuration (9 stances / 3 agents / 3-per-agent / 2 rounds).

A July 2026 deep-research pass verifying that roadmap against primary sources found the direction sound
but four things needing correction before it can be leaned on: the diversity payoff is **modest and
about ordering** — a few genuinely distinct lenses beat more identical copies — not the claimed large
ratio, and its matched-count delta is small
([[DIVSCALE]](../research/sources.md#DIVSCALE)); **transfer to code review is unconfirmed** (the
supporting evidence is small models on QA/math); the invented **counts are unproven**; and one framing
— *Suspec runs the deterministic checks as a pre-gate* — **collides with the reconcile-only boundary**
([ADR-0086](./0086-deterministic-review-scanning-decision.md) Decision 5,
[ADR-0077](./0077-suspec-cli-reconcile-only-harness.md) D8). This ADR names Revolver as the **bounded
form of ADR-0099's panel** and records the review-packet capture it needs — **additively**, without
changing the frozen format.

## Decision

**Revolver Review is the bounded, named form of the [ADR-0099](./0099-review-orchestration-and-role-routing.md)
lead-orchestrated independent-lens panel — it adds no new review authority.**

1. **The flow is ADR-0099's, bounded.** A lead picks a few **distinct** lenses from a menu by the
   change's risk; same-round lenses run **blind and isolated** and **draft before they compare**
   (reading a peer's raw output induces conformity —
   [[CONSENSUSCOST]](../research/sources.md#CONSENSUSCOST)); the lead reconciles into one report; the
   **human owns the verdict** ([ADR-0077](./0077-suspec-cli-reconcile-only-harness.md) D8). A lens
   reviewer never renders the status or the suggested decision. The **cross-round exchange format** —
   total isolation versus an adjudicated summary — is **open**: the tested remedy is *isolation*
   ([[CONSENSUSCOST]](../research/sources.md#CONSENSUSCOST)), so same-round isolation is the
   load-bearing rule and any cross-round summary is a conservative design choice, not an evidence-backed
   one. _Level: convention/checklist — nothing enforces it._

2. **The stance wheel is a lens MENU; counts are measured defaults, not law.** No stance/agent/round
   count is canon — not 9/3/3/2, not any number. The strategy stops adding lenses/rounds when the
   **marginal unique accepted findings** dry up (plus hard budget/round caps), never on silence or
   agreement. Any count or cheap-tier default is **validated on the review-gate benchmark** by marginal
   unique-accepted-finding yield and cost-versus-unique-yield; the diversity payoff is modest and about
   ordering ([[DIVSCALE]](../research/sources.md#DIVSCALE)), and code-review transfer is flagged
   unconfirmed. _Level: convention._

3. **Candidate-finding adjudication is captured additively.** Lens output enters as a **candidate** and
   the lead moves it to **accepted / rejected / duplicate / unverified / blocked**. This is an
   **optional, additive** capture in the review packet — an opt-in section that leaves the frozen
   requirement-coverage table and the Pass/Fail/Unverified/Blocked verdict enum unchanged (the
   [ADR-0060](./0060-suspec-workspace.md) Decision 4 / ADR-0099 additive-amendment pattern; the review
   packet **format does not change**). An accepted finding carries concrete evidence; reviewer
   confidence is **non-evidence**; deduplication feeds the unique-finding count the stop rule reads;
   a review is **never** auto-closed on agent agreement (agreement is not a correctness signal —
   [[CORRELATED]](../research/sources.md#CORRELATED)). _Level: convention (the kit review template
   carries the optional capture)._

4. **Deterministic checks are reconciled, not run.** The reviewer or worker runs the project's
   build/test/lint commands; Revolver **reconciles the pasted, already-run output** and never spawns
   the project's commands ([ADR-0086](./0086-deterministic-review-scanning-decision.md) Decision 5,
   [ADR-0077](./0077-suspec-cli-reconcile-only-harness.md) D8). The lever is reliable, **actionable**
   structured evidence over free-form critique
   ([ADR-0121](./0121-evidence-gating-load-bearing-mechanic.md);
   [[CRITIC-TOOL]](../research/sources.md#CRITIC-TOOL),
   [[FLIPFLOP]](../research/sources.md#FLIPFLOP)) — a surfaced, interpretable result, not a raw trace.
   _Level: convention._

5. **Per-lens cost tiers are opt-in and owned by the model-routing convention** (a separate decision):
   blind lenses default cheaper, the reconciling lead and high-risk lenses (security, architecture)
   stronger, resolved by the runner — **no shipped model defaults**, and model **size is never a
   quality proxy**. A mixed-tier panel also **decorrelates** the reviewers. _Level: convention._

## Alternatives considered

| Alternative | Why rejected |
| --- | --- |
| Ship the fixed `9/3/3/2` stance profile as canon | The counts are unproven and code-review transfer is unconfirmed; a validated-looking constant would overclaim. Ship a menu + a measured stop rule. |
| A new frozen review-packet format for candidate findings | ADR-0099 already holds the format stable; the capture is additive/optional, exactly like the lens/plan capture. A re-freeze is unwarranted churn. |
| Rename `adversarial-review` into Revolver | #85's explicit non-goal. `adversarial-review` is the per-lens discipline; Revolver is the orchestration around a panel of it. Keep both. |
| Have the strategy run the deterministic checks as a pre-gate | Crosses the reconcile-only boundary (ADR-0086 D5 / ADR-0077 D8). Reconcile already-run evidence instead. |

## Consequences

- **No verdict-model change and no format re-freeze.** Pass/Fail/Unverified/Blocked and the coverage
  table stand; the candidate-finding section is additive and opt-in.
- **`adversarial-review` is unchanged** — each Revolver lens runs it; no rename, no absorption.
- **The counts stay honest.** The public strategy carries no count-bearing prose asserted as proven
  ([ADR-0117](./0117-no-count-bearing-prose.md)); the numbers live in the measurement, not the doctrine.
- **The review-gate benchmark gains a Revolver measurement track** (marginal unique-yield per lens/round;
  cost-vs-yield per lens/tier) — a reopen of its v1 list, not new standing infrastructure.
- **The universal `revolver-review` skill** (suspec-skills) carries the strategy framework-free and
  citation-free ([ADR-0113](./0113-product-vs-docs-boundary.md)); the evidence lives here.

## Status

Accepted (2026-07-02). **Refines / extends** [ADR-0099](./0099-review-orchestration-and-role-routing.md) (names and
bounds the panel). **Honors** [ADR-0077](./0077-suspec-cli-reconcile-only-harness.md) D8 and
[ADR-0086](./0086-deterministic-review-scanning-decision.md) Decision 5 (reconcile-only),
[ADR-0121](./0121-evidence-gating-load-bearing-mechanic.md) (evidence-gating),
[ADR-0060](./0060-suspec-workspace.md) Decision 4 (additive packet amendment), and
[ADR-0117](./0117-no-count-bearing-prose.md) (no count-bearing prose). **Relates**
[ADR-0095](./0095-review-model-grounding.md), [ADR-0056](./0056-adversarial-self-review-completion-discipline.md),
and [ADR-0119](./0119-independent-review-invariant.md). The per-lens **cost-tier convention is a separate
decision** (the model-routing wave).
