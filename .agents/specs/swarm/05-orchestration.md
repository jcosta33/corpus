# Swarm Kernel Specification v0.1 — Part 05: Orchestration & parallelism

<!-- Part 05 of the Swarm Kernel Specification (§18–§19). All parts share one section numbering (§0–§35 + Appendices A–G); cross-references of the form “§N” resolve via the index in [README.md](./README.md). -->

## 18. Multi-agent orchestration and safe parallelism

### 18.1 Scope: the kernel owns a coordination contract, not a scheduler

Swarm MUST treat multi-agent coordination as a **static, recorded contract** that a reviewer or a future checker reads, never as a live scheduler the kernel executes. This is the orchestration projection of Principle 1 (NO RUNTIME, see §2): everything that would "run" agents — batching, dispatch, stall detection, replanning — is documented as a CONTRACT a future launcher builds against, and is never shipped by this repo.

Concretely, the kernel owns exactly four things and nothing more:

| # | Kernel-owned artifact | Where specified |
|---|---|---|
| 1 | Obligation-level scope declarations (`WRITES`, `READS`, `DEPENDS ON`, `AFFECTS`) as SOL surface fields | §18.2 |
| 2 | Two derived graphs the `lower` pass MUST emit (dependency DAG + write-surface conflict graph) | §18.4 |
| 3 | The single canonical safe-parallelism predicate | §18.5 |
| 4 | The recorded coordination artifact schema (`task-orchestration.md`) | §19 |

The boundary is fixed by the orchestration boundary with one clause of rationale each: agents are **not yet reliable at real-time coordination** and coding parallelizes worse than research; the **write side stays single-threaded** (ADR 0010); safe concurrency reduces to **conflict-serializability** over declared access sets; and a stall-then-replan signal is the runtime analogue of the recorded liveness marker (§19.5). The kernel records the contract those mechanisms operate on; it does not operate them.

Depth split (normative):

| Layer | Owns |
|---|---|
| **Kernel** | The four artifacts above: declarations, two graphs, the predicate, the artifact schema. |
| **Stdlib** | The `decompose` pass guide and the lead-engineer profile (§26, §27) that apply the contract. |
| **Launcher/harness (OUT of kernel)** | Anything that *runs* agents (§18.8). |

### 18.2 Obligation-level scope declarations (surface fields)

Every obligation block (REQ, CONSTRAINT, INVARIANT — see §6) MAY carry the four scope-declaration metadata clauses below. They are SOL **surface** syntax: UPPERCASE, space-separated, English-shaped, appended after the obligation body in the trailing-metadata position fixed by §5 (`DEPENDS ON / TOUCHES / WRITES / READS / AFFECTS / RISK`). The corresponding IR field is `snake_case` (§12); the surface↔IR split is master layering.

| Surface clause | IR field | Meaning | Graph contribution |
|---|---|---|---|
| `WRITES <surface-list>` | `writes[]` | The write surfaces (named SURFACEs or paths/globs) the obligation mutates. | Write-surface conflict graph (§18.4). |
| `READS <surface-list>` | `reads[]` | The read set the obligation depends on but does not mutate. | Read/write conflict edges (§18.6). |
| `DEPENDS ON <id-list>` | `depends_on[]` | Hard ordering: this obligation MUST be satisfied after the listed obligations. | Dependency DAG (§18.4). |
| `AFFECTS <id-list-or-surface>` | `affects[]` | The impact set: obligations or surfaces that may be perturbed but are not directly written. | Soft conflict edge (`affects`, §18.6). |

`AFFECTS` MUST be lowered to an `affects` edge in the IR, never folded into `writes` or `depends_on`. `DEPENDS_ON` (underscore) is **not** a surface keyword; it is a transcription of the IR edge type, and any source author writing `DEPENDS_ON` in `.swarm.md` MUST be flagged `SOL-S005`-adjacent (keyword-form error). The surface keyword is exactly `DEPENDS ON` (two words).

Worked example (surface):

