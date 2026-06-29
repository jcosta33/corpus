# The basic workflow

The loop:

```text
Pull -> (Inventory) -> Spec -> (Change Plan) -> Task -> Run -> Review -> Close
        optional       optional
```

Every artifact is markdown in the workspace. See [where files live](03-where-files-live.md).

## 1. Pull

Bring in the upstream ask. Point the spec's `sources` straight at the origin — a ticket URL, an
issue, or `self` — or, when you want the raw request kept verbatim, capture it as an intake file
first. Intake is optional; the spec is the unit.

Capture intake when work starts from a ticket, issue, chat thread, support note, or PR description
and you want the original preserved.

Do:

- copy the source text verbatim
- record source, URL, and capture date
- avoid interpretation

Skip this when the work is self-originated and the spec can name its source directly.

## 2. Inventory

Map existing code before changing it.

Use this for brownfield areas, unclear ownership, risky behavior, or code no one fully understands.

Do:

- list observed modules, interfaces, tests, and unknowns
- cite files and lines
- avoid prescribing fixes

Skip this when the relevant code is already understood.

## 3. Spec

State what must be true.

Do:

- write one requirement per behavior
- give each requirement an `AC-NNN` id
- add `Verify with:` for every requirement
- list non-goals and open questions

A spec with blocking open questions stays `draft`.

## 4. Change Plan

Plan structural work.

Use this for migrations, rewrites, schema changes, broad refactors, or cross-repo changes.

Do:

- name behavior that must survive
- split work into waves
- give every wave a verification step
- state rollback or cutover criteria

Skip this for small, local feature work.

## 5. Task (only when splitting)

Most work is one spec → one implementer: **no task file** — the implementer works from the spec and
fills its `## Execution` section. Cut tasks only when one spec splits into **parallel slices**.

When you split, each task:

- copies a scope-subset from the spec or change plan
- names `Do not change` areas
- includes every verify command the worker must run
- stays write-disjoint from its sibling tasks

A task does not add requirements.

## 6. Run

The worker implements the spec (or, when split, the task).

Do:

- work on a branch or worktree
- run every verify command
- paste real command output
- record the run in the spec's `## Execution` (or the task): changed files, out-of-scope edits, blocked questions, and candidate findings

`Tests passed` without output is not evidence.

## 7. Review

A non-implementer judges the result against the spec (and the task, when split) — never the
implementer. For a trivial change you verified yourself, you are that judge.

The formal review — a `reviews/` packet, a review lead running independent lenses — is the
form for a substantial or high-diffusion change. It is optional for a trivial, low-diffusion
one. The independent judgment is not.

Do, when you write the packet:

- create one coverage row per scoped requirement
- mark empty evidence as `Unverified`, never `Pass`
- route exceptions to human attention
- spot-check at least one green row

See [reviewing output](08-reviewing-output.md).

## 8. Close

Record the final state.

Do:

- merge, block, or send back for follow-up
- save durable lessons as findings
- record any decision worth keeping in `decisions/`
- update `status.md`
- link closed work to its review packet while the packet is retained

See [saving findings](09-saving-findings.md).

## Common paths

| Work | Path |
| --- | --- |
| Small feature | Pull -> Spec -> Task -> Run -> Review -> Close |
| Bug fix | Pull -> amend spec -> Task -> Run -> Review -> Close |
| Brownfield change | Pull -> Inventory -> Spec -> Task -> Run -> Review -> Close |
| Migration or rewrite | Pull -> Inventory -> Spec -> Change Plan -> wave Tasks -> Reviews -> Close |
| PR that already exists | Intake the PR -> write the acceptance bar -> Review |

## What not to skip

For code-changing work, keep:

- verification output
- independent review — a non-implementer judges it; the formal packet scales with risk
- evidence for every `Pass`
- a visible record of blocked or unverified work

## Related

- Next: [Where files live](03-where-files-live.md)
- Previous: [What is Corpus?](01-what-is-corpus.md)
