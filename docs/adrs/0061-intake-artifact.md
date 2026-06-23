---
type: adr
id: adr-0061
status: accepted
created: 2026-06-11
updated: 2026-06-11
---

# ADR-0061 — The intake artifact and the Pull step

## Context

Work usually originates in an external tracker (Jira, Linear, GitHub, Notion). Specs interpret; without a
captured original, nobody can later check what was actually asked, and upstream edits silently orphan the
spec. Structured intake is mainstream practice in the trackers themselves (issue forms/templates).

## Decision

1. **Intake** (`type: intake`) is the thinnest possible snapshot: frontmatter `source`, `url`, `captured`
   (date) plus the upstream content **pasted verbatim** — never edited, never interpreted. The spec cites
   it in `sources[]`.
2. Intake is **recommended when work originates in an external tool**, never required. It is not a spec
   parent with its own pipeline: it is preserved input. PRDs, research, and bug reports remain their own
   (advanced) artifacts.
3. **Pull** is the loop's first step: capture the upstream item into `intake/`, by copy-paste today.
   Tracker connectors are a future-CLI concern (`corpus pull`); this repo ships none.

## Alternatives considered

| Alternative                                   | Why weaker                                                                |
| --------------------------------------------- | ------------------------------------------------------------------------- |
| Spec links the tracker URL only               | Upstream items get edited/deleted; the interpretation loses its anchor    |
| Rich intake schema (fields, labels, comments) | Re-invents the tracker; verbatim paste is the honest, zero-ceremony floor |

## Consequences

Positive: ticket→spec provenance for free. Negative: one more (tiny) file per externally-sourced item.

## Status

Accepted. Refines ADR-0030; partially supersedes ADR-0053's deferral of an intake directory (the
no-connectors clause is reaffirmed).

## Propagation

Template (intake), docs/02/10, workspace tree (0060), conformance fixture, future-cli page.
