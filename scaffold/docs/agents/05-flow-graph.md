# 05 · The flow graph

> The recommended mapping between documents, tasks, and personas. This is the core of the framework's conditioning model: pick a source document and a default task type, suggested persona, skills, and verification commands all follow. They are defaults — the agent may re-assess and route differently when the work in front of it doesn't match.

This document is reference material — agents consult it when deciding what to do. A launcher (the Swarm CLI or any compatible tool) **may** apply this graph deterministically when it scaffolds a task file, and the directive skill `description`s reproduce the routing in-session. But none of it is gatekeeper-enforced: when the task doesn't match the suggested default, load the skill whose `description` fits and record the divergence in your task file's `## Decisions`.

For the personas referenced here, see the `persona-<slug>` skills under `.agents/skills/` (eight ship as skills). For the documentation tiers, see `01-process.md`. For document types and their structure, see `02-file-types.md`.

---

## The pipeline

```
┌──────────────────┐
│  Source document │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐    Default by document type (agent may re-assess):
│    Task type     │    audit → refactor, spec → feature, etc.
└────────┬─────────┘
         │
         ▼
┌──────────────────┐    Suggested by task type (agent may re-assess):
│     Persona      │    refactor → Janitor, feature → Builder, etc.
└────────┬─────────┘
         │
         ▼
┌──────────────────┐    Skills self-activate by directive description;
│  Conditioned     │    verification commands referenced. Worktree +
│   task.md        │    branch created. Agent CLI launches.
└──────────────────┘
```

Information flows in one direction along the verbosity gradient: high-level to low-level, never back.

```
research.md  ──▶  spec.md       ──▶  task.md   (feature)
research.md  ──▶  audit.md      ──▶  task.md   (refactor)
research.md  ──▶  bug-report.md ──▶  task.md   (fix)

research.md is OPTIONAL — only when training data is insufficient
```

Task files are terminal. They never feed another doc; durable findings are promoted to audits, specs, or research before the session closes.

---

## Document → task type

Every document the human (or an upstream agent) hands to the framework has a recommended default task type. A launcher may apply the default automatically; the user can override at session start, and the agent may re-assess once it reads the source doc and record any divergence in `## Decisions`.

| Source document                              | Default task type                                                    | Why                                                                              |
| -------------------------------------------- | -------------------------------------------------------------------- | -------------------------------------------------------------------------------- |
| `spec.md`                                    | feature                                                              | The spec describes a new capability to build                                     |
| `audit.md`                                   | refactor                                                             | The audit identifies cleanup work to do                                          |
| `bug-report.md`                              | fix                                                                  | The report describes a defect to repair                                          |
| `research.md` (technical)                    | spec-writing                                                         | Research is upstream input; the next step is translating into a spec             |
| `research.md` (UX/market)                    | spec-writing                                                         | Same — translate findings into requirements                                      |
| _none — initial human ask_                   | research-writing / spec-writing / audit-writing / bug-report-writing | A "blank slate" ask kicks off an authoring task; which one depends on the prompt |
| _another agent's branch_                     | review                                                               | Lead Engineer or Skeptic reviewing finished work                                 |
| _multiple source docs (e.g. 5 specs)_        | orchestration                                                        | Lead Engineer decomposes and delegates                                           |
| _existing audit + new investigation request_ | deepen-audit                                                         | Skeptic re-walks an existing audit                                               |
| `migration plan`                             | migration                                                            | Mechanical change across many call sites                                         |
| `benchmark report`                           | performance                                                          | Optimisation with measured baseline                                              |
| `cleanup list`                               | refactor                                                             | Janitor proves deletion safety                                                  |
| `test plan`                                  | testing                                                              | New test coverage from a structured plan                                         |

### Edges the routing strongly discourages

These aren't gatekeeper-enforced, but the routing model treats them as anti-patterns. If you take one of them anyway, document why in `## Decisions`.

