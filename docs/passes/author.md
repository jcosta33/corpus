# The `author` step

> Swarm's reference for the `author` step: how human intent enters the flow as `spec.swarm.md`, and how the epistemic stance of each source parent is preserved when it is authored in.

`author` is the first of the **nine steps** of the Swarm flow (`author -> lint -> improve -> lower -> decompose -> implement -> verify -> review -> promote`). This page is the reference for that single step.

Like every Swarm step, `author` has **no runtime**: it is a contract a human, an agent following a step guide, or a future tool performs. Nothing here is shipped code.

## What the step does

The `author` step **captures human intent as SOL obligations and APS prose**, producing the first analyzable artifact of the flow.

| Aspect | Value |
|---|---|
| Phase(s) | **entry** — pre-`PARSE` |
| Input artifacts | chat, `research.md`, `audit.md`, `bug-report.md`, prior `spec.swarm.md` |
| Output artifact | `spec.swarm.md` (draft: prose + SOL blocks) |
| Typical carrier profile | Architect (spec), Surveyor/Researcher (research), Auditor (audit), Bug Hunter (bug-report) |
| Lint layer | — (produces the input to `lint`; emits no lint codes itself) |

## Where it sits in the flow

The seven **phases** are `PARSE -> NORMALIZE -> LOWER -> EXECUTE -> VERIFY -> REVIEW -> PROMOTE`. `author` is deliberately **outside** that phase taxonomy: it is the *entry step* that runs **before `PARSE`**, because its output (`spec.swarm.md`, written to the feature folder `specs/<feature>/` beside any source docs it normalized) is the first artifact Swarm can analyze.

Two contract notes follow from this position:

- **`author` is not itself analyzable.** Everything *downstream* of `author` is analyzable; the author step is the boundary at which un-structured intent (chat, working documents) becomes the structured, analyzable spec. Analysis begins at `lint` (the `PARSE` + `NORMALIZE` step), not at `author`.
- **`author` feeds `lint`.** The next step, `lint`, is non-mutating and decides well-formedness; the only step permitted to rewrite the spec is `improve`, and only semantics-preservingly. So `author` is where new intent legitimately *enters*; steps after it normalize and structure that intent rather than re-invent it.

## `author` ships author guides, not a step guide

The shipped stdlib guide set (ADR-0042) is: a dedicated step guide for each of `lint`, `decompose`, `review[profile: skeptic]`, and `promote`; nine per-`task_kind` `implement` guides (`write-feature`/`fix`/`refactor`/`rewrite`/`migration`/`performance`/`testing`/`documentation` + `fix-flaky-test`); six author guides (`write-spec`/`audit`/`research`/`bug-report`/`prd`/`rfc`); and two cross-cutting fragments (`empirical-proof`, `distillation-discipline`). Each ships as a standalone skill carrier.

`author` is **not** served by a single step guide: it is served by the **six author guides** — `write-spec`, `write-audit`, `write-research`, `write-bug-report`, `write-prd`, and `write-rfc` — one per recognized parent that normalizes into a spec. Across the nine steps, the six analysis steps — `lint`, `improve`, `lower`, `decompose`, `review`, `promote` — each ship a dedicated step guide; `implement` is served by the nine per-`task_kind` implement guides; `author` by these six author guides; and `verify` by the `empirical-proof` cross-cutting fragment. Every step now has a guide, but a guide is an optional aid, not a validity gate — the step contract is the binding artifact, and a guide, when used, is SOFT control (Invariant 2): it MUST NOT define SOL/APS semantics, modality, authority order, or verification meaning.

## Authoring is parent-normalization: epistemic stances are preserved

`author` is the step through which a spec's recognized **parents** normalize into `spec.swarm.md`. The recognized parents are PRD, research, RFC, ADR, audit, bug-report, finding, use-case/examples, NFR/SLO, and interface sources (OpenAPI / GraphQL / DB schema).

Each parent carries an **epistemic stance** — what kind of knowledge it is allowed to assert — and that stance is **normative**: it MUST be preserved when the parent is promoted into a spec (or, for a bug-report, into a fix task). The `author` step is where most of this normalization happens (the rows below marked "via `author`"):

