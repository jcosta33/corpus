# Feature: example conformant task

> Fixture — **expected verdict: PASS.** A minimal `feature` task file that satisfies every
> rule in `../conformance.yaml`. A checker run against this must return conformant.

## Metadata

- Slug: example-conformant
- Type: feature
- Status: done

## Objective

Add a `--json` flag to the `export` command so output can be piped to other tools.

## Linked docs

- Spec: `.agents/specs/export-json-flag.md`

## Plan

1. Add the flag to the arg parser.
2. Branch the formatter on the flag.
3. Map each acceptance criterion to a test.

## Self-review

> **Hard gate.** Every question has a written answer; every required paste slot is filled.

### Verification outputs (paste actual command output — do not paraphrase)

- `git status` →
  ```
  On branch feature/export-json-flag
  nothing to commit, working tree clean
  ```
- `{{cmdValidate}}` (last 2 lines):
  ```
  ✓ 312 files passed
  Done in 9.1s
  ```
- `{{cmdTest}}` (last 2 lines):
  ```
  Tests: 488 passed, 488 total
  Time:  6.0 s
  ```
- `{{cmdValidateDeps}}` (last 2 lines): `n/a` — no dependency-graph validator in this project.

### Acceptance-criteria coverage

| Criterion | Check | Result |
| --------- | ----- | ------ |
| `export --json` emits valid JSON | `test`: `export.json.test` | passed; fails when the flag branch is removed (assertion-flip verified) |
| exit code 0 on success | `command`: `AGENTS.md > Commands > Test` | covered by the suite above |

## Open questions

- (none)
