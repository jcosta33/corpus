# The Step-Output Rubrics

> Swarm's producer-side self-tests: nine per-step quality predicates that score whether an agent actually *performed* a step, plus the four cross-step predicates the suite scores wherever the relevant artifact appears. These rubrics measure the framework's own behaviour. They are not installed into any adopted project.

Swarm is markdown-only, provider-neutral, and has **no runtime**. These rubrics are **inert scoring data**: each predicate is a boolean assertion a human reviewer (or a future eval harness) decides by reading a step's input artifact and its output artifact, never by running a tool. Nothing here executes.

## What these rubrics are — and are not

The golden corpus pins *what a correct flow produces* — the expected obligations, traces, and verdicts of each fixture. The **step-output rubrics** are the complementary half: the scoring criteria the suite runs *against a candidate step's actual output* to decide whether the transformation was performed correctly. They exist because **schema-validity is not correctness**. A `task.md` can be perfectly well-formed and still drop an obligation; a `review.md` can carry every required `VERDICT` block and still be summary-only. The grammar checks (the `SOL-S` lint family and the task-file violation classes) already cover well-formedness; these rubrics grade *step behaviour* — did the transformation preserve the obligations, bindings, scopes, authorities, and verdicts it was contracted to preserve.

Each rubric is a small set of **checkable predicates**, not a Likert or quality score. A predicate either holds or it does not. The suite reports the count of failing predicates per step, and **a single failing predicate fails the step**. Every predicate is decidable against the step's input artifact plus its output artifact alone — no runtime, no tool under test is presumed.

These are **producer-side self-tests**. They measure the Swarm framework's own validity fixtures and any agent executing the flow. They are deliberately *not* part of the starter kit an adopter installs: an adopted project gets the authoring skills, reference cards, and templates, but not these rubrics, because an adopter does not re-grade the framework. That is why these pages live under `evals/` and may freely link sibling `docs/` pages.

## The nine rubrics, one per step

The rubrics are indexed in flow order. Each page states that step's output-grading predicates (what a correct output MUST exhibit) and re-states the cross-step predicates the suite scores at that stage.

| Step | Phase(s) | Rubric | Grades |
| --- | --- | --- | --- |
| `author` | entry | [author.md](author.md) | source fidelity, stance, surfaced uncertainty |
| `lint` | PARSE + NORMALIZE | [lint.md](lint.md) | parse-validity decided, blocking recall, non-mutation, severity |
| `improve` | NORMALIZE | [improve.md](improve.md) | intent preserved, no distillation loss, closed op set |
| `lower` | LOWER | [lower.md](lower.md) | total obligation preservation, binding/authority survival, edge soundness |
| `decompose` | LOWER | [decompose.md](decompose.md) | write-disjoint packets, DAG order, total coverage, context |
| `implement` | EXECUTE | [implement.md](implement.md) | scope-faithful diff, obligation coverage, trace honesty |
| `verify` | VERIFY | [verify.md](verify.md) | proof-result completeness, adapter resolution, provenance |
| `review` | REVIEW | [review.md](review.md) | verdict completeness/correctness, sceptical independence, gate |
| `promote` | PROMOTE | [promote.md](promote.md) | nothing durable left task-local, provenance, stance, no spurious |

The nine steps and their phase mapping are the canonical set fixed in the [flow graph](../../docs/reference/cheatsheet.md); these rubrics add no step and remove none.

## The four cross-step predicates

Four predicates are not owned by a single step. The suite scores them **wherever the relevant artifact appears**, because they are the flow-wide correctness invariants the corpus exists to defend. Each per-step rubric page re-states the cross-step predicates that apply at its stage; this table is the single definition.

| Cross-step predicate | What it asserts | Scored at the output of |
| --- | --- | --- |
| **Parse-validity** | Every emitted SOL artifact re-parses clean against the grammar; no step emits a structurally invalid block. | `author`, `improve`, `lower`, `decompose`, `promote` |
| **Trace-completeness** | The backward chain `obligation → task → trace → verdict` is unbroken: every assigned obligation reaches a verdict, and every verdict names an obligation that exists upstream. | `decompose`, `implement`, `verify`, `review` |
| **Verdict-correctness** | Each `VERDICT` is consistent with its evidence and the 7-value verdict model (4 core + 3 lifecycle decorators); no decorator is applied without its condition, no core verdict contradicts its proof result. | `verify`, `review` |
| **Drift-detection** | The step classifies and surfaces each drift class — stale spec drift, undocumented implementation drift, stale proof drift, and memory drift — rather than silently passing it. | `review`, `promote`; the stale-memory and unauthorized-change fixtures |

Drift-detection is defined without a runtime: drift is found by the `review` and `promote` steps comparing the approved obligation set against the recorded evidence and the higher-authority sources, never by observing a running system. A step that fails to flag a drift class present in its fixture fails the drift-detection predicate **even if every other predicate holds**.

## How a rubric is scored (no runtime)

For a candidate step output, a reviewer (or future harness):

1. Reads the step's **input artifact** and its **output artifact**.
2. Evaluates each predicate on that rubric page as a boolean, citing the span that decides it.
3. Re-evaluates the cross-step predicates listed for that stage.
4. Reports the count of failing predicates. **Any failing predicate fails the step.**

Because every predicate is decidable from the two artifacts alone, the score is reproducible by hand today and automatable by a future harness without either trusting or running the tool under test. The held-out mutated variants in the corpus are the contamination guard: a step that satisfies a rubric on the canonical fixture but not on its semantically equivalent mutated twin has memorized the label, not executed the transformation, and is scored a fail on that step.

## Related references

- [The golden corpus](../../docs/reference/golden-corpus.md) — the inert fixture suite these rubrics are scored over; defines the nine rubrics and the cross-step predicates this directory expands.
- [The flow graph](../../docs/reference/cheatsheet.md) — the canonical counts (7 blocks, 5 modals, 7 verdicts, 9 proof types, 9 steps, 10 improve operations, 5 lint layers) every rubric cites.
- [The step guides](../../docs/passes/) — the per-step contracts each rubric grades against.
- [The lint catalogue](../../docs/language/errors.md) — every `SOL-<LAYER>NNN` code a rubric references.
- [Drift and staleness](../../docs/reference/drift-and-staleness.md) — the four staleness conditions the drift-detection cross-step predicate scores.