```sol
REQ AC-014:
  WHEN refresh.token IS expired
  THE auth-client MUST request a new access token
  VERIFY BY test:cmdTest:tests/auth/test_refresh.py#test_expired_triggers_refresh
  DEPENDS ON AC-010
  WRITES auth.client.code
  READS auth.config
  AFFECTS AC-022
  RISK high
```

Lowered IR fragment (snake_case, §12):

```json
{
  "id": "REQ.auth-refresh.AC-014",
  "kind": "REQ",
  "writes": ["auth.client.code"],
  "reads": ["auth.config"],
  "depends_on": ["AC-010"],
  "affects": ["AC-022"]
}
```

with the relationships emitted as edges (the single source of relationship truth, §12), never duplicated as node scalars in the conflict analysis:

```json
{"from": "REQ.auth-refresh.AC-014", "to": "REQ.auth-refresh.AC-010", "type": "depends_on", "hard": true},
{"from": "REQ.auth-refresh.AC-014", "to": "REQ.auth-refresh.AC-022", "type": "affects", "hard": false}
```

### 18.3 Named SURFACEs and the no-`locks`-primitive rule

A **write surface** is a named coarse region declared with the SOL `SURFACE` statement. There is **no** `locks` primitive on either the surface or IR layer; a lock group **is** a named SURFACE, so lock-set analysis reduces to write-set analysis at surface granularity.

```ebnf
surface_def = "SURFACE", ws, surface_name, ws, "=", ws, surface_expr, [ ws, surface_attr ], nl;
surface_expr = glob | path | surface_name, { ",", surface_expr };
surface_attr = "[", ( "append-only" | "integration" | "shared" ), "]";
```

Example:

```sol
SURFACE auth.client.code = src/auth/client/**
SURFACE auth.config      = config/auth.yaml
SURFACE repo.lockfile    = package-lock.json [append-only]
SURFACE ci.config        =.github/workflows/** [shared]
SURFACE db.migrations    = migrations/** [integration]
```

An obligation's `WRITES` clause SHOULD reference named SURFACEs rather than raw globs, BECAUSE named surfaces make the conflict graph stable under file moves and let one attribute govern many obligations. An obligation MAY write a raw path; raw paths are treated as anonymous singleton surfaces for conflict analysis.

#### 18.3.1 SURFACE attributes (gap G7)

The optional `[attr]` tag changes how the safe-parallelism predicate (§18.5) and staleness (§16) treat the surface. This resolves gap G7; it is NORMATIVE in v0.1.

| Attribute | Conflict treatment | Staleness treatment | Typical surfaces |
|---|---|---|---|
| *(none)* | Ordinary exclusive write surface: any two obligations that both `WRITES` it conflict and serialize. | Modification after last PASS → `STALE` (§16). | Feature source, test files. |
| `append-only` | Concurrent appends do **not** conflict (no shared mutable region); the surface MUST NOT be edited in place. | An append MUST NOT mark unrelated proofs STALE; only a non-append edit triggers blanket staleness. | Lockfiles, changelogs, manifests. |
| `integration` | Writes serialize through a single dedicated integration step rather than blocking feature work; treated as a high-conflict surface routed to one worker/pass. | Modification marks STALE only obligations whose proof exercised the integration surface. | Migrations, shared schemas. |
| `shared` | Treated as a hidden high-conflict surface: writes serialize by default; never co-scheduled in a parallel batch. | Does NOT trigger blanket staleness across the whole spec; staleness is scoped to proof-exercised obligations. | CI config, project-wide manifests, global config. |

Rationale (terse): shared/global/append-only files (lockfiles, CI definitions, manifests) function as hidden high-conflict surfaces even when the visible feature work is disjoint; without an attribute the predicate would either over-serialize honest feature work or, worse, treat a lockfile touch as an ordinary write conflict and force a blanket re-verification. The attribute lets the predicate be correct in both directions.

### 18.4 The two derived graphs (lowering obligation)

The `lower` pass (§9, §11) MUST emit, from a parsed and normalized spec, exactly two coordination graphs into the IR `edges[]`:

