---
type: audit
id: AUDIT-repository-gates
---

# Corpus repository gates: can a broken change pass?

## Scope

- Goal: map the repository gates and assess whether a broken change can pass them.
- Surface: [scripts/lint-all.sh](../../../../../corpus/scripts/lint-all.sh),
  [scripts/lint-accepted-adrs.sh](../../../../../corpus/scripts/lint-accepted-adrs.sh),
  [scripts/lint-artifact-skills.sh](../../../../../corpus/scripts/lint-artifact-skills.sh),
  [.github/workflows/method-gates.yml](../../../../../corpus/.github/workflows/method-gates.yml),
  and [AGENTS.md](../../../../../corpus/AGENTS.md) for the declared check slot and delivery path.
- Exclusions: the content of `docs/` and `skills/` was not read. Probes copy those trees and
  mutate the copies without reviewing them.
- Frozen state: commit `ae6d2e8cf61c16f306772dcfc65e3b8cea80a7a6`. Every `file:line` below refers
  to that commit. Blob IDs are in [the evidence receipt, E1](./AUDIT-repository-gates.evidence.md).
- Working tree at audit time: dirty, with staged ADR 0190 and edits under `docs/` and `skills/`.
  Another writer also changed `scripts/lint-artifact-skills.sh` during the audit (3 lines inserted
  after HEAD line 221). That edit is uncommitted and not assessed. Line numbers after 221 in the
  working-tree copy run 3 higher than cited here.
- Scope question for the human (none available). The question: should the audit cover HEAD or the
  moving working tree? Recommended and applied: **HEAD `ae6d2e8`**, because it is stable and is
  what CI last ran. Alternatives were the working tree (includes the in-flight gate edit, but the
  target keeps moving and citations go stale) or both (twice the cost, and the working-tree half is
  stale as soon as the other writer commits).
- Evidence: [AUDIT-repository-gates.evidence.md](./AUDIT-repository-gates.evidence.md), with
  probe trees in [probe/](./probe/).

## Map

### Entry points and wiring

- `cmdCheck` is `sh scripts/lint-all.sh` (AGENTS.md:44-46). The delivery path is "Work from
  `main`; commit and push directly" (AGENTS.md:48).
- CI: workflow `method-gates` runs on `push` to `main` and on every `pull_request`
  (method-gates.yml:3-6). It has `contents: read` (:8-9) and `actions/checkout@v4` with
  `fetch-depth: 0` (:15). It runs `sh scripts/lint-all.sh` from the checked-out tree (:20), with
  `CORPUS_HISTORY_BASE` set to the PR base SHA or the push `before` SHA (:19).
- `lint-all.sh` runs `lint-accepted-adrs` and `lint-artifact-skills` and collects failures into
  `rc` without stopping early (:13-16). It then runs an inline `adr-ranges` grep over `AGENTS.md`,
  `CLAUDE.md`, `GEMINI.md`, and `README.md` (:18-26) and exits `rc` (:33).
- Main has no branch protection and no rulesets. The local clone has no `core.hooksPath` and no
  non-sample hooks ([E3](./AUDIT-repository-gates.evidence.md)). The last eight CI runs were all
  `push` events and all succeeded. None was a `pull_request` run.

### `lint-accepted-adrs.sh`: the ADR seal

- Optional history check (:9-29): runs only when `CORPUS_HISTORY_BASE` is non-empty and non-zero.
  It fails closed if the base commit is missing (:12-15). Every numbered ADR in the base must
  still exist (:19-22) and must have no diff against the base (:23-26).
- Set seal (:31-48): numbered ADRs come from `git ls-files` (the index). The file count must
  equal `EXPECTED_COUNT=187` (:5, :33-37). A digest of the working-tree contents of those files
  must equal `EXPECTED_DIGEST` (:6, :39-48).
- Filename filter: `^docs/adrs/[0-9]{4}-[^/]+\.md$` (:17, :32).
- `lint-all.sh:15` passes `$ROOT`, but this script ignores the argument and derives `ROOT` from
  its own path (:4).

### `lint-artifact-skills.sh`: the structural skill gate

- Manifest: the skill directories, the `SKILL.md` payloads, and the `skills/README.md` catalog
  links must each equal the hard-coded four names (:12-15, :157-169). Catalog labels must match
  their targets (:171-173).
- Payload hygiene: no non-Markdown files (:175-177), no symlinks (:178-180), no subdirectories
  (:193-195), and nothing besides `SKILL.md` in a skill folder (:196-202).
- Per-skill checks:
  - Frontmatter has exactly one `name` matching the folder and exactly one `description` under
    YAML-safety limits (:77-101, :185).
  - The description does not name its own skill (:186-189).
  - The file has at most 500 lines (:190-191).
- Link checks:
  - Link syntax: no reference-style, complex, unsafe-scheme, or fragment links (:103-117, :205).
  - No root-relative links (:206-208).
  - Relative links must resolve inside the skill folder (:210-218). The target's existence is
    not tested.
