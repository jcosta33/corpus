# Walk the loop · Review

_Works today — plain markdown plus your agent; no Corpus tooling required._

You have a finished change: the agent implemented `AC-001`, ran the integration test, and
left you a task packet with the output. Now you decide whether it's done — not by reading the
diff line by line, but by reading **one row and one exception**. That is the Review step, and it
is the step Corpus exists for.

By the end of this page you'll have written `reviews/checkout-expiry.md`: a one-row coverage
table that records what passed and with what evidence, plus a single Human-attention row that
routes the one part of this change a person should still eyeball. The full anatomy of the
packet — every section, every invariant — lives in
[Reviewing agent output](../08-reviewing-output.md); this page fills it in for our scenario.

> **Reminder — this is a worked artifact, not a live run.** You're producing a real review
> packet for the `shop-api` reference change. The `npm run test:integration` line never executes
> against anything here; the pasted output below is what _your_ agent's run would produce. When
> you run the loop on your own next real change, you'll paste your own.

## The one idea: review by exception

A coding agent can hand you a 3000-line diff. Reading it top to bottom isn't review — it's
skimming with extra guilt. Corpus inverts it: you read **which requirements passed and with what
evidence**, then **the short list of places the packet says your eyes are needed**. You still
open the diff — but where the packet points, not at line 1.

