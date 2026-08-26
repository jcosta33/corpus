---
name: sus-inventory
description: Map an unfamiliar or change-critical code area as durable current state. Use when wide change lacks a proven map. Do not use for direct implementation, narrow path tracing, or small isolated work.
---

# Sus Inventory

Map reality. Invent nothing. Prescribe nothing.

Ask required questions through the native picker, or numbered choices plus `Other`. Put the
recommendation first; offer three genuine options, two if binary; give each one plain reason and
cost.

## Method

Enter on explicit inventory request or after the human selects a Suspec inventory workflow for a
durable current-state map.

1. Lock scope and exclusions to the coming change.
2. List current modules: path, observed responsibility, evidence.
3. List current interfaces: signature or surface, direct and dynamic callers, observed contract,
   evidence.
4. Record externally visible behavior with tests, `file:line`, or decisive command output.
5. Map data, state, side effects, persistence, generated surfaces, configuration, and external
   consumers.
6. List existing tests and the behavior each actually controls.
7. Expose unknowns with exact search boundaries and missing evidence. If none surfaced, state
   `None found` and the boundary checked.

Search callers and string registrations. Run safe checks for dynamic claims. Zero-caller and
no-match claims require command and result. Every sentence must fit:
`this exists; it behaves this way; here is the evidence.`
Trace any unfamiliar or dangerous code path to closure before claiming its behavior.

## Artifact

Resolve `~/.agents/artifacts/<workspace>/` to an absolute path; derive `<workspace>` from the
repository or working-directory basename. Write there with `type: inventory`, a unique `INV-` ID,
and linked sidecars beside it. On collision or ambiguous workspace, present human-readable name
choices. On a blocked write, offer grant and retry, another agent-neutral user directory, or cancel.
Never overwrite or fall back to a repository, vendor directory, or temporary path.

Write local source references relative to the artifact. Use absolute paths only for runtime handoff.

Start with:

```yaml
---
type: inventory
id: INV-{{slug}}
---
```

## Output

Before handoff, cut repetition, softness, ceremony, and structural bloat without changing contracts,
identifiers, verbatim source text, evidence, or behavior. Rerun applicable checks. Return only
clickable Markdown links for the inventory and every sidecar, with compact `~/.agents/...` labels
and fully expanded absolute destinations. Explain only a blocker, failed creation, incomplete
verification, or irreversible-action confirmation.

## Boundaries

Force material ambiguity in scope into explicit human selection. Block mapping until selection.

Strip severity, prescriptions, target architecture, and implementation steps.

## Close

Once fully actioned and no downstream step needs it, require one human disposition for the artifact
and its sidecars: Delete, Leave, or Promote. Promote moves transient material into project-owned
permanence. Delete every selected path and verify absence; survivors block close.
