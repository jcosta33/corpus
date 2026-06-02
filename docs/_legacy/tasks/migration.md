# 📋 Task: migration

> **TL;DR.** Move the codebase from API A to API B mechanically across many call sites. Lead persona is The Migrator. Plan in waves; the codebase must compile and pass tests after each wave, not only at the end. No bulk codemods.

> 📦 **This page is documentation.** The actual task template lives at [`/scaffold/.agents/skills/write-migration/references/task-template.md`](../../scaffold/.agents/skills/write-migration/references/task-template.md).

---

## 🎯 When to use

A `migration` task is right when:

- A migration plan (or a spec acting as one) defines the source and target APIs.
- Many call sites need the same mechanical change.
- Behaviour is preserved (it's a *surface* change, not a *semantic* change).

If behaviour changes, it's `rewrite`. If it's a single file with a small change, it's `refactor`. If it's a dependency version bump rather than an API replacement, it's `upgrade`.

---

## 🧬 Metadata

| Field                | Value                                              |
| -------------------- | -------------------------------------------------- |
| **Source doc**       | `migration plan` or `spec.md`                      |
| **Lead persona**     | [The Migrator](../personas/the-migrator.md)       |
| **Secondary**        | [The Skeptic](../personas/the-skeptic.md) (review of each wave) |
| **Output**           | Codebase using the target API; old API removed (or scheduled) |
| **Recommended skills** | `write-migration`, `empirical-proof`, `persona-migrator` |
| **Verification gate slots** | `cmdInstall` (pre), `cmdValidate` (per wave), `cmdValidate` (post), `cmdTest` (post), migration-coverage check (post), [`behaviour-preservation`](../reference/verification-gates.md) (self-review) — an equivalence check that fails if behaviour changed, not just a green suite |

---

## Canonical template (agent artefact)

The verbatim Markdown template (persona directive, placeholders, gated `Self-review`) lives under **`/scaffold/.agents/templates/`**. Install by copying [`/scaffold`](../../scaffold/README.md); do not paste large template bodies from framework docs into downstream repos — that guarantees drift.

### Why these structural clusters exist

Every task template shares the same structural clusters; see [Why these structural clusters exist](README.md#why-these-structural-clusters-exist) in the task-type overview for the shared rationale.

---

## ⚠️ Common anti-patterns

- Bulk codemods touching hundreds of files
- Skipping per-wave validation ("this wave is small")
- Shims with no removal criteria
- "Mostly migrated" final state
- Behaviour drift bundled into the migration

---

## See also

- [`personas/the-migrator.md`](../personas/the-migrator.md)
- [`tasks/upgrade.md`](upgrade.md) — close cousin (dependency / framework version)
- [`tasks/refactor.md`](refactor.md) — when scope is single-module
- [`documents/extended.md`](../documents/extended.md) — the migration plan format
- [`skills/write-migration.md`](../skills/write-migration.md)
