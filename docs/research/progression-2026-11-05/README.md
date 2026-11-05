# Progression test, 2026-11-05: artifact authors before and after ADR-0190

This test compares the four artifact authors as they stood at `ae6d2e8` ("old") with the
[ADR-0190](../../adrs/0190-tracker-first-and-shorter-authors.md) versions ("new"). Each skill did two
representative tasks per version on the current model.

## Method

- **Runs.** 16 runs: 4 skills × 2 tasks × 2 versions. Each run was one fresh Claude Opus 5.5
  subagent given a skill file by path and a task.
  - The skill files sat under neutral labels `p` and `q`, assigned per skill. Spec and research had
    `p` = old; audit and campaign had `p` = new.
  - Each run wrote its artifact to its own directory, not `~/.agents/artifacts`.
  - No human was available: every question was recorded with a recommended answer.
  - Every run was read-only.
- **Grading.** One fresh Opus 5.5 grader graded all 16 artifacts blind to the mapping.
  - Rules were common evidence, certainty, and human-authority rules plus per-skill rules.
  - It spot-checked at least two citations per run against the source repositories.
  - The full sheet is [GRADES.md](GRADES.md).
- **Tasks:**
  - `spec-A`: a Sourdaw `issue:file` validation spec. The project has a spec issue form.
  - `spec-B`: a structural split of this repository's skill gate.
  - `audit-A`: assess this repository's gates.
  - `audit-B`: map Sourdaw's issue-filing route, map only.
  - `research-A`: POSIX sh versus Python for this repository's gates.
  - `research-B`: FFmpeg licensing and patent posture for a commercial Electron DAW.
  - `campaign-A`: resolve every open Sourdaw `research(` issue.
  - `campaign-B`: deliver every open Sourdaw `spec(native)` issue.
- **Outputs.** `runs/<skill>-<task>-<p|q>/` holds each run's artifact and top-level sidecars. Probe
  and fixture trees that copied repository state were left out.

## Cost

Tokens are subagent totals reported by the harness.

| Run | Version (label) | Tokens | Tool uses | Wall time |
| --- | --- | --- | --- | --- |
| spec-A | old (p) | 77,027 | 15 | 115 s |
| spec-A | new (q) | 84,976 | 25 | 203 s |
| spec-B | old (p) | 112,440 | 25 | 737 s |
| spec-B | new (q) | 115,437 | 28 | 697 s |
| audit-A | old (q) | 87,890 | 22 | 304 s |
| audit-A | new (p) | 94,016 | 25 | 327 s |
| audit-B | old (q) | 96,110 | 35 | 273 s |
| audit-B | new (p) | 90,966 | 30 | 365 s |
| research-A | old (p) | 99,116 | 38 | 419 s |
| research-A | new (q) | 109,469 | 52 | 544 s |
| research-B | old (p) | 116,875 | 45 | 522 s |
| research-B | new (q) | 116,637 | 57 | 582 s |
| campaign-A | old (q) | 149,709 | 36 | 385 s |
| campaign-A | new (p) | 138,010 | 32 | 290 s |
| campaign-B | old (q) | 148,528 | 39 | 370 s |
| campaign-B | new (p) | 130,622 | 40 | 313 s |

The two runs per cell cannot separate cost from noise:

- spec, audit, and research cost about the same in both versions;
- campaign was about 10% cheaper and 20% faster with the new version.

## Result

The new version tied or beat the old one on every skill. The grader found no rule where the new
version regressed against the old, so no cut was reverted.

| Skill | Verdict | Rules where the old version failed and the new passed |
| --- | --- | --- |
| spec | new better | spec-A: S1 (old bundled two obligations in one `Then`), S2 (old used one unfiltered test command that passes before any case exists), S3 (old ignored the issue form's required fields and its "No local paths" source rule; new mapped onto the form's field ids) |
| audit | new better | audit-A: E1 (old cited three wrong `AGENTS.md` lines), A2 (old asserted "docs/ is ungated" without printing the sweep command) |
| research | new somewhat better | No rule difference. New exercised AVFoundation, read Chromium's FFmpeg `config.h`, and was about 30% shorter on research-B. |
| campaign | new better | K2 on both tasks (old invented control strengths outside the three-term vocabulary), E3 (old accepted owner-reserved decision gates itself), K4 (old dropped the ban on taking over another owner's branch), K1 on campaign-B (old copied priority labels into the loop) |

## Weaknesses both versions share

- **spec-B:** both versions bundle several checks into one `Then`, failing S1.
- **campaign-A:** both versions copy some mutable ledger state, failing K1.
  - Old copied the #4682 claim state and lane occupancy.
  - New copied seven priorities and the #4682 claim snapshot.

These are existing rules that models still break. They are not regressions.

## Limits

- **Sample size.** Two tasks per skill and one run per cell. Treat the result as a regression
  screen, not an effect size.
- **Contamination.** The spec-B runs read this repository's live `scripts/` while ADR-0190's gate
  edit was uncommitted. The old run's baseline captured that diff (`runs/spec-B-p/evidence-baseline.md`).
- **One grader.** There was no second grader to measure agreement.
