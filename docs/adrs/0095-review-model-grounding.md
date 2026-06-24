---
type: adr
id: adr-0095
status: accepted
created: 2026-06-22
updated: 2026-06-22
---

# ADR-0095 — Ground the review model in evidence: maintainability-first value, independent distinct-lens reviewers, participation as the gate, agent-runs-the-app as evidence

## Context

Corpus exists for the review step, but the canon under-stated _what review is for_ and _how to
weight it_. A web-verified evidence pass (corpus-works #52; sources below, each verified June 2026 with
honest tiers) settles five framing questions — and corrects two of the issue's own framings.

- **Review's primary payload is the maintainability/design layer tests cannot reach.** Roughly 75%
  of defects found in review do not affect visible functionality — they are _evolvability_ defects
  (documentation, structure, readability) execution-based QA cannot detect ([[MANTYLA09]]). In modern
  review, defect comments are a minority (~14%) while code-improvement comments dominate (~29%);
  review also delivers knowledge transfer and team awareness ([[BACCHELLI13]]). So review is
  **complementary to** tests/CI (which own functional regressions), not a slower substitute.
- **Reviewer ≠ author.** No modern RCT measures self- vs independent-review yield, so this rests on
  the **desk-checking cognitive principle**, not a measured effect: "if the author was aware of
  defects, he probably would have corrected them already" ([[WIEGERS95]] — practitioner, design
  rationale). Reinforces ADR-0056.
- **Two is the convergent reviewer optimum; participation, not coverage, is the quality signal.**
  Modern review converged on ~2 reviewers, with little marginal yield beyond ([[RIGBY13]]); low
  reviewer _participation_ (engagement) is estimated to add up to **five** post-release defects
  (vs up to two for low coverage) — "coverage alone does not guarantee" quality ([[MCINTOSH14]]).
- **Exercising the running app is a distinct, valuable, but unreliable verifier.** An LLM agent
  driving live apps found 53 real bugs (35 fixed) ([[GPTDROID]]); exploratory exercise matches
  scripted on effectiveness ([[ITKONEN14]] — student-study scope). But agents driving live web UIs
  are unreliable — the best reach ~61%, most ~30% ([[WEBAGENTILLUSION]]). So an app-run is **evidence
  for a human to judge, never an autonomous verdict**, and is best captured with deterministic
  accessibility-tree tooling, not pixels/vision ([[PLAYWRIGHTMCP]]).

## Decision

1. **Review value is framed maintainability/design-first and complementary to tests**
   (`docs/08-reviewing-output.md`). Evolvability findings are first-class in the packet, not an
   afterthought; tests/CI own functional regressions, review owns the layer they cannot see. _Level:
   convention._ ([[MANTYLA09]], [[BACCHELLI13]])

2. **Reviewer ≠ author, as a design-rationale rule** reinforcing ADR-0056's no-self-verdict — stated
   as the desk-checking principle, **not** an enforcement-sounding "evidence shows much more
   effective." _Level: design rationale._ ([[WIEGERS95]])

3. **Default to two independent, distinct-lens reviewers; escalate to a third for high-risk/
   high-diffusion changes.** The lenses are distinct aims, all skeptical — e.g. correctness /
   maintainability+design / security+repro. Agent reviewers are cheap, so a third is easier to
   justify than the human-coordination literature implies. _Level: checklist._ ([[RIGBY13]], [[MCINTOSH14]],
   high-diffusion per [ADR-0094](./0094-decomposition-and-risk-weighted-review.md))

4. **Participation is the gate, not the checkbox.** A `Pass` requires evidence of substantive
   engagement (a finding raised, a re-run, a reasoned result). **An empty-evidence `Pass` reads
   `Unverified`** — _not a new "Blocked" state._ (Refinement of #52's "Pass → Blocked": `Unverified`
   is the precise existing review-result for "no evidence supports this result"; `Blocked` means a
   precondition prevents proceeding. The protective intent is identical and **already ships** — the
   corpus-cli reconcile flags an empty-evidence Pass row as `Unverified`, AC-020 — so no new semantics
   or corpus-cli change is needed.) _Level: convention, with the shipped reconcile as the toolable
   realization._ ([[MCINTOSH14]] is the warrant)

5. **Agent-runs-the-app is evidence, not a verdict.** The author-agent **attaches its run**
   (accessibility snapshot, console, network) as proof; an **independent reviewer-agent re-runs the
   journey and judges**. Prefer deterministic accessibility-tree tooling ([[PLAYWRIGHTMCP]]) over
   pixel/vision; an autonomous run never certifies a change. _Level: convention/toolable (the tooling
   is BYO; nothing enforces it)._ ([[GPTDROID]], [[ITKONEN14]], [[WEBAGENTILLUSION]])

6. **`corpus-reviewer` / `corpus-challenger` carry the distinct-lens framing** and keep "issue no
   verdict; the human owns the result" (corpus-agents). _Level: convention._

## Consequences

- No `checks.yaml` rule and no contract-version bump land here: the participation gate is the
  already-shipped empty-evidence→Unverified reconcile, and the distinct-lens / agent-run practices
  are conventions + BYO tooling. Consistent with the honesty framework (ADR-0063) — no "enforced."
- Two of #52's framings were corrected against the evidence: the independence claim is softened to a
  design-rationale cognitive principle (no RCT), and "Pass → Blocked" is realized as the precise,
  already-shipped "Pass → Unverified."
- Scope caveats travel with the citations: [[ITKONEN14]] is a student experiment (non-significant
  ≠ proven equivalence); [[WEBAGENTILLUSION]] shows agent UI-driving is unreliable — which is exactly
  why the app-run is evidence, not verdict.

## Propagation

`docs/08-reviewing-output.md` (the five framing rules), the `corpus-reviewer`/`corpus-challenger`
definitions in `corpus-agents`, `docs/research/sources.md` (the eight entries above). No review-packet
_format_ change (ADR-0058/0089 stand); the participation gate is the existing empty-evidence→Unverified
reconcile, not a new field or check.

## Update (2026-06-24) — refined by [ADR-0099](./0099-review-orchestration-and-role-routing.md)

ADR-0099 refines Decision 3 (the default reviewer count) and sharpens Decision 2's wording. The
two-reviewers-plus-a-risk-third default stands as the warrant for **human** review ([[RIGBY13]](../research/sources.md#RIGBY13)'s
~2 is a human-coordination-cost finding). For **agent** reviewers — cheap, as Decision 3 already noted
— a **review lead orchestrating at least three distinct lenses** is the low-cost default, since the
marginal cost RIGBY13 weighed is the cost agents do not pay. "Reviewer ≠ author" is sharpened to
**reviewer ≠ implementer**: the spec/task author may review code they did not implement.
