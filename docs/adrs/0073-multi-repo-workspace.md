---
type: adr
id: adr-0073
status: accepted
created: 2026-06-12
updated: 2026-06-12
---

# ADR-0073 — The multi-repo workspace, named and finished

## Context

A dedicated workspace repo governing several code repos has been recorded since ADR-0050
("multi-repo via namespaced IDs"), ADR-0060 ("one spec store can govern many code repos"),
and ADR-0062 (the code-repo adapter) — and the DX-format wave (ADR-0072) incidentally built
its working mechanics: per-context Commands sub-tables, the context carve-out, the run-summary
custody relay, the session-maintained board. But the docs presented the shape under an orphan
label ("External") in two paragraphs, three of its conventions were unstated, and the owner's
direction is explicit: the scaffolding must work as well for a central orchestration repo
(the Corpus family: canon / starter-kit / skills / cli / website; the general case: features
spanning frontend + backend repos) as for the co-located default. A two-lens challenge round
(architect · canon-coherence) shaped the result; SPEC-multi-repo-workspace carries the
requirements.

## Decision

1. **One name.** The placement keeps the product's existing term — a **dedicated workspace
   repo** — and its governs-several-code-repos use is named the **multi-repo workspace**: the
   same kit installed in its own repo, governing several code repos. The "External" label is
   retired; no hub/spoke vocabulary anywhere (the metaphor minted synonyms for things the
   product already names). The glossary defines the new term and maps ADR-0062's internal
   "code-repo adapter" to its everyday noun — the term is not promoted to user tier.
2. **The placement decision rule, both arms.** Co-located while features live in one repo and
   the same people shape specs and merge code; the multi-repo workspace when features
   routinely span repos — a spec inside repo A is invisible to repo B's developers and drifts
   unowned — or when the people shaping specs are not the people merging code (the recorded
   ADR-0050 trigger). The drift-cost candor of ADR-0060 Decision 3 stays adjacent.
3. **The context carve-out covers repos, gated by independent verifiability.** The
   one-requirement-N-tasks carve-out (ADR-0072's platform case) generalizes to _context_ —
   platform or repo — with the entry condition stated wherever the carve-out is: the repo case
   applies only when the requirement is independently verifiable in each repo (the
   contract-test shape). A behavior that exists only when both repos meet decomposes into
   per-repo requirements; the carve-out never covers a requirement no single task verifies.
4. **Affected areas may carry a context prefix.** An entry may be prefixed with exactly a
   Commands sub-heading's context name (`### Commands (web)` → `web: src/checkout/…`),
   binding the entry to that sub-table for slot resolution. A task names at most one context —
   mixed prefixes are the signal to split. The prefix is task-body content owned by the
   workspace, outside the placeholder namespaces; checks.yaml notes in a comment that matchers
   compare the path part (a comment — the contract is untouched, the ADR-0072(e) precedent).
   The SOL adapter-resolution sentence gains the sub-table clause.
5. **Future CLI: composition, not a mode.** Several code repos each pointing their
   `.corpus/config.yaml` at the same workspace _is_ the multi-repo workspace under the
   contracts as written; workspace-side orchestration across governed repos is outside the
   current command contracts and waits for its own ADR.
6. **Install guidance for repo families.** The full workspace exists once (the multi-repo
   workspace); code repos carry the existing three-line footprint and nothing else;
   derived-content repos (a published kit, a skills collection) carry no install — their
   intent lives upstream.

## Alternatives considered

- **"Hub-and-spoke" as the pattern name** — challenge-round kill: six lexemes for one shape,
  against ADR-0057's vocabulary tiers; the descriptive name does the work.
- **A third kit "destination"** — the governs-several case uses the dedicated-repo copy line
  byte-identically; a third bullet would fork the two-placement model (ADR-0060 D3).
- **Promoting "code-repo adapter" to user tier** — inverts the tier mechanism and brands a
  footprint whose strongest property is being nothing; glossary mapping instead.
- **A "hub mode" entry in future-cli** — a promise with no contract under it (ADR-0063);
  stated as composition of the shipped per-repo contracts instead.

## Consequences

Accepted. Refines ADR-0050, ADR-0060 (Decision 3's placement framing — the "external" label
retires in favor of the product's standing "dedicated workspace repo" + the new shape name),
ADR-0062 (term stays reference-tier, now glossary-mapped), ADR-0072 (Decision 4's sub-table
resolution gains its Affected-areas binding; the platform carve-out generalizes with an entry
condition). The Corpus family's own multi-repo workspace is a separate owner action.

## Propagation

docs/03/06/07, reference/{glossary, step-bars, advanced-lifecycle, future-cli,
structured-requirements}, task template comment, kit README, split-work guide, checks.yaml
comment, ledger row.
