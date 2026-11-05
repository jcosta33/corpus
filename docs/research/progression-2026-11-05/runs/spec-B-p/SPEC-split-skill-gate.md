---
type: spec
id: SPEC-split-skill-gate
status: ready
sources:
  - ../../../../../corpus/scripts/lint-artifact-skills.sh
  - ../../../../../corpus/scripts/lint-all.sh
  - ../../../../../corpus/.github/workflows/method-gates.yml
  - ../../../../../corpus/AGENTS.md
  - ./evidence-baseline.md
  - ./differential-check.sh
---

# Split the artifact-skill gate into a catalog gate and a content gate

## Intent

Replace `scripts/lint-artifact-skills.sh` with two gates that `scripts/lint-all.sh` runs one after
the other:

- `scripts/lint-skill-catalog.sh` owns the catalog, manifest, and payload checks.
- `scripts/lint-skill-content.sh` owns the per-skill content checks.

Every check in the baseline survives with the same trigger, the same stdout and stderr lines, and a
non-zero exit. The new gates reject nothing the baseline accepts. `cmdCheck` and CI stay
`sh scripts/lint-all.sh`.

## Baseline

The baseline is `scripts/lint-artifact-skills.sh` at the commit Wave 0 records as `BASE`. Line
numbers below are at HEAD `ae6d2e8`. Evidence: [evidence-baseline.md](./evidence-baseline.md).

Structure:

- Usage `scripts/lint-artifact-skills.sh [REPO_ROOT]`, `set -eu`, `LC_ALL=C` (lines 4-6). Resolves
  `ROOT` and exits 1 with `artifact-author catalog not found: $ROOT/skills` when `skills/` is
  missing (lines 8-10).
- The `expected` skill list (lines 12-15) feeds both the manifest checks and the sibling-name check
  (line 225).
- Helpers: `require_regex` and `require_literal` (17-29), `reject_absolute_source_examples` (31-60),
  `section_text` (62-68), `relative_links` (70-75), `validate_skill_frontmatter` (77-101),
  `validate_link_syntax` (103-117), `validate_artifact_frontmatter` (119-139), `declaration_values`
  (141-155).
- The script stops at the first failure (`exit 1`) and prints `lint-artifact-skills: OK` on success
  (line 288).
- `scripts/lint-all.sh:13-16` runs each gate as `sh "$ROOT/scripts/$gate.sh" "$ROOT"`, records failure
  with `rc=1`, and keeps going. The header comment at line 5 names the gate.
- CI (`.github/workflows/method-gates.yml:20`) runs `sh scripts/lint-all.sh` on `ubuntu-latest`,
  where `/bin/sh` is dash.

The table assigns every check to a new gate:

| Baseline lines (HEAD) | Check | Owner |
| --- | --- | --- |
| 8-10 | `skills/` exists | both |
| 157-169 | directories, payloads, and catalog rows match `expected` | catalog |
| 171-173 | catalog row label equals target | catalog |
| 175-177 | no non-Markdown file under `skills/` | catalog |
| 178-180 | no symlink under `skills/` | catalog |
| 193-195 | no subdirectory inside a skill folder | catalog |
| 196-202 | a skill folder holds only `SKILL.md` | catalog |
| 256-260 | no provenance citation in `README.md` or `skills/README.md` | catalog |
| 262 | link syntax in `skills/README.md` | catalog |
| 263-270 | relative links in `skills/README.md` and `skills/sources.md` resolve | catalog |
| 185 | skill frontmatter shape and name | content |
| 186-189 | description does not name its own skill | content |
| 190-191 | `SKILL.md` at most 500 lines | content |
| 205 | link syntax in skill documents | content |
| 206-208 | no root-relative link | content |
| 210-218 | relative links stay inside the package | content |
| 219-221 | no internal or dependency vocabulary | content |
| uncommitted, after 221 | no thinker or named-method vocabulary (present only if it lands in `BASE`) | content |
| 222-224 | no `../<x>/SKILL.md` dependency | content |
| 225-230 | no sibling skill named | content |
| 233-236 | no fence in `## Output` | content |
| 238-240 | `## Artifact` and `## Close` present | content |
| 241 | neutral artifact root present | content |
| 242-244 | placement and handoff words present | content |
| 245-247 | no absolute local source example | content |
| 248-250 | lifecycle words present | content |
| 251-253 | no provenance citation or source URL in `SKILL.md` | content |
| 272-286 | artifact type ownership and frontmatter contract per author | content |

