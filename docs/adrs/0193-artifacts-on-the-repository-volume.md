---
type: adr
id: adr-0193
status: accepted
created: 2026-11-13
---

# ADR-0193 - Artifacts stay on the repository's volume

## Context

[ADR-0148](./0148-agent-neutral-artifact-workspace.md) fixed one neutral root under the home
directory, `~/.agents/artifacts/<workspace>/`. On the owner's machine the repositories live on a
separate volume, `/Volumes/Development`, while the home directory sits on the system volume. On
2026-11-12, `df` reported the system data volume at 95% capacity and the development volume at 44%.
Every artifact, sidecar, log, and patch written for a repository on the development volume landed
on the fuller system volume, away from the work it describes.

José Costa, the owner, ruled on 2026-11-13: the artifacts the authors create stay on the same drive
as the repository.

## Decision

1. **Same volume as the repository.** Artifacts live at
   `<root>/.agents/artifacts/<workspace>/<ID>.md`, outside the repository. Run `df -P` on the
   repository and on the home directory; the last field is the mount point. If the two match,
   `<root>` is the absolute home path, so repositories on the home volume keep ADR-0148's location.
   Otherwise `<root>` is the repository's mount point. Outside a repository, the working directory
   takes its place. _Level: convention._
2. **No cross-volume fallback.** If the root is unwritable, offer grant and retry, another
   agent-neutral directory on the same volume, or cancel. Never fall back to another volume, vendor
   storage, the repository, or a temporary directory. _Level: convention._
3. **Gate.** `sh scripts/lint-artifact-skills.sh` requires the `<root>/.agents/artifacts/<workspace>/`
   literal, the `df -P` resolution, and the same-volume and no-other-volume wording in every
   author.
4. **No migration machinery.** Artifacts already under `~/.agents/artifacts/` stay where they are
   until their set closes. Corpus adds no mover, registry, or resolver.

## Narrowed decisions

- [ADR-0148](./0148-agent-neutral-artifact-workspace.md) Decision 1: the root follows the
  repository's volume instead of always the home directory. Decision 3: the "another agent-neutral
  user directory" choice must stay on the same volume. Explicit absolute paths, zero repository
  footprint, and the passive directory stand.

## Consequences

- Artifacts for repositories on a secondary volume no longer consume space on the system volume.
- An agent can no longer assume one fixed root across repositories; the absolute handoff path,
  already required, remains the only way to find an artifact.
- A sandbox may need one explicit permission for each volume root it writes.

## Status

Accepted (2026-11-13). Narrows ADR-0148.
