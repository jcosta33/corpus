# `audit.md`

An audit is an observation-only source artifact: it records present-state risk, debt, drift, duplication, or unsafe patterns as they exist *today*, grounds each observation in evidence, and feeds the obligation graph only by promoting INTO a `spec.swarm.md`. It is a parent of a spec, never a spec itself, and it carries no obligations of its own.

## Purpose & epistemic stance

An audit asserts one kind of knowledge: **what is true now**. Its stance is **observation-only** — it describes the present state of a system (code, artifacts, surfaces) and the risk that state carries, and it asserts no new intended behavior. It is durable, evidence-anchored discovery of risk, not a statement of intent and not a fix.

What an audit MUST NOT do:

- It MUST NOT carry its own obligation blocks. An `audit.md` MUST NOT author `REQ`, `CONSTRAINT`, `INVARIANT`, or `INTERFACE` blocks. Observed risk has no obligation force until it is **promoted into a `spec.swarm.md`** by the author pass; only there does it acquire binding force as SOL obligations. An audit that writes its own obligation blocks would let an observation be read as an approved contract and bypass authoring — the failure mode the observation-only stance exists to prevent.
- It MUST NOT prescribe a fix inline. An audit names what *is* and the risk it carries; it does not state the remedy. The remedy is a downstream decision that the author pass (for a spec change) or a fix task (for a defect) owns. Recommending *candidate obligations a future spec should carry* — in plain prose — is permitted and expected; writing those obligations as SOL blocks here is not.
- It MUST NOT assert intended behavior. Stating what the system *should* do is intent; that belongs to a spec (or a PRD that promotes to one), not to an observation of the current state.

This stance is held by the surrounding distillation-loss and source-authority discipline of the framework — when content crosses the boundary from an observation into a spec, the loss budget governs what may be dropped and an observation MUST NOT silently override a higher-authority artifact. It is not enforced by any gatekeeper tool: Swarm has no runtime, so nothing here is parsed, checked, or executed by shipped code. The discipline lives in the language and reference layer; a conformant repository MUST NOT ship a tool whose job is to police artifact composition.

Two named specializations reuse this exact template, frontmatter, and stance and differ only in conventional content: a **benchmark report** (observation-only performance measurement) and a **cleanup report** (observation-only debt/risk inventory). They parse exactly as an audit and MUST NOT introduce their own block types or behavior.

## Filename & placement

An audit is a **working artifact**, not a compiler-visible source. Swarm partitions every pipeline file by whether its name carries the literal `.swarm.` infix before the final extension:

- The human-authored, compiler-visible spec is `*.swarm.md` — the only hand-written file that carries the infix.
- Emitted, contract-shaped outputs are `*.swarm.*` (e.g. `*.swarm.ir.json`, `*.swarm.trace.md`).
- Working artifacts — including this one — are plain `.md` with **no** `.swarm.` infix.

Therefore the file is named `audit.md` (or a descriptive `<topic>.audit.md` / `<topic>.md` in a folder that scopes it). It MUST NOT be named `*.swarm.md`; doing so would mark an observation as a compiler-visible source spec and is a placement defect.

In an adopted project's `.swarm/` workspace, an audit is **desired-side durable source material** and lives under sources:

- `.swarm/sources/audits/` — the canonical home; an audit defines durable knowledge about the present state and is committed.
- It does **not** live in `.swarm/generated/` (that holds recreatable execution packets — task frames, traces, reviews) or in `.swarm/status/` (observed satisfaction and drift, which never redefines intent).
- On resolution, a retired audit moves to `.swarm/archive/`, linked to the spec, finding, or task it promoted into — it is not silently deleted.

A conformant kernel ships the `audit.md` template, but a conformant repository need not contain any audit instance; audits are conditional, written only when a present-state observation is worth recording.

## Required sections / fields, in order

### Frontmatter contract

YAML frontmatter delimited by `---`, with at minimum:

| Field | Meaning |
| --- | --- |
| `type: audit` | Names the artifact class. Required. |
| `id` | A stable slug identifying this audit. Required. |
| `status` | Lifecycle marker (`draft` initially; advances as the audit is acted on). |
| `created` / `updated` | Authoring and last-revision timestamps. |

A specialization MAY set `type: benchmark` or `type: cleanup`, but parses exactly as an audit.