- **research → fix** — discouraged. Research should go through a spec or audit before becoming actionable. Implementing directly from research means skipping the stage whose job is to translate.
- **spec → refactor** — uncommon. Refactor tasks are driven by audits. If a spec calls for restructuring, the spec is implicitly the refactor's plan, but the task is still tracked as a feature unless the change is purely structural.
- **bug-report → refactor** — discouraged. A bug report drives a fix, not a cleanup. If fixing the bug reveals broader cleanup needs, surface them as findings; do not expand scope silently.
- **audit → feature** — discouraged. Audits do not specify new features; they describe current state and recommend cleanup. If the audit's recommended approach is "build something new", the next step is a spec, not a feature task.

---

## Task type → persona

Each task type has a **suggested** primary persona. Some have secondary personas for handoff (e.g. a feature task ends with a Skeptic review; a refactor task ends the same way). These are defaults, not assignments — the agent adopts the suggested mindset unless the work calls for a different one.

Of the persona mindsets named below, **eight ship as standalone skills**: Architect, Auditor, Janitor, Migrator, Performance Surgeon, Skeptic, Surveyor, and Lead Engineer (`.agents/skills/persona-<slug>/SKILL.md`). The other five lead personas are **mindsets carried by the matching workflow skill**, not separate skills: Builder by `write-feature`, Bug Hunter by `write-bug-report`, Documentarian by `write-documentation`, Test Author by `write-testing`, Researcher by `write-research`. Lead Engineer ships as `persona-lead-engineer` precisely because orchestration has **no** workflow skill — so the coordination mindset is itself the discipline, and `persona-lead-engineer` carries it.

