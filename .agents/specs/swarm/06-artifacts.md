# Swarm Kernel Specification v0.1 — Part 06: Artifacts and templates

<!-- Part 06 of the Swarm Kernel Specification (§20–§21). All parts share one section numbering (§0–§35 + Appendices A–G); cross-references of the form “§N” resolve via the index in [README.md](./README.md). -->

## 20. The artifact set and conformance definition

This section defines the complete set of files a Swarm repository may contain, partitions them into two normative classes by the `.swarm.` filename infix, enumerates the canonical filenames in each class, and fixes the tiered required-artifact set on which conformance is defined. The per-artifact *contracts* and copyable *templates* are specified in §21; the mechanically-checkable conformance procedure is specified in §32.

### 20.0 Repository layout

This subsection is the single canonical map of every path this specification names. It precedes the artifact partition (§20.1) and the conformance definition (§20.4) so a reader can locate any artifact, template, or reference doc by its directory before reading the rules that govern it. The tree below is normative for path *shape* (which directory an artifact lives in); the conformance definition (§20.4) — not this tree — fixes which paths a conformant repository MUST contain.

A repository has four top-level concerns, each a sibling directory: `docs/` (prose that *explains* Swarm), `examples/` (worked good/bad specs that *demonstrate* it), `evals/` (framework self-tests that *measure the framework itself*), and `scaffold/.agents/` (the installable payload — the kernel — that a consuming repo *adopts*).

```text
docs/                              # explains Swarm (prose + tables; not installed)
  language/                        # the SOL+APS language and its taxonomies
    SOL.md                         # surface grammar + 7 block-type reference (§5–§6)
    APS.md                         # the controlled-prose standard (§7)
    errors.md                      # the SOL-<LAYER>NNN lint catalogue (§8, Appendix B)
    versioning.md                  # the three version axes (§25)
  model/                           # the no-runtime mental model
    compiler-pipeline.md           # 7 phases / 9 passes (§9, §26)
    source-artifacts.md            # the `.swarm.` infix partition (§20.1)
    source-authority.md            # the two-axis authority model + tie-break (§22)
    conformance.md                 # the conformance definition, in prose (§20.4, §32)
  artifacts/                       # one page per artifact contract (§21)
    spec.md  task.md  trace.md  review.md  finding.md  memory.md
    adr.md  audit.md  research.md  prd.md  rfc.md  bug-report.md
  passes/                          # one page per pass (§26); 9 passes
    author.md  lint.md  improve.md  lower.md  decompose.md
    implement.md  verify.md  review.md  promote.md
  library/                         # the parameterizing layers
    pass-guides.md                 # the skill/pass-guide model (§26)
    heuristic-profiles.md          # the 6 stdlib profile files (the full 13-persona set maps to passes, §27)
    overlays.md                    # project rule bundles (§27)
  reference/                       # cross-cutting reference pages
    glossary.md                    # one-word-one-meaning term store
    proof-types.md                 # the 9 proof types (§15)
    promotion-protocol.md          # the promotion statuses + workflow (§23)
    distillation-loss-budget.md    # Preserved/Dropped/Still-uncertain (§24)

examples/                          # worked good/bad specs (illustrative; not installed)
  auth-refresh/                    # the canonical clean spec
  checkout-payment-5xx/            # incident-driven, proof-heavy spec
  stale-memory/                    # demonstrates STALE/CONTRADICTED decorators
  conflicting-obligations/         # demonstrates CONTRADICTED + tie-break (§22)
  blocking-question/               # demonstrates Q-NNN + BLOCKED

evals/                             # framework SELF-TESTS (tests the spec itself; not installed)
  fixtures/                        # inputs the framework's own checks run against
  rubrics/                         # the §33.6 per-pass quality rubrics (author … promote)

scaffold/                         # the installable payload root (see note below)
  AGENTS.md                        # the populated bootloader a consumer adopts (§31)
  .agents/                       # everything copied into a consuming repo's .agents/
    language/                      # self-contained copies of the Tier-2 references (§20.3.2)
      SOL.md  APS.md  errors.md  versioning.md
    templates/                     # copyable skeletons (§21); NO verdict.md (§20.2.3)
      spec.swarm.md  task.md  trace.md  review.md  finding.md  adr.md
      audit.md  research.md  bug-report.md  prd.md  rfc.md
      memory/INDEX.md
    passes/                        # one page per pass (§26); the 9 pass contract pages
      author.md  lint.md  improve.md  lower.md  decompose.md
      implement.md  verify.md  review.md  promote.md
    skills/                        # pass guides + companion guides (§26); 1 dir per skill
      pass-author-spec/  pass-lint-spec/  pass-improve-spec/
      pass-lower-spec/  pass-decompose-spec/  pass-implement-obligations/
      pass-verify-trace/  pass-review-trace/  pass-promote-findings/
    profiles/                      # the 6 heuristic profiles (§27)
      builder.md  skeptic.md  architect.md  researcher.md  reviewer.md  janitor.md
    overlays/                      # project rule bundles (§27)
      README.md
    memory/                        # the recall layer (§23)
      INDEX.md                     # Tier-1 recall map
      glossary.md                  # Tier-2 term store
      patterns/                    # Tier-2 recurring knowledge
    conformance/                   # inert conformance contract (§32)
      conformance.yaml             # the manifest (data); checker is deferred (§32.7)
      README.md                    # states inertness + "checker is deferred"
      fixtures/                    # the SHIPPED conformance suite — the golden corpus (§33)
    .swarm-version                 # framework/package version, semver (§25, §20.4) — adopted project mirrors this as .swarm/VERSION
```

**Note — the installable payload directory.** The installable payload directory is `scaffold/.agents/`; it is conceptually "the kernel" — the unitary framework a consuming repository adopts wholesale (§2). A consumer copies the contents of `scaffold/.agents/` to its own `.agents/` and adopts `scaffold/AGENTS.md` as `AGENTS.md`. The framework-dev repo's `scaffold/` is therefore the **shipping location of the installable payload** (the kernel) — *this* repository's authoring-side directory — and is a different artifact from the **adopted-project workspace** the payload installs *into*: in a consuming repo the kernel installs to `.swarm/kernel/`, under which `.swarm/` is the canonical Swarm workspace and `.agents/` is only an agent-tool compatibility surface (the workspace model is specified in §20.5; the framework-dev vs adopted-project distinction is design rationale, not an empirical claim). A v0.2 ADR MAY rename `scaffold/` → `kernel/` to make the conceptual name literal; if it does, `scaffold/` MUST be kept as a one-cycle compatibility alias so in-flight adopters do not break, and the alias MUST be removed no later than the following MINOR release. The rename is cosmetic: it changes the payload's directory name, never the `.agents/` interior, the artifact filenames (§20.2), or the conformance definition (§20.4).

**Note — `evals/` is not the conformance suite.** `evals/` and `scaffold/.agents/conformance/fixtures/` are distinct and MUST NOT be conflated. `evals/` holds the *framework's self-tests* — the `evals/fixtures/` inputs and the `evals/rubrics/` per-pass quality rubrics (§33.6) that measure whether *this specification and its scaffold* hold together; it is authoring-side and is not part of the installable payload. `scaffold/.agents/conformance/fixtures/` holds the *shipped conformance suite* — the golden corpus (§33) that a consuming repository carries to validate *its own* adoption against the conformance contract (§32). The first tests the kernel; the second is tested *by* every kernel adopter. Neither directory executes anything (Invariant 1, NO RUNTIME — §2): both are inert data a future tool would consume.

### 20.1 The `.swarm.` infix rule (normative)

Swarm partitions every repository file that participates in the pipeline into exactly two classes, discriminated by whether the filename carries the literal infix `.swarm.` before its final extension.

| Class | Rule | Meaning |
| --- | --- | --- |
| Compiler-visible | The filename MUST contain the `.swarm.` infix (e.g. `auth.swarm.md`, `auth.swarm.ir.json`). | The file is *parsed or emitted by the compiler*. It is either the human-authored SOL source or a contract-shaped output a future tool produces. Its byte content is subject to the SOL grammar (§5–§6) or the IR/plan JSON schemas (§12–§13, Appendix C). |
| Working artifact | The filename MUST NOT contain `.swarm.` and uses a plain `.md` extension (e.g. `task.md`, `review.md`). | The file is a *human/agent working artifact*: a lowered work packet, a verdict record, a durable fact, a decision, or a recall map. It is structured Markdown governed by an artifact contract (§21), not by the SOL grammar, though it MAY embed SOL blocks (notably VERDICT and TRACE) as quoted data. |

