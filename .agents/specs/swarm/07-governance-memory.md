# Swarm Kernel Specification v0.1 — Part 07: Governance, memory, versioning

<!-- Part 07 of the Swarm Kernel Specification (§22–§25). All parts share one section numbering (§0–§35 + Appendices A–G); cross-references of the form “§N” resolve via the index in [README.md](./README.md). -->

## 22. Source authority

Source authority is the deterministic procedure a conformant Swarm repo MUST use to decide, when two artifacts assert conflicting obligations, **which obligation governs**. It is the conflict-resolution complement to the obligation graph (§3): the graph records *what* obligations exist and how they relate; source authority records *which wins* when they disagree. Authority is **not** a planning hint and **not** a confidence score; it is the binding precedence order, and it is the only sanctioned alternative to silently letting the most recently written artifact win.

The model has **two orthogonal axes** that MUST be applied **lexicographically — domain first, then artifact**. Rationale: a security obligation and a product obligation may share artifact rank yet must not share governing force; the two questions ("how authoritative is the *container*" and "how authoritative is the *domain*") are genuinely independent, so they MUST be ranked independently and combined in a fixed order rather than collapsed into one ladder.

### 22.1 The two axes

#### 22.1.1 Axis A — artifact authority (backward trace)

Axis A ranks an obligation by **the kind of artifact that contains it** and that artifact's lifecycle status. It answers "how settled is the container this obligation was traced back *from*." It is therefore the **backward-trace** axis: follow an obligation back to its source artifact and read its rank.

| Rank | Artifact (with required status) | Notes |
| ---- | ------------------------------- | ----- |
| 1 (highest) | accepted `adr.md` | Nygard-immutable decision (§30); the strongest recorded intent. |
| 2 | approved `spec.swarm.md` | The behavioral contract; `status: approved` in frontmatter. |
| 3 | accepted `finding.md` | A durable project fact whose `status` is `accepted` or `promoted` (§23). |
| 4 | reviewed `audit.md` | Present-state observation that has passed a `review` pass. |
| 5 | reviewed `research.md` | External/exploratory evidence that has passed a `review` pass. |
| 6 | task notes (`task.md`) | Execution-local; durable only after promotion (§23.4). |
| 7 (lowest) | chat | Conversational context; never authoritative on its own. |

A conformant tool MUST reject (lint `SOL-M002`, see §22.3) any claim that a lower-ranked artifact silently amended a higher-ranked one. An artifact below `approved`/`accepted` status occupies the rank of its **draft tier**, which is one step below its accepted tier; e.g. a `proposed` ADR does not outrank an `approved` spec.

#### 22.1.2 Axis B — domain authority (forward governing force)

Axis B ranks an obligation by **the governance domain it belongs to**, independent of where it is written. It answers "how much *forward* governing force this obligation projects over everything downstream." It is therefore the **forward-governing-force** axis.

| Rank | Domain | Examples |
| ---- | ------ | -------- |
| 1 (highest) | enforced-policy | Deterministic, externally-enforced rules (the enforcement lane, §17): write-surface gates, secret redaction, permission denies. |
| 2 | compliance | Regulatory / legal obligations (data residency, retention, audit trails). |
| 3 | security | Authn/authz, secret handling, attack-surface constraints. |
| 4 | architecture | Module boundaries, ownership, layering, public interfaces. |
| 5 | product | User-visible behavior, acceptance criteria. |
| 6 | team | Conventions, style, process agreements. |
| 7 | task-map | Per-task execution scoping (§19). |
| 8 (lowest) | memory | Promoted findings/patterns (§23). |

An obligation's domain MUST be discoverable from its container or an explicit domain tag; where a `spec.swarm.md` is single-domain its domain MAY be declared once in frontmatter (`domain: security`), otherwise each obligation block carries the governing domain in its `AFFECTS`/owner metadata as lowered into the IR (§12). The two lowest domains, `task-map` and `memory`, are also the two axis **floors** (§22.4).

### 22.2 The conflict rule (normative)

When two obligations conflict (they constrain the same trigger/state/surface with incompatible modality), a conformant tool MUST resolve them by this exact procedure, in order:

