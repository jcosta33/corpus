---
name: corpus-spec
description: Write, revise, or check a verifiable change contract before implementation. Use when intent or consequential behavior must become requirements with acceptance checks, or when a refactor, migration, rewrite, upgrade, or schema or performance change must preserve behavior through staged waves and rollback. Do not use for small clear fixes, direct implementation, or factual verification.
---

# Corpus Spec

A spec is decided intent under test. Nothing else belongs.

## Method

1. Read project rules, current code, tests, related decisions, open issues, and the project's spec
   form if its tracker has one.
2. Settle discoverable facts and reversible conventions yourself. Ask the human only about
   material behavior, public contracts, security, cost, or irreversible choices.
3. If one precise sentence governs the work, state it inline with its verification. Write no file.
4. Otherwise write the spec. Any unresolved blocking choice keeps `status: draft` and blocks
   dependent work.
5. Verification output and review belong on the native pull request. The implementer cannot accept
   their own work.

## Shape

```yaml
---
type: spec
id: SPEC-{{slug}}
status: draft
sources:
  - ISSUE-123
  - ../relative/source.md
---
```

`# {{title}}`, then `## Intent` (what must become true, for whom, and where it stops; no
implementation plan) and `## Requirements`. Add `## Boundary` only when Intent does not bound the
work, and `## Open questions` only while `draft`.

```markdown
### AC-001
- When: one concrete condition, or `always` for an invariant
- Then: the actor MUST do one observable thing
- Verify with: `exact command` or a named manual check
```

A short name may follow the ID. Use exactly those three items, in that order, and nothing else under
the heading. Use exactly one of `MUST`, `MUST NOT`, `SHOULD`, `SHOULD NOT`, or `MAY` in `Then`.
Split obligations that fail independently. Name a mechanism only when a public contract makes it
observable.

## Structural change

For a refactor, migration, rewrite, upgrade, schema change, or performance change, also write:

- `## Baseline`: current structure and behavior, each with `file:line`, test, or command evidence.
- Preserved behavior as requirements with `When: always`. Verify each with a golden, differential,
  or property check that fails on drift. A green suite proves only what it executes, and no step
  may weaken, skip, or delete a test to turn green.
- `## Waves`: expand, migrate in batches, then contract, in the smallest ordered steps that each
  leave build and tests green. Give each its affected surfaces, verification, and rollback point.
- `## Cutover`: entry, completion, abort, and restore conditions.

Name every removed behavior as retired or re-established; a removal that is neither is a defect.
Give every compatibility shim a path and a removal condition. Contract ends at zero old call sites
across source, tests, generated code, dynamic dispatch, and configuration, outside named shims.
Measure performance before and after with one protocol: workload, environment, warmup, samples,
statistic, and ceiling.

## Verify

Before handoff, or in check-only mode without editing, report every break of the rules above, any
`TBD`, `TODO`, `???`, or blocking question in a `ready` spec, and every local source that does not
resolve.

## Artifact

When the project's tracker has a spec form, the filed issue is the spec: write the draft below in
the form's fields, file it through the project's route, and treat the file as spent. Otherwise the
file is the spec.

Write `~/.agents/artifacts/<workspace>/<ID>.md` with `~` expanded; `<workspace>` is the repository
or working-directory basename. Keep sidecars, such as evidence receipts and run notes, beside it and
link them. On a collision or an unwritable directory, ask the human; never overwrite, and never fall
back to the repository, a vendor directory, or a temporary path. Write local references relative to
the artifact. Return only clickable `~/.agents/...` links with absolute destinations, plus any
filed issue, and explain only a blocker, a failed write, incomplete verification, or an
irreversible-action confirmation.

## Close

When no downstream step needs the set, ask the human once: Delete, Leave, or Promote into
project-owned records. Once the spec is filed, Delete is the default. After Delete, confirm every
path is gone; a survivor blocks close.
