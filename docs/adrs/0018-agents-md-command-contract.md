# ADR 0018: Commands resolve through the `AGENTS.md` contract

## Status

Superseded by [0038](./0038-verify-by-adapters-through-commands.md) — command resolution is recast as `VERIFY BY` adapters resolving through `AGENTS.md > Commands` (§15, §31.3); the single-source-of-truth `## Commands` table is preserved and bound to the SOL proof model. The original decision text below is kept as history (Nygard, §30.1: an accepted ADR is never edited in place; only this status line is added).

## Context

Skills must run a project's validation, test, and format commands without hardcoding tooling (pnpm vs cargo vs maven). [0005](./0005-placeholder-syntax.md) established `{{name}}` placeholders for *templates*. But a `SKILL.md` body is prose the agent reads and acts on directly, not a template a launcher fills — so a raw `{{cmdValidate}}` in skill prose is a placeholder with nothing to bind it. Skill bodies need a way to name the command-to-run that resolves at read time and degrades gracefully when the binding is absent.

## Decision

Two surfaces, one source of truth.

- **Skill bodies reference commands by their contract name in prose**, e.g. "run the project's validation command, `AGENTS.md > Commands > Validation`" — never a bare `{{cmd}}` placeholder used as an invocation. If the named entry is missing or undefined, the skill **asks the user before running anything** and proceeds once told. Skills never invent concrete commands.
- **Templates keep the `{{cmd*}}` placeholders** (`{{cmdValidate}}`, `{{cmdTest}}`, `{{cmdFormat}}`, `{{slug}}`, …) in `.agents/templates/` and each skill's `references/task-template.md`. A launcher binds them from the same source.

That source is the new **`## Commands`** section of `AGENTS.md` — naming the repository's commands in the context file is what makes them reliably reached [[AGENTSMD-HARM]](../research/sources.md#AGENTSMD-HARM). It maps the contract names to placeholders and to project commands across three tiers, so every placeholder in the catalogue is bindable or explicitly marked:

- **Required** — `Validation` → `{{cmdValidate}}`, `Test` → `{{cmdTest}}`, `Format` → `{{cmdFormat}}`.
- **Extended** — bound when the relevant work occurs: `Install`, `Typecheck`, `Lint`, `Build`, `ValidateDeps` (dependency-flow / architecture-boundary), `Benchmark`. Mark `n/a` with a reason if absent.
- **Out-of-contract** — `MarkdownLint`, `LinkCheck`, `CitationCheck`: doc/research-specific; a project binds them only if a `documentation`/`research-writing` task needs one, otherwise the skill asks at run time. They are catalogued (with status) in `docs/reference/template-placeholders.md` but carry no standard `AGENTS.md` row.

One table feeds both the prose references (read by the agent) and the placeholder bindings (filled by the launcher). Every `{{cmd*}}` in the catalogue maps to a tier above — none is unbindable by construction.

This reconciles with [0005](./0005-placeholder-syntax.md): placeholders remain the template mechanism; the named-entry prose reference is the read-time mechanism for skill bodies; both resolve to the single `AGENTS.md > Commands` table.

## Consequences

- Positive: skills stay language-agnostic and self-contained (no invented commands, no leaked tooling — see [0016](./0016-skills-are-self-contained.md)).
- Positive: graceful degradation — a partially-configured repo gets a question, not a wrong command or a silent skip.
- Negative: a consuming repo must fill the `## Commands` table for skills to run unattended; an unfilled entry turns into a prompt every session until bound (the file itself advises promoting repeated answers into the table).

## Alternatives rejected

- **Hardcode commands in skill bodies.** Forks the framework per stack and leaks tooling into portable skills.
- **Use `{{cmd}}` placeholders inside skill prose too.** Skill bodies aren't launcher-rendered, so the placeholder would surface unresolved to the agent — a literal `{{cmdValidate}}` is not a runnable command. Named-entry prose with graceful degradation is the read-time-correct form.
