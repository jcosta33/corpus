---
type: adr
id: adr-0084
status: accepted
created: 2026-06-16
updated: 2026-06-16
---

# ADR-0084 — Boundary-safe prepare verbs; narrow the board-mutating close to scaffold-only

## Context

The W1 surface map (`corpus-hq` AUDIT-corpus-cli-surface) passed the whole candidate corpus-cli surface
through the reconcile-only boundary (ADR-0077) and found exactly one boundary-eroding idea: a
**`status.md`-mutating close** (a `corpus finish`/`corpus close` that flips a board row to a pass-like
state). It crosses **ADR-0077 Decision 8** — the human owns the review result (Pass / Fail /
Unverified / Blocked); the CLI routes, it never adjudicates — because writing a board row to a
pass-like state _is_ adjudicating that human-owned verdict. ADR-0077 **Decision 1** enumerates a
"gated close" as a _reconcile_ capability; that phrasing is precisely what the open DECIDE #1.2
contests, and it is the clause this ADR narrows.

Two loop verbs remain unbuilt and are boundary-safe (prepare engine, ADR-0077 D1): **`corpus pull`**
(snapshot a ticket into `intake/`) and a **finding scaffold** (offered at Close — scaffold a finding
file from a finished task). They _prepare_ a new file; they read or derive no board state.

## Decision

1. **`corpus pull <ref>` writes exactly one verbatim intake snapshot** (`intake/<slug>.md` with
   `source`/`url`/`captured`), and **never a spec** — normalizing a ticket into requirements is
   judgment work, not transcription. Prepare engine (D1); _level: toolable._
2. **The finding scaffold (`corpus promote`) writes one candidate finding file** (`findings/<slug>.md`
   from the template, pre-filling `from:`), and **never asserts a learning and never writes the
   board**. It is offered at Close; the human fills and accepts it. Prepare engine (D1); _level:
   toolable._ This reverses `future-cli.md`'s "promote folds into close, not its own engine" — the W1
   map re-derived it as its own boundary-safe scaffold verb; recorded here.
3. **The board-mutating close stays PARKED (DECIDE #1.2).** No corpus-cli command writes `status.md`;
   the board is hand-edited. A future `corpus close`/`corpus finish` that mutates the board is a
   reversal of this clause and **needs its own ADR** — it is not shipped by drift. This narrows
   ADR-0077 D1's enumerated "gated close" to scaffold-only. _Level: convention (the hard line), an
   invariant a boundary regression test asserts (no Core use-case writes `status.md`)._
   **Reopen trigger:** write that ADR only on demonstrated **adopter demand for the review-gate
   teeth** — generation-volume / convenience demand does not qualify (refuted; corpus-hq #1.2, and
   the #9/#11 measure-first verdict). This trigger is the durable home for the #1.2 decision; the
   GitHub feedback issue need not stay open as a separate tracker.

No `checks.yaml` rule, no contract-version bump — the prepare verbs touch no check; the drift-guard
is untouched.

## Alternatives considered

| Alternative                                                                          | Why weaker                                                                                                                                                                                               |
| ------------------------------------------------------------------------------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Ship a board-mutating `corpus close`/`finish` now**                                | Crosses ADR-0077 D8 (the CLI would adjudicate the human-owned result by writing a pass-like board row); it is the open DECIDE #1.2, deliberately parked, not shipped by convenience. Rejected.           |
| **Fold `promote` into `close` (not its own verb)** — `future-cli.md`'s prior framing | The board-mutating `close` is parked, so there is no `close` engine to fold into; the W1 map re-derived the finding scaffold as a standalone boundary-safe prepare verb. Rejected in favor of `promote`. |
| **`corpus pull` auto-drafts a spec from the ticket**                                 | Normalizing a ticket into requirements is judgment, not transcription; auto-drafting smuggles authoring into a prepare verb. Rejected — `pull` writes the snapshot only.                                 |
| **Do nothing (leave the loop verbs unbuilt)**                                        | The loop verbs are the validated, boundary-safe widening of the CLI (gh #10); leaving them out is not a boundary win, just an incomplete loop. Rejected.                                                 |

## Consequences

Accepted. `corpus pull` and `corpus promote` ship as prepare verbs that scaffold one new file each and
mutate no board; the board-mutating close is parked behind a future ADR; a **boundary regression
test** (no Core use-case writes `status.md`) makes the no-mutation property an invariant, not a
convention. Refines ADR-0077 (narrows the "gated close" clause wherever it appears — D1's reconcile
list and D5's Supercharge list — to scaffold-only); does not re-open D8 (it reaffirms it).
`future-cli.md`'s `pull`/`close`/`promote` rows converge accordingly (the CONT rider). The
implementation is cut and reviewed from `corpus-hq` (SPEC-corpus-cli-m3-prepare). Negative: two more
commands to maintain. Neutral: a team that wants board mutation must wait for (or propose) the
parked-close ADR.
