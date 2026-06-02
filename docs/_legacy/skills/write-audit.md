# Skill (documentation): `write-audit`

> **For agents:** instructions → [`/scaffold/.agents/skills/write-audit/SKILL.md`](../../scaffold/.agents/skills/write-audit/SKILL.md)

---

## TL;DR

An audit inventories the **truth of the codebase now** and makes an area legible so downstream work can be planned. It is honest observation, not prescription — redesign belongs in a spec. The skill self-activates when the user asks for a code audit, architecture review, technical-debt survey, or quality assessment (including deepening an existing audit) and stays out of forward-looking specs and defect reproduction.

## What the skill actually enforces

The body's rules: **state the goal first** (a measurable target, not "improve the billing module" — without a goal, "current state" has no meaning); **every finding cites `<path>:<line>`**, and vague observations get demoted or removed; **every issue carries a "Needed"** stating the concrete change that would close it (the *what*, not the *how* — that's the implementer's call); issues are **sorted by impact**, with severity (BLOCKER / MAJOR / MINOR) calibrated by consequence-if-unaddressed, not by how loud the issue feels.

Beyond static reading, the skill demands **verifying dynamic invariants** (concurrency, lifecycle, resource cleanup don't show in the text — exercise them), a **no-callers-anywhere search** (dead code labelled as working is itself a finding), explicit **risks** (condition, mitigation, in-scope-or-not), and **adversarial reading** that sets aside any prior audit's framing. The **pre-deliver visibility gate** forces a completeness table — one row per issue, each confirming `<path>:<line>` present and `Needed` non-empty — and the audit is not delivered until every row is ✅.

## Why audits gate downstream work indirectly

An audit spawns typed follow-ups (refactor, performance) that preserve its numbered issues. The skill forces traceable linkage so each finding cites an observable mechanism and the rule it violates, which is what lets a refactor pass address "the audit's Needed items" precisely. Poor audits produce archaeology sessions later — the skill minimises unstructured debt prose so the cleanup mindset has something to work from.

## Epistemic guardrails

| Risk | Skill counterweight |
|------|---------------------|
| Sneaking redesign into the audit | Explicit ban — prescription is pushed to spec-writing. |
| Severity inflation | Calibration by consequence, with exemplars in the SKILL body. |
| Unverifiable fluff | Every observation requires a `file:line` or a reproducible trace. |
| Empty Risks section | "Look harder; there are always risks worth naming." |

When adversarial amplification is wanted, an audit hands off to a deepen-audit pass under the skeptic mindset.

## Command resolution

The audit is mostly read-only, but rule 5 (verifying dynamic invariants) runs the project's validation — and sometimes tests — to confirm claimed thread-safety, cleanup, or lifecycle assumptions. It resolves those commands by name through `AGENTS.md > Commands` and asks the user if an entry is missing rather than guessing.

## Bundled resources

- `references/task-template.md` — a fillable audit-writing task template combining the workflow scaffold (metadata, AGENTS.md command contract, constraints, progress checklist, decisions, Self-review for finding specificity / severity calibration / adversarial completeness) with the deliverable inlined as a `## Deliverable` block (goal, scope, code paths, findings with severity + file:line + observation + Needed + evidence, risks, suggested approaches, open questions, Distillation Loss Statement). At session close, copy the `## Deliverable` block to its final home (`<your-audits-dir>/{{slug}}.md`).

## Related

- [Document: audit](../documents/audit.md)
- [Task: audit-writing](../tasks/audit-writing.md)
- [Auditor persona](../personas/the-auditor.md) — ships as `persona-auditor`
- [Janitor persona](../personas/the-janitor.md) — ships as `persona-janitor`
