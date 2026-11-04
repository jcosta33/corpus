---
name: corpus-campaign
description: Write or revise a restartable goal contract for one delivery campaign that spans several pull requests. Use when one durable objective needs dependency-aware, write-disjoint streams, a project-native progress ledger, and named delivery authorities. Do not use when the goal fits one pull request or only a plan is wanted.
---

# Corpus Campaign

Snapshots rot. Goals survive.

## Method

Read project governance, governing requirements, dependency state, delivery commands, branch
protection, release constraints, worktrees, and the live tracker. Lock one objective and one
verifiable stopping condition. Reject unrelated backlog.

Pick one project-native issue, epic, or equivalent ledger. It owns work items, dependencies,
assignments, pull requests, and status. The campaign points to it and never copies its mutable
state. Keep the ledger self-contained: no transient artifact names, paths, or links.

### Authority

For each operation the campaign uses (lane allocation, verification, heavyweight execution,
publication, review, merge, cleanup), record the owner, strength, mechanism, and failure behavior in
the ledger:

- **Advisory:** instructions coordinate willing agents. Claim no rejection.
- **Deterministic local:** a project command rejects an invalid transition.
- **Isolated authority:** workers cannot reach the protected state, resource, or credential.

A claim that a worker cannot bypass a boundary requires isolation. Missing authority blocks only the
operations that depend on it; independent work continues. A trusted owner may bootstrap a missing
control while its guarded transition stays blocked. Hosted status checks are optional;
project-approved local proof is valid.

### Lanes

Inspect `git worktree list`, the branches, and tracked and untracked state. Classify every lane by
path, branch, owner, and state. Never seize an active or unknown lane, and force-clean nothing.

- Keep one branch and one implementation owner per lane.
- Reuse only a clean, released lane.
- Size parallelism from proven independent work, machine limits, verification cost, and reviewer
  capacity.
- Implementing on `main` needs named project or owner authority.

### Dispatch

Dispatch only work that is dependency-ready and write-disjoint. Sequence shared contracts, generated
surfaces, unknown scope, and overlapping files.

Give each owner the objective, ledger, repository, lane, branch, scope, exclusions, dependencies,
acceptance checks, and pull-request policy. Require back only status, changed paths, branch, pull
request, head, decisive checks, and blockers.

The implementation owner edits, tests, commits, pushes, and repairs review findings. The orchestrator
coordinates and verifies; it never hijacks another owner's branch.

Choose the cheapest adequate model tier:

- economy only for bounded mechanical work with a decisive oracle;
- standard for contained work;
- strongest for architecture, security, migrations, cross-repository judgment, or unresolved
  ambiguity.

Escalate a blocked or disputed step, then return to the cheaper tier.

### Delivery

Define the strongest observable check before changing behavior, and reproduce a bug before fixing it.
Trust a regression test only when it fails on the defect and passes on the repair.

Keep one reviewable concern per pull request, and merge in dependency order. Follow repository
conventions; without them, use an imperative title, Summary, and Verification. Mark a pull request
ready only after required checks pass.

Review with the smallest set of fresh reviewers that covers the material risks. Give each reviewer
the head, diff, requirements, and one risk. Publish only verified, actionable defects as line or
file comments, each stating defect, consequence, and required outcome. The implementation owner
cannot accept its own work; a distinct reviewer validates each repair.

Before merge, reconcile governing artifacts, head, base, proof, and review state, and bind the merge
to the expected head. Drift resets the affected checks and review. Delete only campaign-owned merged
branches and campaign-created worktrees.

Humans own intent, material decisions, waivers, irreversible authority, and acceptance. They may
delegate execution to a named orchestrator or project mechanism. Ask them for those choices:
recommendation first, two or three real options, each with its cost. Keep the campaign `draft` until
every blocking choice is resolved.

## Shape

```yaml
---
type: campaign
id: CAMPAIGN-{{slug}}
status: draft
ledger: {{project-native-url}}
sources:
  - {{governing-artifact-or-url}}
---
```

Write each of these sections exactly once: `## Objective`, `## Completion contract`,
`## Authorities`, `## Operating loop`, and `## Stops`. Add `## Constraints`, `## Non-goals`, or
`## Workstreams` only when they carry information. Workstreams may name stable ledger IDs only.

The operating loop runs on every pickup:

1. Read the campaign and every authority.
2. Reconcile repository, ledger, pull-request, worktree, and verification state from live evidence.
   Repair ledger drift before trusting its status.
3. Select the highest-priority dependency-ready work that fits current capacity.
4. Execute it through project implementation, verification, review, and merge gates.
5. Record progress in the ledger.
6. Repeat until the completion contract passes or a named human decision blocks progress.

Keep checkboxes, counts, SHAs, lane occupancy, pull-request snapshots, and session diaries out of the
campaign. Use `status: ready` only when every authority is reachable from the execution environment
and every operation names an owner, strength, mechanism, and failure behavior.

## Artifact

Write `~/.agents/artifacts/<workspace>/<ID>.md` with `~` expanded. `<workspace>` is the repository
or working-directory basename. Put sidecars, such as evidence receipts and run notes, beside it and
link them. Never overwrite; on a collision, ask for a name. If the directory is unwritable, offer
grant and retry, another user directory, or cancel. Never fall back to the repository, a vendor
directory, or a temporary path. Write local source references relative to the artifact; hand off
absolute paths.

## Output

Return only clickable links to the artifact and its sidecars, labelled `~/.agents/...`, with
absolute destinations. Explain only a blocker, a failed write, incomplete verification, or an
irreversible-action confirmation.

## Close

When no downstream step needs the set, ask the human once: Delete, Leave, or Promote into
project-owned records. After Delete, confirm every path is gone; a survivor blocks close.
