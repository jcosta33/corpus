# `research.md`

A research artifact is the framework's detached evidence store: it surveys options and evidence behind a single decision-informing question, commits to no decision, and feeds the obligations only by promoting INTO a `spec.swarm.md`. It is a parent of a spec, never a spec itself, and — unlike every other parent — it is not bound to one downstream consumer; one research artifact may inform many at once. This page is the contract that file class must satisfy.

## Purpose & epistemic stance

A research artifact asserts one kind of knowledge: **inquiry**. Its stance is **investigation** — it records what an inquiry has surveyed and what remains open, and it commits to no decision. It is detached, citable evidence gathered to inform a choice, not the choice itself; it promotes rather than governs.

This is what most distinguishes research from the other source artifacts. An audit is observation of present-state risk; a bug-report is diagnosis of a defect; a finding is one durable, accepted fact. Research is broader and earlier: it surveys a field of options and evidence before any of them has been accepted, and its job is to leave the decision space well-mapped, not to close it.

What a research artifact MUST NOT do:

- It MUST NOT carry its own obligation blocks. A `research.md` MUST NOT author `REQ`, `CONSTRAINT`, `INVARIANT`, or `INTERFACE` blocks. Surveyed evidence has no obligation force until it is **promoted into a `spec.swarm.md`** by the author step; only there does it acquire binding force as SOL obligations. Research that wrote its own obligation blocks would let an inquiry be read as an approved contract and bypass authoring — the failure mode the investigation stance exists to prevent.
- It MUST NOT commit to a decision. Its findings survey the options; the `## Recommendation` it ends with is advisory — a direction the spec author MAY lift, not a committed obligation. Resolving an open question inside the research by asserting a decision breaks the inquiry stance; an open question carries forward as a `QUESTION` candidate, it is not silently settled here.
- It MUST NOT let its findings or open questions vanish on promotion. Each finding (`R-NNN`) and each open question (`Q-NNN`) is durable: an accepted finding promotes to a standalone `finding.md`, and an open question carries forward as a `QUESTION` block in the promoted spec rather than being dropped.

Nothing enforces this stance at runtime ([Swarm ships no runtime](README.md)); it is held by the distillation-loss and source-authority discipline, where a lower-authority inquiry MUST NOT silently override a higher-authority artifact. A conformant repository MUST NOT ship a tool whose job is to police artifact composition.

Because research is the *detached* evidence store, its scope is wider than a single downstream artifact. Keeping evidence detached minimizes copying, preserves provenance, and reduces distillation loss when upstream facts evolve: one research artifact MAY feed many PRDs, RFCs, specs, ADRs, findings, or audits at once. A downstream artifact references a span of it by the cross-file convention `<research-id>#R-NNN` (for example `password-recovery-survey#R-002`), so a finding can be cited without copying its evidence into every consumer.

## Filename & placement

`research.md` is a **working artifact** in the filename sense — a plain `.md` source-document, not a compiler-visible spec. The discriminator is the `.swarm.` filename infix:

- The single human-authored compiler-visible spec is `*.swarm.md`.
- Emitted, contract-shaped Swarm outputs carry the `.swarm.*` infix (for example `*.swarm.ir.json`, `*.swarm.trace.md`).
- Source-documents and working artifacts — research, audits, bug-reports, findings, tasks, reviews, ADRs — carry **no** infix and use a plain `.md` extension.

A research artifact is structured Markdown governed by this contract; it is **not** parsed as SOL source, and it **MUST NOT** be given a per-artifact `.swarm.*` name. A conformant tool treats the missing infix as sufficient proof not to parse the file as a spec.

In an adopted project, research is a durable source artifact — a `type: research` document committed in `specs/<feature>/` beside the `spec.swarm.md` it informs: desired-truth-adjacent evidence, committed and never recreated. A detached inquiry that feeds many specs may start its own feature folder; its accepted `R-NNN` findings promote to `finding.md` instances in `.agents/memory/`.

