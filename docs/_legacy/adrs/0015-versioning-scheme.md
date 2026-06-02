# ADR 0015: Semantic-ish versioning for the framework scaffold

## Status

Accepted

## Context

Consumers copy `/scaffold` into repos. Undocumented breakage in templates/skills forks hundreds of workspaces silently.

## Decision

Treat **breaking changes** to template section names, mandatory skills, persona blocks, or flow-graph edges as semver-major for the framework package narrative. Minor adds optional sections/skills; patch fixes wording without behavioural change.

`MIGRATIONS.md` at the repo root (plural — consistent with `DEPRECATIONS.md`) records upgrade notes between framework milestones; `DEPRECATIONS.md` records removed surfaces. These ledger files are created **at the first milestone that needs them** — their absence pre-1.0 is expected, not a broken promise, so docs reference the policy here rather than hard-linking files that may not exist yet.

The version a consumer holds is recorded in **`.agents/.swarm-version`** (a single semver-ish line, e.g. `0.1.0`) so both an adopter and a conformance checker can read "what version do I hold" mechanically. The scaffold ships this file; bump it on every framework release.

## Consequences

- Positive: teams can judge upgrade risk when refreshing scaffolds.
- Negative: burdens maintainers with compatibility thinking — proportional to adoption.
