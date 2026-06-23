---
type: adr
id: 0047-skills-are-self-contained
status: accepted
created: 2026-06-06
updated: 2026-06-06
supersedes:
superseded_by:
---

# ADR-0047: Skills are self-contained; citations are provenance, not a required read

## Context

ADR-0016 made skills **cite-don't-define**: a skill carries procedure and _cites_ the authoritative
semantics (the `passes/` + `language/` references) rather than restating them. That kept skills thin and
single-homed the semantics — but it assumed the agent **follows the citation** to load the authority when
it matters. Building the first real adopter (`corpus-cli`) surfaced that this assumption is unsound for an
LLM agent:

- The official Agent Skills design makes following a reference **the model's discretion** — bundled
  references load "as needed," and "files never referenced in a session never load at all." A skill that
  is only _correct_ when the agent follows a pointer is betting on an optional step.
- Corpus already carried the evidence against deep references: chained references "get partial-read and
  silently dropped" [[SKILLBP]](../research/sources.md#SKILLBP), which is why the body-shape rule was
  "one hop." The logical conclusion is **zero required hops**.
- Non-salient / out-of-context material is underused (lost-in-the-middle, multi-turn decay
  [[LOSTMID]](../research/sources.md#LOSTMID)), and agents default to parametric priors over provided
  context — so an agent handed a thin skill that _cites_ "the verdict model" acts on its prior notion of
  it, often subtly wrong.

Empirically, inspecting the kernel skills confirmed they were **already operationally self-contained**
(the merge-gate predicate, verdict grammar, lint codes, etc. are stated inline); the `././passes/` /
`././language/` links were already pure provenance. They were not load-bearing reads — they were the
_only_ reason the kernel had to ship `passes/` + `language/` at all (to keep those links from dangling).

## Decision

1. **A skill MUST be sufficient for the agent to perform its task correctly from the loaded skill body
   plus the operative references the pass actually needs.** The pass _procedure_ is inline (within the
   skill + its one-hop bundled `references/`); the _shared closed-set facts_ that several passes lean on
   (the SOL grammar, the proof/verdict/adequacy rules, the IR/edge schema) live in the compact, shipped
   `reference/` cards a skill names. The agent's correctness MUST NOT depend on following a citation to an
   *un*shipped manual — but loading an operative card the running pass requires is reliable (it is needed
   to act, not skippable rationale). See [0048](./0048-installed-payload-is-the-runtime-surface.md)'s
   Update for where this boundary settled.
2. **Citations are provenance, not a required read.** A skill names its authoritative source (e.g. "the
   `review` pass", "the SOL error catalogue") for a human and for drift-tracking — it does not link a
   file the agent must open, and it does not link a file outside the shipped surface.
3. **Single-sourced to prevent drift** (the ADR-0016 concern preserved): a skill's inlined rules are
   derived from the canonical spec (`docs/`) and eyeball-diffed on change — the same discipline ADR-0044
   uses for the docs↔kernel twins. Self-contained _for the agent_; single-sourced _for integrity_; named
   _for the human_.

This **refines ADR-0016**: "cite-don't-define" becomes "**inline-what's-needed, define-once-upstream,
cite-by-name-for-provenance**." A skill still owns no semantics (it does not _redefine_ them); it now
_carries_ the operational form rather than pointing at it.

## Alternatives considered

| Alternative                                          | Why rejected                                                                                                                                                                                                                                                   |
| ---------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Keep cite-don't-define (skills cite local `passes/`) | The cited hop is not reliably followed; the agent acts on a thin skill + its prior, not the cited authority.                                                                                                                                                   |
| Ship a compact normative _card_ the skills cite      | Adopted for the **shared** facts (see [0048](./0048-installed-payload-is-the-runtime-surface.md)'s Update): an operative card the running pass needs is a _reliable_ hop, unlike a skipped rationale citation. Per-pass _procedure_ still inlines, not carded. |
| Let each skill define semantics freely               | Drift: copies diverge from the spec. Single-sourcing (decision 3) is what makes inlining safe.                                                                                                                                                                 |

## Consequences

- **Positive:** skills work without the agent chasing references; the kernel no longer needs to ship
  `passes/` + `language/` for the skills to resolve (see [0048](./0048-installed-payload-is-the-runtime-surface.md)).
- **Negative:** skills carry more content (the operational rules, not just a pointer), and the rules are
  duplicated from the spec — managed by single-sourcing + eyeball-diff (decision 3), the same cost the
  docs↔kernel twins already pay.
- **Neutral:** no closed-set or grammar change; the skill-as-SOFT-control rule (a skill owns no semantics)
  is unchanged — it now _delivers_ the rule inline instead of citing it.

## Status

Accepted (v0.1). The de-link of the 34 kernel skills (+ templates, memory, conformance) is done; the
citations are name-only provenance.

## Affected obligations / constraints

- Refines: [0016](./0016-skills-are-self-contained.md) (cite-don't-define → inline-and-single-source),
  [0042](./0042-skill-carrier-and-standalone-conditioning.md).
- Enables: [0048](./0048-installed-payload-is-the-runtime-surface.md).
- Does NOT change: any closed set, the obligation grammar, or the skill-owns-no-semantics invariant.

> **Ledger note (2026-06-11):** refined by ADR-0064.
