---
type: audit
id: AUDIT-corpus-repo-gates
---

# Corpus repository gates: can a broken change pass?

## Scope

- Repository: `/Volumes/Development/corpus`, remote `jcosta33/corpus` (public, default branch `main`).
- Frozen state: commit `ae6d2e8cf61c16f306772dcfc65e3b8cea80a7a6`. Audited blobs at that commit:
  - `scripts/lint-all.sh` `e5f8911`
  - `scripts/lint-accepted-adrs.sh` `78e20a6`
  - `scripts/lint-artifact-skills.sh` `5bfce83`
  - `.github/workflows/method-gates.yml` `a59f07d`
  - `AGENTS.md` `016d13b`
- Goal: assess whether the gates in `scripts/` and `.github/workflows/` can pass a broken change.
- Exclusions: everything under `docs/` and `skills/` was left unread (trial rule). The gates were
  probed against synthetic fixtures instead of the real skill files.
- Working-tree note: another writer is editing the tree while this audit runs. While I read, a
  3-line uncommitted edit landed in `scripts/lint-artifact-skills.sh` (`git diff --stat`:
  `1 file changed, 3 insertions(+)`), alongside a staged `docs/adrs/0190-*.md` and changes under
  `docs/` and `skills/`. All `file:line` citations below point at the frozen HEAD blobs. A live run
  of `sh scripts/lint-all.sh` on that dirty tree failed with
  `accepted ADR set drift: expected 187 files, found 188`.
- Scope question for the human: none. The task named the surface and the exclusions.

## Map

| Gate | What it checks | What it takes on faith |
| --- | --- | --- |
| `method-gates.yml` | Runs `sh scripts/lint-all.sh` on `push` to `main` and on `pull_request`. Sets `CORPUS_HISTORY_BASE` to the PR base or the push `before` (`method-gates.yml:3-6,17-20`). | That a red run stops the change. Branch protection API: `Branch not protected (HTTP 404)`. Rulesets: `[]`. |
| `lint-all.sh` | Runs both gate scripts and records each failure without stopping (`lint-all.sh:13-16`). Greps four root files for ADR ranges such as `0001-0187` (`:19-26`). | That all four grepped files exist. |
| `lint-accepted-adrs.sh` | When a base is set: no base-tree numbered ADR has been removed or changed (`:9-29`). Always: the tracked numbered-ADR count and the combined sha256 equal hard-coded constants (`:5-6,31-48`). | That the constants are updated only for new ADRs. The script itself is not sealed. |
| `lint-artifact-skills.sh` | The skill set, its catalog, and its payload shape (`:157-180`). Frontmatter (`:77-101,185`). Link syntax and package containment (`:103-117,204-218`). Banned vocabulary (`:219-230`). Required headings and keywords (`:238-250`). README provenance (`:256-260`). Existence of relative links in `skills/README.md` and `skills/sources.md` (`:262-270`). Artifact type and ID ownership (`:272-286`). | That required keywords mean the contract they name. That a contained link resolves to a real file. |

A search across every gate file for the paths it touches (`grep -nE 'docs/|README|sources\.md|\.github|scripts/' scripts/*.sh .github/workflows/*.yml`) found no `docs/` path other than `docs/adrs`. It also found no gate over `.github/` or `scripts/` themselves.

Last observed CI run: 41934540124 (`push`, head `ae6d2e8`, `success`). Its log shows
`CORPUS_HISTORY_BASE: 85660017…`, then `lint-accepted-adrs: OK`, `lint-artifact-skills: OK`,
`adr-ranges: OK`, `lint-all: OK`. The green check therefore exercised all three gates, including
the history seal.

Probe evidence, all run under both `sh` and `dash`:
- [probe-output.txt](./AUDIT-corpus-repo-gates-probes/probe-output.txt)
- [probes.sh](./AUDIT-corpus-repo-gates-probes/bin/probes.sh)
- Fixtures: [fixtures/run-20261105T101106](./AUDIT-corpus-repo-gates-probes/fixtures/run-20261105T101106)

