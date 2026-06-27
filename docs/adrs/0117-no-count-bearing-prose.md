---
type: adr
id: adr-0117
status: accepted
created: 2026-06-27
updated: 2026-06-27
---

# ADR-0117 — No count-bearing ranges in bootstrap/reference prose — link-only pointers

## Context

The Phase 3 family sweep (workflow `wf9rvvwys`) confirmed the re-architecture this program shipped
was correct in **file structure** — 8→6 agents, 7→11 skills, corpus-mcp at 0.2.0, the
[ADR-0112](./0112-two-tier-skills.md) catalog/kit split — but the **doc/reference layer drifted**, and
the drift clustered where prose **hardcodes a count or a range that some other file is the real owner
of**. Two concrete instances:

- A bootstrap `AGENTS.md` asserted the "latest" ADR range as **0001–0108** — false the moment
  [ADR-0112](./0112-two-tier-skills.md) landed. The range was a frozen copy of a number the ADR ledger
  (`docs/adrs/README.md`) owns; the ledger advanced and the copy did not.
- A `CHANGELOG` carried a **stale skill count** — a number the skill set itself owns, written into
  prose and never re-synced when the catalog/kit split changed the count.

Neither was caught by a gate; a human caught both in the sweep. This is the single-sourcing principle
(CLAUDE.md "Single-sourcing"; the "No counts ceremony" rule that already confines closed-set
cardinalities to two reconciliation points) being violated in the *bootstrap/reference prose layer* —
the one layer the existing manual strip+rule of this program did **not** cover, because that pass
scoped to the catalog + agents, not the reference files. A count copied into prose is a duplicated
source of truth, and a duplicated source of truth drifts silently the next time its owner changes.

## Decision

**Bootstrap and reference prose MUST NOT hardcode a count-bearing range or cardinality that duplicates
an authoritative ledger.** Specifically:

1. **No frozen ADR ranges.** Prose that points at the decision log uses a **stable link-only pointer**
   — `docs/adrs/README.md` — the complete immutable ledger — never a number range
   (no "ADRs 0001–0108", no "latest: 0112"). The ledger is the only thing that knows its own extent.

2. **No hardcoded set counts.** A skill count, agent count, pass count, or any closed-set cardinality
   is **not** written into bootstrap/reference prose. Either point at the source (a link, a manifest)
   or **generate the number from the source at build time** so it cannot fall out of sync. This is a
   corollary of the existing "No counts ceremony" confinement, extended to the bootstrap/reference
   surface the sweep found uncovered.

3. **The rule is a single-sourcing corollary, not a new construct.** It adds no format and no new
   vocabulary; it names *where* single-sourcing was being broken and forbids the specific shape
   (count-in-prose) that breaks it.

**Honesty level: convention — in force now by discipline + review.** This program already applied it:
the bootstrap `AGENTS.md` is now **link-only** (the false 0001–0108 range is gone, replaced by the
ledger pointer). Nothing in this repository *enforces* the rule today. The **toolable** path — a CI
lint that flags an ADR-range literal or a bare set-count in a tracked doc and fails if it disagrees
with the owning ledger — is the natural enforcement and is **not yet shipped**; until it ships, this
is a review checklist item, per [ADR-0063](./0063-honesty-framework-and-tooling-boundary.md). No
prose may describe this rule as "enforced", "guaranteed", or "blocking".

## Consequences

- **Costs a small expressiveness loss.** A reader skimming bootstrap prose no longer sees "we have N
  skills" or "ADRs go up to X" inline — they follow one link to the owning ledger/manifest. That is the
  deliberate trade: a pointer that is always right beats a number that is sometimes right.
- **The drift class the sweep found goes away at the source for the convention-following case** — once
  prose links instead of copying, the ledger advancing can no longer falsify the prose. The catch is
  that, at *convention* level, this holds only for prose written under the discipline; a number copied
  in by a future author is still possible until the lint ships. The recurrence the sweep documented
  (the class survived in corpus-mcp + the kit because the manual pass covered only catalog+agents) is
  exactly the residual: **humans catch it, not gates**, until the toolable lint lands.
- **Build-time generation (option 2) shifts a maintenance burden into the build** — a count that must
  appear (e.g. a generated summary) now needs a generator reading the source, not a hand-edited
  literal. Acceptable: a build step that derives the number cannot drift; a hand-edited literal does.
- **Affected obligations.** Refines [ADR-0108](./0108-living-specs.md) (silent staleness is the dominant
  failure; this closes one silent-staleness vector in the bootstrap/reference layer) and reaffirms the
  CLAUDE.md single-sourcing + "No counts ceremony" rules by extending their reach to bootstrap/reference
  prose. Honesty governed by [ADR-0063](./0063-honesty-framework-and-tooling-boundary.md). These are
  **new** ADRs that refine prior ones by reference only — no accepted ADR is edited in place (Nygard
  immutability).
- **Does NOT change** any artifact format, the checks contract (`checks.yaml`), the two
  count-reconciliation points (`checks/README.md`, the cheatsheet appendix), or the kit/catalog split.
