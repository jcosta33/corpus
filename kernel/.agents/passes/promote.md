# The `promote` pass

> Authoritative source: 07-governance-memory.md §23 (the memory model, the promotion protocol §23.4, the seven-value promotion-status enum, the discovery-to-target routing table §23.4.2, validation & rollback §23.4.3). This is a reference projection; where it and the spec disagree, the spec governs.

`promote` is the last of the **nine passes** of the Swarm compiler pipeline (`author -> lint -> improve -> lower -> decompose -> implement -> verify -> review -> promote`). This page is the short reference view for that single pass; the long-form contract is §23 of the spec.

Like every Swarm pass, `promote` has **no runtime**: it is a contract a human, an agent following a pass guide, or a future tool performs. The kernel ships the *files and the discipline* a retrieval/promotion tool would build against — not a retrieval engine, validation scorer, or eviction manager (§23, §23.6). Nothing here is shipped code.

## What the pass does

A discovery made during a task does **not** become memory by being written down; it becomes memory by being **promoted** (§23.4). The `promote` pass is the durable feedback loop: it takes each discovery a task surfaced, routes it to a durable target, indexes it, and records its disposition — so a future task can recall it without bloating the always-loaded bootloader (§31).

The model is **two-tier and provenance-anchored** (§23). Rationale: chat transcripts and inline prose are not memory — they are unindexed, unprovenanced, and unfalsifiable. Memory MUST be a *promotion system* (a fact earns durability through a recorded promotion) backed by an *immutable evidence store*, with a compact index over it.

| Aspect | Value (from §23) |
|---|---|
| Phase | **PROMOTE** — the seventh and final phase |
| Input | the task's discoveries + the resolved-or-pending promotion queue |
| Output | durable writes to `.swarm/memory/` and `.swarm/sources/` (plus the `AGENTS.md` pointer case, §23.4.1) and a fully-resolved promotion queue |
| Close gate | a task MUST NOT close while any promotion item is `pending` (§23.4) |
| Ships a stdlib pass guide in v0.1? | **Yes** — `promote` is one of the five tooled-first passes (with `lint`, `decompose`, `implement`, `review[profile: skeptic]`) |

## The two-tier memory model

`promote` writes into a model with a deliberate split between a cheap map and an immutable store.

### Tier-1 — the compact map (what an agent reads first)

| Artifact | Role | Discipline |
|---|---|---|
| `memory/INDEX.md` | A **map of links, not explanations**; links into Tier-2, never duplicates bodies | Every entry MUST carry a **`Load when`** condition (the trigger telling a future agent the entry is relevant). The **load-when discipline**: an entry that cannot name *when it matters* MUST be removed — it is dead weight against the §24 loss budget and §31 density cap. |
| `memory/glossary.md` | One word, one meaning (`[STE]` controlled vocabulary) | Each entry binds exactly one term to one definition; a contested term is **split**, never overloaded. An in-file `TERM` in a spec takes precedence over the glossary for that spec. |

### Tier-2 — the immutable evidence store (the territory)

| Artifact | Role in memory | Mutability |
|---|---|---|
| `finding.md` | One durable project fact + its evidence | Immutable once `accepted`/`promoted`; status may advance, body does not silently change |
| `adr.md` | Architectural/product decision + rationale | Nygard-immutable (§30); amend only by superseding ADR |
| `audit.md` | Present-state risk/debt observation | Immutable record of an observation at a point in time |
| `bug-report.md` | Reproducible-defect diagnosis | Immutable record of a reproduction |
| `memory/patterns/*.md` | Recurring knowledge spanning **multiple** findings | Append-on-supersession |

A single finding MUST NOT be promoted directly to a pattern: promote it to a `finding.md` first, and to a `memory/patterns/*.md` pattern only once a **second corroborating finding** exists. A pattern MUST cite the findings it generalizes.

## Provenance — mandatory on every promoted finding (§23.3)

Every finding that reaches `accepted` or `promoted` MUST carry the full provenance record; provenance is what makes a finding *falsifiable* and *staleness-checkable*. A finding without it is chat, not memory.

