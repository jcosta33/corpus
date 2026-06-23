# Corpus

**A lightweight spec and review workflow for teams using coding agents.**

Turn tickets into clear specs, specs into agent-ready tasks, and agent output into
evidence you can review — plain markdown, any agent, no runtime.

## The problem

Coding agents increase code volume; they don't increase your capacity to direct and
check it. The mess collects in five places: vague tickets pasted into chat, context
re-explained every session, agents drifting off-scope, giant PRs nobody can honestly
review, and lessons lost the moment the session ends.

Corpus is not an agent. Claude Code, Codex, Cursor, Aider — or a human — does the
coding. Corpus organizes the work around them, and invests where the bottleneck
actually is: **generation outpaces validation**, so the review side gets the structure.

## The loop

```
Pull ──▶ Spec ──▶ Task ──▶ Run ──▶ Review ──▶ Close
 │        │        │        │        │          │
intake   spec     task    branch   review     finding
snapshot                  + code   packet     + status
```

1. **Pull** the work — snapshot the ticket into `intake/`.
2. **Spec** it — a one-page contract: requirements with IDs and `Verify with:` notes.
3. **Task** it — a bounded packet an agent can finish in one sitting.
4. **Run** it — your agent CLI, in its own git worktree (a parallel checkout: its own folder and branch).
5. **Review** it — coverage, evidence, and a human-attention list, not a 3,000-line diff.
6. **Close** it — save what you learned as a finding; update the board.

Structural or brownfield work adds two optional steps — an **inventory** (map what
exists) and a **change plan** (how the codebase changes safely). Small cleanups skip
straight to Task. The full guide: [docs/02-basic-workflow.md](docs/02-basic-workflow.md).

## Sixty seconds of Corpus

A requirement in a spec:

```markdown
### AC-001 — Expired refresh token redirects to login
When the refresh token is expired, the client must clear the local
session and redirect to `/login`.

Verify with: `auth-refresh-expired-token.test`
```

And the review packet that comes back after an agent run:

```markdown
| ID     | Result     | Evidence                       | Human attention |
|--------|------------|--------------------------------|-----------------|
| AC-001 | Pass       | test output pasted             | no              |
| AC-002 | Unverified | no test output found           | yes             |

## Human attention
1. AC-002 has no pasted test output.
2. Retry logic changed in `src/auth/client.ts` — outside task scope.
```

That table is the point: instead of reading the whole diff, you read which
requirements passed **with evidence**, which didn't, and where your eyes are needed.
An empty evidence cell means *Unverified*, never *Pass*. The full demo — a 41-file
agent PR reviewed by exception — is
[docs/examples/large-pr-review.md](docs/examples/large-pr-review.md).

## Where files live

- **This repo** — the framework: the docs and the checks contract. The ready-to-copy workspace (templates + guides) is [jcosta33/swarm-starter-kit](https://github.com/jcosta33/swarm-starter-kit).
- **Your workspace** — specs, tasks, reviews, findings: a dedicated repo or the same tree in your project ([where files live](docs/03-where-files-live.md)).
- **Your code repos** — stay clean. The PR links its review packet; that's all.

## Which repo do I want?

Corpus is a small family of repos. Where you go depends on what you're doing:

| You want to… | Go to |
|---|---|
| **start using Corpus** — get a working workspace | [swarm-starter-kit](https://github.com/jcosta33/swarm-starter-kit) — copy it whole, fill `AGENTS.md`, run the loop |
| **understand the method** — formats, the checks contract, the decision ledger | **this repo** — `docs/` (the numbered happy path), `docs/reference/`, `docs/adrs/` |
| **run the checks / wire the gate** — `swarm check` as a command | [swarm-cli](https://github.com/jcosta33/swarm-cli) — the reference CLI (optional) |
| **add optional skills** — review personas, code-depth guides | [swarm-skills](https://github.com/jcosta33/swarm-skills) — `npx skills add jcosta33/swarm-skills` |

Most people start at the kit and never need to read this repo cover to cover.

## What works today, what comes later

**Today** (markdown + your agent, nothing to install): the templates, specs, task
packets, review packets, findings, the worked examples. Corpus itself needs no runtime.

**Toolable today** (optional — the reference CLI, [swarm-cli](https://github.com/jcosta33/swarm-cli)):
`swarm check` runs the [checks contract](docs/reference/checks.md) over your specs and reviews, and
the kit's [hooks](https://github.com/jcosta33/swarm-starter-kit/tree/main/hooks) wire it into your
commit and pull-request gates — so the review side gets *teeth* without anyone installing a runtime to
use Corpus. `swarm init`, `swarm new`, `swarm worktree`, `swarm pull`, `swarm promote`, and `swarm status`
scaffold and prepare the loop's mechanics, `swarm run` launches a prepared task on your agent in its
worktree (recording the launch), and `swarm review` reconciles a finished run against its spec and
diff — surfacing facts (omitted edits, out-of-scope changes, unbacked claims), never a review result.

**Planned** (the rest of `swarm-cli`): `swarm close`.
What ships today vs. later — the capability matrix: [docs/reference/future-cli.md](docs/reference/future-cli.md).

Corpus does **not** promise deterministic generation, automatic correctness, formal
verification, compiling software from specs, or the end of PR review — it promises
better inputs, bounded tasks, reviewable evidence, and kept context.

## What Corpus is / is not

**Is:** a spec format agents can work from · a task-packet format that bounds agent
work · a review-packet format that shows where human attention goes · a findings
convention so lessons survive the session · a starter kit of markdown templates ·
a workspace convention that keeps all of it out of your code repos.

**Is not:** an agent or agent runtime · a compiler · a programming language · a
Jira/Linear replacement · a code generator · a replacement for PRs and CI · a docs
portal · a complete SDLC platform · a guarantee that agent output is correct.

**Take what you want.** Each part above stands on its own — adopt just the review packet,
or just the spec format, and add the rest only when the work calls for it. The formats are
plain markdown you own outright: no runtime, no lock-in, no walled garden. Together they
compound; apart, each still earns its place.

How it differs from its neighbors: spec-first scaffolds generate plans; trackers
hold tickets; AI reviewers hunt bugs and check a diff against a linked ticket's
acceptance criteria; an `AGENTS.md` alone carries standing facts, not per-change
contracts. Corpus's distinct piece is the **persisted, independent, exception-routing
review packet** tied to requirement IDs — deterministic (no model in the loop), keyed to
a spec/task packet that lives in your git history, and verdict-free (it routes facts; a
human owns Pass/Fail) — plus a workspace and one honesty rule: anything not enforced by a
tool says so.

## Get started

1. Copy the kit whole — it is a ready workspace: use [jcosta33/swarm-starter-kit](https://github.com/jcosta33/swarm-starter-kit) as a template (a new repo, or a folder in your project).
2. Fill its `AGENTS.md` with your commands and facts.
3. Claude Code finds the guides via the shipped `.claude/skills` symlink; point any other tool at `.agents/skills/`.
4. New to the loop? **[Walk it once, hands-on](docs/tutorial/README.md)** — a guided build on one small change. Then write a spec for your next non-trivial change and run it for real.

Or hand your agent [docs/ADOPTING.md](docs/ADOPTING.md) and let it do the copying.

## Going deeper

[What is Corpus](docs/01-what-is-swarm.md) · [Basic workflow](docs/02-basic-workflow.md) · [Writing specs](docs/04-writing-specs.md) ·
[Reviewing output](docs/08-reviewing-output.md) · [Examples](docs/examples/) · [Reference](docs/reference/) ·
[Design decisions](docs/adrs/) · [Evidence](docs/research/sources.md)
