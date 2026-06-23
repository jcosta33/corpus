# Where files live

*Works today — plain markdown plus your agent; no Corpus tooling required.*

Three pieces, three homes:

| Piece                   | What it is                                                            | Where it lives                                                 |
| ----------------------- | --------------------------------------------------------------------- | -------------------------------------------------------------- |
| **The Corpus framework** | The docs (this repository) and the [starter kit](https://github.com/jcosta33/swarm-starter-kit) you copy | Upstream. You read and copy from it; your work never goes here |
| **Your workspace**      | Where your specs, tasks, reviews, and findings live                   | Its own repo, or a folder inside your code repo (below)        |
| **Your code repos**     | Where the code lives                                                  | Untouched — Corpus adds nothing to them                         |

## The workspace

```text
your-workspace/
  AGENTS.md              # the bootloader (CLAUDE.md / GEMINI.md symlink to it)
  specs/
    checkout/            # one folder per feature — durable intent
      spec.md            #   the spec
      research.md        #   supporting docs sit beside the spec they serve
  intake/                # tracker items, captured verbatim (see 10-integrations.md)
  tasks/                 # task packets — one per unit of agent work
  reviews/               # review packets — the durable record of each task
  findings/              # lessons saved at Close
  inventory/             # appears when structural work needs it
  change-plans/          # appears when structural work needs it
  decisions/             # project decisions, numbered (0001-, 0002-, …)
  templates/             # the kit templates you copied in
  advanced/              # optional templates and reference cards — copy pieces when needed
  examples/              # one worked chain — read it, then delete it
  status.md              # the hand-edited workboard
  .agents/               # agent tooling — guides live in .agents/skills/
  .claude/skills         # symlink -> .agents/skills (tool adapter; never content)
  .gitignore.additions   # lines for your CODE repos' .gitignore
```

Two kinds of folder:

- **Feature folders** (`specs/<feature>/`) hold durable intent: the spec plus whatever fed it
  (research, audit, PRD), side by side — so requirement → evidence is one folder hop.
- **Type folders** (`intake/`, `tasks/`, `reviews/`, `findings/`, `inventory/`, `change-plans/`)
  hold the flow of work. They are **committed, not scratch** — the review packet that links its PR
  is the record of what was done and how it was checked. `inventory/` and `change-plans/` appear
  only when structural work needs them (see [brownfield work](05-brownfield-and-change-plans.md)).

The workspace itself must be **version-controlled** — a git repo of its own, or committed inside
your code repo. It *is* the durable record; an uncommitted workspace (a local folder that was
never `git init`'d) silently drifts from the code it describes, leaving the commit but losing the
spec, review, and finding that explain it. This is a convention — nothing enforces it.

Both naming depths are valid: flat files (`tasks/012-checkout-totals.md`) for small projects, or a
folder per item with an `NNN-` prefix when items grow attachments. A file declares what it is in
its frontmatter (`type: spec`, `type: task`, …) — the formats live in the
[kit templates](https://github.com/jcosta33/swarm-starter-kit/tree/main/templates/) and [artifact formats](reference/artifact-formats.md);
this page never restates them. `.agents/` holds only the tooling your agent CLI loads
(see [integrations](10-integrations.md)); your content never lives there.

## One repo or two?

Both are first-class:

- **Co-located** — a single-repo team keeps the same tree inside its code repo, optionally under a
  visible `swarm/` directory at the root. Same layout, one less repo.
- **Dedicated workspace repo** — the same kit installed in a repo of its own. When it governs
  several code repos, that is the **multi-repo workspace**: one spec store, one board, one set
  of decisions for the whole family. Think of it as a Git-native, agent-readable form of the
  requirements store larger organizations already keep outside their code.

The decision rule: stay co-located while features live in one repo and the same people shape
specs and merge code; use the multi-repo workspace when features routinely span repos — a spec
inside repo A is invisible to repo B's developers and drifts unowned — or when the people
shaping specs are not the people merging code.

Separation has a known cost — specs can drift from the code they describe. The review packet is
where that surfaces; see the drift note below.

## Your code repos stay clean

A code repo needs **nothing** to work with Corpus. At most:

- a one-line pointer in its `AGENTS.md` — `Corpus workspace: <path or url>; read the task packet
you are given`;
- the kit's `.gitignore.additions`, so anything transient an agent writes locally stays out of
  commits;
- optionally, the `implement-task` agent guide copied into the repo's skills directory
  (see [integrations](10-integrations.md)).

Task packets reach the agent by paste or by path. The PR remains the merge mechanism; it links the
review packet in the workspace, and the packet is the record. In a multi-repo workspace the same
flow repeats per repo: one spec cuts repo-scoped tasks (each naming its repo's Commands
sub-table), and each code repo's PR links its own review packet back in the workspace. Committed Corpus content in code
repos — specs, reviews, findings — stays out of bounds. That is a convention — nothing in this
repo enforces it — but it is what keeps adoption from dirtying a single product repo.

## When specs change (and drift)

A spec is amended in place after review feedback: edit the requirement, keep its ID, and note any
material cut under "Dropped from sources". There is no regeneration step. Drift between workspace
and code surfaces at review time — a coverage row that no longer matches the code reads Fail or
Unverified — and a spec known to lag reality is marked `stale` on the
[status board](https://github.com/jcosta33/swarm-starter-kit/blob/main/templates/status.md) until someone amends it.

## What lasts, and what ages out

After hundreds of artifacts, not everything should live forever. Records management gives a clean
test: a record is **durable** when it is evidence of a decision; it is **transitory** when it has
short-term value and no decision rides on it (NARA's transitory bar is "generally less than ~180
days") [[NARAGRS52]](research/sources.md#NARAGRS52). Split the workspace that way:

- **Durable records — keep for the repo's life, supersede, never delete.** Decisions (ADRs),
  specs of record, and saved findings. A reversed decision is *kept and marked superseded* with a
  pointer to its replacement, sequentially numbered and never reused
  [[NYGARDADR]](research/sources.md#NYGARDADR) [[MADR]](research/sources.md#MADR) — the same
  status lifecycle (`proposed | accepted | deprecated | superseded-by-NNNN`) the ADR ledger already
  uses. Each carries a **named owner**, because documents without owners go stale
  [[SWEGBOOKDOCS]](research/sources.md#SWEGBOOKDOCS), and write-once rots — about 29% of popular
  repos already carry an outdated reference [[DOCROT]](research/sources.md#DOCROT).
- **Transitory output — let it age out.** Review packets, `swarm check` output, and run logs are
  evidence *of a moment*; once the task is closed and the durable record (the finding, the merged
  PR) captures what mattered, the rest belongs in **git history (the default archive)** or an
  `archive/` directory, on a **30–90-day retention window** — the band CI tools already use
  (GitHub Actions 90 days [[GHRETENTION]](research/sources.md#GHRETENTION), GitLab 30 [[GLRETENTION]](research/sources.md#GLRETENTION)). Don't
  accumulate them in the live tree forever.

Two conventions keep a large workspace navigable. **One canonical home per rule or decision** — the
failure that bites at scale is *duplication*, not absence (Google's Borg had 7–10 overlapping
setup docs, no owner) [[SWEGBOOKDOCS]](research/sources.md#SWEGBOOKDOCS), so "no canonical owner" is a
reviewable defect. And the **board is the index**: a flat per-type folder plus `status.md` carrying
`ID · title · status · superseded-by` keeps hundreds of artifacts findable by search over a flat
list. All of this is convention — nothing enforces it; a `swarm check` that the `superseded_by`
pointers resolve and the index lists them is a named, not-yet-shipped follow-up
([ADR-0096](adrs/0096-artifact-lifecycle.md)).

## Next

- [Basic workflow](02-basic-workflow.md) — the loop these folders serve.
- [Writing specs](04-writing-specs.md) — what goes in `specs/<feature>/spec.md`.
- [Adopting Corpus](ADOPTING.md) — one copy of the kit sets this tree up.
