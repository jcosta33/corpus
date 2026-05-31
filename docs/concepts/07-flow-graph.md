# 07 · The flow graph

> **TL;DR.** The recommended mapping between source documents, task types, personas, skills, and verification commands. Pick a source document and the rest follows as a *suggested* default — a launcher may apply it deterministically when it scaffolds a task file, and the directive skill `description`s reproduce it in-session, but it is guidance, not gatekeeper-enforced. The agent self-assesses and may re-route, recording the divergence in `## Decisions`. The full operational tables live in [`reference/flow-graph.md`](../reference/flow-graph.md); this concept doc explains the *why* and the *edge cases*.

---

## 🗺️ The pipeline as a flow

```
┌──────────────────┐
│  Source document │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐    Determined by document type:
│    Task type     │    audit → refactor, spec → feature, etc.
└────────┬─────────┘
         │
         ▼
┌──────────────────┐    Determined by task type:
│     Persona      │    refactor → Janitor, feature → Builder, etc.
└────────┬─────────┘
         │
         ▼
┌──────────────────┐    Skills + verification commands attached.
│  Conditioned     │    Worktree + branch created. Agent CLI launches.
│   task.md        │
└──────────────────┘
```

Information flows in one direction along the verbosity gradient — high-level to low-level, never back.

```
research.md  ──▶  spec.md       ──▶  task.md   (feature)
research.md  ──▶  audit.md      ──▶  task.md   (refactor)
research.md  ──▶  bug-report.md ──▶  task.md   (fix)

research.md is OPTIONAL — only when training data is insufficient
```

Task files are terminal. They never feed another doc; durable findings are *promoted* to audits, specs, or research before the session closes (see [`03-distillation.md`](03-distillation.md)).

---

## 🚦 Document → task type (the routing rules)

Every source document has exactly one *suggested* default task type. A launcher (CLI or human) may apply the default deterministically at session start; the agent may also re-route in-session when the work doesn't match. Either way, the default is the recommendation, not a lock.

| Source document                         | Default task type                                                    | Why                                                                                |
| --------------------------------------- | -------------------------------------------------------------------- | ---------------------------------------------------------------------------------- |
| `spec.md`                               | feature                                                              | The spec describes a new capability to build                                       |
| `audit.md`                              | refactor                                                             | The audit identifies cleanup work to do                                            |
| `bug-report.md`                         | fix                                                                  | The report describes a defect to repair                                            |
| `research.md` (technical)               | spec-writing                                                         | Research is upstream input; the next step is translating into a spec               |
| `research.md` (UX/market)               | spec-writing                                                         | Same — translate findings into requirements                                        |
| _none — initial human ask_              | research-writing / spec-writing / audit-writing / bug-report-writing | A "blank slate" ask kicks off an authoring task; which one depends on the prompt   |
| _another agent's branch_                | review                                                               | Lead Engineer or Skeptic reviewing finished work                                   |
| _multiple source docs (e.g. 5 specs)_   | orchestration                                                        | Lead Engineer decomposes and delegates                                             |
| _existing audit + new investigation_    | deepen-audit                                                         | Skeptic re-walks an existing audit                                                 |
| `migration plan`                        | migration                                                            | Mechanical change across many call sites                                           |
| `benchmark report`                      | performance                                                          | Optimisation task with measured baseline                                           |
| `cleanup list`                          | refactor                                                             | Janitor proves deletion safety                                                    |
| `test plan`                             | testing                                                              | New test coverage from a structured plan                                           |

For the operational tables, see [`reference/flow-graph.md`](../reference/flow-graph.md).

---

## 🚫 Edges the routing discourages

Swarm discourages certain "tempting" edges because they violate the distillation discipline or the doc-type epistemic stances. These are recommended routing — the agent honours them as guidance and surfaces a divergence in `## Decisions` if it ever crosses one deliberately.

| Discouraged edge                              | Why                                                                                  |
| --------------------------------------------- | ------------------------------------------------------------------------------------ |
| `research → fix` (skipping spec/audit)        | Research is input. Implementation requires a spec, audit, or bug-report to translate the input into a contract. |
| `spec → refactor`                             | Refactor tasks are driven by audits. If a spec calls for restructuring, the spec is implicitly the refactor's plan, but the task is still tracked as a feature unless the change is purely structural. |
| `bug-report → refactor`                       | A bug report drives a fix, not a cleanup. If fixing the bug reveals broader cleanup needs, surface them as findings; do not expand scope silently. |
| `audit → feature`                             | Audits do not specify new features. If the audit's recommended approach is "build something new", the next step is spec-writing, not a feature task. |
| `code → spec` (back-fill)                     | Specs are forward-looking. Narrating finished code as a spec is dishonest. Use documentation instead. |
| `task with no source doc and no task scope`   | Every task is grounded.                                                              |
| `one source doc → multiple task types`        | One suggested route per source. Split the work.                                      |
| `multiple source docs → one task`             | One source per task. Multiple sources = multiple tasks (or use orchestration).      |
| `task file authored after implementation begins` | The task file is step one. Conditioning before action.                            |
| `persona invented per session`                | Personas are catalogued (13 mindsets; 8 ship as skills).                            |
| `durable findings left only in the task file` | Task files are gitignored. Migrate findings to audits/specs/research.                |

