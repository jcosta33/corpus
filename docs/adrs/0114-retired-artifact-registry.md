---
type: adr
id: adr-0114
status: proposed
created: 2026-06-27
updated: 2026-06-27
---

# ADR-0114 — A retired/relocated-artifact registry + cross-repo reference linter

## Context

The re-architecture this program shipped — 8→6 agents, 7→11 skills, the mcp 0.2.0 bump, and the
[ADR-0112](./0112-two-tier-skills.md) catalog/kit split — was correct **in file structure**: the moves
landed, the directories match the decision. The Phase 3 family sweep (workflow `wf9rvvwys`,
AUDIT-family) found the failure is one layer up — the **doc/reference layer drifted**, and **every**
recurring issue in that sweep mapped to a missing automated gate, not to a bad edit.

Two concrete drifts the sweep caught, both about cross-repo facts restated by hand instead of resolved
against one source:

- **Location disagreement.** [ADR-0112](./0112-two-tier-skills.md) decided `write-*` live in the
  **kit** (`.agents/skills/`), not the catalog. The sweep found **three repos disagreeing** on where
  `write-documentation` lives — each repo's prose stated the location independently, so each could drift
  independently, and did.
- **Retired artifacts named as active.** The re-architecture retired a set of agents and tools —
  `corpus-explorer`, `persona-skeptic`, `corpus-evidence-checker`, `corpus_scan_task`,
  `corpus_validate_review_packet`. The sweep found **four sites** still naming retired artifacts as if
  active. The citation/product-pollution and count-drift classes had **recurred** in corpus-mcp and the
  kit because this program's manual strip-and-rule pass covered only the catalog and the agents —
  humans caught the rest in review, not a gate. A fact restated independently in N places drifts in N
  places; nothing greps for it.

This is the regime [ADR-0043](./0043-checkable-documents.md) names: the reliable lever is a
**deterministic external check** over the reference layer, not more prose discipline. And it is bound by
[ADR-0063](./0063-honesty-framework-and-tooling-boundary.md): until a checker ships, this is a
convention held by discipline and review — naming it "enforced" would be the exact trust-killer 0063
forbids.

## Decision

**Proposed (design intent — this ADR builds nothing).** Record the direction for a single canonical
registry plus a shared cross-repo linter, so a later pass knows *what* to build and *what not* to
re-restate by hand.

1. **One canonical registry, under corpus `docs/`.** A single source-of-truth file lists **every** agent,
   skill, and MCP tool across the family, each with a **status**:
   - `active`
   - `redirect-stub` (the name resolves but only points elsewhere)
   - `retired` (gone; names its replacement, or none)
   - `relocated→<target>` (moved; names the new home, e.g. `write-documentation: relocated→kit`)

   The registry is the **only** place these cross-repo facts are stated; every product/reference doc in
   every family repo **links** to it rather than restating the location or the active/retired status —
   the single-sourcing rule applied to the artifact inventory.

2. **A shared linter, run in each repo's CI.** One linter (shared spec, vendored or installed per repo)
   greps each repo's **product and reference docs** for any registry name whose status is **not
   `active`**, and **fails the run**, pointing the author at the replacement the registry names
   (`corpus-explorer → corpus-…`, `write-documentation → kit`). This is the toolable path: the gate the
   sweep found missing, that would have caught all four retired-name sites and the three location
   disagreements mechanically instead of by reviewer attention.

3. **Honesty level.** **proposed — not in force.** No registry file and no linter are created by this
   ADR. Until the registry exists and the linter ships in CI, the cross-repo facts remain held by
   **convention + review** ([ADR-0063](./0063-honesty-framework-and-tooling-boundary.md)); this ADR may
   not be cited as if a gate exists. Promote to `accepted` only when the registry lands and the linter
   runs.

_Level: proposed (design intent). The CI linter is the future toolable path — **not yet shipped**._

## Consequences

- **Cost — building it.** Two new artifacts to create and maintain: the registry (must be kept current
  on every agent/skill/tool change — itself a discipline until something reconciles it) and a linter
  shared across repos (a per-repo CI wiring cost, and a cross-repo versioning question — whose copy is
  authoritative, how each repo pins it).
- **Cost — false friction.** A grep-for-names linter will flag legitimate mentions: an ADR, a changelog,
  or a migration note that *names a retired artifact on purpose*. The design must carve an allowlist
  (ADRs are immutable history and legitimately name retired things; the registry itself names them) or
  the gate becomes noise an author learns to suppress — which is worse than no gate.
- **Benefit.** The two drift classes the sweep found recurring — retired-name pollution and
  location/count drift across repos — become **mechanically catchable** at the boundary they actually
  cross, instead of relying on a human noticing one stale name among many. A fact stated once, linked
  everywhere, drifts in one place.
- **Scope.** This is reference-layer integrity, in the spirit of
  [ADR-0043](./0043-checkable-documents.md)'s deterministic-resolving-check direction (the name either
  resolves to an `active` registry entry, or it doesn't). It does **not** touch the artifact formats, the
  core loop, the verdict model, or the [ADR-0112](./0112-two-tier-skills.md) kit/catalog partition — it
  is the gate that keeps the prose layer honest *about* those decisions.

## Affected obligations / constraints

- **Refines (by reference, not edit — Nygard immutability):** [ADR-0112](./0112-two-tier-skills.md)
  (the kit/catalog split whose location facts this would keep from drifting). **Grounded by:**
  [ADR-0043](./0043-checkable-documents.md) (deterministic external check over the reference layer) and
  [ADR-0063](./0063-honesty-framework-and-tooling-boundary.md) (the honesty level — this is a convention
  with a named-but-unshipped toolable path).
- **Does NOT change:** the artifact formats, the core loop, the verdict model, the checks contract, or
  the [ADR-0112](./0112-two-tier-skills.md) partition. Accepted ADRs are refined here by reference, never
  edited in place.
- **Builds nothing.** No registry file, no linter, no CI change ships with this ADR — design intent only,
  like [ADR-0043](./0043-checkable-documents.md). Promote to `accepted` only if and when the registry and
  the linter land.
