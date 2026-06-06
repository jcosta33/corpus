---
type: adr
id: 0045-overlays-are-project-owned
status: superseded
created: 2026-06-05
updated: 2026-06-06
supersedes:
superseded_by: 0049-minimal-install-no-mount-no-imposed-workspace
---

> **Superseded by [ADR-0049](./0049-minimal-install-no-mount-no-imposed-workspace.md).** There is no
> overlays directory: project conventions now live in `AGENTS.md`. The reasoning below (project rules must
> survive a framework upgrade) still holds — under 0049 it holds because the bootloader an agent reads is
> project-owned and an upgrade only re-copies Swarm's named skill files.

# ADR-0045: Overlays are project-owned and live outside the replaceable kernel payload

## Context

Overlays are the project-local rule layer (architecture conventions, extra refusals, local command
bindings) a repository adds on top of the kernel ([overlays reference](../library/overlays.md)). They are
**project-authored** content. Yet the kernel payload model placed them *inside* the framework-owned tree:
`docs/model/workspace.md` listed `overlays/` as a sub-directory of `.swarm/kernel/` (the installed payload)
and the producer seed shipped at `starter-kit/.agents/overlays/` (which mirrors `.swarm/kernel/`).

That nesting is an **upgrade footgun**. The kernel-upgrade model ([0044](./0044-kernel-is-derived-and-self-contained.md))
replaces `.swarm/kernel/` **wholesale** from a newer payload. With overlays nested inside it, a naive payload
swap **deletes the project's overlays** — the one directory under `.swarm/kernel/` a project is *expected* to
author. The workspace table even said "Framework-owned; project edits belong in `overlays/`," i.e. it marked a
project-owned island inside a framework-owned, replace-on-upgrade tree — exactly the ownership conflation that
makes upgrades unsafe.

## Decision

**Overlays are project-owned and live at a top-level `.swarm/overlays/`** — a sibling of `.swarm/kernel/`,
*outside* the replaceable payload — not at `.swarm/kernel/overlays/`.

1. **`.swarm/overlays/`** is a top-level workspace category (alongside `sources/`, `status/`, `memory/`,
   `ledger/`, `archive/`), **project-owned and committed**. A kernel upgrade replaces `.swarm/kernel/`
   wholesale and **never touches `.swarm/overlays/`**.
2. The producer seed moves out of the payload mirror: `starter-kit/.agents/overlays/` → **`starter-kit/overlays/`**
   (a workspace seed, not part of the `starter-kit/.agents/` → `.swarm/kernel/` mirror), so [0044](./0044-kernel-is-derived-and-self-contained.md)'s
   "`starter-kit/.agents/` mirrors `.swarm/kernel/`" invariant stays honest. The stdlib ships it **empty (a README)**.
3. The ownership boundary is now **positional**: everything under `.swarm/kernel/**` is framework-owned and
   replaced on upgrade; `.swarm/overlays/` (with the root `AGENTS.md`, `.swarm/config.yaml`, and the data
   workspace) is project-owned and preserved. This is the same boundary the upgrade story relies on.
4. The **overlay contract is unchanged** ([overlays reference](../library/overlays.md)): an overlay is
   SOFT, additive, lazily-loaded-by-name guidance that MUST NOT override an approved obligation or redefine
   kernel semantics. Only its *location* and *ownership tagging* change.

Refines [0040](./0040-kernel-payload-directory.md) (the kernel payload directory) and supports
[0044](./0044-kernel-is-derived-and-self-contained.md) (the self-contained, replaceable payload). This is a
precondition for a safe kernel upgrade and for the static adoption bundle.

## Alternatives considered

| Alternative | Why rejected |
| --- | --- |
| Keep overlays under `.swarm/kernel/overlays/`, preserve them on upgrade by a special stash/restore step | Makes the upgrade special-case a project-owned subdir of a framework-owned tree; ownership-by-exception is exactly the conflation that caused the footgun. Positional ownership (location = owner) is simpler and safe by construction. |
| Keep the producer seed at `starter-kit/.agents/overlays/` | Breaks [0044](./0044-kernel-is-derived-and-self-contained.md)'s mirror invariant (`starter-kit/.agents/` ⇒ `.swarm/kernel/`): the coherence gate would expect it to install under `.swarm/kernel/overlays/`. The seed must leave the payload mirror. |
| Put project rules in the root `AGENTS.md` instead of overlays | `AGENTS.md` is always-loaded persistent facts; overlays are lazily-loaded, pass-scoped rule bundles — a different lifecycle ([overlays reference](../library/overlays.md) §"where does a rule belong"). They are not interchangeable. |

## Consequences

### Positive

- A kernel upgrade is **safe by construction**: replacing `.swarm/kernel/` cannot delete project overlays.
- Ownership is positional and unambiguous: `.swarm/kernel/**` framework-owned/replaced; everything else the
  project's.
- Aligns overlays with the other project-owned, upgrade-surviving surfaces (the root `AGENTS.md`, `config.yaml`).

### Negative

- The `.swarm/` workspace grows from eight to nine top-level categories; adopters learn one more directory.
- Existing prose and the producer layout that named `starter-kit/.agents/overlays/` / `.swarm/kernel/overlays/`
  must be updated (this ADR + `workspace.md` + `overlays.md` + the `starter-kit/AGENTS.md`/`README.md` pointers).

### Neutral / tradeoffs

- The overlay contract, the dependency-chain position (most-downstream), and the SOFT/additive boundary are
  unchanged — this is a relocation + ownership-tagging decision, not a semantic change. No canonical closed
  set changes.

## Status

Accepted (v0.1).

## Affected obligations / constraints

- Adds: `.swarm/overlays/` as a project-owned, upgrade-surviving top-level workspace category; the positional
  ownership boundary (`.swarm/kernel/**` framework-owned/replaced vs `.swarm/overlays/` project-owned/preserved).
- Modifies: the workspace partition (eight → nine categories); the producer seed location
  (`starter-kit/.agents/overlays/` → `starter-kit/overlays/`); the `starter-kit/AGENTS.md` and `starter-kit/README.md` overlay
  pointers; the "Where overlays live" contract in `docs/library/overlays.md`.
- Refines: [0040](./0040-kernel-payload-directory.md). Supports: [0044](./0044-kernel-is-derived-and-self-contained.md).
- Does NOT change: the overlay contract, the dependency chain, the SOFT/additive boundary, or any canonical count.
