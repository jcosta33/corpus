# 🐝 Swarm scaffold

> **The literal, copy-and-paste artefacts that turn any repo into a Swarm-conformant repo.** The copied runtime artefacts are self-contained: skill bodies and templates reference only files that land in your repo (`AGENTS.md`, sibling skills, the shipped `docs/agents/`), so nothing breaks when you copy. This README is meta — it points back at the framework's `/docs/` for the *why*, which you don't copy.

This directory mirrors what your repository's structure should look like at the relevant paths. Copy the contents into your repo's root; bind the `{{cmdX}}` placeholders in `AGENTS.md` to your project's commands; you're conformant.

For the *why* behind these artefacts — the conceptual rationale, design decisions, worked examples — see the upstream Swarm framework repo's `/docs/` directory (not copied into your repo). The scaffold is what to copy; the upstream docs are what to read.

---

## 🗺️ What's in here

```
scaffold/
├── README.md                              ← you are here
├── AGENTS.md                              ← root agent brief (TODO markers to fill in)
├── CLAUDE.md                              ← Claude Code alias (imports AGENTS.md)
├── GEMINI.md                              ← Gemini alias (points to AGENTS.md)
├── .gitignore.additions                   ← lines to append to your .gitignore
│
├── docs/
│   └── agents/                            ← human-facing process docs that ship with every project
│       ├── 01-process.md                  ← the documentation-first workflow
│       ├── 02-file-types.md               ← what each document type contains
│       ├── 03-workflow.md                 ← step-by-step session flow
│       ├── 04-standards.md                ← writing and execution standards
│       └── 05-flow-graph.md               ← the recommended routing graph
│
└── .agents/
    ├── skills/                            ← 24 self-activating skills, one dir each (SKILL.md + references/)
    │   │  # quality gates (3) — cross-cutting disciplines
    │   ├── adversarial-review/
    │   ├── distillation-discipline/
    │   ├── empirical-proof/
    │   │  # specialised (1)
    │   ├── fix-flaky-test/
    │   │  # authoring (12) — one per kind of work
    │   ├── write-audit/
    │   ├── write-bug-report/
    │   ├── write-documentation/
    │   ├── write-feature/
    │   ├── write-fix/
    │   ├── write-migration/
    │   ├── write-performance/
    │   ├── write-refactor/
    │   ├── write-research/
    │   ├── write-rewrite/
    │   ├── write-spec/
    │   ├── write-testing/
    │   │  # personas (8) — role mindsets that ship as skills
    │   ├── persona-architect/
    │   ├── persona-auditor/
    │   ├── persona-janitor/
    │   ├── persona-lead-engineer/
    │   ├── persona-migrator/
    │   ├── persona-performance-surgeon/
    │   ├── persona-skeptic/
    │   └── persona-surveyor/
    │       # Each non-persona skill ships a references/ dir alongside SKILL.md:
    │       #   references/task-template.md  (the per-skill task template),
    │       #   except distillation-discipline=worked-example.md, empirical-proof=evasions.md
    │
    └── templates/                         ← 8 flat templates
        ├── spec.md                        ← source-doc templates (4)
        ├── audit.md
        ├── bug-report.md
        ├── research.md
        ├── skill.md                       ← meta-template for new project-specific skills
        ├── task-base.md                   ← shared task skeleton
        ├── task-orchestration.md          ← the two skill-less task types
        └── task-review.md
```

> Per-skill task templates are **not** in the flat `templates/` directory — they live in each skill's `references/task-template.md`, so loading the skill brings its template with it. The flat `templates/` holds only the source-doc templates, the skill meta-template, the shared task skeleton, and the two task types that have no skill (`orchestration`, `review`).

---

## 🚀 Install procedure

The scaffold is designed for **mirror-the-paths** installation: every file's path inside `scaffold/` is the path it should land at, relative to your repo's root.

### Quick install (one shell)

From your repo's root:

