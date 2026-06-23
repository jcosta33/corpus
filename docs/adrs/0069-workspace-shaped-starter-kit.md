---
type: adr
id: adr-0069
status: accepted
created: 2026-06-12
updated: 2026-06-12
---

# ADR-0069 — The starter kit is a workspace, copied whole

## Context

The kit promised copy-and-go and delivered a parts box. Owner review (2026-06-12) found the
adoption path piecemeal: `starter-kit/agent/` is a staging directory whose name matches no
convention any tool recognizes, and whose contents scatter on adoption (`AGENTS.md` to the
workspace root, guides to `.claude/skills/`); the six flow folders ADR-0060 prescribes are
*documented* in docs/03 but never *shipped*, so every adopter rebuilds the tree by hand from a
diagram; ADOPTING.md needs several copy steps with different destinations to assemble what the
kit could simply be. The piecemeal experience is acceptable for the optional tier — it is the
core path where it defeats the kit's reason to exist.

## Decision

1. **`starter-kit/` is a complete Corpus workspace.** Its root carries `AGENTS.md` (+
   `CLAUDE.md`/`GEMINI.md` symlinks), `templates/`, the prescribed flow folders (`specs/`,
   `intake/`, `tasks/`, `reviews/`, `findings/`, `inventory/`, `change-plans/`, `decisions/`)
   each seeded with a one-line README, the live `status.md` board, and the worked example as a
   deletable folder. Adoption is one copy: `cp -r starter-kit/ <your-workspace>` (standalone
   repo or a folder in an existing project), then fill `AGENTS.md`.
2. **Guides live at `.agents/skills/`, tool adapters are symlinks.** The three core guides
   ship at `starter-kit/.agents/skills/{write-spec,implement-task,review-output}/` — the
   workspace's own agent-tooling home, consistent with docs/03's "`.agents/` = agent tooling
   only". Tool-specific discovery is a symlink: `.claude/skills → ../.agents/skills` ships in
   the kit; other tools get a one-line equivalent in `AGENTS.md`. The pattern is the house
   pattern: agnostic target, symlink adapters — exactly `AGENTS.md` ← `CLAUDE.md`/`GEMINI.md`.
3. **`advanced/` stays a parts tier, piecemeal by design.** Optional templates are used in
   place; optional guides are copied into `.agents/skills/` when wanted. The staging directory
   `agent/` is retired.
4. **Distribution: in-repo now, template repo at public launch.** The kit stays in this repo
   while formats settle — the swarm-cli kit copy's lag is live evidence of what a second
   derived repo costs pre-stability. At public launch the kit is published as a separate
   GitHub *template repository* (one-click "Use this template"), produced either by a split or
   by a producer-side mirror job; that step is deliberate, recorded here, and not started now.

## Alternatives considered

- **Split the template repo immediately** — cleanest adopter story, but every format edit
  becomes a two-repo commit while the formats are demonstrably still moving; rejected for now,
  adopted as the launch plan (point 4).
- **Keep the parts-box kit and improve ADOPTING's checklist** — documentation cannot fix a
  shape problem; the checklist *was* the symptom.
- **Ship `.claude/skills/` as the real directory** — privileges one tool and inverts the house
  pattern; rejected for the agnostic-home-plus-symlink form.

## Consequences

Accepted. Refines ADR-0064 (the core/advanced tiering and guide set survive unchanged; the
"12-file copy checklist" adoption framing is superseded by copy-the-folder), ADR-0060 (the
workspace layout is now shipped, not only documented), ADR-0049 (in-place install survives;
the kit now ships the six prescribed flow folders pre-built, per that ADR's goldilocks
update). ADOPTING.md collapses to one copy step plus per-tool symlink notes.

## Propagation

starter-kit tree, ADOPTING, root README (get-started), docs/03, docs/10, kit AGENTS.md,
`.agents/SKILLS-MANIFEST.md` counterpart paths, propagation matrix.

> **Addendum (2026-06-12):** two corrections from the same-day verification passes. (1) The
> copy command is `cp -R` — on macOS BSD cp, `-r` dereferences the kit's three symlinks into
> stale copies; all live surfaces document `-R`. (2) `decisions/` ships a short governance
> README plus the `0001-adopt-swarm` seed entry, not a one-line README like the seven flow
> folders. Known consequence, recorded in `.agents/SKILLS-MANIFEST.md`: the kit's nested
> `.claude/skills` symlink surfaces the three kit guides in Claude sessions on the Corpus repo
> itself.