1. **The dependency DAG** — built from every `DEPENDS ON` clause as `depends_on` edges. It MUST be acyclic; a cycle is an ORCHESTRATION-layer error (`SOL-O002`, see §8). Topologically sorting it yields the legal partial order of work.
2. **The write-surface conflict graph** — an undirected graph whose nodes are obligations and whose edges connect any two obligations that are **not write-disjoint** under the surface rules of §18.3 and the read rules of §18.6. Two obligations share an edge iff they write the same non-attribute surface, or write a `shared`/`integration` surface, or stand in a read/write conflict on the same surface.

These two graphs are the entire mechanical substrate of safe parallelism. The kernel emits them; it MUST NOT schedule against them. Any document or tool that presents these graphs as a live scheduler violates Principle 1 and §17.

```text
spec.swarm.md
   │  (lower)
   ├──► dependency DAG          (from DEPENDS ON)        → legal order
   └──► write-surface graph     (from WRITES / SURFACEs / READS) → safe batches
```

### 18.5 The safe-parallelism predicate (single, canonical)

There is exactly one safe-parallelism predicate in Swarm. Conformant tools and authors MUST use it verbatim; no alternative or relaxed predicate is permitted in v0.1.

> **Two work packets MAY run in parallel if and only if they are dependency-independent AND write-disjoint** — that is: neither is reachable from the other in the dependency DAG, **and** they share no write surface and no interface or migration node in the write-surface conflict graph. Anything unscoped or shared **serializes by default**.

Formally, for work packets `a` and `b`:

```text
parallel_safe(a, b)  ⇔
      ¬reachable_DAG(a, b) ∧ ¬reachable_DAG(b, a)        # dependency-independent
   ∧  writes(a) ∩ writes(b) = ∅                          # no shared write surface
   ∧  ¬shares_interface_or_migration(a, b)               # no shared boundary node
   ∧  ¬readwrite_conflict(a, b)                           # §18.6
```

Two defaults are normative and MUST NOT be weakened:

- **Unscoped serializes.** An obligation with no `WRITES` clause MUST be treated as conflicting with every other obligation (its write set is unknown, hence assumed maximal). It MUST NOT be co-scheduled in a parallel batch. Rationale: a missing scope is a hidden conflict, and the write side stays single-threaded by default (ADR 0010).
- **Shared serializes.** Any obligation touching a `shared` or `integration` SURFACE, or any INTERFACE/migration node, MUST serialize (§18.3.1).

Read-only passes (`lint`, `review`, and any pass that declares only `READS`) MAY run broadly in parallel, because read/read never conflicts (§18.6).

### 18.6 The READS conflict rule (gap G7)

Read/write coordination follows **conflict-serializability** semantics. This resolves gap G7 and is NORMATIVE in v0.1.

| Pair on the same surface | Conflict? | Edge emitted |
|---|---|---|
| read / read | No — always parallel-safe | none |
| read / write | **Yes** — conflict | conflict edge in the write-surface graph |
| write / write | **Yes** — conflict | conflict edge in the write-surface graph |

That is: two obligations that both only `READS` a surface MUST be schedulable in parallel; but if one `READS` a surface that another `WRITES`, they MUST be connected by a conflict edge and serialized (the reader either runs strictly before or strictly after the writer in the DAG order). Reads on *different* surfaces never conflict. `AFFECTS` contributes a soft `affects` edge that the predicate treats as advisory (a reviewer signal), not as a hard conflict, unless the affected surface also appears in a `WRITES` set.

Worked example: `AC-014` (`READS auth.config`) and `AC-031` (`WRITES auth.config`) MUST be serialized; `AC-014` (`READS auth.config`) and `AC-040` (`READS auth.config`) MAY run in parallel.

### 18.7 Orchestration lint codes

Two ORCHESTRATION-layer lint codes (`SOL-O001` write-surface conflict marked parallel and `SOL-O005` owned-path outside `WRITES`, §8) govern the coordination contract. Both are NORMATIVE in v0.1.

| Code | Layer | Severity | Triggers when |
|---|---|---|---|
| `SOL-O001` | ORCHESTRATION | **ERROR** | Two obligations sharing a write surface (a conflict edge in the write-surface graph) are marked for, or scheduled into, the same parallel batch. |
| `SOL-O005` | ORCHESTRATION | **ERROR** | A worker's OWNED path in `task-orchestration.md` falls outside the union of that worker's assigned obligations' declared `WRITES` surfaces (the two-tier lowering check, §19.7). |

