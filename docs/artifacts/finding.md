# `finding.md`

A finding is one durable, provenance-anchored project fact discovered during work — the unit of evidence the memory recall map links into so a future task can find what an earlier task learned. This page is the contract that file class must satisfy.

## Purpose and epistemic stance

A finding asserts **evidence**: a single, falsifiable proposition learned while doing real work, anchored to the artifacts that ground it and scoped to the conditions under which it holds. It is durable *discovery*, not *intent* — it records what was found to be true, never what behavior the system is required to have.

That stance fixes a hard boundary on what a finding may contain:

- A finding **MUST NOT** carry its own obligation blocks. It declares no `REQ`, `CONSTRAINT`, `INVARIANT`, or `INTERFACE` of its own force. A finding has no authority to require behavior; if a discovery implies a behavior the system should have, that intent is promoted *into* a spec, where it acquires obligation force, and only there. This mirrors the discipline observation-only artifacts follow — an audit records present-state risk but declares no new intended behavior; a bug-report root-causes a defect but prescribes no fix.
- A finding **MUST** state exactly **one** durable fact. A claim that bundles several propositions cannot be falsified, scoped, or staleness-checked as a unit; split it into one finding per fact.
- A finding **MUST** be falsifiable. Without provenance — the file, command, output, or source that grounds it — a finding is chat, not memory: unindexed, unprovenanced, and unable to be re-verified or retired.
- A finding **MUST** name its scope. If it cannot say *when* the fact applies (`## Applies when`), it **MUST NOT** be promoted. A fact with no scope envelope is dead weight against memory density and cannot be matched to a future task.

Once a finding reaches `accepted`, its **body is immutable**: its status may advance, but the recorded fact and evidence do not silently change. A finding that is later disproved or replaced is retired through status (`stale`/`superseded`) or withdrawn through rollback — never edited in place. This keeps the discovery chain auditable.

Where a finding governs once accepted: it carries weight as durable evidence in the source-authority model, ranking below intent (specs) and decisions (ADRs) — it informs and grounds obligations, it does not outrank them. A promotion that would *weaken* an existing obligation is forbidden at every target, because memory is the floor of the authority model, not a lever over intent.

## Filename and placement

`finding.md` is a **working artifact**, not a compiler-visible source. The discriminator is the `.swarm.` filename infix:

- The single human-authored compiler-visible spec is `*.swarm.md`.
- Emitted, contract-shaped Swarm outputs carry the `.swarm.*` infix (for example `*.swarm.ir.json`, `*.swarm.trace.md`).
- Working artifacts — findings, tasks, reviews, ADRs — carry **no** infix and use a plain `.md` extension.

A finding is structured Markdown governed by this contract; it is **not** parsed as SOL source, and it **MUST NOT** be given a per-artifact `.swarm.*` name. A conformant tool treats the missing infix as sufficient proof not to parse the file as a spec.

In an adopted project, a finding is a durable recall artifact — a `type: finding` document committed in **`.agents/memory/`**, where the recall map indexes it and patterns generalize from it:

- A finding is durable discovery, committed in `.agents/memory/` (the recall store), not a per-feature source doc.
- The Tier-1 recall map (`memory/INDEX.md`) links each promoted finding with a "Load when".
- A Tier-2 pattern is recurring knowledge that **generalizes** several findings.

A finding is **not** execution scratch: it is desired-truth-adjacent durable knowledge, committed, and never one of the recreatable execution packets (task frames, traces, reviews) or transient scratch. It is the Tier-2 evidence store that the Tier-1 recall map points at; the index links into a finding's body but never duplicates it. A single finding is **never** promoted directly to a pattern — a pattern distills two or more corroborating findings and must cite the findings it generalizes.

## Required sections and fields, in order

### YAML frontmatter

| Field | Required | Meaning |
| --- | --- | --- |
| `type` | always | Literal `finding`. |
| `id` | always | The finding slug (matches the filename / index entry). |
| `status` | always | `candidate \| accepted \| promoted \| rejected \| stale \| superseded`. Advances forward; goes `stale` when `content_hash` no longer matches the cited source, `superseded` when replaced. |
| `created` / `updated` | always | The provenance timestamp (`created` at discovery; `updated` on each status transition). |
| `confidence` | always | `high \| medium \| low`. |
| `origin_obligations` | on promotion | The obligation IDs (`AC-`/`C-`/`I-`/`IF-…`) the fact was discovered against. |
| `origin_traces` | on promotion | The trace entries (`*.swarm.trace.md#<ID>`) that produced the evidence. |
| `pass` + `profile` | on promotion | The step and heuristic profile under which it was found (for example `review` + `skeptic`). |
| `reviewer_or_tool` | on promotion | The human reviewer or tool/adapter that confirmed it. |
| `content_hash` | on promotion | Hash of the cited source/surfaces at promotion time; this is the input the staleness check compares against. |

The full provenance set is **mandatory on every finding that reaches `accepted` or `promoted`**. A `candidate` finding may be drafted with provenance fields still empty, but it MUST NOT be promoted until they are populated — provenance is what makes the fact falsifiable and staleness-checkable.

### Body sections

| Section | Meaning |
| --- | --- |
| `# Finding: <title>` | The finding's title. |
| `## Claim` | The one durable fact, stated as a single falsifiable proposition. |
| `## Evidence` | The File / Command / Output / Source references that ground the claim. |
| `## Applies when` | The scope conditions under which the fact holds. **Mandatory** — a finding that cannot name this MUST NOT be promoted. |
| `## Does not apply when` | The conditions under which the fact does **not** hold; the other half of the scope envelope. |
| `## Related obligations` | Obligation IDs the fact bears on, beyond its `origin_obligations[]` provenance. |
| `## Promotion target` | The promotion route: keep-scoped, promote into spec / audit / ADR / memory pattern, or mark stale/superseded. |
| `## Status history` | Append-only status transitions, one line per transition; prior lines are never edited. |

`## Applies when` and `## Does not apply when` mirror the `Load when` trigger the finding's `memory/INDEX.md` entry carries: the scope that decides when a future task should recall the fact.

## Copyable template

The copyable skeleton is `starter-kit/.agents/templates/finding.md`. That file is the empty starting point an author copies to create a new finding; **this page is its contract** — the meaning of each field, the epistemic boundary, and the placement rules the skeleton is filled in against. In an adopted project the same skeleton ships with the installed starter kit.

## Related

- `docs/passes/promote.md` — the step that dispositions each discovery, writes a promoted finding to `sources/findings/`, and indexes it in `memory/INDEX.md` with a `Load when`.
- `docs/passes/review.md` and `docs/passes/verify.md` — the steps that most often surface findings (against obligations and traces).
- `docs/artifacts/audit.md` — the sibling observation-only source artifact; a present-state risk promotes into a spec rather than carrying obligation force here.
- `docs/artifacts/adr.md` — the sibling decision artifact; a finding that captures a chosen architectural trade-off promotes into an ADR.
- `docs/artifacts/spec.md` — the obligation source a finding promotes *into* when its discovery implies new intended behavior.
- `docs/artifacts/memory.md` — the two-tier recall model: the `INDEX.md` map plus the `patterns/` knowledge that generalizes multiple findings.
