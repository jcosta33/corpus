# Adoption

## Install skills

Install globally for your harness (Codex shown):

```bash
npx skills add jcosta33/suspec -g -a codex
```

This installs the artifact authors. Universal working methods install separately from
[jcosta33/skills](https://github.com/jcosta33/skills):

```bash
npx skills add jcosta33/skills -g -a codex
```

Suspec does not annex the repository: its commands, architecture, and policy stay in native
instructions.

Re-running `npx skills add` updates present entries but does not remove names absent from the source.
After a catalog removal, delete only obsolete Suspec entries with
`npx skills remove -g -a <agent> <names...>`, then reinstall. Preserve unrelated skills.
The catalogs split: the `sus-*` authors moved here and the universal methods moved to
`jcosta33/skills`. Remove `sus-review`, `sus-panel`, `disrespec`, and `fork-me` explicitly, then
install both sources so `panel`, `debloat`, `ask-user`, and `drill` land.

## Add the optional CLI

The CLI is unpublished. Install it from source with Node.js 22.6 or newer:

```bash
git clone https://github.com/jcosta33/suspec-cli
cd suspec-cli
corepack enable
pnpm install --frozen-lockfile
pnpm link --global
```

The repository pins pnpm 10 through Corepack.

Run:

```bash
suspec check <path>
```

It reads explicit absolute or current-working-directory-relative paths and adds no repository
configuration. Exact behavior: [CLI reference](reference/cli.md).

## Add the optional global policy

Preview the exact user-level changes, then apply only the approved harnesses:

```bash
suspec setup codex claude-code kimi-code zcode opencode cursor antigravity
suspec setup codex claude-code kimi-code zcode opencode cursor antigravity --yes
suspec setup codex claude-code kimi-code zcode opencode cursor antigravity --check
```

The policy cuts narration and repetition, keeps durable findings in the work, and routes context
through lean-ctx and RTK when available. It preserves required questions, warnings, blockers, exact
evidence, and failed verification. Setup adds one neutral inline block to each harness's native global
instruction file and writes nowhere else. Remove it reversibly:

```bash
suspec setup codex claude-code kimi-code zcode opencode cursor antigravity --remove
suspec setup codex claude-code kimi-code zcode opencode cursor antigravity --remove --yes
```

`npx skills` installs workflows. `suspec setup` installs global interaction rules. Neither substitutes
for the other.

## First structured run

1. Use `sus-spec` to write intent and requirements with stable IDs and `Verify with:` lines.
2. Carry its absolute path from `~/.agents/artifacts/<workspace>/`.
3. Implement from that path and preserve real verification output.
4. Have a non-implementer review the result on the native PR. The implementer cannot accept.
5. Optionally run `suspec check` against the spec, task, change plan, or campaign involved.
6. Route durable findings to native memory or project records.
7. After the final consumer finishes, choose Delete, Leave, or Promote for the complete transient
   artifact set.

A trivial fix skips this workflow. Do not bill obvious work for ceremony. State intent and
verification inline. See the [bug-fix example](examples/bug-fix.md) and
[tutorial](tutorial/README.md).

No fresh reviewer means no independent review. Direct self-review may find defects; it cannot close
work whose risk requires independence.

## Without the CLI

Write the documented [artifact shapes](reference/artifact-formats.md), run each verification, preserve
real output, and have a non-implementer review every requirement. Treat empty evidence as unverified.
The CLI automates structural checks only.

## Teams

The canonical machine contract is `checks/checks.yaml`; the CLI ships its matching implementation.
Teams decide which reported levels block CI and may add project-owned checks. Editing a local contract
copy does not reconfigure the CLI.

Suspec commits nothing by default. Your project remains your project: it owns code, tests, decisions,
guides, PRs, and any explicitly promoted artifact.
