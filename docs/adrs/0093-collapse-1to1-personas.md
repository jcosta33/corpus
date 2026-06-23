---
type: adr
id: adr-0093
status: accepted
created: 2026-06-22
updated: 2026-06-22
---

# ADR-0093 — Collapse the 1:1 authoring personas; the catalog ships only cross-cutting stances

## Context

The corpus-skills catalog shipped seven `persona-*` conditioning stances. But ADR-0064 already folds
each stance's _substance_ into the kit work guides (`write-spec` carries the architect stance,
`review-output` carries refute-by-default, `write-audit` carries observation-only, `write-research`
the researcher stance, the documentation guide the documentarian stance). So five disciplines had
**two carriers** — the folded form in the guide _and_ a standalone persona — and the substance had in
practice drifted into a third copy (corpus-hq's dev-skill mirror), out of sync with the catalog.

A deep-research pass (corpus-hq `specs/corpus-skills/research-personas-as-skills.md`) settled the
principle. A persona's _identity_ does not systematically improve objective-task performance
([[ZHENG-PERSONA]](../research/sources.md#ZHENG-PERSONA)); role _framing_ helps only via the concrete
directives it evokes ([[KONG-ROLEPLAY]](../research/sources.md#KONG-ROLEPLAY)) — directives that
already live in the kit guide. For the skeptic specifically, the lever is **external grounding**, not
the critical attitude ([[SELFCORRECT]](../research/sources.md#SELFCORRECT); corroborated by Huang et al.
arXiv 2310.01798 and CRITIC arXiv 2305.11738, 3-vote-verified in the research note). And more
simultaneous, partially-redundant instructions degrade adherence (arXiv 2509.21051, 2307.03172 — see
the research note). So a standalone stance earns its keep only when it is genuinely
**cross-cutting** (reused across several guides); a stance that maps **1:1** to one work guide is a
redundant second carrier whose only reliable effect is drift.

## Decision

1. **Collapse the four 1:1 authoring personas.** `persona-architect`, `persona-auditor`,
   `persona-researcher`, `persona-documentarian` are removed from the catalog. Each discipline keeps
   its **single canonical carrier — the folded form in its work guide**: architect→`write-spec`,
   auditor→`write-audit`, researcher→`write-research` (the kit); documentarian→`write-documentation`
   (this catalog's code-depth guide). No substance is lost; the redundant standalone copy is.
2. **The catalog ships only cross-cutting stances.** `persona-skeptic`, `persona-challenger`,
   `persona-surveyor` stay standalone — each is reused beyond any single guide (skeptic spans review,
   root-causing, audit-deepening, and self-review; challenger pressure-tests any pre-commit proposal;
   surveyor's breadth discipline "does not fold cleanly into any single guide", ADR-0064). The
   `empirical-proof` evidence discipline (not a persona) is unchanged.
3. **The kept stances lead grounding-first.** Each opens with its evidence rule (re-run/paste/cite;
   "three named instances"; "an external referent"), not an identity or attitude line — the value is
   the directive, not the persona ([[SELFCORRECT]](../research/sources.md#SELFCORRECT)).
4. **Single source.** corpus-skills is the canonical home of the kept stances; the corpus-hq dev-skill
   mirror re-syncs from it. The corpus repo's own `persona-documentarian` dev-skill is replaced by a
   pointer to the folded `write-documentation` discipline.

## Alternatives considered

| Alternative                          | Why weaker                                                                                                                                                                                    |
| ------------------------------------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Collapse all seven (zero standalone) | surveyor + challenger fold into no guide — removing them loses capability or forces the misfit fold ADR-0064 rejected                                                                         |
| Keep all seven (status quo)          | leaves 1:1 disciplines in two/three drifting carriers for no reuse benefit; identity-only copy adds no measured value                                                                         |
| Measure first, then decide           | defensible, but the change rests on strong findings (identity-is-noise; grounding-is-the-lever) + an observed drift hazard; an A/B is recorded as optional post-hoc validation, not a blocker |

## Consequences

Positive: one carrier per 1:1 discipline (no drift); a small, honest catalog of genuinely
cross-cutting postures; downstream references (canon docs, corpus-agents see-alsos, the website) tell
one true story. Negative: a one-time cross-repo edit (five repos) and the loss of the
"load architect/auditor/researcher/documentarian as a posture without its host guide" affordance —
judged unused in practice (the host guide is where that work happens). Neutral: the kit work guides
are unchanged in substance.

## Status

Accepted. **Refines ADR-0042** (conditioning ships as standalone skills — now only for cross-cutting
stances) and **ADR-0064** (catalog side; the kit-tiering decision is unchanged). Updates the
`review-stances.md` "every stance also ships standalone" convention. Evidence:
corpus-hq `specs/corpus-skills/research-personas-as-skills.md`.

## Propagation

corpus-skills (remove 4 dirs; reframe 3; README; docs/self-containment), corpus-hq (.agents dev subset;
research note; board), corpus/.agents (documentarian dev-skill → pointer; SKILLS-MANIFEST),
corpus/docs/reference (review-stances, agent-guides), corpus-agents (see-also repointing),
corpus-website (`/skills` page). Sources added to `docs/research/sources.md`: ZHENG-PERSONA,
KONG-ROLEPLAY (the grounding claim reuses the existing SELFCORRECT entry); the fuller verified
citation list lives in the research note.
