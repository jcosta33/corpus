# 📋 Task: kickback

> **TL;DR.** A revision task spawned when The Skeptic rejects a worker's branch. The original persona (Builder, Janitor, Migrator, etc.) revises per the Skeptic's specific notes. Source docs: original spec/audit/bug-report **plus** the Skeptic's review notes. After revision, hand back to The Skeptic for re-review.

> 📦 **This page is documentation.** Kickback tasks use the original task type's template (`/scaffold/.agents/skills/write-feature/references/task-template.md`, `task-refactor.md`, etc.) with `Type: kickback (originally: <type>)` and the additions noted below.

---

## 🎯 When to use

A `kickback` task is right when:

- A previous task (feature, refactor, fix, etc.) was reviewed by The Skeptic and the verdict was `KICK BACK`.
- The Skeptic provided specific file:line citations and what must change.
- The branch is salvageable (verdict was not `ABANDON`).

If the Skeptic's verdict was `ABANDON`, the path forward is *not* a kickback — it's re-spec, re-scope, or close.

---

## 🧬 Metadata

| Field                | Value                                              |
| -------------------- | -------------------------------------------------- |
| **Source docs**      | Original source doc (spec/audit/bug-report) **+** the Skeptic's review notes |
| **Lead persona**     | (Original persona — typically The Builder, sometimes Janitor or Migrator) |
| **Secondary**        | [The Skeptic](../personas/the-skeptic.md) (re-review) |
| **Output**           | Revised branch addressing every BLOCKER and (where waived) MAJOR |
| **Recommended skills** | Same as the original task type, plus `adversarial-review` (so the persona can re-check their work against the Skeptic's notes) |
| **Verification gate slots** | Same as the original task type                |

---

## Canonical template (agent artefact)

The verbatim Markdown template (persona directive, placeholders, gated `Self-review`) lives under **`/scaffold/.agents/templates/`**. Install by copying [`/scaffold`](../../scaffold/README.md); do not paste large template bodies from framework docs into downstream repos — that guarantees drift.

### Why these structural clusters exist

Every task template shares the same structural clusters; see [Why these structural clusters exist](README.md#why-these-structural-clusters-exist) in the task-type overview for the shared rationale.

---

## 🛑 Round limit and escalation

A branch that's been kicked back **3 times** is escalated. The Lead Engineer (or human) chooses:

- **Re-spec** — the spec is unclear; spawn a `spec-writing` task to revise.
- **Re-scope** — the work is too large; spawn an `orchestration` to decompose.
- **Abandon** — close the branch and the parent work with rationale.

The 3-round limit is a recommendation, not a hard rule. See [`concepts/08-recursion-and-delegation.md`](../concepts/08-recursion-and-delegation.md) for the escalation protocol.

---

## ⚠️ Common anti-patterns

- Addressing some BLOCKERs but not others ("I'll get to the rest in a follow-up")
- Scope creep during revision (adding "while I'm here" changes)
- Treating a vague kickback as actionable (instead of asking the Skeptic to sharpen it)
- Adopting a different persona during the kickback (the original persona owns the revision)
- Looping past 3 rounds without escalation

---

## See also

- [`personas/the-skeptic.md`](../personas/the-skeptic.md) — author of the kickback
- [`tasks/review.md`](review.md) — the upstream review task
- [`concepts/08-recursion-and-delegation.md`](../concepts/08-recursion-and-delegation.md) — escalation protocol
- [`skills/adversarial-review.md`](../skills/adversarial-review.md) — for re-checking your work
