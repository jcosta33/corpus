# The IR and Plan JSON Schemas

> Swarm's reference for the two emitted JSON contracts: the **IR** (`*.swarm.ir.json`) — the typed obligation graph a tool reasons over — and the **plan** (`*.swarm.plan.json`) — its schedulable projection into work packets. This page reproduces both JSON Schemas in full, names every required field, and pins the three version fields the envelopes carry.

A Swarm specification is human-authored as controlled markdown (`*.swarm.md`); the **intermediate representation** (IR) is the typed, machine-checkable form of that same content. Where the surface is English-shaped UPPERCASE space-separated keywords (`VERIFY BY`, `DEPENDS ON`, `WRITES`), the IR is `snake_case` JSON (`verify_by`, `depends_on`, `writes`): one document re-expressing every obligation, relationship, diagnostic, and provenance fact of one source file. The **plan** takes that obligation graph and groups the work needed to discharge it into schedulable **work packets**. Where the IR answers *"what must hold and how do the obligations relate,"* the plan answers *"what units of work exist, in what order, on which surfaces, and which are safe to run at the same time."*

Both are **emitted contracts, not running code**. Swarm is markdown-only and has NO RUNTIME: this framework ships **no emitter, no parser, no validator, and no scheduler** that produces or consumes these files. The JSON Schemas below are versioned, inert data — the shape a *future* tool MUST honor so any producer and any consumer interoperate. `*.swarm.ir.json` and `*.swarm.plan.json` are reserved, documented filenames, never artifacts a shipped process writes. This is why `provenance.compiler_version` is **`null` today**: there is no emitter to stamp a tool version. A conformant repository MUST carry these schemas verbatim and MUST frame any IR or plan instance as "the contract a future tool emits and a future launcher consumes," never as the output of shipped tooling.

> Design rationale: binding downstream analysis to a typed intermediate rather than to free-form prose is what makes the obligation graph mechanically checkable — topological sort over dependencies, cycle detection, write-surface conflict detection, the traceability join, merge-gate evaluation, and drift recomputation all read the IR, not the markdown. A structured intermediate also measurably outperforms free-form prose for downstream code work, which is why the surface-vs-IR layering is the master distinction of the architecture: a human authors the surface, a tool reasons over the IR.

---

## 1. The IR envelope

A SOL IR document MUST be a single JSON object with **exactly five top-level keys**, in this order:

```json
{
  "meta":        { },
  "nodes":       [ ],
  "edges":       [ ],
  "diagnostics": [ ],
  "provenance":  { }
}
```

| Key | JSON type | Cardinality | Purpose |
|---|---|---|---|
| `meta` | object | exactly 1 | Spec-level identity, language discriminator, version, status, ownership, imports. |
| `nodes` | array of node objects | 0..n | The merged obligation records — one per surface block. |
| `edges` | array of edge objects | 0..n | The typed relationships between nodes — the single source of relationship truth. |
| `diagnostics` | array of diagnostic objects | 0..n | SARIF-shaped lint/compile findings keyed to the unified `SOL-<LAYER><NNN>` taxonomy. |
| `provenance` | object | exactly 1 | Emission facts: source hash, compiler version, compile timestamp. |

A conformant IR document MUST contain all five keys. An empty spec (no blocks) still emits `nodes: []`, `edges: []`, `diagnostics: []` and fully-populated `meta` and `provenance`. No additional top-level keys are permitted in SOL/0.1; unknown top-level keys MUST be rejected by a validating consumer.

### 1.1 `meta` — spec identity and the three version fields

`meta` carries spec-level identity and the three distinct version axes.

```json
{
  "id": "auth-refresh",
  "title": "Access-token refresh",
  "language": "SOL/0.1",
  "version": "0.1.0",
  "status": "draft",
  "owners": ["@auth-platform"],
  "imports": ["shared/security.swarm.md"]
}
```

| Field | JSON type | Required | Meaning |
|---|---|---|---|
| `id` | string | MUST | Stable spec identifier (slug); matches the surface frontmatter `id`, e.g. `auth-refresh`. |
| `title` | string | SHOULD | Human-readable spec title. |
| `language` | string | MUST | The SOL language discriminator, exactly **`SOL/0.1`** for this version. Answers "which grammar / blocks / modals / lint codes." Never merged with `version`. |
| `version` | string | MUST | The **spec content** version — the SemVer of the authored `*.swarm.md` source (e.g. `0.1.0`). Pattern `^[0-9]+\.[0-9]+\.[0-9]+$`. Distinct from `language`. |
| `status` | string | MUST | Spec lifecycle state; one of `draft`, `review`, `approved`, `superseded`. |
| `owners` | array of string | SHOULD (MAY be empty) | Accountable maintainers (handles). |
| `imports` | array of string | SHOULD (MAY be empty) | Relative paths to imported `*.swarm.md` specs whose nodes are in scope for cross-spec reference resolution. |

### 1.2 `nodes[]` — the merged obligation record

Each element of `nodes[]` is one **merged obligation record**: the fully normalized form of a single surface block (`REQ`, `CONSTRAINT`, `INVARIANT`, `INTERFACE`, `QUESTION`, `TRACE`, or `VERDICT` — the seven block types). "Merged" means every clause, modal, scope set, proof binding, status, and source span for that block is collected into one record; nothing about a block is scattered except its *relationships*, which live in `edges[]`. Only `id`, `kind`, and `source` are schema-`required`; the rest are optional-with-`default` (defaulting to `[]`, or to `UNVERIFIED` for `status`) so that the validatable shape stays minimal while the intent table below records which fields a well-formed node carries.

