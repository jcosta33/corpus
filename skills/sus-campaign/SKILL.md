---
name: sus-campaign
description: Write or revise a restartable goal contract for one multi-pull-request delivery campaign. Use when one durable objective needs dependency-aware, write-disjoint streams, a project-native progress ledger, and enforceable delivery gates. Do not use when the goal completes in one pull request, or when the user asks only for a plan artifact.
---

# Sus Campaign

Snapshots rot. Goals survive.

## Method

Read project governance, governing requirements, dependency state, delivery commands, branch
protection, release constraints, current worktrees, and the live tracker.

Lock one objective and one verifiable stopping condition. Reject unrelated backlogs.

Select one project-native issue, epic, or equivalent ledger. It owns work items, dependencies,
assignments, pull requests, and status. The campaign points to it; it never mirrors its mutable
state. Make the ledger self-contained for its audience. Translate stable requirements into it;
never expose transient or local-only artifact names, paths, or links.

### Authority

Map only operations the campaign will use: lane allocation, verification, heavyweight execution,
publication, review, merge, and cleanup. Record each owner, strength, mechanism, and failure in the
ledger.

- **Advisory:** instructions coordinate willing agents. Claim no rejection or containment.
- **Deterministic local:** a project command rejects an invalid transition.
- **Isolated authority:** workers cannot reach protected state, resources, or credentials.

Match strength to the claim. A claim that a worker cannot bypass a boundary requires isolation.
Missing authority blocks only the dependent operation. Independent work continues.
A trusted owner may bootstrap a missing control while its guarded transition stays blocked.
Revalidate when its owner, mechanism, permissions, or relevant state changes.
Hosted status checks are optional; project-approved local proof is valid.

### Lanes

Inspect the path, branch, tracked and untracked state, and `git worktree list`. Classify every lane
by path, branch, owner, origin, and state. Never seize an active or unknown lane.

Size capacity from proven independent work, machine limits, verification cost, and reviewer
capacity. Reuse only a clean released lane. Keep one branch and one implementation owner per lane.
Refresh ignored dependencies after lockfile or toolchain drift. Force-clean nothing. Implementation
on `main` requires named project or owner authority.

### Dispatch

Dispatch only dependency-ready, write-disjoint work. Give each owner the objective, ledger,
repository, lane, branch, scope, exclusions, dependencies, acceptance conditions, checks, and
pull-request policy. Require only status, changed paths, branch, pull request, head, decisive checks,
and blockers. No progress diary or recap.

The implementation owner edits, tests, commits, pushes, and repairs review. The orchestrator
coordinates and verifies; it does not hijack another owner's branch. Reassign only after the owner
stops and the branch head remains expected. Route heavyweight work through its named resource
owner; without one, run sequentially. Record blockers in the pull request or ledger.

Choose implementation models from task complexity and ambiguity. Use an economy tier only for
bounded mechanical work with a decisive oracle, a standard tier for ordinary contained work, and
the strongest tier for architecture, security, migrations, cross-repository judgment, conflicting
evidence, or unresolved ambiguity.

Choose reviewers from the criticality of their stance. Use an economy tier for narrow low-risk
checks, a standard tier for behavioral and integration risk, and the strongest tier for security,
safety, data loss, irreversible change, or disputed severe findings. Escalate the blocked or
disputed step, then return to the cheaper adequate tier. Route from evidence, scope, risk,
reversibility, repeated failure, and reviewer disagreement. Ignore self-confidence.

### Delivery

Define the strongest observable check before changing behavior. For a bug, reproduce the original
failure and expected reason before editing. Trust a regression only when it fails on the defect,
passes on the repair, exercises production behavior, and invents no requirement. Record command,
working directory, state, exit, and decisive output. Re-run after material drift.

Keep one independently reviewable concern per pull request and merge in dependency order. Split
mixed behavior, refactors, and migrations before implementation. Repository size policy wins;
without one, split when reviewability degrades unless the concern is indivisible. Suspec supplies no
line or file threshold.

Open a draft when reviewable code exists. Follow repository title and body conventions. Without
them, use an imperative title, Summary, and Verification; add Dependencies or Risks only when
material. Link the ledger once. Remove agent names, internal review mechanics, process diaries,
repeated evidence, and anything no reviewer can act on. Mark ready only after required checks pass.

Derive the smallest review set covering material risks. Suspec supplies no reviewer or stance count.
Give each reviewer the current head, diff, requirements, accepted decisions, and one distinct risk.
Hide prior reviewer prose unless resolving its finding. Verify findings. Publish only supported,
actionable defects: changed-line threads for local defects, file comments for file-wide defects, and
one short review item for cross-cutting defects. Each finding states defect, consequence, and
required outcome. Omit greetings, praise, process, identities, stance labels, speculation, and
solution essays.

