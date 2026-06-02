# 📒 Guide: Adopting Swarm

> Step-by-step: a project author starting from a non-Swarm repo, how do they bring Swarm in. The scaffold does most of the work — copy a directory, bind a few placeholders, you're conformant.

---

## ⚡ TL;DR

Adopting Swarm is mostly *copying the scaffold* and *binding a few placeholders*. There is no runtime to install; no daemon to start. The framework is documentation; adopting it is a docs operation.

The full install:

1. Copy `/scaffold/` into your repo's root (mirror-the-paths convention) — or vendor only the skill folders you actually need
2. Append `/scaffold/.gitignore.additions` to your `.gitignore`
3. Edit `AGENTS.md`'s `## Commands` section to bind the command contract to your project's commands
4. Optionally write a `.agents/constitution.md` capturing project-wide non-negotiable baselines
5. Verify the install (the conformance checker, when it ships, automates this)

---

## 🪞 The two halves of this repo

Before you start, understand what's where:

- **`/docs/`** — the framework's documentation. *Read* this when you want to understand the framework. Don't copy it.
- **`/scaffold/`** — the literal artefacts you copy into your repo. **Self-contained**: every reference inside `/scaffold/` points to other files inside `/scaffold/` (using `.agents/...` paths the consumer would have). When you copy `/scaffold/` into your repo, no links break.

**You only ever copy `/scaffold/`.** You read `/docs/` while adopting (and afterwards) for the *why*.

---

## 🪜 Pre-flight

Before adopting Swarm, confirm:

- ✅ The project has at least *some* documentation discipline. Swarm amplifies what you already do; it doesn't manufacture discipline from nothing.
- ✅ At least one developer (or AI engineer) is willing to be the framework's first user.
- ✅ You're working with an agent CLI that supports `AGENTS.md` (Claude Code, Codex, Cursor, Aider, Devin, opencode, etc.).
- ✅ You're using git, ideally with worktree support (`git worktree`).

Optional but helpful:

- A project-wide constitution (architectural invariants, security mandates) you can capture in `.agents/constitution.md`
- Existing audit-style notes you can promote to formal `audit.md` files
- A running list of architecturally significant decisions you can promote to ADRs

---

## 🪜 Step 1: Copy the scaffold

From your repo's root, with this Swarm repo cloned somewhere:

```bash
# Replace SWARM_REPO with the path to this Swarm repo
SWARM_REPO=/path/to/swarm

# Copy everything from /scaffold/ into your repo root
cp -r ${SWARM_REPO}/scaffold/.agents .
cp -r ${SWARM_REPO}/scaffold/docs/agents docs/
cp ${SWARM_REPO}/scaffold/AGENTS.md .
cp ${SWARM_REPO}/scaffold/CLAUDE.md .
cp ${SWARM_REPO}/scaffold/GEMINI.md .

# Append the gitignore additions
cat ${SWARM_REPO}/scaffold/.gitignore.additions >> .gitignore

# Create the source-doc directories (the scaffold creates the rest)
mkdir -p .agents/{tasks,specs,audits,bugs,research}
```

What this gives you:

- `AGENTS.md` (root entry point with `TODO` markers and a `## Commands` contract section)
- `CLAUDE.md`, `GEMINI.md` (cross-tool aliases)
- `.gitignore` includes `.agents/tasks/` and `.worktrees/`
- `docs/agents/01-process.md` through `05-flow-graph.md` (process docs every project ships)
- `.agents/skills/` with all 24 shipped skills: 3 quality gates, 1 specialised, 12 authoring, and 8 individual `persona-<slug>` skills — each a self-contained `<name>/SKILL.md`. There is **no always-loaded skill**; each self-activates on its directive `description`.
- `.agents/templates/` with the 8 flat templates (4 source-doc templates, the `skill.md` meta-template, the shared `task-base.md`, and the two skill-less task types `task-orchestration.md` / `task-review.md`). Per-skill task templates live in each skill's `references/task-template.md`.
- Empty `.agents/{tasks,specs,audits,bugs,research}/` directories ready for content

Verify:

```bash
ls -1 .agents/skills/             # should list 24 skill directories
ls -la .agents/templates/         # should list 8 flat templates
ls -la docs/agents/               # should list 5 process docs
grep -F ".agents/tasks/" .gitignore  # should match
```

---

## 🪜 Step 2: Bind the command contract

Open `AGENTS.md`. Search for `TODO` markers:

```bash
grep -n "TODO" AGENTS.md
```

You'll find:

- A `## Project conventions` section with `TODO` placeholders for language, runtime, test runner, package manager
- A `## Commands` section — the **command contract**. Skill bodies reference these entries by name in prose (e.g. *"run the project's validation command, `AGENTS.md > Commands > Validation`"*) and degrade gracefully — if an entry is missing they ask you before running anything. Launchers bind the `{{cmd*}}` placeholders in templates and `references/task-template.md` files from the same entries.

