# Swarm kernel — the installable payload

This directory is the **kernel**: the copy-and-paste payload a repository adopts to become a Swarm project. It is inert markdown — language references, templates, pass and profile guides, the conformance contract, a memory seed, a project-owned overlays seed, and a project-owned `config.yaml` seed. **Nothing here runs** (NO RUNTIME); every artifact is a contract a future tool builds against.

## What installs where

On adoption, the payload installs into a consuming repository's canonical workspace:

```text
kernel/.agents/   →  .swarm/kernel/          # the installed payload (language/ templates/ passes/ skills/ conformance/ memory/)
kernel/overlays/  →  .swarm/overlays/        # project-owned rule bundles, seeded empty — outside the payload so they survive a kernel upgrade (ADR-0045)
kernel/config.yaml →  .swarm/config.yaml      # project-owned config (surfaces, agent adapters, lint overrides), seeded — survives upgrade
kernel/.agents/.swarm-version  →  .swarm/VERSION
kernel/AGENTS.md  →  AGENTS.md               # adopted as the project's bootloader (how an agent starts; ≤200 lines / ≤25 KB)
```

`.swarm/` is the canonical Swarm workspace (desired `sources/`, observed `status/`, derived `generated/`, plus `memory/ ledger/ archive/ kernel/ tmp/`). `.agents/` in a consuming repo is **only an agent-tool compatibility surface** — a one-directional mirror of `.swarm/kernel/skills` (which now also carries the `persona-*` profile stances) so a third-party agent CLI can find loadable instructions; it is never the canonical home of project intent. `CLAUDE.md` / `GEMINI.md` are thin aliases that point an agent tool at `AGENTS.md`.

## Payload contents (`.agents/`)

| Path | What it is |
| --- | --- |
| `language/` | Self-contained references for the language: `SOL.md`, `APS.md`, `errors.md` (the `SOL-<LAYER><NNN>` lint catalogue), `versioning.md`. |
| `templates/` | Copyable skeletons — the core artifacts (`spec.swarm.md`, `task.md`, `trace.md`, `review.md`, `finding.md`, `adr.md`, `memory/INDEX.md`) and the source-doc types (`audit.md`, `research.md`, `bug-report.md`, `prd.md`, `rfc.md`). There is **no `verdict.md`** — a `VERDICT` is a block inside `review.md`. |
| `passes/` | One contract page per pass — the nine passes `author → lint → improve → lower → decompose → implement → verify → review → promote`. |
| `skills/` | Pass guides, per-kind implement & author guides, cross-cutting fragments, and the heuristic-profile `persona-*` stances (reusable methods/stances for executing a pass; lazily loaded, never always-on). |
| *(overlays)* | **Not** in this payload — project rule bundles ship as a sibling seed (`kernel/overlays/` → `.swarm/overlays/`), project-owned and outside `.swarm/kernel/` so they survive a kernel upgrade (ADR-0045). |
| `conformance/` | The inert conformance contract (`conformance.yaml`) and the golden-corpus `fixtures/`. |
| `memory/` | The recall seed: `INDEX.md` (a load-*when* map) and `glossary.md`. |

## Adopting

**The full step-by-step (with a copy-paste agent prompt) is [`../docs/ADOPTING.md`](../docs/ADOPTING.md).** In brief:

1. Copy this payload into the consuming repo's `.swarm/kernel/` and adopt `AGENTS.md`; seed `.swarm/memory/`, `.swarm/config.yaml`, and `.swarm/overlays/`; create the `.swarm/` workspace dirs; and bridge the skills into your agent CLI's scan dir (`.claude/skills` / `.agents/skills`).
2. Fill `AGENTS.md`'s `## Commands` table — bind each `cmd*` slot (`cmdTest`, `cmdLint`, `cmdTypecheck`, `cmdValidate`, …) to a project command. A `VERIFY BY <type>:<adapter>:<artifact>` clause resolves its adapter through that table; an unbound slot means an agent asks before running anything.
3. Fill the `## Project facts` placeholders in `AGENTS.md`.
4. Append the lines in [`.gitignore.additions`](./.gitignore.additions) to the project `.gitignore`.

A repository is **Swarm-conformant** when its installed payload, its `AGENTS.md` bootloader, and its `.swarm/` workspace satisfy the conformance contract in [`.agents/conformance/conformance.yaml`](./.agents/conformance/conformance.yaml). Conformance is graded by tier; nothing is enforced at runtime (there is none) — the contract is what a future launcher honours.
