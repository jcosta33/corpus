# Skill (documentation): `write-refactor`

> **For agents:** instructions → [`/scaffold/.agents/skills/write-refactor/SKILL.md`](../../scaffold/.agents/skills/write-refactor/SKILL.md)

---

## TL;DR

Structural moves under observable invariance — the skill encodes shim contracts and per-batch validation because humans continuously mis-estimate behavioural blast radius. The skill self-activates when the user asks to refactor, restructure, clean up, extract, or address an audit's "Needed" items **only when behaviour is preserved**, and stays out of behaviour-changing rewrites, API/framework migrations, and net-new features.

## Refactor-only — migration is a separate skill

A refactor restructures code while preserving behaviour end-to-end: the audit drives the changes, the structure improves, the surface and semantics stay the same. Anything that *also* changes the surface — replacing one API with another, upgrading a framework version — is a different discipline and now lives in its own skill, `write-migration`. This is the boundary the SKILL body draws explicitly; do not stretch `write-refactor` to cover migration waves.

## What the skill actually enforces

**Behaviour preservation is non-negotiable** — the test suite passes before, at every checkpoint, and after; a test that fails post-refactor means behaviour changed, so investigate before "fixing" the test. This is the [`behaviour-preservation` gate](../reference/verification-gates.md#-spec-intent--equivalence-gates-adr-0022): equivalence is shown by a check that would *fail if behaviour changed*, not merely a green suite. A green suite is necessary but not sufficient — it only covers what was already tested — so the skill asks for the strongest available equivalence oracle (property-based, differential, or golden-output testing), and where no stronger check exists for a given change it makes the agent record *why* the existing suite is a sufficient oracle for that change rather than waving it through. **Periodic architectural validation** runs the dependency-validation command every 10 files (or the audit's chosen frequency) so drift is caught early, not at the end. **Each file is modified individually** — no bulk codemods or `sed` over hundreds of files, because bulk operations hide context-specific deviations. **Every shim is documented** with a path, a forward target, and a verifiable removable-when criterion (a shim without one is permanent debt). **Deletion safety is proven** by `git grep` showing zero callers (checking dynamic-dispatch and string-form lookups separately) with the output pasted into Self-review. Out-of-scope discoveries are **promoted to the audit**, not silently fixed.

## Why the checkpoint cadence

Errors compound super-linearly with the coupling of the modules touched — validating the dependency graph early is far cheaper than rewinding a 50-file refactor that drifted at file 8. The skill refuses to silence a validation failure by editing the validator config; that hides the very drift the checkpoint exists to catch.

## Separation from its neighbours

| Neighbour skill | Divergence |
|-----------------|------------|
| `write-rewrite` | Permits a deliberate semantics shift — refactor forbids any externally visible delta. |
| `write-migration` | Mechanical API/framework replacement wave — refactor targets internal cohesion, not surface change. |
| `write-performance` | Metric-targeted — refactor targets clarity only, unless an audit explicitly nests a perf goal. |

The recurring production incident the boundary prevents: a behaviour-changing edit smuggled in under the "purely internal refactor" label. If behaviour changes, it is a rewrite or a migration — relabel and use that skill.

## The Janitor mindset

The cleanup temperament — neutral toward behaviour, allergic to scope creep — is the Janitor mindset, shipped as `persona-janitor` (`scaffold/.agents/skills/persona-janitor/SKILL.md`). Load it alongside this skill when the work is a debt-reduction pass driven by an audit.

## Command resolution

The skill resolves validate, test, and the architectural dep-validation command by name through `AGENTS.md > Commands`. The dep-validation command is outside the standard contract — ask the user if the project uses one. If `AGENTS.md` is missing or an entry is undefined, it asks the user which command to run rather than guessing.

## Bundled resources

- `references/task-template.md` — a fillable refactor-task template with before/after state, a shim-contracts table, plan, a progress checklist with per-batch validation slots, and a Self-review hard gate covering behaviour preservation, architectural cleanliness, shim hygiene, and deletion safety. Substitute the placeholders and fill it in as you work.

## Related

- [Task: refactor](../tasks/refactor.md)
- [Janitor persona](../personas/the-janitor.md) — ships as `persona-janitor`
- [Write-rewrite skill](write-rewrite.md) — when behaviour changes deliberately
