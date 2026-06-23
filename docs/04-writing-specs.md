# Writing specs

*Works today — plain markdown plus your agent; no Corpus tooling required.*

A spec is one markdown file that answers, before any code is written: **what should the system
do, for whom, how will we know it works, and what is deliberately out of scope?** It is the
contract between whoever wants the change and whoever — or whatever — builds it: an agent should
be able to work from it without coming back with questions, and a reviewer should be able to
check the result against it row by row.

A spec is **not** a task (that's the bounded work packet cut from it — see
[Creating tasks](06-creating-tasks.md)), a design brainstorm, a change plan, a PR description,
an audit, or a bug report. It records intended behavior; how the code gets there is the
implementer's call.

## When to write one — and when not

Write a spec when behavior changes: a user-visible feature, an API or business-rule change,
anything where two people (or one person and one agent) need to agree on acceptance criteria, or
a bug that revealed missing expected behavior worth pinning down.

Skip the spec for:

- a trivial rename,
- formatting-only changes,
- a one-liner already covered by an existing requirement,
- routine housekeeping with no behavior change.

Those go straight to a small task — the [basic workflow](02-basic-workflow.md) page has the
skip-paths. The threshold is a convention — nothing in this repo enforces it — but it is not
politeness: forcing clarification onto already-clear work measurably hurts outcomes — and extending that to documents is this framework’s design judgment
[[HUMANEVALCOMM]](research/sources.md#HUMANEVALCOMM)
[[ASKORASSUME]](research/sources.md#ASKORASSUME).

**Right-size the artifact, too.** A bounded fix or polish against behavior an existing spec
already covers is a **bug report** (the kit's `advanced/bug.md`: reproduction + root cause) feeding
a fix task — not a new feature spec. Reach for a fresh spec only when the behavior itself is new
or changing.

**The one-line test: does anyone have to _agree_ on the acceptance criteria before the work
starts?** If a reviewer or a second party must sign off on *what counts as done*, write the spec —
that agreement is what a spec is for. If the ACs are self-evident and only the implementer needs
them — a small, well-understood net-new change — skip the spec and write a **thin task** that
inlines its two or three ACs with their `Verify with:` lines; the work still gets reviewed, against
the task's own ACs. The trade is deliberate: a self-attested thin task has no separate spec for
`swarm check` to reconcile its coverage against, so keep the spec the moment that coverage check
earns its keep (a wider change, an unfamiliar area, or a reviewer who wants the row-by-row table).

## The template

The format is frozen in the kit — copy
[`templates/spec.md`](https://github.com/jcosta33/swarm-starter-kit/blob/main/templates/spec.md) rather than reinventing it.
What each part is for:

- **Frontmatter** — `type: spec`, an `id` (`SPEC-<slug>`), `title`, `status` (`draft` until the
  open questions are answered, then `ready`), an `owner` (the person who answers questions
  during the work), and `sources` (the ticket or intake file this spec distills).
- **Intent** — one to three sentences: the behavior change and why.
- **Non-goals** — what this spec deliberately does not change.
- **Requirements** — one `### AC-NNN — <name>` per requirement: a single behavior sentence
  ("When X, the component must Y.") and a `Verify with:` line naming a test or command.
- **Open questions** — anything unresolved. An open question keeps the spec out of `status: ready` unless marked "(non-blocking)" (the SOL form spells the same choice as a `[blocking|non-blocking]` tag).
- **Affected areas** — the paths the work is expected to touch.
- A spec is a one-page contract — aim for ~100 lines; past that, you are usually writing
  two specs (a budget convention, not a rule).
- **Dropped from sources** — optional, recommended: what the ticket or PRD asked for that this
  spec deliberately leaves out, and why.

## Writing rules

All advisory — they make requirements checkable, and a reviewer can inspect each one, but
nothing blocks you. The full list of common mistakes to check for lives in
[`reference/checks.md`](reference/checks.md); the optional reference CLI's `swarm check` flags the
toolable ones, and the rest stay review checklist items.

1. **Give every requirement a `Verify with:` line.** It is the highest-value line in the file —
   a runnable check outperforms prose plans as task input (preliminary evidence)
   [[ORACLESWE]](research/sources.md#ORACLESWE). Naming a test that doesn't exist yet is fine;
   the review result reads Unverified until it does. A check over stochastic output (an eval
   metric, a benchmark, an LLM behavior) pins its protocol on the same line — same seed or
   fixed dataset, the metric, the threshold — or two honest runs can disagree about the same
   code. Where no command can run the check, name the method: `manual` (a recorded human
   observation — who judged, what they saw) or `monitor` (a post-merge signal); the
   [verification methods](reference/glossary.md) list the kinds.
2. **Use observable verbs.** "Returns 401", "redirects to `/login`", "writes the audit row" —
   not "handles", "supports", "manages", "improves".
3. **One behavior per requirement.** If the sentence needs an "and", it is usually two
   requirements — split them so each can pass or fail on its own.
4. **Name the actor.** "The client must…", "The API must…" — never "it should" or a passive
   "errors are logged" that leaves the doer unknown.
5. **One binding word per requirement** — must, must not, should, should not, or may — and mean it: a
   "should" hands the agent a decision; make sure that's intended.
6. **Order requirements by importance.** Agents weight earlier instructions more — put the
   requirement you would block the merge over first.
7. **Lift uncertainty into Open questions.** A hedge inside a requirement ("probably", "if
   feasible") buries a decision; a listed question gets answered before `ready`.
8. **Watch the vague words.** _Fast, robust, scalable, secure, gracefully, significant, as
   needed_ — each is fine with a same-sentence number or observable behavior, and a smell
   without one. The watchlist is advisory, never a gate.
9. **Keep Non-goals honest.** List the things a reasonable reader might assume are included but
   aren't — Non-goals are where scope disputes go to be settled cheaply.
10. **Celebrate "Dropped from sources".** Recording what you cut, and why, is where design
    rationale lives — the next person to pick up the ticket sees the decision instead of
    re-litigating it.
11. **Research the platform's limits before the ACs.** For work against an external platform —
    quota, permissions, rate limits, runtime or sandbox constraints — find the binding limits
    *first*: lift an unknown one into **Open questions** (it keeps the spec out of `ready`), bind a
    known one as a requirement with a `Verify with:` line, and record a deliberately-unhandled one
    as a **Non-goal**. Discovering a quota wall *after* the ACs are written is the expensive path.
    (Proving it works against the real platform at review is the runtime-proof rule in
    [Reviewing output](08-reviewing-output.md), per [ADR-0076](adrs/0076-worker-provenance-and-adoption-conventions.md).)

## Why this much care

These rules are not style preferences. Ambiguous or incomplete requirement text measurably
degrades agent code correctness [[ORCHID]](research/sources.md#ORCHID)
[[HUMANEVALCOMM]](research/sources.md#HUMANEVALCOMM) — and models usually code anyway instead of
asking [[HUMANEVALCOMM]](research/sources.md#HUMANEVALCOMM) [[HILBENCH]](research/sources.md#HILBENCH), so the misreading lands in the diff, not in a
clarifying question. The fix is in the text: clarifying or repairing the requirement recovers
correctness, and the repaired text transfers across models
[[SPECFIX]](research/sources.md#SPECFIX) [[CLARIFYGPT]](research/sources.md#CLARIFYGPT) —
and terse, chat-style task input costs agents a large share of their measured benchmark
performance [[SWEMUT]](research/sources.md#SWEMUT) (preliminary). Half an
hour on the spec is cheaper than a review cycle on the wrong implementation.

## When the spec changes

Amend in place. Review feedback, a discovered edge case, a change of direction — edit the
requirement, keep its ID (a renumbered AC silently breaks every task scope, review row, and
finding that references it), and record any material cut under Dropped from sources. New
behavior gets new IDs; retired requirements keep their ID with a one-line note rather than
freeing the number. There is no regeneration step and no version field — git history is the
history. A spec known to lag the code is marked `stale` on the status board until someone
amends it (see [Where files live](03-where-files-live.md)).

## Stricter notation: SOL

For high-risk work, any spec can switch its requirements to SOL — a stricter structured
requirements notation — by adding `format: sol` to the frontmatter. Same requirement, two
surfaces:

```markdown
### AC-001 — Expired refresh token redirects to login

When the refresh token is expired, the client must clear the local
session and redirect to `/login`.

Verify with: `auth-refresh-expired-token.test`
```

```text
REQ AC-001:
WHEN the refresh token is expired
THE client MUST clear the local session
AND THE client MUST redirect to `/login`
VERIFY BY test:cmdTest:auth-refresh-expired-token
```

The IDs, the binding words, and the verification line carry over one-for-one, and review reads
both forms identically — SOL just fixes the clause order and makes the binding explicit. The
notation reference is [`reference/structured-requirements.md`](reference/structured-requirements.md).

## Next

- [Creating tasks](06-creating-tasks.md) — cut the spec into bounded agent work.
- [Brownfield and change plans](05-brownfield-and-change-plans.md) — when the work is
  structural, the spec gets a companion document.