A conformant Swarm tool MUST treat the `.swarm.` infix as the sole, sufficient discriminator for "do I parse/emit this": it MUST NOT attempt to parse a plain `.md` working artifact as a SOL source, and it MUST NOT emit a compiler output to a path lacking the infix. *Rationale:* the double-extension convention (`.test.ts`, `.d.ts`) lets tooling select files by a stable, greppable suffix without content inspection.

The only human-authored `.swarm.` artifact is `*.swarm.md` (the source spec). The three `.swarm.*.json`/`.swarm.trace.md` variants are *emitted* artifacts; see §20.2.2.

### 20.2 Canonical filenames by class

#### 20.2.1 Compiler-visible artifacts (`.swarm.` infix)

| Filename pattern | Role | Authored by | Schema / grammar | Status in v0.1 |
| --- | --- | --- | --- | --- |
| `*.swarm.md` | Source spec — prose (APS) interleaved with SOL blocks. | Human / authoring agent | SOL surface grammar (§5–§6), APS prose standard (§7) | Live; the only hand-written `.swarm.` file. |
| `*.swarm.ir.json` | Emitted intermediate representation (the obligation graph). | Compiler (future tool) | IR envelope (§12, Appendix C) | **Reserved contract name.** Not written by any shipped tool in v0.1. |
| `*.swarm.plan.json` | Emitted plan (lowered, schedulable work packets + graphs). | Compiler/planner (future tool) | Plan envelope (§13) | **Reserved contract name.** Not written by any shipped tool in v0.1. |
| `*.swarm.trace.md` | Emitted/instantiated trace for a built spec. | Implement/verify pass (today: agent by hand) | Trace contract (§21.4) + §16 provenance | Copyable template is `trace.md` (plain); built *instances* MAY take the `*.swarm.trace.md` name. |

The `.json` variants are **documented-as-contract names only**: the kernel pins their shape so a future launcher can build against a stable target, but Swarm ships no parser, emitter, planner, or checker (Invariant 1, NO RUNTIME — see §2). A v0.1 repository MUST NOT claim that any `*.swarm.ir.json` or `*.swarm.plan.json` is produced by a Swarm tool; it MAY contain hand-written examples in the golden corpus (§33).

#### 20.2.2 Working artifacts (plain `.md`)

| Filename | Role | Template tier (§20.3) |
| --- | --- | --- |
| `task.md` | Lowered work packet / pass frame for one pass (§28). | Core (required) |
| `trace.md` | Implementation/preservation claims + evidence against obligations. | Core (required) |
| `review.md` | The verdict record: per-obligation VERDICT blocks + matrix + final verdict. | Core (required) |
| `finding.md` | One durable, provenance-anchored project fact. | Core (required) |
| `adr.md` | An immutable architecture decision record (Nygard form). | Core (required) |
| `memory/INDEX.md` | Compact recall map (links + a "Load when" per entry). | Core (required) |
| `memory/glossary.md` | One-word-one-meaning term store. | Memory model (§23) |
| `memory/patterns/*.md` | Recurring multi-finding knowledge. | Memory model (§23) |
| `audit.md` | Observation-only source artifact; promotes to a spec. | Stdlib source-doc (conditional) |
| `research.md` | Investigation source artifact; promotes to a spec. | Stdlib source-doc (conditional) |
| `bug-report.md` | Diagnosis-only source artifact; promotes into a fix *task*. | Stdlib source-doc (conditional) |

#### 20.2.3 There is NO `verdict.md` (normative)

A repository MUST NOT contain a standalone `verdict.md` artifact, and no tool MAY emit one. `VERDICT` is a SOL *language block* (§6), not a file; `review.md` is its canonical *container* (§21.5). *Rationale:* a verdict is the output of the review pass, exactly as a SARIF `result` lives inside a `run` and never as a free-standing file. The kernel ships documentation of the VERDICT block and the verdict taxonomy (§14) as a reference page, not as a copyable artifact template.

### 20.3 The tiered required-artifact set

The required set is partitioned into three tiers. Only Tiers 1 and 2 are load-bearing for conformance; Tier 3 is shipped but conditional.

#### 20.3.1 Tier 1 — kernel-required pipeline core (contract + copyable template each)

Seven artifacts. Each MUST ship both (a) a documented contract (the required sections/fields and their meaning) and (b) a copyable template skeleton. All seven contracts and templates are given in §21.

| # | Artifact | Class | Pipeline role |
| --- | --- | --- | --- |
| 1 | `spec.swarm.md` | compiler-visible | Source of obligations. |
| 2 | `task.md` | working | Lowered pass frame. |
| 3 | `trace.md` | working | Implementation claims + evidence. |
| 4 | `review.md` | working | Verdict record (verdict container). |
| 5 | `finding.md` | working | Durable fact (memory Tier-2 evidence). |
| 6 | `adr.md` | working | Immutable decision. |
| 7 | `memory/INDEX.md` | working | Recall map (memory Tier-1). |

#### 20.3.2 Tier 2 — kernel-required language / reference docs (not templates)

Six reference documents. These are *prose-and-table reference pages*, not copyable artifact templates; a conformant repo MUST contain a self-contained copy of each so the repository explains its own language without external dependency.

| # | Reference doc | Defines | Spec home |
| --- | --- | --- | --- |
| 1 | SOL reference | Surface syntax + block-type reference. | §5–§6 |
| 2 | APS reference | The controlled-prose standard. | §7 |
| 3 | Error / lint taxonomy | The `SOL-<LAYER><NNN>` catalogue with stable codes + severities. | §8, Appendix B |
| 4 | Source-authority | The two-axis authority model + tie-break. | §22 |
| 5 | Promotion-protocol | The promotion statuses + workflow. | §23 |
| 6 | Distillation-loss-budget | The Preserved/Dropped/Still-uncertain discipline + loss accounting. | §24 |

#### 20.3.3 Tier 3 — stdlib source-doc templates (shipped, conditional)

Three source-document templates the stdlib ships so common authoring entry points exist. They are *conditional*: a repo need not have instantiated any of them to be conformant, but a conformant scaffold MUST ship the templates.

| # | Template | Epistemic stance | Promotes to |
| --- | --- | --- | --- |
| 1 | `audit.md` | Observation-only (records what *is*, never prescribes). | a `spec.swarm.md` (via author pass). |
| 2 | `research.md` | Investigation (open questions + findings). | a `spec.swarm.md` (via author pass). |
| 3 | `bug-report.md` | Diagnosis-only (root cause, never fix). | a fix `task.md` (`task_kind: fix`). |

#### 20.3.4 Supported parents of a spec

A spec is not born only from research. Requirements practice distinguishes intent, evidence, proposal, decision, observation, defect, discovery, scenario, interface, and quality-attribute artefacts; Swarm normalizes all of them into one obligation-bearing `spec.swarm.md` rather than pretending every intent begins as research. The canonical upstream-source model — the recognized **parents** of a spec — is:

| Source class | Canonical artefact | Contributes | May feed |
| --- | --- | --- | --- |
| Intent | `prd.md` | user outcomes, goals, non-goals, success metrics, release constraints | specs, RFCs |
| Evidence | `research.md` | external facts, comparisons, feasibility, standards, risks, confidence | PRDs, RFCs, specs, ADRs, findings |
| Proposal | `rfc.md` | candidate technical approach, alternatives, migration plan | ADRs, specs |
| Decision | `adr.md` | accepted architectural or product constraints and trade-offs | specs, tasks |
| Observation | `audit.md` | present-state risks, debt, drift, duplication, unsafe patterns | findings, specs, refactor tasks |
| Defect | `bug-report.md` | reproduced failure, expected vs. actual behavior, impact | fix tasks, spec amendments |
| Discovery | `finding.md` | one durable, evidenced fact learned during work | specs, ADRs, memory |
| Scenario / example | `use-case.md`, `examples`, acceptance tests | concrete behavior, actor-goal interactions, edge cases | `REQ` blocks + the verification matrix (§21.2) |
| Interface source | OpenAPI, GraphQL schema, DB schema, design contract | boundary shapes and compatibility constraints | `INTERFACE` + `CONSTRAINT` blocks |
| Quality attributes | `nfr.md`, SLOs, accessibility/security briefs | performance, reliability, privacy, accessibility, security | `REQ` / `CONSTRAINT` / `INVARIANT` blocks |

