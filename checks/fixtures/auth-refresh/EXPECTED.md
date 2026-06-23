<!-- checks fixture — expected results pinned in EXPECTED.md (this file) -->

# auth-refresh — expected check results

Checks fixture for [the check catalogue](../../../docs/reference/checks.md): silent token
refresh on 401, with two seeded spec defects. The results below are known by hand and pin
what corpus-cli's `corpus check` must report (toolable). Until that tool runs, nothing
here is enforced — reviewers use the same tables as a checklist.

**Check scope.** Each file is checked standalone. `spec.md` and `spec.sol.md` intentionally
share one `id:` — they are one spec written on both surfaces (this directory's equivalence
pair), not two specs. A real workspace keeps only one, so the pair itself never counts as a
C002 duplicate.

## Seeded defects

| Where               | Defect                                                          |
| ------------------- | --------------------------------------------------------------- |
| AC-002 (both files) | No verification line                                            |
| AC-003 (both files) | "handle … gracefully" — watchlist words, no same-line criterion |

## spec.md (plain form)

| Check                             | Where  | Expected result                                                                            | Severity              |
| --------------------------------- | ------ | ------------------------------------------------------------------------------------------ | --------------------- |
| C003 `verify-with`                | AC-002 | **fires** — no `Verify with:` line                                                         | hard error            |
| Writing-rules watchlist           | AC-003 | flagged — vague verb plus non-verifiable quality; nothing on the line says how to check it | advisory (convention) |
| C001, C002, C004–C006, C008, C009 | —      | pass                                                                                       | —                     |

C007 does not apply: the spec is `status: draft`.

## spec.sol.md (`format: sol`)

| Check                | Where  | Expected result                                                   | Severity   |
| -------------------- | ------ | ----------------------------------------------------------------- | ---------- |
| SOL-V001             | AC-002 | **fires** — no `VERIFY BY`                                        | hard error |
| SOL-P005             | AC-003 | **fires** — watchlist word with no same-line observable criterion | hard error |
| Every other SOL code | —      | pass                                                              | —          |

The same two defects on two surfaces: C003 and SOL-V001 are one rule asked of two forms.
Note the asymmetry on AC-003 — the watchlist hit is advisory in plain form, while SOL-P005
is a hard error: choosing `format: sol` is choosing the stricter bar.

## Equivalence assertion

`spec.md` and `spec.sol.md` encode identical requirement records:

| id     | strength | statement                                                                                                                              | verification                                                                                  |
| ------ | -------- | -------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------- |
| AC-001 | must     | When a request returns 401 and a refresh token is present, the auth client replays the original request once with a refreshed session. | `auth-refresh.spec.ts#replays-after-refresh` — plain: unresolved note · SOL: resolved binding |
| AC-002 | must     | When the refresh token is itself expired, the auth client redirects to `/login`.                                                       | none in either form (the seeded defect)                                                       |
| AC-003 | must     | When the refresh request times out, the auth client handles the failure gracefully.                                                    | `auth-refresh.spec.ts#timeout`                                                                |

Spec-level record: same intent, non-goals, open questions (none), affected areas, and
sources in both files. The SOL `WRITES` clauses are metadata refinement — plain form carries
the same paths under Affected areas. A checker that reads different records out of the two
files is wrong (the anti-fork rule).

## task.md and review.md

| Check              | Where                      | Expected result                                                          |
| ------------------ | -------------------------- | ------------------------------------------------------------------------ |
| `non-empty-paste`  | review rows AC-001, AC-003 | pass — output pasted or linked                                           |
| `non-empty-paste`  | review row AC-002          | the Evidence cell is empty, so the row reads **Unverified** — never Pass |
| `no-open-critical` | task and review            | pass — no open blocking question                                         |
| `trigger-coverage` | review Human attention     | pass — names the unverified row and the risky file                       |

These are checklist-level rules; `corpus check`'s packet mode can flag the mechanical
parts (the empty Evidence cell).

## finding.md

Valid: one claim, evidence, applies/does-not-apply bounds, and future guidance, with `from:`
and `related:` resolving to this fixture's review and spec ids.

_Task-side note: `non-empty-paste` does **not** fire on the task fixture — its Verify boxes are
unchecked and it claims no completion; the rule binds completion claims, not open work._
