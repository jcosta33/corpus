# Ledger draft: Campaign issue for the open research questions

This is a sidecar to [the campaign](CAMPAIGN-resolve-sourdaw-research-issues.md). It holds the
field values for the project-native ledger. The values below are self-contained: they carry no
transient artifact names, paths or links.

File it from the primary checkout:

```
pnpm issue:file campaign --title "feat(campaign): resolve the open research questions" --fields <json of the fields below> --milestone "Campaign closure" --create
```

The Campaign form already applies `epic`, `status:tracking` and `project:features`. Do not attach
the children as sub-issues. Each child already has a parent issue carrying its gate, so the
Child issues field lists them by number instead.

## Priority

P1

## Objective

Answer the question of every research issue that was open, with a `research(` title, when this
campaign was locked, and record each answer as an accepted ADR. Each issue then closes, so its
parent spec or audit can rely on that answer as its gate. The set is locked to the children below.
A later research issue joins only when the owner adds it here.

## Completion contract

- Every child issue below is closed.
- Each child's final body section names:
  - the chosen option;
  - the finding IDs that carried it;
  - the ADR that records it;
  - any residual unconfirmed claim the owner accepted.
- Each ADR is accepted on `main`, indexed in the decisions README, and delivered by `pnpm deliver`
  from a PR bound to its child. One ADR may answer #4682 for both #4681 and #4637. A decision to
  withhold or defer is also an ADR.
- Every licence or admission decision (#4608, #4677, #4723) cites the primary licence or patent
  text it read. It records the owner's choice and claims no licence the source does not state.
- Work each decision leaves behind is filed with `pnpm issue:file` and linked from the closed child.
- This issue is closed and every campaign-created lane is removed with `pnpm lane:remove`.

## Authorities

Strength uses three terms: advisory, deterministic local, and isolated authority.

| Operation | Owner | Strength | Mechanism | Failure behaviour |
| --- | --- | --- | --- | --- |
| Intent, legal exposure, spend, product-behaviour change | José Costa | Advisory | Owner answers a Stops question. The answer is recorded on the child. Private legal advice never enters the public tracker. | The dependent child holds. Others continue. |
| Orchestration and adjudication | Orchestrator session | Advisory | AGENTS.md Delegation and Review. | Surfaces at review or after merge. |
| Ledger filing | Orchestrator | Deterministic local | `pnpm issue:file campaign` validates the template and open milestones. | Refused before any write. |
| Research progress and child state | Orchestrator, using the operator `gh` credential | Advisory | Dated child-body section, plus state and label corrections. | Unrejected. Each pickup rereads and repairs drift. |
| Issue claim | Orchestrator | Advisory | `pnpm issue:claim`. Never over a foreign `status:active`. | A second claimant is not rejected. That child stops. |
| Lane allocation | One implementation owner per lane | Deterministic local | `pnpm lane:open <issue> <slug> --type docs --model <model>`, with the author lock. | Refused. |
| Live-lane cap | Orchestrator | Advisory | AGENTS.md cap. No script enforces it. | Unrejected. Count live lanes before opening one. |
| Heavy execution | Implementation owner | Deterministic local once invoked | `pnpm guard --profile …`. | A kill or timeout is a stop. No unchanged retry. |
| Verification | PR CI `Gate` | Deterministic, hosted | Required by the `main` ruleset. Admission runs from the default branch. | Merge is blocked. |
| Review publication | Reviewer App | Deterministic local | `pnpm review:prepare` and `pnpm review:publish` refuse below the floor, above the cost ceiling, or on frozen PRs. | Refused before any write. |
| No self-approval | AGENTS.md Review | Advisory | Separate App identities. Both credentials are reachable under one user account. | No isolation. The orchestrator checks identities. |
| Merge | Author App, through `pnpm deliver`, plus the `main` ruleset | Deterministic, hosted | Requires APPROVE of the current head, resolved threads, squash, last-push approval and `Gate`, with no bypass actors. | Refused. Drift resets `Gate` and review. |
| Cleanup | Orchestrator | Deterministic local | `pnpm lane:remove` and `pnpm lane:cleanup`. | Refused, and the lane is retained. Never force-clean. |

## Operating loop

1. Read this campaign and every authority.
2. Reconcile repository, ledger, pull-request, worktree, worker and verification state from live
   evidence.
3. Repair ledger drift before trusting status.
4. Select the highest-priority dependency-ready work that fits current capacity and ownership. Only
   one ADR PR is live at a time, because ADR numbers and the decisions index are shared.
5. Execute through implementation, verification, review and integration gates. An ADR PR publishes
   without `--relates`, so its child closes on merge.
6. Record durable progress on child issues, not in this body.
7. Repeat until the completion contract passes or a named stop blocks progress.

## Stops

- **#3708, hosted-provider evaluation spend.**
  - Recommended: no hosted spend now. Decide on the deterministic corpus and admitted local routes,
    and move hosted scoring into the follow-up spec.
  - Alternatives: fund a capped hosted run, or defer.
- **#4608, voice licence posture.**
  - Recommended: permissive licences only. With no admissible pair, withhold browser singing.
  - Alternatives: counsel on CC-BY-NC-SA fit, or commission a first-party voicebank.
- **#4677, AMT provenance.**
  - Recommended: withhold AMT unless every training source permits commercial redistribution of
    derived weights. Ship v1 rule-engine-only.
  - Alternatives: accept the tag with a recorded gap, or commission a counsel review.
- **#4723, FFmpeg posture.**
  - Recommended: an LGPL-only build, with demux plus audio decode and stream-copy export. No video
    encode.
  - Alternatives: system FFmpeg, or a GPL build.
- **#4737, voice budget.**
  - Recommended: keep device-local voice policies.
  - Alternative: a project-wide budget, with cross-instrument stealing.
- **#4682, claim.** The child carries `status:active` with no lane, PR or branch commits of its own.
  - Recommended: the owner confirms it is abandoned, then the orchestrator re-claims it.
  - Alternative: wait.
- **#3645, access blocker.** A claimed desktop platform without reachable audio hardware is recorded
  as an explicit unsupported state until access exists.

## Child issues

#3645
#3708
#4608
#4677
#4682
#4723
#4737

## Non-goals

- Implementing any parent spec.
- Changing release admission flags or manifests.
- Adding FFmpeg.
- Exposing buffer or thread controls.
- Converging sampler engines.
- Re-parenting the children.