`research.md` holds a special role as the kernel's **detached first-class evidence store**: it is not bound to one downstream artefact, and one research artefact MAY feed many PRDs, specs, ADRs, findings, or audits at once. Keeping evidence detached minimizes copying, preserves provenance, and reduces distillation loss (§24) when upstream facts evolve.

Of these parents, `prd.md` (stance: **intent**) and `rfc.md` (stance: **proposal**) join `audit.md`, `research.md`, and `bug-report.md` as Tier-3 **stdlib source-doc templates** — shipped in the scaffold, CONDITIONAL, and never conformance-required (§20.4): a conformant repo need not have instantiated any of them, but a conformant scaffold MUST ship each template. By contrast, `use-case.md`/examples, `nfr.md`/SLOs, and interface sources are **recognized inputs that normalize INTO `spec.swarm.md`** during the `author` pass (§9) — they emit `REQ`/`CONSTRAINT`/`INVARIANT`/`INTERFACE` blocks plus verification-matrix rows directly — and are not necessarily shipped as separate templates. A conformant scaffold therefore SHOULD ship `prd.md` and `rfc.md` templates alongside the existing three (extending the Tier-3 table of §20.3.3 to five), and MAY additionally ship a `use-case.md` or `nfr.md` template, but MUST NOT treat any Tier-3 source-doc as required for conformance.

These additional parents — PRD (intent), RFC (proposal), use-case/example (scenario), NFR/SLO (quality attribute), and interface sources (OpenAPI/GraphQL/DB schema) — are first-class parents of a spec; their epistemic stances are catalogued in the §29.1 stance table and preserved on promotion (intent and proposal remain non-authoritative until an `author` pass turns them into spec obligations, exactly as observation and inquiry do).

### 20.4 The conformance definition (normative)

A repository is **Swarm-conformant** if and only if all of the following hold:

1. It contains a self-contained copy of all six **Tier-2 language/reference docs** (§20.3.2).
2. It contains a copyable template for each of the seven **Tier-1 core artifacts** (§20.3.1), and each template satisfies its §21 contract.
3. It contains a **populated `AGENTS.md` bootloader** (§31) — not an empty placeholder — within the ≤200-line / ≤25 KB density cap (§2, §17).
4. It contains the framework/package version file — `scaffold/.agents/.swarm-version` in the framework-dev repo, or `.swarm/VERSION` in an adopted project (§20.5.1, §25) — carrying a valid semver.

A repository that omits any of the four MUST NOT be described as Swarm-conformant. Conditional artifacts (Tier 3) and the reserved `.swarm.*.json` contract files are **not** required for conformance. The full mechanically-checkable conformance contract — the exact checks, their inputs, and the deferral of an automated checker to a future CLI — is given in §32; the golden corpus that exercises it is given in §33.

---


### 20.5 The adopted-project workspace (`.swarm/`)

§20.0 maps the **framework-dev repository** — the repo in which Swarm *itself* is authored: the `docs/`, `examples/`, `evals/`, and `scaffold/` siblings that explain, demonstrate, self-test, and package the kernel. This subsection maps a different artifact: the **adopted-project workspace** — the directory shape that appears inside a *consuming* project after it adopts Swarm. The two are distinct artifacts and MUST NOT be conflated: `docs/`+`examples/`+`evals/`+`scaffold/` describe how Swarm is built and shipped; `.swarm/`+`.agents/`+`AGENTS.md` describe how an adopted project is laid out. A reader holding the framework repo open is looking at the producer; a reader holding a consuming project open is looking at the product.

The bridge between the two is **installation**. The installable payload — the kernel — ships in the framework repo under `scaffold/` (the `scaffold/.agents/` interior of §20.0, with the v0.2 rename note thereof). On adoption, that payload INSTALLS to **`.swarm/kernel/`** in the consuming project, and `scaffold/AGENTS.md` is adopted as the project's `AGENTS.md`. Nothing executes during or after this copy (Invariant 1, NO RUNTIME — §2): the kernel is inert reference data and copyable templates, and every "workspace" path below is a directory a human or an agent populates, or that a future Swarm toolchain (§12, §32.7) would populate as a CONTRACT it builds against — never a runtime Swarm ships.

#### 20.5.1 The canonical adopted-project tree

The following tree is normative for path *shape* inside an adopted project. As with §20.0, it fixes which directory each kind of artifact lives in; it does not by itself impose conformance (conformance is defined in §20.4 against the kernel's installed contents and the `AGENTS.md` bootloader).

```text
project/
  AGENTS.md                          # the bootloader (§31): how an agent STARTS; short, ≤200 lines / ≤25 KB

  .swarm/                            # THE CANONICAL SWARM WORKSPACE (everything that defines/tracks/reconciles intent)
    VERSION                          # adopted kernel version, semver (§25); the workspace mirror of .agents/.swarm-version
    config.yaml                      # project-level config: surface policies (§16.6), agent adapters (§32.7.4), and (under a `lint:` key) the §8.6 lint-severity overrides

    kernel/                          # the INSTALLED framework payload (copied from the framework repo's scaffold/)
      language/                      # self-contained Tier-2 references (§20.3.2): SOL.md APS.md errors.md versioning.md
      templates/                     # copyable Tier-1 + Tier-3 skeletons (§21); NO verdict.md (§20.2.3)
      passes/                        # one page per pass (§26); the 9 passes
      skills/                        # pass guides + companion guides (§26); 1 dir per skill
      profiles/                      # the 6 heuristic profiles (§27)
      overlays/                      # project rule bundles (§27)

    sources/                         # DESIRED truth + durable source artifacts (the obligation source)
      specs/                         # *.swarm.md source specs (compiler-visible; §20.1)
      prds/  rfcs/  research/        # intent / proposal / detached evidence (§20.3.4)
      audits/  bugs/  findings/      # observation / defect / discovery
      adrs/  interfaces/  nfrs/      # decisions / boundary shapes / quality attributes

    status/                          # OBSERVED satisfaction + drift (reconciles desired vs. real; never redefines intent)
      specs/                         # per-spec satisfaction reports (.status.md alongside the .swarm.md)
      tasks/  worktrees/  drift/     # task state, worktree state, detected drift

    generated/                       # EXECUTION PACKETS — generated/derived; recreatable from sources
      tasks/  traces/  reviews/      # task frames (§28), trace.md, review.md
      tests/  docs/                  # generated tests + generated docs

    memory/                          # DURABLE recall (§23)
      INDEX.md                       # Tier-1 recall map (a map, not a dump)
      glossary.md                    # Tier-2 one-word-one-meaning term store
      patterns/                      # Tier-2 recurring multi-finding knowledge
      stale/                         # superseded/contradicted memory, linked to replacements

    ledger/                          # COMPACT reconciled history (§23) — prevents permanent scratchpad accumulation
      changes/  merges/  promotions/ # change / merge / promotion summaries

    archive/                         # retired durable source artifacts (linked to replacements; not silently deleted)
    tmp/                             # scratch only; no durable knowledge; gitignored

  .agents/                           # COMPATIBILITY MIRROR ONLY (so an agent CLI can load instructions; not canonical)
    skills/                          # mirrored/pointer skills → .swarm/kernel/skills/
    profiles/                        # mirrored/pointer profiles → .swarm/kernel/profiles/
```

The mapping from the framework repo to the adopted project is fixed and load-bearing: `scaffold/.agents/{language,templates,passes,skills,profiles,overlays}` (§20.0) becomes `.swarm/kernel/{language,templates,passes,skills,profiles,overlays}`, and `scaffold/.agents/.swarm-version` (§25) becomes `.swarm/VERSION`. The framework-dev repo's `docs/`, `examples/`, and `evals/` are authoring-side and are **not** installed into a consuming project. *Design rationale (layout/naming):* placing the kernel under `.swarm/kernel/` (rather than at `.agents/` as in §20.0's payload) keeps the canonical workspace self-describing — a project carries its own language, templates, and passes — while the bare `.agents/` directory is reserved for the compatibility role of §20.5.4.

