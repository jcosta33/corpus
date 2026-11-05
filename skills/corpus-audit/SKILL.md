---
name: corpus-audit
description: Map or assess present code from direct evidence. Use for a current-state map before wide change, debt surveys, cleanup or quality assessments, single-implementation benchmarks, or fresh passes over prior audits. Do not use for conformance review against a spec, tracing one narrow path, adversarial review, or option research.
---

# Corpus Audit

Observe. Prove. Prescribe nothing.

## Method

1. Lock the goal, surface, and exclusions. Ask the human when scope is materially ambiguous.
2. Freeze the repository state and record its commit or tree ID.
3. Map what exists: modules and their observed responsibilities; interfaces with direct and
   dynamic callers; visible behavior; data, state, side effects, configuration, generated surfaces,
   and external consumers; tests and the behavior each controls; and what each component takes on
   faith, with what enforces it or `nothing found`. Before a planned change, phrase each question
   without the change, so the map shows what is, not what the change wants.
4. Assess only when asked. State each risk as evidence, failure mode, firing condition, and blast
   radius. Grade it Blocker, Major, or Minor by impact and reach.
5. List what stays unverified, with the search boundary and the missing evidence.

Anchor every claim to `file:line`, a search result, or pasted output. A negative claim, such as
zero callers or no match, needs the whole-scope command and its result. Dynamic behavior, such as
timing, concurrency, cleanup, or lifecycle, needs a run; static reading cannot prove it. Re-derive
current state before reading a prior audit, and recheck every citation you keep. With no supported
risk, write `None observed in scope`. Strip fixes, target states, and requirements.

## Shape

```yaml
---
type: audit
id: AUDIT-{{slug}}
---
```

Use `## Scope` (frozen commit, goal, and exclusions), then `## Map` for a current-state map,
`## Findings` for assessed risks (one `F-NNN` each), or both, then `## Unverified` (areas not
checked and the missing evidence, or `None found. Boundary checked:` with the boundary).

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
