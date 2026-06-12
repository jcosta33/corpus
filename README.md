# Swarm

**A lightweight spec and review workflow for teams using coding agents.**

Turn tickets into clear specs, specs into agent-ready tasks, and agent output into
evidence you can review — plain markdown, any agent, no runtime.

## The problem

Coding agents increase code volume; they don't increase your capacity to direct and
check it. The mess collects in five places: vague tickets pasted into chat, context
re-explained every session, agents drifting off-scope, giant PRs nobody can honestly
review, and lessons lost the moment the session ends.

Swarm is not an agent. Claude Code, Codex, Cursor, Aider — or a human — does the
coding. Swarm organizes the work around them, and invests where the bottleneck
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

## Sixty seconds of Swarm

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

- **This repo** — the framework: docs, templates, a starter kit.
- **Your workspace** — specs, tasks, reviews, findings: a dedicated repo or the same tree in your project ([where files live](docs/03-where-files-live.md)).
- **Your code repos** — stay clean. The PR links its review packet; that's all.

## What works today, what comes later

**Today** (markdown + your agent, nothing to install): the templates, specs, task
packets, review packets, findings, the worked examples.

**Later** (a CLI, in progress as `swarm-cli`): `swarm pull`, `swarm spec check`,
`swarm task new`, `swarm worktree create`, `swarm review`, `swarm status` — the
quality-of-life automation around the same files.
The contract: [docs/reference/future-cli.md](docs/reference/future-cli.md).

Swarm does **not** promise deterministic generation, automatic correctness, formal
verification, compiling software from specs, or the end of PR review — it promises
better inputs, bounded tasks, reviewable evidence, and kept context.

## What Swarm is / is not

**Is:** a spec format agents can work from · a task-packet format that bounds agent
work · a review-packet format that shows where human attention goes · a findings
convention so lessons survive the session · a starter kit of markdown templates ·
a workspace convention that keeps all of it out of your code repos.

**Is not:** an agent or agent runtime · a compiler · a programming language · a
Jira/Linear replacement · a code generator · a replacement for PRs and CI · a docs
portal · a complete SDLC platform · a guarantee that agent output is correct.

How it differs from its neighbors: spec-first scaffolds generate plans; trackers
hold tickets; AI reviewers hunt bugs; an `AGENTS.md` alone carries standing facts, not
per-change contracts. Swarm's distinct piece is the **persisted, independent,
exception-routing review packet** tied to requirement IDs — plus a workspace and one
honesty rule: anything not enforced by a tool says so.

## Get started

1. Copy the kit whole — it is a ready workspace: use [jcosta33/swarm-starter-kit](https://github.com/jcosta33/swarm-starter-kit) as a template (a new repo, or a folder in your project).
2. Fill its `AGENTS.md` with your commands and facts.
3. Claude Code finds the guides via the shipped `.claude/skills` symlink; point any other tool at `.agents/skills/`.
4. Write one spec for your next non-trivial change. Run the loop once.

Or hand your agent [docs/ADOPTING.md](docs/ADOPTING.md) and let it do the copying.

## Going deeper

[What is Swarm](docs/01-what-is-swarm.md) · [Basic workflow](docs/02-basic-workflow.md) · [Writing specs](docs/04-writing-specs.md) ·
[Reviewing output](docs/08-reviewing-output.md) · [Examples](docs/examples/) · [Reference](docs/reference/) ·
[Design decisions](docs/adrs/) · [Evidence](docs/research/sources.md)
