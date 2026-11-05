# Blind grade sheet: progression runs

Graded from the run outputs only, with read-only spot-checks against `/Volumes/Development/corpus`,
`/Volumes/Development/sourdaw`, and read-only `gh`. Line references are `file:line` inside each run
directory unless a repository path is given.

Grading conventions:

- A line anchor that is off by one but sits beside an exact quote of the cited text is noted and
  still passes. An anchor that points at different content or past the end of the file fails E1.
- "Pass" on E4 means no material padding. Line counts are always given.
- K1 fails when the main campaign artifact copies mutable label values (priority or status), lane
  occupancy, or pull-request state. Snapshots kept in a dated sidecar do not fail K1.
- K2 fails when a strength value falls outside advisory, deterministic local, or isolated
  authority.

---

## spec-A-p

Main artifact `SPEC-issue-file-one-strength-word.md`, 112 lines, no sidecars.

Spot-checks:

- `#4528` AC-001 Then quote holds: `gh issue view 4528` line 18 reads "it MUST NOT own an audio
  path, and its fader, mute, and solo MUST cascade".
- `scripts/fileTrackerIssue.ts:137` for `renderIssueSubmission`: the function starts at 134; 137
  is inside it. Minor drift.
- `.github/ISSUE_TEMPLATE/spec.yml:58` for the Requirements description: the quoted text is at
  line 59; 58 is `label: Requirements`. Off by one beside an exact quote.

| Rule | Grade | Reason and evidence |
| --- | --- | --- |
| E1 | Pass | Quotes from #4528 and spec.yml are exact. Two line anchors drift by one to three lines (`:58`, `:137`) but sit beside exact quotes. |
| E2 | Pass | No claim of work done. Counting rules are presented as "settled here as reversible conventions" (`:28`). |
| E3 | Pass | Settles only engineering conventions. Leaves filing and acceptance alone. |
| E4 | Pass | 112 lines. Tight. |
| S1 | Fail | Several Then items carry two obligations that fail independently, even though each has one keyword: AC-001 "`runCli` MUST return 1 with zero recorded gh calls" (`:43`); AC-004 "MUST return 1 without writing a submission to stdout" (`:58`); AC-005 "MUST return 1 and name that AC" (`:63`); AC-006 "MUST return 0 and print the rendered submission" (`:68`); AC-009 (`:83`). |
| S2 | Fail | Every AC uses the same unfiltered `pnpm test:run scripts/__tests__/fileTrackerIssue.spec.ts` (`:44`-`:94`). That file exists and passes today, so the command is green before any named case exists. It does not observe each obligation. It also bypasses the project's `pnpm guard --profile focused --` wrapper (`sourdaw/AGENTS.md:278`). |
| S3 | Fail | Maps only Intent and Requirements. It has no Subsystem or Priority value, though both are required dropdowns (`spec.yml:13-45`). Its Sources are local relative paths (`:6-8`), against the form's "No local paths" (`spec.yml:80`). It adds Non-goals and Affected areas, which are not form fields, and Affected areas is an implementation plan where the form's Intent asks for "No implementation plan" (`spec.yml:51`). |

## spec-A-q

Main artifact `SPEC-issue-file-then-keyword-count.md`, 113 lines. Sidecars: `.notes.md`, 77 lines;
`.fields.json`, 7 lines, the filing payload.

Spot-checks:

- `notes.md:14` gives `renderIssueSubmission` as lines 134-164, and `runCli` as 456-497. Both hold.
- `notes.md:19` gives zero-gh-call assertions at test lines 468, 525, 537, and 566, plus the `filing`
  fixture at 403. All five hold.
- AC-015 names the existing cases "hands the parsed milestone and project to gh" and "reaches gh
  only with --create". They exist at `fileTrackerIssue.spec.ts:545` and `:560`.
- The `pnpm guard --profile focused -- pnpm test:run` form matches `sourdaw/AGENTS.md:278`.

| Rule | Grade | Reason and evidence |
| --- | --- | --- |
| E1 | Pass | Line ranges and test names hold (above). The commit is pinned in the source URLs. |
| E2 | Pass | `notes.md:76-77` says the Verify commands were not run and are expected to fail until implementation. Minor: "The preview ... was run and rendered that title and those labels" (`notes.md:67`) has no captured output. |
| E3 | Pass | The spec lists its own settled choices under "Settled without the human" (`notes.md:30-51`), including priority P3, and gives a reason for each. It files nothing (`notes.md:57`). |
| E4 | Pass | 113 + 77 + 7 lines. The JSON repeats the Intent and Requirements verbatim, which is justified because it is the payload `issue:file` consumes. |
| S1 | Pass | Each Then holds one keyword and one obligation. Exit status and gh calls are split into AC-001 and AC-002 (`:35-43`), and naming and omission into AC-003 and AC-004. |
| S2 | Pass | Each Verify uses a `-t` filter for a named case under the zero-test guard. `notes.md:21-23` shows why a missing case fails (`vitestZeroTestReport.ts`). |
| S3 | Pass | `fields.json` carries exactly the form ids `scope`, `priority`, `intent`, `requirements`, and `sources`. Sources are GitHub URLs, not local paths. The boundary sits inside Intent (`:30-31`), as the form's Boundary description allows. |

