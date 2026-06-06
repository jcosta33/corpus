# Adopting Swarm

Swarm installs into a repository by **copying the kernel payload and seeding a `.swarm/` workspace** —
there is no installer to run (NO RUNTIME). The fastest path is to hand the steps to the coding agent you
already use; a human can run the same steps by hand.

## Quick start — let your agent do it

Paste this into your agent (Claude Code, Codex, Cursor, …), pointing it at a checkout of this repo:

> Adopt the **Swarm** framework into this repository, following `<swarm-repo>/docs/ADOPTING.md`. Specifically:
> 1. Copy `<swarm-repo>/kernel/.agents/` → `.swarm/kernel/` (the framework payload).
> 2. Put `<swarm-repo>/kernel/AGENTS.md` at my repo **root** as `AGENTS.md`, plus the `CLAUDE.md` and
>    `GEMINI.md` one-line `@AGENTS.md` aliases. **If `AGENTS.md`/`CLAUDE.md` already exist, merge — do not
>    overwrite**: append Swarm's sections by heading, keep my existing content, and stop for my approval on
>    any conflict.
> 3. Create the `.swarm/` workspace dirs: `sources/{specs,prds,rfcs,research,audits,bugs,findings,adrs,interfaces,nfrs}`,
>    `status/{specs,tasks,worktrees,drift}`, `generated/{tasks,traces,reviews,tests,docs}`,
>    `memory/{patterns,stale}`, `ledger/{changes,merges,promotions}`, `overlays/`, `archive/`, `tmp/`
>    (add a `.gitkeep` to each so they survive commit).
> 4. Seed the project surfaces: copy `<swarm-repo>/kernel/.agents/memory/{INDEX.md,glossary.md}` → `.swarm/memory/`,
>    `<swarm-repo>/kernel/config.yaml` → `.swarm/config.yaml`, and `<swarm-repo>/kernel/overlays/README.md` → `.swarm/overlays/`.
> 5. Write `.swarm/VERSION` from `<swarm-repo>/kernel/.agents/.swarm-version`.
> 6. Surface the kernel skills into the dir your CLI scans: symlink `.claude/skills/* → ../.swarm/kernel/skills/*`
>    (Claude Code), or `.agents/skills/* → ../.swarm/kernel/skills/*` (the neutral cross-tool convention).
>    On Windows or where symlinks don't survive, copy instead.
> 7. Append `<swarm-repo>/kernel/.gitignore.additions` to my `.gitignore`.
> 8. Fill `AGENTS.md`'s `## Commands` table and `## Project facts` from this repo's **real** test / lint /
>    build commands and conventions — propose them from `package.json`/`Makefile`/CI and ask me to confirm.
> 9. Report what you did per step.

That's the whole adoption. The only things you must supply are the project-specific bits in step 8 (your
commands and facts) and approval of any brownfield merge in step 2.

## What lands where

| From the kernel | → installs to | Owner |
| --- | --- | --- |
| `kernel/AGENTS.md` (+ `CLAUDE.md`/`GEMINI.md` aliases) | repo **root** | project (you fill Commands + facts) |
| `kernel/.agents/` | `.swarm/kernel/` | framework — replaced wholesale on upgrade |
| `kernel/config.yaml` | `.swarm/config.yaml` | project — survives upgrade |
| `kernel/overlays/` | `.swarm/overlays/` | project — survives upgrade |
| memory seed | `.swarm/memory/` | project — grown by the `promote` pass |
| the kernel skills | your CLI's skills dir (`.claude/skills` / `.agents/skills`) via symlink/copy | framework, bridged |

`.swarm/kernel/**` is framework-owned and replaced on upgrade; everything else under `.swarm/`
(plus the root `AGENTS.md`) is yours and is preserved. See [`model/workspace.md`](model/workspace.md) for
the full workspace contract.

## Brownfield (an existing repo)

Adoption is non-destructive: `.swarm/kernel/` is new, so it never collides. The only merge points are the
root `AGENTS.md`/`CLAUDE.md` (append Swarm's sections, keep yours, approve conflicts) and `.gitignore`
(append-only). Existing code is `observed` until an audit + a spec govern it — adoption does not retrofit specs.

## Upgrading

Re-run the copy of `kernel/.agents/` → `.swarm/kernel/` from a newer checkout. `.swarm/kernel/**` is replaced;
`.swarm/overlays/`, `.swarm/config.yaml`, your data workspace, and your filled `AGENTS.md` are **not** touched
(diff the fresh `AGENTS.md` template against yours and fold in only new sections). Re-run the skills bridge.

*A future `swarm` CLI may automate this; today it is these documented steps an agent or a human performs.*
