---
type: research
id: RESEARCH-gate-language
---

# Repository gates: keep POSIX sh plus awk, or port to Python 3 standard library

## Question and scope

**Decision.** Should the gates in `/Volumes/Development/corpus/scripts/` stay in POSIX `sh` plus
`awk`, or move to Python 3 using only the standard library? The gates are `lint-all.sh`,
`lint-accepted-adrs.sh`, and `lint-artifact-skills.sh`, 371 lines in total at `ae6d2e8`. They run locally on
macOS and in GitHub Actions on `ubuntu-latest`, through `.github/workflows/method-gates.yml`.

**Horizon.** The current gate set and its likely growth over the next release cycle of both
platforms. That covers the macOS 27 and Xcode 27 line and `ubuntu-latest` = Ubuntu 26.04.

**Out of scope.** Any change to what the gates enforce. Other languages, such as Node, Rust, or Go.
Third-party Python packages.

**Evidence that would reverse the answer.**

- Toward porting: a recorded case where the same commit gives different gate results on macOS and
  `ubuntu-latest`, or a gate defect caused by shell idiom that reaches a real artifact.
- Toward keeping: Python 3 missing or unusably old on either platform, or a port that cannot
  reproduce the frozen ADR seal digest without re-sealing.

## Method and coverage

- Read all three scripts and the workflow at `ae6d2e8`.
- Ran the gates locally on macOS 27.2. Read the most recent CI log on `ubuntu-latest`.
- Pulled the CI conclusion history (101 runs) and replayed three sampled failures on macOS.
- Ran mutation exercises in a scratch clone, under `sh` (bash 3.2 in POSIX mode) and `dash`.
- Reproduced the ADR seal digest with a Python standard-library one-liner.
- Read first-party platform sources:
  - The GitHub runner-image manifest.
  - Launchpad package data.
  - Apple release notes.
  - PEP 596.
  - The uutils maintainers' own issue tracker.

The commands and untouched outputs are in [the evidence receipts](RESEARCH-gate-language.receipts.md),
cited below as E-n.

**Coverage gaps.**

- No exercise ran on an actual Ubuntu host. `dash` on macOS stands in for the Ubuntu `/bin/sh`,
  but the BSD tools around it stayed. mawk, GNU grep, GNU sed, and uutils were not exercised
  directly. The only Ubuntu evidence is CI passing at HEAD.
- CI logs older than 90 days return HTTP 410, so 32 of the 35 historical failures could not be
  diagnosed.
- By trial rule, `docs/` was not read. Any ADR that already governs the gate language is unknown.

### Sources

| Key | Provenance | Date / version | Method | Observation or inference | Interest |
| --- | --- | --- | --- | --- | --- |
| S-LOCAL | Exercises on this host (E-1, E-2, E-5, E-6) | 2026-11-05; macOS 27.2, Xcode 27.2 | Recorded runs, n=1 host | Observation | None |
| S-CI | GitHub Actions run 41934540124 log (E-3) | 2026-11-04; image ubuntu-26.04 20261101.186.1 | Recorded run, n=1 | Observation | None |
| S-CIHIST | `gh run list` / jobs API (E-4) | 101 runs, 2026-06-27 to 2026-11-04 | Full listing; 3 failures replayed | Observation | None |
| S-RUNNER | `actions/runner-images` `images/ubuntu/Ubuntu2604-Readme.md` | Last commit 2026-10-28; image 20261026.180.1 | Generated manifest of installed software | Observation (vendor-generated) | GitHub describes its own product; low interest in misstating versions |
| S-LP | Launchpad API, `ubuntu/resolute/amd64` published binaries (E-7) | Fetched 2026-11-05 | Archive metadata | Observation | Canonical, first-party |
| S-UUTILS | `uutils/coreutils` issue 15023 | 2026-10-02, closed | Maintainer report on their own CI | Observation | Maintainers of the replacement; no incentive to overstate its reach |
| S-GBIF | `gbif/ipt` issue 3060, citing Launchpad bug 2155137 | 2026-06-03 | Downstream user report, n=1 workload | Observation | Independent user |
| S-APPLE | Apple macOS 10.15 and 12.3 release notes (JSON form of developer.apple.com) | 2019, 2022 | Vendor release notes | Observation of policy; forward statement is intent | First-party |
| S-PEP596 | PEP 596, Python 3.9 release schedule | Final status as of 2025-10-31 | Release-manager record | Observation | First-party |