The implementation owner cannot accept its own work. It fixes, pushes, and replies with the repaired
head and decisive proof; a distinct reviewer or named review authority validates the repair.
Resolve current findings before another sequential reviewer. Restart broad review only after a
contract, trust boundary, failure mode, or requirement changes. Stop when material risks are
covered. Run no quiet rotation, quota, or completion recap.

Immediately before merge, reconcile governing artifacts, head, base, proof, review state, and open
conversations. The owner may delegate merge execution to a named orchestrator, project command,
protected queue, or human. Bind merge to the expected head. Do not claim independence unless the
worker cannot bypass the authority. Drift resets affected checks and review. Revalidate dependent
branches after prerequisites merge. Follow repository merge strategy. Recycle a lane only after
merge or closure and a clean worktree. Delete only campaign-owned merged branches and clean
campaign-created worktrees through the named cleanup owner; preserve everything else.

Prove write-disjoint, dependency-ready parallelism. Sequence shared contracts, generated surfaces,
unknown scope, and overlapping files.

Resolve discoverable facts and reversible conventions. For a material behavior, public contract,
security, cost, authority, waiver, or irreversible choice, use the native picker: recommendation
first, three genuine options by default, two when binary, plain tradeoffs, and `Other`. Keep the
campaign `draft` until every blocking choice is resolved.

Instructions advise. Project commands reject. Isolation removes authority. Claim only what the
mechanism proves. Humans own intent, material decisions, waivers, irreversible authority, and
acceptance. They may delegate execution to a named orchestrator or project mechanism.

## Artifact

Resolve `~/.agents/artifacts/<workspace>/` to an absolute path; derive `<workspace>` from the
repository or working-directory basename. Write there with `type: campaign`, a unique `CAMPAIGN-`
ID, and linked sidecars beside it. On collision or ambiguous workspace, present human-readable name
choices. On a blocked or unwritable destination, offer grant and retry, another agent-neutral user
directory, or cancel. Never overwrite or fall back to a repository, vendor directory, or temporary
path.

Write local source references relative to the artifact. Use absolute paths only for runtime handoff.

Start with:

```yaml
---
type: campaign
id: CAMPAIGN-{{slug}}
status: draft
ledger: {{project-native-url-or-relative-path}}
sources:
  - {{governing-artifact-or-url}}
---
```

Write exactly these required sections:

- **Objective:** one durable outcome.
- **Completion contract:** observable conditions that prove the whole campaign done.
- **Authorities:** governing artifacts, ledger, and owners and mechanisms for every intended
  delivery transition.
- **Operating loop:** reread, reconcile, select, execute, verify, record, repeat. Repeat an action
  only after relevant state changed, the previous attempt failed, or independent proof requires it.
- **Stops:** completion or named human decisions that block dependent work.

Add `Constraints`, `Non-goals`, or `Workstreams` only when they carry information. Workstreams may
name stable ledger IDs; status stays in the ledger.

Every pickup must run the same loop:

1. Read the campaign and every authority.
2. Reconcile repository, ledger, pull-request, worktree, worker, and verification state from live
   evidence.
3. Repair ledger drift before trusting its status.
4. Select the highest-priority dependency-ready work that fits current capacity and ownership.
5. Execute through project implementation, verification, review, and integration gates.
6. Record durable progress in the project-native ledger.
7. Repeat until the completion contract passes or a named human decision blocks progress.

Worker and phase handoffs state only the action, current state, result, decisive evidence,
unresolved condition, and next owner or action.

Put no task-list checkbox, current count, branch SHA, lane occupancy, pull-request snapshot,
session identity, first-run step, or handoff diary in the campaign. Point to the live owner.

Use `status: ready` only when every authority is reachable from the target execution environment,
every blocking choice is resolved, and every intended operation names an honest owner, strength,
mechanism, and failure behavior. A named stop may guard a later unavailable transition without
blocking independent work. A local harness receives the fully expanded absolute campaign path. A
harness without path access receives the same artifact body after its authorities become reachable
there.

## Output

Cut repetition, softness, ceremony, and structural bloat without changing contracts, identifiers,
evidence, or behavior. Rerun applicable checks. Return only clickable Markdown links for the
campaign and every sidecar, with compact `~/.agents/...` labels and fully expanded absolute
destinations. Explain only a blocker, failed creation, incomplete verification, or irreversible
action confirmation.

## Close

Once fully actioned and no downstream step needs it, require one human disposition for the artifact
and its sidecars: Delete, Leave, or Promote. Promote moves transient material into project-owned
permanence. Delete every selected path and verify absence; survivors block close.
