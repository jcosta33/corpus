# ADR 0026: A machine-readable conformance contract + fixtures

## Status

Accepted

## Context

The [agents-as-compiler readiness audit](../../.agents/audits/agents-as-compiler-readiness.md) found that Swarm conformance is **100% prose**: the rules for "is this repo Swarm-conformant?", "is this a well-formed task file?", and "are the `AGENTS.md > Commands` bindings present?" exist (in [`reference/directory-layout.md`](../reference/directory-layout.md), [`reference/agents-md.md`](../reference/agents-md.md), [`reference/template-placeholders.md`](../reference/template-placeholders.md)) but are mechanizable nowhere. A framework whose goal is spec-as-code should make *its own* rules machine-checkable first. The conformance checker is acknowledged as a future CLI concern ("when it ships") — but the **contract** it would check does not exist in a machine-readable form, so there is nothing precise to build against.

## Decision

The framework ships a **machine-readable conformance contract** under `scaffold/.agents/conformance/` (copied into consuming repos), plus **fixtures**. The contract is data, not an executor — consistent with Principle 1.

1. **A schema/manifest** enumerating: the required and optional sections of a well-formed task file (keyed to `task-base.md` — at minimum `## Linked docs`, the per-task `### Verification outputs` slots, and the `## Self-review` hard gate); the required `AGENTS.md > Commands` rows ([0018](./0018-agents-md-command-contract.md): `Validation`/`Test`/`Format`); and the legal placeholder namespaces ([0005](./0005-placeholder-syntax.md), [template-placeholders](../reference/template-placeholders.md)).
2. **A "well-formed task file" definition** a tool can validate — including the content rule that a required `[Paste output]` slot must contain non-empty, non-placeholder text (the mechanizable form of the empirical-proof gate).
3. **Fixtures**: one conformant example, and one example per violation class (empty paste block, missing required slot, illegal placeholder, missing required `Commands` row) with expected pass/fail — so a checker (the Swarm CLI or any tool) has a precise target and a regression suite.

The checker itself remains a CLI concern; this ADR makes the *contract + fixtures* a framework artefact. Together with [0023](./0023-harness-enforcement-contract.md) (re-run + block) it gives a runtime both *what to enforce* (this) and *how* (0023).

## Consequences

- Positive: "is this conformant?" becomes answerable mechanically; a future checker has a schema + fixtures instead of prose to interpret.
- Positive: the spec-as-code goal applies to the framework's own rules first — the most credible place to start.
- Negative: a second representation of rules that also live in prose; the two must stay in sync (the fixtures are the guard — a prose change that breaks a fixture is caught).
- Negative: ships files most consumers won't run until a checker exists; they are inert-but-cheap contract data, not behaviour.

## Alternatives rejected

- **Leave conformance as prose.** The status quo the audit faulted — nothing is checkable, including the framework's own structure.
- **Ship the checker in this repo.** Violates Principle 1. The contract + fixtures are framework; the executor is CLI.
- **Wait for the CLI to define its own contract.** Cedes the framework's definitional authority and guarantees drift between what the framework means and what a tool checks.
