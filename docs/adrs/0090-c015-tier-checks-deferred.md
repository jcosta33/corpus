---
type: adr
id: adr-0090
status: accepted
created: 2026-06-20
updated: 2026-06-20
---

# ADR-0090 — C015 tier-checks stay deferred: no high-precision form exists pre-measurement; the Rejected case is already covered by an invariant

## Context

ADR-0087 minted `C015 citation-resolves` (v0: a `[[KEY]]` that resolves to no `<a id="KEY">` anchor in
`sources.md` is surfaced) and **deferred the tier checks to a separate v1 decision** — a `[[KEY]]`
citing a _Caveated_ or _Rejected_ entry, where the discipline is "Caveated entries MUST NOT carry a
`MUST`-level claim; Rejected entries MUST NOT be cited at all." This ADR makes that v1 decision after
investigating the implementation surface.

The investigation found that neither deferred case has a clean, high-precision implementation today:

- **The Rejected case is already covered.** The `## Rejected — DO NOT CITE` tier is a prose table; its
  entries carry **no `<a id>` anchors** (verified: zero anchors under the Rejected heading). So a
  `[[KEY]]` citing a rejected claim **already dangles** and is **already surfaced by C015 v0** — just
  with a generic "resolves to no anchor" message. There is no new _detection_ to add, only a cosmetic
  message tweak, which does not earn a contract change.
- **The Caveated case is fuzzy.** A Caveated entry _has_ an anchor, so it passes v0. Flagging "a
  `MUST`-level claim cites a Caveated entry" requires a **`MUST`-claim detector** — a natural-language
  classification over the sentence around each citation. That is precisely the low-precision surface the
  effective-false-positive discipline (≤10% effective FP, [[GOOGLESA]](../research/sources.md#GOOGLESA))
  says not to ship unmeasured; an over-firing tier check gets `--no-verify`'d like any other.

## Decision

1. **Do not build C015 tier-checks now; keep C015 at v0 (dangling-anchor only).** _Level: convention /
   decision (ADR-0063) — no check minted, no `checks.yaml` row, no contract-version bump._ Honors
   ADR-0077 Decision 8 (don't ship a noisy fact) and the measure-first gate
   ([0086](./0086-deterministic-review-scanning-decision.md) Decision 3): a check ships only once its
   precision is measured.

2. **Cover the Rejected case with an invariant, not a check.** Record that **a Rejected entry MUST NOT
   carry an `<a id>` anchor** — which is already true. Because rejected entries are anchor-less by
   construction, any `[[KEY]]` citing one dangles and C015 v0 surfaces it. This is a high-precision
   safeguard with zero new code; the invariant is noted in `sources.md` so it stays true (a future
   editor who anchors a rejected entry would silently defeat the check).

3. **The trigger to revisit the Caveated case.** Fold citation cases into the `corpus-bench` corpus and
   **measure** a candidate `MUST`-detector's effective-FP before minting anything. Only a _structural_,
   high-precision signal earns a check — e.g. a controlled RFC-2119 `MUST` marker adjacent to a
   `[[KEY]]` whose anchor sits under the Caveated tier — and only after the benchmark shows it clears
   the ≤10% bar. Until then, the Caveated-MUST discipline stays a **review checklist** item, not a tool.

## Alternatives considered

| Alternative                                            | Why weaker                                                                                                                                                                                           |
| ------------------------------------------------------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Build the Caveated-`MUST` detector now**             | Needs fuzzy NL `MUST`-claim detection; likely exceeds the ≤10% effective-FP bar [[GOOGLESA]](../research/sources.md#GOOGLESA); violates the measure-first gate. Ship it and it gets `--no-verify`'d. |
| **Add a Rejected-citation _message_ variant to C015**  | The Rejected case is already surfaced by v0 (anchor-less → dangles); a sharper message needs the resolver to parse the Rejected table for tiers — real complexity for a cosmetic gain.               |
| **Mint a new check id (C016)**                         | Premature — there is no new high-precision _fact_ to mint. The Rejected case is covered; the Caveated case is unmeasured.                                                                            |
| **Promote the discipline to a hard rule with no tool** | The honesty framework forbids enforcement-sounding claims without a level; the Caveated-`MUST` rule stays an explicit _checklist_ item until a measured check exists.                                |

## Consequences

C015 stays v0 (dangling-anchor only). The Rejected-citation case is covered for free by the anchor-less
invariant — now documented in `sources.md` so it does not silently rot. The Caveated-`MUST` case defers
to a measured future ADR, remaining a review-checklist item meanwhile. No contract change, no version
bump, no new check. Refines ADR-0087 Decision 4 (resolves the deferred v1 question) and honors ADR-0063
(no enforcement without a level) + ADR-0086 Decision 3 (measure before shipping a check).

## Propagation

`docs/adrs/0090-c015-tier-checks-deferred.md` (this record) · `docs/adrs/README.md` (index row) ·
`docs/research/sources.md` (the "Rejected entries carry no `<a id>` anchor" invariant note in the
Rejected section). No corpus-cli / `checks.yaml` change. Refines
[0087](./0087-citation-anchor-check.md) Decision 4.
