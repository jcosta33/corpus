---
name: corpus-spec
description: Write, revise, or check a verifiable change contract before implementation. Use when intent or consequential behavior must become requirements with acceptance checks, when a refactor, migration, rewrite, upgrade, or schema or performance change must preserve behavior through staged waves and rollback, or when parallel workers need a write-disjoint split. Do not use for small clear fixes, direct implementation, or factual verification.
---

# Corpus Spec

A spec is decided intent under test. Nothing else belongs.

## Method

1. Read project rules, current code, tests, related decisions, and open issues.
2. Settle discoverable facts and reversible conventions yourself. Ask the human only about
   material behavior, public contracts, security, cost, or irreversible choices: recommendation
   first, two or three real options, each with its cost.
3. If one precise sentence governs the work, state it inline with its verification. Write no file.
4. Otherwise write the spec. Any unresolved blocking choice keeps `status: draft` and blocks
   dependent work.

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

`# {{title}}`, then non-empty `## Intent` and `## Requirements`. Add `## Non-goals`,
`## Open questions`, or `## Affected areas` only when they carry information.

```markdown
### AC-001 - Short name
- When: one concrete condition, or `always` for an invariant
- Then: the actor MUST do one observable thing
- Verify with: `exact command` or a named manual check
```

Use exactly those three items, in that order, and nothing else under the heading. Use exactly one
of `MUST`, `MUST NOT`, `SHOULD`, `SHOULD NOT`, or `MAY` in `Then`. Split obligations that fail
independently. Name a mechanism only when a public contract makes it observable.

## Structural change

For a refactor, migration, rewrite, upgrade, schema change, or performance change, also write:

- `## Baseline`: current structure and behavior, each with `file:line`, test, or command evidence.
  Map an unfamiliar area before planning.
- Preserved behavior as requirements with `When: always`. Verify each with a golden, differential,
  or property check that fails on drift. A green suite proves only what it executes.
- `## Waves`: the smallest ordered steps that each leave build and tests green. Give each its
  affected surfaces, verification, and rollback point.
- `## Cutover`: entry, completion, abort, and restore conditions.

Give every compatibility shim a path and a removal condition. Count old call sites across source,
tests, generated code, dynamic dispatch, and configuration; the target is zero outside named
shims. Measure performance before and after with one protocol: workload, environment, warmup,
samples, statistic, and ceiling.

## Split

Only when independent workers implement in parallel, add `## Split` with one row per slice:
requirement IDs, permitted write paths, excluded paths, `Starts after`, and `May run with`.

- Each requirement belongs to exactly one slice, unless each repository or platform verifies the
  whole obligation itself.
- Run slices in parallel only when they are write-disjoint and share no interface, schema,
  generated file, or build configuration. Unknown scope conflicts with everything.
- Sequence interface-defining work first.
- Dispatch each worker the spec path and its row.

## Verify

Before handoff, confirm:

- valid frontmatter and unique `AC-` IDs;
- a non-empty Intent;
- the exact three-item block and one strength word in every requirement;
- no `TBD`, `TODO`, `???`, or blocking question at `status: ready`;
- every local source resolves;
- every wave names verification;
- every split slice is write-disjoint, and every requirement is covered once.

In check-only mode, report exact errors without editing.

The implementer records changed files, each verification command with its exit status and
decisive output, scope drift, and blocked questions under `## Execution`. Missing output is
unverified. The implementer cannot accept their own work; a non-implementer reviews on the native
pull request.

## Artifact

Write `~/.agents/artifacts/<workspace>/<ID>.md` with `~` expanded. `<workspace>` is the repository
or working-directory basename. Put sidecars, such as evidence receipts and run notes, beside it and
link them. Never overwrite; on a collision, ask for a name. If the directory is unwritable, offer
grant and retry, another user directory, or cancel. Never fall back to the repository, a vendor
directory, or a temporary path. Write local source references relative to the artifact; hand off
absolute paths.

## Output

Return only clickable links to the artifact and its sidecars, labelled `~/.agents/...`, with
absolute destinations. Explain only a blocker, a failed write, incomplete verification, or an
irreversible-action confirmation.

## Close

When no downstream step needs the set, ask the human once: Delete, Leave, or Promote into
project-owned records. After Delete, confirm every path is gone; a survivor blocks close.
