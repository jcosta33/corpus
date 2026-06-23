---
type: adr
id: adr-0080
status: accepted
created: 2026-06-16
updated: 2026-06-16
---

# ADR-0080 — Requirement ids are spec-scoped, not workspace-global

## Context

C002 (`duplicate-id`, hard error) had two clauses: no two files claim the same frontmatter `id:`,
and **no requirement id is reused across specs** — the second clause was meant to make a bare
`AC-001` an unambiguous workspace-wide reference. ADR-0078 narrowed that second clause to exempt
`draft` specs but **explicitly deferred** the deeper question: "does not resolve the deeper, separate
question of whether requirement ids should be globally unique or spec-scoped … left to a future
decision if revisited."

Dogfooding the reference CLI surfaced the answer. `corpus check` over the corpus-hq workspace is red
with ~29 cross-spec C002 findings, because every spec naturally numbers its requirements from
`AC-001` and the kit's `corpus new spec` scaffold mints `AC-001` for each new spec — so any two
non-draft specs collide through no author fault, and the gate (the product's wedge) reds against its
own dogfood workspace.

The decisive facts: the "globally-unique bare `AC`" goal has **zero live consumers** — every real
reference in the workspace (review coverage rows, C012 reconciliation, task scope) is already scoped
to a single named source spec; the only workspace strings of the form `SPEC-x#AC-NNN` are template
placeholders. And the format reference already says ids are "unique within a file" and already
defines `SPEC-x#AC-NNN` as _the_ cross-file reference form — so C002's cross-spec clause was the
contradiction, not the spec-scoped model. C001 (`unique-ids`) independently enforces within-file
uniqueness, so nothing is lost by scoping.

## Decision

**Requirement ids are spec-scoped.** A bare `AC-NNN` is unique only within its own spec (enforced by
C001); it may recur freely in another spec. A reference that crosses a spec boundary **must** qualify
as `SPEC-x#AC-NNN`. C002 retains **only** its frontmatter-`id:` uniqueness clause (a duplicate
`SPEC-x` is ambiguous regardless of lifecycle, so that clause is unchanged and not draft-exempt).

This closes the question ADR-0078 left open and **subsumes ADR-0078's draft carve-out for requirement
ids** — with requirement ids no longer cross-checked at all, the draft exemption for them is moot
(C002's surviving frontmatter-`id:` clause never had a draft exemption). ADR-0078's reasoning about
_draft ids being work-in-progress_ still informs the sibling lifecycle gates (C007, and C012's
non-draft source-spec guard, ADR-0079).

C002's id, name (`duplicate-id`), and severity (hard error) are **unchanged** — the machine row in
`checks.yaml` is the same, so the contract version and the corpus-cli drift guard are unaffected; only
the prose semantics in `reference/checks.md` and `reference/structured-requirements.md` change, plus
the deletion of the cross-spec requirement-id pass in the reference implementation
(`corpus-cli .../checkWorkspace.ts`).

## Consequences

- `corpus check` greens against the corpus-hq dogfood workspace; the cross-spec C002 findings clear, and
  every spec (and the `corpus new spec` scaffold) can number from `AC-001` without coordination.
- A bare `AC-001` quoted without its spec is now ambiguous by design — readers and tools carry the
  source-spec binding, which tasks, reviews, and C012 already require. Cross-spec references use
  `SPEC-x#AC-NNN`.
- The reference impl drops the `requirementIdToPaths` accumulation/emit in `checkWorkspace.ts`; the
  frontmatter-`id:` collision check stays. corpus-cli's `checkWorkspace` tests assert the new behavior
  (a reused `AC-001` across specs is not a C002 finding; a duplicate frontmatter id still is).
- This does **not** weaken in-file id integrity (C001 holds) and does not touch C012 — which keys a
  review's coverage rows against its single named source spec, exactly the spec-scoped model.