The probes ran against HEAD copies of the gates in
[bin/](./AUDIT-corpus-repo-gates-probes/bin). The base fixture passes:
`lint-artifact-skills: OK rc=0`. Both controls fail as designed: an escaping link (p4) and an
extra payload file (p5) each give `rc=1`. This confirms that failures inside the gate's pipelines
reach the exit code.

## Findings

### F-001 Major: no gate can stop a change reaching `main`

- **Evidence:** CI triggers on `push: branches: [main]` and `pull_request` (`method-gates.yml:3-6`).
  `gh api repos/jcosta33/corpus/branches/main/protection` returns `Branch not protected`, and the
  rulesets list is `[]`. `AGENTS.md` says "Work from `main`; commit and push directly". The last 8
  runs (`gh run list`) were all `push` events, and the repository has 2 pull requests in total.
- **Failure mode:** the gates report after the commit is already on `main`. A red run blocks
  nothing.
- **Firing condition:** any direct push. That is the documented workflow.
- **Blast radius:** every other finding. Each gate is advisory with respect to `main`.

### F-002 Major: the local check skips the ADR history seal, and the seal's constants are re-blessed inline

- **Evidence:**
  - `lint-all.sh:15` calls each gate with only `"$ROOT"`.
  - `lint-accepted-adrs.sh:7-10` skips the history check when `CORPUS_HISTORY_BASE` is empty.
  - Only CI sets that variable (`method-gates.yml:18-19`).
  - The surviving check compares the ADR set to `EXPECTED_COUNT=187` and `EXPECTED_DIGEST=d7a7…`, which are hard-coded in the same unsealed script (`:5-6,34-47`).
  - Adding any ADR requires updating both constants. The live tree is in exactly that state now (`expected 187 files, found 188`).
- **Failure mode:** suppose a change edits an accepted ADR body, adds or deletes one, and also updates the two constants. That change passes `cmdCheck` (`sh scripts/lint-all.sh`). The history check would catch it, but only in CI, after the push (F-001).
- **Firing condition:** any change that adds an ADR. Re-blessing is routine then, so an edit to an old ADR body rides along unnoticed by the local gate.
- **Blast radius:** the "Never rewrite historical ADR bodies" rule in `AGENTS.md`.

### F-003 Major: nothing in `docs/` outside the numbered ADRs is gated

- **Evidence:** the whole-scope search under Map found `docs/adrs` as the only `docs/` path any gate reads. `AGENTS.md` lists `docs/method.md`, `docs/formats.md`, and `docs/research/sources.md` as authorities. It also requires that every load-bearing claim cite `[[KEY]]` linked to `docs/research/sources.md#KEY`, and that a contract change travel as a unit.
- **Failure mode:** these all pass the gates:
  - a broken link in the method, formats, glossary, or research documents
  - a `[[KEY]]` with no matching source entry
  - a published total
  - a half-updated contract
- **Firing condition:** any edit under `docs/` other than to `docs/adrs/NNNN-*.md`.
- **Blast radius:** the canon's method and format authorities. These are what the skills defer to.

### F-004 Major: the skill gate checks that keywords are present, not what the contract says

- **Evidence:**
  - `lint-artifact-skills.sh:238-250` requires the literal headings `## Artifact` and `## Close` and the path `~/.agents/artifacts/<workspace>/`.
  - It requires case-insensitive matches anywhere in the file for these words: `absolute`, `repository`, `vendor`, `temporary`, `collision`, `unwritable|blocked write`, `return only`, `relative to the artifact`, `Delete`, `Leave`, `Promote`, `sidecar`, `downstream step`.
  - No check names any other section.
  - Probe p2 rewrote "never overwrite, and never fall back" as "overwrite freely, and fall back". Result: `rc=0 lint-artifact-skills: OK`.
  - Probe p3 deleted the whole `## Method` section. Result: `rc=0 lint-artifact-skills: OK`.
- **Failure mode:** a skill whose placement, collision, or method rules are inverted or deleted passes, as long as the keywords still appear somewhere in the file.
- **Firing condition:** any edit to a `skills/*/SKILL.md` that keeps those keywords.
- **Blast radius:** all four artifact authors' behavior contracts.

### F-005 Minor: broken links inside skills, broken anchors, and broken root-README links pass

