# `trace.md` — implementation claims bound to evidence

A **trace** is the artifact in which an implementation pass *claims* which obligations it implemented and which it preserved, binds each claim to a verification-output reference, and records the drift-provenance a later staleness check needs. It is the input to judgment, never the judgment itself: a trace asserts "I did X and here is the proof reference"; the `review` pass decides whether that claim holds against the source spec, the diff, and the proof evidence. In the obligation graph, the trace is the edge from an obligation to the change that purports to satisfy it — the only thing that distinguishes a sanctioned edit to a governed surface from undetected drift.

Swarm ships **no runtime**. Every hash, verdict, and surface reference in a trace is a content-hash *contract* a future tool computes; today the trace is written by a human or an agent in markdown and re-checked by hand or by CI scaffolding that does not yet exist. Nothing in this page is automatically enforced.

**Where a trace lives ([ADR-0050](../adrs/0050-swarm-is-a-spec-repo-discipline.md)).** In a **code repo**, the **PR is the default trace** — it names the obligation ids it satisfies, CI is the proof, and review is the verdict; this page's structured `trace.md` is **opt-in**, for audit/compliance or once a tool consumes it, and is **not** written into a pristine code repo by default. The contract below is what such a structured trace MUST satisfy *when you do keep one* (or in a co-located repo); a durable trace outcome can also be contributed back to the spec repo as a linked PR.

## Purpose and epistemic stance

A trace asserts **claims plus evidence references**. It is a record of *what was done* in one pass and *where the proof of it lives* — not a verdict, not intent, and not a discovery.

What a trace MUST do:

- Carry one or more `TRACE` blocks, each naming the obligation it `IMPLEMENTS`, the constraints/invariants it `PRESERVES`, the surfaces it `CHANGED`, and the `PROOF` reference (the verification output the claim rests on).
- Record, per binding, the drift-provenance the staleness join depends on, so a future tool (or a reviewer today) can later detect when the obligation text or a touched surface has moved.
- Account for every change: a change outside the assigned obligations MUST appear in the unassigned-changes table with a reason and an authorizing ID, or the trace is dishonest about its scope.

What a trace MUST NOT do:

- **It MUST NOT pronounce a verdict.** A `TRACE` records a `PASS`-shaped *claim* and a proof reference, but the authoritative judgment is a `VERDICT` block emitted by the `review` pass into a [`review.md`](review.md), evaluated against the spec and the diff — never against the trace's self-report. A self-graded `PASS` in a trace is a claim awaiting review, not a discharged obligation.
- **It MUST NOT carry obligation blocks.** A trace contains no `REQ`, `CONSTRAINT`, `INVARIANT`, or `INTERFACE` blocks of its own. It references obligation IDs that already exist in a `*.swarm.md` source spec; it does not author new intent. A discovery made while tracing is promoted out (see the promotion-items section), not encoded as a fresh obligation in the trace.
- **It MUST NOT re-bless a binding by re-stamping a hash.** Provenance hashes are recorded as the byproduct of a real proof run. Rewriting a recorded hash without re-running the bound proof manufactures a false `PASS` and is forbidden — drift is resolved by a genuine re-run, an obligation amendment, or a code fix, never by editing the trace's hash in place.
- **It MUST NOT introduce a green build as discharge.** A passing `cmd*` is *shape*, not truth. The `PROOF` reference must point at the proof bound to the obligation's `VERIFY BY`, not merely at an aggregate green suite; a bundled suite can pass while the patch is wrong.

A `TRACE` block embedded in a trace is **quoted SOL data** — it MUST obey the SOL block grammar (the same grammar that governs obligation blocks in a source spec), even though the surrounding file is a working artifact, not a compiler-visible spec.

## Filename and placement

The `.swarm.` infix discriminates **compiler-visible** files (parsed or emitted by the compiler — they carry `.swarm.` before the final extension) from **working artifacts** (plain `.md`, governed by an artifact contract rather than the SOL grammar). The trace straddles this line in a specific way:

| Form | Filename | Class | When |
| --- | --- | --- | --- |
| Copyable skeleton | `trace.md` | working (plain) | The shipped template — the uninstantiated form. |
| Built instance | `trace.md` or `*.swarm.trace.md` | working / compiler-visible | A trace produced for a specific built spec; the `*.swarm.trace.md` name is permitted when the instance is tracked as a compiler-emitted artifact alongside the spec it traces. |

The template itself is the only *plain* form; a built instance MAY take the `*.swarm.trace.md` name so a future tool can select traces by the stable, greppable infix without inspecting content. The hashes a trace records live in the markdown trace and/or the emitted IR (`*.swarm.ir.json`); both are contract shapes today, computed by no shipped tool.

In an adopted `.swarm/` workspace, a trace is an **execution packet** — generated/derived from a source spec and a task, recreatable from them — and lives under:

```text
.swarm/
  sources/        # DESIRED truth (specs, audits, findings) — a trace does NOT live here
  generated/
    traces/       # *.swarm.trace.md / trace.md — implementation claims (THIS artifact)
    tasks/        # the task.md pass frame the trace's source_task points back to
    reviews/      # the review.md that judges this trace
  status/         # OBSERVED satisfaction + drift — derived from reviews, not the trace
```

A trace never belongs in `sources/`: it asserts no durable intent. It belongs in `generated/traces/` because it is a derivable record of one pass over already-existing intent.

## Required sections and fields, in order

### Frontmatter contract

