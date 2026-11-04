---
type: adr
id: adr-0188
status: accepted
created: 2026-11-05
---

# ADR-0188 - The product is named Corpus

## Context

The product has carried three names, and no decision record covered either rename:

- **Swarm** until 2026-06-23.
- **Corpus** from 2026-06-23 (commits `3e32399`, `e9ed49b`, `d182340`).
- **Suspec** from 2026-06-30 (commit `367d995`).

Both renames ran as product-wide find-and-replace sweeps. The 2026-06-30 sweep altered sentences
inside immutable ADR bodies, and those were restored by later repair commits (`fad0458`, `619dc4e`).

The Suspec name described a spec-centred product with a checker, an MCP server, a website, and a
setup command. [ADR-0187](./0187-retire-checker-mcp-website-and-setup-policy.md) retired every one
of those surfaces. What remains is a set of standalone skills that write durable, evidence-bound
working artifacts. That set is a body of working documents, which is what Corpus names.

GitHub keeps redirects after a repository rename. `jcosta33/swarm` and `jcosta33/corpus` already
redirected to this repository, and the skills repository already answers to its old names.

## Decision

1. **The product is Corpus.** Current prose, the README, the skills, the artifact-author catalog,
   and the ledger front matter say Corpus.
2. **The repository is `jcosta33/corpus`.** The `jcosta33/suspec` name stays as a GitHub redirect,
   and installs use `npx skills add jcosta33/corpus`.
3. **The skill prefix is `corpus-`.** Installed skills are named `corpus-<type>`.
4. **Universal methods are unbranded.** They stay in `jcosta33/skills` and carry no product prefix.
5. **History stays historical.** Accepted ADR bodies and file names keep the names they were
   written with, including `suspec` in file names such as `0060-suspec-workspace.md`. Readers
   resolve Swarm and Suspec in those bodies through this record.
6. **Renames are hand-edited.** Rename prose file by file. A cross-file find-and-replace is not an
   acceptable rename method, because it already corrupted ADR bodies once.
7. **The CI history-base variable is `CORPUS_HISTORY_BASE`.**

## Consequences

- Installs pinned to `jcosta33/suspec` keep resolving through the redirect. New installs use the
  Corpus name.
- Installed `sus-*` skills must be removed by name. Replacing them does not remove them.
- ADR bodies continue to say Swarm or Suspec where they were written that way. This record is the
  key.

## Status

Accepted (2026-11-05).
