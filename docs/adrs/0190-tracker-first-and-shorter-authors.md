---
type: adr
id: adr-0190
status: accepted
created: 2026-11-05
---

# ADR-0190 - Tracker-first specs and shorter authors

## Context

[ADR-0189](./0189-four-artifact-authors.md) gave the spec a `## Split` table and a `## Execution`
record, kept the audit's Map, Risks, and Unknowns sections, graded research on a four-level
confidence ladder, and taught campaign delivery method in its own Lanes, Dispatch, and Delivery
sections.

Usage and ecosystem research on 2026-11-05 (`corpus-review/research-corpus.md`, outside this
repository) found:

- The owner's main project files specs as tracker issues through an issue form, and its rules
  delete the local copy after filing. Its spec and audit forms had drifted from the skill shapes.
- Parallel slices, live run records, and generic delivery method already have owners: the
  campaign's dispatch rule, tracker task issues, native batch tooling, the pull request, and project
  delivery commands.
- Research agents cite links that resolve but do not support the claim.
- Skills that restate what a strong model already does show no measured benefit and can anchor
  agents on their templates.

## Decision

1. **Specs are tracker-first.** When the project's tracker has a spec form, the filed issue is the
   spec and the artifact file is its draft. Once filed, Delete is the default close disposition.
2. **The spec matches the form.** It has `## Intent`, `## Requirements`, optional `## Boundary`,
   and `## Open questions` only while draft. A short name after `### AC-NNN` is optional.
3. **The spec drops `## Split` and `## Execution`.** The campaign owns write-disjoint dispatch. The
   native pull request owns verification output and review.
4. **The spec's verify step is one sentence.** It checks the stated rules, the absence of
   placeholders at `ready`, and that sources resolve.
5. **Structural change is sharpened.** Waves run expand, migrate in batches, then contract. Every
   removed behavior is named as retired or re-established. No step weakens, skips, or deletes a
   test to turn green.
6. **The audit matches the form.** Its sections are `## Scope`, then `## Map`, `## Findings`, or
   both, then `## Unverified`. The map records what each component takes on faith and what enforces
   it.
7. **Research grades claims, not sections.** Each claim gets one outcome: `Verified`, `Disputed`,
   `Unverified`, or `Overturned`. Each load-bearing claim quotes its supporting passage. Market
   sizing and synthetic-respondent rules leave the skill.
8. **The campaign keeps authorities and loses delivery method.** Each operation still names its
   owner, strength, mechanism, and failure behavior, and project rules govern how it runs. Three
   bans stay in the skill:
   - Never seize a lane.
   - Never take over another owner's branch, and never accept your own work.
   - Bind each merge to the expected head.

   The completion contract is one end state, verified by evidence, while preserving constraints.
   It fits a native goal condition.
9. **Authors state no question format.** Harness and owner policy govern how to ask.
10. **Skills carry the plain procedure.** No skill description or body names a philosopher, a
    thinker, or a named method. Sources are credited in `skills/sources.md` or ADRs. The skill gate
    rejects that vocabulary.

## Narrowed decisions

- [ADR-0189](./0189-four-artifact-authors.md): Decision 3's Split and Execution clauses retire.
  The spec still absorbs change plans. Parallel dispatch moves to the campaign.

## Consequences

- An existing spec with `## Split` or `## Execution` stays readable. No author writes either
  section.
- The four authors drop from 402 lines to 315.
- A blind progression test of old and new authors on two tasks per skill found no rule the new
  versions lost ([results](../research/progression-2026-11-05/README.md)).

## Status

Accepted (2026-11-05). Narrows ADR-0189.
