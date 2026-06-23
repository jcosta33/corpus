---
type: adr
id: adr-0059
status: accepted
created: 2026-06-11
updated: 2026-06-11
---

# ADR-0059 — Frontmatter `type:` is the sole artifact discriminator

## Context

Artifact identification previously hinged on a filename infix; the adopter audit (O-012 §1) found a naming
convention with no consuming tool to be pure ceremony that fights editors, renderers, and casual file
operations, and the strategic synthesis directs plain `.md` everywhere. The workspace model already
identified artifacts by frontmatter in practice.

## Decision

1. Every Corpus artifact is a plain `.md` file whose **frontmatter `type:`** identifies it
   (`spec | task | review | finding | status | intake | inventory | change-plan | audit | bug-report |
   adr | research | prd | rfc | threat-model`). Tools and agents discriminate on `type:`, never on filename.
2. No Corpus file, template, example, or fixture uses a `.swarm.` filename infix. The optional stricter
   spec surface is selected by `format: sol` (ADR-0058) — frontmatter, not filename.
3. The names `*.swarm.ir.json` and `*.swarm.plan.json` survive **only** as reserved contract names on the
   future-CLI page for machine-emitted artifacts no shipped tool produces today.

## Alternatives considered

| Alternative | Why weaker |
|---|---|
| Keep the infix as an optional convention | A residue with no remaining function once `format: sol` exists; two selectors invite drift |
| Discriminate by directory | Breaks on co-located and small-team layouts; `type:` travels with the file |

## Consequences

Positive: zero naming ceremony; renders everywhere; enterprise-friendly. Negative: tools must read
frontmatter (trivial). Neutral: greppability moves from filename to `type:` line.

## Status

Accepted. Supersedes the filename-infix partition model of the former source-artifacts reference; refines
ADR-0030 and ADR-0054.

## Propagation

All file-producing surfaces; conformance manifest (`format: sol` selector); swarm-cli parser targets.

> **Addendum (2026-06-11):** the reserved machine-artifact contract names are spelled without the
> infix — `<spec>.ir.json` / `<spec>.plan.json` — consistent with §2; the future-CLI page is their
> only home. No IR fixtures ship; the schemas are the contract.
