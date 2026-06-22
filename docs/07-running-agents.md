# Running agents

*Works today — plain markdown plus your agent; no Swarm tooling required.*

Run is the step where the task packet leaves your hands. Hand it to whatever
does the work — Claude Code, Codex, Cursor, Aider, or a human colleague.
Swarm does not run agents and does not care which one you use: the packet is
plain markdown, and anything that can read a file can work from it.

## Handing off

Point the agent at the task file and let it follow the sources from there:

```
Read tasks/auth-refresh.md and do what it says.
```

You don't need a prompt preamble. The standing rules live in the task
template's **Agent instructions** section — read the sources first, stay in
scope or stop and say why, run every Verify item and paste real output,
self-review the diff, leave a run summary. They travel with every task, so
every agent gets the same brief.

## Workers and scouts

When you delegate, be clear which of two things you are spawning:

- A **task worker** boots from the packet, owns a write scope, and leaves a run
  summary — its work merges. A worker that produces edits while bypassing the
  packet (acting on an ad-hoc prompt) is the failure mode to catch: detailed
  briefs are what keep delegated agents from duplicating work or leaving gaps
  [[ANTHROPIC-MULTIAGENT]](research/sources.md#ANTHROPIC-MULTIAGENT).
- A **scout** is a read/research helper — it gathers, it doesn't merge, and it
  leaves no packet.

For a delegated task worker, the run summary's optional **Provenance** line
records the boot facts worth inspecting: which sources it read (`AGENTS.md`, the
task, the spec, any change plan), which guide(s) it loaded, its identity, and
its **isolation mode** (its own worktree, the shared tree, or patch-only). These
are *evidence to check at review*, not a trust token — and a delegated task with
none of them is itself the [review exception](08-reviewing-output.md) to
investigate (a guide can silently fail to load; a worker can edit with no packet
at all). When the worker cannot write the workspace, the lead fills the
Provenance line on merge-back. Lead-run and trivial tasks skip the line entirely
— it scales with delegation risk, never ceremony on clear work. For a
multi-worker run, the heavier [coordination record](reference/advanced-lifecycle.md)
carries the same facts per worker.

## One worktree and branch per task

Run each task in its own git worktree, on its own branch off the base —
named `swarm/<spec-slug>`, or `swarm/<spec-slug>/<task-slug>` when several
tasks split one spec:

```bash
git worktree add -b swarm/auth-refresh ../myrepo--auth-refresh main
```

Branch off a base you have reconciled with its remote: if local `main` is ahead of `origin/main`,
each task branch carries those unpushed commits into its PR. `swarm worktree create` flags this as
a non-fatal advisory; the [brownfield precondition](ADOPTING.md#code-repos) routes the decision to
a human.

Why this hygiene pays for itself:

- **Parallel tasks can't trample each other.** Each agent works in its own
  checkout; nothing it edits is visible to its neighbors until merge.
- **Review maps to one branch.** One task → one branch → one PR → one review
  packet. When something fails review, you know exactly which work to send back.
- **Abandoning a bad run is cheap** — remove the worktree, delete the branch,
  your main checkout never knew.

This is a convention — nothing in this repo enforces it; an agent told to
edit in place will edit in place. (The optional reference CLI's `swarm worktree`
sets up the isolated branch and checkout for you; you still launch your own
agent CLI inside it — swarm-cli prepares the loop, it does not run your agent.)

## The honest ceiling on parallelism

Worktrees isolate **file state, not intent**. Two agents in perfectly disjoint
files can still make incompatible decisions: duplicate helpers, divergent
naming, two different answers to the same design question. And every parallel
branch is another review you owe — the bottleneck is your attention, not agent
count. The practical ceiling is a few parallel streams, not fleets. When in
doubt, serialize: tasks are cheap to queue.

Worktrees also isolate file state, **not runtime state**. Two parallel tasks
that bind the same port, database, cache, or secret can still collide even with
disjoint files — give each task its own runtime fixtures (a port range, a
scratch DB, a separate cache) or serialize the ones that share. This is a
convention; nothing enforces it.

## What you get back

The last agent instruction has the agent fill the packet's **`## Run summary`**
section: changed files, one line per command citing its Verify paste, out-of-scope
edits, blocked questions. The pasted output lives under the Verify items; the
summary indexes it — the raw material the
[review packet](08-reviewing-output.md) reads, which is why
output must be pasted, not described. "Tests passed" without the output is
not evidence [[EVIBOUND]](research/sources.md#EVIBOUND); at review it is
recorded as Unverified, not Pass.

If the summary is missing or thin, ask for it before tearing anything down —
the worktree still exists and re-running a command costs seconds. Later, it's
archaeology. Keep the worktree until the **review packet is finalized**, too:
`swarm review` reconciles the live worktree diff, so removing the worktree (the
Close step) before the review is done means you can no longer re-run the
reconcile against that branch — review first, tear down after.

Two sequencing notes that follow from the worktree being a checkout of a commit.
**Fill the task packet's `## Run summary` (and any `## Affected areas` edits)
inside the worktree, not on the base branch** — `swarm review` reads the packet
from the branch under review, so edits made on `main` after `swarm worktree
create` are invisible to the reconcile. And **review the branch before you
merge**: reconciling the merged branch against `main` shows zero changed files
(the work is already in the base), so the self-report check has nothing to diff —
the useful reconcile is on the open branch while the filled packet and the diff
both live there. When the agent cannot write the workspace — a dedicated workspace
repo, a sandboxed runner — it emits the summary at the end of its run and the
runner or human relays it into the task packet at handoff. For per-kind depth
(a fix, a refactor, a migration, performance work), install the matching guide
from [the swarm-skills catalog](https://github.com/jcosta33/swarm-skills) on
top of the kit's implement-task.

## Self-review before handoff

Before leaving its summary — the packet's last instruction — the agent re-reads its
own diff as a skeptic: _what would a reviewer flag?_ This catches the cheap
stuff early: scope creep, leftover debug code, a requirement satisfied in
letter but not in spirit.

It does not replace review. Evaluators systematically favor their own output
[[SELFPREFER]](research/sources.md#SELFPREFER), so an agent grading itself is
structurally biased: self-review produces _fixes_, never a result. The
Pass/Fail call belongs to the next step, made by someone — or something —
that didn't write the code.

## Next

Judge what came back: [Reviewing output](08-reviewing-output.md).
