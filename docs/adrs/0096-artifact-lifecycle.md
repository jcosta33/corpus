---
type: adr
id: adr-0096
status: accepted
created: 2026-06-22
updated: 2026-06-22
---

# ADR-0096 — Artifact lifecycle at scale: durable-vs-ephemeral records, status + supersede, retention, freshness, and anti-duplication

## Context

After hundreds of specs over years, do review files live forever? How do artifacts coexist and stay
findable? A web-verified evidence pass (corpus-hq #54; sources below, each verified June 2026 with
honest tiers) gives a principled lifecycle drawn from records-management and large-org documentation
practice.

- **Durable vs ephemeral has a principled test.** A record is durable when it is "evidence of
  decision-making"; transitory records are "routine records of short-term value (generally less than
  ~180 days)," disposed of when no longer needed ([[NARAGRS52]] — not a hard cutoff). The
  records lifecycle is appraisal → a **retention schedule** → disposition (retain / transfer /
  archive / destroy) ([[ISO15489]]). CI/run artifacts are ephemeral by industry default — GitHub
  Actions retains them **90 days**, GitLab **30** ([[GHRETENTION]], [[GLRETENTION]]).
- **Decisions supersede, never rewrite.** ADRs are numbered sequentially with no reuse, carry a
  **status**, and a reversed decision is _kept and marked superseded with a pointer to its
  replacement_ — not altered or deleted ([[NYGARDADR]]); the `NNNN-title.md` + status pattern scales
  to thousands per repo ([[MADR]]).
- **Write-once fails at scale; the dominant failure is duplication.** ~29% of the most-popular GitHub
  projects currently carry an outdated doc reference ([[DOCROT]]); "documents without owners become
  stale," freshness reminders help (a ~3-month example), and at scale a dominant failure mode is
  **duplication, not just absence** (the Borg case: 7–10 overlapping docs, no owner) ([[SWEGBOOKDOCS]]).

corpus's `docs/adrs/` already numbers sequentially and its ADR frontmatter already carries
`status`/`supersedes`/`superseded_by` — so the decision lifecycle is half-convention already; the
gap is stating it, extending it to specs, and adding the durable/ephemeral + retention + freshness
layer.

## Decision

1. **Durable-vs-ephemeral is a first-class rule** (`docs/03-where-files-live.md`, convention).
   **Durable records** — decisions (ADRs), specs of record, saved findings — persist for the repo's
   life and **supersede-not-delete**. **Transitory output** — review packets, `corpus check` output,
   run logs — ages out: keep it in git history (the default archive) or an `archive/` directory, with
   a retention window in the **30–90-day band** (anchored to GitHub 90 [[GHRETENTION]] / GitLab 30
   [[GLRETENTION]], not an invented number). _Level: convention._ ([[NARAGRS52]], [[ISO15489]])

2. **Status lifecycle + supersede pointer on decisions and specs** (convention, with a named toolable).
   Status is `proposed | accepted | deprecated | superseded` with a `superseded_by: NNNN` pointer
   (corpus's ADR frontmatter already carries this two-field form; the conceptual single-token is
   "superseded-by-NNNN"); the artifact is kept and only its status changes; numbers are sequential
   and never reused ([[NYGARDADR]], [[MADR]]). A
   **`corpus check` is _specified_ (toolable, in the spirit of C015): every `superseded_by` pointer
   resolves to an existing artifact, and the index lists it** — _named here, not shipped; the corpus-cli
   agent mints the contract entry + implementation_ (no `checks.yaml` change lands with this ADR, to
   avoid contract/impl drift; tracked in corpus-hq #61 §B). _Level: convention now, toolable when the
   check ships._

3. **Freshness + named ownership for durable artifacts** (convention). A durable spec/ADR/finding
   names an **owner**, and durable docs carry a freshness review window (a ~3-month example, presented
   as convention not a measured optimum) ([[SWEGBOOKDOCS]]; [[DOCROT]] is the warrant that write-once
   rots). _Level: convention._

3.5. **Single-sourcing is the anti-duplication control** (reinforces the existing rule, MUST-level by
convention). One canonical home per rule/decision; "no canonical owner" is a reviewable defect, and
the failure to guard against is **duplication, not absence** ([[SWEGBOOKDOCS]] Borg). _Level:
convention (the existing single-sourcing rule, sharpened)._

4. **A generated index/board is the discoverability surface** (convention — the weakest-evidence leg,
   labeled as such). A flat per-type folder + a board carrying `ID · title · status · supersedes/
superseded-by` keeps hundreds of artifacts navigable by search-over-a-flat-list. _Level: convention._

## Consequences

- No `checks.yaml` rule and no contract-version bump land here: the supersede/index check is
  specified-not-shipped (corpus-cli follow-up, #61), consistent with the honesty framework (ADR-0063).
- Retention/freshness numbers are anchored, never invented: the 30–90-day band cites GitHub/GitLab,
  the ~180-day transitory bound and the ~3-month freshness reminder are cited as _typical/example_,
  not rules ([[NARAGRS52]], [[SWEGBOOKDOCS]]).
- Scope honesty travels with the citations: [[DOCROT]] is scoped to top-by-stars + Google repos;
  [[ISO15489]] is paywalled (cited by catalog identity + verified clause text); "immutable" is not
  attributed to [[NYGARDADR]] (his words are keep-and-mark-superseded).

## Propagation

`docs/03-where-files-live.md` (the durable/ephemeral + retention + lifecycle + freshness + index
rules), `docs/research/sources.md` (the seven entries above), and the starter kit (an `archive/`
convention + a board note on the supersede lifecycle / board-as-index — the kit board's `State`
column carries status; the `superseded_by` pointer lives in the artifact's frontmatter). The `superseded_by`-resolves /
index-lists `corpus check` is the toolable follow-up (corpus-hq #61 §B), not shipped by this ADR.

## Update (2026-06-22) — the supersede/index check remains specified-not-shipped ([ADR-0097](./0097-mint-c016-c017-defer-oversized.md))

ADR-0097 cleared the deferred-checks backlog under measure-before-ship — minting C016 (pass-needs-evidence)
and C017 (orphaned-reference). The `superseded_by`-resolves / index-lists check named here **stays
specified-not-shipped**: only two real artifacts carry a filled `superseded_by` pointer today, and the
scanned workspace tree does not yet include the ADR ledger where the lifecycle lives — too thin a corpus
to validate a "the pointer resolves + the board lists it" invariant against. It mints when the
`superseded_by` corpus and a scanned index are real. Recorded in ADR-0097.
