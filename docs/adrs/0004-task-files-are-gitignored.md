# ADR 0004: Task files are gitignored

## Status

Accepted. Superseded by [ADR-0060](./0060-corpus-workspace.md) — tasks are committed workspace flow artifacts.

## Context

Task files are **session-local execution packages** tied to disposable worktrees. Committing them clutters history and encourages treating transient checklists as product truth.

## Decision

Convention: `.agents/tasks/` is **gitignored**. Durable knowledge must promote to audits, specs, research, bugs, or project docs **before** `status: done`.

## Consequences

- Positive: worktrees stay disposable; prompts stay reproducible via source docs + template, not accidental task prose.
- Negative: forgetting promotion loses findings — mitigated by the task template's pre-close Self-review gate (the always-loaded manage-task/documentation-gatekeeper skills were removed — see ADR 0017).

> **Ledger note (2026-06-11):** superseded by ADR-0060 (flow artifacts are committed workspace content).