#### 20.5.2 The eight `.swarm/` directory contracts

The workspace separates **desired** state (`sources/`), **observed** state (`status/`), and **generated** execution material (`generated/`), then layers durable recall, compact history, retirement, and scratch on top. The eight top-level workspace directories carry these contracts:

| Directory | Purpose | Committed? | Populated by |
| --- | --- | --- | --- |
| `kernel/` | Installed framework payload (language, templates, passes, skills, profiles, overlays). Framework-owned; updated by kernel migrations; project edits belong in `overlays/`. | Yes | Installation from the framework repo's `scaffold/`; kernel migrations |
| `sources/` | Desired truth + durable source artifacts: specs (primary behavioral intent), PRDs, RFCs, research, audits, bugs, findings, ADRs, interfaces, NFRs (§20.3.4). | Yes | Humans + the `author`/`improve` passes |
| `status/` | Observed satisfaction + drift state: spec satisfaction reports, task/worktree state, drift reports. Records whether code satisfies the spec; never redefines intent. | Yes | The `verify`/`review` passes; drift detection (future toolchain) |
| `generated/` | Generated/derived execution packets: task frames, traces, reviews, generated tests/docs. Recreatable from sources; compacted into `ledger/` on completion. | Mostly gitignored (task frames + active traces/reviews; see §20.5.5) | The `lower`/`decompose`/`implement`/`verify`/`review` passes (or a future toolchain) |
| `memory/` | Durable project recall: `INDEX.md` map, glossary, patterns, stale records. The index says *when to load* each entry, never dumps content inline. | Yes | The `promote` pass |
| `ledger/` | Compact reconciled history: change/merge/promotion summaries preserving obligation coverage, changed surfaces, proof, verdicts, and promotion results. | Yes | Reconciliation after merge/abandonment (future toolchain) |
| `archive/` | Retired durable source artifacts (superseded specs/research, closed bugs, stale findings, resolved audits), each linked to a replacement or closure summary. | Yes | The `promote` pass / manual retirement |
| `tmp/` | Scratch area. No durable knowledge lives here. | No (gitignored) | Ad-hoc agent/human scratch |

#### 20.5.3 The `.agents/` compatibility model

`.swarm/` is the specification-compiler workspace; `.agents/` is an **agent-tool compatibility surface**; `AGENTS.md` is the bootloader. `.agents/` exists only so a third-party agent CLI that looks for `.agents/skills/` or `.agents/profiles/` can find loadable instructions; it is never the canonical home of Swarm's project intent.

| `.agents/` may contain (compatibility) | `.agents/` MUST NOT contain as canonical (forbidden) |
| --- | --- |
| Skills / pass guides mirrored for an agent tool — each pointing back to `.swarm/kernel/skills/…` | Primary specs (`*.swarm.md`) — these are canonical in `.swarm/sources/specs/` |
| Profiles mirrored for compatibility — pointing back to `.swarm/kernel/profiles/…` | Source-authority docs (PRDs, RFCs, research, ADRs, audits, findings, NFRs, interfaces) |
| Tool-specific config a given agent CLI requires | Durable memory (`INDEX.md`, glossary, patterns, stale records) |
| Thin task **pointer** files if a tool expects `.agents/tasks/` — pointing back to `.swarm/generated/tasks/…` | The ledger (compact reconciled history) |
| | Status reports (observed satisfaction + drift) |

Every file in `.agents/` MUST either point back to its canonical `.swarm/kernel/` (or `.swarm/generated/`) original or be a verbatim compatibility copy of kernel material. *Design rationale (layout/naming):* the mirror is one-directional — `.agents/` derives from `.swarm/`, never the reverse — so that there is exactly one source of truth and the compatibility surface can be regenerated or deleted without losing project intent. A canonical artifact that exists *only* under `.agents/` is a layout defect, not a valid adoption.

#### 20.5.4 The governing rule (normative)

The placement of every adopted-project artifact is decided by one rule:

```text
If it defines, tracks, or reconciles project intent  → .swarm/
If it exists only so an agent CLI can load instructions → .agents/
If it starts an agent correctly                       → AGENTS.md
```

This rule is **design rationale** — a workspace layout and naming decision, not an empirical claim — and needs no `sources.md` citation. The only grounded claim in this subsection is the NO-RUNTIME framing of §20.5 (the kernel and every workspace directory are inert; the CLI/worktree/ledger automation is a CONTRACT a future Swarm toolchain builds against, never shipped here): that is **Invariant 1** (§2.1.1), a design invariant of this specification.

#### 20.5.5 Commit policy (informative)

Aligned with the committed?-column of §20.5.2, an adopted project SHOULD gitignore execution-local and scratch state while committing everything that defines, tracks, or reconciles intent:

```gitignore
# Swarm execution-local + scratch state (recreatable from sources)
.swarm/generated/tasks/
.swarm/tmp/

# Optional: active traces/reviews are compacted into .swarm/ledger/ on completion.
# Remove these two lines if governance requires committing active trace/review files.
.swarm/generated/traces/
.swarm/generated/reviews/
```

A project MUST NOT gitignore `.swarm/sources/`, `.swarm/status/`, `.swarm/memory/`, `.swarm/ledger/`, `.swarm/kernel/`, or `.swarm/archive/` unless it intentionally splits durable knowledge into a separate repository. *Rationale:* `generated/` and `tmp/` are reconstructible from `sources/` and need not bloat history, whereas `sources/`/`status/`/`memory/`/`ledger/` are the durable record the reconciliation model depends on.

---


## 21. Artifact contracts and templates

This section gives, for each of the seven Tier-1 core artifacts, (a) its **contract** — the required sections/fields and what each means — and (b) a copyable **template skeleton** as a fenced block. Brief notes follow for the three Tier-3 stdlib source-docs. Surface fields in templates use the canonical space-separated uppercase SOL keywords; frontmatter uses the normalized field names fixed in G10 (`swarm_language: SOL/0.1`, `aps_version: 0.1`, `spec_version: 0.1.0`). Templates reuse the source-doc skeletons wherever this specification affirms them, upgraded to the canonical vocabulary of §4 (7-value verdicts, `VERIFY BY <type>:<adapter>:<artifact>`, provenance fields).

### 21.1 General template conventions (normative)

- Every artifact MUST carry YAML frontmatter delimited by `---` with at minimum a `type` field naming the artifact and an `id`.
- Placeholder tokens use `{{...}}`. A shipped, *uninstantiated* template MUST NOT leave a binding clause as a `{{...}}` placeholder inside a populated artifact; an unfilled `VERIFY BY` placeholder in a built artifact is a `SOL-V001` defect (§8).
- Tables are the required carrier for every matrix (verification, obligation-verdict, promotion queue). A row whose status cell is empty in a *built* artifact is treated as `UNVERIFIED`.
- Surface SOL blocks embedded in a working artifact (TRACE in `trace.md`, VERDICT in `review.md`) are quoted SOL data and MUST obey the SOL block grammar (§6).

### 21.2 `spec.swarm.md` — the source spec

#### 21.2.1 Contract

A spec is a behavioral contract: APS prose interleaved with SOL obligation blocks, which compiles into the obligation graph. A conformant `spec.swarm.md` MUST contain the following sections, in order. Omitting any required section, or presenting them out of order, is a document-level defect `lint` MUST raise as `SOL-S012` (§8.3, Appendix B) — distinct from the per-obligation scope code `SOL-O004` (an obligation lacking `WRITES`/`READS`/`AFFECTS`). The required sections, in order:

