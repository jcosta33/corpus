# Walk the loop · Close

_Works today — plain markdown plus your agent; no Corpus tooling required._

You finished Review with a Pass. The change is real, the coverage row records what was
verified, and the loop is almost done. One step is left — **Close** — and it is the one most
teams skip: keeping what this work taught you so the next session doesn't re-learn it.

By the end of this page you'll have written a finding, updated the board, and stepped back to
see the whole artifact chain you now own. That's the loop walked once.

> **Before you start**, you should have `reviews/checkout-expiry.md` with a passing coverage
> row from the previous page. If you don't, finish Review first.

---

## Step 1 — Save the finding

While building AC-001 you learned something durable: _an expired checkout session is a
**409**, never a 5xx — the timeout is an expected outcome, not a server error._ That is exactly
the kind of fact the next person touching checkout would want to know, and exactly the kind of
fact that evaporates when this session ends. So you write it down.

Why this matters, what counts as durable, and how findings come back to you (the board and
plain `grep` — there is no retrieval engine) is the whole story on
[Saving findings](../09-saving-findings.md). The one rule it sets is short:

> Before closing a task, record anything durable as a finding.

Now do it. Create `findings/session-expiry-is-409.md`, filling the frozen
[`finding.md` template](https://github.com/jcosta33/corpus-starter-kit/blob/main/templates/finding.md).
Don't reinvent the shape — the template already has the slots; you supply the content:

- **What we learned** — one claim: an expired checkout session (older than 30 minutes) returns
  `409 SESSION_EXPIRED`, never a 5xx.
- **Evidence** — point at `reviews/checkout-expiry.md` (the AC-001 coverage row) and the
  integration test `expired-session`. A finding whose evidence is a bare claim is chat, not
  memory.
- **Where it applies** — the checkout session-expiry path.
- **Where it does not apply** — other 4xx cases, non-checkout sessions.
- **`related`** — `SPEC-checkout#AC-001`, so the next task that touches checkout can find it.

Write the title the way you'd later search for it (`session-expiry-is-409`) — `grep` is how it
comes back.

> **Stop-point check.** You have `findings/session-expiry-is-409.md`. It states one claim,
> names its evidence, and links back to AC-001. The lesson now outlives this session.

---

## Step 2 — Update the board

The board, `status.md`, is the team's one-screen answer to _where does everything stand?_ Close
ends with a board update so the work you just did is visible and the new finding gets read
instead of rotting. The board's format and the rule it carries —
**a "verified" or "done" row links its review packet** — live on
[Saving findings](../09-saving-findings.md#update-the-board); the format itself is frozen in the
kit at
[`status.md`](https://github.com/jcosta33/corpus-starter-kit/blob/main/templates/status.md).

Fill the board's existing sections (the template defines them) for the work you walked. In the
**Workboard** table:

- **`SPEC-checkout`** — state `ready`.
- **`checkout-expiry`** (the task) — state `closed`, with its link pointing at
  `reviews/checkout-expiry.md` (the review packet, per the rule above).

Then refresh the **Human attention** list — the template's short list of things a person needs
to look at. Your new finding, `session-expiry-is-409`, belongs under _findings pending
acceptance_ there until someone accepts it.

The board is hand-edited and stays small. (The optional `corpus status` prints a derived board
from your files; you don't need it — by hand is the primary path.)

> **Stop-point check.** `status.md` shows the task closed and linked to its review packet, and
> the new finding sitting in the Human-attention list as pending acceptance. Anyone opening the
> board can now see exactly where this change landed.

---

## You walked the loop

That's it — **Pull → Spec → Task → Run → Review → Close**, once, end to end. Look at what you
produced, in order. This chain _is_ the deliverable Corpus asks for:

| Step   | Artifact you now own                                                          |
| ------ | ----------------------------------------------------------------------------- |
| Pull   | `intake/checkout-expiry.md` — the ask captured verbatim                       |
| Spec   | `specs/checkout/spec.md` — `SPEC-checkout`, one AC with a `Verify with:` line |
| Task   | `tasks/checkout-expiry.md` — scope `[AC-001]`, a "Do not change" guard        |
| Run    | the run summary your agent produced against that packet                       |
| Review | `reviews/checkout-expiry.md` — one coverage row, status pass                  |
| Close  | `findings/session-expiry-is-409.md` + the updated `status.md` board           |

Every box has a named owner, every claim has evidence, and a reviewer could account for the
whole change without scrolling a single diff blind. That is the point of the loop.

### What you deliberately skipped

This was the happy path, and you held to it on purpose. You did **not** write an **inventory**
or a **change plan** — the two artifacts that join the loop only for structural or brownfield
work: refactors, rewrites, migrations, dependency upgrades, schema and performance changes, or
any code nobody fully remembers. A small net-new requirement like AC-001 needs neither, and
writing them anyway just recreates ceremony. When they _do_ switch on — and how to write them —
is [Brownfield work and change plans](../05-brownfield-and-change-plans.md).

### Now run it for real

The next move is the real one: **run this exact loop on your own next small change.** You've
produced every Corpus artifact by hand once; do it again against something that actually ships.

### Where to go deeper

- **Same `shop-api`, harder mode** — [the large-PR review walkthrough](../examples/large-pr-review.md):
  the 41-file version of this change, where the structure catches a regression hiding behind a
  green CI badge. [The bug-fix walkthrough](../examples/bug-fix.md) is the shortest loop with the
  same review discipline.
- **The reference layer** — the [cheatsheet](../reference/cheatsheet.md) (the whole loop on one
  page), [step bars](../reference/step-bars.md) (the entry/exit bar for each step),
  [the advanced memory model](../reference/memory.md) (a load-when index, glossary, and patterns,
  for when `grep` stops being enough), and [the future CLI](../reference/future-cli.md) (what the
  optional `corpus` tooling will do for you).
- **Conditioning your agent** — the
  [corpus-skills catalog](https://github.com/jcosta33/corpus-skills): stances and code-depth guides
  you install when you need them.

That's the loop closed. The next piece of work starts the same way — at
[Pull and Spec](01-pull-and-spec.md).
