# Example: a 41-file refactor, reviewed by exception

*Works today — plain markdown plus your agent; no Swarm tooling required.*

This is the full walkthrough of Swarm's main use case: an agent hands you a large PR, and you
review it without reading 41 files. The work is a refactor — duplicated session handling
consolidated into one module — so it uses the structural flow of the loop:

```
Inventory → Change Plan → Task → Run → Review → Close
```

Every artifact below sits in the workspace in the shipped template shapes
([`templates/`](https://github.com/jcosta33/swarm-starter-kit/tree/main/templates/)). The punchline up front: the
reviewer read eighteen table rows and four exception items across two packets, spot-checked
one green row by hand, and opened three files out of 41 — the three the packet pointed at.

## The scenario

`shop-api` is a TypeScript storefront service. Checkout sessions — created at cart submit,
validated before charging, looked up when the payment provider calls back — are implemented
**three separate times**: in `src/checkout/cart-session.ts`, `src/payments/charge-session.ts`,
and `src/webhooks/session-lookup.ts`. Three copies of id generation, TTL logic, and SQL
against the same `sessions` table. The team wants one `src/sessions/` module — without
changing any behavior.

The behavior itself is already specified in `specs/checkout/spec.md` (`SPEC-checkout` — for
how a spec like this gets written from a ticket, see
[feature-from-ticket](feature-from-ticket.md)). The requirements this refactor must preserve,
each with its "Verify with" command:

- **AC-001 — session on cart submit.** Submitting a cart creates a session bound to it and
  returns its id. `npx vitest run checkout/session-create`
- **AC-002 — at-most-once charge.** The same session submitted for payment twice charges the
  card at most once. `npx vitest run payments/idempotency`
- **AC-003 — session TTL.** A session older than 30 minutes is expired.
  `npx vitest run checkout/session-expiry`
- **AC-004 — expired-session response.** Acting on an expired session returns
  409 SESSION_EXPIRED, never a 5xx. `npm run test:integration -- expired-session`
- **AC-006 — webhook session lookup.** A provider webhook resolves to its session and applies
  the payment status. `npx vitest run webhooks/session-lookup`

## Step 1 — Inventory: map what exists

A refactor of code nobody fully remembers starts with a map, not a plan. The inventory
observes — it does not judge and does not prescribe. `inventory/checkout-sessions.md`:

```markdown
---
type: inventory
id: INV-checkout-sessions
title: checkout session handling inventory
status: ready
owner: checkout-team
sources: [code:src/, tests:test/]
created: 2026-06-02
---

# Inventory: checkout session handling

## Scope

Session creation, validation, expiry, and persistence across checkout,
payments, and webhooks. Excludes cart pricing, refunds, the provider SDK.

## Current modules

| Module                           | Responsibility                        | Notes                             |
| -------------------------------- | ------------------------------------- | --------------------------------- |
| `src/checkout/cart-session.ts`   | create/expire sessions at cart submit | own id generation + SQL           |
| `src/payments/charge-session.ts` | re-validate session before charge     | duplicate expiry math, in seconds |
| `src/webhooks/session-lookup.ts` | resolve provider payloads to sessions | third copy of validation + SQL    |

## Current interfaces

| Interface                    | Callers                   | Behavior                              |
| ---------------------------- | ------------------------- | ------------------------------------- |
| `createCartSession(cartId)`  | `src/api/cart-routes.ts`  | returns `{ sessionId, expiresAt }`    |
| `assertSessionValid(id)`     | `src/payments/charge.ts`  | throws `SessionExpiredError` past TTL |
| `lookupSession(providerRef)` | `src/webhooks/handler.ts` | lowercases the incoming ref first     |

## Observed behavior

| Behavior                                       | Evidence                                                                          |
| ---------------------------------------------- | --------------------------------------------------------------------------------- |
| session ids are 32-char lowercase hex          | `cart-session.ts:41`; asserted in `test/checkout/session-create.test.ts`          |
| TTL is 30 min in all three copies              | `cart-session.ts:57` (ms), `charge-session.ts:88` (s), `session-lookup.ts:34` (s) |
| expired session maps to 409 at the route layer | `src/api/errors.ts:23` maps `SessionExpiredError` → 409                           |
| webhook lookup tolerates uppercase ids         | `session-lookup.ts:19`; the provider sends uppercase refs                         |

## Known risks

- Three TTL implementations, two unit conventions — they agree today by luck.
- Uppercase tolerance exists only in the webhook copy; all three modules write
  the same `sessions` table.

## Existing tests

- `test/{checkout/session-create,checkout/session-expiry,payments/idempotency,webhooks/session-lookup}.test.ts`
- `test/integration/expired-session.test.ts` (integration CI job only)

## Unknowns

- The ops dashboard is believed to grep logs for `session=<32 hex>` — unconfirmed.
- The mobile app may pin the `{ sessionId, expiresAt }` response shape.
- Provider webhook retries may depend on the uppercase tolerance.
```

The Unknowns section is the part people skip and regret: with enough users, every observable
behavior — id shapes, log lines, error spellings — has someone depending on it. Listing what
you _can't_ see from the code is what makes the next document honest.

## Step 2 — Change plan: how the codebase changes safely

A spec answers "what behavior should exist"; a refactor needs "how does the code move without
breaking anyone" — the change plan ([when to write
one](../05-brownfield-and-change-plans.md)). `change-plans/checkout-sessions.md`:

