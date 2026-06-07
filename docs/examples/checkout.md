# Walkthrough: `checkout` — what differs from `auth-refresh`

> A second positive run through all nine Swarm steps — author, lint, improve, lower, decompose, implement, verify, review, promote — for a cart-submission spec. The eight-stage skeleton, the no-runtime framing, and the stage-by-stage mechanics are identical to [`auth-refresh`](./auth-refresh.md); read that page first for the full walkthrough. This page spells out **only what `checkout` teaches that `auth-refresh` does not**: a single obligation that **bundles** three separable responsibilities, and two obligations that **share a write surface** while planned to run in parallel.

## What this case teaches

`checkout` is a small, complete feature: when a shopper submits a cart, the service validates it, charges the card, writes the order and inventory records, and emails a receipt — charging the card at most once. It brackets two defect classes invisible to a schema check and lethal at runtime — a double-charge, a lost order row:

- **A bundled obligation** (`AC-010`) packs *validate the cart* **and** *charge the card* **and** *email the receipt* into one sentence — three responsibilities that fail, verify, and parallelize independently. This is a P-layer prose/singularity defect (`SOL-P004`), repaired by the `ATOMIZE` op.
- **A parallel write-surface conflict**: `AC-011` and `AC-012` both declare `WRITES db/orders` with no ordering between them — two writers contending on one surface. This is an O-layer orchestration defect (`SOL-O001`), flagged at `lint` and enforced at `decompose`, repaired by the `SCOPE` op.

An open (non-`[blocking]`) `QUESTION` `Q-010` rides alongside — whether the order and inventory writes belong in one transaction or two. Unlike `auth-refresh`'s `[blocking]` `Q-001`, a non-blocking question raises no `SOL-O003` risk and does not gate `lower`; it is recorded as a deferred choice and resolved out of band at `improve`.

Everything else — the three version fields in the frontmatter, the SARIF-shaped `SOL-<LAYER><NNN>` diagnostics, the semantics-preserving `improve` ops, the `snake_case` structured-form projection, the `UNVERIFIED` default and `null` `tool_version`, the trace provenance table's seven fields, the per-obligation `VERDICT` model, and the indexed `finding` — works exactly as the `auth-refresh` page describes.

## The authored spec (Stage 1)

The two seeded flaws and the open question, as authored:

```sol
REQ AC-010:
WHEN the cart is submitted
THE checkout service MUST validate the cart AND charge the card AND email the receipt
VERIFY BY test:cmdTest:api/tests/checkout.spec.ts#submit
DEPENDS ON IF-010
WRITES api/src/checkout/submit.ts
RISK high

REQ AC-011:
WHEN the cart is submitted
THE checkout service MUST write the order record
VERIFY BY test:cmdTest:api/tests/order-record.spec.ts#writes-order
WRITES db/orders
RISK medium

REQ AC-012:
WHEN the cart is submitted
THE checkout service MUST write the inventory ledger
VERIFY BY test:cmdTest:api/tests/inventory.spec.ts#writes-ledger
WRITES db/orders
RISK medium

QUESTION Q-010:
Should AC-011 and AC-012 run in one transaction or two?
AFFECTS AC-011
```

The interface `IF-010` (`submitCart RETURNS OrderConfirmation | CheckoutError`, owned by `checkout-service`, `VERIFY BY contract:cmdValidate:openapi/checkout.yaml#submitCart`) and the invariant `I-010` (*a single submitted cart MUST NOT result in more than one card charge*, `VERIFY BY property:cmdTest:api/tests/checkout.properties.ts#charge_at_most_once`) are well-formed as authored — no S/V/M-layer defect fires on them.

## The two diagnostics (Stage 2)

```text
SOL-P004  BLOCKING  layer=P  AC-010:L2 ("MUST validate the cart AND charge the card AND email the receipt")
  message: one REQ clause bundles three separable obligations (validate / charge / email).
  suggest: improve op ATOMIZE — split into one obligation per block.

SOL-O001  BLOCKING  layer=O  AC-011 / AC-012 on surface db/orders
  message: two obligations planned parallel share write surface db/orders;
           violates the safe-parallelism predicate (write surfaces planned parallel must be pairwise disjoint).
  suggest: improve op SCOPE — split the write surfaces, or add a serializing DEPENDS ON.
```

`SOL-O001` is *decidable* the moment the spec declares overlapping write surfaces planned in parallel; `lint` records it early so the author sees both repairs at once, and the orchestration gate at `decompose` is where it would otherwise halt plan emission. `Q-010` is recorded as an open decision, not a gate.

## The repair (Stage 3)

`improve` applies `ATOMIZE` for the bundle and `SCOPE` for the conflict, each semantics-preserving; the owner resolves `Q-010` out of band (decision: serialize `AC-012` behind `AC-011` — one ordered write path).

