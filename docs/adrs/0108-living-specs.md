---
type: adr
id: adr-0108
status: accepted
created: 2026-06-25
updated: 2026-06-25
---

# ADR-0108 — Living specs: an Active container with per-requirement supersession, kept lightweight

## Context

A spec must stay useful and current over years without spawning new documents per change (the
owner's "living organism" requirement). Two evidence passes (RESEARCH-living-specs, corpus-works) ground
the choice:

- **R1 (standards/process):** the field *majority* **supersedes** (IETF, PEP `Final`, ADR append-only
  log); amend-in-place is the *minority* **`Active`** pattern (PEP 1, "never-completed" docs). The
  cautionary tale: elaborate maturity ladders + mandated periodic review **fail** — IETF RFC 6410
  collapsed tiers and dropped the review cadence. MADR has **no** first-class "amends" to borrow.
- **R2 (empirical):** staleness is the dominant, **silent** failure (28.9% of top-1000 repos carry an
  outdated reference; docs co-evolve with code only 13–20% of the time — Tan EMSE 2024, Wen ICPC 2019);
  **bloat + duplication are measured top concerns** (superfluous 55%, duplicate 46% — Aghajani ICSE
  2020). The cadence that works is **review-on-touch** (a doc touch triples reviewer attention; a
  comment on a doc change → update 76.4% of the time — Rao 2022), and silent staleness is caught by a
  **mechanical reference-snapshot diff** (Tan/DOCER). The "minimal docs co-evolve better" claim was
  **refuted** — leanness rests on the bloat-failure data, not a proven sync benefit.

Owner decision: the **hybrid**, kept lightweight.

## Decision

1. **A spec is a two-layer living document. One feature = one spec, forever.** The **container is
   `Active`** — amended in place over years, never re-created for the same feature (ADR-0103's living
   form). **Individual requirements carry status + supersession** (ISO/IEC/IEEE 29148: each AC keeps
   its stable id; an AC is marked superseded/removed *in place* with a pointer, never silently
   dropped). **Amend for evolution; supersede only for whole-feature replacement.** _Level: convention._

2. **A small status set, append-only history.** Spec status: `draft → ready → active` (amended in
   place) `→ superseded` (whole-feature replacement only, with `superseded_by: SPEC-…`). No tier
   ladder (R1: the IETF ladder failed). _Level: convention._

3. **Cadence = review-on-touch, not scheduled audits.** When a change touches a spec's referenced
   code/area, the spec is amended in the **same change** (R2-backed). **No mandated periodic review**
   (R1: IETF dropped it; R2: change-triggered wins). _Level: convention._

4. **Detect staleness mechanically — it is silent.** The keep-clean tooling (ADR-0106) diffs a spec's
   references/ACs against the **last-spec-update snapshot vs the current revision** (Tan/DOCER
   mechanism); advisory until measured (DOCER has false positives). This **ungates ADR-0106's
   spec-side freshness/supersede checks.** _Level: toolable when shipped (ADR-0063)._

5. **Audit trail = git history + the spec's append-only `## Execution`** (ADR-0103), one entry per
   change-cycle. **No heavy per-requirement changelog** — the evidence does not mandate it; keep it
   lightweight (R1 open Q4). _Level: convention._

## Consequences

- The spec becomes the owner's living organism — evidence-grounded, and deliberately **lightweight**
  (small status set, append-only, review-on-touch) to avoid the IETF over-engineering failure.
- **Anti-bloat is justified by the failure data** (bloat/duplication are measured top failures), **not**
  by the refuted "minimal-docs-co-evolve" claim. Prune superfluous/duplicate from the durable spec.
- **Refines ADR-0103** (adds the status/supersede lifecycle + cadence + staleness mechanism to the
  Active container), **extends ADR-0058** (an additive per-requirement status marker) and **ADR-0096**
  (spec status reaches `active`/`superseded`). **Ungates ADR-0106's spec-side checks.**
- **Honest residuals (decided under uncertainty):** no study directly compares named-owner / fixed
  cadence vs review-on-touch; no longitudinal proof mechanical detection cuts time-to-fix; transfer of
  code-comment findings to higher-level markdown specs is untested beyond READMEs/wikis. Recorded;
  revisit if a future measurement contradicts.
- **Implementation deferred** (later plan): the spec template's status values + per-requirement marker;
  the docs (drift rule, lifecycle); the snapshot-diff check ships via ADR-0106's tooling.

## Affected obligations / constraints

- **Refines:** [ADR-0103](./0103-spec-as-living-form-task-on-demand.md) (living form). **Extends:**
  [ADR-0058](./0058-two-tier-spec-format.md) (per-requirement status marker, additive),
  [ADR-0096](./0096-artifact-lifecycle.md) (spec status lifecycle). **Ungates:**
  [ADR-0106](./0106-keep-clean-tooling.md) spec-side checks. **Grounded by:** RESEARCH-living-specs
  (R1 standards + R2 empirical).
- **Does NOT change:** the frozen contract sections' freeze-at-`ready` (the Active container amends via
  the same review-on-touch gate), the verdict model, or the checks contract (no `checks.yaml` rule here).
