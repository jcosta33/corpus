# 📒 Guide: Customizing personas

> How to use a different persona than the suggested default for a task, and how to add an overlay persona for project-specific work the framework's catalogue doesn't cover.

---

## ⚡ TL;DR

Personas **self-activate**. Each of the eight shipped persona skills carries a directive `description`; the agent loads the one whose triggers match the work it's doing. There is no central `personas/SKILL.md` to fork and no launcher that hard-binds a persona to a task type.

Two customisation mechanisms:

1. **Use a different shipped persona** than the suggested default — just load the `persona-<slug>` skill whose `description` fits the task, and record the divergence in the task file.
2. **Add an overlay persona** as a new skill under `.agents/skills/persona-<name>/` for recurring project-specific work the eight shipped personas don't cover.

Overlays don't require framework approval. The framework graduates an overlay to canonical only when many projects independently demand it.

---

## 🎭 How personas activate now

Swarm ships **eight persona skills** — `persona-architect`, `persona-auditor`, `persona-janitor`, `persona-lead-engineer`, `persona-migrator`, `persona-performance-surgeon`, `persona-skeptic`, `persona-surveyor` — each a standalone, self-contained `.agents/skills/persona-<slug>/SKILL.md`. The agent adopts one by loading the skill whose directive `description` matches the task; no persona skill depends on any other, and none loads on every task.

The conceptual catalogue still describes **thirteen mindsets** (see [`personas/README.md`](../personas/README.md)). The other five — Builder, Bug Hunter, Documentarian, Researcher, Test Author — are *not* separate persona skills. Their stance is carried by the matching workflow skill (Builder → `write-feature`, Bug Hunter → `write-bug-report`, Documentarian → `write-documentation`, Researcher → `write-research`, Test Author → `write-testing`). Lead Engineer is the exception: orchestration has no *workflow* skill, so its coordination mindset is the discipline and it ships as the `persona-lead-engineer` skill (the flat `task-orchestration.md` template remains its task scaffold). See [`skills/personas.md`](../skills/personas.md) for the full mapping.

The flow graph maps each task type to a *suggested* persona ([`reference/flow-graph.md`](../reference/flow-graph.md)), and the directive descriptions reproduce that routing in-session. It is **recommended, not enforced** — a launcher may pre-fill a suggested persona when it scaffolds a task file, but the agent re-assesses against the work in front of it.

---

## 🔄 Using a different persona than the suggested default

When the task in front of you doesn't match the suggested default — say the flow graph suggests The Skeptic for a `fix` task but the work is genuinely a minimality-focused cleanup — **load the persona skill whose `description` fits** and record the divergence in the task file's `## Decisions`. That's the whole mechanism. There is no central routing table to edit and no config to fork.

Common reasons to diverge from the suggested default:

| Suggested default                       | When you might pick another                                                |
| --------------------------------------- | --------------------------------------------------------------------------- |
| `fix` → The Skeptic                     | The work is behaviour-preserving cleanup → load `persona-janitor` instead    |
| `migration` → The Migrator              | The change is performance-shaped → load `persona-performance-surgeon`        |
| `audit` → The Auditor                   | The audit is an adversarial second pass (`deepen-audit`) → load `persona-skeptic` |

The divergence is *explicit* — a line in the task file's `## Decisions` so any contributor reading the task file can see which persona ran and why. If your team finds itself diverging the same way for the same task type repeatedly, note the standing preference in the consuming repo's `AGENTS.md > Routing` section so it's visible without spelunking through old task files.

> [ADR 0002](../adrs/0002-personas-1-to-1-with-task-types.md) — the original strict 1-to-1 mapping — is now **superseded to suggested defaults; the agent may re-assess.** Picking a different persona is not an override of a hard rule; it's the framework working as designed.

---

## ➕ Adding an overlay persona

When the eight shipped personas don't capture recurring project-specific discipline, add an overlay — **a new persona skill** under `.agents/skills/persona-<name>/`, beside the shipped eight. It follows the same authoring discipline as any other skill ([`writing-skills.md`](writing-skills.md)) and the same profile shape as the shipped personas ([`personas/README.md` § Profile shape](../personas/README.md#-profile-shape-conceptual--full-headings-live-in-scaffold)).

### When to add an overlay

A new overlay is justified when:

- The work is *recurring* in your codebase (not a one-off task)
- The work has *distinct hard constraints* that none of the eight shipped personas capture
- The work has *distinct empirical proofs* that warrant their own Self-review questions

