---
type: audit
id: AUDIT-codex-promptly-swarm-experience
title: Promptly Swarm adoption experience audit
status: closed
owner: codex
date: 2026-06-12
sources:
  - /Users/josecosta/dev/promptly/AGENTS.md
  - /Users/josecosta/dev/promptly-docs/status.md
  - /Users/josecosta/dev/promptly-docs/reviews/010-control-utilities-validation.md
  - /Users/josecosta/dev/promptly-docs/specs/010-control-utilities/audit.md
  - /Users/josecosta/dev/promptly-docs/findings/promptly-validation-baseline.md
---

# Audit: Promptly Swarm adoption experience

## Scope

- Goal: record what Swarm made observable during the Promptly control-utilities
  stress test, and what operational risks remained at close.
- In scope: adopted workspace shape, task/document traceability, validation
  evidence, subtask handoff surfaces, and commit linkage.
- Out of scope: judging Promptly product quality, changing Swarm templates,
  deciding follow-up requirements, or re-reviewing the Promptly code diff.

## Observations

- **Major - The adopted Promptly code repo now has an agent bootloader that
  points implementation work to a separate Swarm workspace.** Evidence:
  `/Users/josecosta/dev/promptly/AGENTS.md:3` through
  `/Users/josecosta/dev/promptly/AGENTS.md:7` identify
  `../promptly-docs/`, say specs/tasks/reviews/findings/decisions live there,
  and require implementation work to link back to task/review packets. The same
  file lists local validation commands at
  `/Users/josecosta/dev/promptly/AGENTS.md:24` through
  `/Users/josecosta/dev/promptly/AGENTS.md:33`.

- **Major - The Swarm workspace recorded a full artifact chain for one
  implementation slice.** Evidence:
  `/Users/josecosta/dev/promptly-docs/status.md:16` through
  `/Users/josecosta/dev/promptly-docs/status.md:39` list intake, research,
  PRD, inventory, audit, threat model, RFC, ADR, change plan, feature specs,
  bug report, tasks, reviews, validation review, and finding entries for the
  control-utilities work.

- **Major - The audit step exposed implementation risks that were not only
  process artifacts.** Evidence:
  `/Users/josecosta/dev/promptly-docs/specs/010-control-utilities/audit.md:38`
  through `/Users/josecosta/dev/promptly-docs/specs/010-control-utilities/audit.md:45`
  record the unreachable overlay close path and non-serializable stop payload;
  `/Users/josecosta/dev/promptly-docs/specs/014-overlay-close-cancel/bug.md:28`
  through `/Users/josecosta/dev/promptly-docs/specs/014-overlay-close-cancel/bug.md:39`
  carry the close-handler defect into a bug artifact.

- **Major - Review output preserved blocked validation instead of converting it
  into a green result.** Evidence:
  `/Users/josecosta/dev/promptly-docs/reviews/010-control-utilities-validation.md:37`
  through `/Users/josecosta/dev/promptly-docs/reviews/010-control-utilities-validation.md:41`
  record formatting and diff hygiene as Pass, TypeScript and ESLint as
  Blocked, and runtime behavior as Unverified. The validation finding preserves
  command output at
  `/Users/josecosta/dev/promptly-docs/findings/promptly-validation-baseline.md:23`
  through `/Users/josecosta/dev/promptly-docs/findings/promptly-validation-baseline.md:56`.

- **Major - The implementation is committed on Promptly `main`, while the
  supporting Swarm workspace is not a Git repository.** Evidence:
  `rtk git -C /Users/josecosta/dev/promptly show --stat --oneline --summary HEAD`
  output:

  ```text
  0245f6a feat: add settings-driven control utilities
  17 files changed, 504 insertions(+), 139 deletions(-)
  create mode 100644 .agents/skills/implement-task/SKILL.md
  create mode 120000 .claude/skills
  create mode 100644 AGENTS.md
  ```

  `/Users/josecosta/dev/promptly-docs/status.md:43` records the same commit
  hash. `rtk git -C /Users/josecosta/dev/promptly-docs status --short` exited
  128 with:

  ```text
  fatal: not a git repository (or any of the parent directories): .git
  ```