`SOL-O001` is raised from Warning to **ERROR** in this kernel (this specification Theme 6): a write-conflict marked parallel is the precise failure that produces silent, hard-to-review merge corruption, so it MUST block. `SOL-O005` is the new code that enforces the disjoint-scope invariant between the source tier and the execution tier (§19).

```text
SOL-O001  ERROR  AC-014 and AC-031 both WRITES auth.config but share parallel_group "g1"
          suggest: serialize (add DEPENDS ON), split the surface, or drop the shared group
SOL-O005  ERROR  worker "auth-core" owns src/auth/server/** which is outside its obligations'
          declared WRITES {auth.client.code}; either re-scope the worker or add the WRITES surface
```

### 18.8 Out of the kernel (the optional launcher/harness)

The following are explicitly OUT of the kernel and MUST be documented, where they appear at all, as launcher/harness concerns a future tool MAY build against the kernel contract — never as something this repo ships (Principle 1, §17):

| Out-of-kernel concern | Why deferred |
|---|---|
| Live scheduling / batching of work packets | Requires a runtime; the kernel emits the graphs a scheduler would consume, not the scheduler. |
| Real-time stall detection and automatic replan | The kernel records the liveness marker + threshold + action (§19.5); detecting and acting on it in real time is the runtime analogue, deferred. |
| Inter-agent wire protocols (A2A / MCP) | Transport between running agents; no markdown artifact, no kernel surface. |
| SDK delegation primitives | Spawning/handing off live agents; agents are not yet reliable at real-time coordination, so the kernel records the *contract*, not the call. |

A conformant Swarm repo MUST NOT claim any of the above exists. It MUST present the dependency DAG, conflict graph, and predicate as *inputs a launcher could one day consume*, and the coordination artifact (§19) as the recorded contract a human (or eventual checker) reads. This staged-contract stance — recording the contract rather than running live multi-agent orchestration — has empirical support: a simple localize→repair→validate pipeline reaches 32.00% on SWE-bench Lite at $0.70, outperforming the elaborate open-source multi-agent systems of its time [AGENTLESS].

---

## 19. The coordination artifact

### 19.1 Purpose and identity

`task-orchestration.md` is the single canonical **recorded coordination contract** for any multi-agent (orchestration) task. It is a plain `.md` working artifact (§20, §21): it is human/agent-authored, not compiler-emitted, and carries no `.swarm.` infix. It is the execution-tier counterpart of the source-tier scope declarations (§18.2): where the source spec declares `WRITES`/`READS`/`DEPENDS ON`/`AFFECTS` per obligation, the coordination artifact projects those declarations onto **workers** and records the hand-off, liveness, and merge contract a reviewer can reconstruct the whole run from. It is governed by ADR 0025.

A conformant orchestration task file MUST contain the sections in §19.2–§19.6. Each is a recorded contract a reviewer (or a future checker, §32) reads; none is a runtime.

### 19.2 Worker tracker: OWNED and FORBIDDEN paths (the disjoint-scope invariant)

The worker tracker is a table with one row per worker. Two columns are load-bearing:

- **OWNED paths** — the file/glob projection of that worker's assigned obligations' `WRITES` surfaces (§18.2). The set of OWNED paths across all workers MUST be **pairwise non-overlapping**. This pairwise-disjointness IS the disjoint-scope invariant on which write-side parallel safety rests (ADR 0010, §18.5).
- **FORBIDDEN paths** — the union of every *other* worker's OWNED paths. A worker MUST NOT write outside its OWNED set; the FORBIDDEN column makes the boundary explicit and reviewable rather than implicit.

