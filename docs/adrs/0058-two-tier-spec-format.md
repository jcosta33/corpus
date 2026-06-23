---
type: adr
id: adr-0058
status: accepted
created: 2026-06-11
updated: 2026-06-11
---

# ADR-0058 — Two-tier spec format, one data model

## Context

Requirement clarity is the best-evidenced lever Corpus has: ambiguous or incomplete task input measurably
degrades agent code correctness [[ORCHID]](../research/sources.md#ORCHID)
[[HUMANEVALCOMM]](../research/sources.md#HUMANEVALCOMM), models usually generate anyway rather than ask
[[HUMANEVALCOMM]](../research/sources.md#HUMANEVALCOMM) [[HILBENCH]](../research/sources.md#HILBENCH), and
repairing the requirement *text* recovers correctness with cross-model transfer
[[SPECFIX]](../research/sources.md#SPECFIX) [[CLARIFYGPT]](../research/sources.md#CLARIFYGPT). At the same
time the adopter audit found the notation-as-language presentation (versioned grammar, closed sets,
mandatory infix) to be adoption friction with no enforcing tool. EARS-shaped controlled requirements have
industry precedent [[KIRO]](../research/sources.md#KIRO).

## Decision

1. **Default spec form = plain structured markdown.** Frontmatter `type: spec, id, title, status, owner,
   sources[]`; sections Intent / Non-goals / Requirements / Open questions / Affected areas / Dropped from
   sources (optional, recommended). Each requirement is a `### AC-NNN — <name>` heading with a one-sentence
   behavior ("When X, the component must Y.") and a `Verify with:` line. The `Verify with:` line is the
   highest-value line in the template ([[ORACLESWE]](../research/sources.md#ORACLESWE) —
   a runnable check outperforms prose plans as task input (preliminary evidence)); requirements are ordered by importance
   (instruction-following shows primacy bias and silent omission under density
   [[IFSCALE]](../research/sources.md#IFSCALE) — preliminary).
2. **SOL is the optional stricter surface,** selected per file by frontmatter `format: sol`. SOL is a
   *notation* (EARS-shaped blocks: `REQ AC-001:` / `WHEN` / `THE <actor> MUST <response>` / `VERIFY BY`),
   not a language: it carries no version number, and the fields `swarm_language`, `aps_version`,
   `spec_version` do not exist. The full notation reference lives at `docs/reference/structured-requirements.md`.
3. **One form-agnostic requirement record** underlies both surfaces:
   `{ id, strength, statement, verify_refs[], kind, edges[] }` plus spec-level
   `{ intent, non_goals[], open_questions[], affected_areas[], sources[] }`. Shared ID namespace
   (`### AC-NNN` ≡ `REQ AC-NNN:`; cross-file form `SPEC-x#AC-NNN`); shared strength words (must / must not /
   should / may — SOL's uppercase modals are the same enum, stricter surface); one verification field with
   two precisions (`Verify with: <ref>` = unresolved note that reviews as **Unverified** when the target
   does not exist; SOL `VERIFY BY <type>:<adapter>:<artifact>` = resolved binding). Review consumes only
   `{id, verify_ref, result}` — identical over both forms. Checks key on the record, never on the surface
   (anti-fork rule; equivalence fixture pairs in `conformance/` prove it).
4. **Writing rules** (formerly a standalone prose standard) become a short advisory practice: observable
   verbs, a vague-word watchlist, one behavior per requirement, lift uncertainty into Open questions.
   Advisory over both forms; the full catalogue lives in `docs/reference/checks.md`.

## Alternatives considered

| Alternative | Why weaker |
|---|---|
| SOL-only (status quo) | Adoption friction with no enforcement; the evidence requires clarity, not a particular syntax |
| Plain-markdown only, drop SOL | Discards a working stricter surface praised in real adoption (O-002) and the parser target swarm-cli already builds against |
| Two independent formats | Forks the checks/review machinery; the single record + anti-fork fixtures prevent divergence |

## Consequences

Positive: a spec readable with zero training; SOL preserved for high-risk work and tooling. Negative: the
record mapping must be maintained (one normative section, everything else links). Neutral: `format: sol`
is the entire selector mechanism.

## Status

Accepted. Supersedes the spec-file clauses of ADR-0041 and ADR-0015; partially supersedes ADR-0027 and
ADR-0028 (the obligation/prose layers survive as reference-tier notation and writing rules).

## Propagation

Templates, docs/04, reference (structured-requirements, checks, artifact-formats), conformance fixtures
(equivalence pairs), evals, swarm-cli.
