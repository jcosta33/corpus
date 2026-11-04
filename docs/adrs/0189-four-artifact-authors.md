---
type: adr
id: adr-0189
status: accepted
created: 2026-11-05
---

# ADR-0189 - Four artifact authors

## Context

[ADR-0186](./0186-artifact-authors-ship-with-canon.md) shipped seven artifact authors with the
canon: spec, task, inventory, change plan, audit, research, and campaign. The authors took 798
lines. Each one restated the same placement, handoff, and close contract.

Usage on the owner's machine did not match that catalog. A count of `~/.agents/artifacts` on
2026-11-04 found 14 campaigns, 13 audits, 9 research files, 5 tasks, 4 change plans, 2
inventories, and no specs. None of the five tasks matched the task format.

The types also overlapped:

- An inventory is an audit without risk grading.
- A change plan is a spec whose requirements preserve behavior, plus staging.
- A task packet is a slice of a spec, with paths and ordering.

[ADR-0187](./0187-retire-checker-mcp-website-and-setup-policy.md) retired the checker that held
these shapes apart. With the checker gone, nothing outside the skills tells the types apart.

## Decision

1. **Four authors.** Corpus ships `corpus-spec`, `corpus-audit`, `corpus-research`, and
   `corpus-campaign`. Each is a standalone single-file skill.
2. **Four artifact types.** The artifact types are `spec`, `audit`, `research`, and `campaign`.
   Evidence receipts and run notes stay untyped sidecars.
3. **The spec absorbs change plans and tasks.**
   - Structural change is a spec with `## Baseline`, preserved behavior as `When: always`
     requirements, `## Waves`, and `## Cutover`.
   - Parallel dispatch is a spec with a `## Split` table, one row per write-disjoint slice.
   - `## Execution` records the live run inside the spec.
4. **The audit absorbs inventory.** An audit maps present state. It grades risk only when risk was
   assessed.
5. **The file name is the artifact ID.** An artifact lives at
   `~/.agents/artifacts/<workspace>/<ID>.md`. The `type:` field, not the name, identifies its kind.
6. **The universal methods keep their survivor names.** They are `ask-user`, `bulletproof`,
   `debloat`, `dissect`, `drill`, `panel`, and `revolver`, in `jcosta33/skills`. Corpus names them
   and asserts nothing about their contents. Promotion at close is an action the agent performs, not
   a skill.
7. **The docs collapse to three files.** `docs/method.md` holds the method, `docs/formats.md` the
   exact shapes, and `docs/glossary.md` the terms.

## Narrowed decisions

- [ADR-0068](./0068-inventory-and-change-plan.md): inventory and change plan stop being artifact
  types. Their content survives as an unrisked audit and as the structural-change sections of a
  spec.
- [ADR-0144](./0144-keys-and-scaffold.md): the keys stand unchanged. The scaffold is now a spec, an
  audit, research, or a campaign.
- [ADR-0151](./0151-skill-agent-artifact-economy.md) and
  [ADR-0157](./0157-ruthless-skills-and-closed-artifact-authorship.md): artifact authorship stays
  closed. The closed set is the four `corpus-*` authors.
- [ADR-0186](./0186-artifact-authors-ship-with-canon.md): the authors still ship with the canon.
  The seven `sus-*` names give way to four `corpus-*` names.

## Consequences

- An existing `type: task`, `type: inventory`, or `type: change-plan` file stays readable as
  Markdown. No current author writes or revises one. Move a live one into a spec or audit by hand.
- Adopters remove the seven `sus-*` skills by name before installing the four `corpus-*` skills.
- The authors drop from 798 lines to about 400, because the shared contract is stated once per
  author instead of once per type.

## Status

Accepted (2026-11-05). Narrows ADR-0068, ADR-0144, ADR-0151, ADR-0157, and ADR-0186.