| Field | Meaning |
|---|---|
| `claim` | The one durable fact, as a single proposition |
| `evidence` | The file/command/output/source grounding the claim |
| `origin_obligations[]` | The obligation IDs (`AC-/C-/I-…`) the finding was discovered against |
| `origin_traces[]` | The `*.swarm.trace.md` entries that produced the evidence |
| `pass+profile` | The pass + heuristic profile it was found under (e.g. `review[profile: skeptic]`) |
| `reviewer_or_tool` | The human reviewer or tool/adapter that confirmed it |
| `timestamp` | When it was promoted |
| `content_hash` | Hash of the cited source/surfaces at promotion time (drives staleness, §23.5) |
| `confidence` | `high` \| `medium` \| `low` |
| `applies-when` / `does-not-apply-when` | The scope envelope; mirrors the INDEX `Load when` |

## The promotion-status enum — exactly seven values (§23.4)

Every promotion item raised during a task MUST resolve to one of these **seven** statuses before the task closes:

| Promotion status | Meaning | Terminal for this task? |
|---|---|---|
| `pending` | Raised, not yet dispositioned | No — the close gate forbids it |
| `promoted` | Written to its durable target and indexed | Yes |
| `deferred` | Recorded for a future task **with reason** | Yes |
| `rejected` | Judged non-durable **with reason** | Yes |
| `blocked` | Cannot promote yet (e.g. needs an ADR) **with reason** | Yes |
| `validated` | High-consequence intermediate (`pending -> validated -> promoted`); requires independent corroboration (§23.4.3) | No — non-terminal, does not satisfy the close gate alone |
| `rolled-back` | A promoted finding later withdrawn (poisoned / `CONTRADICTED` / `STALE`), recorded as a retraction (§23.4.3) | Post-promotion disposition |

**Close gate (normative).** A task MUST NOT close while any promotion item is `pending`. A `promoted` finding MUST appear in `memory/INDEX.md` with a `Load when` (§23.1.1) and carry full provenance (§23.3).

**Authority floor (normative).** A promotion that would *weaken* an existing obligation is forbidden at any target — it is a `SOL-M004` authority-conflict routed to amendment, because `memory` is the floor domain on Axis B (§22.4). Re-stating a finding as a spec obligation via this pass is a **domain-promotion**: the obligation acquires its *new container's* authority — that is intent acquiring rank, not the `memory` floor being breached.

## Discovery-to-promotion-target routing (§23.4.2)

The kinds are mutually exclusive by intent; a discovery with two faces (e.g. both a durable decision *and* a reusable pattern) is promoted to each applicable target and each lands as its own queue item.

| Discovery | Promote to |
|---|---|
| New intended behaviour (a real obligation to build against) | `spec.swarm.md` (new/amended `REQ`/`CONSTRAINT`/`INVARIANT`/`INTERFACE`), or an ADR when gated on an undecided architectural/product choice |
| Durable architectural/product decision (choice + alternatives + trade-offs) | An ADR (`.swarm/sources/adrs/<nnnn>-<slug>.md`) |
| Present-state risk or debt (what *is*, observed, not yet a chosen change) | An audit (`.swarm/sources/audits/<slug>.md`) — observation-only, never prescriptive |
| Reproduced defect evidence (root cause + expected vs actual) | A bug-report (`.swarm/sources/bugs/<slug>.md`) — diagnosis-only; the fix promotes onward to a `task_kind: fix` task |
| Reusable project fact (durable evidenced claim) | A finding (`.swarm/sources/findings/<slug>.md`), indexed in `memory/INDEX.md` with `Load when` + full provenance |
| Repeated cross-task pattern (recurring solution shape across >1 task) | `memory/patterns/*.md` |
| Terminology clarification (ambiguous/drifted term) | `memory/glossary.md` (resolves `SOL-P006` undefined-term / `SOL-P057` terminology-drift at the source) |
| Universal workflow rule (a procedure for every future task) | A **pass-guide edit (the procedure) PLUS at most a one-line `AGENTS.md` pointer** — never inline procedure in `AGENTS.md` (the G9 tie-break, §23.4.1) |
| Purely local execution detail (relevant only to this run) | Keep in the task only (`task.md`); dispositioned **`rejected`** with reason "execution-local" |

Two consequences hold across every row. First, weakening an obligation is forbidden at any target (the `SOL-M004` floor above). Second, **"keep in the task only" is a real disposition, not an omission**: the item is still recorded in the queue and resolved (`rejected`, with reason), so the mandatory-before-close rule admits no silent drops.

### G9 — "universal workflow rule" promotions never inline procedure

A universal-workflow-rule promotion collides with the ≤200-line bootloader cap and ADR 0017 (only persistent **facts** belong in `AGENTS.md`; **procedures** belong in pass guides). The kernel resolves it normatively:

