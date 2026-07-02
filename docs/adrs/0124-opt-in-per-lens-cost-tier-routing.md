---
type: adr
id: adr-0124
status: accepted
created: 2026-07-01
updated: 2026-07-02
---

# ADR-0124 — Model cost-routing: an opt-in per-lens cost-tier convention the runner resolves

## Context

Revolver Review ([ADR-0122](./0122-revolver-review-bounded-panel-strategy.md)) routes review lenses
through an opt-in per-lens cost-tier map, and `suspec-agents/docs/runners.md` already ships **no model
defaults on purpose** ([ADR-0099](./0099-review-orchestration-and-role-routing.md) also makes a cheaper
implementer viable only when the saving is *measured*). The suspec-works roadmap (#74/#75/#76) proposes a
model-routing preflight built around an `economy`/`balanced`/`maximum-scrutiny` ladder keyed to model
**size/tier**, a runner capability matrix, and cost/yield metrics.

A July 2026 deep-research pass verifying that roadmap against primary sources found the routing layer sound
but the size ladder wrong: model **tier is non-monotonic** for review — a bigger/newer model can
underperform a predecessor ([[BIGGERNOTBETTER]](../research/sources.md#BIGGERNOTBETTER)); **synthetic→real
is a ~92% F1 collapse** ([[BIGGERNOTBETTER]](../research/sources.md#BIGGERNOTBETTER)), so a cheap model must
be validated on real changes; review **volume dilutes** — more comments correlate with slower resolution
and lower relevance ([[REVBOTPR]](../research/sources.md#REVBOTPR)); and a single agent can beat a
multi-agent panel under **matched compute** ([[SINGLEBEATSMAS]](../research/sources.md#SINGLEBEATSMAS)),
bounding fan-out. This ADR ships routing as an **opt-in convention the runner resolves**, drops the size
ladder, and corrects the matrix and the metrics.

## Decision

**Model selection lives in the runner; Suspec ships only an opt-in role→tier map.**

1. **An opt-in per-lens cost-tier map, runner-resolved.** The convention defines a map from review
   roles/lenses to abstract tiers (`cheap` / `mid` / `strong`); the **runner adapter** resolves the alias
   to a concrete model (Claude Code `model:`, Codex `model` / `model_reasoning_effort`, a workflow's
   `agent({model})`). There is **no Suspec router service**, **no shipped model default**, and the concrete
   alias table is **adapter/adopter-owned**, never frozen in canon. `ask` / `auto` / `locked` modes exist;
   a non-interactive/CI run **never prompts**; a runner that cannot honor a tier surfaces the gap as
   human-attention, never a silent downgrade. _Level: convention._

2. **Route the fan-out cheap, the reconciler and high-risk lenses strong.** Blind lens reviewers default to
   a cheaper tier; the reconciling lead and high-risk lenses (security, architecture) to a stronger tier. A
   mixed-tier panel should also **decorrelate** the reviewers — models err in correlated ways, and the
   correlation grows with capability ([[CORRELATED]](../research/sources.md#CORRELATED)) — a diversity
   gain, not only a cost cut. _Level: convention._

3. **Size is never a quality proxy; capability profile is the axis.** Model tier/size is **non-monotonic**
   for review quality ([[BIGGERNOTBETTER]](../research/sources.md#BIGGERNOTBETTER)) — routing is a **cost**
   lever, not a scrutiny ladder. The runner docs name the **capability profile
   (reasoning/calibration/SNR)** as the axis that transfers — the row a full runner capability matrix
   would carry — and diversity is framed around the **ordering** — a few genuinely
   distinct models beat more identical copies — not a large "8×" / "2 ≈ 16" ratio (the matched-count delta
   is modest — [[DIVSCALE]](../research/sources.md#DIVSCALE)). _Level: convention._

4. **Validate any cheap tier on real changes matched to the regime.** A cheap-tier default is a hypothesis
   until validated on **real changes matched to the target diff-size regime** — synthetic-benchmark wins do
   not transfer (~92% F1 collapse, ~15× diff-size cliff —
   [[BIGGERNOTBETTER]](../research/sources.md#BIGGERNOTBETTER)). _Level: convention/checklist._

5. **The headline metric is marginal unique-accepted value.** Cost/yield is recorded as **review-record
   fields** (not a metrics service), and the load-bearing metric is **marginal unique-accepted-finding**
   value — cost-versus-unique-yield per lens×tier — not raw candidate/comment count (volume dilutes —
   [[REVBOTPR]](../research/sources.md#REVBOTPR)). Measuring it **extends the review-gate benchmark** as a
   v1 reopen — the frozen v0 measures recall/precision only and carries no cost/yield/tier axis yet. Weigh
   the
   **equal-token-budget counter** — a single agent can beat a panel under matched compute
   ([[SINGLEBEATSMAS]](../research/sources.md#SINGLEBEATSMAS)) — before defaulting to fan-out.
   _Level: convention._

## Alternatives considered

| Alternative | Why rejected |
| --- | --- |
| The `economy`/`balanced`/`maximum-scrutiny` ladder keyed to model size | Tier is non-monotonic for review ([[BIGGERNOTBETTER]](../research/sources.md#BIGGERNOTBETTER)); a size ladder can pay 3× cost for no gain. Tiers are a cost lever, validated per task. |
| A per-workflow model-router service | No runtime; the runner already selects the model. Suspec ships the map, the adapter resolves it. |
| Ship default concrete models per tier | `runners.md` ships no defaults on purpose; a frozen model list rots and presumes an availability Suspec cannot guarantee. |
| Raw finding-count / comment-volume as the quality metric | Volume dilutes ([[REVBOTPR]](../research/sources.md#REVBOTPR)); marginal unique-accepted value is the honest headline. |
| Trust a cheap model on synthetic-benchmark wins | Synthetic→real is a ~92% F1 collapse; validate on real changes matched to the diff-size regime. |

## Consequences

- **No runtime router, no shipped defaults, size ≠ quality.** The map is a convention; its resolution is
  the runner's; the concrete alias table is adapter-owned.
- **`suspec-agents/docs/runners.md` names the capability-profile axis** and notes that per-lens routing is
  an opt-in adopter knob (no defaults); concrete per-runner alias tables stay adapter-owned.
- **Metrics are review-record fields**, not a service; the headline is marginal unique-accepted value.
  Validating cost/yield **extends the review-gate benchmark** (a v1 reopen — its frozen v0 measures
  recall/precision only, with no cost/yield/tier axis yet).
- **Revolver consumes this map** ([ADR-0122](./0122-revolver-review-bounded-panel-strategy.md)); the
  fan-out/reconciler split and the decorrelation benefit are stated once, here.
- **No count-bearing prose** ([ADR-0117](./0117-no-count-bearing-prose.md)) — the numbers live in the
  measurement, not the doctrine.

## Status

Accepted (2026-07-02). **Serves / extends** [ADR-0122](./0122-revolver-review-bounded-panel-strategy.md) (the cost-tier
map Revolver references) and [ADR-0099](./0099-review-orchestration-and-role-routing.md) (model
routing/escalation + the measured-cost rule). **Honors**
[ADR-0063](./0063-honesty-framework-and-tooling-boundary.md) (levels) and
[ADR-0117](./0117-no-count-bearing-prose.md) (no count-bearing prose). **Relates** the
`suspec-agents/docs/runners.md` no-model-defaults posture and
[ADR-0121](./0121-evidence-gating-load-bearing-mechanic.md).
