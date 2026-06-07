# `review` — step-output rubric

> The output-quality predicate for the `review` step: a candidate `review.md` MUST carry a `VERDICT` for every required obligation, make each verdict match the recorded evidence with lifecycle decorators applied where their condition holds, judge claims independently of the trace's self-report, list every diff hunk outside the write surface, and compute the merge gate by the gate rule without asserting past a FAIL/UNVERIFIED. Each predicate is a boolean a reviewer decides by comparing the source spec, the diff, the proof evidence, and the emitted review — no runtime.

`review` is the `REVIEW`-phase step, run under the `skeptic` profile. It judges trace claims, applies the lifecycle decorators (`WAIVED`/`STALE`/`CONTRADICTED`), and computes the merge gate. Its rubric grades whether the review is **complete, evidence-correct, sceptically independent, and gate-honest**.

**Input artifact:** the source `spec.swarm.md`, the diff, and the `trace.md` proof evidence.
**Output artifact:** the `review.md` (per-obligation verdicts + the merge-gate result).

## Output-grading predicates

Each predicate MUST hold. Any single failing predicate fails the step.

| # | Predicate | Holds when | Fails when |
| --- | --- | --- | --- |
| R1 | **Verdict completeness** | Every required obligation carries a `VERDICT` in `review.md`. | A required obligation has no verdict. |
| R2 | **Verdict-correctness** | Each core verdict matches the recorded evidence, **and** lifecycle decorators (`WAIVED`/`STALE`/`CONTRADICTED`) are applied wherever their condition holds. | A verdict contradicts its evidence, or a decorator's condition holds but the decorator is missing (e.g. an edited-after-PASS surface not marked `STALE`). |
| R3 | **Sceptical independence** | The review judges trace claims against the **source spec, the diff, and the proof evidence** — not against the trace's self-report. | A verdict is justified only by the implementer's summary — summary-only evidence. |
| R4 | **Unauthorized-change caught** | Any diff hunk **outside** the `WRITES` surface is listed in the review. | An out-of-surface diff hunk goes unlisted. |
| R5 | **Gate computed** | The merge-gate result follows the gate rule — *all required verdicts `PASS` or `WAIVED`; none `STALE`/`CONTRADICTED`/`FAIL`/`BLOCKED`/`UNVERIFIED`* — and is **not asserted past** a `FAIL`/`UNVERIFIED`. | The gate opens with a required obligation `STALE`/`FAIL`/`UNVERIFIED`, or the gate result contradicts the verdict set. |

### Decorator and gate checks a reviewer applies

- For R2, the lifecycle decorators have conditions a reviewer decides from evidence: `STALE` when the recorded source/surface hash no longer matches the current write surface; `CONTRADICTED` when a higher-authority source disagrees with the obligation; `WAIVED` when an explicit, recorded waiver covers a required obligation. A decorator applied without its condition, **or** a condition holding with no decorator, both fail R2.
- For R5, a `STALE` required obligation is **not** a failure but is **not mergeable** either — the gate stays closed (`BLOCKED`) until the STALE is reconciled (re-run the proof, amend the spec, or fix the code), never silently re-blessed. A gate that opens over an un-reconciled `STALE` fails R5.

## Cross-step predicates scored here

The suite scores three cross-step predicates at the `review` output:

- **Trace-completeness** — every assigned obligation reaches a verdict (R1 is its review-stage expression), and every verdict names an obligation that exists upstream.
- **Verdict-correctness** — each `VERDICT` is consistent with its evidence and the 7-value model; R2 is its review-stage expression.
- **Drift-detection** — the review classifies and surfaces **stale spec drift** (approved obligation with no matching evidence), **undocumented implementation drift** (observed behaviour with no approved obligation), and **stale proof drift** (a passing binding no longer exercising its obligation), rather than silently passing them. A drift class present in the fixture but unflagged fails this predicate even if R1–R5 all hold.

## Related

- [The `review` step guide](../../docs/passes/review.md) — the skeptic-profile contract, the decorator conditions (R2), and the merge-gate rule (R5) this rubric grades.
- [The flow graph](../../docs/reference/cheatsheet.md) — the 7-value verdict model (4 core + 3 lifecycle) R2 checks against.
- [Drift and staleness](../../docs/reference/drift-and-staleness.md) — the four staleness conditions the drift-detection predicate scores.
