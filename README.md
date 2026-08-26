# Suspec

**Put coding agents on rails. Keep humans on the decisions.**

Suspec ships as standalone skills: explicit intent in, evidence out, human decisions where they
matter. A deterministic CLI catches structural holes without a model. Your harness writes the code.
Plain Markdown keeps the work portable and the repository clean.

Skills install independently. Use the one the work needs.

## Install

Install the skill family for your harness (Codex shown):

```bash
npx skills add jcosta33/suspec-skills -g -a codex
```

Re-running `add` does not prune. After 5.0.0, remove leftover `sus-review`, then re-add the family
so `drill` installs. Cutover detail: [adoption](docs/ADOPTING.md).

Skills install the workflows. Add [suspec-cli](https://github.com/jcosta33/suspec-cli) for
deterministic checks and the optional global agent policy:

```bash
suspec setup codex claude-code kimi-code zcode opencode cursor antigravity
suspec setup codex claude-code kimi-code zcode opencode cursor antigravity --yes
```

The first command previews. The second applies the approved user-level change. Neither touches a
repository.

## Use the least structure that pays

A trivial fix needs no file. Paperwork is not progress:

```text
Fix: expired refresh tokens must redirect to /login, not 500.
Verify with: pnpm test:run auth-refresh-expired-token
```

Implement it, run the command, and preserve the output.
Close it through direct non-implementer review of the final diff and output in the project's native
PR, CI, or conversation surface. No artifact needed.

When intent needs a structured working contract, `sus-spec` writes a spec with observable
requirements:

```markdown
### AC-001 — CSV export honors the selected date range
- When: a user exports a filtered report
- Then: the export endpoint MUST filter rows to the selected date range before generating the CSV
- Verify with: `pnpm test:run export-date-range-filter`
```

Ordinary artifacts live outside the repository under
`~/.agents/artifacts/<workspace>/` and move by absolute path. See
[where files live](docs/03-where-files-live.md).

## Check

```bash
suspec check <path>
```

The checker reports deterministic facts; it does not bless the work. See the [CLI
contract](docs/reference/cli.md) for companions, checks, and exits.

## Method

Every change states intent, receives review, and decides what it taught. Extra scaffold must pay for
itself:

- a spec when one precise sentence cannot govern the work;
- a task when one spec must split into separately dispatchable slices;
- an inventory when present behavior or ownership is unclear;
- `drill` when one seam must lock language, obligation, place, then slice;
- a change plan when structural work must preserve behavior across stages;
- a campaign artifact when one durable goal spans several pull requests.

Suspec does not replace native plan mode, project guidance, issue trackers, PRs, CI, tests, or human
acceptance. Skills install globally; repository commands, architecture, and policy stay in the
repository that owns them.

## Fit

Use Suspec when a change outgrows direct attention, several workers share it, or someone must later
reconstruct intent and proof. Skip it when native planning, project instructions, tests, and direct
review already make the work obvious.

Its distinct mechanism is deterministic reconciliation keyed to requirement IDs. Agents assess and
recommend. Humans own intent, waivers, irreversible actions, and acceptance. The implementer cannot
accept their own work.

## Repositories

| Need                                            | Owner                                                      |
| ----------------------------------------------- | ---------------------------------------------------------- |
| Install the skills                              | [suspec-skills](https://github.com/jcosta33/suspec-skills) |
| Run checks or install global agent rules        | [suspec-cli](https://github.com/jcosta33/suspec-cli)       |
| Give shell-less clients the checker             | [suspec-mcp](https://github.com/jcosta33/suspec-mcp)       |
| Read formats, checks, and decisions             | this repository                                            |

Start with [the basic workflow](docs/02-basic-workflow.md), [adoption](docs/ADOPTING.md), or the
[tutorial](docs/tutorial/README.md). Exact formats and contracts live under
[reference](docs/reference/). Decision history lives in the [ADR ledger](docs/adrs/README.md).
