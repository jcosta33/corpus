# 06 · Task types

> **TL;DR.** 18 task types. Each one has a *suggested* lead persona, a set of skills worth loading, named verification gate slots, and a template. Each type earns its place by being something agents do *constantly* across projects, languages, and stacks. The task-type → persona mapping is a **suggested default**, not a forced pick — the agent arrives pre-conditioned and may re-assess (the original rigid 1:1 mapping in [ADR 0002](../adrs/0002-personas-1-to-1-with-task-types.md) is superseded to suggested defaults).

---

## 🗂️ The catalogue at a glance

The 18 task types fall into three families:

```mermaid
flowchart LR
    subgraph 💻 Implementation tasks
        F1[feature]
        F2[fix]
        F3[refactor]
        F4[rewrite]
        F5[migration]
        F6[upgrade]
        F7[performance]
        F8[testing]
        F9[integration]
        F10[kickback]
    end
    subgraph ✍️ Authoring tasks
        A1[spec-writing]
        A2[audit-writing]
        A3[research-writing]
        A4[bug-report-writing]
    end
    subgraph 🔁 Process tasks
        P1[review]
        P2[deepen-audit]
        P3[orchestration]
        P4[documentation]
    end
```

Single-page reference: [`tasks/README.md`](../tasks/README.md). Per-type details: [`tasks/<type>.md`](../tasks/).

---

## 🧬 Anatomy of a task type

Each task type has the following metadata, defined once in the framework and reused at every site:

| Field                 | What it is                                                     |
| --------------------- | -------------------------------------------------------------- |
| **Suggested persona** | The default mindset (a suggestion; the agent may re-assess)    |
| **Source doc(s)**     | Which document type(s) ground the task                         |
| **Skills worth loading** | The skills whose `description` matches the task; they self-activate (there is no always-loaded skill) |
| **Verification slots** | Named gate slots that fire pre/periodic/post                  |
| **Self-review focus** | The persona-specific Self-review questions                     |
| **Template**          | The literal task-file skeleton with placeholders               |

The metadata flows through the conditioning pipeline (see [`02-conditioning-pipeline.md`](02-conditioning-pipeline.md)) and is materialised as the conditioned task file the agent reads.

---

## 💻 Implementation tasks

Tasks whose deliverable is **code** (or another concrete change to the running system).

| Task              | Suggested persona         | Source doc            | What it produces                    | Page                                         |
| ----------------- | ------------------------- | --------------------- | ----------------------------------- | -------------------------------------------- |
| **feature**       | The Builder               | spec                  | New behaviour                       | [`tasks/feature.md`](../tasks/feature.md)    |
| **fix**           | The Skeptic               | bug-report            | Defect repaired + regression test   | [`tasks/fix.md`](../tasks/fix.md)            |
| **refactor**      | The Janitor               | audit                 | Restructured code, behaviour preserved | [`tasks/refactor.md`](../tasks/refactor.md) |
| **rewrite**       | The Builder               | spec                  | New implementation, behaviour may change | [`tasks/rewrite.md`](../tasks/rewrite.md)   |
| **migration**     | The Migrator              | migration plan / spec | Codebase moved from API A to API B  | [`tasks/migration.md`](../tasks/migration.md) |
| **upgrade**       | The Migrator              | migration plan        | Dependency / framework version bumped | [`tasks/upgrade.md`](../tasks/upgrade.md)   |
| **performance**   | The Performance Surgeon   | benchmark report / spec / audit | Faster code, behaviour preserved | [`tasks/performance.md`](../tasks/performance.md) |
| **testing**       | The Test Author           | spec / audit / bug-report | New tests                       | [`tasks/testing.md`](../tasks/testing.md)    |
| **integration**   | The Builder               | spec                  | SDK / API / MCP server wired in     | [`tasks/integration.md`](../tasks/integration.md) |
| **kickback**      | (original persona)        | original source + Skeptic notes | Revised version of a previously rejected branch | [`tasks/kickback.md`](../tasks/kickback.md) |

---

## ✍️ Authoring tasks

Tasks whose deliverable is a **source document** (which then grounds a downstream implementation task).

| Task                      | Suggested persona          | Source doc                    | What it produces        | Page                                                    |
| ------------------------- | -------------------------- | ----------------------------- | ----------------------- | ------------------------------------------------------- |
| **spec-writing**          | The Architect              | research / audit (optional)   | spec                    | [`tasks/spec-writing.md`](../tasks/spec-writing.md)     |
| **audit-writing**         | The Auditor                | audit brief / human ask       | audit                   | [`tasks/audit-writing.md`](../tasks/audit-writing.md)   |
| **research-writing**      | The Researcher / Surveyor  | research question / human ask | research                | [`tasks/research-writing.md`](../tasks/research-writing.md) |
| **bug-report-writing**    | The Bug Hunter             | human ask / agent observation | bug-report              | [`tasks/bug-report-writing.md`](../tasks/bug-report-writing.md) |

