# 📒 Guide: Writing source documents

> A unified guide to authoring the four core source-doc types: spec, audit, research, bug-report. For each type, this guide cites the persona, the write skill, the template, and the failure modes the discipline prevents.

---

## ⚡ TL;DR

Each source doc has its own persona, its own template, its own write skill, and its own failure modes. The discipline of authoring is *type-specific*. This guide is the index; the per-doc pages are the depth.

---

## 🪜 Pick the right doc type

Use the epistemic-stance test ([`concepts/05-document-types.md`](../concepts/05-document-types.md)):

| What you're claiming                              | Doc type                               |
| ------------------------------------------------- | -------------------------------------- |
| What *should be true* of the system               | spec                                   |
| What *is true* of the system today                | audit                                  |
| What *was true* during a failure                  | bug-report                             |
| What *is true about the world* outside the system | research                               |

A doc that mixes stances is a smell — split it.

---

## 📜 Writing a spec

**Persona:** [The Architect](../personas/the-architect.md)
**Skill:** [`write-spec`](../skills/write-spec.md)
**Template:** [`documents/spec.md`](../documents/spec.md)
**Task type:** [`spec-writing`](../tasks/spec-writing.md)

**Failure modes the discipline prevents:**
- Unverifiable requirements ("the system should be fast")
- Implementation specification ("use `Map<string, X>`")
- Missing acceptance criteria
- `[CRITICAL]` open questions left and proceeded past
- Mixing forward-looking and present-state content

**Quick checklist before finalising:**
- [ ] Every requirement is testable
- [ ] Every design decision names alternatives considered and rejected
- [ ] Pattern survey done; consulted modules cited
- [ ] `[CRITICAL]` open questions resolved or the spec halted
- [ ] If distilled from research: Distillation Loss Statement complete
- [ ] `git status` shows only the spec doc changed

See [The Architect](../personas/the-architect.md) for the persona's stance and constraints.

---

## 📊 Writing an audit

**Persona:** [The Auditor](../personas/the-auditor.md) (or [The Skeptic](../personas/the-skeptic.md) for `deepen-audit`)
**Skill:** [`write-audit`](../skills/write-audit.md)
**Template:** [`documents/audit.md`](../documents/audit.md)
**Task type:** [`audit-writing`](../tasks/audit-writing.md) or [`deepen-audit`](../tasks/deepen-audit.md)

**Failure modes the discipline prevents:**
- Findings without file:line citations
- Vague observations promoted to findings
- Findings without "Needed" entries
- Flat lists not prioritised by impact
- Trusting structural claims without grepping
- Empty Risks / Suggested approaches

**Quick checklist:**
- [ ] Goal stated as a measurable target (not vague intention)
- [ ] Scope defined (in / out)
- [ ] Every finding cites file:line + has a Needed entry
- [ ] Issues prioritised by impact (BLOCKER / MAJOR / MINOR)
- [ ] Risks made explicit with conditions
- [ ] Verified dynamic invariants where claimed
- [ ] "No callers" claims verified by grep
- [ ] `git status` clean on source

See [The Auditor](../personas/the-auditor.md) for the persona's stance and constraints.

---

## 🐛 Writing a bug report

**Persona:** [The Bug Hunter](../personas/the-bug-hunter.md)
**Skill:** [`write-bug-report`](../skills/write-bug-report.md)
**Template:** [`documents/bug-report.md`](../documents/bug-report.md)
**Task type:** [`bug-report-writing`](../tasks/bug-report-writing.md)

**Failure modes the discipline prevents:**
- Reporting symptom as root cause
- Speculating without reproducing
- Conflating "I think" with "I have proven"
- Bug reports that read as "module X is broken"
- Skipping the related-defects search

**Quick checklist:**
- [ ] Reproduction fires deterministically from a fresh checkout
- [ ] Reliable reproduction documented in re-runnable form
- [ ] Root cause stated as file:line + state + input + caller
- [ ] Hypothesis tracker has tested hypotheses with `[confirmed]` / `[disproven]`
- [ ] Related defects searched; nearby vulnerable patterns noted
- [ ] Regression test plan included
- [ ] `git status` clean on source (no fix in this session)

