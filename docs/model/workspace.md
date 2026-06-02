# Workspace Model

> Authoritative source: `.agents/specs/swarm/06-artifacts.md` §20.5 (the adopted-project workspace, the eight `.swarm/` directory contracts, the `.agents/` compatibility model, the governing rule, and the commit policy) and `.agents/specs/swarm/04-verification.md` §16.6 (the five source-code surface policies). This is a reference projection; where it and the spec disagree, the spec governs.

This page fixes the **adopted-project workspace** — the directory shape that appears inside a *consuming* project after it adopts Swarm. It is distinct from the framework-dev repository layout (the `docs/`, `examples/`, `evals/`, and `kernel/` siblings that explain, demonstrate, self-test, and package the kernel, §20.0). The framework repo is the **producer**; an adopted project is the **product**. The two MUST NOT be conflated.

As with everything in the kernel this is **NO RUNTIME** (Invariant 1, §2.1.1): the kernel is inert reference data and copyable templates, and every workspace path below is a directory a human or an agent populates — or that a future Swarm toolchain would populate **as a contract it builds against**, never a runtime Swarm ships. Every "runs" / "populates automatically" verb on this page resolves to that future-launcher contract.

## The one rule

The placement of every adopted-project artifact is decided by a single rule (§20.5.4):

```text
If it defines, tracks, or reconciles project intent   → .swarm/
If it exists only so an agent CLI can load instructions → .agents/
If it starts an agent correctly                        → AGENTS.md
```

This is **design rationale** — a layout and naming decision, not an empirical claim — and needs no citation. The only grounded claim in the workspace model is the NO-RUNTIME framing above (Invariant 1).

## `.swarm/` is the canonical workspace

`.swarm/` is **the** canonical Swarm workspace: everything that defines, tracks, or reconciles intent lives under it. It partitions into eight top-level categories — `sources/ status/ generated/ memory/ ledger/ archive/ kernel/ tmp/` — each a distinct contract:

| Directory | Holds | Category | Committed? | Populated by |
| --- | --- | --- | --- | --- |
| `kernel/` | The installed framework payload — `language/ templates/ passes/ skills/ profiles/ overlays/`. Framework-owned; project edits belong in `overlays/`. | payload | Yes | Installation from the framework repo's `kernel/`; kernel migrations |
| `sources/` | **Desired truth** + durable source artifacts: specs (`*.swarm.md`), PRDs, RFCs, research, audits, bugs, findings, ADRs, interfaces, NFRs (§20.3.4). | desired | Yes | Humans + the `author`/`improve` passes |
| `status/` | **Observed** satisfaction + drift: per-spec satisfaction reports, task/worktree state, drift reports. Records whether code satisfies the spec; never redefines intent. | observed | Yes | The `verify`/`review` passes; drift detection (future toolchain) |
| `generated/` | **Generated** execution packets: task frames, traces, reviews, generated tests/docs. Recreatable from `sources/`; compacted into `ledger/` on completion. | generated | Mostly gitignored (see commit policy) | The `lower`/`decompose`/`implement`/`verify`/`review` passes |
| `memory/` | **Durable recall** (§23): `INDEX.md` (the load-*when* map, never a dump), `glossary.md`, `patterns/`, `stale/`. | durable | Yes | The `promote` pass |
| `ledger/` | **Compact reconciled history** (§23): `changes/ merges/ promotions/`. | durable | Yes | Reconciliation after merge/abandonment (future toolchain) |
| `archive/` | Retired durable source artifacts, each linked to a replacement or closure summary — not silently deleted. | durable | Yes | The `promote` pass / manual retirement |
| `tmp/` | Scratch only. No durable knowledge. | scratch | No | Ad-hoc agent/human scratch |

The canonical tree (path *shape* is normative, §20.5.1):

