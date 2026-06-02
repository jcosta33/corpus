# 🛠️ Skills

> The framework's shipped skills. Each is a self-contained discipline that loads on demand when its `description` matches the work in front of you. Project-specific skills live in `.agents/skills/domain/` in the consumer repo.

> 📦 **The pages in this directory are *documentation about* the skills — what they do, why they exist, what failure modes they prevent.**
>
> The actual skill files (the ones the agent loads at runtime) live in [`/scaffold/.agents/skills/`](../../scaffold/.agents/skills/). Copy the folders you need into your project; each skill is self-contained (its body assumes no sibling skill is installed, so it stays valid after copying).

---

## ⚡ TL;DR

A skill is a Markdown file with YAML frontmatter that the agent loads on demand based on its `description`. The format matches the open [Agent Skills spec](https://agentskills.io), so a skill written for Swarm works in any compatible agent CLI. **There is no always-loaded skill** — install only the skills your work needs, and each one fires on its own directive `description`.

---

## 🧭 The catalogue

Swarm ships **24 skills**, in four groups. Each loads independently when its `description` matches the task; none depends on another being installed.

### 🚦 Quality gates (3)

Cross-cutting disciplines that surface inside whatever task is in play.

| Skill | Purpose |
| ----- | ------- |
| [`adversarial-review`](adversarial-review.md) | Review another agent's work hostile-to-plausible-explanations: the six adversarial questions, cross-module caller search, re-run validation yourself. |
| [`distillation-discipline`](distillation-discipline.md) | Distil a high-verbosity doc into a lower-verbosity one accountably — append a `## Distillation Loss Statement` recording what was dropped and why. |
| [`empirical-proof`](empirical-proof.md) | Back every verifiable claim with verbatim pasted command output. Show, don't tell — no "✅ all passing" summaries. |

### 🩺 Specialised (1)

A discipline for one narrowly-shaped problem.

| Skill | Purpose |
| ----- | ------- |
| [`fix-flaky-test`](fix-flaky-test.md) | Diagnose and stabilise a non-deterministic test — root-cause the nondeterminism rather than adding sleeps, retries, or quarantine. |

### ✍️ Authoring (12)

One skill per kind of work. Each codifies the failure modes its deliverable is built to prevent. Some produce a source doc; some produce code under a discipline.

| Skill | Authors / produces |
| ----- | ------------------ |
| [`write-spec`](write-spec.md) | A forward-looking spec — testable requirements, alternatives considered, no implementation details, halt on `[CRITICAL]`. |
| [`write-audit`](write-audit.md) | An audit of present state — observation not prescription, `file:line` citations, a "Needed" line per finding. Covers deepening an existing audit. |
| [`write-research`](write-research.md) | A research doc grounded in primary sources — finding vs opinion, no blog-post-as-source, no bare "it depends". |
| [`write-bug-report`](write-bug-report.md) | A defect record — reproduced verbatim, symptom separated from root cause, no fix included. |
| [`write-feature`](write-feature.md) | A feature from a spec — survey patterns first, map criteria to steps, halt on ambiguity, no scope creep. |
| [`write-fix`](write-fix.md) | A bug fix from a bug-report — regression test that fails before and passes after, no symptom-patching. |
| [`write-refactor`](write-refactor.md) | Behaviour-preserving restructuring — no observable behaviour change, prove call-site coverage before removing a shim. |
| [`write-rewrite`](write-rewrite.md) | A re-implementation with an explicit, recorded behaviour delta — halt and update the spec on any unplanned change. |
| [`write-migration`](write-migration.md) | An API migration or framework / language version upgrade — wave-by-wave validation, documented shim contracts, callsite coverage proof. |
| [`write-performance`](write-performance.md) | A targeted optimisation under a measured baseline — same-protocol benchmarks, full test suite after every change, document the conditions. |
| [`write-testing`](write-testing.md) | New or improved test coverage — test behaviour not implementation, the assertion-flip proof, no production code edited to pass a test. |
| [`write-documentation`](write-documentation.md) | User-facing documentation — one Diátaxis frame per doc, no hedging, every code example actually run. |

> Each skill name above links to its documentation page in this directory; the actual `SKILL.md` body ships in [`/scaffold/.agents/skills/`](../../scaffold/.agents/skills/) and is the runtime source of truth.

### 🎭 Personas (8)

Mindset-conditioning skills for role-shaped work. Each is a standalone, self-contained profile (~70 lines); load the one whose `description` matches the task. See [`personas.md`](personas.md) for the split model and why standalone skills beat one consolidated file. Of the 13 persona mindsets, these 8 ship as skills; the other 5 (Builder, Bug Hunter, Documentarian, Researcher, Test Author) are carried by their matching `write-*` workflow skill.

| Skill | Mindset |
| ----- | ------- |
| [`persona-architect`](../../scaffold/.agents/skills/persona-architect/SKILL.md) | Structural rigour for spec / requirements / design authoring. |
| [`persona-auditor`](../../scaffold/.agents/skills/persona-auditor/SKILL.md) | Observation-not-prescription for present-state audits. |
| [`persona-janitor`](../../scaffold/.agents/skills/persona-janitor/SKILL.md) | Behaviour preservation for refactor and dead-code work. |
| [`persona-lead-engineer`](../../scaffold/.agents/skills/persona-lead-engineer/SKILL.md) | Coordinate multiple agents to a merged, verified result — orchestration ships no workflow skill, so the coordination mindset is the discipline (see [`../adrs/0025-orchestration-coordination-artifact.md`](../adrs/0025-orchestration-coordination-artifact.md)). |
| [`persona-migrator`](../../scaffold/.agents/skills/persona-migrator/SKILL.md) | Wave-by-wave precision for API migrations and version upgrades. |
| [`persona-performance-surgeon`](../../scaffold/.agents/skills/persona-performance-surgeon/SKILL.md) | Measure-first discipline for optimisation under a target. |
| [`persona-skeptic`](../../scaffold/.agents/skills/persona-skeptic/SKILL.md) | Hostile-to-plausible-explanations review of another agent's work. |
| [`persona-surveyor`](../../scaffold/.agents/skills/persona-surveyor/SKILL.md) | Observed-vs-claimed evidence discipline for UX / market research. |

---

## 📐 The skill format

Every skill is a Markdown file with YAML frontmatter. The format follows the open [Agent Skills spec](https://agentskills.io).

```markdown
---
name: <skill-slug>
description: One or two sentences for the model. Tells the agent WHEN to load this skill.
---

# Skill: <Display name>

## Purpose

What this skill protects against. Why it exists.

## Core rules

Numbered. No hedging.

1.
2.

## What does not belong

Negative space — what to put elsewhere instead.

## Anti-patterns

Concrete failure modes with corrections.

## Examples (optional)

Worked examples illustrating the rules in action.
```

Key conventions:

- **`description` is for the model.** It answers the model's question: *"Should I load this now?"* Phrase it as a directive — a WHAT verb, an `ALWAYS apply this skill when …`, a `Do not … directly`, and a `Skip this skill for …` clause. See [`building/activation.md`](building/activation.md) for the empirical case behind that form.
- **Skills can be folders.** `.agents/skills/<name>/SKILL.md` plus `references/`, `scripts/`, `examples/` subdirectories enable progressive disclosure within a skill.
- **Skills load on demand.** The `description` triggers loading; the body is read only when triggered, and `references/` files only when the body points to them.

---

## 🛠️ Project-specific skills

Projects add their own skills under `.agents/skills/domain/`. They self-activate the same way the shipped skills do — by `description` match. Common candidates:

| Project skill                | Triggers when…                              |
| ---------------------------- | ------------------------------------------- |
| `architecture-violations`    | Editing core layers (presentation, db, etc.) |
| `testing-file-layout`        | Adding tests; need to know where they go    |
| `state-management`           | Touching state or persistence layers        |
| `api-versioning`             | Modifying public API contracts              |
| `audio-engine` / `react-state` / `<your domain>` | Domain-specific patterns         |

These accumulate over time as the team encounters areas where agents repeatedly violate constraints. The pattern is *codify the rule once you've explained it twice*.

---

## 🚦 How skills activate

Skills don't apply themselves by being installed; each carries a directive `description` and loads when its triggers match the work. There is no "core", "loader", or "index" skill that the others depend on, and nothing loads on every task — persistent project context (your stack, conventions, and commands) lives in `AGENTS.md`, not in a resident skill.

- The agent reads its task file (`.agents/tasks/<slug>.md`), which links the source doc, names a suggested persona, and lists the skills worth loading for that task type.
- Each skill fires on its own `description` when the task matches. A persona skill loads when the work is role-shaped (authoring a spec, reviewing a branch, refactoring); a quality gate loads when its discipline is in play (a verifiable claim → `empirical-proof`).
- The routing from source-doc → task type → suggested persona → skills is **recommended, not enforced**. A launcher may apply it deterministically when scaffolding a task; in-session, the directive descriptions reproduce it. When the work doesn't match the default, load the skill whose `description` fits and record the divergence in the task file.

The empirical reason this works — directive descriptions hitting ~100 % activation versus ~55 % for passive ones — and the reason there is no always-loaded skill both live in [`building/activation.md`](building/activation.md). The full rationale for every structural choice in the skill layer is in [`building/`](building/README.md).

---

## See also

- [`building/README.md`](building/README.md) — the science behind every structural choice in the skill layer
- [`building/activation.md`](building/activation.md) — why descriptions take the directive form; the no-always-load rule
- [`building/body-anatomy.md`](building/body-anatomy.md) — numbered rules, length budgets, progressive disclosure
- [`personas.md`](personas.md) — the eight persona skills and the split model
- [`../adrs/0024-confidence-tiers.md`](../adrs/0024-confidence-tiers.md) — the self-reviewed (floor) vs independently-reviewed confidence tiers a skill's output can reach
- [`../adrs/0025-orchestration-coordination-artifact.md`](../adrs/0025-orchestration-coordination-artifact.md) — the orchestration artifact fields `persona-lead-engineer` coordinates against (owned/forbidden paths, hand-off contract, liveness/stall/re-plan, per-conflict intent-preserved proof)
- [`../guides/writing-skills.md`](../guides/writing-skills.md) — how to write project-specific skills
- [`../reference/flow-graph.md`](../reference/flow-graph.md) — the recommended routing graph (source-doc → task → persona → skills)
