# 📋 Task: feature

> **TL;DR.** Build new behaviour from a complete spec. Lead persona is The Builder. Spec is the contract; the Builder doesn't improvise around it. Output: code + tests + handoff to The Skeptic for review.

> 📦 **This page is documentation.** The actual task template (the one a launcher / Swarm CLI scaffolds tasks from) lives at [`/scaffold/.agents/skills/write-feature/references/task-template.md`](../../scaffold/.agents/skills/write-feature/references/task-template.md).

---

## 🎯 When to use

A `feature` task is right when:

- You have a spec describing new behaviour to build (or extending existing behaviour in a way that adds capability).
- The spec is *complete enough to implement from* — no `[CRITICAL]` open questions.
- The change is bounded; it doesn't require restructuring (that's `refactor`) or replacing existing behaviour (that's `rewrite`).

If the spec is incomplete, the task type is `spec-writing` (with The Architect), not `feature`.

---

## 🧬 Metadata

| Field                | Value                                              |
| -------------------- | -------------------------------------------------- |
| **Source doc**       | `spec.md`                                          |
| **Lead persona**     | [The Builder](../personas/the-builder.md)         |
| **Secondary**        | [The Skeptic](../personas/the-skeptic.md) (review) |
| **Output**           | Code (with tests) + Skeptic handoff                |
| **Recommended skills** | `write-feature`, `empirical-proof` (the Builder mindset is carried by `write-feature`) |
| **Verification gate slots** | `cmdInstall` (pre), `cmdValidate` (periodic + post), `cmdTest` (post), `cmdValidateDeps` (post, where applicable), `acceptance-criteria-coverage` (self-review) |

---

## Acceptance-criteria coverage gate

A feature task carries the `acceptance-criteria-coverage` gate ([ADR 0022](../adrs/0022-acceptance-criteria-are-executable-checks.md)): in `Self-review`, every acceptance criterion is mapped to the check the spec bound it to (`test` / `command` / `manual`) and the result is pasted. A `test`-bound criterion counts only when its oracle is shown valid (fails when violated, passes when satisfied). The toolchain suite ([ADR 0021](../adrs/0021-verification-contract.md)) proves the code is well-formed; this gate proves it does what the spec asked. The gate is defined in [`reference/verification-gates.md`](../reference/verification-gates.md).

---

## Canonical template (agent artefact)

The verbatim Markdown template (persona directive, placeholders, gated `Self-review`) lives under **`/scaffold/.agents/templates/`**. Install by copying [`/scaffold`](../../scaffold/README.md); do not paste large template bodies from framework docs into downstream repos — that guarantees drift.

### Why these structural clusters exist

Every task template shares the same structural clusters; see [Why these structural clusters exist](README.md#why-these-structural-clusters-exist) in the task-type overview for the shared rationale.

---

## ⚠️ Common anti-patterns for feature tasks

- Implementing past the spec ("while I'm here…")
- Silent ambiguity resolution (the spec was unclear; the Builder picked one interpretation)
- Declaring done without pasting validation output
- Declaring done with an acceptance criterion that isn't mapped to its check and a pasted result (treating a green suite as coverage)
- Refactoring during the feature task (different scope; promote)
- Reinventing helpers that already exist

---

## See also

- [`personas/the-builder.md`](../personas/the-builder.md) — the lead persona
- [`personas/the-skeptic.md`](../personas/the-skeptic.md) — handoff partner
- [`tasks/review.md`](review.md) — the downstream review task
- [`tasks/kickback.md`](kickback.md) — what happens if the Skeptic kicks back
- [`skills/write-feature.md`](../skills/write-feature.md) — the recommended skill (carries the Builder mindset)
- [`documents/spec.md`](../documents/spec.md) — what the source doc looks like
