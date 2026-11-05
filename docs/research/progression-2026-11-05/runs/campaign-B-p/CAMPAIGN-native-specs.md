---
type: campaign
id: CAMPAIGN-native-specs
status: draft
ledger: pending — the first pickup files it with `pnpm issue:file campaign` from ./CAMPAIGN-native-specs.ledger.json and replaces this value with the new issue URL
sources:
  - https://github.com/jcosta33/sourdaw/issues/4694
  - https://github.com/jcosta33/sourdaw/issues/4696
  - https://github.com/jcosta33/sourdaw/issues/4717
  - https://github.com/jcosta33/sourdaw/blob/main/AGENTS.md
  - https://github.com/jcosta33/sourdaw/blob/main/crates/sourdaw-native/AGENTS.md
  - https://github.com/jcosta33/sourdaw/blob/main/.agents/decisions/0012-neither-target-degrades-the-other.md
  - https://github.com/jcosta33/sourdaw/blob/main/.agents/decisions/0020-deferred-deallocation-off-the-audio-thread.md
  - https://github.com/jcosta33/sourdaw/blob/main/.agents/decisions/0029-electron-desktop-shell.md
  - https://github.com/jcosta33/sourdaw/issues/430
---

# Deliver the native specs

Live evidence read to write this campaign: [evidence receipt](./CAMPAIGN-native-specs.evidence.md).
Ledger body to file: [ledger fields](./CAMPAIGN-native-specs.ledger.json).

## Objective

Deliver every open Sourdaw issue whose title starts with `spec(native)`: #4717 (Scala tuning
family: `.scl`, `.kbm`, `.ascl`, write round-trip, structured errors, browser parity), #4696
(native multi-track recording through `cpal` ring buffers with a sample-accurate native count-in),
and #4694 (Sourdaw as an MTS-ESP master for hosted third-party plugins). Each issue's own
requirements govern its scope. Unrelated backlog is rejected, including issues that share a file
or milestone with these three.

## Completion contract

Done when all of the following hold on `origin/main`, each shown by output the working session
produces:

1. `gh issue view <n> --json state,stateReason` reports `CLOSED` / `COMPLETED` for #4717, #4696,
   and #4694. Each closure comes from a pull request merged through `pnpm deliver` whose required
   `Gate` succeeded on the merged head, or from `pnpm issue:reconcile` after such a merge. A
   not-planned closure does not meet this contract; it changes the objective (see Stops).
2. Every automated acceptance check the three issues name exists on `origin/main` under the name,
   or the renamed equivalent recorded on its issue, and observes its claim:
   - #4717: `scala_scl_fixture_conformance` (50 curated fixtures within 1e-9 Hz of a reference
     CSV), `kbm_roundtrip`, `ascl_live12_roundtrip` or its owner-approved substitute,
     `scl_write_roundtrip`, `scala_parse_errors`, a recorded `pnpm cargo:fuzz` run of at least
     five minutes with no panic, and a browser-runtime case in `importSclFile.spec.ts` covering
     `.scl`, `.kbm`, and `.ascl`.
   - #4696: `multitrack_record_no_xruns`, `count_in_sample_accurate`, and the
     native-path-absent fixture under `src/modules/AudioEngine/repositories/audioRecorder`.
   - #4694: `mts_master_lifecycle` and `mts_single_master_guard`.
   A focused `pnpm guard --profile focused -- pnpm cargo:test --package <crate> <filter>` or
   `pnpm guard --profile focused -- pnpm test:run <spec>` run on current `origin/main` passes for
   each. Each check's blind-review record names a probe that made it fail.
