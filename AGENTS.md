# AGENTS.md — working on the Swarm framework

## What this repo is

This repo **is** the Swarm framework — *a lightweight spec and review workflow for teams using
coding agents*, shipped as markdown: the docs and the checks contract (the copy-whole starter
kit ships as the sibling `swarm-starter-kit` template repo). It ships **no runtime**:
anything described as checkable names its checker (the reference implementation in progress is
`swarm-cli`, a sibling repo); everything else is convention or review checklist, and says so.

- `docs/` — the product: a numbered happy path (`01`–`10`), `reference/` (the deep layer:
  structured requirements, checks, step bars, artifact formats, advanced lifecycle, future CLI,
  memory), `examples/` (three flagship walkthroughs; `large-pr-review.md` is the demo),
  `ADOPTING.md`, `adrs/` (the decision ledger), `research/sources.md` (the evidence bibliography).
- `checks/` — the checks contract as data (`checks.yaml`) + fixtures (test data for
  `docs/reference/checks.md`; swarm-cli's oracle). `.agents/` — a small dev-skills subset
  (see `.agents/SKILLS-MANIFEST.md`).
- The starter kit ships as its own template repo, `../swarm-starter-kit` (ADR-0075): a
  complete workspace adopters copy whole — the core loop guides plus the workspace
  authoring guides at `.agents/skills/`, `templates/`, `advanced/` (optional templates +
  reference cards). Conditioning stances and code-depth guides live in `../swarm-skills`.

## Swarm workspace

Swarm workspace: `../swarm-hq` (the family's multi-repo workspace). Specs, tasks, reviews,
findings, audits, and the board for changes to this repo live there — read the task packet you
are given. Accepted framework decisions still land here, in `docs/adrs/`.

## Startup

1. Read the current task/request first; load only the skill or reference it names.
2. Treat the ADRs (`docs/adrs/`) as the recorded intent for every format and vocabulary rule.
3. Map every completion claim to evidence — paste real output; a claim without it is unverified.
4. Adversarial self-review before declaring done (ADR-0056): re-read your own diff as a skeptic;
   never self-issue a review verdict.

## Universal rules

- **Fresh-product voice.** No migration framing ("previously/renamed/now") anywhere except
  `docs/adrs/`. The framework is presented as originally designed.
- **Honesty framework (ADR-0063).** Rules carry a level: convention · checklist · toolable
  (names swarm-cli's command) · enforced (only with a shipped tool — today, nothing). Never
  write enforcement-sounding claims without a level.
- **Vocabulary tiers (ADR-0057).** User tier (README, `docs/01–10`, `docs/examples/`,
  kit core): step · requirement/AC · evidence · review result (Pass/Fail/Unverified/Blocked) ·
  checks · structured requirements · writing rules · workspace · save a finding. Reference tier
  may also use the precise internal terms (pass, obligation, proof, verdict, SOL codes);
  `docs/reference/glossary.md` maps both directions.
- **No counts ceremony.** Closed-set cardinalities live in exactly two places:
  `checks/README.md` (producer reconciliation note) and the cheatsheet appendix.
  Everywhere else lists values, never counts.
- **Citations are contextual.** Every load-bearing empirical claim cites a verified entry
  inline — the `[[KEY]]` form linking the matching anchor in `docs/research/sources.md` — and the citation moves with the claim.
  Non-verified sources never carry a MUST-level claim; fact-shaped statements without a
  source are labeled design rationale. Web-verify before adding to `sources.md`.
- **Single-sourcing.** Formats are frozen in ADRs 0058/0060/0061/0067/0068 and shipped at
  the kit repo's `templates/` (`../swarm-starter-kit`) — everything else links, never
  restates. A rule lands in `docs/` first; the kit repo, the swarm-skills catalog, and the
  dev skills derive from it (a format change is a two-repo change, cut and reviewed from
  swarm-hq).

## Pointers

- Decisions: `docs/adrs/README.md` (0001–0098; 0057+ are the current architecture, 0094–0098 the latest)
- Workspace (specs, audits, plans, board): `../swarm-hq`
- The starter kit: `../swarm-starter-kit` (github.com/jcosta33/swarm-starter-kit)
- Optional guide catalog: `../swarm-skills` (github.com/jcosta33/swarm-skills)
- Claude Code agent catalog: `../swarm-agents` (github.com/jcosta33/swarm-agents — ADR-0092;
  Claude-Code-first worker definitions + the delegation hook; honest scope: toolable/partial)
- Dev skills (the small subset for working on this repo): `.agents/skills/` — see
  `.agents/SKILLS-MANIFEST.md`
- Evidence: `docs/research/sources.md` (verified / caveated / rejected — never cite rejected)

## Commands

| Slot | Command | Resolves |
|---|---|---|
| — | (none) | markdown-only repo; coherence is checked by review (the swarm-hq workspace cuts and reviews the tasks) |

## Workflow

Work from `main`: commit and push directly to `main` (producer convention only — adopters
follow their own branching; tasks run in worktrees per `docs/07-running-agents.md`).
Commit messages end: `Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>`.

## Compatibility

`CLAUDE.md` and `GEMINI.md` are symlinks to this file — one bootloader, many agent tools.

<!-- swarm:start -->
This repository is adopted into a Swarm workflow. The spec / task / review
workspace and templates come from the Swarm starter kit
(github.com/jcosta33/swarm-starter-kit). Run `swarm --help` for the commands.
<!-- swarm:end -->
