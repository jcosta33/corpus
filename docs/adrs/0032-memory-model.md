---
type: adr
id: 0032-memory-model
status: accepted
created: 2026-06-02
updated: 2026-06-02
supersedes:
superseded_by:
---

# ADR-0032: The memory model

## Context

A discovery made during one task must become reliably available to a future task without bloating the always-loaded bootloader. In the pre-kernel model the only durable carriers of learned facts were chat transcripts and inline prose, which §23 rejects as memory: they are unindexed, unprovenanced, and unfalsifiable. Treating every span of past text as equally recallable also has a governance cost — a fact with no recorded source, no scope, and no staleness signal cannot be trusted, contradicted, or expired, so it silently rots into the recall surface and competes against genuine durable knowledge. The pressure is therefore twofold: keep recall cheap (a map an agent reads first) while making every durable fact earn its place with a recorded provenance that a future conformant tool can falsify and stale-check.

## Decision

Memory is **two-tier and provenance-anchored** (§23, the authoritative specification). Tier-1 is a compact map an agent reads first — recall is a map to pull from, not a dump to load [[LOSTMID]](../research/sources.md#LOSTMID) — `memory/INDEX.md` (links plus a mandatory `Load when` condition; an entry that cannot name when it matters MUST be removed) and `memory/glossary.md` (one word, one meaning). Tier-2 is the immutable evidence store the map points at (`finding.md`, `adr.md`, `audit.md`, `bug-report.md`, `memory/patterns/*.md`). A durable discovery becomes memory only through **promotion**: it is written to exactly one canonical target by the kind of discovery it is (§23.4.2), and on reaching `accepted`/`promoted` it MUST carry its full mandatory provenance — claim, evidence, origin obligations/traces, source pass+profile, reviewer/tool, timestamp, content hash, confidence, and an `applies-when` / `does-not-apply-when` scope envelope (§23.3). Task-local execution detail is never promoted: it is dispositioned `rejected` with reason "execution-local" and dies with the task. The contract requires that a task MUST NOT close while any promotion item is `pending`, and that no promotion may *weaken* an obligation — `memory` is the Axis-B floor (§22.4), so such a promotion is a `SOL-M004` authority-conflict routed to amendment.

## Alternatives considered

| Alternative | Why rejected |
| ------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------- |
| Chat transcripts / inline prose as memory | Unindexed, unprovenanced, unfalsifiable — "chat, not memory"; cannot be staled, contradicted, or scoped (§23, §23.3). |
| Flat single-tier store (no compact map) | Loses the cheap-to-read recall surface; the bootloader bloats and the §24 loss budget / §31 density cap are blown (§23.1). |
| Promote a discovery directly to a reusable pattern | A pattern is a distillation of *multiple* findings; a lone finding promoted as a pattern has no corroboration (§23.2). |
| Inline a universal workflow rule into `AGENTS.md` | Procedures belong in pass guides; the bootloader holds facts. G9 routes them to a guide edit plus a one-line pointer (§23.4.1). |
| Promote every task-local detail "just in case" | Execution detail carries no durable claim; promoting it re-creates the unindexed accumulation memory exists to prevent (§23.4.2). |
| Ship embedding retrieval / auto-eviction now | Each needs a runtime Corpus does not have; explicitly deferred post-v0.1 (§23.6). |

## Consequences

### Positive

- Recall stays cheap: an agent reads a compact, load-when-gated map first and pulls Tier-2 bodies only when a condition fires.
- Every durable fact is falsifiable and stale-checkable, because provenance (content hash + origin traces) is mandatory at `accepted`/`promoted`.
- The mandatory-before-close gate admits no silent drops: even "keep in the task only" is a recorded `rejected` disposition with a reason.

### Negative

- Promotion is authoring work — provenance fields must be filled by hand today; absent a runtime, nothing recomputes the hash or flips a finding `stale` automatically (§23.5, §23.6).
- A discovery with two faces (e.g. both a decision and a pattern) lands as two queue items at two targets, which is more bookkeeping than a single write.

### Neutral / tradeoffs

- The INDEX is a map, not the territory: it MUST NOT duplicate Tier-2 bodies, so a divergence between an INDEX summary line and its linked artifact is treated only as advisory drift.
- The provenance fields, promotion statuses, and `Load when` discipline ship in v0.1; the comparator, decay, and dense retrieval that automate over them are deferred (§23.6).

## Status

Accepted (v0.1).

## Affected obligations / constraints

- Adds: the two-tier memory contract — Tier-1 `memory/INDEX.md` (load-when discipline) + `memory/glossary.md`; Tier-2 immutable evidence store + `memory/patterns/*.md`.
- Adds: mandatory provenance on every `accepted`/`promoted` finding (§23.3) and the discovery-to-target promotion routing (§23.4.2).
- Modifies: task-closure — a task MUST NOT close while any promotion item is `pending`; task-local chatter is dispositioned `rejected` (execution-local), never promoted.

> **Ledger note (2026-06-11):** refined by ADR-0067 (memory tiering).
