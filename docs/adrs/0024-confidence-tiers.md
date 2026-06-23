# ADR 0024: Self-reviewed vs independently-reviewed confidence tiers

## Status

Superseded by [0035](./0035-seven-value-verdict-model.md) — the self-reviewed / independently-reviewed tiers are recast as values of the **7-value verdict taxonomy** (§14, the 4 core + 3 lifecycle verdicts). The original decision text below is kept as history (Nygard, §30.1: an accepted ADR is never edited in place; only this status line is added).

## Context

The agents-as-compiler readiness audit found that the only independent oracle Corpus has — a Skeptic who re-runs validation in their own worktree — is (a) scoped to multi-agent review (`adversarial-review` skips solo authoring), (b) non-binding (routing is recommended, [0020](./0020-activation-by-self-assessment.md)), and (c) a single uncalibrated LLM judgment. Solo single-threaded work — the stated default for write-side tasks — terminates at the *same* agent's `## Self-review`. No document distinguished "the producing agent checked its own work" from "a separate agent independently verified it," so every result read as equally trustworthy when they are not.

## Decision

The framework names **two confidence tiers**, and a result records which it carries:

- **Self-reviewed** — the producing agent passed its own `## Self-review` hard gate (pasted output, acceptance-criteria coverage). This is the floor, and it is *all* a solo single-threaded task gets. Its ceiling is the correlated-failure trap: the agent grades its own output, and a reviewer re-reading the same prose spec is correlated with the generator.
- **Independently-reviewed** — a *separate* agent (the Skeptic) re-ran the project's validation and tests **in its own worktree** and walked the diff under `adversarial-review`. This is the bar a code-producing task should reach before merge (the flow-graph's Skeptic hand-off).

Code-producing tasks **should** reach *independently-reviewed* before merge; where they don't (solo work, skipped hand-off), the result is explicitly *self-reviewed* and must not be presented as more. The strongest form — an executable oracle independent of the generator's distribution, or verifier multiplicity (a panel / voting) — is named as available where the confidence bar demands it; the single-LLM-judge ceiling is recorded rather than hidden.

This does not make review mandatory (that would re-enforce routing, against [0020](./0020-activation-by-self-assessment.md)); it makes the *tier a result carries* explicit, so a reader — or a launcher's merge gate ([0023](./0023-harness-enforcement-contract.md)) — knows what confidence is actually backing it.

## Consequences

- Positive: honest labelling — "high confidence in EVERY task" is qualified by which tier the task reached; solo self-attestation is no longer mistaken for independent verification.
- Positive: gives a future harness a precise merge condition ("require independently-reviewed for code merges").
- Negative: does not eliminate the correlated-failure risk even at the independent tier (LLM grading LLM against the same prose); the executable-oracle binding ([0022](./0022-acceptance-criteria-are-executable-checks.md)) narrows it, verifier multiplicity narrows it further, neither closes it.
- Negative: a tier label is only as honest as the agent recording it — until a harness enforces the re-run, the tier is itself self-attested.

## Alternatives rejected

- **Treat all completed tasks as equally trustworthy.** The status quo the audit faulted — solo self-review and independent re-run read identically.
- **Make independent review mandatory for every task.** Re-enforces routing against [0020](./0020-activation-by-self-assessment.md) and over-constrains authoring/trivial tasks; naming the tier achieves the honesty without the lock.
