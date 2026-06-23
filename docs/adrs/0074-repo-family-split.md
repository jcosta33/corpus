---
type: adr
id: adr-0074
status: accepted
created: 2026-06-13
updated: 2026-06-13
---

# ADR-0074 — The repo family realized: producer workspace and skills catalog

## Context

ADR-0073 named the multi-repo workspace and noted that the Corpus family's own was "a separate
owner action." The owner acted: a `swarm-hq` repo now exists for the family (swarm · swarm-cli ·
swarm-skills · planned: swarm-starter-kit, swarm-ci, swarm-website). Until now this repo carried
its own producer workspace (`.agents/specs|audits|change-plans`) and two skill surfaces beyond
the kit core (the kit's `advanced/` guides; `docs/library/code-skills/`), and swarm-cli carried a
full co-located workspace. The repo-split audit (now at `swarm-hq:specs/repo-split-architecture/audit.md`)
states the governing principle: **`swarm` is canon; every other repo is derived, implemented, or
indexed from it** — and a producer workspace inside the product repo ships planning clutter to
the adopters and the CLI that consume it.

## Decision

1. **The producer workspace is `swarm-hq`** — the family's multi-repo workspace (the ADR-0073
   shape applied to Corpus itself). Specs, audits, research, change plans, findings, tasks,
   reviews, and the board for changes to this repo and to swarm-cli live there. This repo and
   swarm-cli carry the code-repo footprint (the workspace pointer, the gitignore lines, the
   `implement-task` guide) — nothing else. Accepted framework decisions still land here, in
   `docs/adrs/`; `swarm-hq` is not a second canon.
2. **The optional guides are a catalog: `swarm-skills`.** The kit's `advanced/` guides and the
   per-change-shape implementation guides (formerly `docs/library/code-skills/`) move to the
   `swarm-skills` repo in the Agent Skills format (`skills/<name>/SKILL.md`), installable
   piecemeal (`npx skills add jcosta33/swarm-skills`) or by copying folders. The kit keeps the
   three core guides; `starter-kit/advanced/` keeps the optional templates and the two
   reference cards and points at the catalog for guides. `docs/library/` is retired.
3. **The dev subset shrinks to implementation-side guides.** `.agents/skills/` keeps
   `implement-task` (byte-identical kit mirror), `empirical-proof`, and
   `persona-documentarian`. The authoring, review, and persona guides move to `swarm-hq`'s
   skills as workspace-adapted copies — spec writing, reviewing, and auditing for this repo run
   from the workspace.

## Alternatives considered

- **Keep the producer workspace co-located** — the dogfooding default, but this repo is not a
  normal adopter: its product is copied wholesale by adopters and consumed by the CLI, so
  producer artifacts pollute the product surface; the audit's observation 2 makes the boundary
  explicit.
- **Per-repo full installs across the family** — rejected by ADR-0073 Decision 6: one full
  workspace, footprints in code repos, no install in derived-content repos.
- **Advanced guides stay in the kit** — every adopter carries guides they do not need, and the
  catalog cannot grow without growing every workspace copy; the kit stays core-only, the
  catalog installs piecemeal.
- **A `swarm-linter` repo** — rejected; record-level checks belong in swarm-cli
  (`swarm spec check`), per the audit and ADR-0058's notation-not-language framing.

## Consequences

Accepted. Refines ADR-0064 (minimal kit tiering — the optional tier's guides now distribute
via the catalog; the tier's templates and cards stay in the kit), ADR-0069 (kit contents unchanged in shape; the
advanced directory's guide subfolders leave), and ADR-0073 (the family's own multi-repo
workspace exists). The propagation surfaces — docs/01/03/05/07/08, ADOPTING, agent-guides,
review-stances, advanced-lifecycle, kit README, advanced README, the skills manifest, this
repo's `AGENTS.md` — now point at the workspace and the catalog. swarm-cli's uninstall is
recorded in its own history.

## Propagation

AGENTS.md (workspace pointer, pointers, single-sourcing), docs/01, docs/03, docs/05, docs/07,
docs/08, docs/ADOPTING.md, docs/reference/{agent-guides, review-stances, advanced-lifecycle},
starter-kit/README.md, starter-kit/advanced/README.md, .agents/SKILLS-MANIFEST.md, ledger row.
