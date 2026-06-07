# Walkthrough: `auth-refresh`, end to end

> One obligation set carried through all nine Swarm steps in order — author, lint, improve, lower, decompose, implement, verify, review, promote — watching it go from a draft spec with three blocking defects and an open question to a merged, promoted finding. This is the canonical positive walkthrough: identifiers, content hashes, and verdicts are stable from the first stage to the last, so the whole page reads as a single run.

## What you are looking at

`auth-refresh` is a small, complete feature: when an access token expires mid-session, the client silently refreshes it and replays the original request, without ever looping. It is small enough to read in one sitting and rich enough to exercise the parts of the flow that matter — a vague-quality defect, a `SHOULD` with no justification, a missing verification path, an unbounded-retry invariant, a blocking question, and a staleness reconcile at the merge gate.

Nothing here is run by a tool. Swarm ships **no runtime** — every artifact below is inert markdown, the oracle a human or agent reads and writes by hand while following the stdlib step guides. The structured form and plan JSON are *contracts a future tool would emit against*, produced here by hand so the chain is legible. Read this page top to bottom; each stage feeds the next.

The default step order, which this page follows exactly:

```text
author -> lint -> improve -> lower -> decompose -> implement -> verify -> review -> promote
```

---

## Stage 1 — `author`: the human writes the spec

