# 📒 Guide: Monorepo setup

> Nested AGENTS.md, the closest-wins rule, workspace conventions. Concrete example of a multi-package repo with different stacks per workspace.

---

## ⚡ TL;DR

In a monorepo, multiple `AGENTS.md` files coexist. The agent reads the closest file in the directory tree. The repo-root `AGENTS.md` carries shared conventions; per-workspace files add or override.

The `.agents/` directory typically lives at the repo root and is shared. Per-workspace specs / audits / bugs / research can either be co-located in the workspace or stay in the shared `.agents/`.

---

## 🏗️ The hierarchy

```
.
├── AGENTS.md                            # repo-root: shared bindings + monorepo conventions
├── .gitignore                           # includes .agents/tasks/
├── .agents/
│   ├── tasks/                           # gitignored
│   ├── templates/                       # shared flat templates (8)
│   ├── skills/                          # shared skills (24: quality gates + specialised + authoring + 8 persona skills)
│   ├── specs/                           # shared specs (or per-workspace; see below)
│   ├── audits/
│   ├── bugs/
│   └── research/
│
├── packages/
│   ├── api/
│   │   ├── AGENTS.md                    # api-specific bindings; overrides root
│   │   ├── src/
│   │   ├── tests/
│   │   └── package.json
│   │
│   ├── web/
│   │   ├── AGENTS.md                    # web-specific bindings
│   │   ├── src/
│   │   └── package.json
│   │
│   └── shared/
│       └── (no AGENTS.md — inherits root)
│
└── tools/
    └── AGENTS.md                        # tools workspace
```

When the agent works in `packages/api/`, the active `AGENTS.md` is `packages/api/AGENTS.md`. The root `AGENTS.md` is the *fallback*.

---

## 🪜 Step 1: write the root AGENTS.md

The root `AGENTS.md` carries:

- The session-start hook (first action: read your task file)
- The `## Commands` contract that applies *everywhere* (e.g., `Install` → `pnpm install`)
- Monorepo conventions (workspace layout, where each workspace lives)
- The `## Skills` note (skills self-activate; there is no always-loaded skill)
- The constitution pointer

