# Checks — common mistakes to check for

_Works today — plain markdown plus your agent; no Corpus tooling required._

This page is Corpus's check catalogue, in four parts: the **core checks** every spec should pass
(either form), the **evidence checks** for task and review packets, the **writing-rules
watchlist**, and the **SOL check catalogue** for specs that opt into structured requirements
(`format: sol`). Reviewers use it as a checklist; tools build against it.

Reference implementation: **`corpus check` in corpus-cli**. Wherever this page says a check is
_toolable_, that is the tool meant. This page is the contract — what a correct checker reports; the
reference CLI's design + boundary (and the still-partial `format: sol` routing) is the
[CLI reference](future-cli.md); its live command set is the CLI's own catalogue.

## The honesty legend

Nothing in this repository runs, so nothing on this page is enforced. Every rule here carries one
of four levels — read them literally:

| Level          | What it means                                                             |
| -------------- | ------------------------------------------------------------------------- |
| **convention** | Expected practice. Nothing enforces it.                                   |
| **checklist**  | A reviewer is expected to inspect it during review.                       |
| **toolable**   | A tool can check it mechanically — here, `corpus check` in corpus-cli.    |
| **enforced**   | A shipped tool actually rejects violations. **Today, nothing qualifies.** |

Approved phrasings, used throughout Corpus's docs:

> "This is a convention — nothing in this repository enforces it."
>
> "A future check should flag this; until then, treat it as a review checklist item."

A team may adopt any check as blocking _by policy_ — that is the team's gate, not Corpus's.

Teams write their own checks beyond this generic core. Where those belong, and how to name them so
they don't claim more than they prove, is in
[local checks and the extension boundary](local-checks.md).

## Core checks (any spec, either form)

