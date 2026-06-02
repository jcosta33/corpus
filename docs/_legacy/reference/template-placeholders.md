# 📖 Reference: Template placeholders

> The framework's placeholder contract — the interface a CLI or runner must honour to be Swarm-compliant. This is what makes the framework usable by tools other than the Swarm CLI.

---

## ⚡ TL;DR

Placeholders use `{{name}}` syntax. They fall into two namespaces:

- **Command placeholders** (`{{cmdInstall}}`, `{{cmdValidate}}`, …) — bound by the project to repo-specific commands, sourced from `AGENTS.md > Commands`
- **Scaffolding placeholders** (`{{slug}}`, `{{branch}}`, `{{worktreePath}}`, …) — bound by the launcher per task

A runner is **Swarm-compliant** if it honours every placeholder in the catalogues below.

> **Dual contract.** Templates carry `{{cmd*}}` placeholders; skill **bodies** do not. A `SKILL.md` body references a command by its named `AGENTS.md > Commands` entry in prose ("run the project's validation command, `AGENTS.md > Commands > Validation`") and degrades gracefully — if the entry is missing the skill asks the user before running anything. The `{{cmd*}}` placeholders appear only in the **task templates** (`references/task-template.md` and the flat `templates/` files), where a launcher binds them from the same `AGENTS.md > Commands` entries. See the next section.

---

## 🪜 Why a contract

The framework is tool-agnostic. Templates contain `{{cmdValidate}}` rather than `pnpm run validate`; one team binds it to `pnpm run validate`, another to `cargo check && cargo clippy`, another to `pytest -q`. The contract makes the binding the project's responsibility, not the framework's.

Tool builders implementing the contract:

- Substitute every recognised placeholder with the project's binding before passing the task file to the agent
- Leave unrecognised placeholders alone (the agent or another runner may handle them)
- Reserve their own namespaces under `{{<vendor>:...}}` to avoid collisions

See [ADR 0005](../adrs/0005-placeholder-syntax.md) for the syntax decision.

---

## 🔗 The dual contract: prose vs templates

Commands are referenced in two different shapes depending on *where* the reference lives:

| Where                                     | Shape                                                        | Bound by                                         |
| ----------------------------------------- | ----------------------------------------------------------- | ------------------------------------------------ |
| **Skill body** (`SKILL.md` prose)          | Named entry — `AGENTS.md > Commands > Validation`           | Read by the agent at run time (degrades to "ask the user" if the entry is missing) |
| **Task template** (`{{cmd*}}` placeholder) | `{{cmdValidate}}`, `{{cmdTest}}`, …                          | The launcher, from the same `AGENTS.md > Commands` entries |

This keeps skill bodies **self-contained**: a `SKILL.md` body never hardcodes a command and never carries a `{{cmd*}}` placeholder (placeholders would be meaningless without a launcher to resolve them). It points at the project's `AGENTS.md > Commands` section by name. The templates, which a launcher *does* resolve, carry the `{{cmd*}}` placeholders. Both ends bind to the same `AGENTS.md > Commands` table — required entries `Validation` / `Test` / `Format`; extended `Install` / `Typecheck` / `Lint` / `Build` / `ValidateDeps` / `Benchmark`; and out-of-contract doc-lint commands (`MarkdownLint` / `LinkCheck` / `CitationCheck`) that only doc/research-heavy projects bind.

### Where the templates live

| Template                                   | Location                                                    |
| ------------------------------------------ | ----------------------------------------------------------- |
| Per-task-type task templates               | each workflow skill's `references/task-template.md` (e.g. `write-feature/references/task-template.md`) |
| Shared task skeleton                       | `.agents/templates/task-base.md` (documents the skeleton; not launched) |
| Skill-less task types (orchestration, review) | flat `.agents/templates/task-orchestration.md`, `.agents/templates/task-review.md` |
| Source-doc templates                       | flat `.agents/templates/{spec,audit,bug-report,research}.md` |
| Meta-template for new skills               | `.agents/templates/skill.md`                                |

There are **no** flat per-skill task templates in `.agents/templates/` — each workflow skill owns its own task template under `references/`. Only `task-base` (the shared skeleton) and the two skill-less task types stay flat. All of these consume the placeholders catalogued below.

---

## 🛠️ Command placeholders

