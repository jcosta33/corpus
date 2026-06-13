---
type: adr
id: adr-0076
status: accepted
created: 2026-06-13
updated: 2026-06-13
---

# ADR-0076 — Worker provenance surface and the adoption-experience conventions

## Context

Two codex stress runs on a real adopter (Promptly, a browser-extension app) and a kimi hostile
read produced a corpus of field evidence (in `swarm-hq/specs/adoption-experience/` and
`specs/dx-remediation/`). CHANGE-adoption-experience cross-referenced every candidate against the
current framework and, after its own refute-by-default adversarial review (20 findings, all
confirmed), reduced the genuine, still-open, field-validated gaps to the set below. Two are
load-bearing and externally corroborated; the rest are small internal-coherence conventions the
field evidence justified directly.

- **Delegated-worker boot/provenance is invisible.** A subagent can produce scoped edits while
  leaving no artifact proving it booted as a Swarm worker — and in one job a worker that
  self-reported full boot left no task artifact at all. Anthropic's multi-agent research system
  states (verbatim) that each subagent needs an objective, output format, tool/source guidance,
  and clear boundaries, and that vague briefs cause duplicated work and coverage gaps
  [[ANTHROPIC-MULTIAGENT]](../research/sources.md#ANTHROPIC-MULTIAGENT). Swarm already names the
  task packet as the handoff and the advanced lifecycle carries a per-worker hand-off record, but
  the *core* task/review artifacts capture no boot proof.
- **Validation evidence and status hygiene drifted.** The runs surfaced: an environment that
  can't run a runtime check vs a real regression (Fail vs Blocked); rare runtime states that need
  a simulation strategy; a check that passes only on an alternate/diagnostic runtime; baseline
  blockers repeated as noise across review rows; a task packet's own `status:` drifting from the
  board so a worker booting from the packet inherited stale state; a 104-file mixed commit that
  was review-hostile; and a workspace that was never version-controlled, so code/spec
  traceability drifted.

## Decision

A single template-shape change (frozen here) plus a set of conventions, each leveled per the
honesty framework (ADR-0063). All of it is **risk-scaled and opt-in** where it touches the
everyday path — the field evidence's own caution against ceremony on clear work (ADR-0072's
run-summary discipline and docs/06's "too much packet is a cost" both stand).

1. **Worker-provenance surface (template change — frozen).** The task packet's `## Run summary`
   gains an **optional Provenance line** for delegated/worker-run tasks: sources read (`AGENTS.md`,
   task, spec, change plan), guide(s) loaded, worker identity, and **isolation mode** (worktree /
   shared tree / patch-only). Lead-run and trivial tasks omit it — the surface scales with
   delegation risk. It records *boot facts to inspect*, never a trust token, and it stays a digest
   that cites the Verify pastes, never a second copy of output (ADR-0072). *Level: convention.*

2. **Worker vs scout; who records when there is no artifact.** docs/07 distinguishes a **task
   worker** (boots from the packet, owns a write scope, leaves a run summary + provenance) from a
   **scout** (a read/research helper that produces no merge and leaves none). When a delegated
   worker authors no task file, the **lead records the Provenance line on merge-back**, per the
   existing per-worker hand-off model. A worker that produced edits with no task/handoff artifact
   at all is exactly the review exception in Decision 3. *Level: convention.*

3. **Review exception for missing boot provenance.** The review packet's Human-attention triggers
   gain "missing or unconvincing worker-boot provenance for a delegated task" — explicitly
   including silent guide/skill-activation failure (a worker can lose a guide mid-run) and the
   no-artifact case. Framed as an exception to *investigate*, not a checkbox that green-lights a
   worker. *Level: checklist.*

4. **Validation evidence — point to the canon, add only the task-creation guidance.** The Fail vs
   Blocked vs Unverified distinction is already canonical in the advanced lifecycle ("Blocked is an
   environment fix"); docs/08 gains a one-line **pointer** to it, not a restatement (single-
   sourcing). docs/06 gains: a requirement needing a rare runtime state names a **simulation or
   fixture strategy** or is marked Blocked rather than inspected as code; a foundational runtime
   **precondition is ordered as its own first requirement** so dependents read Blocked, not Fail;
   and a check that passes only on a **labeled alternate/diagnostic runtime** is recorded as
   diagnostic evidence with the primary-environment requirement staying Blocked. The existing
   `manual` and `monitor` methods and the post-merge-evidence convention are named, not reinvented.
   A check a worker's *environment* cannot run is Blocked-at-worker with validation reassigned to,
   and re-run by, the lead. *Level: convention/checklist.*

5. **Baseline vs feature in review.** A check failing for reasons outside the change's scope is
   recorded **once** as a Blocked environment-baseline note, not repeated per requirement row, and
   is distinct from a feature-regression Fail. *Level: checklist.*

6. **Closeout status hygiene — board and packet.** The review packet gains a **task-status
   confirmation** checkpoint: the reviewing session confirms the task's board row **and re-syncs
   the task packet's own `status:` frontmatter**, so a worker booting from the packet alone does
   not inherit a stale state. "Implemented and committed, human/runtime validation pending" maps to
   review `needs-human` + task `review-ready` — adopters use the existing states, never invent new
   ones. *Level: checklist.*

7. **Workspace is version-controlled.** The workspace (dedicated repo or co-located folder) must be
   committed to version control, or code/spec traceability silently drifts. *Level: convention.*

8. **Commit hygiene.** A task packet states whether the worker may run repo-wide auto-fixers; if
   so, the worker lands a **mechanical-only commit before behavior-bearing changes**, so review is
   not handed a mixed diff. *Level: convention.*

9. **Runtime isolation beyond file state.** Worktrees isolate *file* state, not *runtime* state —
   parallel tasks binding the same port, database, cache, or secret can still collide; isolate
   those per task or serialize. (Design rationale — a logical property of worktrees, not an
   empirical claim; no citation owed.) *Level: convention.*

10. **Placeholder hygiene.** An unfilled `{{placeholder}}` left in a *live* `AGENTS.md`/board is a
    workspace-validity **checklist failure** today (sharpening the existing "populated AGENTS.md"
    convention); a future `swarm init`/`swarm check` *should* enforce it. *Level: checklist;
    enforcement toolable, not shipped.*

11. **Artifact-fit pointer.** A one-line "choosing the right artifact" pointer, including the
    bug-report-vs-spec choice (a bounded polish fix against an existing spec is a bug report, not a
    new feature spec). No new template — `advanced/bug.md` already ships. *Level: convention.*

Recorded but deferred: a future `swarm run` could generate the worker handoff / launch envelope
from the task packet (*toolable*, its own ADR when built). The provenance bundle, brownfield
example, and skill-risk checklist (kimi market gaps) are additive and held to a separate change
plan.

## Alternatives considered

- **A mandatory boot checklist on every task** — rejected; re-imposes the ceremony the field
  evidence warned against. The surface is opt-in by delegation risk (Decision 1).
- **A new richer status enum** (`implemented-needs-human`, `automated pass; runtime blocked`, which
  the adopter invented) — rejected; the need maps onto the existing review `needs-human` + task
  `review-ready` (Decision 6). Growing the enum would fork the vocabulary (ADR-0057).
- **Restating the Fail/Blocked rule in docs/08** — rejected; it is canonical in the advanced
  lifecycle. docs/08 points to it (Decision 4), preserving single-sourcing.
- **A multi-worker coordination record as the default** — rejected as too heavy for single-worker
  or trivial tasks; it stays the advanced-tier form and Decision 1 is its lightweight core.
- **Shipping the orchestration as a runtime** — rejected; the orchestration research itself
  cautions against "more agents," and Swarm stays markdown-first, recording the handoff, not
  running it.

## Consequences

Accepted. Extends ADR-0072 (the run summary gains an optional provenance line; the review packet
gains a boot-provenance trigger and a task-status checkpoint) and ADR-0060/0062 (the code-repo
footprint and the per-worker hand-off, now cross-linked from the core run path). Honors ADR-0057
(new terms — worker, scout, provenance, isolation mode — are defined in the glossary and the user
tier keeps plain language) and ADR-0063 (every rule above carries a level; nothing claims
enforcement without a shipped tool). The template-shape change propagates in lockstep to the kit,
the swarm-cli `scaffold/` mirror, and any hq copy. One new `sources.md` entry
([[ANTHROPIC-MULTIAGENT]], first-party, web-verified, never a `MUST`) grounds the subagent-brief
direction; the runtime-isolation point is design rationale (no citation owed); the EU AI Act
regulatory rationale and the kimi market statistics are explicitly **not** load-bearing here and
are deferred with the provenance-bundle work.

## Propagation

task template (Provenance line), review template (boot-provenance trigger + Task-status section),
docs/06 (rare-state/precondition/commit-hygiene), docs/07
(worker-vs-scout, isolation recorded, runtime-isolation caution), docs/08 (Fail/Blocked pointer,
baseline-vs-feature, diagnostic-runtime evidence, closeout state mapping), docs/04 + artifact-formats (manual/monitor,
bug-vs-spec pointer, the new Run-summary Provenance line + review Task-status section + the
extended Human-attention trigger list), docs/03 + ADOPTING (workspace version-controlled),
checks.md (placeholder as checklist failure), future-cli (placeholder gate + handoff-generator
note), **checks/checks.yaml v0.4.1** (review `Task status` added to `optional_sections`;
`trigger-coverage` gains the worker-boot-provenance trigger — the heading-for-heading
reconciliation duty in checks/README), glossary (worker · scout · provenance · isolation mode),
research/sources.md (one entry: [[ANTHROPIC-MULTIAGENT]]), swarm-cli scaffold resync + its
`AGENTS.md` contract-version reference, ledger row.
