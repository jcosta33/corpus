---
type: campaign
id: CAMPAIGN-native-specs
status: draft
ledger: unfiled
sources:
  - ../../../../../sourdaw/AGENTS.md
  - ../../../../../sourdaw/crates/sourdaw-native/AGENTS.md
  - ../../../../../sourdaw/crates/daw-engine/AGENTS.md
  - ../../../../../sourdaw/crates/daw-io/AGENTS.md
  - ../../../../../sourdaw/crates/daw-core/AGENTS.md
  - ../../../../../sourdaw/.agents/skills/delivery-orchestration/
  - ../../../../../sourdaw/.agents/decisions/0012-neither-target-degrades-the-other.md
  - ../../../../../sourdaw/.agents/decisions/0020-deferred-deallocation-off-the-audio-thread.md
  - ../../../../../sourdaw/.agents/decisions/0029-electron-desktop-shell.md
  - https://github.com/jcosta33/sourdaw/issues/4717
  - https://github.com/jcosta33/sourdaw/issues/4696
  - https://github.com/jcosta33/sourdaw/issues/4694
  - https://github.com/jcosta33/sourdaw/issues/430
---

# Campaign: deliver the open `spec(native)` specs

Dated pickup evidence: [evidence receipt, 2026-11-05](CAMPAIGN-native-specs.evidence-2026-11-05.md).

## Objective

Deliver every open `jcosta33/sourdaw` issue whose title starts with `spec(native)` to `main`:
#4717 (Scala-family tuning import and export), #4696 (native multi-track recording through `cpal`
ring buffers), and #4694 (Sourdaw as an MTS-ESP master). Each acceptance criterion either lands
through the project's gates or is waived by the owner on that issue.

## Completion contract

The campaign is done when a fresh reconcile against live `origin/main` and the tracker shows all of
the following:

- #4717, #4696, and #4694 are closed. Each was closed by a merged pull request, or by an owner
  comment naming a waiver for every acceptance criterion that did not land.
- Every automated acceptance criterion has its named test on `origin/main`, or a corrected command
  recorded in the issue body. That test ran inside the required `Gate` of the pull request that
  landed it. The review record shows a revert or targeted-mutation probe that turned it red.
- Every manual acceptance criterion has its observed result on the issue, recorded by whoever ran
  it, or an owner waiver.
- MTS-ESP registration or publication code appears on `main` only after an accepted ADR in
  `.agents/decisions/` settles master ownership and `libMTS` distribution. In the same change,
  `crates/sourdaw-native/AGENTS.md` replaces its MTS-ESP prohibition with a link to that ADR.
- The native recording route schema and clock correlation have an accepted ADR before any
  #4696 AC-001 or AC-002 code merges.
- No open pull request, live lane, or unmerged branch created by the campaign remains. Lanes were
  retired through `pnpm lane:remove` or the `pnpm lane:cleanup` worker. Leftover local branches
  were deleted only after their head reached `main`.
- Each child issue body describes `main` accurately, and the ledger issue is closed.

## Authorities

