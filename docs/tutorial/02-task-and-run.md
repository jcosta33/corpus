# Walk the loop · Task and Run

*Works today — plain markdown plus your agent; no Corpus tooling required.*

You have a spec. `specs/checkout/spec.md` (`SPEC-checkout`, status `ready`) carries one
requirement — `AC-001 — Expired session returns 409` — with a runnable check on it. Holding a
spec is not the same as handing work to someone. This page is the two steps that do the handing:

- **Task** — you write the packet that bounds the work: which requirement, which files, what must
  not change, how it gets verified.
- **Run** — the work happens in an isolated branch, and a run summary with real test output comes
  back.

By the end you will have produced `tasks/checkout-expiry.md` and you will know exactly what a
finished run looks like — including the one thing that separates a Pass from an Unverified.

> **About the test command.** Corpus ships no sample repo, so the `npm run test:integration`
> command on this page never literally runs against any code here — `shop-api` is the
> [worked reference](../examples/large-pr-review.md), not a downloadable project. You produce the
> Corpus artifacts for real; you run the actual loop on your own next real change. Everything below
> is a real artifact you can copy.

---

## Step 3 · Task: bound the work

A spec says what should be true. A task hands one slice of it to one pair of hands — agent or
human — with a wall around it. The packet is where the handoff is written down so you can inspect
it. The full reasoning lives in [Creating tasks](../06-creating-tasks.md); here you just fill the
template.

