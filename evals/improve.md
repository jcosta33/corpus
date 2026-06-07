# `improve` — step-output rubric

> The output-quality predicate for the `improve` step: a candidate normalized `spec.swarm.md` MUST change no obligation's intent, drop no id/modality/binding, attribute every edit to one of the ten closed improve operations, and resolve (not silently delete) each blocking lint code. Each predicate is a boolean a reviewer decides by diffing the linted input spec against the improved output — no runtime.

`improve` is the `NORMALIZE`-phase step, run only after `lint`. It is the **only** step permitted to rewrite the spec, and every edit MUST be strictly semantics-preserving (R-IMPROVE). Its rubric grades whether the rewrite stayed inside the closed operation set and preserved every obligation's meaning — intent change routes to amendment, never to `improve`.

**Input artifact:** the linted `spec.swarm.md` + the `lint` report.
**Output artifact:** the normalized `spec.swarm.md` + the spec-improvement report.

## Output-grading predicates

Each predicate MUST hold. Any single failing predicate fails the step.

| # | Predicate | Holds when | Fails when |
| --- | --- | --- | --- |
| I1 | **Intent preserved** | No edit changes the **actor, trigger/state, modality, response, non-goal, or interface** of any obligation; the only approval-free semantic-diff class is pure normalization. | Any edit alters a clause that changes *what* the system builds (a different actor, a relaxed/strengthened modality, a changed trigger or response). |
| I2 | **No distillation loss** | No obligation id, modality, or `VERIFY BY` binding is dropped or weakened across the diff. | An id disappears, a `MUST` becomes a `SHOULD` (or vanishes), or a `VERIFY BY` binding is lost. |
| I3 | **Closed operation set** | Every edit is attributable to exactly one of the ten improve operations (`NORMALIZE`, `ATOMIZE`, `CONCRETIZE`, `QUANTIFY`, `BIND`, `SCOPE`, `CLARIFY`, `DECONFLICT`, `COMPRESS`, `PROMOTE`). | An edit cannot be attributed to any of the ten operations — an operation outside the closed set was invented. |
| I4 | **Lint answered, not masked** | Each blocking lint code from the input report is **resolved** (its repair applied) or **carried forward** (left for amendment with a recorded reason). | A blocking lint code's *text* is deleted while its underlying defect remains — the diagnostic is masked, not answered. |
| I5 | **Escalation honored** | Any intent-changing edit is routed to **amendment/review**, flagged `requires approval: yes` in the improvement report. | An intent-changing edit is applied silently as an improve op (also fails I1, but I5 names the missing escalation). |

### Operation → trigger correspondence

A reviewer checks I3 against the closed mapping: `NORMALIZE`←`SOL-P003`/`SOL-V###`, `ATOMIZE`←`SOL-P004`, `CONCRETIZE`/`QUANTIFY`←`SOL-P005`, `BIND`←`SOL-V001`/`SOL-V###`, `SCOPE`←`SOL-O###`, `CLARIFY`←`SOL-P008`, `DECONFLICT`←`SOL-M002`, `COMPRESS`←`SOL-P054`/`SOL-P055`, `PROMOTE`←the promotion protocol. An edit that applies an operation with no corresponding triggering lint code is a no-op authoring decision, not an improve op, and is scored against I3.

## Cross-step predicates scored here

The suite scores one cross-step predicate at the `improve` output:

- **Parse-validity** — the normalized spec re-parses clean against the grammar; the rewrite emits no structurally invalid block. (An improve step that fixes one smell while introducing a malformed block fails here.)

## Related

- [The `improve` step guide](../../docs/passes/improve.md) — the ten operations, the R-IMPROVE rule (I1/I5), and the twelve-category semantic-diff this rubric grades against.
- [The distillation-loss budget](../../docs/reference/distillation-loss-budget.md) — the no-distillation-loss discipline I2 enforces.
- [The flow graph](../../docs/reference/cheatsheet.md) — the closed set of exactly ten improve operations I3 checks membership against.
