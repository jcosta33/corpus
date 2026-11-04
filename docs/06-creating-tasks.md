# Tasks

Tasks are for separation, not importance. Cut one only when a ready spec contains independently
dispatchable parallel, context, repository, platform, or change-plan wave slices. Size alone proves
nothing. The common one-worker case implements directly from the spec and records `## Execution`
there.

A task narrows existing requirement IDs. If it invents one, it is a bad spec in disguise. A change
plan may add wave and preservation context but never replaces the source spec.

## Contract

A task must:

- name its source spec by absolute path;
- copy the scoped requirement snapshots and `Verify with:` lines;
- define a small write surface and a `Do not change` wall;
- map every scoped requirement to verification;
- record findings and the run summary;
- start only from a source spec with exactly `status: ready`.

`sus-task` writes the packet under the [agent-neutral artifact location](03-where-files-live.md).
Dispatch names the task and ready source spec by absolute path.

Exact shape: [artifact formats](reference/artifact-formats.md).
Add `## Self-review` only when it carries useful checks.

## Splitting

Split when:

- waves have distinct checkpoints and rollback boundaries;
- a prerequisite must land before dependent behavior;
- parallel work has disjoint write surfaces;
- one behavior needs independent implementation and verification across repositories or platforms.

Serialize tasks that write the same file. Parallel edits to one file are serialized conflict, not
parallelism. Prefix multi-repository affected areas:

```text
api: src/checkout/**
web: app/checkout/**
```

Each repository keeps its own verification command.

## Scope wall

Name tempting excluded areas such as schemas, public APIs, payments, authentication, generated files,
and unrelated modules. A polite suggestion is not a wall. A blocked worker stops for a decision. A
wall with an explicit escape path prevents more violations than prohibition alone
([[IMPOSSIBLE]](research/sources.md#IMPOSSIBLE)).

Every verification item names the command and requirement ID. Manual verification names who observed
what. Findings hold surprises, risks, and adjacent issues. The run summary points to evidence without
copying it.

Next: [execution](07-running-agents.md). Previous:
[inventories and change plans](05-brownfield-and-change-plans.md).