| Section | Meaning | Carries |
| --- | --- | --- |
| frontmatter | Identity + the two version axes. | Required: `type: spec`, `id`, `swarm_language: SOL/0.1`, `aps_version`, `spec_version`, `status`. Optional: `title`, `owners`, `imports`, `domain` (§22.1.2), `created`, `updated`. (Canonical set, §5.8.) |
| `## Intent` | One paragraph: the user- or system-visible outcome. | APS prose. |
| `## Non-goals` | Explicit out-of-scope, to bound interpretation. | APS prose / bullets. |
| `## Context` | Only load-bearing background; links, not pastes. | APS prose + links to findings/ADRs/audits. |
| `## Interfaces` | Boundary declarations. | `INTERFACE` blocks (each MUST bind `VERIFY BY contract:…`, §15). |
| `## Obligations` | The binding behavioral requirements. | `REQ` blocks. |
| `## Constraints` | Forbidden actions / restrictions. | `CONSTRAINT` blocks. |
| `## Invariants` | Properties that must hold. | `INVARIANT` blocks (prefer `property\|model\|static` proofs). |
| `## Questions` | Captured ambiguity. | `QUESTION` blocks (`blocking` ones MUST be resolved before lowering, §11). |
| `## Verification coverage` | Per-obligation proof binding, at a glance. | Table: ID → `VERIFY BY` reference. |
| `## Downstream tasks` | Which task frames cover which obligations. | Table: Task → Covers. |
| `## Distillation loss statement` | Preserved / Dropped / Still-uncertain (§24). | Three subsections. |

#### 21.2.2 Template

```markdown
---
type: spec
id: {{slug}}
swarm_language: SOL/0.1
aps_version: 0.1
spec_version: 0.1.0
status: draft
created: {{createdAt}}
updated: {{createdAt}}
---

# Spec: {{title}}

## Intent

State the user-visible or system-visible outcome in one paragraph.

## Non-goals

- Explicitly out of scope.

## Context

Only load-bearing background. Link research, findings, ADRs, audits — do not paste them.

## Interfaces

INTERFACE IF-001:
`<fn-or-boundary>` RETURNS <type>
ACCEPTS:
  - <input>
ERRORS:
  - <error>
OWNED BY <owner>
VERIFY BY contract:<adapter>:<artifact>

## Obligations

REQ AC-001:
WHEN <trigger>
THE <actor> MUST <observable response>
VERIFY BY test:<adapter>:<artifact>[#selector]
WRITES <surface>
RISK medium

## Constraints

CONSTRAINT C-001:
THE <actor/surface> MUST NOT <forbidden action>
VERIFY BY static:<adapter>:<artifact>

## Invariants

INVARIANT I-001:
<state/property> MUST <hold>
VERIFY BY property:<adapter>:<artifact>

## Questions

QUESTION Q-001 [blocking]:
<question>
AFFECTS <id-or-surface>

## Verification coverage

| ID     | VERIFY BY                          |
| ------ | ---------------------------------- |
| AC-001 | test:<adapter>:<artifact>          |
| C-001  | static:<adapter>:<artifact>        |
| I-001  | property:<adapter>:<artifact>      |
| IF-001 | contract:<adapter>:<artifact>      |

## Downstream tasks

| Task | Covers |
| ---- | ------ |
|      |        |

## Distillation loss statement

### Preserved

### Dropped

### Still uncertain
```

### 21.3 `task.md` — the pass frame

#### 21.3.1 Contract

A task is a *pass frame and execution companion*: the lowered work packet for one pass over assigned source. `task_kind` is a frontmatter enum that parameterizes which pass runs (forward-ref §28). The frontmatter MUST carry the orchestration scope fields so the lowering pass can prove disjointness (§18): `assigned_obligations`, `write_surfaces`, `verification_bindings`, plus the coordination fields `parallel_group`, `blocked_by`. A conformant `task.md` MUST contain:

| Section | Meaning |
| --- | --- |
| frontmatter | `type: task`, `id`, `status` (`active \| blocked \| done \| abandoned`; `done` is terminal), `task_kind` (enum), `source`, `assigned_obligations`, `constraints`, `invariants`, `interfaces`, `write_surfaces`, `verification_bindings`, `parallel_group`, `blocked_by`, `produces`. |
| `## Parent contract` | The inherited hand-off contract: objective + deliverable + acceptance bar + boundaries (owned vs forbidden paths). |
| `## Scope` | An explicit **In / Out** list bounding the pass. |
| `## Assigned obligations` | The exact assigned SOL blocks, pasted verbatim. |
| `## Constraints and invariants` | The SOL blocks this task MUST preserve. |
| `## Implementation or pass trace` | What changed, per obligation. |
| `## Verification matrix` | Required proof → actual proof → 7-value status, per obligation. |
| `## Promotion queue` | Discoveries with target + promotion status (§23); all MUST be resolved before task close. |
| `## Self-review` | The structured self-review block (did I do only this pass; preserve semantics; map every claim to evidence). |

`write_surfaces` MUST be a subset of the assigned obligations' `WRITES` surfaces; an owned path outside a declared write surface is a `SOL-O005` defect (§8, G7).

#### 21.3.2 Template

```markdown
---
type: task
id: {{slug}}
status: active
task_kind: feature | fix | refactor | rewrite | migration | upgrade | performance | testing | documentation | spec-writing | research-writing | audit-writing | bug-report-writing | review | orchestration | integration | deepen-audit
source:
assigned_obligations:
constraints:
invariants:
interfaces:
write_surfaces:
verification_bindings:
parallel_group:
blocked_by:
produces:
created: {{createdAt}}
---

# Task: {{title}}

## Parent contract

| Field        | Value |
| ------------ | ----- |
| Objective    |       |
| Deliverable  |       |
| Acceptance bar |     |
| Owned paths  |       |
| Forbidden paths |    |

## Scope

### In

-

### Out

- Do not implement unassigned obligations.
- Do not change behavior outside the assigned write surfaces.
- Do not weaken constraints, invariants, or non-goals.

## Assigned obligations

Paste the exact assigned SOL blocks here.

## Constraints and invariants

Paste all constraints and invariants this task must preserve.

## Implementation or pass trace

| Obligation / target | Files changed | How satisfied |
| ------------------- | ------------- | ------------- |
|                     |               |               |

## Verification matrix

| Obligation / C / I | Required proof | Actual proof | Status |
| ------------------ | -------------- | ------------ | ------ |
|                    |                |              | PASS / FAIL / BLOCKED / UNVERIFIED |

## Promotion queue

| Item | Target | Status |
| ---- | ------ | ------ |
|      |        | pending / promoted / deferred / rejected / blocked |

## Self-review

<self_review>

- Did I perform only the assigned pass?
- Did I preserve all assigned SOL semantics?
- Did I map every completion claim to evidence?
- Did I avoid changes outside the declared write surfaces?
- Did I resolve every promotion item?
- What remains BLOCKED or UNVERIFIED?

</self_review>
```

### 21.4 `trace.md` — implementation claims

#### 21.4.1 Contract

A trace records implementation *claims* against obligations and binds them to *evidence*. Its core payload is one or more `TRACE` blocks (`IMPLEMENTS` / `PRESERVES` / `CHANGED` / `PROOF`, §6) plus the drift-provenance fields from §16 that the staleness join depends on. A conformant `trace.md` MUST contain:

| Section | Meaning |
| --- | --- |
| frontmatter | `type: trace`, `id`, `source_task`, `source_spec`, `created`. |
| `## Claimed implementation` | The `TRACE` blocks. |
| `## Provenance` | The §16 / G11 fields **per binding**: `source_hash` (obligation content hash at PASS), `per_surface_hash[]` (each declared `WRITES` and proof-exercised `READS` file hash/SHA, §16.5), `adapter`, `verdict`, `tier`, `timestamp`. These are what flips a PASS to `STALE` when source or surface drifts (§16). |
| `## Verification matrix` | ID → required proof → actual proof → 7-value status. |
| `## Unassigned changes` | Any change outside assigned obligations, with reason + authorizing ID or `none`. |
| `## Promotion items` | Discoveries to promote, with target + status. |

#### 21.4.2 Template

```markdown
---
type: trace
id: {{slug}}-trace
source_task: .swarm/generated/tasks/{{slug}}.md
source_spec: {{spec-id}}.swarm.md
created: {{createdAt}}
---

# Trace: {{title}}

## Claimed implementation

TRACE T-001:
IMPLEMENTS AC-001
PRESERVES C-001
CHANGED <path>
PROOF <verification output reference>

## Provenance

| Binding | source_hash | per_surface_hash[] | adapter | verdict | tier | timestamp |
| ------- | ----------- | ------------------ | ------- | ------- | ---- | --------- |
| AC-001  |             |                    |         | PASS    |      |           |

## Verification matrix

| ID     | Required proof | Actual proof | Status |
| ------ | -------------- | ------------ | ------ |
| AC-001 |                |              | PASS / FAIL / BLOCKED / UNVERIFIED |

## Unassigned changes

| Change | Reason | Authorized by |
| ------ | ------ | ------------- |
|        |        | AC/C/I/IF ID or `none` |

## Promotion items

| Discovery | Target | Status |
| --------- | ------ | ------ |
```

