---
type: adr
id: adr-0099
status: accepted
created: 2026-06-24
updated: 2026-06-24
---

# ADR-0099 — Review-lead orchestration, agent role routing, and reviewer ≠ implementer

## Context

[ADR-0095](./0095-review-model-grounding.md) grounded the review model in evidence: reviewer ≠
author as a desk-checking rationale ([[WIEGERS95]](../research/sources.md#WIEGERS95)), a default of
two distinct-lens reviewers plus a risk-based third ([[RIGBY13]](../research/sources.md#RIGBY13)),
participation as the gate ([[MCINTOSH14]](../research/sources.md#MCINTOSH14)), and agent-runs-the-app
as evidence not verdict. It already observed that **agent reviewers are cheap, so a third is easier to
justify than the human-coordination literature implies**.

Dogfooding (corpus-works #65/#67/#70) surfaced three seams in how that model is written down:

- **#65 — the procedure still reads as one reviewer producing one packet.** The cost calculus
  [[RIGBY13]](../research/sources.md#RIGBY13) measured (~2 reviewers, little marginal yield beyond) is
  a **human-coordination** cost; an agent lens does not pay it. In practice Corpus review already runs
  several distinct-lens agents — the canon under-states what is done.
- **#67 — the docs name only Worker and Scout.** They do not recommend separate sessions for spec/task
  authoring vs implementation vs review, nor how to route model strength, nor how to judge whether a
  cheaper implementer paid off.
- **#70 — "reviewer ≠ author" reads ambiguously.** Author of *what*? The desk-checking warrant is
  about the author of **the change** — the implementer — not the spec/task author.

## Decision

1. **Review is lead-orchestrated; ≥3 independent lenses is the agent-review default.** A **review lead**
   reads the task, the cited spec, the run summary, and the diff; chooses **at least three distinct
   lenses** for the work (default: *requirement correctness · verification/evidence/repro ·
   maintainability/design risk*; the lead swaps or adds security, data-integrity, performance,
   migration-safety, accessibility, API-compatibility, concurrency, UX, or docs as the change
   warrants); sends independent subreviewers that return **findings + evidence only**; then reconciles
   conflicts, deduplicates, and writes the one canonical packet. _Level: checklist (nothing enforces
   it)._ This **refines [ADR-0095](./0095-review-model-grounding.md) #3**: the two-reviewers-plus-a-
   risk-third default remains the warrant for **human** review — [[RIGBY13]](../research/sources.md#RIGBY13)'s
   ~2 is a human-coordination-cost finding and [[MCINTOSH14]](../research/sources.md#MCINTOSH14)'s
   participation is the quality signal — while for **agent** reviewers, cheap as ADR-0095 already noted,
   ≥3 distinct lenses is the low-cost default, because the marginal cost RIGBY13 weighed is the cost
   agents do not pay. ([[RIGBY13]](../research/sources.md#RIGBY13), [[MCINTOSH14]](../research/sources.md#MCINTOSH14))

2. **Reviewer ≠ implementer** — the precise form of ADR-0095's "reviewer ≠ author." The desk-checking
   warrant ([[WIEGERS95]](../research/sources.md#WIEGERS95): the author would have corrected defects
   they were aware of) is about the author of **the change**, i.e. the implementer. The spec/task
   author **may** review the implementation, **provided they did not implement it**.
   [ADR-0056](./0056-adversarial-self-review-completion-discipline.md)'s `implementer ≠ reviewer` and
   the no-self-verdict gate are reaffirmed unchanged. _Level: design rationale._

3. **Name the roles; route them to separate sessions.** The roles are **spec/task author ·
   implementer · lens (sub)reviewer · review lead/aggregator · human/owner verdict authority**.
   Authoring, implementation, and review should normally run as **different agents/sessions**; the
   implementer reads the task and the cited spec, and the task stays the scope boundary (the
   implementer does not change requirements). **Escalate** to a stronger model/session on unclear
   scope, repeated Verify failures, risky files, or a requirement that needs reinterpretation. A
   **cheaper implementer is viable for a clear, bounded task** because independent review catches the
   misses — but the saving **must be measured** by pass rate, rework rate, and review outcome, never
   assumed, and this guidance **names no vendor or model**. _Level: convention._

4. **The packet records the plan.** The lead's review packet names the **lenses used** and the
   **reconciliation**; a lens subreviewer never renders the final status or suggested decision — the
   human owns the verdict ([ADR-0077](./0077-corpus-cli-reconcile-only-harness.md) D8). _Level:
   convention (the kit review template carries the plan/lens capture)._

## Consequences

- **No `checks.yaml` rule and no contract-version bump:** lead-orchestration, the lenses, and the
  routing/escalation guidance are conventions/checklists + BYO tooling — consistent with the honesty
  framework ([ADR-0063](./0063-honesty-framework-and-tooling-boundary.md)). Nothing here is "enforced."
- **`corpus-reviewer` / `corpus-challenger`** keep "issue no verdict; the human owns the result" and
  gain the review-lead framing: a lens reviewer takes **one** lens and returns findings only; the lead
  orchestrates ≥3 and aggregates.
- **Supersedes nothing.** It **refines** ADR-0095 (#3's default + #2's wording) and **reaffirms**
  ADR-0056 (implementer ≠ reviewer, no self-verdict). No review-packet *format* change — the plan/lens
  capture is additive ([ADR-0058](./0058-two-tier-spec-format.md)/[ADR-0089](./0089-decision-handoff-open-decisions.md)
  stand).
- **Scope honesty travels with the warrant:** [[RIGBY13]](../research/sources.md#RIGBY13)'s ~2 is a
  human-coordination finding; the ≥3-agent default rests on ADR-0095's own already-stated "agent
  reviewers are cheap" observation, stated as **cost rationale, not a measured yield**.

## Propagation

`docs/07-running-agents.md` (the roles + routing/escalation + measured-cost rule),
`docs/08-reviewing-output.md` (the review-lead reviewer rule + the author-may-review clarification),
the kit review template `templates/review.md` (a review-plan / lens-results capture),
`corpus-agents` `agents/corpus-reviewer.md` + `agents/corpus-challenger.md` (the lead-orchestrates /
one-lens-subreviewer framing; the emitted `.codex/*.toml` are regenerated, not hand-edited). ADR-0095
gains a dated ledger note pointing here.

## Affected obligations / constraints

- **Refines:** [ADR-0095](./0095-review-model-grounding.md) (#3 default reviewer count, #2 "reviewer ≠
  author" wording).
- **Reaffirms (does not change):** [ADR-0056](./0056-adversarial-self-review-completion-discipline.md)
  (`implementer ≠ reviewer`, no self-verdict) and the human-owns-the-verdict rule
  ([ADR-0077](./0077-corpus-cli-reconcile-only-harness.md) D8).
- **Does NOT change:** any closed set, the SOL grammar, the verdict model
  (Pass/Fail/Unverified/Blocked), or the review-packet format.