Commands run, with results recorded in the receipt:

- `sh scripts/lint-artifact-skills.sh` exits 0.
- `sh scripts/lint-all.sh` exits 1, but only because of a foreign staged ADR. It prints
  `accepted ADR set drift: expected 187 files, found 188`.
- The harness [differential-check.sh](./differential-check.sh) self-tests green under `sh` and dash
  against both the HEAD body and the working-tree body.

Old call sites in read scope:

- `scripts/lint-all.sh:5` and `:13`.
- The script's own lines 2, 4, and the final OK line.

`.github/` and `AGENTS.md` contain none. `docs/`, `skills/README.md`, `skills/sources.md`,
`README.md`, `CLAUDE.md`, and `GEMINI.md` were not read, so their counts are open; Wave 0 counts
them. `docs/adrs/` bodies are immutable and excluded from the target. No compatibility shim is
planned. The target is zero references outside `docs/adrs/`.

## Requirements

Harness command, referred to below as "the harness command". Run it from `/Volumes/Development/corpus` after the new gates exist. `BASE` is the commit Wave 0 records.

```sh
B=$(mktemp -d) && git archive "$BASE" | tar -x -C "$B" && sh /Volumes/Development/corpus-review/_work/progression/runs/spec-B-p/differential-check.sh "$B/scripts/lint-artifact-skills.sh" scripts/lint-skill-catalog.sh scripts/lint-skill-content.sh "$B" scripts/lint-all.sh
```

### AC-001 - Catalog gate keeps every catalog check
- When: a fixture breaks a check the Baseline table assigns to catalog
- Then: `scripts/lint-skill-catalog.sh` MUST exit non-zero and print every stdout and stderr line the baseline printed for that fixture
- Verify with: the harness command exits 0 and prints a `PASS c-` line for every `c-` mutation

### AC-002 - Content gate keeps every content check
- When: a fixture breaks a check the Baseline table assigns to content
- Then: `scripts/lint-skill-content.sh` MUST exit non-zero and print every stdout and stderr line the baseline printed for that fixture
- Verify with: the harness command exits 0 and prints a `PASS s-` line for every `s-` mutation

### AC-003 - No new rejection
- When: always
- Then: the two new gates MUST NOT reject a tree the baseline accepts
- Verify with: the harness command prints `PASS clean (all accept)` and no `baseline accepts, new rejects` line

### AC-004 - Every baseline check is exercised
- When: always
- Then: the harness MUST trigger every baseline error label with at least one mutation
- Verify with: the harness command prints `baseline labels checked:` and no `FAIL coverage:` line; if a check without a mutation enters `BASE`, add a mutation to the harness before Wave 1

### AC-005 - Clean-tree success line
- When: either new gate runs against a tree that passes every check
- Then: the gate MUST exit 0 and print `<script basename without .sh>: OK`
- Verify with: the harness command prints no `does not print` line

### AC-006 - Missing catalog
- When: either new gate runs with a `REPO_ROOT` that has no `skills/` directory
- Then: the gate MUST exit non-zero and print `artifact-author catalog not found: <resolved root>/skills` to stderr
- Verify with: the harness command prints `PASS empty-root lint-skill-catalog.sh` and `PASS empty-root lint-skill-content.sh`

### AC-007 - lint-all runs both gates
- When: `sh scripts/lint-all.sh` runs
- Then: it MUST run both gates and print the headers `--- lint-skill-catalog ---` and `--- lint-skill-content ---`
- Verify with: the harness command prints `PASS lint-all clean (exit 0)`

