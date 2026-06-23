# Local checks and the extension boundary

_Works today — plain markdown plus your agent; no Corpus tooling required._

Corpus ships only **generic** checks — the ones every spec, task, and review packet should pass
regardless of what the code does ([checks.md](checks.md)). Teams add their own local checks
almost immediately: a script that asserts the migration ran, that the snapshot matches, that the
declared scope was touched. This page says **where those local checks belong** and **how to name
them so they don't claim more than they prove**.

## The extension boundary

Four layers own different checks. Keeping them separate is what lets Corpus core stay portable
while a team's checks grow as specific as they like.

| Layer                                | Owns                                                          | Examples                                                                                                                                           |
| ------------------------------------ | ------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Corpus core CLI** (`corpus check`) | Generic artifact checks — independent of any project's domain | spec shape, task scope, review coverage, empty evidence, workspace validity, stale declared evidence (the `C` catalogue in [checks.md](checks.md)) |
| **Workspace / starter kit**          | Project command slots and local policy                        | the `Commands` table a task's `Verify with:` resolves against; which checks a team treats as blocking; the high-oversight band                     |
| **Code repo**                        | Its real build/test/lint/typecheck commands                   | the gate a task's evidence is produced by — `pnpm test:run`, `cargo build`, whatever the repo actually runs                                        |
| **Optional local scripts**           | Project-specific predicates                                   | a script that emits Corpus-shaped evidence (a review row, a Pass/Fail/Unverified result) for something only this project cares about               |

The rule in one line: **Corpus core stays generic; product-specific predicates live in the layers
a team owns.** A local script that emits Corpus-shaped evidence is welcome and idiomatic — what is
forbidden is implying its predicate is part of Corpus core, or that Corpus enforces it. Corpus
deliberately ships no domain-specific check; a team binds its own tool through a `Verify with:`
command or a `CONSTRAINT` with the `static` verify method (see _Not in the set_ in the
[CLI reference](future-cli.md)).

## Writing local checks without overclaiming

A local check is honest about its **predicate** — the exact proposition it actually establishes —
and routes everything outside that predicate to a human, never to a silent Pass.

**What a script can establish:** that declared artifacts exist, that declared gates ran, that
declared snapshots match, that the declared scope was touched, that parseable structure is
well-formed.

**What a script cannot establish:** "no regressions" in the absolute. A check proves _no
regression across the declared evidence surface_ — the tests that exist, the scope that was
declared — and nothing about behavior outside that surface. Anything outside the declared
evidence path is **Unverified**, a **human-attention** row, or a **follow-up** — never silently
treated as covered ([reviewing output](../08-reviewing-output.md);
[source authority](source-authority.md) on why code outside the path never silently amends
intent).

**So name the check after its predicate, not after the reassurance you wish it gave:**

| Overclaiming name      | Honest name                  | Why                                                                         |
| ---------------------- | ---------------------------- | --------------------------------------------------------------------------- |
| `no-regressions-check` | `baseline-regression-check`  | It proves a named baseline held, not the universal absence of regressions.  |
| `complete-review`      | `coverage-of-declared-scope` | It proves the declared scope was covered, not that the review was complete. |
| `correctness-check`    | `artifact-shape-check`       | It proves structure and shape parse, not that the behavior is correct.      |

**And label its honesty level** ([the honesty legend](checks.md#the-honesty-legend),
[ADR-0063](../adrs/0063-honesty-framework-and-tooling-boundary.md)). A local script is **toolable** at best; it
becomes **enforced** only when your gate actually rejects a merge on its failure — that is your
team's gate, not Corpus's. Until something blocks, it is a checklist or toolable aid, and it says
so. A script that cannot run its check returns **Unverified** or **Blocked**, never a guessed
Pass.

## Related

- [Checks](checks.md) — the generic core catalogue and the honesty legend this page extends.
- [Capability matrix](future-cli.md) — what `corpus check` ships, and the non-goals a team brings its own tool for.
- [Source authority](source-authority.md) — why evidence outside the declared path is Unverified, not covered.
- [Reviewing output](../08-reviewing-output.md) — where local-check results land as review rows.
