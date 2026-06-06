# `prd.md` — product intent

A PRD is a source document that records the **product intent** behind a body of work — the problem, the affected users, and the outcomes that define success — so that every downstream obligation has a single, citable origin of *why* it exists. It is a recognized **parent of a spec**: it asserts intent, it carries no obligations of its own, and it normalizes into a `spec.swarm.md` through the author pass, with its epistemic stance preserved across that promotion.

## Purpose & epistemic stance

A PRD asserts **intent**: it states *what outcome is wanted and why*, and nothing about the mechanism that would deliver it. That is the whole of the knowledge it is permitted to carry, and the boundary is load-bearing.

- A `prd.md` **MUST NOT** author `REQ`, `CONSTRAINT`, `INVARIANT`, or `INTERFACE` obligation blocks. Those blocks come into existence only when the PRD promotes to a `spec.swarm.md` via the author pass. Embedding them in the PRD would let an *intent* be read as an approved behavioral contract and silently bypass the authoring step where intent acquires obligation force — the same prohibition that keeps an audit from prescribing a fix or a bug-report from naming an implementation.
- Its goals are **outcome statements, never `REQ` blocks**; its release constraints are limits on *delivery*, never authored `CONSTRAINT` blocks; its success metrics describe *signals*, not verification bindings.
- A PRD is **non-authoritative until authored**. It does not govern the codebase the way a spec or an ADR does. It is the upstream statement of desire that an author pass reads, distills, and turns into obligations; once promoted, the PRD remains the durable record of the intent those obligations serve, and its stance (intent) is exactly what the promotion preserves.

The reason intent is captured as its own artifact rather than written straight into a spec is provenance: requirements practice distinguishes intent from evidence, proposal, decision, observation, defect, and discovery, and Swarm normalizes all of them into one obligation-bearing spec rather than pretending every intent begins as research. The PRD is the **intent** parent in that model.

## Filename & placement

The PRD obeys the `.swarm.` infix partition that separates compiler-visible files from working artifacts.

- A `prd.md` is a **working artifact**: its filename **MUST NOT** contain the `.swarm.` infix, and it uses a plain `.md` extension. It is structured Markdown governed by this artifact contract, not by the SOL grammar, and it is never parsed or emitted by a compiler.
- The one human-authored compiler-visible spec is `*.swarm.md`; emitted artifacts take a `*.swarm.*` name (e.g. `*.swarm.ir.json`, `*.swarm.trace.md`). A PRD is neither — it is a hand-authored source that *feeds* a spec, so it stays plain `.md`.

In an adopted project's `.swarm/` workspace, a PRD is a durable source artifact and lives under `sources/`:

```
.swarm/sources/prds/<slug>.md
```

It sits beside the other parents of a spec — `sources/specs/` (the `*.swarm.md` it promotes into), `sources/rfcs/`, `sources/research/`, `sources/audits/`, `sources/findings/`, and `sources/adrs/`. PRDs are **never** placed under `generated/` (that directory holds derived execution packets — task frames, traces, reviews — recreatable from sources) and **never** under `memory/` (durable recall; the index, glossary, patterns, and stale records). A PRD is desired-state source, so `sources/` is its only home.

## Required sections / fields, in order

A conformant `prd.md` carries the YAML frontmatter contract followed by seven sections, in this order. The `## Non-goals` section is mandatory and **MUST NOT** be empty — an absent boundary of intent is a defect, not an omission.

### Frontmatter contract

```yaml
type: prd          # fixed; identifies the artifact class
id: <slug>         # stable identifier; the citable name for this intent
status: draft      # one of: draft | accepted | superseded
created: <date>    # authoring date
updated: <date>    # last-revision date
```

### Sections

| # | Section | What it asserts | Stance rule |
| --- | --- | --- | --- |
| 1 | `## Problem` | The user or business problem in plain prose. | States what is wrong or missing — never how to fix it. |
| 2 | `## Users` | Who is affected and which segment the outcome serves. | Identifies the affected population; asserts no behavior. |
| 3 | `## Goals` | The outcomes that define success. | Outcome statements only; **never** `REQ` blocks, and never a mechanism. |
| 4 | `## Non-goals` | The outcomes explicitly out of scope — the boundary of intent. | **Mandatory; MUST NOT be empty.** An empty boundary is a defect. |
| 5 | `## Success metrics` | Measurable signals that a goal was met. | Each metric **SHOULD** be expressible as a future `monitor:` proof, because a metric that cannot be observed cannot later bind a `VERIFY BY`. |
| 6 | `## Release constraints` | Date, rollout, compliance, or dependency limits on shipping. | Constraints on *delivery* — never authored `CONSTRAINT` blocks. |
| 7 | `## Linked evidence` | References to the research and findings that ground the intent. | Cross-file refs use `<spec-id>#<local-id>` where an evidence item has a local id. |

The `## Success metrics` section is a table — `Metric | Target | How observed (future monitor: proof)` — because each row is the seed of a future observable check: when the PRD promotes, a metric that names *how it is observed* can later bind a `VERIFY BY <type>:<adapter>:<artifact>` on the obligation it justified, whereas an unobservable metric strands its goal with no path to proof.

## Copyable template

The copyable skeleton ships in the kernel at:

```
starter-kit/.agents/templates/prd.md
```

That file is the skeleton you copy to start a new PRD; **this page is its contract**. The template carries the frontmatter, the seven section headings in order, and inline guidance that restates the intent-only stance; this page is the authority on what each section means and what the PRD is forbidden to do. Where you are authoring a PRD by hand, copy the template, fill the seven sections, and keep every statement on the intent side of the line — the moment a sentence describes a mechanism or reads as an obligation, it belongs in the spec the author pass will produce, not here.

## Related

- **`docs/passes/author.md`** — the author pass: the single step that reads a PRD (and the other parents of a spec) and emits the `REQ`/`CONSTRAINT`/`INVARIANT`/`INTERFACE` obligation blocks, preserving the PRD's intent stance on promotion.
- **`docs/artifacts/spec.md`** — `spec.swarm.md`, the obligation-bearing contract a PRD promotes into; the only place product intent acquires obligation force.
- **`docs/artifacts/rfc.md`** — the **proposal** parent (`rfc.md`): where a PRD states *what outcome* is wanted, an RFC proposes *how* a technical approach would deliver it; a PRD often cites or originates an RFC.
- **`docs/artifacts/research.md`** — the **evidence** parent (`research.md`): the detached evidence store a PRD's `## Linked evidence` section points into to ground its intent.
- **`docs/artifacts/finding.md`** — the **discovery** parent (`finding.md`): a single durable fact a PRD may cite as evidence for the problem it states.
- **`docs/model/source-artifacts.md`** — the artifact set and the `.swarm.` infix partition that places `prd.md` as a conditional, never-required source-doc template.