| Parent artifact | Epistemic stance | Promotes to |
|---|---|---|
| `spec.swarm.md` | **intent** — declares required behavior as SOL obligations | (is the authority; lowers to tasks) |
| `audit.md` | **observation-only** — describes present state and risk; asserts no new intended behavior | a `spec.swarm.md` (via `author`) |
| `bug-report.md` | **diagnosis-only** — reproduces and root-causes a defect; prescribes no fix | a **fix task** (`implement`) |
| `research.md` | **inquiry** — surveys options and evidence; commits to no decision | a `spec.swarm.md` (via `author`) |
| `prd.md` | **intent** — states desired product outcomes; non-authoritative until authored | a `spec.swarm.md` (via `author`) |
| `rfc.md` | **proposal** — proposes a design/approach; commits nothing until accepted | a `spec.swarm.md` (via `author`) or an `adr.md` |
| `use-case.md` / examples | **scenario** — illustrates desired behavior by example | `REQ`/`INTERFACE` blocks in a `spec.swarm.md` (via `author`) |
| `nfr.md` / SLOs | **quality attribute** — states non-functional targets | `CONSTRAINT`/`INVARIANT` blocks + verification rows (via `author`) |
| interface source (OpenAPI/GraphQL/DB schema) | **boundary shape** — declares an interface contract | `INTERFACE` blocks (via `author`) |
| `finding.md` | **evidence** — one durable, evidenced project fact | governs as Axis-A rank 3 once accepted |
| `adr.md` | **decision** — an immutable architecture decision (Nygard) | governs as Axis-A rank 1 |

### The stance invariants `author` must honor

- An `audit.md` MUST NOT contain `REQ`/`CONSTRAINT`/`INVARIANT` obligation blocks of its own intent. Observed risk has obligation force only **after** it is promoted *into* a spec — and that promotion is the `author` step. (This is the epistemic-stance invariant of the kept ADR 0007.)
- A `bug-report.md` MUST NOT prescribe an implementation. Its diagnosis promotes *into* a **fix task** (an `implement`-step input), not into a fix it dictates. (Kept ADR 0001.)
- More generally, `author` must not let a lower-stance parent smuggle higher-stance content across the boundary: an observation, an inquiry, or a proposal becomes binding **intent** only when authored into a `spec.swarm.md`, where SOL obligations carry that force.

Authoring writes the one human-authored analyzable artifact, `spec.swarm.md`: the `.swarm.` infix marks it as such. Every other parent in the table above is plain `.md` (a working artifact); `author` MUST NOT introduce per-parent `.swarm.*` names for audit / research / bug-report / finding / adr.

## What gates the boundary — but not via `author`

`author` itself emits no lint codes and runs no gate; it produces the draft that the rest of the flow analyzes. The disciplines that *guard* the content `author` produces live downstream and are referenced here only for orientation: forbidden compositions (e.g. a file that is both a spec and an audit) are enforced not by `author` and not by a gatekeeper skill, but by the [distillation loss budget](../reference/distillation-loss-budget.md) and [source authority](../model/source-authority.md). Re-introducing a composition-policing skill is forbidden, because such a skill would be a semantic owner and soft control presented as enforcement (Invariant 2).

## Related

- [`lint`](lint.md) — the next step; the `PARSE` + `NORMALIZE` step that `author` feeds, where analysis begins.
- [`improve`](improve.md) — the only step permitted to rewrite the spec, and only semantics-preservingly.
- [`lower`](lower.md) and [`decompose`](decompose.md) — how the authored spec is structured into the structured form and then into tasks.
- [`verify`](verify.md) — served by the `empirical-proof` cross-cutting fragment rather than a dedicated step guide.
- [SOL](../language/SOL.md) — the obligation language `author` writes into `spec.swarm.md`.
- [`spec.swarm.md`](../artifacts/spec.md) — the one human-authored analyzable artifact `author` produces.
- [`audit.md`](../artifacts/audit.md), [`research.md`](../artifacts/research.md), [`bug-report.md`](../artifacts/bug-report.md) — recognized parents `author` normalizes, each carrying the epistemic stance the table above pins.
- The `write-spec`/`write-audit`/`write-research`/`write-bug-report`/`write-prd`/`write-rfc` author guides — the six author-guide carriers that serve this step, one per recognized parent.
- The Architect and Surveyor/Researcher personas — typical carrier profiles for the `author` step.