The full rationale, the invariants, and the evidence rules are in
[Reviewing agent output → Review by exception](../08-reviewing-output.md#review-by-exception).
Here, we just do it once.

## First, the independence rule

One rule decides who is even allowed to fill this file: **whoever wrote the diff never fills the
result.** The agent that made the change does not judge the change — an evaluator scores its own
work higher than it merits. So:

- The agent implemented `AC-001`. **You** (or a fresh agent session that did _not_ write the
  diff) fill the review packet.
- If you had written the code by hand, an agent would review it. Self-review is still good
  practice, but it yields fixes, never a result.

This is the Skeptic stance — refute by default, treat confident prose as a claim to check. It's
one of Corpus's [review stances](../reference/review-stances.md), and the independence rules behind
it are in [review-stances → Judge independence](../reference/review-stances.md#judge-independence).

**Stop-point check:** you are not the session that wrote the diff. If you are, hand the review to
a fresh session before continuing.

## Step 3a — Create the file and its frontmatter

Make a new file at `reviews/checkout-expiry.md`. Start from the kit's review template —
[`templates/review.md`](https://github.com/jcosta33/corpus-starter-kit/blob/main/templates/review.md) —
which owns the format; you're filling it, not redesigning it. Fill the frontmatter for our task:

```markdown
---
type: review
id: REVIEW-checkout-expiry
task: TASK-checkout-expiry
pr: none yet
reviewer: you (a fresh reader — never the implementing session)
status: draft
---

# Review: Expired checkout session returns 409
```

Leave `status: draft` for now — you flip it to `pass` only once every row is Pass with real
evidence and the exceptions are routed.

**Stop-point check:** the file exists, and `task:` names the task you ran in
[step 2](02-task-and-run.md). You've produced the shell of the review record.

## Step 3b — The coverage table: one row per scoped requirement

The task's scope was `[AC-001]` — one requirement, so the coverage table has exactly one row.
The columns are fixed by the template: `ID | Result | Evidence | Human attention`. Paste the
output your agent run produced for the `Verify with:` command — the same
`Tests: 3 passed, 3 total` you carried out of [step 2](02-task-and-run.md):

```markdown
## Requirement coverage

| ID     | Result | Evidence                                                                   | Human attention |
| ------ | ------ | -------------------------------------------------------------------------- | --------------- |
| AC-001 | Pass   | `npm run test:integration -- expired-session` → `Tests: 3 passed, 3 total` | yes             |
```

This row reads **Pass** because the Evidence cell holds _pasted output_ — a real command result,
not a sentence about one. That's the evidence rule at work; an empty cell would make the row
**Unverified**, never Pass, whatever the prose claims. You don't restate that rule in the packet —
it's the contract, owned by
[Reviewing agent output → The evidence rules](../08-reviewing-output.md#the-evidence-rules) and
the packet checks in [the checks catalogue](../reference/checks.md) (`non-empty-paste`, plus the
coverage check `C012`). Notice the `Human attention` cell reads `yes` even though the result is
Pass — a green row can still route a person. We'll see why in step 3d.

**Stop-point check:** your one row reads `AC-001 | Pass | <pasted output> | …`, and the Evidence
cell holds actual output, not a sentence _about_ output. You've produced the verified-coverage
record.

## Step 3c — Spot-check the green row

A tidy table _feels_ verified — and that feeling is exactly why
[Reviewing agent output → Spot-check one green row](../08-reviewing-output.md#spot-check-one-green-row)
asks you to confirm a Pass yourself before you accept it. With one row, the choice is easy:
re-run `AC-001`'s command and record what you saw, right under the table:

```markdown
Spot-checked: AC-001 — re-ran `npm run test:integration -- expired-session` myself → `Tests: 3 passed, 3 total`.
```

This is a convention, not a tool gate. One honest spot-check per packet keeps the green column
meaning something. (In _this_ worked artifact the command doesn't really run, so the line records
what a real re-run would show; on your own change, you actually re-run it.)

**Stop-point check:** the packet carries a `Spot-checked:` line naming the row you re-ran. You've
produced your own independent confirmation of the green cell.

## Step 3d — Route the one exception

A green table is not the end. Review-by-exception means the packet must consider every class of
thing that needs a human — and _list_ it, even when the row passed. Our change touches checkout,
which is the money path: `risky files` (payments) is one of the exception triggers. So even with
`AC-001` green, one row routes to a person. Add the Human-attention section:

```markdown
## Human attention

1. **Risky file — money path.** This change lands on checkout, which validates a session before
   charging. `AC-001` passes, but the failure mode here is a session that _should_ expire still
   being charged against. Confirm the 409 path runs before any charge call, not after.
```

That's the whole point of the section: it's the short list your future self (or your teammate)
reads instead of the diff. You don't enumerate the trigger classes here — the canonical list of
what needs your eyes lives in
[Reviewing agent output → the exception triggers](../08-reviewing-output.md#what-needs-your-eyes--the-exception-triggers),
and a good packet has considered every one (listing it or marking it n/a). Here, one trigger
fires, so one exception is listed.

**Stop-point check:** your packet has exactly one Human-attention item, and it names _why_ the
file is risky and _what_ a human should look at. You've produced the routed-exception record —
the thing that makes a green review still worth a second pair of eyes.

## Step 3e — The decision, and flip the status

Finish with the suggested decision and update the packet status. Everything passed with pasted
evidence, the spot-check held, and the one exception is an attention note rather than a blocker —
so this merges, with the money-path note flagged for the reviewer's eyes:

```markdown
## Suggested decision

Merge — `AC-001` passes with pasted, spot-checked output. Read the money-path note above before
you do.
```

Then change the frontmatter `status: draft` to `status: pass`. The packet — not a PR thread — is
now the durable record of what was verified against the spec. (The full status set —
`draft · pass · waived · blocked · needs-human` — and what each means is owned by
[Reviewing agent output → Results and packet status](../08-reviewing-output.md#results-and-packet-status).)

> **The optional CLI, as an aside.** `corpus review` can _draft_ this packet — reconciling the
> finished run against the diff and the spec and surfacing the facts (the coverage check `C012`,
> the evidence-binding check `C013`). It surfaces facts; **you still decide the result.** The
> by-hand path above is the primary one — the CLI is a convenience, and nothing in Corpus enforces
> any of these rules.

## What you produced

`reviews/checkout-expiry.md` — a one-row coverage table with pasted, spot-checked evidence for
`AC-001`; one Human-attention row routing the money-path risk; and a merge decision, status
`pass`. You reviewed a finished change without reading the whole diff: one row, one exception.

## Stop-point check (end of step)

- [ ] `reviews/checkout-expiry.md` exists, frontmatter `id: REVIEW-checkout-expiry`,
      `task: TASK-checkout-expiry`, `status: pass`.
- [ ] One coverage row: `AC-001 | Pass | <pasted output> | yes`, the Evidence cell holding
      actual command output (`Tests: 3 passed, 3 total`).
- [ ] A `Spot-checked: AC-001 — …` line records a re-run you did yourself.
- [ ] One Human-attention item names the risky money-path file and what to look at.
- [ ] You are not the session that wrote the diff.

If all five hold, you've walked the Review step. Next: [close the task and save what you
learned](04-close.md).
