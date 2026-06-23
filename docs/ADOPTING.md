# Adopting Corpus

_Works today — plain markdown plus your agent; no Corpus tooling required._

Corpus is files, not software. The starter kit **is** a complete workspace. Adoption is one
copy plus one bootloader to fill. Three paths, in order of preference.

## 1. Manual adoption (one copy, ~15 minutes)

Copy the kit whole from [`jcosta33/corpus-starter-kit`](https://github.com/jcosta33/corpus-starter-kit) —
into a dedicated workspace repo, or a folder inside your project
([where files live](03-where-files-live.md)):

```sh
# dedicated workspace repo (gh needs a visibility flag in non-interactive mode)
gh repo create my-workspace --private --template jcosta33/corpus-starter-kit --clone
# or clone and re-init without a remote:
git clone https://github.com/jcosta33/corpus-starter-kit my-workspace \
  && rm -rf my-workspace/.git && git -C my-workspace init

# or co-located inside your project
git clone https://github.com/jcosta33/corpus-starter-kit /tmp/kit \
  && cp -R /tmp/kit/. <your-project>/workspace/ && rm -rf <your-project>/workspace/.git
# (cp -R with the trailing dot keeps the kit's symlinks; -r would replace them with stale copies)
```

Windows: a default clone materializes the kit's three symlinks as text files (git
`core.symlinks=false`). Either enable Developer Mode and clone with `-c core.symlinks=true`,
or replace the three by hand. `.claude/skills` becomes a real copy of `.agents/skills/`;
`CLAUDE.md` and `GEMINI.md` become real copies of `AGENTS.md`. Otherwise the bootloader never loads.

Then:

1. **Fill the `{{placeholders}}`** — `AGENTS.md` (Commands table, project facts), the seed
   ADR's date and team in `decisions/0001-adopt-corpus.md`, and `status.md` (replace the example
   rows with your first spec and task). In a dedicated workspace repo, the Commands table names
   the commands of the code repos this workspace governs, or stays placeholders until that's decided.
2. **Copy the `For code repos:` pointer** out of `AGENTS.md` into each code repo's own
   `AGENTS.md`, then remove the line here.
3. **Point your agent at the guides.** Claude Code finds them: the kit ships `.claude/skills`
   as a symlink to `.agents/skills/`. For another tool, add its equivalent symlink or copy the
   guide folders where it scans (per-tool table: [integrations](10-integrations.md)).
4. **Read `examples/feature-from-ticket/`**, then delete it when you no longer need it.
5. **Commit the workspace.** A dedicated repo gets `git init` plus a first commit; a co-located
   workspace commits with the code repo. The workspace _is_ the record. An uncommitted local
   folder drifts from the code it describes ([where files live](03-where-files-live.md)).
6. **Write one spec** for your next non-trivial change: `specs/<feature>/spec.md`. Run the loop once.

**First-run discipline** (a **convention** — nothing enforces it): before the first code edit
of a non-trivial change, confirm a spec **and** a task packet exist. The spec states the
intended behavior; the task bounds what an agent may touch. Start coding before either exists
and the review has no acceptance bar to reconcile against — the failure the loop prevents.
Trivial work is where the framework's value is lowest. Spend the ceremony where a review needs
a bar. Want it as a hard gate, not a habit? Wire it into your own pre-commit hook; the
canon ships no enforcer.

**Team defaults:** whoever owns the change writes the spec. The reviewer is whoever did not
write the diff — the implementing agent's session never fills its own review packet.

