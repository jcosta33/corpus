# Skill (documentation): `write-rewrite`

> **For agents:** instructions → [`/scaffold/.agents/skills/write-rewrite/SKILL.md`](../../scaffold/.agents/skills/write-rewrite/SKILL.md)

---

## TL;DR

A rewrite re-implements a module with behaviour that **deliberately changes** — the opposite of the implementer's default conservatism. Because change is *permitted*, unintended changes hide; the skill forces the behaviour delta to be explicit. It self-activates when the user asks to rewrite a module with new behaviour, replace an implementation, or redo something that was wrong, and stays out of behaviour-preserving cleanup, API/framework migrations, and net-new features.

## What the skill actually enforces

**The behaviour delta is explicit** — before writing code, fill a before/after table with every aspect that changes; anything *not* in the table must be preserved, and the table is the contract. **Acceptance criteria cover both** the new behaviour and the explicitly-stated preserved behaviour (a rewrite that only tests the new behaviour misses the regression risk). **Identify all affected callers** by grepping each changed behaviour and updating or verifying each call site. **Halt and update the spec on emergent changes** — a behaviour change discovered mid-implementation that isn't in the delta means stop, authorise it in the spec (or revise to keep the original), because silent emergent change is *the* failure mode. A **module plan** lists what changes in each touched module, and validation runs after every batch.

## The two-surface verification contract

A rewrite is the one task type where behaviour is *permitted* to change, so its verification splits along the delta and binds through [ADR 0021](../adrs/0021-verification-contract.md) / [ADR 0022](../adrs/0022-acceptance-criteria-are-executable-checks.md) (see [`reference/verification-gates.md`](../reference/verification-gates.md)):

- **The delta gets `acceptance-criteria-coverage`.** Each changed behaviour is a spec acceptance criterion, and the spec bound each one to a check — `test`, `command`, or `manual`. The Self-review maps every changed behaviour to its check and pastes the result; a `test`-bound criterion counts only once its oracle is shown to be valid (fails when the criterion is violated, passes when satisfied, proven by assertion-flip). A green suite is not coverage.
- **The non-delta gets `behaviour-preservation`.** Everything outside the recorded delta must be behaviour-preserved, proven by an equivalence check that would *fail if behaviour changed* — a property-based, differential, or golden-output check where the project has one, else an explicit record of why the existing suite is a sufficient oracle for this change. This generalises `write-fix`'s fail-before / pass-after oracle to the whole preserved surface; the suite passing is necessary but not sufficient.

The two are complementary: AC-coverage proves the *intended* change was built; behaviour-preservation proves *nothing else* moved.

## Rewrite vs refactor vs migration

A rewrite is not a refactor: a refactor preserves behaviour end-to-end, a rewrite changes some of it on purpose. It is also not a migration: a migration mechanically swaps one API or framework version for another and lives in its own skill (`write-migration`). Mislabelling is dangerous in both directions — calling a behaviour change a "refactor" smuggles risk past review; calling a behaviour-preserving cleanup a "rewrite" over-marks it and invites unnecessary delta tables. If behaviour is preserved, use `write-refactor`; if it changes, use this skill.

## Risk posture

A rewrite carries higher tail risk than an additive feature: compatibility shims and dual-write periods are often mandatory, so the template encodes phased-cutover journaling. The psychological tilt is toward heroic deletion — the skill counters it with measurable-equivalence checkpoints on the preserved behaviour, unless the spec explicitly demands intentional breakage. Downstream adversarial review (`adversarial-review`) is indispensable before merge, since the delta table is exactly what the reviewer checks the diff against.

## Command resolution

The skill resolves the project's validate and test commands by name through `AGENTS.md > Commands`; if `AGENTS.md` is missing or an entry is undefined, it asks the user which command to run rather than guessing.

## Bundled resources

- `references/task-template.md` — a fillable rewrite-task template with the behaviour-delta table, acceptance criteria (new + preserved), module plan, progress checklist, and a Self-review hard gate carrying both paste slots: the behaviour-delta coverage (each changed behaviour → its check → result) and the behaviour-preservation equivalence check for the non-delta surface. Copy it into your task file location, substitute the placeholders, and fill it in as you work.

## Related

- [Task: rewrite](../tasks/rewrite.md)
- [Write-refactor skill](write-refactor.md) — when behaviour is preserved
- [Adversarial-review skill](adversarial-review.md) — the merge-gate review