| Operation | Owner | Strength | Mechanism | Failure behavior |
| --- | --- | --- | --- | --- |
| Ledger | Campaign orchestrator | Deterministic local (schema). Advisory (content) | A Campaign-form issue filed with `pnpm issue:file campaign`. Children are listed by bare number. Ordering uses GitHub issue dependencies. Sub-issue parentage stays with #430 and #4674, because GitHub gives an issue only one parent. | `issue:file` refuses fields outside the form schema and milestones that are not open. Until the issue exists, the operations that record progress are blocked. Engineering work may start, and its pull requests carry the progress. |
| Tracker claims and corrections | Orchestrator | Deterministic local (claim, reconcile). Advisory (manual `gh` corrections) | `pnpm issue:claim <issue>` when a lane opens. `pnpm issue:reconcile` at delivery. Operator `gh` corrects an issue's own body, labels, milestone, or links. | The scripts refuse when digests mismatch or the identity is wrong. A manual correction has no guard, so read it back after writing. |
| Lane allocation | Orchestrator opens lanes. One implementation owner per lane | Deterministic local (lock, type, stack parent). Advisory (five-live-lane cap) | `pnpm lane:open <issue> <slug> --type <type> --model <model>` from `origin/main`, or `--stack-on <absolute-parent-lane>` for a real dependency. The lane takes the `active:sourdaw-author` lock. | `lane:open` refuses a missing or unknown type, a numeric slug, and a stack parent that is unclean, uncommitted, or foreign. No script enforces the cap, so the orchestrator counts its own live lanes before opening another. Foreign or unknown lanes are never touched. |
| Local verification | Lane author | Deterministic local (resource admission). Advisory (test selection) | `pnpm guard --profile focused -- pnpm cargo:test --package <crate> <filter>` and `pnpm guard --profile focused -- pnpm test:run <changed-spec>`. Format only the changed files. | The guard waits for RAM. A timeout, RSS kill, or monitor failure stops the lane and is reported. A failed check is never rerun to get green. |
| Heavyweight execution: fuzzing for #4717 AC-005, capture stress for #4696 AC-001, WASM regeneration | Lane author, sequenced by the orchestrator | Deterministic local | `pnpm guard --profile extended --max-rss-mib <estimate> -- pnpm cargo:fuzz …`. WASM: the affected package's `wasm:*` script, then `pnpm wasm:manifest` and `pnpm wasm:verify`. | The guard refuses or kills over budget. Record the new budget in the guard's `measuredScriptBudgets`. Freshness is proven only by `pnpm wasm:verify` after staging. |
| Broad verification | PR CI | Hosted deterministic | The `Gate` required by the live `main` ruleset, minted only by `health-gates.yml` after the reviewer App's `ci:approved` admission | A red, cancelled, or missing `Gate` blocks merge. A retry-dependent pass counts as a failure and goes through the repository's failed-Gate recovery procedure. Because a head can edit its own workflows, reviewers check for weakened gates. |
| Publication | Lane author through the trusted bootstrap | Deterministic local | Commit with a conventional subject, then run `pnpm lane:publish` from the protected primary checkout. Earlier slices of one issue pass `--relates`, and the final slice closes it. | Publish refuses uncommitted work, commits authored by someone other than the author App, and a stack parent that is moved, missing, or racing. Lane tooling owns every push, and the ruleset rejects any direct push to `main`. |
| Review | Orchestrator dispatches blind reviewers. The reviewer App publishes | Deterministic local (stance floor, cost ceiling, freeze). Advisory (blindness, stance independence, probes) | `pnpm review:prepare`, then blind economy or standard draws with one stance each, each on a model other than the author's. Then `review.json`, `pnpm review:publish`, `pnpm review:repair` by the author, and `pnpm review:confirm` by the reviewer App. The orchestrator also does its own whole-head review. | Publish refuses draws below the risk-plan floor, a reviewer model over the cost ceiling, and pull requests frozen after five request-changes rounds. A frozen pull request is replaced by one consolidated pull request, then closed with `pr:supersede`. |
| Merge | Orchestrator decides. `pnpm deliver` executes as the author App | Hosted deterministic plus deterministic local | The `main` ruleset requires squash merges, one approval, approval of the last push, resolved threads, and `Gate` on the head. It has no bypass actors. `deliver` merges only a non-draft head with the reviewer App's APPROVE of that exact head. | `deliver` refuses a stale approval, unresolved threads, or `CHANGES_REQUESTED`. A head that drifts needs a fresh `Gate` and a fresh review. |
| Cleanup | `pnpm lane:cleanup` worker, or the orchestrator for its own lanes | Deterministic local | `pnpm lane:remove <path>`, run outside the lane, requires exact-head merge proof. Abandoned work goes through `pnpm lane:strand`. | Removal refuses open pull requests, dirty trees, unknown activity, and foreign locks. Delete only campaign-created merged branches and campaign-created worktrees. |
| Engineering decisions | Orchestrator | Advisory with a durable record | An ADR in `.agents/decisions/` and its ledger, landed through the same lane, review, and delivery path | Dependent acceptance criteria stay undispatched until the ADR merges. |
| Product, legal, spend, waiver, and acceptance decisions | José Costa, owner | Advisory | Owner's answer in chat, recorded on the child issue | Only the dependent criteria in Stops stay blocked. |

