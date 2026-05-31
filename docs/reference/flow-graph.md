# 📖 Reference: The flow graph

> Swarm's **recommended routing**: the mapping from source documents to task types, suggested personas, the skills worth loading, and the verification commands. The operational form of [`concepts/07-flow-graph.md`](../concepts/07-flow-graph.md).
>
> This is guidance, not a gatekeeper. A launcher (the Swarm CLI or any compatible tool) **may** apply it deterministically when it scaffolds a task file, and the directive skill `description`s reproduce it in-session. But nothing forces the route: when the work in front of you doesn't match the suggested default, load the skill whose `description` fits and record the divergence in your task file's `## Decisions`. ADR 0002 (personas 1:1 with task types) is superseded — the mappings below are *suggested defaults*, and the agent may re-assess.

---

## 🪞 Pipeline overview

```
┌──────────────────┐
│  Source document │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐    Suggested by document type
│    Task type     │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐    Suggested by task type
│  Persona (mindset)│
└────────┬─────────┘
         │
         ▼
┌──────────────────┐    Skills worth loading + verification commands
│  Conditioned     │
│   task.md        │
└──────────────────┘
```

Information flows downhill: research → spec/audit/bug-report → task → terminal output. Each arrow above is a *suggested default*, not a forced edge.

---

## 📋 Document → task type

| Source document                                | Default task type                                                    | Why                                                                              |
| ---------------------------------------------- | -------------------------------------------------------------------- | -------------------------------------------------------------------------------- |
| `spec.md`                                      | `feature`                                                            | The spec describes a new capability to build                                     |
| `audit.md`                                     | `refactor`                                                           | The audit identifies cleanup work to do                                          |
| `bug-report.md`                                | `fix`                                                                | The report describes a defect to repair                                          |
| `research.md` (technical)                      | `spec-writing`                                                       | Research is upstream input; next step is translating into a spec                |
| `research.md` (UX/market)                      | `spec-writing`                                                       | Same                                                                             |
| _none — initial human ask_                     | `research-writing` / `spec-writing` / `audit-writing` / `bug-report-writing` | Authoring task; type depends on the prompt                              |
| _another agent's branch_                       | `review`                                                             | Lead Engineer or Skeptic reviewing finished work                                 |
| _multiple source docs (e.g., 5 specs)_         | `orchestration`                                                      | Lead Engineer decomposes and delegates                                           |
| _existing audit + new investigation request_   | `deepen-audit`                                                       | Skeptic re-walks an existing audit                                               |
| `migration plan`                               | `migration`                                                          | Mechanical change across many call sites                                         |
| `benchmark report`                             | `performance`                                                        | Optimisation with measured baseline                                              |
| `cleanup list`                                 | `refactor`                                                           | Janitor proves deletion safety                                                  |
| `test plan`                                    | `testing`                                                            | New test coverage from a structured plan                                         |

### Discouraged edges

These edges are **routing smells**, not hard blocks. No skill enforces them — instead, the relevant directive skill `description`s encode them ("Skip this skill for …", "Do not start … without …"), and a launcher may warn on them. When you take one of these edges anyway, name the reason in `## Decisions`.

| Discouraged                                     | Why it's a smell                                                       |
| ----------------------------------------------- | ---------------------------------------------------------------------- |
| `research → fix` (skipping spec/audit)          | Research is input. Implementation usually wants a translating doc.     |
| `spec → refactor`                               | Refactor work is normally driven by audits, not specs                  |
| `bug-report → refactor`                         | A bug-report normally drives a fix, not a cleanup                      |
| `audit → feature`                               | Audits describe current state; they don't usually specify new features |
| `code → spec` (back-fill)                       | Specs are forward-looking; back-filling is documentation, not a spec   |
| `task with no source doc and no task scope`     | Every task should be grounded (a one-paragraph scope is enough)        |
| `one source doc → multiple task types`          | Prefer splitting the work, or routing through orchestration            |
| `multiple source docs → one task`               | Prefer one source per task (or use orchestration)                      |
| `task file authored after implementation begins` | Condition before you act                                              |
| `durable findings left only in the task file`   | Task files are gitignored — promote findings upstream before close     |

---

## 🎯 Task type → suggested persona

