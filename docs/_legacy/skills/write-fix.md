# Skill (documentation): `write-fix`

> **For agents:** instructions → [`/scaffold/.agents/skills/write-fix/SKILL.md`](../../scaffold/.agents/skills/write-fix/SKILL.md)

---

## TL;DR

Fix work weaponises hostility toward convenient causal narratives: disprove-first, then patch. The skill self-activates when the user asks to fix, patch, resolve, or close a bug, regression, or defect (including hot-fixes and revert-and-re-fix flows) and stays out of authoring the bug-report itself, behaviour-preserving refactors, and behaviour-changing rewrites.

## What the skill actually enforces

**Reproduce in your own worktree before patching** — re-run the bug report's reproduction, confirm the bug fires, paste the output; if it won't reproduce, do not patch, investigate the environment discrepancy first. **Patch the root cause at the cited `<file>:<line>`, not the symptom** — symptom-patches let the bug recur through another path. The proof object is the **regression test that fires before the fix and passes after**: patch your fix out, run the test, watch it fail (proving the test exercises the bug); restore the fix, watch it pass — and paste both transitions. **No scope creep** (neighbouring bugs get promoted to follow-up reports), **run the full suite** after the patch, and **document why this patch addresses the root cause** in `## Decisions`.

## Why a skeptic mindset on fixes

Fixes fail when the engineer accepts the first plausible story — `git blame`, the last commit, the obvious typo. The suggested lead mindset for fix tasks is the Skeptic (recorded in [ADR 0006](../adrs/0006-skeptic-owns-fix-tasks.md)), whose hostility toward convenient explanations aligns with disciplined root-fix plus regression proof. This is a **suggested default route**, not a deterministic assignment: load `persona-skeptic` (`scaffold/.agents/skills/persona-skeptic/SKILL.md`) when the work matches, and record any divergence in your task file's `## Decisions`. The skill itself carries the mistrust-your-own-confidence rule, so the discipline holds even without the persona loaded.

## Distinct from writing the bug-report

The diagnosing mindset ends at the dossier (`write-bug-report`); the fix applies the patch and strengthens the regression sentinel. The stance is similar but the proof objects differ — `git bisect` and a clear root-cause hypothesis on the diagnosis side, a failing-then-passing behavioural test on the fix side. Downstream review is also adversarial (`adversarial-review`), so the loop stays coherent: hostile diagnosis, hostile fix, hostile review.

## Safeguards the skill encodes

| Trap | Guidance |
|------|----------|
| Symptomatic patch masking a systemic fault | Mandatory linkage back to the stated root cause in `## Decisions`. |
| "This should fix it" without flipping the test | The gate is failing — flip the regression test red→green before declaring done. |
| Bundling unrelated cleanup with the fix | Promote it; one bug per fix task. |

For a flaky test that fails intermittently rather than a deterministic defect, the work is a different discipline — see the `fix-flaky-test` skill, not this one.

## Command resolution

The skill resolves the project's validate and test commands by name through `AGENTS.md > Commands`; if `AGENTS.md` is missing or an entry is undefined, it asks the user which command to run rather than guessing.

## Bundled resources

- `references/task-template.md` — a fillable fix-task template with a reproduction block, plan, progress checklist, and a Self-review hard gate that requires pre-patch and post-patch reproduction output. Copy it into your task file location, substitute the placeholders, and fill it in as you work.

## Related

- [Skeptic persona](../personas/the-skeptic.md) — ships as `persona-skeptic`
- [Task: fix](../tasks/fix.md)
- [Write-bug-report skill](write-bug-report.md) — the upstream diagnosis
