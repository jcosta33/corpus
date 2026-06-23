---
type: adr
id: adr-0078
status: accepted
created: 2026-06-14
updated: 2026-06-14
---

# ADR-0078 — C002 (duplicate-id) exempts draft specs from cross-spec requirement-id reuse

## Context

C002 (`duplicate-id`, hard error) has two clauses: no two files claim the same frontmatter `id:`,
and **no requirement ID is reused across specs** — the second clause makes a bare `AC-001` an
unambiguous workspace-wide reference. Dogfooding the reference CLI (corpus-cli) against the real
starter kit surfaced a tension the contract did not resolve: `corpus new spec <slug>` scaffolds a
**draft** spec carrying the stub requirement `AC-001` (matching the kit's spec template). Scaffolding
two specs and running `corpus check` before editing them therefore reds the whole workspace —
`requirement id AC-001 is reused across 2 specs` — through no fault of the author, who has not yet
written any real requirements.

The check was correct against the contract as written; the contract had simply not said how the
globally-unique-id rule interacts with the natural "every spec starts at `AC-001`" scaffolding
convention. The framework already gates a sibling rule on lifecycle: **C007 (`no-tbd-at-ready`)
enforces only at `status: ready`** — a draft may carry `TBD`/`???` placeholders because it is not a
finalized claim.

## Decision

**Cross-spec requirement-id uniqueness (C002's second clause) exempts `draft` specs only; it applies
to every non-draft spec (ready, done, …).** A draft spec's requirement ids are not collected into the
workspace-wide uniqueness set, so two fresh draft scaffolds (or any drafts sharing a stub `AC-001`) do
not collide — but the moment a spec leaves `draft`, its ids are finalized claims that must be unique.
(Gating on `=== 'ready'` would have been too broad, silently exempting `done`/`review-ready` specs
whose ids are finalized.) The carve-out is narrower than but analogous to C007's `ready`-only gate: a
draft's stub ids are work-in-progress, not committed claims.

The first clause is unchanged — **frontmatter `id:` uniqueness still applies to every file** (a
duplicate `SPEC-x` is ambiguous regardless of lifecycle). The rule's id, name (`duplicate-id`), and
severity (hard error) are unchanged, so `checks.yaml` and the contract version are unchanged; only
the prose semantics in `reference/checks.md` are clarified.

## Consequences

- A draft scaffold checks clean immediately; the author writes real, workspace-unique ids before
  flipping a spec out of `draft`, at which point C002 enforces uniqueness against all other non-draft
  specs.
- The honesty bar holds: `reference/checks.md` now states the non-draft scope, and the reference
  implementation (`corpus-cli` `Core/checkWorkspace`) collects requirement ids for the cross-spec
  check from every spec whose `status` is not `draft`.
- This does not relax uniqueness for finalized work — two non-draft specs reusing `AC-001` still fail
  C002 — and it does not resolve the deeper, separate question of whether requirement ids should be
  globally unique or spec-scoped for non-draft specs; that remains the contract's current choice
  (globally unique), left to a future decision if revisited.

> **Update — superseded by [ADR-0080](./0080-spec-scoped-requirement-ids.md).** The deferred question
> is now resolved: requirement ids are **spec-scoped**, not globally unique. C002's cross-spec
> requirement-id clause is dropped (only the frontmatter-`id:` clause survives), so this ADR's draft
> carve-out **for requirement ids** is subsumed and moot — two non-draft specs reusing `AC-001` no
> longer fail C002. The frontmatter-`id:` clause and the draft-is-not-final principle are unchanged.
