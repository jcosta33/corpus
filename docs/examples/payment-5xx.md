# Walkthrough: `payment-5xx` — what differs from `auth-refresh`

> A third positive run through all nine Swarm steps — author, lint, improve, lower, decompose, implement, verify, review, promote — for a payment-processor 5xx handler. The eight-stage skeleton, the no-runtime framing, and the stage-by-stage mechanics are identical to [`auth-refresh`](./auth-refresh.md); read that page first for the full walkthrough. This page spells out **only what `payment-5xx` teaches that `auth-refresh` does not**: a `MUST`-vs-`MUST NOT` semantic contradiction, a `monitor` proof that has no merge-time execution, and a merge gate that reconciles a `CONTRADICTED` obligation rather than a `STALE` one.

## What this case teaches

`payment-5xx` is a small, complete feature: when the payment processor returns a 5xx, the service retries the charge a bounded number of times under the same idempotency key, so a transient outage is absorbed without ever charging the customer twice. It exercises three things `auth-refresh` does not:

- **A `MUST`-vs-`MUST NOT` contradiction** (`AC-020`): the service `MUST retry the charge` and on the **same trigger** `MUST NOT retry the charge`. This is an M-layer defect (`SOL-M002`) — opposed modalities on one normalized actor + trigger + surface set — repaired by the `DECONFLICT` op. It fires on **exact contradiction-key match only**, the deterministic case, not paraphrase or entailment.
- **A vague-quality high-risk clause** (`AC-021`): `MUST handle failures gracefully` — the high-risk word "gracefully" with no observable criterion. This is the same `SOL-P005` family `auth-refresh`'s `I-001` tripped, but here on a binding obligation, repaired by `CONCRETIZE`.
- **A `monitor` proof** on `I-001`: a production duplicate-captures dashboard, the honest oracle for "the same idempotency key never captures twice" — because no harness can witness a *real* duplicate capture. A `monitor` has no merge-time execution, which drives the distinctive gate arc below.

Like `auth-refresh`, `payment-5xx` carries a `[blocking]` `Q-001` (here: should a 503 be retried automatically or surfaced for a manual retry?) that would raise `SOL-O003` if it reached `lower`; it is resolved at `improve` (decision: retry automatically up to the bound, then surface a 502). The three version fields, the SARIF diagnostics shape, the `snake_case` structured-form projection, and the indexed finding all work as the `auth-refresh` page describes.

## The authored spec (Stage 1)

```sol
REQ AC-020:
WHEN the processor returns a 5xx
THE payments service MUST retry the charge
AND THE payments service MUST NOT retry the charge

REQ AC-021:
WHEN a payment attempt fails
THE payments service MUST handle failures gracefully
VERIFY BY test:cmdTest:server/tests/payment-fail.spec.ts#surfaces-error

INVARIANT I-001:
the same idempotency key MUST NOT result in more than one captured charge

QUESTION Q-001 [blocking]:
Should a 503 from the processor be retried automatically or surfaced to the user for a manual retry?
AFFECTS AC-020
```

The interface `IF-001` (`chargeCard ACCEPTS ChargeRequest RETURNS Charge | ProcessorError`, owned by `payments-service`, `VERIFY BY contract:cmdContract:charge-card-contract`) carries its `contract` binding as authored. `AC-021` already carries a `VERIFY BY`; `AC-020` and `I-001` are authored without one and gain theirs at `improve` (via `BIND`).

## The two diagnostics (Stage 2)

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

The missing `AC-020`/`I-001` bindings are not pinned as a separate headline defect — they are repaired in the same `improve` step that deconflicts and concretizes (via `BIND`), so the seeded blocking set is the two codes above plus the blocking-question note for `Q-001`. Because `Q-001` is resolved at `improve`, `SOL-O003` never fires downstream; it is the risk the open question *would* have raised had it survived to structuring.

## The repair (Stage 3)

`improve` applies `DECONFLICT`, `CONCRETIZE`, and `BIND`, each semantics-preserving; the owner resolves `Q-001` out of band.

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

`DECONFLICT` resolved the `MUST retry` / `MUST NOT retry` collision **per source authority**: the owner's intent was a *bounded* retry, never an unconditional one, so `AC-020` becomes a single coherent `MUST retry … at most 3 times under the same idempotency key` and the no-double-charge concern moves onto its own `INVARIANT` `I-001`. Because this is a resolution per source authority rather than an intent change, it stays inside `improve` and does not escalate to amendment.