| Field | JSON type | Required (intent) | Meaning |
|---|---|---|---|
| `id` | string | MUST | IR node id. MAY be namespaced as `<KIND>.<spec>.<surface-id>` (e.g. `REQ.auth-refresh.AC-001`); the short surface id (`AC-001`) MUST be recoverable from it. |
| `kind` | string | MUST | One of `REQ`, `CONSTRAINT`, `INVARIANT`, `INTERFACE`, `QUESTION`, `TRACE`, `VERDICT`. |
| `authority` | string | MUST for obligation kinds | The resolved domain-authority rank governing this node (e.g. `security`, `architecture`, `product`), lowered from the obligation's `DOMAIN` clause or the spec frontmatter. MAY be absent/`null` for `QUESTION`/`TRACE`. |
| `modality` | string \| null | MUST for `REQ`/`CONSTRAINT`/`INVARIANT` | The binding modal: one of `MUST`, `MUST NOT`, `SHOULD`, `SHOULD NOT`, `MAY`. `null` for kinds that carry no modal (`INTERFACE`, `QUESTION`, `TRACE`, `VERDICT`). Mirrors `clauses.modal`. |
| `clauses` | object | MUST | The structured decomposition of the control sentence (§1.2.1). |
| `owner` | string \| null | SHOULD | The accountable owner — lowering of `OWNED BY`. |
| `risk` | string \| null | MAY | One of `low`, `medium`, `high`, `critical` — lowering of `RISK`. |
| `reads` | array of string | MUST (MAY be empty) | The **read** scope set — lowering of `READS`. |
| `writes` | array of string | MUST (MAY be empty) | The **write** scope set — lowering of `WRITES`. Surface names are `SURFACE` ids; there is no `locks` field. |
| `verify_by` | array of object | MUST (MAY be empty) | Normalized proof bindings (§1.2.2) — lowering of `VERIFY BY`. |
| `status` | string | MUST | The node's **core** verdict: one of `PASS`, `FAIL`, `BLOCKED`, `UNVERIFIED`. Closed over the four core values only; defaults to `UNVERIFIED` before a verdict exists. |
| `lifecycle` | array of string | MUST (MAY be empty) | Lifecycle decorators in effect — a subset of `{WAIVED, STALE, CONTRADICTED}`. Carried as a separate field, never fused into `status`. |
| `source` | object | MUST | Origin span and content hash (§1.2.3). |
| `provenance` | array of object | MUST (MAY be empty) | Per-node provenance trail: prior verdicts, lowering ancestry, promotion lineage. Free-form objects whose minimal pinned shape is the trace-provenance record. |

#### 1.2.1 `clauses{}`

`clauses` is the structured form of the surface control sentence. Every key is present; an absent surface clause is `null`. The sub-object is identical in shape across kinds; kinds that do not use a given clause leave it `null`.

| Clause key | Source surface clause | JSON type | Notes |
|---|---|---|---|
| `where` | `WHERE <expr>` | string \| null | Precondition / state qualifier; opaque text in v0.1. |
| `while` | `WHILE <expr>` | string \| null | Sustained-state qualifier; opaque text. |
| `trigger` | `WHEN` / `IF [THEN] <expr>` | object \| null | `{ "kw": "WHEN" \| "IF" \| null, "expr": <string \| null> }`. `THEN` is sugar after `IF` only and is not represented as data. |
| `subject` | `THE <actor>` | string \| null | The bound actor. |
| `modal` | `<MODAL>` | string \| null | The binding modal (mirrors top-level `modality`). |
| `predicate` | `<response>` | string \| null | The required behaviour; opaque text. |
| `timing` | (deferred) | string \| null | RESERVED. Timing keywords (`WITHIN` / `BEFORE` / `UNTIL` / `IMMEDIATELY` / `EVENTUALLY`) are deferred to SOL/0.2; in SOL/0.1 this MUST be `null`. |
| `signature` | `INTERFACE` signature | string \| null | The `INTERFACE` signature; `null` for non-`INTERFACE` kinds. |
| `returns` | `RETURNS <type>` | string \| null | The `INTERFACE` return type. |
| `accepts` | `ACCEPTS:` bullets | array of string | The `INTERFACE` accepted-input bullets. Defaults to `[]`. |
| `errors` | `ERRORS:` bullets | array of string | The `INTERFACE` error bullets. Defaults to `[]`. |

For a chained obligation (`THE … MUST … AND THE … MUST …`), the lowering pass splits it into multiple nodes, one per `THE <actor> <MODAL> <response>` clause; each resulting node has a single-obligation `clauses` object. An `INVARIANT` lowers `<property> MUST|MUST NOT <hold>` into `subject` = the property and `predicate` = the held condition. An `INTERFACE` has no `subject`/`modal`/`predicate`; its `RETURNS`/`ACCEPTS`/`ERRORS` lower into the `signature`/`returns`/`accepts`/`errors` slots, `OWNED BY` into the node `owner`, and a `contract` proof binding MUST be present in `verify_by`.

#### 1.2.2 `verify_by[]` — normalized proof bindings

Each surface `VERIFY BY <type>:<adapter>:<artifact>[#selector]` clause normalizes to one object:

```json
{ "type": "test", "adapter": "cmdTest", "ref": "web/tests/auth.spec.ts", "selector": "retries once", "gate": "required" }
```

