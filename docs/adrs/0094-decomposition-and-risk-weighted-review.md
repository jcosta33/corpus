---
type: adr
id: adr-0094
status: accepted
created: 2026-06-22
updated: 2026-06-22
---

# ADR-0094 — Decomposition into small untangled units; review scrutiny weighted by diffusion, churn, and change-type

## Context

Agent-written changes are cheap to produce and easy to make large. Corpus's leverage is the
_handoff_ — what the agent is told to emit and what the human (or an independent reviewer) must
actually look at. Two recurring questions had no grounded answer in the canon:

1. **How should a task be shaped?** The docs said "a small cleanup is still a task" but never made
   _small, single-concern, untangled, refactor-separated_ the primary decomposition rule.
2. **Where should review scrutiny concentrate?** Field reports framed it as "greenfield (lighter) vs
   brownfield (heavier)." That framing does not hold up against the evidence.

A web-verified evidence pass (corpus-hq #53; sources below, each verified June 2026 with honest
tiers) settled the principle — and **reframed the discriminator** from new-vs-old to
**diffusion / churn / change-type**.

- **Small, self-contained changes are the best-grounded result in code review.** Defect-detection
  effectiveness is best on small changes — a ~200–400 LOC band, falling past ~60–90 min
  ([[SMARTBEAR]] — industry dataset, cite as heuristic). Corroborated: useful-comment proportion
  drops as files-per-change rises ([[BOSU15]]); modern review converged on changes of tens of lines
  ([[RIGBY13]]); "one self-contained change," ~100 reasonable / ~1000 too large, **refactor separate
  from behavior change** ([[GOOGLESMALLCL]]).
- **Untangling buys _cleaner_ reviews, not _more_ bugs caught.** A controlled experiment (n=28) found
  decomposition yields fewer false positives and more context-seeking, with the **number of defects
  found unchanged** ([[DIBIASE19]]). The honest reason to split is reviewability, not detection.
- **Risk rises with diffusion and differs by change-type.** P(a change induces a failure) rises with
  size and **diffusion** (files/modules/subsystems touched) and depends on change type ([[MOCKUS00]]);
  **~40% of fault-fix changes introduce new defects** while a one-line change is <~4% ([[PURUSHOTHAMAN05]]);
  faults cluster in **churned** code — change-count predicts faults better than size ([[GRAVES00]]).
- **Counter-evidence to "net-new is safe":** once size and total changes are controlled, change _type_
  (new feature vs improvement) has **no significant effect** on later defects — size/churn dominates
  ([[HINDLE11]]). So "greenfield" must never justify skipping review on a large or high-diffusion change.

## Decision

1. **Small, single-concern, untangled, refactor-separated is the primary task-decomposition rule**
   (`docs/06-creating-tasks.md`, the `split-work` guide). A task carries one concern; a refactor
   lands in its own task/commit, separate from the behavior change it enables (the small-cleanup
   exception in [[GOOGLESMALLCL]] stands). _Level: convention._

2. **An oversized-packet heuristic is named as a toolable signal** (`corpus check` / a step-bar):
   flag a task or review packet whose **changed-LOC and files-touched/diffusion** exceed a band,
   anchored to the [[SMARTBEAR]] 200–400 LOC heuristic with files-touched as a first-class signal
   ([[BOSU15]]). Thresholds ship as **heuristics with provenance, never enforced law**. _Level:
   toolable (the checker is `corpus-cli`); not built here — this ADR specifies it, corpus-cli implements._

3. **Review scrutiny is weighted by change-type / diffusion / churn, not greenfield-vs-brownfield**
   (`docs/05-brownfield-and-change-plans.md`, `docs/06`). Concentrate human / independent-reviewer
   attention on (a) **fault-fix / modification** changes, (b) **high-diffusion** connective tissue
   touching many files/subsystems/interfaces, (c) **high-churn** loci. A lighter lane for net-new
   code is acceptable **only when it is also small and low-diffusion**, and still demands genuine
   engagement on the risky seams. **The Hindle caveat is explicit:** never let "greenfield" excuse
   skipping review on a large or high-diffusion change ([[HINDLE11]]). _Level: checklist._

4. **Decomposition's benefit is framed honestly as cleaner reviews, not more bugs caught**
   ([[DIBIASE19]]). The docs do not claim splitting catches more defects.

## Consequences

- The "connective-tissue" instinct (split out the wiring so the human reviews only what must be
  reviewed) is kept — but named precisely as **coupling/diffusion**, the version the evidence
  supports, not "new vs old."
- No `checks.yaml` rule and no contract-version bump land with this ADR: the oversized-packet flag is
  specified-not-shipped (a `corpus-cli` toolable, demand-gated), consistent with the honesty framework
  (ADR-0063) — name the checker, never claim enforcement before a tool ships.
- Thresholds are heuristics: [[SMARTBEAR]] is a single 2006 vendor dataset, and [[HINDLE11]] is scoped
  to four Apache Java projects — the docs cite the band as guidance with its provenance and caveats,
  never as a measured optimum.

## Propagation

`docs/06-creating-tasks.md` (task-shaping rule + named oversized-packet flag), `docs/05-brownfield-and-change-plans.md`
(risk-weighted review + Hindle caveat), the kit `split-work` guide (the small/untangled lever),
`docs/research/sources.md` (the nine entries above). The `corpus-cli` oversized-packet check is the
toolable follow-up (tracked in corpus-hq #61 §B), not shipped by this ADR.

## Update (2026-06-22) — the oversized-packet band measured, deferred ([ADR-0097](./0097-mint-c016-c017-defer-oversized.md))

The named oversized-packet toolable was built and **measured**: a raw changed-LOC/files band cannot be
both useful and low-false-positive for code task diffs (≈15% FP at 600 LOC — feature-with-tests shares
the 600–1200 LOC range; a 0-FP band of ≥1500 never fires on the population it targets). So the
band-based check is **specified-not-shipped** (id `C018` reserved for a future decomposition-predictive
signal), and `corpus review` surfaces the diff size as **neutral info** instead — the "size as a signal"
intent in the only honest form the data supports. Full measurement in ADR-0097.
