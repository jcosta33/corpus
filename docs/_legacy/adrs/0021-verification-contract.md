# ADR 0021: The verification contract — required validations bind through `AGENTS.md > Commands`

## Status

Accepted

## Context

The [agents-as-compiler readiness audit](../../.agents/audits/agents-as-compiler-readiness.md) found that Swarm conditions the *input* an agent reads but verifies the *output* only by self-attestation, and that the empirical validations a task should run were specified unevenly — each `write-*` skill's task template carried a different, ad-hoc set of paste slots, and several "usual suspect" checks (lint, dependency-flow, typecheck) were not consistently required where they matter. A framework that aims at high per-task confidence cannot leave the validation suite to each skill's discretion.

Swarm has no runtime ([0001](./0001-four-doc-types.md) line of reasoning; [PRINCIPLES.md](../PRINCIPLES.md) #1) — it cannot *execute* a check. But the skills and templates *can specify which validations a task type must run*, and [0018](./0018-agents-md-command-contract.md) already gives the binding mechanism: the `AGENTS.md > Commands` table maps abstract command names to a project's concrete commands. The lever is to make the required validation suite **explicit, uniform, and bound through that one contract**.

## Decision

Every task type declares a **required validation suite** drawn from the `AGENTS.md > Commands` contract. The suite is:

1. **Canonically defined once** in [`reference/flow-graph.md`](../reference/flow-graph.md) (the "Task type → verification commands" matrix) and [`reference/verification-gates.md`](../reference/verification-gates.md) (the phase model: pre / periodic / post / self-review).
2. **Instantiated** as one `[Paste output]` slot per required command in each skill's `references/task-template.md` `### Verification outputs` block (and the flat skill-less templates).
3. **Referenced** by skill bodies in prose via the named `AGENTS.md > Commands > …` entry ([0018](./0018-agents-md-command-contract.md)), degrading to "ask the user" when unbound.

The self-review hard gate requires **one pasted proof per required command** — `empirical-proof`'s "one verification per claim" rule applied to a now-complete, per-task-type suite. A required slot is satisfied by pasted output or by an explicit `n/a` with a one-line reason; it cannot be silently omitted.

This is **orthogonal to [0020](./0020-activation-by-self-assessment.md)**: 0020 governs *which* skills/personas activate (routing); this ADR governs *what proof a task must contain once active* (deliverable completeness). Requiring validations does not re-introduce a deterministic router — it makes the self-review deliverable uniform however the skill activated. It is the compensating mechanism, on the output side, for the routing determinism 0020 relaxed.

## Consequences

- Positive: the validation suite per task type is no longer ad-hoc — it is one matrix, bound through one contract, with a paste slot for each required check. A reviewer (or a future conformance checker, [0026](./0026-conformance-contract.md)) can tell at a glance whether a task ran its required suite.
- Positive: the "usual suspects" (typecheck, lint, dependency-flow, format, test, build, benchmark) all become first-class, bound, and required where they matter — closing the audit's verification-thinness findings.
- Negative: still self-attested — Swarm specifies *that* the suite must run and be pasted; it cannot *enforce* the run. Enforcement is a launcher/CLI concern ([0023](./0023-harness-enforcement-contract.md)). This ADR raises the floor (uniform, conspicuous, complete) without reaching enforcement.
- Negative: a consuming repo must bind more of the `AGENTS.md > Commands` table for a task to run its full suite unattended; unbound extended slots become run-time prompts until filled.

## Alternatives rejected

- **Leave per-skill validation ad-hoc.** The status quo the audit faulted: uneven coverage, no single place to see what a task type must verify.
- **A universal validation timetable applied to every task type.** Over-constrains — an `audit-writing` task should not run a build; the suite is per-task-type by design (the matrix), not one-size-fits-all.
- **Wait for the Swarm CLI to enforce.** Enforcement is downstream; the *contract* (which validations, bound how) is the framework's job and must exist first for any runtime to honour it.
