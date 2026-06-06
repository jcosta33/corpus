# Artifacts

This directory is the contract catalogue for every file a Swarm repository may contain: one page per artifact, each fixing that artifact's epistemic stance, required sections, frontmatter, and copyable skeleton. This page is the index — it defines the rules that *apply across* all artifacts (the `.swarm.` infix partition, filenames by class, the recognized parents of a spec, and the conventions every template obeys) and links each per-artifact contract.

Swarm is markdown-only and has no runtime. Every actor named on these pages — "compiler", "parser", "linter", "planner", "checker" — is a CONTRACT a future tool would build against, never shipped code. Nothing here executes: every artifact is inert reference data, a copyable template, or a file a human or agent populates by hand.

## 1. Two classes, one discriminator: the `.swarm.` infix

Swarm partitions every repository file that participates in the pipeline into **exactly two classes**, discriminated solely by whether the filename carries the literal infix `.swarm.` before its final extension.

| Class | Filename rule | Meaning |
| --- | --- | --- |
| **Compiler-visible** | MUST contain the `.swarm.` infix (e.g. `auth.swarm.md`, `auth.swarm.ir.json`). | The file is *parsed or emitted by the compiler*. Its bytes are subject to the SOL surface grammar or to the IR / plan JSON schemas. |
| **Working artifact** | MUST NOT contain `.swarm.`; uses a plain `.md` extension (e.g. `task.md`, `review.md`). | A *human / agent working artifact*: structured Markdown governed by an artifact contract on these pages, not by the SOL grammar — though it MAY embed SOL blocks (notably `VERDICT` and `TRACE`) as quoted data. |

A conformant Swarm tool MUST treat the `.swarm.` infix as the **sole, sufficient discriminator** for "do I parse or emit this": it MUST NOT parse a plain `.md` working artifact as SOL source, and MUST NOT emit a compiler output to a path lacking the infix. *Design rationale:* the double-extension convention (`.test.ts`, `.d.ts`) lets tooling select files by a stable, greppable suffix without inspecting their content.

There are three filename shapes, and the infix tells them apart:

- **`*.swarm.md`** — the source spec. The **only** human-authored compiler-visible artifact.
- **`*.swarm.*` (e.g. `*.swarm.ir.json`, `*.swarm.plan.json`, `*.swarm.trace.md`)** — *emitted* compiler artifacts. A future tool writes these; in this version they are reserved contract names with no shipped emitter.
- **plain `*.md` (e.g. `task.md`, `audit.md`)** — working artifacts and source documents, authored or worked by hand.

## 2. Canonical filenames by class

### 2.1 Compiler-visible artifacts (`.swarm.` infix)

| Filename pattern | Role | Authored by | Schema / grammar | Status |
| --- | --- | --- | --- | --- |
| `*.swarm.md` | Source spec — APS prose interleaved with SOL blocks. | Human / authoring agent | SOL surface grammar + APS prose standard | Live; the only hand-written `.swarm.` file. |
| `*.swarm.ir.json` | Emitted intermediate representation (the obligation graph). | Compiler (future tool) | IR envelope | **Reserved contract name.** Not written by any shipped tool. |
| `*.swarm.plan.json` | Emitted plan (lowered, schedulable work packets + graphs). | Compiler / planner (future tool) | Plan envelope | **Reserved contract name.** Not written by any shipped tool. |
| `*.swarm.trace.md` | Emitted / instantiated trace for a built spec. | Implement / verify pass (today: agent by hand) | Trace contract + provenance | Copyable template is `trace.md` (plain); built *instances* MAY take the `*.swarm.trace.md` name. |

The two `.json` variants are **documented-as-contract names only**: the kernel pins their shape so a future launcher can build against a stable target, but Swarm ships no parser, emitter, planner, or checker. A repository MUST NOT claim that any `*.swarm.ir.json` or `*.swarm.plan.json` is *produced* by a Swarm tool; it MAY hold hand-written examples in the conformance corpus.

### 2.2 Working artifacts (plain `.md`)

| Filename | Role | Class |
| --- | --- | --- |
| `task.md` | Lowered work packet / pass frame for one pass. | Core (required) |
| `trace.md` | Implementation / preservation claims + evidence against obligations. | Core (required) |
| `review.md` | The verdict record: per-obligation `VERDICT` blocks + matrix + final verdict. | Core (required) |
| `status.md` | Observed-state read-model: per-obligation latest verdict + drift, for one spec. | Execution (derived) |
| `task-orchestration.md` | Coordination record for one parallel decomposition: owned surfaces, hand-offs, liveness, merge log. | Execution (orchestration) |
| `finding.md` | One durable, provenance-anchored project fact. | Core (required) |
| `adr.md` | An immutable architecture decision record (Nygard form). | Core (required) |
| `memory/INDEX.md` | Compact recall map (links + a "Load when" per entry). | Core (required) |
| `memory/glossary.md` | One-word-one-meaning term store. | Memory model |
| `memory/patterns/*.md` | Recurring multi-finding knowledge. | Memory model |
| `audit.md` | Observation-only source document; promotes to a spec. | Source-doc (conditional) |
| `research.md` | Investigation source document; promotes to a spec. | Source-doc (conditional) |
| `bug-report.md` | Diagnosis-only source document; promotes into a fix *task*. | Source-doc (conditional) |
| `prd.md` | Product-intent source document; promotes to a spec. | Source-doc (conditional) |
| `rfc.md` | Technical-proposal source document; promotes to a spec or an ADR. | Source-doc (conditional) |
| `threat-model.md` | Security-domain threat-observation source document; promotes to a spec. | Source-doc (conditional; outside the counted Tier-3 inventory) |