None of these controls isolates workers. Lanes, the author and reviewer App credentials, and the
`jcosta33` keyring credential all live under one OS account on one machine. A worker that ignores
its brief could reach every one of them. Treat role separation as deterministic-local discipline,
not as isolation. Record a reviewer who reuses the author's model under `modelExhaustion`. Fable,
Opus, Astra, and Sol models never review.

## Constraints

- Real-time invariants are hard. Capture, WAV writing, and MTS-ESP calls run off the audio
  callback. The callback does not allocate, lock, or use IPC. Recorded input comes from the engine's
  capture tap. Any ring or retirement primitive follows the `rtrb` plus non-RT drain pattern from
  ADR 0020. Reuse the existing native capture ring; do not add a second one.
- ADR 0012 requires parity. Browser-only builds keep working. Browser tuning-file import parses
  and applies exactly as desktop does, proven by a shared native and browser case corpus.
- These files and surfaces are shared, so their edits are serialized: the native command surface
  (the `sourdaw-native` addon and `electron/commands.ts`), any new app action (it feeds the command
  schema and the agent evidence manifest), and `crates/daw-io` (it feeds the `daw-wasm-decoder`
  WASM manifest). Two live lanes never both edit any of these. Before each dispatch, re-check open
  foreign pull requests that touch the same paths, and wait for or stack on them. Never edit them.
- Wire payload types are hand-mirrored. A changed body signature updates the TypeScript mirror and
  its decoder in the same pull request.
- Product-path pull requests carry user-observable How-to-test steps.
- Reproduce a defect before fixing it. Reach every acceptance criterion with a test that fails on
  revert.

## Workstreams

The stable IDs are issue numbers and acceptance-criterion IDs. Live status belongs to the ledger.
Default parallelism is one lane per stream. The shared-surface rule above can serialize streams.

- **#4717, standard tier; strongest for the parser's error and allocation boundary.**
  1. Decide where the parser lives. Recommendation: keep it in `daw-core`, which feeds no WASM
     package, and correct the AC commands that name `--package daw-io`. Moving it into `daw-io`
     would tie every Scala change to the `daw-wasm-decoder` rebuild and to #4696's lanes.
  2. Harden the desktop `parse_scl` decoder to require the project tuning contract of 128 strictly
     positive frequencies. This defect was found during reconcile, so it is fixed in a lane, not
     filed.
  3. AC-001: corpus plus implicit degree 0 and period handling.
  4. AC-004: `.scl` write.
  5. AC-002: `.kbm`.
  6. AC-003: `.ascl`, after S2.
  7. AC-005: structured errors and fuzzing across all three formats.
  8. AC-006: browser parity for `.kbm` and `.ascl`. This waits for #5762, which routes Scala import
     through typed actions and Undo, or the orchestrator takes #5762 in as a prerequisite slice
     when no other owner holds it.
- **#4696, strongest tier for real-time and persistence; standard for AC-003.**
  1. ADR on the route schema: how capture channels map to `Track.inputId`, plus channel width.
     Recommendation: per-track input as a start channel plus a mono or stereo width, following the
     common DAW input-pair convention, with a document migration. Also decide clock correlation.
  2. AC-003: browser fallback note. This is independent and may go first.
  3. AC-001: multi-channel WAV capture, proven against a deterministic simulated multi-channel
     source.
  4. AC-002: native count-in. This is sequenced with #4088, which owns the native session's
     boundary round trip, and stays separate from #4551, which owns the browser count-in.
