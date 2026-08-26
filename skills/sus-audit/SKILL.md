---
name: sus-audit
description: Audit present code against direct evidence. Use when running debt surveys, cleanup assessments, single-implementation benchmarks, current-state quality assessments, or fresh passes over prior audits without a governing spec or task. Do not use for conformance review, rotating adversarial review, or option research.
---

# Sus Audit

Observe. Prove. Prescribe nothing.

Ask required questions through the native picker, or numbered choices plus `Other`. Put the
recommendation first; offer three genuine options, two if binary; give each one plain reason and
cost.

## Method

1. Lock the goal, surface, and exclusions.
2. Freeze repository state.
3. Inspect source, callers, tests, configuration, generated surfaces, and runtime wiring. Trace any
   unfamiliar or dangerous code path to closure before assessing it.
4. Run safe checks for dynamic claims. Record exact commands, exits, and decisive output.
5. Anchor every observation to `file:line`, search result, or pasted output.
6. Express each risk as evidence, failure mode, firing condition, and blast radius.
7. Grade Blocker, Major, or Minor by impact and reach.
8. Expose unverified areas and missing evidence.

Re-derive current state before reading a prior audit's framing. Recheck every retained citation.

Negative structural claims require a whole-scope search and result. Dynamic behavior requires a run;
static reading cannot prove timing, concurrency, cleanup, or lifecycle. If no supported risk exists,
write `None observed in scope` instead of inventing one.

## Artifact

Resolve `~/.agents/artifacts/<workspace>/` to an absolute path; derive `<workspace>` from the
repository or working-directory basename. Write there with `type: audit`, a unique `AUDIT-` ID, and
linked sidecars beside the audit. On collision or ambiguous workspace, present human-readable name
choices. On a blocked write, offer grant and retry, another agent-neutral user directory, or cancel.
Never overwrite or fall back to a repository, vendor directory, or temporary path.

Write local source references relative to the artifact. Use absolute paths only for runtime handoff.

Start with:

```yaml
---
type: audit
id: AUDIT-{{slug}}
---
```

## Output

Before handoff, cut repetition, softness, ceremony, and structural bloat without changing contracts,
identifiers, verbatim source text, evidence, or behavior. Rerun applicable checks. Return only
clickable Markdown links for the audit and every sidecar, with compact `~/.agents/...` labels and
fully expanded absolute destinations. Explain only a blocker, failed creation, incomplete
verification, or irreversible-action confirmation.

## Boundaries

Force material ambiguity in audit boundaries into explicit human selection. Block the audit until
selection.

Strip fixes, target states, requirements, and recommendations.

## Close

Once fully actioned and no downstream step needs it, require one human disposition for the artifact
and its sidecars: Delete, Leave, or Promote. Promote moves transient material into project-owned
permanence. Delete every selected path and verify absence; survivors block close.
