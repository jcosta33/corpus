# ADR 0003: Distillation is unidirectional

## Status

Accepted

## Context

Information must move from **high verbosity** (research, narrative) toward **executable task files**. Reverse flow ("code → spec", "feelings → audit as requirements") rewires truth to match patches and destroys auditability.

## Decision

Allowed transitions follow the verbosity gradient **downhill** only, with explicit **Distillation Loss Statements** when material is dropped. Promotions from task findings back into specs/audits are **narrow** corrective moves, not full reversals.

## Consequences

- Positive: accountable compression; ambiguity surfaces as authoring work (`spec-writing`) instead of silent implementation drift.
- Negative: mandates extra hops (research → spec → feature) — intentional friction.