3. Every manual acceptance check (#4694 AC-002, AC-003, AC-005, AC-006, and any hardware leg of
   #4696 AC-001) carries the owner's recorded acceptance on its issue. Agents never record it.
4. Constraints below still hold on `origin/main`. In particular, recording still works on the
   browser build through the AudioWorklet path, and Scala import still parses identically on
   browser and desktop.

## Constraints

- ADR 0012: neither the browser nor the desktop target degrades. #4696 keeps the browser
  AudioWorklet recording path working. #4717 imports identically on both targets.
- ADR 0020 and the audio-thread rule: capture callbacks never allocate, lock, or block. Reuse the
  existing `rtrb` capture ring and non-RT drain in `crates/daw-engine`; mint no new primitive.
- `crates/sourdaw-native/AGENTS.md` forbids MTS-ESP registration or publication until ownership and
  distribution are settled. Code for #4694 starts only after an accepted ADR settles them, and
  the change that lifts the constraint amends that file in the same pull request.
- `crates/daw-io` is inside the `daw-wasm-decoder` wasm package closure. Any `daw-io` edit
  rebuilds that package and rewrites the wasm manifest, so two live lanes that edit `daw-io`
  never run in parallel. The same rule applies to the native command surface
  (`electron/commands.ts`, the `sourdaw-native` addon, the hand-maintained bridge mirrors) and to
  any app action, which feeds the command schema and the agent evidence manifest.
- The slice that extends the desktop Scala decoder also rejects tables that are not 128 strictly
  positive frequencies, because it rewrites that decoder.
- Foreign lanes, branches, and pull requests are read-only. Before dispatch, compare the planned
  write set with every live lane's changed files. Capture, recording, and transport lanes overlap
  #4696 most often.

## Non-goals

#4674 (instrument playback of the project tuning), #4536 (microtonal note editing), Sourdaw as an
MTS-ESP client, #4551 (browser count-in on a sample boundary), #4088 (native session pre-arm),
#3990 and #4738 (capture-consumer lifecycle), offline bounce and stem export, and retrospective
capture.

## Workstreams

- #4717: dependency-ready. Its slices share the Scala parser, the native command, and the bridge
  decoder, so they run in sequence on one lane or a stack. Final acceptance of AC-001 and AC-003
  waits on Stop 3.
- #4696: AC-001 and AC-002 wait on an orchestrator-owned ADR that settles the route schema (which
  capture channels map to which track input, and its width) and native capture clock
  correlation. The ADR lane can run beside #4717. Implementation sequences behind any live lane
  that edits `daw-io`, the native command surface, or capture files. Real-time audio work uses the
  strongest author tier.
- #4694: blocked by Stop 1. After the decision, it follows #4696 wherever both touch the native
  engine lifecycle.

## Authorities

The authority table lives in the ledger's Authorities field. This copy is the filing source.

| Operation | Owner | Strength | Mechanism | Failure behavior |
| --- | --- | --- | --- | --- |
| Intent, legal and spend decisions, waivers, manual acceptance | José Costa | Advisory | Recorded decision on the issue or an accepted ADR | Dependent work stays blocked; independent work continues |
| Engineering decisions (route schema, clock correlation, parser placement, browser-parity mechanism, `tune` reuse) | Orchestrator | Advisory | ADR in `.agents/decisions/`, delivered through its own docs lane | Dependent slices wait until the ADR merges |
| Tracker claim | Orchestrator | Deterministic local | `pnpm issue:claim <issue>` through the verified `jcosta33` credential | A refused claim opens no lane |
| Lane allocation | Orchestrator | Deterministic local for lane shape. The five-live-lane cap and write-disjointness are advisory, because `lane:open` checks neither | `pnpm lane:open <issue> <slug> --type <t> --model <m>`, plus `--stack-on` for dependent slices | Refusal stops that lane. At the cap, no new lane opens; the pickup moves existing heads through review and merge |
| Dispatch | Orchestrator to delegated authors | Advisory | Dispatch brief per AGENTS.md Delegation. Never a Fable subagent; explicit model on every dispatch | The deviation is caught at global review; the orchestrator re-briefs or respins |
| Local verification | Author lane | Deterministic local | `pnpm guard --profile focused -- …` with exact spec or crate filters | A timeout, RSS kill, or monitor failure stops the lane |
| Heavyweight execution | PR CI | Isolated authority | `Gate` from `health-gates.yml`, admitted only for the reviewer App's approval of the exact head and required by the `main` ruleset, which has no bypass actors | Red `Gate` blocks merge. Follow the failed-Gate recovery procedure; never rerun to green |
| Publication | Author lane through the protected primary launcher | Deterministic local | `pnpm lane:publish`; `--relates <issue>` on slices that leave the issue open | Refuses uncommitted work, foreign-authored commits, and moved stack parents |
| Review | Blind reviewers at economy or standard tier; never Fable, Astra, Opus, or Sol | Deterministic local for the stance floor and cost ceiling. Advisory for author/reviewer separation, because same-account processes can read both role credentials | `pnpm review:prepare`, `review.json`, `pnpm review:publish`, `review:repair`, `review:confirm` | `review:publish` refuses short floors or over-ceiling models. Five request-changes rounds freeze the PR; respin and `pr:supersede` |
| Merge | Orchestrator decides; author App executes | Isolated authority for head binding (GitHub dismisses stale reviews and requires last-push approval, `Gate`, and resolved threads). Deterministic local for the `deliver` checks | `pnpm deliver` | Refusal leaves the PR open. Head drift resets `Gate` and review |
| Tracker reconciliation | Orchestrator | Deterministic local | `pnpm issue:reconcile` at delivery. Manual operator `gh` only for an issue's own state, labels, milestone, project membership, or sub-issue links | A digest mismatch refuses the edit; reread and retry on fresh state |
| Cleanup | Lane-cleanup worker and orchestrator | Deterministic local | `pnpm lane:cleanup`, `pnpm lane:remove <path>`, `pnpm lane:strand` for abandoned work | Unknown activity or a dirty lane retains the work. Never `git clean`, `git reset --hard`, or a force push |

