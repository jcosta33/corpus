---
type: adr
id: adr-0060
status: accepted
created: 2026-06-11
updated: 2026-06-11
---

# ADR-0060 — The Corpus Workspace: hybrid layout, committed flow artifacts, the review packet

## Context

The product's wedge is review-by-exception: turning large agent output into requirement coverage,
evidence, and a human-attention list. Agent-authored summaries are not trustworthy on their own —
evaluators favor their own generations [[SELFPREFER]](../research/sources.md#SELFPREFER), judges carry
position/verbosity biases [[JUDGEBIAS]](../research/sources.md#JUDGEBIAS), and unsupported "done" claims
are a recurring failure (small-N, preliminary) [[EVIBOUND]](../research/sources.md#EVIBOUND). The external survey found **no
tool ships a persisted, independent, exception-routing review packet** (the verified gap — never claim
"nobody reviews agent output"); it also found every competing tool keeps specs in-repo, while external
requirements stores exist at the RFC/requirements-repo granularity enterprises already run, with
drift/discoverability as the known failure mode of separation (recorded counter-sources: the
spec-kit issue threads #1191/#876/#1059 and the Fiberplane "Drift" post — survey V-059/V-024).

## Decision

1. **Workspace layout (hybrid).** Durable intent lives in feature folders: `specs/<feature>/spec.md` plus
   co-located supporting docs (audit, research, prd, rfc, inventory). Flow artifacts live in committed
   type folders: `intake/`, `tasks/`, `reviews/`, `findings/`, `inventory/`, `change-plans/` (the latter
   two appear when the work needs them). Project decisions in `decisions/` (numbered ADRs). A hand-edited
   `status.md` workboard at the root. `.agents/` holds only tooling. Both naming depths are valid
   (folder-per-artifact with `NNN-` prefixes, or flat files for small projects).
2. **Flow artifacts are committed.** Tasks, reviews, and findings are durable workspace content — the
   review packet that links its PR is the default record of work. (A PR-only record remains the floor for
   teams with no workspace.)
3. **Co-located and external are co-equal defaults.** A single-repo team keeps the same tree inside its
   repo (optionally under a visible `corpus/` directory). The external workspace is framed as a Git-native,
   agent-readable form of the external requirements store larger organizations already run — never as the
   common practice of comparable tools (it is not; the in-repo norm and the drift failure mode are the
   recorded counter-evidence, survey V-021/V-024). One spec store can govern many code repos.
4. **The review packet** (template frozen here, shipped at `starter-kit/templates/review.md`): frontmatter
   `type: review, id, task, pr, status: draft|pass|blocked|needs-human`; sections Summary / Changed files /
   Requirement coverage table (`ID | Result | Evidence | Human attention`, results Pass · Fail · Unverified ·
   Blocked) / optional Change-plan coverage table (same columns) / Human attention / Suggested decision.
   Hard rules: **a Pass needs pasted output or a CI link; an empty Evidence cell means Unverified, never
   Pass** (checklist level); reviewers **spot-check at least one green row's evidence** (automation-bias
   countermeasure — convention level); the exception-trigger list the packet routes is: unverified/failed
   requirements · out-of-scope changes · risky files · missing test output · changed public interfaces ·
   DB migrations · security-sensitive changes · new finding candidates · blocked questions.
5. **The task packet** (template frozen here, shipped at `starter-kit/templates/task.md`): frontmatter
   `type: task, id, source[]` (spec and/or change plan), `scope[]` (requirement ids), `status`; sections
   Source / Scope ("Implement or preserve") / Do not change / Affected areas / Verify checklist / Agent
   instructions (read sources first; stay in scope or stop and say why; run every Verify item and paste
   real output; re-read your own diff as a skeptic before finishing; leave a summary of changed files,
   commands run, findings) / Findings.
6. **Spec evolution is routine.** A spec is amended in place after review feedback (edit the requirement,
   keep its ID, note material drops under "Dropped from sources"); workspace↔code drift is detected at
   review time by the packet's coverage table, and stale specs are flagged on the status board. No
   regeneration ceremony.

## Alternatives considered

| Alternative                             | Why weaker                                                                                                         |
| --------------------------------------- | ------------------------------------------------------------------------------------------------------------------ |
| Gitignored task/review scratch          | Discards the wedge's record; the packet is the product's durable evidence                                          |
| Pure per-feature folders for everything | Flow artifacts cross features (one review covers one task, not one feature); type folders keep the board scannable |
| External-store as the sole default      | Contradicts the documented in-repo norm and adds drift risk for small teams                                        |

## Consequences

Positive: requirement → evidence is one folder hop; the board reads at a glance. Negative: committed flow
artifacts grow the workspace (archive convention left to teams). Neutral: PR remains the merge mechanism.

## Status

Accepted. Supersedes ADR-0004; partially supersedes ADR-0052 (feature folders kept for intent; the
scratch rule and memory-dir home are replaced); refines ADR-0049, ADR-0050, ADR-0032, ADR-0030.

## Propagation

Templates (task, review, status), docs/03/05/06/08, ADOPTING, kit shell, conformance task/review schemas,
examples, evals.

> **Addendum (2026-06-11):** the worker's run record folds into the review packet (the run summary
>
> - evidence cells); a standalone trace artifact exists only as a reserved machine-record sketch on
>   the future-CLI page. Inventories live in the type folder `inventory/`; the feature folder co-locates
>   only spec-supporting documents (audit, research, prd, rfc).

> **Ledger note (2026-06-12):** the workspace layout this ADR prescribes is shipped pre-built
> by the starter kit per ADR-0069.

> **Ledger note (2026-06-12, later):** the addendum's run-record clause ("the worker's run
> record folds into the review packet") is superseded by ADR-0072 — the run summary lives in
> the task packet as a digest; the task and review packet formats are amended additively by
> the same ADR.
