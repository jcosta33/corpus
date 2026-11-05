---
type: spec
id: SPEC-split-skill-gate
status: ready
sources:
  - ../../../../../corpus/scripts/lint-artifact-skills.sh
  - ../../../../../corpus/scripts/lint-all.sh
  - ../../../../../corpus/scripts/lint-accepted-adrs.sh
  - ../../../../../corpus/.github/workflows/method-gates.yml
  - ../../../../../corpus/AGENTS.md
  - differential.sh
  - run-notes.md
---

# Split the skill gate into a catalog gate and a content gate

## Intent

The Corpus maintainer running `sh scripts/lint-all.sh` (locally or in the `method-gates` workflow)
gets the same verdict on every defect `scripts/lint-artifact-skills.sh` catches today, from two
scripts instead of one: `scripts/lint-skill-catalog.sh` owns the catalog, manifest, and payload
checks, and `scripts/lint-skill-content.sh` owns the per-skill content checks. Both run from
`lint-all.sh`. No check is added, removed, loosened, or reworded. The work stops at `scripts/` and
the live surfaces that name the retired script. It does not touch the ADR seal, the `adr-ranges`
check, the workflow file, or any skill text.

Removed behavior:

- Retired: the path `scripts/lint-artifact-skills.sh` and its `lint-artifact-skills: OK` line. No
  shim remains, because `lint-all.sh:13` is the only caller in `scripts/`, `.github/`, and
  `AGENTS.md`, and AC-007 proves no live reference survives.
- Re-established: standalone use of the skill gate, as two invocations that each take the same
  optional `REPO_ROOT` (AC-001, AC-002).
- Retired: a catalog failure hiding content findings. `lint-all.sh` now runs both gates, so a tree
  with a manifest defect can also print content messages (fixture `manifest-payload`). The
  `lint-all.sh` exit status is unchanged, and each split gate still fails fast in reference order.

## Baseline

The reference is the working-tree `scripts/lint-artifact-skills.sh` with SHA-256
`157e69822789ef388534c5a0b9bfdc8d517329075f42f375db5a53dc63bd0a5b`, observed on 2026-11-05 at
`main` `ae6d2e8` plus uncommitted edits. Line numbers below refer to that file.

- `lint-all.sh:13-16` runs `lint-accepted-adrs` and `lint-artifact-skills` in a loop. Each gets
  `"$ROOT"`, prints a `--- name ---` header, and turns a failure into `rc=1` plus
  `  ^ name FAILED`. `lint-all.sh:4-6` lists the gates in its header comment.
- `method-gates.yml:20` runs only `sh scripts/lint-all.sh`. `AGENTS.md` names
  `sh scripts/lint-all.sh` as `cmdCheck`. Nothing in `scripts/`, `.github/`, or `AGENTS.md` calls
  `lint-artifact-skills.sh` directly except `lint-all.sh:13`.
- The skill gate fails fast: the first failed check prints its message to stderr and exits 1
  (`set -eu`, `:5`). It exits 0 and prints `lint-artifact-skills: OK` (`:291`) only when every
  check passes. It accepts an optional `REPO_ROOT` (`:8-9`).
- `sh scripts/lint-artifact-skills.sh "$PWD"` exits 0 on the observed tree. `sh scripts/lint-all.sh`
  exits 1 because another lane's uncommitted ADR 0190 trips the seal:
  `accepted ADR set drift: expected 187 files, found 188`. That failure is outside this spec.
- The thinker-vocabulary check (`:222-224`) is an uncommitted edit by another lane. It appeared
  during this spec's authoring; `HEAD` has a 288-line file without it.

The check inventory and the script that owns each check after the split:

