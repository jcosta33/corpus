# `spec.swarm.md` — the source spec

A `spec.swarm.md` is the one human-authored, compiler-visible artifact in Swarm: APS prose interleaved with SOL obligation blocks, and the single source the obligation graph is built from. Every task, trace, verdict, and proof downstream traces back to a `REQ`, `CONSTRAINT`, `INVARIANT`, or `INTERFACE` block authored here.

Swarm has **no runtime**. Every actor named on this page — "compiler", "parser", "linter", "planner" — is a CONTRACT a human, an agent following a pass guide, or a future tool builds against, never shipped code. A `spec.swarm.md` is inert Markdown; nothing on this page executes.

## Purpose and epistemic stance

A spec's epistemic stance is **intent**: it *declares required behavior*. Where every other source artifact in the framework records what *is* (an audit), what *failed* (a bug-report), what *might* be done (a research or RFC), or what *was decided* (an ADR), the spec is the only artifact that asserts what *must* hold. That intent is carried exclusively by SOL obligation blocks, and obligation force exists nowhere else: a claim that is not in a block is not a contract.

This gives the spec a unique position in the obligation graph. It is the **authority** that lowers to tasks — the root from which work is scheduled and against which proofs are matched. Promotion runs *toward* the spec, never out of it: an audit's observed risk, a bug-report's diagnosis, a research artifact's findings, a PRD's outcomes, an RFC's proposal, and a finding's evidence all acquire obligation force only after an `author` pass normalizes them *into* a spec. Their epistemic stances are preserved across that boundary — observation, inquiry, and proposal become binding intent only here.

What a spec MUST NOT do:

- It MUST NOT carry prose that smuggles obligation force outside a block. Behavioral requirements live in `REQ`/`CONSTRAINT`/`INVARIANT`/`INTERFACE` blocks; the surrounding APS prose frames and explains, but is not itself a contract. A requirement stated only in prose is a defect, not an obligation.
- It MUST NOT leave an obligation unverifiable. Every `REQ`, `CONSTRAINT`, `INVARIANT`, and `INTERFACE` block MUST bind a proof via `VERIFY BY <type>:<adapter>:<artifact>` — drawn from the 9 proof types (`static`, `test`, `contract`, `property`, `model`, `perf`, `security`, `manual`, `monitor`). An `INTERFACE` block MUST bind a `contract:` proof specifically.
- It MUST NOT ship a `blocking` `QUESTION` into lowering. Captured ambiguity belongs in `QUESTION` blocks; a `[blocking]` question MUST be resolved before the spec is lowered to tasks.
- It MUST NOT silently drop intent. Anything narrowed, deferred, or left open when content was distilled into the spec is accounted for in the closing **Distillation loss statement**.

A spec asserts only the 5 modals — `MUST`, `MUST NOT`, `SHOULD`, `SHOULD NOT`, `MAY` — to set obligation strength, and it is the artifact whose blocks downstream verdicts judge against the 7 verdicts (4 core: `PASS`, `FAIL`, `BLOCKED`, `UNVERIFIED`; 3 lifecycle: `WAIVED`, `STALE`, `CONTRADICTED`).

## Filename and placement

The spec is the **only** human-authored file that carries the `.swarm.` infix. The infix is the sole, sufficient discriminator a Swarm tool uses to decide "do I parse this as SOL source": a filename containing `.swarm.` before its final extension is compiler-visible; a plain `.md` is a working artifact governed by its own contract, never parsed as SOL.

| Class | Filename rule | Example |
| --- | --- | --- |
| **Compiler-visible (human-authored)** | MUST contain `.swarm.` before the extension; this class has exactly one hand-written member. | `auth.swarm.md` |
| **Compiler-visible (emitted)** | MUST contain `.swarm.`; produced by a future tool, never hand-written. | `auth.swarm.ir.json`, `auth.swarm.plan.json`, `auth.swarm.trace.md` |
| **Working artifact** | MUST NOT contain `.swarm.`; plain `.md`. | `task.md`, `review.md`, `finding.md` |

So the spec is named `<slug>.swarm.md` (e.g. `auth.swarm.md`, `checkout.swarm.md`). The sibling source artifacts that promote into it — audit, research, bug-report, PRD, RFC, finding, ADR — are all plain `.md`; no per-artifact `.swarm.*` name is introduced for any of them.

In an adopted project's `.swarm/` workspace, the spec lives under **`sources/`** — the layer holding canonical, hand-authored intent:

```text
project/
  .swarm/
    sources/                 # human-authored intent — specs live HERE
      auth.swarm.md          # the source spec
      auth-audit.md          # a plain-.md parent that promotes into it
    generated/               # emitted, recreatable artifacts (IR, plan, traces, reviews, tasks)
      auth.swarm.ir.json     # the obligation graph emitted FROM the spec (reserved contract name)
      auth.swarm.plan.json   # the lowered plan (reserved contract name)
    memory/                  # the recall layer (INDEX, glossary, patterns)
```

The spec is a `sources/` artifact because it is authored by hand and is the durable intent of record. Its emitted projections — the IR obligation graph (`*.swarm.ir.json`) and the plan (`*.swarm.plan.json`) — are `generated/` artifacts, recreatable from the spec and never hand-edited as intent. (Those `.json` names are reserved contracts: the framework ships no parser, emitter, or planner that writes them; a repo MAY hold hand-written examples in its corpus, but MUST NOT claim a Swarm tool produced them.)

## Required sections and fields, in order

