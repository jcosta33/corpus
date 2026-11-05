---
type: research
id: RESEARCH-gate-language
---

# Keep the Corpus repository gates in sh plus awk, or port them to Python 3 standard library

## Question and scope

- Decision: whether the gates in `jcosta33/corpus` stay as shell scripts with awk, or get
  rewritten in Python 3 using only the standard library.
- Gates in scope, at `ae6d2e8`:
  [lint-all.sh](../../../../../corpus/scripts/lint-all.sh),
  [lint-accepted-adrs.sh](../../../../../corpus/scripts/lint-accepted-adrs.sh),
  [lint-artifact-skills.sh](../../../../../corpus/scripts/lint-artifact-skills.sh), run by
  [method-gates.yml](../../../../../corpus/.github/workflows/method-gates.yml).
- Environments: local macOS (this host runs macOS 27.2, arm64) and GitHub Actions `ubuntu-latest`.
- Horizon: the next year of gate edits. That window includes the `ubuntu-latest` move to 26.04
  and further macOS releases.
- Evidence that would flip the answer to "port": a gate behaving differently because of
  BSD and GNU dialect differences, a planned gate that has to parse structure (YAML, nested Markdown)
  rather than match lines, or a Python floor that both environments provide without new installs.
- Evidence that would make the answer "keep": the gates already run correctly on both platforms,
  a port is likely to introduce errors, and the port gains nothing that a few small fixes can't get.

No scope question for the human was needed. The task names the options, the platforms, and the
files.

## Method and coverage

- Read the three scripts and the workflow, plus git history for `scripts/` and `.github/`.
- Ran the gates in a clean clone at HEAD, using `/bin/sh` (bash 3.2.57 in sh mode) and `/bin/dash`
  with macOS BSD awk 20200816. Timed the runs and injected 9 defects (fault injection).
- Read CI run history and runner-image logs with read-only `gh`.
- Wrote a standard-library prototype of the ADR seal and ran it on Python 3.9.6 (the Xcode one) and
  Python 3.15.2 (Homebrew).
- Fetched primary sources: runner-images readmes, Apple release notes, PEP 596, POSIX.1-2024
  `find`, and the Ubuntu `mawk` package page.
- Commands and untouched output are in the
  [evidence receipt](./RESEARCH-gate-language-receipt.md).

Not covered:

- The Ubuntu runner's awk (`mawk` or `gawk`) was not exercised against the defect probes. No local
  mawk, gawk, or container runtime exists, and the trial forbids pushing a probe branch.
- A Mac without Xcode or the Command Line Tools was not available.
- The causes of the 34 historical CI failures could not be recovered (logs return HTTP 410).
- No published, controlled comparison of defect rates in shell versus Python linters was found or
  used. Claims about maintainability below are labelled inference.

## Findings

### R-001. The gates are small, but most of the size is dialect-heavy text matching

- Observation: 371 lines in total, split 33 / 50 / 288. `lint-artifact-skills.sh` contains
  19 `grep`, 4 `sed`, 8 `awk`, and 9 `find` invocation sites, plus 36 POSIX bracket classes such as
  `[[:space:]]`. The seal uses `git`, `xargs`, `shasum`, and one `awk` (receipt E5).
- Confidence: High. Taken directly from the files.
- Relevance: a port is cheap for the seal and the range check. Almost all of the porting cost and
  risk is in the artifact-skills gate.

### R-002. Both macOS shells run the gates cleanly and fast

- Observation: at `ae6d2e8`, both gates print `OK` under `/bin/sh` and `/bin/dash`.
  `lint-all.sh` takes `real 0.52` seconds (receipt E2).
- Confidence: High for this host.
- Relevance: speed and local correctness give no reason to port.

### R-003. All 9 injected defects are caught on macOS

- Observation: 9 injected defects each exit `rc=1` with the intended message under both shells
  (receipt E3). They cover self-naming, a broken link, a link escape, ADR body drift, naming a
  sibling, a colon in the description, two forms of absolute source, and a fragment link.
- Confidence: Moderate. Downgrades:
  - The probes ran on macOS BSD awk only; the Ubuntu runner's awk was not exercised.
  - The extra-payload-file probe was not run.
