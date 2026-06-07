---
type: audit
id: sim-bugfix-audit
status: draft
created: 2026-06-07
updated: 2026-06-07
---

# Audit: the bug-fix and audit-remediation developer journeys

> Observation-only. This audit records present-state risk in the two developer journeys as the
> shipped framework documents them today; it authors no obligation blocks and prescribes no fix.
> Each observation cites `file:line`; severity is by blast radius, not discovery order.

## Scope

**In scope.** The two journeys a reviewer must trust, as documented:

- (a) bug surfaces → `bug-report.md` (diagnosis-only) → promotes into a `task_kind: fix` task →
  `write-fix` implement → `verify` → `review`/merge gate.
- (b) developer audits a code area → `audit.md` (observation-only) → promote recommended obligations
  into a `spec.swarm.md` → `task_kind: refactor` implement.

Files read end-to-end: `docs/artifacts/{bug-report,audit,finding}.md`;
`docs/passes/{author,implement,promote,review}.md`; `docs/model/source-authority.md`;
`starter-kit/.agents/skills/{write-bug-report,write-audit}/SKILL.md` + their `references/task-template.md`;
`docs/library/code-skills/{write-fix,write-refactor,fix-flaky-test}/SKILL.md`;
`docs/library/code-skills/write-fix/references/task-template.md`; ADRs 0001/0006/0007;
`docs/passes/decompose.md` (COVERAGE gate); `docs/artifacts/task.md` (task_kind routing).

**Out of scope.** Whether the documents are internally readable as prose; the SOL grammar itself; the
non-code journeys (PRD/RFC/research → spec); any change to source files (this is observation-only). No
behavioural claim about a runtime is made — Swarm ships none, which is itself the root of several
observations below.

## Observations

### O1 — the bug-report → fix-task hop has no owning step and no documented hand-off mechanism (BLOCKER)

Every other parent in the `author` table promotes **into a `spec.swarm.md`** and the `author` step's
declared output is exactly that single artifact (`docs/passes/author.md:17`, table row
`bug-report.md … a fix task (implement)` at `:46`). But the bug-report alone promotes into a *fix task*,
**bypassing the spec**. No step owns this transform: `author` produces a spec, `decompose`
(`docs/passes/decompose.md:253`) is the only step that emits `task.md` packets and it partitions a
**lowered spec**'s obligation nodes — there is no spec here. `write-fix` (`write-fix/SKILL.md:62-73`)
*consumes* a `task.md` that already carries `assigned_obligations`, `write_surfaces`, and
`verification_bindings`; it never explains who authored that packet. The evidence: searching the pass
guides for the hand-off returns only the assertion *that* it happens (`docs/passes/author.md:46,59`;
`docs/passes/promote.md:90`), never *how* the frame is constructed. A reviewer watching journey (a) will
find a hole exactly where the diagnosis becomes work.

### O2 — a fix task's `assigned_obligations` are undefined when the bug-report records a coverage gap (BLOCKER)

A bug-report's `## Affected obligations` references an **existing** obligation by id, *or* states that
**none** covers the broken behaviour and records that as "a finding the promoted fix task must reconcile"
(`docs/artifacts/bug-report.md:59`; `write-bug-report/SKILL.md:117-124`; template
`write-bug-report/references/task-template.md:144-153`). The fix-task template then demands the fixer
"Paste the assigned SOL blocks verbatim … Use their IDs as scope"
(`write-fix/references/task-template.md:63-66`). When the bug exposed a *gap*, there is **no obligation to
paste** — yet `write-fix` repeatedly scopes the entire task to "the assigned obligation(s)" (rules at
`write-fix/SKILL.md:92-105`) and the merge gate (O3) needs an obligation to gate against. The word
"reconcile" (`docs/artifacts/bug-report.md:59`) is never operationalized: nothing says the fixer must
first author the missing obligation into a spec (an `author`/`improve` amendment, an approval-required
change per `source-authority.md:154`) before the fix can be scoped. A developer here is mis-routed:
either they smuggle a new obligation in at `implement` (forbidden, `write-fix/SKILL.md:103-105`), or they
fix with no obligation and produce an unverifiable, un-gateable change.