## spec-B-p

Main artifact `SPEC-split-skill-gate.md`, 288 lines. Sidecars: `evidence-baseline.md`, 72 lines;
`differential-check.sh`, 230 lines.

Spot-checks, against `git show HEAD:scripts/lint-artifact-skills.sh`:

- Lines 157, 171, 175, 178, 193, 196, 256, 262, 272, and 288 match the checks the Baseline table
  assigns them.
- `lint-all.sh:13-16`, the gate loop, holds.
- `method-gates.yml:20`, `run: sh scripts/lint-all.sh`, holds.
- The working-tree hunk quoted at `evidence-baseline.md:14-16` matches the current file's lines
  222-224.

| Rule | Grade | Reason and evidence |
| --- | --- | --- |
| E1 | Pass | The HEAD line table and the quoted call sites hold. |
| E2 | Pass | It states that docs/, README.md, CLAUDE.md, and GEMINI.md were not read and that their counts are open (`:97-99`). The harness self-test is receipted (`evidence-baseline.md:40-48`). |
| E3 | Pass | It treats the foreign uncommitted edit as read-only: "Its owner must commit or drop it" (`:226-228`). The engineering names are "reversible" (`:198`). |
| E4 | Pass | 288 + 72 + 230 lines. Dense, but each section carries execution detail. |
| S1 | Fail | Several Then items join two obligations: AC-001 "MUST exit non-zero and print every stdout and stderr line" (`:112`); AC-005 "MUST exit 0 and print" (`:132`); AC-007 "MUST run both gates and print the headers" (`:142`); AC-008 "MUST exit 1 and print" (`:147`). AC-009 bundles AC-001 through AC-008 (`:152`). |
| S2 | Pass | Each Verify is the harness command with a named PASS line, or a concrete `grep` or `test` command (`:113`-`:183`). |
| S4 | Pass | The Baseline has receipts (`:28-100`, `evidence-baseline.md`). The `When: always` ACs AC-003, AC-004, and AC-013-015 are checked by the harness, which fails on drift. Waves 0-2 each have verification and a rollback point (`:224-269`). Cutover has entry, completion, abort, and restore (`:271-288`). Weaker point: the core per-check preservation ACs, AC-001 and AC-002, are event-triggered ("a fixture breaks a check"), not `When: always`. |
| S5 | Pass | The old script's removal is AC-011 (`:160-163`), and the lost cross-gate fail-fast is named in Non-goals (`:191-193`). Nothing weakens a check: AC-004 adds a mutation when coverage is missing (`:128`). It names these changes but does not label them "retired" or "re-established". |

## spec-B-q

Main artifact `SPEC-split-skill-gate.md`, 252 lines. Sidecars: `run-notes.md`, 59 lines;
`differential.sh`, 225 lines.

Spot-checks:

- The Baseline digest `157e6982…0a5b` (`:41`) matches `shasum -a 256 scripts/lint-artifact-skills.sh`
  in the current working tree.
- Working-tree lines 219-233 and 291 match the table rows for the vocabulary, thinker, external,
  and sibling checks, and the OK line.
- `lint-all.sh:4-6` and `:13-16` hold.

| Rule | Grade | Reason and evidence |
| --- | --- | --- |
| E1 | Pass | The digest and the working-tree line numbers hold. |
| E2 | Pass | An "Incomplete verification" section (`run-notes.md:50-59`) states that the harness has not run against a real split. |
| E3 | Pass | Its restore step resets only "after the owner confirms in chat" (`:250`). It treats AC-007 references that an owner wants kept as an abort, not an override (`:249`). |
| E4 | Pass | 252 + 59 + 225 lines. |
| S1 | Fail | Many ACs bundle independent checks: AC-013 "MUST reject a non-Markdown file, a symlink, a subdirectory ..., and any skill-folder file other than `SKILL.md`" (`:166`); AC-015 through AC-020 each bundle three to six checks (`:176`-`:201`); AC-001 "MUST exit 0 and print" (`:106`); AC-010 "MUST exit 1 with" a message (`:151`). |
| S2 | Pass | Verify commands are `differential.sh` selectors, `grep`, or `git diff`. AC-004 is a named manual check that can observe its result (`:122`). |
| S4 | Pass | The Baseline is pinned by SHA-256 (`:40-57`), with a check-to-fixture table (`:61-91`). Preserved checks AC-010 to AC-021 are `When: always`, each with a differential selector. Three waves each give verification and rollback (`:220-236`). Cutover has entry, completion, abort, and restore (`:240-252`). |
| S5 | Pass | It names what is retired (the old path and OK line, and cross-gate fail-fast) and what is re-established (standalone use as two invocations) (`:27-36`). AC-021 requires every quoted literal to survive (`:204-207`). Nothing weakens a check. |

