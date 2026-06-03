---
type: adr
id: 0040-kernel-payload-directory
status: accepted
created: 2026-06-02
updated: 2026-06-02
supersedes:
superseded_by:
---

# ADR-0040: The kernel payload ships under `kernel/`

## Context

The copyable framework payload — the unitary thing a consuming repository adopts wholesale — needs one shipping directory in this framework-dev repo. An earlier layout named that directory `scaffold/` (ADR [0008](./0008-empirical-proof-as-framework-primitive.md) still cites the earlier `/scaffold/.agents/templates/` path). The name was wrong twice over: it read as disposable boilerplate rather than the inert, versioned *kernel* a repo installs and keeps, and it did not match the term the spec uses everywhere else for that artifact. The §34.0 wave-2 note resolved this by renaming the payload root, but recorded the rename as a v0.2-deferred, optional cosmetic change — leaving v0.1 to ship under a name the rest of the kernel vocabulary had already abandoned. That left wave 2 ("install the payload") with no settled directory to lay the payload down under, and the spec's own §20.0 layout already drawing the tree under `kernel/`. The deferral and the frozen layout contradicted each other.

## Decision

v0.1 ships the copyable kernel payload under `kernel/` (renamed from the earlier `scaffold/`), pulling the rename forward from its v0.2 deferral. `kernel/.agents/` is the installable payload interior and `kernel/AGENTS.md` is the populated bootloader a consumer adopts; the framework-dev `kernel/` is the *shipping location*, distinct from the adopted-project workspace it installs into. The install relation is unchanged: a consumer copies the contents 1:1, and in a consuming repo the payload lands at `.swarm/kernel/`, under which `.swarm/` is the canonical workspace and `.agents/` is only an agent-tool compatibility mirror. The rename is cosmetic — it changes the payload's directory name only, never the `.agents/` interior, the artifact filenames, or the conformance definition. The full specification is §20.0 (the canonical layout note) and §20.5 (the adopted-project `.swarm/kernel/` install target); the wave-2 ordering is §34.0.

## Alternatives considered

| Alternative | Why rejected |
| --- | --- |
| Keep the earlier `scaffold/` name | It misframes the inert, versioned kernel a repo adopts and keeps as disposable boilerplate, and it diverges from the term the rest of the spec uses for that exact artifact (§20.0). |
| Hold the rename at its v0.2 deferral and ship v0.1 under `scaffold/` | Wave 2 ("install the payload") and the frozen §20.0 layout already draw the tree under `kernel/`; deferring the name would force a second rename mid-stream and leave v0.1 shipping under a name the kernel vocabulary had retired (§34.0). |
| Change the `.agents/` interior, filenames, or conformance definition alongside the rename | Out of scope by design judgement: the §20.0 note fixes the rename as *cosmetic*, so touching the interior would reopen settled artifact and conformance decisions (§20.0, §20.4). |

## Consequences

### Positive

- The shipping directory name now matches the spec's own term for the artifact ("the kernel"), removing the `scaffold/`↔`kernel/` divergence the §20.0 layout had already adopted.
- Wave 2 has a single, settled directory to lay the payload under (`kernel/.agents/`, `kernel/AGENTS.md`), with no second rename owed in v0.2.
- The framework-dev shipping location and the adopted-project install target read consistently: `kernel/` ships, `.swarm/kernel/` receives.

### Negative

- ADR [0008](./0008-empirical-proof-as-framework-primitive.md)'s body still cites the earlier `/scaffold/.agents/templates/` path; per the immutable-ADR rule that body stays as written and is corrected only by this record, so a reader of 0008 alone sees the earlier name.

### Neutral / tradeoffs

- The change is purely a directory-name rename; the install relation, the `.agents/` interior, the artifact filenames, and the conformance definition are unchanged, so a tool keying on those is unaffected.
- The §20.0 note's reserved v0.2 rename + one-cycle-alias path is now moot for this rename; this record pulls it forward instead, and a consuming repo's `.swarm/kernel/` target is unchanged either way.

## Status

Accepted (v0.1).

## Affected obligations / constraints

- Adds: the v0.1 payload-directory contract — the copyable kernel ships under `kernel/` (`kernel/.agents/` interior, `kernel/AGENTS.md` bootloader), installing 1:1 into a consumer's `.swarm/kernel/` (§20.0, §20.5).
- Modifies: the earlier `scaffold/` payload-root name is renamed to `kernel/` (interior, filenames, and conformance definition unchanged).
- Supersedes: the §34.0 wave-2 note's v0.2 deferral of the payload-directory rename — the rename is pulled forward into v0.1 by this record; there is no prior ADR to supersede.
