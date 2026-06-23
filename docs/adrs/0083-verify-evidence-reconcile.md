---
type: adr
id: adr-0083
status: accepted
created: 2026-06-18
updated: 2026-06-18
---

# ADR-0083 — The structured-evidence format: binding a requirement's named Verify command to its recorded result

## Context

A single requirement's verification crosses three artifacts. The named command is declared on the
spec's `Verify with:` line (plain form) or `VERIFY BY` binding (SOL); the implementer runs it and
pastes the output under the task packet's `## Verify` items; the reviewer transcribes or cites that
into the review packet's `## Requirement coverage` Evidence cell. What threads the three is the
requirement id (stable, spec-scoped per ADR-0080) plus human transcription — never a mechanical
join. The Evidence cell is a free-form string.

What `corpus review` reconciles today is coverage (C012: in-scope ids covered, no orphan rows) plus
a set of structural facts — among them the one mechanical evidence fact that exists: a `Pass` row
with an empty Evidence cell reads Unverified. That fact is binary presence — _is the cell
non-empty?_ — never _does this cell's content correspond to the requirement's named Verify command,
and does it record a pass?_ The named command is captured as a discrete field nowhere: the spec
requirement record is `{ id, line, body }` with the command buried in `body`; the coverage row is
`{ id, result, evidence }` with the cell a raw string. Nothing extracts the command from the spec,
nothing extracts a command or pass signal from the cell, and nothing joins the two.

So the chain confirms a requirement _has_ a Verify reference (C003) and that its Pass row _has_ some
non-empty evidence — but never that _the recorded evidence names the requirement's own command and a
pass_. That missing join is the design question this ADR decides: can "the requirement's named
`Verify with:` command actually ran and passed, as shown in the evidence" be checked mechanically?

The honest answer is two-tiered. Matching a named command to a free-form prose cell is fuzzy —
lightweight requirement-/prose-smell detection sits at roughly 48–59% precision in field studies
[[SMELLS]](../research/sources.md#SMELLS) — so a free-form match can only ever be a warning routed
to human attention, never a hard error (the SMELLS-precision rule already governing the writing-rules
watchlist in [checks.md](../reference/checks.md)). A hard match is buildable only against a _defined
grammar_: a structured-evidence block keyed to the requirement id, naming the command, carrying a
closed-value pass signal. This is the same form/precision split [structured
requirements](../reference/structured-requirements.md) §4 already draws on the _spec_ side — a plain
`Verify with:` is an unresolved note the reviewer chases; a SOL `VERIFY BY` is a resolved binding. We
need the symmetric move on the _evidence_ side.

This ADR freezes that format and the canon prose only. It mints no check and bumps no contract.

## Decision

**Freeze a structured-evidence format: an optional fenced `verify` block, keyed to the requirement
id, that records the named command and a closed-value pass signal beside the free-form Evidence
cell.** The block is a sibling to the coverage row, not a cell value — a GFM cell cannot hold pipes,
newlines, or fences without breaking the row. The free-form Evidence cell is unchanged; the block is
the resolved binding the cell points at.

The shape (one block per opted-in row):

````
| AC-001 | Pass | see verify block | no |

```verify id=AC-001 cmd="npm test -- auth-refresh.spec.ts" result=pass
replays-after-refresh ✓  (1 passed, 0 failed)
```
````

- **Keyed to the requirement id.** The `id=AC-NNN` token keys the block to its coverage row,
  resolved within the review packet's single named source spec — never workspace-global (ADR-0080).
  This is the only join that already threads spec → task → review.
- **Command named.** `cmd="…"` carries the named command verbatim, so a parser can compare it
  (exact string after trimming/whitespace-collapse — a closed-value match, not prose matching)
  against the spec requirement's named command — the `Verify with:` reference, or the SOL `VERIFY BY`
  artifact.
- **Pass signal closed-value.** `result=pass` (enum `pass | fail`) is the one token a parser matches
  exactly to confirm the block records a pass for the named command. This closed-value signal exists
  nowhere today.
- **The fenced body is unparsed.** The verbatim pasted output below the info-string is for the human
  and the spot-check; it is never parsed for a pass/fail verdict — doing so would re-enter the fuzzy
  band. The body is also self-reported by the implementing session, so it is not external proof the
  command ran. Keeping the machine-read signal in the closed-value info-string and the human-read
  proof in the free-form body is exactly what separates the hard half from the warning half.

**The fact the check surfaces, stated honestly.** Because the body is unparsed and self-reported, the
only machine-read signal is the closed-value info-string. So the fact a checker can surface is a
**consistency fact**: _the structured-evidence block records a `result=pass` for the requirement's
named Verify command, and the recorded `cmd` matches the spec's named command_ — i.e. the named
command is _recorded_ as having run and passed. Whether it actually executed with that output stays a
human spot-check.

**The severity split (the rule the format earns).** A hard match is _makeable_ — but only on a
narrow, fully closed-value reconcile, three exact-match facts and no prose interpretation: (1) a
`verify` block exists keyed to a Pass row's id; (2) its `cmd=` matches (normalized) the spec
requirement's named command; (3) its `result=` token equals `pass`. A structured mismatch — a block
whose `cmd` disagrees with the spec's named command, a `result=fail` recorded under a Pass row, or a
malformed/duplicate block — is the kind of objective corruption the format **makes hard-checkable**.
This mismatch is the same fact-class the verdict-free reconcile already surfaces today as
`statusPassContradicted` / `badResultCells` (a packet `status: pass` or a coverage Result contradicted
by another recorded field): surfacing or rejecting a `cmd`/`result` contradiction is an
**internal-consistency fact** — the recorded signal disagrees with the recorded Result — **not** the
tool concluding the row should read Unverified or Fail. The human still owns the result (ADR-0077
Decision 8). **A Pass row that omits the `verify` block and uses only the free-form cell stays a
warning** routed to human attention: that is the fuzzy command-in-prose match the SMELLS-precision
band keeps advisory, never machine-rejected. The split is structural: the structured form present → a
hard-checkable consistency fact is available; absent → the existing free-form warning, unchanged.

**Scope-guarded and shipped conservatively.** The hard match binds only where the source spec is
non-draft — a draft's ids and commands are work-in-progress (ADR-0079's non-draft guard, mirroring
C002's draft exemption and C007's ready gate). And per ADR-0079's "a never-field-tested check ships
conservative" precedent, the _hard-error_ severity is a frozen **capability** of the format, not the
day-one behavior: the W4 mint ships the structured-form mismatch at **warning** first, with a recorded
path for a future ADR to promote it to hard error once the format is field-tested. The W2 freeze is
"the hard match is buildable against this grammar"; "hard error on day one" is not claimed.