```markdown
## Worker tracker

| Worker | Source doc | Task kind | Profile | OWNED paths | FORBIDDEN paths | Hand-off (deliverable / acceptance bar) | Branch | Status | Last progress | Last verdict |
| ------ | ---------- | --------- | ------- | ----------- | --------------- | --------------------------------------- | ------ | ------ | ------------- | ------------ |
| auth-client | auth-refresh.swarm.md | implement | builder | src/auth/client/** | src/auth/server/**, migrations/** | refresh-on-expiry works; AC-014 PASS | feat/auth-client | in-progress | 2026-05-31 grafted token store | — |
| auth-server | auth-refresh.swarm.md | implement | builder | src/auth/server/** | src/auth/client/**, migrations/** | issuer rotation; AC-021 PASS | feat/auth-server | awaiting-review | 2026-05-31 endpoint done | PASS |
```

Status values MUST be drawn from: `not-started`, `in-progress`, `stalled`, `awaiting-review`, `kicked-back`, `merged`, `abandoned`. The pairwise-disjointness of OWNED paths MUST be confirmed *before* spawning any worker; if two sub-tasks need the same file they are not independent and MUST be sequenced (a `DEPENDS ON` edge / serial order), not parallelized.

### 19.3 The hand-off contract (per worker)

Each worker row carries a **hand-off contract** — the four fields below. This is what defeats "vague subtask descriptions," the field's named #1 multi-agent failure mode (MAST: specification/system-design issues (FC1) 41.77% + inter-agent misalignment 36.94% together ≈ 79% of multi-agent failures — and a recorded hand-off contract attacks both `[MAST]`), so it MUST be recorded, not left to prose.

| Hand-off field | Meaning |
|---|---|
| **Objective** | The single outcome the worker must produce. |
| **Expected deliverable** | The concrete artifact/branch the worker hands back. |
| **Acceptance bar** | The verdict the lead will review against (the obligations that MUST reach PASS, §14). |
| **Boundaries** | The OWNED/FORBIDDEN paths (§19.2) plus any preserved constraints/invariants. |

### 19.4 The `## Parent contract` section (inherited into each child task)

When the lead spawns a worker, the worker's task file MUST contain a `## Parent contract` section carrying that worker's hand-off contract verbatim. This mirrors the existing Scope In / Scope Out discipline: the child inherits its objective, deliverable, acceptance bar, and boundaries from the parent's worker tracker, so the boundary the lead recorded and the boundary the worker sees are the same text.