- Relevance: the sh gates detect defects on at least one platform. Nothing tests them on the other.

### R-004. Clean runs passed on two Ubuntu releases, and `ubuntu-latest` moved underneath the workflow

- Observation: green runs used image `ubuntu-24.04` on 2026-08-19 and 2026-08-26, and image
  `ubuntu-26.04` on 2026-11-04. The workflow pins only `ubuntu-latest` (receipt E4).
- Source claim: the runner-images README still maps `ubuntu-latest` to 24.04 and describes the
  migration as gradual over 1-2 months (S1). The 26.04 readme announces the switch for
  November 2026 (S3).
- Confidence: High on the clean path. These are first-party run logs plus first-party image docs.
- Relevance:
  - The sh gates already survived one silent OS migration: bash 5.2 to 5.3, and dash builds
    `6ubuntu5` to `12ubuntu3`.
  - The runner's Python also moved during that migration, from 3.12.3 to 3.14.4 (S2, S3).
    Neither option avoids platform drift.

### R-005. No evidence that dialect differences have ever broken these gates

- Observation:
  - 34 of the last 100 runs failed, all dated 2026-08-03 or earlier.
  - Their logs return HTTP 410, and the annotations say only `Process completed with exit code 1.`
  - Searching commit messages for portability terms finds no gate fix. The one BSD/GNU fix
    (`9cdcea0`, `cp -r` versus `cp -R`) was in documented adoption commands, not in a gate
    (receipt E4).
- Confidence: Low. Downgrades:
  - The failure causes are `[unconfirmed]`.
  - Commit-message search is indirect evidence.
  - Absence of a fix does not prove absence of a bug.
- Relevance: there is no observed portability failure that a port would fix. This is weak support
  for keeping the scripts.

### R-006. On macOS, Python 3 comes from the same developer tools as `git`, at an end-of-life version

- Observation: `/usr/bin/python3` and `/usr/bin/git` are the same binary (78 hard links,
  200560 bytes). `xcrun` resolves both into the Xcode developer directory. The version there is
  Python 3.9.6 (receipt E1).
- Source claims:
  - Python 3.9 reached end of life on 2025-10-31 (S7).
  - Apple warned in 10.15 that scripting runtimes would stop shipping by default (S5), and removed
    Python 2.7 in 12.3 (S6).
- Inference: the gates already need `git`, so stdlib Python on macOS adds no new install. A port
  must still either target 3.9, which is end of life, or require a newer interpreter
  (Homebrew or similar), which is a new prerequisite. Across environments the floor spans
  3.9 to 3.14.
- Confidence: Moderate. Downgrades:
  - Single host.
  - What happens on a Mac without developer tools is `[unconfirmed]`.
- Relevance: Python's availability is not a blocker. Its version floor is a recurring cost the
  shell option does not have.

### R-007. The sh gates' one non-POSIX runtime dependency is Perl, and a native replacement exists

- Observation:
  - `shasum` is a Perl script (`#!/usr/bin/perl`), and Perl is still present on macOS 27.2.
  - `/sbin/sha256sum (Darwin) 1.0` exists and prints byte-identical `hash  path` lines
    (receipt E1, E8).
- Source claim: Apple put Perl in the same deprecation notice as Python in 10.15 (S5).
- Inference: GNU coreutils `sha256sum` on Ubuntu prints the same format. This was not run on the
  runner, so it is `[unconfirmed]` there.
- Confidence: Moderate.
- Relevance: the strongest platform-risk argument against sh, losing Perl, has a one-line fix and is
  not an argument for Python.

### R-008. The gates are "POSIX sh" in name only

- Source claim: POSIX.1-2024 `find` defines `-depth` but not `-mindepth` or `-maxdepth` (S8).
  `lint-artifact-skills.sh` uses both.
- Observation: the scripts also rely on `shasum`, `grep -o`, and `sed -E`.
- Inference: the real contract is "macOS BSD userland plus Ubuntu GNU/mawk userland". Ubuntu CI
  checks it on every push. On macOS it is checked only when someone runs the gates by hand.
