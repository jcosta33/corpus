# The `improve` pass — the ten improve operations

> Authoritative source: 03-compiler-pipeline.md §10 (the ten improve operations, strictly semantics-preserving — §10.1 R-IMPROVE / R-DECOMPOSE-NOT-IMPROVE, §10.2 the closed set, §10.3 worked examples, §10.4 the twelve-category semantic-diff and R-SEMDIFF). This is a reference projection; where it and the spec disagree, the spec governs.

`improve` is the third of the **nine passes** of the Swarm compiler pipeline (`author -> lint -> improve -> lower -> decompose -> implement -> verify -> review -> promote`). It is the `NORMALIZE`-phase pass that rewrites a spec to satisfy SOL and APS. This page is the short reference view for that single pass; the long-form contract is the spec (§10).

Like every Swarm pass, `improve` has **no runtime**: it is a contract a human, an agent following a pass guide, or a future tool performs. Nothing here is shipped code (Invariant 1, §2).

## What the pass does

The `improve` pass takes a linted spec and brings it into canonical, smell-free, **semantics-preserving** form. It is defined as a **closed set of exactly ten operations** — a conformant `improve` pass MUST NOT invent operations outside this set, and "improve the spec" with no named operation is not a valid request (§10).

| Aspect | Value (from §9.3) |
|---|---|
| Phase | **`NORMALIZE`** (the canonicalization stage) |
| Input artifacts | `spec.swarm.md` + the `lint` report |
| Output artifacts | `spec.swarm.md` (normalized) + a spec-improvement report |
| Typical carrier profile (§27) | Architect / Skeptic |
| Lint layer (§8) | — (answers the lint codes mapped in §10; emits none of its own) |

Two ordering facts pin where `improve` sits (§9.3.1):

- **`improve` runs only after `lint`.** Each improve operation is *triggered* by one or more lint codes. Running `improve` with no lint findings to answer is a **no-op**.
- **`improve` is the only pass permitted to rewrite the spec.** `lint` is non-mutating (it only emits diagnostics); `improve` is where the spec text legitimately changes — and only semantics-preservingly.

## The hard rule: improve is semantics-preserving

> **R-IMPROVE (§10.1).** Every improve operation MUST be strictly semantics-preserving. An improve operation MUST NOT add, remove, weaken, strengthen, or otherwise change the **intent** of any obligation. Any change to obligation intent — a new requirement, a relaxed constraint, a different actor, a changed trigger or response — MUST route to **amendment/review**, never to `improve`.

Design rationale (from §10.1): `improve` is the normalization phase; intent change is a `PROMOTE`/amendment decision governed by source authority (§22). Conflating the two would let a "cleanup" silently rewrite what the system builds — a direct violation of "code is reality, not intent" (Invariant 4, §2). The spec-improvement report MUST carry a *Semantic changes* row for any edit the author is unsure preserves intent, flagged `requires approval: yes`; such edits are out of scope for `improve` and belong to amendment.

> **R-DECOMPOSE-NOT-IMPROVE (§10.1).** `decompose` is a separate **pass** (§9, §11), NOT an improve operation. Splitting a spec into task-sized work packets is lowering work that changes the *artifact partition*, not the *prose*; it MUST NOT appear in the improve set. The improve operation `ATOMIZE` is distinct: it splits one bundled obligation into multiple obligations *within the same spec*, preserving the spec as the unit.

## The ten operations (normative)

The closed set, in spec order (§10.2):

```text
NORMALIZE  ATOMIZE  CONCRETIZE  QUANTIFY  BIND  SCOPE  CLARIFY  DECONFLICT  COMPRESS  PROMOTE
```

Each operation is *triggered* by one or more lint codes (§8), has a precondition (what must hold before it applies) and a postcondition (what it guarantees after). Trigger codes use the unified `SOL-<LAYER>###` namespace across the five lint layers (S/P/M/V/O); legacy `APS-*` codes are retired (§8, Appendix B).