### 21.5 `review.md` — the verdict record

#### 21.5.1 Contract

A review compares trace claims against obligations, constraints, invariants, diffs, and verification evidence. **This artifact IS the verdict record**: it is the canonical container of `VERDICT` blocks, and there is no `verdict.md` (§20.2.3). A conformant `review.md` MUST contain:

| Section | Meaning |
| --- | --- |
| frontmatter | `type: review`, `id`, `source_trace`, `source_spec`, `reviewed_output`, `pass`, `profile` (e.g. `skeptic`), `created`. |
| `## Per-obligation verdicts` | One `VERDICT` block per judged obligation, using the canonical verdict line: `VERDICT <id>: <CORE> [(<lifecycle> by <authority>: <reason>)]` plus `REASON` / `EVIDENCE`. Core ∈ {PASS, FAIL, BLOCKED, UNVERIFIED}; lifecycle ∈ {WAIVED, STALE, CONTRADICTED} (§14). |
| `## Obligation-verdict matrix` | A compact table of every obligation ID → core verdict → lifecycle → evidence checked. |
| `## Constraint and invariant verdicts` | The same, for `C-` and `I-` IDs. |
| `## Unauthorized changes` | Every change not traceable to an authorizing obligation, judged allowed / suspect / reject. |
| `## Final verdict` | The merge-gate result: merge iff every required obligation is `PASS` or `WAIVED`, none `STALE`/`CONTRADICTED`/`FAIL`/`BLOCKED`/`UNVERIFIED` (§14). |
| `## Promotion queue` | Items to promote, with target + status. |

A WAIVED verdict MUST name authority + reason + expiry; a STALE verdict MUST cite the prior-verdict ref + changed surface; a CONTRADICTED verdict MUST cite the two conflicting evidence refs (§14).

#### 21.5.2 Template

```markdown
---
type: review
id: {{slug}}-review
source_trace: {{slug}}-trace
source_spec: {{spec-id}}.swarm.md
reviewed_output:
pass: review
profile: skeptic
created: {{createdAt}}
---

# Review: {{title}}

## Per-obligation verdicts

VERDICT AC-001: PASS
REASON <why this core verdict>
EVIDENCE <proof artifact / output reference>

VERDICT AC-002: FAIL (WAIVED by {{authority}}: {{reason}}; expires {{date}})
REASON <why>
EVIDENCE <reference>

## Obligation-verdict matrix

| Obligation | Core verdict | Lifecycle | Evidence checked |
| ---------- | ------------ | --------- | ---------------- |
| AC-001     | PASS         | —         |                  |
| AC-002     | FAIL         | WAIVED    |                  |

## Constraint and invariant verdicts

| ID    | Core verdict | Lifecycle | Evidence checked |
| ----- | ------------ | --------- | ---------------- |
| C-001 | PASS         | —         |                  |
| I-001 | PASS         | —         |                  |

## Unauthorized changes

| Change | Authorized by          | Verdict |
| ------ | ---------------------- | ------- |
|        | AC/C/I/IF ID or `none` | allowed / suspect / reject |

## Final verdict

Merge gate: PASS / BLOCKED
(merge iff every required obligation is PASS or WAIVED; none STALE/CONTRADICTED/FAIL/BLOCKED/UNVERIFIED)

## Promotion queue

| Item | Target | Status |
| ---- | ------ | ------ |
```

### 21.6 `finding.md` — a durable fact

#### 21.6.1 Contract

A finding is one durable, provenance-anchored project fact discovered during work; it is the Tier-2 evidence store the memory index (§23) links into. Every promoted finding MUST carry the full provenance set so its staleness can be computed and its applicability scoped. A conformant `finding.md` MUST contain:

| Field / section | Meaning |
| --- | --- |
| `status` (frontmatter enum) | `candidate \| accepted \| promoted \| rejected \| stale \| superseded`. Goes `stale` when `content_hash` no longer matches the cited source/surfaces (§16). |
| `## Claim` | The one durable fact. |
| `## Evidence` | File / command / output / source references. |
| provenance fields | `origin_obligations[]`, `origin_traces[]`, `pass` + `profile`, `reviewer_or_tool`, `timestamp`, `content_hash`, `confidence`. |
| `## Applies when` / `## Does not apply when` | Scope conditions (mandatory; if it cannot name when it applies, it MUST NOT be promoted). |
| `## Promotion target` | The promotion route (spec / audit / ADR / memory pattern / keep-scoped / stale). |
| `## Status history` | Append-only status transitions. |

#### 21.6.2 Template

```markdown
---
type: finding
id: {{slug}}
status: candidate
created: {{createdAt}}
updated: {{createdAt}}
origin_obligations:
origin_traces:
pass:
profile:
reviewer_or_tool:
content_hash:
confidence: high | medium | low
---

# Finding: {{title}}

## Claim

One durable project fact.

## Evidence

- File:
- Command:
- Output:
- Source:

## Applies when

-

## Does not apply when

-

## Related obligations

-

## Promotion target

- [ ] Keep as scoped finding
- [ ] Promote into spec
- [ ] Promote into audit
- [ ] Promote into ADR
- [ ] Promote into memory pattern
- [ ] Mark stale / superseded

## Status history

- {{createdAt}} — candidate — created during {{pass}} pass
```

### 21.7 `adr.md` — an immutable decision

#### 21.7.1 Contract

An ADR records one architecture decision in Nygard form. ADRs are **immutable**: an accepted ADR is never edited in place; "amending" it means writing a *new* superseding ADR and setting the old one's status to `superseded`. A conformant `adr.md` MUST contain the four Nygard elements — context, decision, consequences, status — plus the supersession link fields:

| Section | Meaning |
| --- | --- |
| frontmatter | `type: adr`, `id`, `status` (`proposed \| accepted \| superseded \| rejected`), `supersedes`, `superseded_by`, `created`, `updated`. |
| `## Context` | What forced the decision. |
| `## Decision` | What was chosen. |
| `## Consequences` | Positive / negative / neutral tradeoffs. |
| status linkage | An amended ADR gets only a `Superseded by ADR-00XX` status line; its body stays immutable. |

#### 21.7.2 Template

```markdown
---
type: adr
id: {{slug}}
status: proposed
created: {{createdAt}}
updated: {{createdAt}}
supersedes:
superseded_by:
---

# ADR: {{title}}

## Context

What forced the decision.

## Decision

What we chose.

## Alternatives considered

| Alternative | Why rejected |
| ----------- | ------------ |

## Consequences

### Positive

### Negative

### Neutral / tradeoffs

## Status

proposed | accepted | superseded | rejected
(if superseded: Superseded by ADR-00XX — body below stays immutable)

## Affected obligations / constraints

- Adds:
- Modifies:
- Supersedes:
```

### 21.8 `memory/INDEX.md` — the recall map

#### 21.8.1 Contract

The memory index is a compact **MAP** — links, not explanations. It is the Tier-1 entry point that links into the Tier-2 evidence store (findings, ADRs, patterns, glossary). Every entry MUST carry a `Load when` condition; an entry that cannot name when it matters MUST be removed. A conformant `memory/INDEX.md` MUST contain:

| Section | Meaning |
| --- | --- |
| frontmatter | `type: memory-index`, `id: memory-index`, `status: active`, `updated`. |
| `## Always-relevant project facts` | The few facts loaded every task. |
| `## Topic files` | Table: Topic → file → **Load when**. |
| `## Durable findings` | Table: Finding → status → **Load when**. |
| `## Decisions` | Table: ADR → status → **Load when**. |
| `## Stale or superseded memory` | Table: Item → replacement → action. |

#### 21.8.2 Template

