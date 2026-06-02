# Walkthrough: `checkout`, end to end

> One obligation set carried through all nine Swarm passes in order — author, lint, improve, lower, decompose, implement, verify, review, promote — watching a cart-submission spec go from a draft with one bundled obligation, a parallel write-surface conflict, and an open question to a merged, promoted finding. This is the checkout positive walkthrough: identifiers, content hashes, and verdicts are stable from the first stage to the last, so the whole page reads as a single run.

## What you are looking at

`checkout` is a small, complete feature: when a shopper submits a cart, the service validates it, charges the card, writes the order and inventory records, and emails a receipt — charging the card at most once. It is small enough to read in one sitting and rich enough to exercise the two defect classes this domain exists to bracket: an obligation that **bundles** three separable responsibilities into one sentence, and two obligations that **share a write surface** while being planned to run in parallel. The first is a prose/singularity defect caught at `lint`; the second is an orchestration defect, also flagged at `lint` and enforced at `decompose`. Both are the kind of error that is invisible to a schema check and lethal at runtime — a double-charge, a lost order row — which is exactly why they are pinned here. An open `QUESTION` rides alongside them and is resolved out of band during `improve`.

Nothing on this page is run by a tool. Swarm ships **no runtime** — every artifact below is inert markdown, the oracle a human or agent reads and writes by hand while following the stdlib pass guides. The IR and the work packets are *contracts a future tool would emit against*, produced here by hand so the chain is legible. Read this page top to bottom; each stage feeds the next.

The default pass order, which this page follows exactly:

```text
author -> lint -> improve -> lower -> decompose -> implement -> verify -> review -> promote
```

---

## Stage 1 — `author`: the human writes the spec