## Findings

**R-001. The current gates already give the same result on both platforms at HEAD.**

- Evidence:
  - S-CI shows `lint-all: OK` on `Image: ubuntu-26.04`. The gate step took about 0.55 s (E-3).
  - S-LOCAL at committed `ae6d2e8` shows `lint-accepted-adrs: OK` (E-4) and
    `lint-artifact-skills: OK` (E-2).
  - The full local run took 0.655 s.
- Outcome: `Verified` (two independent observations on different platforms).
- Weakness: one commit, and the clean path only.
- Relevance: today there is no observed cross-platform divergence to fix.

**R-002. The sampled historical CI failures were content drift, not platform divergence.**

- Evidence:
  - S-CIHIST lists 35 failures, all between 2026-06-27 and 2026-08-03, and none since.
  - The three most recent failed in step `Accepted ADR history`.
  - Replayed on macOS, all three fail identically. For example:
    `accepted ADR set drift: expected 165 files, found 166` (E-4).
  - A commit-message search of gate history found no portability fix (E-4).
- Outcome:
  - `Verified` for the three-run sample.
  - The cause of the other 32 is `Unverified`, because their logs are gone (HTTP 410).
    Settling it would mean replaying each failed head SHA on macOS and comparing against its
    failed step name from the jobs API.
- Weakness: small sample. The scripts back then were different, more numerous gate files.
- Relevance: the strongest reason to port, platform divergence, has no recorded instance.

**R-003. The sh seal has a latent silent-pass defect for whitespace in an ADR file name.**

- Evidence: S-LOCAL probe (E-5).
  - `xargs` splits `0999-a b.md`, and `shasum` reports `shasum: b.md: No such file or directory`.
  - The pipeline status is `awk`'s, so the gate still prints `lint-accepted-adrs: OK`. The file
    was hashed nowhere.
  - The same result under `sh` and under `dash`.
- Outcome: `Verified` by exercise. Reaching it in practice also needs `EXPECTED_COUNT` advanced.
- Weakness: today's prevalence is zero. Every ADR name matches `^[0-9]{4}-[a-z0-9-]+\.md$` (E-5).
- Relevance:
  - This is a shell-idiom defect class (word splitting, pipeline status) that a Python
    `subprocess`/`hashlib` gate would not have.
  - It can also be fixed in sh with a few lines: reject any `docs/adrs/*.md` name outside the
    strict pattern before hashing.

**R-004. In the sh gate, a missing link target aborts with an unlabelled error and a shell-dependent exit code.**

- Evidence: S-LOCAL (E-5). A skill link `./nope/a.md` produces:
  - Under `sh`: rc 1, `cd: [...]/./nope: No such file or directory`.
  - Under `dash`: rc 2, `cd: can't cd to [...]/./nope`.
- Labelled checks behaved identically under both shells: stray payload file and escaping link,
  both rc 1 with the same message.
- Outcome: `Verified` by exercise.
- Weakness: the gate still fails closed. Only the message and exit code differ.
- Relevance: a small platform difference that already exists. It does not decide the question,
  and an explicit `|| { echo ...; exit 1; }` fixes it in sh.

**R-005. Python 3 is present on both platforms with no new install beyond what git already needs.**

- macOS evidence: S-LOCAL (E-1).
  - `/usr/bin/python3` and `/usr/bin/git` are the same 200560-byte binary with 78 hard links.
  - `xcrun` resolves both into `/Applications/Xcode.app/Contents/Developer/usr/bin/`.
  - The gates already need git, so Python comes from the same developer-tools install.