**Reconcile-only, restated (ADR-0077 Decision 8).** The check surfaces a _fact_ — the consistency
fact above — on the verdict-free review report. It never sets the review result (Pass / Fail /
Unverified / Blocked), never sets a packet `status: pass`, never computes a merge decision. The human
owns the result; an empty Evidence cell still reads Unverified.

**This moves the form/truth boundary; it does not dissolve it.** The format moves the mechanical
question from _is the Evidence cell non-empty?_ (today's binary presence) to _does the recorded
evidence name the requirement's own command and a pass?_ — a strictly stronger form fact. It does
**not** answer _did the command truly run with that output?_ (the body is unparsed and self-reported)
nor _does passing that command mean the requirement is truly met?_ Two gaps stay human: the
self-reported body carries the fabrication risk that prompt-only done-claims are prone to (small-N,
preliminary) [[EVIBOUND]](../research/sources.md#EVIBOUND), so the spot-check convention (a reviewer
re-runs one green row's evidence by hand) carries the anti-rubber-stamp load — evaluators measurably
favor their own generations [[SELFPREFER]](../research/sources.md#SELFPREFER) and carry predictable
judgment biases [[JUDGEBIAS]](../research/sources.md#JUDGEBIAS); and whether the named command covers
the right behavior, the edge cases, and the real runtime stays a human judgment. The check confirms
internal consistency (named command ↔ recorded pass ↔ keyed row), not external ground truth.

**Honesty level: toolable, in prose, at most.** A future `corpus review` / `corpus check` should
confirm the structured-evidence block records a matching named command with a `result=pass`; until
then it is a review checklist item. Nothing in the repository runs, so nothing is **enforced** —
enforcement requires a shipped tool wired to a gate, and that gate is the adopting team's CI or the
agent CLI's hook runtime, never corpus-cli.

**The check is a new code, C013 — not a strengthening of C012.** C012 (`coverage`) answers one
question: does every in-scope id have a row, and does every row name a real spec id? — an id-set
reconcile against the source spec. The structured-evidence check answers a different question against
a different field: does a block keyed to the requirement record a matching named command and a pass
signal? Folding the second into C012 would blur two facts a reviewer cites separately, and C012's
warning severity (a coverage gap is review _incompleteness_, not corruption) does not fit the new
check's structural two-tier severity. A clean code keeps the cite clarity ("C013 on AC-003") and lets
the severity split live on its own row.

## Alternatives considered

| Alternative                                                                                                                             | Why weaker                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            |
| --------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Hard-match the free-form Evidence cell directly** (parse the existing prose cell for the command and a pass token)                    | Fails the SMELLS-precision bar — a command-in-prose match sits at ~48–59% precision [[SMELLS]] and would false-block real evidence. The free-form cell must stay a warning. Rejected.                                                                                                                                                                                                                                                                                                                                                                                 |
| **The check issues a Pass/Fail verdict** on whether the named command passed                                                            | Violates ADR-0077 Decision 8 and ADR-0063 — the harness routes a fact (a consistency fact), it never adjudicates the review result. Rejected.                                                                                                                                                                                                                                                                                                                                                                                                                         |
| **Defer the format entirely; leave all evidence free-form and warning-only**                                                            | Forgoes the only mechanically defensible tightening of the evidence wedge — the structured form is the one path that moves the boundary at all. Rejected.                                                                                                                                                                                                                                                                                                                                                                                                             |
| **The task `## Verify` section as the structured home** (a `verify` fence per Verify item in the task packet)                           | The block would live in the task packet, which `corpus review` does not parse today (it parses the review packet, keyed by id), adding parse surface beyond the existing coverage-row machinery; and a hard match would key on the _implementer's own_ fence, brushing the independence rule. The review-packet sibling block reuses the id-keyed coverage-row parser and keeps the structured fact beside the row it backs. Rejected as the _home_ (see Propagation for the narrow W4 token-carry the task may still hold).                                          |
| **A full machine run-record now** (a fenced `{id, cmd, exit, ref}` projection the agent emits with the work order, parsed for `exit=0`) | Structurally the strongest — a discrete `cmd` and a closed `exit` integer. But it presumes the W4 parse work (lift the spec command into a field; a new run-record parser; a three-way id join) and a runner/wrapper that emits it, which is the W4 build, not a W2 format freeze. Adopting the run record _now_ would smuggle the implementation into the format decision. The keyed `verify` block degrades gracefully to today's free-form warning and is tool-draftable to the same record in W4. Deferred to W4 as the richer source; rejected as the W2 freeze. |
| **Strengthen C012 to also carry the evidence-binding fact**                                                                             | Conflates coverage (id-set reconcile) with evidence binding (a block records a matching command + a pass) — two facts a reviewer cites separately — and forces one severity onto two different defect classes. Rejected in favor of minting C013.                                                                                                                                                                                                                                                                                                                     |

## Consequences

Accepted as the frozen format; the structured-evidence block is canon prose now. This MOVES the
form/truth boundary (a hard-checkable consistency fact on _does the recorded evidence name the
requirement's own command and a pass?_) without dissolving it (_did the command truly run?_ and _is
the requirement truly met?_ stay human), and tops out at toolable — never enforced.

Positive: the evidence wedge gains its first mechanically defensible tightening; the format is
opt-in (zero forced ceremony, a row may still use only the free-form cell and stay a warning) and
tool-draftable to near-zero added human cost in W4. Negative: a second evidence form to teach and a
new parse path to build. Neutral: a team may treat the structured-form warning as blocking by its own
CI policy — that is the team's gate, not Corpus's.

**Single-sourcing: the format and the rule land in canon — [docs/08-reviewing-output.md](../08-reviewing-output.md),
[reference/structured-requirements.md](../reference/structured-requirements.md),
[reference/checks.md](../reference/checks.md), and this ADR — first. Everything below derives, and is
FUTURE (the W4 deliverable), not done by this ADR.** W2 writes no `checks.yaml`, mints no check code,
bumps no contract version, and ships no fixtures or implementation. There is no "staged held bump"
state between W2 and W4.

## Propagation

The following derive from this ADR and the canon prose, landing **coordinated in W4** — recorded
here as future, per ADR-0079's "the contract edit ships with the implementation, not as a standalone
canon commit that would red the gate in between" precedent:

- **The C-id mint — C013.** A new `C013` core-check row in `checks.yaml` and its definition in
  `reference/checks.md` (the structured-evidence binding check), with its two-tier severity (warning
  on the absent/free-form case; the structured-form mismatch shipped conservative at warning, a future
  ADR may promote to hard error with field evidence) and its non-draft scope guard. The closed-set
  counts in `checks/README.md` and the cheatsheet appendix move accordingly.
- **The contract version bump — `0.5.0 → 0.6.0`** in `checks.yaml`, moved in lockstep with
  corpus-cli's pinned `CONTRACT_VERSION` so the drift-guard test never reds in between.
- **Kit template derivations.** `templates/review.md` gains the optional `verify` block beside the
  Evidence cell (with the info-string grammar in a comment); `templates/task.md` may optionally emit
  the same `result=pass` token under `## Verify` / `## Run summary` so a future review draft copies it
  rather than re-derives; `templates/spec.md` is unchanged in shape — its `Verify with:` line becomes
  the parse target the W4 spec-side command lift reads.
- **The corpus-cli build.** `parseReviewPacket` gains a fenced-`verify`-block scanner (none exists
  today; the parser reads pipe rows only); `parseSpecRecord` lifts the `Verify with:` / `VERIFY BY`
  command into a discrete field (today it is undifferentiated inside `body`); `reconcileReview`
  surfaces the new consistency fact on the verdict-free report. Fixtures add a `verify`-block review
  case plus a surface-equivalence pair (clean block, mismatched `cmd`, `result=fail` under Pass, and a
  free-form-only row that stays a warning).

Refines ADR-0079 (the same coordinated-landing and conservative-shipping pattern) and ADR-0072/0076
(the run record + paste are the substrate the structured block projects). Does not re-open the
spec-scoped-id question (closed by ADR-0080).