```markdown
---
type: change-plan
id: CHANGE-checkout-sessions
title: Consolidate session handling into src/sessions/
status: ready
kind: refactor
owner: checkout-team
sources: [INV-checkout-sessions]
preserves:
  [
    SPEC-checkout#AC-001,
    SPEC-checkout#AC-002,
    SPEC-checkout#AC-003,
    SPEC-checkout#AC-004,
    SPEC-checkout#AC-006,
  ]
created: 2026-06-03
---

# Change Plan: Consolidate session handling into src/sessions/

## Intent

Replace three independent session implementations with one `src/sessions/`
module. No observable behavior changes.

## Why this change is needed

INV-checkout-sessions: three copies of id generation, TTL math (in two
different units), and SQL against one table — agreeing today by coincidence.

## Baseline

- Checkout, payments, and webhooks each own create/validate/expire logic and
  their own queries against `sessions`.

## Target state

- `src/sessions/store.ts` is the only module generating ids, computing expiry,
  and touching the `sessions` table; the three local copies are deleted.
- Unchanged: the 30-min TTL, the `{ sessionId, expiresAt }` shape, the 409
  mapping, uppercase tolerance on webhook refs, the table schema.

## Behavioral preservation guarantees

| ID                   | Behavior                                                                                              | Verify with                                                     |
| -------------------- | ----------------------------------------------------------------------------------------------------- | --------------------------------------------------------------- |
| SPEC-checkout#AC-002 | the same session is never charged twice                                                               | `npx vitest run payments/idempotency`                                 |
| SPEC-checkout#AC-003 | sessions expire at 30 minutes                                                                         | `npx vitest run checkout/session-expiry`                              |
| SPEC-checkout#AC-004 | expired session → 409, never 5xx                                                                      | `npm run test:integration -- expired-session`                   |
| SPEC-checkout#AC-006 | webhooks resolve provider refs, incl. uppercase                                                       | `npx vitest run webhooks/session-lookup`                              |
| PG-001               | session ids keep the 32-char lowercase-hex shape (suspected log-parser dependents — see INV Unknowns) | `npx vitest run sessions/id-shape` (contract test, written in wave 1) |

<!-- PG-001 has no spec id: if the dependency is confirmed, a spec amendment
     is owed. -->

## Non-goals

- No TTL, response-shape, or `sessions` schema change; no refund work.

## Affected surfaces

| Surface                          | Intended change                 |
| -------------------------------- | ------------------------------- |
| `src/sessions/`                  | new — the single implementation |
| `src/checkout/cart-session.ts`   | deleted in wave 1               |
| `src/payments/charge-session.ts` | deleted in wave 2               |
| `src/webhooks/session-lookup.ts` | deleted in wave 3               |

## Risk areas

- Expiry math: the payments copy computes in seconds — an easy silent break.
- Error mapping: `src/api/errors.ts:23` maps the _typed_ `SessionExpiredError`
  to 409; a module that throws anything else turns expiry into a 500.
- Webhook case-insensitivity lives in only one of the three copies.

## Transformation waves

1. Build `src/sessions/` + the id-shape contract test; switch **checkout**.
   Green: unit + integration suites + new contract tests.
2. Switch **payments**; delete its copy. Green: full suites + idempotency run.
3. Switch **webhooks**; delete the last copy. Green: full suites + a staging
   replay of recorded provider webhooks.

## Cutover conditions

- All session logic imported only from `src/sessions/`; the three old files
  gone; every preservation guarantee verified in the last wave's review.

## Rollback criteria

- A preservation guarantee fails in staging after a wave merges, or checkout
  conversion / webhook success drops below baseline. Each wave is one PR —
  rollback is reverting that PR.

## Verification strategy

- [ ] `npx vitest run` and `npm run test:integration` per wave
- [ ] `npx vitest run sessions/id-shape` from wave 1 on; staging replay before cutover

## Review focus

- Expiry, the 409 mapping, the id shape — and any file outside the wave's module list.

## Task split

| Task                      | Wave | Scope (guarantee/requirement ids)    |
| ------------------------- | ---- | ------------------------------------ |
| TASK-checkout-sessions-w1 | 1    | SPEC-checkout#AC-001..AC-004, PG-001 |
| TASK-checkout-sessions-w2 | 2    | SPEC-checkout#AC-002, AC-003         |
| TASK-checkout-sessions-w3 | 3    | SPEC-checkout#AC-006, PG-001         |
```

