# ADR 0007: Bug-report is diagnosis-only ("meta-task")

## Status

Accepted

## Context

Diagnosis (repro, isolation, scope) uses different proofs than remedy (patch + regression suite). Combining them biases toward premature fixes and under-documented regressions.

## Decision

Authoring **`bug-report.md`** completes when the anomaly is reproducible and the root cause is stated with evidence — **without** embedding the patch. Fixing is **`fix`** routed from that report.

## Consequences

- Positive: clean separation of Bug Hunter forensic discipline from Skeptic-fix discipline.
- Negative: forces two hops for simple bugs — traded for clearer accountability.
