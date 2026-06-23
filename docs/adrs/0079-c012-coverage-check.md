---
type: adr
id: adr-0079
status: accepted
created: 2026-06-15
updated: 2026-06-15
---

# ADR-0079 — C012 (coverage): mint the deterministic review-coverage check

## Context

ADR-0077 (Decision 7) names **deterministic coverage** — does every requirement the work claims to
be in scope actually appear in the review — as _the_ mechanically defensible wedge for corpus-cli:
unlike judging whether evidence is adequate (human work), reconciling an id set is exact. The
checks contract (`checks.yaml` / `reference/checks.md`) had no such check: C001–C009 key on the
spec, C010–C011 on the change plan, and the review-packet `content_rules` cover evidence presence
(`pass-needs-evidence`), the no-open-critical gate, and trigger routing — but nothing reconciles the
**coverage table against its source spec's requirement ids**.

The `corpus review` M2 spec (SPEC-corpus-cli-m2-review, AC-019/022) needs this reconcile, and the
honesty framework (ADR-0063) forbids corpus-cli claiming a check that has no contract. The capability
the superseded `008-trace` spec described — binding each requirement to its verification — folds into
review as exactly this: coverage rows reconciled against the spec. So the wedge needs a real,
named, levelled contract entry before the tool can run it.

## Decision

**Mint a new core check, `C012` (`coverage`), keyed on the review packet, at `warning` severity.**

C012 has two faces, both at the same severity:

- **uncovered** — an in-scope requirement id from the source spec has no coverage row in the review
  packet (the dominant signal: "this requirement was not reviewed yet").
- **orphan** — a coverage row names an id absent from the source spec (a stale or mistyped id).

Coverage keys on the **task packet's declared `scope`** as the in-scope id set; when `scope`
disagrees with the spec's id set, the divergence is itself a surfaced fact (not silently resolved).

**Scope-guarded to non-draft source specs.** A review whose source spec is still `draft` is exempt —
its requirement ids are work-in-progress, not finalized claims. This mirrors C002's draft exemption
(ADR-0078) and C007's `ready`-only gate: coverage is required only once the spec it reconciles
against is a committed contract.

**Severity is `warning`, deliberately.** A coverage gap is review _completeness_, not artifact
_corruption_ (the C001/C003 integrity checks are hard-errors because a malformed spec is objectively
broken; an incomplete or mid-flight review is not). A requirement may be legitimately deferred or
waived, so a hard-error would false-block. Per ADR-0077's "build minimally, tighten with evidence"
ethos, a never-field-tested check ships conservative: `warning`, which teams may treat as blocking
by their own CI policy (the standing warning rule), and which a future ADR may promote to
hard-error with evidence (a recorded reversal, as ADR-0078 narrowed C002's scope). Hard-error was
considered and rejected for now on exactly this ground.

**The same check serves two commands at their own exit posture.** `corpus check` may run C012 on
review files at its severity (warning → exit 1); `corpus review` surfaces C012 as one reconcile fact
under its advisory posture (all reconcile findings → exit 1, SPEC-corpus-cli-m2-review AC-024).
Neither issues a verdict — C012 surfaces the coverage facts; the human owns the result (ADR-0077
Decision 8 is unchanged).

## Consequences

- `checks.yaml` gains a `C012, name: coverage, severity: warning` core-check row plus a `review_file`
  `content_rule` stating the rule and its non-draft scope guard; its `version:` bumps `0.4.1 → 0.5.0`
  (a rule change). `reference/checks.md` gains the C012 definition and table row. The closed-set
  counts in `checks/README.md` and the cheatsheet appendix move accordingly (the only two places
  counts live).
- **Coordinated cross-repo change (the drift guard).** corpus-cli's `checksContract.ts` pins the
  contract `version:` and reconciles its `CORE_CHECKS` table against the sibling `checks.yaml`; its
  drift-guard test fails the moment the versions diverge. So the `checks.yaml`/`checks.md` edit, the
  `CONTRACT_VERSION` bump, and C012's implementation in corpus-cli **land together** as the M2 build —
  not as a standalone canon commit that would red corpus-cli's gate in between. This ADR records the
  decision; the contract edit ships with the implementation.
- C012 unblocks flipping SPEC-corpus-cli-m2-review from `draft` to `ready`.
- This does not resolve the separate, open "globally-unique vs spec-scoped requirement ids" question
  (ADR-0078) — C012 reconciles a review's coverage against one named source spec, independent of
  that choice.