```markdown
## Parent contract

- Objective: implement refresh-on-expiry in the auth client.
- Expected deliverable: branch `feat/auth-client` with AC-014 implemented.
- Acceptance bar: AC-014 reaches VERDICT PASS (VERIFY BY test:cmdTest:...).
- Boundaries:
  - OWNED: `src/auth/client/**`
  - FORBIDDEN: `src/auth/server/**`, `migrations/**`
  - PRESERVE: I-003 (no unbounded retry), IF-002 (token-store interface)
```

A worker MUST NOT write outside its `## Parent contract` boundaries; doing so is the execution-tier violation caught by `SOL-O005` (§18.7, §19.7).

### 19.5 Liveness marker, STALL threshold, and STALL action

The coordination artifact MUST record liveness as data, because a worker hung `in-progress` or silently diverging is otherwise an invisible state (the kernel has no runtime to detect it).

- **LIVENESS marker** — the `Last progress` column. The lead updates it each time it checks the worker.
- **STALL threshold** — a worker whose `Last progress` has **not advanced across two consecutive checks** is `stalled`. The two-consecutive-checks threshold is Swarm design rationale (a chosen constant for the recorded liveness marker), not an empirical borrowing; it is the recorded form a future launcher's stall detector reads.
- **STALL action** — on `stalled`, the lead MUST take one recorded action: **re-plan**, **re-scope**, **escalate**, or **abandon**. The chosen action and its rationale MUST be written to a `## Decisions` section so the run is reconstructable.

```markdown
## Decisions

| When | Worker | Trigger | Action | Rationale |
| ---- | ------ | ------- | ------ | --------- |
| 2026-05-31 | auth-server | stalled (2 checks, no progress) | re-scope | endpoint coupling was underestimated; split into AC-021a/b |
```

This is a recorded contract a future launcher could automate, not a stall detector the kernel runs (§18.8).

### 19.6 The merge log and the INTENT-PRESERVED-PROOF column

The merge log records the order branches were merged, conflicts encountered, and how each was resolved — a reconstructable history. It MUST carry an **INTENT-PRESERVED-PROOF** column for every non-trivial conflict resolution.

```markdown
## Merge log

| Order | Worker | Merged into | Conflicts | Resolution | INTENT-PRESERVED-PROOF |
| ----- | ------ | ----------- | --------- | ---------- | ---------------------- |
| 1 | auth-server | main | none | fast-forward | suite green (no conflict) |
| 2 | auth-client | main | token-store init | kept both init paths, guarded by config | property check on token-store equivalence + AC-014/AC-021 re-run PASS |
```

The INTENT-PRESERVED-PROOF column MUST show that the conflict resolution kept **both** sides' intent — not merely that the suite passed. "Tests pass on the merged branch" is necessary but, where the suite may not cover the interaction, **not sufficient** (this is the §14 rule that schema-valid/green output is not verification, applied to merges). For refactor, migration, and merge conflicts the recommended equivalence oracle is a **property**, **differential**, or **metamorphic** check (a `property` or `contract` proof type, §15) on the conflicted region, BECAUSE these check behavioral equivalence directly rather than relying on a suite that may miss the interaction. A trivial (no-conflict / fast-forward) merge MAY record the green suite alone.

### 19.7 The lowering rule tie (OWNED ⊆ WRITES; violation = `SOL-O005`)

The execution tier and the source tier are tied by one normative lowering rule:

> A worker's OWNED paths MUST be a subset of the union of its assigned obligations' declared `WRITES` surfaces (lowered to file/glob projection).

A violation — a worker owning a path outside its obligations' declared write surfaces — is `SOL-O005` (§18.7), an ERROR. The fix is either to re-scope the worker (shrink OWNED) or to add the surface to the obligation's `WRITES` clause in the source spec (widen the declared write set). The lead MUST NOT silently let a worker write outside the declared surfaces, BECAUSE that is exactly the hidden write that the conflict graph cannot see and the disjoint-scope invariant cannot protect.

The relationship between the tiers, end to end:

```text
source tier (.swarm.md)         execution tier (task-orchestration.md)
  obligation.WRITES  ──project──► worker.OWNED   (subset; else SOL-O005)
  obligation.DEPENDS ON ─────────► merge order (partial order from the DAG, §18.4)
  write-surface conflict graph ──► OWNED paths pairwise disjoint (§18.2)
```

`DEPENDS ON` edges lower to the **merge-order partial order** (a branch MUST be merged after the branches it depends on); the write-surface conflict graph is the proof that the workers' OWNED paths are pairwise disjoint. Together these make the decomposition correctness — the property that makes parallel writes safe — re-derivable from the artifact alone rather than held in the lead's head.


### 19.8 Task lifecycle, worktrees, and the merge gate (contract)

This subsection specifies the **task lifecycle** an orchestration run follows, the **worktree/git etiquette** that makes the §18.5 single-writer discipline concrete on disk, and the **per-task merge gate** that is the §14 merge gate evaluated at the moment a task's branch would merge. Per Invariant 1 (NO RUNTIME, §2), nothing here is shipped: the CLI/worktree/branch/ledger automation is a **CONTRACT a future Swarm toolchain builds against**, never a runtime this repo runs. Every "the toolchain prepares…" / "the toolchain removes…" clause below is the recorded shape of an action a launcher MAY one day perform; the kernel fixes the artifacts and the gate predicate that action must respect, and nothing more. Paths and the branch/worktree/commit conventions are **design rationale**, not empirical claims, and carry no citation; the two single-writer/coordination clauses are anchored where they appear.

#### 19.8.1 The task lifecycle (four phases)

A task moves through four recorded phases. Each phase names the artifacts it reads and the artifacts it writes; the durable record at the end is the ledger entry (§23.7), the updated status artifact (§21.11), and any promoted findings — never the generated execution files, which are disposable (§20, Principle 7 of the workspace doctrine).

| Phase | What is read | What is produced | Where |
|---|---|---|---|
| **1. Creation** | the source artifact (`spec.swarm.md`, §21.2) | the lowered chain `source artifact → obligation graph → task graph → generated task frame` | task frame under `.swarm/generated/tasks/<task-slug>.md` |
| **2. Execution** | the task frame + the source spec | the toolchain prepares the task frame, a worktree, a branch, agent startup context, the verification matrix (§21.2), and the promotion queue (§23.4) | worktree at `.worktrees/swarm/<spec-slug>/<task-slug>`, branch `swarm/<spec-slug>/<task-slug>` |
| **3. Completion** | the worktree diff + proof evidence | the agent emits a **trace**; review emits a **review** with per-obligation `VERDICT` blocks (§14, §21.5) | trace under `.swarm/generated/traces/`, review under `.swarm/generated/reviews/` |
| **4. Reconciliation** | the trace + review | compact trace/review into the ledger; promote durable findings; update the status artifact; remove or archive the generated files; remove the worktree | ledger under `.swarm/ledger/` (§23.7), status under `.swarm/status/` (§21.11), worktree removed |

Creation is the lowering chain of §11 and §18.4: the `lower` pass emits the obligation graph and the two derived graphs (dependency DAG + write-surface conflict graph, §18.4); the `decompose` pass projects those onto a task graph; each task graph node materializes as one **generated task frame** under `.swarm/generated/tasks/`. The task frame is a *generated execution packet*, not a durable source-of-truth document — it MAY be recreated from the source artifact and MUST NOT be relied on as authority after the task closes.

Execution is the toolchain's preparation step. The toolchain prepares exactly six things and dispatches nothing the kernel owns: the task frame, the worktree, the branch, the agent startup context (the `## Parent contract` of §19.4 carried verbatim into the child task), the verification matrix the task must satisfy, and the promotion queue the task must drain before close (§23.4). Dispatching the agent that fills the worktree is a launcher concern (§18.8), out of the kernel.

Completion is the trace/review pair. The agent emits its implementation claims as a **trace** (`.swarm/generated/traces/`, §21.4); the `review` pass judges those claims against the source spec, the diff, and the proof evidence — never against the trace's self-report (§14, §32) — and emits a **review** (`.swarm/generated/reviews/`, §21.5) carrying one `VERDICT` per required `VERIFY BY` binding (§15.7).

Reconciliation is the only phase that produces durable record. After the merge gate (§19.8.3) passes and the branch merges — or the task is abandoned — the toolchain MUST: (1) compact the trace and review into a ledger entry (§23.7) preserving covered obligations, changed surfaces, proof, verdicts, and promotion results; (2) drain the promotion queue, promoting durable findings to their typed homes (§23.4.2); (3) update the status artifact (§21.11) so observed satisfaction reflects the merge; (4) remove or archive the generated task/trace/review files; and (5) remove the worktree (§19.8.2). A task MUST NOT be treated as closed while any promotion-queue item is still `pending` (§23.4).

#### 19.8.2 Worktree and git etiquette (the contract)

The worktree convention makes the §18.5 safe-parallelism predicate concrete on disk. The mapping is exact and load-bearing:

> **Every worktree maps to exactly one task; every task maps to its assigned obligations; every worker writes only its OWNED surfaces.**

This is the §18.5 single-writer / write-disjoint discipline made physical: one writer per surface, and the worktrees are the physical enforcement of the §19.2 OWNED-paths pairwise-disjointness invariant — two tasks that would write the same surface are not write-disjoint, hence not parallel-safe, hence MUST NOT be given concurrent worktrees but sequenced via a `DEPENDS ON` edge (§18.4). The doctrine that the **write side stays single-threaded** and that conflicting actions carry conflicting decisions is the empirical anchor for this rule `[COGNITION]` (writes single-threaded; share full context, not isolated messages) `[ANTHROPIC-MA]` (LLM agents are not yet reliable at real-time coordination; the orchestrator-worker split), and it is fixed as a design decision by ADR 0010.

Recommended conventions (design rationale, not normative grammar):

| Item | Recommended form |
|---|---|
| Branch | `swarm/<spec-slug>/<task-slug>` |
| Worktree path | `.worktrees/swarm/<spec-slug>/<task-slug>` |

A structured **commit-message pattern** records, in the commit itself, the same source→execution tie the coordination artifact records (§19.7), so the run is reconstructable from git history alone:

```text
swarm: implement <task-slug> <ID-list>

Spec:      .swarm/sources/specs/<context>/<slug>.swarm.md
Task:      .swarm/generated/tasks/<task-slug>.md
Covers:    AC-001, AC-002          # the obligations this commit satisfies
Preserves: C-001, I-001            # the constraints/invariants it must not break
Trace:     .swarm/generated/traces/<task-slug>.trace.md
Review:    .swarm/generated/reviews/<task-slug>.review.md
```

`Covers` MUST list only obligations assigned to the task; `Preserves` lists the constraints/invariants the §19.4 `## Parent contract` named as boundaries. The `Trace` and `Review` lines point at the artifacts the merge gate (§19.8.3) reads. A worktree MUST NOT be reused across tasks, and on completion the toolchain removes the worktree (reconciliation step 5, §19.8.1) so a stale worktree never masquerades as a live writer.

> **Scope of the worktree guarantee.** A worktree enforces **file/path** disjointness (the §18.2 OWNED-paths invariant), not **runtime-resource** disjointness: two write-disjoint parallel tasks can still collide on shared ports, dev databases, caches, secrets, or test state. Runtime-resource isolation is out of scope for the kernel's write-surface model and is a launcher / runtime-isolation concern (§18.8).

#### 19.8.3 The per-task merge gate (the §14 gate, evaluated per task)

The task merge gate is **not a second gate**. It is the §14.4 merge gate — the single normative predicate "every required obligation's required `VERIFY BY` bindings are all `PASS`/`WAIVED`" — evaluated at the point a task's branch would merge into its base. The kernel defines one merge gate; this subsection only fixes the scope (the task's assigned obligations) and the orchestration-specific blocking conditions layered on top of it.

A task **MUST NOT merge** if any of the following holds:

| # | Blocking condition | Anchor |
|---|---|---|
| 1 | The **trace is missing** or the **review is missing** for the task. | §19.8.1 phase 3; §32 (a verdict justified only by the implementer's summary fails) |
| 2 | Any **assigned obligation's verdict is `FAIL` or `UNVERIFIED`** (including a required binding with no verdict — `SOL-V008` — and a `PASS (STALE)`, which is treated as not-`PASS`, §14.4). | §14.4 |
| 3 | A **blocking `QUESTION` affects assigned work** — an unresolved `[blocking]` `QUESTION` (§6.5) whose `AFFECTS` set reaches an obligation the task covers. | §6.5, §11.1.2 (R-BLOCKING-Q) |
| 4 | The **promotion queue is unhandled** — any promotion-queue item for the task is still `pending`. | §23.4 |
| 5 | A **write-surface conflict remains** — a worker's OWNED path overlaps another's (`SOL-O001`), or a worker owns a path outside its obligations' declared `WRITES` (`SOL-O005`, §19.7), or an unmerged dependency in the `DEPENDS ON` merge-order remains. | §18.5, §18.7, §19.7 |
| 6 | The **base branch is dirty or out of policy** — uncommitted changes on the base, or the base violates a branch-protection / merge policy. | git etiquette (design rationale) |

Conditions 1–4 are the §14 merge gate read at task scope — a missing trace/review is a verification gap, a `FAIL`/`UNVERIFIED` verdict is a failed gate, a blocking `QUESTION` is an unresolved precondition, and an unhandled promotion queue blocks task close (§23.4). Condition 5 is the orchestration overlay: the per-task gate additionally requires that the §18 write-disjoint invariant still holds at merge time, because two tasks that have silently drifted into the same surface produce exactly the hard-to-review merge corruption that `SOL-O001` was raised to ERROR to prevent (§18.7). When all conditions clear, the branch merges, its resolution is recorded in the §19.6 merge log (with an INTENT-PRESERVED-PROOF for every non-trivial conflict), and the task advances to reconciliation (§19.8.1 phase 4).

This is a recorded contract a future launcher (or eventual checker, §32) reads and could one day enforce — it is **not** a gate the kernel runs. Like every gate disposition in Swarm, it is enforced by a deterministic check OUTSIDE the model where one exists, and recorded by a human or agent today (§14.4, §18.1).