```markdown
---
type: memory-index
id: memory-index
status: active
updated: {{createdAt}}
---

# Memory index

## Purpose

The compact map of durable project knowledge. Read before tasks that may depend
on prior discoveries; follow links to topic files only when the Load-when matches.

## Always-relevant project facts

-

## Topic files

| Topic                 | File                       | Load when                                |
| --------------------- | -------------------------- | ---------------------------------------- |
| Architecture patterns | `patterns/architecture.md` | Editing module boundaries or ownership   |
| Testing patterns      | `patterns/testing.md`      | Adding, moving, or interpreting tests    |
| Debugging patterns    | `patterns/debugging.md`    | Investigating repeated failures          |

## Durable findings

| Finding | Status | Load when |
| ------- | ------ | --------- |
|         |        |           |

## Decisions

| ADR | Status | Load when |
| --- | ------ | --------- |
|     |        |           |

## Stale or superseded memory

| Item | Replacement | Action |
| ---- | ----------- | ------ |
|      |             |        |
```

### 21.9 Tier-3 stdlib source-doc templates (brief notes)

The stdlib ships three source-document templates (§20.3.3). Each is plain `.md`, carries `type` + `id` frontmatter, and preserves a fixed *epistemic stance* enforced by the distillation-loss + source-authority discipline (§22, §24), not by a gatekeeper skill.

| Template | Required sections | Stance rule | Promotion |
| --- | --- | --- | --- |
| `audit.md` | `## Scope`, `## Observations` (evidence-cited), `## Risks`, `## Recommended obligations`. | Observation-only: records what *is*; MUST NOT prescribe a fix inline. | Promotes to a `spec.swarm.md` via the author pass. |
| `research.md` | `## Question`, `## Findings` (each → a `finding.md`), `## Open questions`, `## Recommendation`. | Investigation: open questions remain `QUESTION` candidates until resolved. | Promotes to a `spec.swarm.md` via the author pass. |
| `bug-report.md` | `## Symptom`, `## Reproduction`, `## Root cause`, `## Affected obligations`. | Diagnosis-only: MUST NOT contain the fix; states the broken obligation. | Promotes into a fix `task.md` (`task_kind: fix`), never directly into code. |

#### 21.10 PRD and RFC source-doc templates (stdlib, conditional)

These two stdlib source-doc templates extend the Tier-3 set of §21.9. Like `audit.md`, `research.md`, and `bug-report.md`, each is plain `.md`, carries `type` + `id` frontmatter, and preserves a fixed *epistemic stance* enforced by the distillation-loss and source-authority discipline (§22, §24), not by any gatekeeper tool. They are **conditional**: a conformant repo MUST ship the templates in `scaffold/.agents/` but MAY have zero instances — a `prd.md` is required only when a change introduces or reshapes intended product behaviour, and an `rfc.md` is required only when a technical approach needs a decision before it is committed to an approved `spec.swarm.md` or an `adr.md`. Both promote forward through the author pass; neither carries obligation blocks itself (§21.10.3).

##### 21.10.1 `prd.md` — product intent

A PRD captures the **product intent** behind a body of work: the problem, the affected users, and the outcomes that define success — never the mechanism. Its stance is **intent-only**: it states *what outcome is wanted and why*, and MUST NOT author `REQ`/`CONSTRAINT`/`INVARIANT`/`INTERFACE` obligation blocks (those are produced when it promotes to a `spec.swarm.md` via the author pass). It is required when a change initiates new product behaviour or alters the scope of existing behaviour, so that downstream obligations have a single, citable source of intent. A conformant `prd.md` MUST contain:

| Section | Meaning | Stance rule |
| --- | --- | --- |
| frontmatter | `type: prd`, `id`, `status` (`draft \| accepted \| superseded`), `created`, `updated`. | — |
| `## Problem` | The user/business problem in plain prose. | States the problem, not a solution. |
| `## Users` | Who is affected; the segments the outcome serves. | — |
| `## Goals` | The outcomes that define success (intent, not mechanism). | Outcome statements, never `REQ` blocks. |
| `## Non-goals` | Explicitly out-of-scope outcomes; the boundary of intent. | Mandatory; an empty boundary is a defect. |
| `## Success metrics` | Measurable signals that a goal was met. | Each metric SHOULD be expressible as a future `monitor:` proof type BECAUSE a metric that cannot be observed cannot later bind a `VERIFY BY` (§proof types). |
| `## Release constraints` | Date, rollout, compliance, or dependency limits on shipping. | Constraints on *delivery*, not authored `CONSTRAINT` blocks. |
| `## Linked evidence` | References to `research.md`/`finding.md` that ground the intent. | Cross-file refs use `<spec-id>#<local-id>` where an evidence item has a local id. |

```markdown
---
type: prd
id: {{slug}}
status: draft
created: {{createdAt}}
updated: {{createdAt}}
---

# PRD: {{title}}

## Problem

The user or business problem, in plain prose. State what is wrong or missing,
not how to fix it.

## Users

- Who is affected and which segment the outcome serves.

## Goals

- Outcomes that define success (intent, not mechanism).

## Non-goals

- Explicitly out of scope. The boundary of intent; MUST NOT be empty.

## Success metrics

| Metric | Target | How observed (future monitor: proof) |
| ------ | ------ | ------------------------------------ |
| | | |

## Release constraints

- Date / rollout / compliance / dependency limits on shipping.

## Linked evidence

- research: (e.g. password-recovery-survey#F-002)
- finding:
```

##### 21.10.2 `rfc.md` — technical proposal

An RFC records **one technical proposal** put forward for a decision: the problem it solves, the proposed approach, the alternatives weighed, and the explicit decision being requested. Its stance is **proposal/pre-decision**: it advocates an approach but commits to none until the requested decision is made, at which point it promotes to an accepted `adr.md` (the immutable decision) and/or an approved `spec.swarm.md` (the behavioral contract) via the author pass. It is required when a technical approach is significant enough that a record of *why this and not the alternatives* must outlive the change. Every unresolved item in `## Open questions` is a `QUESTION` (`Q-NNN`) candidate and MUST remain open until resolved (§blocking-question handling); an RFC MUST NOT be promoted while a question that blocks its proposal is unresolved. A conformant `rfc.md` MUST contain:

| Section | Meaning | Stance rule |
| --- | --- | --- |
| frontmatter | `type: rfc`, `id`, `status` (`proposed \| accepted \| rejected \| superseded`), `created`, `updated`. | — |
| `## Problem` | What technical problem forces a proposal. | Cite the originating `prd.md`/`finding.md`/`audit.md` where one exists. |
| `## Proposal` | The advocated approach, in enough detail to evaluate. | Describes a mechanism; authors no obligation blocks. |
| `## Alternatives` | Other approaches and why each is weaker. | Mandatory; "none considered" is a defect BECAUSE an RFC's value is the comparison it records. |
| `## Migration plan` | How adoption proceeds from the present state. | Steps and ordering, not authored `TRACE` blocks. |
| `## Open questions` | Unresolved points that gate the decision. | Each is a `QUESTION` (`Q-NNN`) candidate until resolved. |
| `## Decision requested` | The exact decision being asked for. | Names the promotion target (`adr.md` and/or `spec.swarm.md`). |

```markdown
---
type: rfc
id: {{slug}}
status: proposed
created: {{createdAt}}
updated: {{createdAt}}
---

# RFC: {{title}}

## Problem

The technical problem that forces a proposal. Cite the originating PRD, finding,
or audit where one exists.

## Proposal

The advocated approach, in enough detail to evaluate. Describes a mechanism;
authors no obligation blocks.

## Alternatives

| Alternative | Why weaker than the proposal |
| ----------- | ---------------------------- |
| | |

## Migration plan

1. Step / ordering from the present state to the proposed state.

## Open questions

- Each unresolved point is a QUESTION (Q-NNN) candidate until resolved; an RFC
 with a blocking open question MUST NOT be promoted.

## Decision requested

The exact decision being asked for, and its promotion target
(accepted adr.md and/or approved spec.swarm.md).
```

##### 21.10.3 Stance and promotion summary

Both templates obey the same no-obligation discipline as the §21.9 set: neither `prd.md` nor `rfc.md` MAY contain `REQ`/`CONSTRAINT`/`INVARIANT`/`INTERFACE` blocks, because doing so would let an *intent* or a *proposal* be read as an approved contract and bypass the author pass (§24 source-authority). Obligations come into existence only when these source docs promote forward:

