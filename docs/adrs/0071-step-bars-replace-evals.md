---
type: adr
id: adr-0071
status: accepted
created: 2026-06-12
updated: 2026-06-12
---

# ADR-0071 — Step bars: the per-step quality bars are product reference

## Context

`evals/` was an island. No tool contract names it (`docs/reference/future-cli.md` promises no
`corpus eval`); nothing in README, docs/, starter-kit/, or the checks data links to it; even
the spec-first pilot defines its metrics operationally on review packets. Each page carried
the label "internal rationale; not needed to use Corpus" — yet what the pages actually define
is not internal at all: the predicates that say whether a spec faithfully distilled its
sources (_stance preserved_, _nothing invented as sourced_), whether a task faithfully bounded
its spec, whether a review's results are consistent with its evidence. That is **the
definition of done for each step of the loop** — the fourth thing the product teaches, next to
_how_ (docs 01–10), _what shape_ (templates), and _what a tool can flag_ (checks). The
directory name compounded the mislabel: "evals" is ML-benchmark jargon, the same register
problem ADR-0070 fixes for "conformance".

## Decision

1. **One reference page: `docs/reference/step-bars.md`.** The six step bars (their boolean
   predicates, the notes a scorer needs) plus the cross-step predicates (re-parses clean,
   chain unbroken, result consistent with evidence, drift surfaced) and a short
   advanced-lifecycle scoring note. Honesty level: checklist — a reviewer applies a bar by
   hand; no tool implements any of it today.
2. **The page is product, linked from the happy path** — an adopter grading their own loop
   uses the same bars the producer uses as a regression rubric when guides or templates
   change. One home, two uses; no separate producer copy.
3. **`evals/` is deleted.** Load-bearing citations move with their claims onto the new page.
   The propagation matrix drops evals as a derived surface and gains the page.

## Alternatives considered

- **Move to `.agents/evals/`** — honest about today's only consumer, but buries product
  content as producer tooling and keeps the jargon name; rejected by the owner.
- **`checks/rubrics/`** — blurs the line ADR-0063 draws between the toolable contract and
  judgment instruments; a bar is not a check.
- **Fold each bar into its happy-path page** — puts the right content in the wrong weight
  class; docs/01–10 are deliberately light, and the cross-step predicates have no single home
  in that shape.

## Consequences

Accepted. Supersedes the standalone `evals/` surface (as re-keyed by the repositioning);
refines ADR-0065/0066 framing. The bars keep their predicate ids (P/S/T/R/V/C series) so
existing producer records that cite them stay readable.

## Propagation

new reference page, evals/ deletion, happy-path + cheatsheet links, root bootloader
AGENTS.md repo map, propagation matrix.
