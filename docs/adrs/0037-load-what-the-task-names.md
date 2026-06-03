---
type: adr
id: 0037-load-what-the-task-names
status: accepted
created: 2026-06-02
updated: 2026-06-02
supersedes: [0020]
superseded_by:
---

# ADR-0037: Loading doctrine: load what the task names

## Context

ADR 0020 made skills and personas **self-activate by self-assessment**: each carried
a directive `description` and loaded when its triggers matched the work in front of the
agent. That was the right answer to a real pressure — in a launcher-less
world there may be no gatekeeper to route work — but it elevated description-matching to
the *primary* mechanism. Two problems follow from making the fallback the default. First,
routing then depends on `description` quality: a vague or over-broad description mis-fires,
and the agent has no authoritative statement of what it should load for the pass it is in.
(Practitioner reports preliminarily suggest directive, exclusion-bearing descriptions
activate more reliably than passive ones; the direction is illustrative, not load-bearing,
and the kernel does not rest routing on it [[ACTIVATION-BLOG]](../research/sources.md#ACTIVATION-BLOG).)
Second, leaning on always-evaluated descriptions pushes toward more conditioning being
ambiently present, which works against the density discipline that protects adherence and
cost (§31). §26.4 resolves this by naming the canonical doctrine and demoting self-assessment
to an explicitly degraded mode.

## Decision

The canonical loading doctrine is **load what the task names**: a `task.md` SHOULD name,
in its frontmatter or assignment block, the pass guide(s) and profile(s) it activates for
the pass it frames, and when named the agent MUST load exactly those and SHOULD NOT load
others — because always-on density harms adherence and cost (§31). Description-matching is
**retained but reframed as the launcher-less fallback**: when no launcher and no explicit
naming is present, an agent MAY fall back to matching a guide's self-activating `description`
against the task, but this is a degraded mode, not the contract. ADR 0017's prohibition on
always-loaded skills is kept verbatim — pass guides and profiles remain lazily loaded. The
full specification, including the example `task.md` → guide binding, is detailed in the
pass-guides reference ([`docs/library/pass-guides.md`](../library/pass-guides.md)). Loading remains **orthogonal** to the verification and
self-review deliverable: which conditioning loads (routing) and what proof a task must carry
once active (verification) are independent axes, exactly as ADR 0020 established.

## Alternatives considered

| Alternative | Why rejected |
| --- | --- |
| Keep description-match self-assessment as the primary mechanism (ADR 0020) | Makes routing depend on `description` quality and pushes toward ambient, always-evaluated conditioning that harms adherence and cost; the task itself is the authoritative place to name what loads (§26.4, §31). |
| Drop description-matching entirely, require explicit naming always | Breaks the launcher-less case ADR 0020 existed to serve — a task dropped into an arbitrary agent CLI with no naming would have no way to route at all; the fallback MUST survive (§26.4). |
| A standing gatekeeper that loads guides per task | An always-loaded skill, forbidden by ADR 0017, and not guaranteed present on a consumer's machine (§26.4, ADR 0017). |
| Always-load the relevant guides for a pass | Contradicts ADR 0017 and the §31 density cap; pass guides and profiles are lazily loaded by name (§26.4). |

## Consequences

### Positive

- The task file becomes the authoritative, auditable record of what conditioning a pass loads, instead of routing being implied by description heuristics.
- Loading exactly what the task names minimizes always-on density, protecting adherence and controlling cost (§31).
- The launcher-less case still works: description-matching survives intact as a defined fallback, so a task dropped into any agents.md-compatible CLI can still route.

### Negative

- Authors must now name pass guides and profiles in `task.md`; an unnamed task silently drops to the degraded description-match mode.
- The two modes (named vs description-matched) are a distinction readers must hold; conflating them reintroduces the ambiguity this ADR removes.

### Neutral / tradeoffs

- No mechanism is removed — description-matching is reframed, not deleted; the change is which mechanism is canonical.
- Routing reproducibility is strongest when tasks name their guides; description-matching remains best-effort, the same tradeoff ADR 0020 carried.
- Loading stays orthogonal to the verification/self-review deliverable; this ADR changes routing only and leaves the proof contract untouched.

## Status

Accepted (v0.1).

- Supersedes ADR-0020 (recasts activation-by-self-assessment: "load what the task names" is canonical and description-match self-assessment is demoted to the launcher-less fallback).

## Affected obligations / constraints

- Adds: the "load what the task names" doctrine — a task SHOULD name its pass guide(s) and profile(s), and when named the agent MUST load exactly those and SHOULD NOT load others (§26.4).
- Modifies: the role of the self-activating `description` — retained as the launcher-less fallback (a degraded mode), no longer the primary activation mechanism (§26.4).
- Supersedes: activation-by-self-assessment as the canonical loading mechanism (ADR 0020).
