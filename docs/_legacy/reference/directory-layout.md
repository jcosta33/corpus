# 📖 Reference: Directory layout

> The minimum directory structure for a Swarm-conformant repo. Empty directories exist by convention so agents know where to place new artefacts without inventing locations.

---

## 🏠 Repo root

```
.
├── AGENTS.md                          # entry point — see reference/agents-md.md
├── .gitignore                         # must include .agents/tasks/
└── .agents/
    ├── tasks/                         # gitignored; worktree-local task files
    ├── templates/                     # shared task skeleton, skill-less task templates, source-doc + skill meta-templates
    ├── skills/                        # self-activating skills (workflow, quality-gate, persona, domain)
    ├── specs/                         # source doc: feature specs
    ├── audits/                        # source doc: codebase audits
    ├── bugs/                          # source doc: bug reports
    └── research/                      # source doc: external knowledge
```

---

## 🗄️ Optional but recommended

```
.agents/
    ├── adrs/                          # Architecture Decision Records
    ├── constitution.md                # project-wide non-negotiable baselines
    ├── migrations/                    # migration plans (specialised specs)
    ├── benchmarks/                    # benchmark reports (specialised audits)
    ├── cleanups/                      # cleanup lists (specialised audits)
    ├── test-plans/                    # test plans (specialised specs)
    ├── audit-briefs/                  # framing for audit-writing tasks
    ├── research-questions/            # framing for research-writing tasks
    ├── review-scopes/                 # framing for review tasks
    └── reviews/                       # review reports (Skeptic verdicts)
```

---

## 🛠️ Skills directory

The 24 shipped skills are flat siblings under `.agents/skills/`. There is **no always-loaded skill** and no consolidated `personas/SKILL.md` — each persona is its own self-activating skill. Each non-persona skill carries a `references/` folder (most hold a `task-template.md`).

```
.agents/skills/
    │ # Quality gates (3) — cross-cutting disciplines
    ├── empirical-proof/
    │   ├── SKILL.md
    │   └── references/evasions.md
    ├── adversarial-review/
    │   ├── SKILL.md
    │   └── references/task-template.md
    ├── distillation-discipline/
    │   ├── SKILL.md
    │   └── references/worked-example.md
    │
    │ # Specialised (1)
    ├── fix-flaky-test/
    │   ├── SKILL.md
    │   └── references/task-template.md
    │
    │ # Workflow / authoring (12) — write-<type>, each with references/task-template.md
    ├── write-spec/
    ├── write-audit/
    ├── write-research/
    ├── write-bug-report/
    ├── write-feature/
    ├── write-fix/
    ├── write-refactor/
    ├── write-rewrite/
    ├── write-migration/
    ├── write-performance/
    ├── write-testing/
    ├── write-documentation/
    │
    │ # Personas (8) — self-activating mindset skills
    ├── persona-architect/SKILL.md
    ├── persona-auditor/SKILL.md
    ├── persona-janitor/SKILL.md
    ├── persona-migrator/SKILL.md
    ├── persona-performance-surgeon/SKILL.md
    ├── persona-skeptic/SKILL.md
    ├── persona-surveyor/SKILL.md
    ├── persona-lead-engineer/SKILL.md
    │
    └── domain/                         # project-specific skills accumulate here
        └── (e.g., architecture-violations, testing-file-layout, etc.)
```

The other 5 catalogued mindsets (Builder, Bug Hunter, Documentarian, Researcher, Test Author) do **not** ship as persona skills — they are carried by the matching workflow skill (Builder → `write-feature`, Bug Hunter → `write-bug-report`, Documentarian → `write-documentation`, Test Author → `write-testing`, Researcher → `write-research`). Lead Engineer ships `persona-lead-engineer` *because* orchestration has no workflow skill to carry its coordination mindset (ADR 0025); the flat `task-orchestration.md` remains its task template.

Skills can be:

- **Folders** (`<name>/SKILL.md` plus optional `references/`, `scripts/`, `examples/` subdirectories) — preferred for skills that benefit from progressive disclosure; every shipped skill uses this form
- **Flat files** (`<name>.md`) — fine for short project skills

