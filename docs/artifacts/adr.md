# `adr.md` — the immutable decision record

An `adr.md` is a single architecture decision recorded in Nygard form — context, decision, consequences, status — that, once accepted, is **never edited in place**: it is amended only by writing a new, superseding ADR. Among the obligations it is the highest-authority **parent** of a spec: an accepted decision constrains what later specs may obligate, and it governs as the strongest recorded intent when two artifacts assert overlapping content.

## Purpose & epistemic stance

An ADR asserts one kind of knowledge: a **decision** — a choice that was made, in the context that forced it, with the alternatives that were weighed and the consequences accepted. It is durable architectural or product intent: "we chose X over Y, and here is why." Its stance is *commitment* (distinct from an RFC, whose stance is *proposal* and which commits nothing until accepted, and from a finding, whose stance is *evidence* about what is true rather than what was chosen).

What an ADR MUST do:

- Record **one** decision. A document that bundles several unrelated decisions is not an ADR; split it.
- Capture the decision **in its context** — the problem, constraint, or pressure that made a choice necessary — so the record stays auditable after the surrounding situation changes.
- Name the **alternatives rejected** and the consequences accepted, so a future reader can reconstruct *why this and not the others* without re-deriving it.

What an ADR MUST NOT do:

- It **MUST NOT be edited in place once accepted.** The body of an accepted ADR is immutable. "Amending" a decision means publishing a *new* superseding ADR, not rewriting the old one. (See *Nygard immutability* below.)
- It **MUST NOT carry its own SOL obligation blocks** (`REQ`/`CONSTRAINT`/`INVARIANT`). An ADR is a decision, not a behavioral contract. A decision acquires obligation force only when an `author` step promotes it *into* a `spec.swarm.md`, where the chosen constraints become real obligations. An ADR that smuggles obligation blocks into itself is a distillation error — it is asserting spec-level authority from a decision-level artifact.
- It **MUST NOT silently re-bless a reversed decision.** If a later decision overturns this one, the override is recorded as supersession, not as a quiet edit; the truth of the decision is the *full chain* of ADRs, not whichever one is latest.

### Nygard immutability (normative)

An accepted ADR is a **dated record of a decision in its context**. Rewriting it destroys the historical record that makes the decision chain auditable — a future reader could no longer tell what was decided, when, or against what alternatives. Therefore:

> An accepted ADR MUST NOT be edited in place. Amending an ADR means publishing a **new, superseding ADR**; the original keeps its body and gains only a `Superseded by ADR-NNNN` status line. The truth of any decision is the **full chain** of ADRs, not the latest one alone.

The amended ADR's body stays frozen; only its `status` becomes `superseded` and its `superseded_by` link is filled in. The superseding ADR carries the new decision and points back via `supersedes`. This is the same append-only-with-supersession discipline Swarm applies to its change ledger and to promoted memory: a fact is replaced by a better fact, never quietly overwritten.

## Filename & placement

An ADR is a **working artifact**, not a compiler-visible source. Its filename therefore MUST NOT carry the `.swarm.` infix and MUST use a plain `.md` extension. The infix rule partitions every Swarm-tracked file into two classes: the human-authored compiler-visible source is `*.swarm.md` (only the spec); files that a future tool *emits* take the `*.swarm.*` shape (e.g. `*.swarm.ir.json`, `*.swarm.trace.md`); everything an agent or human authors as a working record — including ADRs, findings, reviews, traces, and tasks — is plain `.md`. An ADR is parsed by no tool; it is structured Markdown governed by this contract, though it MAY quote SOL blocks as data.

Concretely, the class boundary is:

| Class | Filename shape | Example |
| --- | --- | --- |
| Compiler-visible source (human-authored) | `*.swarm.md` | `auth.swarm.md` |
| Emitted by a future tool | `*.swarm.*` | `auth.swarm.ir.json`, `auth.swarm.trace.md` |
| Working artifact (this class) | plain `.md` | `adr.md`, `0027-sol-is-the-language.md` |

