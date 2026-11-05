---
type: campaign
id: CAMPAIGN-resolve-sourdaw-research-issues
status: draft
ledger: unfiled — the first pickup files the Campaign issue from CAMPAIGN-resolve-sourdaw-research-issues.ledger-draft.md with `pnpm issue:file campaign`, then replaces this value with its URL
sources:
  - ../../../../../sourdaw/AGENTS.md
  - ../../../../../sourdaw/.github/ISSUE_TEMPLATE/campaign.yml
  - ../../../../../sourdaw/.github/ISSUE_TEMPLATE/research.yml
  - ../../../../../sourdaw/.agents/decisions/README.md
  - ../../../../../sourdaw/.agents/decisions/0026-ownership-by-exception.md
  - ../../../../../sourdaw/.agents/decisions/0030-exact-model-release-admission.md
  - ../../../../../sourdaw/.agents/skills/delivery-orchestration/
  - https://github.com/jcosta33/sourdaw/issues/3645
  - https://github.com/jcosta33/sourdaw/issues/3708
  - https://github.com/jcosta33/sourdaw/issues/4608
  - https://github.com/jcosta33/sourdaw/issues/4677
  - https://github.com/jcosta33/sourdaw/issues/4682
  - https://github.com/jcosta33/sourdaw/issues/4723
  - https://github.com/jcosta33/sourdaw/issues/4737
---

Live state observed when this was written: [evidence receipt](CAMPAIGN-resolve-sourdaw-research-issues.evidence.md).
Ledger body to file: [ledger draft](CAMPAIGN-resolve-sourdaw-research-issues.ledger-draft.md).

## Objective

Answer the question of every Sourdaw research issue that was open, with a `research(` title, when
this campaign was locked: #3645, #3708, #4608, #4677, #4682, #4723, #4737. Each answer becomes an
accepted decision record. Each issue then closes, so its parent spec or audit can rely on that
answer as its gate.

The set is locked to these seven ledger children. A `research(` issue filed later joins only when
the owner adds it to the ledger.

## Completion contract

The campaign is done when every check below passes against live GitHub and `origin/main`:

1. `gh issue view <n> --json state` reports `CLOSED` for each of the seven children.
2. Each child's final body section names the chosen option, the finding IDs that carried it, and
   the decision record. It also names any residual `[unconfirmed]` claim the owner accepted.
3. Each decision record is an accepted ADR on `origin/main` under `.agents/decisions/`, indexed in
   that directory's `README.md`, and delivered through `pnpm deliver` from a PR bound to the child
   issue. One ADR may answer #4682 for both of its consumers, #4681 and #4637. An owner decision to
   withhold or defer is still an ADR, like ADR 0030's `Withhold` rows.