### Body sections, in order

| Section | Required content | Stance rule |
| --- | --- | --- |
| `# Audit: <title>` + stance note | The title, then a one-line reminder that this is observation-only and authors no obligation blocks. | Sets the reader's frame; the note is part of the contract. |
| `## Scope` | What was inspected and what was deliberately left out — the code paths, artifacts, or surfaces under audit and the boundary of the observation. State both **In scope** and **Out of scope**. | Bounds the observation; an unstated boundary makes the audit unfalsifiable. |
| `## Observations` | What is true *today*, each item citing the evidence that grounds it (`file:line`, command output, grep result, or other observable). | Present state only. State the fact, never the fix. Each observation MUST be evidence-cited — an ungrounded, fact-shaped claim is a defect; an explicit claim→support structure is itself a primary quality axis of an agent's report [[REPORTLOGIC]](../research/sources.md#REPORTLOGIC). |
| `## Risks` | Things that could go wrong but were **not** observed firing yet, each with the conditions under which they would fire. | Still observation, not prescription. Name the failure mode and its trigger, not the remedy. |
| `## Recommended obligations` | Candidate obligations a downstream author pass would promote into a `spec.swarm.md`, described in **plain prose** — what the spec SHOULD require. | MUST NOT be written as SOL obligation blocks. The author pass emits the blocks on promotion; this section only nominates them. |

Promotion target: an audit promotes to a `spec.swarm.md` via the author pass (its `## Recommended obligations` seed the spec's `REQ`/`CONSTRAINT`/`INVARIANT` blocks). It may also feed a `finding.md` (a single durable fact extracted from an observation) or a refactor task, but it never becomes code directly.

## Severity calibration

Each observation and risk carries a **severity** so that a downstream author or fix task can triage. The scale has three rungs:

| Severity | Meaning |
| --- | --- |
| **BLOCKER** | Safe downstream work cannot proceed until this is handled — a security hole, a correctness cliff, or an unsafe pattern that will produce wrong results. |
| **MAJOR** | Materially costs velocity or reliability; it must be scheduled explicitly rather than batched away. |
| **MINOR** | Cosmetic or isolated; acceptable to defer or batch with adjacent work. |

The calibration heuristic is **severity by blast radius, not by discovery order**: a finding's rung reflects *what breaks if the observation is wrong* — how far the damage spreads and how unsafe it leaves downstream work — not how hard the finding was to surface or how clever the search that found it was. A subtle defect that took an exhaustive grep to locate is still MINOR if its blast radius is one cosmetic edge case; an obvious gap is a BLOCKER if it lets unsafe work proceed unchecked. When a severity is promoted or demoted and the call is contestable, record the reasoning in the observation so a reviewer can re-derive it. Calibrating by blast radius is what keeps severity falsifiable instead of a vibe — for why grounded, falsifiable observations are the load-bearing part of an audit, see [the evidence behind source artifacts](../research/sources.md).

## Copyable template

The copyable skeleton ships at:

```
kernel/.agents/templates/audit.md
```

That template is the skeleton you copy to start a new audit; **this page is its contract** — it states what each section means, the stance the artifact must hold, and where the file lives. Copy the template, fill every placeholder, keep the stance note, and ground every observation in evidence. A shipped, uninstantiated template MUST NOT be treated as a populated artifact.

## Related

- [`finding.md`](finding.md) — a single durable, evidenced fact; an audit observation may be extracted into one.
- [`bug-report.md`](bug-report.md) — the sibling diagnosis-only source artifact; where an audit observes standing risk, a bug-report diagnoses a reproduced defect and promotes into a fix task.
- [`spec.swarm.md`](spec.md) — the obligation-bearing source an audit promotes INTO; the only place observed risk acquires obligation force.
- [`research.md`](research.md) / [`prd.md`](prd.md) / [`rfc.md`](rfc.md) — the other parents of a spec, each with its own preserved epistemic stance.
- [The `author` pass](../passes/author.md) — the pass that promotes an audit's recommended obligations into a spec's SOL blocks.
- [The `promote` pass](../passes/promote.md) — routes durable discovery (including findings extracted from audits) into memory and sources.
- [Source artifacts and the `.swarm.` infix partition](../model/source-artifacts.md) — the full artifact set, the two-class partition, and the conformance tiers this artifact sits in.
