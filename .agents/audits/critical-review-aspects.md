---
type: audit
id: critical-review-aspects
status: draft
created: 2026-06-07
updated: 2026-06-07
---

# Audit: 10 critical aspects to watch out for in a review of Swarm

> **Stance: observation-only.** This is a *reviewer's watch-list* — the aspects of Swarm a reviewer
> (or a prospective adopter) must scrutinize hardest — derived by simulating five real developer
> journeys end-to-end against the repo, validating the findings firsthand, and applying my own
> analysis. It records what *is* and the risk it carries; it authors no obligations and prescribes no
> fixes. Each aspect is tagged **design-tension** (a deliberate consequence of an invariant — watch it,
> don't "fix" it) or **fixable-defect** (a concrete inconsistency worth correcting).

## Method

Five subagents each simulated a journey, reading the actual files it touches, and produced an audit:
**adoption/instantiation**, **the full 9-step authoring pipeline**, **bug-fix + audit**, **parallel
decompose + memory + drift**, and **verify + review (the trust backbone)**. Their findings were then
**validated firsthand** (the agents over-call) and consolidated. Two validation rules were applied:
(1) retired vocabulary or stale paths inside **ADR bodies** are immutable history (Nygard governance),
not defects; (2) a finding flagged only because "NO RUNTIME enforces nothing" is a *design-tension* to
watch, not a bug — Invariant 1 is deliberate. This audit **supersedes and replaces** the five
intermediate `sim-*` audits and the three earlier dev audits (`claims-and-evidence`, `content-economy`,
`spec-implementation-readiness`), which were deleted (recoverable via git; the last was itself stale —
it framed Swarm as a runtime-to-build).

## The 10 critical aspects

### 1. The entire correctness/trust model is soft control with no enforcer — design-tension (the dominant one)

Every gate Swarm describes — the merge gate, write-disjointness, staleness, the stance boundaries,
implementer≠reviewer, oracle adequacy — is **manual markdown a human or agent performs by hand**
(Invariant 1, NO RUNTIME: `docs/PRINCIPLES.md`; "a gate is a check a reviewer applies by reading
evidence", `docs/reference/cheatsheet.md:5`). It recurred in **all five** journeys. The concrete failure
mode: in a **single-agent loop**, one actor can author → implement → verify → review → self-pass a
well-formed *fiction* with nothing to stop it. **Watch:** whether the discipline survives a real (esp.
solo) loop, and — the #1 adopter risk — whether a reader mistakes the (honest, caveated) contracts for
enforced guarantees. The docs are scrupulously honest in-prose that "runs/enforces" means *a future
tool*; the danger lives entirely in the reader.

### 2. Independence (implementer≠reviewer, the judge panel) is self-attested and unbindable — design-tension

The named centerpiece of the trust model — an independent reviewer, the dual-judge rule for high-RISK
work, "no shared lineage with the generator" — rests on a `judge` adjunct **the rendering agent simply
types** (`docs/passes/review.md`, `starter-kit/.agents/skills/persona-skeptic`). `manual` is a
gate-passing proof type, and the default review oracle is an LLM. Nothing binds recorded judge identity
to the actual actor, and [[CORRELATED]] shows even truthful cross-vendor judges are not independent.
**Watch:** whether a review is genuinely independent or a generator grading itself behind a typed label.

### 3. "Schema is not verification" is advisory by default — fixable-defect / design-tension

The deepest claim (a proof must actually exercise the obligation, not just be green/schema-valid) is
**not** what the default behavior enforces: the oracle-adequacy lint codes (`SOL-V011`/`SOL-V003`) warn
only unless strict mode is opted in, and the **merge-gate predicate ignores adequacy entirely**
(`docs/passes/verify.md`, `docs/passes/review.md`). A `RISK high` obligation can clear the gate on a
bare green test the author wrote and self-reported as adequate. **Watch:** the gap between the
framework's deepest claim and its default — wherever `SCHEMA IS NOT VERIFICATION` is invoked, confirm
adequacy is actually gated, not advisory.

### 4. The merge gate has an empty-set / coverage-gap edge — fixable-defect

The gate is "every **required** obligation carries a passing/WAIVED verdict" (`docs/passes/review.md`).
A bug or change whose behavior **no obligation covers** (a `bug-report` records the gap but authors no
obligation, `docs/artifacts/bug-report.md:14`) yields an **empty in-scope set** → the gate is trivially
true → the change ships "verified" with no contract and no proof. **Watch:** any task whose assigned-
obligation set is empty or hand-invented; the coverage-gap path must force a spec amendment before the
gate means anything.

### 5. The drift/staleness layer rests on hashes no human or LLM can compute — fixable-defect

`source.content_hash` and the trace's `per_surface_hash[]` are **MUST** fields
(`docs/passes/lower.md`, `docs/artifacts/trace.md`) on which the *entire* staleness/drift detection
depends — yet under NO RUNTIME a human can't reliably produce a real SHA-256 and an LLM can't at all, so
they get faked or omitted and the guarantees become aspirational. Worse, **finding**-staleness is
structurally weaker than verdict-staleness: one scalar `content_hash`, no per-surface/exercised set, no
comparator (`docs/artifacts/finding.md`, `docs/reference/drift-and-staleness.md`) → promoted memory
never actually flips `stale`. **Watch:** the step pages should mark hashes "tool-only — leave a
documented placeholder," and a reviewer must treat hand-emitted hashes as untrusted.

### 6. Parallel-coordination safety is single-spec and hand-computed — design-tension / fixable-defect

Write-side safety reduces to **glob-overlap a human computes with no checker**; "under-declared
`WRITES`" silently defeats the one safe default ("unscoped serializes"); nothing observes a worker
mid-run (a diverging worker is conceded "invisible state"); and the safe-parallelism proof is
**single-spec** — concurrent decompositions over *different* specs can collide on a shared surface with
no artifact able to see it (`docs/passes/decompose.md`, the coordination-record reference,
`docs/passes/implement.md`). **Watch:** independently re-derive every `merge_safe: true` (`**` spans
segments), diff each branch against its FORBIDDEN set, and check whether two parallel runs span
different specs.

### 7. Internal single-source-of-truth slips — fixable-defect

The framework's own discipline ("a rule lands in `docs/` once") has leaks a reviewer must catch. The
sharpest: **`SOL-M001` is defined two ways** — "cross-spec id collision" (`docs/language/SOL.md:122,455`)
vs "actor/object incompleteness" (`docs/passes/lint.md:113`, `docs/language/errors.md:181`), two
canonical pages, two primary meanings, two different `improve`-op routings. Lower-tier: "waiver" names
two differently-shaped objects (a 7-field lint-demotion record, `docs/language/errors.md:117`, vs a
3-field verdict `WAIVED`, `docs/passes/verify.md:44`) — legitimately distinct, but the shared name
invites confusion. **Watch:** every closed-set count and code definition reconciling across pages (the
`cheatsheet.md` hub is the anchor).

### 8. Non-spec entry paths + stance laundering at the un-analyzable `author` step — fixable-defect / design-tension

The `author` step is described as producing a `spec.swarm.md`, but a `bug-report` promotes into a **fix
task** instead (`docs/passes/author.md:46`) — the hop is *named* but the task-population mechanism
(`assigned_obligations`/`write_surfaces`/`verification_bindings`) is under-specified vs the
spec→`lower`→`decompose` path that normally fills them. And the source-doc **stance boundaries**
(audit = observation-only, bug-report = diagnosis-only, neither authors obligations) are unenforceable —
`## Recommended obligations` prose is laundered verbatim into binding SOL intent at an `author` step the
framework itself calls outside analysis (`docs/passes/author.md`). **Watch:** that promotion preserves
stance and doesn't invent or distort intent, and that the bug-report→fix-task seam is real.

### 9. Adoption's first-run journey has dead-ends — fixable-defect

A newcomer following `docs/ADOPTING.md` hits avoidable traps: the copy instruction says "copy
`{skills,…}` into `.agents/`" then "put skills in `.claude/skills/`" in adjacent clauses
(`docs/ADOPTING.md:28-31`) → a literal copy lands skills where Claude Code never scans them, silently;
startup rule #1 "read the current task file first" (`starter-kit/AGENTS.md`) points at a task file that
is gitignored, never created, and whose template ships **code-side** (`docs/library/code-skills/
templates/`), not in the spec-repo kit; and normative `MUST`s ("a valid repo MUST have a regression
check," "validity is graded per role") promise enforcement with no shipped check or fixture. **Watch:**
whether a fresh adopter can actually reach a working, activated state.

### 10. Evidence discipline, positioning honesty, and the adapter surface — design-tension / fixable-defect

Three trust-of-the-framework-itself checks. (a) **§0.7:** a few load-bearing claims ride
non-peer-reviewed preprints; the rule is that a preprint never carries a `MUST` — a reviewer should
confirm every `MUST`-level claim rests on a verified source. (b) **The `AGENTS.md > Commands` adapter
resolver** is a free-string surface a `VERIFY BY <type>:<adapter>:<artifact>` binding resolves through —
an under-examined confused-deputy / injection surface if a spec or untrusted source can influence what
command an adapter runs. (c) **Positioning:** the dominant over-claim risk is, again, a reader treating
the honest caveated prose as enforced guarantees — the framing must keep promising *clarity, safe runs,
reviewable evidence*, never *automatic correctness*.

## What I validated DOWN (transparency — the army over-called)

- **"bug-report→fix-task hop is undefined" (BLOCKER → MAJOR):** it *is* named (`author.md:46`); only the
  task-population mechanism is under-specified. Folded into #8.
- **"two waiver shapes is a contradiction" → MINOR:** two legitimately distinct concepts sharing a name.
  Folded into #7.
- **Retired vocabulary / stale paths inside ADR bodies (~15 findings) → dropped:** ADR bodies are
  immutable history (Nygard); the current truth lives in the ledger + `docs/`.
- **"diagrams.html / config.yaml" findings → already actioned:** both deleted in the prior remediation.
- **Most "X is unenforced (NO RUNTIME)" findings → reframed** as design-tensions (#1), not defects.

## Critical watch-outs, one line each (the shortlist)

1. Soft control everywhere — does the discipline survive a solo loop? · 2. Self-attested independence ·
3. Adequacy advisory, not gated · 4. Empty-obligation-set gate edge · 5. Uncomputable hashes →
hollow drift · 6. Hand-computed, single-spec parallel safety · 7. `SOL-M001` (and counts) reconcile? ·
8. Stance laundering at `author` · 9. Adoption dead-ends · 10. §0.7 + adapter injection + over-claim.

## Recommended obligations (prose — candidate watch-disciplines a spec/ADR could carry)

- A conformance/coherence review SHOULD treat every "gate/check/enforced/MUST" as **advisory until a
  tool exists**, and the positioning SHOULD never imply enforcement Swarm does not provide.
- The merge-gate predicate SHOULD define its behavior on an **empty in-scope obligation set** (a
  coverage-gap change must not pass by vacuity).
- Hash-bearing fields SHOULD be explicitly marked **tool-only placeholders** in the by-hand pipeline.
- The single-source-of-truth slips (esp. `SOL-M001`) SHOULD be reconciled at their canonical home.
