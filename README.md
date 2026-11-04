# Suspec

**Standalone skills that write durable, evidence-bound working artifacts for agent work.**

Agents get the mechanical work; humans keep intent, material decisions, and acceptance. Each skill
installs on its own and writes one plain-Markdown artifact outside your repository. Your harness
writes the code.

## Install

```bash
npx skills add jcosta33/suspec -g -a codex
```

That installs the [artifact authors](skills/README.md). Universal working methods — verification,
review, deliberation, sequencing, compression, memory — install separately from
[jcosta33/skills](https://github.com/jcosta33/skills).

Re-running `add` does not prune. Remove leftover `sus-review`, `sus-panel`, `disrespec`, and
`fork-me` before re-adding.

## Use the least structure that pays

A trivial fix needs no file. Paperwork is not progress:

```text
Fix: expired refresh tokens must redirect to /login, not 500.
Verify with: pnpm test:run auth-refresh-expired-token
```

Implement it, run the command, and preserve the output. Close it through direct non-implementer
review of the final diff and output in the project's native PR, CI, or conversation surface. No
artifact needed.

When intent needs a structured working contract, `sus-spec` writes a spec with observable
requirements:

```markdown
### AC-001 — CSV export honors the selected date range
- When: a user exports a filtered report
- Then: the export endpoint MUST filter rows to the selected date range before generating the CSV
- Verify with: `pnpm test:run export-date-range-filter`
```

Ordinary artifacts live outside the repository under `~/.agents/artifacts/<workspace>/` and move
by absolute path. See [where files live](docs/03-where-files-live.md).

## Method

Every change states intent, receives review, and decides what it taught. Extra scaffold must pay for
itself:

- a spec when one precise sentence cannot govern the work;
- a task when one spec must split into separately dispatchable slices;
- an inventory when present behavior or ownership is unclear;
- a change plan when structural work must preserve behavior across stages;
- an audit when present-state risk needs evidence;
- research when a decision needs evidence it does not yet have;
- a campaign artifact when one durable goal spans several pull requests.

Suspec does not replace native plan mode, project guidance, issue trackers, PRs, CI, tests, or human
acceptance. Skills install globally; repository commands, architecture, and policy stay in the
repository that owns them.

## Fit

Use Suspec when a change outgrows direct attention, several workers share it, or someone must later
reconstruct intent and proof. Skip it when native planning, project instructions, tests, and direct
review already make the work obvious.

Agents assess and recommend. Humans own intent, waivers, irreversible actions, and acceptance. The
implementer cannot accept their own work.

Start with [the basic workflow](docs/02-basic-workflow.md). Exact formats live under
[reference](docs/reference/). Decision history lives in the [ADR ledger](docs/adrs/README.md).
