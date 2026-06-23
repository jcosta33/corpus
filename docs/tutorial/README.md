# Your first loop: a hands-on walkthrough

*Works today — plain markdown plus your agent; no Corpus tooling required.*

You learn Corpus by walking the loop once, by hand. This track is a guided build: four short
pages, one small change, every step ending in a file you can see. By the end you will have
produced a real set of Corpus artifacts and watched a change travel from a vague ask to a
reviewed, recorded result.

The other docs explain Corpus and tell you how to do each step well. This track is the
do-it-yourself path between them: you follow along and produce the artifacts as you read.

## What you'll build

One pass through the six-step loop, on a single small requirement. Each step leaves one
artifact behind, and you'll create each one for real — in the order the per-page list at the
bottom of this page lays out, so you always know which page produces which file:

- **an intake** — `intake/checkout-expiry.md`, the ask captured verbatim before you interpret it
- **a spec** — `specs/checkout/spec.md`, one requirement with a way to verify it
- **a task** — `tasks/checkout-expiry.md`, scoped to that requirement, with a "Do not change" line
- **a run summary** — the agent's account of what it did, filled into the task packet
- **a green review packet** — `reviews/checkout-expiry.md`, one coverage row marked Pass
- **a finding** — `findings/session-expiry-is-409.md`, the lesson saved so the next session keeps it
- **an updated board** — `status.md`, the task's row flipped and closed

Seven small files. That is the whole loop — nothing here is large, and every step succeeds
before the next one begins.

## The change you'll work

You'll add **one** net-new requirement to `shop-api`, the TypeScript storefront service from
the worked example in [the large-PR walkthrough](../examples/large-pr-review.md):

> A checkout session older than 30 minutes must return `409 SESSION_EXPIRED`, never a 5xx.

That's it — small enough to hold in your head, real enough to exercise every step. This is the
six-step **happy path**: green from end to end, no surprises. The two optional steps —
Inventory and Change Plan — stay off (they switch on only for structural or brownfield work);
the close of the track points you to them when you're ready to go deeper.

## The six-step shape

Every Corpus change follows the same loop:

**Pull → Spec → Task → Run → Review → Close.**

The diagram, the optional steps, and the one-line summary of each live in
[the basic workflow](../02-basic-workflow.md) — read it once for the shape, then come back. This
track walks those steps in order:

- **[01 · Pull and Spec](01-pull-and-spec.md)** — capture the ask into an intake, interpret it into one requirement.
- **[02 · Task and Run](02-task-and-run.md)** — bound the agent's work, then let it work.
- **[03 · Review](03-review.md)** — read the evidence, fill the coverage row.
- **[04 · Close](04-close.md)** — record the lesson, flip the board.

## Before you start

You need two things, and a little framing.

1. **A workspace** — the folder where your intakes, specs, tasks, reviews, and findings live.
   You get one by copying the starter kit whole; that copy gives you the `intake/`, `specs/`,
   `tasks/`, `reviews/`, `findings/`, and `status.md` you'll write into, plus the templates
   you'll fill. Set it up with [Adopting Corpus](../ADOPTING.md) — about fifteen minutes — and
   come back. (Already have a workspace? You're ready.)

2. **An agent, or yourself.** Corpus ships no agent; it shapes the inputs any agent works from
   and the output you review. The Run step hands the task packet to your coding agent — but a
   human can play that role just as well for this walkthrough. Either way, see
   [running agents](../07-running-agents.md) for how the handoff works.

### One honest note about the scenario

Corpus ships no runtime and no sample repo, so there is
no `shop-api` checkout to run a test against here — the `npm run test:integration` command in
the spec is the *kind* of check a real spec carries, not a command that executes against this
fiction. So treat `shop-api` as the **worked reference**: you'll write every Corpus artifact for
real, against this scenario, to learn the shapes — and then run the loop for real on your
**own next change**, where the verify commands point at code that exists. The artifacts you
produce here are genuine Corpus files; only the code they describe is borrowed. (The step pages
echo this in one line and link back here — this is the full version.)

## What's next

Open **[01 · Pull and Spec](01-pull-and-spec.md)** — you'll capture the ask into an intake and
write your first spec.