A conformant `spec.swarm.md` MUST carry the following sections in exactly this order. Omitting any required section, or presenting them out of order, is the document-level lint defect `SOL-S012` (BLOCKING) — distinct from the per-obligation scope advisory `SOL-O004` (an obligation lacking `WRITES`/`READS`/`AFFECTS`).

| # | Section | Meaning | Carries |
| --- | --- | --- | --- |
| 1 | frontmatter | Identity plus the two version axes. | YAML (see below). |
| 2 | `## Intent` | One paragraph: the user- or system-visible outcome this spec contracts. | APS prose. |
| 3 | `## Non-goals` | Explicit out-of-scope, to bound interpretation. | APS prose / bullets. |
| 4 | `## Context` | Only load-bearing background — links to findings/ADRs/audits/research, never pasted copies. | APS prose + links. |
| 5 | `## Interfaces` | Boundary declarations. | `INTERFACE` blocks; each MUST bind `VERIFY BY contract:<adapter>:<artifact>`. |
| 6 | `## Obligations` | The binding behavioral requirements. | `REQ` blocks. |
| 7 | `## Constraints` | Forbidden actions / restrictions on the solution space. | `CONSTRAINT` blocks. |
| 8 | `## Invariants` | Properties that must always hold. | `INVARIANT` blocks (prefer `property` / `model` / `static` proofs). |
| 9 | `## Questions` | Captured ambiguity. | `QUESTION` blocks; a `[blocking]` one MUST be resolved before lowering. |
| 10 | `## Verification coverage` | Per-obligation proof binding at a glance. | Table: each obligation ID → its `VERIFY BY` reference. |
| 11 | `## Downstream tasks` | Which task frames cover which obligations. | Table: Task → Covers. |
| 12 | `## Distillation loss statement` | What survived distillation into this spec, and what did not. | Three subsections: `### Preserved`, `### Dropped`, `### Still uncertain`. |

### Frontmatter contract

The required frontmatter set is fixed; the rest is optional:

| Field | Required? | Meaning |
| --- | --- | --- |
| `type: spec` | required | Identifies the artifact class. |
| `id` | required | Stable slug for this spec, the root of its obligation IDs. |
| `swarm_language: SOL/0.1` | required | The SOL language version the blocks conform to (the language axis). |
| `aps_version` | required | The APS prose-standard version the prose conforms to. |
| `spec_version` | required | This spec's own semver (the content axis), independent of the language axis. |
| `status` | required | `draft` \| `approved` \| (lifecycle states per the framework). |
| `title` | optional | Human-readable title. |
| `owners` | optional | Accountable owners. |
| `imports` | optional | Other specs whose obligations this one references. |
| `domain` | optional | Domain authority band (e.g. `product`), used by the source-authority model. |
| `created` / `updated` | optional | Provenance timestamps. |

The two version axes are deliberately separate: `swarm_language` tracks the grammar the blocks are written against, while `spec_version` tracks the evolution of this spec's content. A spec can revise its obligations (bumping `spec_version`) without moving to a new SOL version, and vice versa.

### Block discipline

Obligation content lives **only** in SOL blocks, each opened by a bare header `TYPE PREFIX-NNN:` (e.g. `REQ AC-001:`, `CONSTRAINT C-001:`, `INVARIANT I-001:`, `INTERFACE IF-001:`, `QUESTION Q-001:`). A `REQ` follows the `WHEN <trigger> / THE <actor> MUST <observable response>` shape, binds a proof, and SHOULD declare scope (`WRITES` / `READS` / `AFFECTS`) so it can be safely parallelized. The four obligation-bearing block types each appear under their dedicated section; `QUESTION` blocks record ambiguity and do not assert intent.

## Copyable template

The copyable skeleton for this artifact is:

```
starter-kit/.agents/templates/spec.swarm.md
```

That file is the skeleton you copy and fill — every `{{placeholder}}` and each `<what goes here>` guide is replaced when you author a real spec. **This page is its contract**: the template is the shape, and the sections, ordering, frontmatter, block discipline, and epistemic-stance rules above are the obligations that shape must satisfy. In an adopted project the same skeleton ships under `.swarm/kernel/templates/spec.swarm.md`.

## Related

- `docs/passes/author.md` — the `author` pass: the only pass that *writes* a `spec.swarm.md`, normalizing its parents (audit, research, RFC, PRD, bug-report, finding, ADR) into it while preserving each parent's epistemic stance.
- `docs/passes/lint.md` — the `lint` pass: the first pass that *reads* the spec, checking well-formedness and raising `SOL-S012` when a required section is missing or out of order.
- `docs/passes/lower.md` — the `lower` pass: consumes the spec's SOL surface and emits the IR obligation graph (`*.swarm.ir.json`).
- `docs/passes/decompose.md` — splits the obligation graph into the schedulable task frames named in this spec's `## Downstream tasks` table.
- `docs/artifacts/task.md` — the lowered work packet a spec's obligations become.
- `docs/artifacts/audit.md`, `docs/artifacts/research.md`, `docs/artifacts/bug-report.md` — observation-, inquiry-, and diagnosis-stance parents that promote into a spec (the first two) or into a fix task (the last).
- `docs/artifacts/finding.md`, `docs/artifacts/adr.md` — the evidence and decision parents that govern alongside, and can promote into, a spec.
- `docs/model/source-artifacts.md` — the full `.swarm.` infix partition and the tiered required-artifact set this spec anchors.
