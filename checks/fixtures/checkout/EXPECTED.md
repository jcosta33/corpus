<!-- checks fixture — expected results pinned in EXPECTED.md (this file) -->

# checkout — expected check results

Checks fixture for [the check catalogue](../../../docs/reference/checks.md): cart submission
and checkout, with two seeded defects — a bundled requirement, and two requirements sharing
one write area. The results below are known by hand and pin what corpus-cli's
`corpus check` must report (toolable). Until that tool runs, nothing here is enforced —
reviewers use the same tables as a checklist.

**Check scope.** Each file is checked standalone. `spec.md` and `spec.sol.md` intentionally
share one `id:` — they are one spec written on both surfaces (this directory's equivalence
pair), not two specs. A real workspace keeps only one, so the pair itself never counts as a
C002 duplicate.

## Seeded defects

| Where                        | Defect                                                                             |
| ---------------------------- | ---------------------------------------------------------------------------------- |
| AC-001 (both files)          | Three separable behaviors bundled into one requirement (validate · charge · email) |
| AC-002 + AC-003 (both files) | Both write `db/orders` — one write area shared by two requirements                 |

## spec.md (plain form)

| Check                             | Where  | Expected result                                            | Severity              |
| --------------------------------- | ------ | ---------------------------------------------------------- | --------------------- |
| C004 `one-strength-word`          | AC-001 | pass — exactly one "must" (the bundling hides behind it)   | —                     |
| Writing-rules watchlist           | AC-001 | flagged — bundling connectives joining separable behaviors | advisory (convention) |
| C001–C003, C005, C006, C008, C009 | —      | pass                                                       | —                     |

C007 does not apply: the spec is `status: draft`.

The shared write area has no core check code in plain form: it surfaces only as the
Affected-areas note and the open question, for a reviewer to catch (checklist).

## spec.sol.md (`format: sol`)

| Check                          | Where  | Expected result                                       | Severity   |
| ------------------------------ | ------ | ----------------------------------------------------- | ---------- |
| SOL-P004                       | AC-001 | **fires** — several separable behaviors in one clause | hard error |
| Every other SOL code (in-file) | —      | pass                                                  | —          |

Same defect, two surfaces: the bundling is advisory in plain form and SOL-P004 (hard error)
in SOL form — choosing `format: sol` is choosing the stricter bar. The fix is the same in
both: split AC-001 into one requirement per behavior, each with its own verification.

## At task-splitting

AC-002 and AC-003 share the write area `db/orders` — explicit `WRITES` clauses in SOL form,
prose in plain form. Splitting them into two **parallel** tasks fires SOL-O001 (hard error):
two parallel tasks writing the same files. The shipped `task.md` is the safe resolution —
one task owns both requirements, so SOL-O001 does not fire on this fixture as shipped.

## Equivalence assertion

`spec.md` and `spec.sol.md` encode identical requirement records:

| id     | strength | statement                                                                                                                                   | verification                                                               |
| ------ | -------- | ------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------- |
| AC-001 | must     | When the shopper submits the cart, the checkout service validates the cart and charges the card and emails the receipt (the seeded bundle). | `checkout.spec.ts#submit` — plain: unresolved note · SOL: resolved binding |
| AC-002 | must     | When the charge succeeds, the checkout service writes the order record.                                                                     | `order-record.spec.ts#writes-order`                                        |
| AC-003 | must     | When the charge succeeds, the checkout service appends the inventory ledger entry.                                                          | `inventory.spec.ts#writes-ledger`                                          |

Spec-level record: same intent, non-goals, one non-blocking open question, affected areas,
and sources in both files (SOL records the question as a `QUESTION` block; plain form as a
bullet — same record). The SOL `WRITES` clauses are metadata refinement; plain form carries
the same surfaces under Affected areas. A checker that reads different records out of the
two files is wrong (the anti-fork rule).

## task.md and review.md

| Check              | Where                      | Expected result                                                          |
| ------------------ | -------------------------- | ------------------------------------------------------------------------ |
| `non-empty-paste`  | review rows AC-001, AC-002 | pass — output pasted or linked                                           |
| `non-empty-paste`  | review row AC-003          | the Evidence cell is empty, so the row reads **Unverified** — never Pass |
| `no-open-critical` | task and review            | pass — the open question is non-blocking                                 |
| `trigger-coverage` | review Human attention     | pass — names the unverified row and the DB write surface                 |

## finding.md

Valid: one claim, evidence, applies/does-not-apply bounds, and future guidance. This finding
(`FINDING-shared-write-area`) is also a named source of the change plan in
`../transformation/change-plan.md`.

_Task-side note: `non-empty-paste` does **not** fire on the task fixture — its Verify boxes are
unchecked and it claims no completion; the rule binds completion claims, not open work._
