# Walk the loop · Pull and Spec

*Works today — plain markdown plus your agent; no Corpus tooling required.*

This is the first leg of the tutorial. You will walk the six-step loop —
**Pull → Spec → Task → Run → Review → Close** — once, end to end, by adding one small
requirement to a service. By the end of this page you will have produced two real Corpus
artifacts: an intake snapshot and a spec.

The change lands on `shop-api`, the TypeScript storefront from
[the large-PR-review example](../examples/large-pr-review.md) — your *worked reference*, the
same artifacts filled in and reviewed. As the [track overview](README.md#one-honest-note-about-the-scenario)
explains, you write the Corpus artifacts here for real and run the loop for real on your own next
change; the `Verify with:` commands below name `shop-api`'s tests, but nothing here executes code.

**The change you are speccing:**

> A checkout session older than 30 minutes must return `409 SESSION_EXPIRED`, never a 5xx.

That is it — one net-new behavior. This is the happy path: green the whole way through, the six
steps and nothing else. (Two optional steps, Inventory and Change Plan, switch on only for
structural or brownfield work; you'll meet them in the close, not here.)

---

## Step 1 · Pull — capture the ask, unedited

Work usually arrives from somewhere — a ticket, a Slack thread, a customer report. The Pull
step does one thing: it snapshots that ask **verbatim** into an intake file, before you
interpret a single word of it. The spec (next step) is where interpretation happens; the
intake stays as the anchor you can check that interpretation against later, even after the
original ticket is edited or closed. The beat to internalize: **preserve here, interpret next.**

The Pull section of [the basic workflow](../02-basic-workflow.md#1--pull--capture-what-was-asked)
owns the *why* and *when* of this step; read it once. The shape of the file is frozen in the kit
template — copy
[`templates/intake.md`](https://github.com/jcosta33/swarm-starter-kit/blob/main/templates/intake.md)
rather than inventing fields.

Now create the file. In your workspace, make `intake/checkout-expiry.md` and paste the ask into
it, untouched:

**`intake/checkout-expiry.md`**

```markdown
---
type: intake
source: SHOP-4012
url: https://acme.atlassian.net/browse/SHOP-4012
captured: 2026-06-20
---

# Intake: stale checkout sessions return 500s

SHOP-4012 — Stale checkout sessions return 500s
Reporter: Priya N. (Support) · Priority: High · Labels: checkout, api

When a customer leaves checkout open for a while and then tries to pay,
the API sometimes throws a 500 instead of telling them the session timed
out. Support can't tell these apart from real outages.

What we want: a checkout session older than 30 minutes must return
409 SESSION_EXPIRED, never a 5xx.
```

Resist the urge to clean it up. The reporter's wording, the priority, the label — leave all of
it. If the wording is awkward, that awkwardness is data the spec will resolve out in the open.

> The optional `swarm pull` captures this snapshot for you. By hand, you copy-paste into the
> template — exactly what you just did. The CLI is a convenience, never a requirement.

**Stop-point check.** You should now have one file, `intake/checkout-expiry.md`, containing the
ask word-for-word and nothing you wrote yourself. If you find you "improved" any of the
reporter's phrasing, undo it — that belongs in the spec. ✔ Intake captured.

---

## Step 2 · Spec — interpret the ask into one requirement

Now you interpret. The spec turns that raw ask into intent, what's deliberately out of scope,
and — the heart of it — **one verifiable requirement.** For this change there is exactly one:
an expired session returns `409 SESSION_EXPIRED`.

[Writing specs](../04-writing-specs.md) owns the full rules for how a requirement is phrased —
observable verbs, one behavior each, one binding word, and the rest. Don't try to memorize them
from here; the canonical page is the home, and you'll lean on it the moment your own specs get
bigger. For this one requirement, the rules mostly take care of themselves.

The format is frozen in the kit — copy
[`templates/spec.md`](https://github.com/jcosta33/swarm-starter-kit/blob/main/templates/spec.md)
and fill it. Create `specs/checkout/spec.md`:

**`specs/checkout/spec.md`**

```markdown
---
type: spec
id: SPEC-checkout
title: Expired checkout sessions return 409
status: ready
owner: checkout-team
sources:
  - intake/checkout-expiry.md
---

# Expired checkout sessions return 409

## Intent

When a customer acts on a checkout session that has aged past its 30-minute
lifetime, the API tells them the session expired instead of failing. Raised
by support volume in SHOP-4012.

## Non-goals

- The 30-minute lifetime itself does not change.
- The `sessions` table schema does not change.
- No change to how sessions are created or charged — only the response to an
  already-expired one.

## Requirements

### AC-001 — Expired session returns 409

When a request acts on a checkout session older than 30 minutes, the API
must respond `409 SESSION_EXPIRED` and never a 5xx.

Verify with: `npm run test:integration -- expired-session`

## Open questions

- None.

## Affected areas

- `src/checkout/`
```

**Stop-point check.** You now have `specs/checkout/spec.md` — a filled spec with one requirement,
`AC-001`, carrying its `Verify with:` line. That is the artifact; the rest of this step is
understanding the choices baked into it. ✔ Spec file written.

### Why the spec reads the way it does

Each of these choices is backed by a rule on [Writing specs](../04-writing-specs.md):

- The requirement keeps its own ID, `AC-001`. Every task scope, review row, and finding later
  in this loop will point at that exact ID.
- `status: ready` — because there are no open questions left to settle. A spec with an
  unresolved question stays `draft`.
- The `Non-goals` block names the things a reader might *assume* you're changing (the lifetime,
  the table) and says you are not. That is where scope disputes get settled cheaply.

The `Verify with:` line under `AC-001` does the most work of anything in the file —
[Writing specs](../04-writing-specs.md#writing-rules) calls it *the highest-value line in the
file*, because a runnable check outperforms prose plans as task input. For `AC-001` that line is
`npm run test:integration -- expired-session`: it hands your agent a concrete target to hit and
gives your reviewer something to read instead of the whole diff. It is fine that this command
names a test in `shop-api` you aren't running here — in your own loop, this is the line you'd run.

Which line is "good enough" is itself a checklist. Corpus's catalogue of common spec mistakes —
including the rule that *every* requirement carries a `Verify with:` line — lives in
[the checks reference](../reference/checks.md). You don't need it for one requirement, but it is
the page reviewers (and the optional `swarm check`) work from, so know it's there.

> For high-risk work, a spec can switch its requirements to a stricter structured notation —
> see [structured requirements](../reference/structured-requirements.md). Not now: one plain
> `### AC-NNN` requirement is exactly right here.

**Ready check.** Before moving on, confirm your spec has:

- frontmatter `id: SPEC-checkout` and `status: ready`,
- exactly one requirement, `### AC-001 — Expired session returns 409`,
- a `Verify with:` line under it,
- an `Open questions` section that reads "None."

If `Open questions` had anything unresolved, the status would be `draft`, not `ready` — go
settle it before moving on. ✔ Spec ready.

---

## What you have so far

Two files, and a clean separation between them: `intake/checkout-expiry.md` holds *what was
asked*, and `specs/checkout/spec.md` holds *what you'll build and how you'll know it works*.
The requirement `AC-001` is the thread the rest of the loop pulls on.

**Next:** [Task and Run](02-task-and-run.md) — bound `AC-001` into a packet your agent can
work, then let it run.