These apply to every spec, whether it uses plain `### AC-NNN` requirements or SOL blocks. Both
forms encode the same requirement record, so each check means the same thing in both — the
[C ↔ SOL mapping](#how-core-checks-map-to-sol-codes) below shows the correspondence.

**Level: checklist today; toolable — `corpus check` implements exactly this table.**
The _Checker severity_ column is the contract for that tool (see
[the severity split](#the-severity-split-the-corpus-check-contract)), not a claim that
anything blocks today.

| ID   | Name                      | Check                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             | Checker severity |
| ---- | ------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------- |
| C001 | `unique-ids`              | Every requirement ID (`AC-NNN`; `C-NNN`/`I-NNN` in SOL form) appears exactly once in the file.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    | hard error       |
| C002 | `duplicate-id`            | No other file in the workspace claims the same frontmatter `id:`. Requirement ids (`AC-NNN`) are **spec-scoped** — unique within a file (C001) and reused freely across specs; a reference that crosses a spec boundary qualifies as `SPEC-x#AC-NNN` ([ADR-0080](../adrs/0080-spec-scoped-requirement-ids.md)).                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   | hard error       |
| C003 | `verify-with`             | Every requirement carries a `Verify with:` line (SOL form: a `VERIFY BY` line). This is the highest-value line in a spec — a runnable check outperforms prose plans as task input (preliminary evidence) [[ORACLESWE]](../research/sources.md#ORACLESWE).                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         | hard error       |
| C004 | `one-strength-word`       | Each requirement states exactly one strength word — must, must not, should, should not, or may. Two strength words usually means two requirements.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                | warning          |
| C005 | `non-goals-present`       | A Non-goals section exists and is non-empty — what this spec deliberately does not change.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        | warning          |
| C006 | `open-questions-present`  | An Open questions section exists (even if it says "none").                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        | warning          |
| C007 | `no-tbd-at-ready`         | No `TBD`, `TODO`, `???`, or unresolved open question (one not marked non-blocking) remains in a spec at `status: ready`. At `status: draft` these are fine.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       | hard error       |
| C008 | `sources-named`           | Frontmatter `sources:` names at least one origin — a ticket, an intake file, an ADR.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              | warning          |
| C009 | `broken-source-link`      | Every workspace file path or cross-reference ID named in `sources:` or in a requirement resolves to something that exists. External tracker IDs (a bare `JIRA-123`) are exempt — naming them at all is C008 territory.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            | hard error       |
| C010 | `preserves-refs-resolve`  | Every entry in a change plan's `preserves:` frontmatter and its Behavioral-preservation-guarantees table resolves to a real requirement ID (or is an explicit `PG-NNN` plan-local guarantee).                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     | hard error       |
| C011 | `waves-present`           | A change plan whose `kind` is `migration`, `rewrite`, or `schema-change` has a non-empty Transformation waves section, each wave naming its verify step.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          | warning          |
| C012 | `coverage`                | A review packet's coverage table reconciles against its source spec, keyed on the task packet's declared `scope`: every in-scope requirement id has a coverage row (an in-scope id with no row is **uncovered**), and every coverage row names an id present in the source spec (a row naming an absent id is **orphan**). Scope-guarded to **non-draft** source specs (a `draft`'s ids are work-in-progress, the same draft-is-not-final principle as C007's ready gate); when `scope` disagrees with the spec's id set, that divergence is itself surfaced as a fact, not silently resolved. Recorded under [ADR-0079](../adrs/0079-c012-coverage-check.md).                                                                                                                                                                                                                                                                    | warning          |
| C013 | `verify-evidence-binding` | Where a review packet coverage row carries a structured-evidence `verify` block (fenced, `id=AC-NNN cmd="…" result=pass\|fail`, keyed to the row's id; the body verbatim and unparsed), the recorded `cmd` matches the requirement's named `Verify with:` / `VERIFY BY` command and a Pass row's block reads `result=pass`; a structured mismatch (a `cmd` disagreeing with the named command, a `result=fail` under a Pass row, a malformed or duplicate block) is surfaced as an internal-consistency fact, and a Pass row with only the free-form Evidence cell stays a warning. Scope-guarded to **non-draft** source specs; the structured-form mismatch is hard-capable but ships conservative at warning (a future ADR may promote it). Surfaces a fact, never a verdict ([ADR-0077](../adrs/0077-corpus-cli-reconcile-only-harness.md) Decision 8). Recorded under [ADR-0083](../adrs/0083-verify-evidence-reconcile.md). | warning          |
| C014 | `do-not-change-touched`   | The change's files (the worktree diff under `corpus review`, or the review packet's Changed files section) reconcile against the task packet's `## Do not change` entries: a changed file matching a Do-not-change entry is surfaced as a protected-path fact routed to Human attention. Matching uses the same path/prefix semantics as the Affected-areas matcher (a context prefix is stripped to its path part; a `{{placeholder}}` template line is ignored). Distinct from out-of-scope drift: a file may lie **inside** the declared Affected areas yet still match a Do-not-change entry. Surfaces a fact, never a verdict ([ADR-0077](../adrs/0077-corpus-cli-reconcile-only-harness.md) Decision 8). Recorded under [ADR-0086](../adrs/0086-deterministic-review-scanning-decision.md).                                                                                                                                 | warning          |
| C015 | `citation-resolves`       | A spec's inline `[[KEY]]` citation (the citations-are-contextual form) that resolves to no `<a id="KEY">` anchor in the `sources.md` its frontmatter `sources:` names is surfaced as a dangling-citation fact. Skip-guarded: when the spec names no resolvable `sources.md`, the check does not fire (a spec that cites nothing, or whose sources.md cannot be located, is never false-flagged); it fires only when a `sources.md` is resolvable **and** a `[[KEY]]` has no matching anchor. v0 is the dangling-anchor case only — the tier checks (a MUST-level claim citing a _Caveated_/_Rejected_ entry) are deferred to a separate v1. Surfaces a fact, never a verdict ([ADR-0077](../adrs/0077-corpus-cli-reconcile-only-harness.md) Decision 8). Recorded under [ADR-0087](../adrs/0087-citation-anchor-check.md).                                                                                                        | warning          |
| C016 | `pass-needs-evidence`     | A review packet coverage row recorded as **Pass** with an **empty Evidence cell** is a structural contradiction — a Pass needs pasted output, a CI link, or (for a manual Verify) a named human's recorded observation; an empty cell reads Unverified, never Pass. Unlike the judgment-laden C012/C013, this is unambiguous, so it is the one review-reconcile rule shipped **hard error**, and the **gate** path (`corpus check <review>`) blocks on it. The advisory **reconcile** path (`corpus review`) surfaces the same row ids without blocking ([ADR-0077](../adrs/0077-corpus-cli-reconcile-only-harness.md) Decision 8 — the reconcile never issues a blocking verdict). Implements the `pass-needs-evidence` review-packet content rule; minted + measured 0-FP on the real reviews in [ADR-0097](../adrs/0097-mint-c016-c017-defer-oversized.md).                                                                    | hard error       |
| C017 | `orphaned-reference`      | A bundled `.agents/skills/<name>/references/<file>` whose filename is named **nowhere** in its sibling `SKILL.md` — dead weight no reader is pointed at, the failure the reference-load field test measured (a bundled template helps only when the guide actually loads it). **Orphan direction only**: a reference no one points at, never the inverse (a named-but-absent target, which is higher-FP). Matching is lenient — the bare filename at a path/word boundary in the body counts as named — so a guide that does point at its references is never flagged, while a substring coincidence (`a.md` inside `data.md`) is not mistaken for a mention; measured 0-orphan across the real `.agents/skills/` corpus (6 references) in [ADR-0097](../adrs/0097-mint-c016-c017-defer-oversized.md). A warning nudge.                                                                                                           | warning          |

One semantic note on C003: a `Verify with:` line whose target does not exist yet is **not** a spec
defect — it is an unresolved note, and the requirement reviews as **Unverified** until the target
exists and its output is pasted. The check asks that the line _be there_, not that it already pass.

One note on C009: a **relative** path named in `sources:` or a requirement resolves against **both** the
spec file's own directory **and** the workspace root — a hit under either is a resolve, only a path under
neither is a broken link. So a spec at `specs/checkout/spec.md` can name a root-level intake the natural
way, `intake/CHK-1.md` (what `corpus pull` + `corpus new spec` scaffold — it resolves from the workspace
root), OR co-locate its ticket beside the spec as `ticket.md` (it resolves from the spec dir). Both work;
no `../../`-relative path is needed. The fixture `checks/fixtures/cross-folder-source/` pins the
root-level-intake case so the worked example's co-located `ticket.md` no longer masks it.

One note on size: [ADR-0094](../adrs/0094-decomposition-and-risk-weighted-review.md) named an
**oversized-packet** heuristic (changed-LOC + files-touched over a band). Measuring real task diffs
([ADR-0097](../adrs/0097-mint-c016-c017-defer-oversized.md)) showed a raw band cannot be both useful
and low-false-positive for code tasks — legitimate feature-with-tests commits occupy the same
600–1200 LOC range as genuinely-too-big ones — so the band-based **check is specified-not-shipped**.
Instead `corpus review` surfaces the diff size (changed LOC + files-touched, generated/vendored
excluded) as **neutral information**, and the reviewer judges decomposition. No threshold is asserted.

### When is a workspace valid?

The whole bar, nothing more: a workspace is valid when **(a)** it has a populated `AGENTS.md`
(aim for ~100 lines — Corpus's own convention, not a cap), **(b)** the core templates are present,
and **(c)** at least one spec satisfies the core checks above. "Populated" means filled: an
unfilled `{{placeholder}}` left in a _live_ `AGENTS.md` or board is a clause-(a) finding,
not a valid workspace (the templates keep their placeholders; the live files must not).

`corpus check` ships clauses (a) and (b): a missing core templates tree (clause b) is **blocking**, while
an unfilled `{{placeholder}}` in a live `AGENTS.md`/board (clause a) is a **warning** (exit 1, not a
blocking exit 2) — a "finish setup" nudge, since a freshly `corpus init`'d workspace ships the kit's
boilerplate placeholders and must not greet a day-one user with a failed gate. Clause (c) is verified
by the per-spec core checks above. _(Level: toolable — `corpus check` implements exactly this; the
~100-line aim in clause (a) stays a convention, not a checked threshold.)_

## Task and review packet checks

These guard the evidence chain from agent run to merge decision. **Level: checklist** — review is
expected to inspect each one; `corpus check`'s packet mode can flag the mechanical parts
(empty Evidence cells, terminal status with open questions). At convention level, the reviewer also spot-checks at least one green row's evidence by hand — structured packets invite rubber-stamping.

- **`non-empty-paste`** — a completion claim binds to pasted output or a CI link, never a bare
  "tests passed". A claim without visible output is not evidence
  [[EVIBOUND]](../research/sources.md#EVIBOUND). In a review packet: an empty Evidence cell
  means **Unverified**, never **Pass**.
- **`no-open-critical`** — work is not closed with an open blocking question. A task or review
  packet whose status is terminal must carry no unresolved blocking question anywhere in it.
- **`trigger-coverage`** — the review packet's Human attention section considered every trigger
  class or marked it n/a: unverified or failed requirements · out-of-scope changes · risky files ·
  missing test output · changed public interfaces · DB migrations · security-sensitive changes ·
  new finding candidates · blocked questions. The checklist itself lives in
  [reviewing output](../08-reviewing-output.md) and the review template.

- **`verify-evidence-binding`** — _(Level: toolable — corpus-cli's `corpus review` / `corpus check` reconcile it as core check **C013** (shipped); the structured-form mismatch is hard-capable but ships at warning. Still not **enforced** — the canon repo runs nothing; the team's gate / the agent CLI's hook runtime enforces. This bullet's level overrides the section's checklist default.)_ Beyond presence, a coverage row may carry a structured-evidence `verify` block (keyed to the requirement id, naming the command, carrying a closed-value `result` signal — the format frozen in [ADR-0083](../adrs/0083-verify-evidence-reconcile.md) and shown in [reviewing output](../08-reviewing-output.md)). Where the block is present against a **non-draft** source spec, a checker can match the recorded command against the requirement's `Verify with:` / `VERIFY BY` reference and confirm the `result` token is `pass` — a closed-value reconcile of _whether the row records a matching command and a pass signal_. A structured mismatch (a `cmd` disagreeing with the named command, a `result=fail` recorded under a Pass row, a malformed or duplicate block) is an internal-consistency fact — the recorded signal disagrees with the recorded Result, the same fact-class as a `status: pass` contradicted by a non-Pass row — and is the kind of objective corruption the format makes hard-checkable; surfacing or rejecting it is **not** the tool concluding the row should read Unverified or Fail. An absent block on a free-form-only row stays a **warning** routed to human attention, because a command-in-prose match is fuzzy [[SMELLS]](../research/sources.md#SMELLS). The check surfaces a fact, never a verdict — the human owns Pass/Fail/Unverified/Blocked ([ADR-0077](../adrs/0077-corpus-cli-reconcile-only-harness.md) Decision 8). Its contract entry (a new core check, scope-guarded to non-draft specs, shipped conservative at warning per the ADR-0079 precedent, with a recorded path to promote the structured-form mismatch to hard error once field-tested) is recorded in ADR-0083; it is now core check **C013** (`warning`) in `checks.yaml`, shipped with the `corpus review` / `corpus check` reconcile.

## Writing rules — the watchlist

**Level: convention.** These word families predict requirements an agent will interpret
differently than you meant. Automated detection of them is known to be imprecise (precision
bounded well below 1.0 in field studies [[SMELLS]](../research/sources.md#SMELLS)) — which is
exactly why this list is an advisory watchlist, not a gate.

**The same-line rule, in plain words:** a risky word is fine when the _same line_ makes it
checkable — it names who does what to what, gives a number with units, or points at a named test.
If the line cannot say how you would check it, rewrite the line.

| Family                          | Examples                                                                                       | What to do instead                                                  |
| ------------------------------- | ---------------------------------------------------------------------------------------------- | ------------------------------------------------------------------- |
| Subjective / promotional        | robust, clean, simple, intuitive, seamless, user-friendly, modern, elegant, proper, reasonable | Replace with the observable behavior you actually want.             |
| Non-verifiable quality          | fast, performant, scalable, secure, reliable, graceful, sufficient                             | Give a number with units, or name the test that decides it.         |
| Vague action verbs              | handle, support, manage, improve, optimize, streamline                                         | Say who does what to what.                                          |
| Loopholes                       | as far as possible, if practical, where feasible                                               | Decide: either it is required or it is not.                         |
| Ambiguous qualifiers            | significant, minimal, as needed, where appropriate                                             | Quantify, or delete the qualifier.                                  |
| Comparatives without a baseline | better, faster, more efficient, optimal                                                        | Name the baseline and the margin ("p95 under 200 ms, from 450 ms"). |
| Ambiguous quantifiers           | all, any, every, some                                                                          | State the exact set ("the three admin endpoints").                  |
| Bundling connectives            | and, or, and/or joining separable behaviors                                                    | Split — one requirement per behavior.                               |
| Ambiguous exceptions            | unless, except where                                                                           | Restate as a positive condition ("When X, …").                      |
| Vague references                | it, this, that, the above                                                                      | Name the thing.                                                     |

Two related habits worth checking alongside the watchlist: a bare "must not" with no paired
affirmative behavior leaves what _should_ happen undecided — state what the component does
instead; and uncertainty buried in requirement prose ("probably", "we think") belongs in Open
questions, not in the requirement.

## The SOL check catalogue (`format: sol` only)

When a spec opts into [structured requirements](structured-requirements.md) with `format: sol`,
its blocks have enough shape for finer-grained checks. Each `SOL-XNNN` code below names one
common mistake, what to look for, and the fix.

**Level: every code below is checklist today and toolable — `corpus check` reports these
codes for `format: sol` files. None is enforced.** Codes are stable identifiers: cite them in
review comments ("SOL-P005 on AC-003") so a fix is unambiguous.

### Structure (`SOL-S…`) — is the block well-formed?

| Code     | Common mistake                                                                                                                     | Fix                                                                                                  |
| -------- | ---------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------- |
| SOL-S001 | A trigger line (`WHEN`/`IF`/`WHILE`/`WHERE`) with no actor line after it.                                                          | Add the `THE <actor> MUST <response>` line.                                                          |
| SOL-S002 | An unknown block type or clause keyword.                                                                                           | Use a documented block type / clause keyword.                                                        |
| SOL-S003 | An actor line with no strength word (`MUST`/`MUST NOT`/`SHOULD`/`SHOULD NOT`/`MAY`).                                               | Insert the strength word you mean.                                                                   |
| SOL-S004 | Two blocks share an ID within one file.                                                                                            | Renumber.                                                                                            |
| SOL-S005 | The ID prefix does not match the block type (e.g. `REQ C-001:`).                                                                   | Use the matching prefix: REQ→`AC-`, CONSTRAINT→`C-`, INVARIANT→`I-`, INTERFACE→`IF-`, QUESTION→`Q-`. |
| SOL-S006 | `SHOULD`/`SHOULD NOT` with no `BECAUSE` or `EXCEPT` in the block.                                                                  | Add the reason, or strengthen to `MUST`/`MUST NOT`.                                                  |
| SOL-S007 | A malformed header — missing colon, spaces or illegal characters in the ID.                                                        | Write `TYPE PREFIX-NNN:`.                                                                            |
| SOL-S008 | Metadata or free prose before the block's first control line.                                                                      | Lead with the condition or actor line; metadata goes at the end.                                     |
| SOL-S010 | An unknown trailing metadata field.                                                                                                | Use a documented field, or move the text to commentary.                                              |
| SOL-S011 | A header with a recognized block type but no ID.                                                                                   | Add a `PREFIX-NNN` ID.                                                                               |
| SOL-S012 | A required spec section missing or out of order.                                                                                   | Add or reorder the section — see the [spec format](artifact-formats.md).                             |
| SOL-S013 | Hidden characters (zero-width, bidirectional-control, homoglyph) in requirement text — an instruction-injection vector for agents. | Strip them; re-author in printable characters.                                                       |
| SOL-S014 | A block missing a clause its shape requires.                                                                                       | Add the required clause.                                                                             |

### Prose (`SOL-P…`) — does the sentence pin down behavior?

| Code     | Common mistake                                                                        | Fix                                                                                |
| -------- | ------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------- |
| SOL-P001 | A condition with no consequence — the trigger is there, the behavior is not.          | Supply the consequence.                                                            |
| SOL-P002 | No responsible actor.                                                                 | Name who does it.                                                                  |
| SOL-P003 | A missing or lowercase strength word where binding force is meant.                    | Write the uppercase modal.                                                         |
| SOL-P004 | Several separable behaviors bundled into one clause.                                  | Split — one requirement per block.                                                 |
| SOL-P005 | A watchlist word in a requirement with no same-line observable criterion.             | Apply the same-line rule: who/what, a threshold, or a named test on the same line. |
| SOL-P006 | An undefined term in a requirement.                                                   | Define it — an in-file `TERM` or the project glossary.                             |
| SOL-P007 | A bare `MUST NOT` with no paired affirmative behavior.                                | State what the actor does instead.                                                 |
| SOL-P008 | Uncertainty left in requirement prose instead of a `QUESTION` block / Open questions. | Lift it into a question.                                                           |
| SOL-P050 | A pronoun with no unique antecedent.                                                  | Name the referent.                                                                 |
| SOL-P051 | Passive voice hiding the actor.                                                       | Name the actor doing the action.                                                   |
| SOL-P052 | A requirement sentence beyond ~20 words.                                              | Split or tighten.                                                                  |
| SOL-P053 | Non-present or non-active phrasing.                                                   | Write present tense, active voice.                                                 |
| SOL-P054 | A decorative phrase that adds no constraint.                                          | Delete it.                                                                         |
| SOL-P055 | Repeated context that adds nothing new.                                               | Delete it.                                                                         |
| SOL-P056 | A comparative with no baseline.                                                       | Name the baseline and the margin.                                                  |
| SOL-P057 | A term drifting from its glossary definition (synonym, casing variant).               | Use the canonical term.                                                            |
| SOL-P058 | `SHALL`/`SHALL NOT` used as a strength word.                                          | Write `MUST`/`MUST NOT`.                                                           |

### Cross-references (`SOL-M…`) — do the pieces agree?

| Code     | Common mistake                                                                                                      | Fix                                                                            |
| -------- | ------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------ |
| SOL-M001 | An actor, object, or surface that resolves nowhere in the spec or its imports (also: an ID collision across files). | Define the referent, or fix the ID.                                            |
| SOL-M002 | Two requirements with the same actor + trigger + surface and opposed strength words — a direct contradiction.       | Pick one; record why in the spec.                                              |
| SOL-M003 | A `DEPENDS ON` / `IMPLEMENTS` / `PRESERVES` reference naming an ID that does not exist.                             | Fix the reference.                                                             |
| SOL-M004 | A lower-authority file weakening a higher-authority requirement.                                                    | Resolve at the higher authority — see [source authority](source-authority.md). |

### Verification (`SOL-V…`) — is every claim checkable?

| Code     | Common mistake                                                                                                                               | Fix                                                                                |
| -------- | -------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------- |
| SOL-V001 | A requirement block (`REQ`/`CONSTRAINT`/`INVARIANT`) or `INTERFACE` with no `VERIFY BY`.                                                     | Add the binding.                                                                   |
| SOL-V002 | A `VERIFY BY` whose command or artifact does not resolve.                                                                                    | Point it at something runnable.                                                    |
| SOL-V003 | Evidence that cannot observe what it claims (e.g. an invariant bound only to one unit test).                                                 | Bind a check that can actually see the property.                                   |
| SOL-V004 | A Pass recorded against text that has since changed.                                                                                         | Re-run the evidence — never re-bless silently.                                     |
| SOL-V005 | A review result outside Pass / Fail / Unverified / Blocked, or a lifecycle marker (Waived, Stale, Contradicted) missing its required fields. | Use a valid result; complete the marker's fields.                                  |
| SOL-V006 | An `INTERFACE` verified by anything other than a contract check.                                                                             | Bind a contract test.                                                              |
| SOL-V007 | A lifecycle marker on the wrong result (e.g. Waived on a Pass).                                                                              | Remove or correct the marker.                                                      |
| SOL-V008 | A required binding with no recorded result at review time.                                                                                   | It counts as Unverified — run it, or waive it on the record.                       |
| SOL-V009 | A `VERIFY BY` evidence type outside the documented set.                                                                                      | Use a documented type — see [structured requirements](structured-requirements.md). |
| SOL-V010 | A manual or waived result with no named human.                                                                                               | Name who accepted it, and why.                                                     |
| SOL-V011 | Evidence that does not say what it actually exercised.                                                                                       | Record what ran relative to the requirement.                                       |

### Splitting work (`SOL-O…`) — can tasks run safely in parallel?

These matter when a spec is split into tasks — the [advanced lifecycle](advanced-lifecycle.md)
covers that step in full.

| Code     | Common mistake                                           | Fix                                                               |
| -------- | -------------------------------------------------------- | ----------------------------------------------------------------- |
| SOL-O001 | Two parallel tasks writing the same files.               | Serialize them, or split the write surfaces.                      |
| SOL-O002 | A dependency cycle between requirements or tasks.        | Break the cycle.                                                  |
| SOL-O003 | An unresolved blocking question reaching task-splitting. | Answer or downgrade it first — splitting past it commits a guess. |
| SOL-O004 | A requirement with no declared write/read scope.         | Declare the surfaces it touches.                                  |
| SOL-O005 | A task writing paths outside its declared scope.         | Declare the path, or stop writing it.                             |
| SOL-O006 | An imported file duplicating a policy requirement.       | Deduplicate — one home per rule.                                  |
| SOL-O007 | A requirement assigned to no task.                       | Assign it — coverage is the point of splitting.                   |
| SOL-O008 | A requirement assigned to two implementing tasks.        | Assign exactly one implementer.                                   |

## How core checks map to SOL codes

One requirement record underlies both spec forms, so a core check and its SOL codes are the same
question asked of two surfaces — never two different rules. The fixtures under `checks/` in
the Corpus repo include simple/SOL equivalence pairs that pin this.

| Core check                    | SOL form                                       |
| ----------------------------- | ---------------------------------------------- |
| C001 `unique-ids`             | SOL-S004 / SOL-S005                            |
| C002 `duplicate-id`           | SOL-M001                                       |
| C003 `verify-with`            | SOL-V001 / SOL-V002                            |
| C004 `one-strength-word`      | SOL-S003 / SOL-P003 / SOL-P004                 |
| C005 `non-goals-present`      | SOL-S012                                       |
| C006 `open-questions-present` | SOL-S012 / SOL-P008                            |
| C007 `no-tbd-at-ready`        | SOL-P008 / SOL-O003                            |
| C008 `sources-named`          | — (frontmatter check; identical in both forms) |
| C009 `broken-source-link`     | SOL-M003                                       |

The writing-rules watchlist corresponds to SOL-P005 (watchlist word, no same-line criterion),
SOL-P056 (comparative, no baseline), and SOL-P004 (bundling connectives).

## The severity split: the `corpus check` contract

Every check on this page maps to one of two severities. This is the contract the reference
implementation builds against — until that tool is in front of you, read the split as advice on
what to fix first, not as anything blocking.

- **Hard error** — the checker must reject (non-zero exit). The defect changes what gets built:
  a missing or colliding ID, a requirement nobody can verify, a contradiction, a placeholder
  shipped as ready.
- **Warning** — the checker must report but not reject. The defect makes the spec weaker or
  harder to read, and a human should decide.

| Severity   | Checks                                                                                                                                                       |
| ---------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Hard error | C001, C002, C003, C007, C009, C010 · all `SOL-S` codes · SOL-P001–P008 · all `SOL-M` codes · SOL-V001/V002 and V004–V010 · SOL-O001/O002/O003/O005/O007/O008 |
| Warning    | C004, C005, C006, C008, C011, C012, C013, C014, C015 · SOL-P050–P058 · SOL-V003, SOL-V011 · SOL-O004, SOL-O006                                               |

One position-sensitive case: SOL-P056 (comparative, no baseline) is a hard error inside a
requirement line and a warning in surrounding commentary — commentary may be loose; a requirement
line _is_ the requirement.

Teams may promote any warning to blocking by policy. Going the other way — accepting a hard error
— deserves a written note in the review packet saying who accepted it and why.

## Related

- [Structured requirements](structured-requirements.md) — the SOL notation these codes check, and the two-surfaces-one-model rule.
- [Writing specs](../04-writing-specs.md) — the happy-path guide the core checks back.
- [Reviewing output](../08-reviewing-output.md) — where the packet checks and the trigger checklist live.
- [Artifact formats](artifact-formats.md) — every template this page's checks apply to.
- `checks/` (Corpus repo) — the checks fixtures: expected results per check, the test data corpus-cli runs against.