These are **read-only on source code** — the worktree's source files don't change. The deliverable is one document, and the Self-review's first check is `git status` showing no source files modified.

---

## 🔁 Process tasks

Tasks whose deliverable is a **decision**, **review**, or **coordination artefact**.

| Task              | Suggested persona        | Source doc                 | What it produces                         | Page                                           |
| ----------------- | ------------------------ | -------------------------- | ---------------------------------------- | ---------------------------------------------- |
| **review**        | The Skeptic              | another agent's branch     | Verdict (approve / kickback / abandon) + findings list | [`tasks/review.md`](../tasks/review.md) |
| **deepen-audit**  | The Skeptic              | existing audit             | Updated audit with previously missed findings | [`tasks/deepen-audit.md`](../tasks/deepen-audit.md) |
| **orchestration** | The Lead Engineer        | multiple source docs       | Merged result + worker tracker + merge log | [`tasks/orchestration.md`](../tasks/orchestration.md) |
| **documentation** | The Documentarian        | task scope / spec / audit  | User-facing documentation (README, how-to, reference) | [`tasks/documentation.md`](../tasks/documentation.md) |

---

## 🎯 Why each one earns its place

Every task type in the catalogue is defended by **ubiquity**: agents do this constantly, across projects, languages, and stacks. The bar for adding a task type is high (see [Principle 10](../PRINCIPLES.md#10--the-catalogue-grows-but-slowly-and-with-evidence)), and several plausible-sounding types collapsed into existing types:

| Plausible task              | Folded into                                                            |
| --------------------------- | ---------------------------------------------------------------------- |
| **Hotfix**                  | `fix` — urgency is a property of the bug-report, not a separate task type |
| **Security Fix**            | `fix` — the bug is a vulnerability; security context is captured in the bug-report |
| **Algorithm Implementation** | `feature` — the spec is algorithmically tricky; the persona stays Builder |
| **Architecture Design**     | `spec-writing` — systemic-impact specs are authored by the Architect; no separate "Architecture Design" persona |
| **Cleanup**                 | `refactor` — the Janitor handles deletion safety as part of refactor |
| **Dependency Upgrade**      | `migration` (when call sites change) or `refactor` (when only obsolete usages get removed) |
| **Spike / Investigation**   | `research-writing` — produces a research file, even when scope is exploratory |
| **Code Review (PR)**        | `review` — same task type, regardless of whether the source is human or agent |

These collapses are deliberate: a smaller catalogue is easier to memorise, easier to route, and easier to teach. When a real-world task genuinely doesn't fit, the catalogue grows — but with evidence, an ADR, and a migration path.

---

## 📦 The shared task skeleton

All 18 task types extend a common base. The base sections are present in every template; type-specific sections add to them. The skeleton:

```markdown
# {{title}}

## Metadata
- Slug · Agent · Branch · Base · Worktree · Created · Status · Type

> 🔒 / ⚠️ / (no marker) **<TASK TYPE> SESSION** — short descriptor of constraints
> **PERSONA:** Suggested **<Persona>** — load `.agents/skills/persona-<slug>/SKILL.md` (for the 8 shipped personas) or rely on the workflow skill that carries the mindset; re-assess and record any divergence in `## Decisions`

## Objective
One paragraph; what is true when this task is done.

## Linked docs
- Source doc(s)
- Optional research
- Related artefacts

## Skills
- (workflow skill, e.g. write-<type>)
- (quality-gate skills whose description matches: empirical-proof / adversarial-review / distillation-discipline)
- (persona-<slug> skill, for the 8 shipped personas, when role-shaped)

## Domain skills
Project-specific skills that self-activate by description-matching.

## Constraints
Task-specific + persona's forbidden actions.

## Plan
Step-by-step, written before implementation begins.

## Progress checklist
Discrete items, marked as they complete.

## Decisions
Significant choices made during the session, with rationale.

## Findings
Codebase discoveries worth preserving. Promote durable findings to upstream docs before close.

## Assumptions
Every assumption marked [pending] or [confirmed].

## Blockers
Anything preventing confident progress.

## Validation gates
Named slots, with pasted output.

## Self-review (HARD GATE)
Written answers to the persona's checklist with empirical proof.

## Next steps
Concrete starting points if the session ends incomplete.
```

The base lives at [`reference/task-base.md`](../reference/task-base.md). Type-specific templates extend it — see each task page in [`tasks/`](../tasks/).

---

## 🔌 Verification gate slots by task type

The framework defines **slots**; the project binds them to commands in `AGENTS.md > Commands`, and the launcher fills the matching `{{cmd*}}` placeholders in the task template. Skill bodies reference the commands by name (`AGENTS.md > Commands > Validation`) and degrade gracefully when a binding is missing. The slots fire at known phases:

| Phase                   | When                                  |
| ----------------------- | ------------------------------------- |
| **Pre-implementation**  | Before the agent edits code           |
| **Periodic**            | At checkpoints during execution       |
| **Post-implementation** | After all changes                     |
| **Self-review**         | At task close, pasted into hard gate  |

Per-task slot map: [`reference/flow-graph.md`](../reference/flow-graph.md) (the verification command attachment table).

The universal slots present on every code-producing task (template placeholder → `AGENTS.md > Commands` entry):

- `git status` — only intended files changed
- `{{cmdValidate}}` (`Commands > Validation`) — the project's catch-all check; most projects bind it to typecheck + lint
- `{{cmdFormat}}` (`Commands > Format`) — formatting
- `{{cmdTest}}` (`Commands > Test`) — the test runner
- `{{cmdTypecheck}}` (`Commands > Typecheck`) — standalone static analysis, where the project separates it from Validation
- `{{cmdValidateDeps}}` (`Commands > ValidateDeps`) — architectural / dependency boundary check (projects may not have this; mark `n/a`)
- `{{cmdBuild}}` (`Commands > Build`) — build the artefact

Type-specific additions (some examples):

- `performance` adds `{{cmdBenchmark}}` (`Commands > Benchmark`) — fired at baseline and after target.
- `migration` adds `{{cmdValidate}}` *after every wave* (the codebase must compile and pass tests at every wave checkpoint, not just at the end).
- `bug-report-writing` adds a *reproduction-output* slot (the proof that the bug fires reliably).
- Doc-producing tasks (research, audit, spec, documentation) run their markdown lint / link check / citation check through the project's `Commands > Validation` binding, or the skill asks the user when no doc-lint command is bound.

For the full slot catalogue: [`reference/template-placeholders.md`](../reference/template-placeholders.md).

---

## 🤝 Hand-off conventions

Most task types end with a Skeptic review:

| Task              | Hands off to                    |
| ----------------- | ------------------------------- |
| feature           | review (Skeptic)                |
| refactor          | review (Skeptic)                |
| rewrite           | review (Skeptic)                |
| migration         | review (Skeptic) per wave       |
| upgrade           | review (Skeptic) per wave       |
| performance       | review (Skeptic)                |
| testing           | review (Skeptic)                |
| integration       | review (Skeptic)                |
| documentation     | review (Skeptic)                |
| spec-writing      | (terminal — feeds future feature task) |
| audit-writing     | (terminal — feeds future refactor task) |
| research-writing  | (terminal — feeds future spec-writing task) |
| bug-report-writing | (terminal — feeds fix task)    |
| fix               | review (Skeptic — second-pass) |
| review            | (terminal — emits verdict)      |
| kickback          | review (Skeptic — re-review)    |
| deepen-audit      | (terminal — updates audit)      |
| orchestration     | (terminal — Lead Engineer holds the bag end-to-end) |

The Skeptic-as-terminal-node pattern is a deliberate design choice — see [`04-personas.md`](04-personas.md) and [`09-empirical-proof.md`](09-empirical-proof.md).

---

## 🪜 The taxonomy is versioned

When a real-world task pattern recurs across projects and doesn't fit any existing type, the catalogue grows. The bar:

1. **Evidence** — the same pattern in at least 3 independent codebases.
2. **An ADR** — captures the alternatives considered (folding into existing types) and why they were rejected.
3. **A migration path** — a documented upgrade route for adopters, under the versioning/migration policy ([ADR 0015](../adrs/0015-versioning-scheme.md)).
4. **Conformance update** — the conformance checker updates to validate the new type.
5. **Versioning bump** — a minor version (additive) or major version (if breaking).

Conversely, when a task type has no users in practice, it can be deprecated under the same versioning/migration policy ([ADR 0015](../adrs/0015-versioning-scheme.md)). Deprecation has a similar bar: evidence, ADR, migration path.

---

## ❓ Open question: Brainstorm task type

The frontier-research file ([`12-prior-art.md`](12-prior-art.md)) flags an open question: should Swarm add a *Brainstorm* task type for proactive exploration before authoring? The field is split:

- Spec Kit folds brainstorming into `/specify`.
- BMAD has it as a workflow phase.
- Superpowers makes it a skill.

**Swarm's current position:** Brainstorming is the *preparation phase* of `research-writing`. The Researcher/Surveyor uses search tools aggressively and forms hypotheses before drafting the research file. There is no separate Brainstorm task type. If field practice shows the preparation phase needs its own structure, the catalogue grows. For now, it doesn't.

---

## See also

- [`tasks/`](../tasks/) — the per-type pages with templates and examples
- [`02-conditioning-pipeline.md`](02-conditioning-pipeline.md) — how the pipeline picks task types
- [`07-flow-graph.md`](07-flow-graph.md) — the routing graph
- [`../reference/flow-graph.md`](../reference/flow-graph.md) — the operational tables
- [`../reference/template-placeholders.md`](../reference/template-placeholders.md) — the placeholder contract
- [ADR 0006](../adrs/0006-skeptic-owns-fix-tasks.md) — why fix tasks adopt the Skeptic
- [ADR 0007](../adrs/0007-bug-report-as-meta-task.md) — why bug-report is its own task type
