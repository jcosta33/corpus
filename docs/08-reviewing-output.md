# Reviewing agent output

*Works today — plain markdown plus your agent; no Corpus tooling required.*

Review is the step Corpus exists for. Coding agents produce more code than anyone can read
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

## What review is for

Most of what review catches is not broken behavior. About **three-quarters of the defects found in
code review do not affect visible functionality** — they are *evolvability* defects (structure,
readability, documentation) that tests and CI are blind to
[[MANTYLA09]](research/sources.md#MANTYLA09); in modern review, defect comments are a minority while
code-improvement comments dominate [[BACCHELLI13]](research/sources.md#BACCHELLI13). So review is
**complementary to tests, not a slower substitute**: CI owns functional regressions, review owns the
maintainability and design layer no suite can see — which is exactly why a human is still required
for substantial changes. Treat evolvability findings (a confusing name, a leaky boundary, an
undocumented contract) as first-class review output, not an afterthought to "did it pass."
(Convention; [ADR-0095](adrs/0095-review-model-grounding.md).)

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

(`swarm review` drafts this packet — it reconciles the finished run against the diff and the spec
and surfaces the facts; the result is still decided by you, or a fresh agent session that did not
write the diff.)

## Review packet invariants

Every non-trivial agent run ends in a review packet before it counts as review-ready. A sound
packet holds to five invariants — a quick checklist before you trust one:

- [ ] **One row per scoped requirement.** Every requirement (and preservation guarantee) in the
  task's scope has exactly one coverage row — an in-scope id with no row can neither pass nor route
  to a human.
- [ ] **Empty evidence means Unverified, never Pass.** A Pass needs pasted output, a CI link, or a
  named human's recorded observation; a blank Evidence cell reads Unverified whatever the prose says.
- [ ] **Out-of-scope edits become Human-attention rows.** A changed file outside the task's Affected
  areas is surfaced, not merged quietly.
- [ ] **The implementer never issues its own result.** Whoever wrote the diff does not fill the
  result — a fresh agent session or a human does. Self-review yields fixes, never a result.
- [ ] **The packet is the durable record.** The PR or comment may summarize it, but the packet — not
  the PR thread — is what survives as the record of what was verified against the spec.

These are checklist-level (a reviewer inspects them) and toolable: `swarm check` flags the
mechanical ones (empty evidence, coverage, out-of-scope edits) and `swarm review` drafts the packet
and reconciles it against the diff. Nothing in this repo enforces them.

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
6. **API, DOM, or platform behavior wants proof from the real runtime.** A green unit test against
   a mock is a claim about the mock; the requirement is met only when the actual call, render, or
   permission is observed. Name the runtime the evidence came from — the live endpoint, a real
   browser, the target OS — so a Pass on integration-shaped work can't rest on a stubbed one.
7. **An agent that runs the app produces evidence, not a verdict.** Driving the live app to exercise
   a behavior is a distinct, valuable verifier — an LLM agent found 53 real bugs (35 fixed) this way
   [[GPTDROID]](research/sources.md#GPTDROID) — but agents driving live UIs are unreliable (the best
   reach ~61%, most ~30% [[WEBAGENTILLUSION]](research/sources.md#WEBAGENTILLUSION)), so an autonomous
   run never *certifies* a change. The author-agent **attaches its run** (accessibility snapshot,
   console, network) as the Evidence; an **independent reviewer re-runs the journey and judges** — the
   no-self-result rule applies to app-runs too. Prefer deterministic accessibility-tree tooling
   (Playwright-MCP style: structured data, "no vision models needed")
   [[PLAYWRIGHTMCP]](research/sources.md#PLAYWRIGHTMCP) over pixel/vision, the flakier layer.

A coverage row may also carry its evidence in a structured form: an optional fenced `verify` block, placed beside the row and keyed to the requirement id, that names the command and a pass signal — a machine-checkable form of the same evidence the free-form cell points at.

````
| AC-001 | Pass | see verify block | no |

```verify id=AC-001 cmd="npm test -- auth-refresh.spec.ts" result=pass
replays-after-refresh ✓  (1 passed, 0 failed)
```
````

The info-string is the machine-readable part — the requirement id, the named command, and a `pass`/`fail` signal; the fenced body below it is the verbatim paste, for you and the spot-check. The block is opt-in: a row may still use only the free-form cell. The form is what earns a mechanical match — a `verify` block whose `cmd` matches the requirement's named `Verify with:` command, keyed to a Pass row, carrying `result=pass`, lets a tool confirm *the row records a matching named command with a pass signal* rather than only *the cell is non-empty*. A row with only the free-form cell stays a human-attention item — matching a named command to free-form prose is imprecise [[SMELLS]](research/sources.md#SMELLS), so it is read, never machine-rejected. Either way this moves where the machine can help, not what is true: the fenced body is self-reported and unparsed, so the block does not prove the command actually ran, and a passing command does not by itself mean the requirement is met — the spot-check rule below still carries that weight. swarm-cli's `swarm review` / `swarm check` reconcile this today — core check **C013** confirms the block records a matching named command with `result=pass` and surfaces a mismatch as a consistency fact (never a review result). It is toolable, not enforced: the canon repo runs nothing, and a team's gate decides whether to act on it.

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
- integration seams — callers, schemas, events, or contracts this change touches that the task's
  own tests don't exercise (it passes in isolation, but the system it plugs into may not)
- work delegated in a **shared worktree** — if an agent sub-delegated and edits were not isolated
  to one branch/checkout, treat provenance and scope as unverified until shown otherwise
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

## Who reviews — independent, distinct-lens, and engaged

- **The reviewer is not the author.** This is the desk-checking principle, not a measured effect: if
  the author had seen the defect they would have fixed it, so an author reviewing only their own work
  is the weakest possible review [[WIEGERS95]](research/sources.md#WIEGERS95). It reinforces the
  no-self-result invariant (ADR-0056) — design rationale, not enforcement.
- **Default to two independent reviewers, each with a distinct lens; add a third for risk.** Modern
  review converged on about two reviewers, with little extra caught beyond
  [[RIGBY13]](research/sources.md#RIGBY13). Give each a distinct, skeptical aim — e.g. **correctness**,
  **maintainability + design**, **security + reproduction** — not two passes of the same read.
  Escalate to a third lens for a high-risk or high-diffusion change (the diffusion signal from
  [Brownfield & change plans](05-brownfield-and-change-plans.md)); agent reviewers are cheap, so a
  third is easy to justify.
- **Participation is the gate, not the sign-off.** A `Pass` requires evidence of *substantive
  engagement* — a finding raised, a check re-run, a reasoned result — because lax participation, not
  thin coverage, is what predicts post-release defects (up to five extra)
  [[MCINTOSH14]](research/sources.md#MCINTOSH14). An empty-evidence `Pass` already reads `Unverified`
  (the invariant above): that is the participation gate in mechanical form.

Checklist level; nothing enforces reviewer count or lens assignment ([ADR-0095](adrs/0095-review-model-grounding.md)).

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

## Scoring a delegated run — the self-report is a claim

When the work was delegated to a worker agent, the only thing it hands back about *how* it ran
is its `## Run summary` (what it says it changed, the results it cites) and the **shape of the
diff** (what actually changed). That self-report is evidence to inspect, never a trust token: a
worker can claim a green result it never produced, or boot from a stale packet and report against
the wrong scope. Score it the same way you score any claim — re-run, don't relay. A worked pass:

- **AC-001, the worker wrote `Pass` and cited `npm test -- auth.spec.ts`.** Re-run that command
  yourself in the worktree. It passes → the row is **Pass**, and *your* pasted output fills the
  Evidence cell. It fails or errors → **Fail** (or **Unverified** if you cannot run it) — the
  worker's paste proved the command ran at some past moment, not that it passes now.
- **AC-002, the worker wrote `Pass` with an empty Evidence cell.** That reads **Unverified** —
  a Pass needs evidence, and an empty cell is the absence of it (the gate blocks this: core check
  **C016**). Re-run to settle it; do not inherit the green.
- **The diff shape vs the claimed scope.** The Run summary names `src/auth/refresh.ts`; the diff
  also touched `src/billing/invoice.ts`, which the summary never mentions and the task's Affected
  areas do not cover. That mismatch is an exception trigger (a changed-not-claimed / out-of-scope
  fact) routed to Human attention — surface it even if every requirement row is green.
- **Provenance is evidence, not a pass.** If the run records *how* it was isolated (its own
  worktree vs a shared checkout) and what it loaded, read it to judge attribution — a shared
  worktree where edits were not isolated to one branch means treat scope and provenance as
  unverified until shown otherwise. A worker's "I followed the discipline" is a claim like any
  other; the diff and your re-run are the evidence.

The rule underneath: a delegated run gives you a richer *claim* to check, never a result you can
copy. You produce the verdict from your own re-run and your read of the diff — the worker's
summary points your attention, it does not score the work.

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

These five are the whole set — don't invent new ones. "Implemented and committed, but human or
runtime validation is still pending" is **not** a new status: it is this packet `needs-human`
with the task at `review-ready` on the board. At closeout, confirm the board row **and** the task
packet's own `status:` move together (a worker that boots from a stale packet inherits stale
state).

## When review sends work back

A `Fail`, an unresolved `Blocked`, or a `needs-human` call does not reopen the spec or grow the
current packet — it starts another turn of the loop. Cut a **bounded follow-up task** scoped to
exactly the rows that didn't pass (plus any out-of-scope edits to revert), point it at the same
spec, and run it like any other task. Because the requirement IDs are stable, the next review
packet reconciles against the same IDs — you can see at a glance which previously-failing rows now
pass. The board row moves back to `ready` (or stays `blocked` while a human question is open) and
forward again through `running` → `review-ready`; the spec stays the fixed contract the whole way.

Keep rework as bounded as the first attempt. A follow-up that keeps growing is a sign the spec was
underspecified — amend the spec, don't let the task sprawl to cover what the contract should have said.

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