- **Evidence:**
  - For `SKILL.md` links, `lint-artifact-skills.sh:210-217` checks only that the target lies inside the package folder. It never checks that the target exists.
  - Existence is checked only for `skills/README.md` and `skills/sources.md` (`:263-270`).
  - `relative_links` strips `#…` before testing (`:73`). Fragment syntax is rejected only in the files passed to `validate_link_syntax` (`:205,262`), and `skills/sources.md` is not among them.
  - No gate checks links in the root `README.md`.
  - Probe p1 added `[the appendix](./appendix.md)` to a `SKILL.md`. Result: `rc=0`.
  - Probe p6 added `./corpus-audit/SKILL.md#no-such-anchor` in `skills/sources.md` and `./docs/no-such-file.md` in `README.md`. Result: `rc=0`.
- **Failure mode:** dead links ship in the skill payload and the product README.
- **Firing condition:** any edit that adds such a link.
- **Blast radius:** readers of the installed skills and of the README. Behavior is unaffected.

### F-006 Minor: the ADR-range check passes whenever one of its four files is missing

- **Evidence:**
  - `lint-all.sh:20-26` runs `grep -nHE … AGENTS.md CLAUDE.md GEMINI.md README.md` as the `if` condition, so any non-zero exit leads to `adr-ranges: OK`.
  - `CLAUDE.md` and `GEMINI.md` are tracked symlinks (`git ls-files -s`: mode `120000`).
  - The Linux grep(1) man page states the exit status is "2 if an error occurred". The quiet-mode exception applies only to `-q`, which this call does not use.
  - Probe p8 ran the block verbatim with `GEMINI.md` absent and `0001-0187` present in `AGENTS.md`. The match was printed, the raw grep exit was `2`, and the gate said `adr-ranges: OK`. With all four files present, the same input gives `adr-ranges FAILED`.
  - The pattern also misses ranges written with "to" or an em dash. Probe p8 printed `adr-ranges: OK` for `0001 to 0187` and `0001—0187`.
- **Failure mode:** ranges restated in bootstrap files pass silently.
- **Firing condition:** renaming or removing any of the four files, or a dangling symlink.
- **Blast radius:** the one rule this block enforces.

### F-007 Minor: a change to the gates is judged by the changed gates

- **Evidence:**
  - CI runs `sh scripts/lint-all.sh` from the checked-out change (`method-gates.yml:15,20`).
  - No gate fingerprints `scripts/` or `.github/` (see the Map search).
  - Probe p7 used a copy of the gate with an early `exit 0`. It passed the p4 fixture that the real gate fails: `rc=0` against `rc=1`.
- **Failure mode:** a change that weakens or disables a gate passes that gate.
- **Firing condition:** any edit to `scripts/*.sh` or `method-gates.yml`. A concurrent uncommitted edit to `lint-artifact-skills.sh` exists right now (see Scope).
- **Blast radius:** all gates. No review or protection backstops it (F-001).

## Unverified

- **Local git hooks and `core.hooksPath`.** These would show whether anything runs `cmdCheck` before a push. They are outside the permitted read scope (`scripts/`, `.github/`, `AGENTS.md`), so they were not inspected.
- **GNU versus BSD userland.** CI runs on `ubuntu-latest` with GNU grep, sed, awk, and dash. The probes ran on macOS BSD grep 2.6.0, BSD sed, and BSD awk, under `sh` (bash) and `dash`. Gate behavior on GNU tools was observed only through the passing HEAD run. No mutation probe ran on GNU tools.
- **The real `skills/` and `docs/` content.** These were not read (trial rule). Whether the shipped files contain dead links or anchors today is unchecked. Probes used synthetic fixtures derived from the variant skill file.
- **The `pull_request` path, and a push whose `before` commit can no longer be fetched.** Neither was run. Static reading of `lint-accepted-adrs.sh:12-15` says the second fails closed with `accepted ADR history base is unavailable`.
- **The concurrent working-tree edits.** These are the 3-line addition to `lint-artifact-skills.sh` and the staged ADR 0190. Both are outside the frozen state and were not assessed.
- **A discarded probe run.** The earlier fixture directory `fixtures/run-20261105T101046` came from a first run in which the p2 mutation did not apply. It is superseded by `run-20261105T101106`, and its p2 line should not be cited.