Note what the preservation table is doing: "no behavior change" became five named, checkable
rows — four reusing the spec's own requirement ids, one (`PG-001`) covering a surface the
spec never wrote down. Those rows come back later as the reviewer's checklist.

## Step 3 — The wave-1 task

`tasks/checkout-sessions-w1.md` bounds the agent: sources, scope, off-limits, verify commands.

```markdown
---
type: task
id: TASK-checkout-sessions-w1
source:
  - SPEC-checkout
  - CHANGE-checkout-sessions
scope:
  [
    SPEC-checkout#AC-001,
    SPEC-checkout#AC-002,
    SPEC-checkout#AC-003,
    SPEC-checkout#AC-004,
    PG-001,
  ]
status: ready
---

# Task: Sessions module + switch checkout (wave 1)

## Source

- Spec: `specs/checkout/spec.md` (SPEC-checkout)
- Change plan: `change-plans/checkout-sessions.md` (CHANGE-checkout-sessions), wave 1

## Scope

Implement or preserve:

- Build `src/sessions/store.ts` per the change plan's target state.
- Write the id-shape contract test (PG-001) before switching callers.
- Switch `src/checkout/` to the new module; delete `cart-session.ts`.
- AC-001..AC-004 must behave exactly as today.

## Do not change

- `src/payments/charge-session.ts`, `src/webhooks/session-lookup.ts` (waves 2–3)
- the `sessions` table schema; any API response shape

## Affected areas

- `src/sessions/` (new), `src/checkout/`, `test/`

## Verify

- [ ] `npx vitest run checkout/session-create` (AC-001)
- [ ] `npx vitest run payments/idempotency` (AC-002)
- [ ] `npx vitest run checkout/session-expiry` (AC-003)
- [ ] `npm run test:integration -- expired-session` (AC-004)
- [ ] `npx vitest run sessions/id-shape` (PG-001)
- [ ] `npx vitest run` (full unit suite)

## Agent instructions

1. Read the source spec and change plan first.
2. Stay inside this task's scope; if a requirement can't be met as written, stop and say why.
3. Run every Verify item and paste the real output — a claim without output is unverified.
4. Before finishing, re-read your own diff as a skeptic: what would a reviewer flag?
5. Fill `## Run summary` below — changed files, per-command results citing the Verify
   pastes, out-of-scope edits, blocked questions — and drop durables in `## Findings`.

## Findings

- The three TTL copies disagreed in *units* (ms vs seconds) — they agreed by
  luck; durable gotcha, candidate for Close.
```

## Step 4 — The run: a 41-file PR

The agent works in its own worktree and opens PR `#482`: **41 files changed, +1,816 −1,204**.
The packet's `## Run summary` section ends:

```text
Created src/sessions/ (store.ts, errors.ts, index.ts) and switched all of
src/checkout/ to it; deleted cart-session.ts and its direct tests. Unit suite
green (CI run #5512). While in payments I also modernized the retry backoff in
src/payments/retry.ts. Webhooks untouched. All requirements satisfied.
```

