# Skill (documentation): `fix-flaky-test`

> **For agents:** instructions → [`/scaffold/.agents/skills/fix-flaky-test/SKILL.md`](../../scaffold/.agents/skills/fix-flaky-test/SKILL.md)

---

## TL;DR

A flaky test fails non-deterministically — green sometimes, red sometimes, and almost always worse in CI than locally. `fix-flaky-test` exists to stop the most tempting non-fix in software: re-running until green, calling it fixed, and shipping the bug. Flakiness is almost always a *real* signal — about timing, ordering, shared state, or environmental coupling — and the only acceptable resolution is finding the root cause and removing it.

## The failure mode it prevents

The flake says something true about the system, and the lazy responses all suppress that signal instead of acting on it:

- **Re-run until green.** "Three reruns later it passed" is the bug, not the fix.
- **`await sleep(500)`.** The race is still there; the window in which it loses just got wider.
- **Quarantine as the resolution.** `.skip` / `.fail` / `it.if(env)` is containment, not a fix — and without a tracking issue and a date it becomes a permanently disabled test.
- **Widen the assertion.** Changing `toBe(5)` to `toBeGreaterThan(0)` because the value drifts masks the bug with a looser check.

## Core rules (summarised)

- **Reproduce before you claim to understand.** Loop the test — typically 100×, often 500×–1000× for low-frequency flakes — until it fires. A flake that won't reproduce in 1000 runs is *un-isolated*, not unreal: broaden conditions (CI, load, different seed, run alongside siblings).
- **Categorise the source.** Every flake belongs to a known category — timing/ordering, shared state, network/external, randomness, time, resource exhaustion, environment. Naming the category narrows the fix; mixed-category flakes get split.
- **Find the root cause in production code or test setup, not in the assertion.** The assertion is the messenger. The cause lives in nondeterministic production code, un-isolated setup/teardown, a parallel-runner harness, or the environment.
- **Reject sleeps and timeout-bumps** — unless timing is genuinely part of a documented async contract, in which case you wait on the *contract*, not on a hope.
- **Reject quarantine as the resolution.** It has a place (keeping CI green while a real fix is investigated) but it is never the fix.
- **Verify by loop-running 100×–1000× and pasting the output.** A flake reproduced once is not a flake fixed once. The pasted pass/fail summary lives in `## Self-review > Verification outputs`; without it, "I think it's fixed" is unfalsifiable.
- **Document the cause inline.** A one-liner in the test or production code (*"session ID is seeded; do not use `Math.random` here"*) makes the failure mode recognisable next time.
- **If the cause is in production code, hand off downstream.** A flake is sometimes the symptom of a real production bug — a race, an unhandled rejection, a resource leak. This skill produces the diagnosis; the production fix is a downstream bug-fix task, with the now-stable test as its regression guard.

## Boundary

`fix-flaky-test` is *specialised* — it stabilises an *existing* test. It is not for authoring new tests (that's `write-testing`), not for feature work whose tests fail deterministically (that's `feature`), and not for a test that fails 100% of the time after a change (that's a `fix` if a regression, or `feature` if the expected behaviour changed). Deterministic failure is a different category of problem.

## Task type and suggested persona

`fix-flaky-test` is one of the framework's specialised skills — it has no dedicated 1:1 task-type page; the work fits inside the broader [`testing`](../tasks/testing.md) lane, but the skill is what carries the stabilisation discipline. The temperament is investigative and adversarial: reproduce, categorise, root-cause, prove. The Skeptic reviews the verification — was the loop-run output actually pasted, did *every* run pass, was the cause removed rather than hidden.

Suggested default, not a gate. Load it whenever non-deterministic failures show up — even when the user never says the word "flaky" — and record the routing in your task file's `## Decisions`.

## Project commands it reads

The skill resolves the test command through `AGENTS.md > Commands > Test`. A loop-runner ("run this test 500 times") is **not** in the standard contract; the skill asks the user how the project loops a single test (e.g. `--repeat=500`, `--test-threads=1`, a custom CI matrix). If `AGENTS.md` is missing or the test command is undefined, it asks before declaring reproduction reliable — guessing the command produces false signals.

## What it ships

`references/task-template.md` — a task-file scaffold for a flaky-test session: the flake-category field, the loop-run reproduction protocol, and the verification table where the passing loop-run output lands. Copy it into your project's task-file location, substitute the `{{...}}` placeholders, and fill it in as you work.

## Related

- [Skill: write-testing](write-testing.md) — for authoring new tests from scratch
- [Task: testing](../tasks/testing.md) — the broader lane this specialised skill operates within
- [Building skills: self-containment](building/self-containment.md) — why this skill carries no cross-skill links and resolves commands through `AGENTS.md`
