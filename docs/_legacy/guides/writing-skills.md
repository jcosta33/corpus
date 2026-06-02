# 📒 Guide: Writing skills

> How to author a project-specific skill that *loads when it should* and *fires once it's loaded*. The directive `description` contract; the body anatomy and length budget; self-containment; when a skill ships a `references/task-template.md`; when to write a skill at all vs. add to AGENTS.md or `docs/`.

---

## ⚡ TL;DR

A skill is a Markdown file with YAML frontmatter. Two things make it work, and both are empirically grounded:

1. The **`description`** decides whether the skill *loads*. Write it in directive form — and only the directive form reliably activates.
2. The **body** decides whether, once loaded, the rules actually *fire*. Numbered rules with rationale, an `## Anti-patterns` section, and a body that stays well under the length cap.

Skills carry *multi-step procedures* loaded on demand. Persistent facts (your stack, your commands) belong in `AGENTS.md`, which is always available. A skill authored to load on every task is the wrong primitive — its content belongs in `AGENTS.md`.

The depth behind every rule in this guide — with citations — lives in [`docs/skills/building/`](../skills/building/). This guide is the how-to; that directory is the why.

---

## 🪜 When to write a skill

Write a skill when:

- A *recurring constraint* trips agents up across sessions
- The constraint is *deep enough* that capturing it inline (in AGENTS.md or a task file) would bloat
- The constraint is *narrow enough* that loading it on demand — when the work touches the relevant area — beats loading it always

**Don't write a skill when:**

- The rule is universal — put it in `AGENTS.md`
- The rule is task-specific — put it in the task template (`references/task-template.md`)
- The rule is one-off — put it in the task file's `## Constraints`
- The rule is human-facing documentation — put it in `docs/`
- The rule *should always be loaded* — that's `AGENTS.md` content with a `SKILL.md` filename. Move it. See [`building/scope.md`](../skills/building/scope.md) and [`building/activation.md` § The "always-load" anti-pattern](../skills/building/activation.md#the-always-load-anti-pattern).

The pattern is *codify the rule once you've explained it twice*.

---

## 📐 The skill format