Each row is a **suggested default**, not a binding. The `docs/personas/` catalogue describes 13 mindsets, but only **8 ship as skills** (`persona-{architect,auditor,janitor,lead-engineer,migrator,performance-surgeon,skeptic,surveyor}`). The other 5 mindsets are carried by the matching workflow skill: Builder → `write-feature`, Bug Hunter → `write-bug-report`, Documentarian → `write-documentation`, Test Author → `write-testing`, Researcher → `write-research`. Lead Engineer ships as `persona-lead-engineer` because orchestration has no workflow skill to carry its discipline — the coordination mindset is the discipline ([ADR 0025](../adrs/0025-orchestration-coordination-artifact.md)). The "Persona skill?" column says how the suggested mindset is delivered.

| Task type                       | Suggested persona       | Persona skill?                                          | Secondary (handoff)             |
| ------------------------------- | ----------------------- | ------------------------------------------------------- | ------------------------------- |
| `feature`                       | The Builder             | mindset in `write-feature`                              | The Skeptic (review)            |
| `fix`                           | The Skeptic             | `persona-skeptic`                                       | (kickback returns to original)  |
| `refactor`                      | The Janitor             | `persona-janitor`                                       | The Skeptic (review)            |
| `rewrite`                       | The Builder             | mindset in `write-rewrite`                              | The Skeptic (review)            |
| `spec-writing`                  | The Architect           | `persona-architect`                                     | —                               |
| `research-writing` (technical)  | The Researcher          | mindset in `write-research`                             | —                               |
| `research-writing` (UX/market)  | The Surveyor            | `persona-surveyor`                                      | —                               |
| `audit-writing`                 | The Auditor             | `persona-auditor`                                       | —                               |
| `bug-report-writing`            | The Bug Hunter          | mindset in `write-bug-report`                           | —                               |
| `migration`                     | The Migrator            | `persona-migrator`                                      | The Skeptic (review per wave)   |
| `upgrade`                       | The Migrator            | `persona-migrator`                                      | The Skeptic (review per wave)   |
| `performance`                   | The Performance Surgeon | `persona-performance-surgeon`                           | The Skeptic (review)            |
| `testing`                       | The Test Author         | mindset in `write-testing`                              | The Skeptic (review)            |
| `documentation`                 | The Documentarian       | mindset in `write-documentation`                        | The Skeptic (review)            |
| `review`                        | The Skeptic             | `persona-skeptic`                                       | —                               |
| `deepen-audit`                  | The Skeptic             | `persona-skeptic`                                       | —                               |
| `orchestration`                 | The Lead Engineer       | `persona-lead-engineer` (no workflow skill; flat template) | The Skeptic (merge-gate pass)   |
| `integration`                   | The Builder             | mindset in `write-feature`                              | The Skeptic (review)            |
| `kickback`                      | (original persona)      | (whichever delivered the original mindset)              | The Skeptic (re-review)         |

The project may override the suggested persona for any task type (a launcher concern). The agent may also re-assess in-session — load the `persona-<slug>` skill whose `description` fits, or rely on the workflow skill's own mindset, and note the choice in `## Decisions`.

---

## 🛠️ Task type → skills worth loading

There is **no always-loaded skill**. Each row lists the skills whose `description`s typically match the work; they self-activate when their triggers fire. The three quality gates (`empirical-proof`, `adversarial-review`, `distillation-discipline`) are cross-cutting — they surface inside whatever task is in play whenever their trigger is present (a verifiable claim, a review pass, an upstream-doc transformation). A suggested `persona-<slug>` skill loads on its own `description` for the 8 personas that ship as skills; the other mindsets ride along with their workflow skill.

| Task type             | Skills worth loading                                          |
| --------------------- | ------------------------------------------------------------- |
| `feature`             | `write-feature`, `empirical-proof`                            |
| `fix`                 | `write-fix`, `adversarial-review`, `empirical-proof`          |
| `refactor`            | `write-refactor`, `empirical-proof`                           |
| `rewrite`             | `write-rewrite`, `empirical-proof`                            |
| `spec-writing`        | `write-spec`, `distillation-discipline`                       |
| `research-writing`    | `write-research`, `distillation-discipline`                   |
| `audit-writing`       | `write-audit`, `adversarial-review`                           |
| `bug-report-writing`  | `write-bug-report`, `adversarial-review`, `empirical-proof`   |
| `migration`           | `write-migration`, `empirical-proof`                          |
| `upgrade`             | `write-migration`, `empirical-proof`                          |
| `performance`         | `write-performance`, `empirical-proof`                        |
| `testing`             | `write-testing`, `empirical-proof` (+ `fix-flaky-test` if a test is flaky) |
| `documentation`       | `write-documentation`, `distillation-discipline`, `empirical-proof` |
| `review`              | `adversarial-review`, `empirical-proof`                       |
| `deepen-audit`        | `write-audit`, `adversarial-review`, `empirical-proof`        |
| `orchestration`       | `persona-lead-engineer`, `adversarial-review`, `empirical-proof` (no workflow skill; flat template) |
| `integration`         | `write-feature`, `empirical-proof`                            |
| `kickback`            | (same workflow skill as the original task type) + `adversarial-review` |