| # | Operation | Trigger lint code(s) | Precondition | Postcondition |
|---|---|---|---|---|
| 1 | `NORMALIZE` | `SOL-P003`, `SOL-V###` | A clause uses an informal/lowercase modal or non-canonical phrasing/clause order. | Clause uses an approved uppercase modal in canonical clause order; no meaning changed. |
| 2 | `ATOMIZE` | `SOL-P004` | One block bundles two or more separable obligations. | Each separable obligation is its own block with its own id; bindings distributed. |
| 3 | `CONCRETIZE` | `SOL-P005` | A vague-quality word has no same-line observable criterion. | The word is replaced by observable behavior (actor + action + object). |
| 4 | `QUANTIFY` | `SOL-P005` | An unbounded quality has no measurable threshold. | The quality carries a measurable threshold or named measurable criterion. |
| 5 | `BIND` | `SOL-V001`, `SOL-V###` | An obligation lacks a `VERIFY BY` binding, source, interface, or trace reference. | The obligation carries a valid `VERIFY BY <type>:<adapter>:<artifact>` and required references (merges legacy `Bind` + `Trace`). |
| 6 | `SCOPE` | `SOL-O###` | The spec lacks declared non-goals, applicability, write surfaces, or exclusions. | Explicit non-goals / applicability / `WRITES` / exclusions are present. |
| 7 | `CLARIFY` | `SOL-P008` | Behavioral uncertainty is buried in prose, not lifted to a block. | The uncertainty is an explicit interpretation OR a `QUESTION` block. |
| 8 | `DECONFLICT` | `SOL-M002` | Two obligations (or an obligation and a higher artifact) contradict. | The contradiction is resolved per source authority (§22), or raised to amendment. |
| 9 | `COMPRESS` | `SOL-P054`, `SOL-P055` | Prose carries non-load-bearing noise or redundancy. | Noise/redundancy removed; future agents interpret the text consistently (merges legacy `Compress` + `Stabilize`). |
| 10 | `PROMOTE` | promotion protocol (§23) | A durable fact sits in task-local state. | The fact is moved to `finding.md` / `spec.swarm.md` / `adr.md` / memory with provenance. |

**`CONCRETIZE` vs `QUANTIFY` (§10.2).** Operations 3 and 4 share the trigger `SOL-P005` (vague-quality word with no observable criterion). They differ only in *repair*: `CONCRETIZE` substitutes *observable behavior* (qualitative), `QUANTIFY` substitutes a *measurable threshold* (quantitative). The author selects whichever the obligation's nature requires; both exit the same lint code.

### Worked before/after (§10.3)

```sol
NORMALIZE
  before:  WHEN request fails, the client should retry once.
  after:   WHEN the request fails THE client SHOULD retry once BECAUSE transient failures are common.

ATOMIZE
  before:  REQ AC-010: THE API MUST validate input AND log AND retry AND alert.
  after:   REQ AC-010: THE API MUST validate input.
           REQ AC-011: THE API MUST log the validation outcome.
           REQ AC-012: THE API MUST retry once on transient failure.
           REQ AC-013: THE API MUST alert on repeated failure.

CONCRETIZE
  before:  THE response MUST be fast.
  after:   THE service MUST return the first byte within the bound named by VERIFY BY perf:cmdBenchmark:p99.

QUANTIFY
  before:  THE service MUST handle high load.
  after:   THE service MUST sustain 1000 requests per second at p99 < 200ms.

BIND
  before:  REQ AC-020: THE worker MUST persist progress every 100 rows.
  after:   REQ AC-020: THE worker MUST persist progress every 100 rows
           VERIFY BY test:cmdTest:import.progress_checkpointing.

SCOPE
  before:  (spec has no non-goals)
  after:   ## Non-goals — Swarm MUST NOT define a runtime; WRITES src/auth/** only.

CLARIFY
  before:  The session probably clears, but caching behavior is unclear.
  after:   QUESTION Q-003: [blocking] Does session clear evict the token cache? AFFECTS AC-001.

DECONFLICT
  before:  AC-001 THE client MUST send a request; AC-009 THE client MUST NOT send a request (same trigger).
  after:   AC-001 retained per source authority; AC-009 superseded with REASON, or both raised to amendment.

COMPRESS
  before:  THE system, in order to be robust and resilient, MUST very carefully validate.
  after:   THE system MUST validate the request body.

PROMOTE
  before:  (task note: "discovered the refresh endpoint rate-limits at 5/min")
  after:   finding.md: claim + evidence + origin_obligations[] + applies-when.
```

