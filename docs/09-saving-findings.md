# Saving findings

*Works today — plain markdown plus your agent; no Swarm tooling required.*

Close is the last step of the loop. The merge happened; the review packet records what was
verified. What's left is the part most teams skip: keeping what the work taught you. An
agent session ends and its context evaporates — anything not written to a file is gone.
Writing intermediate state to durable files measurably helps multi-step work, and is the recommended pattern for work that spans sessions
[[CTXENG]](research/sources.md#CTXENG) [[SCRATCHPAD]](research/sources.md#SCRATCHPAD).

## The honest weakness

A hand-edited board and a findings folder are willpower in markdown — the same discipline
wikis die of. Two structural prompts are built in so the habit isn't bare: the review
packet routes **new finding candidates** as an exception class (the reviewer sees them),
and the agent guides end every task with "anything learned worth saving as a finding."
A future `swarm close` will prompt for both; until then this is a convention, and saying
so beats pretending otherwise.

## The one rule

> **Before closing a task, record anything durable as a finding.**

This is a convention — nothing in this repo enforces it. It costs one short file in
`findings/`, written from the frozen template at
[`templates/finding.md`](https://github.com/jcosta33/swarm-starter-kit/blob/main/templates/finding.md): what we learned,
the evidence, where it applies, where it does not, and what to do differently next time.
The task packet's Findings section is the staging area — at Close, anything sitting there
moves to `findings/` or gets dropped deliberately.

## What counts as a finding

Durable means _the next task would want to know this_:

- **provider quirks** — "the payments sandbox rate-limits at 10 rps; the docs say 100"
- **hidden contracts** — "the export job assumes `user.email` is never null"
- **decisions** — "we retry idempotent calls only; rationale in the review packet" (a
  decision big enough to outlive one feature graduates to an ADR in `decisions/`)
- **gotchas** — "the test suite passes locally with a stale fixture; regenerate first"

What does **not** count: run logs, transcripts, "the tests passed" (that lives in the review
packet), local environment details, anything you'd never grep for again. A finding states
one claim — if you're writing three, write three findings.

## How findings come back

There is no retrieval engine. Findings return through two cheap channels:

- **the board** — `status.md` lists findings pending acceptance, so they get read and either
  accepted or marked stale instead of rotting;
- **grep** — findings are plain markdown with real words in them; "what do we know about
  the payments sandbox?" is one search away. Write titles you would search for.

When you write the next spec or task packet that touches the same area, link the finding in
its sources. That is the whole feedback loop: lessons from one task become input to the next.

## Update the board

Close ends with a board update in `status.md`
([template](https://github.com/jcosta33/swarm-starter-kit/blob/main/templates/status.md)): mark the task closed, link its review
packet, list the new finding as pending acceptance, and refresh the Human attention list
(blocking questions on draft specs · tasks with no review packet · findings pending
acceptance). One honest rule, at checklist level: **a "verified" or "done" claim on the
board links its review packet** — a board full of unlinked "done" rows is a wish list, not
a status.

The board is hand-edited and stays small. (Future CLI: `swarm status` will derive per-spec
coverage from the review packets — today the board is the hand-kept summary.)

## When you outgrow this

A `findings/` folder plus grep carries a team surprisingly far. Teams with hundreds of
findings, multiple repos, or recurring cross-feature patterns adopt the advanced memory
model — a load-when index, a glossary, and patterns built from corroborated findings. It
lives at [`reference/memory.md`](reference/memory.md); adopt it when grep stops being
enough, not before.

That's the loop closed: [pull the next piece of work](02-basic-workflow.md).