| Check | Lines | Owner after split | Fixture in `differential.sh` |
| --- | --- | --- | --- |
| `skills/` exists | 10 | both (precondition) | `root-missing` |
| Directory, `SKILL.md`, and catalog-link sets equal the expected manifest | 12-15, 157-169 | catalog | `manifest-dir`, `manifest-catalog`, `manifest-payload` |
| Catalog row label equals its target folder | 171-173 | catalog | `catalog-row` |
| No non-Markdown file under `skills/` | 175-177 | catalog | `payload-nonmarkdown` |
| No symlink under `skills/` | 178-180 | catalog | `payload-symlink` |
| No subdirectory inside a skill folder | 193-195 | catalog | `payload-subdirectory` |
| Only `SKILL.md` inside a skill folder | 196-202 | catalog | `payload-extra-file` |
| No provenance citation in `README.md` or `skills/README.md` | 259-263 | catalog | `readme-provenance` |
| Link syntax of `skills/README.md` | 103-117, 265 | catalog | `readme-link-syntax` |
| Relative links in `skills/README.md` and `skills/sources.md` resolve | 70-75, 266-273 | catalog | `readme-broken-link` |
| Skill frontmatter: one name equal to the folder, one valid description | 77-101, 185 | content | `content-frontmatter` |
| Description does not name its own skill | 186-189 | content | `content-self-name` |
| `SKILL.md` has at most 500 lines | 190-191 | content | `content-length` |
| Link syntax of each skill document | 103-117, 205 | content | `content-link-reference`, `-complex`, `-unsafe`, `-fragment` |
| No root-relative link | 206-208 | content | `content-link-root` |
| Relative links stay inside the skill folder | 209-218 | content | `content-link-escape` |
| No internal or dependency vocabulary | 219-221 | content | `content-vocab-internal` |
| No thinker or named-method vocabulary | 222-224 | content | `content-vocab-thinker` |
| No `../X/SKILL.md` dependency | 225-227 | content | `content-vocab-external` |
| No sibling skill named | 228-233 | content | `content-vocab-sibling` |
| No fence in the `## Output` section | 62-68, 236-239 | content | `content-output-fence` |
| `## Artifact` and `## Close` present | 24-29, 241-243 | content | `content-heading-artifact`, `content-heading-close` |
| Neutral artifact root literal present | 244 | content | `content-neutral-root` |
| Placement and handoff words present | 17-22, 245-247 | content | `content-placement` |
| No absolute local source example | 31-60, 248-250 | content | `content-source-absolute` |
| Lifecycle disposition words present | 251-253 | content | `content-lifecycle` |
| No provenance citation or source URL in `SKILL.md` | 254-256 | content | `content-provenance` |
| Each writer declares only its own artifact type | 141-155, 275-284 | content | `content-type-ownership` |
| Each writer has exactly one artifact frontmatter example with its type and ID prefix | 119-139, 285-289 | content | `content-artifact-frontmatter` |

Placement rule: a check about which files exist under `skills/`, the catalog, or the product READMEs
belongs to the catalog gate. A check that reads the text of a skill's own files belongs to the
content gate. The two payload-shape checks inside the per-skill loop (`:193-202`) are catalog
checks under this rule.

`differential.sh` copies the repository working tree into a temporary tree, injects one defect per
fixture, and compares the reference gate (extracted from `BASE`) with the split pair. Self-test
receipt: `run-notes.md`.

## Requirements

### AC-001 Catalog gate passes a clean tree
- When: `scripts/lint-skill-catalog.sh` runs on a clean checkout, from any working directory, with or without a `REPO_ROOT` argument
- Then: the catalog gate MUST exit 0 and print `lint-skill-catalog: OK`
- Verify with: `sh differential.sh ../../../../../corpus "$BASE" clean` from this artifact's directory, then `(cd / && sh /Volumes/Development/corpus/scripts/lint-skill-catalog.sh)`

### AC-002 Content gate passes a clean tree
- When: `scripts/lint-skill-content.sh` runs on a clean checkout, from any working directory, with or without a `REPO_ROOT` argument
- Then: the content gate MUST exit 0 and print `lint-skill-content: OK`
- Verify with: `sh differential.sh ../../../../../corpus "$BASE" clean` from this artifact's directory, then `(cd / && sh /Volumes/Development/corpus/scripts/lint-skill-content.sh)`

### AC-003 lint-all runs both gates in order
- When: `sh scripts/lint-all.sh` runs
- Then: `lint-all.sh` MUST run `lint-skill-catalog` and then `lint-skill-content`, each through the existing gate loop with `"$ROOT"`, after `lint-accepted-adrs`
- Verify with: `sh scripts/lint-all.sh 2>/dev/null | grep -E '^--- lint-'` prints exactly `--- lint-accepted-adrs ---`, `--- lint-skill-catalog ---`, `--- lint-skill-content ---` in that order

### AC-004 lint-all fails when either gate fails
- When: either split gate exits nonzero
- Then: `lint-all.sh` MUST print `  ^ <gate> FAILED` for that gate and exit 1
- Verify with: manual check in a scratch `git worktree add` copy: apply the `catalog-row` edit from `differential.sh`, run `sh scripts/lint-all.sh`, and observe `  ^ lint-skill-catalog FAILED` with exit 1; reset the copy, apply the `content-vocab-sibling` edit, and observe `  ^ lint-skill-content FAILED` with exit 1

### AC-005 lint-all header lists the gates it runs
- When: always
- Then: the header comment of `lint-all.sh` MUST list `lint-skill-catalog.sh` and `lint-skill-content.sh` with one-line purposes
- Verify with: `grep -cE '^#   lint-skill-(catalog|content)\.sh ' scripts/lint-all.sh` prints `2`

