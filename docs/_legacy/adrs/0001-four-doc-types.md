# ADR 0001: Four core document types

## Status

Accepted

## Context

Agent workflows need durable artefacts with **distinct epistemic jobs**. Mixing intents (explain vs prescribe vs observe vs reproduce) collapses auditing, causes silent drift, and makes routing ambiguous.

Industry practice (Diátaxis, GitHub Spec Kit separation) converges on multiple kinds of upstream truth.

## Decision

Define **four core** durable document kinds in Swarm:

- **research** — understanding-oriented exploration
- **spec** — prescriptive requirements the Builder executes against
- **audit** — present-state violations / debt ledger
- **bug-report** — deterministic reproduction plus root cause, not fix

Extended types (ADR, constitution, migration plan, benchmarks) orbit these without replacing them.

## Consequences

- Positive: deterministic document → task routing; agents cannot "implement from research" without a spec-writing hop.
- Negative: taxonomy overhead — teams must classify before routing.
- Operational: compatibility tables and the recommended-routing docs encode this boundary (the documentation-gatekeeper skill was removed — see ADR 0017).
