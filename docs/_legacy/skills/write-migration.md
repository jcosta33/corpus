# Skill (documentation): `write-migration`

> **For agents:** instructions → [`/scaffold/.agents/skills/write-migration/SKILL.md`](../../scaffold/.agents/skills/write-migration/SKILL.md)

---

## TL;DR

A migration moves the implementation from API A to API B — framework major, language version, library replacement — while the surface behaviour stays put. `write-migration` is the discipline that stops a migration from stranding in a half-done state, or "completing" while old-API callsites still lurk in the corners grep can't reach.

## The failure mode it prevents

Migrations fail in two characteristic ways, and the skill is built against both:

- **The permanent half-migration.** Some callsites use the new API, some use the old one, and the "transition" becomes the steady state forever. The shim that was supposed to be temporary outlives everyone who remembers why it exists.
- **The phantom completion.** The migration is declared done, but old-API callsites survive in dynamic dispatch, string-based registry lookups, generated code, and reflection — none of which a text search finds. The codebase *looks* migrated and isn't.

## Core rules (summarised)

- **Surface behaviour is preserved — proven by an equivalence check.** The test suite passes before, at every wave checkpoint, and after; the implementation moves, the contract doesn't, and a failing test after a wave is a signal to investigate, not a test to "fix". But a green suite is *necessary, not sufficient*: it only proves what was already covered. The [`behaviour-preservation`](../reference/verification-gates.md) gate requires an equivalence check that would *fail if behaviour changed* — property-based, differential (run old and new API on the same inputs while the old path is still reachable behind the shim), or golden-output — or, where no stronger check exists, an explicit record of why the existing suite is a sufficient oracle for this migration.
- **Plan in waves, up front.** A wave is the smallest atomic change that leaves the codebase compiling and green. Document the waves before you start — don't discover them mid-flight.
- **Validate after every wave.** Run `Validation` and `Test` at the end of each wave. Final-only validation lets drift accumulate across waves until untangling it becomes its own project.
- **Each file migrated deliberately.** No bulk codemods, no `sed` over hundreds of files, no shell loops. Bulk substitution silently breaks the one callsite that used the API in an unusual way.
- **Track callsite coverage explicitly.** Count old-API callsites up front; track migrated-vs-remaining per wave. Not done until the remaining count (outside explicit shims) is zero — across the *whole* codebase, not just the scoped modules.
- **Every shim has a removal criterion.** Shim path, forward target, and a *verifiable* removable-when condition (e.g. `git grep -c '<old-API>' src/` returns 0). A shim without a removal criterion is permanent — the migration's lasting cost.
- **Search beyond grep.** After the text search, explicitly audit dynamic dispatch, string-based references, generated code, and test fixtures, and paste the audit into `## Self-review`.
- **Promote out-of-scope findings.** "While I'm migrating" semantic changes destroy reviewability. Anything off the plan gets promoted to an audit, not silently fixed.

## Boundary

A migration is a *surface* change. If the new API is meant to behave differently, that divergence is a separate spec/task — promote it. Behaviour-preserving cleanup of internals at a single API version is `refactor`, not migration. Net-new feature work against the new API is `feature`.

## Task type and suggested persona

`write-migration` carries the discipline for the [`migration`](../tasks/migration.md) task type (and its close cousin, [`upgrade`](../tasks/upgrade.md)). The matching persona is the [**Migrator**](../personas/the-migrator.md), whose runtime mindset ships as [`persona-migrator/SKILL.md`](../../scaffold/.agents/skills/persona-migrator/SKILL.md). The Skeptic reviews each wave: did the suite stay green, is the callsite count actually zero.

These are suggested defaults, not gates. If the work in front of you doesn't fit the migration shape, load the skill whose description matches and note the divergence in your task file's `## Decisions`.

## Project commands it reads

The skill resolves commands through the consuming repo's `AGENTS.md > Commands` — `Validation` (after every wave; never let two waves' breakage accumulate) and `Test`. An optional dep-validation / architectural-rules check is not in the standard contract; the skill asks the user if the project has one. Missing or undefined entries → it asks before proceeding rather than guessing.

## What it ships

`references/task-template.md` — a fillable migration-task template: source/target APIs, the wave plan, compatibility-shim table (path / forward target / removable-when), a callsite tracker, per-wave validation slots, and a self-review hard gate covering wave integrity, callsite coverage, shim hygiene, behaviour preservation (the named equivalence check), and final state. Substitute the `{{...}}` placeholders and fill it in as you work.

## Related

- [Task: migration](../tasks/migration.md)
- [Task: upgrade](../tasks/upgrade.md) — the dependency / framework-version cousin
- [Persona: the Migrator](../personas/the-migrator.md)
- [Building skills: self-containment](building/self-containment.md) — why this skill carries no cross-skill links and resolves commands through `AGENTS.md`
