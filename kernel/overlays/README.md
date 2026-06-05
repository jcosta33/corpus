# Overlays (workspace seed)

> Project rule bundles. Non-kernel, project-authored; cite/quote upstream nodes but are never cited by them.
>
> **This is a workspace seed, not part of the `.swarm/kernel/` payload.** On adoption it installs to the
> project-owned **`.swarm/overlays/`** (a sibling of `.swarm/kernel/`, *outside* the framework-owned tree),
> so a project's overlays **survive a kernel upgrade** — the upgrade replaces `.swarm/kernel/` wholesale but
> never touches `.swarm/overlays/`. The standard library ships this directory empty with this README; a
> project populates it. See `docs/library/overlays.md` for the overlay contract and ADR-0045 for the
> ownership rationale.