- Confidence: High for `find` (primary spec). Moderate for the rest, which was not checked against
  the spec.
- Relevance: dialect drift is a real but so far unrealized risk (R-005). It argues for testing on
  both platforms, not necessarily for a rewrite.

### R-009. A Python port would silently weaken the gates unless every regex is translated and proved

- Observation:
  - Python 3.9.6 `re` accepts `[[:space:]]+` with only a `FutureWarning: Possible nested set`.
    It then fails to match two spaces (receipt E6).
  - The artifact-skills gate has 36 such classes (R-001).
  - Its self-test, `scripts/test-lint-artifact-skills.sh` (159 lines), was deleted in `e8caa16`
    (receipt E4).
- Inference: a hand port has no fixture suite to prove it equivalent. A mistranslated class makes
  the gate pass content it should reject.
- Confidence: High for the `re` behavior and the deleted test. The size of the risk is inference.
- Relevance: this is the main cost of porting. Any port must first restore fault-injection
  fixtures and run them against both implementations.

### R-010. Porting the seal is trivial and exact

- Observation: a 12-line stdlib prototype reproduces `187` files and digest
  `d7a79f141bee818ab66d5e3c5f5779e1f89142cd15bdc24a55df0e21aa716474` on Python 3.9.6 and 3.15.2,
  in 0.07-0.11 seconds (receipt E7). The prototype omits the history-base check.
- Confidence: High.
- Relevance: if a port ever happens, the seal is not the hard part. It also shows the port's
  benefit is small for that gate.

## Options

| Option | Cost | Gain | Main risk |
| --- | --- | --- | --- |
| A. Keep sh plus awk, and harden | Restore a fault-injection fixture script, about the size of the deleted 159-line test. Optionally swap `shasum` for `sha256sum`. | No migration. Both platforms already green (R-002, R-004). | awk or BSD/GNU drift stays untested on the runner (R-003, R-008). |
| B. Port to Python 3 stdlib, 3.9 floor | Rewrite about 370 lines, translating 38 POSIX classes plus the `tr`/`grep -i`/awk semantics. Needs the same fixture suite to prove equivalence (R-009). | One regex dialect on both platforms. Structured parsing and `unittest` become available. | Silent gate weakening during translation (R-009). The floor is an end-of-life version or a new prerequisite (R-006). |
| C. Keep now, port when a trigger fires | Same as A, plus a written trigger. | Postpones B until it has a concrete gain. | The trigger may never be written down. |

## Open questions

- Does each defect probe in receipt E3 fail the same way under the runner's awk? Test: add the
  fixture script from option A to `lint-all.sh`, so the existing workflow runs it on
  `ubuntu-latest`. This is the one test that could expose a dialect gap (R-003).
- Will future gates need structured parsing (YAML frontmatter beyond `key: value`, nested Markdown)?
  If yes, that is the concrete gain that would justify option B. No such gate is planned in the
  scripts read.
- Recorded question for the human, raised by the trial rules rather than the method: is a Mac
  without developer tools a supported place to run the gates? Recommended answer: no. `git`
  already requires the tools (R-006), so the answer does not separate the options.

## Recommendation

Keep the gates in sh plus awk (option A), and treat a port as option C's deferred step rather than
current work.

- The shell gates pass on macOS under both shells and on two Ubuntu releases, and catch every
  injected defect locally (R-002, R-003, R-004). There is no recorded dialect failure (R-005).
- A port gives up a working, tested-in-place implementation for one with no equivalence proof
  (R-009). It also brings in a Python version floor that is either end of life or a new
  prerequisite (R-006). The seal prototype shows the gain is small where the port is easy (R-010).
- The real weakness, untested dialect behavior on the runner (R-003, R-008), is fixed more cheaply
  by restoring a fault-injection fixture script that CI runs. The Perl dependency can go with a
  one-line `sha256sum` swap if Apple ever removes Perl (R-007).
- Port to stdlib Python when either of these happens:
  - the restored fixtures expose a mismatch between BSD and runner behavior that cannot be fixed
    within shell;
  - a planned gate needs structured parsing.

  Write the fixture suite before the port, and run it against both implementations.

The decision stays with the owner.
