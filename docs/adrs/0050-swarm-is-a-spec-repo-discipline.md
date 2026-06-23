---
type: adr
id: 0050-corpus-is-a-spec-repo-discipline
status: accepted
created: 2026-06-07
updated: 2026-06-07
supersedes:
superseded_by:
---

# ADR-0050: Corpus is a spec-repo discipline; the code repo stays pristine

> **Refined by [ADR-0051](./0051-complete-the-spec-repo-pivot.md).** Specs and intent artifacts now live
> **top-level** (`specs/`, `adrs/`, …), not under `.agents/specs/` as written below — `.agents/` holds only
> tooling. The kit also ships the **authoring skills only** (the 17 code-implementation skills are
> `docs/library/code-skills/` reference). Everything else here stands.

## Context

[ADR-0049](./0049-minimal-install-no-mount-no-imposed-workspace.md) cut adoption to a goldilocks set of six
`.agents/` folders, but still assumed **one adopted repo** holding the skills, the specs, and the
execution scratch together. Pushing on real adoption surfaced that this is the wrong default:

- **Intent is curated by a few; code is written by many, across repos.** A spec ("auth must work this
  way") often governs **several** code repos (web, mobile, backend). Co-located, a cross-cutting spec has
  no home and gets duplicated. In an enterprise, reviewers/architects curate intent with their own review
  process; developers pick it up. That is a **spec/documentation repo**, separate from code.
- **The code repo must stay pristine.** Developers reject tools that litter their codebase. A repo should
  hold its real sources of truth and its code — not a tool's working files.
- **SOL is an authoring aid, not a reading burden.** SOL's English-shaped keywords force the _author_ to be
  unambiguous, testable, and bounded; a capable agent **reads** a good SOL spec with no grammar manual. So a
  code repo needs **no SOL-reading skill and no reference cards** — the spec itself is the interface.
- **The PR is already the trace.** A trace ("obligation X is satisfied by this code, here's the evidence")
  and a verdict are exactly what a **PR + CI + review** provide — they simply aren't keyed to obligation
  IDs. A `trace.md`/`review.md` file in the code repo mostly **duplicates the PR**.
- **Humans are the glue.** With no runtime, a human/agent carries structured intent from the spec into a
  code repo and opens a PR. Adoption should be designed around that, not around an automated compiler.

This maps cleanly onto Corpus's own model: **spec repo = desired truth; code repo = reality; a coverage
record = observed satisfaction.** The intent/reality split _is_ the repo boundary.

## Decision

1. **Two topologies, spec-repo-led.** A **spec/documentation repo** is where Corpus lives (specs + PRDs /
   RFCs / ADRs / audits / findings + the authoring kit + memory + a lightweight coverage record). **Code
   repos** consume specs and stay pristine. **Co-located** (specs and code in one repo) is the degenerate
   case — the same model with the two repos collapsed; it needs no separate machinery and remains the right
   choice for a solo / single-repo project.
2. **The kit splits.** The **authoring kit** (the `write-*` guides, `lint`/`improve`/`lower`/`decompose`/
   `review`/`promote` guides, the `reference/` cards, the `persona-*` stances, the templates) installs into
   the **spec repo**. The **implementing kit** is one optional skill — `implement-and-verify` (+ a persona
   if wanted) — for a **code repo**.
3. **The code repo stays pristine.** **No required Corpus footprint.** No specs (they live in / are
   referenced from the spec repo), no SOL-reading skill, no `reference/` cards. Anything an agent generates
   while implementing (task frames, scratch, transient traces) is **gitignored**. Anything durable (a
   learning, a decision, discovered drift) flows **back to the spec repo as a linked PR**, never as litter
   in the code repo. The most a code repo commits is a `.gitignore` line and, if the developer chooses, the
   `implement-and-verify` skill.
4. **The PR is the default trace/verdict.** A code-repo PR **references the obligation IDs** it satisfies;
   CI is the proof; review is the verdict; the spec repo's coverage record aggregates it. A structured
   `trace.md`/`review.md` is **opt-in** — for audit/compliance, or once a real tool consumes it — never a
   code-repo default.
5. **Multi-repo specs ride existing SOL machinery.** Namespaced obligation IDs and cross-spec references
   (`spec-id#AC-001`) already let a code repo's PR name an obligation in the central spec. No new grammar.
6. **Drop the per-repo version marker.** Remove the adopter-side version file (the `.corpus-version` mirror)
   and conformance check (d). The only load-bearing version is the **language** version, which already
   travels in each spec's frontmatter (`corpus_language: SOL/0.1`). This refines the package axis of
   [ADR-0041](./0041-two-axis-versioning.md); the language axis is unchanged.

This **refines [ADR-0049](./0049-minimal-install-no-mount-no-imposed-workspace.md)** — its six `.agents/`
folders are now the **spec repo's** authoring workspace; a code repo gets near-zero — and **refines
[ADR-0041](./0041-two-axis-versioning.md)** (the package-version marker is dropped for adopters). It changes
**no** closed set, the SOL grammar, the pass pipeline, or the reconciliation design.

## Alternatives considered

| Alternative                                                        | Why rejected                                                                                                                                                                 |
| ------------------------------------------------------------------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Keep the single adopted-repo model (0049 as-is)                    | Doesn't serve multi-repo / cross-cutting specs or the enterprise author-vs-consume split, and still puts Corpus files in the developer's code repo.                          |
| Require an implementing kit / SOL-reading skill in every code repo | Contradicts "SOL is self-legible to a reader" and "the code repo is the developer's." The spec is the interface; mandating skills is pollution.                              |
| Keep structured `trace.md`/`review.md` in the code repo by default | Re-invents the PR + CI + review, which already are the trace/verdict. Reserve structured traces for audit-heavy cases.                                                       |
| Pin specs into code repos via git submodule/URL                    | Heavier machinery than the "humans are the glue" reality needs; reference-by-ID in the PR is lighter and matches how teams already cite RFCs/ADRs. (Left open as an opt-in.) |

## Consequences

- **Positive:** code repos stay clean; one spec can govern many repos; the author→review→consume flow fits
  how organizations already work; Corpus is honestly positioned as a spec/documentation discipline, not
  something that lives in your code.
- **Negative:** teams stand up two repos, and the spec↔code reconciliation crosses a repo boundary. But
  there is **no automated loop to break** — reconciliation is human/agent-mediated today, so the spec is
  simply pulled from a central place. Trust is **earned, not enforced**: a great spec makes agent output
  _likely and checkable_, not guaranteed; the guarantee comes from spec quality + the developer running the
  verify discipline.
- **Neutral:** the obligation model, every closed set, the SOL grammar, the nine passes, and the
  intent/reality/observed reconciliation **design** are unchanged — only _where files live_ and _what a code
  repo carries_ change.

## Status

Accepted (v0.1). `ADOPTING.md`, `model/workspace.md`, `positioning.md`, `README.md`, and `PRINCIPLES.md` are
reworked around the two topologies; the kit is renamed `install/` → `starter-kit/` and split
authoring/implementing; the `implement-and-verify` skill is added; the version marker + conformance check
(d) are dropped. The prose de-jargon and verbosity cuts flagged in 0049's Status remain a separate
follow-up.

## Affected obligations / constraints

- Refines: [0049](./0049-minimal-install-no-mount-no-imposed-workspace.md) (its `.agents/` set is the spec
  repo's; the code repo gets near-zero), [0041](./0041-two-axis-versioning.md) (package-version marker
  dropped for adopters; language axis unchanged).
- Depends on: [0047](./0047-skills-are-self-contained.md) (self-contained skills make a one-skill
  implementing kit viable).
- Does NOT change: the obligation grammar, any closed set, the nine passes, or the reconciliation design.

> **Ledger note (2026-06-11):** refined by ADR-0060, ADR-0062.
