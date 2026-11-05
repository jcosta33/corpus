---
type: campaign
id: CAMPAIGN-resolve-open-research-issues
status: draft
ledger: unfiled — a Campaign issue in https://github.com/jcosta33/sourdaw/issues, filed with `pnpm issue:file campaign` (see Stops, L-1)
sources:
  - /Volumes/Development/sourdaw/AGENTS.md
  - /Volumes/Development/sourdaw/.agents/decisions/README.md
  - /Volumes/Development/sourdaw/.github/ISSUE_TEMPLATE/campaign.yml
  - /Volumes/Development/sourdaw/.github/ISSUE_TEMPLATE/research.yml
  - https://github.com/jcosta33/sourdaw/issues/3645
  - https://github.com/jcosta33/sourdaw/issues/3708
  - https://github.com/jcosta33/sourdaw/issues/4608
  - https://github.com/jcosta33/sourdaw/issues/4677
  - https://github.com/jcosta33/sourdaw/issues/4682
  - https://github.com/jcosta33/sourdaw/issues/4723
  - https://github.com/jcosta33/sourdaw/issues/4737
---

## Objective

Bring every research issue in `jcosta33/sourdaw` that was open at campaign lock with a title
starting `research(` to a decided, closed state: #3645, #3708, #4608, #4677, #4682, #4723, #4737.
Each closes on a durable decision that its downstream spec can build on. Research issues filed
after lock join only when the owner adds them to the ledger. All other backlog is out of scope.

## Completion contract

The campaign is complete when all of the following hold, checked live against GitHub and
`origin/main`:

1. Each of #3645, #3708, #4608, #4677, #4682, #4723 and #4737 has `state: CLOSED`
   (`gh issue view <n> --json state,stateReason,closedByPullRequestsReferences`).
2. Each closure rests on exactly one of these decision records:
   - a merged pull request on `main`, delivered through `pnpm deliver`, that adds an accepted ADR
     under `.agents/decisions/`, indexed in `.agents/decisions/README.md`, recording the selected
     option. The ADR states each of the issue's open questions as answered with a cited primary
     source or executed measurement, or marked `[unconfirmed]` and explicitly waived by the owner;
   - for a negative or deferral outcome, an owner decision recorded on the issue, closed as
     `not planned`, that names the evidence and the reversal condition.
3. Every decision that Stops marks as owner-owned (legal, spend, security, or product-claim
   consequence) is accepted by the owner in that record. An agent's acceptance does not satisfy
   this.
