<!-- checks fixture — expected results pinned in EXPECTED.md (this file) -->

# transformation — expected check results

Checks fixture for the structural-work pair: an inventory (`INV-checkout-storage`) and the
change plan built on it (`CHANGE-inventory-ledger`). Both files are **valid** — this
directory pins what a well-formed pair looks like, not a defect. The results below are known
by hand and pin what corpus-cli's `corpus check` must report for change plans (toolable).
Until that tool runs, nothing here is enforced — reviewers use the same table as a checklist.

## change-plan.md

| Check                               | What it asks                                                                                                                                                                                                                                                                               | Expected result                              |
| ----------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | -------------------------------------------- |
| `C010 `preserves-refs-resolve``     | Every id in `preserves:` and in the preservation-guarantees table resolves: `SPEC-checkout#AC-002` and `SPEC-checkout#AC-003` resolve against `../checkout/spec.md` (and equally against `../checkout/spec.sol.md` — same records); `PG-001` is defined in the plan's own guarantees table | pass                                         |
| `C011 `waves-present``              | The Transformation waves section is non-empty and every wave names the check that keeps the codebase green                                                                                                                                                                                 | pass — each wave carries a named green check |
| Guarantee rows carry a verification | Every preservation guarantee has a `Verify with` entry — review consumes the same `{id, verify_ref, result}` rows as requirement coverage                                                                                                                                                  | pass                                         |
| `sources:` resolve                  | `INV-checkout-storage` is the sibling `inventory.md`; `FINDING-shared-write-area` is `../checkout/finding.md`                                                                                                                                                                              | pass                                         |

Two deliberate features a checker must not misread:

- **PG-001 is not a broken reference.** A guarantee with no spec id gets a `PG-NNN` id in
  the plan itself; it usually signals a spec amendment is owed (the plan says so), but it is
  a valid row, not a resolution failure.
- **The task split references guarantee ids, not files.** `TASK-ledger-w1`–`w3` are the
  intended split; the tasks themselves don't exist yet, and `C011 `waves-present`` does not require
  them to.

## inventory.md

| Check                                | What it asks                                                                                                                          | Expected result |
| ------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------- | --------------- |
| Observes, never judges or prescribes | Every section reports what exists with evidence (file:line, test names); no fix is prescribed — prescription is the change plan's job | pass            |
| Unknowns recorded                    | The unseen-dependents risk is in Unknowns, not silently dropped                                                                       | pass            |

## How the pair connects

The inventory maps `db/orders` as it is; the change plan cites it in `sources:`, enumerates
what it preserves (never "no behavior change" — the guarantees table lists each preserved
behavior with its check), and stages the move in waves with cutover and rollback conditions.
The shared-write-area defect this plan resolves is seeded and pinned in the checkout fixture
(`../checkout/EXPECTED.md`).
