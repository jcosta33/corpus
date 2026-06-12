# Checks fixtures

*Advanced design note — internal rationale; not needed to use Swarm.*

Test data for [the checks reference](../docs/reference/checks.md), consumed by swarm-cli.
Every check in that reference is a claim about what a correct checker reports on a given
file; this directory pins those reports as fixtures, per the two-way severity split
(hard error / warning). swarm-cli's `swarm spec check` is the reference consumer — its
test suite runs against these files — and a reviewer working by hand can use them the
same way: apply the checks, compare against the pinned expectation.

**Nothing in this directory runs.** It is data, not a runner: Swarm ships the contract
([`checks.yaml`](./checks.yaml)) and the fixtures that test it, never the checker.

## When is a workspace valid?

The whole bar, in one breath: a workspace is valid when **(a)** it has a populated
`AGENTS.md` (aim for ~100 lines — guidance, not a cap), **(b)** the core templates are
present, and **(c)** at least one spec satisfies the core checks of
[the checks reference](../docs/reference/checks.md). Nothing else is required. This is a
convention — nothing in this repository enforces it; `swarm spec check` can verify clause (c).

## The two evidence rules

Checklist level — review is expected to inspect both; `swarm spec check`'s packet mode can
flag the mechanical parts:

- **`non-empty-paste`** — a completion claim binds to pasted output or a CI link, never a
  bare "tests passed" [[EVIBOUND]](../docs/research/sources.md#EVIBOUND). In a review
  packet, an empty Evidence cell means **Unverified**, never **Pass**.
- **`no-open-critical`** — work is not closed with an open blocking question; a task or
  review whose status is terminal carries no unresolved blocking question anywhere in it.

## What is in this directory

| Path | Holds |
|---|---|
| [`checks.yaml`](./checks.yaml) | The checks contract as data: spec-form selector, core check list with severities, task and review packet schemas, the evidence rules, advisory command slots, placeholder namespaces. |
| [`fixtures/conformant-task.md`](./fixtures/conformant-task.md) | A task packet that passes every task check — the positive oracle. |
| [`fixtures/violations.md`](./fixtures/violations.md) | One minimal negative fixture per violation class, each with the check it trips and the expected report. |
| `fixtures/auth-refresh/` · `fixtures/payment-5xx/` · `fixtures/checkout/` | Three end-to-end domains: the spec in both forms (the equivalence pair), a task packet, a review packet, a finding, and an `EXPECTED.md` pinning what a checker must report at each artifact. |
| [`fixtures/prose-corpus/`](./fixtures/prose-corpus/README.md) | The labeled writing-rules corpus: prose spans with ground-truth labels for the advisory watchlist, plus the precision/recall baseline any detector is scored against. |
| `fixtures/intake/` | One valid intake snapshot; the expectation is pinned in the file's trailing note. |
| `fixtures/transformation/` | A valid inventory + change-plan pair; its `EXPECTED.md` pins `C010 preserves-refs-resolve` and `C011 waves-present`. |

## The three domains and the examples they mirror

Each fixture domain covers the same ground as one worked example in `docs/examples/` —
the example teaches the workflow; the fixture pins the checker results over equivalent
artifacts:

| Fixture domain | Worked example |
|---|---|
| `fixtures/auth-refresh/` | [feature-from-jira](../docs/examples/feature-from-jira.md) |
| `fixtures/payment-5xx/` | [bug-fix](../docs/examples/bug-fix.md) |
| `fixtures/checkout/` | [large-pr-review](../docs/examples/large-pr-review.md) |

## The equivalence pairs (the anti-fork proof)

A spec is written in plain structured markdown by default, or in the stricter SOL
notation per file via frontmatter `format: sol` — but both surfaces encode one and the
same requirement record, and every check keys on the record, never the surface
(see [structured requirements](../docs/reference/structured-requirements.md)). Each
domain therefore ships the **same spec in both forms**, and its `EXPECTED.md` pins that
a checker extracts the identical record set — same requirement IDs, same strength words,
same verification references — from either file. If the two forms ever drift into
different check behavior, these pairs are the fixtures that catch it.

## Reference values (reconciliation) — producer note

This section is for maintainers of Swarm and of tools that consume it. The closed sets
below have exact sizes, and those sizes are registered in exactly two places: **here** and
the appendix of [the cheatsheet](../docs/reference/cheatsheet.md). Adopter-facing pages list
values rather than counting them (a numeral-bearing model name — the six-step loop, the
nine-step lifecycle — is a name, not a registry copy). A change to any set updates both
places — and the fixtures that exercise it — in the same commit.

| Closed set | Count | Values |
|---|---|---|
| Block types (SOL form) | 5 | `REQ`, `CONSTRAINT`, `INVARIANT`, `INTERFACE`, `QUESTION` |
| Strength words | 5 | must, must not, should, should not, may (SOL form: the same words uppercase) |
| Review results | 7 (4 core + 3 lifecycle) | core: Pass, Fail, Unverified, Blocked · lifecycle: Waived, Stale, Contradicted |
| Verification methods | 9 | `static`, `test`, `contract`, `property`, `model`, `perf`, `security`, `manual`, `monitor` |
| Loop steps | 6 (+ 2 conditional) | Pull, Spec, Task, Run, Review, Close (+ Inventory, Change Plan for structural work) |
| Lifecycle steps (advanced) | 9 | author, lint, improve, lower, decompose, implement, verify, review, promote |
| Improve operations | 10 | NORMALIZE, ATOMIZE, CONCRETIZE, QUANTIFY, BIND, SCOPE, CLARIFY, DECONFLICT, COMPRESS, PROMOTE |
| Check layers | 5 | S (structure), P (prose), M (cross-references), V (verification), O (splitting work) — code form `SOL-<LAYER>NNN` |

Reconciliation duties this note carries:

- The core check IDs and severities in [`checks.yaml`](./checks.yaml) match
  [the checks reference](../docs/reference/checks.md) row for row.
- The task and review section lists in [`checks.yaml`](./checks.yaml) match
  the kit's `templates/` (the swarm-starter-kit repo) heading for heading.
- Every fixture's pinned expectation agrees with both; a fixture that disagrees means
  the contract, the prose, or the fixture is wrong — find out which before shipping.

## How a checker uses this directory

1. Read the rules from [`checks.yaml`](./checks.yaml) (or implement
   [the checks reference](../docs/reference/checks.md) directly — they must
   agree over the core checks and packet schemas;
   the SOL catalogue is prose-only and lives in the reference).
2. Run over [`fixtures/conformant-task.md`](./fixtures/conformant-task.md): the expected
   report is empty.
3. Run over each snippet in [`fixtures/violations.md`](./fixtures/violations.md): each
   must produce exactly the named check at the named severity.
4. Run over each domain's artifacts and compare against its `EXPECTED.md` — including
   the equivalence pair, where both spec forms must yield the same record set.
5. Score any writing-rules detector against
   [`fixtures/prose-corpus/labeled.yaml`](./fixtures/prose-corpus/labeled.yaml) and check
   it against the baseline in [its README](./fixtures/prose-corpus/README.md).