| Field | Meaning |
| --- | --- |
| `type: trace` | Fixes the artifact class. Required. |
| `id` | Stable identifier for this trace (conventionally `{{slug}}-trace`). Required. |
| `source_task` | Path to the `task.md` pass frame this trace was produced under (e.g. `.swarm/generated/tasks/{{slug}}.md`). Required. |
| `source_spec` | The `*.swarm.md` source spec whose obligations this trace claims against (e.g. `{{spec-id}}.swarm.md`). Required. |
| `created` | Recording timestamp. This is where the "when" of the trace lives — the provenance fields below carry *content state*, never a timestamp. Required. |

### Body sections (in order)

| Section | Meaning |
| --- | --- |
| `## Claimed implementation` | One or more `TRACE` blocks. Each: `IMPLEMENTS <obligation-id>`, `PRESERVES <constraint/invariant-id>`, `CHANGED <surface/path>`, `PROOF <verification output reference>`. This is the trace's core payload. |
| `## Provenance` | The closed seven-field drift-provenance record, **per binding** — the join that flips a `PASS` to `STALE` when source or surface drifts. Fields below. |
| `## Verification matrix` | One row per obligation ID: required proof → actual proof → core status. Status is one of the four core verdicts (`PASS` / `FAIL` / `BLOCKED` / `UNVERIFIED`). An empty status cell in a *built* trace is read as `UNVERIFIED`. |
| `## Unassigned changes` | Any change outside the assigned obligations, each with a reason and an authorizing ID (an `AC`/`C`/`I`/`IF` id), or the single value `none`. |
| `## Promotion items` | Discoveries surfaced during the pass, each with a target and a promotion status. These leave the trace to become findings, ADRs, or new obligations elsewhere — they are not encoded as obligations in the trace. |

### The provenance record (the seven fields, per binding)

Every binding's **last `PASS`** records exactly this closed seven-field set — the single trace-provenance schema the verdict model, the drift check, and the memory model all read from, so they never diverge:

| Field | Meaning |
| --- | --- |
| `source_hash` | Content hash of the obligation source — the exact bytes of the obligation block in the `*.swarm.md` spec — at the time of the `PASS`. A change here means *intent moved*. |
| `per_surface_hash[]` | One `{surface, hash, exercised}` entry per declared `WRITES` surface **and** per `READS` surface the proof actually exercised. `exercised: true` iff the proof executed or analysed that surface; the exercised subset is the proof's evidence path. A change to a participating (exercised) surface means *code moved*. |
| `adapter` | The `cmd*` slot the proof resolved through. A rebind/retarget/removal of this adapter is itself a drift condition. |
| `verdict` | The core verdict recorded — `PASS` for any drift-trackable binding. |
| `tier` | The proof type (one of the nine proof types), the same value recorded as the binding's IR `type`. |
| `origin_obligations[]` | The obligation IDs this `PASS` judged. |
| `origin_traces[]` | The trace(s) that produced the change being judged. |

Two optional adjuncts MAY extend a verdict's provenance without altering this base — `oracle_adequacy` (when oracle adequacy is recorded) and `judge` (when a manual/judge-rendered verdict is recorded). They are optional extensions on the same record, not separate schemas.

**Why provenance is load-bearing.** A `PASS` is a statement about a moment: the obligation said X, the code did Y, the proof confirmed Y satisfies X. A prior `PASS` becomes `STALE` (a lifecycle decorator, recorded at review time, not claimed here) when **any** of four conditions holds: (a) the obligation `source_hash` changed; (b) a declared write surface in `per_surface_hash[]` changed; (c) an exercised `READS` surface on the evidence path changed; or (d) the bound `adapter` changed. `STALE` blocks the merge gate until reconciled — by re-running the proof, amending the obligation, or fixing the code. Recording the provenance is what makes all four detectable without a runtime; omitting a field blinds the check. (A surface the proof never exercised — `exercised: false` — does not participate in freshness on that ground alone, so an unrelated lockfile bump does not falsely mark an obligation stale; an in-place behavioral edit to an exercised surface does, regardless of that surface's policy attribute.)

## Copyable template

The copyable skeleton is the framework template at **`starter-kit/.agents/templates/trace.md`** (installed into an adopted project at `.swarm/kernel/templates/trace.md`). Copy that file to start a new trace; this page is its contract. A shipped, uninstantiated template MAY leave `{{...}}` placeholders, but a *built* trace MUST NOT leave a binding clause as a `{{...}}` placeholder, and an unfilled `VERIFY BY`/`PROOF` clause in a built trace is a `SOL-V001` defect.

## Related

- [`spec.md`](spec.md) — the `*.swarm.md` source spec that owns the obligations a trace claims against; the trace's `source_spec` points back to it.
- [`task.md`](task.md) — the lowered pass frame a trace is produced under; the trace's `source_task` points back to it, and its assigned obligations bound the trace's scope.
- [`review.md`](review.md) — the verdict record that *judges* this trace, emitting one `VERDICT` per required binding and recording any `STALE`/`WAIVED`/`CONTRADICTED` lifecycle decorator.
- [`finding.md`](finding.md) — where a durable discovery from a trace's promotion-items table lands.
- [`adr.md`](adr.md) — where a discovery that is an immutable decision lands.
- [implement pass](../passes/implement.md) — the pass that produces a trace (records `TRACE` claims and runs bound proofs to gather evidence).
- [verify pass](../passes/verify.md) — re-runs the bound proofs deterministically over the trace's claims.
- [review pass](../passes/review.md) — consumes the trace and emits the authoritative verdicts.