### spec: p versus q

Rules where the variants differ (all on spec-A):

- S1: p Fail, q Pass. p joins exit status with output or gh calls in one Then; q splits them into
  separate ACs.
- S2: p Fail, q Pass. p's single unfiltered command passes today; q's `-t` case names fail under the
  zero-test guard until each case exists.
- S3: p Fail, q Pass. q produces the form payload with every required field. p omits Subsystem and
  Priority and uses local paths as Sources.

spec-B: both fail S1, for compound Then items. Each passes S2, S4, and S5.

Quality differences:

- spec-A-q is ready to file as written. spec-A-p would need its fields rebuilt and its Verify
  commands rewritten before filing.
- spec-B-q handles retired and moved behavior more explicitly, and it fixes the baseline by digest
  instead of a future `BASE`.
- spec-B-p's harness covers the dash and CI legs more fully (AC-009), and it keeps the cross-gate
  ordering change as a declared non-goal.
- Lengths are close (spec-A 112 against 113 + 84; spec-B 288 against 252).

Verdict: q is better. It fixes all three spec-A rule failures and regresses on no rule.

---

## audit-A-p

Main artifact `AUDIT-corpus-repo-gates.md`, 145 lines. Probes:
`AUDIT-corpus-repo-gates-probes/`, with `probe-output.txt` (24 lines), `bin/`, and `fixtures/`.

Spot-checks:

- `lint-accepted-adrs.sh:7-10` skips the history check on an empty base. Holds.
- `:5-6`: `EXPECTED_COUNT=187` and the digest. Holds.
- `method-gates.yml:3-6` (triggers) and `:18-19` (env). Hold.
- `gh api .../branches/main/protection` returns `Branch not protected (HTTP 404)`, and rulesets
  return `[]`. Holds.
- `lint-artifact-skills.sh:73` strips `[?#]`, and `:210-217` checks containment only. Holds.

| Rule | Grade | Reason and evidence |
| --- | --- | --- |
| E1 | Pass | Every spot-checked anchor holds. Probe results are receipted in `probe-output.txt`. |
| E2 | Pass | It lists unverified areas (`:138-145`) and flags a discarded probe run (`:145`). Minor: F-002's failure mode (`:76`) is stated without a note that it was not probed. |
| E3 | Pass | "Scope question for the human: none" (`:26`). It makes no decision. |
| E4 | Pass | 145 lines. Compact. |
| A1 | Pass | Findings state only evidence, failure, firing condition, and radius. No fixes. |
| A2 | Pass | The whole-scope negative ("no `docs/` path other than `docs/adrs`") prints its command: `grep -nE 'docs/\|README\|sources\.md\|\.github\|scripts/' scripts/*.sh .github/workflows/*.yml` (`:37`). |
| A3 | Pass | F-001 to F-007 each give Evidence, Failure mode, Firing condition, Blast radius, and a Major or Minor grade (`:57-136`). |
| A4 | Pass | The Unverified section names each boundary and what evidence is missing (`:138-145`). |
| A5 | Pass | The Map has a "What it takes on faith" column, which names what enforces each assumption or that nothing does (`:30-35`). An example is "That a red run stops the change. Branch protection API: `Branch not protected`". |

## audit-A-q

Main artifact `AUDIT-repository-gates.md`, 241 lines. Sidecars: `AUDIT-repository-gates.evidence.md`,
161 lines; `probe/` trees.

Spot-checks:

- `AGENTS.md:44-46` for `cmdCheck` (`:36`) fails: at HEAD, blob `016d13b`, the table is at lines
  41-43.
- `AGENTS.md:48` for "Work from `main`; commit and push directly" (`:37`, `:119`) fails: the file is
  45 lines long, and the quote is at line 45.
- `AGENTS.md:7` for "never be rewritten" (`:145`) fails: the text is at line 8.
- `AGENTS.md:9-10`, `:26-27`, and `:3-4` hold.
- Script anchors (`lint-accepted-adrs.sh:5-6`, `:9-29`, `:31-32`; `lint-artifact-skills.sh:17-22`,
  `:256-260`) hold.
- E3 for branch protection and rulesets holds.

