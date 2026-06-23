---
type: adr
id: adr-0082
status: accepted
created: 2026-06-16
updated: 2026-06-16
---

# ADR-0082 — Platform constraints are an advisory rule, not a new core section

## Context

Field feedback (corpus-hq issue #5) asked for a "Platform Constraints & Hazards" forcing-function
section so platform research — quota, permissions, rate limits, runtime/sandbox constraints — is
done _before_ the acceptance criteria, when it's cheap, rather than discovered mid-build. The
question was whether to add a section, and to which artifact at which tier.

Two facts narrowed it. ADR-0076 already shipped the runtime-_hazard_ half this cycle
(precondition-as-first-requirement, rare-runtime-state simulation, the runtime-proof review rule,
the runtime-isolation caution). And both happy-path docs already warn that a section every author
must consider on already-clear work is exactly the ceremony that measurably hurts outcomes — so a
new always-present heading carries real cost for the case (a small change with no platform surface)
where it is pure overhead.

## Decision

**Add no new core section. Serve platform constraints with one advisory writing rule that routes
them into the sections that already exist.** An unknown platform limit becomes an **Open question**
(which already gates `ready`); a deliberately-unhandled one becomes a **Non-goal**; a known one
becomes a **requirement with a `Verify with:` line**. The change is:

- `docs/04-writing-specs.md` — writing rule 11 ("Research the platform's limits before the ACs"),
  advisory, no gate.
- `docs/05-brownfield-and-change-plans.md` — one note pointing the change-plan's existing **Review
  focus** at platform hazards (which already pairs with ADR-0076's runtime-isolation caution).

The frozen core spec section list (ADR-0058) and the change-plan format (ADR-0068) are **unchanged**;
no `checks.yaml` change; no new template heading for any check to reconcile against.

**Rejected:**

- _(a) a new section in the spec template_ — largest blast radius for the option most redundant with
  Open questions, and it would amend ADR-0058's frozen section list.
- _(b) a section in the change-plan template_ — mostly duplicates the existing Risk-areas / Review-focus
  fields.

**Escalation path (deferred, demand-gated):** if field evidence later shows platform-bound adopters
re-deriving structure, add a standalone `advanced/platform-constraints.md` modeled on
`advanced/threat-model.md` — an observation-only _input_ doc that feeds the spec via `sources[]`,
with binding constraints restated as spec requirements — never an amendment to the frozen core
section list. This ledger row exists to record that (a)/(b) were considered and declined, so the
choice is not silently re-litigated.

## Consequences

- The constraints half of #5 is served with no frozen-format change; the hazard half remains
  ADR-0076's, so future runtime work strengthens and exemplifies those rules rather than adding a
  parallel section.
- The advisory rule carries no gate (consistent with the rest of the writing rules and the
  ceremony-on-clear-work caution); a team that wants teeth can treat it as a review checklist item.
- If the escalation is ever taken, it reuses the established `threat-model` input-doc pattern, so the
  corpus-cli reconcile and the kit advanced tier treat it like any other optional input doc.
