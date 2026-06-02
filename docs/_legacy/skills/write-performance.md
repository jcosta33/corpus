# Skill (documentation): `write-performance`

> **For agents:** instructions → [`/scaffold/.agents/skills/write-performance/SKILL.md`](../../scaffold/.agents/skills/write-performance/SKILL.md)

---

## TL;DR

Performance work is targeted optimisation of a *measured* bottleneck under a *stated* target — not opportunistic tinkering. `write-performance` is the discipline behind three commitments: numbers, not vibes; the same measurement protocol before and after; never regress correctness for speed.

## The failure mode it prevents

Two characteristic disasters, and the skill exists to block both:

- **The benchmark that improved but production didn't.** The number moved under conditions that don't match reality — wrong input shape, wrong load profile, warm cache where prod runs cold. A "30% faster" that nobody can feel.
- **The speedup that quietly broke correctness.** A bug in performance clothing. The optimisation shaved milliseconds and silently changed a result, and nobody ran the test suite because "it's just a perf change".

## Core rules (summarised)

- **Measure first.** Establish a baseline benchmark in your worktree *before* touching code. Without a baseline, "improvement" has no meaning. "We know it's slow" is not a baseline.
- **Target = a number under conditions.** "p95 latency of `getQuote()` under 1k RPS drops from 240 ms to ≤ 80 ms," not "make X faster".
- **Hypothesis = a falsifiable claim.** State what you believe the bottleneck is and what measurement would disprove it. "I think this is slow" is not a hypothesis.
- **Same protocol before and after.** Warmup runs, sample count, statistical aggregate, hardware, environment — identical for baseline and final, or the comparison is meaningless.
- **Every change is benchmarked.** Change → re-run → compare. Don't batch optimisations; you can't tell which one mattered. Don't skip the benchmark because "I'm sure this helps".
- **Full test suite after every change.** Performance work does not get to skip the tests. A faster wrong answer is still wrong.
- **Document the conditions.** The speedup holds under a *specific* input shape, load profile, hardware, and cache state. Whoever inherits the code needs to know when it stops helping.
- **Readability is on probation, with a hard ceiling.** If the optimisation hurt readability, justify it and comment the call site, or the next refactor unwinds it. Define a regression ceiling below which the change rolls back regardless of other gains.

## Boundary

This is *targeted* work. A correctness fix against a defect is `fix`. Net-new work against a spec is `feature`. If the bottleneck isn't measured yet, that's an audit (or a research task to establish the benchmarking methodology) first — performance work starts from a number.

## Task type and suggested persona

`write-performance` carries the discipline for the [`performance`](../tasks/performance.md) task type. The matching persona is the [**Performance Surgeon**](../personas/the-performance-surgeon.md), whose runtime mindset ships as [`persona-performance-surgeon/SKILL.md`](../../scaffold/.agents/skills/persona-performance-surgeon/SKILL.md). The Skeptic reviews: same protocol both sides, suite still green, conditions documented.

Suggested defaults, not gates. If the work doesn't fit the performance shape, load the skill whose description matches and record the divergence in your task file's `## Decisions`.

## Project commands it reads

The skill resolves commands through `AGENTS.md > Commands` — `Validation` and `Test`. A `Benchmark` command is **not** in the required contract but performance work needs one; the skill asks the user which command to use and records it in the task file's `Measurement protocol`. Missing or undefined entries → it asks before establishing a baseline rather than inventing a command.

## What it ships

`references/task-template.md` — a fillable performance-task template: a baseline block (benchmark command, conditions, key metric, measurement), a target block (target value, hard ceiling), the hypothesis, the measurement protocol, a progress checklist, and a self-review hard gate covering baseline-and-target proof, correctness preservation, conditions/generality, and the readability tradeoff. Copy it into your project's task-file location, substitute the `{{...}}` placeholders, and fill it in as you work.

## Related

- [Task: performance](../tasks/performance.md)
- [Persona: the Performance Surgeon](../personas/the-performance-surgeon.md)
- [Building skills: self-containment](building/self-containment.md) — why this skill carries no cross-skill links and resolves commands through `AGENTS.md`