```markdown
# AGENTS.md (repo root)

> First action: read your task file at `.agents/tasks/<your-slug>.md`. The file names a suggested persona, lists the skills worth loading, links your source doc, and binds the verification commands. Then proceed.

## Project conventions

- Monorepo: pnpm workspaces
- Languages: TypeScript ≥ 5.5 (`packages/*`), Rust 1.79 (`tools/`)
- Test runner per workspace (see workspace AGENTS.md)

## Commands

| Command (referenced as `Commands > …`) | Template placeholder | Bind to (repo-wide default) | Notes |
|----------------------------------------|----------------------|-----------------------------|-------|
| `Install` | `{{cmdInstall}}` | `pnpm install --frozen-lockfile` | repo-wide install |
| `Validation` | `{{cmdValidate}}` | `pnpm -r run validate` | runs across all workspaces |
| `Test` | `{{cmdTest}}` | `pnpm -r test` | runs across all workspaces |
| `ValidateDeps` | `{{cmdValidateDeps}}` | `pnpm run validate:deps` | dependency-cruiser at root |

Per-workspace overrides may narrow these to a single workspace (see workspace AGENTS.md files).

## Workspace conventions

- `packages/api/` — server (Node.js, hono, vitest)
- `packages/web/` — client (Vite, React, vitest)
- `packages/shared/` — shared types and utilities (no runtime dependencies)
- `tools/` — Rust CLIs (cargo, cargo-test)

## Skills

Skills live in `.agents/skills/<name>/SKILL.md` and self-activate on their directive `description`. There is no always-loaded skill. Adopt the persona skill whose `description` matches your task (or the mindset carried by the matching workflow skill).

## Constitution

`.agents/constitution.md` — supreme law of the project.

## Subagent strategy

- Read-side parallelism (research, audit, review) is permitted via subagents.
- Write-side work is single-threaded per workspace.
- Cross-workspace changes go through the Lead Engineer (orchestration).

## Override semantics

Subdirectories may have their own `AGENTS.md` (or `AGENTS.override.md`) for path-specific conventions. The closest file in the directory tree wins.
```

---

## 🪜 Step 2: write per-workspace AGENTS.md

Each workspace's `AGENTS.md` *overrides* the root for the bindings that differ:

```markdown
# packages/api/AGENTS.md

> Same first-action rule as root: read your task file at `.agents/tasks/<your-slug>.md` first.

This workspace overrides the root `AGENTS.md` for the following:

## Commands (api workspace)

| Command | Template placeholder | Bind to (this workspace only) |
|---------|----------------------|-------------------------------|
| `Validation` | `{{cmdValidate}}` | `pnpm --filter api run validate` |
| `Test` | `{{cmdTest}}` | `pnpm --filter api test` |
| `Build` | `{{cmdBuild}}` | `pnpm --filter api build` |
| `ValidateDeps` | `{{cmdValidateDeps}}` | `pnpm --filter api run validate:deps` |

## Workspace-specific constraints

- Database migrations live in `packages/api/migrations/` and follow the per-wave protocol per `tasks/migration.md`
- API contracts are versioned per ADR 0007 (path-prefix versioning)
- All HTTP handlers must use the `withErrorBoundary` wrapper (ADR 0014)

## Workspace-specific overlay personas

This workspace uses **The Integrator** overlay for SDK-wiring tasks. The overlay is a self-contained persona skill at `.agents/skills/persona-integrator/SKILL.md` (beside the shipped eight); note the standing preference in this workspace's `AGENTS.md > Routing`.
```

The Rust workspace has different bindings:

```markdown
# tools/AGENTS.md

> Same first-action rule.

## Commands (tools workspace — Rust)

| Command | Template placeholder | Bind to |
|---------|----------------------|---------|
| `Install` | `{{cmdInstall}}` | `cargo build` |
| `Validation` | `{{cmdValidate}}` | `cargo check && cargo clippy -- -D warnings` |
| `Format` | `{{cmdFormat}}` | `cargo fmt --check` |
| `Typecheck` | `{{cmdTypecheck}}` | `cargo check` |
| `Test` | `{{cmdTest}}` | `cargo test` |
| `Build` | `{{cmdBuild}}` | `cargo build --release` |
| `ValidateDeps` | `{{cmdValidateDeps}}` | `cargo deny check` |
```

---

## 🪜 Step 3: decide where source docs live

Two patterns work:

### Pattern A: shared `.agents/` at repo root

Specs / audits / bugs / research all live at `.agents/specs/`, etc. Per-workspace ownership is implicit (the slug or path inside the doc indicates the workspace).

**Pros:** single index of all source docs; cross-cutting docs are obvious.
**Cons:** the directory grows; finding workspace-specific docs requires grepping.

### Pattern B: per-workspace `.agents/`

Each workspace has its own `.agents/` directory:

```
packages/
├── api/
│   ├── .agents/
│   │   ├── specs/
│   │   ├── audits/
│   │   └── bugs/
│   └── src/
└── web/
    ├── .agents/
    │   ├── specs/
    │   └── audits/
    └── src/
```

The repo-root `.agents/` still exists for cross-cutting docs (research, ADRs, constitution).

**Pros:** workspace ownership is obvious; per-workspace docs grow independently.
**Cons:** cross-workspace docs need a convention (live at root); `.agents/tasks/` either nests or stays at root.

The framework doesn't mandate one pattern. Pattern A is simpler for small monorepos; Pattern B scales better.

---

## 🪜 Step 4: handle cross-workspace work

Some tasks span multiple workspaces (a feature touching `api` and `web`; a refactor moving code between workspaces). These go through `orchestration`:

- The Lead Engineer reads the cross-cutting spec
- Decomposes into per-workspace sub-tasks (one per workspace)
- Each sub-task runs in its own worktree, with its workspace's AGENTS.md (and bindings) active
- Workers complete; the Lead Engineer reviews each as the Skeptic
- Merges the per-workspace branches into the integration branch
- Runs *integrated* validation (using the root AGENTS.md's repo-wide bindings)

See [`tasks/orchestration.md`](../tasks/orchestration.md) and [`concepts/08-recursion-and-delegation.md`](../concepts/08-recursion-and-delegation.md).

---

## 🪜 AGENTS.override.md (Codex compatibility)

OpenAI Codex supports a `AGENTS.override.md` filename that *only overrides* (rather than replacing) the parent. This can be useful when a workspace wants to inherit most of the root's content and only override specific bindings.

```markdown
# packages/api/AGENTS.override.md

(no preamble — inherits everything from ../../AGENTS.md and only overrides the listed commands)

## Commands (overrides)

| Command | Template placeholder | Bind to |
|---------|----------------------|---------|
| `Validation` | `{{cmdValidate}}` | `pnpm --filter api run validate` |
| `Test` | `{{cmdTest}}` | `pnpm --filter api test` |
```

The framework treats `AGENTS.md` and `AGENTS.override.md` interchangeably for monorepo nesting; the choice is a stylistic one.

---

## ⚠️ Common monorepo pitfalls

| Pitfall                                                                | Fix                                                                |
| ---------------------------------------------------------------------- | ------------------------------------------------------------------ |
| Forgetting to override `cmdTest` in a workspace; `pnpm -r test` runs everything for every task | Per-workspace AGENTS.md narrows the slot to the workspace |
| Cross-workspace specs that don't say which workspace owns the spec     | Convention: spec name prefix indicates workspace (e.g., `api-pkce.md`); or use Pattern B |
| Tasks file slugs colliding across workspaces                          | Convention: prefix slugs with workspace (`api-pkce`, `web-pkce`)  |
| Workspace adopting an overlay persona without root AGENTS.md mentioning it | Document the overlay in the workspace's AGENTS.md and (optionally) reference from the root |
| Running orchestration where workers are in different workspaces; Lead Engineer trying to use a single set of bindings | Each worker runs with its workspace's AGENTS.md active; Lead Engineer's final integrated validation uses root bindings |

---

## See also

- [`reference/agents-md.md`](../reference/agents-md.md) — the AGENTS.md anatomy
- [`reference/directory-layout.md`](../reference/directory-layout.md) — the canonical layout
- [`tasks/orchestration.md`](../tasks/orchestration.md) — cross-workspace orchestration
- [`concepts/08-recursion-and-delegation.md`](../concepts/08-recursion-and-delegation.md) — the Lead Engineer pattern
