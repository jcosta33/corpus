# ADR 0022: Acceptance criteria are expressible as runnable checks

## Status

Accepted

## Context

The [agents-as-compiler readiness audit](../../.agents/audits/agents-as-compiler-readiness.md) named one BLOCKER (against the goal): a spec's acceptance criteria are prose a human or agent interprets, never compiled into machine-checkable assertions. The toolchain validations of [0021](./0021-verification-contract.md) (typecheck, lint, dependency-flow, test) prove the code is *well-formed and the existing suite passes* — they do **not** prove the code does *what the spec intended* unless the spec's intent is itself expressed as a runnable check. The reviewer (`adversarial-review`) then grades against the same prose spec the generator read — a correlated check, not an independent oracle. This is the gap between "disciplined conditioning" and "spec as code."

One lane already does it right: [`write-fix`](../skills/write-fix.md) requires a regression test that **fails before the fix and passes after**, anchored to a concrete reproduction — a validated oracle. The pattern is reachable; it just was not generalised to acceptance criteria.

## Decision

Each spec **acceptance criterion carries a check binding** — it is written so its satisfaction is verifiable, and it names *how*:

- `test` — a test exercises it (preferred); the test is shown to be a valid oracle (it fails when the criterion is violated, passes when satisfied — the assertion-flip / fail-then-pass discipline).
- `command` — an `AGENTS.md > Commands` entry's output demonstrates it.
- `manual` — interpretation is unavoidable; the criterion carries a one-line justification for why it cannot be a runnable check.

`write-spec` produces criteria in this form; `write-feature` maps each criterion → its check → pasted result in the self-review; `write-testing` turns `test`-bound criteria into oracles. The behaviour-preservation lanes (`refactor`, `migration`, `rewrite`) generalise `write-fix`'s fail-then-pass oracle: equivalence is shown by a check that would fail if behaviour changed, not only by "the existing suite still passes."

This scopes the "executable contract" language honestly: a Swarm spec is **prose whose acceptance criteria are meant to compile to checks**, with explicit `manual` exceptions — not a spec that directly generates an implementation.

## Consequences

- Positive: spec intent becomes verifiable, not just toolchain health — the closing gate for the feature lane stops being prose-matching by the generator's own model.
- Positive: narrows the correlated-failure trap — a `test`-bound criterion validated as an oracle is independent of the prose in a way an LLM re-reading the prose is not.
- Negative: does not eliminate correlation — an LLM-authored test of an LLM-misread criterion still passes both; an independent oracle (a human-authored reference test, property/differential checks) is stronger where available, and `manual` criteria remain interpretive.
- Negative: more authoring effort at spec time; the `manual` escape hatch prevents this from blocking criteria that genuinely cannot be automated.

## Alternatives rejected

- **Keep acceptance criteria as free prose.** The BLOCKER: intent is never checkable, and the reviewer grades against the same prose.
- **Require every criterion be a passing test, no exceptions.** Over-constrains — some criteria (UX feel, documentation tone) are genuinely manual; forcing a test invites tautological tests. The `manual`-with-reason tier keeps the requirement honest.
- **Make Swarm generate the tests/implementation (true compiler).** Out of scope — Swarm is a documentation framework with no runtime; it specifies that criteria *be* checkable, it does not execute them.