`author` is the only stage where a human writes a `.swarm.` artifact directly. The output is a `spec.swarm.md`: frontmatter plus prose sections (`## Intent`, `## Interfaces`, `## Obligations`, `## Invariants`, `## Questions`) interleaved with typed SOL blocks. The author is not expected to write clean obligations on the first pass — that is what `lint` and `improve` are for. The frontmatter carries the three separate version fields: `swarm_language` (which grammar and lint codes apply), `aps_version` (the prose standard), and `spec_version` (the SemVer of this spec's content). They are never merged.

Note the two deliberate flaws and the open question planted here. `AC-010` bundles three separable obligations into a single sentence — *validate the cart* **and** *charge the card* **and** *email the receipt* — three responsibilities that fail, verify, and parallelize independently. `AC-011` and `AC-012` both declare `WRITES db/orders` with no ordering between them: two writers contending on one surface. And `Q-010` is an open (non-`[blocking]`) question about whether the order and inventory writes belong in one transaction or two.

```sol
---
type: spec
swarm_language: SOL/0.1
aps_version: 0.1
spec_version: 0.1.0
id: checkout
status: draft
---

# Spec: Cart submission and checkout

## Intent
When a shopper submits their cart the service validates it, charges the card, writes the
order and inventory records, and emails a receipt — charging the card at most once.

## Interfaces

INTERFACE IF-010:
`submitCart` RETURNS `OrderConfirmation | CheckoutError`
ERRORS:
  - card-declined
  - cart-expired
OWNED BY checkout-service
VERIFY BY contract:cmdValidate:openapi/checkout.yaml#submitCart

## Obligations

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

## Invariants

INVARIANT I-010:
a single submitted cart MUST NOT result in more than one card charge
VERIFY BY property:cmdTest:api/tests/checkout.properties.ts#charge_at_most_once

## Questions

QUESTION Q-010:
Should AC-011 and AC-012 run in one transaction or two?
AFFECTS AC-011
```

---

## Stage 2 — `lint`: diagnose, don't touch

`lint` reads the spec and emits SARIF-shaped diagnostic records in the unified `SOL-<LAYER><NNN>` namespace, without changing a single character. Each record names the closed `improve` op that repairs it, so the next stage is mechanical rather than open-ended. Two diagnostics fire on the authored source, both BLOCKING because each one changes *what* gets built rather than merely how the text reads. The `severity` here is the authoring-layer value (`BLOCKING`/`ADVISORY`); when this lowers into the IR's `diagnostics[]` array it becomes the `level` value (`error`/`warning`/`note`).

```text
SOL-P004  BLOCKING  layer=P  AC-010:L2 ("MUST validate the cart AND charge the card AND email the receipt")
  message: one REQ clause bundles three separable obligations (validate / charge / email).
  suggest: improve op ATOMIZE — split into one obligation per block.

SOL-O001  BLOCKING  layer=O  AC-011 / AC-012 on surface db/orders
  message: two obligations planned parallel share write surface db/orders;
           violates the safe-parallelism predicate (write surfaces planned parallel must be pairwise disjoint).
  suggest: improve op SCOPE — split the write surfaces, or add a serializing DEPENDS ON.
```

`SOL-P004` is a P-layer (prose/singularity) defect: it fires at the `NORMALIZE`/`improve` stage and is repaired by `ATOMIZE`. `SOL-O001` is an O-layer (orchestration) defect: strictly it is *decidable* the moment the spec declares overlapping write surfaces planned in parallel, and it is the gate `lower`/`decompose` enforce before any plan emits. Lint records it early so the author sees both repairs at once; the orchestration gate at Stage 5 is where it would otherwise halt plan emission, and `SCOPE` is the op that clears it. No other layer fires — `IF-010` carries a `contract` proof, `I-010` is measurable as written, and every obligation has a `VERIFY BY` path.

`Q-010` is a non-blocking `QUESTION` — it carries no `[blocking]` tag, so it raises no `SOL-O003` (blocking-question-reaches-lowering) risk and does not gate `lower`. It is recorded as an open decision to settle at `improve`. A blocking `QUESTION` would be a hard gate; this one is a deferred choice.

---

## Stage 3 — `improve`: apply the closed ops, preserve intent

`improve` applies the named ops — here `ATOMIZE` for the bundle and `SCOPE` for the write-surface conflict — each strictly semantics-preserving. An op may make an obligation singular, well-scoped, or safely parallelizable; it may never change what the author meant. Anything that *would* change intent routes to amendment or review, never to `improve`. Separately, the spec owner resolves `Q-010` out of band (decision: serialize `AC-012` behind `AC-011` — one ordered write path), and `Q-010` is removed.

`ATOMIZE` splits `AC-010` into three single-obligation REQs: `AC-010` keeps *validate the cart*, and two fresh ids carry the rest — `AC-013` *charge the card* and `AC-014` *email the receipt*. Each atom keeps the shared trigger (`WHEN the cart is submitted`) and the shared `DEPENDS ON IF-010`, and each gets its own `VERIFY BY` selector; the charge atom keeps `AC-010`'s original high `RISK`, while validate is regraded medium and email low. `SCOPE` resolves `SOL-O001` by giving `AC-012` a disjoint write surface (`db/inventory` instead of `db/orders`) **and** a serializing `DEPENDS ON AC-011`, so the two record-writers are now both write-disjoint and ordered. Only the changed and added blocks are shown.

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
DEPENDS ON AC-011
WRITES db/inventory
RISK medium

INVARIANT I-010:
a single submitted cart MUST NOT result in more than one card charge
VERIFY BY property:cmdTest:api/tests/checkout.properties.ts#charge_at_most_once
```

Each diagnostic maps to a closed repair. `ATOMIZE` turned the one bundled `AC-010` into three single-obligation REQs (`AC-010`, `AC-013`, `AC-014`), clearing `SOL-P004` — no obligation, modality, or binding was dropped, only separated; re-grading per-child `RISK` is metadata, not a semantic-diff change, so the split stays intent-preserving. `SCOPE` gave `AC-012` the disjoint surface `db/inventory` and added `DEPENDS ON AC-011`, so the pair is now pairwise write-disjoint *and* serialized, clearing `SOL-O001`. With both blocking diagnostics resolved and `Q-010` closed, the spec is ready to lower.

---

## Stage 4 — `lower`: emit the typed IR

`lower` projects the normalized spec into the typed intermediate representation, `checkout.swarm.ir.json`. Three things happen mechanically: uppercase SOL surface keywords become `snake_case` IR fields (`VERIFY BY` becomes `verify_by`, `DEPENDS ON` becomes a `depends_on` edge); every relationship moves into `edges[]`, the single source of relationship truth, never duplicated as a node scalar; and node ids become namespaced. Note that the atomized `AC-010`/`AC-013`/`AC-014` are now three independent nodes with their own predicates and proof bindings — the bundle is gone from the IR entirely. A slice is shown.

```json
{
  "meta": {
    "id": "checkout",
    "title": "Cart submission and checkout",
    "language": "SOL/0.1",
    "version": "0.1.0",
    "status": "draft"
  },
  "nodes": [
    {
      "id": "INTERFACE.checkout.IF-010",
      "kind": "INTERFACE",
      "clauses": { "returns": "OrderConfirmation | CheckoutError" },
      "owner": "checkout-service",
      "verify_by": [
        { "type": "contract", "adapter": "cmdValidate",
          "ref": "openapi/checkout.yaml", "selector": "submitCart", "gate": "required" }
      ],
      "status": "UNVERIFIED",
      "source": { "file": "checkout.swarm.md", "line_start": 30, "line_end": 37,
                  "content_hash": "sha256:2a7c…d0" }
    },
    {
      "id": "REQ.checkout.AC-010",
      "kind": "REQ",
      "modality": "MUST",
      "clauses": { "trigger": { "kw": "WHEN", "expr": "the cart is submitted" },
                   "subject": "checkout service",
                   "predicate": "validate the cart" },
      "risk": "medium",
      "writes": ["api/src/checkout/submit.ts"],
      "verify_by": [
        { "type": "test", "adapter": "cmdTest",
          "ref": "api/tests/checkout.spec.ts",
          "selector": "validates-cart", "gate": "required" }
      ],
      "status": "UNVERIFIED",
      "source": { "file": "checkout.swarm.md", "line_start": 41, "line_end": 47,
                  "content_hash": "sha256:4b1f…12" }
    },
    {
      "id": "REQ.checkout.AC-013",
      "kind": "REQ",
      "modality": "MUST",
      "clauses": { "trigger": { "kw": "WHEN", "expr": "the cart is submitted" },
                   "subject": "checkout service",
                   "predicate": "charge the card" },
      "risk": "high",
      "writes": ["api/src/checkout/submit.ts"],
      "verify_by": [
        { "type": "test", "adapter": "cmdTest",
          "ref": "api/tests/checkout.spec.ts",
          "selector": "charges-card", "gate": "required" }
      ],
      "status": "UNVERIFIED",
      "source": { "file": "checkout.swarm.md", "line_start": 49, "line_end": 55,
                  "content_hash": "sha256:5c2a…34" }
    },
    {
      "id": "REQ.checkout.AC-014",
      "kind": "REQ",
      "modality": "MUST",
      "clauses": { "trigger": { "kw": "WHEN", "expr": "the cart is submitted" },
                   "subject": "checkout service",
                   "predicate": "email the receipt" },
      "risk": "low",
      "writes": ["api/src/checkout/submit.ts"],
      "verify_by": [
        { "type": "test", "adapter": "cmdTest",
          "ref": "api/tests/checkout.spec.ts",
          "selector": "emails-receipt", "gate": "required" }
      ],
      "status": "UNVERIFIED",
      "source": { "file": "checkout.swarm.md", "line_start": 57, "line_end": 63,
                  "content_hash": "sha256:6d3b…56" }
    },
    {
      "id": "REQ.checkout.AC-011",
      "kind": "REQ",
      "modality": "MUST",
      "clauses": { "trigger": { "kw": "WHEN", "expr": "the cart is submitted" },
                   "subject": "checkout service",
                   "predicate": "write the order record" },
      "risk": "medium",
      "writes": ["db/orders"],
      "verify_by": [
        { "type": "test", "adapter": "cmdTest",
          "ref": "api/tests/order-record.spec.ts",
          "selector": "writes-order", "gate": "required" }
      ],
      "status": "UNVERIFIED",
      "source": { "file": "checkout.swarm.md", "line_start": 65, "line_end": 71,
                  "content_hash": "sha256:7e4c…78" }
    },
    {
      "id": "REQ.checkout.AC-012",
      "kind": "REQ",
      "modality": "MUST",
      "clauses": { "trigger": { "kw": "WHEN", "expr": "the cart is submitted" },
                   "subject": "checkout service",
                   "predicate": "write the inventory ledger" },
      "risk": "medium",
      "writes": ["db/inventory"],
      "verify_by": [
        { "type": "test", "adapter": "cmdTest",
          "ref": "api/tests/inventory.spec.ts",
          "selector": "writes-ledger", "gate": "required" }
      ],
      "status": "UNVERIFIED",
      "source": { "file": "checkout.swarm.md", "line_start": 73, "line_end": 80,
                  "content_hash": "sha256:8f5d…9a" }
    },
    {
      "id": "INVARIANT.checkout.I-010",
      "kind": "INVARIANT",
      "modality": "MUST NOT",
      "clauses": { "subject": "a single submitted cart",
                   "predicate": "result in more than one card charge" },
      "verify_by": [
        { "type": "property", "adapter": "cmdTest",
          "ref": "api/tests/checkout.properties.ts",
          "selector": "charge_at_most_once", "gate": "required" }
      ],
      "status": "UNVERIFIED",
      "source": { "file": "checkout.swarm.md", "line_start": 84, "line_end": 87,
                  "content_hash": "sha256:3b90…ee" }
    }
  ],
  "edges": [
    { "from": "REQ.checkout.AC-010", "to": "INTERFACE.checkout.IF-010",
      "type": "depends_on", "hard": true },
    { "from": "REQ.checkout.AC-013", "to": "INTERFACE.checkout.IF-010",
      "type": "depends_on", "hard": true },
    { "from": "REQ.checkout.AC-014", "to": "INTERFACE.checkout.IF-010",
      "type": "depends_on", "hard": true },
    { "from": "REQ.checkout.AC-012", "to": "REQ.checkout.AC-011",
      "type": "depends_on", "hard": true },
    { "from": "REQ.checkout.AC-013", "to": "INVARIANT.checkout.I-010",
      "type": "affects", "hard": false }
  ],
  "diagnostics": [],
  "provenance": { "hash": "sha256:c901…7f", "compiler_version": null,
                  "compiled_at": "2026-06-02T00:00:00Z" }
}
```

Every node enters `lower` at `status: UNVERIFIED` — the default before any verdict exists. The three atoms `AC-010`/`AC-013`/`AC-014` each `depends_on` the interface `IF-010`; the `AC-012 → AC-011` edge is the serializing `DEPENDS ON` the `SCOPE` op added; and the single `affects` edge records that the charge obligation `AC-013` touches the at-most-once `INVARIANT` `I-010`. `compiler_version` is `null` because no tool is shipped; the IR is the contract a future tool would emit against, produced here by hand.

---

## Stage 5 — `decompose` and `implement`: project a write-disjoint plan, then build it

`decompose` projects the IR into `task.md` work packets, computing the partition on which all safe parallelism rests. This is the stage that would have *halted* on the authored spec: the safe-parallelism predicate requires that any two packets scheduled in parallel have **pairwise-disjoint** write surfaces, and the original `AC-011`/`AC-012` shared `db/orders` — the `SOL-O001` the `SCOPE` op already cleared at Stage 3. The checkout IR decomposes into two packets with disjoint write surfaces: `checkout-submit` owns the service code (`api/src/checkout/submit.ts`) and the order record (`db/orders`), and `checkout-inventory` owns the inventory ledger (`db/inventory`), serialized behind `checkout-submit` by `blocked_by` (the lowered form of the `AC-012 DEPENDS ON AC-011` edge). Each packet's owned paths MUST be a subset of its assigned obligations' `WRITES` — a packet writing a path outside its declared `write_surfaces` is the hard error `SOL-O005` (owned-path-outside-write-surface). Only the load-bearing frame is shown; the verification matrix is filled in by `implement`/`verify` as work lands.

```text
---
type: task
id: checkout-submit
status: active
task_kind: feature
source: .swarm/sources/specs/checkout.swarm.md
assigned_obligations: [AC-010, AC-013, AC-014, AC-011]
invariants: [I-010]
interfaces: [IF-010]
write_surfaces: [api/src/checkout/submit.ts, db/orders]
verification_bindings:
  - AC-010: test:cmdTest:api/tests/checkout.spec.ts#validates-cart
  - AC-013: test:cmdTest:api/tests/checkout.spec.ts#charges-card
  - AC-014: test:cmdTest:api/tests/checkout.spec.ts#emails-receipt
  - AC-011: test:cmdTest:api/tests/order-record.spec.ts#writes-order
  - I-010:  property:cmdTest:api/tests/checkout.properties.ts#charge_at_most_once
parallel_group: checkout-edits
blocked_by: []
---

# Task: Implement checkout submit, charge, and order-write path

## Scope

### In
- Implement AC-010, AC-013, AC-014, AC-011, and preserve I-010 within
  api/src/checkout/submit.ts and db/orders.

### Out
- Do not implement unassigned obligations.
- Do not write db/inventory (owned by the serialized `checkout-inventory` packet).

## Verification matrix
| Obligation | Required proof              | Actual proof                            | Status |
| ---------- | --------------------------- | --------------------------------------- | ------ |
| AC-010     | test:#validates-cart        | checkout.spec.ts validates-cart passed  | pass   |
| AC-013     | test:#charges-card          | checkout.spec.ts charges-card passed    | pass   |
| AC-014     | test:#emails-receipt        | checkout.spec.ts emails-receipt passed  | pass   |
| AC-011     | test:#writes-order          | order-record.spec.ts writes-order passed| pass   |
| I-010      | property:#charge_at_most_once| checkout.properties.ts passed          | pass   |
```

The second packet, `checkout-inventory`, covers `AC-012`, owns the disjoint surface `db/inventory`, and carries `blocked_by: [checkout-submit]` (the `AC-012 DEPENDS ON AC-011` edge). Its single binding is `test:cmdTest:api/tests/inventory.spec.ts#writes-ledger`. Disjoint `WRITES` (`api/src/checkout/submit.ts` + `db/orders` vs `db/inventory`) plus explicit ordering satisfy the safe-parallelism predicate — the `SOL-O001` the authored source tripped is cleared, not merely re-marked. `implement` executes each packet against exactly its declared surfaces; the `I-010` invariant rides along the submit packet as a preserved obligation because the charge path it constrains lives there.

---

## Stage 6 — `verify`: record the trace and its provenance

`verify` runs the bound proofs and records a `TRACE` block per work packet plus the provenance that the drift join depends on. Each `TRACE` declares what it `IMPLEMENTS`, what it `PRESERVES`, what surfaces it `CHANGED`, and one `PROOF` line per binding with its result. `T-010` covers the submit packet (`AC-010`, `AC-013`, `AC-014`, `AC-011`, preserving `I-010`); `T-011` covers the serialized inventory packet (`AC-012`). The provenance table carries the canonical seven fields: `source_hash` (echoing the IR node's `content_hash`), `per_surface_hash[]` (each `{surface, hash, exercised}`), `adapter`, `verdict`, `tier` (the proof *type*, never a RISK value), `origin_obligations[]`, and `origin_traces[]`. These hashes are what later detects staleness — they are the load-bearing part of the artifact.

```text
---
type: trace
id: checkout-trace
source_task: .swarm/generated/tasks/checkout-submit.md
source_spec: .swarm/sources/specs/checkout.swarm.md
---

# Trace: checkout

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

## Provenance
| binding | source_hash      | per_surface_hash[]                          | adapter | verdict | tier     | origin_obligations | origin_traces |
| ------- | ---------------- | ------------------------------------------- | ------- | ------- | -------- | ------------------ | ------------- |
| AC-010  | sha256:4b1f…12   | {submit.ts, sha256:a110…b2, exercised}      | cmdTest | PASS    | test     | [AC-010]           | [T-010]       |
| AC-013  | sha256:5c2a…34   | {submit.ts, sha256:a110…b2, exercised}      | cmdTest | PASS    | test     | [AC-013]           | [T-010]       |
| AC-014  | sha256:6d3b…56   | {submit.ts, sha256:a110…b2, exercised}      | cmdTest | PASS    | test     | [AC-014]           | [T-010]       |
| AC-011  | sha256:7e4c…78   | {db/orders, sha256:b220…c3, exercised}      | cmdTest | PASS    | test     | [AC-011]           | [T-010]       |
| AC-012  | sha256:8f5d…9a   | {db/inventory, sha256:c330…d4, exercised}   | cmdTest | PASS    | test     | [AC-012]           | [T-011]       |
| I-010   | sha256:3b90…ee   | {checkout.properties.ts, sha256:d440…e5, exercised} | cmdTest | PASS | property | [I-010]            | [T-010]       |
```

The three atoms charge against the same submit surface (`submit.ts`), each with its own selector on `checkout.spec.ts`; the two write obligations each cite their own write surface — `db/orders` and `db/inventory`, now provably disjoint — and the `I-010` property exercises `checkout.properties.ts` where the at-most-once invariant lives. All six bindings are recorded `PASS`; nothing executed here, the results are pinned data.

---

## Stage 7 — `review`: per-obligation verdicts and the merge gate

`review` (run under the `skeptic` profile) consumes the trace and emits one `VERDICT` line per obligation. Each verdict carries a core value — `PASS`, `FAIL`, `BLOCKED`, or `UNVERIFIED` — optionally decorated with a lifecycle value (`WAIVED`, `STALE`, `CONTRADICTED`). The skeptical review judges the trace claims against the source spec, the diff, and the proof evidence — not against the trace's self-report. All six obligations — the five REQs and the invariant — come back clean `PASS`, and the orchestration check confirms the two packets' write surfaces are genuinely disjoint.

```text
---
type: review
id: checkout-review
source_trace: .swarm/generated/traces/checkout-trace.md
source_spec: .swarm/sources/specs/checkout.swarm.md
---

# Review: checkout

## Per-obligation verdicts

VERDICT AC-010: PASS
REASON `validates-cart` exercises a submitted cart and asserts validation runs before any charge.
EVIDENCE checkout.spec.ts validates-cart output in review log

VERDICT AC-013: PASS
REASON `charges-card` exercises the charge path; the diff in submit.ts charges exactly once.
EVIDENCE checkout.spec.ts charges-card output in review log

VERDICT AC-014: PASS
REASON `emails-receipt` asserts a receipt is sent after a successful charge.
EVIDENCE checkout.spec.ts emails-receipt output in review log

VERDICT AC-011: PASS
REASON `writes-order` asserts the order record is persisted to db/orders.
EVIDENCE order-record.spec.ts writes-order output in review log

VERDICT AC-012: PASS
REASON `writes-ledger` asserts the inventory ledger is persisted to the disjoint db/inventory surface, serialized behind AC-011.
EVIDENCE inventory.spec.ts writes-ledger output in review log

VERDICT I-010: PASS
REASON Property test fails on any path producing charge_count > 1; current run is green.
EVIDENCE checkout.properties.ts charge_at_most_once output in review log

## Unauthorized-change check
No diff hunk wrote outside its packet's declared WRITES. The `checkout-submit` packet touched
only api/src/checkout/submit.ts and db/orders; the `checkout-inventory` packet touched only
db/inventory. The two write surfaces are pairwise disjoint and AC-012 is ordered behind AC-011,
so the safe-parallelism predicate holds — the SOL-O001 conflict the authored source carried is
cleared, not merely re-marked.

## Final verdict
Gate: every required obligation is PASS or WAIVED; none STALE/CONTRADICTED/FAIL/BLOCKED/UNVERIFIED.
Result: PASS — six required obligations — the five REQs (AC-010, AC-013, AC-014, AC-011,
AC-012) and the invariant I-010 — are clean PASS, and no parallel write-surface conflict
remains. The merge gate opens.
```

Unlike the auth-refresh walkthrough, there is no staleness reconcile here — the surfaces these packets touched were not re-edited after the proofs ran, so every recorded source hash still matches its live surface. The gate opens on the first evaluation: every required obligation is `PASS`, none `STALE`/`CONTRADICTED`/`FAIL`/`BLOCKED`/`UNVERIFIED`, and the safe-parallelism predicate the `SCOPE` op restored at Stage 3 still holds at the gate.

---

## Stage 8 — `promote`: capture a durable finding

With the gate open and the work merged, `promote` captures a durable discovery from the task as a `finding.md` carrying full provenance: which obligations and traces it came from, the pass and profile that produced it, the reviewer or tool, a `content_hash`, a confidence level, and applies-when / does-not-apply-when bounds. The discovery here surfaced when `ATOMIZE` split the bundled `AC-010` into separate charge (`AC-013`) and order-write (`AC-011`) obligations: those two became separately schedulable steps, and if the charge commits but the order-write fails, a client retry re-submits the cart and charges a second time — violating `I-010` *in aggregate* even though each individual submit charges at most once.

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

The finding is then indexed in memory by a single `MAP` line carrying a "Load when" condition. No procedure is inlined in the index — the link points at the finding, and the index stays a thin router into memory.

```text
# memory/INDEX.md  (excerpt)
- Charge and order-write must be atomic — `.swarm/sources/findings/charge-and-order-write-must-be-atomic.md`
  — Load when: implementing or reviewing a checkout/payment path that charges then persists.
```

That closes the loop: a draft spec with one bundled obligation, a parallel write-surface conflict, and an open question became a normalized, atomized spec, a typed IR with an explicit dependency chain, a write-disjoint and serialized pair of work packets, an implemented and traced change, a reviewed merge that confirmed the partition holds, and a promoted finding that future work on this surface will load on demand.

---

## Related

- Pass references, in pipeline order: [`author`](../passes/author.md), [`lint`](../passes/lint.md), [`improve`](../passes/improve.md), [`lower`](../passes/lower.md), [`decompose`](../passes/decompose.md), [`implement`](../passes/implement.md), [`verify`](../passes/verify.md), [`review`](../passes/review.md), [`promote`](../passes/promote.md)
- [Golden corpus](../reference/golden-corpus.md) — `checkout` is the positive (`must-compile`) fixture this walkthrough draws from; the authored source trips `SOL-P004` (bundled obligation) and `SOL-O001` (parallel write-surface conflict)
- Artifact references for each stage's output: [`spec`](../artifacts/spec.md), [`task`](../artifacts/task.md), [`trace`](../artifacts/trace.md), [`review`](../artifacts/review.md), [`finding`](../artifacts/finding.md), [`memory`](../artifacts/memory.md)
