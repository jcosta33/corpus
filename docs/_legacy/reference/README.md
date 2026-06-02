# 📖 Reference

> Lookup material. Dense, exhaustive, structured for skimming. The single most-referenced section of the docs.

---

## 🗂️ The catalogue

| Doc                                            | What it answers                                                                                       |
| ---------------------------------------------- | ----------------------------------------------------------------------------------------------------- |
| [`flow-graph.md`](flow-graph.md)               | The operational tables: source-doc → task-type, task-type → persona, task-type → skills, task-type → verification commands |
| [`compatibility-matrix.md`](compatibility-matrix.md) | The persona × doc, persona × task, doc × task matrices                                          |
| [`template-placeholders.md`](template-placeholders.md) | The framework's placeholder contract — what `{{cmdX}}` and `{{slug}}` mean for tool builders   |
| [`task-base.md`](task-base.md)                 | The shared task skeleton (sections every task template includes)                                       |
| [`document-base.md`](document-base.md)         | The shared document skeleton (sections every doc template includes)                                    |
| [`directory-layout.md`](directory-layout.md)   | The minimum `.agents/` directory structure for a Swarm-conformant repo                                 |
| [`agents-md.md`](agents-md.md)                 | The AGENTS.md anatomy + Swarm's adoption of the open standard                                          |
| [`verification-gates.md`](verification-gates.md) | The named gate slots and when each fires                                                              |
| [`glossary.md`](glossary.md)                   | Every term Swarm uses, defined precisely                                                              |

---

## 🪞 How to use the reference

The reference exists for **lookup**, not for reading top-to-bottom. Each doc opens with a TOC. Skim to find the cell you need; drill in for the detail.

If you want to *understand* the framework's mechanism, start with [`concepts/`](../concepts/). If you want to *do* something specific, start with [`guides/`](../guides/). The reference is for *what's the rule again?*

---

## 🛡️ Conformance

A project is Swarm-conformant if and only if every cell of the reference matrices holds in the project. The conformance rules — the operational form of "every cell holds" — are documented in the conformance checker (when it ships). Until then, this reference is the canonical statement of what conformance means.

---

## See also

- [`concepts/`](../concepts/) — the why
- [`guides/`](../guides/) — the how
- [`personas/`](../personas/) — per-persona pages
- [`tasks/`](../tasks/) — per-task pages
- [`documents/`](../documents/) — per-doc pages
- [`skills/`](../skills/) — the framework's shipped skills