- Ubuntu evidence:
  - S-RUNNER lists "Python 3.14.4" under Language and Runtime. It also lists
    "Python 3.11.17 … 3.15.1" in the tool cache.
  - S-LP gives `python3 3.14.3-0ubuntu2 IMPORTANT` for resolute.
- Outcome: `Verified` (S-RUNNER and S-LP are different publishers with different data; macOS by
  exercise).
- Weakness:
  - The macOS result was observed on a host with full Xcode, not on Command Line Tools alone.
  - Minimal Ubuntu containers may lack `python3` (priority `important`, not `required`). That does
    not affect the full runner VM.
- Relevance: it removes the main reason to keep sh, which is "no runtime dependency".

**R-006. On stock macOS the Python floor is 3.9.6, which reached end of life on 2025-10-31.**

- Evidence:
  - S-LOCAL: `/usr/bin/python3 --version` gives `Python 3.9.6` with Xcode 27.2.
  - S-PEP596: "As of 2025-10-31, 3.9 has reached the end-of-life phase".
  - S-APPLE (10.15): "Future versions of macOS won’t include scripting language runtimes by
    default, and might require you to install additional packages."
- Outcome: `Verified`.
- Weakness: the Apple statement is intent from 2019 and has not come true for python3 as of
  macOS 27.2.
- Relevance:
  - A port must either target 3.9 syntax and stdlib, or require Homebrew or python.org Python
    and add an install step.
  - Ubuntu provides 3.14, so CI alone would not catch 3.10+ syntax that breaks on stock macOS.
    A port would need `actions/setup-python` pinned to 3.9, or a macOS CI job.

**R-007. The "sh plus awk" gate already depends on Perl and on platform-varying tool implementations.**

- Evidence:
  - S-LOCAL: `/usr/bin/shasum` is `#!/usr/bin/perl` (Perl 5.34.1).
  - The scripts also call `grep`, `sed`, `find`, `sort`, `tr`, `wc`, `xargs`, `basename`,
    `dirname`, and `git`.
  - macOS uses bash 3.2 as `sh` and `awk version 20200816`.
  - Ubuntu 26.04 uses Dash 0.5.12 (S-RUNNER, S-LP `REQUIRED`) and Perl 5.40.1 (S-RUNNER).
  - Ubuntu's `shasum` comes from `perl`, which is `OPTIONAL` there (S-LP).
- Outcome: `Verified`.
- Which `awk` the runner uses is `Unverified`:
  - `mawk` is `REQUIRED` and `gawk` is `OPTIONAL` (S-LP). S-RUNNER lists neither.
  - Settle it with `readlink -f "$(command -v awk)"; awk -W version` in a workflow run.
- Relevance: the sh option already carries a scripting runtime and two or three implementations of
  each text tool. The real comparison is one Python implementation against that tool matrix, not
  "no dependencies" against "a dependency".

**R-008. The tools under the sh gates on `ubuntu-latest` changed implementation in 2026, with no repository-side pin.**

- Evidence:
  - S-UUTILS: "Ubuntu 26.04 images ship uutils as the system coreutils (`coreutils-from-uutils`,
    rust-coreutils 0.8.0 or 0.10.0 depending on the image)".
  - S-GBIF: "Ubuntu has swapped from GNU Coreutils to a reimplementation in Rust." The bug it
    cites, Launchpad 2155137, is `sort` hanging on a 1.7 GB file.
  - S-RUNNER announces that "`ubuntu-latest` label will use Ubuntu 26.04 in November 2026". S-CI
    confirms 26.04 is already in use.
- Outcome: `Verified` (uutils maintainers and an independent user).
- Weakness: indirect. The cited bug is far outside gate scale, and the gates pass on uutils at
  HEAD (R-001).
- Relevance: a standing source of platform churn under sh gates. A Python standard-library gate
  would depend only on `python3` and `git`.

**R-009. A standard-library port can reproduce the frozen ADR seal byte for byte.**