| Rule | Grade | Reason and evidence |
| --- | --- | --- |
| E1 | Fail | Three `AGENTS.md` anchors point at the wrong lines, and `AGENTS.md:48` (`:37`, `:119`) points past the end of a 45-line file. The quoted text is still correct, and the script anchors hold. |
| E2 | Pass | Each risk records its "Basis: static reading ... No run probed this" (`:146`, `:215`), and the Unknowns are explicit. |
| E3 | Pass | A scope question (HEAD or working tree) is recorded with options and the recommendation applied (`:24-28`). |
| E4 | Pass | 241 + 161 lines. The Map (`:32-112`) restates almost every check the script makes. That is defensible for a map, but it is about 60 lines heavier than the task needs. |
| A1 | Pass | No fixes or target states. "Delivery control as observed" (`:128`) is descriptive. |
| A2 | Fail | The load-bearing negative "Ungated content ... rests on the whole-scope sweep in E9" (`:102-106`) has no command in E9 (`evidence.md:154-160`). E9 describes the search terms and the hits but prints no command. Borderline: the hooks negative (`evidence.md:56-57`) does show its commands. |
| A3 | Pass | Eight risks, each with evidence, failure mode, firing condition, blast radius, and a grade (`:114-223`). |
| A4 | Pass | Unknowns give the search boundary and missing evidence (`:225-241`). |
| A5 | Pass | Implicit but present: "Nothing at the push boundary enforces it" (`:128-129`); "No gate checks `[[KEY]]` citation keys" (`:104-105`); the script "ignores the argument and derives `ROOT`" (`:58-59`). There is no dedicated view of assumptions. |

## audit-B-p

Main artifact `AUDIT-issue-file-route.md`, 291 lines, no sidecars.

Spot-checks:

- `AGENTS.md:465`, "validation against **open** milestones rejects it before filing", holds.
- `prValidationScope.ts:27-37` (`REVIEW_TOOLING` including `fileTrackerIssue`) holds.
- `validation.yml:562-595`: the `tooling-unit` job and its exclusion list hold.
- `oxlint.craft-baseline.mjs:36` and `:878` hold.
- Minor drift: `AGENTS.md:461`, the sub-issue sentence, is at 462.

| Rule | Grade | Reason and evidence |
| --- | --- | --- |
| E1 | Pass | Spot-checks hold. One off-by-one sits beside a paraphrase. |
| E2 | Pass | "Nothing was executed" (`:277-279`). Each faith dependency is marked as not enforced in the repository. |
| E3 | Pass | Records the scope question with a recommendation (`:21-23`). |
| E4 | Pass | 291 lines. The live tracker metadata (`:190-207`) is a dated snapshot that the map's purpose justifies. |
| A1 | Pass | No prescriptions. |
| A2 | Pass | The whole-tree command and result are printed (`:36-46`). So is the `describe` and `it` grep behind "No test found" (`:250-252`). |
| A3 | Pass | Mode is map only, with no Findings section (`:16`). The faith dependencies are descriptive, not graded. |
| A4 | Pass | The Unverified section gives the boundary and the missing evidence (`:275-291`). |
| A5 | Pass | The section "Faith dependencies: what the route assumes and what enforces it" (`:209-228`). |

## audit-B-q

Main artifact `AUDIT-issue-file-route.md`, 270 lines. Sidecar: `AUDIT-issue-file-route.vitest.txt`,
56 lines.

Spot-checks:

- `healthGatesWorkflow.spec.ts:3177-3185`, which throws "repository metadata is machine-read and
  must not be exempt", holds.
- `prValidationScope.ts:36` and `validation.yml:562-565` hold.
- The exclusions at `:595-596` (five specs, none of them `fileTrackerIssue`) hold.
- `oxlint.craft-baseline.mjs:36` and `:878` hold.
- The vitest receipt shows 47/47.

| Rule | Grade | Reason and evidence |
| --- | --- | --- |
| E1 | Pass | Spot-checks hold. The test run is receipted. |
| E2 | Pass | It says the dry run was refused by the permission classifier and that the behavior is inferred (`:246-250`). gh behaviors are marked "Unconfirmed". |
| E3 | Pass | Records the scope question with options and costs (`:22-28`). |
| E4 | Pass | 270 + 56 lines. |
| A1 | Pass | No prescriptions. |
| A2 | Pass | It prints the whole-scope `git ls-files \| xargs grep` command and its result (`:185-191`), the `trustedGithubWriteBootstrap.ts` grep with exit 1 (`:39-40`), and the `\.name` grep (`:74-75`). |
| A3 | Pass | "Map only; risk was not requested and is not assessed" (`:11`). |
| A4 | Pass | Unknowns give the boundary and missing evidence (`:244-270`). |
| A5 | Pass | "Validation located elsewhere ... neither is enforced in this file" (`:126-135`), plus the Unconfirmed gh assumptions (`:251-260`). Less explicit than p. |

### audit: p versus q

Rules where the variants differ (all on audit-A):

- E1: p Pass, q Fail. q's `AGENTS.md` line anchors are three lines off, and `AGENTS.md:48` points
  past the end of the file.