### O3 — the merge gate is vacuous for a fix that has no in-scope obligation (BLOCKER)

The merge gate is "evaluated over every **required** obligation … in scope"
(`docs/passes/review.md:50-52`). If journey (a) lands a fix task with zero assigned obligations (the O2
gap), the universally-quantified predicate over an empty set is **trivially true** — the change set
"MAY be promoted" with no proof of anything. The regression-test discipline in `write-fix`
(`write-fix/SKILL.md:133-146`) is *guide-level* SOFT control (`write-fix/SKILL.md:21-29`), explicitly not
a validity gate, and there is NO RUNTIME to demand it. So the strongest correctness signal in the whole
bug-fix journey — red-before/green-after — is unenforceable, and the gate that should catch its absence
sees nothing to evaluate.

### O4 — diagnosis-only / observation-only stances are entirely unenforceable (NO RUNTIME) (MAJOR)

Both stances are held "by … discipline" with the explicit disclaimer "Nothing enforces this stance at
runtime" and "A conformant repository MUST NOT ship a tool whose job is to police artifact composition"
(`docs/artifacts/audit.md:15`; `docs/artifacts/bug-report.md:17`; reinforced at
`docs/passes/author.md:64-66`). The only stated guards are the distillation-loss budget and source
authority — neither of which inspects *content*: a bug-report that prescribes a patch, or an `audit.md`
that contains a `REQ` block, is a well-formed markdown file that no documented check rejects. The
`SOL-S013` non-printing-character check (`docs/passes/review.md:90`) is lexical, not semantic. The stance
boundary therefore lives **only** in the author's self-review checkbox (`write-bug-report/SKILL.md:191`;
`write-audit/SKILL.md:231-232`) — an agent grading its own composition, the precise self-preference hazard
`review.md:71` documents for judges. A reviewer cannot assume the stance held; they must re-read for it by
hand on every artifact.

### O5 — an `audit.md` that prescribes is the single most likely stance violation, and the line is fuzzy by design (MAJOR)

The audit contract permits "Recommending *candidate obligations a future spec should carry* — in plain
prose" while forbidding "prescribe a fix inline" (`docs/artifacts/audit.md:12`; `audit.md:60`
`## Recommended obligations`). The distinction between "the spec SHOULD require X" (permitted) and "we
should do X" (forbidden, `write-audit/SKILL.md:193`) is a prose-judgment with no mechanical test. The
`write-audit` guide itself spends rules 8 and the anti-patterns (`write-audit/SKILL.md:151-157,205-206`)
trying to hold a line it admits is soft. In journey (b), the `## Recommended obligations` prose is the
*only* thing carried forward into the spec's SOL blocks at the next `author` step — so a prescriptive
slip here is laundered directly into binding intent with no second checkpoint.

### O6 — promotion drops/distorts intent across two stance changes with no traceability artifact (MAJOR)

Journey (b) is audit (observation) → spec (intent) → task (execution). The audit's
`## Recommended obligations` are prose; the `author` step "emits the blocks on promotion"
(`docs/artifacts/audit.md:60`). There is **no required back-link** from a spec obligation to the audit
prose that seeded it, and no documented check that every recommended obligation actually became a SOL
block — the distillation-loss budget guards *dropping during structuring*
(`docs/passes/decompose.md:277`), but the audit→spec `author` hop is **upstream of `lint`** and therefore
"not itself analyzable" (`docs/passes/author.md:26-27`). So an audit's recommended obligation can be
silently lost or reworded into different intent at the one step that is, by the framework's own statement,
outside analysis. Symmetrically in journey (a), the bug-report's referenced obligation id and its
"coverage gap" note can be dropped when the fix task is hand-authored (O1/O2) with nothing tracing the
loss.

