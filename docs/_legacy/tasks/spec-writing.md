# 📋 Task: spec-writing

> **TL;DR.** Translate research / audit / human ask into a verifiable spec a Builder can implement from. Lead persona is The Architect. Read-only on source code; only the spec doc changes. Halt on `[CRITICAL]` open questions before they block downstream implementation.

> 📦 **This page is documentation.** The actual task template lives at [`/scaffold/.agents/skills/write-spec/references/task-template.md`](../../scaffold/.agents/skills/write-spec/references/task-template.md). The doc-template the spec-writing task produces lives at [`/scaffold/.agents/templates/spec.md`](../../scaffold/.agents/templates/spec.md).

---

## 🎯 When to use

A `spec-writing` task is right when:

- A research file or audit identifies something that needs a forward-looking spec.
- A human asks for a spec on a new capability (no upstream artefact required).
- An ADR identifies a structural change that needs detailed specification.

If you're documenting *what was built*, that's `documentation`, not `spec-writing`. Specs are forward-looking — see [`concepts/05-document-types.md`](../concepts/05-document-types.md).

---

## 🧬 Metadata

| Field                | Value                                              |
| -------------------- | -------------------------------------------------- |
| **Source doc(s)**    | `research.md` and/or `audit.md` (optional); human ask |
| **Lead persona**     | [The Architect](../personas/the-architect.md)     |
| **Output**           | `spec.md` at `.agents/specs/{{slug}}.md`           |
| **Recommended skills** | `write-spec`, `distillation-discipline`, `persona-architect` |
| **Verification gate slots** | post: `git status` (clean on source — must show no source/config changes) |

---

## Canonical template (agent artefact)

The verbatim Markdown template (persona directive, placeholders, gated `Self-review`) lives under **`/scaffold/.agents/templates/`**. Install by copying [`/scaffold`](../../scaffold/README.md); do not paste large template bodies from framework docs into downstream repos — that guarantees drift.

### Why these structural clusters exist

Every task template shares the same structural clusters; see [Why these structural clusters exist](README.md#why-these-structural-clusters-exist) in the task-type overview for the shared rationale.

---

## ⚠️ Common anti-patterns

- Speccing implementation steps instead of requirements
- Speccing without surveying prior art
- Leaving `[CRITICAL]` open questions and proceeding
- "We can figure that out during implementation"
- Mixing forward-looking spec content with present-state observation
- Modifying source code "to verify the design"

---

## See also

- [`personas/the-architect.md`](../personas/the-architect.md)
- [`documents/spec.md`](../documents/spec.md)
- [`skills/write-spec.md`](../skills/write-spec.md)
- [`skills/distillation-discipline.md`](../skills/distillation-discipline.md)
