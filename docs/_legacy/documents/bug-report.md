# 🐛 Document: bug-report.md

> **TL;DR.** Fault dossier with reproducible story + proven root—not the patch plan. Seeds `fix` tasks that adopt Skeptic hostility toward convenient causality narratives.

> 📦 **Authoring scaffold:** [`/scaffold/.agents/templates/bug-report.md`](../../scaffold/.agents/templates/bug-report.md).

---

## 🎯 Purpose

Freeze anomaly understanding so Skeptic-fix can spend cycles disproving hypotheses instead of redoing archaeology. Separation formalised in [ADR 0007](../adrs/0007-bug-report-as-meta-task.md).

---

## 📍 Where it lives

`.agents/bugs/{{slug}}.md` → closed archive after regression guard exists post-fix merge.

---

## ✍️ Authoring persona

[The Bug Hunter](../personas/the-bug-hunter.md).

---

## Canonical scaffold reasoning

Scaffold Markdown encodes investigative discipline (repro snippets, flake handling, correlated defects search). Maintain only under `/scaffold`.

### Structural intent

| Element | Reason |
|---------|--------|
| Deterministic reproduction | Lets third party falsify symptom independently of author memory. |
| Root-cause segmentation | Explicitly distinguishes observation vs inference vs speculative hardening ideas. |
| Regression test blueprint | Gives downstream Skeptic-fix a completion oracle without authoring the patch here. |

---

## ⚠️ Failure modes targeted

- Symptom-only tickets lacking causal chain narrative.
- Premature remediation sketches bloating forensic clarity.
- Skipping lineage search for duplicate defect IDs / related incidents.

---

## 🪞 Why diagnosis and fix diverge tasks

Distinct empirical proofs plus adversarial temperament for patch validation → parallel quality improvement vs combined “quick-close” regressions historically observed in single-pass agent sessions.

See [ADR 0007](../adrs/0007-bug-report-as-meta-task.md).

---

## See also

- [`tasks/bug-report-writing.md`](../tasks/bug-report-writing.md)
- [`tasks/fix.md`](../tasks/fix.md)
- [`skills/write-bug-report.md`](../skills/write-bug-report.md)
- [`personas/the-skeptic.md`](../personas/the-skeptic.md)