| Field | JSON type | Required | Meaning |
|---|---|---|---|
| `type` | string | MUST | One of the 9 closed proof types: `static`, `test`, `contract`, `property`, `model`, `perf`, `security`, `manual`, `monitor`. Test scope qualifiers (`test:unit`, `test:integration`, `test:e2e`) are carried verbatim in `type`. |
| `adapter` | string | MUST | The AGENTS.md > Commands slot the type resolves through (a `cmd*` placeholder, e.g. `cmdTest`, `cmdLint`); a free string, not a command this framework runs. |
| `ref` | string | MUST | The project artifact (test file, contract file, model, checklist id); a free string. |
| `selector` | string \| null | MAY | The `#selector` fragment — a specific case/property/invariant name within `ref`. |
| `gate` | string | MUST (defaults `required`) | `required` or `advisory`; `required` bindings participate in the merge gate. |

#### 1.2.3 `source{}`

```json
{ "file": "auth-refresh.swarm.md", "line_start": 18, "line_end": 27, "content_hash": "sha256:9f2c…" }
```

| Field | JSON type | Required | Meaning |
|---|---|---|---|
| `file` | string | MUST | Relative path to the originating `*.swarm.md`. |
| `line_start` | integer (≥1) | MUST | First line of the block (1-based). |
| `line_end` | integer (≥1) | MUST | Last line of the block. |
| `content_hash` | string | MUST | Content hash of the block's source text (e.g. `sha256:…`); the obligation-source hash the drift model joins against (drives `STALE` detection). |

#### 1.2.4 `status` — the verdict model, carried as two fields

The verdict model is carried as **two orthogonal fields, never fused**: `status` is the **core** verdict (one of four mutually-exclusive values) and `lifecycle[]` is the set of decorators in effect (a subset of `{WAIVED, STALE, CONTRADICTED}`). This separation keeps the merge gate and verdict lint closed over the four core values while lifecycle state evolves independently.

| Value | Class | Meaning |
|---|---|---|
| `PASS` | core | A bound required proof ran and succeeded. |
| `FAIL` | core | A bound proof ran and failed. |
| `BLOCKED` | core | A bound proof could not run (missing prereq / tool / env). |
| `UNVERIFIED` | core | No acceptable proof bound, or none executed. The default for a freshly-lowered, never-executed obligation. |
| `WAIVED` | lifecycle | A `FAIL`/`UNVERIFIED` accepted with authority + reason + expiry. |
| `STALE` | lifecycle | A prior `PASS` whose evidence no longer matches the current source/surface hashes. |
| `CONTRADICTED` | lifecycle | Two proofs disagree, or trace/code disagrees with the obligation. |

### 1.3 `edges[]` — the single source of relationship truth

Every relationship between two nodes is one typed directed edge.

```json
{ "from": "REQ.auth-refresh.AC-001", "to": "INTERFACE.auth-refresh.IF-001", "type": "depends_on", "hard": true }
```

| Field | JSON type | Required | Meaning |
|---|---|---|---|
| `from` | string | MUST | Source node id. |
| `to` | string | MUST | Target node id. |
| `type` | string | MUST | One of the 7 closed edge types: `depends_on`, `blocks`, `conflicts_with`, `verified_by`, `affects`, `implements`, `preserves`. |
| `hard` | boolean | MUST (defaults `true`) | `true` = a hard relationship (mandatory ordering, hard conflict, required proof); `false` = soft/advisory. |

> **Edges are the single source of relationship truth.** A relationship between two nodes MUST be represented exactly once, as an edge, and MUST NOT also be duplicated as a node scalar — there is no `depends_on`, `blocks`, `conflicts_with`, `verified_by`, `affects`, `implements`, or `preserves` field on a node. A consumer computing dependency order, conflict, or traceability MUST read `edges[]` and MUST NOT reconstruct relationships from node fields. Design rationale: a relationship stored twice can disagree; one representation cannot.

This is distinct from the **scope sets** on a node (`reads`, `writes`): a scope set answers "what region of the world does this single obligation touch?" — intrinsic node data — while an edge answers "how do two nodes relate?" The lowering pass *derives* `conflicts_with` and `affects` edges *from* scope sets (e.g. two nodes sharing a write surface yield a `conflicts_with` edge), keeping the raw declaration on the node and the computed relationship in the graph so the derivation is auditable and the two never silently disagree. `affects` is purely an edge type (a resolved node→node impact link); it is not also a node scope set.

### 1.4 `diagnostics[]`

Each diagnostic is a SARIF-shaped finding keyed to the unified `SOL-<LAYER><NNN>` lint namespace.

```json
{
  "code": "SOL-V001",
  "level": "error",
  "node": "REQ.auth-refresh.AC-002",
  "source": { "file": "auth-refresh.swarm.md", "line_start": 31, "line_end": 33 },
  "message": "Obligation has no VERIFY BY binding; no verification path."
}
```

| Field | JSON type | Required | Meaning |
|---|---|---|---|
| `code` | string | MUST | A unified lint code matching `^SOL-[SPMVO][0-9]{3}$` — the five layers being `S` SYNTAX, `P` PROSE, `M` SEMANTIC, `V` VERIFICATION, `O` ORCHESTRATION. |
| `level` | string | MUST | SARIF level: `error`, `warning`, or `note`. Maps to the BLOCKING/ADVISORY split (`BLOCKING` ⇒ `error`; `ADVISORY` ⇒ `warning`); `note` carries informational findings. A waiver that demotes a code to `off` suppresses it — the diagnostic is omitted entirely, not emitted with an `off` level. |
| `node` | string \| null | one of `node`/`source` MUST be present | The node id the finding attaches to, if node-scoped. |
| `source` | object \| null | one of `node`/`source` MUST be present | A source span `{ file, line_start, line_end }` for findings with no resolved node (e.g. a parse error). |
| `message` | string | MUST | Human-readable finding text. |
| `suggest` | string \| null | MAY | An optional fix hint — the closed improve op or repair that resolves it. |

