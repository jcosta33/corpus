# Promotion Protocol

A discovery made during a task does **not** become memory by being written down. It becomes memory by being **promoted** — an explicit, recorded act that moves a fact from a task's ephemeral scratch into a durable, indexed, provenanced artifact. This page is the promotion protocol Swarm references by name: the seven-value status enum, the mandatory-before-close gate, the discovery-to-target routing table, the validation/rollback discipline, and the **ledger** that records the disposition of every promotion as compact, immutable history.

Promotion exists because chat transcripts and inline prose are *not* memory — they are unindexed, unprovenanced, and unfalsifiable. Memory is a promotion system (a fact earns durability through a recorded promotion) backed by an immutable evidence store, with a compact index over it [[CTXENG]](../research/sources.md#CTXENG). The protocol is markdown-only and NO-RUNTIME: it describes the *files and the discipline* a future retrieval/checker tool would build against, not a shipped engine — nothing here ships a retrieval engine, a compactor, or a git driver.

## The promotion-status enum (seven values)

Every promotion item raised during a task MUST resolve to one of these statuses before the task closes:

| Promotion status | Meaning |
| ---------------- | ------- |
| `pending` | Raised, not yet dispositioned. |
| `promoted` | Written to its durable target and indexed. |
| `deferred` | Recorded for a future task, with reason. |
| `rejected` | Judged non-durable, with reason. |
| `blocked` | Cannot promote yet (e.g. needs an ADR), with reason. |
| `validated` | High-consequence intermediate (`pending → validated → promoted`); requires independent corroboration. |
| `rolled-back` | A promoted finding later withdrawn (poisoned / `CONTRADICTED` / `STALE`), recorded as a retraction. |

The promotion-status enum is therefore exactly these **seven** values. Note this is the *promotion* enum and is distinct from a `finding.md`'s own `status` enum (`candidate | accepted | promoted | rejected | stale | superseded`) — a finding's status tracks the life of one durable artifact; a promotion's status tracks the disposition of one queue item.

### How the seven statuses behave at the close gate

The seven statuses do not all play the same role:

- **`pending`** is the unresolved state. **A task MUST NOT close while any promotion item is `pending`**. This is the core gate.
- **`validated`** is a **non-terminal intermediate** in the chain `pending → validated → promoted`; it does *not* satisfy the close gate on its own — an item parked at `validated` is still unresolved for the purpose of closing.
- **`rolled-back`** is a **post-promotion disposition**: it records the withdrawal of an already-`promoted` finding, so it is reached *after* promotion, not as a way to resolve a fresh queue item.
- The remaining four non-`pending` statuses — **`promoted` / `deferred` / `rejected` / `blocked`** — are **terminal for this task**. Of these, `deferred`, `rejected`, and `blocked` each MUST carry a reason.

## The mandatory-before-close gate

Promotion is **mandatory before task closure**. Every discovery a task surfaces enters the **promotion queue** and MUST resolve to one of the canonical seven statuses; a task MUST NOT close while any item is `pending`. Two consequences follow:

- A `promoted` finding MUST appear in `memory/INDEX.md` with a `Load when` condition and carry full provenance. The `Load when` is the trigger telling a future agent the entry is relevant to its current task; an entry that cannot name *when it matters* is dead weight and MUST be removed (the **load-when discipline**).
- **"Keep in the task only" is a real disposition, not an omission.** A purely local execution detail is still recorded in the queue and resolved — dispositioned `rejected` with reason "execution-local". The mandatory-before-close rule admits **no silent drops**: every discovery is either promoted somewhere durable or explicitly resolved as non-durable, on the record.

## Discovery-to-promotion-target routing

Given the *kind* of discovery, the protocol fixes the single durable target the `promote` step writes to. The kinds are mutually exclusive by intent; when a discovery has two faces (e.g. it is both a durable decision and a reusable pattern), it is promoted to each applicable target and each lands as its **own queue item**.

| Discovery | Promote to |
| --------- | ---------- |
| New intended behaviour (a real obligation/constraint to build against) | `spec.swarm.md` (a new or amended `REQ`/`CONSTRAINT`/`INVARIANT`/`INTERFACE`), or an ADR when the behaviour is gated on an undecided architectural/product choice. |
| Durable architectural or product decision (a choice with consequences, alternatives, trade-offs) | An ADR — a `type: adr` doc in `decisions/`, project-wide and sequentially numbered. |
| Present-state risk or debt (what *is*, observed but not yet a chosen change) | An audit — a `type: audit` doc in `specs/<feature>/` beside the spec it concerns, observation-only, never prescriptive. |
| Reproduced defect evidence (root cause + expected vs actual, reproducible) | A bug-report — a `type: bug-report` doc in `specs/<feature>/`, diagnosis-only; the fix promotes onward to a `task_kind: fix` task. |
| Reusable project fact (a durable claim learned during work, with evidence) | A finding — a `type: finding` doc in `.agents/memory/`, indexed in `memory/INDEX.md` with a `Load when` and full provenance. |
| Repeated cross-task pattern (a recurring solution shape seen across more than one task) | `memory/patterns/*.md`. |
| Terminology clarification (a term whose meaning was ambiguous or drifted) | `memory/glossary.md` (the canonical lexicon; resolves `SOL-P`-layer terminology drift — `SOL-P006` undefined-term, `SOL-P057` terminology-drift — at the source). |
| Universal workflow rule (a procedure that should apply to every future task) | A step-guide edit (the procedure) **plus at most a one-line `AGENTS.md` pointer** — NEVER inline procedure in `AGENTS.md`; the bootloader holds persistent facts, not steps. |
| Purely local execution detail (relevant only to this task's run) | Keep in the task only (`task.md`); it is **not** durable and is dispositioned `rejected` for promotion with reason "execution-local". |

Two normative consequences hold across **every** row:

1. **A promotion that would *weaken* an existing obligation is forbidden at any target.** It is a `SOL-M004` authority-conflict routed to amendment, because `memory` is the floor domain on Axis B of source authority. A fact can never quietly relax an obligation it was discovered against.
2. **No silent drops.** As above, "keep in the task only" is an explicit `rejected`-with-reason disposition recorded in the queue, not a quiet omission.

### The "universal workflow rule" tie-break

Routing a *universal workflow rule* toward `AGENTS.md` collides with the ≤200-line bootloader cap [[LOSTMID]](../research/sources.md#LOSTMID) and the rule that only persistent **facts** belong in `AGENTS.md` while **procedures** belong in step guides [[AGENTSMD-HARM]](../research/sources.md#AGENTSMD-HARM). Swarm resolves this normatively:

> A "universal workflow rule" promotion MUST become **a step-guide edit (the procedure) PLUS at most a one-line `AGENTS.md` pointer (the fact that the guide exists and when to load it).** It MUST NOT inline the procedure into `AGENTS.md`.

| Where it goes | What goes there |
| ------------- | --------------- |
| Step guide (`docs/library/pass-guides.md`) | The actual procedure / steps. |
| `AGENTS.md` | One line: the pointer + its load-when, nothing procedural. |

Example: promoting "always run the migration dry-run before applying" adds the dry-run procedure to the `implement` step guide; `AGENTS.md` gains only `- Before applying a migration, load the implement step guide (migration section).` This keeps the bootloader a map and the procedure lazily loaded.

## Provenance — mandatory on every promoted finding

Every finding that reaches `accepted` or `promoted` status MUST carry the full provenance record. Provenance is what makes a finding *falsifiable* and *staleness-checkable*; a finding without it is chat, not memory.

| Field | Meaning |
| ----- | ------- |
| `claim` | The one durable fact, stated as a single proposition. |
| `evidence` | The file/command/output/source that grounds the claim. |
| `origin_obligations[]` | The obligation IDs (`AC-`/`C-`/`I-…`) the finding was discovered against. |
| `origin_traces[]` | The `*.swarm.trace.md` entries that produced the evidence. |
| `pass+profile` | The step and heuristic profile under which it was found (e.g. `review[profile: skeptic]`). |
| `reviewer_or_tool` | The human reviewer or tool/adapter that confirmed it. |
| `timestamp` | When it was promoted. |
| `content_hash` | Hash of the cited source/surfaces at promotion time (drives staleness). |
| `confidence` | `high` \| `medium` \| `low`. |
| `applies-when` / `does-not-apply-when` | The scope envelope; mirrors the `Load when` of the INDEX entry. |

A single finding MUST NOT be promoted directly to a pattern. Promote it to a `finding.md` first, and to a `memory/patterns/*.md` pattern only once a **second corroborating finding** exists, since a pattern is the distillation of *several* findings and MUST cite the findings it generalizes.

## Validation and rollback (memory governance)

**Authorization is not validation.** A forward-only base model (`pending → promoted` on approval) is insufficient: a memory write MUST pass *consistency verification* — not merely owner approval — before consolidation, because a durable store has three distinct failure points: poisoning at ingestion, semantic drift at consolidation, and conflict/hallucination at retrieval. Two additions close the gap:

- **The `validated` status.** A high-consequence promotion MUST pass `pending → validated → promoted`, where `validated` requires **independent corroboration** — a second finding, a re-run proof, or a reviewer who is *not* the promoting agent — generalizing the two-finding rule for patterns. A `pending` finding produced by an externally-authored source (the untrusted-source boundary; the rule/config-file poisoning vector) MUST NOT skip `validated`.
- **Rollback.** A `promoted` finding later shown poisoned, `CONTRADICTED`, or `STALE` MUST be withdrawable via the `rolled-back` disposition. Rollback records a **retraction entry in `memory/INDEX.md`** — *not* a silent delete; the chain stays auditable under the same append-only immutability the ledger inherits — and **re-opens any obligation it had narrowed**.

> **Supersession vs. rollback.** Supersession *replaces* a fact with a better one; rollback *withdraws* a fact that should never have been promoted. They are different acts with different audit meanings.

The two-tier index/store split is a deliberate **design choice**, not a measured property: a compact index over an immutable evidence store mirrors OS-style two-tier context management and extract–consolidate–retrieve memory pipelines. Automated validation scoring, decay, and embedding retrieval remain deferred.

## Staleness of a promoted finding

A `promoted` finding does not stay authoritative forever. A finding becomes **`stale`** when its `content_hash` no longer matches the cited source/surfaces — the same drift signal that produces the `STALE` verdict lifecycle decorator and the spec↔code drift reconcile. A `stale` finding MUST NOT be relied on as authority; it is routed to re-verification or supersession, and a `superseded` finding records its replacement in `memory/INDEX.md`'s stale/superseded table.

Swarm ships the **fields** that make staleness computable (`content_hash`, `origin_traces`); it does **not** ship the comparator. Recomputing the hash and flipping `accepted → stale` is a harness/CLI concern, aspirational and manual today (NO-RUNTIME).

## The ledger — compact reconciled history

Memory preserves *durable facts*; the **ledger** preserves *compact reconciled history* — the audit trail of completed work after its execution material has been thrown away. The two are complementary, not redundant: a `finding.md` records *what we learned* and is loaded *when its `Load when` fires*; a ledger entry records *what a task did, covered, and proved* and is read *when an auditor reconstructs why the codebase is the way it is*. The ledger is the bright line that lets Swarm discard task scratch without losing auditability: a task surfaces a `task.md` frame, one or more `*.swarm.trace.md` implementation claims, and a `review.md` verdict record (all execution packets — gitignored scratch, or recreatable from sources); once the work is merged or abandoned and its discoveries are promoted, those packets have served their purpose, and their load-bearing content is **compacted into** a ledger entry on reconciliation. Keeping the verbose packets indefinitely would re-create exactly the unindexed accumulation that promotion rejects for chat transcripts.

This is design rationale, not an empirical claim — it specifies the files and the append-only discipline a future reconciliation tool builds against (NO-RUNTIME); nothing here ships a reconciliation engine, a compactor, or a git driver.

### Location and shape

The ledger is compacted history a future reconciliation tool keeps — not a mounted tree a project materializes up front; it is created lazily on first write (per the reconciliation design in [docs/model/workspace.md](../model/workspace.md)). It carries three categories of entry:

```text
ledger/
  changes/          # one entry per completed change set (covered obligations, surfaces, proofs, verdicts)
  merges/           # one entry per merge-gate decision at the change-set level
  promotions/       # one entry per resolved promotion queue
```

A **ledger entry is an immutable, append-only record** under the same discipline as an ADR (Nygard immutability): an entry is never edited in place; a correction is a *new* entry that references the one it amends, so the truth of any change is the full chain, not the latest row. The ledger is therefore the change-history analogue of the ADR chain — ADRs record *decisions* immutably; the ledger records *reconciled task outcomes* immutably. This append-only-with-supersession shape is a design choice, not a measured property.

### What is ephemeral vs. what is durable

The ledger fixes the durability boundary across the three knowledge layers:

| Layer | What it is | Durability | Git disposition |
| ----- | ---------- | ---------- | --------------- |
| Execution packets | task frames, traces, reviews (`{tasks,traces,reviews}`) | **Ephemeral** — recreatable from sources; compacted into the ledger on reconciliation | Gitignored (task frames always, and optionally traces/reviews once governance accepts ledger compaction as the system of record) |
| Ledger | the compacted history (`{changes,merges,promotions}`) | **Durable** — the compact audit trail that outlives the packets | Committed |
| Memory + sources | the `.agents/memory/` recall, plus the `type:`-tagged source docs in `specs/<feature>/` and `decisions/` | **Durable** — recall + desired truth | Committed |

Because the ledger captures the load-bearing summary of a trace/review on reconciliation, a project MAY gitignore the verbose execution packets without losing auditability — the ledger is what survives. By contrast, the ledger, the memory, and the source docs are never gitignored as a matter of governance: deleting them deletes the project's reconciled history, durable recall, and desired truth respectively. Whether a given repo gitignores active traces/reviews is a per-project governance choice, not a Swarm mandate; the only mandate is that *if* they are dropped, their load-bearing content MUST first have compacted into a ledger entry.

### What a `changes/` ledger entry records

A `changes/` ledger entry is the compaction target of a task's trace + review. It MUST capture, for the completed task:

| Field | Content | Source it compacts |
| ----- | ------- | ------------------ |
| Covered obligation IDs | The `AC-`/`C-`/`I-`/`IF-` IDs the task discharged | The trace's `IMPLEMENTS`/`PRESERVES` claims and the review's verdict matrix |
| Changed write-surfaces + hashes | Each surface in the task's `WRITES` set with its `per_surface_hash` | The one trace-provenance schema: the `per_surface_hash[]` and `source_hash` recorded on each binding's last `PASS` — the ledger pins the same hashes, so the change record and the drift/staleness join never diverge |
| Proofs run + their verdicts | Each `VERIFY BY <type>:<adapter>:<artifact>` binding's recorded verdict, in the **4-core + 3-lifecycle** verdict model: core ∈ {`PASS`, `FAIL`, `BLOCKED`, `UNVERIFIED`}, lifecycle ∈ {`WAIVED`, `STALE`, `CONTRADICTED`} | The review's per-obligation `VERDICT` blocks and obligation-verdict matrix |
| Promotion results | The disposition of every promotion-queue item — `promoted` / `deferred` / `rejected` / `blocked` (and `validated` / `rolled-back` where validation/rollback applied) | The resolved promotion queue; a task cannot close while any item is `pending`, so the ledger entry records a **fully-resolved queue by construction** |

### What a `merges/` entry records — the merge-gate decision

A `merges/` entry records the **merge-gate decision** itself: the change-set-level `PASS`/`BLOCKED` verdict under the merge gate, together with the **unauthorized-change list** the review computed.

- **The gate's binding rule.** A change set is promotable **iff** every required obligation's latest verdict is `PASS` or `WAIVED` and none is `STALE`, `CONTRADICTED`, `FAIL`, `BLOCKED`, or `UNVERIFIED`. When the gate is `BLOCKED`, the ledger entry records *which* bindings were unmet — the obligations whose latest verdict was not `PASS`/`WAIVED` — so the block is falsifiable and re-attempts target exactly the gap.
- **The unauthorized-change list.** Every diff hunk not traceable to an authorizing obligation, judged `allowed` / `suspect` / `reject` (the review's `## Unauthorized changes` section).

The merge-gate decision and the unauthorized-change list are precisely what make the ledger an **audit trail**: they record *that the gate was evaluated, with what result, and what fell outside authorized scope* — the falsifiable record that the change set was admitted by the gate rather than waved through.

### What a `promotions/` entry records

A `promotions/` entry records the durable targets each promoted discovery landed at — the same routing the discovery-to-promotion-target table above fixes: a spec amendment, an ADR, a finding, a pattern, a glossary entry, or a step-guide-plus-pointer. It closes the loop between a task's discoveries and the durable memory + source docs.

### Why the ledger introduces no new evidence

Every field above is **compacted from artifacts Swarm already specifies** — the trace-provenance schema, the verdict model, the review's unauthorized-change and final-verdict sections, and the promotion queue. The ledger introduces no new evidence type and no new empirical claim. It is a projection of the existing reconciliation outputs into a compact, immutable, committed history, so that the execution packets may be discarded without severing the backward trace from today's code to the obligations, proofs, and verdicts that produced it.

## How the protocol joins the rest of Swarm

The block-type, modal, verdict, and lint-layer counts named below are Swarm's fixed vocabulary — **7 block types, 5 modals, 7 verdicts (4 core + 3 lifecycle), 5 lint layers S/P/M/V/O**; this page reproduces them by reference, it does not redefine them.

- **The verdict model.** The `promote` step runs after the change-set verdict is recorded. Rollback triggers (`CONTRADICTED`, `STALE`) are two of the **three lifecycle verdicts** in the 4-core + 3-lifecycle (= 7-verdict) model.
- **Source authority.** `memory` is the floor domain on Axis B, which is *why* a promotion can never weaken an obligation — that path is a `SOL-M004` authority-conflict routed to amendment.
- **The ledger.** Every promotion disposition lands in the ledger as compact, immutable history; because a task cannot close with any `pending` item, a ledger entry records a fully-resolved queue *by construction* (see [The ledger — compact reconciled history](#the-ledger--compact-reconciled-history) above).
- **The loss budget.** The `task.md → finding.md` boundary is a distillation boundary: the step-by-step execution log MAY be dropped, but the evidence for the durable claim MUST survive. Promotion is one of the two boundaries (with spec→task structuring) the loss budget most acutely governs.

## Open question — the staleness comparator

Swarm ships the **fields** that make staleness computable (`content_hash`, `origin_traces`) but not the **comparator** that recomputes the hash and flips `accepted → stale`; that is a harness/CLI concern, aspirational and manual today (NO-RUNTIME). Likewise, automated validation *scoring*, decay, and embedding retrieval are deferred: the `validated` status today is satisfied by human / second-finding / re-run corroboration, not a scored gate.

## Related

- [docs/model/workspace.md](../model/workspace.md) — the workspace model and reconciliation design; introduces the ledger (`changes/ merges/ promotions/`) as compacted history a future tool keeps, and the ephemeral-vs-durable boundary this page's ledger section specifies.
- [docs/reference/distillation-loss-budget.md](distillation-loss-budget.md) — what MAY be dropped vs. what MUST survive at the `task.md → finding.md` promotion boundary.
- [docs/reference/drift-and-staleness.md](drift-and-staleness.md) — the `STALE`/`CONTRADICTED` lifecycle verdicts that trigger rollback, and the `content_hash` drift signal that flips a finding `stale`.
- [docs/model/source-authority.md](../model/source-authority.md) — why `memory` (Axis B floor) can never weaken an obligation, and the `SOL-M004` authority-conflict route.
