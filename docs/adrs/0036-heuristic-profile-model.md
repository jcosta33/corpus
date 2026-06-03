---
type: adr
id: 0036-heuristic-profile-model
status: accepted
created: 2026-06-02
updated: 2026-06-02
supersedes: [0006, 0009, 0013, 0019]
superseded_by:
---

# ADR-0036: Personas become heuristic profiles

## Context

An earlier design iteration carried personas as a tangle of overlapping commitments. ADR 0009 named them mindsets but the term still invited org-chart reading; ADR 0006 bound the Skeptic *mindset* to a `fix` *task type* as its "lead persona"; ADR 0013 encoded each persona body as an "iron law" of Hard constraints / Forbidden actions plus a Red-flags table; and ADR 0019 made the standalone persona skill the canonical carrier and litigated which of the 13 mindsets earned a file ("13 mindsets, 8 skills"). The result coupled four things that are independent: the *mindset*, the *thing it parameterizes*, the *form of its refusals*, and the *file it ships in*. §27 collapses that coupling: a persona was never an org role and never a procedure — it is an optional cognitive stance applied to a pass.

## Decision

A persona is recast as a **heuristic profile**: an optional cognitive stance that changes *what an agent looks for and refuses* while performing a pass, with the procedure staying in the pass guide (§27.1). Four consequences follow, each superseding an earlier ADR. (1) A profile parameterizes a **pass**, not a task type — the Skeptic is a profile on the `review`/`verify` passes, not the owner of `fix` tasks (§27.3, supersedes 0006). (2) All 13 are uniformly heuristic profiles; the 8/5 "ships vs rides" asymmetry is dropped (§27.4, supersedes 0009/0019). (3) The "iron law" is recast as a profile's `## Refuses` red-flag table — one of the seven canonical profile sections, a skill-shaped body with a third-person `description` carried under progressive disclosure [[SKILLSPEC]](../research/sources.md#SKILLSPEC) (§27.2, supersedes 0013). (4) A profile's **carrier is an implementation detail**: a standalone file is one option, inlining into a pass guide is another; conformance checks the contract, not the file (§27.1, supersedes 0019). The full specification is §27.

## Alternatives considered

| Alternative | Why rejected |
| --- | --- |
| Keep persona × task-type routing (Skeptic owns `fix`, ADR 0006) | A mindset is orthogonal to the work kind; binding it to a task type duplicated the same stance across many cells and mislabeled a pass parameter as an owner (§27.4). |
| Keep persona × document-type routing | Same duplication on a second axis; profile × pass replaces both earlier matrices, and a repo MUST NOT reintroduce either (§27.4). |
| Keep "personas are mindsets" wording unchanged (ADR 0009) | The word still invited org-chart reading and left the mindset unbound to what it parameterizes; "heuristic profile applied to a pass" makes both explicit (§27.1). |
| Keep the iron-law body shape (ADR 0013) | The Hard constraints / Forbidden actions split is folded into one enumerated `## Refuses` red-flag table inside the fixed seven-section contract (§27.2). |
| Ship every profile as its own skill file (ADR 0019) | Couples the kernel object (the mindset) to an incidental carrier; the file is incidental and inlining is equally valid, so conformance checks the contract instead (§27.1). |
| Make a profile mandatory on its pass | A pass is well-defined with no profile loaded; a profile sharpens a pass but is never required for it to be valid (§27.1). |

## Consequences

### Positive

- Collapses both earlier persona matrices onto one axis (profile × pass), removing the per-cell duplication of the same mindset.
- A profile is now defined by a single contract (seven sections, §27.2), so the iron law, red flags, and applicability live in one stable shape.
- Carrier freedom lets a profile inline into a pass guide where that reads better, without losing conformance.

### Negative

- Readers who learned the old "lead persona owns this task type" model must re-learn routing as profile × pass.
- Dropping the 8/5 split means the "which personas ship as files" guidance no longer carries discrimination weight; the value test ADR 0019 applied is gone.

### Neutral / tradeoffs

- The 13 mindsets are preserved 1:1 as profiles; none is added or removed — only their routing, body shape, and carrier rules change.
- A profile remains a skill-shaped file and so inherits the §26.1 semantic-ownership prohibition unchanged: it MUST NOT define language or artifact semantics.

## Status

Accepted (v0.1).

- Supersedes ADR-0006 (recasts the Skeptic from owner of `fix` tasks to a profile on the `fix`/`review` passes).
- Supersedes ADR-0009 (recasts "personas are mindsets" as heuristic profiles bound to the pass they parameterize).
- Supersedes ADR-0013 (recasts the iron law + red-flags body as a profile's `## Refuses` red-flag table).
- Supersedes ADR-0019 (recasts the standalone persona skill as one carrier option among others, not the canonical form).

## Affected obligations / constraints

- Adds: the heuristic-profile contract (the seven canonical sections of §27.2) and the profile × pass routing rule (§27.3–27.4).
- Modifies: the carrier rule for profiles — standalone file OR inlined pass guide, conformance binds the contract not the carrier (§27.1).
- Supersedes: persona × task-type and persona × document-type routing; the "iron law" body shape; the "8 of 13 ship as skills" carrier rule.