Diagnostics live only in `diagnostics[]`; they are never folded into node `status` (a node's `status` is its verdict, not its lint state).

### 1.5 `provenance`

```json
{ "hash": "sha256:source-file-digest…", "compiler_version": null, "compiled_at": "2026-05-31T12:00:00Z" }
```

| Field | JSON type | Required | Meaning |
|---|---|---|---|
| `hash` | string | MUST | Content hash of the whole source `*.swarm.md` at emission. |
| `compiler_version` | string \| null | MUST (MAY be `null`) | The emitting tool's version — the third version axis. **`null` today**, because no emitter ships. |
| `compiled_at` | string \| null | MUST (MAY be `null`) | ISO-8601 timestamp of emission; `null` until a tool emits. |

### 1.6 The three version fields (never merged)

The envelope echoes **three distinct version axes**. They occupy three distinct fields and a consumer MUST NOT collapse, merge, or infer one from another:

| Field | Axis | Answers | Today |
|---|---|---|---|
| `meta.language` | LANGUAGE | Which SOL grammar / block set / modal set / lint codes apply | `SOL/0.1` |
| `meta.version` | SPEC CONTENT | Which revision of this spec's obligations | e.g. `0.1.0` |
| `provenance.compiler_version` | TOOL | Which emitter produced this IR | `null` (no shipped emitter) |

These three values drift independently and MUST remain three fields.

### 1.7 The IR JSON Schema (normative)

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "$id": "https://swarm.dev/schema/0.1/swarm.ir.json",
  "title": "Swarm IR envelope (*.swarm.ir.json)",
  "type": "object",
  "additionalProperties": false,
  "required": ["meta", "nodes", "edges", "diagnostics", "provenance"],
  "properties": {
    "meta": {
      "type": "object",
      "additionalProperties": false,
      "required": ["id", "language", "version", "status"],
      "properties": {
        "id":      { "type": "string", "description": "Spec id (slug); e.g. auth-refresh" },
        "title":   { "type": "string" },
        "language":{ "const": "SOL/0.1", "description": "SOL language discriminator; never merged with version" },
        "version": { "type": "string", "pattern": "^[0-9]+\\.[0-9]+\\.[0-9]+$", "description": "Spec content SemVer; never merged with language" },
        "status":  { "enum": ["draft", "review", "approved", "superseded"] },
        "owners":  { "type": "array", "items": { "type": "string" }, "default": [] },
        "imports": { "type": "array", "items": { "type": "string", "description": "Path to an imported *.swarm.md" }, "default": [] }
      }
    },

    "nodes": {
      "type": "array",
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": ["id", "kind", "source"],
        "properties": {
          "id":   { "type": "string", "description": "IR node id; MAY be namespaced, e.g. REQ.auth-refresh.AC-001 (surface id is the short AC-001)" },
          "kind": { "enum": ["REQ", "CONSTRAINT", "INVARIANT", "INTERFACE", "QUESTION", "TRACE", "VERDICT"] },
          "authority": { "type": "string", "description": "Domain authority rank label (Axis B): e.g. security, architecture, product" },
          "modality":  { "enum": ["MUST", "MUST NOT", "SHOULD", "SHOULD NOT", "MAY", null], "description": "Binding force; obligation kinds (REQ/CONSTRAINT/INVARIANT) only; null for INTERFACE/QUESTION/TRACE/VERDICT" },
          "clauses": {
            "type": "object",
            "additionalProperties": false,
            "description": "Lowered SOL clauses; null/absent for inapplicable slots",
            "properties": {
              "where":     { "type": ["string", "null"] },
              "while":     { "type": ["string", "null"] },
              "trigger":   { "type": ["object", "null"], "additionalProperties": false, "properties": { "kw": { "enum": ["WHEN", "IF", null] }, "expr": { "type": ["string", "null"] } }, "description": "Lowering of WHEN/IF — the {kw, expr} discriminator" },
              "subject":   { "type": ["string", "null"], "description": "The actor in THE <actor> <MODAL> <response>" },
              "modal":     { "enum": ["MUST", "MUST NOT", "SHOULD", "SHOULD NOT", "MAY", null] },
              "predicate": { "type": ["string", "null"], "description": "The response/predicate" },
              "timing":    { "type": ["string", "null"], "description": "RESERVED; timing keywords deferred to SOL/0.2" },
              "signature": { "type": ["string", "null"], "description": "INTERFACE signature; null for non-INTERFACE kinds" },
              "returns":   { "type": ["string", "null"], "description": "INTERFACE RETURNS type" },
              "accepts":   { "type": "array", "items": { "type": "string" }, "default": [], "description": "INTERFACE ACCEPTS bullets" },
              "errors":    { "type": "array", "items": { "type": "string" }, "default": [], "description": "INTERFACE ERRORS bullets" }
            }
          },
          "owner":  { "type": ["string", "null"], "description": "Lowering of OWNED BY" },
          "risk":   { "enum": ["low", "medium", "high", "critical", null] },
          "reads":  { "type": "array", "items": { "type": "string" }, "default": [] },
          "touches":{ "type": "array", "items": { "type": "string" }, "default": [], "description": "Lowering of TOUCHES — surfaces the obligation touches but does not own/write" },
          "writes": { "type": "array", "items": { "type": "string", "description": "Write surface path/glob or named SURFACE member" }, "default": [] },
          "verify_by": {
            "type": "array",
            "default": [],
            "items": {
              "type": "object",
              "additionalProperties": false,
              "required": ["type", "adapter", "ref"],
              "properties": {
                "type":     { "enum": ["static", "test", "contract", "property", "model", "perf", "security", "manual", "monitor"], "description": "Closed 9-type proof taxonomy" },
                "adapter":  { "type": "string", "description": "Resolves through AGENTS.md > Commands (a cmd* slot); free string" },
                "ref":      { "type": "string", "description": "Artifact reference; free string" },
                "selector": { "type": ["string", "null"], "description": "Lowering of #selector; e.g. a test name or invariant name" },
                "gate":     { "enum": ["required", "advisory"], "default": "required" }
              }
            }
          },
          "status": { "enum": ["PASS", "FAIL", "BLOCKED", "UNVERIFIED"], "description": "Core verdict (one of four); UNVERIFIED is the default before a verdict exists" },
          "lifecycle": { "type": "array", "items": { "enum": ["WAIVED", "STALE", "CONTRADICTED"] }, "default": [], "description": "Lifecycle decorators on the core verdict; empty for a plain core verdict. Carried as a separate field, never fused into status" },
          "source": {
            "type": "object",
            "additionalProperties": false,
            "required": ["file", "line_start", "line_end", "content_hash"],
            "properties": {
              "file":         { "type": "string" },
              "line_start":   { "type": "integer", "minimum": 1 },
              "line_end":     { "type": "integer", "minimum": 1 },
              "content_hash": { "type": "string", "description": "Hash of the obligation source span; the drift model joins against it (drives STALE)" }
            }
          },
          "provenance": { "type": "array", "items": { "type": "object" }, "default": [], "description": "Per-node trace/finding provenance objects; minimal pinned shape = the trace-provenance schema" }
        }
      }
    },

    "edges": {
      "type": "array",
      "description": "Single source of relationship truth; relationships are NOT also node scalars",
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": ["from", "to", "type"],
        "properties": {
          "from": { "type": "string", "description": "Source node id" },
          "to":   { "type": "string", "description": "Target node id" },
          "type": { "enum": ["depends_on", "blocks", "conflicts_with", "verified_by", "affects", "implements", "preserves"] },
          "hard": { "type": "boolean", "default": true, "description": "true = hard ordering/conflict; false = soft/advisory" }
        }
      }
    },

    "diagnostics": {
      "type": "array",
      "description": "SARIF-shaped; attach to a node or a source span",
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": ["code", "level", "message"],
        "anyOf": [ { "required": ["node"] }, { "required": ["source"] } ],
        "properties": {
          "code":    { "type": "string", "pattern": "^SOL-[SPMVO][0-9]{3}$", "description": "Unified lint namespace" },
          "level":   { "enum": ["error", "warning", "note"] },
          "node":    { "type": ["string", "null"], "description": "Node id the diagnostic is bound to, if any" },
          "source": {
            "type": ["object", "null"],
            "additionalProperties": false,
            "properties": {
              "file":       { "type": "string" },
              "line_start": { "type": "integer", "minimum": 1 },
              "line_end":   { "type": "integer", "minimum": 1 }
            }
          },
          "message": { "type": "string" },
          "suggest": { "type": ["string", "null"], "description": "Optional fix hint (the improve op or repair)" }
        }
      }
    },

    "provenance": {
      "type": "object",
      "additionalProperties": false,
      "required": ["hash", "compiler_version", "compiled_at"],
      "properties": {
        "hash":             { "type": "string", "description": "Hash of the source *.swarm.md this IR was emitted from" },
        "compiler_version": { "type": ["string", "null"], "description": "Tool version; null until a tool exists; never merged with meta.language or meta.version" },
        "compiled_at":      { "type": ["string", "null"], "format": "date-time" }
      }
    }
  }
}
```

### 1.8 Annotated example instance

A minimal 3-node graph: one `REQ` (verified by a test and a property), one `INTERFACE` it depends on (which MUST itself carry a `contract` proof), and one diagnostic. `edges[]` carries every relationship; no relationship is repeated as a node scalar.

```json
{
  "meta": {
    "id": "auth-refresh",
    "title": "Access token refresh",
    "language": "SOL/0.1",
    "version": "0.1.0",
    "status": "draft",
    "owners": ["@auth-platform"],
    "imports": ["shared/security.swarm.md"]
  },
  "nodes": [
    {
      "id": "REQ.auth-refresh.AC-001",
      "kind": "REQ",
      "authority": "security",
      "modality": "MUST",
      "clauses": {
        "where": null, "while": null,
        "trigger": { "kw": "WHEN", "expr": "response.status == 401 AND refresh_token present" },
        "subject": "web-client",
        "modal": "MUST",
        "predicate": "retry original_request once",
        "timing": null
      },
      "owner": "@web-platform",
      "risk": "medium",
      "reads": [], "writes": ["web/src/http/client.ts"],
      "verify_by": [
        { "type": "test",     "adapter": "cmdTest", "ref": "web/tests/auth-refresh-401.spec.ts", "selector": null, "gate": "required" },
        { "type": "property", "adapter": "cmdTest", "ref": "web/tests/auth-refresh.properties.ts", "selector": "no_unbounded_retry", "gate": "required" }
      ],
      "status": "UNVERIFIED",
      "source": { "file": "auth-refresh.swarm.md", "line_start": 18, "line_end": 29, "content_hash": "sha256:9f1c…" },
      "provenance": []
    },
    {
      "id": "INTERFACE.auth-refresh.IF-001",
      "kind": "INTERFACE",
      "authority": "architecture",
      "owner": "@auth-platform",
      "verify_by": [
        { "type": "contract", "adapter": "cmdValidate", "ref": "openapi/auth.yaml", "selector": "POST /token/refresh", "gate": "required" }
      ],
      "status": "UNVERIFIED",
      "source": { "file": "auth-refresh.swarm.md", "line_start": 31, "line_end": 38, "content_hash": "sha256:2ab7…" },
      "provenance": []
    }
  ],
  "edges": [
    { "from": "REQ.auth-refresh.AC-001", "to": "INTERFACE.auth-refresh.IF-001", "type": "depends_on", "hard": true }
  ],
  "diagnostics": [
    { "code": "SOL-V003", "level": "warning", "node": "REQ.auth-refresh.AC-001", "source": null,
      "message": "obligation bound to a unit test where a stronger proof is preferred; prefer property|model|static.", "suggest": "BIND a property: or model: proof" }
  ],
  "provenance": {
    "hash": "sha256:c0ffee…",
    "compiler_version": null,
    "compiled_at": "2026-05-31T12:00:00Z"
  }
}
```

Notes on the instance: `meta.language` (`SOL/0.1`), `meta.version` (`0.1.0`), and `provenance.compiler_version` (`null`, no tool exists) are the three distinct version fields and are never collapsed; the `verify_by[].adapter` values (`cmdTest`, `cmdValidate`) are AGENTS.md > Commands slots, not commands this framework runs; node `status` is `UNVERIFIED` because no `VERDICT` block has judged either obligation yet; the diagnostic `code` matches `^SOL-[SPMVO][0-9]{3}$`.

### 1.9 IR conformance

A document is a conformant SOL/0.1 IR iff it: (1) has exactly the five top-level keys of §1; (2) populates every field the schema marks `required`, and supplies the documented `default` for any optional field it omits; (3) uses only the closed enumerations (7 node kinds, 5 modals, 9 proof types, 7 edge types, the four core verdict values plus the three lifecycle decorators, and the `SOL-<LAYER><NNN>` code space); (4) represents every relationship once, as an edge (§1.3); (5) keeps the three version fields distinct (§1.6). The normative machine-readable form is the JSON Schema of §1.7; the intent tables above record which fields a well-formed node carries beyond the minimal `required` set.

---

## 2. The plan envelope

The plan is the schedulable projection of the IR — derived from it by the `decompose` pass — and carries the **same contract-only status**: no tool emits it, no scheduler executes it. What is out of scope here is the live scheduler/harness that would execute the work packets across agents; the plan itself is the kernel's *static* coordination contract.

A SOL plan document MUST be a single JSON object with **exactly four top-level keys**:

```json
{
  "meta":      { },
  "packets":   [ ],
  "edges":     [ ],
  "provenance":{ }
}
```

| Key | JSON type | Cardinality | Purpose |
|---|---|---|---|
| `meta` | object | exactly 1 | Plan-level identity, the spec/IR it derives from, the three version fields. |
| `packets` | array of work-packet objects | 0..n | The schedulable work units (§2.2). |
| `edges` | array of edge objects | 0..n | Inter-packet relationships — the same single-source-of-relationship-truth rule as the IR. |
| `provenance` | object | exactly 1 | Emission facts; same shape as the IR `provenance`. |

The plan reuses the IR's structural discipline: relationships between packets live only in `edges[]` (never duplicated as packet scalars), and the three version fields stay distinct. The plan carries `writes[]` (write surfaces) and **never a `locks` field** — a lock group is a named coarse write `SURFACE`, so lock-set analysis *is* write-set analysis at surface granularity.

### 2.1 `meta`

```json
{
  "id": "auth-refresh",
  "derived_from": "auth-refresh.swarm.ir.json",
  "language": "SOL/0.1",
  "version": "0.1.0",
  "max_parallel": null
}
```

| Field | JSON type | Required | Meaning |
|---|---|---|---|
| `id` | string | MUST | Spec/plan identifier; matches `meta.id` of the source IR. |
| `derived_from` | string | MUST | Path to the `*.swarm.ir.json` this plan was lowered from. |
| `language` | string | MUST | The SOL discriminator (`SOL/0.1`); same axis as the IR `meta.language`. |
| `version` | string | MUST | The spec content version this plan reflects. Pattern `^[0-9]+\.[0-9]+\.[0-9]+$`. |
| `max_parallel` | integer \| null | MAY (defaults `null`) | An advisory parallelism hint for a launcher; `null` = unspecified. The kernel computes *safety* (§2.3); concurrency *limits* are a launcher policy. |

### 2.2 `packets[]` — work packets

A **work packet** is one schedulable unit: a single pass applied (under an optional profile) to a selected set of obligations, with declared scope, ordering, and a merge-safety verdict.

```json
{
  "id": "WP-002",
  "pass": "implement",
  "profile": "default",
  "inputs":  ["REQ.auth-refresh.AC-001"],
  "outputs": ["web/src/http/client.ts", "auth-refresh.swarm.trace.md"],
  "writes":  ["web.http.client"],
  "reads":   ["api.auth.session-store"],
  "depends_on": ["WP-001"],
  "lane": "agent-a",
  "batch": 1,
  "merge_safe": true
}
```

| Field | JSON type | Required | Meaning |
|---|---|---|---|
| `id` | string | MUST | Packet identifier, unique within the plan. |
| `pass` | string | MUST | The pass this packet runs: one of the 9 passes `author`, `lint`, `improve`, `lower`, `decompose`, `implement`, `verify`, `review`, `promote`. |
| `profile` | string \| null | MAY (defaults `null`) | The heuristic profile parameterizing the pass (e.g. `skeptic` on `review`, `lead-engineer` on `decompose`). `null` = the pass's default profile. |
| `inputs` | array of string | MUST | The node ids (obligations / questions / traces) this packet consumes. |
| `outputs` | array of string | MUST | The artifacts this packet is expected to produce (code paths, `*.swarm.trace.md`, `review.md`, `finding.md`, …). |
| `writes` | array of string | MUST (MAY be empty) | The **write surfaces** this packet modifies — `SURFACE` ids, derived from the `writes` scope sets of its `inputs`. Every write surface here MUST be a subset of its obligations' declared `WRITES`. No `locks` field. |
| `reads` | array of string | MUST (MAY be empty) | The read surfaces this packet touches. |
| `depends_on` | array of string | MUST (MAY be empty) | Packet ids that MUST complete before this packet; the merge-order partial order. Each entry MUST also appear as a `depends_on` edge. |
| `lane` | string \| null | MAY (defaults `null`) | A suggested execution lane/worker label. A launcher hint only; absence does not affect safety. |
| `batch` | integer \| null | MAY (defaults `null`) | A suggested wave/round index for staged fan-out. Launcher hint only. |
| `merge_safe` | boolean | MUST | The kernel's verdict on whether this packet may run concurrently with its batch-mates: `true` iff it is dependency-independent of and write-disjoint from every other packet it would run alongside (§2.3). |

#### 2.2.1 Packet edges

Inter-packet relationships use the same edge object as the IR — `{ from, to, type, hard }` — drawn from the same closed 7-type set. The relevant types for a plan are `depends_on` (ordering) and `conflicts_with` (a shared write surface, or a read/write conflict on one surface). `conflicts_with` edges are what make a packet `merge_safe: false` against its conflict-mates. As in the IR, these relationships MUST live only in `edges[]`; the per-packet `depends_on[]` array is the declaration, the edge is the computed graph relationship.

### 2.3 The safe-parallelism predicate

The plan's `merge_safe` flag is the surface of the kernel's single canonical safe-parallelism predicate:

> Two work packets MAY run in parallel **iff** they are **dependency-independent** (neither is reachable from the other along `depends_on` edges) **AND write-disjoint** (their `writes` sets share no `SURFACE`, there is no read/write conflict on a shared surface, and they share no interface/migration node). Anything unscoped or sharing a surface **serializes by default**.

A packet's `merge_safe` MUST be `false` if it has any unresolved `conflicts_with` edge to a packet in the same `batch`, or if any of its `inputs` is unscoped (empty `writes` where a write is implied). `merge_safe` is the kernel's *static* verdict; a launcher MAY further serialize for its own reasons but MUST NOT parallelize two packets the plan marks unsafe. Design rationale: review entropy and merge collisions, not agent count, are the binding constraint on safe parallelism.

### 2.4 The plan JSON Schema (normative)

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "$id": "https://swarm.dev/schema/0.1/swarm.plan.json",
  "title": "Swarm plan envelope (*.swarm.plan.json)",
  "type": "object",
  "additionalProperties": false,
  "required": ["meta", "packets", "edges", "provenance"],
  "properties": {
    "meta": {
      "type": "object",
      "additionalProperties": false,
      "required": ["id", "derived_from", "language", "version"],
      "properties": {
        "id":           { "type": "string", "description": "Plan id (slug); typically the source spec id." },
        "derived_from": { "type": "string", "description": "The *.swarm.ir.json / spec id this plan was derived from." },
        "max_parallel": { "type": ["integer", "null"], "default": null, "description": "Advisory parallelism hint for a launcher." },
        "language":     { "const": "SOL/0.1", "description": "SOL language discriminator; never merged with version." },
        "version":      { "type": "string", "pattern": "^[0-9]+\\.[0-9]+\\.[0-9]+$", "description": "Spec content SemVer; never merged with language." }
      }
    },
    "packets": {
      "type": "array",
      "description": "Work packets.",
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": ["id", "pass", "inputs", "outputs", "merge_safe"],
        "properties": {
          "id":         { "type": "string", "description": "Packet id, unique within the plan." },
          "pass":       { "enum": ["author", "lint", "improve", "lower", "decompose", "implement", "verify", "review", "promote"] },
          "profile":    { "type": ["string", "null"], "default": null, "description": "Heuristic profile; null = the pass default." },
          "inputs":     { "type": "array", "items": { "type": "string" }, "description": "Node ids this packet consumes." },
          "outputs":    { "type": "array", "items": { "type": "string" }, "description": "Artifacts produced (code paths, trace/review/finding)." },
          "writes":     { "type": "array", "items": { "type": "string" }, "default": [], "description": "Write surfaces; each MUST be a subset of its inputs' WRITES (SOL-O005)." },
          "reads":      { "type": "array", "items": { "type": "string" }, "default": [] },
          "depends_on": { "type": "array", "items": { "type": "string" }, "default": [], "description": "Packet ids; each MUST also appear as a depends_on edge." },
          "lane":       { "type": ["string", "null"], "default": null, "description": "Launcher hint only." },
          "batch":      { "type": ["integer", "null"], "default": null, "description": "Launcher hint only." },
          "merge_safe": { "type": "boolean", "description": "Kernel verdict: dependency-independent + write-disjoint from batch-mates." }
        }
      }
    },
    "edges": {
      "type": "array",
      "description": "Single source of inter-packet relationship truth; closed edge-type set.",
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": ["from", "to", "type"],
        "properties": {
          "from": { "type": "string", "description": "Source packet id." },
          "to":   { "type": "string", "description": "Target packet id." },
          "type": { "enum": ["depends_on", "blocks", "conflicts_with", "verified_by", "affects", "implements", "preserves"] },
          "hard": { "type": "boolean", "default": true }
        }
      }
    },
    "provenance": {
      "type": "object",
      "additionalProperties": false,
      "required": ["hash", "compiler_version", "compiled_at"],
      "properties": {
        "hash":             { "type": "string", "description": "Hash of the source IR/spec this plan was derived from." },
        "compiler_version": { "type": ["string", "null"], "description": "Tool version; null until a tool exists." },
        "compiled_at":      { "type": ["string", "null"], "format": "date-time" }
      }
    }
  }
}
```