**Optional, when you need them:** the kit's `advanced/` templates are used in place (the
inventory lives in the kit's `advanced/README.md`; the audit template is the recommended first
taste for brownfield teams). Conditioning stances and per-shape implementation guides install
from [the corpus-skills catalog](https://github.com/jcosta33/corpus-skills) into `.agents/skills/`
with `npx skills add jcosta33/corpus-skills` (add `--list` to preview without installing, or copy
the folders).

## 2. Agent-assisted adoption

Hand your coding agent this prompt:

> Adopt the Corpus framework into this repository. Read
> `https://github.com/jcosta33/corpus/blob/main/docs/ADOPTING.md` and
> `https://github.com/jcosta33/corpus-starter-kit` — then perform the manual-adoption
> steps for me: copy the starter-kit repo whole as my workspace, fill its `AGENTS.md` Commands
> table from my real test/lint/build setup (read package.json/Makefile/CI and confirm
> with me), wire my agent tool to `.agents/skills/` if it is not Claude Code, and append
> the gitignore additions to my code repos. This is additive — do not delete or
> overwrite my files; stop and ask on any conflict.

## 3. CLI adoption

`corpus init` does the above mechanically. It scaffolds the workspace into a new or existing
repo, conflict-safe. The reference CLI is optional — the markdown workflow never requires it.
Its design and boundary are in the [CLI reference](reference/future-cli.md) (the live command
list is the CLI's own catalogue).

It picks its layout by directory emptiness. An **empty** dir (a fresh `git init` with no
committed files counts) gets the full **workspace** layout: `templates/`, `specs/`, `tasks/`,
`reviews/`, `intake/`, the skills. A **non-empty** dir gets the thin **footprint** layout — a
pointer `AGENTS.md` plus `.gitignore` — assuming it's a code repo pointing at a separate workspace.
For the full workspace inside an existing or non-empty repo (a co-located workspace, or a docs
repo), pass `--workspace`: `corpus init --from <kit> --workspace`. `corpus init` announces the
layout it chose. Re-running with `--workspace` over a prior footprint init upgrades the pointer
`AGENTS.md` to the full one, backing the stub up.

## Code repos

A code repo that implements against your specs needs **nothing**. At most:

- a one-line pointer in its `AGENTS.md`: _"Corpus workspace: `<path-or-url>` — read the task packet you are given before coding"_;
- the `implement-task` guide copied into its skills directory;
- the workspace's `.gitignore.additions` lines appended to its `.gitignore` (agent scratch and future CLI state — the _workspace_ commits its artifacts and needs none of it).

The agent works from the task packet; the PR links the workspace review packet. Specs, reviews,
and findings never live in the code repo (convention — nothing enforces it). That keeps the
workspace authoritative, which is the point.

**Brownfield precondition — sync the base before opening PRs.** Before cutting per-task branches
against a code repo, confirm its local default branch is in sync with `origin/<default>`. If the
local base is _ahead_, every task branch carries those unpushed commits into its PR. Fast-forward
push them, or branch from a different base first. This is a checklist step (nothing enforces it).
`corpus worktree create` flags an ahead-of-remote base as a non-fatal advisory, but the reconcile
decision is yours.

## Upgrading

You copied the kit whole, so there's no automatic upgrade. That's the point: nothing reaches
into your repo. Instead, **watch and re-copy**. Each kit release records what changed in its
[CHANGELOG](https://github.com/jcosta33/corpus-starter-kit/blob/main/CHANGELOG.md) under
[semantic versioning](https://semver.org). You can tell a safe addition (minor/patch) from a
layout change to reconcile (major) before pulling anything.

With the optional CLI, `corpus update --check` reads the `.agents/.corpus-version` stamp written at
`corpus init`. It tells you whether your copy is behind the kit, with the changelog delta — a
read-only staleness signal that decides nothing and pulls nothing.

To upgrade, re-copy `templates/`, `.agents/skills/`, and `hooks/` from a newer kit checkout. Your
specs, tasks, reviews, findings, decisions, board, and `AGENTS.md` are yours; the kit never
touches them. Re-copying the kit-owned files is safe unless you customized one (the CHANGELOG
flags those). `corpus update --write` does exactly this re-copy. It refreshes only the kit-owned
guidance (`templates/`, `.agents/skills/`, `advanced/`, `hooks/`) and leaves every artifact in
that "yours" list untouched. A guide you customized is backed up to `<file>.corpus-bak` so the
kit's version can land without losing your edits — reconcile, then delete the backup. The same
pin-and-re-pull model holds for the [corpus-skills catalog](https://github.com/jcosta33/corpus-skills)
(`npx skills`) and [corpus-cli](https://github.com/jcosta33/corpus-cli): pin to a release, re-pull
when you choose.
