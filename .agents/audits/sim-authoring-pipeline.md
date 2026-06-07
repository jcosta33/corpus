---
type: audit
id: sim-authoring-pipeline
status: draft
created: 2026-06-07
updated: 2026-06-07
---

# Simulated journey: authoring the first feature spec through the full 9-step pipeline by hand

## Scope

A skeptic walk-through of the producer journey a *consuming* developer would take: write a
`spec.swarm.md` from a rough idea (write-spec), then run it through `lint → improve → lower →
decompose → implement → verify → review → promote` **by hand, with no runtime** (Invariant 1). The
question this audit answers is not "is the spec format coherent on paper" — it largely is — but
"where does a human/agent actually get *stuck*, produce something the next step cannot consume, or
hit a contract that disagrees with the guide they are told to follow."

Read for this simulation: `docs/passes/{author,lint,improve,lower,decompose,implement,verify,
review,promote}.md`; `docs/language/SOL.md`; `docs/artifacts/spec.md`; `docs/reference/
structured-form.md`; the `write-spec`, `pass-lint-spec`, `pass-lower-spec` skills and the
`spec.swarm.md` template under `starter-kit/`; plus `docs/language/errors.md` and the conformance
fixtures. Observation-only; no fixes prescribed; no source edited.

## Observations

### O-1 (MAJOR) — `SOL-M001` has two contradictory definitions across the canonical docs

`docs/language/SOL.md:122` and `:455` define `SOL-M001` as **"cross-spec id collision"**
(intra-spec duplicate is `SOL-S004`). `docs/passes/lint.md:113` and `docs/language/errors.md:181`
define `SOL-M001` as **"actor/object incompleteness"** (a modal with no resolvable actor *and*
object). `errors.md:181` tries to paper over it ("…*also* catches cross-spec id collision"), but
the two principal-code tables a by-hand linter consults give the same code a different primary
meaning. CLAUDE.md states the shipped cards are *derived* from `docs/`, single-sourced — yet here
the two `docs/` pages themselves disagree. A linter (human or future tool) keying on `SOL-M001`
cannot know which defect class it names; the `improve`-op routing differs too (`errors.md:237`
routes `SOL-M001`→`CONCRETIZE`, sensible for actor-incompleteness, wrong for an id collision).
Evidence: `SOL.md:122,455` vs `lint.md:113` vs `errors.md:181,237`.

### O-2 (MAJOR) — `lower` mandates a `content_hash` on every node, but nothing tells a human how to produce one without a runtime

`docs/lower.md:127` and `structured-form.md:132,302` make `source.content_hash` (e.g. `sha256:…`)
a **MUST** on every lowered node, and the drift/staleness model and every `STALE` verdict join
against it. The `pass-lower-spec` skill repeats the requirement (`SKILL.md:45,58`) but gives no
procedure. With NO RUNTIME, the `lower` carrier is a human/agent who must hand-emit a SHA-256 of a
line span into JSON — an operation no human does reliably and an LLM cannot do at all (it cannot
compute a real digest). The result: either the field is faked (a plausible-looking but wrong hash,
which silently poisons every downstream staleness check) or omitted (a distillation/validity
defect). This is the single most "impossible to execute by hand" step in the pipeline, and the docs
present it as a routine field. Evidence: `lower.md:127`, `structured-form.md:132,302,404`.

### O-3 (MAJOR) — the whole `lower` step asks a human to hand-author a large, schema-exact JSON graph

`lower` (`docs/lower.md`) requires, by hand: namespaced node ids, the full `nodes[]` record per
block (every `clauses{}` slot present-or-null, `verify_by[]` normalized to `{type,adapter,ref,
selector,gate}`, `reads/writes/touches`, `status`, `lifecycle`, source span + hash), `edges[]` as
the *single* relationship store with `conflicts_with`/`affects` **derived** from scope-set overlap
under a POSIX glob-language lattice (`decompose.md:218`), plus two derived graphs. `structured-form.md`
fixes `additionalProperties:false` and "unknown top-level keys MUST be rejected." A human producing
this for a non-trivial spec is doing a compiler's job with no compiler and no validator to catch a
slip. The `.swarm.ir.json` is then the input the rest of the pipeline reasons over, so any
hand-error propagates silently. Severity MAJOR not BLOCKER only because the framework explicitly
frames the structured form as "the contract a future tool emits" — but the 9-step *by-hand* journey
the simulation models still requires it as a gate before `decompose`. Evidence: `lower.md:89-196`,
`structured-form.md:14-35,216-365`, `decompose.md:214-223`.

