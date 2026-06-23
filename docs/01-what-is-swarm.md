# What is Corpus?

_Works today — plain markdown plus your agent; no Corpus tooling required._

> **A spec and review workflow for teams coding with agents.** Tickets become specs, specs
> become agent-ready tasks, agent output becomes evidence you can review — plain markdown,
> any agent, no runtime.

Agents multiply code volume. Corpus cuts the coordination and review cost of that volume.
Generation outpaces validation, so Corpus invests in validation.

## The problem

Teams using agents hit the same five walls, in roughly this order:

- **Vague tickets.** "Improve session handling" — the agent picks one reading and builds it convincingly.
- **Re-pasted context.** The same constraints retyped into every prompt, then forgotten in the session where they mattered.
- **Agent drift.** Mid-task, the agent solves a nearby problem and touches three files nobody mentioned.
- **Giant unreviewable PRs.** Forty files of plausible code at once; nobody can say which requirement a hunk satisfies.
- **Lost findings.** "The staging DB truncates that column" evaporates with the session; the next one re-learns it the expensive way.

Each wall gets one small markdown artifact and the habit of working from it.

## Is — and is not

Corpus **is**:

- a spec format agents can work from
- a task-packet format that bounds agent work
- a review-packet format that shows where human attention goes
- a findings convention so lessons survive the session
- a starter kit of markdown templates
- a workspace convention

Corpus **is not**:

- an agent or agent runtime
- a compiler
- a programming language
- a Jira/Linear replacement
- a code generator
- a replacement for PRs and CI
- a docs portal
- a complete SDLC platform
- a formal verification system
- a guarantee that agent output is correct

## Where it sits among the tools you already use

| Adjacent product                                    | What it does                               | Corpus's relationship to it                                                                                                                                                                    |
| --------------------------------------------------- | ------------------------------------------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Coding agents** (Claude Code, Cursor, Copilot, …) | write the code                             | Corpus ships no agent. It shapes the inputs any agent works from and the output you review. Bring your own.                                                                                    |
| **Spec-driven workflows**                           | turn a written spec into an implementation | Same family. Corpus's bet is the review side: every requirement carries a verification method, and the packet shows the evidence per requirement. It stays small — templates, not a generator. |
| **Issue trackers** (Jira, Linear, GitHub Issues)    | hold the backlog and the conversation      | The ticket stays put. Corpus snapshots it into an intake file and interprets it into a spec an agent can act on. Nothing replaces the tracker.                                                 |
| **Docs portals** (wikis, Notion, docs sites)        | describe the system after the fact         | A Corpus spec is a working document — acceptance criteria, verification methods, open questions. It drives the change, not documents it later.                                                 |
| **Review tooling** (PRs, CI, review bots)           | gate the merge                             | Corpus keeps the PR. The review packet rides alongside it and points the reviewer where to look; CI output is the evidence the packet cites.                                                   |
| **Refactoring tooling** (codemods, OpenRewrite, …)  | execute mechanical change                  | The change plan states what must survive and how to check it; a codemod is one way a task executes a step of that plan.                                                                        |

## Optional and advanced

Optional on any task: Pull/intake · Inventory · Change Plan · a new spec for a covered bug
fix · a board row for trivial work. Each has a skip rule in
[the workflow](02-basic-workflow.md).

Advanced exists but is not part of the first path: audit and research artifacts, the
granular lifecycle, the richer result vocabulary, the memory model, the kit's optional
`advanced/` templates, the stance-and-depth catalog in
[corpus-skills](https://github.com/jcosta33/corpus-skills), and the entire CLI (future).

You start with four: spec, task, review, finding.

## What Corpus does not promise

- **No deterministic generation.** The same spec run twice yields two different diffs. A good spec narrows the space; it does not fix the output.
- **No automatic correctness.** Passing output pasted beside a requirement is strong evidence, not a certificate. Someone still decides to merge.
- **No formal verification.** Evidence means tests, commands, and their real output — not a mathematical proof.
- **No end of PR review.** The review packet directs human attention; it does not dismiss it.

One meta-promise, kept everywhere: **every rule says how strongly it is held**, on a
four-level honesty scale. A "MUST" never hides whether anything checks it.

- **convention** — recommended; nothing checks it.
- **checklist** — a human applies it at review time, by reading.
- **toolable** — a tool _could_ run it mechanically; the docs name the command (corpus-cli's `corpus check`).
- **enforced** — a shipped tool runs it and blocks. Nothing in _this_ repo enforces anything; it is markdown. The optional [corpus-cli](https://github.com/jcosta33/corpus-cli) makes the toolable checks runnable. The kit's gate enforces them in your CI.

Every check carries its level: [reference/checks.md](reference/checks.md).

## The failure modes it answers

Agents fail in predictable patterns. Each pattern is why a piece of Corpus exists.

| Failure mode                | What it looks like                                                                                                                                                                                                                     | What answers it                                                                                                                                                                  |
| --------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Drift**                   | the agent solves _a_ problem, not _the_ problem                                                                                                                                                                                        | the task packet: an explicit scope and a "Do not change" list                                                                                                                    |
| **Ambiguous input**         | ambiguity measurably degrades generated code, and models do not reliably flag or resolve it on their own [[ORCHID]](research/sources.md#ORCHID) [[HUMANEVALCOMM]](research/sources.md#HUMANEVALCOMM)                                   | requirements written one per ID, each with its own verification method                                                                                                           |
| **Lost handoff**            | the handoff from plan to implementation is — on preliminary evidence — the dominant failure surface in multi-agent code generation [[PLANCODER]](research/sources.md#PLANCODER)                                                        | the handoff is a written, bounded task packet — not a chat message                                                                                                               |
| **Hallucinated completion** | "done," but nothing was checked — in a randomized trial, developers _believed_ they were ~20% faster with AI while _measuring_ ~19% slower [[METR]](research/sources.md#METR) (preliminary: 16 experienced developers on mature repos) | a Pass needs pasted output, a CI link, or a named human's recorded observation (manual checks). An empty Evidence cell means Unverified, never Pass — a review checklist rule.   |
| **No resumable trail**      | the session ends mid-stride; the next one starts from zero                                                                                                                                                                             | work externalized to files: intake, spec, task, review. Writing intermediate work down measurably improves multi-step performance [[SCRATCHPAD]](research/sources.md#SCRATCHPAD) |
| **Repeated mistakes**       | the same class of bug returns every few sessions                                                                                                                                                                                       | findings saved at Close, kept where the next task will look                                                                                                                      |

## Restraint

Corpus stays useful by staying small.

- **Fewer files.** Write what the work needs; skip the rest. The workflow names the skip-paths — no guilt.
- **Every file useful.** If a file changes neither what the agent does nor what the reviewer checks, don't write it.
- **Evidence over planning prose.** A pasted test run beats a page of plan.

Next: [the basic workflow](02-basic-workflow.md) — from ticket to merged, reviewed change.
