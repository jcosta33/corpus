# ADR 0020: Activation by self-assessment

## Status

Accepted

## Context

[0002](./0002-personas-1-to-1-with-task-types.md) had the launcher *deterministically* set persona from task type plus flow graph, and the agent did not self-assign. In a vendored, à-la-carte world there may be no launcher applying the graph — a consumer can drop skills into any agent CLI that follows the [agents.md](https://agents.md/) standard. Activation can't depend on an enforcing gatekeeper that may not be present, and a removed gatekeeper skill ([0017](./0017-no-always-load-skills.md)) means nothing is left to block a mismatched route at run time anyway. Conditioning has to survive without an enforcer.

## Decision

Skills and personas **self-activate by self-assessment**. Each carries a **directive `description`** — "ALWAYS apply this skill when … Do not … Skip this skill for …" — and loads when its triggers match the work in front of the agent. The agent reads the task, matches descriptions, and loads what fits.

The **flow graph is recommended routing, not enforcement**. A launcher (the Swarm CLI or any compatible tool) *may* apply it deterministically when it scaffolds a task file, and the directive descriptions reproduce the same routing in-session. But it is guidance: when the suggested default doesn't match reality, the agent loads the skill whose `description` fits and records the divergence in its task file's `## Decisions`.

This **supersedes the enforcement stance of [0002](./0002-personas-1-to-1-with-task-types.md)**: the 1:1 task-type → persona pairing remains the *suggested* default, but it is no longer a deterministic, agent-can't-override assignment.

## Consequences

- Positive: conditioning works in any agent CLI, launcher or not — the description *is* the routing signal, carried with the skill.
- Positive: the agent can re-assess when reality straddles task types, instead of being forced into a misfit and re-tasked.
- Negative: depends on description quality — a vague or over-broad `description` mis-fires, so descriptions must be directive and carry explicit exclusions; this is why personas/skills can't link siblings to disambiguate ([0016](./0016-skills-are-self-contained.md)) and must name task types instead.
- Negative: loses hard determinism on the *routing* axis — a launcher that wants it must still apply the graph itself; the framework guarantees recommended routing, not enforced routing.
- **Tension with the agents-as-compiler goal, named explicitly.** Trading enforced routing for self-assessment removes determinism on the routing axis, which is in tension with the "spec-as-code / agents-as-compiler" ambition. It does **not**, by itself, weaken output confidence: *which conditioning loads* (routing) and *what proof a task must contain once active* (output verification) are **orthogonal axes**. The compensating mechanism lives on the output side — the per-task verification contract that requires empirical validation bound through `AGENTS.md > Commands` ([ADR 0021](./0021-verification-contract.md)) and the harness contract a compliant runtime honours ([ADR 0023](./0023-harness-enforcement-contract.md)). Requiring validations does not re-introduce a deterministic router; it makes the self-review *deliverable* uniform however the skill activated.
- **Cross-agent / cross-session conditioning reproducibility is a guarantee only when a launcher applies the graph; best-effort otherwise.** Two agents handed the same source doc + task type reach the same starting conditioning iff a launcher (or identical description-matching) routes them there.

## Alternatives rejected

- **Keep deterministic launcher-set personas ([0002](./0002-personas-1-to-1-with-task-types.md)).** Assumes a launcher is always present and an enforcing gatekeeper exists; neither holds for à-la-carte vendoring into an arbitrary agent CLI.
- **A standing gatekeeper skill that validates routing each task.** That is an always-loaded skill, rejected by [0017](./0017-no-always-load-skills.md); it also can't be guaranteed present on a consumer's machine.