## The `improve`-op `CLARIFY` is not the CLARIFY *gate*

The `CLARIFY` improve operation (op 7 above) and the **CLARIFY gate** (§11.6.1) are distinct and MUST NOT be conflated (§11.6, normative reconciliation):

- The `CLARIFY` **op** is a *local edit* in the `NORMALIZE` phase: it lifts one buried prose ambiguity (`SOL-P008`) into an explicit interpretation or a `QUESTION` block. The op *creates* the QUESTION.
- The CLARIFY **gate** is a *pipeline checkpoint* at the `NORMALIZE`→`LOWER` boundary: it refuses to advance the spec while any such question is still open and blocking. The gate *waits on* it.

One is the repair; the other is the precondition that the repair has been discharged. This page covers the op; the gate belongs to the lowering reference (§11).

## How an edit is judged legitimate: the twelve-category semantic diff (§10.4)

R-IMPROVE is the *rule*; the **semantic-diff classification** is the *operational test* behind it. Every spec edit reaching the `improve` or `review` pass MUST be classified into exactly one of **twelve closed categories**. The set is closed: a conformant pass MUST NOT invent a thirteenth, and an edit that fits none is itself a defect (an unanalyzable diff) that MUST be split until each part classifies.

| # | Category | What changed | Auto-approved? |
|---|---|---|---|
| 1 | added obligation | A new `REQ`/`CONSTRAINT`/`INVARIANT`/`INTERFACE` block (a new obligation id) appears. | No — amendment (§22.6) |
| 2 | removed obligation | An existing obligation id is deleted or renumbered out of existence. | No — amendment (§22.6) |
| 3 | changed trigger | The `WHEN`/state precondition of an obligation is added, removed, widened, or narrowed. | No — amendment (§22.6) |
| 4 | changed actor | The `THE <actor>` subject of an obligation is replaced. | No — amendment (§22.6) |
| 5 | changed modality | The modal (`MUST`/`MUST NOT`/`SHOULD`/`SHOULD NOT`/`MAY`, §5) is strengthened, weakened, or negated. | No — amendment (§22.6) |
| 6 | changed response | The required action/object (the obligation's effect) is altered. | No — amendment (§22.6) |
| 7 | changed proof binding | A `VERIFY BY <type>:<adapter>:<artifact>[#selector]` is added, removed, or repointed (§15). | No — amendment (§22.6) |
| 8 | changed non-goal | A `Non-goals`/applicability/`WRITES` exclusion is added, removed, or rescoped. | No — amendment (§22.6) |
| 9 | changed interface | An `INTERFACE` (`IF-NNN`) contract is altered. | No — amendment (§22.6); breaking changes flagged per §22.6 |
| 10 | changed invariant | An `INVARIANT` (`I-NNN`) is added, removed, or restated with different force. | No — amendment (§22.6) |
| 11 | changed question status | A `QUESTION` (`Q-NNN`) changes lifecycle (raised, answered, downgraded `[blocking]`→`[non-blocking]`, or materially resolved). | No — amendment (§22.6) |
| 12 | pure normalization | Formatting, casing, keyword form (§4.10), canonical clause order, dead-link/proof-ref completion, or redundancy compression — with **no** change to any obligation's actor, trigger, modality, response, binding, non-goal, interface, invariant, or question status. | **Yes** — the only approval-free class |

> **R-SEMDIFF (§10.4).** **Pure normalization (category 12) is the only auto-approved class.** Every one of categories 1–11 is an **amendment** and MUST route to approval per §22.6. The `improve` and `review` passes MUST classify each edit before the spec is promoted; an unclassified edit MUST NOT be promoted. An edit that combines a normalization with any of categories 1–11 is classified by its strongest (non-normalization) category, never as pure normalization — normalization does not "absorb" a semantic change ridden in alongside it.

The bridge this makes explicit: an `improve` operation (§10.2) is legitimate **iff** every edit it makes classifies as category 12. The moment an edit classifies as any of 1–11, the work has **left `improve` and entered amendment**, and the change report (§9.3) MUST record the category and carry `requires approval: yes`.

## Why this discipline (design rationale)

The "lint before you generate, then normalize without changing intent" shape is grounded, not stylistic. Ambiguous task descriptions cut code-generation Pass@1 by roughly 25–30% and contradictory ones by up to 40% [AMBIGCODE]; a benchmark of 1,304 tasks shows frontier models degrade >30% on ambiguous requirements and cannot autonomously resolve them [ORCHID]; conversely, surfacing and resolving ambiguity before generation (clarify-then-generate) raised GPT-4 Pass@1 from 70.96% to 80.80% [CLARIFYGPT]. The `CLARIFY` op (lift ambiguity to a `QUESTION`) and the `DECONFLICT` op (resolve contradiction) are the concrete normalizations that turn those gains into pass-level behavior — while R-IMPROVE keeps the cleanup from silently editing intent.

## Preserved / Dropped / Still-uncertain

**Preserved** (projected faithfully from §10):

- The closed set of **exactly ten** improve operations, in spec order, with each operation's trigger lint code(s), precondition, and postcondition (§10.2).
- The hard semantics-preserving rule **R-IMPROVE** and the **R-DECOMPOSE-NOT-IMPROVE** boundary, plus the *Semantic changes* report row (§10.1).
- The `CONCRETIZE`/`QUANTIFY` same-trigger / different-repair distinction (§10.2).
- All ten worked before/after examples (§10.3), verbatim.
- The full **twelve-category** semantic-diff set, **R-SEMDIFF**, and the "legitimate `improve` op iff every edit is category 12" test (§10.4).
- The `improve`-pass row of §9.3 and the two ordering notes from §9.3.1 (runs only after `lint`; only pass that may rewrite the spec).

**Dropped** (out of scope for this single-pass projection; lives in the spec):

- The full nine-pass / seven-phase model and the pass→phase mapping for the other eight passes (§9), beyond the row needed to place `improve`.
- The CLARIFY **gate** and the COVERAGE gate machinery (§11.6) — only the op-vs-gate reconciliation is summarized here; the gates belong to the lowering reference.
- The §22.6 amendment/approval table itself, and the source-authority two-axis model (§22) that `DECONFLICT` and `PROMOTE` defer to.
- The IR shape that lowering emits, including how `verify_by`, `WRITES`, and edges are normalized (§11–§12).
- That `improve` is one of the four passes shipping **no** stdlib pass guide in v0.1 (§9.4) — stated in the spec; not load-bearing for using the op set.

**Still-uncertain** (the spec governs; not pinned here):

- The precise lint-code-to-operation routing where a code maps to more than one op or shares a trigger (e.g. `SOL-V###` triggers both `NORMALIZE` and `BIND`; `SOL-P005` triggers both `CONCRETIZE` and `QUANTIFY`) — §10.2 fixes the triggers and the repair distinction but leaves the per-finding selection to author judgment.
- Whether `improve` gains a stdlib pass guide in a future framework release (open by §9.4, "without any language-version change", §25).
- The exact threshold/heuristics for the `COMPRESS` op's "non-load-bearing noise" and for when an `ATOMIZE` is required versus advisory — §10 names the operation and trigger but not a mechanical bundling metric (cf. the `SOL-P004`-adjacent chaining warning, §11.1.1).