`ATOMIZE` splits `AC-010` into three single-obligation REQs: `AC-010` keeps *validate the cart*, and two fresh ids carry the rest — `AC-013` *charge the card* and `AC-014` *email the receipt*. Each atom keeps the shared trigger (`WHEN the cart is submitted`) and `DEPENDS ON IF-010`, and gets its own `VERIFY BY` selector; the charge atom keeps the original high `RISK`, validate is regraded medium and email low. Re-grading per-child `RISK` is metadata, not a semantic-diff change, so the split stays intent-preserving — no obligation, modality, or binding is dropped, only separated.

`SCOPE` gives `AC-012` a disjoint write surface (`db/inventory` instead of `db/orders`) **and** a serializing `DEPENDS ON AC-011`, so the two record-writers are now both write-disjoint and ordered.

```sol
REQ AC-010:
WHEN the cart is submitted
THE checkout service MUST validate the cart
VERIFY BY test:cmdTest:api/tests/checkout.spec.ts#validates-cart
DEPENDS ON IF-010
WRITES api/src/checkout/submit.ts
RISK medium

REQ AC-013:
WHEN the cart is submitted
THE checkout service MUST charge the card
VERIFY BY test:cmdTest:api/tests/checkout.spec.ts#charges-card
DEPENDS ON IF-010
WRITES api/src/checkout/submit.ts
RISK high

REQ AC-014:
WHEN the cart is submitted
THE checkout service MUST email the receipt
VERIFY BY test:cmdTest:api/tests/checkout.spec.ts#emails-receipt
DEPENDS ON IF-010
WRITES api/src/checkout/submit.ts
RISK low

REQ AC-012:
WHEN the cart is submitted
THE checkout service MUST write the inventory ledger
VERIFY BY test:cmdTest:api/tests/inventory.spec.ts#writes-ledger
DEPENDS ON AC-011
WRITES db/inventory
RISK medium
```

(`AC-011` and `I-010` are unchanged from Stage 1.) With both blocking diagnostics resolved and `Q-010` closed, the spec is ready to lower.

## What the structured form and the plan show (Stages 4–5)

