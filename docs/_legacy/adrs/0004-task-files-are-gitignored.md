# ADR 0004: Task files are gitignored

## Status

Accepted

## Context

Task files are **session-local execution packages** tied to disposable worktrees. Committing them clutters history and encourages treating transient checklists as product truth.

## Decision

Convention: `.agents/tasks/` is **gitignored**. Durable knowledge must promote to audits, specs, research, bugs, or project docs **before** `status: done`.

## Consequences

- Positive: worktrees stay disposable; prompts stay reproducible via source docs + template, not accidental task prose.
- Negative: forgetting promotion loses findings — mitigated by the task template's pre-close Self-review gate (the always-loaded manage-task/documentation-gatekeeper skills were removed — see ADR 0017).
