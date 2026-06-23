---
type: adr
id: 0053-structured-spec-and-review-system
status: accepted
created: 2026-06-07
updated: 2026-06-07
supersedes:
superseded_by:
---

# ADR-0053: Corpus is a structured specification & review system (review-as-exceptions)

## Context

Recent agent-evaluation evidence is consistent on one point: **the surrounding system matters as much as the
model.** Harness/configuration choice alone moved aggregate scores by **23.8 points** on a fixed task set and
model pool [[HARNESSBENCH]](../research/sources.md#HARNESSBENCH); an automatic-harness method lifted
Terminal-Bench 2 pass@1 **69.7%→77.0%** with the gains coming from *tools, middleware, and memory — not the
system prompt* [[AHE]](../research/sources.md#AHE); a standardized harness + trace inspection is what made
agent evaluation tractable at all [[HAL]](../research/sources.md#HAL); and frontier agents still score
**< 65%** on hard, verifiable CLI tasks [[TERMBENCH]](../research/sources.md#TERMBENCH). In parallel,
**ambiguous requirements degrade code generation and models can't reliably self-resolve the ambiguity**
[[ORCHID]](../research/sources.md#ORCHID). And the productivity story is not what it feels like: a 2025 RCT
measured experienced developers **~19% slower** with AI while they *believed* they were faster
[[METR]](../research/sources.md#METR), and industry data finds adoption raises **both throughput and
instability** absent a control layer [[DORA2025]](../research/sources.md#DORA2025).

Read together, these say what Corpus should *be*, plainly: not "the smartest agent," but the layer that makes
agent work **legible, safe, and reproducible** — clear specs in, reviewable evidence out, with a verification
gate as the control the evidence says adoption lacks. The framing the framework had drifted toward
(spec-repo discipline, obligations, verdicts) is correct but under-stated; this ADR names the position.

Crucially, **the substance already exists** and needs no new machinery: the merge gate
([0035](./0035-seven-value-verdict-model.md)), the `WAIVED` lifecycle verdict, `status.md` (desired vs.
observed), source authority ([0031](./0031-source-authority-two-axis.md)), the trace/review separation, and
the recognized source-classes (`docs/artifacts/README.md §3`) are all in place. This is a **positioning
reframe over existing parts**, not a new layer.

## Decision

1. **Position Corpus as a structured specification & review system for agentic software work**: it turns messy
   inputs into verifiable specs, specs into bounded agent work, and large agent output into reviewable
   evidence.
2. **Foreground "review-as-exceptions" as the merge-gate payoff** — the productivity unlock and the control
   layer. A reviewer inspects **failed/unverified obligations, unauthorized changes, high-risk surfaces, and
   promotion decisions**, not every generated line. This is framing mapped onto the *existing* `review.md`
   sections (the merge-gate predicate, `## Unauthorized changes`, the `RISK high/critical` dual-judge rule,
   `## Promotion queue`) — it restates no semantics.
3. **No new artifacts, directories, roles, or runtime.** No `docs/enterprise/`, no "Spec Author" role, no
   `intake/status/ledger/policy/` scaffold dirs — the substance (merge gate, `WAIVED`, status, source
   authority, source-classes) already exists. The only structural addition is an **optional**
   `## Source inputs` section in the spec contract + template (provenance for upstream intent, drawn from the
   existing source-classes), with **zero tool-specific connectors**.
4. **Honor the overclaim ban.** The public language avoids "compiler," "trust agents automatically," "makes
   review obsolete," "regenerates code from specs," and "the new SDLC." Understated = clear and brief, not
   informal: the SOL/verdict rigor stays.

This **refines** [0050](./0050-swarm-is-a-spec-repo-discipline.md),
[0051](./0051-complete-the-spec-repo-pivot.md), and [0052](./0052-per-feature-spec-folders.md) (a positioning
layer over the spec-repo discipline + per-feature homes) and keeps `.agents/`
([0049](./0049-minimal-install-no-mount-no-imposed-workspace.md)). It changes **no** closed set, the SOL
grammar, the nine steps, the verdicts, or the artifact set.

## Alternatives considered

| Alternative | Why rejected |
| --- | --- |
| Add an enterprise layer — `docs/enterprise/`, a "Spec Author" role, `intake/status/ledger/policy/` dirs | The useful substance already exists (spec-repo discipline 0050/0051, `WAIVED`, `status.md`, source-authority, promotion-protocol, source-classes). New dirs/roles add ceremony without new capability — against the minimality discipline. |
| Build tool-specific intake connectors (Jira/Notion/Linear/…) | Couples the framework to vendors and adds a runtime surface. The agnostic source-classes + an optional `## Source inputs` link table capture upstream provenance with zero connectors. |
| Expand the APS improve-operation set / high-risk-word list (per the source brief) | The improve-operation set is a **frozen closed set of 10** (conformance check A15); changing it breaks count reconciliation for no gain. |
| Market as a "harness platform" / "compiler" | Overclaims, and the evidence rewards the opposite: the harness matters *internally* [[HARNESSBENCH]](../research/sources.md#HARNESSBENCH)[[AHE]](../research/sources.md#AHE), but users buy clarity, safety, and reviewable evidence — not a harness brand. |

## Consequences

- **Positive:** a plain, evidence-grounded position (the control/verification layer); review-as-exceptions
  makes the payoff legible to a reviewer drowning in agent diffs; the framing is defensible against the
  perceived-vs-real gap [[METR]](../research/sources.md#METR) and the adoption-instability finding
  [[DORA2025]](../research/sources.md#DORA2025).
- **Negative:** a bounded doc sweep — `positioning.md`, the root `README` on-ramp, `passes/review.md`
  foregrounding, the spec contract/template `## Source inputs` section, and the `sources.md` grounding. Done
  as part of this change.
- **Neutral:** no closed set, grammar, step, verdict, or artifact changes — only framing, one optional spec
  section, and the evidence base grow.

## Status

Accepted (v0.1). The positioning/README/review/spec-contract edits and the `sources.md` additions are this
change. No follow-on migration.

## Affected obligations / constraints

- Refines: [0050](./0050-swarm-is-a-spec-repo-discipline.md), [0051](./0051-complete-the-spec-repo-pivot.md),
  [0052](./0052-per-feature-spec-folders.md) (positioning over the existing discipline + homes).
- Keeps: [0049](./0049-minimal-install-no-mount-no-imposed-workspace.md) (`.agents/`, no mount).
- Grounded by: [[HARNESSBENCH]](../research/sources.md#HARNESSBENCH), [[AHE]](../research/sources.md#AHE),
  [[HAL]](../research/sources.md#HAL), [[TERMBENCH]](../research/sources.md#TERMBENCH),
  [[ORCHID]](../research/sources.md#ORCHID), [[METR]](../research/sources.md#METR),
  [[DORA2025]](../research/sources.md#DORA2025).
- Does NOT change: any closed set, the SOL grammar, the nine steps, the verdicts, or the artifact set.

> **Ledger note (2026-06-11):** refined by ADR-0057; intake-directory deferral partially superseded by ADR-0061.
>
> **Ledger note (2026-06-12) — evidence and its limits:** the Context figures (HARNESSBENCH, AHE, HAL, TERMBENCH, METR) are preprint-tier corroboration, cited here as preliminary evidence, not settled results; METR's uplift figure in particular should not be cited as settled (see the caveats in `../research/sources.md`).