`CONCRETIZE` replaced "handle failures gracefully" with an observable criterion (return HTTP 502 with a structured `processor-unavailable` body inside the 30s budget) and reworded the selector from `surfaces-error` to `surfaces-502` to match. `BIND` attached the missing bindings. The `monitor` binding on `I-001` is the load-bearing choice: the honest oracle for "the same idempotency key never captures twice" is the production duplicate-captures dashboard, not a unit test.

## The structured form (Stage 4)

`lower` halts on any unresolved blocking diagnostic or open blocking `QUESTION` (`SOL-O003`); the structured form exists *only because* `improve` deconflicted `AC-020` and closed `Q-001` first. `I-001` lowers with `modality: MUST NOT`. Only `AC-020 affects I-001` is an `affects` edge — `AC-021` surfaces the exhaustion error and does not touch the capture path, so it carries no edge to the invariant. As on every page, every node enters at `status: UNVERIFIED` and `tool_version` is `null` (no tool is shipped).

## The work packet (Stage 5) — a pending monitor row

Both obligations write the same surface (`server/src/payments/charge.ts`), so they cannot run in parallel against it; the decomposer assigns them to **one serialized packet** rather than splitting across parallel tasks — satisfying the safe-parallelism predicate without any `SCOPE`-style split. The packet's `source` is `specs/payment-5xx/spec.swarm.md`.

The distinctive detail is `I-001`'s `monitor` proof: a production dashboard cannot be "run" inside the packet, so its verification-matrix row stays `pending` at merge and resolves at verify/review from the production observation, not from this build:

```text
## Verification matrix
| Obligation | Required proof                | Actual proof                                         | Status  |
| ---------- | ----------------------------- | ---------------------------------------------------- | ------- |
| AC-020     | test:#retries-bounded         | payment-5xx.spec.ts passed                           | pass    |
| AC-021     | test:#surfaces-502            | payment-fail.spec.ts passed                          | pass    |
| I-001      | monitor:#zero_double_captures | duplicate-captures dashboard (no execution at merge) | pending |
```

## The verify trace (Stage 6) — a harness/production disagreement

The `AC-020`/`AC-021` `test` proofs PASS in the harness. But the `I-001` `monitor` proof reports **FAIL**: the production duplicate-captures dashboard observed a non-zero double-capture count over its window — runtime evidence the harness never saw.

```text
TRACE T-001:
IMPLEMENTS AC-020, AC-021
PRESERVES I-001
CHANGED server/src/payments/charge.ts
PROOF test:cmdTest:server/tests/payment-5xx.spec.ts#retries-bounded passed
PROOF test:cmdTest:server/tests/payment-fail.spec.ts#surfaces-502 passed
PROOF monitor:cmdMonitor:dashboards/payments/duplicate-captures#zero_double_captures failed
```

In the provenance table the `monitor` row records the surface as `observed`, not `exercised`: a production dashboard witnesses the running surface rather than driving it under a harness. Its `adapter` is `cmdMonitor`, its `tier` is `monitor`, its `verdict` is `FAIL`. The harness test (`AC-020`) and the production monitor (`I-001`) thus disagree about the *same* no-double-charge property.

## The merge gate (Stage 7) — `CONTRADICTED`, not `STALE`

Where `auth-refresh` reconciles a `STALE` obligation, `payment-5xx` reconciles a `CONTRADICTED` one. `AC-021` is a clean `PASS`. `AC-020` and `I-001` each carry the `CONTRADICTED` decorator because both proofs speak to the same property and disagree:

```text
VERDICT AC-020: PASS (CONTRADICTED by review: bounded-retry test and the production duplicate-captures monitor disagree about the no-double-charge property)
REASON Bounded-retry harness test PASSes, but the production monitor observes duplicate captures on the same key; the two proofs disagree about the no-double-charge property.
EVIDENCE test:cmdTest:payment-5xx.spec.ts#retries-bounded passed
EVIDENCE monitor:cmdMonitor:duplicate-captures#zero_double_captures failed

VERDICT I-001: FAIL (CONTRADICTED by review: the production duplicate-captures monitor contradicts the bounded-retry test on the no-double-charge property)
REASON Production duplicate-captures count is non-zero over the window, contradicting the harness test that exercises a single-flight retry path.
EVIDENCE monitor:cmdMonitor:duplicate-captures#zero_double_captures failed
EVIDENCE test:cmdTest:payment-5xx.spec.ts#retries-bounded passed
```