### 2.5 Worked plan fragment

For the auth-refresh spec (one `INTERFACE`, one `REQ` depending on it, one `INVARIANT`), a conformant plan fragment:

```json
{
  "meta": { "id": "auth-refresh", "derived_from": "auth-refresh.swarm.ir.json",
            "language": "SOL/0.1", "version": "0.1.0", "max_parallel": null },
  "packets": [
    { "id": "WP-001", "pass": "implement", "profile": "default",
      "inputs": ["INTERFACE.auth-refresh.IF-001"], "outputs": ["openapi/auth-refresh.yaml"],
      "writes": ["api.auth.contract"], "reads": [], "depends_on": [],
      "lane": "shared", "batch": 0, "merge_safe": false },
    { "id": "WP-002", "pass": "implement", "profile": "default",
      "inputs": ["REQ.auth-refresh.AC-001", "INVARIANT.auth-refresh.I-001"], "outputs": ["web/src/http/client.ts"],
      "writes": ["web.http.client"], "reads": ["api.auth.contract"],
      "depends_on": ["WP-001"], "lane": "agent-a", "batch": 1, "merge_safe": true },
    { "id": "WP-003", "pass": "verify", "profile": "default",
      "inputs": ["INVARIANT.auth-refresh.I-001"], "outputs": ["auth-refresh.swarm.trace.md"],
      "writes": ["web.http.tests"], "reads": ["web.http.client"],
      "depends_on": ["WP-002"], "lane": "agent-b", "batch": 2, "merge_safe": true }
  ],
  "edges": [
    { "from": "WP-002", "to": "WP-001", "type": "depends_on", "hard": true },
    { "from": "WP-003", "to": "WP-002", "type": "depends_on", "hard": true }
  ],
  "provenance": { "hash": "sha256:…", "compiler_version": null, "compiled_at": "2026-05-31T12:00:00Z" }
}
```