The `name` and `description` in the YAML frontmatter is what the agent uses; the format follows the open [Agent Skills spec](https://agentskills.io). Each shipped `SKILL.md` body is **self-contained** — it references project commands by their `AGENTS.md > Commands` entry name, not by path, and carries no cross-skill links.

---

## 📄 Templates directory

The flat `templates/` directory is deliberately slim (8 files). Per-task-type task templates do **not** live here — each workflow skill owns its own `references/task-template.md`. Only the shared task skeleton, the two skill-less task types, the four source-doc templates, and the skill meta-template stay flat.

```
.agents/templates/
    ├── task-base.md                    # the shared task skeleton (documents the base; not launched)
    ├── task-orchestration.md           # skill-less task type (Lead Engineer mindset)
    ├── task-review.md                  # skill-less task type (Skeptic mindset)
    │
    ├── spec.md                         # source-doc template
    ├── audit.md                        # source-doc template
    ├── bug-report.md                   # source-doc template
    ├── research.md                     # source-doc template
    │
    └── skill.md                        # meta-template for authoring new skills
```

Per-skill task templates live alongside their skill:

```
.agents/skills/write-feature/references/task-template.md
.agents/skills/write-fix/references/task-template.md
… (one per workflow skill, plus fix-flaky-test and adversarial-review)
```

All of these contain `{{placeholders}}` (see [`template-placeholders.md`](template-placeholders.md)). The launcher resolves the `{{cmd*}}` ones from the project's `AGENTS.md > Commands` section.

---

## 📁 Worktrees

When the agent CLI uses git worktrees (recommended for parallel work):

```
.worktrees/
    ├── <slug-1>/                       # one worktree per active task
    ├── <slug-2>/
    └── ...
```

Each worktree has its own `.agents/tasks/<slug>.md` (gitignored). The other `.agents/` directories are shared (via the worktree's git linkage).

---

## ✅ Conformance checklist

A repo is Swarm-conformant if:

- [ ] `AGENTS.md` exists at the repo root with a `## Commands` section binding the required entries (`Validation`, `Test`, `Format`) and a `## Skills` section establishing self-activation (no always-loaded skill)
- [ ] `.gitignore` includes `.agents/tasks/`
- [ ] `.agents/tasks/` exists (and is empty in the committed state)
- [ ] `.agents/templates/` contains the shared `task-base.md`, the two skill-less task templates (`task-orchestration.md`, `task-review.md`), the four source-doc templates (`spec.md`, `audit.md`, `bug-report.md`, `research.md`), and the `skill.md` meta-template
- [ ] `.agents/skills/` contains the 8 persona skills (`persona-{architect,auditor,janitor,migrator,performance-surgeon,skeptic,surveyor,lead-engineer}/SKILL.md`)
- [ ] `.agents/skills/` contains the 3 quality-gate skills (`empirical-proof`, `adversarial-review`, `distillation-discipline`)
- [ ] `.agents/skills/` contains the 12 workflow skills (`write-{spec,audit,research,bug-report,feature,fix,refactor,rewrite,migration,performance,testing,documentation}`) plus `fix-flaky-test`
- [ ] Each non-persona skill ships a `references/` folder (a `task-template.md`, except `distillation-discipline`=`worked-example.md` and `empirical-proof`=`evasions.md`)
- [ ] `.agents/specs/`, `.agents/audits/`, `.agents/bugs/`, `.agents/research/` all exist (even if empty)
- [ ] Every persona skill body includes the framework subsections (Role / Mindset / Hard constraints / Forbidden actions / Decision heuristics / Checklist)
- [ ] Every `write-<type>` skill body includes the framework subsections (Purpose / Core rules / What does not belong / Anti-patterns)
- [ ] Every shipped `SKILL.md` body is self-contained (no cross-skill links; references commands by their `AGENTS.md > Commands` entry, not by path)
- [ ] AGENTS.md instructs every agent to read its task file at `.agents/tasks/<slug>.md` as its first action

A conformance checker (when it ships) automates this validation.

---

## 🎨 Variations

The above is the *minimum*. Projects can:

- Use folder-based skills (with sub-files) for progressive disclosure
- Add overlay persona skills (`.agents/skills/persona-<slug>/SKILL.md`, project-specific)
- Add `.agents/skills/domain/` skills as the project accumulates patterns
- Separate active and shipped specs into `.agents/specs/active/` and `.agents/specs/shipped/`
- Separate active and resolved audits similarly
- Add additional doc types (extended) under their own subdirectories

The framework cares about the *minimum*; everything beyond it is a project choice.

---

## See also

- [`agents-md.md`](agents-md.md) — what AGENTS.md should contain
- [`template-placeholders.md`](template-placeholders.md) — placeholder contract
- [`flow-graph.md`](flow-graph.md) — what each task type expects
- [`guides/adopting-swarm.md`](../guides/adopting-swarm.md) — how to install the layout