Each `CONTRADICTED` verdict carries *both* conflicting evidence lines, in priority order — the verdict's own proof first, then the proof it disagrees with. `AC-020` (a `PASS` decorated `CONTRADICTED`) leads with the green `test`; `I-001` (a `FAIL` decorated `CONTRADICTED`) leads with the red `monitor`. That two-line pairing is what makes the disagreement auditable — neither side is silently dropped.

Per the proof-strength preorder `model > property | contract > test > static > manual | monitor`, the `test` PASS is the **working assumption** over the `monitor` FAIL — but a working assumption does not close the contradiction. The gate result is **BLOCKED**: a `CONTRADICTED` required obligation blocks the gate until the disagreement is reconciled — contradiction is never resolved by picking the more convenient result.

### The reconcile

A contradiction is **never** closed by silently trusting the stronger oracle's working assumption; it is closed only when both proofs agree after a recorded reconciliation. The reconcile re-examines the *disagreeing* proofs rather than picking between them: the production double-captures came from concurrent requests racing before the idempotency key persisted — two requests for the same key both passed the not-yet-persisted-key check and each captured a charge, a real defect the single-in-flight harness test never exercised. The fix is a single-flight guard that persists the idempotency key before any capture; `server/src/payments/charge.ts` is edited, the bound `test` is extended with a concurrent-request case, and both proofs are re-run against the new surface. The `test` (with the concurrent case) PASSes and the `monitor` window now reports zero double captures. The two proofs agree, so the `CONTRADICTED` decorator drops from `AC-020` and `I-001`, `I-001` resolves to a clean `PASS`, and with every required obligation `PASS` the gate opens — final outcome `PASS`.

## The promoted finding (Stage 8)

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

The finding is indexed in memory by a single `MAP` line carrying a "Load when" condition:

```text
# memory/INDEX.md  (excerpt)
- Idempotency key required on 5xx retry — `.agents/memory/findings/idempotency-key-required-on-5xx-retry.md`
  — Load when: implementing or reviewing a payment retry path that re-submits a charge after a 5xx.
```

That closes the loop: a draft spec with a self-contradiction, a vague-quality clause, and an open blocking question became a deconflicted and concretized spec, a typed structured form, a scoped work packet, an implemented and traced change, a reviewed merge that BLOCKED on a production/harness contradiction and reconciled to PASS, and a promoted finding that future work on this surface will load on demand.

## Related

- [Walkthrough: `auth-refresh`](./auth-refresh.md) — the full eight-stage walkthrough this page is a delta against; its merge gate reconciles a `STALE` obligation rather than a `CONTRADICTED` one.
- [Walkthrough: `checkout`](./checkout.md) — the multi-obligation atomicity case: a bundled obligation and a parallel write-surface conflict.
- [Drift and staleness](../reference/drift-and-staleness.md) — the `CONTRADICTED` decorator and the not-silent reconcile discipline the merge gate enforces here.
- [Proof types and the `VERIFY BY` binding](../reference/proof-types.md) — the nine proof types the bindings above draw from (`contract` for the `INTERFACE`, `test` for the obligations, `monitor` for the invariant — the production observation that drives the contradiction).
- [Golden corpus](../reference/golden-corpus.md) — `payment-5xx` is the positive (`must-pass`) fixture this walkthrough draws from; its canonical defect class is the `MUST`-vs-`MUST NOT` contradiction (`SOL-M002`), the vague high-risk word (`SOL-P005`), and the blocking-question-at-structuring risk (`SOL-O003`).
- Step references, in flow order: [`author`](../passes/author.md), [`lint`](../passes/lint.md), [`improve`](../passes/improve.md), [`lower`](../passes/lower.md), [`decompose`](../passes/decompose.md), [`implement`](../passes/implement.md), [`verify`](../passes/verify.md), [`review`](../passes/review.md), [`promote`](../passes/promote.md)
- Artifact references for each stage's output: [`spec`](../artifacts/spec.md), [`task`](../artifacts/task.md), [`trace`](../artifacts/trace.md), [`review`](../artifacts/review.md), [`finding`](../artifacts/finding.md), [`memory`](../artifacts/memory.md)