### AC-006 The combined script is retired
- When: the split is complete
- Then: `scripts/lint-artifact-skills.sh` MUST NOT exist
- Verify with: `test ! -e scripts/lint-artifact-skills.sh`

### AC-007 No live surface names the retired script
- When: the split is complete
- Then: a file outside `.git` and ADR bodies MUST NOT name `lint-artifact-skills`
- Verify with: `grep -rn --exclude-dir=.git --exclude-dir=adrs 'lint-artifact-skills' .` prints nothing

### AC-008 Shared code has one definition
- When: always
- Then: each helper function from the reference and the expected manifest MUST be defined exactly once across `scripts/*.sh`
- Verify with: `for f in require_regex require_literal reject_absolute_source_examples section_text relative_links validate_skill_frontmatter validate_link_syntax validate_artifact_frontmatter declaration_values; do n=$(cat scripts/*.sh | grep -c "^$f() {"); [ "$n" = 1 ] || echo "$f: $n"; done; [ "$(cat scripts/*.sh | grep -c "^expected='")" = 1 ] || echo "expected manifest duplicated"` prints nothing

### AC-009 The workflow and the other gates are untouched
- When: always
- Then: the split MUST NOT change `.github/`, `scripts/lint-accepted-adrs.sh`, or the `adr-ranges` block of `lint-all.sh`
- Verify with: `git diff --quiet "$BASE" -- .github scripts/lint-accepted-adrs.sh` exits 0, and `git diff "$BASE" -- scripts/lint-all.sh` touches only the header comment and the gate loop list

### AC-010 Missing skills root is still rejected
- When: always
- Then: both split gates MUST exit 1 with `artifact-author catalog not found: <root>/skills` when `skills/` is absent
- Verify with: `sh differential.sh ../../../../../corpus "$BASE" root`

### AC-011 Manifest drift is still rejected
- When: always
- Then: the catalog gate MUST reject drift between the expected manifest and the skill directories, the `SKILL.md` payloads, or the catalog links, with the reference message and the reference's expected/actual listing
- Verify with: `sh differential.sh ../../../../../corpus "$BASE" manifest`

### AC-012 Catalog row drift is still rejected
- When: always
- Then: the catalog gate MUST reject a catalog row whose label differs from its target folder with `catalog label and target drift`
- Verify with: `sh differential.sh ../../../../../corpus "$BASE" catalog`

### AC-013 Payload shape is still enforced
- When: always
- Then: the catalog gate MUST reject a non-Markdown file, a symlink, a subdirectory inside a skill folder, and any skill-folder file other than `SKILL.md`, each with its reference message
- Verify with: `sh differential.sh ../../../../../corpus "$BASE" payload`

### AC-014 Product README and catalog link checks are still enforced
- When: always
- Then: the catalog gate MUST reject provenance citations in `README.md` or `skills/README.md`, unsupported link syntax in `skills/README.md`, and unresolved relative links in `skills/README.md` or `skills/sources.md`, each with its reference message
- Verify with: `sh differential.sh ../../../../../corpus "$BASE" readme`

### AC-015 Skill frontmatter, self-naming, and length are still enforced
- When: always
- Then: the content gate MUST reject invalid skill frontmatter, a description that names its own skill, and a `SKILL.md` over 500 lines, each with its reference message
- Verify with: `sh differential.sh ../../../../../corpus "$BASE" content-frontmatter && sh differential.sh ../../../../../corpus "$BASE" content-self-name && sh differential.sh ../../../../../corpus "$BASE" content-length`

### AC-016 Skill link safety is still enforced
- When: always
- Then: the content gate MUST reject reference-style, complex inline, unsafe URI, fragment, root-relative, and package-escaping links in skill documents, each with its reference message
- Verify with: `sh differential.sh ../../../../../corpus "$BASE" content-link`

### AC-017 Skill vocabulary bans are still enforced
- When: always
- Then: the content gate MUST reject internal or dependency vocabulary, thinker or named-method vocabulary, `../X/SKILL.md` dependencies, and sibling skill names, each with its reference message
- Verify with: `sh differential.sh ../../../../../corpus "$BASE" content-vocab`

### AC-018 The artifact contract text is still required
- When: always
- Then: the content gate MUST reject a fenced `## Output` section, a missing `## Artifact` or `## Close` heading, a missing neutral artifact root, and a missing placement or handoff word, each with its reference message
- Verify with: `sh differential.sh ../../../../../corpus "$BASE" content-output && sh differential.sh ../../../../../corpus "$BASE" content-heading && sh differential.sh ../../../../../corpus "$BASE" content-neutral && sh differential.sh ../../../../../corpus "$BASE" content-placement`