These are bound by the project in its `AGENTS.md > Commands` section (a launcher may also read a CLI config). The framework cares only about the slot names; the project binds them. The skill-body equivalent is the named `Commands > …` entry the placeholder maps to (see the dual contract above).

Every slot carries a **contract status** so the catalogue and `AGENTS.md > Commands` agree (no placeholder is unbindable by construction): **required** = skills rely on it; **extended** = bind when the work occurs, else `n/a` with a one-line reason; **out-of-contract** = no standard `AGENTS.md` row, bound only by doc/research-heavy projects (otherwise the skill asks at run time).

| Placeholder              | Status            | Semantics                                                       | Example bindings                                  |
| ------------------------ | ----------------- | --------------------------------------------------------------- | ------------------------------------------------- |
| `{{cmdValidate}}`        | **required**      | The project's catch-all check (lint + format + typecheck)       | `pnpm run validate` · `cargo check && cargo clippy` |
| `{{cmdTest}}`            | **required**      | Test suite                                                      | `pnpm test` · `cargo test` · `pytest`             |
| `{{cmdFormat}}`          | **required**      | Format check                                                    | `pnpm run format:check` · `cargo fmt --check`     |
| `{{cmdInstall}}`         | extended          | Install dependencies / set up the worktree                      | `pnpm install` · `cargo build` · `pip install -r requirements.txt` |
| `{{cmdTypecheck}}`       | extended          | Static analysis / type check                                    | `pnpm run typecheck` · `mypy .` · `cargo check`   |
| `{{cmdLint}}`            | extended          | Lint only (when not folded into `Validate`)                     | `pnpm run lint` · `cargo clippy` · `ruff check`   |
| `{{cmdBuild}}`           | extended          | Build the project artefact                                      | `pnpm run build` · `cargo build --release`        |
| `{{cmdValidateDeps}}`    | extended          | Dependency-flow / architecture-boundary check                   | `pnpm run validate:deps` · `dependency-cruiser` · `import-linter` |
| `{{cmdBenchmark}}`       | extended          | Run benchmarks (used by `performance` tasks)                    | `pnpm run bench` · `cargo bench`                  |
| `{{cmdMarkdownLint}}`    | out-of-contract   | Lint Markdown docs (`documentation` tasks, doc-heavy projects)  | `pnpm run lint:md` · `markdownlint`               |
| `{{cmdLinkCheck}}`       | out-of-contract   | Check that doc links resolve (`documentation` tasks)            | `pnpm run check:links` · `lychee`                 |
| `{{cmdCitationCheck}}`   | out-of-contract   | Check research-file citations (`research-writing`, rare)        | (project-defined; few projects implement this)    |

A repo that lacks an *extended* slot (e.g., no dependency-flow tooling) marks it `n/a` with a one-line justification rather than silently skipping it. *Out-of-contract* slots need no row unless a `documentation`/`research-writing` task uses one.

---

## 🪧 Scaffolding placeholders

Bound by the launcher per task. The framework defines the names; the launcher computes the values.

