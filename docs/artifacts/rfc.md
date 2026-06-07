# `rfc.md` — technical proposal

An RFC is a source document that records **one technical proposal** put forward for a decision — the problem it solves, the advocated approach, the alternatives weighed, and the exact decision being requested — so that *why this approach and not the alternatives* outlives the change that prompted it. It is a recognized **parent of a spec**: it advocates a mechanism, it commits nothing and carries no obligations of its own, and once its requested decision is made it promotes into an `adr.md` (the immutable decision) and/or a `spec.swarm.md` (the behavioral contract) through the author step, with its proposal stance preserved across that promotion.

## Purpose & epistemic stance

An RFC asserts a **proposal**: it advocates a single technical approach in enough detail to be evaluated, and records the comparison that justifies preferring it — but it decides nothing. Its knowledge is *pre-decision*. That boundary is load-bearing.

- An `rfc.md` **MUST NOT** author `REQ`, `CONSTRAINT`, `INVARIANT`, or `INTERFACE` obligation blocks. Those blocks come into existence only when the RFC promotes — to an accepted `adr.md`, an approved `spec.swarm.md`, or both — via the author step. Embedding them in the RFC would let a *proposal* be read as an already-approved contract and silently bypass the authoring step where a proposal acquires obligation force, and the decision step where it acquires commitment. This is the same prohibition that keeps a PRD's goals from being read as `REQ` blocks, an audit from prescribing a fix, and a bug-report from naming an implementation.
- It **commits to none of its alternatives** until the requested decision is made. An RFC advocates one approach but is, until accepted, a record of an open choice. Its `## Migration plan` describes steps and ordering from the present state to the proposed state — it is **never** a set of authored `TRACE` blocks; tracing is what happens after a spec exists, not within a proposal.
- Its `## Alternatives` section is **mandatory and "none considered" is a defect**, because an RFC's durable value is precisely the comparison it records: the reason a future reader can trust the chosen approach is that the rejected ones are written down beside it.
- It is **non-authoritative until accepted-and-authored**. An RFC does not govern the codebase the way a spec or an ADR does. It is the upstream proposal that an author step reads and turns into obligations (and that a decision turns into an ADR); once promoted, the RFC remains the durable record of the proposal those obligations and that decision serve.