Nobody reads 41 files line by line — and "all requirements satisfied" is exactly the kind of
sentence the review step exists to interrogate: an unsupported done-claim, the failure
pattern illustrated (small-N, preliminary) by [[EVIBOUND]](../research/sources.md#EVIBOUND).

## Step 5 — The review packet

The packet turns the PR into requirement coverage plus a short exception list. Because this
task executes a change plan, it carries **both** tables: requirement coverage for the spec ids
in scope, change-plan coverage for the plan's remaining guarantees and wave conditions.
(The optional `swarm review --write` drafts the requirement-coverage table for you — every
row Unverified; the change-plan coverage table you or your agent still fills.)
`reviews/checkout-sessions-w1.md`:

```markdown
---
type: review
id: REVIEW-checkout-sessions-w1
task: TASK-checkout-sessions-w1
reviewer: mara@acme (human; a fresh session — the implementing agent never reviews)
pr: https://github.com/acme/shop-api/pull/482
status: blocked
---

# Review: Sessions module + switch checkout (wave 1)

## Summary

New src/sessions/ module; checkout switched to it, old copy deleted. Seven of
nine rows verified with output (six pass; AC-004 fails). AC-004 regressed
(expired sessions now return 500), two guarantees carry no evidence, one edit
is outside the task's scope.

## Changed files

- `src/sessions/` (3 new files), `src/checkout/` (11 files), `test/` (24 files)
- `src/payments/retry.ts` ← not in the task's affected areas
- deleted: `src/checkout/cart-session.ts`, `test/checkout/cart-session-internal.test.ts`

## Requirement coverage

| ID                   | Result | Evidence                                                                                                                                                      | Human attention |
| -------------------- | ------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------- |
| SPEC-checkout#AC-001 | Pass   | `npx vitest run checkout/session-create` → `Tests  4 passed (4)` (pasted in PR)                                                                                | no              |
| SPEC-checkout#AC-002 | Pass   | `npx vitest run payments/idempotency` → `Tests  6 passed (6)` (pasted in PR)                                                                                   | no              |
| SPEC-checkout#AC-003 | Pass   | `npx vitest run checkout/session-expiry` → `Tests  5 passed (5)` (pasted in PR)                                                                                | no              |
| SPEC-checkout#AC-004 | Fail   | `npm run test:integration -- expired-session` → `expected 409, received 500`; `src/sessions/store.ts:74` throws `Error("expired")`, not `SessionExpiredError` | yes             |

Spot-checked: AC-001 — re-ran `npx vitest run checkout/session-create` myself → `Tests  4 passed (4)`.

## Change-plan coverage

| ID                                                           | Result     | Evidence                                                                                                         | Human attention |
| ------------------------------------------------------------ | ---------- | ---------------------------------------------------------------------------------------------------------------- | --------------- |
| Wave 1 — checkout imports sessions only from `src/sessions/` | Pass       | `grep -rn "cart-session" src/ test/` → no matches (pasted)                                                       | no              |
| Wave 1 — `cart-session.ts` deleted                           | Pass       | PR file list: 2 deletions, both checkout-local                                                                   | no              |
| Wave 1 — unit suite green                                    | Pass       | CI run #5512, all jobs green (link)                                                                              | no              |
| SPEC-checkout#AC-006 (preserved)                             | Unverified | run summary says "webhooks untouched", but the new module writes the rows webhooks read; the suite was never run | yes             |
| PG-001 — id shape                                            | Unverified |                                                                                                                  | yes             |

## Human attention

1. **AC-004 regressed.** Expired sessions surface as 500, not 409 — the exact
   error-mapping risk the change plan flagged. Failing output above.
2. **Two rows have no evidence.** The id-shape contract test (PG-001) was never
   written; the webhook suite never run — an empty Evidence cell is Unverified,
   never Pass. Both commands are already in the task's Verify list.
3. **Out-of-scope edit.** `src/payments/retry.ts` is wave-2 territory, not
   session work. Revert here; re-propose for wave 2 if it matters.

## Suggested decision

Block until: AC-004 returns 409 with output pasted; `sessions/id-shape` exists
and passes; `webhooks/session-lookup` output is pasted; `retry.ts` is reverted.
```

Two rules carried this packet, both checklist-level (the reviewer inspects them; nothing in
this repo enforces them): **a Pass needs pasted output, a CI link, or — for a manual Verify
method — a named human's recorded observation**, and **an empty Evidence cell means
Unverified, never Pass**. Note that CI was green and AC-004 still failed —
the integration job doesn't run on draft PRs, and the deleted module took an expired-session
test down with it. "CI green" and "requirements verified" are different claims.

## Step 6 — The follow-up task

The block list converts directly into a small task, `tasks/checkout-sessions-w1-fix.md` —
same template shape as wave 1, so only the substance is shown here:

```markdown
---
type: task
id: TASK-checkout-sessions-w1-fix
source:
  - SPEC-checkout
  - CHANGE-checkout-sessions
scope: [SPEC-checkout#AC-004, SPEC-checkout#AC-006, PG-001]
status: ready
---

# Task: Close the wave-1 review blocks (PR #482)

## Scope

Implement or preserve:

- AC-004 — throw `SessionExpiredError` from `src/sessions/store.ts`; expired
  sessions return 409 again.
- PG-001 — write `test/sessions/id-shape.test.ts` (32-char lowercase hex).
- AC-006 — run the webhook suite against the new write path.
- Revert `src/payments/retry.ts` to main. Do not change anything else in #482.

## Verify

- [ ] `npm run test:integration -- expired-session` (AC-004)
- [ ] `npx vitest run sessions/id-shape` (PG-001)
- [ ] `npx vitest run webhooks/session-lookup` (AC-006)
- [ ] `git diff main -- src/payments/retry.ts` → empty
```

## Step 7 — The second packet: short and green

The agent pushes three commits to the same PR. The second packet re-judges every row —
results don't carry over, evidence does. `reviews/checkout-sessions-w1-fix.md`:

```markdown
---
type: review
id: REVIEW-checkout-sessions-w1-fix
task: TASK-checkout-sessions-w1-fix
reviewer: mara@acme (human; a fresh session — the implementing agent never reviews)
pr: https://github.com/acme/shop-api/pull/482
status: pass
---

# Review: Wave-1 blocks closed (PR #482, commits 4–6)

## Summary

All four block items resolved with pasted output; every wave-1 row passes.
Reviewer spot-checked AC-002 locally.

## Changed files

- `src/sessions/store.ts`, `test/sessions/id-shape.test.ts` (new),
  `src/payments/retry.ts` (reverted)

## Requirement coverage

| ID                   | Result | Evidence                                                                   | Human attention |
| -------------------- | ------ | -------------------------------------------------------------------------- | --------------- |
| SPEC-checkout#AC-001 | Pass   | re-run in CI #5547 (link)                                                  | no              |
| SPEC-checkout#AC-002 | Pass   | CI #5547 — and re-run locally by the reviewer: `Tests  6 passed (6)`  | no              |
| SPEC-checkout#AC-003 | Pass   | CI #5547 (link)                                                            | no              |
| SPEC-checkout#AC-004 | Pass   | `npm run test:integration -- expired-session` → `Tests  3 passed (3)` (pasted) | no              |

Spot-checked: AC-002 — re-ran `npx vitest run payments/idempotency` locally → `Tests  6 passed (6)`.

## Change-plan coverage

| ID                                            | Result | Evidence                                                        | Human attention |
| --------------------------------------------- | ------ | --------------------------------------------------------------- | --------------- |
| Wave 1 — single import path, old copy deleted | Pass   | grep re-run, no matches (pasted)                                | no              |
| Wave 1 — suites green                         | Pass   | CI #5547, unit + integration jobs (link)                        | no              |
| SPEC-checkout#AC-006 (preserved)              | Pass   | `npx vitest run webhooks/session-lookup` → `Tests  7 passed (7)` (pasted) | no              |
| PG-001 — id shape                             | Pass   | `npx vitest run sessions/id-shape` → `Tests  2 passed (2)` (pasted)       | no              |
| Out-of-scope edit reverted                    | Pass   | `git diff main -- src/payments/retry.ts` → empty (pasted)       | no              |

## Human attention

1. Finding candidate: writing the PG-001 test confirmed the ops dashboard
   parses session ids from logs (`ops/dashboards/checkout.json:18`) — the id
   shape is a de-facto public interface. Save as a finding; spec amendment owed.

## Suggested decision

Merge. Wave 2 (TASK-checkout-sessions-w2) is unblocked.
```

The spot-check on AC-002 is deliberate. A tidy green table invites rubber-stamping, and the
bias is measured: evaluators measurably favor their own generations
[[SELFPREFER]](../research/sources.md#SELFPREFER) and carry predictable judgment biases
[[JUDGEBIAS]](../research/sources.md#JUDGEBIAS). Re-running one green row by hand is the
convention that keeps the column meaning something — nothing enforces it.

## Step 8 — Close: merge, save the finding, update the board

PR #482 merges. The finding candidate becomes `findings/session-id-shape-is-public.md`:

```markdown
---
type: finding
id: FINDING-session-id-shape-is-public
status: accepted
from: REVIEW-checkout-sessions-w1-fix
date: 2026-06-09
related: [SPEC-checkout#AC-001, PG-001]
---

# Finding: Session id shape is a de-facto public interface

## What we learned

The ops dashboard extracts `session=([0-9a-f]{32})` from service logs
(`ops/dashboards/checkout.json:18`). Changing the id format breaks monitoring
even though no API contract mentions it.

## Evidence

PR #482; `reviews/checkout-sessions-w1-fix.md` (PG-001 row, pasted output);
the dashboard config line above.

## Where it applies

- `src/sessions/store.ts` id generation; log-format changes in session paths.

## Where it does not apply

- Internal variable naming; ids never written to logs.

## Future guidance

Treat id and log formats as API. SPEC-checkout was amended in place with
AC-009 codifying the shape — the guarantee now has a spec id, and PG-001
retires after wave 3.
```

`PG-001` started as a guarantee with no spec id — usually a sign a spec amendment is owed,
and here it was: the spec gains `AC-009`, and future tasks scope it directly. Finally,
`status.md`:

```markdown
| Item                      | Type        | State                                          | Link                                |
| ------------------------- | ----------- | ---------------------------------------------- | ----------------------------------- |
| SPEC-checkout             | spec        | ready (amended: +AC-009)                       | `specs/checkout/spec.md`            |
| CHANGE-checkout-sessions  | change-plan | in-progress — wave 1 merged                    | `change-plans/checkout-sessions.md` |
| TASK-checkout-sessions-w1 | task        | closed | `reviews/checkout-sessions-w1-fix.md` |
| TASK-checkout-sessions-w2 | task        | ready                                          | `tasks/checkout-sessions-w2.md`     |
```

Waves 2 and 3 repeat steps 3–8 against the same change plan — each one PR, each leaving the
codebase green.

One boundary worth naming: this PR's implementer worked from the maintainer's own packet and
pasted output on demand. A drive-by PR with no packet and a silent author runs the same
review post-hoc — intake the code-shaped work, write the spec as an acceptance bar, produce
all evidence yourself: the arrives-as-code flow in
[Reviewing agent output](../08-reviewing-output.md).

## What the reviewer actually read

For a 41-file, ±3,000-line PR, the human review consumed: **nine coverage rows** plus **three
exception items** in the first packet, nine more rows and one exception item (the finding
candidate) in the second — eighteen rows and four exception items end to end; **three files opened**, all on the packet's pointers (the `throw` site, the
409 mapping, the out-of-scope `retry.ts` diff); and **one green row re-run by hand**. The
other 38 files were never read line by line — they were _accounted for_: every behavior that
mattered had a named row, every row had evidence or was called Unverified to its face, and
everything else was routed to the exception list. That, not reading faster, is how review
keeps up with agents — and the structure caught what a diff scroll usually misses: a
regression hiding behind a green CI badge, two confident claims with no output behind them,
and a drive-by edit two waves early.

## Related

- [Reviewing agent output](../08-reviewing-output.md) — the evidence rules and exception
  triggers this packet applies
- [Brownfield and change plans](../05-brownfield-and-change-plans.md) — when an inventory and
  a change plan are worth writing, and when they are not
- [feature-from-ticket](feature-from-ticket.md) — the six-step happy path, including authoring a
  spec like SPEC-checkout · [bug-fix](bug-fix.md) — the shortest loop, same review discipline
- Templates used here: [inventory](https://github.com/jcosta33/swarm-starter-kit/blob/main/templates/inventory.md) ·
  [change-plan](https://github.com/jcosta33/swarm-starter-kit/blob/main/templates/change-plan.md) ·
  [task](https://github.com/jcosta33/swarm-starter-kit/blob/main/templates/task.md) · [review](https://github.com/jcosta33/swarm-starter-kit/blob/main/templates/review.md) ·
  [finding](https://github.com/jcosta33/swarm-starter-kit/blob/main/templates/finding.md) · [status](https://github.com/jcosta33/swarm-starter-kit/blob/main/templates/status.md)
