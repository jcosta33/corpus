# {{title}}

> This file documents the **shared task skeleton** every type-specific task template extends. It is not itself launched as a task. Each workflow skill ships its own `references/task-template.md` (e.g. `write-feature`, `write-audit`) that includes these sections plus its own additions; the two skill-less task types keep flat templates here (`task-orchestration.md`, `task-review.md`).

## Metadata

- Slug: {{slug}}
- Agent: {{agent}}
- Branch: {{branch}}
- Base: {{baseBranch}}
- Worktree: {{worktreePath}}
- Created: {{createdAt}}
- Status: active
- Type: <task-type>

---

> 🔒 / ⚠️ / 🧪 / 📚 **<TASK TYPE> SESSION** — short descriptor of the session's discipline.
>
> **AGENTS.md:** `{{cmdValidate}}` / `{{cmdTest}}` / `{{cmdInstall}}` resolve from `AGENTS.md > Commands`. Non-contract values (`{{cmdBenchmark}}`, `{{cmdValidateDeps}}`, `{{cmdTypecheck}}`) — ask the user. If `AGENTS.md` is missing, ask before substituting.

---

## Objective

What is true when this task is done. One paragraph maximum.

---

## Linked docs

- Source doc: `{{specFile}}` (or `{{auditFile}}`, `{{bugReport}}`, etc.)
- Related research / audit / ADR / constitution: `<paths>`

---

## Parent contract

(Present **only when an orchestration spawned this task** — the Lead Engineer fills it from the worker-tracker row before hand-off; it is this worker's lane. Omit for top-level tasks.)

- **Owned paths:** `<paths this worker may modify>`
- **Forbidden paths:** `<paths owned by sibling workers — do not touch>`
- **Expected deliverable:** `<what this worker must produce>`
- **Acceptance bar:** `<what the parent will review the result against>`

Stay inside the owned paths. If the work requires touching a forbidden path, halt and surface it to the orchestration — do not silently widen scope; that is how parallel writers collide.

---

## Skills to load

Skills self-activate by description match — load the ones whose `description` fits the work in front of you:

- The **workflow skill** for this task type (e.g. `write-feature`, `write-fix`, `write-audit`).
- The **quality gates** whose descriptions match (`empirical-proof` on any task with verifiable claims, `adversarial-review` on review/audit passes, `distillation-discipline` when transforming an upstream doc).
- The **suggested persona** (a `persona-<slug>` skill if one matches the work; otherwise the mindset is carried by the workflow skill itself). Record the choice — and any divergence from the suggested default — in `## Decisions`.

There is no always-loaded skill. Install and load only what the work needs.

---

## Domain skills

- (Project-specific skills under `.agents/skills/domain/`, loaded by description-matching to the work.)

---

## Constraints

- Work only inside this worktree
- Do not switch branches unless explicitly instructed
- Do not merge, rebase, or push unless explicitly instructed
- (Task-type-specific constraints)
- (Persona's forbidden actions, summarised)
- **Proactively research and read related docs.** Browse `.agents/specs/`, `.agents/audits/`, `.agents/research/`, `.agents/bugs/`, `docs/`, `AGENTS.md`, and the project skills directory as needed.

---

## (Type-specific blocks)

Per task type, additional sections are inserted here. See each skill's `references/task-template.md` (or the flat template for skill-less types):

- `write-feature`: (no extra blocks beyond Objective + Linked docs)
- `write-fix`: `## Reproduction`
- `write-refactor`: `## Before / after state`, `## Shim contracts`
- `write-rewrite`: `## Behavior delta`, `## Acceptance criteria`, `## Module plan`
- `write-migration`: `## Migration source and target`, `## Wave plan`, `## Compatibility shims`, `## Callsite tracker`
- `write-performance`: `## Baseline`, `## Target`, `## Hypothesis`, `## Measurement protocol`
- `write-testing`: `## Coverage gap`, `## Test cases`, `## Test placement`
- `write-documentation`: `## Doc target`, `## Source material`, `## Examples to verify`
- `write-bug-report`: `## Reported behavior`, `## Reproduction attempts`, `## Reliable reproduction`, `## Hypothesis tracker`, `## Root cause`
- `write-audit`: `## Goal`, `## Scope`, `## Code paths to inspect`
- `write-research`: `## Research question`, `## Sources to consult`, `## Findings outline`
- `task-orchestration.md` (flat): `## Worker tracker`, `## Kickback queue`, `## Merge log`
- `task-review.md` (flat): `## Diff overview`, `## Findings`, `## Verdict`

---

## Plan

(Step-by-step, written before implementation begins.)

1.
2.
3.

---

## Progress checklist

(Discrete items, marked as they complete. Each template ends the checklist with one Self-review item per Self-review question.)

- [ ] (item)

---

## Decisions

(Significant choices made during the session, with rationale. Record which skills and persona were loaded, and any divergence from the suggested default.)

- ***

## Findings

(Codebase discoveries worth preserving. Promote durable findings to upstream docs before close.)

- ***

## Assumptions

(Every assumption marked `[pending]` or `[confirmed]`.)

- [pending]

---

## Blockers

(Anything preventing confident progress, recorded immediately.)

- ***

## Next steps

(Concrete starting points if the session ends incomplete.)

- ***

---

## Self-review

Stop. (Persona-specific framing — see each task template for the opening stance and questions.)

> **Hard gate.** The task is not complete until every question below has a written answer directly beneath it.

### Verification outputs (paste actual command output — do not paraphrase)

This block lists **one paste slot per REQUIRED command for this task type**, drawn from `AGENTS.md > Commands` and fixed by the per-task-type required-suite matrix (the "Task type → verification commands" Self-review column in the recommended-routing reference). Every slot carries verbatim output — never a paraphrase, never "passed". A slot that genuinely cannot run is marked `n/a` with a one-line reason (or recorded in `## Blockers`), not silently dropped.

- `git status` → (only the intended files changed; no orphans)
- (one slot per required command for this task type — e.g. `{{cmdValidate}}` / `{{cmdTest}}` last 2 lines — plus any task-type-specific oracle, such as a fail-before/pass-after regression check)

### (persona-specific Self-review questions)

- ...
  Answer:

### Final Polish

- Did you ask yourself: "What did I leave behind? Did I actually run all the gates, or did I trust my memory?" Do not leave the work without this final adversarial pass.
  Answer:

Only when every answer above is written is this task complete.
