# Skills (documentation): the persona skills

> **For agents:** each persona is its own self-contained skill. Adopt one by loading its `SKILL.md` from [`/scaffold/.agents/skills/persona-<slug>/SKILL.md`](../../scaffold/.agents/skills/). There is no consolidated persona loader to read first.

---

## TL;DR

Swarm ships **eight persona skills** — `persona-architect`, `persona-auditor`, `persona-janitor`, `persona-migrator`, `persona-performance-surgeon`, `persona-skeptic`, `persona-surveyor`, and `persona-lead-engineer`. Each is a standalone, self-contained `SKILL.md` (~70 lines) carrying that mindset's hard constraints, forbiddances, required proofs, and red-flag rationalisations. The agent loads the one whose directive `description` matches the task — no persona skill depends on any other, and none loads on every task.

A persona is a **mindset, not a role**: same agent, same model, different stance, different output. The skill's job is to lock that stance in from the start of the work and hold it when the task gets hard.

---

## The split model: eight standalone skills, not one consolidated file

Earlier framing shipped all personas as a single consolidated `personas/SKILL.md` that a loader read and indexed into. Swarm splits them: one `persona-<slug>/SKILL.md` per mindset.

The split follows directly from how skills load. The open spec defines three loading stages — metadata always in context, the body loaded when the `description` matches, references on demand. A consolidated file defeats the middle stage: adopting *one* persona would pull *all thirteen* mindset bodies into context, most of them irrelevant to the task at hand. With the split, only the body the agent actually adopts loads. Total context cost is *lower* than a single monolithic index, not higher.

This is the progressive-disclosure argument, and it compounds with the U-shaped attention finding (*Lost in the Middle*): a long body buries its middle in an attention trough, so a 600-line consolidated catalogue would have its later personas read but not reliably acted on. Eight ~70-line bodies keep every persona's constraints near the start-or-end of its own short context. The full evidence — length budgets, the U-curve, and why the persona discipline is the canonical example of progressive disclosure — is in [`building/body-anatomy.md`](building/body-anatomy.md).

Self-containment seals the split: each persona skill assumes no sibling is installed. A consumer can vendor only `persona-skeptic` and `persona-architect` and both work, because neither body links to the other or to a shared loader. The directive `description` does the disambiguation — its `Skip this skill for …` clause names the *task types* this persona is not for, never a sibling persona's name.

---

## How a persona skill loads: self-assessment, not a launcher pick

The agent loads the persona whose `description` matches the work it is doing — that is self-assessment against the directive `description`, not a name handed down by a loader. A launcher (the Swarm CLI or any compatible tool) *may* pre-fill a suggested persona when it scaffolds a task file, and the directive descriptions reproduce the same routing in-session; but the routing is **recommended, not enforced**. When the task in front of you doesn't match the suggested default, load the persona whose `description` fits and record the divergence in the task file's `## Decisions`.

Each persona `description` follows the directive form: a WHAT verb (*"Adopt the Skeptic persona."*), an `ALWAYS apply this skill when …` trigger list, a `Do not blend personas, soften the constraints, or revert to default helpfulness mid-task`, and a `Skip this skill for …` exclusion. See [`building/activation.md`](building/activation.md) for why that form activates reliably and the consolidated-loader form does not.

---

## Eight skills, thirteen mindsets

The conceptual catalogue under [`../personas/`](../personas/README.md) describes **thirteen mindsets**. Only **eight ship as standalone persona skills** — the eight listed above. The other five are not separate skills; their mindset is carried by the matching **workflow skill**, which encodes the same stance inline:

| Mindset (catalogue) | Ships as | Where the stance lives |
| ------------------- | -------- | ---------------------- |
| Architect | `persona-architect` | persona skill |
| Auditor | `persona-auditor` | persona skill |
| Janitor | `persona-janitor` | persona skill |
| Migrator | `persona-migrator` | persona skill |
| Performance Surgeon | `persona-performance-surgeon` | persona skill |
| Skeptic | `persona-skeptic` | persona skill |
| Surveyor | `persona-surveyor` | persona skill |
| Lead Engineer | `persona-lead-engineer` | persona skill — orchestration has no workflow skill, so the coordination mindset is itself the discipline ([ADR 0025](../adrs/0025-orchestration-coordination-artifact.md)) |
| Builder | — | carried by `write-feature` |
| Bug Hunter | — | carried by `write-bug-report` |
| Documentarian | — | carried by `write-documentation` |
| Researcher | — | carried by `write-research` |
| Test Author | — | carried by `write-testing` |

The five mindset-only personas earn no separate skill because their discipline is inseparable from the work the workflow skill already governs — the Builder mindset *is* the discipline `write-feature` enforces, so duplicating it as a standalone persona would only add a second body to load for the same task. The eight that do ship as skills are the ones whose stance applies where no single workflow skill carries it: seven span more than one workflow skill (the Skeptic reviews any code-producing branch; the Migrator covers both migration and upgrade), and Lead Engineer ships because orchestration has **no** workflow skill at all (per [ADR 0019](../adrs/0019-personas-ship-as-individual-skills.md) as amended) — so isolating each keeps it independently loadable.

---

## Cross-persona discipline

These rules hold for every persona, whether it ships as a skill or rides inside a workflow skill:

- **Do not blend personas mid-session.** One stance per task. The constraints are most valuable when the work is hardest — that is exactly when the agent is tempted to drop them.
- **Do not treat the persona as a costume.** Citing the persona name without holding its constraints is the partial-adoption failure mode. The required empirical proofs are non-negotiable.
- **Do not self-promote to a different persona** because you decided the original was wrong. Surface the concern and record it; do not switch silently.

The enforcement is the **Self-review hard gate**: the task cannot close without pasted empirical proof matching the persona's required proofs. The constraint mechanism enforces the constraint stance.

---

## Related

- [`../personas/README.md`](../personas/README.md) — the thirteen-mindset conceptual catalogue (routing, contrasts, hazards)
- [`building/body-anatomy.md`](building/body-anatomy.md) — progressive disclosure and the U-curve; why eight short bodies beat one long one
- [`building/activation.md`](building/activation.md) — the directive `description` form that drives self-assessment loading
- [`building/self-containment.md`](building/self-containment.md) — why each persona skill assumes no sibling is installed
- [`README.md`](README.md) — the full skill catalogue