In the structured form, the atomized `AC-010`/`AC-013`/`AC-014` are three independent nodes with their own predicates and proof bindings — the bundle is gone entirely. The load-bearing edges are: three `depends_on` edges from the atoms to `IF-010`; one serializing `depends_on` edge `AC-012 → AC-011` (the `SCOPE` op's `DEPENDS ON`); and one `affects` edge `AC-013 → I-010` recording that the charge obligation touches the at-most-once invariant (`AC-011`, `AC-014`, `AC-010` do not touch the capture path, so they carry no edge to `I-010`).

`decompose` is the stage that would have **halted** on the authored spec: the safe-parallelism predicate requires any two parallel packets have pairwise-disjoint write surfaces, and the original `AC-011`/`AC-012` shared `db/orders`. The cleared structured form decomposes into two packets:

- **`checkout-submit`** owns `api/src/checkout/submit.ts` + `db/orders`, covering `AC-010`, `AC-013`, `AC-014`, `AC-011`, preserving `I-010`. Its `source` is `specs/checkout/spec.swarm.md`.
- **`checkout-inventory`** owns the disjoint surface `db/inventory`, covers `AC-012`, and carries `blocked_by: [checkout-submit]` (the lowered form of the `AC-012 DEPENDS ON AC-011` edge). Its single binding is `test:cmdTest:api/tests/inventory.spec.ts#writes-ledger`.

Disjoint `WRITES` plus explicit ordering satisfy the safe-parallelism predicate — the `SOL-O001` the authored source tripped is cleared, not merely re-marked. (Each packet's owned paths MUST be a subset of its obligations' `WRITES`, or it is the hard error `SOL-O005`, owned-path-outside-write-surface — the same two-tier rule `auth-refresh` shows.)

## The verify trace (Stage 6)

`verify` records one `TRACE` block per packet. `T-010` covers the submit packet; `T-011` covers the serialized inventory packet:

```text
TRACE T-010:
IMPLEMENTS AC-010, AC-013, AC-014, AC-011
PRESERVES I-010
CHANGED api/src/checkout/submit.ts, db/orders
PROOF test:cmdTest:api/tests/checkout.spec.ts#validates-cart passed
PROOF test:cmdTest:api/tests/checkout.spec.ts#charges-card passed
PROOF test:cmdTest:api/tests/checkout.spec.ts#emails-receipt passed
PROOF test:cmdTest:api/tests/order-record.spec.ts#writes-order passed
PROOF property:cmdTest:api/tests/checkout.properties.ts#charge_at_most_once passed

TRACE T-011:
IMPLEMENTS AC-012
CHANGED db/inventory
PROOF test:cmdTest:api/tests/inventory.spec.ts#writes-ledger passed
```

The three atoms charge against the same submit surface (`submit.ts`), each with its own selector on `checkout.spec.ts`; the two write obligations cite their own now-disjoint surfaces (`db/orders` and `db/inventory`). All six bindings record `PASS` in the provenance table (seven canonical fields, as on the `auth-refresh` page).

## The merge gate (Stage 7) — no reconcile

`review` (under the `skeptic` profile) judges all six obligations — the five REQs and `I-010` — clean `PASS`, and adds an **unauthorized-change check** the single-packet `auth-refresh` run does not need:

```text
## Unauthorized-change check
No diff hunk wrote outside its packet's declared WRITES. The `checkout-submit` packet touched
only api/src/checkout/submit.ts and db/orders; the `checkout-inventory` packet touched only
db/inventory. The two write surfaces are pairwise disjoint and AC-012 is ordered behind AC-011,
so the safe-parallelism predicate holds — the SOL-O001 conflict the authored source carried is
cleared, not merely re-marked.
```

Unlike `auth-refresh`, there is **no staleness reconcile**: the surfaces these packets touched were not re-edited after the proofs ran, so every recorded source hash still matches its live surface. The gate opens on the first evaluation — every required obligation is `PASS`, none `STALE`/`CONTRADICTED`/`FAIL`/`BLOCKED`/`UNVERIFIED`, and the safe-parallelism predicate the `SCOPE` op restored still holds at the gate.

## The promoted finding (Stage 8)

The discovery surfaced when `ATOMIZE` split the bundle into separately schedulable charge (`AC-013`) and order-write (`AC-011`) steps:

```text
---
type: finding
id: charge-and-order-write-must-be-atomic
status: promoted
related_obligations: [AC-013, AC-011, I-010]
confidence: high
---

# Finding: The card charge and the order-record write must commit atomically

## Claim
Once AC-010's bundle was atomized, the charge (AC-013) and the order-write (AC-011) became
separately schedulable steps. If the charge commits but the order-write fails, a client retry
re-submits the cart and charges the card a second time — violating I-010 in aggregate even
though each individual submit charges at most once. The two steps MUST share one transaction (or
an idempotency key on the charge) so a failed order-write rolls the charge back.

## Provenance
- origin_obligations: [REQ.checkout.AC-013, REQ.checkout.AC-011, INVARIANT.checkout.I-010]
- origin_traces: [checkout-trace#T-010]
- pass: verify; profile: skeptic
- reviewer_or_tool: review.md (human review)
- content_hash: sha256:5c2a…34
- confidence: high

## Applies when
- The charge step and the order-record write are scheduled as separate steps.
- A submitted cart can be retried after a partial failure.

## Does not apply when
- The charge carries an idempotency key keyed to the cart submission.
- The charge and order-write share a single committed transaction.
```

The finding is indexed in memory by a single `MAP` line carrying a "Load when" condition — the link points at the finding, and the index stays a thin router:

```text
# memory/INDEX.md  (excerpt)
- Charge and order-write must be atomic — `.agents/memory/findings/charge-and-order-write-must-be-atomic.md`
  — Load when: implementing or reviewing a checkout/payment path that charges then persists.
```

That closes the loop: a draft spec with one bundled obligation, a parallel write-surface conflict, and an open question became a normalized, atomized spec, a typed structured form with an explicit dependency chain, a write-disjoint and serialized pair of work packets, an implemented and traced change, a reviewed merge that confirmed the partition holds, and a promoted finding that future work on this surface will load on demand.

## Related

- [Walkthrough: `auth-refresh`](./auth-refresh.md) — the full eight-stage walkthrough this page is a delta against; the canonical single-packet positive run.
- [Walkthrough: `payment-5xx`](./payment-5xx.md) — the contradiction case: a production `monitor` proof disagrees with a green harness test at the merge gate.
- [Golden corpus](../reference/golden-corpus.md) — `checkout` is the positive (`must-pass`) fixture this walkthrough draws from; the authored source trips `SOL-P004` (bundled obligation) and `SOL-O001` (parallel write-surface conflict).
- Step references, in flow order: [`author`](../passes/author.md), [`lint`](../passes/lint.md), [`improve`](../passes/improve.md), [`lower`](../passes/lower.md), [`decompose`](../passes/decompose.md), [`implement`](../passes/implement.md), [`verify`](../passes/verify.md), [`review`](../passes/review.md), [`promote`](../passes/promote.md)
- Artifact references for each stage's output: [`spec`](../artifacts/spec.md), [`task`](../artifacts/task.md), [`trace`](../artifacts/trace.md), [`review`](../artifacts/review.md), [`finding`](../artifacts/finding.md), [`memory`](../artifacts/memory.md)
