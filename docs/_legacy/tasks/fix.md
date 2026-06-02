# 📋 Task: fix

> **TL;DR.** Repair a defect documented in a `bug-report.md`. Lead persona is The Skeptic — root-causing demands hostility toward plausible-sounding explanations. Output: code patch + regression test + handoff back to The Skeptic for re-review.

> 📦 **This page is documentation.** The actual task template lives at [`/scaffold/.agents/skills/write-fix/references/task-template.md`](../../scaffold/.agents/skills/write-fix/references/task-template.md).

---

## 🎯 When to use

A `fix` task is right when:

- A `bug-report.md` exists with a verified root cause and a reliable reproduction.
- The fix is bounded; it doesn't require new behaviour (that's `feature`) or restructuring (that's `refactor`).
- A regression test is part of the deliverable.

If the bug report is incomplete (no reliable reproduction, no root cause), the task type is `bug-report-writing` (with The Bug Hunter), not `fix`.

---

## 🧬 Metadata

| Field                | Value                                              |
| -------------------- | -------------------------------------------------- |
| **Source doc**       | `bug-report.md`                                    |
| **Lead persona**     | [The Skeptic](../personas/the-skeptic.md) — see [ADR 0006](../adrs/0006-skeptic-owns-fix-tasks.md) |
| **Secondary**        | (kickback returns to original Skeptic-as-fixer)    |
| **Output**           | Code patch + regression test                       |
| **Recommended skills** | `write-fix`, `adversarial-review`, `empirical-proof`, `persona-skeptic` |
| **Verification gate slots** | `cmdInstall` (pre), `cmdValidate` (post), `cmdTest` (post), regression-test fires (post) |

---

## 🪞 Why The Skeptic owns fix tasks

Fixing a bug requires the same hostility toward plausible explanations that the Skeptic uses for review. The bug report says "the cause is X"; the fixer must verify X is actually the cause before patching, and must verify the patch actually addresses X (not just suppresses the symptom).

If your team prefers a dedicated `Fixer` persona (minimality-focused rather than adversarial-focused), you can override the default per-task persona via `swarm.config` (a CLI concern). The framework default is The Skeptic.

---

## Canonical template (agent artefact)

The verbatim Markdown template (persona directive, placeholders, gated `Self-review`) lives under **`/scaffold/.agents/templates/`**. Install by copying [`/scaffold`](../../scaffold/README.md); do not paste large template bodies from framework docs into downstream repos — that guarantees drift.

### Why these structural clusters exist

Every task template shares the same structural clusters; see [Why these structural clusters exist](README.md#why-these-structural-clusters-exist) in the task-type overview for the shared rationale.

---

## ⚠️ Common anti-patterns for fix tasks

- Patching the symptom instead of the root cause
- Skipping reproduction in your worktree (trusting the bug report's claim)
- Regression test that doesn't actually fail before the fix
- Scope creep ("while I'm here, this related bug…")
- Bundling the fix with unrelated cleanup

---

## See also

- [`personas/the-skeptic.md`](../personas/the-skeptic.md) — the lead persona (in fixer mode)
- [`personas/the-bug-hunter.md`](../personas/the-bug-hunter.md) — author of the source bug-report
- [`tasks/bug-report-writing.md`](bug-report-writing.md) — the upstream task
- [`tasks/review.md`](review.md) — the post-fix review
- [`skills/write-fix.md`](../skills/write-fix.md) — the recommended skill
- [ADR 0006](../adrs/0006-skeptic-owns-fix-tasks.md) — why The Skeptic