4. Every admission or licence decision (#4608, #4677, #4723) cites the primary licence or
   patent-pool text it read. It also records the owner's choice from [Stops](#stops). It never
   claims a licence the source does not state, as ADR 0035 does for DDSP.
5. Work the decision leaves behind is filed with `pnpm issue:file` and linked from the closed child.
   That includes the native buffer and rate controls spec for #3645, the help-projection spec for
   #3708, and the patched-runtime build for #4682. Implementation is not part of this campaign.
6. The ledger issue is closed. Every campaign-created lane has been removed with `pnpm lane:remove`.

## Authorities

The ledger issue's Authorities field carries this table verbatim. Strength uses three terms: advisory, deterministic local, and isolated authority.

| Operation | Owner | Strength | Mechanism | Failure behaviour |
| --- | --- | --- | --- | --- |
| Intent, legal exposure, spend, product-behaviour change | José Costa, in chat | Advisory | Owner answers a [Stops](#stops) question. The orchestrator records the choice on the child issue. Private legal advice stays in `~/.agents/artifacts`, because the tracker is public. | The dependent stream holds at its stop. Independent streams continue. |
| Orchestration, dispatch, finding adjudication, global head review | Campaign orchestrator, the top-level session | Advisory | AGENTS.md Delegation and Review. The orchestrator never implements. | A defect from a skipped duty surfaces only at review or after merge. |
| Ledger filing | Orchestrator | Deterministic local | `pnpm issue:file campaign` validates fields against the Campaign template and open milestones before filing. | Refused before any write. Fix the fields and refile. |
| Research progress and child state corrections | Orchestrator, using the operator `gh` credential | Advisory | Dated body section on the child issue. This follows the existing child-body pattern and AGENTS.md "later corrections require manual `gh`". Status label and closure corrections are the permitted manual `gh` exceptions. | Nothing rejects a wrong edit. Step 2 of the operating loop rereads and repairs drift. |
| Issue claim | Orchestrator | Advisory | `pnpm issue:claim <n>` swaps the status label and the board column. Before claiming, check the issue is free of `status:active` held by another owner. | Two claimants are not rejected. A foreign `status:active` stops that stream; see [Stops](#stops). |
| Lane allocation | Implementation owner, one per lane | Deterministic local | `pnpm lane:open <n> <slug> --type docs --model <model>` branches from `origin/main` and takes the `active:sourdaw-author` lock. It refuses an unknown type or a numeric slug. | Refused. No lane, no branch. |
| Live-lane cap | Orchestrator | Advisory | The AGENTS.md lane cap. No script enforces it; see the evidence receipt. Live lanes already exceed the cap, so a campaign lane opens only after capacity frees. | Nothing rejects an excess lane. The orchestrator must count live lanes before opening one. |
| Heavyweight execution: probes, browser, native, WASM, measurement | Implementation owner | Deterministic local once invoked | `pnpm guard --profile <focused\|broad\|extended> -- <command>` admits by free RAM and kills on RSS. | A timeout, RSS kill, or monitor failure is a stop. Never retry unchanged. Bypassing the guard is advisory-only misuse. |
| Verification | PR CI, `Gate` from `health-gates.yml` | Deterministic, hosted | The ruleset requires `Gate` on the PR head. Admission runs from the default branch and admits only the reviewer App's approval label for the exact head. | Red or missing `Gate` blocks merge. A head that weakens its own workflow is caught only by review, which is advisory. |
| Review publication | Reviewer App, through `pnpm review:prepare` and `pnpm review:publish` | Deterministic local | Refuses below the risk plan's stance floor, above the reviewer cost ceiling, with credential-shaped values, or on a frozen PR. | Refused before any remote write. |
| Author cannot approve own work | AGENTS.md Review | Advisory | Separate App identities. Both role credential files sit at the primary root under the same user account, so a worker could reach them. | No isolation. The orchestrator verifies reviewer and author identities and models in `review.json`. |
| Merge | Author App, through `pnpm deliver`, plus the GitHub `main` ruleset | Deterministic, hosted | `deliver` refuses without the reviewer App's APPROVE of the current head and resolved threads. The ruleset requires squash merge, one approval, last-push approval, resolved threads, and `Gate`, with no bypass actors. | Refused. Drift on the head resets `Gate` and review. Not isolated from workers: the operator credential that can change rulesets is in the shared keyring. |
| Cleanup | Orchestrator | Deterministic local | `pnpm lane:remove <path>` refuses anything other than a clean lane whose single PR head reached `main`. The `pnpm lane:cleanup` worker handles missed deliveries. | Refused, and the lane is retained. Never force-clean. Delete only campaign-created lanes and their merged branches. |

Delivery procedure, flags, and refusal semantics: the `delivery-orchestration` repository skill,
loaded before any review or delivery script.

## Constraints

- **Research is evidence, not requirements.** A child closes on a decision. Its intent and
  acceptance checks go to a filed Spec (`research.yml`).
- **The licence posture is fixed.** Sourdaw is Apache-2.0 (`LICENSE`, `package.json`). This bears
  directly on the GPL and CC-BY-NC-SA options in #4723 and #4608.
- **Admission is exact-artifact only.** Any model or voice decision follows ADR 0030, ADR 0035 and
  ADR 0037: pinned revision, byte size, SHA-256, and an explicit licence field.
- **Two targets, two carriers.** ADR 0012 and ADR 0044 govern #3645, #4723 and #4737. Neither target
  may be degraded for the other. Comparisons need evidence on both carriers.
- **ADR PRs serialize.** Every ADR PR takes the next monotonic number and edits the
  `.agents/decisions/README.md` index, so only one ADR lane is live at a time. Research and probe
  work on other children only writes child bodies and private artifacts, so it runs in parallel.
- **Probes stay outside tracked files.** Prototype and measurement code lives in
  `~/.agents/artifacts`. A lane is opened only for the ADR PR.
- **Models.** Authors and the orchestrator choose by AGENTS.md tiers:
  - strongest for #4682 (security), #4737 (real-time DSP measurement) and #3645 (native audio);
  - standard for #3708 and for the primary-source licence surveys in #4608, #4677 and #4723;
  - economy only for mechanical ledger edits.

  Reviewers use economy or standard only, and never Fable, Astra, Opus or any Sol model. Per the
  owner's global rule, Fable never runs as a subagent; every dispatch names a non-Fable model.
- **Resource safety.** Broad suites, lint, types, builds and WASM-all never run locally; PR CI owns
  them.
- **No secrets in the tracker.** No credential, private legal advice, or session transcript goes
  into a child body, PR, or review.

## Non-goals

- Implementing any parent spec: #4607, #4676, #4681, #4637, #4722, #4719, #4730, #3801.
- Changing `MODEL_RELEASE_ADMISSION` or any manifest.
- Adding an FFmpeg dependency.
- Exposing buffer or thread controls.
- Converging sampler engines.
- Other open issues under #430, #3684 or #3806.
- Re-parenting the children. Each child already has a parent issue (#3684, #4607, #4676, #4681,
  #4722, #430) carrying its gate relationship. The ledger therefore lists children by bare number
  rather than as sub-issues.

## Workstreams

Each child is one stream. Its research runs in parallel with the others. Its ADR PR waits for the
ADR serialization slot.

- **#4682.** Select a maintained fixed QuickJS artifact, or a reviewed reproducible patched build,
  that closes the recorded heap-accounting gap and the typed-array fix gap. Then record the Electron
  `app://` observation and write one runtime ADR for #4681 and #4637. Depends on the
  [S6](#stops) claim being cleared. Strongest tier.
- **#4737.**
  - Write DG-001 to DG-003 as accepted engineering gates.
  - Run the equal-sounding-voice CPU, memory and quality comparison on both carriers. It needs a
    native artifact, which the checkout lacked when this was written.
  - Write the convergence ADR.
  - Depends on [S5](#stops) only for the project-wide voice-budget clause. Strongest tier.
- **#3645.** Record the backend-reported buffer and rate capability and the restart and refusal
  behaviour on each claimed desktop platform. Write the truthful-controls ADR and file the
  implementation spec. Platforms without reachable hardware are blocker [B1](#stops). Strongest
  tier.
- **#3708.** Build the deterministic question corpus and the authority matrix, and score the
  current explain context before any model call. Choose the help authority as an engineering
  decision: canonical source when the manual, UI contracts and registry disagree. Write the ADR and
  file the help-projection spec. Provider runs depend on [S1](#stops). Standard tier.
- **#4608.** Run the Q-002 primary-source survey of English DiffSinger voicebanks and vocoders and
  their exact redistribution terms. The ADR waits on [S2](#stops). Standard tier.
- **#4677.** Read the AMT model card and paper for training sources, then trace each source's
  licence. The ADR waits on [S3](#stops). Standard tier.
- **#4723.** Read the FFmpeg licensing FAQ, the current H.264 and AAC pool terms for decode-only and
  stream-copy use, and comparable Electron creative tools. Check WebCodecs equivalence for the
  browser target. The ADR waits on [S4](#stops). Standard tier.

## Operating loop

Run on every pickup:

1. Read this campaign, the ledger issue, AGENTS.md, and every authority above. Load the
   `delivery-orchestration` skill before any review or delivery script.
2. Reconcile live state:
   - each child's state, labels, claim and last body section;
   - open and merged PRs naming a child;
   - `git worktree list` and the branches, classifying every lane by path, branch, owner and state;
   - the ADR index on `origin/main`;
   - private probe artifacts.

   Repair ledger and child drift before trusting status. Never seize an active or unknown lane.
3. Pick the highest-priority dependency-ready stream that fits current capacity: live-lane cap,
   guard admission, the single ADR slot, and reviewer availability. Priority follows child
   `priority:` labels.
4. Dispatch it to one owner. Give the owner the objective, ledger, repository, lane, branch, scope,
   exclusions, dependencies, acceptance checks and PR policy. Require back only status, changed
   paths, branch, PR, head, decisive checks, and blockers. Reproduce every claim the ADR rests on
   from a primary source or a guarded run. An ADR PR goes through:
   1. `lane:open --type docs`;
   2. a commit;
   3. `lane:publish`, without `--relates`, so the child closes on merge;
   4. `review:prepare`;
   5. blind review at the risk plan's floor;
   6. the orchestrator's global review;
   7. `review:publish`;
   8. `Gate`;
   9. `deliver`.
5. Record progress as a dated section on the child issue. Record decisions there and in the ADR.
   The ledger body carries no status.
6. Repeat until the [completion contract](#completion-contract) passes, or until every remaining
   stream waits on a named stop.

## Stops

No human was available when this was written. Each question records its options and a recommended
answer, and the campaign stays `draft` until the owner answers the blocking ones.

- **S1, spend, blocks #3708 provider evaluation only.** Should a hosted-provider evaluation run be
  funded now?
  - **Recommended: no hosted spend now.** Resolve #3708 on the deterministic corpus plus the
    admitted local WebLLM routes (ADR 0037). Hosted scoring moves into the help-projection spec's
    acceptance. Cost: hosted answer quality is unmeasured when the authority is chosen.
  - Fund a capped hosted run now, through native provider sessions (ADR 0028). Cost: provider spend
    and credential handling.
  - Defer #3708. Cost: explain chat stays without a help authority.
- **S2, legal, blocks the #4608 ADR.** Which voice licence posture is acceptable?
  - **Recommended: permissive licences only (MIT, Apache-2.0 or equivalent) for both voicebank and
    vocoder.** If the Q-002 survey finds no such pair, the ADR withholds browser singing and the
    issue closes on that finding. Cost: browser singing may not ship.
  - Ask counsel whether the CC-BY-NC-SA vocoder fits Sourdaw's distribution. Cost: legal fees, and
    the only tested voice is Chinese.
  - Commission a first-party English voicebank. Cost: large spend and lead time.
- **S3, legal, blocks the #4677 ADR.** What does AMT need to clear for commercial shipping?
  - **Recommended: withhold AMT unless the survey shows every training source permits commercial
    redistribution of derived weights.** Ship v1 Session Player rule-engine-only, with Composer's
    Assistant v2 benchmarking filed as follow-up. Cost: no neural tier in v1.
  - Accept the Apache-2.0 tag with a recorded provenance gap, as ADR 0037 did for build provenance.
    Cost: legal exposure.
  - Commission a counsel review. Cost: spend and delay.
- **S4, legal and patent, blocks the #4723 ADR.** Which FFmpeg build and distribution posture?
  - **Recommended: an LGPL-only build.** Use demux plus audio decode for extraction and stream-copy
    video for muxed export, with no video encode anywhere. The linking form is whatever the survey
    shows LGPL compliance requires. Use WebCodecs in the browser only if it matches. Cost: no future
    video transcoding without a new ADR.
  - Use the user's system FFmpeg and bundle none. Cost: detection, onboarding, and a version matrix.
  - Bundle a GPL build. Cost: the distribution falls under GPL terms, against the Apache-2.0
    posture, and patent exposure remains.
- **S5, product behaviour, blocks only the voice-budget clause of the #4737 ADR.** Should voices be
  budgeted per device or project-wide?
  - **Recommended: keep device-local voice policies.** No instrument can steal another's notes.
    Cost: no project-wide memory budget.
  - Use a project-wide voice budget. Cost: a user-visible cross-instrument stealing change.
- **S6, ownership, blocks #4682.** The child has carried `status:active` since 2026-10-11, without a
  lane, PR, or branch commits of its own. Its owner is unknown.
  - **Recommended: the owner confirms the claim is abandoned.** The orchestrator then re-claims it
    with `pnpm issue:claim`. Cost: none if it is truly stale.
  - Wait for the claimant to surface. Cost: the runtime ADR, #4681 and #4637 stay blocked.
- **B1, access blocker, not a question.** Device evidence for #3645 on any claimed desktop platform
  without reachable hardware stays blocked until access exists. That platform's row in the ADR is
  recorded as an explicit unsupported state, never as an inert control.
