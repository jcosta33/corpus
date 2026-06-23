---
type: adr
id: 0040-kernel-payload-directory
status: accepted
created: 2026-06-02
updated: 2026-06-02
supersedes:
superseded_by:
---

# ADR-0040: The installable payload ships from a single directory (originally `kernel/`, now `starter-kit/`)

> **Refined by [ADR-0049](./0049-minimal-install-no-mount-no-imposed-workspace.md).** Two updates: (1) the
> _adopter-side_ mount this ADR defined (`.corpus/kernel/`) is gone — under 0049 the payload installs in
> place beside the project's own skills; (2) the producer directory has been **renamed `kernel/` → `starter-kit/`**
> (the "kernel" OS metaphor was dropped as oversell for a NO-RUNTIME file-set). The _producer-side_ decision
> below — that the payload ships from one directory in this repo — still stands; only its name changed.
> Body text below is the original historical reasoning (which argued _for_ the name "kernel").

## Context

The copyable framework payload — the unitary thing a consuming repository adopts wholesale — needs one shipping directory in this framework-dev repo. An earlier layout named that directory `scaffold/` (ADR [0008](./0008-empirical-proof-as-framework-primitive.md) still cites the earlier `/scaffold/.agents/templates/` path). The name was wrong twice over: it read as disposable boilerplate rather than the inert, versioned _kernel_ a repo installs and keeps, and it did not match the term the spec uses everywhere else for that artifact. The §34.0 wave-2 note resolved this by renaming the payload root, but recorded the rename as a v0.2-deferred, optional cosmetic change — leaving v0.1 to ship under a name the rest of the kernel vocabulary had already abandoned. That left wave 2 ("install the payload") with no settled directory to lay the payload down under, and the spec's own §20.0 layout already drawing the tree under `starter-kit/`. The deferral and the frozen layout contradicted each other.

## Decision

v0.1 ships the copyable kernel payload under `starter-kit/` (renamed from the earlier `scaffold/`), pulling the rename forward from its v0.2 deferral. `starter-kit/.agents/` is the installable payload interior and `starter-kit/AGENTS.md` is the populated bootloader a consumer adopts; the framework-dev `starter-kit/` is the _shipping location_, distinct from the adopted-project workspace it installs into. The install relation is unchanged: a consumer copies the contents 1:1, and in a consuming repo the payload lands at `.corpus/kernel/`, under which `.corpus/` is the canonical workspace and `.agents/` is only an agent-tool compatibility mirror. The rename is cosmetic — it changes the payload's directory name only, never the `.agents/` interior, the artifact filenames, or the conformance definition. The full specification is §20.0 (the canonical layout note) and §20.5 (the adopted-project `.corpus/kernel/` install target); the wave-2 ordering is §34.0.

## Alternatives considered

| Alternative                                                                               | Why rejected                                                                                                                                                                                                                                     |
| ----------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Keep the earlier `scaffold/` name                                                         | It misframes the inert, versioned kernel a repo adopts and keeps as disposable boilerplate, and it diverges from the term the rest of the spec uses for that exact artifact (§20.0).                                                             |
| Hold the rename at its v0.2 deferral and ship v0.1 under `scaffold/`                      | Wave 2 ("install the payload") and the frozen §20.0 layout already draw the tree under `starter-kit/`; deferring the name would force a second rename mid-stream and leave v0.1 shipping under a name the kernel vocabulary had retired (§34.0). |
| Change the `.agents/` interior, filenames, or conformance definition alongside the rename | Out of scope by design judgement: the §20.0 note fixes the rename as _cosmetic_, so touching the interior would reopen settled artifact and conformance decisions (§20.0, §20.4).                                                                |

## Consequences

### Positive

- The shipping directory name now matches the spec's own term for the artifact ("the kernel"), removing the `scaffold/`↔`starter-kit/` divergence the §20.0 layout had already adopted.
- Wave 2 has a single, settled directory to lay the payload under (`starter-kit/.agents/`, `starter-kit/AGENTS.md`), with no second rename owed in v0.2.
- The framework-dev shipping location and the adopted-project install target read consistently: `starter-kit/` ships, `.corpus/kernel/` receives.

### Negative

- ADR [0008](./0008-empirical-proof-as-framework-primitive.md)'s body still cites the earlier `/scaffold/.agents/templates/` path; per the immutable-ADR rule that body stays as written and is corrected only by this record, so a reader of 0008 alone sees the earlier name.

### Neutral / tradeoffs

- The change is purely a directory-name rename; the install relation, the `.agents/` interior, the artifact filenames, and the conformance definition are unchanged, so a tool keying on those is unaffected.
- The §20.0 note's reserved v0.2 rename + one-cycle-alias path is now moot for this rename; this record pulls it forward instead, and a consuming repo's `.corpus/kernel/` target is unchanged either way.

## Status

Accepted (v0.1).

## Affected obligations / constraints

- Adds: the v0.1 payload-directory contract — the copyable kernel ships under `starter-kit/` (`starter-kit/.agents/` interior, `starter-kit/AGENTS.md` bootloader), installing 1:1 into a consumer's `.corpus/kernel/` (§20.0, §20.5).
- Modifies: the earlier `scaffold/` payload-root name is renamed to `starter-kit/` (interior, filenames, and conformance definition unchanged).
- Supersedes: the §34.0 wave-2 note's v0.2 deferral of the payload-directory rename — the rename is pulled forward into v0.1 by this record; there is no prior ADR to supersede.
