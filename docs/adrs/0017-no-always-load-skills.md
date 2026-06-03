# ADR 0017: No always-loaded skills

## Status

Accepted

## Context

Two concerns are candidates for loading on *every* task: task-file lifecycle and promotion discipline (`manage-task`), and routing and forbidden-flow rules (`documentation-gatekeeper`). A skill authored to load unconditionally is the wrong primitive. Skills load on demand and cost context every time they fire; content that must be present on every task is **persistent project context**, which belongs in the always-available entry file, not in a skill paid for on each activation [[LOSTMID]](../research/sources.md#LOSTMID).

An always-loaded skill also blurs the contract: an agent can't tell which skills matched the work from its `description` and which were force-fed, and consumers can't vendor selectively if two skills are secretly mandatory.

## Decision

There are **no always-loaded skills**. `manage-task` and `documentation-gatekeeper` are removed as skills. Content is re-homed by kind:

- **Persistent context** (facts, conventions, commands every task needs) → `AGENTS.md`.
- **Multi-step procedures** (the discipline for a kind of work) → on-demand skills that self-activate when their `description` matches (see [0020](./0020-activation-by-self-assessment.md)).

Concretely:

- `manage-task`'s task-file lifecycle and promotion discipline now live in the **task templates** (`.agents/templates/task-base.md` and the per-skill `references/task-template.md`) plus the **process docs** — the discipline is exercised where the task file is actually filled in, not preloaded as standing instructions.
- `documentation-gatekeeper`'s routing and forbidden-flow rules become **framework concept docs** describing *recommended* routing. They are guidance, not an enforced gate (see [0020](./0020-activation-by-self-assessment.md) and the superseding note on [0002](./0002-personas-1-to-1-with-task-types.md)).

## Consequences

- Positive: every loaded skill earned its place by matching the work; context isn't spent on dormant procedures.
- Positive: selective vendoring is honest — no hidden mandatory skills.
- Negative: the lifecycle/routing discipline is now distributed (templates + docs) rather than centralised in one skill — mitigated by keeping each task template carry its own slice and by the process docs being the single narrative.

## Alternatives rejected

- **Keep the two skills but mark them "auto-load".** Reintroduces the wrong primitive — per-task context cost for content that is really persistent (belongs in `AGENTS.md`) or really on-demand (belongs in a matching skill).
- **Fold both into `AGENTS.md` wholesale.** Over-stuffs the persistent file with multi-step procedures that most tasks don't need; procedures belong in on-demand skills, only the facts belong in `AGENTS.md`.