- **Minor - The artifact load was high for the size of the shipped code
  change.** Evidence:
  `/Users/josecosta/dev/promptly-docs/status.md:16` through
  `/Users/josecosta/dev/promptly-docs/status.md:39` list the full chain, while
  the Promptly commit stat above shows one small extension-control slice across
  17 files.

## Risks

- **Major - Docs/code traceability can drift when the Swarm workspace is not
  versioned with the implementation.** Fires when another agent clones or
  checks out Promptly without the local `promptly-docs` directory state; the code
  commit remains available, but the related research, PRD, specs, reviews, and
  findings are only present in the local docs folder.

- **Major - A future agent can misread `needs-human` as unfinished implementation
  rather than validation gating.** Fires when workboard state is scanned without
  opening the review packet; the status rows at
  `/Users/josecosta/dev/promptly-docs/status.md:30` through
  `/Users/josecosta/dev/promptly-docs/status.md:38` all keep
  `needs-human` or `needs-human validation` even after the Promptly `main`
  commit exists at `/Users/josecosta/dev/promptly-docs/status.md:43`.

- **Minor - Full-chain Swarm usage can bury the next action under many valid
  artifacts.** Fires when a small feature slice is processed with the complete
  optional tier; the workboard list at
  `/Users/josecosta/dev/promptly-docs/status.md:16` through
  `/Users/josecosta/dev/promptly-docs/status.md:39` is legible, but dense.

- **Minor - Validation baselines can dominate review output.** Fires when repo
  checks fail before reaching the feature under review; the validation summary
  at `/Users/josecosta/dev/promptly-docs/reviews/010-control-utilities-validation.md:39`
  and `/Users/josecosta/dev/promptly-docs/reviews/010-control-utilities-validation.md:40`
  records TypeScript and ESLint blockers outside the feature slice.

## Open questions / unverified areas

- Chrome runtime behavior remains unverified. Evidence:
  `/Users/josecosta/dev/promptly-docs/status.md:46` through
  `/Users/josecosta/dev/promptly-docs/status.md:47` ask for manual browser
  checks, and
  `/Users/josecosta/dev/promptly-docs/reviews/010-control-utilities-validation.md:41`
  marks runtime behavior Unverified.
- The audit did not inspect whether `promptly-docs` is intentionally outside Git
  or temporarily uninitialized.
- The audit did not inspect whether Promptly has a remote branch policy for
  pushing local `main` commits.

## Candidate requirements

- A future adoption guide could name how a separate docs workspace is versioned
  with its code repo.
- A future status convention could distinguish "implemented and committed, human
  runtime validation pending" from "implementation not complete".
- A future lightweight path could define which artifact types are required for
  small feature slices and which are optional stress-test coverage.
- A future validation note could separate environment-baseline failures from
  feature-regression failures in review summaries.

## Completeness table

| Item | Evidence present? | Severity | Firing condition (risks)? |
|---|---|---|---|
| O1 | yes | Major | n/a |
| O2 | yes | Major | n/a |
| O3 | yes | Major | n/a |
| O4 | yes | Major | n/a |
| O5 | yes | Major | n/a |
| O6 | yes | Minor | n/a |
| R1 | yes | Major | yes |
| R2 | yes | Major | yes |
| R3 | yes | Minor | yes |
| R4 | yes | Minor | yes |

## Self-review

- Every observation cites a file line or pasted command output.
- Every risk has a severity and firing condition.
- Dynamic claims are limited to commands whose output is pasted here or in the
  cited review/finding.
- The audit records present state and candidate requirement areas only; it does
  not edit Promptly or write a fix plan.