A proposal is captured as its own artifact, rather than written straight into a spec or an ADR, for provenance: the RFC is the **proposal** parent among the [recognized parents of a spec](README.md#3-the-recognized-parents-of-a-spec) — the recognized place where an approach lives while it is still being argued, and (for the decision itself) the upstream of an ADR.

## Filename & placement

The RFC obeys the `.swarm.` infix partition that separates compiler-visible files from working artifacts.

- An `rfc.md` is a **working artifact**: its filename **MUST NOT** contain the `.swarm.` infix, and it uses a plain `.md` extension. It is structured Markdown governed by this artifact contract, not by the SOL grammar, and it is never parsed or emitted by Swarm.
- The one human-authored compiler-visible spec is `*.swarm.md`; emitted artifacts take a `*.swarm.*` name (e.g. `*.swarm.ir.json`, `*.swarm.trace.md`). An RFC is neither — it is a hand-authored source that *feeds* a spec and/or an ADR, so it stays plain `.md`.

In an adopted project, an RFC is a durable source artifact — a `type: rfc` document committed in `specs/<feature>/`, beside the `spec.swarm.md` it can promote into (or, once decided, an ADR in `decisions/`). An RFC is **never** execution scratch (the derived task frames, traces, and reviews a run produces, recreatable from sources) and **never** durable recall (the index, glossary, patterns, and stale records). An RFC is a proposed-design source, so the feature folder is its home.

## Required sections / fields, in order

A conformant `rfc.md` carries the YAML frontmatter contract followed by six sections, in this order. The `## Alternatives` section is mandatory and **MUST NOT** record "none considered" — an absent comparison is a defect, not an omission.

### Frontmatter contract

```yaml
type: rfc            # fixed; identifies the artifact class
id: <slug>           # stable identifier; the citable name for this proposal
status: proposed     # one of: proposed | accepted | rejected | superseded
created: <date>      # authoring date
updated: <date>      # last-revision date
```

### Sections

| # | Section | What it asserts | Stance rule |
| --- | --- | --- | --- |
| 1 | `## Problem` | The technical problem that forces a proposal. | Cite the originating `prd.md`, `finding.md`, or `audit.md` where one exists. States the problem, never the obligation. |
| 2 | `## Proposal` | The advocated approach, in enough detail to evaluate. | Describes a mechanism; authors **no** obligation blocks. |
| 3 | `## Alternatives` | Other approaches and why each is weaker than the proposal. | **Mandatory; "none considered" is a defect.** An RFC's value is the comparison it records. |
| 4 | `## Migration plan` | How adoption proceeds from the present state to the proposed state. | Steps and ordering only; **never** authored `TRACE` blocks. |
| 5 | `## Open questions` | Unresolved points that gate the decision. | Each is a `QUESTION` (`Q-NNN`) candidate until resolved; an RFC with a blocking open question **MUST NOT** be promoted. |
| 6 | `## Decision requested` | The exact decision being asked for. | Names the promotion target — an accepted `adr.md` and/or an approved `spec.swarm.md`. |

The `## Alternatives` section is a table — `Alternative | Why weaker than the proposal` — because each row is a recorded judgment that a future reader (or a superseding RFC) can reopen: the comparison is the artifact's point, so an RFC that records no alternative has discarded the one thing it exists to preserve. The `## Open questions` section is a **promotion gate**: every unresolved item is a `QUESTION` (`Q-NNN`) candidate, and while any question that blocks the proposal stays open the RFC **MUST NOT** promote — a proposal cannot become an obligation or a decision while the thing that gates it is still undecided.

## Copyable template

The copyable skeleton ships in the starter kit at:

```
starter-kit/.agents/templates/rfc.md
```

That file is the skeleton you copy to start a new RFC; **this page is its contract**. The template carries the frontmatter, the six section headings in order, and inline guidance that restates the proposal-only, no-obligation stance; this page is the authority on what each section means and what the RFC is forbidden to do. Where you are authoring an RFC by hand, copy the template, fill the six sections, and keep every statement on the proposal side of the line — the moment a sentence reads as an approved behavioral contract it belongs in the `spec.swarm.md` the author step will produce, and the moment it reads as a settled choice it belongs in the `adr.md`, not here.

## Related

- **`docs/passes/author.md`** — the author step: the single step that reads an RFC (and the other parents of a spec) and emits the `REQ`/`CONSTRAINT`/`INVARIANT`/`INTERFACE` obligation blocks, preserving the RFC's proposal stance on promotion.
- **`docs/artifacts/adr.md`** — `adr.md`, the immutable decision an accepted RFC promotes into; once a `## Decision requested` is answered, the chosen approach becomes a dated, immutable architecture decision.
- **`docs/artifacts/spec.md`** — `spec.swarm.md`, the obligation-bearing contract an RFC's `## Proposal` promotes into; the only place a proposed mechanism acquires obligation force.
- **`docs/artifacts/prd.md`** — the **intent** parent (`prd.md`): where an RFC proposes *how* a technical approach delivers an outcome, a PRD states *what outcome* is wanted and why; an RFC's `## Problem` often cites the originating PRD.
- **`docs/artifacts/finding.md`** — the **discovery** parent (`finding.md`): a single durable fact an RFC's `## Problem` may cite as evidence for the proposal it forces.
- **`docs/artifacts/audit.md`** — the **observation** parent (`audit.md`): observed present state and risk an RFC's `## Problem` may cite as the pressure that forces a proposal.
- **`docs/model/source-artifacts.md`** — the artifact set and the `.swarm.` infix partition that places `rfc.md` as a conditional, never-required source-doc template alongside the other parents of a spec.
