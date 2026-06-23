---
type: adr
id: adr-0087
status: accepted
created: 2026-06-20
updated: 2026-06-20
---

# ADR-0087 — Mint C015 `citation-resolves`: the inline `[[KEY]]` anchor check (toolable, fact-not-verdict, measured before shipping)

## Context

"Citations are contextual" is a load-bearing project rule (CLAUDE.md): every load-bearing empirical claim
cites a verified entry via the `[[KEY]]` form, linking the matching `<a id="KEY">` anchor in
`docs/research/sources.md`. The 2026-06 adversarial audit (corpus-hq #29) found this rule had **no
checker**: `corpus check` validates a spec's frontmatter `sources:` paths (C009), but not its inline
`[[KEY]]` citations. A real dangling citation — `[[FAROS2025]]` in `SPEC-review-gate-benchmark`, an
anchor that does not exist in `sources.md` — passed `corpus check` clean and shipped. The rule's
discipline was unenforced.

The owner decided (post-remediation, after the review-gate benchmark was built) to **mint a check** for
it, rather than a CI-only lint, sequenced so its precision is measured before it ships — the
measure-first gate ADR-0086 Decision 3 committed to, and the C014/ADR-0086 mint precedent.

## Decision

1. **Mint `C015 citation-resolves` (warning, toolable).** A spec's inline `[[KEY]]` citation that does not
   resolve to an `<a id="KEY">` anchor in the workspace's `sources.md` is surfaced as a C015 warning.
   _Level: toolable (ADR-0063) — `corpus check` flags it. Never enforced (no merge block) until a wired
   gate exists._ It **surfaces a fact** (a dangling citation), never a verdict (ADR-0077 Decision 8):
   warning, not hard-error, because the human owns whether the citation is wrong or the anchor is owed.

2. **Pure check, injected resolver — mirrors C009.** `check_citation_anchors(spec, anchor_resolves)` is
   pure over the parsed record; the command supplies `anchor_resolves: (key) => boolean`, built by
   reading the `sources.md` the spec's frontmatter `sources:` names, extracting its `<a id="…">`
   anchors. The parser marks `[[KEY]]` citations distinctly from markdown `](path)` links.

3. **Skip when there is nothing to check against.** If the spec names no resolvable `sources.md`, C015
   does not fire (the resolver admits every key) — so a spec that cites nothing, or whose sources.md
   cannot be located, is never false-flagged. C015 fires only when a sources.md is resolvable **and** a
   `[[KEY]]` has no matching anchor. This bounds the effective-false-positive surface to genuine dangles.

4. **Scope v0 to the dangling-anchor case only.** A `[[KEY]]` with no `<a id="KEY">` is the whole v0.
   **Deferred to a separate v1 decision:** the tier checks (a MUST-level claim citing a _Caveated_ or
   _Rejected_ entry) — they need the tier metadata parsed out of `sources.md` and a notion of
   "MUST-level claim," a larger surface that earns its own ADR.

5. **Measured before shipping (the gate).** C015's precision is measured before it counts as shipped:
   run it over the real corpus-hq specs (all citations valid after the #29 remediation) — it must produce
   **zero** C015 warnings (0% effective-FP on real clean specs) — and over a seeded fixture with a
   dangling `[[KEY]]` — it must fire (recall). This is the v0 measurement; folding citation cases into
   the `corpus-bench` corpus is the richer follow-up.

6. **Single-sourced like every contract change (the two-repo rule).** `checks.yaml` gains the C015 row +
   a `version` bump (0.7.0 → 0.8.0); `checksContract.ts` mirrors it (CONTRACT_VERSION + CheckId +
   SEVERITY_BY_ID + CORE_CHECKS), guarded by the drift test; `docs/reference/checks.md` +
   `cheatsheet.md` carry the C015 row; `checks/fixtures/` gains the oracle case; the kit's
   `advanced/checks-reference.md` gains the C015 row. The contract data + the corpus-cli implementation
   land in lockstep (the ADR-0079/0083/0086 coordinated-landing pattern, so the drift-guard never reds).

## Alternatives considered

| Alternative                                                                  | Why weaker                                                                                                                                                                                                                                               |
| ---------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **CI-lint only** (a grep, no contract mint)                                  | Catches the dangle but lives outside the C0xx contract — adopters' `corpus check` would not surface it, and it would not appear in the kit's catalogue. The owner chose the contract mint for parity with the other citation/structure rules.            |
| **Hard-error severity**                                                      | A dangling citation is a fact for a human to resolve (a typo'd key vs an owed anchor), not a corruption — warning matches the `outsideScope`/C012/C013/C014 fact-class. Promotable later with a recorded path, the ADR-0079/0083 conservative precedent. |
| **Validate the tier too in v0** (MUST-level claim ↔ Caveated/Rejected entry) | Needs `sources.md` tier parsing + a MUST-claim model — a much larger, fuzzier surface. Defer to v1 so the dangling-anchor case ships measured and clean.                                                                                                 |
| **Global sources.md config**                                                 | A `.corpus/config.yaml` `sources_path` would add config surface for a v0; reading the path from the spec's own frontmatter `sources:` is self-contained and matches how the dangling case actually arose.                                                |

## Consequences

Accepted: C015 ships measured (0% FP on real specs, fires on the fixture) and bumps the contract to
0.8.0 across the two-repo set. The citation discipline is now toolable, not just a convention. Nothing
is _enforced_ (a dangling citation never blocks a merge) until a gate wires `corpus check` to CI
(corpus-hq #13/#10). Honors ADR-0077 D8 (a fact, never a verdict), ADR-0063 (toolable, never enforced),
and the single-sourcing rule. Refines ADR-0086 (closes the citation-validation gap it surfaced as #29).

## Propagation

`checks/checks.yaml` (C015 row + version 0.8.0) · `corpus-cli` (`parseSpecRecord` citation marking,
`check_citation_anchors`, `checksContract` mirror + version, the command's `anchor_resolves` builder,
tests) · `docs/reference/checks.md` + `cheatsheet.md` (C015 row + severity split) · `checks/fixtures/`
(a dangling-citation oracle) · `../corpus-starter-kit/advanced/checks-reference.md` (C015 row) ·
`docs/adrs/README.md` (the index row). The corpus-cli code + the `checks.yaml` data land in one
coordinated change so the drift-guard stays green.