```bash
# 1. Copy the directory contents (the .agents/ tree, docs/agents/, the alias files)
cp -r path/to/swarm/scaffold/.agents .
cp -r path/to/swarm/scaffold/docs/agents docs/

# 2. Copy the entry-point files
cp path/to/swarm/scaffold/AGENTS.md .
cp path/to/swarm/scaffold/CLAUDE.md .
cp path/to/swarm/scaffold/GEMINI.md .

# 3. Append to your .gitignore
cat path/to/swarm/scaffold/.gitignore.additions >> .gitignore

# 4. Create the source-doc directories
mkdir -p .agents/{tasks,specs,audits,bugs,research}
```

### Required edits after copying

The scaffold ships with `TODO` markers where your project's specifics belong. Search for them:

```bash
grep -rn "TODO" AGENTS.md .agents/
```

You must:

1. **Bind the command contract in `AGENTS.md`'s `## Commands` section.** Replace each `TODO` with your project's command — the **Required** rows (`Validation`, `Test`, `Format`) plus any **Extended** rows your work touches (`Install`, `Typecheck`, `Build`, `ValidateDeps`, `Benchmark`); mark unavailable extended rows `n/a` with a one-line reason. Skills reference these by name in prose (e.g. `AGENTS.md > Commands > Validation`) and degrade gracefully — an unbound entry means the skill asks you before running anything.
2. **Fill in the `## Project conventions` section in `AGENTS.md`** — language, runtime, test runner, package manager.
3. **Optionally:** add a `.agents/constitution.md` capturing project-wide non-negotiable baselines.

### Verify

```bash
ls -1 .agents/skills/                   # should list 24 skill directories
ls -1 .agents/templates/                # should list 8 files (4 source-doc + skill.md + task-base.md + task-orchestration.md + task-review.md)
ls .agents/skills/write-feature/references/task-template.md   # per-skill task templates live here, not in templates/
grep -c "TODO" AGENTS.md                 # should be 0 after you've bound the placeholders
grep -F ".agents/tasks/" .gitignore      # should match
```

---

## 🪞 The placeholder contract

Both the flat templates in `.agents/templates/` and the per-skill `references/task-template.md` files use `{{name}}` placeholders. They fall into two namespaces:

### Command placeholders (project-bound, set once in `AGENTS.md`'s `## Commands` section)

| Placeholder              | What it represents                                                           |
| ------------------------ | ---------------------------------------------------------------------------- |
| `{{cmdInstall}}`         | Install dependencies / set up the worktree                                  |
| `{{cmdValidate}}`        | The project's catch-all check (lint + format + typecheck)                   |
| `{{cmdLint}}`            | Lint only                                                                   |
| `{{cmdFormat}}`          | Format check                                                                |
| `{{cmdTypecheck}}`       | Static analysis / type check                                                |
| `{{cmdTest}}`            | Test suite                                                                  |
| `{{cmdBuild}}`           | Build the project artefact                                                  |
| `{{cmdValidateDeps}}`    | Architectural / dependency-graph boundary check (mark `n/a` if unavailable) |
| `{{cmdBenchmark}}`       | Run benchmarks (`performance` tasks)                                         |
| `{{cmdMarkdownLint}}`    | Lint Markdown docs (where applicable)                                       |
| `{{cmdLinkCheck}}`       | Check doc links resolve                                                     |
| `{{cmdCitationCheck}}`   | Check research-file citations are valid (rare)                              |

### Scaffolding placeholders (per-task, set by your launcher / Swarm CLI)

| Placeholder         | What it represents                                                                       |
| ------------------- | ---------------------------------------------------------------------------------------- |
| `{{slug}}`          | URL-safe task slug (`oauth2-pkce`)                                                       |
| `{{title}}`         | Human-readable title                                                                     |
| `{{agent}}`         | Agent CLI / model identifier                                                             |
| `{{branch}}`        | Git branch                                                                               |
| `{{baseBranch}}`    | Base branch                                                                              |
| `{{worktreePath}}`  | Worktree location                                                                        |
| `{{createdAt}}`     | ISO-8601 timestamp                                                                       |
| `{{specFile}}`      | Path to the primary source doc                                                           |
| `{{auditFile}}`     | Path to the source audit (when applicable)                                              |
| `{{bugReport}}`     | Path to the source bug-report                                                            |
| `{{reviewFile}}`    | Path to a Skeptic's review notes (kickback tasks)                                       |
| `{{round}}`         | Kickback round (1, 2, 3)                                                                 |
| `{{originalType}}`  | Kickback's original task type                                                            |
| `{{originalPersona}}` | Kickback's original persona                                                              |

