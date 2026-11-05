# Evidence receipt: live state when the campaign was written

This is a sidecar to [the campaign](CAMPAIGN-resolve-sourdaw-research-issues.md). It is a snapshot
of live state on 2026-11-05 (around 09:11 UTC). The campaign deliberately keeps none of this
mutable state. Every pickup re-derives it.

## Repository

- `origin/main` was at `aa4d3e02f4951f8dfca455e92cb9b56bf9ed388e`, checked with `git ls-remote`.
- The primary checkout `/Volumes/Development/sourdaw` was on `main` at the same commit. It had only
  untracked operational paths under `.agents/`, `.local/` and `.review-private/`.
- The licence is Apache-2.0, per `LICENSE` and the `"license"` field in `package.json`.
- `core.hooksPath` is set to `.githooks`.

## Tracker

The tracker had 358 open issues, read with `gh issue list --state open --limit 1000`. Seven had
titles starting with `research(`.

| Issue | Priority | Status | Parent |
| --- | --- | --- | --- |
| #3645 audio-engine, truthful native buffer and processing controls | P2 | tracking | #3684 |
| #3708 ai, authoritative Sourdaw expertise for built-in chat | P1 | tracking | #3684 |
| #4608 ai, admissible DiffSinger voicebank and vocoder | P3 | tracking | #4607 |
| #4677 ai, whether AMT weights can ship commercially | P3 | tracking | #4676 |
| #4682 midi, capability-secure script runtime | P3 | **active** | #4681 |
| #4723 build, FFmpeg build, linking and patent posture | P2 | tracking | #4722 |
| #4737 daw-dsp, sample-playback runtime convergence | P3 | tracking | #430 |

Other tracker facts:

- **Pull requests.** None of the seven had sub-issues or open PRs: 19 open PRs were checked by title
  and body, plus each child's cross-reference timeline.
- **Ledger.** No existing Campaign issue covers this set. #430, "exhaust Sourdaw gaps portfolio",
  is broader, so it was rejected as the ledger.
- **#4682 claim.** `status:active` was applied by `jcosta33` on 2026-10-11T17:06:35Z. The last body
  update was dated 2026-10-28. No worktree exists for it.
  - Local branch `agent/4682/capability-secure-script-runtime` exists, last commit 2026-10-11.
  - It has zero commits beyond `main` and is an ancestor of `main`.
  - It has no matching remote head.
  - Its owner is unknown, so it is classified foreign and empty, and left untouched.
- **#3708.** A 2026-11-04 owner comment confirms that R-003 is fixed by #4222. The central gap
  remains.
- **Dependent issue states.**
  - Open: #4607, #4676, #4681, #4637, #4722, #4719, #4730, #3801, #4732, #4733, #2375, #3684, #3806,
    #430.
  - Closed: #3643, #3566, #3402, #3668.
- **Milestones.** Open milestones include "Campaign closure", which #430, #5873 and #6062 use.

## Lanes

`git worktree list --porcelain` reported 285 worktrees, 277 of them locked:

- the primary checkout;
- two detached worktrees under `~/.agents/artifacts`;
- 149 detached review worktrees under `.agents/review-worktrees/`;
- 133 author lanes under `.agents/worktrees/`.

No worktree path or branch names a campaign child. All existing lanes belong to other owners and
are read-only for this campaign. Live author lanes far exceed the AGENTS.md cap of five live lanes.
`grep` over `scripts/*.ts` found no code enforcing a lane cap.

## Delivery controls

- **`main` ruleset 20938734**, active, read with `gh api`. It sets:
  - deletion and non-fast-forward protection;
  - squash-only merges;
  - one approving review;
  - dismissal of stale reviews on push;
  - last-push approval;
  - resolved threads;
  - required status check `Gate`, non-strict;
  - an empty `bypass_actors` list.
- **Role credential files.** `.env.sourdaw-author` and `.env.sourdaw-reviewer` exist at the primary
  root with mode `0600` under one user account. Their contents were not read.
- **Operator credential.** `gh auth status` reports `jcosta33` logged in via the keyring.
- **Trusted scripts in `package.json`:**
  - `lane:open`, `lane:publish`, `lane:remove`, `lane:cleanup`, `lane:strand`, `lane:sync-parent`;
  - `issue:file`, `issue:claim`, `issue:reconcile`;
  - `review:prepare`, `review:publish`, `review:repair`, `review:confirm`;
  - `deliver`, `pr:supersede`, `pr:retire`, `guard`.
- **Review risk class.** `scripts/reviewRiskPolicy.ts` plans `docs-only` when every path is
  Markdown prose outside `public/`, and sets a floor of one stance for that class. Whether an ADR
  PR plans `docs-only` is decided by `review:prepare`'s `risk-plan.json`. This was not verified for
  `.agents/decisions/` paths.

## Not read, under the trial rules

- The `delivery-orchestration` skill and every other `SKILL.md`. The campaign cites the skill as
  the procedure authority without asserting its contents.
- Primary licence, patent-pool and model-card sources for #4608, #4677 and #4723. Those surveys are
  campaign work.
