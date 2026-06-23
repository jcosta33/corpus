# Running agents

_Works today — plain markdown plus your agent; no Corpus tooling required._

Run is where the task packet leaves your hands. Hand it to whatever does the work: Claude Code,
Codex, Cursor, Aider, or a human colleague. Corpus does not run agents and does not care which you
use. The packet is plain markdown, and anything that reads a file can work from it.

## Handing off

Point the agent at the task file and let it follow the sources from there:

```
Read tasks/auth-refresh.md and do what it says.
```

No preamble needed. The standing rules live in the task template's **Agent instructions**: read
the sources first, stay in scope or stop and say why, run every Verify item and paste real output,
self-review the diff, leave a run summary. They travel with every task, so every agent gets the same
brief.

## Workers and scouts

When you delegate, be clear which of two things you are spawning:

- A **task worker** boots from the packet, owns a write scope, and leaves a run summary. Its work
  merges. Catch the worker that edits while bypassing the packet, acting on an ad-hoc prompt:
  detailed briefs keep delegated agents from duplicating work or leaving gaps
  [[ANTHROPIC-MULTIAGENT]](research/sources.md#ANTHROPIC-MULTIAGENT).
- A **scout** is a read/research helper. It gathers, doesn't merge, leaves no packet.

For a delegated worker, the run summary's optional **Provenance** line records the boot facts worth
inspecting: which sources it read (`AGENTS.md`, the task, the spec, any change plan), which guide(s)
it loaded, its identity, and its **isolation mode** (its own worktree, the shared tree, or
patch-only). These are _evidence to check at review_, not a trust token. A delegated task with none
of them is itself the [review exception](08-reviewing-output.md) to investigate: a guide can
silently fail to load, and a worker can edit with no packet at all. When the worker can't write the
workspace, the lead fills the line on merge-back. Lead-run and trivial tasks skip it. It scales
with delegation risk, never ceremony on clear work. A multi-worker run keeps the same facts per
worker in the heavier [coordination record](reference/advanced-lifecycle.md).

## One worktree and branch per task

Run each task in its own git worktree, on its own branch off the base. Name it `corpus/<spec-slug>`,
or `corpus/<spec-slug>/<task-slug>` when several tasks split one spec:

```bash
git worktree add -b corpus/auth-refresh ../myrepo--auth-refresh main
```

Branch off a base reconciled with its remote. If local `main` is ahead of `origin/main`, each task
branch carries those unpushed commits into its PR. `corpus worktree create` flags this as a
non-fatal advisory; the [brownfield precondition](ADOPTING.md#code-repos) routes the decision to a
human.

Why this hygiene pays for itself:

- **Parallel tasks can't trample each other.** Each agent works in its own checkout. Nothing it
  edits is visible to its neighbors until merge.
- **Review maps to one branch.** One task → one branch → one PR → one review packet. When work
  fails review, you know exactly what to send back.
- **Abandoning a bad run is cheap.** Remove the worktree, delete the branch. Your main checkout
  never knew.

A convention — nothing enforces it, and an agent told to edit in place will. The optional reference
CLI's `corpus worktree` sets up the isolated branch and checkout for you. You still launch your own
agent CLI inside it: corpus-cli prepares the loop, it does not run your agent.

## The honest ceiling on parallelism

Worktrees isolate **file state, not intent**. Two agents in disjoint files can still make
incompatible decisions: duplicate helpers, divergent naming, two answers to one design question.
And every parallel branch is another review you owe. The bottleneck is your attention, not agent
count. The practical ceiling is a few parallel streams, not fleets. When in doubt, serialize — tasks
are cheap to queue.

They isolate file state, **not runtime state**, either. Two tasks that bind the same port,
database, cache, or secret can collide even with disjoint files. Give each its own runtime fixtures
(a port range, a scratch DB, a separate cache), or serialize the ones that share. A convention;
nothing enforces it.

## What you get back

The last agent instruction fills the packet's **`## Run summary`**: changed files, one line per
command citing its Verify paste, out-of-scope edits, blocked questions. The pasted output lives
under the Verify items. The summary indexes it for the [review packet](08-reviewing-output.md) to
read. That is why output must be pasted, not described. "Tests passed" without the output is not
evidence [[EVIBOUND]](research/sources.md#EVIBOUND); at review it is recorded as Unverified, not
Pass.

If the summary is missing or thin, ask for it before tearing anything down. The worktree still
exists, and re-running a command costs seconds. Later, it's archaeology.

Keep the worktree until the **review packet is finalized**. `corpus review` reconciles the live
worktree diff, so tearing it down at Close before review leaves you unable to re-run the reconcile.
Two notes follow from the worktree being a checkout of a commit. First, **fill the `## Run summary`
(and any `## Affected areas` edits) inside the worktree, not on the base.** `corpus review` reads the
packet from the branch under review, so edits made on `main` after `corpus worktree create` are
invisible. Second, **review before you merge.** A merged branch reconciled against `main` shows zero
changed files — the work is already in the base — so the check has nothing to diff. Reconcile on the
open branch, where the filled packet and the diff both live.

When the agent cannot write the workspace — a dedicated workspace repo, a sandboxed runner — it
emits the summary at the end of its run, and the runner or human relays it into the packet at
handoff. For per-kind depth (a fix, a refactor, a migration, performance work), install the matching
guide from [the corpus-skills catalog](https://github.com/jcosta33/corpus-skills) on top of the kit's
implement-task.

## Self-review before handoff

Before leaving its summary — the packet's last instruction — the agent re-reads its own diff as a
skeptic: _what would a reviewer flag?_ This catches the cheap stuff early: scope creep, leftover
debug code, a requirement satisfied in letter but not in spirit.

It does not replace review. Evaluators systematically favor their own output
[[SELFPREFER]](research/sources.md#SELFPREFER), so an agent grading itself is structurally biased.
Self-review produces _fixes_, never a result. The Pass/Fail call belongs to the next step, made by
someone — or something — that didn't write the code.

## Next

Judge what came back: [Reviewing output](08-reviewing-output.md).