See [The Bug Hunter](../personas/the-bug-hunter.md) for the persona's stance and constraints.

---

## 📚 Writing research

**Persona:** [The Researcher](../personas/the-researcher.md) (technical) or [The Surveyor](../personas/the-surveyor.md) (UX/market)
**Skill:** [`write-research`](../skills/write-research.md)
**Template:** [`documents/research.md`](../documents/research.md)
**Task type:** [`research-writing`](../tasks/research-writing.md)

**Failure modes the discipline prevents:**
- Opinion presented as finding (no source citation)
- Sources listed but not actually consulted
- Vague attribution ("according to common practice")
- Recommendations that say "it depends" without saying *on what*
- Inferring product behaviour without verifying

**Quick checklist:**
- [ ] Decision-informing question stated in 1-2 sentences
- [ ] At least 3 independent primary sources cited
- [ ] Every Findings claim cites a numbered source
- [ ] Comparison explicit with named criteria (where multiple options exist)
- [ ] Recommendation is actionable (or "no recommendation" is justified)
- [ ] Unverified claims marked `[unconfirmed]`
- [ ] If technical: product-behaviour claims verified, not inferred
- [ ] If UX/market: 3+ concrete competitor examples cited; observed-vs-claimed distinguished

See [The Researcher](../personas/the-researcher.md) (technical mode) and [The Surveyor](../personas/the-surveyor.md) (UX/market mode) for both stances.

---

## 🔁 Cross-doc patterns

### The Distillation Loss Statement

When a doc is distilled from upstream (research → spec, audit → spec, etc.), append a `## Distillation Loss Statement` per [`skills/distillation-discipline.md`](../skills/distillation-discipline.md):

```markdown
## Distillation Loss Statement

**Dropped from upstream:**
- <what was dropped, in concrete terms>

**Why downstream doesn't need this:**
- <justification>
```

A reviewer reads upstream and downstream side by side; the Loss Statement makes verifying nothing load-bearing went missing easy.

### `[CRITICAL]` and `[MINOR]` open questions

`## Open questions` distinguish:

- **`[CRITICAL]`** — would change the doc's content if answered. Block downstream work.
- **`[MINOR]`** — worth recording but not blocking. Implementation may proceed.

The Architect halts on `[CRITICAL]`. Other personas similarly halt on `[CRITICAL]` before finalising.

### Decisions with named alternatives

In `## Design decisions` (specs) or `## Decisions` (others), every significant choice shows its work:

```markdown
### Decision: <name>

**Chosen:** <what was chosen>

**Considered and rejected:**
- _<alternative A>_ — rejected because <reason>
- _<alternative B>_ — rejected because <reason>
```

A decision without alternatives is incomplete — the reader can't tell whether the alternatives were considered or merely overlooked.

---

## 🪜 The author/reviewer matrix

Some docs are reviewed by a *different* persona than authored. Use the matrix to find the reviewer:

See [`reference/compatibility-matrix.md` Table 1](../reference/compatibility-matrix.md#table-1-personas--document-types).

For example: a spec authored by The Architect is reviewed (when relevant) by The Researcher (for research-grounded specs) or The Surveyor (for UX-grounded specs). The reviewer's job is to verify the spec faithfully captures the upstream's load-bearing claims.

---

## ⚠️ Cross-cutting anti-patterns

- **Author starts implementing during the authoring task** — read-only constraint violated; halt
- **Doc takes both forward-looking and present-state stances** — split into two docs
- **`[CRITICAL]` open question pushed past** — halt; resolve via separate task or downgrade with reasoning
- **Distillation without a Loss Statement** — append it; it's how reviewers verify nothing was dropped silently
- **Decisions without named alternatives** — incomplete; either name the alternative or remove the decision

---

## See also

- [`documents/`](../documents/) — per-doc-type pages with full templates
- [`personas/`](../personas/) — per-persona pages with worked examples
- [`skills/`](../skills/) — the write skills
- [`concepts/03-distillation.md`](../concepts/03-distillation.md) — the Distillation Loss Statement protocol
- [`concepts/05-document-types.md`](../concepts/05-document-types.md) — the epistemic-stance frame
- [`reference/compatibility-matrix.md`](../reference/compatibility-matrix.md) — author/reviewer matrix
