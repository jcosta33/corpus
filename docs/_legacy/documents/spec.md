# 📜 Document: spec.md

> **TL;DR.** Forward-looking contract: what **should become true**. Diátaxis *Reference*-shaped. Authored by The Architect. Seeds `feature` / `rewrite` / `integration` lanes. Acceptance criteria exist to extinguish Builder interpretation battles.

> 📦 **Authoring scaffold:** [`/scaffold/.agents/templates/spec.md`](../../scaffold/.agents/templates/spec.md) — install via [`/scaffold/README.md`](../../scaffold/README.md).

---

## 🎯 Purpose

Bind Architect intent to mechanically testable predicates so downstream tasks cannot smuggle tacit assumptions. Anything that smells like observational archaeology belongs in audits, not here.

---

## 📍 Where it lives

`.agents/specs/{{slug}}.md` — promoted to `/shipped/` subfolders after delivery when teams track living contracts.

---

## ✍️ Authoring persona

[The Architect](../personas/the-architect.md) is the suggested default ([ADR 0002](../adrs/0002-personas-1-to-1-with-task-types.md), superseded by [0020](../adrs/0020-activation-by-self-assessment.md)); routing is recommended, not enforced, so the agent may re-assess and record divergence.

---

## Canonical scaffold (human reasoning — **not** the literal template)

Markdown skeleton + XML-ish helper tags remain **only** in `/scaffold` so consumer copies diverge consciously, not accidentally via docs copy-pasta.

### Why those heading clusters matter

| Cluster | Load-bearing rationale |
|--------|-------------------------|
| Goal vs scope fences | Keeps exploratory narrative outside executable requirements surface. |
| User-visible behaviours | Bridges product language ↔ engineering validation without prescribing internals. |
| Acceptance criteria with check bindings | Gives Test Author / Builder unanimous oracle for completeness tests. Each criterion declares *how it is verified* — `test` / `command` / `manual` — so the downstream `feature` task checks against the spec rather than re-interpreting it ([ADR 0022](../adrs/0022-acceptance-criteria-are-executable-checks.md)). |
| Design decisions (+ rejected options) | Freezes ambiguity resolution historically—prevents reopened religious wars later. |
| Open questions taxonomy (`[CRITICAL]` / `[MINOR]`) | Forces explicit chokepoints before Implementation begins burning calendar. |
| Distillation Loss Statement | When derived from research, proves Architect acknowledged compression risk. |

Verbatim headings, placeholders, and tag blocks: **do not mirror from `/docs`** — sync only through scaffold refreshes tracked in version control ([ADR 0015](../adrs/0015-versioning-scheme.md)).

---

## 🔗 Acceptance criteria carry check bindings (the spec's half of spec-as-code)

A testable criterion is not enough on its own — each acceptance criterion **declares how it is verified**, its *check binding*, so intent is checkable rather than re-interpreted by every implementer ([ADR 0022](../adrs/0022-acceptance-criteria-are-executable-checks.md)). The binding is one of:

- **`test`** (preferred) — a test exercises it, and that test is a valid *oracle*: it fails when the criterion is violated and passes when satisfied (the downstream `feature` / `testing` work proves this by flipping the assertion).
- **`command`** — the output of a named `AGENTS.md > Commands` entry demonstrates it.
- **`manual`** — verification is unavoidably human; the criterion carries a one-line reason why it cannot be a runnable check.

In the scaffold the criteria are a structured block — criterion, check kind, binding, and a result paste slot — and a criterion with no binding is **not finalisable**. This is the spec's half of the spec-as-code contract: the spec binds each criterion to a check, and the downstream `feature` task maps each criterion to that check and pastes the result (the `acceptance-criteria-coverage` gate in [`../reference/verification-gates.md`](../reference/verification-gates.md)). The spec is checked *against*, not merely read.

---

## ⚠️ Failure modes the `write-spec` skill targets

- Unmeasurable adjectives posing as requirements.
- Acceptance criteria left without a check binding (`test` / `command` / `manual`) — leaving the downstream task to re-interpret intent.
- Sneaking implementation recipe into supposedly behavioural contract.
- Shipping with unanswered `[CRITICAL]` questions silently demoted.
- Mixing observations of today's code with prescriptions for tomorrow.

---

## See also

- [`tasks/spec-writing.md`](../tasks/spec-writing.md)
- [`skills/write-spec.md`](../skills/write-spec.md)
- [`concepts/05-document-types.md`](../concepts/05-document-types.md)
- [`extended.md`](extended.md)
