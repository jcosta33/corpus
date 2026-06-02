# 📋 Task: review

> **TL;DR.** Adversarial inspection of a worker's branch (or your own work in a fresh session). Lead persona is The Skeptic. Output: a verdict (APPROVE / KICK BACK / ABANDON) and a findings list. Fixes happen in a downstream task. Run validation yourself; do not trust the worker's pasted output.

> 📦 **This page is documentation.** The actual task template lives at [`/scaffold/.agents/templates/task-review.md`](../../scaffold/.agents/templates/task-review.md).

---

## 🎯 When to use

A `review` task is right when:

- A code-producing task has finished and produced a branch.
- Independent verification is required before merge.
- The reviewer must operate adversarially, not collaboratively.

The Lead Engineer adopts this task type as part of orchestration (becomes The Skeptic for each worker's branch). A standalone `review` task can also be spawned for any branch needing pre-merge review.

---

## 🧬 Metadata

| Field                | Value                                              |
| -------------------- | -------------------------------------------------- |
| **Source doc**       | A branch under review + the original source doc (spec/audit/bug-report) |
| **Lead persona**     | [The Skeptic](../personas/the-skeptic.md)         |
| **Output**           | Verdict + findings list                            |
| **Recommended skills** | `adversarial-review`, `empirical-proof`, `persona-skeptic` |
| **Verification gate slots** | `cmdInstall` (pre), `cmdValidate` (post — **run by you**), `cmdTest` (post — **run by you**), `git diff` of branch under review |

---

## Canonical template (agent artefact)

The verbatim Markdown template (persona directive, placeholders, gated `Self-review`) lives under **`/scaffold/.agents/templates/`**. Install by copying [`/scaffold`](../../scaffold/README.md); do not paste large template bodies from framework docs into downstream repos — that guarantees drift.

### Why these structural clusters exist

Every task template shares the same structural clusters; see [Why these structural clusters exist](README.md#why-these-structural-clusters-exist) in the task-type overview for the shared rationale.

---

## ⚠️ Common anti-patterns

- Approving because the worker said all tests passed
- Reviewing only the diff and missing the unchanged callers
- Soft-language findings
- Trusting the worker's pasted verification output instead of running yourself
- Demoting findings to avoid confrontation
- Approving a small diff without confirming the small diff is the right work

---

## See also

- [`personas/the-skeptic.md`](../personas/the-skeptic.md)
- [`skills/adversarial-review.md`](../skills/adversarial-review.md) — the canonical review skill
- [`skills/empirical-proof.md`](../skills/empirical-proof.md)
- [`tasks/kickback.md`](kickback.md) — what happens after a KICK BACK verdict
- [`tasks/deepen-audit.md`](deepen-audit.md) — sibling task
