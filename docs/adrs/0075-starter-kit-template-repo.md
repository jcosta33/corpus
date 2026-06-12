---
type: adr
id: adr-0075
status: accepted
created: 2026-06-13
updated: 2026-06-13
---

# ADR-0075 — The starter kit ships as its own template repo; essential guides ship installed

## Context

ADR-0069 kept the kit inside this repo "until public launch" so format edits stayed one-repo
commits; ADR-0074 split the producer workspace (swarm-hq) and the optional guides
(swarm-skills) out, tiering all twelve advanced guides into the catalog. Two corrections from
the owner followed. First, the kit split's precondition is gone: with the workspace in swarm-hq
cutting and reviewing every change, a format edit is already a reviewed cross-repo operation,
and the family's repos exist. Second, ADR-0074's tier line was drawn in the wrong place: the
workspace authoring guides (`write-audit`, `write-research`, `write-rfc`, `write-prd`,
`write-bug-report`, `write-change-plan`, `write-inventory`, `spec-check`, `split-work`,
`save-findings`, `adversarial-review`) author and gate Swarm's own artifacts — every Swarm
workspace needs them, which is the definition of essential, not optional.

## Decision

1. **The kit is its own template repo: `swarm-starter-kit`.** The repo root is the workspace
   (copy whole / "Use this template"); kit content is edited there. This repo's docs and ADRs
   remain the rule canon; the kit ships what the ADRs freeze. `starter-kit/` leaves this repo;
   every doc reference points at the kit repo (URL form — the docs are read on GitHub).
2. **Essential guides ship installed.** The kit's `.agents/skills/` carries the core loop
   (`write-spec`, `implement-task`, `review-output`) plus the eleven workspace authoring
   guides. `advanced/` keeps the optional templates and the two reference cards.
3. **The catalog is the optional layer.** swarm-skills carries the six conditioning stances
   (`persona-architect`, `-auditor`, `-documentarian`, `-researcher`, `-skeptic`,
   `-surveyor`), the standalone `empirical-proof`, and the ten per-change-shape
   implementation guides — plus, under its `docs/`, the skill-design research layer
   (activation, body anatomy, execution, self-containment, task files, scope, sources)
   imported from the owner's upstream skills library.

## Alternatives considered

- **Keep the kit in-repo until launch (ADR-0069 as written)** — its rationale (one-repo format
  edits) no longer holds: the workspace already makes every format change a planned, reviewed
  task, and a template repo gives adopters one-click copy instead of a subfolder extraction.
- **A generated mirror (kit stays canonical here, repo derived)** — doubles every edit and
  needs sync automation nobody has; the family precedent (ADR-0074: content edited in its
  shipping repo, rules canon here) already works.
- **Essential guides as kit `advanced/` opt-ins** — "essential but uninstalled" is a
  contradiction adopters pay for; the DX audit's cold-adopter evidence says uninstalled
  guides simply don't get used.

## Consequences

Accepted. Refines ADR-0064 (the optional tier is now: advanced templates + cards in the kit,
stances + code depth in the catalog), ADR-0069 (the workspace shape stands; the
defer-to-launch clause is executed; the kit-skill-surfacing note retires with the nested
copy), ADR-0073 (the kit repo joins the governed family as derived content), and ADR-0074
(Decision 2's tier line moves: workspace authoring guides are kit content, not catalog
content). Cost accepted: a format change is a two-repo change, mitigated by swarm-hq review.

## Propagation

AGENTS.md, README, docs/01/02/03/04/05/06/08/09/10, ADOPTING, examples ×3,
reference/{artifact-formats, cheatsheet, memory, step-bars, review-stances, agent-guides,
advanced-lifecycle}, checks/README, SKILLS-MANIFEST, ledger row; swarm-cli's scaffold resync;
swarm-hq pointer updates.