If the work folds cleanly into an existing persona with a different mindset switch, *don't* add an overlay — use the existing one.

### Common overlay candidates

| Overlay                | Lifts from                          | Triggering pattern                                            |
| ---------------------- | ----------------------------------- | ------------------------------------------------------------- |
| **The Type Surgeon**   | a TypeScript-soundness mindset      | TypeScript codebase with strict generics / variance constraints |
| **The Integrator**     | an SDK/MCP wiring mindset           | Heavy third-party integration work                           |
| **The Spike Investigator** | bounded throwaway prototyping   | Spike code answering one explicit, bounded question                 |
| **The Security Reviewer** | (project-defined)                | Regulated codebase requiring per-PR security audit            |
| **The Accessibility Auditor** | (project-defined)            | UI codebase with WCAG conformance requirements                |
| **The Data Engineer**  | (project-defined)                   | Data pipeline / ETL work with its own constraints             |

These appear in the [Persona section's overlay catalogue](../personas/README.md#-project-level-overlays).

### How to add an overlay

1. **Author the persona skill** at `.agents/skills/persona-<name>/SKILL.md`. Mirror the iron-law scaffold the shipped personas use — `Hard constraints`, `Forbidden actions`, `Empirical proofs`, `Red flags`, handoffs — and a directive `description` whose `Skip this skill for …` clause names the *task types* this persona is not for (never a sibling persona's name). Rationale: [`concepts/04-personas.md`](../concepts/04-personas.md) and the profile-shape notes in [`personas/README.md`](../personas/README.md).
2. **Keep it self-contained.** The overlay assumes no sibling persona is installed; its body links no other skill and hard-codes no consumer `.agents/…` path. Project commands are referenced as `AGENTS.md > Commands > …` in prose.
3. **Record the standing preference, if any.** If a task type should default to the overlay, note it in the consuming repo's `AGENTS.md > Routing` section so humans can audit the preference without binary-config spelunking.
4. **(Optional)** Draft an ADR documenting why merging into an existing persona failed — it prevents silent persona explosion.

Operational shortcuts produce decorative personas incapable of powering the Self-review gate. The profile shape is what makes the persona *operational*.

---

## 🪜 Graduation: when an overlay becomes canonical

If many projects independently adopt the same overlay (or a similar one), the framework may *graduate* it to canonical (as the ninth, tenth, … shipped persona skill). The path:

1. Multiple projects use the same overlay (3+ independent codebases is a reasonable signal)
2. A framework contributor proposes graduation via an ADR
3. The proposed persona skill is reviewed and refined
4. The persona enters the shipped catalogue (`scaffold/.agents/skills/persona-<slug>/`) and the conceptual catalogue (`docs/personas/`)
5. The release notes document the change for adopters

Until graduation, overlays are project-level and don't affect framework-conformance.

---

## ⚠️ Common mistakes

- **Adding an overlay because an existing persona "feels off"** — usually fixable by adopting the persona properly, not by inventing a new one. Try the existing persona for 3–5 sessions first.
- **Inventing personas per session** — forbidden. The persona is catalogued (as a skill) before it's used.
- **Diverging from the suggested default without recording why** — note the divergence in the task file's `## Decisions`; a standing preference goes in `AGENTS.md > Routing`.
- **Naming a sibling persona in an overlay's `Skip for …` clause** — name the *task type* instead; self-containment forbids assuming a sibling is installed.
- **Overlay personas that skip the profile shape** — no Hard constraints, no Red flags, no Empirical proofs makes the overlay aspirational rather than operable; the Self-review gate has nothing to enforce.

---

## See also

- [`personas/README.md`](../personas/README.md) — the persona catalogue and profile shape
- [`skills/personas.md`](../skills/personas.md) — how the eight persona skills map to the thirteen mindsets
- [`concepts/04-personas.md`](../concepts/04-personas.md) — the conceptual frame
- [`reference/compatibility-matrix.md`](../reference/compatibility-matrix.md) — the suggested routing mappings
- [`writing-skills.md`](writing-skills.md) — how to author the overlay skill
- [ADR 0002](../adrs/0002-personas-1-to-1-with-task-types.md) — the 1-to-1 mapping, superseded to suggested defaults
- [ADR 0009](../adrs/0009-personas-are-mindsets.md) — mindset, not role
- [ADR 0019](../adrs/0019-personas-ship-as-individual-skills.md) — why personas ship as individual skills
- [`extending-the-framework.md`](extending-the-framework.md) — how to propose adding to the framework itself