1. **Compare DOMAIN rank (Axis B) first — but only when at least one obligation is in the hard-policy band (Axis-B ranks 1–3: enforced-policy, compliance, security).** When a hard-policy-band obligation is involved, the higher domain wins **regardless of artifact rank** (a `security` obligation governs a `product` obligation even from a lower-ranked artifact). If **neither** obligation is in the hard-policy band, domain rank does **not** override artifact authority — go to step 2.
2. **Otherwise — neither obligation is in the hard-policy band, or the two are in the same domain — compare ARTIFACT authority (Axis A).** The obligation in the higher-ranked artifact wins; if artifact rank also ties, the higher domain rank breaks the tie.
3. **If both axes are equal, STOP.** A conformant tool MUST NOT auto-select a winner. It MUST emit `SOL-M002` (semantic-layer contradiction, §8) and route the conflict to amendment/review (§14). Resolution is an authoring act, never an inference.

This ordering is **lexicographic with a hard-policy gate**: domain rank is decisive only inside the hard-policy band (Axis-B ranks 1–3); below that band, artifact authority is the most-significant key and domain rank is only a tie-breaker. This prevents a low-criticality domain note (e.g. a `team`-rank remark in a reviewed audit) from overriding a higher-authority artifact (e.g. a `product` obligation in an approved spec).

### 22.3 Worked tie-break example

> A reviewed `audit.md` records a `security` obligation: *the refresh endpoint MUST reject reuse of a rotated refresh token*. An approved `spec.swarm.md` records a `product` obligation: *the refresh endpoint MUST accept the most recent token presented, for a seamless re-login*. They conflict on the same trigger (reuse of a prior refresh token).

Applying §22.2:

1. **Axis B (domain).** `security` (rank 3) vs `product` (rank 5). Security outranks product. **Resolution stops here: the security obligation governs.**
2. Axis A is **never consulted**, even though the product obligation sits in a higher-ranked artifact (approved spec, rank 2) than the security obligation (reviewed audit, rank 4).

```sol
CONSTRAINT C-014: # from reviewed audit.md, domain: security
THE refresh endpoint MUST NOT accept a refresh token that has already been rotated
VERIFY BY security:cmdScan:auth-replay#rotated-token
AFFECTS auth.refresh
```

```sol
REQ AC-031: # from approved spec.swarm.md, domain: product
WHEN a client presents the most recent refresh token
THE refresh endpoint MUST issue a new access token
VERIFY BY test:cmdTest:auth-refresh#happy-path
AFFECTS auth.refresh
```

`C-014` (security) governs. The product REQ `AC-031` is not deleted; it is routed to amendment so its trigger can be narrowed to exclude rotated tokens. Had both obligations been `product`, the procedure would fall to Axis A and the approved spec would win over the reviewed audit.

> **Second example (below the hard-policy band).** A reviewed `audit.md` records a `team`-domain note: *new modules SHOULD live under `src/v2/`*. An approved `spec.swarm.md` records a `product` obligation on the same surface. Neither is in the hard-policy band (ranks 1–3), so domain rank does **not** decide; ARTIFACT authority does (step 2), and the approved spec (rank 3) outranks the reviewed audit (rank 5). The product obligation wins; the audit note is advisory. Were the audit note instead a `security` obligation (in-band), step 1 would flip the result.

### 22.4 Invariants on both axes

These hold on Axis A and Axis B simultaneously, and a conformant tool MUST NOT let any precedence computation violate them:

| Invariant | Statement |
| --------- | --------- |
| Code is reality, not intent | Code and tests are implementation reality. They MAY **falsify** an obligation (producing `FAIL`/`CONTRADICTED`/`STALE`, §14, §16) but MUST NOT **silently amend** intent. A divergence routes to the §16 three-way reconcile, never to a quiet edit of the obligation. |
| Memory and task-map are a floor | `memory` (Axis B rank 8) and `task-map` (rank 7) are the lowest domains and never outrank any governing domain; equivalently, a promoted finding or a task scoping note can **inform** but never **weaken** an obligation. A promotion that would weaken an obligation is itself a `SOL-M002` contradiction (§23). |
| Planning hints reorder, never weaken | `DEPENDS ON`, `parallel_group`, and other planning metadata (§13, §18) change the **order** work runs in. They MUST NOT change modality, scope, or verification bindings of any obligation. |

### 22.5 Bidirectional traceability framing

The two axes are the two directions of requirements traceability:

- **Axis A is the backward trace.** Given an obligation, you trace it *back* to the artifact it came from; the artifact's rank tells you how settled the provenance is.
- **Axis B is the forward governing force.** Given an obligation, you trace its domain *forward* over everything it governs; the domain's rank tells you how much force it projects downstream.

