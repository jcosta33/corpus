# Example: a bug fix

*Works today — plain markdown plus your agent; no Swarm tooling required.*

The bug shape of the loop: **Pull → Spec check → Task → Run → Review → Close**. A bug is a
disagreement between the code and the spec — or, as here, a place where the spec was
silent. Every artifact appears in its frozen template shape
([`templates/`](https://github.com/jcosta33/swarm-starter-kit/tree/main/templates/)).

## Step 1 — Pull the bug ticket

Same first move as any externally-sourced work: snapshot the ticket verbatim into
`intake/`. The incident log excerpt is the most valuable part — it rides along unedited.

**`intake/PAY-88.md`**

```markdown
---
type: intake
source: PAY-88
url: https://linear.app/acme/issue/PAY-88
captured: 2026-06-10
---

# Intake: Customer charged twice during processor outage

PAY-88 — Customer charged twice during processor outage
Reported by: on-call (incident #2031) · Priority: Urgent

During yesterday's processor outage (14:02–14:19 UTC) order #58213 was
captured twice: $79.90 ×2 for one checkout. The processor returned a 5xx on
the first attempt; our retry captured again.

Log excerpt:

    14:03:11 charge attempt order=58213 key=chg_8841 -> 502
    14:03:14 charge retry   order=58213 key=chg_9907 -> 201 captured
    14:07:40 processor webhook: chg_8841 captured (delayed)

Note the two keys. The retry minted a NEW idempotency key, so the processor
saw two independent charges. Refund issued; we need this to be impossible.
```

## Step 2 — Spec check: what did the spec actually require?

A bug fix starts at the spec, not the code. The payments service already has one — here it
is, as it stood when the incident happened.

**`specs/payment-retry/spec.md`** — before the amendment:

```markdown
---
type: spec
id: SPEC-PAYMENT-RETRY
title: Bounded retry on processor 5xx
status: ready
owner: payments
sources:
  - intake/JIRA-097.md
---

# Bounded retry on processor 5xx

## Intent

A transient processor outage is absorbed by bounded retries; an exhausted
retry budget surfaces a structured error instead of hanging the request.

## Non-goals

- No changes to the checkout UI; this spec covers the payments service only.

## Requirements

### AC-001 — Bounded retry

When the processor returns a 5xx, the payments service must retry the
charge at most 3 times.

Verify with: `npx vitest run server/tests/payment-5xx.spec.ts`

### AC-002 — Exhausted budget surfaces a 502

When the retry budget for a charge is exhausted, the payments service must
return HTTP 502 with a structured `processor-unavailable` error body.

Verify with: `npx vitest run server/tests/payment-fail.spec.ts`

## Open questions

- None.

## Affected areas

- `server/src/payments/charge.ts`
```

The check comes back uncomfortable: the code violates neither requirement — the bug lives
in what the spec never said. Nothing requires a retry to reuse the original idempotency
key, so the spec is amended in place with one new requirement (existing IDs keep their
numbers; on the workboard, the spec's row moves back from `done` until the fix lands):

```markdown
### AC-003 — One idempotency key per charge

When a charge is retried after a processor 5xx, the payments service must
reuse the idempotency key persisted before the first capture attempt — a
retry never mints a new key.

Verify with: `npx vitest run server/tests/payment-retry-idempotency.spec.ts`
```

This codebase was familiar ground. In an unfamiliar brownfield area, the loop would start
with an inventory of what's actually there before the spec check — see
[Brownfield and change plans](../05-brownfield-and-change-plans.md).

## Step 3 — Task

The task implements the new requirement and explicitly preserves the two old ones — a bug
fix that breaks the bounded retry is not a fix.

**`tasks/payment-retry-key.md`**

```markdown
---
type: task
id: TASK-PAYMENT-RETRY-KEY
source:
  - SPEC-PAYMENT-RETRY
scope: [AC-003, AC-001, AC-002]
status: ready
---

# Task: Persist one idempotency key across 5xx retries

## Source

- Spec: `specs/payment-retry/spec.md` (SPEC-PAYMENT-RETRY)

## Scope

Implement or preserve:

- AC-003 — implement: retries reuse the key persisted before the first
  capture attempt; write the regression test first and show it red
- AC-001 — preserve: retry stays bounded at 3
- AC-002 — preserve: exhausted budget still returns the structured 502

## Do not change

- The processor client wrapper (`server/src/processor/`)
- Refund and webhook handling

## Affected areas

- `server/src/payments/charge.ts`

## Verify

- [ ] `npx vitest run server/tests/payment-retry-idempotency.spec.ts` (AC-003)
- [ ] `npx vitest run server/tests/payment-5xx.spec.ts` (AC-001)
- [ ] `npx vitest run server/tests/payment-fail.spec.ts` (AC-002)

## Agent instructions

1. Read the source spec (and change plan, if any) first.
2. Stay inside this task's scope. If a requirement can't be met as written,
   stop and say why instead of improvising.
3. Run every Verify item and paste the real output — a claim without output
   counts as unverified.
4. Before finishing, re-read your own diff as a skeptic: what would a
   reviewer flag?
5. Fill `## Run summary` below — changed files, one line per Verify command
   citing its pasted output above, out-of-scope edits, blocked questions —
   and drop anything durable in `## Findings`.

## Findings

<!-- Anything durable discovered during the task — moved to findings/ at Close. -->
```

## Step 4 — Run: red, then green

The agent fills the packet's `## Run summary` section (and `## Findings`). The red run is
load-bearing: it proves the new test can fail — that it actually reproduces PAY-88 — before
the fix makes it pass.

```markdown
## Findings

- Idempotency keys were minted per capture *attempt*, not per charge — the
  durable lesson behind PAY-88; candidate for Close
  (FINDING-5XX-RETRY-IDEMPOTENCY).

## Run summary — TASK-PAYMENT-RETRY-KEY

Changed files:

- server/src/payments/charge.ts — persist the idempotency key before the
  first capture attempt; retries read the persisted key, never mint one
- server/tests/payment-retry-idempotency.spec.ts — new regression test

Regression test first, against the unfixed code (red):

    $ npx vitest run server/tests/payment-retry-idempotency.spec.ts

     ❯ server/tests/payment-retry-idempotency.spec.ts (1 test | 1 failed)
       × reuses the persisted idempotency key across 5xx retries
         → expected 1 distinct key for order 58213, got 2 (chg_8841, chg_9907)

     Test Files  1 failed (1)
          Tests  1 failed (1)

After the fix, full payments suite (green):

    $ npx vitest run server/tests/

     ✓ server/tests/payment-retry-idempotency.spec.ts (1 test) 502ms
     ✓ server/tests/payment-5xx.spec.ts (3 tests) 689ms
     ✓ server/tests/payment-fail.spec.ts (2 tests) 297ms

     Test Files  3 passed (3)
          Tests  6 passed (6)

Worth saving: the double-capture needed no concurrency — the first attempt's
capture succeeded processor-side after the 502 had already been returned to
us. Any retry that mints a new key risks a double-capture all by itself.
```

## Step 5 — Review

Every row is green, and the packet still routes exceptions: payments code is a risky file,
a trigger class no green row cancels ([Reviewing agent output](../08-reviewing-output.md)
has the full list). The reviewer spot-checked one green row by re-running the regression
test before accepting the table.

**`reviews/payment-retry-key.md`**

```markdown
---
type: review
id: REVIEW-PAYMENT-RETRY-KEY
task: TASK-PAYMENT-RETRY-KEY
pr: https://github.com/acme/payments/pull/233
reviewer: priya@acme (human; the agent implemented)
status: pass
---

# Review: Persist one idempotency key across 5xx retries

## Summary

The regression test reproduces PAY-88 red against the old code and passes
after the fix; the bounded-retry and 502 behaviors are preserved with suite
output. The money-moving capture path was touched, so it gets a human look
regardless of the green column.

## Changed files

- `server/src/payments/charge.ts`
- `server/tests/payment-retry-idempotency.spec.ts`

## Requirement coverage

| ID     | Result | Evidence                                                      | Human attention |
| ------ | ------ | ------------------------------------------------------------- | --------------- |
| AC-003 | Pass   | regression test red-then-green, output pasted in PR #233      | no              |
| AC-001 | Pass   | `payment-5xx.spec.ts` — 3 tests passed in the same suite run  | no              |
| AC-002 | Pass   | `payment-fail.spec.ts` — 2 tests passed in the same suite run | no              |

Spot-checked: AC-003 — re-ran `npx vitest run server/tests/payment-retry-idempotency.spec.ts` myself before accepting.

## Human attention

1. `server/src/payments/charge.ts` is a money-moving path — a risky file by
   any definition. Read the key-persistence diff even though every row is
   green; confirm the key is persisted before the first capture attempt,
   not after it.
2. Finding candidate: a 5xx retry without a persisted idempotency key risks
   double-capture — worth saving for every future payment-path task.

## Suggested decision

Merge.
```

## Step 6 — Close

The incident's lesson is bigger than this fix, so it is saved as a finding with its evidence
attached ([Saving findings](../09-saving-findings.md)).

**`findings/payment-5xx-idempotency.md`**

```markdown
---
type: finding
id: FINDING-5XX-RETRY-IDEMPOTENCY
status: candidate
from: REVIEW-PAYMENT-RETRY-KEY
date: 2026-06-11
related: [SPEC-PAYMENT-RETRY#AC-003]
---

# Finding: 5xx retry without a persisted idempotency key risks double-capture

## What we learned

A charge retried after a processor 5xx can double-capture unless every
attempt reuses one idempotency key persisted before the first capture
attempt: the first attempt may have captured processor-side after the 5xx
was returned, and a retry under a fresh key is an independent charge.

## Evidence

`reviews/payment-retry-key.md` — regression test red against the old code,
green after the fix (PR #233); incident log in `intake/PAY-88.md`.

## Where it applies

- Any retry of a side-effecting external call (charges, transfers, order
  placement) where the provider deduplicates by idempotency key.

## Where it does not apply

- Read-only or naturally idempotent calls, where a retry cannot duplicate
  an effect.

## Future guidance

Before adding a retry around any money-moving call, check that the
idempotency key is persisted before the first attempt and reused by every
retry — and write the many-attempts-one-key test before the fix.
```

**`status.md`** (the rows this fix touched — the closed task links its review packet):

```markdown
| Item                          | Type    | State     | Link                                  |
| ----------------------------- | ------- | --------- | ------------------------------------- |
| SPEC-PAYMENT-RETRY            | spec    | done      | `specs/payment-retry/spec.md`         |
| TASK-PAYMENT-RETRY-KEY        | task    | closed    | `reviews/payment-retry-key.md`        |
| FINDING-5XX-RETRY-IDEMPOTENCY | finding | candidate | `findings/payment-5xx-idempotency.md` |
```

That's the bug shape end to end: ticket preserved, spec checked and amended with one
requirement, red-then-green evidence, an all-green packet that still routed the risky file
to a human, and a finding that outlives everyone's memory of incident #2031.

## Other examples

- [A feature from a Jira ticket](feature-from-jira.md) — the six-step happy path with every
  artifact shown in full.
- [A large PR review](large-pr-review.md) — the main demo: a change-plan-driven refactor
  and the packet that makes a 41-file agent PR reviewable.