```text
project/
  AGENTS.md                 # the bootloader (§31): how an agent STARTS; short, ≤200 lines / ≤25 KB

  .swarm/                   # THE CANONICAL SWARM WORKSPACE
    VERSION                 # adopted kernel version, semver (§25)
    config.yaml             # surface policies (§16.6), agent adapters, lint-severity overrides
    kernel/                 # the INSTALLED payload (language templates passes skills profiles overlays)
    sources/                # DESIRED truth      → specs/ prds/ rfcs/ research/ audits/ bugs/ findings/ adrs/ interfaces/ nfrs/
    status/                 # OBSERVED state     → specs/ tasks/ worktrees/ drift/
    generated/              # EXECUTION packets  → tasks/ traces/ reviews/ tests/ docs/
    memory/                 # DURABLE recall     → INDEX.md glossary.md patterns/ stale/
    ledger/                 # COMPACT history    → changes/ merges/ promotions/
    archive/                # retired source artifacts (linked to replacements)
    tmp/                    # scratch (gitignored)

  .agents/                  # COMPATIBILITY MIRROR ONLY (not canonical)
    skills/                 # mirrored/pointer → .swarm/kernel/skills/
    profiles/               # mirrored/pointer → .swarm/kernel/profiles/
```

## The source / status / generated split

The three execution-time categories are kept deliberately separate, because they answer three different questions and one must never silently overwrite another:

- **`sources/` — desired truth.** What the project *intends*: the obligation source. A spec here is primary for **intent**.
- **`status/` — observed satisfaction + drift.** Whether the code actually satisfies that intent, and where it has drifted. It **records** reality against intent; it **never redefines** intent.
- **`generated/` — execution packets.** The task frames, traces, and reviews produced while turning a source into verified change. Recreatable from `sources/`, and compacted into `ledger/` on completion so the workspace does not accumulate a permanent scratchpad.

This split is the workspace-wide form of the per-path surface policy below: each names which side of the intent-versus-reality reconciliation an artifact (or a code region) sits on.

## The ledger

`.swarm/ledger/` is the **compact reconciled history**: a durable, low-volume summary that survives after `generated/` execution packets are compacted away. Each ledger entry preserves what a future audit needs — **obligation coverage, changed surfaces, the proof run, the verdicts, and the promotion results** — so a completed unit of work leaves a permanent reconciled record rather than an ever-growing pile of task scratchpads. It is committed (`changes/ merges/ promotions/`); `generated/tasks/` and `tmp/` are not. The ledger is what lets `generated/` be safely gitignored: the durable facts have already been lifted out of it.

## Source-code surface policies

The workspace separation has a per-path projection over the codebase itself. A code region declares **exactly one** policy from a closed set of five (§16.6.2). This follows from **Invariant 4 — code is reality**: specs are primary for intent, code is primary for implementation reality, and the trace/review/status layer reconciles the two. A surface policy records which side of that reconciliation a region sits on.

| Policy | Meaning | Manual edits |
| --- | --- | --- |
| `generated` | Regenerated from a **named source artifact** (an OpenAPI doc, a schema, an interface spec) — the artifact is the truth, the file is its emission. | **Forbidden** — edit the source and regenerate; a hand-edit is overwritten and is a finding. |
| `governed` | Reconciled implementation reality under an obligation: a spec owns intent, the code owns realization, trace/review reconcile them. | **Allowed only with an obligation trace** (`allowed_with_trace`) — every change carries an obligation id and emits a trace. |
| `observed` | Existing code not yet governed — pre-existing reality with no obligation behind it. | Allowed, but the surface needs an audit + a spec before it can become `governed`. |
| `external` | Vendor / third-party code (dependencies, generated SDKs you do not own, copied upstream). | **Do not modify** — changes belong upstream or in an owned wrapper. |
| `deprecated` | Scheduled for removal or migration; retained until cutover. | Discouraged; permitted edits SHOULD be migration/removal steps, not new behavior. |

`observed` is the **honest default** for brownfield adoption: real code that no obligation yet claims. It is the on-ramp — an audit (`.swarm/sources/audits/`) plus a spec promote `observed` → `governed`; it is never silently treated as if a spec already governed it.

The doctrine this set **rejects** is equally important (§16.6.1): code is *not* disposable, source is *not* "regenerated from specs," manual edits are *not* forbidden, and the model MAY *not* rewrite the codebase from prose intent. Code is reconciled implementation reality, not a minified build product of the spec. Only a surface explicitly marked `generated` is regenerated, and even then only from a named source artifact.