A conformant repo's source-authority reference (`docs/language/source-authority.md`, a kernel-required reference per §20) MUST state both axes, the lexicographic rule, the three invariants, and at least the §22.3 worked tie-break.

---

### 22.6 Human-approval-required changes

Source authority (§22) decides which obligation governs when two conflict; this section decides which **edits** to the obligation set a conformant repo MAY apply on its own versus which require approval. The classification feeding this table is the closed twelve-category semantic diff of §10.4: categories 1–11 are amendments and require approval; category 12 (pure normalization) does not.

| Change type | Approval required |
| --- | --- |
| Add, remove, or renumber an obligation id (`AC-NNN`/`C-NNN`/`I-NNN`/`IF-NNN`) | Yes |
| Change an obligation's actor, trigger, modality, response, or non-goal | Yes |
| Make a breaking `INTERFACE` (`IF-NNN`) change | Yes |
| Materially resolve a `[blocking]` `QUESTION` (§6, §11.1.2) | Yes |
| Accept a `manual` proof where no automated proof previously existed (§15) | Yes |
| Approve or supersede an `adr.md` (§30) | Yes |
| Promote a `finding.md` into an approved `spec.swarm.md` (§23) | Yes |
| Normalize formatting, casing, or keyword form (§4.10) | No |
| Fix an editorial typo with no semantic effect | No |
| Add a missing link or proof-ref without changing meaning | No |
| Compress redundant prose while preserving semantics | No |

The "Yes" rows are exactly the changes that alter what the system is obligated to build, what counts as proof, or which decision governs — each one corresponds to a non-normalization category in §10.4 and MUST route to amendment/review (§14) rather than being applied inside `improve` (§10.1). The "No" rows are the pure-normalization class (§10.4, category 12): they are semantics-preserving by definition and a conformant tool MAY apply them without approval.

> **R-APPROVAL-AUTHORITY.** This spec is provider- and org-neutral about **who** approves; it defines only **what** requires approval. Approval **authority** for any "Yes" row MUST be resolved through the source-authority ladder (§22): the approver is the owner of the highest-ranked governing artifact in the relevant domain — the accepted `adr.md` owner for an ADR change, the approved `spec.swarm.md` owner for an obligation or interface change, the domain owner (Axis B, §22.1.2) for a cross-domain conflict. There is **no** undefined "human role" in the kernel; "approval required: Yes" means "an authoring act by the relevant source-authority owner is required," never an appeal to an unspecified gatekeeper. A change applied without the authority resolved by §22 is itself a `SOL-M002` contradiction (a lower-ranked actor silently amending a higher-ranked artifact, §22.1.1).

## 23. The memory model

Memory is Swarm's durable feedback loop: the mechanism by which a discovery made during one task becomes reliably available to a future task without bloating the always-loaded bootloader (§31). The model is **two-tier and provenance-anchored**. It is markdown-only (Principle 1, §2): nothing here describes a retrieval engine; it describes the *files and the discipline* a future retrieval tool would build against.

Rationale: chat transcripts and inline prose are not memory — they are unindexed, unprovenanced, and unfalsifiable. Memory MUST be a **promotion system** (a fact earns durability through a recorded promotion) backed by an **immutable evidence store**, with a compact index over it.

### 23.1 Tier-1 — the compact map (kernel)

Tier-1 is what an agent reads *first* and *cheaply*. It is a map, not the territory.

#### 23.1.1 `memory/INDEX.md`

`memory/INDEX.md` is a kernel-required core artifact (§20). It is a **compact map of links, not explanations**. Each entry MUST carry a **`Load when` condition** — the trigger that tells a future agent the entry is relevant to its current task.

Normative rule (the **load-when discipline**): if an entry cannot name *when it matters*, it MUST be removed from the index. An entry without a usable `Load when` is dead weight against the §24 loss budget and the §31 density cap.

```text
## Durable findings

| Finding | Status | Load when |
| -------------------------------- | -------- | ------------------------------------------------------ |
| finding-refresh-token-replay.md | promoted | Touching auth token rotation or refresh endpoints |
| finding-bq-cost-explosion.md | accepted | Writing or reviewing analytics queries against BigQuery |

## Topic files

| Topic | File | Load when |
| --------------------- | -------------------------- | ------------------------------------------------------ |
| Architecture patterns | `patterns/architecture.md` | Editing module boundaries, ownership, or cross-cutting flows |
```

The INDEX **links into** Tier-2 artifacts; it MUST NOT duplicate their bodies. A conformant tool MAY treat a divergence between an INDEX summary line and the linked artifact as advisory drift.

