---
type: adr
id: adr-0081
status: accepted
created: 2026-06-16
updated: 2026-06-16
---

# ADR-0081 — Re-adopt the kit provenance stamp (narrow reversal of ADR-0050 §6)

## Context

The kit is adopted by copying it whole, so it can never be _pushed_ to — an adopter silently drifts
from the latest kit with no local signal that their copied files are stale (corpus-hq issue #12).
ADR-0015 once defined a version marker; ADR-0050 §6 **dropped** it, on the sole ground that "nothing
reads it in a no-runtime world." That premise is now false: corpus-cli reads the workspace (ADR-0077),
and `corpus init` already exists as the natural place to stamp a copied version.

The tempting full fix — `corpus check` _warns_ when the workspace is behind the latest kit — cannot
ship honestly today. `corpus check` has no honest source for "latest": a network fetch breaks its
hermetic reads-filesystem/writes-nothing posture (ADR-0077); a constant pinned in corpus-cli goes
stale and couples release cadences; a local-CHANGELOG compare is circular (you only have the newer
CHANGELOG once you have already re-copied). So the staleness _warning_ has no honest backing yet.

## Decision

**Re-adopt a provenance stamp; defer the staleness warning.** This narrowly reverses ADR-0050 §6 for
the _provenance_ use (which now has a reader), not for a conformance check.

- The kit carries a machine-readable `VERSION` file (tracking the CHANGELOG's current release),
  bumped as part of the release ritual.
- `corpus init` (workspace mode) stamps `.agents/.corpus-version` in the new workspace from the kit's
  `VERSION` — a one-line provenance pin recording which kit version this workspace was copied from.
  It is best-effort (an older kit without `VERSION` stamps nothing) and the tool owns it (a re-init
  re-stamps unconditionally; it is not conflict-handled like user content).
- This is a **provenance pin, not a staleness check** (honesty level _toolable_ — the named checker
  is corpus-cli). It turns ADOPTING's manual "watch the releases" into an exact local-version-vs-CHANGELOG
  compare.

**Deferred:** the automated behind-latest _warning_ in `corpus check`. Shipping it needs an honest
"latest" source — most plausibly pushed kit release tags or a fetchable version — and a decision on
the hermeticity trade-off. A future ADR settles that with evidence (the conservative-then-promotable
pattern C012 used, ADR-0079). The open question is named here so it is not lost.

No `checks.yaml` rule and no contract-version bump: the stamp adds a provenance file, not a check, so
it stays off the corpus-cli drift-guard critical path.

## Consequences

- An adopter (and any future audit or tool) can read which kit version a workspace holds — a
  provenance anchor that does not exist today; the watch-and-re-copy model (ADOPTING) gains a local
  side to compare.
- The kit gains a `VERSION` file the release ritual must keep in step with the CHANGELOG (and,
  later, with pushed release tags).
- corpus-cli's `init_workspace` writes the stamp in workspace mode; a footprint install (a code repo,
  no `.agents/` workspace) stamps nothing. Tests cover the stamped and the no-`VERSION` paths.
- The drift problem #12 raised is addressed with an honest slice; the staleness _warning_ is a named,
  deferred follow-on, not an over-promised check.
