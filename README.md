# Corpus

**Standalone skills that write durable, evidence-bound working artifacts for agent work.**

Agents get the mechanical work; humans keep intent, material decisions, and acceptance. Each skill
installs on its own and writes one plain-Markdown artifact outside your repository. Your harness
writes the code.

## Install

```bash
npx skills add jcosta33/corpus -g
```

That installs the [artifact authors](skills/README.md). Universal working methods such as
verification, review, deliberation, sequencing, and compression install separately from
[jcosta33/skills](https://github.com/jcosta33/skills).

## Use the least structure that pays

A trivial fix needs no file. Paperwork is not progress:

```text
Fix: expired refresh tokens must redirect to /login, not 500.
Verify with: pnpm test:run auth-refresh-expired-token
```

Implement it, run the command, and preserve the output. Close it through direct non-implementer
review of the final diff and output in the project's native PR, CI, or conversation surface. No
artifact needed.

When intent needs a structured working contract, `corpus-spec` writes a spec with observable
requirements:

```markdown
### AC-001 - CSV export honors the selected date range
- When: a user exports a filtered report
- Then: the export endpoint MUST filter rows to the selected date range before generating the CSV
- Verify with: `pnpm test:run export-date-range-filter`
```

Artifacts live outside the repository at `~/.agents/artifacts/<workspace>/<ID>.md` and move by
absolute path. See [where artifacts live](docs/method.md#where-artifacts-live).

## Method

Every change states intent, receives review, and decides what it taught. Extra structure must pay
for itself:

- a spec when one precise sentence cannot govern the work, staged when structural work must
  preserve behavior;
- an audit when present behavior, ownership, or risk needs evidence;
- research when a decision needs evidence it does not yet have;
- a campaign when one durable goal spans several pull requests.

Corpus does not replace native plan mode, project guidance, issue trackers, PRs, CI, tests, or human
acceptance. Skills install globally; repository commands, architecture, and policy stay in the
repository that owns them.

Start with [the method](docs/method.md). Exact shapes live in [formats](docs/formats.md) and terms in
the [glossary](docs/glossary.md). Decision history lives in the [ADR ledger](docs/adrs/README.md).