### 2.3 There is NO `verdict.md` (normative)

A repository MUST NOT contain a standalone `verdict.md`, and no tool MAY emit one. `VERDICT` is a SOL *language block*, not a file; `review.md` is its canonical *container*. *Rationale:* a verdict is the output of the review pass, exactly as a SARIF `result` lives inside a `run` and never as a free-standing file. The kernel ships documentation of the `VERDICT` block and the verdict taxonomy as a reference page, not as a copyable artifact template.

## 3. The recognized parents of a spec

A spec is not born only from research. Swarm normalizes the many artefacts of requirements practice into one obligation-bearing `spec.swarm.md` rather than pretending every intent begins as research. Each **parent** carries an **epistemic stance** — what kind of knowledge it is allowed to assert — and that stance is preserved when its content is promoted into a spec.

| Source class | Canonical artefact | Epistemic stance | Promotes to |
| --- | --- | --- | --- |
| Intent | `prd.md` | **intent** — desired product outcomes; non-authoritative until authored | a `spec.swarm.md` (via `author`) |
| Evidence | `research.md` | **inquiry** — surveys options and evidence; commits to no decision | a `spec.swarm.md` (via `author`); many PRDs / specs / ADRs / findings |
| Proposal | `rfc.md` | **proposal** — proposes a design; commits nothing until accepted | a `spec.swarm.md` (via `author`) or an `adr.md` |
| Decision | `adr.md` | **decision** — an immutable architecture decision (Nygard) | governs as highest-authority constraint; feeds specs / tasks |
| Observation | `audit.md` | **observation-only** — describes present state and risk; asserts no new intended behavior | a `spec.swarm.md` (via `author`); findings / refactor tasks |
| Defect | `bug-report.md` | **diagnosis-only** — reproduces and root-causes; prescribes no fix | a **fix task** (via `implement`) |
| Discovery | `finding.md` | **evidence** — one durable, evidenced project fact | governs as evidence once accepted; feeds specs / ADRs / memory |
| Scenario | `use-case.md` / examples | **scenario** — illustrates desired behavior by example | `REQ` / `INTERFACE` blocks in a spec (via `author`) |
| Interface | OpenAPI / GraphQL / DB schema | **boundary shape** — declares an interface contract | `INTERFACE` (+ `CONSTRAINT`) blocks in a spec (via `author`) |
| Quality attribute | `nfr.md` / SLOs | **quality attribute** — states non-functional targets | `CONSTRAINT` / `INVARIANT` blocks + verification rows (via `author`) |

Two epistemic-stance invariants follow and are normative:

- An `audit.md` MUST NOT carry `REQ` / `CONSTRAINT` / `INVARIANT` obligation blocks of its own intent — observed risk is promoted *into* a spec, where it acquires obligation force.
- A `bug-report.md` MUST NOT prescribe an implementation — its diagnosis promotes *into* a fix task.

`research.md` holds a special role as the kernel's **detached first-class evidence store**: it is not bound to one downstream artefact — one research artefact MAY feed many PRDs, specs, ADRs, findings, or audits at once — which minimizes copying, preserves provenance, and reduces distillation loss when upstream facts evolve.

Of these parents, five are shipped as **stdlib source-doc templates** — `audit.md`, `research.md`, `bug-report.md`, `prd.md`, and `rfc.md`. They are **conditional**: a repository need not have instantiated any of them to be conformant, but a conformant kernel payload MUST ship each template. The remaining parents — `use-case.md` / examples, `nfr.md` / SLOs, and interface sources — are **recognized inputs that normalize INTO a spec** during the `author` pass and are not necessarily shipped as separate templates. A conformant kernel payload MAY additionally ship a `use-case.md` or `nfr.md` template, but MUST NOT treat any source-doc as required for conformance.

## 4. General template conventions

These conventions are normative and apply to **every** artifact template in the catalogue:

