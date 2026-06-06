---
type: adr
id: 0033-golden-corpus
status: accepted
created: 2026-06-02
updated: 2026-06-02
supersedes:
superseded_by:
---

# ADR-0033: The golden corpus

## Context

The conformance contract (§32, ADR 0026) is inert versioned data: the precise definition a future checker would honour. But a contract alone cannot demonstrate conformance — it states the rules, not the verdicts those rules produce on real specs. Without worked, verdict-pinned examples there is nothing to validate a checker (or a human reviewer) against, and nothing that proves the obligation language and its passes behave as the contract claims. Worse, a suite of only *valid* specimens cannot catch the failure mode Swarm exists to prevent: a structurally well-formed artifact that is nonetheless wrong (Invariant 4 — schema-valid ≠ verified). Established compiler-conformance practice resolves this by shipping a suite of both allowed and disallowed productions whose conformity is known *without* the tool under test (§33.1). The pressure: Swarm needs that oracle, but Invariant 1 (NO RUNTIME) forecloses shipping a checker to produce it.

## Decision

Conformance is evidenced by a **golden corpus** of positive (must-compile) and negative (must-be-rejected) fixtures spanning the three recurring domains — auth-refresh, checkout, payment-5xx — with each positive domain fixture shipping the complete `spec → obligations → task → trace → verdict → promotion` pipeline chain, and each domain carrying its canonical defect class encoded with `SOL-<LAYER>NNN` codes. The corpus is **inert data — the oracle, not a running checker**: each fixture's expected verdict is pinned in its metadata header and is known independent of any tool. A conformant tool is *checked against* the corpus; until a launcher exists, a human validates a repository against it by hand. The full specification — pipeline chain, per-domain defect classes, task-file negative classes, the labeled prose precision/recall baseline, the pass-output rubrics, and the contamination-hygiene held-out/mutated variants — is detailed in the conformance reference ([`docs/model/conformance.md`](../model/conformance.md)). The corpus ships under `starter-kit/.agents/conformance/fixtures/`; the three pipeline-complete walkthroughs also ship under `docs/examples/` for human readers.

## Alternatives considered

| Alternative | Why rejected |
| --- | --- |
| Ship the conformance contract (§32) alone, no fixtures | A contract states rules but pins no verdicts; nothing validates a checker or a reviewer, and the contract's own claims go undemonstrated (§33.1). |
| Positive (must-compile) fixtures only | Cannot catch the core failure mode — a schema-valid artifact that is wrong (Invariant 4). Compiler-conformance practice requires disallowed productions whose rejection is known (§33.1). |
| Ship a checker to generate verdicts | Violates Invariant 1 (NO RUNTIME). Swarm ships the contract and its oracle, never the checker (§32.7); the corpus pins verdicts as data instead. |
| Canonical fixtures only, no held-out/mutated variants | Public fixtures invite contamination: an agent-as-compiler reproduces the *labels* without performing the *passes*. The corpus MUST ship a semantically-equivalent mutated twin as the conformance gate (§33.7.1). |
| Grade passes with a Likert/quality score | Quality scores are not decidable against the artifact alone. The pass-output rubrics are checkable boolean predicates — a single failing predicate fails the pass (§33.6). |

## Consequences

### Positive

- Gives Swarm a tool-independent oracle: expected verdicts are pinned as data, so a future checker has a regression suite and a human has something concrete to validate against.
- The negative fixtures defend Invariant 4 directly — every error-code family gets a guarding fixture, and the canonical "tests passed" hole is a first-class FAIL fixture (§33.4).
- The held-out mutated variants make label-memorization detectable, so a passing verdict evidences a correctly executed pass rather than a recognized string (§33.7.1).

### Negative

- The corpus is a second representation of the language's rules alongside the §32 contract; the two must stay consistent (the fixtures themselves are the guard — a contract change that breaks a fixture is caught).
- Curating positive *and* negative *and* mutated variants across three full pipeline chains is substantial authoring cost, and the prose precision/recall baseline demands inter-annotator-agreement discipline (§33.5).
- The corpus is inert until a checker or eval harness exists; in the meantime it is validated by hand (NO RUNTIME).

### Neutral / tradeoffs

- The §33.5 precision/recall figures (≥0.90 / ≥0.85) are stated as v0.1 **design targets** for the curated gold set — chosen acceptance bars, not measurements — and the spec records the lower field ceiling for honest calibration (§0.7, §33.5).
- The pass-output rubrics grade *compiler behaviour* (obligation/binding/scope/verdict preservation), not grammar; grammar is already covered by the `SOL-S` family and §33.4 (§33.6).

## Status

Accepted (v0.1).

## Affected obligations / constraints

- Adds: the golden-corpus obligation — a conformant repository MUST ship positive + negative fixtures across the three domains, each positive fixture carrying the full pipeline chain with verdicts pinned as data (§33.1–§33.3).
- Adds: the held-out mutated-variant obligation — each canonical domain fixture MUST ship at least one semantically-equivalent regenerated twin as the conformance gate (§33.7.1).
- Modifies: the conformance contract of ADR 0026 / §32 — the contract is now evidenced by a shipped fixture oracle, not by prose alone.
