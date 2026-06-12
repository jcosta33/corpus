# Adopting Swarm

*Works today — plain markdown plus your agent; no Swarm tooling required.*

Swarm is files, not software. The starter kit **is** a complete workspace — adoption is one
copy plus one bootloader to fill in. Three paths, in order of preference.

## 1. Manual adoption (one copy, ~15 minutes)

Copy the kit whole from its template repo —
[`jcosta33/swarm-starter-kit`](https://github.com/jcosta33/swarm-starter-kit) — as a dedicated
workspace repo or a folder inside your project ([where files live](03-where-files-live.md)):

```sh
# dedicated workspace repo
gh repo create my-workspace --template jcosta33/swarm-starter-kit   # or clone and re-init:
git clone https://github.com/jcosta33/swarm-starter-kit my-workspace \
  && rm -rf my-workspace/.git && git -C my-workspace init

# or co-located inside your project
git clone https://github.com/jcosta33/swarm-starter-kit /tmp/kit \
  && cp -R /tmp/kit/. <your-project>/workspace/ && rm -rf <your-project>/workspace/.git
# (cp -R with the trailing dot keeps the kit's symlinks; -r would replace them with stale copies)
```

Windows: a default clone or copy materializes the kit's three symlinks as small text files
(git `core.symlinks=false`). Either enable Developer Mode and clone with
`-c core.symlinks=true`, or replace `.claude/skills` with a real copy of `.agents/skills/`.

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
5. **Write one spec** for your next non-trivial change: `specs/<feature>/spec.md`. Run the
   loop once.

Team defaults, stated once: whoever owns the change writes the spec; who reviews is whoever
did not write the diff — the implementing agent's session never fills its own review packet.

Optional, when you need them: the kit's `advanced/` templates are used in place (the
inventory is in the kit's `advanced/README.md`; the advanced audit template is the
recommended first taste for brownfield teams), and conditioning stances plus
per-change-shape implementation guides install from
[the swarm-skills catalog](https://github.com/jcosta33/swarm-skills) into `.agents/skills/`
(`npx skills add jcosta33/swarm-skills --list`, or copy the folders).

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

## 3. Future CLI adoption

`swarm init` will do the above mechanically. It does not exist yet — the contract
is [reference/future-cli.md](reference/future-cli.md).

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

## Upgrading

Re-copy `templates/` and `.agents/skills/` from a newer kit checkout. Your specs, tasks,
reviews, findings, decisions, board, and `AGENTS.md` are yours — the kit never touches
them.
