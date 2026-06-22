# Adopting Swarm

*Works today — plain markdown plus your agent; no Swarm tooling required.*

Swarm is files, not software. The starter kit **is** a complete workspace — adoption is one
copy plus one bootloader to fill in. Three paths, in order of preference.

## 1. Manual adoption (one copy, ~15 minutes)

Copy the kit whole from its template repo —
[`jcosta33/swarm-starter-kit`](https://github.com/jcosta33/swarm-starter-kit) — as a dedicated
workspace repo or a folder inside your project ([where files live](03-where-files-live.md)):

```sh
# dedicated workspace repo (gh needs a visibility flag in non-interactive mode)
gh repo create my-workspace --private --template jcosta33/swarm-starter-kit --clone
# or clone and re-init without a remote:
git clone https://github.com/jcosta33/swarm-starter-kit my-workspace \
  && rm -rf my-workspace/.git && git -C my-workspace init

# or co-located inside your project
git clone https://github.com/jcosta33/swarm-starter-kit /tmp/kit \
  && cp -R /tmp/kit/. <your-project>/workspace/ && rm -rf <your-project>/workspace/.git
# (cp -R with the trailing dot keeps the kit's symlinks; -r would replace them with stale copies)
```

Windows: a default clone or copy materializes the kit's three symlinks as small text files
(git `core.symlinks=false`). Either enable Developer Mode and clone with
`-c core.symlinks=true`, or replace each of the three — `.claude/skills` with a real copy of
`.agents/skills/`, and `CLAUDE.md` / `GEMINI.md` with real copies of `AGENTS.md` (otherwise the
bootloader never loads).

Then:

1. **Fill the `{{placeholders}}`** — `AGENTS.md` (Commands table, project facts), the
   seed ADR's date and team in `decisions/0001-adopt-swarm.md`, and seed `status.md`:
   the board is yours — replace the example row shape with your first spec and task rows.
   In a dedicated workspace repo the Commands table names the commands of the code repos
   this workspace governs (or stays as placeholders until that's decided).
2. **Copy the `For code repos:` pointer out** of `AGENTS.md` into each code repo's own
   `AGENTS.md`, then remove the line here.
3. **Point your agent at the guides.** Claude Code already finds them — the kit ships
   `.claude/skills` as a symlink to `.agents/skills/`. For another tool, add its
   equivalent symlink or copy the guide folders to wherever it scans (the per-tool table
   is in [integrations](10-integrations.md)).
4. **Read `examples/feature-from-ticket/`**, then delete it when you no longer need it.
5. **Commit the workspace.** A dedicated repo gets `git init` + a first commit; a co-located
   workspace is committed with the code repo. The workspace *is* the record — an uncommitted
   local folder drifts from the code it describes ([where files live](03-where-files-live.md)).
6. **Write one spec** for your next non-trivial change: `specs/<feature>/spec.md`. Run the
   loop once.

Team defaults, stated once: whoever owns the change writes the spec; who reviews is whoever
did not write the diff — the implementing agent's session never fills its own review packet.

Optional, when you need them: the kit's `advanced/` templates are used in place (the
inventory is in the kit's `advanced/README.md`; the advanced audit template is the
recommended first taste for brownfield teams), and conditioning stances plus
per-change-shape implementation guides install from
[the swarm-skills catalog](https://github.com/jcosta33/swarm-skills) into `.agents/skills/`
with `npx skills add jcosta33/swarm-skills` (add `--list` to preview the catalog without
installing, or copy the folders).

## 2. Agent-assisted adoption

Hand your coding agent this prompt:

> Adopt the Swarm framework into this repository. Read
> `https://github.com/jcosta33/swarm/blob/main/docs/ADOPTING.md` and
> `https://github.com/jcosta33/swarm-starter-kit` — then perform the manual-adoption
> steps for me: copy the starter-kit repo whole as my workspace, fill its `AGENTS.md` Commands
> table from my real test/lint/build setup (read package.json/Makefile/CI and confirm
> with me), wire my agent tool to `.agents/skills/` if it is not Claude Code, and append
> the gitignore additions to my code repos. This is additive — do not delete or
> overwrite my files; stop and ask on any conflict.

## 3. CLI adoption

`swarm init` does the above mechanically — it scaffolds the workspace into a new or existing repo,
conflict-safe. The reference CLI is optional (the markdown workflow never requires it); what ships
today vs. later is the [capability matrix](reference/future-cli.md).

It auto-detects its layout by directory emptiness: an **empty** dir (a fresh `git init` with no
committed files counts as empty) gets the full **workspace** layout — `templates/`, `specs/`, `tasks/`,
`reviews/`, `intake/`, the skills; a **non-empty** dir gets the thin **footprint** layout (just a pointer
`AGENTS.md` + `.gitignore`), on the assumption it is a *code* repo pointing at a separate workspace. So
when you want the **full workspace inside an existing/non-empty repo** (a co-located workspace, or
adopting into a docs repo), pass `--workspace` explicitly: `swarm init --from <kit> --workspace`. `swarm
init` announces the layout it chose; re-running with `--workspace` over a prior footprint init upgrades
the pointer `AGENTS.md` to the full one (backing the stub up).

## Code repos

A code repo that implements against your specs needs **nothing**. At most:

- a one-line pointer in its `AGENTS.md`: _"Swarm workspace: `<path-or-url>` — read
  the task packet you are given before coding"_;
- the `implement-task` guide copied into its skills directory;
- the workspace's `.gitignore.additions` lines appended to its `.gitignore` (they cover
  agent scratch and future CLI state — the *workspace* commits its artifacts and needs
  none of it).

The agent works from the task packet; the PR links the workspace review packet.
Specs, reviews, and findings never live in the code repo (convention — nothing
enforces it; that's the point of keeping the workspace authoritative).

**Brownfield precondition — sync the base before opening PRs.** Before cutting per-task branches
against a code repo, confirm its local default branch is in sync with `origin/<default>`. If the
local base is *ahead*, every task branch carries those unpushed commits into its PR — decide
whether to publish them (a fast-forward push) or branch from a different base first. This is a
checklist step (nothing enforces it); `swarm worktree create` also surfaces an ahead-of-remote
base as a non-fatal advisory, but the reconcile decision is yours.

## Upgrading

You adopted the kit by copying it whole, so there is no automatic upgrade — and that is the
point: nothing reaches into your repo. Instead, **watch and re-copy**. Each kit release records
what changed in its [CHANGELOG](https://github.com/jcosta33/swarm-starter-kit/blob/main/CHANGELOG.md)
under [semantic versioning](https://semver.org), so you can see whether a bump is a safe addition
(minor/patch) or a layout change you'd reconcile (major) before pulling anything.

Re-copy `templates/`, `.agents/skills/`, and `hooks/` from a newer kit checkout. Your specs,
tasks, reviews, findings, decisions, board, and `AGENTS.md` are yours — the kit never touches
them, so re-copying the kit-owned files is safe unless you have customized one (the CHANGELOG
flags those). The same model holds for the [swarm-skills
catalog](https://github.com/jcosta33/swarm-skills) (`npx skills`) and
[swarm-cli](https://github.com/jcosta33/swarm-cli): pin to a release, re-pull when you choose.