### AC-019 Sources, lifecycle, and provenance rules are still enforced
- When: always
- Then: the content gate MUST reject an absolute local source example, a missing lifecycle disposition word, and a provenance citation or source URL in `SKILL.md`, each with its reference message
- Verify with: `sh differential.sh ../../../../../corpus "$BASE" content-source && sh differential.sh ../../../../../corpus "$BASE" content-lifecycle && sh differential.sh ../../../../../corpus "$BASE" content-provenance`

### AC-020 Artifact type ownership is still enforced
- When: always
- Then: the content gate MUST reject a writer that declares another artifact type, and a writer without exactly one frontmatter example carrying its type and ID prefix, each with its reference message
- Verify with: `sh differential.sh ../../../../../corpus "$BASE" content-type && sh differential.sh ../../../../../corpus "$BASE" content-artifact`

### AC-021 Every pattern, word list, and label survives verbatim
- When: always
- Then: every quoted literal in the reference script MUST appear in `scripts/*.sh`
- Verify with: `sh differential.sh ../../../../../corpus "$BASE" strings`

### AC-022 Each check fails only in its owner
- When: a single-defect fixture other than `manifest-payload` runs
- Then: the split gate that does not own the injected check, per the Baseline table, MUST exit 0
- Verify with: `sh differential.sh ../../../../../corpus "$BASE" all` prints `differential: OK`

## Waves

Each wave lands as its own commit on `main`. All three are pushed together, because a contract
change travels as a unit. "Green" means `lint-skill-*` (or, before Wave 2, `lint-artifact-skills`)
prints `OK` under `lint-all.sh`, and `lint-accepted-adrs` has the same result as at `BASE`.

1. Expand. Add `scripts/skill-gate-lib.sh` (sourced, never run by `lint-all.sh`) holding the shared
   `relative_links`, `validate_link_syntax`, and the expected manifest. Add
   `scripts/lint-skill-catalog.sh` and `scripts/lint-skill-content.sh`, moving each check body
   verbatim into the owner from the Baseline table, in reference order. Content-only helpers move
   into the content gate. The old script and `lint-all.sh` stay unchanged.
   Surfaces: three new files in `scripts/`. Verify: AC-001, AC-002, AC-008 (once the old script is
   gone; before that, count only the new files), AC-010 to AC-022. Rollback point: remove the three
   new files; nothing calls them yet.
2. Migrate. Change the `lint-all.sh` gate list to `lint-accepted-adrs lint-skill-catalog
   lint-skill-content` and update its header comment. Edit every live reference that
   `grep -rn --exclude-dir=.git --exclude-dir=adrs 'lint-artifact-skills' .` finds outside
   `scripts/lint-artifact-skills.sh` itself, one file at a time and by hand.
   Surfaces: `scripts/lint-all.sh` and the files the grep names. Verify: AC-003, AC-004, AC-005,
   AC-009. Rollback point: restore `lint-all.sh` and the edited references from the Wave 1 commit.
3. Contract. Delete `scripts/lint-artifact-skills.sh`. Surfaces: that file. Verify: AC-006, AC-007,
   AC-008, then `sh differential.sh ../../../../../corpus "$BASE" all`. Rollback point: restore the
   file with `git show "$BASE:scripts/lint-artifact-skills.sh"` and revert the Wave 2 loop change.

## Cutover

- Entry: `git status --short scripts .github AGENTS.md` prints nothing. Set `BASE=$(git rev-parse
  HEAD)`. `shasum -a 256 scripts/lint-artifact-skills.sh` equals the Baseline digest, or this
  spec's Baseline table and the `differential.sh` fixtures are revised to match `BASE` before work
  starts. `sh scripts/lint-artifact-skills.sh` exits 0. `SELFTEST=1 sh differential.sh
  ../../../../../corpus - all` (from this artifact's directory) prints `differential: OK`.
- Completion: AC-001 to AC-022 pass at the Wave 3 commit. All three commits are pushed to `main`.
  The `method-gates` run for that push shows `lint-skill-catalog: OK` and `lint-skill-content: OK`.
- Abort: a fixture reports `INERT` or `FAIL`, and resolving it would mean changing a pattern,
  label, word list, or check order. Or another lane changes `scripts/` after `BASE`. Or AC-007
  finds a reference whose owner decides it must keep the old name.
- Restore: before pushing, reset the lane to `BASE` only after the owner confirms in chat. After
  pushing, add `git revert` commits for Waves 3, 2, and 1 in that order; never rewrite history.
  Then confirm `sh scripts/lint-all.sh` prints `lint-artifact-skills: OK` again.