| Template | Stance | Promotes to |
| --- | --- | --- |
| `prd.md` | Intent-only (states the wanted outcome and why; authors no obligations). | A `spec.swarm.md` via the author pass; `## Success metrics` seed future `monitor:` proofs. |
| `rfc.md` | Proposal / pre-decision (advocates one approach, commits to none). | An accepted `adr.md` and/or approved `spec.swarm.md` via the author pass once `## Decision requested` is answered. |


### 21.11 The status artifact (observed state)

#### 21.11.1 Motivation

The workspace separates **desired state** from **observed state** as two distinct artifacts so neither corrupts the other (a design choice; cf. the source/status/generated split). A `spec.swarm.md` under `sources/specs/<ctx>/<slug>.swarm.md` is the *desired truth*: the obligation graph the author pass authored, immutable as intent until an explicit amendment moves it. Whether the codebase currently *satisfies* that intent is a different, time-varying fact, and it MUST NOT be recorded by editing the spec.

A spec MUST NOT be continuously edited to add pass/fail annotations, per-obligation verdicts, or drift notes. Doing so would (a) churn the `source_hash` of every obligation on each verification cycle — falsely tripping the staleness rule (§16.2 condition (a)) for obligations whose *intent* never moved — and (b) blur the source-authority line by letting observed reality masquerade as authored intent. Observed satisfaction and drift therefore live in a separate **status artifact**: `status/specs/<ctx>/<slug>.status.md`, which observes exactly one spec.

> *Design rationale.* This mirrors the spec/status separation already fixed for the workspace (`sources/specs/` holds desired behavioral state; `status/specs/` holds observed satisfaction of that behavior). The status artifact is the workspace's persisted projection of the judged obligation graph — the read-model the merge gate (§14) and drift detection (§16) consult, never a second place where intent is authored. The desired-state/observed-state split is itself an established pattern: Kubernetes objects carry a desired-state `spec` and an observed-state `status`, and the system reconciles the difference between the two [K8S-SPECSTATUS].

#### 21.11.2 Contract

A `*.status.md` is a **working artifact** (plain `.md`, no `.swarm.` infix — §20.1): it is an observed-state read-model governed by an artifact contract, not a SOL source. It is **never hand-authored as intent**; it is *regenerated or updated by the `verify`, `review`, and `promote` passes* (§9) from the trace/verdict record, and reflects only what those passes recorded. A conformant `*.status.md` MUST contain:

| Section | Meaning | Carries |
| --- | --- | --- |
| frontmatter | Identity + the observed spec + freshness. | `type: status`, `id`, `spec` (the `spec.swarm.md` id this status observes), `updated`. |
| `## Obligation status` | Per obligation, the **latest** 4-core + 3-lifecycle verdict (§14) plus the proof/evidence ref that justifies it. | Table: ID → core (`PASS`/`FAIL`/`BLOCKED`/`UNVERIFIED`) → lifecycle (`WAIVED`/`STALE`/`CONTRADICTED` or `—`) → evidence/proof ref. Mirrors the obligation-verdict matrix of §14 / §21.5 — it does not re-judge, it records the latest judgment. |
| `## Drift` | The obligations whose latest verdict carries a `STALE` or `CONTRADICTED` lifecycle decorator (§16), each with the staleness reason. | Table: ID → `STALE`/`CONTRADICTED` → reason (the changed-surface or adapter that triggered staleness per §16.2/§16.5, or the two conflicting evidence refs for `CONTRADICTED`) → prior-verdict ref. |
| `## Coverage` | Which obligations have a passing proof. | Table: ID → covered? (a binding whose latest verdict is `PASS` with no blocking lifecycle) → bound proof ref. Aggregate coverage and drift coverage (§16.4) MAY be summarized here. |

Normative rules:

- The status artifact is a **read-model, not an authority.** It MUST NOT introduce, modify, or weaken any obligation, constraint, invariant, or interface; the only authoritative source of intent is the `spec.swarm.md` it observes (§22). Status can falsify assumptions and route an amendment, but it does not redefine intent.
- The `## Obligation status` rows MUST be the **latest** verdict per obligation, consistent with the merge-gate predicate (§14.4): an obligation passes the gate iff its row is `PASS` or `WAIVED` and no row is `STALE`/`CONTRADICTED`/`FAIL`/`BLOCKED`/`UNVERIFIED`. The status artifact does not re-evaluate the gate; it is the projection the gate is evaluated *over*.
- A `STALE` or `CONTRADICTED` row in `## Drift` MUST carry the same mandatory fields its `VERDICT` block does (`SOL-V005`, §14.3): a `STALE` row cites its prior-verdict ref and the changed `WRITES`/`READS` surface or rebound adapter (§16.2, §16.5); a `CONTRADICTED` row cites its two conflicting evidence refs (§14.1.2).
- The artifact is **regenerated/updated, never hand-edited as intent.** Because Swarm ships no runtime (Invariant 1, NO RUNTIME — §2), "regenerated by the `verify`/`review`/`promote` passes" today means an agent following those pass guides rewrites the status from the trace and `review.md` record; a future Swarm toolchain MAY produce it deterministically. Either way the status artifact is *derived* — it is rebuildable from the spec, the trace-provenance schema (§16.1, G11), and the `review.md` verdict record (§21.5). It MUST NOT be the only home of any fact.

#### 21.11.3 Template

```markdown
---
type: status
id: {{slug}}-status
spec: {{spec-id}}.swarm.md
updated: {{updatedAt}}
---

# Status: {{title}}

Observed satisfaction of `sources/specs/{{ctx}}/{{slug}}.swarm.md`.
Regenerated by the verify / review / promote passes — never hand-authored as
intent. The authoritative obligations live in the spec; this file records only
the latest observed verdict, drift, and coverage.

## Obligation status

| ID     | Core verdict                          | Lifecycle                       | Evidence / proof ref |
| ------ | ------------------------------------- | ------------------------------- | -------------------- |
| AC-001 | PASS / FAIL / BLOCKED / UNVERIFIED    | — / WAIVED / STALE / CONTRADICTED |                      |
| C-001  |                                       | —                               |                      |
| I-001  |                                       | —                               |                      |
| IF-001 |                                       | —                               |                      |

## Drift

| ID | Lifecycle           | Reason (changed surface / adapter / conflicting refs) | Prior-verdict ref |
| -- | ------------------- | ----------------------------------------------------- | ----------------- |
|    | STALE / CONTRADICTED |                                                       |                   |

## Coverage

| ID     | Covered (latest = PASS, no blocking lifecycle) | Bound proof |
| ------ | ---------------------------------------------- | ----------- |
| AC-001 | yes / no                                       |             |

<!-- drift_coverage = (count latest-verdict STALE) / (count required obligations) — §16.4 -->
```

#### 21.11.4 Relationship to the verdict and drift models

The status artifact is the persisted **read-model** that the two enforcement concerns consult:

- **Merge gate (§14).** The gate is the predicate "every required obligation's latest verdict is `PASS` or `WAIVED`, and none is `STALE`/`CONTRADICTED`/`FAIL`/`BLOCKED`/`UNVERIFIED`" (§14.4). `## Obligation status` is the at-a-glance projection of exactly that set of latest verdicts; a reader (or a future deterministic check outside the model — §17.1) evaluates the gate by reading these rows rather than by re-scanning every `review.md`.
- **Drift detection (§16).** `## Drift` is the persisted output of the staleness rule. When the obligation `source_hash` (§16.2 condition (a)), a declared write surface (condition (b)), an exercised `READS` surface (§16.5 condition (c)), or the bound adapter (condition (d)) changes after a recorded `PASS`, the prior `PASS` is decorated `STALE` and surfaces here with its changed-surface reason, forcing the 3-way reconcile (§16.3). `## Coverage` carries the denominator for the drift-coverage metric (§16.4).

A status row is therefore always *downstream* of a `VERDICT` block in a `review.md` (§14.5, §21.5) and the trace-provenance schema (§16.1): the `review.md` records the judgment and the trace records the hashes; the `*.status.md` projects the latest of each per obligation so the spec stays a stable statement of intent while observed reality is tracked beside it. There is no `verdict.md` (§20.2.3); equally, there is no second authority — the status artifact observes, the spec intends, and the two are reconciled by the verify/review/promote passes, not by editing one into the other.