- **#4694, strongest tier; `native-security` and `realtime-audio` risk.**
  1. ADR on master ownership: which process registers, and the order inside the shutdown cascade.
     This is engineering work and may start now.
  2. Owner decision S1 on distribution.
  3. AC-001 and AC-004, tested through a seam that fakes libMTS.
  4. AC-003.
  5. AC-005.
  6. Manual acceptance for AC-002 and AC-006, under S3.

## Non-goals

These are out of scope: instruments playing the project tuning (#4674), the microtonal piano roll
(#4536), browser count-in on a sample boundary (#4551), the native session pre-arm (#4088),
retrospective capture (#4542), offline bounce or stem export, Sourdaw as an MTS-ESP client, and the
remaining rows of the gaps census in #430.

## Operating loop

1. Read this campaign, `AGENTS.md`, the nested `AGENTS.md` for every touched subtree, and the
   delivery-orchestration skill before running any review or delivery script.
2. Reconcile repository, ledger, child-issue, pull-request, worktree, and verification state from
   live evidence: `git fetch`, `git worktree list`, `gh` reads, and the live ruleset. Repair ledger
   drift before trusting status. On first pickup, file the ledger and correct the stale child bodies
   listed in the evidence receipt.
3. Select the highest-priority work that is dependency-ready, write-disjoint, and fits capacity
   (#4696 is P1; #4717 and #4694 are P3). Skip anything waiting on a Stop.
4. Execute it through `lane:open`, `issue:claim`, focused verification, `lane:publish`, blind
   review, the orchestrator's whole-head review, `Gate`, and `deliver`, in dependency order.
5. Record progress on the child issues and the ledger, never in this file.
6. Repeat until the completion contract passes or a named Stop blocks every remaining item.

## Stops

No human was available for this trial. Each Stop records the question for José Costa, the
recommended answer, and the options with their costs. The campaign stays `draft` until S1–S3 are
answered. Independent work continues meanwhile.

- **S1. How does Sourdaw obtain `libMTS`?** This blocks all #4694 registration and publication code,
  plus AC-006. The ownership ADR is not blocked.
  - **Recommended: (b).**
  - (a) Detect only. If `libMTS` is missing, link the user to ODDSound's own installer. This is the
    lowest legal exposure, but AC-006 must be changed from "place libMTS" to "guide the install".
  - (b) Detect first. If `libMTS` is missing, place it at the platform-standard path from ODDSound's
    official distribution, only after explicit consent. This matches AC-006 as written. It costs a
    review of ODDSound's terms for automated download, an integrity check, and per-platform paths.
    If those terms forbid automated download, fall back to (a).
  - (c) Bundle `libMTS` with the app. This needs redistribution permission and legal review, and
    adds signing, notarization, and an update policy.
- **S2. Which third-party tuning files may be committed as fixtures?** This blocks #4717 AC-003,
  and AC-001's choice of corpus source.
  - **Recommended: (a).**
  - (a) Commit only first-party fixtures written from the published `.scl`, `.kbm`, and `.ascl`
    formats, with an independently computed reference CSV. Check against Ableton Live 12's bundled
    `.ascl` files only locally, never committing them. AC-003's wording changes accordingly. This
    costs fixture authoring time.
  - (b) Also commit Scala-archive scales with attribution after a license review. This costs the
    review.
  - (c) Commit Live 12 bundled files. This likely redistributes Ableton content and may require
    buying a Live 12 license.
- **S3. What counts as hardware and third-party acceptance?** This blocks the manual parts of #4696
  AC-001 and of #4694 AC-002, AC-003, and AC-006.
  - **Recommended: (a).**
  - (a) Run the automated tests on a deterministic simulated 32-channel source, plus a manual pass
    on the owner's own interface at its real channel count. Use Surge XT, which is free, as the
    decisive MTS-ESP client. Waive Serum and Pianoteq unless the owner already has them. Verify
    Windows only if a Windows machine is available. This costs recorded waivers.
  - (b) Buy a 32-input interface and Serum and Pianoteq licenses. This is real spend.
  - (c) Leave the manual criteria open. The issues stay open and the campaign cannot complete.