**Now create the file.** Copy
[`templates/task.md`](https://github.com/jcosta33/swarm-starter-kit/blob/main/templates/task.md)
to `tasks/checkout-expiry.md` and fill it in. Here is the whole packet for our one requirement:

```markdown
---
type: task
id: TASK-checkout-expiry
source:
  - SPEC-checkout
scope: [AC-001]
status: ready
---

# Task: Expired checkout session returns 409

## Source

- Spec: `specs/checkout/spec.md` (SPEC-checkout)

## Scope

Implement or preserve:

- AC-001 — A checkout session older than 30 minutes returns 409 SESSION_EXPIRED, never a 5xx.

## Do not change

- the `sessions` table schema

## Affected areas

- `src/checkout/`, `test/`

## Verify

- [ ] `npm run test:integration -- expired-session` (AC-001)

## Agent instructions

<!-- The standing rules ship in templates/task.md — copy them verbatim,
     do not rewrite them per task. -->
```

Three lines are doing the real work, and each maps to a part of the template explained on the
[Creating tasks](../06-creating-tasks.md) page:

- **`scope: [AC-001]`** — exactly the requirement from your spec, by id. A task never invents
  requirements of its own; if the work turns out to need more, the agent's instruction is to stop
  and say why, not improvise.
- **The "Do not change" line** — `the sessions table schema`. This is the
  [scope wall](../06-creating-tasks.md#do-not-change-is-the-scope-wall): name the adjacent,
  tempting thing the work should leave alone. It is the most valuable line in many packets.
- **The Verify command** — `npm run test:integration -- expired-session`, copied straight from
  your spec's `Verify with:` line. One runnable command per requirement is the part an agent
  benefits from most.

**The agent instructions are not yours to write.** The standing rules — read the sources first,
stay in scope or stop and say why, run every Verify item and paste real output, self-review the
diff, leave a run summary — ship in the template and travel with every task, so every agent gets
the same brief. Copy the `## Agent instructions` block from
[`templates/task.md`](https://github.com/jcosta33/swarm-starter-kit/blob/main/templates/task.md)
verbatim; do not retype or edit them here. (See
[the section on the standing rules](../06-creating-tasks.md#the-template).)

> **Stop-point check.** Open `tasks/checkout-expiry.md`. You should see: `scope: [AC-001]` in the
> frontmatter, a "Do not change" line naming the `sessions` table schema, exactly one line under
> Verify, and the standing **Agent instructions** block copied from the template unchanged. That
> is a complete packet — one requirement, one wall, one check. You have produced the handoff.

---

## Step 4 · Run: hand it off in isolation

Run is the step where the packet leaves your hands. You can hand it to whatever does the work —
Claude Code, Codex, Cursor, Aider, or a human colleague. Corpus does not run agents and does not
care which one you use; the packet is plain markdown, and anything that can read a file can work
from it ([Running agents](../07-running-agents.md)).

### Make an isolated branch

Run each task in its own git worktree, on its own branch off the base. This keeps the work off
your main checkout, maps one task to one branch to one review, and makes abandoning a bad run as
cheap as deleting a directory ([why this hygiene pays off](../07-running-agents.md#one-worktree-and-branch-per-task)).

**Now run this** (against your own repo, on your own next change):

```bash
git worktree add -b swarm/checkout-expiry ../shop-api--checkout-expiry main
```

That gives you a fresh checkout in `../shop-api--checkout-expiry` on a new branch
`swarm/checkout-expiry`. This is a convention — nothing here enforces it; an agent told to edit in
place will edit in place. *(The optional `swarm worktree` sets up the isolated branch and checkout
for you; you still launch your own agent inside it —
[the reference CLI](../reference/future-cli.md) prepares the loop, it does not run your agent.)*

### Hand off the packet

Point whoever is doing the work — agent or human — at the task file and let them follow the
sources from there. No prompt preamble is needed; the standing rules are already in the packet.
For an agent, the one-line handoff is:

```
Read tasks/checkout-expiry.md and do what it says.
```

A human colleague reads the same file and works from the same Scope, "Do not change", and Verify
line. *(The optional [`swarm run`](../reference/future-cli.md) launches a configured agent in the
task's worktree and records the launch; it never becomes the agent — the coding loop is still the
agent's, never Corpus's.)*

### What comes back

The worker does two things with the packet on the way out. First, it runs each Verify item and
**pastes that command's real output directly under the item** — that is where the evidence lives.
Then the last standing instruction has it fill the packet's **`## Run summary`** section —
changed files, out-of-scope edits, blocked questions, and one line per Verify command that
*points back* at the paste rather than repeating it. Both shapes are owned by the
[task template](https://github.com/jcosta33/swarm-starter-kit/blob/main/templates/task.md) and
explained in [What you get back](../07-running-agents.md#what-you-get-back) — don't redraw them.
A finished, green packet for our task looks like this, Verify section first:

```markdown
## Verify

- [x] `npm run test:integration -- expired-session` (AC-001)

      Test Suites: 1 passed, 1 total
      Tests:       3 passed, 3 total
```

```markdown
## Run summary

- Changed files: src/checkout/expiry.ts, src/api/errors.ts, test/integration/expired-session.test.ts
- Verify results:
  - npm run test:integration -- expired-session (AC-001) → PASS (output under Verify above)
- Out-of-scope edits: none
- Blocked questions: none
```

Notice what makes that packet trustworthy: the **actual test output is pasted in** under the
Verify item, and the summary just indexes it — never re-pastes it. This is the one rule on this
page worth memorizing, and it decides the review result a step later:

> **"Tests passed" with no pasted output is not evidence.** A done-claim with the command's real
> output behind it can become a **Pass** at review. A bare "all tests passed" with nothing pasted
> is recorded as **Unverified** — not Pass, not Fail — until someone produces the output
> ([the evidence rule](../07-running-agents.md#what-you-get-back)). Insist on the paste while the
> worktree still exists and a re-run costs seconds; later it is archaeology.

The worker also self-reviews its diff as a skeptic before leaving the summary — that yields
*fixes*, never a result; the Pass/Fail call belongs to the next step, made by someone who didn't
write the code. See
[self-review before handoff](../07-running-agents.md#self-review-before-handoff) for why an agent
grading its own work can't issue the verdict.

> **Stop-point check.** You should have: a worktree on branch `swarm/checkout-expiry`, the packet
> handed off with the one-line prompt, and a returned packet where the integration-test output is
> **pasted under its Verify item** (green) and the `## Run summary` line cites it. If the summary
> says "passed" but no output sits under the Verify item, it is not done — ask for the paste
> before tearing anything down. When the output is there, you are holding a run ready to judge.

---

## What you produced

- `tasks/checkout-expiry.md` — a complete task packet: one requirement in scope, one "Do not
  change" wall, one Verify command, the standing agent instructions from the template.
- An isolated branch (`swarm/checkout-expiry`) and a returned packet with real test output
  **pasted under the Verify item** and a **Run summary** that indexes it — the raw material the
  review step reads.

## Next

You have a finished run with pasted evidence and an untrustworthy-by-default done-claim sitting in
it. The next step turns that into a Pass: [Review](03-review.md).