The `## Commands` section has a **Required** block (skills rely on these) and an **Extended** block (bound when the relevant work occurs; mark `n/a` with a one-line reason if your project has none). Replace each `TODO` with your command. Example for a TypeScript / pnpm project:

```markdown
| Command (referenced as `Commands > …`) | Template placeholder | Bind to                              |
| -------------------------------------- | -------------------- | ------------------------------------ |
| `Validation`                           | `{{cmdValidate}}`    | `pnpm typecheck && pnpm lint`        |
| `Test`                                 | `{{cmdTest}}`        | `pnpm test`                          |
| `Format`                               | `{{cmdFormat}}`      | `pnpm format`                        |

Extended (bind when the work occurs, or mark `n/a`):

| `Install`        | `{{cmdInstall}}`      | `pnpm install`                       |
| `Typecheck`      | `{{cmdTypecheck}}`    | `pnpm typecheck`                     |
| `Build`          | `{{cmdBuild}}`        | `pnpm build`                         |
| `ValidateDeps`   | `{{cmdValidateDeps}}` | `pnpm validate:deps` (dependency-cruiser) |
| `Benchmark`      | `{{cmdBenchmark}}`    | `n/a` — only used by performance tasks |
```

Skills never invent commands. If a value isn't in `## Commands`, they ask you and proceed once told. Extended entries you don't have can be marked `n/a` with a one-line justification.

---

## 🪜 Step 3: Optionally write the constitution

If your project has architecturally invariant rules (security mandates, layering, language version pins), capture them in `.agents/constitution.md`. There's no template in scaffold for this (the constitution is project-specific by design); recommended sections:

- `## §1. Tech stack`
- `## §2. Code quality`
- `## §3. Architecture`
- `## §4. Security`
- `## §5. Testing`

The constitution is read by every persona before serious work; it's the supreme law of the project. Specs, audits, and ADRs reference it.

---

## 🪜 Step 4: Verify the install

Manual checklist (when the conformance checker ships, automates these):

- [ ] `AGENTS.md` exists at repo root, with a `## Commands` section
- [ ] `AGENTS.md` no longer contains `TODO` markers (`grep -c TODO AGENTS.md` → 0)
- [ ] `.gitignore` includes `.agents/tasks/` and `.worktrees/`
- [ ] `.agents/skills/` contains 24 skill directories (`ls -1 .agents/skills/ | wc -l` → 24)
- [ ] The 3 quality gates exist: `adversarial-review/`, `distillation-discipline/`, `empirical-proof/`
- [ ] The 8 persona skills exist: `persona-{architect,auditor,janitor,lead-engineer,migrator,performance-surgeon,skeptic,surveyor}/`
- [ ] The 12 authoring skills exist: `write-{spec,audit,research,bug-report,feature,fix,refactor,rewrite,migration,performance,testing,documentation}/`
- [ ] `fix-flaky-test/SKILL.md` exists
- [ ] `.agents/templates/` contains the 8 flat templates
- [ ] `.agents/specs/`, `.agents/audits/`, `.agents/bugs/`, `.agents/research/` all exist
- [ ] `docs/agents/01-process.md` through `05-flow-graph.md` exist

---

## 🪜 Step 5: Run your first conditioned task

Pick a small piece of work — a feature, a small refactor, a doc update — and:

