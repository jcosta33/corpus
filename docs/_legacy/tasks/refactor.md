# 📋 Task: refactor

> **TL;DR.** Restructure code without changing observable behaviour. Lead persona is The Janitor. Source: an `audit.md`. Run the project's architecture-boundary check (`AGENTS.md > Commands > ValidateDeps`) after every 10-file batch (the framework convention). Document every shim contract before consumers touch it.

> 📦 **This page is documentation.** The actual task template lives at [`/scaffold/.agents/skills/write-refactor/references/task-template.md`](../../scaffold/.agents/skills/write-refactor/references/task-template.md).

---

## 🎯 When to use

A `refactor` task is right when:

- An `audit.md` exists with prioritised "Needed" entries.
- The change is *structural*, not behavioural — observable behaviour is preserved.
- Tests pass before, during (at every checkpoint), and after.

Behaviour preservation is verified by the [`behaviour-preservation` gate](../reference/verification-gates.md#-spec-intent--equivalence-gates-adr-0022): an equivalence check that would *fail if behaviour changed* — property-based, differential, or golden-output testing where available. A green existing suite is necessary but not sufficient (it only covers what was already tested); where no stronger check exists for a change, the task records explicitly why the existing suite is a sufficient oracle for that change.

If the change is mechanical replacement of API A with API B, that's `migration`, not `refactor`. If observable behaviour changes, that's `rewrite`, not `refactor`. If the audit triggers a structural rethink, that's `spec-writing`, not `refactor`.

---

## 🧬 Metadata

| Field                | Value                                              |
| -------------------- | -------------------------------------------------- |
| **Source doc**       | `audit.md`                                         |
| **Lead persona**     | [The Janitor](../personas/the-janitor.md)         |
| **Secondary**        | [The Skeptic](../personas/the-skeptic.md) (review) |
| **Output**           | Restructured code, behaviour preserved             |
| **Recommended skills** | `write-refactor`, `empirical-proof`, `persona-janitor` |
| **Verification gate slots** | `cmdInstall` (pre), `cmdValidateDeps` (every 10 files), `cmdValidateDeps` (post), `cmdTypecheck` (post), `cmdTest` (post), [`behaviour-preservation`](../reference/verification-gates.md#-spec-intent--equivalence-gates-adr-0022) (self-review) |

---

## Canonical template (agent artefact)

The verbatim Markdown template (persona directive, placeholders, gated `Self-review`) lives under **`/scaffold/.agents/templates/`**. Install by copying [`/scaffold`](../../scaffold/README.md); do not paste large template bodies from framework docs into downstream repos — that guarantees drift.

### Why these structural clusters exist

Every task template shares the same structural clusters; see [Why these structural clusters exist](README.md#why-these-structural-clusters-exist) in the task-type overview for the shared rationale.

---

## ⚠️ Common anti-patterns

- Silencing a validation failure by editing the validator config
- "While I'm here" semantic changes
- Codemods touching hundreds of files in one commit
- Deleting code without grep-evidence
- Skipping checkpoint validation
- Refactoring tests "for clarity" alongside production code

---

## See also

- [`personas/the-janitor.md`](../personas/the-janitor.md)
- [`tasks/migration.md`](migration.md) — close cousin (different scope)
- [`tasks/rewrite.md`](rewrite.md) — when behaviour does change
- [`documents/audit.md`](../documents/audit.md) — the source doc
- [`skills/write-refactor.md`](../skills/write-refactor.md)
