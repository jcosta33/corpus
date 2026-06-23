---
type: adr
id: adr-0091
status: accepted
created: 2026-06-20
updated: 2026-06-22
---

# ADR-0091 — `swarm update`: a reconcile-only kit refresh — ship `--check`, defer the merge

## Context

The kit is adopted by copying it whole ([ADR-0075](./0075-starter-kit-template-repo.md)), so an
adopter silently drifts from the latest kit. [ADR-0081](./0081-kit-provenance-stamp.md) shipped the
`.agents/.swarm-version` provenance pin but **deferred** the staleness warning, on one honest ground:
`swarm check` has no honest source for "latest" — a network fetch breaks its hermetic
reads-filesystem/writes-nothing posture ([ADR-0077](./0077-swarm-cli-reconcile-only-harness.md)), a
pinned constant goes stale, and a local-CHANGELOG compare is circular.

That ground holds **only for `swarm check`**. swarm-hq #12 asked for the full update model, and a
value panel (recorded in swarm-hq `FINDING-competitive-positioning-verified` /
`RESEARCH-feedback-signal-triage`) found the offline concern is real *for the hermetic check*, but an
**explicit, network-touching `swarm update`** is a solved pattern (copier / cookiecutter+cruft).
`swarm init` already resolves the kit by cloning it (or `--from`), so the network already lives in
that surface — the natural home for a "latest" lookup that `swarm check` could not have.

The evidence is **asymmetric**, and this ADR scopes to it. Template *creation* and a CI *drift-check*
are broadly validated; the interactive 3-way *merge* is the part teams are documented to **abandon on
first conflict** ("gives up on template update"; merges fail with "no common ancestor" — Dumont 2025).
For this kit the conflict case is the *common* case, because the kit's own onboarding tells adopters
to edit the generated files (AGENTS.md, the guides).

## Decision

**Add `swarm update` as a reconcile-only verb. Ship `swarm update --check`; defer the merge.**

1. **`swarm update --check`** (the drift signal, shipped). Reads the workspace's
   `.agents/.swarm-version` pin; resolves the kit through the **same source resolution as `swarm init`**
   (clone the default kit, or `--from <path|url>`); reads the kit's `VERSION`; compares; prints whether
   the workspace is behind and the CHANGELOG delta. **Exit 1 behind / 0 clean / 2 error.** It **writes
   nothing** (reconcile-only).
2. **The network lives in `swarm update`, not in `swarm check`.** `swarm check` stays hermetic; the
   explicit `update` verb is where a fetch is honest. This is precisely what ADR-0081 lacked.
3. **Defer the apply/merge.** The 3-way-merge refresh (a future `swarm update --write`) is held behind
   demonstrated demand *and* observed drift. Until then `--write`/apply returns an explicit "deferred"
   message — never a silent no-op — and the honest manual path stands: `--check` points at the
   CHANGELOG delta, the adopter re-copies or cherry-picks the changed rules.
4. **Scope of the reversal.** This reopens ADR-0081's deferral **for the explicit-update case only**;
   the hermetic `swarm check` staleness warning stays deferred.
5. **Honesty level: toolable** — the named checker is swarm-cli's `swarm update --check`. Nothing is
   *enforced*; a team may wire its exit code into their own CI gate (their gate, not Corpus's).

## Alternatives considered

| Alternative | Why weaker |
|---|---|
| Put the staleness warning in `swarm check` | Breaks `swarm check`'s hermeticity — the exact ADR-0081 blocker. Keep the network in the explicit `update` verb. |
| Build the 3-way-merge now | The precedent's merge half is the part the field abandons on first conflict (Dumont 2025), and the kit's edit-the-files onboarding makes conflict the common case — real effort on the least-used half. |
| A network registry / version service | Infrastructure Corpus doesn't have, plus lock-in. copier/cruft prove local pin + a refs fetch suffice. |
| Auto-apply update (no preview) | Breaks reconcile-only — the human must own any mutation. |

## Consequences

`swarm update --check` ships as the actionable half of #12; the `.agents/.swarm-version` pin
(ADR-0081) gains its second reader. ADOPTING's upgrade guidance points at it. Reconcile-only is
preserved (the verb reads + reports; it never writes or issues a verdict). The merge is a **recorded
deferral with a gate** (demand + drift), not a silent omission. The honest manual upgrade path is
unchanged for the once-copied adopter. swarm-cli spec + tasks live in swarm-hq (`specs/swarm-update/`).

## Update (2026-06-22) — the apply ships, but **not** as the 3-way merge

`swarm update --write` now ships (swarm-cli `4536fc7`). Decision 3's deferral was specifically of the
**interactive 3-way merge** — the half the field abandons on first conflict (Dumont 2025) and that this
kit's edit-the-generated-files onboarding makes the common case. The shipped `--write` deliberately is
**not** that merge. It reuses the conflict-safe copy engine (`init_workspace`), **scoped to the
kit-owned guidance only** (`templates/`, `.agents/skills/`, `advanced/`, `hooks/`), with a
**`backup`** default: a customized kit file is preserved as `<file>.swarm-bak` and the kit's version
lands — never a line-level merge, so the "no common ancestor" failure mode never arises. The adopter's
own artifacts (board, specs, decisions, README, `AGENTS.md`) are out of scope by construction, which is
why this honors — rather than reverses — ADOPTING.md's "the kit never touches them" promise. `skip`
leaves the pin behind (a partial apply is honestly still "behind"); `overwrite` is the no-backup
escape hatch. The ADR's core rationale stands: Corpus still does not build the merge teams abandon. The
deferral gate (demand + drift) was met by the goal-run backlog clearance; honesty level stays
**toolable** (the checker/applier is `swarm update`; nothing is enforced).
