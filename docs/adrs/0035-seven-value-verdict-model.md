---
type: adr
id: 0035-seven-value-verdict-model
status: accepted
created: 2026-06-02
updated: 2026-06-02
supersedes: [0024]
superseded_by:
---

# ADR-0035: The 7-value verdict model

## Context

Pre-kernel Corpus answered "did this actually get done?" in two incompatible places. The validation contract spoke in ad-hoc pass/fail prose, where a binding that *could not run* read identically to one that *ran and failed* and to one that was *never attempted* — three different debts collapsed into one word. Separately, [0024](./0024-confidence-tiers.md) named two confidence tiers (self-reviewed vs independently-reviewed) as a labelling discipline bolted onto the same flat pass/fail, because the model had no typed home for *how much* an outcome was trusted. The result was that confidence lived in adjectives, not in the verdict itself, and a reviewer could not route an unmet obligation without re-deriving which kind of "not done" it was. §14 fixes this by giving the verdict a closed, typed vocabulary.

## Decision

A verdict is one of **exactly seven values**, partitioned into two disjoint roles (§14.1). Every required `VERIFY BY` binding carries **exactly one CORE value** and **zero or more LIFECYCLE decorators**:

- **Four CORE run results (mutually exclusive):** `PASS`, `FAIL`, `BLOCKED`, `UNVERIFIED` — the merge-gate outcomes (§14.1.1).
- **Three LIFECYCLE decorators (governance facts that arise around the run):** `WAIVED`, `STALE`, `CONTRADICTED`, each with mandatory fields (§14.1.2).

The merge gate (§14.4) is then a single normative predicate over these values: a change set MAY be promoted iff every required binding's latest verdict is `PASS` or `WAIVED` and none is `STALE`, `CONTRADICTED`, `FAIL`, `BLOCKED`, or `UNVERIFIED`. The verdict line grammar, lint codes (`SOL-V005`/`SOL-V007`/`SOL-V008`), and `review.md` container are fully specified in §14. The confidence tiers of [0024](./0024-confidence-tiers.md) are not deleted — they are recast: "independently-reviewed" is the disposition of a binding whose CORE is `PASS` carrying no weakening lifecycle decorator and resting on an oracle independent of the generator; "self-reviewed" survives as a `manual` proof type (§15.1) whose verdict the strength order (§15.6) ranks at the floor. Confidence now lives in the typed verdict, not in an adjective beside it.

## Alternatives considered

| Alternative | Why rejected |
| --- | --- |
| Keep flat pass/fail prose | Collapses three distinct unmet states; a reviewer cannot tell an environment gap from a binding gap from a real failure, so cannot route the fix (§14.1.1 rationale). |
| Collapse `BLOCKED` into `UNVERIFIED` | They route differently — `BLOCKED` is an environment/adapter fix, `UNVERIFIED` is a binding or execution gap. Conflating them hides which debt is owed (§14.1.1). |
| Make `WAIVED`/`STALE`/`CONTRADICTED` additional CORE values | They are not run results — they annotate a run with a status arising after or around it. Folding them into the core enum would let a verdict be e.g. both `PASS` and `WAIVED` as mutually-exclusive cores, which is incoherent; they are decorators by design (§14.1.2). |
| Allow `WAIVED` on any core / `STALE` on any prior verdict | A `PASS` has no reason to be waived; only a never-trusted `FAIL`/`BLOCKED`/`UNVERIFIED` cannot go stale. The decoration rules encode which combinations are meaningful (`SOL-V007`, §14.3). |
| Keep confidence as the separate two-tier label of [0024](./0024-confidence-tiers.md) | A label beside the verdict is self-attested adjective; the typed verdict gives confidence a home the merge gate reads directly, and the [0024](./0024-confidence-tiers.md) distinction re-expresses as oracle independence (§15.6) over a `PASS`. |

## Consequences

### Positive

- Every unmet obligation carries *why* it is unmet in its type, so a conformant tool (and a human today) can route `FAIL` to code, `BLOCKED` to environment, `UNVERIFIED` to binding — without re-deriving the cause.
- The merge gate becomes one closed predicate over a closed enum, not prose judgement.
- Confidence is typed: the [0024](./0024-confidence-tiers.md) tiers stop being free-floating adjectives and become positions in the verdict taxonomy and the proof-strength order.

### Negative

- More vocabulary for an author to learn and a reviewer to apply correctly; a mis-recorded decorator (e.g. `BLOCKED` where the honest value is `UNVERIFIED`) defeats the routing benefit, which is why §14.1.1 makes the weaker claim mandatory when in doubt.
- Lifecycle decorators carry mandatory fields (authority/expiry, prior-verdict/changed-surface, two evidence refs); recording them is real cost the contract requires for auditability (`SOL-V005`).

### Neutral / tradeoffs

- The model is markdown-only and self-attested today (§2, NO RUNTIME): the verdict is a recorded judgement in `review.md`, and the contract specifies what a future conformant tool MUST honour, not anything that runs now.

## Status

Accepted (v0.1).

Supersedes ADR-0024 (recasts the self-reviewed / independently-reviewed confidence tiers as positions within the seven-value verdict taxonomy and the proof-strength order, rather than a separate two-tier label).

## Affected obligations / constraints

- Adds: the closed seven-value verdict vocabulary (4 CORE + 3 LIFECYCLE) and the CORE-exclusive / decorator composition rule (§14.1); the merge-gate predicate over those values (§14.4); verdict well-formedness lint `SOL-V005`/`SOL-V007`/`SOL-V008` (§14.3).
- Modifies: the merge gate now reads a typed verdict per required binding rather than flat pass/fail prose (§14.4).
- Supersedes: the standalone two confidence tiers of ADR-0024 — confidence is now carried by the verdict's CORE value, its lifecycle decorators, and the proof-strength order (§15.6), not by a separate label.
