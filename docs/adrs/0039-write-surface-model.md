---
type: adr
id: 0039-write-surface-model
status: accepted
created: 2026-06-02
updated: 2026-06-02
supersedes: [0025]
superseded_by:
---

# ADR-0039: The write-surface model

## Context

Pre-kernel Corpus recorded safe parallelism as a standalone *coordination object*. ADR [0025](./0025-orchestration-coordination-artifact.md) gave `task-orchestration.md`'s worker tracker hand-maintained **owned / forbidden paths**, a hand-off contract, a liveness marker, and an intent-preserved merge column — fields a lead authored and kept correct by hand. That made the disjoint-scope invariant *recorded*, but it left owned/forbidden paths as a second source of truth with no mechanical tie back to what the spec actually declares each obligation may write. The lead could own a path no obligation declared, two workers' owned sets could silently overlap, and nothing connected the coordination object to the obligation graph. The orchestration model needed the owned/forbidden boundary to be *derived from the spec*, not asserted alongside it (§18.1, §19).

## Decision

Safe parallelism is expressed as a **write-surface model**: the per-obligation `WRITES`/`READS`/`DEPENDS ON`/`AFFECTS` scope declarations (§18.2) are the single source of scope truth, and the `lower`/`decompose` passes **lower** them into the coordination artifact rather than the lead maintaining a separate object. The `lower` pass MUST emit exactly two derived graphs — the dependency DAG and the write-surface conflict graph (§18.4) — and one canonical safe-parallelism predicate decides co-scheduling over them (§18.5). A worker's OWNED paths are then the file/glob *projection* of its assigned obligations' `WRITES` surfaces, tied by one normative lowering rule (`OWNED ⊆ WRITES`, else `SOL-O005`); FORBIDDEN paths are the lowered union of every other worker's OWNED set (§19.2, §19.7). The coordination artifact still records hand-off, liveness, and merge-intent (the ADR [0025](./0025-orchestration-coordination-artifact.md) contract is preserved), but the disjoint-scope boundary it carries is *lowered*, not authored. The full specification is §18 and §19.

This is recorded contract, not runtime: the passes lower the graphs and the boundary a future launcher would consume, and the predicate is a contract a conformant tool MUST compute identically from the same spec (§18.5.1, §18.8).

## Alternatives considered

| Alternative | Why rejected |
| --- | --- |
| Keep owned/forbidden paths as a hand-maintained coordination object (ADR [0025](./0025-orchestration-coordination-artifact.md) as-is) | A second source of scope truth with no tie to declared `WRITES`; a worker could own a path no obligation declares and the conflict graph could not see it (§19.7 rationale for `SOL-O005`). |
| A `locks` primitive on the surface or IR layer | No `locks` primitive exists: a lock group *is* a named SURFACE, so lock-set analysis reduces to write-set analysis at surface granularity — a separate primitive would duplicate it (§18.3). |
| Multiple or relaxed parallelism predicates | Exactly one canonical predicate is permitted in v0.1 so two implementations derive the identical conflict graph; a relaxed predicate reintroduces the silent merge corruption `SOL-O001` blocks (§18.5, §18.5.1). |
| A live scheduler that batches and stall-detects against the graphs | Violates Principle 1 (NO RUNTIME); the kernel emits the graphs and records the liveness marker + threshold + action, never operating them (§18.8, §19.5). |
| Fold `AFFECTS` into `writes`/`depends_on` | `AFFECTS` is a soft advisory edge a reviewer reads, not a hard conflict; folding it would over-serialize honest work (§18.2, §18.6). |

## Consequences

### Positive

- Decomposition correctness is *re-derivable from the spec alone*: OWNED/FORBIDDEN are lowered from declared `WRITES`, so the disjoint-scope invariant is mechanically checkable (`SOL-O005`) rather than lead-attested.
- A single canonical predicate over two lowered graphs means any two conformant tools agree on which packets are parallel-safe (§18.5.1).
- The unsafe default is the safe default: unscoped and `shared`/`integration` surfaces serialize, so a missing or hidden write surface cannot be silently co-scheduled (§18.5).

### Negative

- Authors must declare scope on obligations for parallelism to be unlocked; an obligation with no `WRITES` serializes against everything, which is correct but costs concurrency until scope is added (§18.5).
- The lowering tie is only as sound as the declared surfaces: a wrong `WRITES` declaration lowers to a wrong OWNED set, and absent a checker the `SOL-O005` subset check is recorded judgement, not enforcement (§18.1, §19.7).

### Neutral / tradeoffs

- The write-surface model guarantees file/path disjointness only; runtime-resource collisions (ports, dev DBs, caches) are explicitly out of scope and a launcher concern (§19.8.2).
- The ADR [0025](./0025-orchestration-coordination-artifact.md) hand-off, liveness, and merge-intent fields are unchanged in substance — only the owned/forbidden boundary is recast from authored to lowered.

## Status

Accepted (v0.1).

Supersedes ADR-0025 (recasts the coordination artifact's hand-maintained owned/forbidden paths as a write-surface lowered by the `lower`/`decompose` passes from declared `WRITES` surfaces, tied by `OWNED ⊆ WRITES`/`SOL-O005`; the hand-off, liveness, and merge-intent contract of 0025 is preserved).

## Affected obligations / constraints

- Adds: the write-surface model as the single expression of safe parallelism — two lowered graphs (dependency DAG + write-surface conflict graph, §18.4), the one canonical safe-parallelism predicate (§18.5), and the `OWNED ⊆ WRITES` lowering tie enforced by `SOL-O005` (§18.7, §19.7).
- Modifies: `task-orchestration.md`'s OWNED/FORBIDDEN paths are now *lowered* from declared `WRITES` rather than hand-maintained (§19.2); the per-task merge gate additionally requires the write-disjoint invariant still holds at merge time (§19.8.3, condition 5).
- Supersedes: ADR-0025's treatment of owned/forbidden paths as a standalone coordination object — they are now a lowered write-surface; the rest of the 0025 contract (hand-off, liveness, merge-intent) is retained.