1. **Author the source doc** (e.g., a small spec at `.agents/specs/<slug>.md`, using the template at `.agents/templates/spec.md`).
2. **Scaffold a conditioned task file** at `.agents/tasks/<slug>.md` (use the governing skill's `references/task-template.md` — e.g. `.agents/skills/write-feature/references/task-template.md` — or, for the two skill-less task types, `.agents/templates/task-orchestration.md` / `task-review.md`; bind the placeholders).
3. **Open the task file in your agent CLI**.
4. **Tell the agent: *"Read the task file and proceed."***

The agent will:

- Load the persona skill whose directive `description` matches the work (e.g. `.agents/skills/persona-skeptic/SKILL.md`), or adopt the mindset carried by the matching workflow skill (e.g. The Builder via `write-feature`), and adopt that stance
- Read the source doc
- Plan, implement, run gates, paste outputs
- Hand off to The Skeptic for review (if applicable)

If something feels off — the agent skipped a step, didn't load a skill, paraphrased verification output instead of pasting — the framework's discipline isn't yet sticky. That's normal for the first few sessions. The discipline tightens as the agent (and you) get the rhythm.

---

## 🪜 Step 6: Iterate

Over time:

- **Promote durable findings** to audits / specs / research (the promotion protocol; see `docs/agents/01-process.md` in your installed scaffold)
- **Add project-specific skills** under `.agents/skills/domain/` as you encounter patterns. Use `.agents/templates/skill.md` as the meta-template, and the [writing-skills guide](writing-skills.md) for the authoring discipline.
- **Add overlay personas** if the eight shipped persona skills miss recurring local discipline. An overlay is a new self-contained persona skill at `.agents/skills/persona-<name>/SKILL.md`, beside the shipped eight (see [`customizing-personas.md`](customizing-personas.md)). There's no central `personas/SKILL.md` to fork.
- **Add ADRs** as you make structurally significant decisions. There's no canonical scaffold ADR template (yet); use the format documented in `docs/documents/extended.md` of this Swarm repo.
- **Update the constitution** as architectural invariants emerge.

The framework grows with the project. The discipline is in the *artefacts*, not in the tooling.

---

## 🪜 Updating an installed scaffold

When this Swarm framework releases a new version with scaffold changes:

1. **Read the project's CHANGELOG and the release notes** to see what changed
2. **Diff your installed copy against the new scaffold** (e.g., `diff -r .agents/skills /path/to/swarm/scaffold/.agents/skills`)
3. **Apply changes** — copy in new files; merge changes to modified files; remove deprecated files
4. **Re-bind any new `## Commands` entries** introduced by new templates or skills

Treat the scaffold like any vendored dependency: track the version you installed, update deliberately.

---

## ⚠️ Common adoption pitfalls

| Pitfall                                                                | Symptom                                                            | Fix                                                              |
| ---------------------------------------------------------------------- | ------------------------------------------------------------------ | ---------------------------------------------------------------- |
| Skipping the first-action paragraph in AGENTS.md                       | Agents don't read the task file first; default to helpfulness     | The scaffold's AGENTS.md ships with this paragraph. Don't remove it |
| Binding placeholders to commands that don't exist                      | Tasks fail at the verification gate                                | Either implement the command or mark the slot `n/a`             |
| Trying to copy from `/docs/` instead of `/scaffold/`                  | Cross-references break (because `/docs/` files reference each other) | Always copy from `/scaffold/`. `/docs/` is documentation; `/scaffold/` is artefacts |
| Installing skills as "just files" without reading them                 | Discipline doesn't take hold                                       | Read each skill at least once; understand what it enforces       |
| Writing the first task before any source doc                           | Ungrounded work — the recommended routing wants a source doc first | Author a source doc first, even a tiny one. Routing is guidance, not gatekeeper-enforced |
| Trying to bend Swarm to a tooling-first mental model                   | Frustration that the framework "doesn't do" the work for you     | Re-read [`PRINCIPLES.md`](../PRINCIPLES.md); Swarm is documentation, not tooling |

---

## 🪞 What you've installed

After step 1, your repo contains:

```
your-project/
├── AGENTS.md                          # entry point (with TODO markers to fill in)
├── CLAUDE.md                          # @AGENTS.md import
├── GEMINI.md                          # AGENTS.md pointer
├── .gitignore                         # includes .agents/tasks/, .worktrees/
│
├── docs/
│   └── agents/                        # human-facing process docs
│       ├── 01-process.md
│       ├── 02-file-types.md
│       ├── 03-workflow.md
│       ├── 04-standards.md
│       └── 05-flow-graph.md
│
└── .agents/
    ├── tasks/                         # gitignored, worktree-local
    ├── templates/                     # 8 flat templates (source-doc + skill meta + task-base + 2 skill-less task types)
    ├── skills/                        # 24 self-contained skills, each <name>/SKILL.md
    │   ├── adversarial-review/        # quality gates (3)
    │   ├── distillation-discipline/
    │   ├── empirical-proof/
    │   ├── fix-flaky-test/            # specialised (1)
    │   ├── persona-{architect,auditor,janitor,lead-engineer,migrator,performance-surgeon,skeptic,surveyor}/  # personas (8)
    │   └── write-{spec,audit,research,bug-report,feature,fix,refactor,rewrite,migration,performance,testing,documentation}/  # authoring (12); each ships references/task-template.md
    ├── specs/                         # populate as your project authors specs
    ├── audits/                        # populate as your project audits areas
    ├── bugs/                          # populate as bugs are reported
    └── research/                      # populate as research is gathered
```

After step 5 (your first task), you'll also have:

- `.agents/specs/<your-first-slug>.md` — your first spec
- `.agents/tasks/<your-first-slug>.md` — your first conditioned task file (gitignored)
- A branch in your worktree with the work the agent did

After many sessions, you'll have:

- Many specs, audits, bugs, research files in `.agents/`
- A `.agents/skills/domain/` directory with your project-specific skills
- A `.agents/constitution.md` capturing your invariants
- A `.agents/adrs/` directory if you adopted ADRs
- A growing pattern library that future agents can lean on

---

## See also

- [`/scaffold/README.md`](../../scaffold/README.md) — the scaffold's own install procedure (with placeholder catalogue)
- [`quickstart.md`](quickstart.md) — the 10-minute version
- [`reference/agents-md.md`](../reference/agents-md.md) — the AGENTS.md anatomy
- [`reference/directory-layout.md`](../reference/directory-layout.md) — the canonical layout
- [`reference/template-placeholders.md`](../reference/template-placeholders.md) — the placeholder contract
- [`customizing-personas.md`](customizing-personas.md) — adding overlay personas
- [`monorepo-setup.md`](monorepo-setup.md) — nested AGENTS.md
- [`PRINCIPLES.md`](../PRINCIPLES.md) — the load-bearing constraints
