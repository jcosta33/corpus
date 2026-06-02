# 📊 Document: audit.md

> **TL;DR.** Observation ledger anchored to constitution / ADRs: what exists *now*, what violates rules, prioritized `Needed`. Spawns refactor / perf / deepening follow-ups—not feature invention.

> 📦 **Authoring scaffold:** [`/scaffold/.agents/templates/audit.md`](../../scaffold/.agents/templates/audit.md).

---

## 🎯 Purpose

Make debt legible enough that Janitor / Performance personas can execute without archaeology. Forbidden stance: prescribing new product behaviours (redirect to Architect + spec pipeline).

---

## 📍 Where it lives

`.agents/audits/{{slug}}.md` → archive resolved packs under `.agents/audits/resolved/` when remediation waves finish.

---

## ✍️ Authoring persona

[The Auditor](../personas/the-auditor.md). Skeptic inherits file during `deepen-audit` revalidation passes.

---

## Canonical scaffold reasoning

Operational Markdown + severity tables live strictly under `/scaffold` to keep portable repos authoritative.

### Why the audit-specific slots exist

| Cluster | Purpose |
|---------|---------|
| Traceability to constitution rules | Prevents vibes-based severity—every MAJOR cites the violated invariant ID. |
| File: line observations | Gives grep-able falsifiers for Skeptic deepening + Janitor checkpoints. |
| `Needed` per finding | Describes outcome shape without embedding the eventual patch narrative. |

---

## 🪜 Severity scale

| Severity   | Interpretation primer |
| ---------- | -------------------- |
| **BLOCKER** | Safe downstream work aborts until handled (security, correctness cliff). |
| **MAJOR**  | Costs velocity / reliability materially; schedule explicitly. |
| **MINOR**  | Cosmetic or isolated; acceptable to batch. |

Calibrate by blast radius, not discovery order—document promote/demotion when controversial.

---

## ⚠️ Failure modes the `write-audit` skill targets

- Assertions lacking locators (`file:line` or reproducible command).
- Prescriptive solution essays masquerading as observations.
- Findings devoid of actionable `Needed` statements.
- Unverified assumptions like "unused" modules without exhaustive search receipts.

---

## See also

- [`tasks/audit-writing.md`](../tasks/audit-writing.md)
- [`tasks/deepen-audit.md`](../tasks/deepen-audit.md)
- [`tasks/refactor.md`](../tasks/refactor.md)
- [`skills/write-audit.md`](../skills/write-audit.md)
- [`skills/adversarial-review.md`](../skills/adversarial-review.md)
- [`extended.md`](extended.md)
