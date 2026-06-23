# Where files live

_Works today — plain markdown plus your agent; no Corpus tooling required._

Three pieces, three homes:

| Piece                    | What it is                                                                                                | Where it lives                                             |
| ------------------------ | --------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------- |
| **The Corpus framework** | The docs (this repository) and the [starter kit](https://github.com/jcosta33/corpus-starter-kit) you copy | Upstream. Read and copy from it; your work never goes here |
| **Your workspace**       | Your specs, tasks, reviews, and findings                                                                  | Its own repo, or a folder inside your code repo (below)    |
| **Your code repos**      | Where the code lives                                                                                      | Untouched. Corpus adds nothing to them                     |

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

- **Feature folders** (`specs/<feature>/`) hold durable intent. The spec plus whatever fed it
  (research, audit, PRD), side by side — requirement → evidence in one folder hop.
- **Type folders** (`intake/`, `tasks/`, `reviews/`, `findings/`, `inventory/`, `change-plans/`)
  hold the flow of work. **Committed, not scratch.** The review packet linking its PR is the
  record of what was done and how it was checked. `inventory/` and `change-plans/` appear only when
  structural work needs them (see [brownfield work](05-brownfield-and-change-plans.md)).

The workspace must be **version-controlled** — its own git repo, or committed inside your code
repo. It _is_ the durable record. An uncommitted workspace drifts: the commit lands, but the spec,
review, and finding that explain it are lost. A convention; nothing enforces it.

Both naming depths are valid. Flat files (`tasks/012-checkout-totals.md`) for small projects. A
folder per item with an `NNN-` prefix when items grow attachments. A file declares what it is in
its frontmatter (`type: spec`, `type: task`, …). The formats live in the
[kit templates](https://github.com/jcosta33/corpus-starter-kit/tree/main/templates/) and [artifact formats](reference/artifact-formats.md),
never restated here. `.agents/` holds only the tooling your agent CLI loads
(see [integrations](10-integrations.md)); your content never lives there.

## One repo or two?

Both are first-class:

- **Co-located** — a single-repo team keeps the same tree inside its code repo, optionally under a
  visible `corpus/` directory at the root. Same layout, one less repo.
- **Dedicated workspace repo** — the same kit in a repo of its own. Across several code repos, this
  is the **multi-repo workspace**: one spec store, one board, one set of decisions for the whole
  family. A Git-native, agent-readable form of the requirements store larger organizations already
  keep outside their code.

The rule: stay co-located while features live in one repo and the same people shape specs and merge
code. Go multi-repo when features routinely span repos — a spec inside repo A is invisible to repo
B's developers and drifts unowned — or when the people shaping specs aren't the people merging code.

Separation has a known cost: specs can drift from the code they describe. The review packet is
where that surfaces (see the drift note below).

## Your code repos stay clean

A code repo needs **nothing** to work with Corpus. At most:

- a one-line pointer in its `AGENTS.md` — `Corpus workspace: <path or url>; read the task packet
you are given`;
- the kit's `.gitignore.additions`, so anything transient an agent writes locally stays out of
  commits;
- optionally, the `implement-task` agent guide copied into the repo's skills directory
  (see [integrations](10-integrations.md)).

Task packets reach the agent by paste or by path. The PR stays the merge mechanism. It links the
review packet in the workspace; the packet is the record. A multi-repo workspace repeats the flow
per repo. One spec cuts repo-scoped tasks (each naming its repo's Commands sub-table); each repo's
PR links its own review packet back. Committed Corpus content — specs, reviews, findings — never
lives in code repos. A convention, nothing enforces it, but it keeps adoption from dirtying a
product repo.

## When specs change (and drift)

A spec is amended in place after review feedback. Edit the requirement, keep its ID, note any
material cut under "Dropped from sources". No regeneration step. Drift surfaces at review time: a
coverage row that no longer matches the code reads Fail or Unverified. A spec known to lag reality
is marked `stale` on the
[status board](https://github.com/jcosta33/corpus-starter-kit/blob/main/templates/status.md) until someone amends it.

## What lasts, and what ages out

After hundreds of artifacts, not everything should live forever. Records management gives a clean
test. A record is **durable** when it is evidence of a decision, **transitory** when it has
short-term value and no decision rides on it (NARA's transitory bar is "generally less than ~180
days") [[NARAGRS52]](research/sources.md#NARAGRS52). Split the workspace that way:

- **Durable records — keep for the repo's life, supersede, never delete.** Decisions (ADRs),
  specs of record, saved findings. A reversed decision is _kept and marked superseded_, with a
  pointer to its replacement, sequentially numbered and never reused
  [[NYGARDADR]](research/sources.md#NYGARDADR) [[MADR]](research/sources.md#MADR) — the
  status lifecycle (`proposed | accepted | deprecated | superseded-by-NNNN`) the ADR ledger already
  uses. Each carries a **named owner**. Documents without owners go stale
  [[SWEGBOOKDOCS]](research/sources.md#SWEGBOOKDOCS), and write-once rots: about 29% of popular
  repos already carry an outdated reference [[DOCROT]](research/sources.md#DOCROT).
- **Transitory output — let it age out.** Review packets, `corpus check` output, and run logs are
  evidence _of a moment_. Once the task closes and the durable record (the finding, the merged PR)
  captures what mattered, the rest belongs in **git history (the default archive)** or an
  `archive/` directory. Keep a **30–90-day retention window** — the band CI tools already use
  (GitHub Actions 90 days [[GHRETENTION]](research/sources.md#GHRETENTION), GitLab 30 [[GLRETENTION]](research/sources.md#GLRETENTION)). Don't
  let them pile up in the live tree.

Two conventions keep a large workspace navigable. **One canonical home per rule or decision.** At
scale the failure is _duplication_, not absence (Google's Borg had 7–10 overlapping setup docs, no
owner) [[SWEGBOOKDOCS]](research/sources.md#SWEGBOOKDOCS), so "no canonical owner" is a reviewable
defect. And the **board is the index.** A flat per-type folder plus `status.md` carrying
`ID · title · status · superseded-by` keeps hundreds of artifacts findable by search. All
convention; nothing enforces it. A `corpus check` that the `superseded_by` pointers resolve and the
index lists them is a named, not-yet-shipped follow-up
([ADR-0096](adrs/0096-artifact-lifecycle.md)).

## Next

- [Basic workflow](02-basic-workflow.md) — the loop these folders serve.
- [Writing specs](04-writing-specs.md) — what goes in `specs/<feature>/spec.md`.
- [Adopting Corpus](ADOPTING.md) — one copy of the kit sets this tree up.