- Every artifact MUST carry YAML frontmatter delimited by `---`, with at minimum a `type` field naming the artifact and an `id`. Per-class fields (e.g. `status`, `created`, `updated`, `source_spec`) are fixed on each artifact's own page.
- Placeholder tokens use `{{...}}`. A shipped, *uninstantiated* template MAY leave `{{...}}` placeholders; a **built** (populated) artifact MUST NOT leave a binding clause as a placeholder — an unfilled `VERIFY BY` placeholder in a built artifact is a `SOL-V001` lint defect.
- Tables are the required carrier for every matrix (verification, obligation-verdict, promotion queue). A row whose status cell is empty in a *built* artifact is treated as `UNVERIFIED`.
- Surface SOL blocks embedded in a working artifact (`TRACE` in `trace.md`, `VERDICT` in `review.md`) are quoted SOL data and MUST obey the SOL block grammar — including the canonical vocabulary: the 7 block types, the 5 modal keywords (`MUST` / `MUST NOT` / `SHOULD` / `SHOULD NOT` / `MAY`), the 7 verdicts (4 core `PASS` / `FAIL` / `BLOCKED` / `UNVERIFIED` + 3 lifecycle `WAIVED` / `STALE` / `CONTRADICTED`), the 9 proof types, and the `VERIFY BY <type>:<adapter>:<artifact>` form.

The copyable skeleton for each artifact lives in the kernel payload under `starter-kit/.agents/templates/`. Each per-artifact page below is the **contract** for one of those skeletons: the page defines what the artifact means and what its sections require; the template is the file you copy and fill.

## 5. Filename and placement in an adopted workspace

Each page restates the `.swarm.` infix rule for its own class: `spec.swarm.md` is the one human-authored compiler-visible source (`.swarm.md`); a built trace MAY take the emitted `*.swarm.trace.md` name; every other working artifact and source document is a plain `.md`.

In an adopted project, the canonical workspace is `.swarm/`, and artifacts live by role:

- **`.swarm/sources/`** — durable source documents and the obligation source: `specs/` (`*.swarm.md`), `prds/`, `rfcs/`, `research/`, `audits/`, `bugs/`, `findings/`, `adrs/`, `interfaces/`, `nfrs/`.
- **`.swarm/generated/`** — recreatable execution packets: `tasks/` (`task.md`), `traces/` (`trace.md`), `reviews/` (`review.md`), generated tests and docs.
- **`.swarm/memory/`** — durable recall: `INDEX.md`, `glossary.md`, `patterns/`, and `stale/`.

The copyable templates themselves install under `.swarm/kernel/templates/`.

## 6. The artifact contract pages

### Pipeline-core artifacts (contract + copyable template each)

| Page | Artifact | Class | Role |
| --- | --- | --- | --- |
| [spec.md](./spec.md) | `spec.swarm.md` | compiler-visible | Source of obligations. |
| [task.md](./task.md) | `task.md` | working | Lowered pass frame for one pass. |
| [trace.md](./trace.md) | `trace.md` | working | Implementation claims + evidence. |
| [review.md](./review.md) | `review.md` | working | The verdict record (verdict container). |
| [finding.md](./finding.md) | `finding.md` | working | One durable, evidenced fact. |
| [adr.md](./adr.md) | `adr.md` | working | An immutable decision. |
| [memory.md](./memory.md) | `memory/INDEX.md` + glossary + patterns | working | The recall map and provenance store. |

### Source-document artifacts (conditional; promote into the pipeline)

| Page | Artifact | Stance | Promotes to |
| --- | --- | --- | --- |
| [prd.md](./prd.md) | `prd.md` | intent | a spec |
| [research.md](./research.md) | `research.md` | inquiry | a spec (and many other parents) |
| [rfc.md](./rfc.md) | `rfc.md` | proposal | a spec or an ADR |
| [audit.md](./audit.md) | `audit.md` | observation-only | a spec |
| [bug-report.md](./bug-report.md) | `bug-report.md` | diagnosis-only | a fix task |
| [threat-model.md](./threat-model.md) | `threat-model.md` | threat-observation | a spec |

### Execution-tier working artifacts (no copyable template; populated during the run)

| Page | Artifact | Class | Role |
| --- | --- | --- | --- |
| [status.md](./status.md) | `status.md` | working (derived) | Observed-state read-model: latest verdict + drift per obligation. |
| [task-orchestration.md](./task-orchestration.md) | `task-orchestration.md` | working (orchestration) | Coordination record for one parallel decomposition. |

## Related

- [docs/model/source-artifacts.md](../model/source-artifacts.md) — the artifact set and the `.swarm.` infix partition in the framework's overall model.
- [docs/model/conformance.md](../model/conformance.md) — which artifacts a conformant repository MUST contain.
- [docs/passes/author.md](../passes/author.md) — the pass that promotes a source document into a `spec.swarm.md`.
- [docs/passes/lower.md](../passes/lower.md), [docs/passes/decompose.md](../passes/decompose.md) — produce `task.md` pass frames from a spec.
- [docs/passes/implement.md](../passes/implement.md), [docs/passes/verify.md](../passes/verify.md) — produce and check `trace.md`.
- [docs/passes/review.md](../passes/review.md) — produces `review.md` and its `VERDICT` blocks.
- [docs/passes/promote.md](../passes/promote.md) — produces `finding.md` and updates `memory/INDEX.md`.
- [docs/language/SOL.md](../language/SOL.md) — the 7 block types these artifacts carry; [docs/language/errors.md](../language/errors.md) — the `SOL-<LAYER><NNN>` lint catalogue.
