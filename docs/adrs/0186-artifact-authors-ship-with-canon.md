---
type: adr
id: adr-0186
status: accepted
created: 2026-08-26
---

# ADR-0186 - Artifact authors ship with canon; universal methods leave the family

## Context

[ADR-0137](./0137-personal-harness-transient-artifacts.md) settled on one globally installed skill
family beside the canon. [ADR-0140](./0140-skills-are-the-product-tools-reinforce.md) made skills the
product. [ADR-0157](./0157-ruthless-skills-and-closed-artifact-authorship.md) closed artifact
authorship to the `sus-*` skills.
[ADR-0181](./0181-evidence-settled-decisions-and-bounded-panels.md) and
[ADR-0182](./0182-concurrent-independent-panel-pass.md) added a panel that wrote a `panel` artifact.

That layout coupled two things with different owners. The artifact authors are Suspec: their section
lists, ID prefixes, and frontmatter are the same contract that `checks/checks.yaml` and
`docs/reference/artifact-formats.md` define, and a contract change had to travel across two
repositories to stay true. The universal methods are not Suspec: verification, review, deliberation,
sequencing, compression, and memory carry no Suspec vocabulary and answer in chat. Keeping both in
one catalog made the canon's own gate reach into a sibling repository to lint its own contract.

[ADR-0184](./0184-two-doors-drill-native-review.md) already deleted the review packet and moved
independent review to native surfaces, which removed the last artifact author that a universal
method could plausibly own.

## Decision

1. **Artifact authors ship with the canon.** `sus-spec`, `sus-task`, `sus-inventory`,
   `sus-change-plan`, `sus-audit`, `sus-research`, and `sus-campaign` live in this repository under
   `skills/`, with their catalog, edit contract, and design evidence beside them. Install them with
   `npx skills add jcosta33/suspec`.
2. **Universal methods leave the family.** The methods that write no document move to
   `jcosta33/skills`, a personal catalog with no Suspec dependency. This repository states where
   they are and asserts nothing about their contents.
3. **The canon lints its own contract.** `scripts/lint-artifact-skills.sh` replaces the delegation
   to the sibling catalog's gate, and `scripts/test-lint-artifact-skills.sh` proves it still bites.
   `lint-method-topology.sh` no longer resolves a skills repository, and the released-changelog
   delegation retires with the catalog that owns it.
4. **Panel stops being an artifact.** A panel returns its recommendation, comparison, dissent, and
   unknowns in chat. Checks contract `0.27.0` removes `panel` from the recognized artifact types, so
   `type: panel` is now an unknown type and a blocking usage error. `docs/reference/checks.md` and
   `docs/reference/artifact-formats.md` drop it in the same change.
5. **Two names change for legibility.** `disrespec` becomes `debloat` and `fork-me` becomes
   `ask-user`. Procedures are unchanged; the names now say what the skills do.

## Narrowed decisions

- [ADR-0137](./0137-personal-harness-transient-artifacts.md): the globally installed family is canon,
  CLI, and MCP. A separate skill-catalog repository is no longer a member.
- [ADR-0115](./0115-synced-catalogs-links-or-gated.md): the artifact-author catalog is now local, so
  its coherence is gated in this repository instead of synced across repositories.
- [ADR-0157](./0157-ruthless-skills-and-closed-artifact-authorship.md): artifact authorship stays
  closed, and the closed set now ships with the contract it writes against.
- [ADR-0181](./0181-evidence-settled-decisions-and-bounded-panels.md) and
  [ADR-0182](./0182-concurrent-independent-panel-pass.md): the panel method survives unchanged; only
  its durable artifact is withdrawn.
- [ADR-0183](./0183-single-file-skills-and-role-routed-models.md): single-file skills still hold, and
  the artifact-author gate now enforces that rule where those skills live.

## Consequences

- A contract change to an artifact shape now travels as one repository-local unit.
- Adopters install from two sources and must remove the old `disrespec`, `fork-me`, and `sus-panel`
  entries before reinstalling; `npx skills add` does not prune renamed names.
- An existing `type: panel` file stops checking clean. Nothing converts it; a panel that mattered
  becomes an ordinary project record.
- Contract `0.26.0` withdrew the review packet and `0.27.0` withdraws the panel type. Both are
  removals; a checker that recognizes fewer types rejects more input, so adopters holding either
  file must move it before upgrading.

## Status

Accepted (2026-08-26). Narrows ADR-0115, ADR-0137, ADR-0157, ADR-0181, ADR-0182, and ADR-0183.
