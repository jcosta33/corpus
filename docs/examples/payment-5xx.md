# Walkthrough: `payment-5xx`, end to end

> One obligation set carried through all nine Swarm passes in order — author, lint, improve, lower, decompose, implement, verify, review, promote — watching a payment-processor 5xx handler go from a draft spec with a self-contradiction, a vague-quality clause, and an open blocking question to a merged, promoted finding. This is a proof-heavy positive walkthrough; identifiers, content hashes, and verdicts are stable from the first stage to the last, so the whole page reads as a single run.

## What you are looking at

`payment-5xx` is a small, complete feature: when the payment processor returns a 5xx, the service retries the charge a bounded number of times under the same idempotency key, so a transient outage is absorbed without ever charging the customer twice. It is small enough to read in one sitting and rich enough to exercise the parts of the pipeline that `auth-refresh` does not: a `MUST`-vs-`MUST NOT` semantic contradiction on a single trigger, a high-risk vague-quality phrase ("handle failures gracefully") with no observable criterion, a `[blocking]` question hanging over the retry obligation that would halt lowering if it survived — and, at the merge gate, a `monitor` proof from production that *disagrees* with a green harness test, driving a `CONTRADICTED` → `BLOCKED` → reconcile → `PASS` arc rather than a staleness reconcile.

Nothing here is run by a tool. Swarm ships **no runtime** — every artifact below is inert markdown, the oracle a human or agent reads and writes by hand while following the stdlib pass guides. The IR and trace provenance are *contracts a future tool would emit against*, produced here by hand so the chain is legible. Read this page top to bottom; each stage feeds the next.

The default pass order, which this page follows exactly:

```text
author -> lint -> improve -> lower -> decompose -> implement -> verify -> review -> promote
```

---

## Stage 1 — `author`: the human writes the spec