In an adopted project, an ADR is a **durable source artifact** — a `type: adr` document committed to the spec repo in **`decisions/`** (the project-wide decision ledger), distinct from the per-feature source docs that live in `specs/<feature>/`. It is **not** execution scratch (the recreatable task frames, traces, and reviews a run produces, which are gitignored or created lazily) and it is not the compact recall map (which links *to* ADRs but does not store their bodies). A retired ADR is marked superseded and linked to the decision that replaced it; it is never silently deleted, because the chain must stay auditable. ADRs are conventionally numbered (`0027-…`, `0028-…`) so the chain reads in decision order; vacated numbers are left unfilled rather than reused, so higher references do not shift.

## Required sections & fields

A conformant `adr.md` MUST contain the four Nygard elements — context, decision, consequences, status — plus the supersession linkage. In order:

### Frontmatter (YAML)

| Field | Meaning |
| --- | --- |
| `type` | MUST be `adr`. |
| `id` | The ADR's stable identifier (its slug / number). |
| `status` | One of `proposed \| accepted \| superseded \| rejected`. |
| `created` | Date the ADR was first written. |
| `updated` | Date the status last changed. On an accepted-then-superseded ADR, the only legitimate update after acceptance is the status flip + `superseded_by` link — never a body edit. |
| `supersedes` | The `id` of the ADR this one replaces (empty if it replaces none). |
| `superseded_by` | The `id` of the ADR that replaced this one (filled in only when this ADR is amended; otherwise empty). |

### Body sections

| Section | Meaning |
| --- | --- |
| `# ADR: <title>` | The decision's title. |
| `## Context` | What forced the decision — the problem, constraints, or pressure that made a choice necessary. |
| `## Decision` | What was chosen, stated plainly. |
| `## Alternatives considered` | A table of each alternative weighed and why it was rejected — the record of *why this and not that*. |
| `## Consequences` | The tradeoffs accepted, split into **Positive** (what this decision wins), **Negative** (what it costs), and **Neutral / tradeoffs** (consequences that are neither clearly good nor bad). |
| `## Status` | `proposed \| accepted \| superseded \| rejected`. An amended ADR gains here only a `Superseded by ADR-00XX` line; the body above stays immutable. |
| `## Affected obligations / constraints` | Which obligation/constraint IDs this decision **Adds**, **Modifies**, or **Supersedes**. This is a *pointer* to where the decision lands once authored into a spec — not obligation blocks living inside the ADR. |

## Copyable template

The copyable skeleton for this artifact is shipped at:

```
starter-kit/.agents/templates/adr.md
```

Copy that file to start a new ADR — it is the empty skeleton (frontmatter + the seven body sections above, with placeholders). **This page is the contract; the template is the skeleton.** When the two are read together, the template tells you the shape to fill in and this page tells you what each section must mean and what the ADR may never do.

## Related

- [`docs/passes/author.md`](../passes/author.md) — the step that consumes an ADR (stance: **decision**) and promotes its chosen constraints *into* a `spec.swarm.md` as real obligations.
- [`docs/passes/promote.md`](../passes/promote.md) — the step that routes a durable architectural/product decision discovered during work to a *new* ADR, and indexes accepted ADRs in the memory recall map.
- [`docs/artifacts/rfc.md`](./rfc.md) — the **proposal** that precedes a decision; an accepted RFC promotes to an `adr.md` and/or a `spec.swarm.md`.
- [`docs/artifacts/finding.md`](./finding.md) — the **evidence** stance; a finding records what is true (and can feed a decision), where an ADR records what was chosen.
- [`docs/reference/promotion-protocol.md`](../reference/promotion-protocol.md) — the promotion statuses and the immutable two-tier memory model an accepted ADR enters as Tier-2 evidence.
