---
type: adr
id: adr-0115
status: accepted
created: 2026-06-27
updated: 2026-06-27
---

# ADR-0115 — Synced workspace catalogs must be links or freshness-gated (no orphaned copies)

## Context

The Phase-3 family sweep (workflow `wf9rvvwys`) confirmed the re-architecture this program shipped —
8→6 agents, 7→11 skills, mcp `0.2.0`, the [ADR-0112](./0112-two-tier-skills.md) catalog/kit split —
was correct **in file structure**, but the doc/reference layer drifted because every recurring issue
mapped to a missing automated gate, not to a bad design. One drift class was a **stale catalog copy**.

The governed skills catalog (corpus-skills) is the single source for the universal, framework-free
skills. The workspace keeps its own copy at `corpus-works/.agents/skills`, which is then symlinked into
the live `.claude/skills` the agents actually load. That copy is a hand-synced **orphan**: nothing tied
it back to upstream. The sweep found it **2+ days and one re-baseline stale** — it was **missing skills
that had been added to the catalog** and **still hosting a skill the catalog had retired**. Because the
live `.claude/skills` symlinks *into* this copy, agents in the workspace were loading a skill set that
silently diverged from the governed source. A human noticed on the sweep; no gate did.

This is the same failure [ADR-0016](./0016-skills-are-self-contained.md) and
[ADR-0017](./0017-no-always-load-skills.md) guard against at the *skill-body* level — the Reference
Illusion and hidden mandatory content — reappearing at the *catalog* level: a whole governed set copied
into a workspace and left to rot. A copy that can drift will drift; the only question is whether anything
catches it.

## Decision

**A governed catalog synced into a workspace MUST NOT be an orphaned copy.** Concretely, where a
workspace consumes a catalog whose single source lives elsewhere (corpus-skills → `corpus-works/.agents/skills`),
exactly one of the two holds:

1. **Preferred — it is a *link* to its single source.** A symlink or git submodule pointing at the
   governed catalog, so there is no second copy to drift. The live `.claude/skills` then links through to
   the one source, and "add/retire a skill upstream" propagates with no manual sync step.

2. **Where a physical copy is genuinely unavoidable — it carries a freshness check.** A CI job that
   diffs the copy against upstream and **fails on any divergence** (a skill present upstream but missing
   in the copy, a skill present in the copy but retired upstream, or a content mismatch). The copy is
   then *gated*, not orphaned: it cannot silently fall behind the source.

No third option: a governed catalog is never copied into a workspace without one of link or
freshness-gate. This is the catalog-scoped form of the no-dead-reference and no-hidden-content rules of
[ADR-0016](./0016-skills-are-self-contained.md) / [ADR-0017](./0017-no-always-load-skills.md), and it
keeps the consumed set faithful to the minimal, governed source the kit tiering assumes
([ADR-0064](./0064-minimal-kit-tiering.md)).

**Honesty level (per [ADR-0063](./0063-honesty-framework-and-tooling-boundary.md)).** The *principle*
is **in force now** — accepted as a **convention** held by discipline and review: when this workspace's
synced catalog is touched, the reviewer checks it is a link or matches upstream, and an orphaned copy is
a finding. The **freshness CHECK is the toolable path and is NOT yet shipped** — there is no CI job today
that diffs the copy against upstream; nothing automated catches the drift, which is exactly why the sweep
caught it by hand. Relinking the existing `corpus-works/.agents/skills` copy to its source (option 1), or
landing the freshness-diff CI (option 2), is **follow-up work**, tracked in corpus-works. Until one of
those ships, this ADR's force is convention-plus-review, and this sentence is the honest statement of
that boundary.

_Level: convention now; the freshness diff is toolable (not yet shipped)._

## Consequences

- **Positive.** The governed catalog has one source of truth again; "the workspace loads a different
  skill set than the catalog defines" stops being possible silently. Once option 1 lands, adding or
  retiring a skill upstream needs zero workspace sync; once option 2 lands instead, divergence turns a CI
  job red instead of waiting for a human sweep.
- **Cost — discipline until the gate ships.** Between now and the relink/CI, the rule rests on reviewer
  attention; an orphaned copy *can* still drift in that window. This ADR does not pretend otherwise — it
  records the convention and names the gate that would make it real, per
  [ADR-0063](./0063-honesty-framework-and-tooling-boundary.md).
- **Cost — link mechanics.** A symlink or submodule is one more piece of repo plumbing (clone/checkout
  must hydrate it; tooling that walks the tree must follow links). The freshness-check alternative trades
  that plumbing for a CI job to build and maintain.
- **Scope.** This governs *governed catalogs synced into a workspace* (the corpus-skills →
  `corpus-works` case the sweep found). It does not touch how an external adopter vendors a subset of the
  catalog into their own repo — that remains a deliberate copy under the self-containment rule of
  [ADR-0016](./0016-skills-are-self-contained.md).

## Affected obligations / constraints

- **Refines (by reference, not edit — Nygard immutability):** [ADR-0016](./0016-skills-are-self-contained.md)
  (no-dead-reference, raised from skill body to whole catalog), [ADR-0017](./0017-no-always-load-skills.md)
  (no hidden/silently-diverging loaded content), [ADR-0064](./0064-minimal-kit-tiering.md) (the consumed
  set stays faithful to the governed source). **Relates to** [ADR-0112](./0112-two-tier-skills.md) (the
  catalog whose copy drifted) and [ADR-0063](./0063-honesty-framework-and-tooling-boundary.md) (the level
  this ADR is held at).
- **Does NOT change:** the catalog/kit partition, any skill format, or the artifact set. The freshness
  check is named here as the toolable enforcement path; it is **not yet built**.