`author` is the only stage where a human writes a `.swarm.` artifact directly. The output is a `spec.swarm.md`: frontmatter plus prose sections (`## Intent`, `## Interfaces`, `## Obligations`, `## Invariants`, `## Questions`) interleaved with typed SOL blocks. The author is not expected to write clean obligations on the first pass — that is what `lint` and `improve` are for. The frontmatter carries the three separate version fields: `swarm_language` (which grammar and lint codes apply), `aps_version` (the prose standard), and `spec_version` (the SemVer of this spec's content). They are never merged.

Note the deliberate flaws planted here: `AC-020` says the service `MUST retry the charge` and on the same trigger `MUST NOT retry the charge` — a self-contradiction; `AC-021` says the service `MUST handle failures gracefully`, a high-risk quality word with no observable criterion; and `Q-001` is a `[blocking]` question hanging over `AC-020`, asking whether a 503 should be retried automatically or surfaced for a manual retry. `AC-021` already carries a `VERIFY BY`; `AC-020` and `I-001` are authored without one and gain theirs at `improve`.

```sol
---
type: spec
swarm_language: SOL/0.1
aps_version: 0.1
spec_version: 0.1.0
id: payment-5xx
status: draft
---

# Spec: Payment-processor 5xx handling

## Intent
When the payment processor returns a 5xx the service retries the charge a bounded
number of times under the same idempotency key, so a transient processor outage is
absorbed without ever charging the customer twice.

## Interfaces

INTERFACE IF-001:
`chargeCard` ACCEPTS `ChargeRequest` RETURNS `Charge | ProcessorError`
ERRORS:
  - processor-5xx
  - idempotency-conflict
OWNED BY payments-service
VERIFY BY contract:cmdContract:charge-card-contract

## Obligations

REQ AC-020:
WHEN the processor returns a 5xx
THE payments service MUST retry the charge
AND THE payments service MUST NOT retry the charge

REQ AC-021:
WHEN a payment attempt fails
THE payments service MUST handle failures gracefully
VERIFY BY test:cmdTest:server/tests/payment-fail.spec.ts#surfaces-error

## Invariants

INVARIANT I-001:
the same idempotency key MUST NOT result in more than one captured charge

## Questions

QUESTION Q-001 [blocking]:
Should a 503 from the processor be retried automatically or surfaced to the user for a manual retry?
AFFECTS AC-020
```

---

## Stage 2 — `lint`: diagnose, don't touch

`lint` reads the spec and emits SARIF-shaped diagnostic records in the unified `SOL-<LAYER><NNN>` namespace, without changing a single character. Each record names the closed `improve` op (or direct edit) that repairs it, so the next stage is mechanical rather than open-ended. Two diagnostics fire on the authored source, both BLOCKING because each one changes *what* gets built rather than merely how the text reads. The `severity` here is the authoring-layer value (`BLOCKING`/`ADVISORY`); when this lowers into the IR's `diagnostics[]` array it becomes the `level` value (`error`/`warning`/`note`).

```text
SOL-M002  BLOCKING  layer=M  AC-020:L2-L3
  message: AC-020 carries opposed modalities on one contradiction key —
           MUST retry the charge AND MUST NOT retry the charge, same actor + trigger.
  suggest: improve op DECONFLICT — resolve per source authority or raise to amendment.

SOL-P005  BLOCKING  layer=P  AC-021:L2 ("THE payments service MUST handle failures gracefully")
  message: vague-quality high-risk word ("gracefully") in a binding clause with
           no same-line observable criterion.
  suggest: improve op CONCRETIZE or QUANTIFY — name the observable behavior and threshold.
```

Beyond the two blocking diagnostics, `lint` records a note about the blocking question: `Q-001` is `[blocking]` and `AFFECTS AC-020`, so `AC-020` MUST NOT reach the `lower` pass until the question is resolved. A blocking `QUESTION` that *does* reach `lower` is itself a hard error (`SOL-O003`, blocking-question-reaches-lowering). The question is a gate, not a suggestion — and because `Q-001` is resolved at `improve`, `SOL-O003` never fires downstream; it is the risk the open question *would* have raised had it survived to lowering. `SOL-M002` fires on **exact contradiction-key match only** — the two clauses share the normalized actor, trigger, and surface set and carry opposed modalities; this is the deterministic case, not paraphrase or entailment.

The missing `AC-020` and `I-001` bindings are not pinned as the headline defect here: they are repaired in the same `improve` pass that deconflicts and concretizes (via `BIND`, below), so the seeded blocking set is just the two codes above plus the blocking-question note. `AC-021` already carries its `VERIFY BY` from the authored source; `IF-001` carries its `contract` binding too.

---

## Stage 3 — `improve`: apply the closed ops, preserve intent

`improve` applies the named ops — here `DECONFLICT`, `CONCRETIZE`, and `BIND` — each strictly semantics-preserving. An op may resolve a contradiction, make a clause observable, or attach a proof; it may never change what the author meant. Anything that *would* change intent routes to amendment or review, never to `improve`. Separately, the spec owner resolves `Q-001` out of band (decision: retry automatically up to the bound, then surface a 502 to the user); that resolution is recorded and `Q-001` is removed, which unblocks `AC-020`. Only the changed blocks are shown.

```sol
REQ AC-020:
WHEN the processor returns a 5xx
THE payments service MUST retry the charge at most 3 times under the same idempotency key
VERIFY BY test:cmdTest:server/tests/payment-5xx.spec.ts#retries-bounded
DEPENDS ON IF-001
WRITES server/src/payments/charge.ts
RISK high

REQ AC-021:
WHEN the retry budget for a charge is exhausted
THE payments service MUST return HTTP 502 with a structured `processor-unavailable` error body within the 30s request budget
VERIFY BY test:cmdTest:server/tests/payment-fail.spec.ts#surfaces-502
DEPENDS ON IF-001
WRITES server/src/payments/charge.ts
RISK medium

INVARIANT I-001:
the same idempotency key MUST NOT result in more than 1 captured charge
VERIFY BY monitor:cmdMonitor:dashboards/payments/duplicate-captures#zero_double_captures
```

Each diagnostic maps to exactly one repair. `DECONFLICT` resolved `AC-020`'s `MUST retry` / `MUST NOT retry` collision per source authority: the owner's intent was a *bounded* retry, never an unconditional one, so `AC-020` becomes a single coherent `MUST retry … at most 3 times under the same idempotency key` and the no-double-charge concern moves onto its own `INVARIANT` (`I-001`), clearing `SOL-M002` — and because this is a resolution per source authority rather than an intent change, it stays inside `improve` and does not escalate to amendment. `CONCRETIZE` replaced "handle failures gracefully" with an observable criterion (return HTTP 502 with a structured `processor-unavailable` body inside the 30s budget), clearing `SOL-P005`; it also reworded `AC-021`'s selector from `surfaces-error` to `surfaces-502` to match. `BIND` attached the missing bindings — a `test` proof to `AC-020` and a `monitor` proof to `I-001`. The `monitor` choice is the load-bearing one: no harness can witness a *real* duplicate capture, so the honest oracle for "the same idempotency key never captures twice" is the production duplicate-captures dashboard, not a unit test. With both diagnostics cleared and `Q-001` closed, the spec is ready to lower.

---

## Stage 4 — `lower`: emit the typed IR

`lower` projects the normalized spec into the typed intermediate representation, `payment-5xx.swarm.ir.json`. Three things happen mechanically: uppercase SOL surface keywords become `snake_case` IR fields (`VERIFY BY` becomes `verify_by`, `DEPENDS ON` becomes a `depends_on` edge); every relationship moves into `edges[]`, the single source of relationship truth, never duplicated as a node scalar; and node ids become namespaced. Crucially, `lower` halts on any unresolved blocking diagnostic or open blocking `QUESTION` (`SOL-O003`); the IR below exists *only because* `improve` deconflicted `AC-020` and closed `Q-001` first.

```json
{
  "meta": {
    "id": "payment-5xx",
    "title": "Payment-processor 5xx handling",
    "language": "SOL/0.1",
    "version": "0.1.0",
    "status": "draft"
  },
  "nodes": [
    {
      "id": "INTERFACE.payment-5xx.IF-001",
      "kind": "INTERFACE",
      "clauses": { "accepts": "ChargeRequest", "returns": "Charge | ProcessorError" },
      "owner": "payments-service",
      "verify_by": [
        { "type": "contract", "adapter": "cmdContract",
          "ref": "contracts/charge-card.pact", "selector": "chargeCard", "gate": "required" }
      ],
      "status": "UNVERIFIED",
      "source": { "file": "payment-5xx.swarm.md", "line_start": 32, "line_end": 39,
                  "content_hash": "sha256:2c8d…b1" }
    },
    {
      "id": "REQ.payment-5xx.AC-020",
      "kind": "REQ",
      "modality": "MUST",
      "clauses": { "trigger": { "kw": "WHEN", "expr": "the processor returns a 5xx" },
                   "subject": "payments service",
                   "predicate": "retry the charge at most 3 times under the same idempotency key" },
      "risk": "high",
      "writes": ["server/src/payments/charge.ts"],
      "verify_by": [
        { "type": "test", "adapter": "cmdTest",
          "ref": "server/tests/payment-5xx.spec.ts",
          "selector": "retries-bounded", "gate": "required" }
      ],
      "status": "UNVERIFIED",
      "source": { "file": "payment-5xx.swarm.md", "line_start": 42, "line_end": 45,
                  "content_hash": "sha256:4f6a…e2" }
    },
    {
      "id": "REQ.payment-5xx.AC-021",
      "kind": "REQ",
      "modality": "MUST",
      "clauses": { "trigger": { "kw": "WHEN", "expr": "the retry budget for a charge is exhausted" },
                   "subject": "payments service",
                   "predicate": "return HTTP 502 with a structured processor-unavailable error body within the 30s request budget" },
      "risk": "medium",
      "writes": ["server/src/payments/charge.ts"],
      "verify_by": [
        { "type": "test", "adapter": "cmdTest",
          "ref": "server/tests/payment-fail.spec.ts",
          "selector": "surfaces-502", "gate": "required" }
      ],
      "status": "UNVERIFIED",
      "source": { "file": "payment-5xx.swarm.md", "line_start": 47, "line_end": 50,
                  "content_hash": "sha256:9a01…7c" }
    },
    {
      "id": "INVARIANT.payment-5xx.I-001",
      "kind": "INVARIANT",
      "modality": "MUST NOT",
      "clauses": { "subject": "the same idempotency key",
                   "predicate": "result in more than 1 captured charge" },
      "verify_by": [
        { "type": "monitor", "adapter": "cmdMonitor",
          "ref": "dashboards/payments/duplicate-captures",
          "selector": "zero_double_captures", "gate": "required" }
      ],
      "status": "UNVERIFIED",
      "source": { "file": "payment-5xx.swarm.md", "line_start": 54, "line_end": 55,
                  "content_hash": "sha256:b730…5d" }
    }
  ],
  "edges": [
    { "from": "REQ.payment-5xx.AC-020", "to": "INTERFACE.payment-5xx.IF-001",
      "type": "depends_on", "hard": true },
    { "from": "REQ.payment-5xx.AC-021", "to": "INTERFACE.payment-5xx.IF-001",
      "type": "depends_on", "hard": true },
    { "from": "REQ.payment-5xx.AC-020", "to": "INVARIANT.payment-5xx.I-001",
      "type": "affects", "hard": false }
  ],
  "diagnostics": [],
  "provenance": { "hash": "sha256:e91f…40", "compiler_version": null,
                  "compiled_at": "2026-06-01T00:00:00Z" }
}
```

Every node enters `lower` at `status: UNVERIFIED` — the default before any verdict exists. `I-001` lowers with `modality: MUST NOT` (it prohibits a second captured charge on the same key). Only `AC-020 affects I-001` is an `affects` edge — `AC-021` surfaces the exhaustion error and does not touch the capture path, so it carries no edge to the invariant. `compiler_version` is `null` because no tool is shipped; the IR is the contract a future tool would emit against, produced here by hand.

---

## Stage 5 — `decompose` and `implement`: project a work packet, then build it

`decompose` projects the IR into a `task.md` work packet, and `implement` executes it. The packet's write surfaces MUST be a subset of the assigned obligations' `WRITES` — the two-tier lowering rule. A packet that writes a path outside its declared `write_surfaces` is the hard error `SOL-O005` (owned-path-outside-write-surface). Both obligations write the same surface (`server/src/payments/charge.ts`), so they cannot run in parallel against it; the decomposer assigns them to one serialized packet rather than splitting them across parallel tasks, satisfying the safe-parallelism predicate (no two parallel packets share a write surface — the defect `SOL-O001` guards). `I-001` is verified by a `monitor` proof, which has no merge-time execution: a production dashboard cannot be "run" inside the packet, so its row stays `pending` here and resolves at the verify/review stage from the production observation, not from this build. Only the load-bearing frame is shown; the verification matrix is filled in by `implement`/`verify` as work lands.

```text
---
type: task
id: payment-5xx-charge
status: active
task_kind: feature
source: .swarm/sources/specs/payment-5xx.swarm.md
assigned_obligations: [AC-020, AC-021]
invariants: [I-001]
interfaces: [IF-001]
write_surfaces: [server/src/payments/charge.ts]
verification_bindings:
  - AC-020: test:cmdTest:server/tests/payment-5xx.spec.ts#retries-bounded
  - AC-021: test:cmdTest:server/tests/payment-fail.spec.ts#surfaces-502
  - I-001:  monitor:cmdMonitor:dashboards/payments/duplicate-captures#zero_double_captures
parallel_group: payments-edits
blocked_by: []
---

# Task: Implement payment-5xx retry and idempotency behavior

## Scope

### In
- Implement AC-020 (bounded retry under the same idempotency key) and AC-021 (502 on
  budget exhaustion), and preserve I-001 (no double capture) within server/src/payments/charge.ts.

### Out
- Do not implement unassigned obligations.
- Do not change behavior outside server/src/payments/charge.ts.

## Verification matrix
| Obligation | Required proof                | Actual proof                                         | Status  |
| ---------- | ----------------------------- | ---------------------------------------------------- | ------- |
| AC-020     | test:#retries-bounded         | payment-5xx.spec.ts passed                           | pass    |
| AC-021     | test:#surfaces-502            | payment-fail.spec.ts passed                          | pass    |
| I-001      | monitor:#zero_double_captures | duplicate-captures dashboard (no execution at merge) | pending |
```

---

## Stage 6 — `verify`: record the trace and its provenance

`verify` records a `TRACE` block plus the provenance that the drift join depends on. The `TRACE` declares what it `IMPLEMENTS`, what it `PRESERVES`, what surfaces it `CHANGED`, and one `PROOF` line per binding with its result. The provenance table carries the canonical seven fields: `source_hash` (echoing the IR node's `content_hash`), `per_surface_hash[]` (each `{surface, hash, exercised}`), `adapter`, `verdict`, `tier` (the proof *type*, never a RISK value), `origin_obligations[]`, and `origin_traces[]`. These hashes are what later detects staleness — they are the load-bearing part of the artifact.

The `AC-020`/`AC-021` `test` proofs PASS in the harness. But the `I-001` `monitor` proof reports **FAIL**: the production duplicate-captures dashboard observed a non-zero double-capture count over its window — runtime evidence the harness never saw. The harness test (`AC-020`) and the production monitor (`I-001`) thus disagree about the *same* no-double-charge property, which `review` will decorate `CONTRADICTED`.

```text
---
type: trace
id: payment-5xx-charge-trace
source_task: .swarm/generated/tasks/payment-5xx-charge.md
source_spec: .swarm/sources/specs/payment-5xx.swarm.md
---

# Trace: payment-5xx charge

TRACE T-001:
IMPLEMENTS AC-020, AC-021
PRESERVES I-001
CHANGED server/src/payments/charge.ts
PROOF test:cmdTest:server/tests/payment-5xx.spec.ts#retries-bounded passed
PROOF test:cmdTest:server/tests/payment-fail.spec.ts#surfaces-502 passed
PROOF monitor:cmdMonitor:dashboards/payments/duplicate-captures#zero_double_captures failed

## Provenance
| binding | source_hash      | per_surface_hash[]                       | adapter    | verdict | tier    | origin_obligations | origin_traces |
| ------- | ---------------- | ---------------------------------------- | ---------- | ------- | ------- | ------------------ | ------------- |
| AC-020  | sha256:4f6a…e2   | {charge.ts, sha256:6b22…9f, exercised}   | cmdTest    | PASS    | test    | [AC-020]           | [T-001]       |
| AC-021  | sha256:9a01…7c   | {charge.ts, sha256:6b22…9f, exercised}   | cmdTest    | PASS    | test    | [AC-021]           | [T-001]       |
| I-001   | sha256:b730…5d   | {charge.ts, sha256:6b22…9f, observed}    | cmdMonitor | FAIL    | monitor | [I-001]            | [T-001]       |
```

Note the `monitor` row records the surface as `observed`, not `exercised`: a production dashboard witnesses the running surface rather than driving it under a harness.

---

## Stage 7 — `review`: per-obligation verdicts and the merge gate

`review` (run under the `skeptic` profile) consumes the trace and emits one `VERDICT` line per obligation. Each verdict carries a core value — `PASS`, `FAIL`, `BLOCKED`, or `UNVERIFIED` — optionally decorated with a lifecycle value. The reviewer judges the trace claims against the source spec, the diff, and the proof evidence — not against the trace's self-report. `AC-021` comes back as a clean `PASS`. `AC-020` and `I-001` are the interesting pair: the bounded-retry `test` PASSed, but the production `monitor` FAILed, and both proofs speak to the *same* no-double-charge property, so each verdict carries the `CONTRADICTED` decorator with the two conflicting evidence refs. Per the proof-strength preorder `model > property | contract > test > static > manual | monitor`, the `test` PASS is the *working assumption* over the `monitor` FAIL — but a working assumption does not close the contradiction. A `CONTRADICTED` on any required obligation BLOCKS the gate until it is reconciled.

```text
---
type: review
id: payment-5xx-charge-review
source_trace: .swarm/generated/traces/payment-5xx-charge-trace.md
source_spec: .swarm/sources/specs/payment-5xx.swarm.md
---

# Review: payment-5xx charge

## Per-obligation verdicts

VERDICT AC-020: PASS (CONTRADICTED by review: bounded-retry test and the production duplicate-captures monitor disagree about the no-double-charge property)
REASON Bounded-retry harness test PASSes, but the production monitor observes duplicate captures on the same key; the two proofs disagree about the no-double-charge property.
EVIDENCE test:cmdTest:payment-5xx.spec.ts#retries-bounded passed
EVIDENCE monitor:cmdMonitor:duplicate-captures#zero_double_captures failed

VERDICT AC-021: PASS
REASON Budget-exhaustion test asserts a 502 with the structured `processor-unavailable` body returned inside the 30s budget.
EVIDENCE payment-fail.spec.ts output in review log

VERDICT I-001: FAIL (CONTRADICTED by review: the production duplicate-captures monitor contradicts the bounded-retry test on the no-double-charge property)
REASON Production duplicate-captures count is non-zero over the window, contradicting the harness test that exercises a single-flight retry path.
EVIDENCE monitor:cmdMonitor:duplicate-captures#zero_double_captures failed
EVIDENCE test:cmdTest:payment-5xx.spec.ts#retries-bounded passed

## Final verdict
Gate: every required obligation is PASS or WAIVED; none STALE/CONTRADICTED/FAIL/BLOCKED/UNVERIFIED.
Result: BLOCKED — AC-020 and I-001 are CONTRADICTED (and I-001's core is FAIL). The `test`
PASS outranks the `monitor` FAIL in the proof-strength preorder and is the working assumption,
but a CONTRADICTED required obligation blocks the gate until the disagreement is reconciled —
contradiction is never resolved by picking the more convenient result.
```

Each `CONTRADICTED` verdict carries *both* conflicting evidence lines, in priority order: the verdict's own proof first, then the proof it disagrees with. `AC-020` (a `PASS` decorated `CONTRADICTED`) leads with the green `test`; `I-001` (a `FAIL` decorated `CONTRADICTED`) leads with the red `monitor`. That two-line evidence pairing is what makes the disagreement auditable — neither side is silently dropped.

### The reconcile

The merge gate refuses to open while any required obligation is `CONTRADICTED`. A contradiction is **never** closed by silently trusting the stronger oracle's working assumption; it is closed only when both proofs agree after a recorded reconciliation. So the reconcile re-examines the *disagreeing* proofs rather than picking between them: the production double-captures came from concurrent requests racing before the idempotency key persisted — two requests for the same key both passed the not-yet-persisted-key check and each captured a charge. That is a real defect the single-in-flight harness test never exercised. The fix is a single-flight guard that persists the idempotency key before any capture; `server/src/payments/charge.ts` is edited, the bound `test` is extended with a concurrent-request case, and both proofs are re-run against the new surface. The `test` (with the concurrent case) PASSes and the `monitor` window now reports zero double captures. The two proofs now agree, so the `CONTRADICTED` decorator drops from `AC-020` and `I-001`, `I-001` resolves to a clean `PASS`, and with every required obligation `PASS` the gate opens — final outcome `PASS`.

---

## Stage 8 — `promote`: capture a durable finding

With the gate open and the work merged, `promote` captures a durable discovery from the task as a `finding.md` carrying full provenance: which obligations and traces it came from, the pass and profile that produced it, the reviewer or tool, a `content_hash`, a confidence level, and applies-when / does-not-apply-when bounds. The discovery here is the one the reconcile surfaced — a 5xx retry that does not *persist* a single idempotency key risks a double-capture, and the defect the harness never witnessed was concurrent requests racing before the key persisted; a single-flight guard that persists the key before any capture is what keeps a bounded retry (`AC-020`) from violating the no-double-charge invariant (`I-001`).

```text
---
type: finding
id: idempotency-key-required-on-5xx-retry
status: promoted
related_obligations: [AC-020, I-001]
confidence: high
---

# Finding: A 5xx retry without an idempotency key risks a double-capture

## Claim
Retrying a charge after a processor 5xx without carrying — and persisting — a single
idempotency key risks double-capturing the customer: the first attempt may have captured
before the 5xx was returned, and a naive retry captures again. The defect the harness test
never witnessed was concurrent requests racing before the key persisted; a single-flight
guard that persists the idempotency key before any capture is the lesson, and it is what
keeps a bounded retry (AC-020) from violating the no-double-charge invariant (I-001).

## Provenance
- origin_obligations: [REQ.payment-5xx.AC-020, INVARIANT.payment-5xx.I-001]
- origin_traces: [payment-5xx-charge-trace#T-001]
- pass: verify; profile: skeptic
- reviewer_or_tool: review.md (human review)
- content_hash: sha256:4f6a…e2
- confidence: high

## Applies when
- A charge is retried after a processor 5xx, and multiple requests for the same key can be in flight.

## Does not apply when
- The idempotency key is persisted before any capture and a single-flight guard serializes retries on that key.
```

The finding is then indexed in memory by a single `MAP` line carrying a "Load when" condition. No procedure is inlined in the index — the link points at the finding, and the index stays a thin router into memory.

```text
# memory/INDEX.md  (excerpt)
- Idempotency key required on 5xx retry — `.swarm/sources/findings/idempotency-key-required-on-5xx-retry.md`
  — Load when: implementing or reviewing a payment retry path that re-submits a charge after a 5xx.
```

That closes the loop: a draft spec with a self-contradiction, a vague-quality clause, and an open blocking question became a deconflicted and concretized spec, a typed IR, a scoped work packet, an implemented and traced change, a reviewed merge that BLOCKED on a production/harness contradiction and reconciled to PASS, and a promoted finding that future work on this surface will load on demand.

---

## Related

- Pass references, in pipeline order: [`author`](../passes/author.md), [`lint`](../passes/lint.md), [`improve`](../passes/improve.md), [`lower`](../passes/lower.md), [`decompose`](../passes/decompose.md), [`implement`](../passes/implement.md), [`verify`](../passes/verify.md), [`review`](../passes/review.md), [`promote`](../passes/promote.md)
- [Golden corpus](../reference/golden-corpus.md) — `payment-5xx` is the positive (`must-compile`) fixture this walkthrough draws from; its canonical defect class is the `MUST`-vs-`MUST NOT` contradiction (`SOL-M002`), the vague high-risk word (`SOL-P005`), and the blocking-question-at-lowering risk (`SOL-O003`)
- [Walkthrough: `auth-refresh`](./auth-refresh.md) — a pipeline-complete positive walkthrough in the same end-to-end style, whose merge gate reconciles a `STALE` obligation rather than a `CONTRADICTED` one
- [Drift and staleness](../reference/drift-and-staleness.md) — the `CONTRADICTED` decorator and the not-silent reconcile discipline the merge gate enforces here
- Artifact references for each stage's output: [`spec`](../artifacts/spec.md), [`task`](../artifacts/task.md), [`trace`](../artifacts/trace.md), [`review`](../artifacts/review.md), [`finding`](../artifacts/finding.md), [`memory`](../artifacts/memory.md)
- [Proof types and the `VERIFY BY` binding](../reference/proof-types.md) — the nine proof types the bindings above draw from (`contract` for the `INTERFACE`, `test` for the obligations, `monitor` for the invariant — the production observation that drives the contradiction)
