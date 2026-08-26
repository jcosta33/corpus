---
name: sus-spec
description: Write, revise, or structurally check a verifiable Suspec spec. Use when intent or consequential open behavior must become requirements and acceptance criteria before implementation. Do not use for direct implementation, small clear work, factual verification, or detailed implementation planning.
---

# Sus Spec

A spec is decided intent under test. Nothing else belongs.

## Method

Enter on explicit request or after the human selects a Suspec spec workflow for unresolved intent.
Direct implementation does not earn a spec.

Keep trivial work as one inline intent sentence when no written contract would change execution or
review. Write no file.

Ask required questions through the native picker, or numbered choices plus `Other`. Put the
recommendation first; offer three genuine options, two if binary; give each one plain reason and
cost.

Before writing:

1. Read project rules, current code, durable decisions, related artifacts, and open issues.
2. Lock goal, audience, success, boundary, and sources.
3. Burn down facts. When a decision lacks evidence, research it until evidence can carry it.
4. Resolve reversible conventions.
5. When consequential behavior remains open, present distinct viable approaches and resolve
   dependent choices in order.
6. Convert selected behavior into intent and executable requirements. Freeze on material behavior,
   public contracts, security, costly tradeoffs, conflicting authority, and irreversible actions.

Every unresolved choice keeps `status: draft` and blocks dependent work.

## Artifact

Resolve `~/.agents/artifacts/<workspace>/` to an absolute path; derive `<workspace>` from the
repository or working-directory basename. Write there with linked sidecars beside it. On collision
or ambiguous workspace, present human-readable name choices. On a blocked write, offer grant and
retry, another agent-neutral user directory, or cancel. Never overwrite or fall back to a
repository, vendor directory, or temporary path.

Write local source references relative to the artifact. Use absolute paths only for runtime handoff.

### Shape

Use this minimal frontmatter shape:

```yaml
---
type: spec
id: SPEC-{{slug}}
title: {{title}}
status: draft
owner: {{owner}}
sources:
  - ISSUE-123
  - ../../path/to/source.md
---
```

Keep `sources` a list. Local paths are relative to the spec; tracker and decision IDs remain bare.
Make the `SPEC-` ID unique.

Require non-empty `## Intent` and `## Requirements`. Add optional sections only for unique payload.

Each requirement:

- one stable `### AC-NNN` ID;
- one non-empty `- When:` condition, using `always` only for an unconditional invariant;
- one non-empty `- Then:` observable obligation with exactly one deliberate `MUST`, `MUST NOT`,
  `SHOULD`, `SHOULD NOT`, or `MAY`; and
- one concrete `- Verify with:` method.

Use those three items once, in that order. Add no other requirement-body line.

Split independently failing obligations. Put consequence first. Name a mechanism only when
compatibility or public contract makes it observable; state why.

## Verify

Check structure. Revise only when requested. Factual verification is separate.

1. Demand valid frontmatter, unique IDs, non-empty Intent, and one obligation per requirement.
   Require the exact three-item block, exactly one strength word in `Then`, and a real verification
   method.
2. Reject placeholders, blocking questions at `status: ready`, broken sources, and vague
   requirements with no same-line observable criterion.
3. Cut any section that improves neither clarity, scope, execution, verification, review, nor
   durable memory.
4. In check-only mode, report exact errors without editing. In write/revise mode, fix them and rerun.

## Output

Before handoff, cut repetition, softness, ceremony, and structural bloat without changing contracts,
identifiers, verbatim source text, evidence, or behavior. Rerun applicable checks. Return only
clickable Markdown links for the spec and every sidecar, with compact `~/.agents/...` labels and
fully expanded absolute destinations. Explain only a blocker, failed creation, incomplete
verification, or irreversible-action confirmation.

## Close

Once fully actioned and no downstream step needs it, require one human disposition for the artifact
and its sidecars: Delete, Leave, or Promote. Promote moves transient material into project-owned
permanence. Delete every selected path and verify absence; survivors block close.
