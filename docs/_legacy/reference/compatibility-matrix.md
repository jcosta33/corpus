# 📖 Reference: Compatibility matrix

> Three printable tables. Designed to be the single most-referenced document in the repo.

---

## Table 1: Personas × Document types

Who authors what, who reviews what.

| Persona                  | Primary author of                          | Secondary reviewer of                  |
| ------------------------ | ------------------------------------------ | -------------------------------------- |
| The Architect            | spec, ADR, constitution                    | research                               |
| The Researcher           | research (technical)                       | ADR                                    |
| The Surveyor             | research (UX/market)                       | spec                                   |
| The Bug Hunter           | bug-report                                 | audit                                  |
| The Auditor              | audit, cleanup list                        | bug-report, constitution               |
| The Lead Engineer        | migration plan (logistics), orchestration tracker | spec                              |
| The Performance Surgeon  | benchmark report                           | spec                                   |
| The Test Author          | test plan                                  | spec                                   |
| The Skeptic              | review report, kickback notes              | every code-producing branch            |
| The Builder              | (code, no durable docs)                    | —                                      |
| The Janitor              | (refactored code, no durable docs)         | —                                      |
| The Migrator             | (migrated code, no durable docs)           | —                                      |
| The Documentarian        | user-facing docs (READMEs, how-tos, references) | —                                 |

---

## Table 2: Personas × Task types

The **suggested** default lead persona per task type. ADR 0002's strict 1-to-1 mapping is superseded — these are suggested defaults the agent may re-assess (see the note below the table).

| Task type                       | Suggested lead persona        | Secondary (handoff)                       |
| ------------------------------- | ----------------------------- | ----------------------------------------- |
| `feature`                       | The Builder                   | The Skeptic                               |
| `fix`                           | The Skeptic                   | (kickback returns to original)            |
| `refactor`                      | The Janitor                   | The Skeptic                               |
| `rewrite`                       | The Builder                   | The Skeptic                               |
| `migration`                     | The Migrator                  | The Skeptic (per wave)                    |
| `upgrade`                       | The Migrator                  | The Skeptic (per wave)                    |
| `performance`                   | The Performance Surgeon       | The Skeptic                               |
| `testing`                       | The Test Author               | The Skeptic                               |
| `integration`                   | The Builder                   | The Skeptic                               |
| `kickback`                      | (original persona)            | The Skeptic (re-review)                   |
| `spec-writing`                  | The Architect                 | —                                         |
| `research-writing` (technical)  | The Researcher                | —                                         |
| `research-writing` (UX/market)  | The Surveyor                  | —                                         |
| `audit-writing`                 | The Auditor                   | —                                         |
| `bug-report-writing`            | The Bug Hunter                | —                                         |
| `review`                        | The Skeptic                   | —                                         |
| `deepen-audit`                  | The Skeptic                   | —                                         |
| `orchestration`                 | The Lead Engineer             | The Skeptic (merge-gate)                  |
| `documentation`                 | The Documentarian             | The Skeptic                               |

These are **suggested defaults**, not bindings. Of the 13 catalogued mindsets, only **8 ship as skills** — `persona-{architect,auditor,janitor,migrator,performance-surgeon,skeptic,surveyor,lead-engineer}` (each at `.agents/skills/persona-<slug>/SKILL.md`). The other 5 mindsets (Builder, Bug Hunter, Documentarian, Researcher, Test Author) are carried by the matching workflow skill (Builder → `write-feature`, Bug Hunter → `write-bug-report`, Documentarian → `write-documentation`, Test Author → `write-testing`, Researcher → `write-research`). Lead Engineer ships `persona-lead-engineer` *because* orchestration has no workflow skill to carry its coordination mindset ([ADR 0025](../adrs/0025-orchestration-coordination-artifact.md)); the flat `task-orchestration.md` remains its task template. The agent loads the `persona-<slug>` skill whose `description` fits, or relies on the workflow skill's own mindset, and records any divergence in `## Decisions`. ADR 0002 (strict 1-to-1) is superseded to "suggested defaults; agent may re-assess".

---

## Table 3: Document types × Task types

What triggers what.

| Source document                              | Spawned task type(s)                                                | Information loss budget                  |
| -------------------------------------------- | ------------------------------------------------------------------- | ---------------------------------------- |
| `research.md` (technical or UX)              | `spec-writing`, `audit-writing`                                     | High (fluff dropped, findings kept)      |
| `spec.md`                                    | `feature`, `testing`, `rewrite`, `integration`                      | Zero (lossless execution)                |
| `audit.md`                                   | `refactor`, `performance`, `deepen-audit`                            | Medium (preserves numbered issues)       |
| `bug-report.md`                              | `fix`                                                               | Zero (exact root cause required)         |
| `migration plan`                             | `migration`, `upgrade`                                              | Zero (mechanical, surface-preserving)    |
| `benchmark report`                           | `performance`                                                       | Zero (numbers preserved)                 |
| `cleanup list`                               | `refactor`                                                          | Zero (deletion-safety preserved)         |
| `test plan`                                  | `testing`                                                           | Zero (test-case list preserved)          |
| `audit brief`                                | `audit-writing`                                                     | n/a (the brief is the framing)          |
| `research question`                          | `research-writing`                                                  | n/a                                      |
| `review scope`                               | `review`                                                            | n/a                                      |
| `ADR`                                        | `feature`, `refactor` (when ADR introduces a constraint to apply)   | Low (constraints immutable)              |
| `constitution.md`                            | `audit-writing`, adversarial-review                                 | Zero (supreme guidelines)                |
| `task scope` (one-paragraph in task file)    | `documentation`, small `testing`                                    | n/a (the scope is the framing)          |

The "information loss budget" column is the *maximum* loss permitted at the transition. See [`concepts/03-distillation.md`](../concepts/03-distillation.md) for the loss-budget concept.

---

## 🛡️ How to use these matrices

- **As a routing oracle.** "I have an `audit.md` — what's the suggested task type?" Look at Table 3.
- **As a persona oracle.** "I have a `feature` task — what's the suggested persona, and does it ship as a skill?" Look at Table 2.
- **As an authorship guide.** "Who should write the ADR?" Look at Table 1.
- **As recommended routing.** These tables are *guidance, not gatekeeper-enforced* — no always-loaded skill blocks a divergent cell. The directive skill `description`s reproduce the routing in-session, and a launcher may apply it deterministically. Diverge by naming the reason in the task file's `## Decisions`.

---

## See also

- [`flow-graph.md`](flow-graph.md) — the routing tables (with skills + verification commands)
- [`personas/`](../personas/) — per-persona pages
- [`tasks/`](../tasks/) — per-task pages
- [`documents/`](../documents/) — per-doc pages
- [ADR 0002](../adrs/0002-personas-1-to-1-with-task-types.md) — the (now superseded) 1-to-1 mapping; today: suggested defaults
