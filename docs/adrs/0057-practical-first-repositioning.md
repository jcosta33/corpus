---
type: adr
id: adr-0057
status: accepted
created: 2026-06-11
updated: 2026-06-11
---

# ADR-0057 — Practical-first repositioning and the six-step loop

## Context

Three usage reports converged: an external adopter audit (`.agents/audits/adoption-experience-review.md`,
O-001..O-012), a product-shape audit, and a strategic synthesis ("Practical Spec, Change, Task, and
Review Workflow", `.agents/plans/inputs/report-3-strategic-synthesis.md`). Diagnosis: the docs presented
a heavy framework (a language, a prose standard, nine passes, closed sets, proof/verdict taxonomies,
conformance) where adopters needed a workflow. An external-evidence survey
(`.agents/plans/plan-validation-survey.md`, V-001..V-062) confirmed the direction: the most-documented,
partly measured complaint against incumbent spec tools is ceremony and generated-markdown bloat (V-001),
and the #2 OSS tool won its position on exactly the lightweight counter-position (V-002). The deeper
reading reconciles the adopter's own findings: SOL's precision was praised as a thinking tool (O-002)
while its presentation was rejected as ceremony (O-012) and its rules lacked tooling (O-003) — one
coherent position: keep the discipline, demote the formalism, name the tool. The public record
attacks generated spec bloat; the short, curated, conditional configuration is the one that record
leaves standing — and the internal pilot (`.agents/plans/spec-first-pilot-protocol.md`) tests it.

## Decision

1. **Identity.** Corpus is presented as *a lightweight spec and review workflow for teams using coding
   agents*: turn tickets into clear specs, specs into agent-ready tasks, and agent output into
   reviewable evidence. Thesis: coding agents increase code volume; Corpus reduces the coordination and
   review cost of that volume ("generation outpaces validation"). The spec is the source of **intended
   behavior**; code is **implementation reality**; review and status connect them. The phrase "source of
   truth" is retired from all surfaces.
2. **The six-step loop is the primary workflow:** `Pull → Spec → Task → Run → Review → Close`, with two
   named conditional steps for structural/brownfield work — Inventory (before Spec) and Change Plan
   (after Spec; ADR-0068). Per-shape flows (feature/refactor/bug/rewrite/cleanup/spike) are documented;
   not every task needs every step, and skip-paths are evidence-required, not concessions
   ([[HUMANEVALCOMM]](../research/sources.md#HUMANEVALCOMM) — forced process on clear tasks measurably
   hurts). The granular nine-step lifecycle (author→lint→improve→lower→decompose→implement→verify→
   review→promote) remains defined in one advanced reference page with an explicit mapping table; it is
   the risk-scaled deep form, not the default.
3. **Docs information architecture:** a numbered happy path `docs/01–10` + `docs/reference/` +
   `docs/examples/` + `docs/adrs/` (kept at this path; nav label "Design decisions") +
   `docs/research/sources.md` (path unchanged — citation anchors). Every page carries exactly one label:
   works-today / future-automation / advanced-design-note. At most one future-CLI aside per happy-path page.
4. **Full rename scope.** User-tier vocabulary (step, requirement, evidence, review result, checks,
   structured requirements, writing rules, review stance, workspace) applies to prose, directory names,
   and `type:` frontmatter alike — no legacy-name seam. Reference pages may use the precise internal
   vocabulary; the glossary maps both directions.
5. **Restraints (standing):** no counts ceremony in any adopter-facing page (reference values are listed,
   never counted; counts live in the producer note + cheatsheet appendix); fewer files, every file useful,
   review evidence over planning prose; one explicit differentiation answer in the README (vs lightweight
   spec tools and vs a bare AGENTS.md) since "lightweight" positioning is already occupied (survey V-002, V-005).

## Alternatives considered

| Alternative | Why weaker |
|---|---|
| Keep the formal framing, improve onboarding only | The reports locate the friction in the framing itself, not just ordering; measured ceremony complaints attach to the category (V-001) |
| Drop the formal layer entirely | The adopter audit praises exactly what it produces (O-001, O-002, O-010); demotion preserves value at zero first-contact cost |
| Rename `docs/adrs/` → `docs/decisions/` | Pure link churn during the highest link-risk migration; newcomers see the nav label, not the dir name |

## Consequences

Positive: a ten-minute newcomer path; the wedge (review-by-exception) leads. Negative: a large one-time
restructuring; reference depth is one click further away. Neutral: internal precision unchanged — demoted,
not deleted.

## Status

Accepted. Refines ADR-0053, ADR-0054, ADR-0029; supersedes the naming clauses of ADR-0049 §2 and the
`pass-*` upgrade-naming story in the adoption docs.

## Propagation

All 13 surfaces (matrix: `.agents/audits/repositioning-propagation.md`).
