# 📋 Task: upgrade

> **TL;DR.** A specialised migration for dependency / framework / language version bumps. Same persona (The Migrator), same wave discipline, same per-wave validation. The distinction is purely in the source of the change — an external library version, not an internal API replacement.

> 📦 **This page is documentation.** The `upgrade` task type uses the same template as `migration`: [`/scaffold/.agents/skills/write-migration/references/task-template.md`](../../scaffold/.agents/skills/write-migration/references/task-template.md), with `Type: upgrade` and the additions noted below.

---

## 🎯 When to use vs `migration`

| If the change is…                                                                | Task type    |
| -------------------------------------------------------------------------------- | ------------ |
| Replacing one of *our* APIs with another of *our* APIs across many call sites    | `migration`  |
| Bumping an *external dependency* version (React 18 → 19, Node 20 → 22, Django 4 → 5) | `upgrade`    |
| Bumping a language version that requires source changes (TypeScript 5.4 → 5.5)   | `upgrade`    |
| Upgrading a tool whose API changes (pnpm 8 → 9 with config-file changes)         | `upgrade`    |

Mechanically, `upgrade` and `migration` use the same template, persona, and discipline. The split exists because:

- The source doc is usually *external release notes / migration guide*, not an internal `migration plan`.
- Validation often includes running the project's full integration suite, not just unit tests, because the upgrade can touch behaviour we don't directly own.
- The "old API" concept is a *previous version*, not a *deprecated internal API*.

---

## 🧬 Metadata

| Field                | Value                                              |
| -------------------- | -------------------------------------------------- |
| **Source doc**       | `migration plan` (often citing external release notes) |
| **Lead persona**     | [The Migrator](../personas/the-migrator.md)       |
| **Secondary**        | [The Skeptic](../personas/the-skeptic.md) (review per wave) |
| **Output**           | Codebase compatible with the upgraded dependency / version |
| **Recommended skills** | `write-migration`, `empirical-proof`, `persona-migrator` |
| **Verification gate slots** | Same as `migration` (incl. the [`behaviour-preservation`](../reference/verification-gates.md) equivalence check at self-review) + `cmdInstall` (must succeed first), `cmdBuild` (post) where applicable |

---

## Canonical template (agent artefact)

Uses **`/scaffold/.agents/skills/write-migration/references/task-template.md`** with **`Type: upgrade`**. Persona (`Migrator`), wave discipline, and empirical cadence mirror [`migration`](migration.md); divergence is semantic input (upstream release artefacts vs internally authored API retirement).

### Semantic split recap

See table in **When to use** — framework keeps templates unified to minimise mechanical drift while letting routing signal different risk stories to reviewers.

### Expected structural adaptations

- Rename wave narrative headers to **`## Upgrade source and target`** emphasising semver endpoints + business/security motivation.
- **Linked docs** must cite authoritative upstream migration / release-note URLs (not merely internal shorthand).
- **Wave validation column** biases toward adding the project's build step (`AGENTS.md > Commands > Build`) each wave — version bumps surface statically before tests.
- Self-review substitutes **pattern-coverage / removed API extinguishment** language for purely internal callsite hunts.

Operational Markdown belongs in spawned task artefacts under `.agents/tasks/`, not mirrored here.

---

## ⚠️ Common anti-patterns

- Skipping the build step (`AGENTS.md > Commands > Build`) in per-wave validation (upgrades often surface at build time, not test time)
- Bumping multiple major dependencies in one task (each is its own upgrade)
- Treating "tests pass" as sufficient when the upgrade may have changed behaviour the suite doesn't cover — a green suite is necessary but not sufficient; the [`behaviour-preservation`](../reference/verification-gates.md) gate wants an equivalence check (property-based / differential / golden-output) that would *fail if behaviour changed*, or an explicit record of why the existing suite is a sufficient oracle here
- Trusting the upstream migration guide without verifying the cited deprecated patterns exist in *our* codebase

---

## See also

- [`tasks/migration.md`](migration.md) — the parent template
- [`personas/the-migrator.md`](../personas/the-migrator.md)
- [`documents/extended.md`](../documents/extended.md) — migration plan format
