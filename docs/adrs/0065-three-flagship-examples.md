---
type: adr
id: adr-0065
status: accepted
created: 2026-06-11
updated: 2026-06-11
---

# ADR-0065 — Three flagship examples; the large-PR review is the demo

## Context

Onboarding needs few, complete walkthroughs — input through evidence — not many partial ones. The
product's wedge is reviewing large agent output; the demo must show it.

## Decision

1. Exactly three examples in `docs/examples/`: **feature-from-jira** (the six-step happy path: intake →
   spec → task → run summary → review packet → finding/status), **bug-fix** (Pull bug → spec check →
   task → run → review → close), **large-pr-review** (the main demo, linked from the README): a
   change-plan-driven refactor — inventory → change plan with preservation guarantees and waves → a
   ~40-file agent PR → requirement *and* change-plan coverage tables → Block on missing evidence →
   follow-up task → second packet → merge + finding.
2. Each example shows every artifact in the pinned template shapes — no abridged chains.
3. The checks fixture corpus (`conformance/`) remains separate producer test data; examples teach,
   fixtures pin.

## Alternatives considered

| Alternative | Why weaker |
|---|---|
| Many small examples | Partial chains teach the ceremony, not the loop |
| Greenfield demo as the lead | The wedge is review pain, which peaks on large diffs and brownfield change |

## Consequences

Positive: one demo carries the wedge and the transformation tier. Negative: examples must be regenerated
whenever a template changes (same-commit rule).

## Status

Accepted. Refines ADR-0033.

## Propagation

docs/examples, README link, kit example (derived from feature-from-jira), conformance name-mapping.

> **Ledger note (2026-06-12):** refined by ADR-0071 — the step bars are the scoring reference
> applied to the examples.
>
> **Ledger note (2026-06-22):** the happy-path example was genericized to a tracker-neutral name
> — `feature-from-jira.md` → `feature-from-ticket.md` — and its Jira-specific framing dropped
> (swarm-hq #58: work originates in any source, not a single tool). The three-example structure
> and ordering are unchanged; only the one example's filename and surface vocabulary moved.
