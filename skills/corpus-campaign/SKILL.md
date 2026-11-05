---
name: corpus-campaign
description: Write or revise a restartable goal contract for one delivery campaign that spans several pull requests. Use only when the user explicitly asks for a campaign, usually after a multi-pull-request goal lost its thread across sessions or workers. It needs dependency-aware, write-disjoint streams, a project-native progress ledger, and named delivery authorities, not a goal that fits one pull request or a plan alone. Never invoke on your own initiative.
disable-model-invocation: true
---

# Corpus Campaign

Snapshots rot. Goals survive.

## Method

Read project governance, governing requirements, dependency state, delivery commands, branch
protection, release constraints, worktrees, and the live tracker. Lock one objective. Reject
unrelated backlog.

Write the completion contract as one end state, verified by named evidence, while preserving named
constraints. The working session's own output must be able to demonstrate it, and it must fit a
native goal condition of 4,000 characters. Belief that the work is probably done never meets it.

Pick one project-native issue, epic, or equivalent ledger. It owns work items, dependencies,
assignments, pull requests, and status. The campaign points to it and never copies its mutable
state. Keep the ledger self-contained: no transient artifact names, paths, or links.

### Authority

For each operation the campaign uses (lane allocation, dispatch, verification, heavyweight
execution, publication, review, merge, cleanup), record the owner, strength, mechanism, and failure
behavior in the ledger. Project rules govern how each runs.

- **Advisory:** instructions coordinate willing agents. Claim no rejection.
- **Deterministic local:** a project command rejects an invalid transition.
- **Isolated authority:** workers cannot reach the protected state, resource, or credential.

A claim that a worker cannot bypass a boundary requires isolation. Missing authority blocks only the
operations that depend on it; independent work continues. A trusted owner may bootstrap a missing
control while its guarded transition stays blocked.

Whatever the project rules say, three bans hold:

- Never seize an active or unknown lane, and force-clean nothing. Classify every worktree by path,
  branch, owner, and state first.
- The orchestrator coordinates and verifies; it never takes over another owner's branch. No owner
  accepts its own work, and a distinct reviewer validates each repair.
- Bind each merge to the expected head. Drift resets the affected checks and review.

Dispatch only dependency-ready, write-disjoint work. Sequence shared contracts, generated surfaces,
unknown scope, and overlapping files. Review the whole design before dispatching parallel streams,
and review the combined result after they merge; per-stream review misses cross-stream defects.

Humans own intent, material decisions, waivers, irreversible authority, and acceptance. They may
delegate execution to a named orchestrator or project mechanism. Keep the campaign `draft` until
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

The operating loop runs on every pickup: read the campaign and every authority; reconcile
repository, ledger, pull-request, worktree, and verification state from live evidence, repairing
ledger drift before trusting its status; take the highest-priority dependency-ready work that fits
capacity through the project's implementation, verification, review, and merge gates; record
progress in the ledger; repeat until the completion contract passes or a named human decision
blocks progress.

Keep checkboxes, counts, SHAs, lane occupancy, pull-request snapshots, and session diaries out of the
campaign. Use `status: ready` only when every authority is reachable from the execution environment
and every operation names an owner, strength, mechanism, and failure behavior.

## Artifact

Write `~/.agents/artifacts/<workspace>/<ID>.md` with `~` expanded; `<workspace>` is the repository
or working-directory basename. Keep sidecars, such as evidence receipts and run notes, beside it and
link them. On a collision or an unwritable directory, ask the human; never overwrite, and never fall
back to the repository, a vendor directory, or a temporary path. Write local references relative to
the artifact. Return only clickable `~/.agents/...` links with absolute destinations, and explain
only a blocker, a failed write, incomplete verification, or an irreversible-action confirmation.

## Close

When no downstream step needs the set, ask the human once: Delete, Leave, or Promote into
project-owned records. After Delete, confirm every path is gone; a survivor blocks close.
