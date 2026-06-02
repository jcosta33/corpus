# 📖 Reference: Task base skeleton

> The shared sections every task template includes. Each workflow skill's `references/task-template.md` (and the two flat skill-less templates, `task-orchestration.md` and `task-review.md`) extends this base; this doc is the canonical statement of what every task file looks like. The base itself lives at `.agents/templates/task-base.md`.

---

## 📐 The skeleton

```markdown
# {{title}}

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

## Skills to load

Skills self-activate by description match — load the ones whose `description` fits the work in front of you. There is no always-loaded skill.

- The **workflow skill** for this task type (e.g. `write-feature`, `write-fix`, `write-audit`).
- The **quality gates** whose descriptions match (`empirical-proof` on any task with verifiable claims, `adversarial-review` on review/audit passes, `distillation-discipline` when transforming an upstream doc).
- The **suggested persona**: a `persona-<slug>` skill if one matches the work (8 ship as skills); otherwise the mindset is carried by the workflow skill itself. Record the choice — and any divergence from the suggested default — in `## Decisions`.

---

## Domain skills

- (Project-specific skills under `.agents/skills/domain/`, loaded by description-matching to the work.)

---

## Constraints

- Work only inside this worktree
- Do not switch branches unless explicitly instructed
- Do not merge, rebase, or push unless explicitly instructed
- (Task-type-specific constraints — e.g., "no source file changes" for read-only sessions; "run cmdValidate after every batch" for code-producing sessions.)
- (Persona's forbidden actions, copied or summarised.)
- **Proactively research and read related docs.** (Permitted directories listed.)

---

## (Type-specific blocks)

Per task type, additional sections are inserted here. They live in each workflow skill's `references/task-template.md`, or — for the two skill-less task types — in the flat `templates/` file:

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
- `write-spec`: `## Pattern survey`
- `write-research`: `## Research question`, `## Sources to consult`, `## Findings outline`
- `task-orchestration.md` (flat): `## Worker tracker`, `## Kickback queue`, `## Merge log`
- `task-review.md` (flat): `## Diff overview`, `## Findings`, `## Verdict`

---

## Plan

(Step-by-step, written before implementation begins.)

---

## Progress checklist

(Discrete items, marked as they complete.)

- [ ] (item)

---

## Decisions

(Significant choices made during the session, with rationale.)

- ***

---

## Findings

(Codebase discoveries worth preserving. Promote durable findings to upstream docs before close.)

- ***

---

## Assumptions

(Every assumption marked `[pending]` or `[confirmed]`.)

- [pending]

---

## Blockers

(Anything preventing confident progress, recorded immediately.)

- ***

---

## Next steps

(Concrete starting points if the session ends incomplete.)

- ***

---

## Self-review

<self_review>

(Persona-specific framing — see each task page for the questions.)

> **Hard gate.** The task is not complete until every question below has a written answer directly beneath it.

### Verification outputs (paste actual command output — do not paraphrase)

- (per-task slot list)

### (persona-specific Self-review questions)

- ...

### Final Polish

- (the standing "what did I leave behind" question)

Only when every answer above is written is this task complete.

</self_review>
```

---

## 🪞 Sections the launcher pre-fills (recommended routing)

A launcher (CLI or human) may pre-fill these from the recommended route; the agent confirms or re-assesses:

- `## Metadata` — fully filled (slug, branch, etc.)
- `> 🔒 ⚠️` markers and the `> **AGENTS.md:**` command-resolution note — set by task type
- `## Skills to load` — the suggested workflow skill, quality gates, and a `persona-<slug>` skill if one matches (else the workflow skill carries the mindset)
- `## Constraints` — base constraints + the suggested persona's forbidden actions
- Per-task verification slot list (the `{{cmd*}}` placeholders) — set by task type
- `## Self-review` skeleton with persona-specific questions — set by the suggested persona

---

## 🪞 Sections the agent fills in

- `## Objective` (rephrased from source doc)
- `## Linked docs` (the launcher provides the primary; the agent adds related)
- `## Plan`
- `## Progress checklist` (the agent ticks off as they go)
- `## Decisions`
- `## Findings`
- `## Assumptions`
- `## Blockers`
- `## Next steps`
- `## Self-review` answers + verification outputs

---

## See also

- [`tasks/`](../tasks/) — every per-task template extends this base
- [`document-base.md`](document-base.md) — the doc equivalent
- [`template-placeholders.md`](template-placeholders.md) — what `{{slug}}`, `{{cmdX}}`, etc. mean, and the dual command contract
- [`reference/agents-md.md`](agents-md.md) — the `## Commands` section the `{{cmd*}}` slots resolve from