Project-specific skills under `.agents/skills/domain/` self-activate in addition, by description-matching to the task domain.

---

## 🔌 Task type → verification commands

The framework defines **slots**; the project binds slots to commands via `AGENTS.md > Commands` ([ADR 0021](../adrs/0021-verification-contract.md)). This is the **canonical required-suite matrix** per task type — the table shows *when* each slot fires; the Self-review column is the per-task hard-gate paste set (one pasted proof per required command). The **spec-intent & equivalence gates** ([ADR 0022](../adrs/0022-acceptance-criteria-are-executable-checks.md)) augment the Self-review column for several task types, listed under the table.

| Task type             | Pre-implementation                       | Periodic                              | Post-implementation                                              | Self-review                            |
| --------------------- | ---------------------------------------- | ------------------------------------- | ---------------------------------------------------------------- | -------------------------------------- |
| `feature`             | `cmdInstall`                             | `cmdValidate` after each batch        | `cmdValidate`, `cmdTest`                                         | All above                              |
| `fix`                 | `cmdInstall`                             | —                                     | `cmdValidate`, `cmdTest`                                         | + `git diff --stat`                    |
| `refactor`            | `cmdInstall`                             | `cmdValidateDeps` every 10 files      | `cmdValidateDeps`, `cmdTypecheck`                                | All above                              |
| `rewrite`             | `cmdInstall`                             | `cmdValidate` after each module       | `cmdValidate`, `cmdTest`                                         | All above                              |
| `spec-writing`        | —                                        | —                                     | `git status` (clean on source)                                   | + `git status`                         |
| `research-writing`    | —                                        | —                                     | `git status`                                                     | + `git status`                         |
| `audit-writing`       | —                                        | —                                     | `git status`                                                     | + `git status`                         |
| `bug-report-writing`  | —                                        | —                                     | `git status` (reproduction proof is its own verification)        | + reproduction output                  |
| `migration`           | `cmdInstall`                             | `cmdValidate` after each wave         | `cmdValidate`, `cmdTest`                                         | All above                              |
| `upgrade`             | `cmdInstall`                             | `cmdBuild` + `cmdValidate` per wave   | `cmdBuild`, `cmdValidate`, `cmdTest`                             | All above                              |
| `performance`         | `cmdInstall`, baseline `cmdBenchmark`    | `cmdTest` after each change           | target `cmdBenchmark`, `cmdTest`                                 | All above                              |
| `testing`             | `cmdInstall`                             | `cmdTest` after each new test         | `cmdTest`, coverage report                                       | All above + assertion-flip proof       |
| `documentation`       | —                                        | —                                     | run any code examples                                            | + example output                       |
| `review`              | `cmdInstall`                             | —                                     | `cmdValidate`, `cmdTest` (run yourself)                          | + `git diff` of branch under review    |
| `deepen-audit`        | `cmdInstall`                             | —                                     | `cmdValidate`, `cmdValidateDeps` (where structural claims rely) | All above                              |
| `orchestration`       | `cmdInstall`                             | per-worker review pass                | merged-branch `cmdValidate`, `cmdTest`                           | + per-worker review log                |
| `integration`         | `cmdInstall`                             | `cmdValidate` after each batch        | `cmdValidate`, `cmdTest` (incl. integration)                     | All above                              |
| `kickback`            | (same as original task type)             | (same)                                | (same)                                                           | (same) + delta from prior head         |

For the placeholder contract (what `cmdInstall`, `cmdValidate`, etc. mean for tool builders), see [`template-placeholders.md`](template-placeholders.md).

### Spec-intent & equivalence additions ([ADR 0022](../adrs/0022-acceptance-criteria-are-executable-checks.md))

Toolchain slots above prove form; these augment the Self-review hard gate to verify *intent* (each gate defined in [`verification-gates.md`](verification-gates.md)):

