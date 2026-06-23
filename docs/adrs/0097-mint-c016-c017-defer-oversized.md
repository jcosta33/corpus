---
type: adr
id: adr-0097
status: accepted
created: 2026-06-22
updated: 2026-06-22
---

# ADR-0097 — Mint C016 (pass-needs-evidence) + C017 (orphaned-reference); the oversized-packet band is specified-not-shipped (measured)

## Context

The goal-run backlog clearance (corpus-hq #61 §B) left three review/workspace checks _specified-not-shipped_
in their ADRs: the **pass-needs-evidence** gate gap (the verified B2 defect — `corpus check <review>`
never evaluated an empty-Evidence Pass cell, corpus-hq #50), the **orphaned-reference** skill check
(ADR-0096-adjacent, #45), and the **oversized-packet** heuristic (ADR-0094). The owner directed
building the deferred backlog with **measure-before-ship** ([ADR-0086](./0086-deterministic-review-scanning-decision.md)/[ADR-0087](./0087-citation-anchor-check.md):
0 false-positives on the real corpus + fires on a seeded fixture, ≤10% effective-FP per
[[GOOGLESA]](../research/sources.md#GOOGLESA)) deciding what mints.

This ADR records the measured outcome: two checks clear the bar and ship; the third does not and is
honestly deferred. Contract bumps **0.8.0 → 0.9.0**.

## Decision

### C016 `pass-needs-evidence` — minted, **hard error** (the gate path)

A review packet coverage row recorded **Pass** with an **empty Evidence cell** is a structural
contradiction (a Pass needs pasted output / a CI link / a named manual observation; an empty cell
reads Unverified). It implements the long-standing `pass-needs-evidence` review-packet content rule,
which `checks.yaml` already pinned `hard-error` but no shipped path honored — the verified B2 defect.

- The **gate** path (`corpus check <review>`) now emits it as **hard error → blocking (exit 2)**.
  Unlike the judgment-laden C012/C013 (warning), this is unambiguous and structural, so the gate the
  CI/pre-commit hook runs is the right place to enforce it.
- The **reconcile** path (`corpus review`) already surfaced the same row ids advisorily and keeps doing
  so — it never blocks ([ADR-0077](./0077-corpus-cli-reconcile-only-harness.md) Decision 8). One
  predicate (`pass_rows_missing_evidence`), two surfaces, so they can never disagree on what counts.
- The split (gate blocks, reconcile informs) is deliberate: the two commands serve different jobs.
- **Measured:** 0 empty-Evidence Pass rows across the real reviews (`checks/fixtures/*/review.md` +
  corpus-hq `reviews/`) — 0-FP on conformant reviews; fires on the seeded empty-evidence fixture.

### C017 `orphaned-reference` — minted, **warning** (the workspace path)

A bundled `.agents/skills/<name>/references/<file>` whose filename is named **nowhere** in its sibling
`SKILL.md` is dead weight no reader is pointed at — the failure the reference-load field test measured.

- **Orphan direction only** (a reference no one points at), never the inverse (a named-but-absent
  target — higher FP, a guide may name a repo file, not a bundled reference). Matching is **lenient**
  (the bare filename anywhere in the body counts as named), so a guide that does point at its
  references is never flagged.
- A workspace-scope warning (like C002), self-guarding (empty when there is no `.agents/skills/` dir).
- **Measured:** **6 bundled reference files** across the real `.agents/skills/` corpus the check
  walks (corpus-hq ×3, corpus-starter-kit ×2, corpus ×1; `task-template.md`, `research-methodology.md`,
  `evasions.md`) — **0 orphans**, under both the shipped lenient match and a stricter linked-context
  check. (An earlier sweep reported 88 by globbing `.worktrees/*/.claude/skills/` transient
  worktree copies the check never scans — corrected here to the reproducible in-scope count.) 0-FP;
  fires on a seeded orphan fixture.

### Oversized-packet (ADR-0094) — **specified-not-shipped** (the honest residual)

[ADR-0094](./0094-decomposition-and-risk-weighted-review.md) named an oversized-packet heuristic
(changed-LOC + files-touched over a band, anchored to [[SMARTBEAR]](../research/sources.md#SMARTBEAR)
200–400 LOC + diffusion [[BOSU15]](../research/sources.md#BOSU15)). It was **built, then measured, then
deferred** — the measure-before-ship discipline working as intended:

- Measuring per-commit diffs across the repos where tasks land (last 40 commits each, generated/vendored
  excluded): the corpus-hq docs corpus maxes at 539 LOC / 9 files, but **code** task diffs are much
  larger — corpus-cli has 6 of 40 commits over 600 LOC (615, 713, 843, 997, 1059, 1199), and the 615-LOC
  one is a coherent feature-with-tests, **not** an oversized packet that needed splitting.
- At a 600-LOC band that is **≈15% effective-FP** on real code work — above the ≤10% ceiling. A band
  high enough to be 0-FP on real task diffs (≥1500 LOC) never fires on the population it targets
  (max real task diff ≈1199 LOC) — useless.
- **The decomposition signal is not in the raw LOC count.** Legitimate feature-with-tests commits and
  genuinely-too-big ones share the 600–1200 LOC range, so a raw band cannot be both useful and low-FP.
- **The obvious refinement, considered and rejected:** excluding test/fixture LOC the way the
  generated/vendored exclusion already works does drop the 600-band FP on corpus-cli to ~0% — but
  scanning the full history, a _source-only_ ≥600 band then fires only on genuinely large single
  units (scaffolds, milestone halves), buying 0-FP only by also dropping to ~0 recall against real
  too-big packets. So test-exclusion relocates the same 0-FP-but-useless trap rather than escaping it;
  the deferral holds.
- **Reserved id:** `C018` is **reserved** for an oversized-packet check if a future
  _decomposition-predictive_ signal (beyond raw LOC) is found; it is **not minted** in 0.9.0, and the
  `CheckId` set stops at C017. The size infrastructure ships now in the neutral-info role below.
- **Resolution:** the band-based **check** stays specified-not-shipped. The _size itself_ is a real,
  FP-free signal, so `corpus review` surfaces the diff size (changed LOC + files-touched,
  generated/vendored excluded) as **neutral information** — the reviewer judges decomposition, no
  threshold asserted. This honors ADR-0094's "size as a signal" intent in the only honest form the
  data supports. The infrastructure (`worktree_changed_stats`, `packet_size_facts`) ships in that
  neutral-info role; if a future signal beyond raw LOC proves decomposition-predictive, a band can be
  re-proposed against it.

## Consequences

- Contract `0.8.0 → 0.9.0`: `checks.yaml` + `checksContract.ts` (CheckId, SEVERITY_BY_ID, CORE_CHECKS) +
  `docs/reference/checks.md` gain C016 + C017; the drift-guard reconciles them.
- The B2 gate gap (#50) is closed: a fabricated **structurally-empty** Pass now blocks the gate. A
  fabricated **but-present** Evidence cell remains the documented #9 honest exception — the tool cannot
  prove pasted evidence is real without executing it (the human spot-check carries that weight).
- ADR-0094 and ADR-0096 are amended with a ledger note: their named toolables now resolve (C016/C017
  shipped; oversized-packet deferred-with-measurement).
- Honesty level: **toolable** for C016/C017 (the checker is corpus-cli); the oversized band is
  **specified-not-shipped**, recorded with the measurement so the deferral is auditable, not silent.