### O-4 (MAJOR) — the starter-kit ships no copyable `task.md` (decompose output) or `trace.md` (implement output) template

`decompose` produces `task.md` work packets with **8 mandatory body sections** (`implement.md:84-96`)
and `implement` produces a `trace.md` with **6 mandatory sections** including 7 per-binding G11
provenance fields (`implement.md:101-110`). But `starter-kit/.agents/templates/` ships only spec /
audit / research / bug-report / prd / rfc / review / adr / finding / threat-model skeletons — **no
`task.md`, no `trace.md`.** The only `task*.md` files in the kit are author-side *working-memory*
templates buried inside the `write-*` skills (`write-spec/references/task-template.md`), which are a
different artifact (the spec-authoring scratchpad, gitignored and discarded), not the
decompose-emitted work packet. A developer reaching `decompose`/`implement` has a contract with no
skeleton to fill. (A producer-side `docs/library/code-skills/templates/task.md` exists, but it is
not in the adopted kit.) Evidence: `ls starter-kit/.agents/templates/` (no task/trace);
`implement.md:73-110`; templates only under `write-*/references/`.

### O-5 (MINOR→MAJOR) — the shipped spec template seeds a live `[blocking]` QUESTION that halts the pipeline if left in

`starter-kit/.agents/templates/spec.swarm.md:101-103` ships the literal skeleton
`QUESTION Q-001 [blocking]:`. The author copies the skeleton and fills placeholders. If the author
does not affirmatively delete or downgrade it, the spec carries an unresolved `[blocking]` QUESTION,
which the CLARIFY gate (`lint.md:164`, `lower.md:66`) treats as **not lowerable** (`SOL-O003`) — the
pipeline stops at `lower`. The template thus defaults to the worst-case gate state, and the only
guard is the author remembering write-spec rule 5 (`write-spec/SKILL.md:86`). A starter template
should default to the *passing* state (no blocking question, or a `[non-blocking]` example).
Evidence: `spec.swarm.md` template `:99-103`; gate at `lint.md:164`.

### O-6 (MAJOR) — `improve` is told to be "strictly semantics-preserving" while routinely changing what the obligation says

`improve` is gated by R-IMPROVE: an operation MUST NOT "add, remove, weaken, strengthen, or
otherwise change the intent of any obligation" (`improve.md:28`), and only category-12 "pure
normalization" is auto-approved; categories 1–11 are amendments needing approval (`improve.md:135`).
But the worked examples *are* category 1–11 changes presented as routine improve ops:
`CONCRETIZE` turns "THE response MUST be fast" into "MUST return the first byte within the bound
named by VERIFY BY perf:…" (`improve.md:75`) — that adds a proof binding (category 7) and a
response (category 6). `QUANTIFY` turns "handle high load" into "sustain 1000 rps at p99<200ms"
(`improve.md:79`) — a changed response (category 6) on any reading. `BIND` adds a `VERIFY BY`
(`improve.md:83`) — category 7 verbatim ("a VERIFY BY … is added"). By the table's own rules these
"improve" ops are amendments requiring approval, yet the step is described as the
normalization stage that runs automatically after lint. A by-hand operator following the worked
examples will route what the semantic-diff table classifies as amendments through the auto-approved
lane. The boundary between "concretizing a vague obligation" and "adding a response/binding" is
exactly where the contract and its own examples disagree. Evidence: `improve.md:28,48-55,75-83`
vs the semantic-diff table `improve.md:120-135`.

### O-7 (MAJOR) — two different "waiver" objects, both called a waiver, with different required-field sets

