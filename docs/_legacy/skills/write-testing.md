# Skill (documentation): `write-testing`

> **For agents:** instructions → [`/scaffold/.agents/skills/write-testing/SKILL.md`](../../scaffold/.agents/skills/write-testing/SKILL.md)

---

## TL;DR

Tests are specifications by other means. `write-testing` is the discipline that keeps them honest: a good test fails for *one* reason, exercises behaviour the caller actually cares about, and survives a refactor that preserves that behaviour. A test that's testing the implementation is a maintenance burden wearing a safety net's clothing.

## The failure mode it prevents

Three kinds of net-negative test — they cost maintenance and catch nothing:

- **The test that passes when commented out.** It asserts something that's true regardless of the code under test. Pure ceremony.
- **The test that tests internals.** It reaches into private methods and module-private state, so it shatters the moment someone refactors the implementation *without changing behaviour*. That's the test breaking, not the code.
- **The bundled test.** Six unrelated assertions in one case. When it fails, it tells the developer "something broke" without saying what.

## Core rules (summarised)

- **Test behaviour, not implementation.** Exercise the public surface. A test that breaks on a behaviour-preserving refactor is a bad test.
- **One test, one reason to fail.** Each test asserts one specific behaviour. If it can fail for two reasons, split it.
- **Flip the assertion to prove the test means something.** After writing each test, flip its assertion (or comment out the path it exercises) → it must fail; restore → it must pass. Paste a representative sample of that failing-then-passing transition into the self-review. A test that passes when flipped tests nothing.
- **A criterion-bound test must encode the criterion's intended behaviour.** When a test is the oracle for a spec acceptance criterion (binding `test`, per [ADR 0022](../adrs/0022-acceptance-criteria-are-executable-checks.md)), two *separate* proofs are required: the assertion-flip proves it fires (not a tautology), and the criterion mapping proves it fires for the right reason — it must assert the behaviour the criterion describes, not an adjacent passing condition, and fail when the *criterion* is violated. If no fail-when-violated test can be built, that's a finding for the spec author (rebind to `command` / `manual`), not licence to ship a green-but-irrelevant test.
- **Place tests per the project's conventions.** Don't guess layout. Follow the existing file-naming / directory / runner convention; if several exist, pick the one closest to the code under test and document the choice.
- **Coverage is a smell, not a target.** A poorly-tested covered line is worse than an uncovered one — it manufactures false confidence. Test the behaviour that deserves a test, not the percentage.
- **Failure messages must be useful.** "AssertionError: expected true" tells the developer nothing. Descriptive test names; descriptive assertion messages where the runner supports them.
- **Tests must be deterministic.** No ordering, timing, shared-mutable-state, unsandboxed-network, or unseeded-randomness dependencies. Flaky tests train developers to ignore failures — the worst outcome.
- **Don't bend production code to ease testing** (without spec authorisation). Hard-to-test code is a finding to promote, not a licence to weaken the production behaviour.

## Boundary

This skill is for *adding or improving* test coverage as a deliverable in its own right. If you're writing tests *as part of* implementing or fixing code, that's `feature` / `fix` — tests are already part of those deliverables, not a separate phase. And a test that fails *deterministically and non-reproducibly* is a different problem — see `fix-flaky-test`.

## Task type and suggested persona

`write-testing` carries the discipline for the [`testing`](../tasks/testing.md) task type. The matching mindset is the **Test Author** — one of the six mindsets that do *not* ship as a standalone persona skill; the temperament rides along with `write-testing` itself. The Skeptic reviews: does each test fail when flipped, does it survive a behaviour-preserving refactor, is the failure message actionable.

Suggested defaults, not gates. If the work doesn't fit the testing shape, load the skill whose description matches and record the divergence in your task file's `## Decisions`.

## Project commands it reads

The skill resolves commands through `AGENTS.md > Commands` — `Test` and `Validation`. Missing or undefined entries → it asks the user which command to run before declaring a new test "passing", rather than guessing.

## What it ships

`references/task-template.md` — a fillable testing-task template: a coverage-gap block, a test-cases table (behaviour / inputs / expected outcome / reason this test exists), a test-placement table, a progress checklist that includes the assertion-flip and criterion-encoding steps, and a self-review hard gate. The hard gate enumerates the required verification suite for a `testing` task — the project's test command, its coverage report, and validation — plus the assertion-flip proof, the criterion-encoding mapping (for any acceptance-criterion-bound test), behaviour-over-implementation, failure-mode clarity, placement, and robustness. Copy it into your project's task-file location, substitute the `{{...}}` placeholders, and fill it in as you work.

## Related

- [Task: testing](../tasks/testing.md)
- [Skill: fix-flaky-test](fix-flaky-test.md) — when an existing test fails non-deterministically
- [Building skills: self-containment](building/self-containment.md) — why this skill carries no cross-skill links and resolves commands through `AGENTS.md`
