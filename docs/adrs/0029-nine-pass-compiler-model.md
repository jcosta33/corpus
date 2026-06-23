---
type: adr
id: 0029-nine-pass-compiler-model
status: accepted
created: 2026-06-02
updated: 2026-06-02
supersedes:
superseded_by:
---

# ADR-0029: The 9-pass compiler model

## Context

The pre-kernel model treated "compile a spec into a change" as an undifferentiated
act — author a spec, then "do the work." Without a named, ordered set of transformations,
there was no place to attach a typed input/output contract, no defensible point to insert
a gate, and no way to say which step may rewrite a spec versus only diagnose it. Stages
(conceptual) and the units actually run (schedulable) were conflated, so "improve the spec"
or "lower it" had no fixed before/after shape. §9 forces the resolution: the journey from a
human-authored specification to a promoted, verified change is modelled as a compiler pipeline,
described at two granularities that MUST NOT be conflated — phases (conceptual stages) and
passes (schedulable transformations).

## Decision

The Corpus pipeline is a fixed, ordered sequence of nine **passes**, each a schedulable
transformation with a typed input artifact and a typed output artifact:

```text
author -> lint -> improve -> lower -> decompose -> implement -> verify -> review -> promote
```

"Compile" is the disciplined transformation of intent into verified change across these passes:
`author` captures intent as a spec; `lint` diagnoses without mutating; `improve` normalizes
semantics-preservingly; `lower` emits the IR graph; `decompose` partitions it into write-disjoint
work packets; `implement` produces the change for assigned obligations; `verify` runs bound proofs
to a per-obligation verdict; `review` judges claims and computes the merge gate; `promote` moves
durable discoveries into provenance-anchored artifacts. There is NO runtime — each pass is a
**contract** a future conformant tool MUST honour, performed today by a human or agent following a
pass guide. For a single obligation the partial order MUST be respected (no `verify` before
`implement`, no `implement` before `lower`). The full per-pass input/output contract, the
pass-to-phase mapping, and the contract notes are detailed in the compiler-pipeline
reference ([`docs/model/how-swarm-works.md`](./model/how-swarm-works.md)) and the per-pass pages under [`docs/passes/`](./passes/).

## Alternatives considered

| Alternative | Why rejected |
| --- | --- |
| One undifferentiated "compile" step | No typed boundary to attach a per-step contract, a gate, or a profile to; the failure modes of lowering, implementing, and verifying differ and MUST be separable (§9). |
| Use only the seven phases as the schedulable unit | Phases are conceptual stages, not schedulable work; an author/agent/tool runs passes, not phases. The small fixed phase taxonomy is the stable spine; the larger pass set is the schedulable surface (§9, §9.1). |
| Let `lint` also rewrite the spec | `lint` is non-mutating by contract; only `improve` may rewrite a spec, and only semantics-preservingly. Fusing them would let a "diagnosis" silently change intent (§9.3.1). |
| Fold `decompose` into `lower` (one LOWER pass) | They have different inputs, outputs, and failure modes — graph construction vs work partitioning; conflating them mixes the two (§9.3.1, §11). |
| Treat `review[profile: skeptic]` as a tenth pass | Adversarial review is a profile parameter on the existing `review` pass, not a separate pass; the earlier `adversarial-review` skill becomes `review[profile: skeptic]` (§9.4). |

## Consequences

### Positive

- Every step gains a typed input→output contract, giving a future tool a precise interface to build against and a human a checkable hand-off.
- A fixed partial order makes illegal sequencing (verifying before implementing, lowering before linting) a nameable error rather than an undefined state.
- Clear separation of the only mutating pass (`improve`) from the diagnostic pass (`lint`) protects "code is reality, not intent."

### Negative

- Nine named passes are more surface to learn and document than a single "do the work" step.
- The phase/pass two-level model is a distinction users must hold; conflating them re-introduces the ambiguity the model exists to remove.

### Neutral / tradeoffs

- Not every pass ships a dedicated stdlib pass guide: `lint`, `decompose`, `review`, and `promote` each ship one; `implement` is served by the nine per-`task_kind` implement guides, `author` by the six author guides, and `verify` by the `empirical-proof` fragment; `improve` and `lower` ship none and are fully specified by the spec, and MAY gain guides later without a language-version change (§9.4) (packaging later revised — see ADR-0042). A guide-less pass is not a conformance gap.
- A launcher MAY interleave passes across multiple specs; the order constraint binds only per single obligation (§9.2).

## Status

Accepted (v0.1).

## Affected obligations / constraints

- Adds: the nine-pass ordered pipeline and its per-pass typed input/output contracts (§9.2, §9.3).
- Adds: the two-level phase-vs-pass distinction and the pass-to-phase mapping (§9.1, §9.3).
- Modifies: the meaning of "compile" — now the disciplined transformation of intent into verified change across the nine passes (§9).
- Supersedes: none.

> **Ledger note (2026-06-11):** refined by ADR-0057 (nine steps become the advanced lifecycle); per-kind routing clauses partially superseded by ADR-0068.