These are recommended routing, not gatekeeper-enforced. The old always-loaded `documentation-gatekeeper` skill that blocked forbidden flows has been removed; its rules now live here as framework guidance, and each `write-<type>` workflow skill prevents its own type's failure modes. The discipline that keeps these edges honest — pasting empirical proof of what changed — is carried by the `empirical-proof` and `adversarial-review` quality-gate skills, which self-activate on matching work.

---

## 🎯 Task type → persona

Each task type has a suggested primary persona; the agent may re-assess. Some have secondary personas for handoff.

For the full table, see [`reference/flow-graph.md`](../reference/flow-graph.md).

Highlights worth understanding:

- **`fix → The Skeptic`** (ships as `persona-skeptic`). The framework's convention is that fix sessions adopt the Skeptic mindset because root-causing demands hostility toward the most plausible-sounding explanation. See [ADR 0006](../adrs/0006-skeptic-owns-fix-tasks.md).
- **`refactor → The Janitor`** (ships as `persona-janitor`). Behaviour preservation is the contract; the Janitor is the mindset built around safety-of-change.
- **`orchestration → The Lead Engineer`** (ships as `persona-lead-engineer`). The only mindset that doesn't write code; it self-activates this skill because orchestration has no workflow skill to carry its discipline (see [ADR 0025](../adrs/0025-orchestration-coordination-artifact.md)). Becomes the Skeptic for each review pass — re-validating a worker's branch in a separate worktree promotes it from **self-reviewed** to **independently-reviewed** ([ADR 0024](../adrs/0024-confidence-tiers.md)).
- **`kickback → original persona`.** When a Skeptic kicks back a Builder's branch, the kickback is itself a task — assigned to the *original* Builder (or a fresh agent in the same mindset) with the Skeptic's notes attached.

---

## 🛠️ Task type → skills

There is **no always-loaded skill**. Each skill self-activates when its directive `description` matches the work; the table below is the recommended set per task type (workflow skill + quality gates + the `persona-<slug>` skill where the suggested persona ships as one). For the 5 mindsets carried by a workflow skill, the persona discipline is already inside that skill — there is no separate skill to load.

| Task type          | Skills worth loading                                                          |
| ------------------ | ----------------------------------------------------------------------------- |
| feature            | `write-feature` (carries Builder), `empirical-proof`                          |
| fix                | `write-fix`, `persona-skeptic`, `adversarial-review`, `empirical-proof`       |
| refactor           | `write-refactor`, `persona-janitor`, `empirical-proof`                        |
| rewrite            | `write-rewrite`, `empirical-proof`                                            |
| spec-writing       | `write-spec`, `persona-architect`, `distillation-discipline`                  |
| research-writing   | `write-research` (carries Researcher), `persona-surveyor` (UX/market), `distillation-discipline` |
| audit-writing      | `write-audit`, `persona-auditor`, `adversarial-review`                        |
| bug-report-writing | `write-bug-report` (carries Bug Hunter), `adversarial-review`, `empirical-proof` |
| migration / upgrade | `write-migration`, `persona-migrator`, `empirical-proof`                     |
| performance        | `write-performance`, `persona-performance-surgeon`, `empirical-proof`         |
| testing            | `write-testing` (carries Test Author), `empirical-proof`                      |
| documentation      | `write-documentation` (carries Documentarian), `distillation-discipline`, `empirical-proof` |
| review             | `persona-skeptic`, `adversarial-review`, `empirical-proof`                    |
| deepen-audit       | `write-audit`, `persona-skeptic`, `adversarial-review`, `empirical-proof`     |
| orchestration      | `persona-lead-engineer`, `adversarial-review`, `empirical-proof`              |

Project-specific skills self-activate in addition, by the same rule: a skill whose `description` field semantically matches the task's objective fires on its own.

---

## ♻️ Recursion

A task can spawn sub-tasks. The conditioning pipeline runs **recursively** at each level — each sub-task is itself a `(source doc, task type, persona)` triple, conditioned in exactly the same way as the parent.

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

Recursion depth is bounded. The framework's default is **2** (a Lead Engineer may spawn workers; those workers are not themselves Lead Engineers). Higher limits are possible — Lead-Engineer-of-Lead-Engineers — but raise carefully.

For the pattern's mechanics, see [`08-recursion-and-delegation.md`](08-recursion-and-delegation.md).

---

## 🔁 Kickback

When the Skeptic rejects a worker's branch, the rejection itself becomes a conditioned task. The kickback is a `(source doc + skeptic notes) → fix task` triple. The original worker (or a fresh agent in the same persona) takes the kickback notes as additional input.

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

