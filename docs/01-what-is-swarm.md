# What is Corpus?

*Works today — plain markdown plus your agent; no Corpus tooling required.*

> **Corpus is a lightweight spec and review workflow for teams using coding agents.**
> Turn tickets into clear specs, specs into agent-ready tasks, and agent output into
> evidence you can review — plain markdown, any agent, no runtime.

The thesis behind it: coding agents increase code volume; Corpus reduces the coordination and
review cost of that volume. Generation outpaces validation — Corpus invests in the validation side.

## The problem

Teams using coding agents hit the same five walls, in roughly this order:

- **Vague tickets.** The ticket says "improve session handling"; the agent picks one of several
  readings and builds it convincingly.
- **Re-pasted context.** The same constraints get retyped into every session prompt — and
  forgotten in the one session where they mattered.
- **Agent drift.** Mid-task, the agent solves a nearby problem instead of the asked one, and
  touches three files nobody mentioned.
- **Giant unreviewable PRs.** Forty files of plausible code arrive at once; nobody can say which
  requirement any given hunk satisfies.
- **Lost findings.** Hard-won lessons ("the staging DB truncates that column") evaporate with the
  session, and the next session re-learns them the expensive way.

Corpus answers each wall with a small markdown artifact and the habit of working from it.

## What Corpus is — and is not

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

| Adjacent product                                    | What it does                               | Corpus's relationship to it                                                                                                                                                                                    |
| --------------------------------------------------- | ------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Coding agents** (Claude Code, Cursor, Copilot, …) | write the code                             | Corpus ships no agent. It shapes the inputs any agent works from and the output you review. Bring whichever agent you have.                                                                                    |
| **Spec-driven workflows**                           | turn a written spec into an implementation | The same family. Corpus's bet is the review side — every requirement carries a verification method, and the review packet shows the evidence per requirement — and it stays small: templates, not a generator. |
| **Issue trackers** (Jira, Linear, GitHub Issues)    | hold the backlog and the conversation      | The ticket stays where it is. Corpus snapshots it into an intake file and interprets it into a spec an agent can act on. Nothing replaces the tracker.                                                         |
| **Docs portals** (wikis, Notion, docs sites)        | describe the system after the fact         | A Corpus spec is a working document — acceptance criteria, verification methods, open questions. It drives the change rather than documenting it later.                                                        |
| **Review tooling** (PRs, CI, review bots)           | gate the merge                             | Corpus does not replace the PR. The review packet rides alongside it and tells the reviewer where to look; CI output is the evidence the packet cites.                                                         |
| **Refactoring tooling** (codemods, OpenRewrite, …)  | execute mechanical change                  | Corpus's change plan states what must survive the change and how to check it; a codemod is one way a task executes a step of that plan.                                                                        |

## What's optional, what's advanced

Optional on any given task: Pull/intake · Inventory · Change Plan · a new spec for a
covered bug fix · a board row for trivial work (each has a stated skip rule in
[the workflow](02-basic-workflow.md)). Advanced — exists, not part of the first path:
audit and research artifacts, the granular lifecycle, the richer result vocabulary, the
memory model, the kit's optional templates (`advanced/`), the stance-and-depth catalog in
[swarm-skills](https://github.com/jcosta33/swarm-skills), and the entire CLI (future). The
core you actually start with: spec, task, review, finding.

## What Corpus does not promise

- **No deterministic generation.** The same spec run twice yields two different diffs. A good
  spec narrows the space; it does not determine the output.
- **No automatic correctness.** A requirement with passing output pasted next to it is strong
  evidence, not a certificate. Someone still decides to merge.
- **No formal verification.** Evidence here means tests, commands, and their real output — not a
  mathematical proof of the program.
- **No end of PR review.** The review packet directs human attention; it does not dismiss it.

And one meta-promise kept everywhere — **every rule says how strongly it is held**, on a four-level
honesty scale, so a "MUST" never hides whether anything actually checks it:

- **convention** — a practice the docs recommend; nothing checks it.
- **checklist** — a check a human applies at review time, by reading.
- **toolable** — a check a tool *could* run mechanically; the docs name the command (swarm-cli's `swarm check`).
- **enforced** — a shipped tool runs it and blocks. Nothing in *this* repo enforces anything — it is
  markdown. The optional [swarm-cli](https://github.com/jcosta33/swarm-cli) makes the toolable checks
  runnable, and the kit's gate can enforce them in your CI.

The list of checks, each carrying its level, lives in [reference/checks.md](reference/checks.md).

## The failure modes it positions against

Coding agents fail in predictable patterns, and each pattern is the reason a piece of Corpus exists.

| Failure mode                | What it looks like                                                                                                                                                                                                                     | What answers it                                                                                                                                                                        |
| --------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Drift**                   | the agent solves _a_ problem, not _the_ problem                                                                                                                                                                                        | the task packet: an explicit scope and a "Do not change" list                                                                                                                          |
| **Ambiguous input**         | ambiguity measurably degrades generated code, and models do not reliably flag or resolve it on their own [[ORCHID]](research/sources.md#ORCHID) [[HUMANEVALCOMM]](research/sources.md#HUMANEVALCOMM)                                                                                        | requirements written one per ID, each with its own verification method                                                                                                                 |
| **Lost handoff**            | the handoff from plan to implementation is — on preliminary evidence — the dominant failure surface in multi-agent code generation [[PLANCODER]](research/sources.md#PLANCODER)                                                                                          | the handoff is a written, bounded task packet — not a chat message                                                                                                                     |
| **Hallucinated completion** | "done," but nothing was checked — in a randomized trial, developers _believed_ they were ~20% faster with AI while _measuring_ ~19% slower [[METR]](research/sources.md#METR) (preliminary: 16 experienced developers on mature repos) | a Pass needs pasted output, a CI link, or a named human's recorded observation (manual checks); an empty Evidence cell means Unverified, never Pass (a review checklist rule)                                                                 |
| **No resumable trail**      | the session ends mid-stride; the next one starts from zero                                                                                                                                                                             | work externalized to files — intake, spec, task, review — and writing intermediate work down measurably improves multi-step performance [[SCRATCHPAD]](research/sources.md#SCRATCHPAD) |
| **Repeated mistakes**       | the same class of bug returns every few sessions                                                                                                                                                                                       | findings saved at Close, kept where the next task will look                                                                                                                            |

## Restraint

Corpus stays useful by staying small:

- **Fewer files.** Write the artifacts the work needs and skip the rest — the workflow has named
  skip-paths, not guilt.
- **Every file useful.** If a file changes neither what the agent does nor what the reviewer
  checks, don't write it.
- **Review evidence over planning prose.** A pasted test run beats a page of plan.

Next: [the basic workflow](02-basic-workflow.md) — the steps from ticket to merged, reviewed change.