### O7 — `RISK`/high-oversight-band escalation is invisible to both journeys until late (MAJOR)

The high-oversight band (named-human REVIEW binding; no agent-self-issued verdict/waiver) keys off an
obligation carrying `RISK critical` or a `WRITES` set tagged `integration`/`shared`
(`docs/model/source-authority.md:124-144`). But a bug-report authors no obligations (`bug-report.md:14`)
and an audit authors none (`audit.md:11`) — so **band membership cannot be known** until an obligation
exists, i.e. after the spec/fix-task is authored. A developer in journey (a) fixing a defect on a
shared/irreversible surface (a destructive migration callsite, say) gets no signal at the bug-report or
fix-task-framing stage that a named human is owed; it surfaces — if at all — only when `review` re-derives
it from the obligation, by hand, with no runtime. For the highest-stakes fixes this is exactly backwards.

### O8 — "fix vs flaky-fix vs refactor vs rewrite" routing rests on the author's self-classification (MAJOR)

Both `task_kind: fix` and `fix-flaky-test` share `task_kind: fix` (`fix-flaky-test/SKILL.md:5-6`;
`write-fix/SKILL.md:5-6`) and are disambiguated only by prose ("Flaky? … this is the wrong template",
`write-fix/references/task-template.md:29-31`). Likewise a refactor that moves behaviour "is no longer a
refactor — it is a `rewrite` or a `migration`; relabel" (`write-refactor/SKILL.md:24-31,28`). Every one of
these forks is a human/agent decision with NO RUNTIME and no gate; a mis-route (a flake treated as a
deterministic fix, a behaviour-changing edit run under `refactor`) produces a green-looking, gate-passing
change that ships the very failure mode the discipline exists to prevent (`write-refactor/SKILL.md:90-103`
warns that "adapting a test to a new result is how a rewrite disguises itself as a refactor").

### O9 — `deepen-audit` re-derivation collides with the "immutable record" rule (MINOR)

`promote.md:40` states an `audit.md` is an "Immutable record of an observation at a point in time," and
`audit.md:33` says a retired audit is "marked resolved … not silently deleted." Yet `deepen-audit`
(a `task_kind`, `write-audit/SKILL.md:5-7`) instructs the author to "Read the prior audit with its framing
**closed** — re-derive every finding from the code" (`write-audit/SKILL.md:52-53,106-111`). It is left
unstated whether deepening *edits the prior audit in place* (violating immutability) or *writes a new
audit superseding it* (the finding/ADR supersession pattern, `promote.md:115`). A reviewer cannot tell
which artifact is now authoritative after a deepen pass. Blast radius is contained to audit bookkeeping,
hence MINOR — but it is a real ambiguity in journey (b)'s iteration.

### O10 — the dev-repo `.agents/audits/` referenced by CLAUDE.md is empty (MINOR)

`CLAUDE.md` Pointers lists "Dev audits: `.agents/audits/`" and the Universal-rules section references
`.agents/audits/`. The directory is empty (`ls .agents/audits/` returns nothing before this file). A
reviewer following the documented pointer to prior dev audits finds none — a stale-pointer / missing-corpus
observation. (This file is the first instance.)

## Risks

- **R1 (fires when journey (a) is run on a gap-bug).** A defect whose broken behaviour no existing
  obligation covers (O2) reaches a fixer who, lacking a documented reconcile step, patches the symptom
  with no obligation and no gate (O3). Firing condition: any bug-report whose `## Affected obligations`
  records "no obligation covers this." Likelihood is high — uncovered behaviour is a common bug class.
- **R2 (fires under stance-laundering).** An `audit.md` slips a prescription into
  `## Recommended obligations` (O5); the next `author` step transcribes it verbatim into a SOL obligation
  (O6); the prescription is now binding intent that no checkpoint flagged. Fires whenever the audit author
  and the promoting author are the same agent in one session (the common case).
