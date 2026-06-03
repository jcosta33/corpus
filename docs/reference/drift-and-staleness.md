# Drift and Staleness

A proof's `PASS` is a statement about a *moment*: the obligation said X, the code did Y, and the proof confirmed Y satisfies X. The instant either the obligation text or the code changes, that confirmation may no longer hold. **Drift** is the divergence between an obligation and its implementation after a recorded `PASS`; **staleness** is drift made machine-detectable. This page fixes how Swarm catches drift, the closed schema each `PASS` records so it *can* be caught, the four conditions that turn a `PASS` `STALE`, and the three-way reconcile a `STALE` verdict forces.

Swarm is markdown-only and has **no runtime**. Nothing here is shipped code: the content-hasher, the staleness check, and the reconcile workflow are all **contracts a future harness builds against**. Because there is no runtime, drift is detected from **content hashes recorded in the trace/IR** at the time of each `PASS`, and the differ that compares those hashes against the working tree is a harness/CLI concern. What this page defines is the schema those hashes live in and the rules that read them.

The governing doctrine is **CODE IS REALITY** (Invariant 4): specs are primary for *intent*, code is primary for *implementation reality*, and the trace/review/status layer reconciles the two. Code can *falsify* an obligation — forcing a fix or an amendment — but a passing run may never *silently re-bless* either side. Staleness is the mechanism that refuses to let a stale `PASS` masquerade as a current one. A green build is *shape*, not truth; staleness asks whether the evidence still matches reality, not whether the suite still exits zero [[REFLEXION]](../research/sources.md#REFLEXION).

## What each PASS records: the trace-provenance schema

Every `VERIFY BY` binding's **last `PASS`** records enough provenance to detect later drift. There is **exactly one** trace-provenance schema, so the verdict model, the drift check, and the memory model never diverge. The required base is a **closed seven-field set**; two named optional adjuncts (`oracle_adequacy` and `judge`) MAY extend a verdict's provenance without altering that base — they are optional extensions on the same record, not additional schemas.

```json
{
  "source_hash": "sha256:…",
  "per_surface_hash": [
    { "surface": "src/auth/client.ts", "hash": "sha256:…", "exercised": true },
    { "surface": "src/auth/session-store.ts", "hash": "sha256:…", "exercised": false }
  ],
  "adapter": "cmdTest",
  "verdict": "PASS",
  "tier": "test",
  "origin_obligations": ["AC-001", "I-001"],
  "origin_traces": ["T-001"]
}
```

| Field | Meaning |
| --- | --- |
| `source_hash` | Content hash of the *obligation source* — the exact bytes of the obligation block in `*.swarm.md` — at the time of the `PASS`. |
| `per_surface_hash[]` | One `{surface, hash, exercised}` per surface in the obligation's declared `WRITES` set **and** the `READS` surfaces the proof exercised, at the time of the `PASS`. `exercised` is a bool — `true` iff the proof actually executed or analysed that surface. The proof's **evidence path** is the *derived* exercised subset (the entries with `exercised: true`); it is not a separate stored field. Recording `READS` hashes is what makes read-side drift detectable. |
| `adapter` | The `cmd*` slot the proof resolved through (the command slot named in `AGENTS.md > Commands`). |
| `verdict` | The core verdict recorded — `PASS` for a drift-trackable binding. |
| `tier` | The proof type (one of the nine — see [Proof Types and the `VERIFY BY` Binding](./proof-types.md)) — the same value recorded as `type` in the IR `verify_by[]` element; used for the proof-strength tie-break. |
| `origin_obligations[]` | The obligation ids this `PASS` judged. |
| `origin_traces[]` | The trace(s) that produced the change being judged. |

The IR field names are snake_case. Hashes are recorded in markdown (`*.swarm.trace.md`) and/or the emitted IR (`*.swarm.ir.json`). Computing them is a future-tool concern; the **schema is the kernel contract** today. The two surfaces in the example above illustrate the central distinction the rest of this page turns on: `src/auth/client.ts` was `exercised: true` (it is on the evidence path), while `src/auth/session-store.ts` was declared but `exercised: false` (the proof never touched it).

## The staleness rule

A prior `PASS` becomes `STALE` — the lifecycle decorator that blocks the merge gate — when **either** of two base conditions holds:

> **(a)** the obligation **source content-hash** changes (the obligation text was edited after the last `PASS`); **or**
> **(b)** any declared **write surface** is modified after the last `PASS` (its current hash differs from the recorded `per_surface_hash`).

Condition (a) means *intent moved*: the proof confirmed an obligation that no longer reads the same. Condition (b) means *code moved*: the proof confirmed code that has since changed. In both cases the recorded `PASS` is no longer trustworthy, and the verdict MUST be decorated `STALE` — carrying its prior-verdict ref and the changed-surface, the mandatory fields a `STALE` decorator requires.

```sol
VERDICT AC-001: PASS (STALE by drift-check: prior-verdict T-001; changed-surface src/auth/client.ts)
REASON src/auth/client.ts changed after the last PASS at T-001; the recorded per-surface hash no longer matches the working tree.
EVIDENCE prior PASS recorded 2026-05-20 against source_hash sha256:ab12…
```

`STALE` **blocks the merge gate**: a `PASS (STALE)` is treated as not-`PASS` until reconciled. A conformant tool — or a human, today — MUST recompute staleness before evaluating the gate and MUST NOT promote on a stale binding. `STALE` is the one lifecycle decorator that may attach **only** to a prior `PASS`: a `FAIL`, `BLOCKED`, or `UNVERIFIED` was never trusted, so it cannot go stale.

## Proof-exercised participation: which surfaces count

Conditions (a) and (b) alone fire on a change to the obligation source-hash or to a *declared write surface*. That narrow trigger leaves two gaps, and both are closed by tying staleness to **what the proof actually exercised** rather than to what the obligation merely declared.

The first gap is that a naive per-surface hash marks *every* obligation that declares a shared or global surface `STALE` on any unrelated edit. The obvious fix — blanket-exempting `append-only` and `shared` surfaces from condition (b) — over-corrects: under such an exemption a *real behavioral* change on an exempt surface would not force `STALE`, while a whitespace-only edit on an ordinary surface would. That inverts the very honesty staleness exists to protect.

The second gap is that drift through an *undeclared read* is invisible: a proof can keep passing while no longer exercising the obligation it was bound to, because syntactic equality of a write surface is not behavioral equality of the obligation. A behavioral change reached through a dependency the obligation reads — but never declared — leaves condition (b) untouched.

The resolution is the **participation rule**:

> A surface participates in an obligation's freshness **if and only if it has an `exercised: true` entry** in that obligation's last `PASS`'s recorded `per_surface_hash[]` — i.e. the proof that produced the `PASS` actually exercised the surface.

This exercised subset is the proof's evidence path. It is read directly from the always-present `per_surface_hash[]` flag, not from any optional adjunct. A surface present only as a *declared* `WRITES` the oracle never exercised (`exercised: false`) does **not** participate on that ground alone. Participation is decided **per obligation, per recorded proof**, never by a blanket attribute toggle:

- A surface the last `PASS` **actually exercised** participates **regardless of its `SURFACE` attribute** — an in-place behavioral edit to an `append-only` or `shared` surface that the proof's evidence path traversed MUST force `STALE`. The surface attribute governs conflict serialization and blanket fan-out, never an exemption from drift on an exercised surface.
- A surface the last `PASS` did **not** exercise does **not** participate — an unrelated edit to a `shared` or global surface (a lockfile bump, an orthogonal CI-matrix entry) MUST NOT mark that obligation `STALE`.

So freshness follows evidence: drift on an *exercised* surface always fires, drift on an *un-exercised* surface never does on its own, and the obligation's own `source_hash` change (condition (a)) still forces `STALE` regardless of any surface.

## The four STALE triggers

With participation defined, the base pair (a)/(b) extends to a closed set of **four** conditions. A prior `PASS` becomes `STALE` when **any** of them holds:

> **(a)** the obligation **source content-hash** changes; **or**
> **(b)** a declared **write surface on the evidence path** is modified after the last `PASS`; **or**
> **(c)** a surface in the obligation's declared **`READS`** set that lies on the evidence path of the last `PASS` is modified after that `PASS` (its current hash differs from the recorded `per_surface_hash` entry); **or**
> **(d)** the **bound adapter changes** — the `cmd*` slot the proof resolved through (recorded as `adapter` in the provenance schema) is rebound, retargeted, or removed relative to the last `PASS`.

Condition (c) makes read-side behavioral drift detectable to the same degree write-side drift already is: the `READS` surfaces the proof exercised are hashed into `per_surface_hash[]` alongside its `WRITES` set, so the recorded evidence path is complete. Condition (d) catches the case where the proof itself moved underneath an unchanged obligation and unchanged code. All four are **content-hash** comparisons computed by a future harness — none requires a runtime. Each surfaces as the same `STALE` verdict, and a `STALE` raised under (c) or (d) MUST still carry its prior-verdict ref and the changed `READS`-surface or adapter in the **changed-surface** field, so the reconcile can act on it.

**Scope limit (honesty).** This rule detects **declared-write, declared-read, and adapter drift** — drift reachable through a surface or adapter recorded on the last `PASS`'s evidence path. It does **not** and **cannot** detect behavioral drift through an *undeclared* dependency, a hidden global, or an environmental input the obligation never declared and the proof never recorded: a missing `READS` declaration means a missing hash, and what is unhashed is unseen. Closing that residual gap requires observing behavior, which has no home in a markdown-only kernel. Swarm therefore claims **declared-drift detection**, never full behavioral-drift detection. An obligation whose true read set exceeds its declared `READS` is a soft-control gap to be caught in review, not a guarantee this page makes. `property` and `metamorphic` oracles narrow the residual by checking behavioral relations rather than syntactic equality; they reduce the gap, they do not erase it.

A worked contrast: a tool that bumps a lockfile no proof exercised leaves drift coverage unchanged; an in-place edit to a CI step that an obligation's proof *did* exercise raises that obligation to `STALE`. Whether to recompute participation incrementally or on demand is a harness concern; the participation rule, the four conditions, and the scope limit are the kernel contract.

## The three-way reconcile

A `STALE` verdict forces an explicit **three-way reconcile**. Exactly one of three resolutions MUST be chosen and recorded. The system MUST NOT silently re-bless either the obligation or the code — there is no fourth, quiet option.

| # | Resolution | When | Effect |
| --- | --- | --- | --- |
| 1 | **Re-run the proof** | The change is compatible; intent and code still agree. | The bound `cmd*` re-runs; a fresh `PASS` with new hashes replaces the stale record. |
| 2 | **Amend / supersede the obligation** | Intent changed; the code is the new desired behavior. | The obligation is amended (or superseded via an ADR), then re-verified. This is an *intent* change and routes to amendment/review. |
| 3 | **Fix the code** | Intent stands; the code drifted away from it. | The code is corrected to satisfy the unchanged obligation, then re-verified. |

This is **code is reality, not intent** made operational. Code can *falsify* an obligation — forcing resolution 2 or 3 — but may never *silently amend* it, which is why resolution 1 requires a genuine re-run, not a hash-rewrite. Re-stamping the recorded hash without re-running the proof is forbidden: it manufactures a false `PASS`. The same not-silent discipline governs a `CONTRADICTED` verdict, where two proofs disagree and the stronger oracle is authoritative only pending a recorded reconciliation.

**Drift coverage** — the percentage of required obligations whose latest verdict is `STALE` — is a first-class Swarm metric a conformant repo SHOULD track (manually today; via tooling when it exists). High drift coverage signals that verification has fallen behind change velocity and that the merge gate is, in aggregate, blocking.

```text
drift_coverage = ( count of required obligations whose latest verdict is STALE )
                 / ( count of required obligations )
```

## Surface policies: governing a region before drift is measured

The staleness rule detects drift *after* a `PASS`. *Before* any of that, a **surface policy** declares how Swarm is permitted to govern a given region of code at all. The two are one mechanism viewed at two times: the policy says what an edit to a surface is *allowed* to be, and the staleness rule says what an edit that violated that allowance *becomes*.

A code region declares **exactly one** policy from a closed set of five: `generated`, `governed`, `observed`, `external`, `deprecated`. The full taxonomy — what each policy means, which manual edits each permits, and the rejected "code is disposable" doctrine — is defined in the [Workspace Model](../model/workspace.md). The policy load-bearing for drift is `governed`.

Surface policies are declared as a `surfaces:` map: each path maps to `{policy, source, manual_edits}` plus any policy-specific fields. Computing and enforcing this map is a future-tool concern; the **map shape is the kernel contract** today.

```yaml
surfaces:
  src/generated/api-client:
    policy: generated
    source: .swarm/sources/interfaces/payments.openapi.yaml
    manual_edits: forbidden

  src/auth/client.ts:
    policy: governed
    source: .swarm/sources/specs/auth/auth-refresh.swarm.md
    manual_edits: allowed_with_trace

  src/legacy:
    policy: observed
    source: none
    manual_edits: allowed
    requires_audit: true
```

The `source` field names the artifact that owns the surface: for `generated`, the artifact it is emitted from; for `governed`, the `*.swarm.md` spec that owns its intent; for `observed`, `none` (with `requires_audit: true` marking the on-ramp). This is the per-path projection of the source/status/generated separation Swarm holds for the whole workspace.

### `governed` + `allowed_with_trace` is the drift contract

The `governed` policy ties directly to the staleness rule:

- **An edit to a `governed` surface without an obligation trace is drift.** A `governed` surface lives in the `per_surface_hash[]` of the proofs whose evidence path traversed it. When it changes, condition (b) and the participation rule fire `STALE` on every obligation that exercised it. A change that carried an obligation id and emitted a fresh trace resolves that `STALE` via re-run (reconcile resolution 1); a change with *no* trace leaves the binding `STALE` against the merge gate with nothing to reconcile it. The trace is therefore not bookkeeping — it is the only thing that distinguishes a sanctioned edit from undetected drift.
- **It is the `WRITES`/`READS` write-surface model projected onto files.** A `governed` surface is the file-level shadow of an obligation's declared write surface: the obligation declares `WRITES <surface>`, the policy map binds that surface to a path and to its owning spec, and the same hash used for write-side conflict serialization is the hash used for staleness. The policy adds no new enforcement primitive; it names, per path, which obligations are permitted to write there. An edit reaching a `governed` path outside any obligation's `WRITES` set is both an unscoped write and an untraced governed edit — the same event seen through the orchestration lens and the drift lens.

A passing test does **not** discharge the obligation. A `governed` edit that ships with a green build has not, by that fact, satisfied its obligation: a bundled suite can pass while the patch is wrong. This is why `allowed_with_trace` requires a trace bound to the obligation's `VERIFY BY` proof, not merely a passing `cmd*`, and why the participation rule refuses to call a surface fresh just because its hash matched. Schema-valid output and green tests are *shape*, not truth — the trace exists so a reviewer can ask whether the obligation was met, not only whether the build was.

## Related

- [Workspace Model](../model/workspace.md) — the five source-code surface policies (`generated`/`governed`/`observed`/`external`/`deprecated`) and the source/status/generated workspace split.
- [Proof Types and the `VERIFY BY` Binding](./proof-types.md) — the nine proof types and the binding grammar whose last `PASS` records the provenance schema above.
- [`verify` pass](../passes/verify.md) — the pass that records a `PASS` and its provenance hashes.
- [`review` pass](../passes/review.md) — where a `STALE` or `CONTRADICTED` verdict routes for reconciliation.
- [`trace` artifact](../artifacts/trace.md) — the markdown carrier of the recorded hashes.
- [`review.md` artifact](../artifacts/review.md) — the verdict container that holds `VERDICT … (STALE …)` blocks.
- [Promotion Protocol](./promotion-protocol.md) — the merge gate a `STALE` binding blocks.
