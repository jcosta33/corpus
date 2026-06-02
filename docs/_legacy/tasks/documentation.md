# 📋 Task: documentation

> **TL;DR.** Write or update user-facing documentation (READMEs, contributor guides, ADRs, public API docs). Lead persona is The Documentarian. The reader is a human who has not read the code; lead with what they need to do. Every code example must run as written.

> 📦 **This page is documentation.** The actual task template lives at [`/scaffold/.agents/skills/write-documentation/references/task-template.md`](../../scaffold/.agents/skills/write-documentation/references/task-template.md).

---

## 🎯 When to use

A `documentation` task is right when:

- The deliverable is *user-facing* prose (READMEs, how-to guides, reference pages, ADRs, API docs).
- A spec or audit identifies the doc gap, **or** a one-paragraph human ask captures the scope.
- The reader is a human, not an agent (agent-facing docs are written by the relevant persona — Architect for spec, Auditor for audit, etc.).

---

## 🧬 Metadata

| Field                | Value                                              |
| -------------------- | -------------------------------------------------- |
| **Source doc**       | `spec.md` / `audit.md` / task scope                |
| **Lead persona**     | [The Documentarian](../personas/the-documentarian.md) |
| **Secondary**        | [The Skeptic](../personas/the-skeptic.md) (review) |
| **Output**           | User-facing doc(s) at the project's doc location   |
| **Recommended skills** | `write-documentation`, `distillation-discipline`, `empirical-proof` (the Documentarian mindset is carried by `write-documentation`) |
| **Verification gate slots** | post: every code example actually run (output pasted), `cmdValidate` (if doc-linting applies) |

---

## Canonical template (agent artefact)

The verbatim Markdown template (persona directive, placeholders, gated `Self-review`) lives under **`/scaffold/.agents/templates/`**. Install by copying [`/scaffold`](../../scaffold/README.md); do not paste large template bodies from framework docs into downstream repos — that guarantees drift.

### Why these structural clusters exist

Every task template shares the same structural clusters; see [Why these structural clusters exist](README.md#why-these-structural-clusters-exist) in the task-type overview for the shared rationale.

---

## ⚠️ Common anti-patterns

- Examples that don't run
- Hedge words ("should", "might", "could") the reader can't act on
- Updating the README without updating in-tree docs that contradict
- Mixing Diátaxis types in a single doc
- Background paragraphs before the action
- Treating documentation as an afterthought to feature work

---

## See also

- [`personas/the-documentarian.md`](../personas/the-documentarian.md)
- [`skills/write-documentation.md`](../skills/write-documentation.md) — the recommended skill (carries the Documentarian mindset)
- [`skills/distillation-discipline.md`](../skills/distillation-discipline.md)
- [`skills/empirical-proof.md`](../skills/empirical-proof.md)
- The [Diátaxis](https://diataxis.fr) framework — the doc-type vocabulary
