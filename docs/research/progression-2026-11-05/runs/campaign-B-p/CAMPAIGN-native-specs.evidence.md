# Evidence receipt: CAMPAIGN-native-specs

Read on 2026-11-05, against `origin/main` `aa4d3e02f4`, with read-only `git` and `gh` only. This
is a snapshot. The campaign never relies on it. Each pickup reconciles from live state.

## Scope selection

- `gh issue list --state open --limit 1000` returned 358 open issues. Titles starting with
  `spec(native)`: #4717, #4696, #4694. Other titles containing "native" use the `fix`, `feat`,
  `bug`, or `research` prefixes and are out of scope.

## Child issues

- #4717: P3, `status:active`, no assignee, milestone "Electron shell & native audio backend",
  parent #4674. Its body names PR #5516 as open. Live state: #5516 is CLOSED. #5761
  (`fix/4717/browser-scala-delivery`, browser `.scl` import) MERGED 2026-10-28, and #5397 MERGED.
  Neither closes #4717. No worktree branch carries 4717, so `status:active` is drift. No `.kbm`
  or `.ascl` code exists in `crates/`, `src/`, or `electron/`. No cargo-fuzz target exists.
  `async-file-imports.md` in the review stances records the #5516 and #5761 escape lessons.
- #4696: P1, `status:tracking`, milestone "Electron shell & native audio backend", parent #430.
  Owner comment of 2026-11-04: nothing has landed, `crates/daw-io` holds only `audio_decode.rs`
  and `lib.rs`, an `rtrb` capture ring exists in `crates/daw-engine/src/capture.rs`, #3773 is
  closed, #4088 owns the desktop boundary round trip, and the route schema must come first.
  `hound` and `rtrb` are already dependencies of `sourdaw-native`, and `cpal` 0.18 of
  `daw-engine` and `sourdaw-native`.
- #4694: P3, `status:tracking`, milestone "Native plugin hosting", parent #430. No MTS-ESP code
  exists in `crates/`, `src/`, or `electron/`. `crates/sourdaw-native/AGENTS.md` forbids
  registration or publication until ownership and distribution are settled. The #430 census lists
  `SPEC-mts-esp-host.md` as gated on DG-001 (libMTS distribution) and
  `SPEC-native-multitrack-recording.md` as gated on DG-001 (route schema and clock correlation).

## Authorities and controls

- The `main` ruleset (id 20938734) is active with no bypass actors. It enforces deletion and
  non-fast-forward bans, squash only, one approval, stale-review dismissal on push, last-push
  approval, resolved threads, and the required `Gate` context (non-strict).
- `.env.sourdaw-author` and `.env.sourdaw-reviewer` exist at the primary root with mode 0600. Their
  contents were not read. `delivery-orchestration/references/trust-boundary.md` states that
  same-account processes can read credentials, so role separation is not isolation.
- `scripts/openLane.ts` contains no live-lane cap check. The AGENTS.md five-lane cap is advisory.
- `scripts/wasm-artifacts.ts` lists `crates/daw-wasm-decoder`, which depends on `daw-io`. No wasm
  package depends on `daw-core`.
- Live author lanes under `.agents/worktrees/` far exceed the five-lane cap at this reading. Lane
  allocation for this campaign would wait on capacity.
- Open campaign epic #5614 does not list any of the three children.

## Not read

The trial rules excluded the delivery-orchestration `SKILL.md`. The Authorities table relies on
`AGENTS.md`, `package.json` scripts, and `references/trust-boundary.md`. No trusted write script
was run, and no ledger was filed.