#### 23.1.2 `memory/glossary.md`

`memory/glossary.md` enforces **one word, one meaning** (ASD-STE100 discipline, also referenced by APS §7 and the `SOL-P006` undefined-term rule, §8). Each entry binds exactly one term to exactly one definition. A term whose meaning is contested MUST be split into distinct terms, never overloaded. The glossary is the project-level fallback for term resolution; an in-file `TERM` definition in a `spec.swarm.md` takes precedence over the glossary for that spec (term-resolution precedence).

### 23.2 Tier-2 — the immutable evidence store (kernel)

Tier-2 is the **territory**: the durable artifacts the INDEX points at.

| Artifact | Role in memory | Mutability |
| -------- | -------------- | ---------- |
| `finding.md` | One durable project fact + its evidence | Immutable once `accepted`/`promoted`; status may advance, body does not silently change |
| `adr.md` | Architectural/product decision + rationale | Nygard-immutable (§30); amend only by superseding ADR |
| `audit.md` | Present-state risk/debt observation | Immutable record of an observation at a point in time |
| `bug-report.md` | Reproducible-defect diagnosis | Immutable record of a reproduction |
| `memory/patterns/*.md` | Recurring knowledge spanning **multiple** findings | Append-on-supersession |

`memory/patterns/*.md` exists for knowledge that recurs across more than one finding — a pattern is the distillation of several findings into reusable guidance, and it MUST cite the findings it generalizes. A single finding MUST NOT be promoted directly to a pattern; promote it to a `finding.md` first, and to a pattern only once a second corroborating finding exists.

### 23.3 Provenance (mandatory on every promoted finding)

Every finding that reaches `accepted` or `promoted` status MUST carry the full provenance record. Provenance is what makes a finding *falsifiable* and *staleness-checkable*; a finding without it is chat, not memory.

| Field | Meaning |
| ----- | ------- |
| `claim` | The one durable fact, stated as a single proposition. |
| `evidence` | The file/command/output/source that grounds the claim. |
| `origin_obligations[]` | The obligation IDs (`AC-/C-/I-…`) the finding was discovered against. |
| `origin_traces[]` | The `*.swarm.trace.md` entries that produced the evidence. |
| `pass+profile` | The pass and heuristic profile under which it was found (e.g. `review[profile: skeptic]`, §26–§27). |
| `reviewer_or_tool` | The human reviewer or tool/adapter that confirmed it. |
| `timestamp` | When it was promoted. |
| `content_hash` | Hash of the cited source/surfaces at promotion time (drives staleness, §23.5). |
| `confidence` | `high` \| `medium` \| `low`. |
| `applies-when` / `does-not-apply-when` | The scope envelope; mirrors the `Load when` of the INDEX entry. |

```text
---
type: finding
id: finding-refresh-token-replay
status: promoted
confidence: high
origin_obligations: [C-014]
origin_traces: [auth-refresh.swarm.trace.md#C-014]
pass: review
profile: skeptic
reviewer_or_tool: cmdScan / human reviewer jdoe
timestamp: 2026-05-31T09:14:00Z
content_hash: sha256:7f1c…a02b
applies_when: "auth token rotation, refresh endpoints"
does_not_apply_when: "single-use opaque session cookies (no rotation)"
---

## Claim
Reusing a rotated refresh token MUST be rejected; the rotation store is the oracle, not the JWT exp.
```

### 23.4 Promotion

A discovery during a task does not become memory by being written down; it becomes memory by being **promoted**. The kernel references the promotion protocol (`docs/language/promotion-protocol.md`, §20) and its status enum. Every promotion item raised during a task MUST resolve to one of these before the task closes:

| Promotion status | Meaning |
| ---------------- | ------- |
| `pending` | Raised, not yet dispositioned. |
| `promoted` | Written to its durable target and indexed. |
| `deferred` | Recorded for a future task with reason. |
| `rejected` | Judged non-durable with reason. |
| `blocked` | Cannot promote yet (e.g. needs an ADR) with reason. |

Normative rule: a task MUST NOT close while any promotion item is `pending`. A `promoted` finding MUST appear in `memory/INDEX.md` with a `Load when` condition (§23.1.1) and carry full provenance (§23.3). A promotion that would *weaken* an obligation is forbidden — it is a `SOL-M002` contradiction routed to amendment, because `memory` is the floor domain on Axis B (§22.4).

