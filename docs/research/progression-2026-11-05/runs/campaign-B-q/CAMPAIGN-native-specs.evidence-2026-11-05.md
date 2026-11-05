# Evidence receipt: CAMPAIGN-native-specs pickup, 2026-11-05

This receipt is for [CAMPAIGN-native-specs](CAMPAIGN-native-specs.md). It is a dated snapshot. Re-read
live state before acting on any line below. Everything here was gathered read-only.

## Scope selection

- `gh issue list --state open --limit 1000` returned 358 open issues. Filtering titles that start
  with `spec(native` left three:
  - #4717: P3. Labels `status:active`; board "In progress". Milestone "Electron shell & native audio
    backend". Parent #4674.
  - #4696: P1. Labels `status:tracking`. Same milestone. Parent #430.
  - #4694: P3. Labels `status:tracking`. Milestone "Native plugin hosting". Parent #430.
- None of the three has sub-issues or `blocked_by` dependencies.

## Repository and lanes

- The primary checkout is on `main` at `aa4d3e02f4`, which equals `origin/main`. It has untracked
  operational directories only.
- `git worktree list` shows no worktree whose path or branch names #4717, #4696, #4694, Scala, MTS,
  `.kbm`, `.ascl`, or multitrack. Several foreign recording lanes exist (punch capture, pause
  capture, recording pass identity); they are read-only for this campaign.
- Two local branches remain from #4717 work:
  - `fix/4717/browser-scala-delivery` is the head of merged #5761.
  - `agent/4717/browser-scala-import` is the head of closed, unmerged #5516.
- `scripts/openLane.ts` has no match for a live-lane cap (grep for `five`, `max…lane`, `lane…limit`,
  `MAX_LIVE`, `liveLane`). The five-lane rule in `AGENTS.md` is therefore advisory.
- `.env.sourdaw-author` and `.env.sourdaw-reviewer` exist at the primary root with mode 0600. They
  were not read. `gh` is logged in as `jcosta33`.

## Ruleset

Live ruleset `main` (id 20938734) is active on the default branch. It blocks deletion and
non-fast-forward pushes and has no bypass actors. Its pull-request rule requires:

- squash merges only;
- one approval;
- dismissal of stale reviews;
- approval of the last push;
- resolved threads.

It also requires `Gate` as a non-strict status check.

## Ledger drift to repair on first pickup

- #4717's body says #5516 is open and that delivery is held for an unlanded escaped-main lesson.
  Both claims are stale:
  - #5516 closed unmerged on 2026-10-28. #5761, "fix(project): enable browser Scala imports",
    merged on 2026-10-28 and says it consolidates #5516.
  - The lesson is present in `.agents/skills/review-stances/async-file-imports.md`, entry 2, which
    cites #5397 and #5516.
- #4717 carries `status:active` and "In progress", but no live lane holds it.
- #4717's AC commands name `--package daw-io`. The parser and `TuningParseError` live in
  `crates/daw-core/src/tuning/scala.rs`. `crates/daw-io` holds only `audio_decode.rs` and `lib.rs`.
- #4696's body says no ring buffer exists in `crates/` and cites #3773 as open. Its own 2026-11-04
  comment refutes the first claim (`crates/daw-engine/src/capture.rs`). #3773 closed on 2026-09-25.
- The desktop decoder defect reported in #4717 is confirmed in source.
  `src/modules/Project/repositories/nativeTuning/parseScl.ts` `isNumberArray` accepts any finite
  array, with no length-128 check and no positivity check. No issue tracks it; the campaign fixes it
  in a lane.

## Dependencies and overlap observed

- #5762, "fix(project): route Scala tuning imports through typed actions and Undo", is open with
  `status:ready`. It covers the same import path as #4717 AC-006.
- #4088 is open with `status:ready`; it owns the native session round trip. #4551 is open; it owns
  the browser count-in. #4674 and #4536 are open.
- `crates/daw-wasm-decoder` depends on `daw-io`. The other WASM packages (`daw-dsp`,
  `proof-chamber`, `scoring`) do not depend on `daw-core`, `daw-io`, or `daw-engine`.
- These open foreign pull requests touch paths the campaign will edit. Re-check them before
  dispatch:
  - #5633 touches `crates/sourdaw-native/src/commands/tuning.rs` and `crates/daw-io/AGENTS.md`.
  - #5657 touches `crates/daw-engine/src/capture_clock.rs` and the browser recorder.
  - #5381 touches the browser recorder.
- `crates/sourdaw-native/AGENTS.md` still forbids MTS-ESP registration or publication until the
  ownership and distribution contracts are settled. No ADR mentions MTS-ESP except ADR 0016's
  historical note.