- Evidence: S-LOCAL (E-6). A `hashlib`/`subprocess`/`re` one-liner printed
  `187 d7a79f141bee818ab66d5e3c5f5779e1f89142cd15bdc24a55df0e21aa716474`. That equals
  `EXPECTED_COUNT` and `EXPECTED_DIGEST` in `lint-accepted-adrs.sh`.
- Outcome: `Verified` by exercise. The computation is deterministic.
- Weakness: it ran under Python 3.15.2, not 3.9.6. It used only calls that 3.9 also has.
- Relevance: porting needs no re-seal of accepted ADRs. That rules out one reversal condition.

**R-010. Port cost is bounded but not trivial, and it touches a repository contract.**

- Evidence:
  - 371 lines at `ae6d2e8`, with nine `awk` invocations, eight of them
    in the skill gate (E-8).
  - Python startup is 0.037 s for `/usr/bin/python3` (E-6). Performance does not decide this.
  - `CLAUDE.md`/`AGENTS.md` fixes `cmdCheck` as `sh scripts/lint-all.sh`, and `method-gates.yml`
    runs the same command.
- Outcome: `Verified` for size and the command surface. Whether an existing ADR fixes the gate
  language is `Unverified`, because `docs/adrs/` was out of bounds. Settle it by searching
  `docs/adrs/` for `POSIX`, `awk`, `shell`, and `Python`.
- Relevance: a port is one contract change across scripts, workflow, `cmdCheck`, and any ADR.
  Under the repository rule it must land as a unit.

## Options

**A. Keep sh plus awk, and harden two defects.**

- Reject non-kebab ADR names before hashing (R-003).
- Label the `cd` failure in link resolution (R-004).
- Cost: a few lines. No contract change.
- Carries forward:
  - The tool matrix (R-007).
  - The uutils churn (R-008).
  - The shell-idiom defect class (R-003).
- Supported by R-001 and R-002: no observed divergence.

**B. Port to Python 3.9-compatible standard library.**

- Supported by R-005, R-007, R-008, and R-009:
  - Python is available everywhere.
  - Implementation churn disappears.
  - The seal is portable.
- Cost:
  - A rewrite of about 370 lines with behavior-preserving verification. The mutation set in E-5 is the
    seed oracle.
  - A version floor to enforce in CI (R-006).
  - A contract change (R-010).

**C. Keep sh, add a macOS job to CI.**

- Turns R-007 and R-008 drift into a detected failure instead of a removed cause.
- Costs macOS runner minutes on every push.
- Does not address the R-003 defect class.

## Open questions

These would normally go to the human. No human was available, so each records a recommended answer.

1. **Is stock macOS without Homebrew Python a supported gate environment?**
   Recommended answer: yes. The gates already require developer tools for `git` (R-005). Any port
   must therefore run on `/usr/bin/python3` 3.9.6 (R-006).
2. **Does an accepted ADR already fix the gate language?**
   Recommended answer: unknown (R-010). Search `docs/adrs/` before acting. If one exists, a port
   needs a superseding ADR.

## Recommendation

**Choose Option A now: keep POSIX sh plus awk, and harden the two defects.**

- No platform divergence has been observed (R-001, and R-002 for the sample).
- The defects found are small and fixable in place (R-003, R-004).
- A port adds an end-of-life version floor that CI would not enforce by default (R-006). It also
  adds a contract change for no demonstrated failure (R-010).

**Move to Option B if any trigger occurs.**

- The same commit gives different gate results on macOS and `ubuntu-latest`.
- A shell-idiom defect reaches a real artifact.
- The gates take on structural parsing that the line-oriented `awk` programs cannot do soundly,
  such as nested YAML or Markdown structure.

R-005 and R-009 show that a port is feasible at any time without re-sealing.

**Test that would settle the residual uncertainty.** Run the E-5 mutation set plus the clean tree on
a `workflow_dispatch` matrix of `macos-latest` and `ubuntu-latest`, and print `awk -W version`. A
mismatch in any exit code or message beyond the known R-004 case favors Option B.

The decision stays with the owner.
