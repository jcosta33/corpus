# 📚 Document: research.md

> **TL;DR.** Highest-verbosity explanatory layer citing primary evidence. Ends in actionable recommendation—not silent handwave to Implement. Seeds `spec-writing` / selective audit follow-ups depending on anomalies uncovered.

> 📦 **Authoring scaffold:** [`/scaffold/.agents/templates/research.md`](../../scaffold/.agents/templates/research.md).

---

## 🎯 Purpose

Bundle external truths + synthesized implications for Architects. Must never become an implicit spec shortcut; research is upstream input, and the recommended routing is research → `spec-writing`, not straight to implementation (see [`reference/flow-graph.md`](../reference/flow-graph.md)).

Avoid generating research artefacts when training-data sufficiency suffices—intellectual honesty check lives in authoring skill scaffold.

---

## 📍 Where it lives

`.agents/research/{{slug}}.md` superseded lineage tracked via filenames / metadata—mutable history discouraged; fork new slug when world changes.

---

## ✍️ Authoring personas

[The Researcher](../personas/the-researcher.md) (technical) · [The Surveyor](../personas/the-surveyor.md) (UX/market). Single file picks one investigative lens—split genuinely hybrid asks.

---

## Canonical scaffold reasoning

Source tags, bibliography blocks, methodological caveats articulated only inside `/scaffold` template to avoid divergence between explanatory docs and operative prompts.

### Epistemic affordances encoded

| Area | Benefit |
|------|---------|
| Hypothesis bullets | Keeps exploratory branches visible versus merged pretend-certainty prose. |
| Source table w/ timestamps | Surfaces staleness reviewers must discount. |
| Explicit unknowns `[pending]` | Prevents covert deferral accumulating interest downstream. |

---

## 📖 Citation conventions summary

Prefer numbered bibliography + mirrored inline cites. Weight primary references (RFC, official docs with version, reproducible gist) heavier than punditry—full nuance enumerated in authoring skill scaffold, not duplicated here verbatim.

---

## ⚠️ Failure modes targeted

- Unsourced decisive language.
- “Further study needed” without scoping what's blocked.
- Accidental insertion of behavioural mandates (belongs Architect-side spec).

---

## 🔭 Technical vs UX / market split

| Mode | Persona emphasis | Typical evidence |
|------|------------------|------------------|
| Technical | Researcher rigor | Specs, code, reproducible benchmarks |
| UX/market | Surveyor synthesis | Behavioural studies, competitive teardowns |

Do not mingle modes in one file—correlation analysis becomes unfalsifiable stew.

---

## See also

- [`tasks/research-writing.md`](../tasks/research-writing.md)
- [`skills/write-research.md`](../skills/write-research.md)
- [`skills/distillation-discipline.md`](../skills/distillation-discipline.md)
- [`concepts/05-document-types.md`](../concepts/05-document-types.md)