#### 23.4.1 G9 tie-break — "universal workflow rule" promotions

The promotion table (§23.4, adapted from this specification) routes a *universal workflow rule* toward `AGENTS.md`. This collides with the ≤200-line bootloader cap and ADR 0017 (only persistent **facts** belong in `AGENTS.md`; **procedures** belong in pass guides). The kernel resolves the collision normatively (G9):

A "universal workflow rule" promotion MUST become **a pass-guide edit (the procedure) PLUS at most a one-line `AGENTS.md` pointer (the fact that the guide exists and when to load it).** It MUST NOT inline the procedure into `AGENTS.md`.

| Where it goes | What goes there |
| ------------- | --------------- |
| Pass guide (`docs/skills/…`, §26) | The actual procedure / steps. |
| `AGENTS.md` | One line: the pointer + its load-when, nothing procedural. |

> Example — promoting "always run the migration dry-run before applying": the dry-run procedure is added to the `implement` pass guide; `AGENTS.md` gains only `- Before applying a migration, load the implement pass guide (migration section).`

This keeps the bootloader a map (consistent with §31) and the procedure lazily loaded.

#### 23.4.2 Discovery-to-promotion-target table

Promotion is **mandatory before task closure** (§23.4): every discovery a task surfaces enters the **promotion queue** and MUST resolve to one of `pending | promoted | deferred | rejected | blocked`, and a task MUST NOT close while any item is `pending` — all five statuses except `pending` are terminal-for-this-task, and `deferred`/`rejected`/`blocked` each carry a reason. This subsection is the consolidated routing table the §20.3.2 promotion-protocol reference doc cites: given the *kind* of discovery, it fixes the single durable target the `promote` pass (§) writes to. The kinds are mutually exclusive by intent; when a discovery has two faces (e.g. it is both a durable decision and a reusable pattern), it is promoted to each applicable target and each lands as its own queue item.

