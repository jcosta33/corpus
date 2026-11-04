---
name: corpus-audit
description: Map or assess present code from direct evidence. Use for a current-state map before wide change, debt surveys, cleanup or quality assessments, single-implementation benchmarks, or fresh passes over prior audits. Do not use for conformance review against a spec, tracing one narrow path, adversarial review, or option research.
---

# Corpus Audit

Observe. Prove. Prescribe nothing.

## Method

1. Lock the goal, surface, and exclusions. Ask the human when scope is materially ambiguous:
   recommendation first, two or three real options, each with its cost.
2. Freeze the repository state and record its commit or tree ID.
3. Map what exists:
   - modules and their observed responsibilities;
   - interfaces, with direct and dynamic callers;
   - externally visible behavior;
   - data, state, side effects, configuration, generated surfaces, and external consumers;
   - tests, and the behavior each one actually controls.
4. Assess only when asked. State each risk as evidence, failure mode, firing condition, and blast
   radius. Grade it Blocker, Major, or Minor by impact and reach.
5. List unknowns, with the search boundary and the missing evidence.

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

Use the sections `## Scope` (with the frozen state), `## Map`, `## Risks` (only when assessed), and
`## Unknowns`.

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
