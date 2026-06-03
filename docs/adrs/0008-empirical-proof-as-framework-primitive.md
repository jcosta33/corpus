# ADR 0008: Empirical proof as a framework primitive

## Status

Accepted

## Context

Models complete the "successful task" pattern with confident summaries. Without structural proof gates, hallucinated greens pass review.

## Decision

Every code-changing task archetype mandates **verbatim** command output (or bounded equivalent) in `## Self-review` / verification sections. Paraphrase is invalid — a passed test with no pasted output is not a proof [[REFLEXION]](../research/sources.md#REFLEXION). Skeptic reviewers **re-run** checks locally.

Encoded in **`empirical-proof`** skill plus task templates (`/scaffold/.agents/templates/` and each skill's `references/task-template.md`).

This is a **specification-and-conspicuousness primitive, not an enforcement one.** Pasted output is agent-self-attested — gameable by fabricated or stale paste — so its power is that omission is *visible*, not that it is *prevented*. Mechanical enforcement (re-run the bound commands in a clean checkout, block promotion on failure or empty paste) is the contract a compliant runtime honours, specified by [0023](./0023-harness-enforcement-contract.md). The Skeptic re-run ([0021](./0021-verification-contract.md), rule 5) is the in-framework approximation; a harness is the real thing.

## Consequences

- Positive: makes a whole class of false completions *conspicuous* — the empty paste block is visible.
- Negative: self-attested — absent a re-running harness ([0023](./0023-harness-enforcement-contract.md)), the gate is the agent grading itself; conspicuousness reduces but does not eliminate fabricated or stale paste.
- Negative: slower closes; brittle in broken dev envs → must surface explicit `## Blockers`.
- Open: the discipline's *effectiveness* at reducing hallucinated completion is not yet measured against a Swarm-specific benchmark; it rests on the activation/Reflexion evidence.