- A2: p Pass, q Fail. q's key "docs/ is ungated" negative rests on a sweep whose command is not
  printed. p prints its grep. This one is borderline.

audit-B: no rule difference.

Quality differences:

- audit-A-q found more: eight risks against seven, including the untracked-ADR blind spot, the
  mutable `checkout@v4` tag, and the fail-open README provenance check. It also labels static-only
  bases, which p does not.
- audit-A-p proved more by running: an `exit 0`-weakened gate (F-007), and an em-dash range miss
  (F-006). It is shorter (145 lines against 241 + 161).
- audit-B-q ran the test suite and found more for a validation change. It notes that `composeIssueTitle`
  uses the raw scope, that `name` is parsed but never read, that vitest collects nine
  `.agents/artifacts` copies without `--exclude`, and that `healthGatesWorkflow` guards
  `ISSUE_TEMPLATE`. audit-B-p is equally precise, with a stronger assumptions section and live
  metadata.

Verdict: on audit-A, p is better because q regresses on E1 and A2. audit-B is a tie, with q slightly
more useful. Overall p is better on rule compliance.

---

## research-A-p

Main artifact `RESEARCH-gate-language.md`, 215 lines. Sidecar: `RESEARCH-gate-language-receipt.md`,
203 lines.

Spot-checks:

- Commit `e8caa16` deleted the 159-line `scripts/test-lint-artifact-skills.sh`. Holds.
- `9cdcea0` is the `cp -R` adoption-command fix, not a gate fix. Holds.
- There are 36 `[[:class:]]` tokens in HEAD `lint-artifact-skills.sh`. Holds.
- `-mindepth` and `-maxdepth` are present. Holds.
- 33, 50, and 288 lines at HEAD. Holds.

| Rule | Grade | Reason and evidence |
| --- | --- | --- |
| E1 | Pass | Spot-checks hold. Every finding points to a receipt E-n. |
| E2 | Pass | Downgrades and `[unconfirmed]` labels are used (R-005, R-007). Gaps are listed (`:42-49`). |
| E3 | Pass | "The decision stays with the owner" (`:215`). The question for the human is recorded with a recommendation (`:191-193`). |
| E4 | Pass | 215 + 203 lines. |
| R1 | Pass | Decision, scope, horizon, and reversing evidence in both directions (`:8-24`). The Options table carries a "Main risk" column (`:177-181`). |
| R2 | Pass | Sources S1-S8 are dated "fetched 2026-11-05", with quoted passages (`receipt.md:182-203`). The primary specs, PEP, and vendor readmes are competent sources. |
| R3 | Pass | Each finding has a Confidence with its downgrades. The runner-images README (24.04) and the run logs (26.04) are shown side by side (R-004, `:79-91`). |
| R4 | Pass | The recommendation cites R-002 to R-010 and leaves the decision to the owner (`:195-215`). |

## research-A-q

Main artifact `RESEARCH-gate-language.md`, 277 lines. Sidecar: `RESEARCH-gate-language.receipts.md`,
176 lines.

Spot-checks:

