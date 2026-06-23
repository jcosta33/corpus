---
type: adr
id: adr-0066
status: accepted
created: 2026-06-11
updated: 2026-06-11
---

# ADR-0066 — Checks: the adopter validity bar and the producer-internal reference values

## Context

A conformance regime sized for a language ecosystem (document-copy clauses, count acceptance checks,
maturity ladders) reads as gatekeeping to adopters (O-004, O-012 §3) — while the underlying test data
(fixtures with pinned expectations, a labeled prose corpus) is genuinely valuable to the tooling that
checks specs.

## Decision

1. **Adopter validity bar (the whole of it):** a workspace is valid when it has (a) a populated
   `AGENTS.md` (soft length guidance), (b) the core templates present, and (c) at least one spec
   satisfying the core checks of `docs/reference/checks.md`. Nothing else is required; no document-copy
   clause; no maturity ladder.
2. **Evidence rules survive verbatim** (checklist level): `non-empty-paste` — a completion claim binds to
   pasted output or a CI link, never a bare "tests passed" — the failure illustrated (small-N,
   preliminary) by [[EVIBOUND]](../research/sources.md#EVIBOUND);
   `no-open-critical` — work is not closed with an open blocking question.
3. **Reference values are producer-internal.** The closed-set cardinalities and their reconciliation
   checks live only in `conformance/README.md` (producer note) and the cheatsheet appendix. Adopter-facing
   pages list values, never counts.
4. **The corpus is "checks fixtures":** test data for `docs/reference/checks.md`, consumed by corpus-cli.
   Fixtures pin expected results per the two-way severity split (hard error / warning); each spec-format
   fixture domain ships a simple/SOL **equivalence pair** asserting both surfaces encode the identical
   requirement record (the anti-fork proof), plus intake, change-plan, and inventory fixtures.

## Alternatives considered

| Alternative                               | Why weaker                                                                   |
| ----------------------------------------- | ---------------------------------------------------------------------------- |
| Keep the three-clause definition + ladder | Measures adopters against producer concerns; the reports name it as friction |
| Drop fixtures                             | corpus-cli loses its oracle; the checks contract becomes untestable          |

## Consequences

Positive: "valid" is answerable in one breath. Negative: producers carry the reconciliation burden
explicitly (where it belongs).

## Status

Accepted. Partially supersedes ADR-0026 and ADR-0051 (validity-bar clauses) and ADR-0033 (corpus framing);
refines ADR-0063.

## Propagation

conformance/ (README, yaml, fixtures), checks.md, cheatsheet appendix, evals, corpus-cli.

> **Ledger note (2026-06-12):** the checks fixtures' home renamed to `checks/` by ADR-0070;
> step-output scoring became the step-bars reference page per ADR-0071.