Heavyweight CI, merge, and lane scripts are reachable only from the owner's machine with the role
credentials at the primary checkout root. This trial did not exercise them, which is one reason the
status stays `draft`.

## Operating loop

On every pickup:

1. Read this campaign, the ledger, the three child issues, `AGENTS.md`, nested `AGENTS.md` files
   for every planned path, and the delivery-orchestration skill before any review or delivery
   script.
2. Reconcile repository, ledger, pull-request, worktree, and verification state from live
   evidence: `git fetch`, `gh issue view`, `gh pr list`, `git worktree list --porcelain`, and the
   latest `Gate` runs. Classify every worktree by path, branch, owner, and state. Never seize an
   active or unknown lane.
3. Repair ledger drift before trusting status. Correct child bodies that name superseded pull
   requests, and clear `status:active` where no live lane or pull request holds the claim.
4. Take the highest-priority dependency-ready, write-disjoint work that fits lane capacity and
   that no stop blocks. Brief one author per slice with the issue's acceptance checks.
5. Run it through publication, blind review, the orchestrator's global review, repair, approval,
   `Gate`, and `pnpm deliver`, bound to the expected head. No owner accepts its own work. A
   distinct reviewer confirms each repair.
6. Record progress on the child issues and the ledger, never in this file.
7. Repeat until the completion contract passes or a stop below blocks every remaining item.

## Stops

No human is available for this trial. Each question below is recorded with a recommended answer.
Independent work continues while a stop is open.

1. **libMTS distribution and update policy (#4694 DG-001; legal exposure).** Should Sourdaw bundle
   ODDSound's `libMTS`, install it on first run with consent, or require a separate install?
   Recommendation: discover an existing `libMTS` at the platform-standard path first. If none is
   found, offer a consented install from ODDSound's own distribution, and never bundle it. This
   holds only after the `libMTS` licence terms are verified and recorded in the ADR that lifts the
   `sourdaw-native` constraint. Blocks all #4694 code.
2. **Manual MTS-ESP clients (#4694 AC-003; spend).** AC-003 names Serum and Pianoteq, both
   commercial. Buy licences, or accept other clients? Recommendation: accept Surge XT, which is
   free and open source, plus any MTS-ESP clients the owner already licenses. Record the
   substitution on #4694. Blocks only #4694's manual acceptance.
3. **Third-party fixture provenance in a public repository (#4717 AC-001, AC-003; legal exposure,
   possible spend).** AC-003 names Ableton Live 12's bundled `.ascl` files, and AC-001 needs 50
   curated `.scl` fixtures. Recommendation: commit only first-party fixtures written against the
   published formats. Run the Live 12 round-trip locally from the owner's own install, without
   committing Ableton's files, and record the result on #4717. Blocks only the final acceptance of
   those two checks.
4. **Reference hardware for #4696 AC-001 (spend; reference tiers are an unratified census gate).**
   Is a 32-input interface required? Recommendation: discharge AC-001 with a deterministic test
   that drives a simulated 32-channel, 48 kHz, 128-sample callback through the real ring and WAV
   writer, plus an owner manual run on whatever interface is available. Blocks only the hardware
   leg.
5. **Objective change.** Any decision to retire an issue instead of delivering it (for example,
   not hosting MTS-ESP) changes this objective. Revise the campaign before closing that issue.

Ledger shape (recorded, not a stop): #4694 and #4696 are sub-issues of #430, and #4717 is a
sub-issue of #4674. GitHub allows one parent per issue, so the ledger lists the children in its
Child issues field and does not re-parent them.
