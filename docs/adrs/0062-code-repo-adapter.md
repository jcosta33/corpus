---
type: adr
id: adr-0062
status: accepted
created: 2026-06-11
updated: 2026-06-11
---

# ADR-0062 — Code-repo adapter: pristine today, gitignored CLI state when a CLI exists

## Context

Corpus's workspace holds intent and evidence; code repos hold code. The committed-dotdir norm
(`.github/`, `.vscode/`) shows teams tolerate committed tool directories, but a spec workflow that
litters every implementing repo multiplies its footprint by the number of repos and couples them to the
workspace's conventions. ADR-0050 already allows gitignored scratch in code repos.

## Decision

1. **Today (no Corpus tooling ships):** a code repo needs nothing. At most: a one-line pointer in its
   `AGENTS.md` ("Corpus workspace: <path/url>; read the task packet you are given"), the kit's
   `.gitignore.additions`, and optionally the `implement-task` agent guide copied into the repo's skills
   directory. Task packets are handed to the agent by paste or path; transient files stay gitignored.
   The PR links the workspace review packet — the PR is the merge mechanism, the packet is the record.
2. **When a CLI exists,** it may own a fully **gitignored** `.swarm/` local-state directory in code repos
   (`config.yaml`, `work/`, `cache/`, `tmp/`) — machine state in the `.git/`/`node_modules/` sense, never
   committed, never required by the markdown workflow, specified only on the future-CLI page.
3. Committed Corpus content in code repos remains out of bounds (convention level): specs, reviews, and
   findings belong to the workspace.

## Alternatives considered

| Alternative | Why weaker |
|---|---|
| Committed `.swarm/` in code repos (the dotdir norm) | Multiplies footprint across repos; couples every repo to workspace conventions; the workspace already is the committed home |
| Forbid `.swarm/` even for the future CLI | A CLI needs local state; pretending otherwise re-creates dishonest docs |

## Consequences

Positive: adopting Corpus never dirties a product repo. Negative: agents must be pointed at the workspace
explicitly. Neutral: deviates deliberately from the committed-dotdir norm (recorded counter-evidence).

## Status

Accepted. Reaffirms ADR-0049 and ADR-0050 (clarification; the gitignored-scratch clause of 0050 is the
ground for §2).

## Propagation

docs/03/07/10, ADOPTING, kit `.gitignore.additions` + `implement-task` guide, future-cli page.
