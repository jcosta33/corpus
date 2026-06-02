# ADR 0006: Skeptic mindset on `fix` tasks

## Status

Accepted

## Context

Fixes fail when engineers accept the **first plausible narrative** (`git blame`, last commit, obvious typo). Bugs often require adversarial narrowing: prove/disprove hypotheses, widen repro, falsify correlates.

## Decision

Primary **lead persona** for `fix` tasks is **The Skeptic**. The persona's hostility toward convenient explanations aligns with disciplined root-fix + regression proofs.

Separate **Bug Hunter** remains for **writing** defect reports (`bug-report-writing`); Skeptic-fix executes the remedy pass.

## Consequences

- Positive: fewer masking patches; proofs match failure mode severity.
- Negative: sceptical narration can alarm stakeholders — prose should cite **facts** (`file:line`, commands), not melodrama.
