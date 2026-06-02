# 📋 Task: deepen-audit

> **TL;DR.** Re-walk an existing audit with fresh adversarial eyes. Lead persona is The Skeptic. Read the code with the prior audit *closed*. Look for what the prior audit missed; flag any of its claims that don't hold up. Output: an updated audit (or a new audit citing the prior one) with new findings and corrections.

> 📦 **This page is documentation.** The `deepen-audit` task type uses the same template as `audit-writing`: [`/scaffold/.agents/skills/write-audit/references/task-template.md`](../../scaffold/.agents/skills/write-audit/references/task-template.md), with `Type: deepen-audit` and the additions noted below.

---

## 🎯 When to use

A `deepen-audit` task is right when:

- An existing audit covers an area but new evidence (a bug, a near-miss, a perf regression) suggests it missed something.
- The audit is being re-validated as input to a high-stakes downstream task (a major refactor, a Q3 commit).
- A senior reviewer wants a fresh adversarial pass.

If you're auditing a *new* area for the first time, that's `audit-writing`. Deepening is specifically *re-auditing* with prior context.

---

## 🧬 Metadata

| Field                | Value                                              |
| -------------------- | -------------------------------------------------- |
| **Source doc**       | Existing `audit.md` + the human's deepening ask    |
| **Lead persona**     | [The Skeptic](../personas/the-skeptic.md)         |
| **Output**           | Updated `audit.md` (or new audit citing the prior) |
| **Recommended skills** | `write-audit`, `adversarial-review`, `empirical-proof`, `persona-skeptic` |
| **Verification gate slots** | post: `git status` (clean on source), `cmdValidate` and `cmdValidateDeps` if structural claims rely on them |

---

## Canonical template (agent artefact)

Uses **`/scaffold/.agents/skills/write-audit/references/task-template.md`** with `type: deepen-audit`. Conceptually inherits the authoring skeleton from [`audit-writing`](audit-writing.md) but swaps persona and proof emphasis to Skeptic-coded adversarial re-verification rather than Auditor net-new discovery.

### Why deepen-audit merits its own routed task

| Concern | Rationale |
|--------|-----------|
| **Framing contagion** | Reading the predecessor audit before code imports blind spots labelled as completeness. Launcher encodes mandatory sequencing in constraints + persona. |
| **Epistemic duty** | Not only additive findings — must falsify stale claims referencing moved codepaths. Different Self-review interrogatives than first-pass audit-writing. |

### Deltas the conditioned file must encode (summaries — verbatim text in scaffold / generated task only)

- Session banner + persona block quoting Skeptic deepening protocol.
- `## Linked docs` includes **prior audit** path as primary foil.
- Constraint bullets: independent read-first discipline, corroborate or negate prior citations, explicit correction choreography for contradicted assertions.
- Self-review appendix: adversarial completeness questions distinct from Auditor checklist.

Structured starter lives with other task templates under `/scaffold/.agents/templates/` (see scaffold README); do **not** mirror full Markdown bodies here — that reintroduces copy drift.

---

## ⚠️ Common anti-patterns

- Reading the prior audit before the code (you'll inherit its framing)
- Treating the prior audit as ground truth ("the prior audit said X, so I won't check X")
- Adding new findings without verifying the prior audit's existing ones
- Writing a fresh audit that doesn't cite the prior
- Not flagging contradictions between the prior and current state

---

## See also

- [`personas/the-skeptic.md`](../personas/the-skeptic.md)
- [`tasks/audit-writing.md`](audit-writing.md) — the parent template
- [`tasks/review.md`](review.md) — sibling task (review of code, not of audits)
- [`documents/audit.md`](../documents/audit.md)
- [`skills/adversarial-review.md`](../skills/adversarial-review.md)