- **R3 (fires on a shared/irreversible-surface fix).** A fix on an `integration`/`shared` surface (O7)
  proceeds to a merge gate that an agent self-verifies, because the band that would demand a named human
  was never computed (no obligation existed upstream to carry the tag). Fires on any destructive-migration
  or shared-state defect routed through the bug-report journey.
- **R4 (fires on mis-classification).** A flaky failure is filed as a deterministic `fix` (O8); the fixer
  loops-to-green or widens an assertion, records a `passed` proof_result, and the gate — having no runtime
  and no obligation forbidding it — admits it. Fires whenever the failure's non-determinism is not obvious
  at triage.
- **R5 (fires across a promotion chain edit).** A `deepen-audit` pass edits the prior audit in place (O9),
  and a downstream reader cites a finding that the deepen pass silently changed, breaking the audit-trail
  immutability the framework asserts elsewhere (`promote.md:40`). Fires whenever an audit is deepened
  rather than superseded.

## Recommended obligations

(Prose only — candidate intent a future spec/ADR author would carry; not authored as SOL here.)

- The framework SHOULD name the step (or extend `author`/`decompose`) that constructs a fix `task.md`
  from a bug-report and SHOULD state how its `assigned_obligations`, `write_surfaces`, and
  `verification_bindings` are derived — closing O1.
- It SHOULD make "reconcile the coverage gap" a concrete, ordered precondition: when a bug-report records
  *no covering obligation*, the missing obligation MUST be authored into a spec (an approval-required
  amendment) before the fix is scoped — closing O2/O3.
- It SHOULD require a traceability link from each promoted spec obligation back to the audit
  `## Recommended obligations` prose (or bug-report obligation id) it came from, and a check that the
  promotion set is total — closing O6.
- It SHOULD specify whether `deepen-audit` supersedes (new file) or amends (in-place), to resolve the
  immutability collision — closing O9.
- It SHOULD address how high-oversight-band membership is surfaced *before* an obligation exists for
  surface-tagged or destructive bug fixes — closing O7.

## Critical watch-outs for a reviewer (ranked)

1. **The bug-report → fix-task hop is undefined (O1+O2+O3, BLOCKER).** This is the load-bearing seam of
   journey (a) and it is missing. Watch for: a fix task whose `## Assigned obligations` is empty or
   hand-invented; a "coverage gap" bug-report with no spec amendment preceding the fix; a merge gate that
   passed over zero obligations. Any of these means the bug was "fixed" with no contract and no real gate.
2. **Stance boundaries are author-self-policed only (O4+O5, MAJOR).** NO RUNTIME inspects content. Re-read
   every `audit.md` for an obligation block or an inline prescription, and every `bug-report.md` for a
   prescribed patch, by hand — the self-review checkbox is not evidence the stance held. Watch
   `## Recommended obligations` prose most closely; it is laundered straight into binding intent.
3. **High-stakes fixes escape the oversight band until too late (O7+R3, MAJOR).** For any fix touching a
   shared/integration/irreversible surface, confirm a named human is on the verdict — the band that should
   demand it cannot be computed from a bug-report or audit, so it is easy to skip.
4. **task_kind mis-routing ships the exact failure each discipline guards (O8+R4, MAJOR).** Independently
   re-classify: is the failing test deterministic or flaky? did the "refactor" move any observable
   behaviour? A wrong fork produces a green, gate-passing change carrying the masked defect.
5. **Promotion can silently drop or reword intent at an un-analyzable step (O6+R2/R5, MAJOR).** The
   audit→spec `author` hop is upstream of `lint` and outside analysis by the framework's own statement;
   check that every recommended obligation actually became a SOL block and that no `deepen-audit` edited a
   prior audit in place.
