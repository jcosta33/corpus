# 📖 Reference: Document base skeleton

> The shared sections every source-document template includes. Per-type templates extend this base; this doc is the canonical statement of what every doc looks like.

---

## 📐 The skeleton

```markdown
# <Title>

## Status

Draft / Active / Resolved / Shipped / Superseded

## Author

(Persona name; or human author if pre-Swarm)

## Context

Why this doc exists. The triggering ask. The audience.

## Linked docs

- Upstream sources (research / audit / earlier doc): `<paths>`
- Related documents (other specs, ADRs, constitution): `<paths>`

## (Type-specific main content)

(Per doc type — see below for each)

## Decisions

Significant choices made while writing this doc, with rationale and named alternatives.

## Open questions

- [ ] **[CRITICAL]** Questions that block downstream work
- [ ] **[MINOR]** Questions worth recording but not blocking

## Distillation Loss Statement

(For docs distilled from upstream — see [`concepts/03-distillation.md`](../concepts/03-distillation.md))

**Dropped from upstream:**
- <what>

**Why downstream doesn't need this:**
- <why>
```

---

## 🪞 Per-type extensions

| Type            | Adds                                                                                                            |
| --------------- | --------------------------------------------------------------------------------------------------------------- |
| `spec.md`       | `## Goal` · `## Scope` · `## User-visible behaviour` · `## Acceptance criteria` · `## Constraints` · `## Pattern survey` · `## Tradeoffs and risks` |
| `audit.md`      | `## Goal` · `## Scope` · `## Code paths inspected` · `## Findings` (with file:line + severity + Needed) · `## Risks` · `## Suggested approaches` |
| `bug-report.md` | `## Reported behaviour` · `## Reliable reproduction` · `## Hypothesis tracker` · `## Root cause` · `## Related defects` · `## Regression test plan` |
| `research.md`   | `## Research question` · `## Sources` · `## Findings` · `## Comparison` · `## Recommendation`                  |

For the full per-type templates, see:

- [`documents/spec.md`](../documents/spec.md)
- [`documents/audit.md`](../documents/audit.md)
- [`documents/bug-report.md`](../documents/bug-report.md)
- [`documents/research.md`](../documents/research.md)
- [`documents/extended.md`](../documents/extended.md) (ADR, constitution, migration plan, benchmark report, etc.)

---

## 🪞 Sections every doc has

| Section                          | Why                                                                       |
| -------------------------------- | ------------------------------------------------------------------------- |
| `## Status`                      | Lifecycle state (Active / Resolved / Shipped / Superseded)                |
| `## Author`                      | Traceability (persona name; for human-authored docs, the human's name)   |
| `## Context`                     | Why the doc exists; the audience                                         |
| `## Linked docs`                 | Upstream + related; the trail                                             |
| `## Decisions`                   | Significant choices with named alternatives                              |
| `## Open questions`              | `[CRITICAL]` and `[MINOR]` markers                                        |
| `## Distillation Loss Statement` | If distilled from upstream                                                |

The Distillation Loss Statement is *required* for docs distilled from upstream artefacts; *optional* for docs born from a human's first ask. See [`distillation-discipline.md`](../skills/distillation-discipline.md).

---

## See also

- [`documents/`](../documents/) — per-type pages
- [`task-base.md`](task-base.md) — the task equivalent
- [`concepts/05-document-types.md`](../concepts/05-document-types.md)
- [`skills/distillation-discipline.md`](../skills/distillation-discipline.md)