4. Each research issue body's final Findings and Advisory recommendation agree with its decision
   record. Each parent spec (#3684, #4607, #4676, #4681, #4722) and each named consumer (#4637,
   #4719, #4730) that depends on a decision cites it.
5. No decision record claims a measurement, confinement, license reading, or carrier result that
   was not executed. Every claimed figure is traceable to a run whose receipt the record names.

Constraints that must still hold at completion are listed under Constraints. A belief that a
question is probably settled never meets this contract.

## Constraints

- Gated code stays out until its decision merges: no FFmpeg binding in any crate manifest before
  #4723 is decided; no script-runtime package before #4682; no DiffSinger or AMT artifact
  referenced by a manifest or `MODEL_RELEASE_ADMISSION` before an exact-artifact ADR of the
  ADR 0030/0035/0037 shape; no buffer, rate or thread control shown before its owning runtime
  contract (#3645).
- ADR 0012 (neither target degrades the other) and ADR 0044 (two-carrier live playback) bind every
  option chosen for #3645, #4682, #4723 and #4737.
- ADRs are immutable and take the next unused number. Course changes supersede.
- Probes and benchmarks run through `pnpm guard`. Broad suites run in PR CI only.
- Secrets, private archives and session evidence stay in `~/.agents/artifacts`. The public tracker
  and ADRs cite primary sources, not private paths.
- Reviewers use economy or standard tiers only (AGENTS.md Review).

## Non-goals

Implementing the downstream specs (#3801, #4607, #4637, #4676, #4681, #4719, #4722, #4730) or any
feature these decisions unlock. Those specs only gain citations from this campaign.

## Workstreams

Stable ledger IDs, highest priority first. Dependency and write-overlap notes are durable. Status
lives in the ledger.

- #3708 (P1): help-authority contract for explain chat. Deterministic question corpus first. Hosted
  provider runs wait on Stop S-6.
- #4723 (P2): FFmpeg build, linking and patent posture. Primary-source license and patent-pool
  reading can run now. Acceptance waits on S-1.
- #3645 (P2): truthful native buffer, rate and thread controls. Needs a backend capability survey
  on each supported platform. Missing hardware access is a blocker, not a question.
- #4737 (P3): sampler runtime convergence and memory policy. Remaining both-carrier, equal-voice
  evidence can run now. DG-001 to DG-003 ratification waits on S-4.
- #4682 (P3): capability-secure script runtime for #4681 and #4637. Artifact-admission gaps must
  close before acceptance. Waits on S-5 and on L-2 (unknown active claim).
- #4677 (P3): AMT weights' commercial shippability. Provenance reading can run now. Acceptance
  waits on S-2.
- #4608 (P3): DiffSinger voicebank and vocoder. The Q-002 survey runs first and may make Q-001
  moot. Acceptance waits on S-3.

Sequencing: each ADR adds a file and edits the shared `.agents/decisions/README.md` index and the
ADR number sequence. Keep at most one ADR-landing lane live at a time, or stack it on the live one.
Evidence-only work that changes no tracked file may run in parallel. Any probe harness that touches
`crates/daw-dsp` feeds the wasm manifest and must not overlap a live lane on that closure.

## Authorities

Record this table in the ledger at filing. The project rules in AGENTS.md and the
delivery-orchestration skill govern how each operation runs.

| Operation | Owner | Strength | Mechanism | Failure behavior |
| --- | --- | --- | --- | --- |
| Ledger filing | Orchestrator | Deterministic local | `pnpm issue:file campaign …` validates the template schema and open milestones | Refusal: nothing filed. The campaign stays `draft` |
| Issue claim | Orchestrator | Deterministic local | `pnpm issue:claim <n>` (verified `jcosta33` credential) swaps status labels and moves the board | Refusal: the item is not started |
| Lane allocation | Orchestrator | Deterministic local, plus advisory | `pnpm lane:open <n> <slug> --type docs --model <model>` refuses missing types and locks `active:sourdaw-author`. The five-live-lane cap and write-disjointness are AGENTS.md instructions; no command was found that enforces them | Refusal: wait. A cap breach is a policy violation without a mechanical reject |
| Dispatch | Orchestrator | Advisory | Delegation briefs per AGENTS.md Delegation, one task per agent | No rejection: the orchestrator verifies returned evidence |
| Research evidence on issues | Orchestrator, operator account | Advisory | Manual `gh` body edits, or `pnpm issue:reconcile` digest-guarded edits at delivery | Manual edits have no reject. Reconcile refuses on digest drift |
| Local verification and probes | Author agent | Deterministic local | `pnpm guard --profile …` admits by free RAM and kills on RSS overrun | Timeout or RSS kill is a stop for that probe. Never rerun to green |
| Heavyweight CI | GitHub Actions | Isolated authority | `Gate` minted by `health-gates.yml` from the default branch, admitted only on the reviewer App's APPROVE label | Red or failed `Gate` blocks merge |
| Publication | Author App | Deterministic local | `pnpm lane:publish` (`--relates` for a slice that must not close its issue). It refuses uncommitted work and foreign commit identity | Refusal: nothing pushed |
| Review | Reviewer App, blind draws | Deterministic local | `pnpm review:prepare`, then `pnpm review:publish` refuses below the draw floor, above the cost ceiling, or after the five-round freeze | Refusal: no review posted. A frozen PR is respun |
| Merge | Author App | Isolated authority for the rules; deterministic local for identities | The live `main` ruleset (no bypass actors) requires a squash PR, one approval of the last push, resolved threads and `Gate`. `pnpm deliver` binds the approval to the current head | Any drift resets `Gate` and review |
| Cleanup | Lane-cleanup worker | Deterministic local | `pnpm lane:cleanup` / `pnpm lane:remove` with exact-head merge proof | Unknown activity retains the lane |
| Owner decisions (Stops) | José Costa | Advisory | A recorded acceptance in the ADR PR or on the issue | Missing: only the dependent acceptance is blocked |

Author and reviewer App credentials both sit in the primary checkout, inside one machine-account
trust boundary. Role separation is therefore deterministic local, not isolated. No claim that a
worker cannot approve its own work holds.

## Operating loop

On every pickup:

1. Read this campaign, the ledger, AGENTS.md, and the delivery-orchestration skill before any
   script.
2. Reconcile live state: each child issue's state, labels, body and comments; PRs referencing them;
   `git worktree list` classified by path, branch, owner and state; and `origin/main` ADRs. Repair
   ledger drift before trusting its status.
3. Take the highest-priority dependency-ready item that fits lane capacity and write-disjointness.
   Evidence work on an owner-gated item counts as ready. Only its acceptance waits.
4. Run it through the project gates. Evidence goes on the issue. A decision lands as an ADR lane
   through `lane:open`, `lane:publish`, blind review, the orchestrator's global review, and
   `deliver`.
5. Record progress in the ledger and on the child issue.
6. Repeat until the completion contract passes or every remaining item waits on a named Stop.

Never seize an active or unknown lane or issue claim. Never take over another owner's branch.

## Stops

Each Stop blocks only the acceptance named. Unattended trial: the question is recorded here with a
recommended answer, and work continues on everything independent.

- **S-1 (#4723, legal):** which FFmpeg build, linking mode, and patent posture does Sourdaw
  ship? Recommended: an LGPL-only build that demuxes and decodes audio for extraction and
  stream-copies the video for muxed export, with no video encoding. Use WebCodecs for the browser
  target (ADR 0012). Prefer dynamic linking. Accept only after counsel confirms current FFmpeg
  licensing and the H.264/AAC pool terms. Sourdaw is Apache-2.0, which weighs against a GPL build.
- **S-2 (#4677, legal):** may the AMT weights ship commercially given their training-data
  provenance? Recommended: accept AMT only if the model card, paper and every training-source
  license clearly permit commercial redistribution. Otherwise ship v1 rule-engine-only, the parent
  spec's documented fallback.
- **S-3 (#4608, legal and spend):** is CC-BY-NC-SA admissible, and may Sourdaw fund a first-party
  voicebank? Recommended: treat non-commercial licenses as inadmissible for an Apache-2.0
  distribution. Admit only a permissively licensed English pair found by the Q-002 survey, or
  defer browser singing. No commissioning spend without a separate owner decision.
- **S-4 (#4737, product):** ratify, amend or reject DG-001 to DG-003, and decide whether a
  project-wide voice budget is intended. Recommended: keep device-owned runtimes and device-local
  voice budgets. Accept gates only with figures from executed both-carrier evidence. Evaluate a
  narrow shared sample-source interface only where it preserves current output.
- **S-5 (#4682, security):** accept the script runtime and trust branch for third-party code.
  Recommended: QuickJS in WASM on the `integrity-verified-worker` branch. Use a maintained
  artifact or a reviewed reproducible patched build that closes the heap-accounting and
  typed-array admission gaps, with separate runtime, linear-memory and host limits.
- **S-6 (#3708, spend and product claim):** which providers form the acceptance matrix, what
  score blocks release, which production questions are product promises, and is there authority
  to spend on hosted-provider evaluation? Recommended: build the deterministic corpus and the
  help-authority matrix first, with no spend. Evaluate local routes. Run hosted routes only under
  an explicit owner budget. Prefer the hybrid generated snapshot.
- **L-1 (ledger):** file a new Campaign issue as the ledger. GitHub gives each issue one parent,
  and every child already has one (#430, #3684, #4607, #4676, #4681, #4722). Recommended: list the
  children by number in the ledger's Child issues field and do not re-parent them. Until it is
  filed, this campaign stays `draft`.
- **L-2 (#4682, unknown claim):** the issue carries `status:active`, but no lane or PR for it was
  found. Recommended: adopt it only after a fresh reconciliation finds no live lane, PR or
  in-flight update. Otherwise leave it with its claimant.
