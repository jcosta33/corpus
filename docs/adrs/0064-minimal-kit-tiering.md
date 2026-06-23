---
type: adr
id: adr-0064
status: accepted
created: 2026-06-11
updated: 2026-06-11
---

# ADR-0064 — Minimal starter kit: core copy surface, advanced tier, focused guides

## Context

Adoption collapses under ceremony: the adopter audit counted 47–49 installed files before the first line
of project content (O-006, R-001), judged several broad personas to be internalized stances adding noise,
and found the skill-loading story underdocumented (O-007) — while singling out the surveyor stance as the
standout (O-008) and the audit template as the fastest path to value (O-001). Vendor guidance favors few,
focused skills over broad personas.

## Decision

1. **Core copy surface = 12 files.** `templates/{spec, task, review, finding, status, intake, inventory,
change-plan}.md` + `agent/AGENTS.md` + three focused agent guides: `agent/write-spec/`,
   `agent/implement-task/`, `agent/review-output/` (SKILL.md carrier — auto-discoverable by agent CLIs,
   plainly readable by humans). Whole kit excluding `advanced/` ≤ 24 files.
2. **The three guides absorb the cross-cutting disciplines.** `write-spec` carries the architect stance
   (intent not implementation; survey before inventing) and the dropped-from-sources practice;
   `implement-task` carries scope discipline, evidence-or-it-didn't-happen, and adversarial self-review
   before handoff; `review-output` carries refute-by-default, the evidence rules, and the finding-saving
   close. No standalone persona files in the core kit.
3. **Advanced tier (`starter-kit/advanced/`, all optional):** templates `{audit, bug, research, adr, rfc,
prd, threat-model}.md`; reference cards `sol-reference.md` (the notation) and `checks-reference.md`;
   guides `{write-audit, write-research, persona-surveyor, write-bug-report, write-prd, write-rfc,
write-change-plan, write-inventory, spec-check, save-findings, split-work}`. The audit template is
   flagged "recommended first taste for brownfield teams". **persona-surveyor stays a standalone guide**
   — its evidentiary discipline (three named instances; observation vs claim) is the one stance that does
   not fold cleanly.
4. **Adoption is manual-first:** a copy checklist (the 12 files) leads; the agent-assisted prompt is the
   second path; a future `corpus init` is the third.

## Alternatives considered

| Alternative                               | Why weaker                                                                                 |
| ----------------------------------------- | ------------------------------------------------------------------------------------------ |
| Ship everything, label tiers in docs only | The install footprint is the friction; labels don't shrink it                              |
| Plain .md guides instead of SKILL.md dirs | Loses agent-CLI auto-discovery; SKILL.md reads fine as plain markdown                      |
| Fold surveyor too                         | Its rules are load-bearing for research quality and don't belong to any single write-guide |

## Consequences

Positive: five-minute adoption; every core file earns its place. Negative: advanced material is a second
copy step. Neutral: guides install beside user skills (`pass-`-free names cannot collide).

## Status

Accepted. Partially supersedes ADR-0019, ADR-0002, ADR-0009 (persona shipping model); refines ADR-0042,
ADR-0036, ADR-0047, ADR-0056.

## Propagation

starter-kit tree, ADOPTING, docs/03/10, .agents dev subset, code-skills library index.

> **Addendum (2026-06-11):** the advanced tier additionally ships `adversarial-review` — a deep
> hostile re-review guide (with a session task template) for agent branches that warrant more than
> the review packet. It pairs with a dev-tier copy at `.agents/skills/adversarial-review/`; the pair
> is registered in the propagation matrix.

> **Ledger note (2026-06-12):** adoption framing (the 12-file copy checklist) superseded by
> ADR-0069 — the kit is copied whole as a workspace; the core/advanced tiering and the guide
> set survive unchanged.