### AC-008 - lint-all fails when either gate fails
- When: either gate exits non-zero inside `sh scripts/lint-all.sh`
- Then: `lint-all.sh` MUST exit 1 and print `^ <gate> FAILED` for that gate
- Verify with: the harness command prints `PASS lint-all c-non-markdown (exit 1)` and `PASS lint-all s-sibling-named (exit 1)`

### AC-009 - Same results under dash
- When: the gates run under dash, the CI `/bin/sh`
- Then: every result in AC-001 through AC-008 MUST hold
- Verify with: the harness command with `GATE_SH=dash` prefixed exits 0, and the `method-gates` workflow run for the pushed commit succeeds

### AC-010 - One skill list
- When: always
- Then: the expected skill list MUST be defined in exactly one file under `scripts/`
- Verify with: `grep -l "^expected='corpus-audit" scripts/*.sh | wc -l` prints `1`

### AC-011 - Old gate removed
- When: Wave 2 is merged
- Then: `scripts/lint-artifact-skills.sh` MUST NOT exist
- Verify with: `test ! -e scripts/lint-artifact-skills.sh`

### AC-012 - No stale references
- When: Wave 2 is merged
- Then: the repository MUST NOT reference `lint-artifact-skills` outside `docs/adrs/`
- Verify with: `! grep -rn --exclude-dir=.git --exclude-dir=adrs 'lint-artifact-skills' .`

### AC-013 - lint-all header names both gates
- When: always
- Then: the `scripts/lint-all.sh` header comment MUST list `lint-skill-catalog.sh` and `lint-skill-content.sh`, each with a one-line purpose
- Verify with: `grep -cE '^#   lint-skill-(catalog|content)\.sh ' scripts/lint-all.sh` prints `2`

### AC-014 - AGENTS.md layout stays true
- When: always
- Then: the `scripts/` line in `AGENTS.md` SHOULD read "`scripts/`: the ADR seal and the skill catalog and content gates, run together by `lint-all.sh`."
- Verify with: `grep -F 'the ADR seal and the skill catalog and content gates, run together by' AGENTS.md`

### AC-015 - Entry point unchanged
- When: always
- Then: `cmdCheck` and the CI step MUST stay `sh scripts/lint-all.sh`
- Verify with: `git diff --quiet "$BASE" -- .github && grep -F '| `cmdCheck` | `sh scripts/lint-all.sh` |' AGENTS.md`

## Non-goals

- Changing any check's pattern, message, threshold, or exit code.
- Editing anything under `skills/` or `docs/adrs/`, or changing `lint-accepted-adrs.sh` or the
  `adr-ranges` step.
- Writing an ADR. The gate's file layout is not method.
- Keeping the order of first failures across the two gates for a tree with several faults. Each gate
  keeps the baseline's relative order, and `lint-all.sh` now reports one failure per gate instead of
  one in total.
- Fixing the pre-existing `lint-accepted-adrs` count failure caused by the foreign staged ADR.

## Affected areas

Engineering decisions settled here, all reversible:

- **Names.** The new gates are `scripts/lint-skill-catalog.sh` and `scripts/lint-skill-content.sh`.
  The shared definitions live in `scripts/skill-gate-common.sh`. That file has no `lint-` prefix, so
  it never reads as a gate, and `lint-all.sh` does not run it.
- **Shared file.** `skill-gate-common.sh` holds the `ROOT` resolution and the `skills/` guard
  (baseline 8-10), `expected` (12-15), `relative_links` (70-75), and `validate_link_syntax`
  (103-117). Each gate sources it with `. "$(dirname -- "$0")/skill-gate-common.sh"` after
  `set -eu` and `export LC_ALL=C`. Both gates need these pieces, and a duplicated skill list could
  drift between the manifest check and the sibling check, which AC-010 forbids.
- **Catalog gate.** It loops over `"$ROOT"/skills/*/SKILL.md` to get each folder, using the baseline's
  `pwd -P` resolution, and runs the payload checks from baseline lines 193-202.
- **Content gate.** It keeps `require_regex`, `require_literal`, `reject_absolute_source_examples`,
  `section_text`, `validate_skill_frontmatter`, `validate_artifact_frontmatter`,
  `declaration_values`, and `writer_types`.