| Discovery | Promote to |
| --------- | ---------- |
| New intended behaviour (a real obligation/constraint to build against) | `spec.swarm.md` (a new or amended `REQ`/`CONSTRAINT`/`INVARIANT`/`INTERFACE`), or an ADR when the behaviour is gated on an undecided architectural/product choice. |
| Durable architectural or product decision (a choice with consequences, alternatives, trade-offs) | An ADR (`.agents/adrs/<nnnn>-<slug>.md`). |
| Present-state risk or debt (what *is*, observed but not yet a chosen change) | An audit (`.agents/audits/<slug>.md`) — observation-only, never prescriptive (§20.3.3). |
| Reproduced defect evidence (root cause + expected vs actual, reproducible) | A bug-report (`.agents/bug-reports/<slug>.md`) — diagnosis-only; the fix promotes onward to a `task_kind: fix` task (§20.3.3). |
| Reusable project fact (a durable claim learned during work, with evidence) | A finding (`.agents/findings/<slug>.md`), indexed in `memory/INDEX.md` with a `Load when` (§23.1.1) and full provenance (§23.3). |
| Repeated cross-task pattern (a recurring solution shape seen across more than one task) | `memory/patterns/*.md`. |
| Terminology clarification (a term whose meaning was ambiguous or drifted) | `memory/glossary.md` (the canonical lexicon; resolves `SOL-V`-layer terminology drift at the source). |
| Universal workflow rule (a procedure that should apply to every future task) | A pass-guide edit (the procedure) **plus at most a one-line `AGENTS.md` pointer** — NEVER inline procedure in `AGENTS.md`; the bootloader holds persistent facts, not steps (§23.4.1). |
| Purely local execution detail (relevant only to this task's run) | Keep in the task only (`task.md`); it is **not** durable and is dispositioned `rejected` for promotion with reason "execution-local". |

Two normative consequences hold across every row. First, a promotion that would *weaken* an existing obligation is forbidden at any target — it is a `SOL-M002` contradiction routed to amendment, because `memory` is the floor domain on Axis B (§22.4). Second, "keep in the task only" is a real disposition, not an omission: such an item is still recorded in the queue and resolved (`rejected`, with reason), so that the mandatory-before-close rule (§23.4) admits no silent drops.

### 23.5 Staleness

A finding's `status` enum is `candidate | accepted | promoted | rejected | stale | superseded`. A finding becomes **`stale`** when its `content_hash` (§23.3) no longer matches the cited source/surfaces — the same drift signal that produces the `STALE` verdict lifecycle decorator (§14) and the spec↔code drift reconcile (§16). A `stale` finding MUST NOT be relied on as authority; it is routed to re-verification or supersession. A `superseded` finding records its replacement in `memory/INDEX.md`'s stale/superseded table.

The kernel ships the **fields** that make staleness computable (`content_hash`, `origin_traces`); it does **not** ship the comparator. Recomputing the hash and flipping `accepted → stale` is a harness/CLI concern (§16, §17), aspirational/manual today (Principle 1).

### 23.6 Deferred to post-v0.1

The following are explicitly **out of scope for v0.1**, because each requires a runtime Swarm does not ship:

| Deferred | Reason |
| -------- | ------ |
| Embedding / dense-vector retrieval | Needs an index engine and runtime. |
| LRU (or any automatic) eviction | Needs a runtime memory manager. |
| Automatic staleness hashing | Needs a differ/checker (§16); fields shipped, comparator deferred. |
| Cross-session agent identity | Needs persistent runtime state. |
| Memory dashboards / analytics | Needs a runtime UI. |

v0.1 ships the two-tier file model, the provenance fields, the promotion statuses, and the `Load when` discipline. Automation builds against them later.

---

## 24. The distillation loss budget

Distillation is the deliberate **dropping of detail** that happens whenever information crosses a boundary in the pipeline — most acutely at the **spec → task lowering boundary** (§11) and the **promotion boundary** (§23.4). The loss budget is the discipline governing *what may be dropped* versus *what must survive*. Its purpose is to let lowering and promotion compress aggressively without ever silently losing binding force.

Rationale: a distillation that drops an obligation, its modality, or its verification binding has not compressed the spec — it has **changed what gets built**. The loss budget makes that the bright line.

### 24.1 What MAY be abstracted or dropped

At any distillation boundary, the following MAY be abstracted, summarized, or dropped entirely, because none of it carries binding force:

| Droppable | Where it survives instead |
| --------- | ------------------------- |
| Commentary and narrative prose | The source artifact (linked, not copied). |
| Redundant restatements | The single canonical statement. |
| Rationale already recorded elsewhere | The ADR / finding / research it came from. |
| Rejected options, source digressions, low-confidence observations | The `research.md` (§24.4 table). |
| Step-by-step execution logs | The `task.md` and the trace. |

### 24.2 What MUST survive every distillation

The following MUST survive intact across **every** boundary. Dropping or weakening any of them is a **distillation error** (lint `SOL-V001`/`SOL-M…` family, §8), not a stylistic choice:

| Must survive | Why |
| ------------ | --- |
| The obligation itself (its ID) | The traceability key (§4); losing it severs backward trace (§22.5). |
| Its modality (`MUST`/`MUST NOT`/`SHOULD`/…) | Modality *is* the binding force (§4); losing it neutralizes the obligation. |
| Its verification bindings (`VERIFY BY …`) | An obligation with no proof path is `UNVERIFIED` (§14, §15). |
| Its authority and scope | The domain/artifact rank (§22) and `WRITES`/`READS`/`AFFECTS` scope (§18). |
| Constraints, invariants, non-goals, unresolved `QUESTION`s | These bound the build; dropping a non-goal silently widens scope. |

The this specification's loss-budget matrix is canonical and reproduced here as the per-boundary specialization of these two lists:

| From | To | Permitted loss | Forbidden loss |
| ---- | -- | -------------- | -------------- |
| `research.md` | `spec.swarm.md` | Source digressions, rejected options, low-confidence observations | Constraints, unresolved ambiguity, decision-changing evidence |
| `audit.md` | `spec.swarm.md` | Low-priority cleanup details | Observed risks affecting target behavior |
| `bug-report.md` | fix task | Duplicate failed reproduction attempts | Reliable reproduction, expected/actual behavior, root-cause evidence |
| `spec.swarm.md` | task | Rationale not needed for execution | Obligation IDs, modality, constraints, invariants, verification bindings, non-goals |
| `finding.md` | task | Historical discussion | Actionable claim, applicability, evidence |
| `task.md` | `finding.md` | Step-by-step execution log | Evidence for the durable claim |
| task output | trace | Narrative detail | Obligation ID, changed files, proof |
| trace | review verdict | Implementation chatter | Claim, evidence, pass/fail reason |

### 24.3 The budget is a discipline, not a gatekeeper

The loss budget is **enforced by source authority (§22) plus lint (§8)** — it is not, and MUST NOT be implemented as, a "documentation-gatekeeper" skill or persona. Rationale: a gatekeeper is soft control (a model deciding whether to allow a passage, §2 / §17), so it can be talked past; a lint rule plus an authority comparison are deterministic checks against the typed obligation set.

Concretely:
- **Lint** catches a distillation error structurally: a lowered task that omits an obligation ID its source spec declares, or a `VERIFY BY` binding present in the spec but absent in the task, is a `SOL-V001`/`SOL-M…` diagnostic.
- **Source authority** catches it semantically: a distilled artifact that contradicts its higher-authority source is a `SOL-M002` contradiction (§22.2), routed to amendment — the distillation cannot silently win.

The **`spec.swarm.md` distillation loss statement** (the `Preserved / Dropped / Still uncertain` section, §21) is the human-authored declaration the lint checks against. It records what the author *intends* to be droppable, so the loss is auditable rather than accidental.

### 24.4 Forbidden compositions

A **forbidden composition** is the silent mixing of two distinct epistemic stances — most dangerously, an **observation-only artifact silently becoming intent**. Examples: an `audit.md` (observation of present state) read as if it were an approved `spec.swarm.md` (intended behavior); a `research.md` (exploratory) treated as a decision; a `bug-report.md` (diagnosis) treated as a fix authorization.

These compositions are prevented by the **loss budget + source authority**, NOT by a documentation-gatekeeper:

- The **loss budget** forces the crossing to be explicit: an audit *promotes to* a spec through the `audit.md → spec.swarm.md` row of §24.2, which is an authoring act that re-states observations as obligations with their own IDs, modality, and verification bindings. There is no path by which an audit's prose becomes binding without that re-statement.
- **Source authority** ranks the stances: an `audit` (Axis A rank 4, observation) cannot silently amend an approved `spec` (rank 2); if it appears to, that is a `SOL-M002` contradiction routed to review (§22.2).

> Worked example — an `audit.md` notes "the refresh endpoint currently accepts rotated tokens." This is an **observation**, not intent. To affect the build it must promote into `spec.swarm.md` as a re-stated obligation (`CONSTRAINT C-014`, §22.3) carrying modality and `VERIFY BY`. The audit prose alone has Axis-A rank 4 and `audit`/`security` domain; it never silently overwrites the product spec — the §22 conflict procedure governs, and the loss budget forces the explicit re-statement. The epistemic stance is preserved end-to-end: an observation stayed labeled an observation until an author deliberately turned it into intent.

The conformant repo's distillation-loss-budget reference (`docs/language/distillation-loss-budget.md`, §20) MUST state both lists (§24.1, §24.2), the per-boundary matrix, the discipline-not-gatekeeper rule, and the forbidden-composition treatment.

---

## 25. Versioning

Swarm has **two independent version axes**. Conflating them is a category error: one tracks the *meaning of the language*, the other tracks *the package that delivers it*. A conformant repo MUST track both and MUST NOT merge them into a single number.

### 25.1 The two axes

| Axis | What it versions | Where it lives | Cadence |
| ---- | ---------------- | -------------- | ------- |
| **Language version** | The SOL + APS feature set: grammar, the 7 block types, the 5 modals, the clause keywords, the `SOL-<LAYER>NNN` lint codes (§4–§8) | Per-file frontmatter: `swarm_language` + `aps_version` | Small, slow-moving: `0.1`, `0.2`, `1.0` |
| **Framework / package version** | The scaffold, templates, skills/pass guides, personas/profiles, flow-graph (§20, §21, §26–§29) | `.agents/.swarm-version` (semver) | Ordinary semver; may move many times between language bumps |

Rationale: this mirrors C# `LangVersion` vs the SDK/compiler, and Rust editions vs `rust-version` vs cargo/rustc — the *language API* (grammar + lint codes) and the *package API* (template sections + skills + flow-graph) evolve on independent clocks, and SemVer is only meaningful when each public API is named explicitly.

#### 25.1.1 Language version

The language version answers "**which grammar, blocks, modals, and lint codes does this file speak?**" It is carried **per file** so that a single repo MAY contain `spec.swarm.md` files at different language versions during a migration.

- `swarm_language` is the **SOL discriminator**, written `SOL/0.1`.
- `aps_version` is the **APS prose-standard version**, written `0.1`.

#### 25.1.2 Framework / package version

The framework version answers "**which scaffold, templates, and pass guides shipped this repo?**" It is a single semver string in `.agents/.swarm-version`. This **extends ADR 0015** (which established `.agents/.swarm-version`); ADR 0015 is *extended, not replaced* (§30) — it is scoped to the package axis and the language axis is added alongside it.

### 25.2 The one-way trigger

The axes are independent, but coupled by exactly **one** directional rule:

> **Any change to the SOL/APS language version MUST force at least a framework MINOR release** — additive language change → framework MINOR; breaking language change → framework MAJOR. The framework MAY release any number of versions (PATCH/MINOR/MAJOR) **without** changing the language version.

```text
language change ──(MUST)──▶ framework MINOR (additive) or MAJOR (breaking)
framework change ──(MAY)──▶ no language change required
```

Rationale: a new keyword or lint code changes what the templates and pass guides must teach, so the package that ships them MUST move; but fixing a template typo or adding a skill never changes the grammar, so the language MUST stay pinned. The trigger is **one-way**: language ⇒ framework, never framework ⇒ language.

### 25.3 Three distinct version fields in the IR/plan

The emitted IR (§12) and plan (§13) MUST echo **three distinct fields**, and a conformant tool MUST NOT merge any two of them:

| Field | Axis / meaning | Example |
| ----- | -------------- | ------- |
| `meta.language` | The SOL **discriminator** (which grammar this IR was parsed under) | `"SOL/0.1"` |
| `meta.version` | The **spec content version** (the semver of *this spec's intent*, independent of language and framework) | `"0.1.0"` |
| `provenance.compiler_version` | The **tool version** that emitted the IR, when a tool exists | `"0.0.0"` / unset today (no runtime, §2) |

```json
{
 "meta": {
 "language": "SOL/0.1",
 "version": "0.1.0",
 "title": "auth-refresh"
 },
 "provenance": {
 "compiler_version": null
 }
}
```

These answer three different questions — *which grammar* (`meta.language`), *which revision of this spec's intent* (`meta.version`), *which tool produced this* (`provenance.compiler_version`) — and a single number cannot answer all three.

### 25.4 G10 — frontmatter normalization (normative)

To unblock the §25.3 three-field mapping, the kernel pins one canonical frontmatter vocabulary across **all** `.swarm.md` and template files (G10):

```text
---
swarm_language: SOL/0.1 # SOL discriminator (= meta.language in the IR)
aps_version: 0.1 # APS prose-standard version
spec_version: 0.1.0 # spec content version (= meta.version in the IR)
---
```

| Frontmatter field | Maps to IR field | Axis |
| ----------------- | ---------------- | ---- |
| `swarm_language: SOL/0.1` | `meta.language` | Language (discriminator) |
| `aps_version: 0.1` | (not echoed in IR; governs prose lint layer `SOL-P…`) | Language |
| `spec_version: 0.1.0` | `meta.version` | Spec content |

Conformance note: earlier draft templates currently write `swarm_language: 0.1` (a bare number). The normalized form is `swarm_language: SOL/0.1` (with the `SOL/` discriminator) and a separate `spec_version`. A conformant repo MUST use the normalized form; a bare `swarm_language: 0.1` is a `SOL-S…`-class frontmatter diagnostic. The framework version is **never** written in per-file frontmatter — it lives only in `.agents/.swarm-version`.

Key resolutions encoded, all marked NORMATIVE per this specification:
- **§22**: two orthogonal axes applied lexicographically (domain first via Axis B, then artifact via Axis A), the three-step conflict rule terminating in `SOL-M002`, the worked security-audit-beats-product-spec tie-break, the three cross-axis invariants, and the backward-trace/forward-governing-force framing.
- **§23**: two-tier provenance-anchored model (Tier-1 INDEX map + glossary with the load-when discipline; Tier-2 immutable evidence store + patterns), full mandatory provenance field set, promotion status enum with task-close gate, the **G9** tie-break (pass-guide edit + one-line AGENTS.md pointer, never inline procedure), `candidate|accepted|promoted|rejected|stale|superseded` staleness tied to §16, and the post-v0.1 deferral table.
- **§24**: MAY-drop vs MUST-survive lists, the per-boundary matrix, the discipline-not-gatekeeper rule (lint + source authority), and forbidden-compositions prevention via loss budget + source authority.
- **§25**: the two axes, the one-way trigger (language ⇒ framework MINOR/MAJOR), the three never-merged IR fields, and the **G10** frontmatter normalization (`swarm_language: SOL/0.1`, `aps_version: 0.1`, `spec_version: 0.1.0`).

Now I'll draft my six sections (§26–§31). Writing the final canonical specification text.