Skills are Markdown files with YAML frontmatter, matching the open [Agent Skills spec](https://agentskills.io). The canonical body skeleton (every shipped skill follows it):

```markdown
---
name: <kebab-case-slug>
description: <directive form — see § Writing the description, ~350–600 chars>
---

# Skill: <Display name>

## Purpose
<2–3 sentences. The failure mode this skill prevents.>

## Core rules
### 1. <Rule>
<rule body + 1–2 sentence rationale>

### 2. <Rule>
…

## What does not belong
<negative space — pointers to where adjacent content lives instead>

## Anti-patterns
<concrete failure modes with corrections: ❌ <pattern> → <correction>>

## Bundled resources
<one line per references/, scripts/, assets/ shipped alongside, if any>
```

### File location

| Form          | Path                                             | When to use                                 |
| ------------- | ------------------------------------------------ | ------------------------------------------- |
| Flat file     | `.agents/skills/<name>.md`                       | Short skills (one screen)                   |
| Folder form   | `.agents/skills/<name>/SKILL.md`                 | Skills with references / scripts / examples |

For folder form, optional subdirectories — each kept **exactly one hop** from `SKILL.md`:

```
.agents/skills/<name>/
├── SKILL.md             # the entry; same format as flat
├── references/          # detailed reference material the skill cites (e.g., task-template.md)
├── scripts/             # helper scripts the skill mentions (e.g., for verification)
└── examples/            # worked examples
```

The agent reads `SKILL.md` first; subdirectories load on demand. **Never nest references** — a `references/` file that links to another `references/` file gets partial-read and silently dropped. Why: [`building/body-anatomy.md` § References stay exactly one hop away](../skills/building/body-anatomy.md#references-stay-exactly-one-hop-away).

---

## 🎯 Writing the `description`

The `description` is the single most load-bearing line in a skill. It is what the model scans to decide *whether to load*. Get it wrong and the most careful body never runs.

A controlled 650-trial study measured activation across description styles: passive *"Use when …"* descriptions activated only ~55 % of the time and collapsed to 37 % under hooks, while the **directive form activated 100 % of trials** (CMH OR = 20.6, p < 0.0001). The full evidence is in [`building/activation.md`](../skills/building/activation.md).

Write the directive form — four clauses, in order:

```text
<WHAT verb> <object>.
ALWAYS apply this skill when <trigger 1>, <trigger 2>, or <trigger 3> — even if <implicit signal>.
Do not <forbidden default behaviour> directly.
Skip this skill for <out-of-scope task type 1> or <out-of-scope task type 2>.
```

- **WHAT verb + object** — name the action concretely so the model can pattern-match user intent.
- **ALWAYS apply this skill when …** — force unconditional activation; the *"even if …"* qualifier captures implicit triggers the user didn't say literally.
- **Do not … directly.** — block the bypass: the path the agent takes when it decides *not* to load the skill.
- **Skip this skill for …** — name the *types of task* this skill is not for. This prevents directive saturation when many skills overlap on triggers.

> ✏️ **Length:** practical target **350–600 characters**, hard cap 800. Below ~200 means the triggers + exclusion are too thin and activation regresses. See [`building/activation.md` § The compliance ceiling](../skills/building/activation.md#the-compliance-ceiling-brevity-is-structural).

### A worked before/after (`write-feature`)

**Before** (~50–77 % activation):

```yaml
description: Use when implementing a feature from a spec. Encodes the discipline — read the spec, survey patterns, halt on ambiguity, validate after every batch, paste verification output.
```

**After** (~100 % activation):

```yaml
description: Implement a feature from a spec. ALWAYS apply this skill when the user asks to implement, build, or add a feature, when a spec doc is referenced, or when an acceptance criterion is named — even if the user does not name the spec explicitly. Do not start writing feature code directly without first surveying patterns, mapping criteria to steps, and halting on ambiguity. Skip this skill for bug-fix work against an existing implementation, behaviour-preserving refactors, or behaviour-changing rewrites of existing modules.
```

### Description anti-patterns

| ❌ Description                                  | Why it fails                                              |
| ---------------------------------------------- | --------------------------------------------------------- |
| "About: testing"                               | No WHAT verb, no trigger — the model can't tell when to load |
| "Use when authoring a research doc."           | Passive trigger; lifts activation only ~55 %, collapses under hooks |
| "Use this for everything related to auth."     | Too broad — the skill loads constantly                    |
| "… ALWAYS apply when researching." (no `Skip for …`) | Missing exclusion → directive saturation; the agent picks one of the colliding skills arbitrarily |
| "Handles all web development tasks."           | The Everything-Skill — too broad to activate correctly; belongs in AGENTS.md |
| "Mandatory." / "always loaded"                 | If it should always load, it's AGENTS.md content, not a skill |

> **Never name a sibling skill in the `Skip for …` clause.** Name the *task type* instead. A consumer who vendored only your skill (and not the neighbour) would otherwise have a description that points at a skill that isn't installed. Self-containment forbids it. See [`building/activation.md` § Directive saturation](../skills/building/activation.md#directive-saturation-why-exclusions-name-the-task-types-were-not-claiming).

---

## 🧱 Writing the body

Activation gets the skill loaded; the body's structure decides whether the rules fire. The empirical chain (U-shaped attention, Anthropic best practices, skill-creation anti-patterns) is in [`building/body-anatomy.md`](../skills/building/body-anatomy.md).

| Rule | What it means | Why |
| --- | --- | --- |
| **Length: target ~200 lines, hard-cap 500** | If a body grows past 200, ask *"what moves to `references/`?"*, not *"can I raise the limit?"* | Past ~200 lines, instructions toward the bottom are read but not consistently acted on; the 500-line cap is non-negotiable. |
| **Numbered rules with rationale** | `### 1. <Rule>` … `### N. <Rule>`, each with one or two sentences of justification. | A bare ALL-CAPS imperative works only for the cases the author imagined; the rationale lets the model extend the rule to a case it didn't. |
| **An `## Anti-patterns` section** | Concrete failure modes with corrections, not just rules. | Without negative examples the agent has no prior for the edge cases that don't fit the happy path; it invents a fix, often wrong. |
| **`## What does not belong`** | Name content that should live elsewhere, with pointers. | The negative-space sibling of self-containment — keeps the body from accreting AGENTS.md or `docs/` material. |
| **References one hop away** | `references/*.md` exactly one level deep; no `references/` file links another. | Reference depth turns into partial reads, which turn into silent omissions. |

---

## 🔒 Self-containment

Shipped skills do not reference each other and do not hard-code project-internal paths in their bodies. This is what makes a skill independently vendorable — a consumer copies only the folders they need, and nothing breaks.

| Rule | What it means |
| --- | --- |
| **No cross-skill links in the body** | A SKILL.md body never says "see also `write-fix`" or links a sibling's path. The `Skip for …` clause names task types, not sibling skills. |
| **No framework-internal paths in the body** | A SKILL.md body doesn't hard-code `.agents/…` or `docs/agents/…` consumer paths. It refers to project commands *by contract* — see below. |
| **Project values come from `AGENTS.md`** | When a skill needs a command, its prose references *"`AGENTS.md > Commands > Validation`"* (and the like) and degrades gracefully: if the entry is missing, it asks you before running anything. |

The command contract is the seam between universal *how-to-work* skills and project-specific *what-to-run* facts:

- **In SKILL.md bodies (prose):** reference the command by name — *"run the project's validation command, `AGENTS.md > Commands > Validation`."* Never write a literal command, and never use `{{cmdValidate}}` as if it were an invocation.
- **In `references/task-template.md`:** keep the `{{cmdValidate}}` / `{{cmdTest}}` / `{{slug}}` mustache placeholders. A launcher binds them from `AGENTS.md`'s `## Commands` table; a human filling the template by hand resolves them the same way.

Why: [`building/self-containment.md`](../skills/building/self-containment.md) and the `## Commands` contract documented in [`reference/agents-md.md`](../reference/agents-md.md).

---

## 📋 Should this skill ship a `references/task-template.md`?

A workflow skill *may* ship a task template — the imperative working-memory scaffold the agent instantiates at `.agents/tasks/<slug>.md`. Most do; a few deliberately don't.

Ship one when the **working state is genuinely separate from the deliverable** — the agent needs a place to track hypotheses, paste verification output, and record decisions that isn't the artefact itself.

Ship **none** when:

- The deliverable *is* the working state (a source-doc template already carries the structure).
- The skill is a **cross-cutting quality gate** (`empirical-proof`, `adversarial-review`, `distillation-discipline`) whose discipline lives entirely in `SKILL.md` — these ship a `worked-example.md` / `evasions.md` instead.
- The skill is a **persona** — its mindset rides in the `SKILL.md`; the task template comes from whichever workflow skill governs the work.

The full 6-criterion rubric and the empirical case (Anthropic's three-file note-taking pattern, the InfiAgent 21× ablation) is in [`building/task-files.md`](../skills/building/task-files.md).

---

## 🪞 Skill vs AGENTS.md vs docs/

| Content                                                          | Lives in                       |
| ---------------------------------------------------------------- | ------------------------------ |
| Universal invariant (every agent needs it)                       | `AGENTS.md`                    |
| Project command (what to run)                                    | `AGENTS.md` `## Commands`      |
| Domain-specific procedure (loads on relevant work)               | `.agents/skills/<name>/SKILL.md` |
| Task-type-specific rule (per task type)                          | the skill's `references/task-template.md` |
| One-off task constraint (this task only)                         | the task file's `## Constraints` |
| Human-facing reference / explanation                             | `docs/`                        |
| Architectural decision rationale                                 | `.agents/adrs/<NNNN>-<slug>.md` |
| Project-wide invariants (security, layering, version pins)       | `.agents/constitution.md`     |

If a rule could live in two places, pick the *narrower* — narrower means the agent loads it only when relevant.

---

## 🛠️ Skill review checklist

Before committing a skill:

- [ ] Frontmatter has `name` and a **directive** `description` (WHAT verb + ALWAYS + Do not + Skip for, ~350–600 chars)
- [ ] The `Skip for …` clause names *task types*, never a sibling skill
- [ ] *Purpose* names the failure mode the skill prevents
- [ ] *Core rules* are numbered and each carries a one-line rationale
- [ ] *What does not belong* lists what goes elsewhere, with pointers
- [ ] *Anti-patterns* name concrete failure modes with corrections
- [ ] Body sits well under 200 lines (hard cap 500); depth pushed to `references/`
- [ ] `references/` files are exactly one hop deep; no `references/`→`references/` links
- [ ] No cross-skill links and no consumer `.agents/…` / `docs/…` paths in the body
- [ ] Commands are referenced as `AGENTS.md > Commands > …` in prose; `{{cmd*}}` placeholders only in `references/task-template.md`
- [ ] If it's a workflow skill, you've decided (per the rubric) whether it ships a task template
- [ ] Tried in a real session and confirmed it loads at the right moments

---

## 🔁 Updating an existing skill

- Note the change in the project's CHANGELOG (or a folder-form skill's own changelog).
- If the change *tightens* the discipline (new red flag, new constraint), tell the team — agents in flight may not see the update mid-session.
- If the change *loosens* it (a constraint is no longer required), record the rationale in an ADR.

---

## See also

- [`skills/building/`](../skills/building/) — the empirical evidence behind every rule above
- [`skills/building/activation.md`](../skills/building/activation.md) — the directive `description` contract
- [`skills/building/body-anatomy.md`](../skills/building/body-anatomy.md) — body structure + length budget
- [`skills/building/self-containment.md`](../skills/building/self-containment.md) — no cross-skill links; the AGENTS.md command contract
- [`skills/building/task-files.md`](../skills/building/task-files.md) — when a skill ships a `references/task-template.md`
- [`skills/README.md`](../skills/README.md) — the shipped skill catalogue (24 skills)
- [`reference/agents-md.md`](../reference/agents-md.md) — the `## Commands` contract and when to put rules there instead
