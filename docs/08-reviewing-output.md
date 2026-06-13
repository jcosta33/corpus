# Reviewing agent output

*Works today — plain markdown plus your agent; no Swarm tooling required.*

Review is the step Swarm exists for. Coding agents produce more code than anyone can read
line by line; the review packet turns that volume into a short list of things a human must
actually look at. This page covers the Review step of the loop: what the packet contains,
the evidence rules, and where your eyes go.

## Review by exception

An agent run can hand you a 3000-line diff. Reading it top to bottom is not review — it is
skimming with extra guilt. Review by exception inverts it:

- read **which requirements passed, with what evidence**,
- read **which did not** (failed, unverified, or blocked),
- read **the exceptions** — the short list of places the packet says your eyes are needed.

You still open the diff — but you open it where the packet points, not at line 1. Everything
covered by a passing result with real evidence has already been accounted for; your attention
is spent on what the structure flags.

## The review packet

The packet is one markdown file in `reviews/`, one per task, named after the task's slug. The format is frozen in the kit
template — [`templates/review.md`](https://github.com/jcosta33/swarm-starter-kit/blob/main/templates/review.md) — and a
filled example lives in [`examples/`](examples/). Walking through it:

- **Summary** — two or three sentences: what changed, what is verified, what is not.
- **Changed files** — the touched paths, so out-of-scope edits are visible at a glance.
- **Requirement coverage** — the heart of the packet. One row per requirement in the task's
  scope: `ID | Result | Evidence | Human attention`. The evidence cell holds pasted command
  output or a CI link (for a manual method: the named human's recorded observation), not a
  sentence about output. Read the task packet's Run summary section first — it indexes the
  Verify pastes the cells cite.
- **Change-plan coverage** — only when the task executes a change plan (see below).
- **Human attention** — the exception list: each item, why it matters, a suggested action.
- **Suggested decision** — merge, or block until a named item is resolved.

A packet should fit on one page. If it doesn't, the task was probably too big — that is
feedback for [task splitting](06-creating-tasks.md), not a reason to write a longer packet.

(Future CLI: `swarm review` will draft this packet — today you, or a fresh agent session that
did not write the diff, fill the template.)

## The evidence rules

These are checklist-level rules: nothing in this repo enforces them — the reviewer inspects
them, and they are on the review checks in [`reference/checks.md`](reference/checks.md).

1. **A Pass needs pasted output, a CI link, or — for a manual Verify method — a named
   human's recorded observation (who judged, what they saw).** A bare "tests passed" is a
   claim, not evidence — unsupported done-claims are the failure this rule exists to catch,
   illustrated (small-N, preliminary) by [[EVIBOUND]](research/sources.md#EVIBOUND).
2. **An empty Evidence cell means Unverified, never Pass.** If nobody can point at the
   output, the requirement was not verified, whatever the prose says.
3. **Don't merge with an open critical item.** A failed or blocked requirement, or an
   unanswered blocking question, holds the merge until it is resolved or explicitly waived
   by a human. A waiver is a record — who waived · which rows · why · expiry — and the
   packet's status becomes `waived` at merge; the row's Result stays what the evidence says.
4. **A known-flaky check cannot buy a Pass with one green run.** Reproduce per the
   fix-flaky-test discipline (loop it) before the row reads Pass.
5. **Separate an environment baseline from a feature regression.** A check that fails for
   reasons outside this change's scope — a broken build script, a missing toolchain, an
   environment that can't run the check — is **Blocked**, not Fail (the full Blocked-vs-Fail
   distinction is in [the advanced lifecycle](reference/advanced-lifecycle.md)). Record such a
   baseline blocker **once**, not as a Fail on every requirement row it touches. A check that
   actually ran and the behavior is wrong is a feature-regression **Fail**. And a check that
   passes only on a **labeled alternate/diagnostic runtime** (e.g. a bundled browser when the
   target environment is Blocked) is recorded as *diagnostic evidence* — the
   target-environment requirement stays Blocked until it runs there.

Solo? The independence rule holds by actor: whoever produced the diff — your hands or an
agent session — does not fill the packet. Agent implements → you review; you implement → a
fresh agent session reviews. Self-review stays mandatory and yields fixes, never a result.

## Spot-check one green row

Before accepting the table, pick at least one Pass row and verify its evidence yourself —
re-run the command, or open the CI link and read the actual result. This is a convention,
not something any tool checks, and it exists because structured packets invite
rubber-stamping: a tidy table _feels_ verified. The bias is measured, not hypothetical —
evaluators measurably favor their own generations
[[SELFPREFER]](research/sources.md#SELFPREFER) and carry predictable judgment biases
[[JUDGEBIAS]](research/sources.md#JUDGEBIAS). One honest spot-check per packet keeps the
green column meaning something.

## What needs your eyes — the exception triggers

The Human attention section routes these. A good packet has considered every class — either
listing an exception or having nothing to list:

- unverified or failed requirements
- out-of-scope changes (edits not traceable to the task's scope)
- risky files (auth, payments, IAM policies, security groups, state moves, destroys —
  anything with a blast radius)
- missing test output
- changed public interfaces
- DB migrations
- security-sensitive changes
- new finding candidates (durable lessons — see [Saving findings](09-saving-findings.md))
- blocked questions

## Read like a skeptic

When a branch warrants more than the packet — high risk, large diff, low trust — the
[`adversarial-review`](https://github.com/jcosta33/swarm-starter-kit/blob/main/.agents/skills/adversarial-review/SKILL.md)
guide (shipped in the kit) runs the deep form: re-run validation yourself, walk six
adversarial questions, search the callers of everything that changed.

The reviewer's stance is refute-by-default: a claim is unproven until evidence forces you to
accept it. In practice —

- treat confident prose as a claim to check, never as proof;
- prefer output you ran or watched run over output you were handed;
- if you authored the change, you don't decide its review result — self-review before
  finishing is good practice (the [task template](https://github.com/jcosta33/swarm-starter-kit/blob/main/templates/task.md) asks the
  agent for it), but it produces fixes, not approval.

## Reviewing transformation work

When the task executes a change plan (refactor, migration, rewrite — see
[Brownfield and change plans](05-brownfield-and-change-plans.md)), the preservation
guarantees are rows too. The packet's **Change-plan coverage** table gives each "must still
behave exactly as before" guarantee the same `ID | Result | Evidence | Human attention`
treatment as the requirements. "Nothing broke" is a claim like any other — it needs evidence.

## When the work arrives as code

Sometimes there is no upstream artifact at all — an external PR from a stranger, a vendor
patch, a bug in code no spec covers. The loop still works, run post-hoc:

1. **Intake the code-shaped work** — snapshot the PR description and diff stats verbatim
   (`source: gh-pr`), exactly like a ticket.
2. **Write the spec as an acceptance bar** — what must be true for this change to merge,
   one `AC-NNN` per behavior, written *after* the code exists. It bounds the review, not
   the build.
3. **The reviewer produces all evidence.** A silent or unavailable author pastes nothing —
   your own runs fill the Evidence column, which is the stronger position anyway: the
   worker's paste is a claim; your run is evidence.

The packet then reads identically to any other review — without a task packet, the spec's
requirement ids key the coverage table directly.

## Results and packet status

Each coverage row carries one result:

| Result         | Meaning                                                        |
| -------------- | -------------------------------------------------------------- |
| **Pass**       | Verified — pasted output, a CI link, or a named human's recorded observation (manual method) |
| **Fail**       | Verified and the requirement is not met                        |
| **Unverified** | No evidence — including every empty Evidence cell              |
| **Blocked**    | Cannot be verified until something else is resolved            |

The packet itself carries a status in its frontmatter: `draft` (being filled) · `pass`
(every row Pass, decision is merge) · `waived` (merged with a recorded waiver) · `blocked`
(an open critical item holds the merge) ·
`needs-human` (exceptions routed, awaiting a human call). A richer result vocabulary exists
for advanced workflows — see [`reference/advanced-lifecycle.md`](reference/advanced-lifecycle.md).

## What a review is not

- **Not a PR replacement.** The packet links the PR; the PR (and your CI) remains the merge
  mechanism. The packet is the record of _what was verified against the spec_ — something a
  diff view never shows.
- **Not an AI bug-hunter.** Code-review bots flag defects in the diff; the packet routes
  human attention by requirement coverage. Use both — they don't compete.
- **Not a guarantee.** A packet full of Pass rows with real evidence is strong signal, not
  proof of correctness. That's why the spot-check rule and the exception triggers exist.

Once the decision is made, one step remains: [close the task and save what you
learned](09-saving-findings.md).
