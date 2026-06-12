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

## One worktree and branch per task

Run each task in its own git worktree, on its own branch off the base —
named `swarm/<spec-slug>`, or `swarm/<spec-slug>/<task-slug>` when several
tasks split one spec:

```bash
git worktree add -b swarm/auth-refresh ../myrepo--auth-refresh main
```

Why this hygiene pays for itself:

- **Parallel tasks can't trample each other.** Each agent works in its own
  checkout; nothing it edits is visible to its neighbors until merge.
- **Review maps to one branch.** One task → one branch → one PR → one review
  packet. When something fails review, you know exactly which work to send back.
- **Abandoning a bad run is cheap** — remove the worktree, delete the branch,
  your main checkout never knew.

This is a convention — nothing in this repo enforces it; an agent told to
edit in place will edit in place. (Future CLI: `swarm worktree create` and
`swarm run` will set up the branch and launch the agent — today you run the
git command and your agent CLI yourself.)

## The honest ceiling on parallelism

Worktrees isolate **file state, not intent**. Two agents in perfectly disjoint
files can still make incompatible decisions: duplicate helpers, divergent
naming, two different answers to the same design question. And every parallel
branch is another review you owe — the bottleneck is your attention, not agent
count. The practical ceiling is a few parallel streams, not fleets. When in
doubt, serialize: tasks are cheap to queue.

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
archaeology. When the agent cannot write the workspace — an external workspace
repo, a sandboxed runner — it emits the summary at the end of its run and the
runner or human relays it into the task packet at handoff. For per-kind depth
(a fix, a refactor, a migration, performance work), load the matching guide
from `docs/library/code-skills/` in the Swarm repo on top of the kit's
implement-task.

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