| Where it goes | What goes there |
|---|---|
| Pass guide (`docs/skills/…`) | The actual procedure / steps |
| `AGENTS.md` | One line: the pointer + its load-when, nothing procedural |

> Example — promoting "always run the migration dry-run before applying": the dry-run procedure is added to the `implement` pass guide; `AGENTS.md` gains only `- Before applying a migration, load the implement pass guide (migration section).`

## Validation and rollback (memory governance, §23.4.3)

Authorization is not validation. A memory write MUST pass consistency verification before consolidation, not merely owner approval `[SSGM]`; the named failure points are poisoning at ingestion, semantic drift at consolidation, and conflict/hallucination at retrieval. The v0.1 forward-only `pending -> promoted` model addresses none of these, so two additions close the gap:

- **`validated`.** A high-consequence promotion MUST pass `pending -> validated -> promoted`, where `validated` requires **independent corroboration** — a second finding, a re-run proof, or a reviewer who is not the promoting agent (generalizing the two-finding rule for patterns). A `pending` finding from an externally-authored source (the untrusted-source boundary; the `[NVIDIA-AGENTSMD]` / `[RULESBACKDOOR]` poisoning vector) MUST NOT skip `validated`.
- **`rolled-back`.** A promoted finding later shown poisoned, `CONTRADICTED` (§14), or `STALE` (§16) MUST be withdrawable, recording a **retraction entry in `memory/INDEX.md`** — not a silent delete, so the chain stays auditable (Nygard immutability, §30) — and re-opening any obligation it had narrowed. Supersession replaces a fact with a better one; rollback withdraws a fact that should never have been promoted.

## Staleness (§23.5)

A finding's `status` enum is `candidate | accepted | promoted | rejected | stale | superseded`. A finding becomes **`stale`** when its `content_hash` no longer matches the cited source/surfaces — the same drift signal behind the `STALE` verdict decorator (§14) and the spec↔code reconcile (§16). A `stale` finding MUST NOT be relied on as authority; it routes to re-verification or supersession. A `superseded` finding records its replacement in the INDEX stale/superseded table. The kernel ships the **fields** that make staleness computable (`content_hash`, `origin_traces`); it does **not** ship the comparator — recomputing the hash and flipping `accepted -> stale` is a harness/CLI concern, aspirational/manual today (Principle 1).

## Deferred to post-v0.1 (§23.6)

Each of these needs a runtime Swarm does not ship: embedding / dense-vector retrieval; LRU (or any automatic) eviction; automatic staleness hashing (fields shipped, comparator deferred); cross-session agent identity; memory dashboards / analytics. v0.1 ships the two-tier file model, the provenance fields, the promotion statuses, and the `Load when` discipline — automation builds against them later.

## Preserved / Dropped / Still-uncertain

**Preserved** (projected faithfully from §23):

- The two-tier provenance-anchored model: Tier-1 (`memory/INDEX.md` with the load-when discipline; `memory/glossary.md` one-word-one-meaning) and Tier-2 (the immutable evidence store + `patterns/*.md`, with the single-finding-not-to-pattern rule).
- The full mandatory provenance field set (§23.3).
- The **seven-value** promotion-status enum (`pending | promoted | deferred | rejected | blocked | validated | rolled-back`), the task-close gate, and the `SOL-M004` no-weakening floor.
- The complete discovery-to-target routing table (§23.4.2), the G9 tie-break (§23.4.1), the validation/rollback additions (§23.4.3), the `candidate|accepted|promoted|rejected|stale|superseded` staleness enum tied to §16, and the post-v0.1 deferral table.

**Dropped** (out of scope for this single-pass projection; lives in the spec):

- Source authority — the two axes, the lexicographic conflict rule, and human-approval-required changes — §22; cited here only where promotion touches the `memory` floor and `SOL-M004`.
- The ledger (`.swarm/ledger/`) and the ephemeral-vs-durable workspace boundary — §23.7.
- The distillation loss budget and versioning — §24, §25.
- The full nine-pass / seven-phase model and the other eight passes — see `author.md`, `lint.md`, and §9.

**Still-uncertain** (the spec governs; not pinned here):

- The exact `validated`-corroboration procedure (what counts as a "second finding" vs a "re-run proof" vs an "independent reviewer") — §23.4.3 fixes the requirement, not a step-by-step recipe; the `promote` stdlib pass guide would supply that.
- The mechanics of the staleness comparator (recompute, compare, flip) — explicitly deferred to a harness/CLI (§23.5, §23.6); the kernel ships only the fields.