| Task type                    | Primary persona                                               | Secondary (handoff)                                                                                                           |
| ---------------------------- | ------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------- |
| feature                      | The Builder                                                   | The Skeptic (review)                                                                                                          |
| fix                          | The Skeptic                                                   | — (the framework's existing convention is that fix sessions adopt the Skeptic mindset because root-causing demands hostility) |
| refactor                     | The Janitor                                                   | The Skeptic (review)                                                                                                          |
| rewrite                      | The Builder                                                   | The Skeptic (review)                                                                                                          |
| spec-writing                 | The Architect                                                 | —                                                                                                                             |
| research-writing (technical) | The Researcher                                                | —                                                                                                                             |
| research-writing (UX/market) | The Surveyor                                                  | —                                                                                                                             |
| audit-writing                | The Auditor                                                   | —                                                                                                                             |
| bug-report-writing           | The Bug Hunter                                                | —                                                                                                                             |
| migration                    | The Migrator                                                  | The Skeptic (review of each wave)                                                                                             |
| performance                  | The Performance Surgeon                                       | The Skeptic (review)                                                                                                          |
| testing                      | The Test Author                                               | The Skeptic (review)                                                                                                          |
| documentation                | The Documentarian                                             | The Skeptic (review)                                                                                                          |
| review                       | The Skeptic                                                   | —                                                                                                                             |
| deepen-audit                 | The Skeptic                                                   | —                                                                                                                             |
| orchestration                | The Lead Engineer                                             | The Skeptic (the merge-gate review pass adopts this stance)                                                                   |
| integration                  | The Builder                                                   | The Skeptic (review)                                                                                                          |
| upgrade                      | The Migrator                                                  | The Skeptic (review of each wave)                                                                                             |
| kickback                     | The Builder (or whichever persona produced the original work) | The Skeptic (re-review after fix)                                                                                             |

A project may override the suggested primary persona for any task type — via launcher configuration, or simply because the agent re-assesses in-session and loads a different `persona-<slug>` skill. Record the choice in `## Decisions`. A common override: a team that prefers minimality-focus over adversarial-focus may route fix tasks toward the Janitor mindset rather than the Skeptic.

---

## Task type → skills attached

There is **no always-loaded skill**. Skills self-activate by their directive `description` — each one fires when its triggers match the work in front of you. The table below lists the skills that *typically* match each task type; treat it as a guide, not a load order.

| Task type          | Skills that typically match                                 |
| ------------------ | ----------------------------------------------------------- |
| feature            | `write-feature`, `empirical-proof`                          |
| fix                | `write-fix`, `adversarial-review`, `empirical-proof`        |
| refactor           | `write-refactor`, `empirical-proof`                         |
| rewrite            | `write-rewrite`, `empirical-proof`                          |
| spec-writing       | `write-spec`, `distillation-discipline`                     |
| research-writing   | `write-research`, `distillation-discipline`                 |
| audit-writing      | `write-audit`, `adversarial-review`                         |
| bug-report-writing | `write-bug-report`, `adversarial-review`, `empirical-proof` |
| migration          | `write-migration`, `empirical-proof`                        |
| upgrade            | `write-migration`, `empirical-proof`                        |
| performance        | `write-performance`, `empirical-proof`                      |
| testing            | `write-testing`, `empirical-proof`                          |
| documentation      | `write-documentation`, `distillation-discipline`, `empirical-proof` |
| review             | `adversarial-review`, `empirical-proof`                     |
| deepen-audit       | `write-audit`, `adversarial-review`, `empirical-proof`      |
| orchestration      | `adversarial-review`, `empirical-proof`                     |
| integration        | `write-feature`, `empirical-proof`                          |
| kickback           | (same as the original task type) + `adversarial-review`     |

Project-specific skills under `.agents/skills/domain/` (architecture-violations, testing-file-layout, etc.) self-activate the same way when their `description` matches the task domain.

---

## Task type → verification commands

Each task type fires verification commands at specific phases. The commands themselves come from your project's bindings in `AGENTS.md`; the table below shows *when* they fire.

| Task type          | Pre-implementation                    | Periodic                         | Post-implementation                                              | Self-review                         |
| ------------------ | ------------------------------------- | -------------------------------- | ---------------------------------------------------------------- | ----------------------------------- |
| feature            | `cmdInstall`                          | `cmdValidate` after each batch   | `cmdValidate`, `cmdTest`                                         | All above                           |
| fix                | `cmdInstall`                          | —                                | `cmdValidate`, `cmdTest`                                         | + `git diff --stat`                 |
| refactor           | `cmdInstall`                          | `cmdValidateDeps` every 10 files | `cmdValidateDeps`, `cmdTypecheck`                                | All above                           |
| rewrite            | `cmdInstall`                          | `cmdValidate` after each module  | `cmdValidate`, `cmdTest`                                         | All above                           |
| spec-writing       | —                                     | —                                | `git status` (must be clean on source)                           | + `git status`                      |
| research-writing   | —                                     | —                                | `git status`                                                     | + `git status`                      |
| audit-writing      | —                                     | —                                | `git status`                                                     | + `git status`                      |
| bug-report-writing | —                                     | —                                | `git status` (the reproduction proof is its own verification)    | + reproduction output               |
| migration          | `cmdInstall`                          | `cmdValidate` after each wave    | `cmdValidate`, `cmdTest`                                         | All above                           |
| upgrade            | `cmdInstall`                          | `cmdBuild` + `cmdValidate` per wave | `cmdBuild`, `cmdValidate`, `cmdTest`                          | All above                           |
| performance        | `cmdInstall`, baseline `cmdBenchmark` | `cmdTest` after each change      | target `cmdBenchmark`, `cmdTest`                                 | All above                           |
| testing            | `cmdInstall`                          | `cmdTest` after each new test    | `cmdTest`, coverage report                                       | All above + assertion-flip proof    |
| documentation      | —                                     | —                                | run any code examples                                            | + example output                    |
| review             | `cmdInstall`                          | —                                | `cmdValidate`, `cmdTest` (run yourself, not trusting the worker) | + `git diff` of branch under review |
| deepen-audit       | `cmdInstall`                          | —                                | `cmdValidate`, `cmdValidateDeps` (where structural claims rely)  | All above                           |
| orchestration      | `cmdInstall`                          | per-worker review pass           | merged-branch `cmdValidate`, `cmdTest`                           | + per-worker review log             |
| integration        | `cmdInstall`                          | `cmdValidate` after each batch   | `cmdValidate`, `cmdTest` (incl. integration)                     | All above                           |

---

## Recursion

A task can spawn sub-tasks. The conditioning pipeline runs recursively at each level, with no special cases — each sub-task is itself a (source doc, task type, persona) triple.

The most common recursion is the Lead Engineer pattern:

```
human → orchestration task (Lead Engineer)
            │
            ├── feature task (Builder, on spec A)
            ├── feature task (Builder, on spec B)
            ├── refactor task (Janitor, on audit C)
            └── feature task (Builder, on spec D)
```

Each child task gets its own worktree, branch, conditioned task file, and agent CLI session. The Lead Engineer's task file tracks all children — slug, branch, status, last review verdict.

The recursion limit is set per project (CLI concern). Default: 2 (a Lead Engineer may spawn workers, and those workers are not themselves Lead Engineers). Higher limits permit Lead-Engineer-of-Lead-Engineers patterns; raise carefully.

---

## Subagent strategy

The framework's position on parallelism (per the field consensus that converged through 2025-2026):

- **Read-side parallelism is permitted.** Research, audit, and review tasks may run in subagents (separate context windows reporting back digests).
- **Write-side parallelism is forbidden.** Implementation tasks (feature, fix, refactor, migration) run in the main thread; the Lead Engineer pattern serialises writes through a single-threaded merge protocol.

Two Builders must never write to the same file at the same time. The Lead Engineer's decomposition rule: **disjoint file scopes**.

---

## Kickback

When the Skeptic rejects a worker's branch, the rejection itself becomes a conditioned task. The kickback is a (source doc + skeptic notes) → fix task triple. The original worker (or a fresh agent in the same persona) takes the kickback notes as additional input.

```
Builder finishes feature task
         │
         ▼
Skeptic reviews (review task)
         │
   ┌─────┴─────┐
   │           │
 PASS       FAIL → kickback task
                       │ (source: original spec + skeptic notes)
                       │ (task type: feature kickback)
                       │ (persona: Builder)
                       ▼
                   Builder revises
                       │
                       ▼
                Skeptic reviews again
```

A kickback is a normal task with normal conditioning. The only special input is the Skeptic's notes — they ride alongside the original spec in `## Linked docs`.

Round limit (recommendation, not hard rule): 3. After 3, escalate (re-spec / re-scope / abandon / human).

---

## Edge cases

**Ambiguous source document.** If a doc is unclear — a research file that's really an audit, a spec that contains too much current-state — the launcher (or the agent) should ask the human to confirm the doc type rather than guess. The framework strongly prefers explicit reclassification over silent re-routing.

**No source document.** A "blank slate" ask kicks off an authoring task. The authoring type follows from the human's prompt — "research X", "audit Y", "spec Z", "find the bug in W"; if neither the launcher nor the agent can tell, ask.

**Multiple source docs.** A task may legitimately have multiple sources (spec + research, audit + research, original spec + skeptic notes for a kickback). All sources go in `## Linked docs`. The task type follows the *primary* source's routing rule.

**No research, no spec.** Trivial tasks may skip the docs entirely — see `01-process.md` on what counts as trivial. For non-trivial work, document the skip in the task file's `## Decisions` with the reason.

**Research that's sufficient without a spec.** Strongly discouraged. If you find yourself implementing directly from research, stop and write the spec first. Research is input; spec is contract. The framework leans hard against this because the failure mode (drift between research findings and implementation) is severe and silent — skip the spec only with an explicit, recorded reason.

---

## Decision flow when starting a task

```
Does a source document exist?
├── No → authoring task
│         │
│         └── Which authoring type matches the human's ask?
│             ├── "research X"      → research-writing
│             ├── "audit Y"         → audit-writing
│             ├── "spec Z"          → spec-writing
│             └── "find bug W"      → bug-report-writing
│
└── Yes → look up the source doc type in "Document → task type" above
              │
              └── Route to the default task type
                       │
                       └── Look up persona in "Task type → persona"
                                │
                                └── Attach skills, inject commands, scaffold task file
```

A launcher may run this routing for you when it scaffolds the task file; the agent then reads the conditioned task file and adopts the persona named in the `> **PERSONA:**` blockquote. But the agent stays in the loop: if the source doc or the ask doesn't fit the routed default, re-assess, load the skill whose `description` matches, and record the divergence in `## Decisions`.

---

## See also

- `01-process.md` — the documentation-first workflow
- `02-file-types.md` — what each document type contains
- `03-workflow.md` — step-by-step session flow
- `04-standards.md` — writing and execution standards
- `.agents/skills/persona-<slug>/SKILL.md` — the eight shipped persona skills (Architect, Auditor, Janitor, Migrator, Performance Surgeon, Skeptic, Surveyor, Lead Engineer)
