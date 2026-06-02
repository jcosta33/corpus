# Skill (documentation): `write-research`

> **For agents:** instructions → [`/scaffold/.agents/skills/write-research/SKILL.md`](../../scaffold/.agents/skills/write-research/SKILL.md)

---

## TL;DR

Research answers a decision-informing question with traceable lineage to primary sources. Exploratory dead-ends belong — labelled as such — but the deliverable is a recommendation a spec author can lift straight into requirements. The skill self-activates when the user asks for research, a comparison, an evaluation of options, or a recommendation (technical or UX/market) and stays out of forward-looking spec authoring and present-state audits.

## What the skill actually enforces

The discipline is **evidentiary: cite or omit**. Every Findings claim carries a numbered inline citation (`[1]`, `[short-key]`) matched to `## Sources`; a claim without one is opinion. Sources are ranked by primacy — standards, then peer-reviewed papers, then official docs, then the library's source, then verified product behaviour, then secondary commentary (cite the primary source the commentary rests on). At least **three independent sources** as a floor, with coverage of the space as the real target. Options are compared **in a table with named criteria**, side-by-side, so the spec author can lift the comparison into a `## Design decisions` section. The recommendation is **actionable** — "adopt NATS JetStream, three reasons…" — and if no clear recommendation is possible, the skill says so and states what would unblock it, never "it depends" with no object.

Two unverifiability guards: claims that couldn't be confirmed are bracketed `[unconfirmed]` rather than fabricated, and product-behaviour claims are **verified by interacting** with the product (curl, sandbox, recorded session), not inferred from its docs. The **pre-deliver visibility gate** forces a verification table — one row per Findings paragraph confirming a `[N]` citation and a verified-or-`[unconfirmed]` status — and the doc is not delivered until every row is ✅.

## Technical vs UX/market modes

A single research file picks one mode; if a topic is genuinely both, split it. Technical research stresses reproducible experiments — libraries, benchmarks, standards. UX/market research applies the same evidentiary discipline to a softer subject: "common practice" must cite at least three concrete examples, user-expectation claims cite the research that produced them (not the agent's intuition), and the skill insists on distinguishing **what users do** (observed) from **what users want** (claimed). One example is never a pattern.

## Why uncertainty is promoted, not hidden

Agents prematurely collapse a pending claim into a confident one to sound decisive. The skill mandates visible uncertainty states (`[unconfirmed]`) to resist that narrative-closure bias — and those honest states feed a clean Distillation Loss Statement when the research is later distilled into a spec. The anti-pattern it fights is an authoritative tone with no measurement behind it.

## Where research routes

Research is upstream input, not a green light. A recommendation reaches production only by being distilled into a spec (or an audit) and implemented there — research alone never authorises a code edit. That ordering is the framework's recommended routing, conditioned in-session by the directive skill descriptions, not enforced by any gatekeeper skill.

## Command resolution

Where research verifies live product behaviour, it uses whatever run/curl command the project provides; it resolves project commands by name through `AGENTS.md > Commands` and asks the user if an entry is missing rather than guessing.

## Bundled resources

- `references/task-template.md` — a fillable research-task template combining the workflow scaffold (metadata, AGENTS.md command contract, constraints, progress checklist, decisions, Self-review) with the deliverable inlined as a `## Deliverable` block (research question, sources, findings, comparison table, recommendation, open questions, Distillation Loss Statement). At session close, copy the `## Deliverable` block to its final home (`<your-research-dir>/{{slug}}.md`).

## Related

- [Research document type](../documents/research.md)
- [Task: research-writing](../tasks/research-writing.md)
- [Concept: distillation](../concepts/03-distillation.md)
- [Surveyor persona](../personas/the-surveyor.md) — UX/market mindset, ships as `persona-surveyor`
