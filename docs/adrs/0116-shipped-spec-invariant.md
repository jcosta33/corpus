---
type: adr
id: adr-0116
status: proposed
created: 2026-06-27
updated: 2026-06-27
---

# ADR-0116 — Shipped-spec invariant + status/spec coherence check

## Context

[ADR-0108](./0108-living-specs.md) made the spec an `Active` living container with a small status set
(`draft → ready → active → superseded`); [ADR-0110](./0110-execution-change-record.md) made each
`## Execution` change-cycle entry the durable, structured residue of a closed change (Scope, the
AC→evidence Coverage digest, the SHA/hash Pins). Together they assume a spec's recorded lifecycle and
its board placement stay coherent. Nothing checks that they do.

The Phase 3 family sweep (workflow `wf9rvvwys`) found the drift this leaves open. `SPEC-corpus-agents`
was marked **shipped** on the workspace board, yet:

- its own frontmatter status still said **`ready`** (board and spec disagreed about whether the work
  was done);
- it carried **no `## Execution` section** at all — the AC→evidence digest ADR-0110 calls for a closed
  spec was simply absent, so the requirement→evidence linkage for a "shipped" feature did not exist;
- one of its acceptance criteria still named a **retired artifact**, an AC that could never have closed
  against the work that actually shipped.

A spec the board calls shipped, with no Execution record, a disagreeing status, and an AC pointing at a
thing that no longer exists, is the exact silent-staleness failure ADR-0108 set out to catch — and it
slipped because the lifecycle is held by discipline alone, with no coherence gate. This was one of the
recurring classes the sweep traced to a missing automated gate: humans caught it, no check did.

## Decision

**Propose an invariant — _a spec marked shipped on the board MUST be coherent with its own record_ —
and propose extending the existing `corpus check` to verify it.** A spec is *shipped-coherent* iff:

1. **Status agrees.** When the board places a spec in a terminal/shipped column, the spec's own
   frontmatter status is the agreeing terminal value (`active` for an amended-and-shipped living spec,
   or `superseded` with a `superseded_by:` pointer) — never still `draft`/`ready`. The two records of
   "is this done?" must not contradict each other.

2. **Execution is present.** A shipped spec carries at least one `## Execution` change-cycle entry
   (ADR-0110): the durable Scope + AC→evidence Coverage digest for the change that shipped. A spec the
   board calls done with no Execution record is incoherent — the requirement→evidence linkage for a
   shipped feature is exactly the residue ADR-0110 keeps.

**Proposed checker.** Extend `corpus check` (the toolable subset, [ADR-0063](./0063-honesty-framework-and-tooling-boundary.md))
to **fail when the board marks a spec shipped but the spec's status disagrees, or the spec has no
`## Execution` section** — a status/spec coherence check joining the existing `C0NN` core-check family.
The check is 0-FP by construction on the board signal: it fires *only* on a spec the board itself
declares shipped, so a `draft`/`ready`/in-flight spec is never touched, and a legacy or 1:1-simple spec
that the board has not marked shipped is never forced into the structured form. (The AC-names-a-retired-
artifact symptom is left to the ADR-0108 reference-snapshot staleness mechanism and to review — it is
not part of this coherence check.)

_Level: **proposed** — design intent only. This records the invariant and the checker's contract; **no
rule is built here**, no `checks.yaml` entry is added, and `corpus check` ships nothing for this today.
The invariant is the discipline-and-review obligation until the check lands; promote to `accepted`,
and the check from proposed to `toolable`, only when the rule is implemented._

## Consequences

- **The shipped/ready contradiction the sweep found becomes detectable** instead of relying on a human
  reading both the board and the frontmatter. The board and the spec stop being two records that can
  silently disagree about whether a feature is done.
- **A shipped spec is forced to carry its ADR-0110 evidence digest** — the gate makes the durable
  AC→evidence residue a precondition of "shipped," not an optional courtesy that a fast close can skip.
- **Cost:** another `corpus check` core check to specify and (later) build and maintain; until it ships
  this is one more discipline-and-review obligation, which is precisely the failure mode the sweep
  showed discipline alone does not hold. The honest cost is the gap between this `proposed` record and a
  shipped checker — this ADR closes nothing on its own.
- **Coupling to the board reader.** The check needs to read the board's shipped signal as well as the
  spec; it inherits whatever the board representation is. If a spec is shipped without ever touching the
  board, the gate has no signal to fire on — it covers board-recorded shipped specs, not every closed
  one.

## Affected obligations / constraints

- **Refines:** [ADR-0108](./0108-living-specs.md) (adds a coherence gate to the living-spec lifecycle
  it defines) and [ADR-0110](./0110-execution-change-record.md) (makes a present `## Execution` digest a
  precondition of a board-shipped spec). **Grounded by:** the Phase 3 family sweep (`wf9rvvwys`,
  `SPEC-corpus-agents`).
- **Does NOT change:** the spec status set, the `## Execution` format, the verdict model, or the checks
  contract — no `checks.yaml` rule is added here (the checker is proposed, not shipped; ADR-0063). ADRs
  0108/0110 are refined by reference, never edited (Nygard immutability).
