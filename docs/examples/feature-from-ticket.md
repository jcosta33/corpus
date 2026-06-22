# Example: a feature from a ticket

*Works today — plain markdown plus your agent; no Swarm tooling required.*

One small feature — silent token refresh on 401 — carried through the whole loop:
**Pull → Spec → Task → Run → Review → Close**. Every artifact appears in full, in the exact
shape its kit template freezes ([`templates/`](https://github.com/jcosta33/swarm-starter-kit/tree/main/templates/)).
This page is [the basic workflow](../02-basic-workflow.md) with real content in every slot.

## Step 1 — Pull: capture the ticket

Work starts in a tracker, so the first move is a snapshot: paste the ticket verbatim into
`intake/` — the spec interprets; the intake preserves what was actually asked, so anyone
can later check the interpretation against the original. (The optional `swarm pull` captures
this snapshot for you; by hand you copy-paste.)

**`intake/WEB-123.md`**

```markdown
---
type: intake
source: WEB-123
url: https://tracker.example.com/WEB-123
captured: 2026-06-08
---

# Intake: Users get logged out mid-session

WEB-123 — Users get logged out mid-session
Reporter: Dana M. (Support) · Priority: High · Labels: auth, web

Support has 14 tickets this month from users who lose long forms when their
session dies. Access tokens expire after 15 minutes; the app bounces the user
to the login screen and the form state is gone.

What we want: when the access token expires, the app should refresh it
silently and carry on — the user should never notice. While we're at it, can
we also add a "remember me for 30 days" checkbox on the login page?

Comments:

- Priya (PM), Jun 2: If the refresh token itself is dead, send them to
  /login — don't try anything clever, and definitely don't loop.
- Tomas (Eng), Jun 3: Watch out for a request retrying forever on a bad
  token. Whatever we do must retry at most once per request.
```

Nothing is edited — even the "while we're at it" line stays. It matters in the next step.

## Step 2 — Spec: interpret the ticket

The spec turns the ticket into requirements an agent can build against, each with a
`Verify with:` line — a runnable check is the most useful single line you can hand an
agent [[ORACLESWE]](../research/sources.md#ORACLESWE). The "remember me" ask is deliberately
left out, and the drop is recorded where the ticket's author can find it.

**`specs/auth-refresh/spec.md`**

```markdown
---
type: spec
id: SPEC-AUTH-REFRESH
title: Silent token refresh on 401
status: ready
owner: web-platform
sources:
  - intake/WEB-123.md
---

# Silent token refresh on 401

## Intent

When an access token expires mid-session, the web client refreshes it
silently and replays the original request — a user with a live refresh token
never lands on the login screen. Raised by support volume in WEB-123.

## Non-goals

- Token lifetimes stay as they are (15-minute access tokens).
- No changes to the login page itself.
- Mobile clients are out of scope; this spec covers the web client only.

## Requirements

### AC-001 — Silent refresh and replay

When a request returns 401 and a refresh token is present, the web client
must call `refreshSession` exactly once, then replay the original request
with the new session. A single original request is never retried more than
once.

Verify with: `npx vitest run web/tests/auth-refresh-401.spec.ts`

### AC-002 — Expired refresh token ends the session

When the refresh token is expired, the web client must clear the local
session and redirect to `/login`. No retry, no loop.

Verify with: `npx vitest run web/tests/auth-refresh-expired.spec.ts`

## Open questions

- None. (Redirect vs. an inline re-auth modal was settled in the ticket
  comments: redirect to `/login`.)

## Affected areas

- `web/src/http/client.ts`
- `web/src/auth/session.ts`

## Dropped from sources

- "Remember me for 30 days" checkbox (WEB-123) — a session-lifetime
  feature, not part of silent refresh; split out as WEB-131.
```

**Dropped from sources** is where the honesty lives: the ticket asked, the spec declined,
and the reason is on record instead of silently vanishing.

## Step 3 — Task: bound the agent's work

The task packet gives the agent three boundaries: what to implement, what to leave alone,
and how to verify. The agent instructions are the standard block from the template.

**`tasks/auth-refresh.md`**

```markdown
---
type: task
id: TASK-AUTH-REFRESH
source:
  - SPEC-AUTH-REFRESH
scope: [AC-001, AC-002]
status: ready
---

# Task: Implement silent token refresh

## Source

- Spec: `specs/auth-refresh/spec.md` (SPEC-AUTH-REFRESH)

## Scope

Implement or preserve:

- AC-001 — silent refresh and replay on 401, at most one retry per request
- AC-002 — expired refresh token clears the session, redirects to `/login`

## Do not change

- The login page (`web/src/pages/login/`)
- Token lifetimes or the auth server API

## Affected areas

- `web/src/http/client.ts`
- `web/src/auth/session.ts`

## Verify

- [ ] `npx vitest run web/tests/auth-refresh-401.spec.ts` (AC-001)
- [ ] `npx vitest run web/tests/auth-refresh-expired.spec.ts` (AC-002)

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

## Step 4 — Run: the agent works, then reports

Hand the packet to any coding agent — [Running agents](../07-running-agents.md) covers the
mechanics. The run ends with the agent filling the packet's own `## Run summary`
section — and dropping the durable discovery in `## Findings`:

```markdown
## Findings

- Refresh responses can arrive concurrently from multiple tabs — the
  single-flight guard is load-bearing; candidate for Close
  (FINDING-REFRESH-SINGLE-FLIGHT).

## Run summary

The run summary for TASK-AUTH-REFRESH.

Changed files:

- web/src/http/client.ts — 401 interceptor: refresh once, replay once
- web/src/auth/session.ts — clearSession(); expired-token guard
- web/tests/auth-refresh-401.spec.ts — new (2 tests)

Commands run:

    $ npx vitest run web/tests/auth-refresh-401.spec.ts

     ✓ web/tests/auth-refresh-401.spec.ts (2 tests) 384ms
       ✓ replays the original request with the new session after a 401
       ✓ calls refreshSession exactly once per original request

     Test Files  1 passed (1)
          Tests  2 passed (2)

AC-002: clearing the session and redirecting to /login works — verified
manually against the dev server with an expired refresh token.

Worth saving: when several requests are in flight on an expired token, each
one sees its own 401 and each calls refreshSession. I serialized refresh
behind a single in-flight promise — otherwise one expired token hits the
token endpoint N times.
```

One Verify item has pasted output; the other has a sentence. That difference is exactly what
the next step exists to catch.

## Step 5 — Review: build the packet, route the exceptions

The reviewer (or their agent) fills the packet from the run summary and the diff — the rules
are in [Reviewing agent output](../08-reviewing-output.md). "Verified manually" is a claim,
not evidence, and an empty or claim-only Evidence cell means Unverified, never Pass — a
checklist rule: nothing in this repo enforces it; the reviewer inspects it.

**`reviews/auth-refresh.md`** — as first written:

```markdown
---
type: review
id: REVIEW-AUTH-REFRESH
task: TASK-AUTH-REFRESH
pr: https://github.com/acme/shop-web/pull/412
reviewer: mara@acme (the agent's session implemented; Mara reviews)
status: needs-human
---

# Review: Silent token refresh

## Summary

The 401 interceptor refreshes once and replays once, with test output
pasted. The expired-refresh-token path (AC-002) has no test output — only a
manual claim — so it stands Unverified. One finding candidate: concurrent
401s fanning out to multiple refresh calls.

## Changed files

- `web/src/http/client.ts`
- `web/src/auth/session.ts`
- `web/tests/auth-refresh-401.spec.ts`

## Requirement coverage

| ID     | Result     | Evidence                                                              | Human attention |
| ------ | ---------- | --------------------------------------------------------------------- | --------------- |
| AC-001 | Pass       | `auth-refresh-401.spec.ts` — 2 tests passed, output pasted in PR #412 | no              |
| AC-002 | Unverified | no test output — "verified manually" is a claim, not evidence         | yes             |

Spot-checked: AC-001 — re-ran `npx vitest run web/tests/auth-refresh-401.spec.ts` myself → 2 passed.

## Human attention

1. AC-002 is Unverified — the spec names `auth-refresh-expired.spec.ts`,
   which was never written. Ask the agent for the test plus pasted output.
2. Finding candidate: concurrent 401s fan out to multiple refresh calls;
   the single-flight guard in `client.ts` deserves a saved finding.

## Suggested decision

Block until AC-002 has real evidence.
```

The Unverified row is the packet doing its job: it turned a 3-file diff into one precise
follow-up. The agent writes the missing test and pastes the run:

```text
$ npx vitest run web/tests/auth-refresh-expired.spec.ts

 ✓ web/tests/auth-refresh-expired.spec.ts (2 tests) 291ms
   ✓ clears the local session when the refresh token is expired
   ✓ redirects to /login when the refresh token is expired

 Test Files  1 passed (1)
      Tests  2 passed (2)
```

The packet is updated in place — the row flips, the frontmatter `status` becomes `pass`,
and the decision changes:

```markdown
| AC-002 | Pass | `auth-refresh-expired.spec.ts` — 2 tests passed, output pasted in PR #412 | no |

## Suggested decision

Merge.
```

Before signing off, the reviewer spot-checked one green row by re-running AC-001's command —
the convention that keeps a tidy table from becoming a rubber stamp.

## Step 6 — Close: save the finding, update the board

The "worth saving" note becomes a finding — a durable lesson with its evidence attached
([Saving findings](../09-saving-findings.md) covers the lifecycle).

**`findings/refresh-single-flight.md`**

```markdown
---
type: finding
id: FINDING-REFRESH-SINGLE-FLIGHT
status: candidate
from: REVIEW-AUTH-REFRESH
date: 2026-06-11
related: [SPEC-AUTH-REFRESH#AC-001]
---

# Finding: Concurrent 401s fan out to multiple refresh calls

## What we learned

When several requests are in flight as a token expires, each sees its own
401 and each calls `refreshSession` — one expired token becomes N refresh
calls and N replays unless refresh is serialized behind a single in-flight
promise.

## Evidence

PR #412 run summary and `reviews/auth-refresh.md`; the single-flight guard
in `web/src/http/client.ts`, with `auth-refresh-401.spec.ts` exercising the
exactly-once rule.

## Where it applies

- Any client where multiple requests can be in flight when a token expires.

## Where it does not apply

- Clients that serialize all authenticated requests through one queue.

## Future guidance

When touching a token-refresh path, check for a single-flight guard first —
and write the concurrent-401 test before the happy-path one.
```

Finally, the workboard rows. The closed task's link points at its review packet — the
board's one honest rule is that a done claim links its evidence.

**`status.md`** (the rows this feature added)

```markdown
| Item                          | Type    | State     | Link                                |
| ----------------------------- | ------- | --------- | ----------------------------------- |
| SPEC-AUTH-REFRESH             | spec    | done      | `specs/auth-refresh/spec.md`        |
| TASK-AUTH-REFRESH             | task    | closed    | `reviews/auth-refresh.md`           |
| FINDING-REFRESH-SINGLE-FLIGHT | finding | candidate | `findings/refresh-single-flight.md` |

## Human attention

- FINDING-REFRESH-SINGLE-FLIGHT pending acceptance.
```

That's the whole loop: a ticket became a snapshot, a spec with a recorded drop, a bounded
task, a run with pasted evidence, a packet that blocked once and passed honestly, and a
lesson that outlives the session.

## Other examples

- [A bug fix](bug-fix.md) — the bug shape: spec check, a one-line amendment, and a
  regression test that runs red before the fix.
- [A large PR review](large-pr-review.md) — the main demo: a change-plan-driven refactor
  and the packet that makes a 41-file agent PR reviewable.