- **Usage.** Both gates keep the `[REPO_ROOT]` argument and the usage comment form.
- **Files touched:**
  - Wave 1 creates `scripts/skill-gate-common.sh`, `scripts/lint-skill-catalog.sh`, and
    `scripts/lint-skill-content.sh`.
  - Wave 2 modifies `scripts/lint-all.sh` and `AGENTS.md`, plus every non-ADR reference Wave 0
    finds.
  - Wave 2 deletes `scripts/lint-artifact-skills.sh`.
  - Wave 2 edits references by hand, one file at a time, per `AGENTS.md`.

## Waves

### Wave 0 - Freeze the baseline
- Do this first:
  - Wait until no uncommitted edit to `scripts/` exists. The working tree holds a foreign,
    uncommitted thinker-vocabulary check that is read-only for this work. Its owner must commit or
    drop it.
  - Record `BASE=$(git rev-parse HEAD)` under Execution.
  - Count references with `grep -rn --exclude-dir=.git 'lint-artifact-skills' .`. Record every hit
    outside `docs/adrs/` as a Wave 2 edit.
  - Self-test the harness: pass the baseline as OLD, CATALOG, and CONTENT, under `sh` and under
    `GATE_SH=dash`. For phase 2, name the copy `lint-artifact-skills.sh`.
- Affected surfaces: none. This wave only reads.
- Verification: the self-test exits 0 with no `FAIL coverage:` line.
- Rollback point: nothing to undo.

### Wave 1 - Add the two gates beside the old one
- Do this:
  - Create the shared file and both gates.
  - Move each check from the baseline in the Baseline table's order.
  - Leave `lint-all.sh` and the old script untouched.
- Affected surfaces: three new files in `scripts/`.
- Verification:
  - The harness command with `scripts/lint-all.sh` dropped from its arguments, under `sh` and
    under `GATE_SH=dash`.
  - `sh scripts/lint-artifact-skills.sh`, which must still print `lint-artifact-skills: OK`.
  - AC-010.
- Rollback point: revert the Wave 1 commit with `git revert`. Nothing calls the new files yet.

### Wave 2 - Cut lint-all over and remove the old gate
- Do this, in one commit:
  - In `lint-all.sh`, replace `lint-artifact-skills` in the gate list with
    `lint-skill-catalog lint-skill-content`.
  - Update the header comment.
  - Update `AGENTS.md` and every Wave 0 reference.
  - Delete `scripts/lint-artifact-skills.sh`.
- Affected surfaces:
  - `scripts/lint-all.sh`
  - `scripts/lint-artifact-skills.sh`
  - `AGENTS.md`
  - each Wave 0 reference
- Verification:
  - The full harness command, under `sh` and under `GATE_SH=dash`.
  - AC-011 through AC-015.
  - `sh scripts/lint-all.sh` prints `lint-skill-catalog: OK` and `lint-skill-content: OK`. Any
    remaining failure must be the pre-existing ADR count only.
- Rollback point: `git revert` the Wave 2 commit. That restores the old script and wiring. Never
  rewrite history.

## Cutover

- **Entry.**
  - `BASE` is recorded.
  - `scripts/` has no uncommitted foreign edit.
  - The harness self-test against `BASE` is green under `sh` and dash.
  - Wave 1 is green.
- **Completion.**
  - AC-001 through AC-015 pass, each with its recorded command and exit status.
  - The `method-gates` workflow succeeds on the pushed Wave 2 commit, or fails only on the
    pre-existing ADR count. If so, record its verbatim message.
- **Abort.**
  - Any harness `FAIL` that changing check logic cannot fix.
  - A foreign commit to `scripts/lint-artifact-skills.sh` lands between Wave 0 and Wave 2. The
    baseline has then moved: re-run Wave 0 against the new `BASE` and redo Wave 1.
- **Restore.** `git revert` the Wave 2 commit, then the Wave 1 commit. Confirm that
  `sh scripts/lint-artifact-skills.sh` prints `lint-artifact-skills: OK` and that `lint-all.sh`
  lists `lint-artifact-skills` again.