- Vocabulary bans: internal vocabulary (:219-221), `../X/SKILL.md` dependencies (:222-224),
  and sibling skill names (:225-230).
- Contract keyword checks:
  - No fenced block under `## Output` (:233-236).
  - The literal headings `## Artifact` and `## Close` must appear (:238-240).
  - The neutral root literal must appear (:241).
  - These words must appear anywhere in the file: absolute, repository, vendor, temporary,
    collision, unwritable or blocked write, return only, relative to the artifact (:242-244).
  - No absolute `sources:` examples (:245-247).
  - The words Delete, Leave, Promote, sidecar, and downstream step must appear (:248-250).
  - No `AUDIT-n`, GitHub URL, or DOI (:251-253).
- Repository-wide checks:
  - No provenance citations in `README.md` or `skills/README.md` (:256-260).
  - Link syntax in `skills/README.md` (:262).
  - Relative links in `skills/README.md` and `skills/sources.md` must exist; fragments are
    stripped first (:263-270, :73).
  - Each writer declares exactly one artifact `type` value, and its frontmatter template carries
    the expected type and ID prefix (:272-286).

### What the gates control and what they leave alone

- Gated content: the numbered ADR files (by digest and, in CI, by history), the `skills/` tree,
  `skills/README.md` and `skills/sources.md` link existence, and range strings in the four root
  files.
- Ungated content: `docs/method.md`, `docs/formats.md`, `docs/glossary.md`,
  `docs/research/sources.md`, and `docs/adrs/README.md`. Their only coverage is that a link from
  `skills/README.md` or `skills/sources.md` must point at an existing file. No gate checks
  `[[KEY]]` citation keys or link fragments. This rests on the whole-scope sweep in
  [E9](./AUDIT-repository-gates.evidence.md).
- Observed pass on HEAD: the skill gate passes on an extracted HEAD tree
  ([E4](./AUDIT-repository-gates.evidence.md)). CI passed all three gates on `ae6d2e8`
  ([E3](./AUDIT-repository-gates.evidence.md)).
- Observed fail on the current working tree: the ADR seal fails with
  `accepted ADR set drift: expected 187 files, found 188`
  ([E2](./AUDIT-repository-gates.evidence.md)).

## Risks

### Major: no gate stands between a change and `main`

- Evidence:
  - AGENTS.md:48 sets direct commit-and-push to `main`.
  - CI triggers on push to `main` after the push lands (method-gates.yml:4-5).
  - Branch protection returns 404 and rulesets are `[]`.
  - No local hook is installed ([E3](./AUDIT-repository-gates.evidence.md)).
- Failure mode: a change that fails `lint-all.sh` still reaches `main`. CI reports the failure
  only afterwards.
- Firing condition: any push where nobody ran `cmdCheck`, or where it failed and the push went
  ahead anyway.
- Blast radius: every file in the repository, published to a public repository.
- Delivery control as observed: `deterministic local` when run by hand, plus a post-push CI
  signal. Nothing at the push boundary enforces it.

### Major: the gates and their seals can be edited by the change they check

- Evidence:
  - CI runs the checked-out `scripts/lint-all.sh` (method-gates.yml:20).
  - The seal constants live in the gated tree (lint-accepted-adrs.sh:5-6).
  - The history check is part of the same editable script (:9-29) and is skipped when
    `CORPUS_HISTORY_BASE` is empty (:10). The local `cmdCheck` never sets it (AGENTS.md:46,
    lint-all.sh:15).
- Failure mode 1, local: a change edits an accepted ADR body and updates `EXPECTED_DIGEST`. It
  passes `sh scripts/lint-all.sh`.
- Failure mode 2, CI: a change that also edits `lint-accepted-adrs.sh` or `lint-all.sh` passes
  CI as well.
- Firing condition: for local runs, any ADR edit plus a digest update. For CI, the same change
  plus a gate-script edit.
- Blast radius: the accepted decision history that AGENTS.md:7 says must never be rewritten.
- Basis: static reading of the control flow only. No run probed this.

### Major: the skill gate checks keywords and structure, not the contract

- Evidence: the contract checks are word-presence and heading-literal tests on the whole file
  (lint-artifact-skills.sh:17-22, :238-250). `## Output` is checked only for a fenced block
  (:233-236). Nothing requires it to exist.
- Probe ([E6](./AUDIT-repository-gates.evidence.md)): deleting the `## Output` heading and
  appending `Write the artifact into the repository root when convenient.` still gives
  `lint-artifact-skills: OK`.
- Failure mode: a skill that contradicts or drops its own placement, output, or lifecycle rules
  passes, provided the required words still appear somewhere.
- Firing condition: any edit to a `SKILL.md` that keeps the keyword set.
- Blast radius: the shipped artifact-author skills, which are the repository's product
  (AGENTS.md:3-4).