| Task type | Added Self-review gate |
| --------- | ---------------------- |
| `feature`, `integration` | `acceptance-criteria-coverage` — each criterion → its check binding (`test` / `command` / `manual`) → pasted result |
| `integration` | `integration-boundary` — secret-grep negative, SDK/API version pin, contract test |
| `refactor`, `migration`, `rewrite` | `behaviour-preservation` — an equivalence check that fails if behaviour changed, not just "the suite is green" |
| `spec-writing` | acceptance criteria carry check bindings (the deliverable itself, not a run) |
| `review` | validation + tests re-run **by the reviewer** in their own worktree (independent of the worker's paste) |
| `fix` | `regression-test` fails before the fix, passes after (already a validated oracle) |

### Confidence tiers ([ADR 0024](../adrs/0024-confidence-tiers.md))

The pasted proofs above carry a confidence tier. There are two:

- **self-reviewed** — the producing agent ran the required commands and pasted them in its own Self-review hard gate. This is the floor; all solo work reaches it.
- **independently-reviewed** — a separate Skeptic re-ran validation in its own worktree (the `review` row above), independent of the worker's paste.

Code-producing tasks **should** reach *independently-reviewed* before merge; solo work is explicitly *self-reviewed*-tier. In the Lead Engineer pattern, the orchestrator becomes the Skeptic and re-validates each worker's branch, recording the per-worker review outcome and the coordination fields (owned/forbidden paths, hand-off contract, liveness/stalled markers, per-conflict intent-preserved proof) in `task-orchestration.md` ([ADR 0025](../adrs/0025-orchestration-coordination-artifact.md)).

---

## ♻️ Recursion

A task can spawn sub-tasks. The conditioning pipeline runs recursively at each level. Each sub-task is itself a `(source doc, task type, persona)` triple.

The most common recursion is the **Lead Engineer pattern**:

```
human → orchestration task (Lead Engineer)
            │
            ├── feature task (Builder, on spec A)
            ├── feature task (Builder, on spec B)
            ├── refactor task (Janitor, on audit C)
            └── feature task (Builder, on spec D)
```

Each child task gets its own worktree, branch, conditioned task file, and agent CLI session. The Lead Engineer's task file tracks all children — slug, branch, status, last review verdict.

The recursion limit is set per project (CLI concern); framework default is **2**. Higher limits permit Lead-Engineer-of-Lead-Engineers patterns; raise carefully.

See [`concepts/08-recursion-and-delegation.md`](../concepts/08-recursion-and-delegation.md).

---

## 🔁 Kickback

When the Skeptic rejects a worker's branch, the rejection itself becomes a conditioned task. The kickback is a `(source doc + skeptic notes) → fix-style task` triple. The original worker (or a fresh agent in the same persona) takes the kickback notes as additional input.

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

Kickback round limit (recommendation, not hard rule): 3. After 3, escalate (re-spec / re-scope / abandon / human).

See [`tasks/kickback.md`](../tasks/kickback.md).

---

## ❓ Edge cases

| Edge case                            | Framework response                                                              |
| ------------------------------------ | ------------------------------------------------------------------------------- |
| Ambiguous source document            | Launcher asks human to confirm doc type. Explicit reclassification, not silent re-routing |
| No source document                   | Authoring task (research-writing / spec-writing / audit-writing / bug-report-writing) |
| Multiple source documents            | Either orchestration (decompose) or one primary source + others as context     |
| Trivial task with no source doc      | Allowed — task scope captures the ask in the task file's `## Objective`        |
| "Research is sufficient without spec" | Discouraged — write the spec first (the directive `description`s steer you there) |

---

## 🧭 Decision flow when starting a task

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
              └── Suggest the default task type
                       │
                       └── Look up the suggested persona in "Task type → suggested persona"
                                │
                                └── List skills worth loading, bind commands, scaffold task file
```

A launcher may pre-compute this when it scaffolds the task file, or the agent may walk it in-session from the directive skill `description`s. Either way it is a recommendation: the agent reads the task file, loads the skill whose `description` fits the work (and the suggested `persona-<slug>` skill if one matches), and records any divergence from the suggested route in `## Decisions`.

---

## See also

- [`concepts/07-flow-graph.md`](../concepts/07-flow-graph.md) — the conceptual frame
- [`compatibility-matrix.md`](compatibility-matrix.md) — the persona × doc × task matrices
- [`template-placeholders.md`](template-placeholders.md) — the placeholder contract
- [`reference/agents-md.md`](agents-md.md) — the `## Routing` pointer and `## Commands` contract
- [`personas/`](../personas/), [`tasks/`](../tasks/), [`documents/`](../documents/), [`skills/`](../skills/)