- The awk sites at HEAD lines 32, 63, 74, 78, 120, 142, 171, and 186 hold.
- `uutils/coreutils#15023` (closed, created 2026-10-02) contains the quoted "Ubuntu 26.04 images
  ship uutils as the system coreutils (`coreutils-from-uutils` ...". Holds.
- `EXPECTED_COUNT` and `EXPECTED_DIGEST` at `lint-accepted-adrs.sh:5-6` hold.

| Rule | Grade | Reason and evidence |
| --- | --- | --- |
| E1 | Pass | Spot-checks hold. |
| E2 | Pass | R-009 states that the one-liner ran on 3.15.2, not 3.9.6 (`:196`). R-002 marks 32 of the 35 failures `Unverified`. Minor overstatement: Option B "Implementation churn disappears" (`:230`). |
| E3 | Pass | Open questions carry recommended answers. "The decision stays with the owner" (`:277`). |
| E4 | Pass | 277 + 176 lines. The Sources table earns its space. |
| R1 | Pass | Decision, horizon, out of scope, and reversal conditions in both directions (`:8-26`). The options list what each carries forward (`:215-242`). |
| R2 | Pass | The Sources table gives provenance, date or version, method, and interest (`:56-66`). Findings quote the sources (R-006, R-008). |
| R3 | Pass | Each finding is marked Verified or Unverified, with a weakness. Vendor intent and observed reality are shown side by side (R-006 weakness, `:150-151`). |
| R4 | Pass | The recommendation cites R-001 to R-010. The decision stays with the owner (`:255-277`). |

### research-A: p versus q

No rule difference.

Quality differences:

- q is more accurate about the runner. R-008 gives evidence that Ubuntu 26.04 swapped GNU coreutils
  for uutils. p's R-007 and R-008 assume "Ubuntu GNU/mawk userland" (`p:145`), though p does mark the
  `sha256sum` point unconfirmed.
- q found two real latent defects by probing: the whitespace-name silent pass in the seal (R-003)
  and a shell-dependent exit code on a missing link directory (R-004).
- p found the deleted self-test and the Python `[[:space:]]` translation trap (R-009). It also ran
  the seal prototype on 3.9.6 itself.
- p is shorter (418 lines against 453 in total).

Verdict: a near tie on rules. q is somewhat more useful and accurate.

## research-B-p

Main artifact `RESEARCH-sourdaw-ffmpeg-posture.md`, 433 lines. Sidecar: `.receipts.md`, 138 lines.

Spot-checks:

- Electron `build/args/all.gn:59-60` (`ffmpeg_branding = "Chrome"`, `proprietary_codecs = true`)
  holds.
- `release.gn:7` "LGPL requirement ..." and `:9` `is_component_ffmpeg = true` hold.
- FFmpeg `configure:2005`, the `EXTERNAL_LIBRARY_GPL_LIST`, with `libx264` and `libx265` at 2014
  and 2015, holds.

| Rule | Grade | Reason and evidence |
| --- | --- | --- |
| E1 | Pass | Spot-checks hold. The receipts state that web quotes came through a summarizer (`receipts.md:4-6`). |
| E2 | Pass | It says no product behavior was exercised (`:61-62`). x264.org is marked unreachable, and absence findings `[unconfirmed]` (R-015). |
| E3 | Pass | Legal and product-claim questions go to the owner with options (Q-1, Q-2, `:368-389`). "The decision stays with the owner" (`:433`). |
| E4 | Pass | 433 + 138 lines. It is long: 22 findings, several low-weight (R-019 DeckLink, R-022 search-summary only). This is the longest research artifact, but not restated boilerplate. |
| R1 | Pass | Decision, segment, workload, horizon, and three reversal conditions (`:12-35`). The Options table carries counter-evidence for each option (`:355-361`). |
| R2 | Pass | Licence texts, configure, Electron source, and vendor pages, with quotes (R-001, R-002, R-009). The receipt table gives a date on the page or "none" or "not captured" for several pages (`receipts.md:107-130`). |
| R3 | Pass | Each finding is marked Observation, Source claim, or Inference, with a Confidence. The gyan.dev self-contradiction is "reported as found" (R-006). |
| R4 | Pass | The recommendation cites R-001 to R-021 and names its weakest links (`:429-433`). |

## research-B-q

Main artifact `RESEARCH-sourdaw-ffmpeg-video-posture.md`, 303 lines. Sidecars: `.receipts.md`,
129 lines; `.avfoundation-probe.swift`, 32 lines.

Spot-checks:

- FFmpeg `configure:3613` `h264_mf_encoder_deps="mediafoundation"` and `:3789`
  `prores_videotoolbox_encoder_deps="pthreads"` hold.
- Electron `release.gn` and `all.gn` hold, as for p.

| Rule | Grade | Reason and evidence |
| --- | --- | --- |
| E1 | Pass | Spot-checks hold. Primary documents are hashed (`receipts.md:9-17`). The AVFoundation exercise output is untouched (`receipts.md:102-107`). |
| E2 | Pass | Media Foundation is "documented, not exercised" (`:62`). Legal readings are marked Unverified (R-007, R-009, R-012, R-017). |
| E3 | Pass | O-1 is marked "Spend or legal exposure, so the owner decides" (`:252`). "The decision stays with the owner" (`:303`). |
| E4 | Pass | 303 + 129 + 32 lines. |
| R1 | Pass | Decision, scope, horizon, and reversal conditions (`:8-41`). |
| R2 | Pass | Licence texts are fetched and hashed. The Apple page is dated (published 2026-08-09) and Via LA updated 2026-09-28, with quotes inline (R-008, R-011, R-013). |
| R3 | Pass | Each finding is Verified or Unverified and names its settling check. The 2016 HEVC waiver and the current rate page are shown side by side (R-010). |
| R4 | Pass | The recommendation cites R-001 to R-017 and the O-n questions, and leaves the decision to the owner. |

### research-B: p versus q

No rule difference.

Quality differences:

- q ran an AVFoundation encode and decode exercise for ProRes, H.264, and HEVC (E-4). It read
  Chromium's actual FFmpeg `config.h`, which shows zero encoders and `CONFIG_PRORES_DECODER 0`. p
  inferred the bundled codecs from the gn flags alone.
- q hashes its fetched primary texts. q is about 30% shorter in the main artifact.
- p covers more ground: AAC royalties, Windows N, OpenH264 profiles, and LGPL §11. Its options include
  an explicit hybrid (e).

Verdict: q is better. Its evidence is stronger and it is more concise, with no rule regressions.

---

## campaign-A-p

Main artifact `CAMPAIGN-resolve-open-research-issues.md`, 178 lines, no sidecars.

Spot-checks:

- `gh issue list` shows exactly seven open `research(` issues: #3645, #3708, #4608, #4677, #4682,
  #4723, and #4737. Their priorities match the artifact, and #4682 carries `status:active`.
- ADR files 0012, 0030, 0035, 0037, and 0044 exist.
- Ruleset 20938734 is active with `bypass_actors: []`.
- Sourdaw's `LICENSE` and `package.json` are Apache-2.0.

| Rule | Grade | Reason and evidence |
| --- | --- | --- |
| E1 | Pass | Spot-checks hold. |
| E2 | Pass | The trust boundary is stated plainly: "No claim that a worker cannot approve its own work holds" (`:118-120`). |
| E3 | Pass | DG-001 to DG-003 ratification is left to the owner (S-4, `:159-162`). Clause 3 of the contract says agent acceptance does not satisfy it (`:41-43`). |
| E4 | Pass | 178 lines. |
| K1 | Fail | It points at one ledger, but the main artifact copies mutable state: seven priority labels (`:78-91`, for example "#3708 (P1)") and the #4682 claim and lane snapshot "carries `status:active`, but no lane or PR for it was found" (`:176-178`). |
| K2 | Pass | Every row has an owner, a strength from the three-term vocabulary, a mechanism, and failure behavior (`:103-116`). |
| K3 | Pass | One live-checkable end state (`gh issue view` state plus a decision record), with the evidence named. Constraints are bound explicitly (`:27-51`). |
| K4 | Pass | "Never seize an active or unknown lane or issue claim. Never take over another owner's branch" (`:139`). Self-acceptance is excluded (`:41-43`). "`pnpm deliver` binds the approval to the current head" (`:114`). |
| K5 | Pass | `status: draft`, because the ledger is unfiled (`:4-5`, L-1). |

## campaign-A-q

Main artifact `CAMPAIGN-resolve-sourdaw-research-issues.md`, 230 lines. Sidecars: `.evidence.md`,
92 lines; `.ledger-draft.md`, 120 lines.

Spot-checks:

- The evidence table (`evidence.md:20-28`) matches live labels.
- Ruleset 20938734 holds.
- `#4737` body line 43 reads "Accept, amend or reject the recovered historical draft DG-001–DG-003".
  Line 7 reads "this issue keeps the question open for the owner".

| Rule | Grade | Reason and evidence |
| --- | --- | --- |
| E1 | Pass | Spot-checks hold. |
| E2 | Pass | The evidence sidecar is labelled a snapshot. Unread items are listed (`evidence.md:87-92`). |
| E3 | Fail | The #4737 workstream reads "Write DG-001 to DG-003 as accepted engineering gates" (`:127`), and S5 covers only the voice-budget clause (`:218`). The issue itself leaves ratification of those gates to the owner (#4737 body lines 7 and 43). |
| E4 | Pass | 230 + 92 + 120 lines. The ledger draft repeats the Authorities table and Stops. It is the filing payload, but it is the heaviest campaign output. |
| K1 | Fail | It points at one ledger and keeps priorities out ("Priority follows child `priority:` labels", `:163-164`). But the main artifact still copies lane occupancy, "Live lanes already exceed the cap" (`:67`), and claim state, "has carried `status:active` since 2026-10-11, without a lane, PR, or branch commits" (`:223-224`). |
| K2 | Fail | It declares the three-term vocabulary (`:57`), then uses "Deterministic, hosted" for Verification (`:69`) and Merge (`:72`). |
| K3 | Pass | Six live-checkable conditions (`:36-53`). Constraints are not explicitly bound into the contract, apart from clause 4's licence rule. |
| K4 | Fail | "Never seize an active or unknown lane" is present (`:161`), and merge is bound to the current head (`:72`). It never forbids taking over another owner's branch. Cleanup limits only deletion (`:73`). |
| K5 | Pass | `status: draft`, ledger unfiled (`:4-5`). |

## campaign-B-p

Main artifact `CAMPAIGN-native-specs.md`, 175 lines. Sidecars: `.evidence.md`, 51 lines;
`.ledger.json`, 15 lines.

Spot-checks:

- #4717 is P3, `status:active`, milestone "Electron shell & native audio backend". Holds.
- #4696 is P1. #4694 is P3, "Native plugin hosting". Holds.
- PR #5516 is CLOSED. PR #5761 merged 2026-10-28 from `fix/4717/browser-scala-delivery`. Holds.
- `crates/sourdaw-native/AGENTS.md:78` forbids MTS-ESP registration. Holds.
- `crates/daw-io/src` contains only `audio_decode.rs` and `lib.rs`. Holds.

| Rule | Grade | Reason and evidence |
| --- | --- | --- |
| E1 | Pass | Spot-checks hold. |
| E2 | Pass | It states that no trusted write script was run and that this is why the status is draft (`:119-121`). |
| E3 | Pass | Legal, spend, and manual acceptance go to the owner (Stops 1-4). Engineering ADRs stay with the orchestrator, consistent with owner authority. |
| E4 | Pass | 175 + 51 + 15 lines. The JSON repeats the campaign text as the filing payload. |
| K1 | Pass | Mutable state is confined to the dated evidence sidecar. The main artifact keeps no labels, counts, or PR state. Minor: the workstream status word "dependency-ready" (`:89`). |
| K2 | Pass | Every row has an owner, a strength, a mechanism, and failure behavior. Mixed strengths are split by aspect within the vocabulary (`:104-117`). |
| K3 | Pass | Four conditions, each "shown by output the working session produces", including focused guard commands and constraint preservation (`:34-58`). |
| K4 | Pass | "Foreign lanes, branches, and pull requests are read-only" (`:76`). "Never seize an active or unknown lane" (`:132-133`). "No owner accepts its own work", bound to the expected head (`:139-140`). "Agents never record it" for manual acceptance (`:55`). Note: loop step 3 clears a stale `status:active` without asking the owner (`:135`). |
| K5 | Pass | `status: draft`, ledger pending (`:4-5`). |

## campaign-B-q

Main artifact `CAMPAIGN-native-specs.md`, 193 lines. Sidecar: `.evidence-2026-11-05.md`, 77 lines.

Spot-checks:

- `parseScl.ts:13-15` `isNumberArray` checks only finiteness. Holds.
- `crates/daw-core/src/tuning/scala.rs` defines `TuningParseError`. Holds.
- #4717 Verify lines name `--package daw-io` (body lines 24 and 29). Holds.
- #5762 is an open issue with the quoted title. Holds.

| Rule | Grade | Reason and evidence |
| --- | --- | --- |
| E1 | Pass | Spot-checks hold. |
| E2 | Pass | The evidence receipt is dated and says to re-read before acting (`evidence.md:3-4`). The trust boundary is stated (`:72-76`). |
| E3 | Pass | S1-S3 go to the owner with options and costs. Engineering choices are labelled recommendations. |
| E4 | Pass | 193 + 77 lines. |
| K1 | Fail | It points at one ledger ("Live status belongs to the ledger", `:99`), but the loop copies priority labels: "(#4696 is P1; #4717 and #4694 are P3)" (`:151`). It files no ledger payload; `ledger: unfiled` (`:5`). |
| K2 | Fail | It uses "Hosted deterministic" for Broad verification (`:64`) and "Hosted deterministic plus deterministic local" for Merge (`:67`). Neither is a vocabulary term. |
| K3 | Pass | One end state, checked by a fresh reconcile, with tests run inside `Gate` and a mutation probe (`:35-53`). Constraint preservation is bound only for the MTS-ESP and route-schema ADRs, not for ADR 0012 parity. |
| K4 | Pass | "Foreign or unknown lanes are never touched" (`:61`). Foreign PRs: "Never edit them" (`:90`). Merge requires approval of "that exact head" (`:67`). Acceptance is owner-only (`:70`). Weaker than p: manual results may be "recorded by whoever ran it" (`:43-44`). |
| K5 | Pass | `status: draft` (`:4`). |

### campaign: p versus q

Rules where the variants differ:

- campaign-A, E3: p Pass, q Fail. q's campaign accepts DG-001 to DG-003 itself; p routes their
  ratification to the owner.
- campaign-A, K2: p Pass, q Fail. q uses "Deterministic, hosted".
- campaign-A, K4: p Pass, q Fail. q drops the ban on taking over another owner's branch.
- campaign-B, K1: p Pass, q Fail. q's loop copies priority labels.
- campaign-B, K2: p Pass, q Fail. q uses "Hosted deterministic".

campaign-A K1 fails on both: p copies priorities and claim state, q copies lane occupancy and claim
state.

Quality differences:

- q's trust-boundary reasoning is more careful in substance. It argues why GitHub-hosted checks are
  not isolated from workers who share the keyring. But it expresses that by inventing a strength
  term instead of using the vocabulary.
- campaign-B-q's workstreams are more actionable. It found the `--package daw-io` command drift, the
  stale #4717 and #4696 bodies, and foreign PRs #5633, #5657, and #5381 that overlap its write set.
- campaign-B-p ships a ready filing payload (`.ledger.json`), and its contract is stricter on agent
  acceptance.
- campaign-A-q adds a ledger draft, about 120 lines that largely repeat the campaign.

Verdict: p is better on both campaign tasks. q regresses on K2 twice, and on E3, K4, and K1 once each.
