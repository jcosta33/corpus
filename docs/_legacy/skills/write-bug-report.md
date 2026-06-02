# Skill (documentation): `write-bug-report`

> **For agents:** instructions → [`/scaffold/.agents/skills/write-bug-report/SKILL.md`](../../scaffold/.agents/skills/write-bug-report/SKILL.md)

---

## TL;DR

A bug report crystallises **minimal reproduction + causal story**, deliberately excluding the remedy — a cognitive firewall against the patch-before-understanding pathology. The fixer must be able to patch from the report alone, with zero re-investigation. The skill self-activates when the user reports a bug, defect, regression, or unexpected behaviour (even an intermittent one) and stays out of fixing the bug (a downstream task) and present-state audits.

## What the skill actually enforces

**Reproduce before explaining** — a bug is a hypothesis until it fires, and the reproduction output is the proof. **Isolate to the smallest reproduction**; the attempts that didn't repro are noise captured in `## Reproduction attempts`, not the lead. **State the root cause precisely** as *file:line + state + input + caller* — the symptom alone is not the cause. **Distinguish observation from inference** (mark inferences in a `## Hypothesis tracker` with `[supports]` / `[disproven]` / `[confirmed]`), **search for related defects** by grepping the *pattern* not just the file, and **propose a regression test** with location and assertion.

The hard gate is the **pre-deliver visibility gate**: `## Reliable reproduction` must contain the exact command and the **verbatim failing output**, plus a determinism note (fires every run / N of M / `[unable to reproduce]`). A report with no pasted output — or marked `[unable to reproduce]` without an explanation in `## Reproduction attempts` — is not finalisable.

## Why bug-report is its own meta-task

Diagnosis and fix have **different mindsets, different empirical proofs, and different ways of being wrong**. bug-report-writing is forensic, hypothesis-driven, read-only on code; the fix is adversarial about its own patch and runs the regression test. A combined "diagnose-and-fix" task short-circuits the diagnosis at the first plausible explanation — the split forces the diagnosis to stand on its own. The decision is recorded in [ADR 0007](../adrs/0007-bug-report-as-meta-task.md).

## The psychology the firewall fights

Offering a fix feels helpful, and that dopamine shortcut is exactly what corrupts the diagnosis: once a remedy is in mind, the investigation stops looking for a better cause. The skill blocks the remedy so the fix task inherits uncompromised evidence. The same mistrust applies inward — the adversarial-mindset rule says push past the first hypothesis that fits and ask whether the cause could be elsewhere.

## Quality markers

A strong report shrinks the fix task's fan-out:

| Dimension | Benefit |
|-----------|---------|
| Reproduction deterministic | The fixer (and reviewer) verifies failure before trusting the patch. |
| Hypotheses ranked, observation separated from inference | Saves the fixer from re-walking blind alleys. |
| Blast radius fenced (related-defects search) | Targets the regression-suite design. |

## Relation to auditing

Structural defects surface via audits; a bug-report stays incident-scoped. The skill resists the creeping architecture essay inside an incident record — a "module X is broken" narrative is an audit finding, not a bug report.

## Command resolution

The reproduction step runs the project's test or runtime entry point; the skill resolves `AGENTS.md > Commands > Test` (and any project run/start command for runtime defects) by name, and asks the user if an entry is missing rather than guessing. The pasted reproduction output must come from one of those commands.

## Bundled resources

- `references/task-template.md` — a fillable bug-report-writing task template combining the workflow scaffold (metadata, AGENTS.md command contract, constraints, progress checklist, decisions, Self-review for reproduction reliability and root-cause depth) with the deliverable inlined as a `## Deliverable` block (reported behaviour, reliable reproduction, reproduction-attempt history, hypothesis tracker, root cause, related defects, regression-test plan, open questions, Distillation Loss Statement). At session close, copy the `## Deliverable` block to its final home (`<your-bugs-dir>/{{slug}}.md`).

## Related

- [Bug report document](../documents/bug-report.md)
- [Task: bug-report-writing](../tasks/bug-report-writing.md)
- [Bug Hunter persona](../personas/the-bug-hunter.md) — the diagnosing mindset (carried by this skill; not shipped as a separate persona skill)
- [Write-fix skill](write-fix.md) — the downstream remedy pass