A kickback is a *normal task with normal conditioning*. The only special input is the Skeptic's notes — they ride alongside the original spec in `## Linked docs`.

Kickback loops are bounded too — the framework recommends a hard limit of **3 kickback rounds** per branch. After 3, the orchestrator (or human) escalates: re-spec the work, re-scope, or abandon. See [`08-recursion-and-delegation.md`](08-recursion-and-delegation.md) for the escalation protocol.

---

## ❓ Edge cases

The framework anticipates several common ambiguities and has a defined response for each.

### 🤔 Ambiguous source document

A document is unclear — a research file that's really an audit, a spec that contains too much current-state.

**Framework response:** The launcher (CLI or human) should *ask the human to confirm the doc type* rather than guess. The framework strongly prefers explicit reclassification over silent re-routing.

**In practice:** When the agent encounters an ambiguous source doc, it halts and surfaces the ambiguity in `## Findings`, then waits for a human (or a separate `audit-writing` / `spec-writing` task) to reclassify.

### 📭 No source document

A "blank slate" ask. The human says "research X" or "audit Y" or "find the bug in Z" with no upstream artefact.

**Framework response:** The launcher selects the *authoring* type from the human's prompt — `research-writing`, `audit-writing`, `spec-writing`, `bug-report-writing` — or asks if it cannot tell.

**In practice:** Most blank-slate asks are handled by `research-writing` followed by `spec-writing`. The framework prefers two crisp authoring tasks over one ambiguous task.

### 📑 Multiple source documents

A task may legitimately have multiple sources (spec + research, audit + research, original spec + skeptic notes for a kickback).

**Framework response:** All sources go in `## Linked docs`. The task type follows the *primary* source's routing rule. The other sources are *grounding context*, not separate routing inputs.

**In practice:** The Lead Engineer pattern (orchestration) is the canonical case for multiple-source-doc routing; everything else is one-primary-with-context.

### 🛠️ No research, no spec — trivial task

Trivial tasks may skip the full doc chain. Examples: a one-line documentation update, a small Test Authoring task, a typo fix.

**Framework response:** The task file's `## Objective` and `## Linked docs` sections are sufficient grounding. The `## Decisions` section records the skip with a reason.

**In practice:** The threshold is judgement-based. Heuristic: if the work has *structured content* (lists of items, repro steps, target metrics, acceptance criteria), it needs a separate doc. If it's a paragraph of prose, task scope is enough.

### 🔬 Research that's "sufficient without a spec"

The agent has done the research, the answer seems clear, and the temptation is to implement directly without writing the spec.

**Framework response: strongly discouraged.** If you find yourself implementing directly from research, *stop and write the spec first*. Research is input; spec is contract. The failure mode (drift between research findings and implementation) is severe and silent — the `distillation-discipline` skill treats this as a near-absolute rule, and crossing it should be surfaced loudly in `## Decisions` rather than done silently.

### ⚖️ Optimisation overlapping structural edits (resolved tension)

Older exploratory drafts debated precedence when **performance improvements require internal reorganisation**. Default stance:

1. **Prefer sequential specialised tasks** — `performance` carries measurement obligations; a follow-on `refactor` (Janitor mindset, via `persona-janitor`) absorbs behaviour-neutral extraction — wire dependencies through orchestration metadata so reviewers grasp ordering.
2. **Merged single-task exception** permitted only when `## Linked docs` explicitly ranks the benchmark/report above cosmetic debt *and* the conditioned Self-review inherits **both** measurement + behavioural invariance checks.
3. **Never** disguise semantic deltas as refactors (the `adversarial-review` skill catches this on review) or cite perf wins without artefacts (the `empirical-proof` skill refuses unproven claims in Self-review).

ADR / constitution notes for storage layout (research vs specs): prefer `.agents/adrs/` chronology distinct from drafts in `.agents/specs/` when teams need divergence tracking — launcher paths remain project conventions as long as the routing tables stay consistent.

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
              └── Take the suggested default task type
                       │
                       └── Look up the suggested persona in "Task type → persona"
                                │
                                └── List the skills worth loading, inject commands, scaffold task file
```

A launcher may run this when it scaffolds the file; the directive skill `description`s reproduce the same routing in-session. The agent reads the conditioned task file, adopts the persona named in the `> **PERSONA:**` blockquote — and re-assesses against the actual work, recording any divergence in `## Decisions`.

---

## See also

- [`02-conditioning-pipeline.md`](02-conditioning-pipeline.md) — the mechanism end-to-end
- [`08-recursion-and-delegation.md`](08-recursion-and-delegation.md) — recursion and kickback in detail
- [`../reference/flow-graph.md`](../reference/flow-graph.md) — the operational tables
- [`../reference/compatibility-matrix.md`](../reference/compatibility-matrix.md) — the doc × task × persona matrices
- [ADR 0002](../adrs/0002-personas-1-to-1-with-task-types.md) — the 1:1 persona↔task mapping, superseded to suggested defaults
