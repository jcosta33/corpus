---
type: adr
id: 0051-complete-the-spec-repo-pivot
status: accepted
created: 2026-06-07
updated: 2026-06-07
supersedes:
superseded_by:
---

# ADR-0051: Complete the spec-repo pivot — one authoring kit, specs top-level, code skills as reference

## Context

[ADR-0050](./0050-swarm-is-a-spec-repo-discipline.md) established that Corpus is a spec-repo discipline, but
the `starter-kit/` still carried the old shape:

- ~448 KB of **not-installed** content lived inside the kit — the `language/` (88 KB) and `passes/` (196 KB)
  **derived twins** and the `conformance/` golden corpus (164 KB). A thing you hand an adopter should contain
  only what the adopter uses.
- The kit's skills mixed **authoring** (`write-spec`, `pass-lint-spec`, `persona-architect`…) with
  **code-implementation** (`write-feature`, `fix-flaky-test`, `persona-bug-hunter`, `persona-builder`…). A
  docs/spec repo has no use for the latter — the kit was effectively two kits crammed together.
- Specs sat under `.agents/specs/`, conflating the **product** (intent) with **agent tooling**.

This completes the pivot to the owner's restated principles — **no bloat, straightforward, simple, minimal**.

## Decision

1. **Specs and intent artifacts live top-level, outside `.agents/`.** In an adopted spec repo, `*.md`
   specs live in `specs/`, and other intent docs (`adrs/`, `audits/`, `findings/`, PRDs, RFCs) are top-level
   content too. **`.agents/` holds only tooling** — `skills/`, `reference/`, `templates/`, `memory/`. Specs
   are the product, not agent tooling. (This refines [ADR-0050](./0050-swarm-is-a-spec-repo-discipline.md),
   which had put specs under `.agents/specs/`.)
2. **The starter kit is ONE kit — the spec/docs-repo authoring kit.** It ships the **20 authoring skills**
   (6 source-author guides, 6 analysis pass guides, 2 fragments, 6 authoring personas) + the `reference/`
   cards + the source-doc/`review` templates + the bootloader. Nothing for code work.
3. **The 17 code-implementation skills are framework reference, not kit content.** The 9 per-kind implement
   guides, the 7 code personas, and `implement-and-verify` move to **`docs/library/code-skills/`**. A code
   repo's *only* optional Corpus skill is **`implement-and-verify`**, copied as a **single standalone** — never
   a bundled second kit. The code repo stays pristine; the self-legible spec is its interface. (The
   13-persona closed set is unchanged — 6 authoring + 7 code = 13, split across two homes.)
4. **The kit ships no `language/`, `passes/`, or `conformance/`.** The `language/`+`passes/` **twins are
   deleted**: `docs/language/` and `docs/passes/` become the **sole canonical home**, which **retires the
   twin-maintenance discipline of [ADR-0044](./0044-kernel-is-derived-and-self-contained.md)** — a
   simplification (no more eyeball-diffing two copies). The conformance golden corpus moves to a producer-side
   top-level **`conformance/`** (test data for a future checker, never part of the kit).

This **refines** [0050](./0050-swarm-is-a-spec-repo-discipline.md) (specs top-level),
[0048](./0048-installed-payload-is-the-runtime-surface.md) (kit = authoring skills + reference + templates),
and [0042](./0042-skill-carrier-and-standalone-conditioning.md) (the catalogue splits 20 shipped / 17
reference); it **retires the twin mechanism of** [0044](./0044-kernel-is-derived-and-self-contained.md)
(`docs/` is now the sole home; the kit ships neither twin). It changes **no** closed set, the SOL grammar,
the nine passes, or the reconciliation design.

## Alternatives considered

| Alternative | Why rejected |
| --- | --- |
| Keep specs under `.agents/specs/` (0050 as-is) | Buries the product (intent) inside an agent-tooling dir. Specs are content; for a docs repo they deserve a top-level home. |
| Keep the code skills in the kit (or as a second bundled kit) | A docs/spec repo never runs `implement` — shipping `persona-bug-hunter` et al. is dead weight, and "two kits in one" is exactly the bloat being removed. |
| Keep the language/passes twins in the kit (self-contained offline) | The kit no longer ships the manuals at all (skills are self-contained + name the `reference/` cards, ADR-0047), so the twins resolve nothing — they were pure maintenance cost. |
| Drop the code skills entirely | They carry real implement-pass discipline (migration waves, measure-first perf, the stances). Keep them as `docs/library/` reference rather than deleting — available to anyone, shipped to no one. |

## Consequences

- **Positive:** the starter kit shrinks to exactly what a spec repo uses (≈20 skills + reference + templates +
  bootloader); specs read as the product (top-level); the docs↔kernel twin-diff chore is gone; a code repo's
  footprint is a self-legible spec + at most one optional skill.
- **Negative:** a broad doc sweep (ADOPTING, workspace, README, PRINCIPLES, conformance, golden-corpus,
  library/pass-guides + heuristic-profiles, the bootloaders) to the new structure, plus the physical moves.
  Done as part of this change.
- **Neutral:** every closed set (13 personas, 9 passes, 7 blocks…), the SOL grammar, and the reconciliation
  design are unchanged — only *where files live* and *what the kit bundles* change.

## Status

Accepted (v0.1). Physical restructure done (`git mv` the 17 code skills → `docs/library/code-skills/`,
conformance → top-level `conformance/`, twins deleted); the model/adoption docs and the bootloaders are
reworked to the final structure; `swarm-cli` (co-located) is realigned (specs top-level).

## Affected obligations / constraints

- Refines: [0050](./0050-swarm-is-a-spec-repo-discipline.md) (specs top-level), [0048](./0048-installed-payload-is-the-runtime-surface.md) (kit contents), [0042](./0042-skill-carrier-and-standalone-conditioning.md) (catalogue split).
- Retires: the twin-maintenance mechanism of [0044](./0044-kernel-is-derived-and-self-contained.md) (`docs/` is the sole canonical home; no shipped twins).
- Depends on: [0047](./0047-skills-are-self-contained.md) (self-contained skills make shipping no manuals/twins safe).
- Does NOT change: the obligation grammar, any closed set, the nine passes, or the reconciliation design.

> **Ledger note (2026-06-11):** refined by ADR-0057; validity bar partially superseded by ADR-0066.
