# Formats

Every Corpus artifact is Markdown with frontmatter. The `type:` field identifies it; kind is never
read from the file name or location. Each artifact lives at `~/.agents/artifacts/<workspace>/<ID>.md`
([method](method.md#where-artifacts-live)).

| Type | Writer | Carries | ID prefix |
| --- | --- | --- | --- |
| `spec` | `corpus-spec` | intent and verifiable requirements, optionally staged | `SPEC-` |
| `audit` | `corpus-audit` | an evidenced map of present state, optionally graded for risk | `AUDIT-` |
| `research` | `corpus-research` | evidence for one decision-informing question | `RESEARCH-` |
| `campaign` | `corpus-campaign` | one restartable multi-pull-request goal | `CAMPAIGN-` |

No other `type:` value is a Corpus artifact. Evidence receipts and run notes are untyped sidecars.
Sidecars live beside their governing artifact, link from it, and travel through handoff and close
with it as one absolute path set. The close disposition is not frontmatter or lifecycle state.
Project records such as issues, decision records, and product documents keep their native formats.

## Spec

```yaml
---
type: spec
id: SPEC-checkout
status: draft
sources:
  - SHOP-4012
  - ../tickets/shop-4012.md
---
```

`status` is exactly `draft` or `ready`. Only a `ready` spec is dispatched or reviewed; an unresolved
blocking decision keeps it `draft`. `sources` is a list: local paths resolve relative to the spec,
and tracker or decision IDs stay bare.

Required: `# Title`, a non-empty `## Intent` (what must become true, for whom, and where it stops),
and `## Requirements`. Add `## Boundary` only when Intent does not bound the work, and
`## Open questions` only while `draft`.

When the project's tracker has a spec form, the filed issue is the spec and the local file is a
draft: its sections map onto the form's fields, and once filed the draft's default disposition is
Delete.

Each requirement:

```markdown
### AC-001 - Expired session returns 409
- When: a checkout session is older than 30 minutes
- Then: the API MUST return `409 SESSION_EXPIRED`, never a 5xx
- Verify with: `npm run test:integration -- expired-session`
```

- one stable `### AC-NNN` heading, optionally followed by ` - short name`; IDs are digits only and
  unique within the spec;
- exactly one non-empty `When`, `Then`, and `Verify with`, in that order, and no other line;
- `When: always` only for an unconditional invariant;
- exactly one of `MUST`, `MUST NOT`, `SHOULD`, `SHOULD NOT`, or `MAY` in `Then`;
- no `TBD`, `TODO`, `???`, or blocking open question once `status: ready`.

A named `Verify with` method that does not exist yet is not a spec defect; the requirement stays
unverified until evidence exists.

**Structural change** adds `## Baseline` (current state with evidence), preserved behavior as
`When: always` requirements verified by checks that fail on drift, `## Waves` (expand, migrate in
batches, contract; each green, with verification and a rollback point), and `## Cutover` (entry,
completion, abort, restore). Every removed behavior is named as retired or re-established, and no
step weakens, skips, or deletes a test to turn green.

Verification output, scope drift, and review live on the native pull request, not in the spec.

## Audit

```yaml
---
type: audit
id: AUDIT-checkout-sessions
---
```

Sections: `## Scope` (frozen commit, goal, and exclusions), then `## Map` for a current-state map,
`## Findings` for assessed risks, or both, then `## Unverified` (areas not checked and the missing
evidence, or `None found. Boundary checked:` with the boundary). Every claim cites `file:line`, a
search, or pasted output. The map records what each component takes on faith and what enforces it,
or `nothing found`. Each finding has a stable `F-NNN` and states evidence, failure mode, firing
condition, blast radius, and a Blocker, Major, or Minor grade; with none, write `None observed in
scope`. No prescriptions.

## Research

```yaml
---
type: research
id: RESEARCH-payment-provider
---
```

Sections that carry payload: Question and scope, Method and coverage, Findings, Options, Open
questions, Recommendation. Each finding has a stable `R-NNN`, one claim, exact evidence with the
supporting passage, one outcome (`Verified`, `Disputed`, `Unverified`, or `Overturned`), and decision
relevance. A disputed finding shows each figure with its source and never an average. The recommendation cites
finding IDs and never makes the decision.

## Campaign

```yaml
---
type: campaign
id: CAMPAIGN-checkout-modernization
status: draft
ledger: https://github.com/example/shop/issues/123
sources:
  - https://github.com/example/shop/issues/120
---
```

Required, each exactly once: `## Objective`, `## Completion contract`, `## Authorities`,
`## Operating loop`, and `## Stops`. Optional: `## Constraints`, `## Non-goals`, `## Workstreams`
(stable ledger IDs only).

The completion contract is one end state, verified by named evidence, while preserving named
constraints. The working session's own output can demonstrate it, and it fits a native goal
condition of 4,000 characters.

One project-native ledger owns work items, dependencies, assignments, pull requests, and status. The
campaign points to it and contains no task-list checkboxes, counts, SHAs, or snapshots. `status:
ready` means every authority is reachable and every intended operation names an owner, an honest
control strength (advisory, deterministic local, or isolated authority), a mechanism, and failure
behavior. A named stop may guard a later unavailable transition without blocking independent work.

Every pickup rereads the campaign and its authorities, reconciles live state, repairs ledger drift,
selects the highest-priority dependency-ready work, runs project gates, records durable progress,
and repeats until the completion contract passes or a named human decision blocks work. Local
`ledger` and `sources` references resolve relative to the campaign; use durable URLs when the goal
runs where those files are unavailable. The campaign never grants merge, cleanup, credential, or
resource authority.

## Evidence receipt

An untyped sidecar beside its governing artifact. Each record has a stable anchor:

````markdown
<a id="E-001"></a>
## E-001

- Command: `pnpm test`
- Working directory: `/path/to/repo`
- State: `git:<commit-or-tree-id>`
- Exit: `0`

```text
untouched raw output
```
````

The governing artifact links the anchor and quotes only the decisive excerpt.

## Run note

An untyped sidecar for raw round logs or execution detail that would dominate its governing
artifact. Keep raw records untouched and link the note from the artifact. It carries no status or
verdict.

## Findings

Findings are not an artifact type. Task-local findings ride the live artifact and die with it. A
durable personal lesson becomes native memory; a durable team fact enters a project channel such as
an issue, decision record, test, or maintained documentation.

## Reference rules

- IDs are stable.
- Requirement IDs are spec-scoped. Cross-spec references use `SPEC-id#AC-NNN`.
- Every reference resolves relative to the artifact that names it; no root is inferred.
- Accepted decisions are superseded, not rewritten.
- During live work, code can falsify a working spec; reconcile the intent before close.

## Writing watchlist

These words are allowed only when the same line makes them checkable.

| Family | Examples | Better form |
| --- | --- | --- |
| subjective | robust, clean, simple, intuitive | state observable behavior |
| quality without measure | fast, secure, reliable | give threshold or named test |
| vague verbs | handle, support, improve | name actor, action, object |
| loopholes | where feasible, if practical | make it required or remove it |
| ambiguous qualifiers | significant, minimal | quantify |
| comparatives | better, faster | name baseline and margin |
| broad quantifiers | all, any, every, some | name the exact set |
| bundling | and, or, and/or | split requirements |
| vague references | it, this, above | name the thing |