### Major: the canon documents under `docs/` are ungated apart from ADR files

- Evidence: whole-scope sweep in [E9](./AUDIT-repository-gates.evidence.md). AGENTS.md:9-10
  names `docs/method.md` and `docs/formats.md` as authorities. AGENTS.md:26-27 requires
  `[[KEY]]` citations linked to `docs/research/sources.md#KEY`.
- Failure mode: these all pass:
  - a broken link in a method, formats, or glossary document;
  - a dangling citation key;
  - a missing anchor;
  - a ledger (`docs/adrs/README.md`) that disagrees with the ADR files.
- Firing condition: any edit under `docs/` outside numbered ADR files.
- Blast radius: the method and format authorities that every secondary surface links to.

### Minor: negative `grep` checks fail open when a file is missing

- Evidence: `if grep ...; then fail; else OK` at lint-all.sh:20-26 and
  lint-artifact-skills.sh:256-260. `grep` exits 2 on a missing file. Without `-q`, it still exits
  2 when another file holds a real match (man7 grep(1), EXIT STATUS).
- Probes ([E7](./AUDIT-repository-gates.evidence.md),
  [E8](./AUDIT-repository-gates.evidence.md)): with all four root files absent, the log shows
  `adr-ranges: OK` and `lint-artifact-skills: OK`. With a real `0001-0187` hit plus one missing
  file, grep exits 2 and the branch prints `adr-ranges: OK`.
- Failure mode 1: deleting or renaming `AGENTS.md` leaves the `CLAUDE.md` and `GEMINI.md`
  symlinks dangling. The range check then passes even if `README.md` restates an ADR range. The
  same holds for deleting `README.md`.
- Failure mode 2: no gate checks that `AGENTS.md` exists at all.
- Firing condition: a missing or dangling root file.
- Blast radius: the agent contract entry point and the product README. A deletion shows up
  plainly in the diff, which limits reach.

### Minor: broken links inside a skill package pass

- Evidence: relative links in `SKILL.md` are checked only for escaping the folder
  (lint-artifact-skills.sh:210-218). Existence is tested only for `skills/README.md` and
  `skills/sources.md` (:263-270).
- Probe ([E5](./AUDIT-repository-gates.evidence.md)): `See [the guide](./guide.md).` passes with
  `rc=0`, although the folder holds only `SKILL.md`. The control link `../corpus-spec/SKILL.md`
  fails with `skill link escapes package`.
- Failure mode: a shipped skill links to a file that does not exist.
- Firing condition: any intra-folder link other than `./SKILL.md`. The payload rule at :196-202
  makes every other target nonexistent.
- Blast radius: the reader of that one skill.

### Minor: the ADR seal sees only tracked files with one filename shape

- Evidence: the set comes from `git ls-files` with `^docs/adrs/[0-9]{4}-[^/]+\.md$`
  (lint-accepted-adrs.sh:31-32). The history base uses the same filter (:16-17).
- Failure mode 1: a local run before `git add` ignores a new untracked ADR and reports OK. The
  count changes only after staging.
- Failure mode 2: an ADR named outside the pattern, such as a three-digit number or a file in a
  subdirectory of `docs/adrs/`, is never sealed or frozen.
- Firing condition: a new ADR that is not staged, or that is misnamed.
- Blast radius: one decision record escapes immutability.
- Basis: static reading. Untracked-file behavior follows from `git ls-files` listing the index.
  It was not separately probed.

### Minor: the checkout action is pinned to a mutable tag

- Evidence: `actions/checkout@v4` (method-gates.yml:15).
- Failure mode: upstream retagging changes the code the gate job runs.
- Firing condition: a change to the upstream `v4` tag.
- Blast radius: the CI gate result only. The job token is `contents: read` (:8-9).

## Unknowns

- CI toolchain on failure paths. Every failing probe ran locally under `/usr/bin/grep` (BSD grep
  2.6.0) and macOS `awk`. CI runs `ubuntu-latest` with GNU grep and that image's default `awk`.
  Search boundary: the last eight CI runs, all successes. Missing evidence: a CI run that drives a
  failing case.
- History-check behavior after a force push to `main`. Static reading says it fails closed when
  the `before` SHA is unreachable (lint-accepted-adrs.sh:12-15). Missing evidence: whether
  `fetch-depth: 0` retrieves an orphaned `before` commit. No run was made.
- Pull-request path. No `pull_request` run appears in the last eight runs, so the
  `base.sha` branch of method-gates.yml:19 has not been observed.
- History check on a real ADR edit. This audit did not run it, because a probe would need commits
  in a repository. Missing evidence: a run with `CORPUS_HISTORY_BASE` against an edited ADR.
- The uncommitted working-tree hunk in `scripts/lint-artifact-skills.sh` from another writer. It
  is outside the frozen state and was not assessed.
- `docs/` and `skills/` content. This audit did not read them, so it makes no claim about whether
  either currently holds broken links, citations, or contract contradictions.