It is **not** execution scratch: it is never one of the recreatable execution packets (task frames, traces, reviews) or transient scratch. As a Tier-3 stdlib source-doc it is **conditional** — the starter kit MUST ship the template, but a conformant repo need not have instantiated any research artifact, and a missing instance is not a conformance gap.

## Required sections & fields, in order

### YAML frontmatter

| Field | Required | Meaning |
| --- | --- | --- |
| `type` | always | Literal `research`. |
| `id` | always | The research slug (matches the filename and the `<research-id>` half of every `#R-NNN` cross-file ref). |
| `status` | always | Lifecycle of the inquiry — `open` while it is still surveying, advancing as findings are accepted and the artifact promotes. |
| `created` / `updated` | always | Provenance timestamps (`created` when the inquiry opens; `updated` on each change). |

### Body sections

The four body sections are required and MUST appear in this order. The order is the shape of an inquiry: state the question, survey the evidence, surface what is still open, then advise.

| Section | Meaning |
| --- | --- |
| `## Question` | The single, specific, decision-informing question the inquiry exists to answer, in one or two sentences. If it cannot be stated concisely, the scope is unclear and MUST be narrowed first. |
| `## Findings` | The surveyed evidence, each finding a citable span with a stable local id `R-NNN`. Each carries **Claim** (the one durable fact), **Evidence** (file / command / output / external source — enough to re-verify), **Confidence** (`high \| medium \| low`), and **Bears on** (the downstream question, option, or obligation-to-be it informs). Survey only — draw no conclusion here. |
| `## Open questions` | Unresolved points the inquiry surfaced but did not settle, each a `QUESTION` candidate `Q-NNN`. Each MUST stay open until resolved and carries forward to the promoted spec; do not resolve one here by asserting a decision. |
| `## Recommendation` | A specific, actionable direction the spec author MAY lift into a `spec.swarm.md`, naming the `R-NNN` findings that ground it. Advisory, not a committed decision; it authors no obligation blocks. If no recommendation is possible, state WHY and which open `Q-NNN` would unblock one. |

The `R-NNN` finding ids and `Q-NNN` question ids are the load-bearing local handles: `R-NNN` is what a downstream artifact cites as `<research-id>#R-NNN` and what an accepted finding promotes to a `finding.md` under; `Q-NNN` is what survives into the promoted spec's `## Questions` as a `QUESTION` block.

## Copyable template

The copyable skeleton is `starter-kit/.agents/templates/research.md`. That file is the empty starting point an author copies to create a new research artifact; **this page is its contract** — the meaning of each section and field, the epistemic boundary (inquiry, never decision; no obligation blocks), and the placement rules the skeleton is filled in against. In an adopted project the same skeleton ships with the installed starter kit.

## Related

- [`docs/passes/author.md`](../passes/author.md) — the step that normalizes a research artifact into a `spec.swarm.md`: the `## Recommendation` seeds the spec's obligations, open `Q-NNN` questions become its `QUESTION` blocks, and the inquiry stance is preserved (non-authoritative until authored).
- [`docs/passes/promote.md`](../passes/promote.md) — the step that dispositions each accepted `R-NNN` finding into a standalone `finding.md` and indexes it for recall.
- [`docs/artifacts/finding.md`](finding.md) — the durable-fact artifact an accepted research finding promotes to; a finding is one evidenced proposition, where research is the survey it came out of.
- [`docs/artifacts/audit.md`](audit.md) — the sibling observation-only source artifact; both feed the obligations only by promoting INTO a spec and carry no obligations of their own.
- [`docs/artifacts/prd.md`](prd.md) — the sibling intent source artifact; research is one of the evidence stores a PRD's `## Linked evidence` cites by `#R-NNN`.
- [`docs/artifacts/spec.md`](spec.md) — the obligation source a research artifact promotes *into*; the one home where surveyed evidence acquires obligation force.