A runner (the Swarm CLI or any other) is **Swarm-compliant** if it substitutes every required placeholder before passing the task file to the agent. The framework defines the names; the project (or runner) binds the values.

---

## 🎭 The persona catalogue

Personas condition mindset for role-shaped work. The framework's catalogue (in the upstream Swarm framework repo's `/docs/personas/`, not copied here) describes **13 mindsets**, of which **8 ship as standalone skills** in this scaffold — each in its own `persona-<slug>/SKILL.md`, self-activating when its `description` matches the task:

| Persona skill                | Primary tasks                |
| ---------------------------- | ---------------------------- |
| `persona-architect`          | spec-writing                 |
| `persona-auditor`            | audit-writing                |
| `persona-janitor`            | refactor                     |
| `persona-lead-engineer`      | orchestration — coordinate multiple agents to a merged, verified result |
| `persona-migrator`           | migration, upgrade           |
| `persona-performance-surgeon` | performance                 |
| `persona-skeptic`            | review, deepen-audit, fix    |
| `persona-surveyor`           | research-writing (UX/market) |

`persona-lead-engineer` ships even though orchestration has no workflow skill: the coordination mindset *is* the discipline, so it self-activates as the orchestration surface. It coordinates against the `task-orchestration.md` template, which records per-worker owned/forbidden paths, the expected-deliverable/acceptance-bar hand-off contract (mirrored in each worker's `## Parent contract` in `task-base.md`), a liveness marker + stalled status + re-plan trigger, and per-conflict intent-preserved proof.

The other **5 mindsets do not ship as separate skills** — each is carried by the matching workflow (authoring) skill, so loading the skill brings the mindset with it:

| Mindset           | Carried by             |
| ----------------- | ---------------------- |
| The Builder       | `write-feature`        |
| The Bug Hunter    | `write-bug-report`     |
| The Documentarian | `write-documentation`  |
| The Researcher    | `write-research`       |
| The Test Author   | `write-testing`        |

Open any `persona-<slug>/SKILL.md` for the full profile. Project-specific overlay personas (e.g., a TypeSurgeon for a TS-heavy shop) should live alongside as their own `persona-<slug>/SKILL.md` directories.

---

## 🧰 What's NOT in this scaffold

- **A CLI.** Swarm is a documentation framework. Tools that implement it (the Swarm CLI, plus any compatible runner) live in separate repos.
- **Project-specific skills.** Add yours under `.agents/skills/domain/` after install.
- **The constitution.** Your project's non-negotiable baselines (`.agents/constitution.md`) is project-specific; the scaffold doesn't ship one.
- **Source docs (specs, audits, bugs, research).** Those are your project's content; the scaffold creates the *directories* but you author the *files*.
- **Conformance checker.** A future addition. The scaffold's structure is the conformance contract for now.

---

## 📜 Updating an installed scaffold

When the framework releases a new version with scaffold changes, the project repo's CHANGELOG and `MIGRATIONS.md` will list:

1. **Changed files** — diff against your installed copy, apply changes
2. **New files** — copy in
3. **Removed files** — remove (or deprecate per the migration notes)

Treat the scaffold like any vendored dependency: track the version you installed, update deliberately.

---

## 📚 Reference

For the *why* behind every artefact, see the upstream Swarm framework repo (these live there, not in your vendored copy):

- The framework's main documentation is at `/docs/` in the Swarm framework repo.
- The persona-task-doc mapping is in the Swarm framework repo's `/docs/reference/flow-graph.md` (the scaffold ships its own copy of the routing graph at `docs/agents/05-flow-graph.md`).
- The placeholder contract is in the Swarm framework repo's `/docs/reference/template-placeholders.md`.
- The conceptual frame is in the Swarm framework repo's `/docs/concepts/`.

But again — **once you copy the scaffold into your repo, you don't need the upstream `/docs/` for day-to-day operation.** The scaffold is self-contained.
