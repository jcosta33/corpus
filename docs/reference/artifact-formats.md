# Artifact formats

Every Suspec artifact is Markdown with frontmatter. Evidence receipts and run notes are untyped
Markdown sidecars.

Sidecars live beside their governing artifact, link from it, and travel through handoff and close as
one absolute path set. A collision follows the same stop rule as the primary artifact.

The `type:` field identifies the artifact. Kind is read from frontmatter, never from the
filename or location. Ordinary artifacts live under the agent-neutral
`~/.agents/artifacts/<workspace>/` root and move into a project only through explicit promotion
([where files live](../03-where-files-live.md)).

Only the artifact authors below create Suspec artifacts. When no downstream step needs the
transient set, the workflow requires one human disposition for every artifact and sidecar: Delete,
Leave, or Promote. Disposition is not frontmatter or lifecycle state.

## Types

| Type | Writer | Carries | ID prefix |
| --- | --- | --- | --- |
| `spec` | `sus-spec` | intent and verifiable requirements | `SPEC-` |
| `task` | `sus-task` | one dispatched source slice | `TASK-` |
| `inventory` | `sus-inventory` | observed present-state structure | `INV-` |
| `change-plan` | `sus-change-plan` | a staged structural transformation | `CHANGE-` |
| `audit` | `sus-audit` | evidenced present-state risks | `AUDIT-` |
| `research` | `sus-research` | evidence for one decision-informing question | `RESEARCH-` |
| `campaign` | `sus-campaign` | one restartable multi-pull-request goal | `CAMPAIGN-` |

No other `type:` value is a Suspec artifact. Project records such as issues, decision records,
product documents, and release documentation keep their project-native formats.

## Spec

Frontmatter:

```yaml
type: spec
id: SPEC-checkout
title: Expired checkout sessions
status: draft
owner: checkout-team
sources:
  - SHOP-4012
```

Required sections:

- Intent
- Requirements

Add `Non-goals`, `Open questions`, `Affected areas`, `Dropped from sources`, or `Execution`
only when the section carries information. A deferred decision keeps the spec `draft` and
blocks dependent execution.
Only a spec whose status is exactly `ready` can be dispatched or reviewed. A missing status,
`draft`, or any other value blocks both transitions.

Each requirement has:

- one `### AC-NNN` heading;
- one non-empty `- When:` condition;
- one non-empty `- Then:` observable obligation with exactly one binding word; and
- one `- Verify with:` method.

Use those three items once, in that order, with no other requirement-body line. Use `When: always`
only for an unconditional invariant.

`## Execution` holds changed files, verify output, scope drift, and blocked questions for
the live run. When work is split, those notes live in each task packet instead. Execution
notes are review input, not a durable append-only history.

## Task

Frontmatter:

```yaml
type: task
id: TASK-checkout-expiry
source:
  - SPEC-checkout
scope: [AC-001]
status: ready
```

Sections:

- Source — full spec path, source commit, and a verbatim snapshot of every scoped requirement block;
  when a change plan supplies wave or preservation context, name it here after the spec
- Scope
- Do not change
- Affected areas
- Verify
- Agent instructions
- Run order — dependency sequence plus non-empty `Starts after:` and `May run with:` values; use
  `None` explicitly
- Findings
- Run summary

Add `Self-review` when it carries useful pre-handoff checks.

Every verify item names a requirement id.

Checking a task requires its ready source spec through `--spec <spec-path>`. The task's `source:`
must name that spec. Several task paths may share one companion only when they share that source.

`status` is one of:

- `ready`
- `running`
- `review-ready` — implementation and evidence are ready for a non-implementer; not a review file and not proof that independent review happened
- `closed`

## Evidence receipt

Evidence receipts are untyped sidecars. Name large receipts `evidence-<slug>.md`. Each record has a
stable `E-NNN` anchor and:

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

The governing artifact links the anchor and includes only the decisive verbatim excerpt.
One receipt may support several claims when each claim names its evidence anchor.

## Run note

A run note is an untyped sidecar for raw round logs or execution detail that would dominate its
governing artifact. Name it for the run, keep raw records untouched, and link it from the artifact.
It carries no lifecycle status or independent verdict.

## Finding

Findings are not a standalone artifact — there is no `finding` type, no `FINDING-` id, no
file to write. Ephemeral findings ride the live spec or task and die with it. A durable
personal lesson becomes native harness memory. A durable team fact enters a
human-selected project channel such as an issue, ADR, test, runbook, or maintained documentation.
Keep one claim, its evidence, a searchable title, and no assigned id ([memory](memory.md),
[saving findings](../09-saving-findings.md)).

## Inventory

Use before brownfield work.

Sections:

- Scope
- Observed structure
- Interfaces
- Tests
- Unknowns
- Observed constraints

No prescriptions.

## Audit

An audit records present-state findings, severity, and direct evidence. It does not invent intended
behavior or prescribe a change. Each finding must be independently checkable from the named source.

## Research

Research answers one decision-informing question with source-qualified findings, limitations, and
open uncertainty. It does not make the decision. Marketing claims, synthetic respondents, and
anecdotes remain labeled as such.

## Change plan

Use for structural work.

Sections:

- Baseline
- Target
- Preservation guarantees
- Transformation waves
- Cutover / rollback
- Task split

Every wave names verification.

## Campaign

Frontmatter:

```yaml
type: campaign
id: CAMPAIGN-checkout-modernization
status: draft
ledger: https://github.com/example/shop/issues/123
sources:
  - ../checkout/spec.md
```

Required sections:

- Objective
- Completion contract
- Authorities
- Operating loop
- Stops

Add `Constraints`, `Non-goals`, or `Workstreams` only when useful. `status` is `draft` or `ready`.
A ready campaign has no unresolved blocking decision. Every intended operation names a reachable
owner, honest control strength, mechanism, and failure behavior. A named stop may guard a later
unavailable transition without blocking independent work.

The campaign is a stable goal contract. One project-native issue, epic, or equivalent ledger owns
work items, dependencies, assignments, pull requests, and mutable status. The campaign points to
that ledger and contains no Markdown task-list checkboxes.

Every pickup rereads the campaign and its authorities, reconciles live state, repairs ledger drift,
selects the highest-priority dependency-ready work, executes project gates, records durable
progress, and repeats until the completion contract passes or a named human decision blocks work.

Local `ledger` and `sources` references resolve artifact-relative. Use durable URLs when the goal
runs where those local files are unavailable. The campaign never grants merge, cleanup, credential,
or resource authority.

## Reference rules

- IDs are stable.
- Accepted decisions are superseded, not rewritten.
- Requirement IDs are spec-scoped.
- Cross-spec references use `SPEC-id#AC-NNN`.
- During live work, code can falsify a working spec; reconcile the intent before close.

## Related

- [Checks](checks.md)
- [Basic workflow](../02-basic-workflow.md)
- [Where files live](../03-where-files-live.md)
- [Reviewing output](../08-reviewing-output.md)
