<!-- checks fixture — expected results pinned in EXPECTED.md (this file) -->

# payment-5xx — expected check results

Checks fixture for [the check catalogue](../../../docs/reference/checks.md): payment
provider 5xx handling, with two seeded defects — a pair of contradictory requirements, and
an open blocking question in a spec marked `status: ready`. The results below are known by
hand and pin what corpus-cli's `corpus check` must report (toolable). Until that tool
runs, nothing here is enforced — reviewers use the same tables as a checklist.

**Check scope.** Each file is checked standalone. `spec.md` and `spec.sol.md` intentionally
share one `id:` — they are one spec written on both surfaces (this directory's equivalence
pair), not two specs. A real workspace keeps only one, so the pair itself never counts as a
C002 duplicate.

## Seeded defects

| Where                         | Defect                                                                          |
| ----------------------------- | ------------------------------------------------------------------------------- |
| AC-002 vs AC-003 (both files) | Same actor, same trigger, opposed strength words — must retry vs must not retry |
| Open questions (both files)   | A blocking question is unresolved while the spec claims `status: ready`         |

## spec.md (plain form)

| Check                  | Where          | Expected result                                                        | Severity   |
| ---------------------- | -------------- | ---------------------------------------------------------------------- | ---------- |
| C007 `no-tbd-at-ready` | Open questions | **fires** — an unresolved blocking question remains at `status: ready` | hard error |
| C001–C006, C008, C009  | —              | pass                                                                   | —          |

No core check keys on the contradiction in plain form — catching AC-002 vs AC-003 is a
review checklist item there. That gap is exactly what the stricter surface buys below.

## spec.sol.md (`format: sol`)

| Check                          | Where           | Expected result                                            | Severity   |
| ------------------------------ | --------------- | ---------------------------------------------------------- | ---------- |
| C007 `no-tbd-at-ready`         | Q-001           | **fires** — core checks apply to both surfaces             | hard error |
| SOL-M002                       | AC-002 / AC-003 | **fires** — same actor and trigger, opposed strength words | hard error |
| Every other SOL code (in-file) | —               | pass                                                       | —          |

## At task-splitting

`task.md` exists even though Q-001 is open and blocking — that is the third pinned result:
splitting work past an unresolved blocking question fires SOL-O003 (hard error). Answer or
downgrade the question first; preparing tasks past it commits a guess.

## Equivalence assertion

`spec.md` and `spec.sol.md` encode identical requirement records:

| id     | strength | statement                                                                                                    | verification                                                                                       |
| ------ | -------- | ------------------------------------------------------------------------------------------------------------ | -------------------------------------------------------------------------------------------------- |
| AC-001 | must     | When the same idempotency key is submitted twice, the payments service captures at most one charge.          | `payment-idempotency.spec.ts#at-most-one-capture` — plain: unresolved note · SOL: resolved binding |
| AC-002 | must     | When the provider returns a 5xx, the payments service retries the charge once with the same idempotency key. | `payment-retry.spec.ts#retries-once`                                                               |
| AC-003 | must not | When the provider returns a 5xx, the payments service does not retry the charge.                             | `payment-retry.spec.ts#no-retry`                                                                   |

Spec-level record: same intent, non-goals, one blocking open question, affected areas, and
sources in both files (SOL records the question as `QUESTION Q-001 [blocking]`; plain form
as a "Blocking:" bullet — same record). The SOL `WRITES` and `RISK` clauses are metadata
refinement. A checker that reads different records out of the two files is wrong (the
anti-fork rule) — including the contradiction: it must be present in both record sets, even
though only the SOL surface has a code that names it.

## task.md and review.md

| Check              | Where                      | Expected result                                                                                                                                                                                |
| ------------------ | -------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `non-empty-paste`  | review rows AC-001, AC-002 | pass — output pasted or linked                                                                                                                                                                 |
| `non-empty-paste`  | review row AC-003          | the Evidence cell is empty, so the row reads **Unverified** — never Pass                                                                                                                       |
| `no-open-critical` | review                     | **does not fire** — the open blocking question is correctly reflected as `status: blocked`; the rule guards terminal statuses. Counterfactual: the same packet at `status: pass` would fire it |
| `trigger-coverage` | review Human attention     | pass — names the contradiction, the blocked question, the unverified row, and the security-sensitive path                                                                                      |

## finding.md

Valid: one claim, evidence, applies/does-not-apply bounds, and future guidance, with `from:`
and `related:` resolving to this fixture's review and spec ids.

_Task-side note: `non-empty-paste` does **not** fire on the task fixture — its Verify boxes are
unchecked and it claims no completion; the rule binds completion claims, not open work._
