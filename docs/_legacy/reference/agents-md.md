# 📖 Reference: AGENTS.md

> Swarm's adoption of the open AGENTS.md standard. AGENTS.md is the canonical entry point every Swarm-conformant repo ships with — short, opinionated, and focused on what every agent must know.

---

## ⚡ TL;DR

`AGENTS.md` lives at the repo root. It tells the agent:

1. Where the task file lives (read it first)
2. The repo's **command contract** — named `## Commands` entries (Validation / Test / Format, plus extended slots) that skills reference in prose and launchers bind to `{{cmd*}}` placeholders
3. That skills **self-activate** by `description` — there is no always-loaded skill to name here

It is read by every agent CLI that supports the open standard (Claude Code, Codex, Cursor, Aider, Devin, Factory, Jules, Junie, Warp, Zed, opencode, and more — the standard is stewarded by the [Agentic AI Foundation](https://agents.md/) under the Linux Foundation).

---

## 🪜 Why AGENTS.md

The format originated at OpenAI Codex and has been adopted across the agent-tooling ecosystem. The OpenAI monorepo alone reportedly ships 88 nested AGENTS.md files (closest-wins), with `AGENTS.override.md` for monorepo subdirectories that need different rules.

Swarm adopts the standard verbatim: the `AGENTS.md` is the entry point; nesting works (closest-wins); overrides are explicit.

---

## 📐 The recommended template

```markdown
# AGENTS.md

> First action: read your task file at `.agents/tasks/<your-slug>.md`. It links your source doc, lists the skills worth loading, names a suggested persona, and binds the verification commands you'll need. Then proceed.

## Project conventions

- Language: <e.g., TypeScript ≥ 5.5>
- Runtime: <e.g., Node.js LTS>
- Test runner: <e.g., vitest>
- Package manager: <e.g., pnpm ≥ 9>

## Commands

This is the **command contract**. Skills reference these entries by name in prose
(e.g. "run the project's validation command, `AGENTS.md > Commands > Validation`")
and degrade gracefully — if an entry is missing they ask before running anything.
Launchers bind the `{{cmd*}}` placeholders in templates from the same entries.

Required (skills rely on these):

| Command (referenced as `Commands > …`) | Template placeholder | Bind to                             |
| -------------------------------------- | -------------------- | ----------------------------------- |
| `Validation`                           | `{{cmdValidate}}`    | `pnpm typecheck && pnpm lint`       |
| `Test`                                 | `{{cmdTest}}`        | `pnpm test`                         |
| `Format`                               | `{{cmdFormat}}`      | `pnpm format`                       |

Extended (bound when the relevant work occurs; mark `n/a` with a one-line reason if none):

| Command        | Template placeholder  | Bind to / `n/a`         | Used by                          |
| -------------- | --------------------- | ----------------------- | -------------------------------- |
| `Install`      | `{{cmdInstall}}`      | `pnpm install`          | most code tasks (worktree setup) |
| `Typecheck`    | `{{cmdTypecheck}}`    | `pnpm typecheck` / `n/a` | refactor, feature, type checks  |
| `Lint`         | `{{cmdLint}}`         | `pnpm lint` / `n/a`     | standalone lint (not folded into Validation) |
| `Build`        | `{{cmdBuild}}`        | `pnpm build` / `n/a`    | upgrade, feature                 |
| `ValidateDeps` | `{{cmdValidateDeps}}` | `pnpm validate:deps` / `n/a` | refactor / migration / review (dependency-flow) |
| `Benchmark`    | `{{cmdBenchmark}}`    | `pnpm bench` / `n/a`    | performance                      |

Out-of-contract (doc/research-heavy projects only; otherwise the skill asks at run time): `MarkdownLint`, `LinkCheck`, `CitationCheck`. Version held: `.agents/.swarm-version`.

## Skills

Skills live in `.agents/skills/<name>/SKILL.md` and **self-activate**: each carries a
directive `description` and loads when its triggers match the task. There is **no
always-loaded skill** — keep only the skills your work needs and let each fire on its
own description. (A skill authored to load on every task is the wrong primitive —
its content is persistent context and belongs here in AGENTS.md.)

## Repo structure

- Source: `src/`
- Tests: `tests/`
- Agent docs / skills / templates: `.agents/`
- Worktree-local task files (gitignored): `.agents/tasks/`
- User-facing docs: `docs/`

## Constitution

The project's non-negotiable baselines live in `.agents/constitution.md`. Every spec, audit, and ADR operates within its constraints.

## ADRs

Architecturally significant decisions are recorded under `.agents/adrs/`.

## Routing (recommended, not enforced)

Swarm's flow graph maps a source doc → task type → suggested persona → skills worth
loading. It is recommended routing: a launcher may apply it deterministically, and the
directive skill `description`s reproduce it in-session. When the task doesn't match the
suggested default, load the skill whose `description` fits and record the divergence in
the task file's `## Decisions`.

## Subagent strategy

- Read-side parallelism (research, audit, review) is permitted via subagents.
- Write-side work (feature, fix, refactor, migration) runs single-threaded.

See `docs/concepts/10-subagent-strategy.md` for the full rationale.

## Override semantics

This file is repo-root. Subdirectories may have their own `AGENTS.md` (or `AGENTS.override.md`) for path-specific conventions. The closest file in the directory tree wins.
```

---

## 🪞 What AGENTS.md is NOT

- **Not a place to put domain rules.** Domain rules go in skills (`.agents/skills/domain/`). AGENTS.md is for *universal invariants* — what every agent in the repo must know.
- **Not a substitute for a persona skill.** A persona skill (`.agents/skills/persona-<slug>/SKILL.md`) self-activates on its own `description`; AGENTS.md only points to the recommended routing that suggests one.
- **Not a substitute for the spec.** Per-task constraints live in the task's source doc; AGENTS.md tells the agent *to read its task file first*.
- **Not where the agent stores state.** AGENTS.md is read; not written. State lives in the task file (per session) or in the source docs (durable).

---

## 🪜 Hierarchical AGENTS.md

In monorepos, multiple `AGENTS.md` files coexist. The agent reads the closest file in the directory tree (the file in the deepest enclosing directory wins).

Example monorepo:

```
.
├── AGENTS.md                            # repo-root: shared bindings
├── packages/
│   ├── api/
│   │   └── AGENTS.md                    # api-specific bindings (overrides cmdTest, etc.)
│   └── web/
│       └── AGENTS.md                    # web-specific bindings
└── tools/
    └── AGENTS.md                        # tools workspace
```

When an agent works in `packages/api/`, the `packages/api/AGENTS.md` is the active one. It can:

- **Inherit** by referencing the root: `# packages/api/AGENTS.md` *— see the root `AGENTS.md` for shared conventions; this file overrides…*
- **Override** specific `## Commands` entries (e.g., the api package's `Test` may bind to `vitest -c packages/api/vitest.config.ts`)
- **Add** workspace-specific constraints (e.g., a stricter typecheck flag)

For OpenAI Codex compatibility, you can use `AGENTS.override.md` instead of `AGENTS.md` in subdirectories that should *only* override (not replace) the parent.

---

## 🪧 Session-start hook

The agent has to be told to read its task file before doing anything else. AGENTS.md is the natural place to do this — the first paragraph of the file is the session-start hook.

The framework recommends:

> First action: read your task file at `.agents/tasks/<your-slug>.md`. It links your source doc, lists the skills worth loading, names a suggested persona, and binds the verification commands you'll need. Then proceed.

This is one paragraph but it's load-bearing. Without it, the agent may default to its own helpfulness instead of adopting the task file's conditioning. Skills then self-activate from their own `description`s once the work in front of the agent matches — AGENTS.md does not list a skill to load on every session, because there is no always-loaded skill.

Some agent CLIs support hook mechanisms (Claude Code's session-start hooks, Codex's skill auto-loading) that can supplement the AGENTS.md instruction. The framework recommends both: the AGENTS.md instruction as the *content*, and the CLI's hook as the *delivery mechanism*.

---

## 🛡️ The conformance rule

A Swarm-conformant repo must have:

- `AGENTS.md` at the repo root
- The "first action" instruction (read your task file)
- A `## Commands` section binding the required entries (`Validation`, `Test`, `Format`) — plus any extended entries the project's work needs — so skills can reference them in prose and launchers can bind the `{{cmd*}}` placeholders (see [`template-placeholders.md`](template-placeholders.md))
- A `## Skills` section establishing that skills self-activate by `description` (no always-loaded skill)

Optional but recommended:

- A `## Routing` pointer (recommended, not enforced)
- Subagent strategy section
- Constitution / ADR pointers
- Hierarchical AGENTS.md in monorepos

---

## 🧰 Aliases for vendor-specific names

Some agent CLIs look for specific filenames before checking the open AGENTS.md standard. Recommended aliases (one-line files that import AGENTS.md):

| Vendor file       | Recommended content                                    |
| ----------------- | ------------------------------------------------------ |
| `CLAUDE.md`       | `# Project context\n\n@AGENTS.md` (Claude Code import) |
| `GEMINI.md`       | A short pointer: `See AGENTS.md` (Gemini)             |
| `.cursor/rules/`  | (Cursor's per-file rules; can supplement AGENTS.md)   |

The aliases ensure cross-tool portability without duplicating AGENTS.md content.

---

## See also

- [`template-placeholders.md`](template-placeholders.md) — what each `{{cmdX}}` slot means
- [`directory-layout.md`](directory-layout.md) — what AGENTS.md sits next to
- [`concepts/10-subagent-strategy.md`](../concepts/10-subagent-strategy.md) — the subagent strategy AGENTS.md should reference
- [`concepts/12-prior-art.md`](../concepts/12-prior-art.md) — the AGENTS.md standard's origin
- [agents.md](https://agents.md/) — the open standard (external)