| Placeholder         | Semantics                                                                       | Example value                                         |
| ------------------- | ------------------------------------------------------------------------------- | ----------------------------------------------------- |
| `{{slug}}`          | Task's URL-safe slug (used in branch names, task file names, worktree paths)   | `oauth2-pkce`                                         |
| `{{title}}`         | Human-readable title (rendered as the task file's H1)                          | `Feature: OAuth2 PKCE flow`                           |
| `{{agent}}`         | Identifier for the agent CLI / model running this task                          | `claude-sonnet-4` · `codex-gpt-5` · `cursor`          |
| `{{branch}}`        | Git branch for this task                                                        | `feature/oauth2-pkce`                                 |
| `{{baseBranch}}`    | Base branch the worktree branched from                                         | `main`                                                |
| `{{worktreePath}}`  | Path to the worktree                                                            | `.worktrees/oauth2-pkce`                              |
| `{{createdAt}}`     | ISO-8601 timestamp when the task was scaffolded                                 | `2026-04-22T14:32:00Z`                                |
| `{{specFile}}`      | Path to the primary source doc                                                  | `.agents/specs/oauth2-pkce.md`                        |
| `{{auditFile}}`     | Path to the source audit (when applicable)                                     | `.agents/audits/billing-q1-2026.md`                   |
| `{{bugReport}}`     | Path to the source bug-report (when applicable)                                | `.agents/bugs/csv-export-truncation.md`               |
| `{{reviewFile}}`    | Path to a Skeptic's review notes (used in kickback tasks)                      | `.agents/reviews/payments-rate-limit-review.md`       |
| `{{round}}`         | For kickback tasks: round number (1, 2, 3)                                     | `2`                                                   |
| `{{originalType}}`  | For kickback tasks: the task type being revised                                 | `feature`                                             |
| `{{originalPersona}}` | For kickback tasks: the persona being revised                                | `The Builder`                                         |

---

## 🪧 Optional path placeholders

Some templates use placeholders for paths to documents that may or may not exist:

| Placeholder           | Semantics                                                                     |
| --------------------- | ----------------------------------------------------------------------------- |
| `{{constitutionFile}}` | Path to `.agents/constitution.md` (if the project has one)                  |
| `{{adrDir}}`           | Path to `.agents/adrs/` (if the project uses ADRs)                          |
| `{{relatedAdr}}`       | Path to a specific related ADR                                               |

---

## 🛡️ Reserved namespaces

To prevent collision between framework, CLI, and project placeholders:

| Prefix              | Reserved for                                                                  |
| ------------------- | ----------------------------------------------------------------------------- |
| `cmd*`              | Framework command slots (this doc's catalogue)                               |
| (no prefix)         | Framework scaffolding placeholders (this doc's catalogue)                    |
| `swarm:*`           | Swarm CLI extensions                                                          |
| `project:*`         | Project-specific custom placeholders                                          |
| `<vendor>:*`        | Other CLI vendors implementing the framework                                  |

If a CLI vendor wants to introduce a new placeholder, they prefix it with their vendor name to avoid collision. Example: a vendor called `tesseract` adding a new placeholder for an experimental capability would name it `{{tesseract:experimental_x}}`.

---

## 🪜 Required vs optional placeholders

| Placeholder                                                                  | Required for…                                                                |
| ---------------------------------------------------------------------------- | ---------------------------------------------------------------------------- |
| `{{slug}}`, `{{branch}}`, `{{baseBranch}}`, `{{worktreePath}}`, `{{createdAt}}` | Every task                                                                |
| `{{agent}}`                                                                  | Every task (for traceability)                                                |
| `{{title}}`                                                                  | Every task                                                                   |
| `{{cmdInstall}}`, `{{cmdValidate}}`, `{{cmdTest}}`                           | Every code-producing task                                                    |
| `{{cmdValidateDeps}}`                                                        | `refactor`, `migration`, `upgrade` (or `n/a` documented)                    |
| `{{cmdBenchmark}}`                                                           | `performance`                                                                |
| `{{cmdBuild}}`                                                               | `upgrade` (and `feature` where applicable)                                   |
| `{{cmdTypecheck}}`                                                           | `refactor`, `feature` (where applicable)                                     |
| `{{specFile}}`                                                               | Every task with a source doc                                                 |
| `{{auditFile}}`, `{{bugReport}}`, `{{reviewFile}}`, `{{round}}`, `{{originalType}}`, `{{originalPersona}}` | Per-task type as applicable                       |

---

## 🛡️ The conformance rule

A runner is **Swarm-compliant** if and only if:

1. It substitutes every required placeholder with a valid binding before passing the task file to the agent.
2. It leaves unrecognised placeholders alone (no silent stripping).
3. It does not introduce placeholders in the framework's reserved namespace (`cmd*` or no-prefix) without first proposing them to the framework via an ADR.

Compliance lets a project switch CLIs without rewriting templates.

---

## 🪞 Why `{{cmdX}}` and not `${cmdX}` or `<cmdX>`

[ADR 0005](../adrs/0005-placeholder-syntax.md) covers the decision. Summary:

- `${X}` collides with shell variable substitution (templates are often `cat`-piped through shells).
- `<X>` collides with HTML / XML / Markdown angle-bracket syntax.
- `{{X}}` is widely recognised (Mustache, Handlebars, Jekyll) and *doesn't* collide with common syntaxes.

The convention is also model-friendly — agent CLIs see `{{X}}` and recognise it as a placeholder rather than as content to render.

---

## See also

- [`reference/flow-graph.md`](flow-graph.md) — when each `cmd*` slot fires
- [`reference/agents-md.md`](agents-md.md) — the `## Commands` section where the project binds the slots
- [ADR 0005](../adrs/0005-placeholder-syntax.md) — syntax decision
- [`tasks/`](../tasks/) — the templates that consume these placeholders