A by-hand operator meets *two* waivers. (a) The **lint-config** waiver demoting a BLOCKING code:
`lint.md:188` requires **seven** fields (`code, scope, to, authority, reason, expiry,
recorded_at`). (b) The **`WAIVED` verdict** decorator at the merge gate: `verify.md:44,89` and
`SOL.md:375` require **authority + reason + expiry** (three). They are genuinely different objects,
but both are "the waiver," both gate-relevant, both auto-expire on source-hash change, and the docs
never put them side by side — so an operator who learned the 3-field verdict form will under-fill a
lint-config waiver (missing `scope`/`recorded_at`/`to`), and "a demotion without a complete waiver
record is itself a validity defect" (`lint.md:186`). Easy to get silently wrong by hand. Evidence:
`lint.md:186-190` vs `verify.md:42-52,89` vs `SOL.md:371-377`.

### O-8 (MINOR) — `SOL-S012` required-section order vs the optional `## Source inputs` the template inserts mid-list

`spec.md:43-59` fixes 12 required sections in exact order; out-of-order is `SOL-S012` (BLOCKING).
The optional `## Source inputs` MAY sit "immediately after `## Context` (before `## Interfaces`)"
(`spec.md:61-67`). The shipped template puts `## Source inputs` exactly there (`spec.swarm.md:46`)
but **with a fill-in table row, not deleted** — and the template comment says "delete if there's no
upstream provenance." A by-hand linter applying `SOL-S012` strictly must special-case this one
optional section's legal position; the rule as written ("sections out of mandated order") does not
obviously admit an interleaved optional section, and only the prose at `spec.md:67` rescues it ("an
extra recognized optional section at its defined position is not a defect"). The conflict is mild
but it is precisely the kind of thing a strict checker trips on. Evidence: `spec.md:44,61-67`;
template `:46-55`.

### O-9 (MAJOR) — every gate, lint code, merge predicate, and verdict is "manual today," so the entire pipeline's safety rests on operator diligence the docs cannot enforce

This is the load-bearing assumption a reviewer must scrutinize, stated honestly but pervasively:
the CLARIFY gate (`lint.md:177`), the COVERAGE gate (`decompose.md:253`), the merge gate
(`verify.md:111`), every `SOL-V`/`SOL-S013` lint floor (`review.md:108`), the oracle-adequacy
`SOL-V011` check (`verify.md:284`), and staleness recomputation (`promote.md:119`) are all
"contracts checkable today by review, enforced by a future tool — manual today." The framework is
candid about this (`verify.md` §7 soft/hard control), and the candor is a strength. But the
*simulation's* finding is the cumulative effect: by `promote`, an operator has been asked to
hand-verify roughly a dozen predicates over a hand-built JSON graph they also produced, with no
check anywhere catching a slip. The probability that a multi-step by-hand run is fully
contract-compliant is low, and nothing in the pipeline surfaces a missed predicate. The honesty
about NO RUNTIME does not reduce the operational fragility; it documents it. Evidence: `lint.md:177`,
`decompose.md:253`, `verify.md:111,284,333`, `promote.md:119`.

### O-10 (MINOR) — `improve` runs only after `lint`, but `lint` is the only step with a shipped reference-card-only command path and no obligation to actually run anything

`lint` "needs no `cmd*` slot in the common case… performed by hand today" (`pass-lint-spec/
SKILL.md:77`). So the first analytic gate of the pipeline is, by design, a human reading prose for
S/P/M defects across a closed code catalogue (`errors.md`). The `P` layer alone is ~17 codes with
position-sensitive reclassification ("BLOCKING inside an obligation block, ADVISORY in commentary",
`lint.md:80`). Executing this faithfully by hand on every clause is a substantial, error-prone
manual task, and `improve`'s entire trigger set depends on `lint` having found the right codes —
a missed `SOL-P008` or `SOL-M002` means the CLARIFY gate silently passes a spec that should have
blocked. Evidence: `lint.md:80,96-143`; `pass-lint-spec/SKILL.md:53-59,77`.

### O-11 (MINOR) — `decompose` output (`task.md`) carries no `content_hash`/source-span obligation but `implement`'s `trace.md` must emit `per_surface_hash[]` by hand

`implement.md:107` requires the `trace.md` `## Provenance` to carry, per binding, a
`per_surface_hash[]` of `{surface, hash, exercised}` for "each declared `WRITES` and proof-exercised
`READS` surface." Same problem as O-2: hand-computing per-surface content hashes with no runtime is
not feasible for a human and not possible for an LLM. These flip a PASS to STALE, so a faked hash
defeats drift detection at the verification layer specifically. Evidence: `implement.md:107`;
`trace.md` provenance schema referenced there.

## Risks

- **R-1 (fires when a spec is lowered by hand and any node's `content_hash` is fabricated).** Every
  downstream `STALE` check (`verify.md`, `promote.md`) joins against a hash that does not correspond
  to the source bytes. Drift detection reports green forever or flaps randomly; the one mechanism
  meant to catch spec↔code divergence is silently inert. Grounded in O-2, O-11.

- **R-2 (fires when an author follows the `improve` worked examples literally).** Category-6/7
  amendments (added response, added/repointed proof binding) are committed through the auto-approved
  normalization lane without the approval R-SEMDIFF demands, defeating the "improve never changes
  intent" invariant the whole step is built to guarantee. Grounded in O-6.

- **R-3 (fires when a developer reaches `decompose`/`implement` in an adopted repo).** No shipped
  `task.md`/`trace.md` skeleton exists in the kit, so the work-packet and trace artifacts are
  improvised against an 8-section / 6-section prose contract, and a missing mandatory section
  (`SOL-S014` for a no-PROOF trace; an absent `## Verification matrix`) is caught only by a
  by-hand review that may not happen. Grounded in O-4.

- **R-4 (fires the first time `SOL-M001` is cited in a real lint report).** Author and reviewer
  disagree on whether the code means "unresolved actor/object" or "cross-spec id collision," and the
  routed `improve` op (`CONCRETIZE` vs a rename/import fix) is wrong for one of the two readings.
  Grounded in O-1.

- **R-5 (fires when the spec template is copied and shipped without editing the seeded QUESTION).**
  The pipeline halts at `lower` (`SOL-O003`) on a spec that the author believed was finished, with
  the cause buried in a skeleton placeholder. Grounded in O-5.

- **R-6 (cumulative, fires on essentially every full by-hand run).** One of the ~dozen manual gate
  predicates is mis-evaluated; because nothing is enforced, the change reaches `promote` with an
  undetected gate violation. The framework's honesty about NO RUNTIME makes this visible but does
  not prevent it. Grounded in O-9.

## Critical watch-outs for a reviewer (ranked)

1. **The `SOL-M001` double-definition (O-1).** A canonical lint code means two different things in
   two canonical pages. This is a concrete single-source-of-truth violation against CLAUDE.md's own
   "a rule lands in `docs/` first" discipline, and it is cheap to verify and fix. Highest priority.

2. **Hand-computed hashes are the pipeline's unfixable-by-hand step (O-2, O-11).** `content_hash`
   and `per_surface_hash[]` are MUST fields that a human cannot produce reliably and an LLM cannot
   produce at all, yet the entire drift/staleness layer depends on them. Either the by-hand journey
   must explicitly mark these as "tool-only, leave as a documented placeholder," or the staleness
   guarantees are aspirational in a way the step pages do not flag.

3. **`improve`'s worked examples contradict R-IMPROVE/R-SEMDIFF (O-6).** The step that promises never
   to change intent demonstrates intent changes as its canonical examples. A reviewer must decide
   whether CONCRETIZE/QUANTIFY/BIND are truly category-12 (and re-justify why adding a binding is
   "pure normalization") or whether the examples need an "this routes to amendment" caveat.

4. **No `task.md`/`trace.md` skeleton in the adopted kit (O-4).** The two artifacts the EXECUTE phase
   turns on have rich mandatory contracts and zero copyable starting point for a consuming repo —
   the most concrete "next step can't be cleanly produced" gap in the simulated journey.

5. **The cumulative manual-gate burden (O-9) and the two-waiver field mismatch (O-7).** Scrutinize
   whether a realistic operator can actually clear a dozen unenforced predicates and two
   differently-shaped waiver records correctly across one run; the framework's correctness rests on
   it, and the docs nowhere give the operator a single consolidated by-hand checklist for the full
   pipeline.

6. **The spec template's seeded blocking QUESTION (O-5).** Trivial to fix, high nuisance value: the
   shipped default halts the pipeline.