`author` is the only stage where a human writes a `.swarm.` artifact directly. The output is a `spec.swarm.md`: frontmatter plus prose sections (`## Intent`, `## Interfaces`, `## Obligations`, `## Invariants`, `## Questions`) interleaved with typed SOL blocks. The author is not expected to write clean obligations on the first draft — that is what `lint` and `improve` are for. The frontmatter carries the three separate version fields: `swarm_language` (which grammar and lint codes apply), `aps_version` (the prose standard), and `spec_version` (the SemVer of this spec's content). They are never merged.

Note the deliberate flaws planted here: `AC-002`'s `SHOULD clear the local session` carries no justification and the block has no `VERIFY BY`; `I-001` says retry count must not exceed "one" as a word rather than a measurable threshold; and `Q-001` is a `[blocking]` question hanging over `AC-002`.

```sol
---
type: spec
swarm_language: SOL/0.1
aps_version: 0.1
spec_version: 0.1.0
id: auth-refresh
status: draft
---

# Spec: Silent token refresh on 401

## Intent
When an access token expires mid-session the client transparently refreshes it
and replays the original request, without ever looping.

## Interfaces

INTERFACE IF-001:
`refreshSession` RETURNS `Session | AuthExpired`
ERRORS:
  - network-timeout
  - invalid-refresh-token
OWNED BY auth-client
VERIFY BY contract:cmdContract:refresh-session-contract

## Obligations

REQ AC-001:
WHEN a request returns 401 AND a refresh token is present
THE auth client MUST call `refreshSession` once
AND THE auth client MUST replay the original request with the new session
VERIFY BY test:cmdTest:web/tests/auth-refresh-401.spec.ts#replays-after-refresh
DEPENDS ON IF-001
WRITES web/src/http/client.ts
RISK high

REQ AC-002:
WHEN the refresh token is expired
THE auth client SHOULD clear the local session
AND THE auth client MUST redirect to `/login`

## Invariants

INVARIANT I-001:
the retry count for a single original request MUST NOT exceed one

## Questions

QUESTION Q-001 [blocking]:
Should an expired refresh token redirect to `/login` or open an inline re-auth modal?
AFFECTS AC-002
```

---

## Stage 2 — `lint`: diagnose, don't touch

`lint` reads the spec and emits SARIF-shaped diagnostic records in the unified `SOL-<LAYER><NNN>` namespace, without changing a single character. Each record names the closed `improve` op (or direct edit) that repairs it, so the next stage is mechanical rather than open-ended. Three diagnostics fire on the authored source, all BLOCKING because each one changes *what* gets built rather than merely how the text reads. The `severity` here is the authoring-layer value (`BLOCKING`/`ADVISORY`); when this lowers into the structured form's `diagnostics[]` array it becomes the `level` value (`error`/`warning`/`note`).

```text
SOL-V001  BLOCKING  layer=V  AC-002:L1-L4
  message: obligation AC-002 has no VERIFY BY binding; no verification path.
  suggest: improve op BIND — add VERIFY BY <type>:<adapter>:<artifact>.

SOL-S006  BLOCKING  layer=S  AC-002:L2 ("THE auth client SHOULD clear the local session")
  message: SHOULD without an accompanying BECAUSE or EXCEPT clause.
  suggest: Edit — add BECAUSE <reason>, or raise to MUST.

SOL-P005  BLOCKING  layer=P  I-001:L1
  message: INVARIANT predicate uses a vague quality phrase with no same-line observable criterion.
  suggest: improve op CONCRETIZE or QUANTIFY — name the measured quantity and threshold.
```

Beyond the three blocking diagnostics, `lint` records a note about the blocking question: `Q-001` is `[blocking]` and `AFFECTS AC-002`, so `AC-002` MUST NOT reach the `lower` step until the question is resolved. A blocking `QUESTION` that *does* reach `lower` is itself a hard error (`SOL-O003`, blocking-question-reaches-structuring). The question is a gate, not a suggestion.

---

## Stage 3 — `improve`: apply the closed ops, preserve intent

`improve` applies the named ops — here `BIND`, `NORMALIZE`, and `CONCRETIZE` — each strictly semantics-preserving. An op may make an obligation testable, well-formed, or measurable; it may never change what the author meant. Anything that *would* change intent routes to amendment or review, never to `improve`. Separately, the spec owner resolves `Q-001` out of band (decision: redirect to `/login`); that resolution is recorded and `Q-001` is removed, which unblocks `AC-002`. Only the changed blocks are shown.

```sol
REQ AC-002:
WHEN the refresh token is expired
THE auth client MUST clear the local session
AND THE auth client MUST redirect to `/login`
VERIFY BY test:cmdTest:web/tests/auth-refresh-expired.spec.ts#clears-and-redirects
DEPENDS ON IF-001
WRITES web/src/http/client.ts
RISK medium

INVARIANT I-001:
the retry count for a single original request MUST NOT exceed 1
VERIFY BY property:cmdTest:web/tests/auth-refresh.properties.ts#no_unbounded_retry
```

Each diagnostic maps to exactly one repair. `NORMALIZE` raised `SHOULD` to `MUST` — the spec owner judged the session-clear mandatory, so `SOL-S006` clears with no `BECAUSE` needed. `CONCRETIZE` fixed the threshold to the literal `1` and named the measured quantity, clearing `SOL-P005`. `BIND` attached a `test` proof to `AC-002` and a `property` proof to `I-001` (an `INVARIANT` prefers `property`, `model`, or `static` over a plain unit test), clearing `SOL-V001`. All three diagnostics now resolve, and with `Q-001` closed, the spec is ready to lower.

---

## Stage 4 — `lower`: emit the typed structured form

`lower` projects the normalized spec into the typed structured form, `auth-refresh.swarm.ir.json`. Three things happen mechanically: uppercase SOL surface keywords become `snake_case` fields (`VERIFY BY` becomes `verify_by`, `DEPENDS ON` becomes a `depends_on` edge); every relationship moves into `edges[]`, the single source of relationship truth, never duplicated as a node scalar; and node ids become namespaced. Note that `AC-001`'s `AND THE` chain splits into two distinct obligations, `AC-001.1` and `AC-001.2`, each carrying its own predicate but sharing the trigger, write surface, and proof binding. A slice is shown.

```json
{
  "meta": {
    "id": "auth-refresh",
    "title": "Silent token refresh on 401",
    "language": "SOL/0.1",
    "version": "0.1.0",
    "status": "draft"
  },
  "nodes": [
    {
      "id": "INTERFACE.auth-refresh.IF-001",
      "kind": "INTERFACE",
      "clauses": { "returns": "Session | AuthExpired" },
      "owner": "auth-client",
      "verify_by": [
        { "type": "contract", "adapter": "cmdContract",
          "ref": "refresh-session-contract", "selector": null, "gate": "required" }
      ],
      "status": "UNVERIFIED",
      "source": { "file": "auth-refresh.swarm.md", "line_start": 9, "line_end": 15,
                  "content_hash": "sha256:1f4a…c0" }
    },
    {
      "id": "REQ.auth-refresh.AC-001.1",
      "kind": "REQ",
      "modality": "MUST",
      "clauses": { "trigger": { "kw": "WHEN", "expr": "a request returns 401 AND a refresh token is present" },
                   "subject": "auth client",
                   "predicate": "call refreshSession once" },
      "risk": "high",
      "writes": ["web/src/http/client.ts"],
      "verify_by": [
        { "type": "test", "adapter": "cmdTest",
          "ref": "web/tests/auth-refresh-401.spec.ts",
          "selector": "replays-after-refresh", "gate": "required" }
      ],
      "status": "UNVERIFIED",
      "source": { "file": "auth-refresh.swarm.md", "line_start": 19, "line_end": 27,
                  "content_hash": "sha256:9b2e…41" }
    },
    {
      "id": "REQ.auth-refresh.AC-001.2",
      "kind": "REQ",
      "modality": "MUST",
      "clauses": { "trigger": { "kw": "WHEN", "expr": "a request returns 401 AND a refresh token is present" },
                   "subject": "auth client",
                   "predicate": "replay the original request with the new session" },
      "risk": "high",
      "writes": ["web/src/http/client.ts"],
      "verify_by": [
        { "type": "test", "adapter": "cmdTest",
          "ref": "web/tests/auth-refresh-401.spec.ts",
          "selector": "replays-after-refresh", "gate": "required" }
      ],
      "status": "UNVERIFIED",
      "source": { "file": "auth-refresh.swarm.md", "line_start": 19, "line_end": 27,
                  "content_hash": "sha256:9b2e…41" }
    },
    {
      "id": "INVARIANT.auth-refresh.I-001",
      "kind": "INVARIANT",
      "modality": "MUST NOT",
      "clauses": { "subject": "the retry count for a single original request",
                   "predicate": "exceed 1" },
      "verify_by": [
        { "type": "property", "adapter": "cmdTest",
          "ref": "web/tests/auth-refresh.properties.ts",
          "selector": "no_unbounded_retry", "gate": "required" }
      ],
      "status": "UNVERIFIED",
      "source": { "file": "auth-refresh.swarm.md", "line_start": 39, "line_end": 42,
                  "content_hash": "sha256:7d10…aa" }
    }
  ],
  "edges": [
    { "from": "REQ.auth-refresh.AC-001.1", "to": "INTERFACE.auth-refresh.IF-001",
      "type": "depends_on", "hard": true },
    { "from": "REQ.auth-refresh.AC-001.2", "to": "INTERFACE.auth-refresh.IF-001",
      "type": "depends_on", "hard": true },
    { "from": "REQ.auth-refresh.AC-001.1", "to": "INVARIANT.auth-refresh.I-001",
      "type": "affects", "hard": false },
    { "from": "REQ.auth-refresh.AC-001.2", "to": "INVARIANT.auth-refresh.I-001",
      "type": "affects", "hard": false }
  ],
  "diagnostics": [],
  "provenance": { "hash": "sha256:c33b…9e", "tool_version": null,
                  "emitted_at": "2026-05-31T00:00:00Z" }
}
```

Every node enters `lower` at `status: UNVERIFIED` — the default before any verdict exists. `tool_version` is `null` because no tool is shipped; the structured form is the contract a future tool would emit against, produced here by hand.

---

## Stage 5 — `decompose` and `implement`: project a work packet, then build it

`decompose` projects the structured form into a `task.md` work packet, and `implement` executes it. The packet's write surfaces MUST be a subset of the assigned obligations' `WRITES` — the two-tier structuring rule. A packet that writes a path outside its declared `write_surfaces` is the hard error `SOL-O005` (owned-path-outside-write-surface). The packet inherits the proof bindings from the obligations it covers and names its source spec. Only the load-bearing frame is shown; the verification matrix is filled in by `implement`/`verify` as work lands.

```text
---
type: task
id: auth-refresh-client
status: active
task_kind: feature
source: specs/auth-refresh/spec.swarm.md
assigned_obligations: [AC-001, AC-002]
invariants: [I-001]
interfaces: [IF-001]
write_surfaces: [web/src/http/client.ts]
verification_bindings:
  - AC-001: test:cmdTest:web/tests/auth-refresh-401.spec.ts#replays-after-refresh
  - AC-002: test:cmdTest:web/tests/auth-refresh-expired.spec.ts#clears-and-redirects
  - I-001:  property:cmdTest:web/tests/auth-refresh.properties.ts#no_unbounded_retry
parallel_group: client-edits
blocked_by: []
---

# Task: Implement auth-refresh client behavior

## Scope

### In
- Implement AC-001, AC-002, and preserve I-001 within web/src/http/client.ts.

### Out
- Do not implement unassigned obligations.
- Do not change behavior outside web/src/http/client.ts.

## Verification matrix
| Obligation | Required proof              | Actual proof                          | Status |
| ---------- | --------------------------- | ------------------------------------- | ------ |
| AC-001     | test:#replays-after-refresh | auth-refresh-401.spec.ts passed       | pass   |
| AC-002     | test:#clears-and-redirects  | auth-refresh-expired.spec.ts passed   | pass   |
| I-001      | property:#no_unbounded_retry| auth-refresh.properties.ts passed     | pass   |
```

---

## Stage 6 — `verify`: record the trace and its provenance

`verify` runs the bound proofs and records a `TRACE` block plus the provenance that the drift join depends on. The `TRACE` declares what it `IMPLEMENTS`, what it `PRESERVES`, what surfaces it `CHANGED`, and one `PROOF` line per binding with its result. The provenance table carries the canonical seven fields: `source_hash` (echoing the structured-form node's `content_hash`), `per_surface_hash[]` (each `{surface, hash, exercised}`), `adapter`, `verdict`, `tier` (the proof *type*, never a RISK value), `origin_obligations[]`, and `origin_traces[]`. These hashes are what later detects staleness — they are the load-bearing part of the artifact.

```text
---
type: trace
id: auth-refresh-client-trace
source_task: tasks/auth-refresh-client.md
source_spec: specs/auth-refresh/spec.swarm.md
---

# Trace: auth-refresh client

TRACE T-001:
IMPLEMENTS AC-001, AC-002
PRESERVES I-001
CHANGED web/src/http/client.ts
PROOF test:cmdTest:web/tests/auth-refresh-401.spec.ts#replays-after-refresh passed
PROOF test:cmdTest:web/tests/auth-refresh-expired.spec.ts#clears-and-redirects passed
PROOF property:cmdTest:web/tests/auth-refresh.properties.ts#no_unbounded_retry passed

## Provenance
| binding | source_hash      | per_surface_hash[]                       | adapter | verdict | tier     | origin_obligations | origin_traces |
| ------- | ---------------- | ---------------------------------------- | ------- | ------- | -------- | ------------------ | ------------- |
| AC-001  | sha256:9b2e…41   | {client.ts, sha256:5510…b3, exercised}   | cmdTest | PASS    | test     | [AC-001]           | [T-001]       |
| AC-002  | sha256:e8f7…2d   | {client.ts, sha256:5510…b3, exercised}   | cmdTest | PASS    | test     | [AC-002]           | [T-001]       |
| I-001   | sha256:7d10…aa   | {properties.ts, sha256:aa90…1c, exercised}| cmdTest | PASS    | property | [I-001]            | [T-001]       |
```

---

## Stage 7 — `review`: per-obligation verdicts and the merge gate

`review` (run under the `skeptic` profile) consumes the trace and emits one `VERDICT` line per obligation. Each verdict carries a core value — `PASS`, `FAIL`, `BLOCKED`, or `UNVERIFIED` — optionally decorated with a lifecycle value. `AC-001` and `I-001` come back as clean `PASS`. `AC-002` is the interesting one: its bound test PASSed, but `web/src/http/client.ts` was edited *after* that PASS was recorded, so the recorded source no longer matches the current write-surface hash. The verdict is decorated `STALE`, with the prior verdict and the changed surface named in the decorator. A STALE required obligation is not a failure — but it is not mergeable either, until it is reconciled.

```text
---
type: review
id: auth-refresh-client-review
source_trace: traces/auth-refresh-client-trace.md
source_spec: specs/auth-refresh/spec.swarm.md
---

# Review: auth-refresh client

## Per-obligation verdicts

VERDICT AC-001: PASS
REASON Replay-after-refresh test exercises a 401 with a present refresh token and asserts one replay.
EVIDENCE auth-refresh-401.spec.ts output in review log

VERDICT AC-002: PASS (STALE by review: prior-verdict T-001; changed-surface web/src/http/client.ts)
REASON Prior PASS evidence no longer matches current write-surface hash; requires 3-way reconcile.
EVIDENCE prior verdict + changed-surface diff in review log

VERDICT I-001: PASS
REASON Property test fails on any path producing retry_count > 1; current run is green.
EVIDENCE auth-refresh.properties.ts output in review log

## Final verdict
Gate: every required obligation is PASS or WAIVED; none STALE/CONTRADICTED/FAIL/BLOCKED/UNVERIFIED.
Result: BLOCKED — AC-002 is STALE. Re-run the bound proof against the current surface
(reconcile option 1), then re-evaluate. After re-run AC-002 → PASS, the gate opens.
```

### The reconcile

The merge gate refuses to open while any required obligation is `STALE`. STALE is never silently re-blessed; it is reconciled one of three ways — re-run the proof against the current surface, amend the spec, or fix the code. Here the change to `client.ts` was a legitimate refactor that the existing test still covers, so reconcile option 1 applies: re-run the bound proof against the current surface. The re-run passes, `AC-002`'s verdict becomes a clean `PASS`, the STALE decorator drops, and the gate opens — every required obligation is now `PASS`, none `STALE`/`CONTRADICTED`/`FAIL`/`BLOCKED`/`UNVERIFIED`.

---

## Stage 8 — `promote`: capture a durable finding

With the gate open and the work merged, `promote` captures a durable discovery from the task as a `finding.md` carrying full provenance: which obligations and traces it came from, the pass and profile that produced it, the reviewer or tool, a `content_hash`, a confidence level, and applies-when / does-not-apply-when bounds. The discovery here is a real one surfaced during review — a single expired token can fan out to many concurrent 401s, each independently calling `refreshSession`, which can violate `I-001` *in aggregate* even though each individual request retries at most once.

```text
---
type: finding
id: refresh-storm-on-shared-401
status: promoted
related_obligations: [AC-001, I-001]
confidence: high
---

# Finding: A single expired token can fan out to N concurrent 401s

## Claim
Concurrent in-flight requests each see the 401 and independently call refreshSession;
without a single-flight guard this violates I-001 in aggregate even though each request
retries at most once.

## Provenance
- origin_obligations: [REQ.auth-refresh.AC-001, INVARIANT.auth-refresh.I-001]
- origin_traces: [auth-refresh-client-trace#T-001]
- pass: verify; profile: skeptic
- reviewer_or_tool: review.md (human review)
- content_hash: sha256:9b2e…41
- confidence: high

## Applies when
- Multiple requests can be in flight when a token expires.

## Does not apply when
- The client serializes all auth-bearing requests.
```

The finding is then indexed in memory by a single `MAP` line carrying a "Load when" condition. No procedure is inlined in the index — the link points at the finding, and the index stays a thin router into memory.

```text
# memory/INDEX.md  (excerpt)
- Refresh storm on shared 401 — `.agents/memory/findings/refresh-storm-on-shared-401.md`
  — Load when: implementing or reviewing concurrent token-refresh paths.
```

That closes the loop: a draft spec with three blocking defects and an open question became a normalized spec, a typed structured form, a scoped work packet, an implemented and traced change, a reviewed and reconciled merge, and a promoted finding that future work on this surface will load on demand.

---

## Related

- Step references, in flow order: [`author`](../passes/author.md), [`lint`](../passes/lint.md), [`improve`](../passes/improve.md), [`lower`](../passes/lower.md), [`decompose`](../passes/decompose.md), [`implement`](../passes/implement.md), [`verify`](../passes/verify.md), [`review`](../passes/review.md), [`promote`](../passes/promote.md)
- [Golden corpus](../reference/golden-corpus.md) — `auth-refresh` is the positive (`must-pass`) fixture this walkthrough draws from
- Artifact references for each stage's output: [`spec`](../artifacts/spec.md), [`task`](../artifacts/task.md), [`trace`](../artifacts/trace.md), [`review`](../artifacts/review.md), [`finding`](../artifacts/finding.md), [`memory`](../artifacts/memory.md)