Surfaces are declared as a `surfaces:` map in `.swarm/config.yaml`, each path → `{policy, source, manual_edits}` (plus policy-specific fields such as `requires_audit`). Computing and enforcing the map is a future-tool concern; the **map shape is the kernel contract today**.

## `.agents/` is a compatibility surface, not the source of truth

`.agents/` exists **only** so a third-party agent CLI that looks for `.agents/skills/` or `.agents/profiles/` can find loadable instructions. It is never the canonical home of project intent. Every file in `.agents/` MUST either point back to its canonical `.swarm/kernel/` (or `.swarm/generated/`) original, or be a verbatim compatibility copy of kernel material. The mirror is **one-directional** — `.agents/` derives from `.swarm/`, never the reverse — so there is exactly one source of truth and the compatibility surface can be regenerated or deleted without losing intent.

A canonical artifact that exists *only* under `.agents/` is a layout defect, not a valid adoption. In particular, the following are canonical in `.swarm/` and MUST NOT live in `.agents/` as their primary home: primary specs (`.swarm/sources/specs/`), source-authority docs (PRDs, RFCs, research, ADRs, audits, findings, NFRs, interfaces), durable memory, the ledger, and status reports. (`.agents/specs/`, `.agents/tasks/`, and `.agents/memory/` as *canonical* roots are exactly the anti-pattern this rule forbids; any such path is permissible only as an explicitly-marked compatibility pointer or migration step.)

## The CLI / agent boundary

Swarm coordinates agent-CLI workers and **prepares and validates** work; it does **not** own the model loop, the file-editing mechanics, or the provider/MCP runtime, and it MUST NOT replace an agent CLI. The future launcher is a contract a toolchain builds against — it would scaffold task frames, bind `VERIFY BY` adapters through `AGENTS.md > Commands`, serialize write surfaces, and reconcile the ledger — all consistent with the orchestrator-worker, single-threaded-writes boundary. No canonical page implies Swarm is an agent runtime: there is no "Swarm is an agent CLI" and no "agent runtime" here. Every "runs" verb resolves to that future-launcher contract (Invariant 1).

## Commit policy (informative)

An adopted project SHOULD gitignore execution-local and scratch state while committing everything that defines, tracks, or reconciles intent:

```gitignore
# Swarm execution-local + scratch state (recreatable from sources)
.swarm/generated/tasks/
.swarm/tmp/
# Optional: active traces/reviews are compacted into .swarm/ledger/ on completion.
.swarm/generated/traces/
.swarm/generated/reviews/
```

A project MUST NOT gitignore `.swarm/sources/`, `.swarm/status/`, `.swarm/memory/`, `.swarm/ledger/`, `.swarm/kernel/`, or `.swarm/archive/` unless it intentionally splits durable knowledge into a separate repository. `generated/` and `tmp/` are reconstructible from `sources/`; the rest are the durable record the reconciliation model depends on.

## Preserved / Dropped / Still-uncertain

- **Preserved.** The one governing rule; the statement that `.swarm/` is the canonical workspace and its eight-directory partition with the committed?/populated-by contracts; the source/status/generated split; the ledger contract; the five surface policies (closed set) with the rejected "code is disposable" doctrine and the `surfaces:` map shape; the `.agents/` one-directional compatibility model and what it may not hold; the CLI/agent boundary and the no-runtime framing; and the commit policy — because AW1–AW9 require a canonical page to state each of these.
- **Dropped (left to the spec).** The framework-repo→adopted-project install mapping in full (§20.5.1 path-by-path), the `governed`+`allowed_with_trace` drift mechanics and their tie to `per_surface_hash[]`/§16.5 participation (§16.6.4), the "passing test does not discharge the obligation" argument (§16.6.5), and the §16.6.6 cross-reference table. These remain the spec's long-form responsibility.
- **Still-uncertain (governed by the spec).** Who runs the future launcher and what it automates is unspecified by the kernel and bound by the adopting repo; the surface-policy enforcement and ledger reconciliation are manual-today and aspirational until tooling exists. This projection records that boundary rather than resolving it.