`WP-001` is `merge_safe: false` (it freezes a shared interface contract; consumers serialize behind it); `WP-002` and `WP-003` are write-disjoint from their batch-mates and depend only on completed prior batches, so they are `merge_safe: true`.

### 2.6 Plan conformance

A document is a conformant SOL/0.1 plan iff it: (1) has exactly the four top-level keys of §2; (2) populates every field the §2.4 schema marks `required` (defaulting optional fields); (3) carries **no `locks` field** anywhere; (4) uses only the closed pass set in `packets[].pass` and the closed 7-type edge set in `edges[]`; (5) represents inter-packet relationships once, as edges (§2.2.1); (6) keeps the three version fields distinct (§1.6). The plan is documented data only — no running emitter or scheduler ships. The normative machine-readable form is the JSON Schema of §2.4.

---

## Related

- [docs/model/compiler-pipeline.md](../model/compiler-pipeline.md) — the seven phases / nine passes that emit and consume the IR and the plan; the `lower` and `decompose` passes that produce them.
- [docs/language/versioning.md](../language/versioning.md) — the two version axes and the three version fields (`meta.language`, `meta.version`, `provenance.compiler_version`) these envelopes carry.
- [docs/language/SOL.md](../language/SOL.md) — the surface language: the 7 block types, 5 modals, and clause grammar these JSON fields are the lowering of.
- [docs/language/errors.md](../language/errors.md) — the `SOL-<LAYER><NNN>` lint catalogue the `diagnostics[]` array carries.
- [docs/reference/proof-types.md](./proof-types.md) — the 9 closed proof types and the `VERIFY BY <type>:<adapter>:<artifact>` binding the `verify_by[]` array normalizes.
- [docs/reference/flow-graph.md](./flow-graph.md) — the canonical counts (7 kinds, 5 modals, 9 proof types, 7 edge types, 9 passes) the closed enumerations in these schemas MUST match.
- [docs/model/conformance.md](../model/conformance.md) — which artifacts a conformant repository MUST carry, including these schemas verbatim.
