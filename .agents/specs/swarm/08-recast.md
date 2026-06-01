# Swarm Kernel Specification v0.1 — Part 08: Recasting the framework

<!-- Part 08 of the Swarm Kernel Specification (§26–§31). All parts share one section numbering (§0–§35 + Appendices A–G); cross-references of the form “§N” resolve via the index in [README.md](./README.md). -->

## 26. Skills as pass guides

This section recasts the framework's 24 shipped skills onto the compiler model. A *skill* in the legacy framework was a self-contained procedural module a model loaded to perform a unit of work. Under the kernel, that role is renamed and re-scoped: a skill is a **pass guide** — a procedural module that documents *how* to perform one of the nine canonical passes (§9), and nothing more. The recast preserves every skill's procedural value while removing one specific failure mode: skills MUST NOT own language semantics.

### 26.1 The semantic-ownership prohibition

> **The load-bearing rule of this section.** No pass guide, profile, fragment, or any other skill-shaped file MAY define, redefine, or be required to interpret SOL or APS semantics.

A conformant Swarm repo MUST satisfy all of the following:

- No skill file defines a block type, a modal, a clause keyword, a verdict value, a proof type, a lint code, or any IR field. These live exclusively in the language reference (`docs/language/`) and the typed IR (§12), per the binding invariant that all load-bearing meaning lives in SOL + IR (this specification Q-semantics-1).
- A correctly written `*.swarm.md` file MUST be understandable to a strong model *without* any skill loaded, because it uses controlled natural language (§5–§7) and stable formal blocks (§6).
- A skill MAY cite, link to, or quote the language reference, but the citation is non-authoritative delivery; the authoritative text is the language reference itself.

Rationale: skills are *procedural modules, not semantic homes*; placing semantics in a skill would make meaning depend on a non-authoritative, lazily-loaded layer whose adherence is not guaranteed.

A regression check (§32, §34) MUST confirm that no skill, profile, or `AGENTS.md` section defines modality, authority order, or verification semantics.

### 26.2 The 24-skill → ~9-pass recast

The 24 shipped skills recast onto the nine passes of §9. The mapping is *many-skills-to-one-pass*: a pass MAY carry more than one pass guide (e.g. `implement` carries one guide per implementation kind), and every pass carries **at least one** pass guide. Two cross-cutting fragments (§26.3) are shared across passes rather than owned by one.

| Legacy skill | Recast role | Owning pass |
|---|---|---|
| `write-spec` | author guide | `author` (spec) |
| `write-research` | author guide | `author` (research) |
| `write-audit` | author guide | `author` (audit) |
| `write-bug-report` | author guide | `author` (bug-report) |
| `write-feature` | implement guide | `implement` |
| `write-fix` | implement guide | `implement` |
| `write-refactor` | implement guide | `implement` |
| `write-rewrite` | implement guide | `implement` |
| `write-migration` | implement guide | `implement` |
| `write-performance` | implement guide | `implement` |
| `write-testing` | implement guide | `implement` |
| `write-documentation` | implement guide | `implement` |
| `fix-flaky-test` | narrow implement guide | `implement` |
| `adversarial-review` | **folds into** the review pass as a profile (Skeptic, §27) — no longer a skill | `review` |
| `empirical-proof` | cross-cutting fragment | shared (behind `verify`) |
| `distillation-discipline` | cross-cutting fragment | shared (behind `lower`/`promote`) |
| `persona-architect` | becomes a profile (§27) | `author` (spec) |
| `persona-auditor` | becomes a profile (§27) | `author` (audit) |
| `persona-janitor` | becomes a profile (§27) | `implement` |
| `persona-migrator` | becomes a profile (§27) | `implement` |
| `persona-performance-surgeon` | becomes a profile (§27) | `implement` |
| `persona-skeptic` | becomes a profile (§27) | `review`/`verify` |
| `persona-surveyor` | becomes a profile (§27) | `author` (research) |
| `persona-lead-engineer` | becomes a profile (§27) | `decompose`/merge-gate |

Three transformations in that table are normative and called out individually:

- **`adversarial-review` folds into `review`.** It MUST NOT survive as a standalone skill. Its adversarial method becomes the **Skeptic profile** (§27) applied to the `review` and `verify` passes. Rationale: skepticism is a *profile parameter to a pass*, not a separate pass.
- **`fix-flaky-test` survives as a narrow `implement` guide.** It is the one legacy skill that maps to a sufficiently specific procedure (de-flaking a non-deterministic test) to remain its own guide rather than collapse into `write-fix`.
- **The eight `persona-*` skills become profiles (§27).** Their carrier (standalone file vs inlined in a pass guide) is an implementation detail; what matters is that a profile is a heuristic stance, not a procedure module.

The resulting pass-guide set carried by `docs/passes/` (and the scaffold copy under `scaffold/.agents/skills/`) MUST cover the nine passes; the five **stdlib pass guides** that are tooled first are `lint`, `decompose`, `implement`, `review[profile: skeptic]`, and `promote`.

### 26.3 The two cross-cutting fragments

Two procedural disciplines apply across multiple passes and are therefore packaged as **fragments**, not pass guides. A fragment is a pass guide that a pass guide composes (it has the same shape, §26.5, but is named by another guide rather than by a task `task_kind`).

| Fragment | Discipline it carries | Passes that compose it |
|---|---|---|
| `empirical-proof` | the proof / `VERIFY BY` discipline — every completion claim maps to an independent, re-runnable proof; "tests passed" without output is not a proof (§15) | `verify`, `review` |
| `distillation-discipline` | the loss-budget discipline — what MUST be preserved and what MAY be dropped when meaning crosses an artifact boundary (§24) | `lower`, `decompose`, `promote` |

Neither fragment defines semantics: `empirical-proof` does not define the proof taxonomy (that is §15); `distillation-discipline` does not define the loss budget table (that is §24). Each is the *procedure* for applying a discipline the language and reference layers own.

### 26.4 Activation doctrine (ADR 0020, reframed)

ADR 0020's self-activating `description` field is **retained but reframed**. The canonical doctrine is:

> **Load the pass guide or profile that the task file names.** Description-matching is the launcher-less fallback, not the primary mechanism.

Normatively:

- A `task.md` (§28) SHOULD name, in its frontmatter or assignment block, the pass guide(s) and profile(s) it activates for the pass it frames. When named, the agent MUST load exactly those, and SHOULD NOT load others. BECAUSE always-on density harms adherence and cost (§31, this specification Q-density-1).
- When no launcher and no explicit naming is present, an agent MAY fall back to matching a guide's self-activating `description` against the task. This is a degraded mode, not the contract.
- A skill MUST NOT be always-loaded (ADR 0017, kept verbatim). Pass guides and profiles are lazily loaded.

Example task-to-guide binding (the recommended primary path):

```text
task.md frontmatter:
  task_kind: fix
  pass: implement
  pass_guides: [write-fix, fix-flaky-test]
  profiles: [skeptic]
```

The agent loads `write-fix`, `fix-flaky-test`, and the Skeptic profile for this `implement` pass, and nothing else.

### 26.5 Pass-guide contract

Every pass guide MUST declare the following sections; this is the contract a conformant pass guide satisfies (adapted from this specification):

```markdown
# Pass guide: <name>

## Purpose
## Consumes
## Produces
## Preserves
## Rejects
## Procedure
1.
2.
3.
## Output contract
## Self-review delta
```

Dependency direction MUST be one-way and acyclic:

```text
language definitions → artifact contracts → pass contracts → pass guides → heuristic profiles → project overlays
```

A pass guide MAY depend on shared language, artifact, and pass contracts. A pass guide MUST NOT introduce a circular dependency, MUST NOT be required to interpret SOL, and MUST NOT override an approved SOL obligation. These constraints are recorded in ADR 0017 (kept), ADR 0016 (kept, self-contained skill bodies), and a new kernel ADR for the 9-pass model (§30).

### 26.6 Overlays

The §26.5 dependency chain terminates in an undefined "project overlays" node. This subsection defines that node and closes the chain. An **overlay** is the project-scoped guidance layer that sits *downstream* of every kernel object: it consumes language, artifact, pass, pass-guide, and profile contracts, and is consumed by nothing.

An **overlay** is an OPTIONAL, project-scoped bundle of **non-kernel rules** — architecture conventions, testing policy, and domain or house rules specific to one repository — that lives at `scaffold/.agents/overlays/<name>/`. An overlay carries project guidance the kernel deliberately does not ship: where a pass guide documents *how* to perform a pass (§26.5) and a profile documents *what to look for and refuse* (§27.1), an overlay documents *what this project additionally expects* on top of both. A conformant repo MAY ship zero overlays; the kernel is complete without any.

Overlays are the canonical re-home for legacy architecture and testing-policy "skills." Those skills were never pass guides (they document no pass) and never profiles (they carry no cognitive stance); they encode project-local convention. Re-homing them as overlays keeps that convention out of the pass-guide set, where it would otherwise contaminate the standard-library guides with one repo's house rules.

#### Overlay contract

Every overlay MUST be a `*.md` file (or a directory of them) under `scaffold/.agents/overlays/<name>/`, declaring the following frontmatter and sections:

```markdown
---
type: overlay
name: <name>
version: 0.1.0
---

# Overlay: <name>

## Purpose
<the one project concern this overlay addresses, single clause>

## Applies to
<the passes, task_kinds, paths, or layers this overlay's rules govern>

## Rules
<the project-specific guidance, as an enumerated list>

## Rationale
<why this project holds these rules; never a restatement of kernel semantics>
```

| Section | Content |
|---|---|
| `## Purpose` | the single project concern the overlay exists to serve |
| `## Applies to` | the scope (passes, `task_kind`s, paths, or layers) under which the overlay's rules are guidance |
| `## Rules` | the enumerated project-specific rules — architecture/testing/domain conventions and nothing kernel-owned |
| `## Rationale` | why the project holds these rules; states the reason inline, never a kernel definition |

#### The overlay prohibition

The §26.1 semantic-ownership prohibition applies to overlays identically and is restated here as a hard rule, because an overlay is the layer most tempting to abuse as a back door for project-local semantics. An overlay:

- MUST NOT define or redefine SOL or APS semantics.
- MUST NOT define or redefine a block type (§6), a modal (§5), a verdict value (§14), a proof type (§15), or a lint code (§20).
- MUST NOT override an approved SOL obligation. An overlay is purely additive guidance; it adds project-specific expectations and never weakens, waives, or reinterprets a kernel obligation. Waiver authority remains a human or the spec owner (§14), never an overlay.
- MUST NOT be always-loaded. Like pass guides and profiles, an overlay is lazily loaded by name from a `task.md` (§26.4); description-matching is the degraded fallback.

An overlay is **SOFT control** (§4): its rules are guidance for a model, not enforcement, and they bind nothing the kernel marks authoritative. The regression check of §26.1 (confirming no skill, profile, or `AGENTS.md` section defines modality, authority order, or verification semantics) MUST be extended to cover overlays: a conformant repo MUST confirm that no overlay defines or overrides any of the kernel objects enumerated above.

With overlays defined, the §26.5 dependency chain is complete and acyclic, terminating here:

```text
language definitions → artifact contracts → pass contracts → pass guides → heuristic profiles → project overlays
```

Overlays MAY depend on (cite, link, or quote) any upstream node; nothing depends on an overlay. An overlay MUST NOT introduce a back-edge into the chain — it MUST NOT be required to interpret SOL, and MUST NOT be named as a dependency of a pass guide, a profile, or a pass contract.

## 27. Personas as heuristic profiles

This section recasts the framework's 13 persona mindsets into **heuristic profiles**. A persona was never an org role (ADR 0009, kept verbatim — "personas are mindsets"); the recast makes that explicit and binds each mindset to the pass it parameterizes rather than to a task type or document type.

### 27.1 What a heuristic profile is

A **heuristic profile** is an optional cognitive stance applied to a pass. It is not a character, not an actor, and not a procedure. A profile changes *what an agent looks for and refuses* while performing a pass; the procedure itself stays in the pass guide (§26).

Normatively:

- A profile MUST NOT define language or artifact semantics (the §26.1 prohibition applies identically: a profile is a skill-shaped file).
- A profile is **optional**: a pass is well-defined without any profile loaded. A profile sharpens a pass; it is never required for the pass to be valid.
- A profile's **carrier is an implementation detail.** A profile MAY ship as a standalone file (e.g. `scaffold/.agents/skills/persona-skeptic/`) OR be inlined into a pass guide. Conformance checks the *contract* (§27.2), not the carrier. Rationale: the mindset is the kernel object; the file is incidental.

### 27.2 The canonical profile contract

Every heuristic profile MUST declare exactly these seven sections, in this order:

```markdown
# Heuristic profile: <name>

## Prevents
## Default questions
## Required evidence
## Refuses          <!-- the red-flag table (ADR 0013) -->
## Self-review delta
## Applies when
## Does not apply when
```

Section semantics:

| Section | Content |
|---|---|
| `## Prevents` | the one failure class this stance exists to catch (single clause) |
| `## Default questions` | the questions the stance forces the agent to ask while performing the pass |
| `## Required evidence` | the evidence the stance demands before it accepts a claim |
| `## Refuses` | the **red-flag table** (ADR 0013, amended): each row is a pattern the stance rejects on sight, replacing the legacy "iron law" with an enumerated refusal set |
| `## Self-review delta` | what the agent additionally checks in its self-review when this profile is active |
| `## Applies when` | the pass/`task_kind` conditions under which the profile is appropriate |
| `## Does not apply when` | the conditions under which the profile MUST NOT be loaded (prevents misapplication) |

The `## Refuses` red-flag table is the home of what ADR 0013 called the "iron law." ADR 0013 is amended via a superseding ADR (§30): the iron law is recast as a profile's `Refuses` rows.

Worked example (the Skeptic profile, the canonical reference profile per this specification):

```markdown
# Heuristic profile: Skeptic

## Prevents
Premature acceptance of plausible but unverified claims.

## Default questions
- What would falsify this?
- Does the evidence prove the exact obligation, by ID?
- Did the branch change behavior outside the assigned obligations?

## Required evidence
- Proof mapped to obligation IDs, with re-runnable artifact references.
- Diff review for unauthorized changes.
- Constraint/invariant preservation evidence.

## Refuses
| Red flag | Action |
| --- | --- |
| Summary-only proof | reject; demand the proof artifact |
| "Tests passed" with no output | reject; UNVERIFIED |
| A trace passing an obligation with missing evidence | reject; UNVERIFIED |

## Self-review delta
- Re-check every PASS verdict against the cited evidence before closing.

## Applies when
- pass ∈ {review, verify}; task_kind ∈ {review, fix}.

## Does not apply when
- The pass is author/lint/improve (no claims exist to falsify yet).
```

### 27.3 The profile → pass mapping

The 13 personas map to passes as follows. This table is normative; it is the routing that **profile × pass replaces** the legacy persona × task-type and persona × document-type matrices. The stdlib ships a six-file profile subset (§20.5.1); `reviewer.md` is a convenience alias carrying the **Skeptic** stance for the `review` pass (row 1), not a fourteenth persona.

| Profile (legacy persona) | Pass(es) it parameterizes |
|---|---|
| Skeptic | `review` / `verify` |
| Architect | `author` (spec) |
| Auditor | `author` (audit) |
| Surveyor | `author` (research — breadth / inventory survey) |
| Researcher | `author` (research — depth / external evidence) |
| Bug Hunter | `author` (bug-report) |
| Janitor | `implement` (by kind: refactor/cleanup) |
| Migrator | `implement` (by kind: migration/upgrade) |
| Performance Surgeon | `implement` (by kind: performance) |
| Builder | `implement` (by kind: feature/rewrite) |
| Test Author | `implement` (by kind: testing) |
| Documentarian | `implement` (by kind: documentation) |
| Lead Engineer | `decompose` / merge-gate (`review` over the obligation set) |

### 27.4 Profile × pass routing replaces the persona matrices

The legacy framework routed work through two matrices: persona × task-type (ADR 0002, already superseded by ADR 0020) and persona × document-type. Both are retired.

> A conformant repo MUST express routing as **profile × pass**: a task names a pass (§28) and MAY name the profile that sharpens it (§26.4). A repo MUST NOT reintroduce a persona-per-task-type or persona-per-document-type matrix.

Rationale: the old matrices duplicated the same mindset across many cells; collapsing them onto the pass axis removes the duplication and the 8/5 "persona vs profile" asymmetry the legacy docs carried. The `8/5` split is dropped: all 13 are uniformly heuristic profiles.

## 28. Task types as pass frames

This section recasts the framework's 18 task types onto the nine-pass model. The unifying statement is that a **task is a pass frame**: a `task.md` is the lowered work packet that frames exactly one pass over an assigned set of obligations. The 18 types do not disappear; they become a frontmatter **enum** that parameterizes two passes.

### 28.1 `task_kind` is a parameter, not a pass

A task carries a `task_kind:` frontmatter field whose value is one of the **17** canonical kinds — the 18 legacy task types minus the banned `kickback` (§28.2, which is a re-entry edge, not a type). `task_kind` **parameterizes** the `implement` and `author` passes — it selects which pass guide(s) (§26) and profile (§27) apply — but it is not itself a pass. The nine passes (§9) are the fixed transformation set; `task_kind` is a dimension that varies inside two of them.

```text
task_kind:  feature | fix | refactor | rewrite | migration | upgrade
          | performance | testing | documentation        ← parameterize `implement`
          | spec-writing | research-writing | audit-writing
          | bug-report-writing                            ← parameterize `author`
          | review                                        ← selects `review`
          | orchestration | integration                  ← select `decompose` + merge-gate
          | deepen-audit                                  ← parameterizes `author` (audit)
```

### 28.2 The `task_kind` → pass mapping

The mapping is normative:

| Legacy task type | Family | Pass(es) | Follow-on passes |
|---|---|---|---|
| `feature` | implementation | `implement` | `verify` → `review` |
| `fix` | implementation | `implement` | `verify` → `review` |
| `refactor` | implementation | `implement` | `verify` → `review` |
| `rewrite` | implementation | `implement` | `verify` → `review` |
| `migration` | implementation | `implement` | `verify` → `review` |
| `upgrade` | implementation | `implement` | `verify` → `review` |
| `performance` | implementation | `implement` | `verify` → `review` |
| `testing` | implementation | `implement` | `verify` → `review` |
| `documentation` | implementation | `implement` | `verify` → `review` |
| `spec-writing` | authoring | `author` (spec) | `lint` → `improve` → `lower` |
| `research-writing` | authoring | `author` (research) | `lint` → `improve` → `lower` |
| `audit-writing` | authoring | `author` (audit) | `lint` → `improve` → `lower` |
| `deepen-audit` | authoring | `author` (audit) | `lint` → `improve` → `lower` |
| `bug-report-writing` | authoring | `author` (bug-report) | `lint` → `improve` → `lower` |
| `review` | process | `review` | — |
| `orchestration` | process | `decompose` + merge-gate `review` | — |
| `integration` | process | `decompose` + merge-gate `review` | — |

Normative consequences:

- **All build/change kinds route to `implement`.** The nine implementation kinds differ only in `task_kind` (which guide/profile applies), never in pass.
- **All source-authoring kinds route to `author`,** then through the canonical authoring chain `lint → improve → lower` (a spec is authored, linted, improved, and lowered before it produces tasks).
- **`review` routes to the `review` pass.** **`orchestration` and `integration`** route to `decompose` plus a merge-gate `review`, performed under the **Lead Engineer profile** (§27).
- `documentation` is an `implement` kind (it changes a surface — docs — and is traced and verified like any other change), not an `author` kind.

`lower` and `decompose` are the two passes the legacy 18-type model lacked entirely; they are the new machinery that turns an authored spec into bounded, write-disjoint tasks (§11, §18).

### 28.3 Kickback is re-entry, not a task type

> **Normative.** `kickback` is **not** a task type. Kickback is the **re-entry of the `implement` pass** triggered by a `FAIL` or `UNVERIFIED` verdict (§14) from a `review` or `verify` pass.

A conformant repo MUST NOT define a `kickback` task type or a `kickback` value in the `task_kind` enum. When `review`/`verify` returns `FAIL` or `UNVERIFIED` for a required obligation, the obligation re-enters `implement` (the same task frame, re-opened, or a new `implement` task naming the failed obligation IDs); the loop is `implement → verify → review → (FAIL/UNVERIFIED) → implement` until the merge gate (§14) is satisfiable. Rationale: kickback describes the *control-flow edge* re-entering a pass, and modeling it as a separate task type duplicated the `implement` frame and obscured that the obligation set is unchanged.

### 28.4 The flow-graph survives as recommended routing

The legacy flow-graph (`docs/reference/flow-graph.md`, ADR 0020) survives as **recommended routing**, not as a required control structure (no runtime — Principle 1). Its nodes are relabeled onto the compiler model:

| Legacy flow-graph node | Relabeled as |
|---|---|
| document / artifact | **artifact** (the source `spec.swarm.md`, audit, research, bug-report) |
| task type | **pass** (`implement`/`author`/`review`/`decompose`) |
| lead persona | **profile** (§27) |
| recommended skill set | **pass guide(s)** (§26) |

A conformant repo SHOULD ship the flow-graph as `artifact → pass → profile → pass-guide` routing and MUST frame it as a *recommendation an agent re-assesses against the work in front of it*, never as enforcement. The per-task-type verification matrix in the legacy flow-graph is re-expressed as the default `(proof-type, phase)` suite per `task_kind`, binding through `AGENTS.md > Commands` (§15, this specification).

### 28.5 Task-template consolidation

The 18 legacy per-type templates consolidate onto a single task template, which a `task_kind` value specializes. The template's load-bearing fields are `assigned_obligations`, `constraints`, `invariants`, `interfaces`, `write_surfaces`, `verification_bindings`, the promotion queue, and the self-review block (full template in §21). A task MUST paste the *exact* assigned SOL blocks (not paraphrases) into its assignment section, BECAUSE distillation that drops an obligation ID, modality, or verification binding is a distillation error (§24).

## 29. Documents as the unified artifact set

This section recasts the framework's four core document types (ADR 0001, kept verbatim) and their extended types onto the unified artifact set of the kernel (§20, §21). The recast adds the artifacts the four-document model lacked — **trace**, the **VERDICT block**, **finding**, and **memory** — and preserves each source document's **epistemic stance** (what kind of knowledge it is allowed to assert).

The recognized **parents** of a spec — PRD, research, RFC, ADR, audit, bug-report, finding, use-case/examples, NFR/SLO, and interface sources (OpenAPI/GraphQL/DB schema) — are enumerated in §20.3.4. Each normalizes into `spec.swarm.md` while its epistemic stance (below) is preserved on promotion; `prd.md` and `rfc.md` join `audit.md`/`research.md`/`bug-report.md` as conditional Tier-3 stdlib source-doc templates (§20.3.3).

### 29.1 Epistemic stances are preserved

Each source document carries an epistemic stance that constrains what it may assert and where its content may be promoted. These stances are normative and MUST be preserved by the recast:

| Artifact | Epistemic stance | Promotes to |
|---|---|---|
| `spec.swarm.md` | **intent** — declares required behavior as SOL obligations | (is the authority; lowers to tasks) |
| `audit.md` | **observation-only** — describes present state and risk; asserts no new intended behavior | a `spec.swarm.md` (via `author`) |
| `bug-report.md` | **diagnosis-only** — reproduces and root-causes a defect; prescribes no fix | a **fix task** (`implement`) |
| `research.md` | **inquiry** — surveys options and evidence; commits to no decision | a `spec.swarm.md` (via the `author` pass) |

Normative consequence: an `audit.md` MUST NOT contain `REQ`/`CONSTRAINT`/`INVARIANT` obligation blocks of its own intent — observed risk is promoted *into* a spec, where it acquires obligation force. A `bug-report.md` MUST NOT prescribe an implementation — its diagnosis promotes *into* a fix task. These are the epistemic-stance invariants of ADR 0007 (kept) and ADR 0001 (kept).

### 29.2 spec.md becomes spec.swarm.md

The legacy `spec.md` is renamed `spec.swarm.md` — the `.swarm.` infix marks it as the one human-authored compiler-visible artifact (this specification, §20). It carries prose (under APS, §7) plus SOL blocks (§6), and it is the source that the obligation graph is built from. Everything else in the artifact set is plain `.md` (working artifacts) or an emitted `*.swarm.*` artifact (§20). A conformant repo MUST rename every `spec.md` template/reference to `spec.swarm.md` and MUST NOT introduce per-artifact `.swarm.*` names for audit/research/bug-report/finding/adr (those are plain `.md`).

### 29.3 The four artifacts the four-document model lacked

The unified artifact set adds four artifacts the four-document model had no place for. Each is specified in full by another section; this section only records that they join the catalogue and why:

| New artifact | What it is | Owning section |
|---|---|---|
| **trace** (`*.swarm.trace.md`) | an implementation claim mapped to obligation IDs + proof references; consumed by `review` | §12 (IR `implements`/`preserves` edges), §21 (template) |
| **VERDICT** (a SOL *block*, not a file) | the judged outcome of an obligation; lives inside `review.md` (there is no `verdict.md`) | §6, §14 |
| **finding** (`finding.md`) | one durable, evidenced project fact discovered during work | §21, §23 |
| **memory** (`memory/INDEX.md` + glossary + patterns) | the compact recall map + provenance store | §23 |

The VERDICT entry is load-bearing: a verdict is the *output* of a `review` pass, so it is a language block inside the review container, never a standalone artifact. A conformant repo MUST NOT ship a `verdict.md`.

### 29.4 Extended types remain specializations

The extended document types are **specializations** of the four core artifacts, not new artifact kinds. They reuse the parent artifact's template, frontmatter, and epistemic stance; they differ only in conventional content.

| Extended type | Specialization of | Notes |
|---|---|---|
| `constitution` | `spec.swarm.md` | project-wide obligations of highest domain authority (§22) |
| `migration-plan` | `spec.swarm.md` | obligations + ordering for a migration/upgrade |
| `benchmark` (report) | `audit.md` | observation-only performance measurement |
| `cleanup` (report) | `audit.md` | observation-only debt/risk inventory |

A conformant repo MAY ship these as named variants but MUST NOT give them their own block types, lint codes, or IR node kinds; they parse exactly as their parent artifact.

### 29.5 Forbidden compositions are distillation + authority discipline

The legacy framework enforced "forbidden compositions" (e.g. a single file that is simultaneously a spec and an audit, or content that smuggles intent into an observation-only artifact) through a gatekeeper skill. The kernel retires the gatekeeper and re-expresses the same prohibition as two existing disciplines:

- The **distillation loss budget** (§24): when content crosses an artifact boundary, the permitted/forbidden-loss table governs what may be dropped and what MUST be carried. A composition that would smuggle obligation force into an observation-only artifact is a distillation error.
- **Source authority** (§22): the two-axis authority model determines which artifact governs when two assert overlapping content; a lower-authority artifact MUST NOT silently override a higher one.

> **Normative.** Forbidden compositions are enforced by §24 (distillation) and §22 (source authority), not by a gatekeeper skill. A conformant repo MUST NOT reintroduce a skill whose job is to police artifact composition; the discipline lives in the language/reference layer.

Rationale: a gatekeeper skill would be a semantic owner (forbidden, §26.1) and a soft-control mechanism presented as enforcement (forbidden, §17). Routing the prohibition through distillation + authority keeps it in the authoritative layer.

## 30. ADR disposition and new kernel ADRs

This section records the disposition of every existing ADR under the kernel and lists the new kernel ADRs the rework introduces. It is governed by one rule.

### 30.1 Nygard immutability

> **Normative (ADR governance).** An accepted ADR MUST NOT be edited in place. "Amending" an ADR means publishing a **new, superseding ADR**; the original keeps its body and gains only a `Superseded by ADR-NNNN` status line. The truth of any decision is the **full chain** of ADRs, not the latest one alone.

Rationale (Nygard/Fowler): an ADR is a dated record of a decision in its context; rewriting it destroys the historical record that makes the chain auditable. ADR numbers `0011` and `0012` remain **intentionally vacant** (vacated in an earlier consolidation; left unfilled so higher references do not shift).

### 30.2 Per-ADR disposition

The 24 existing ADRs (numbers 0001–0026 minus the intentionally-vacant 0011/0012) fall into three groups.

**Group A — Kept verbatim** (body unchanged; still authoritative as written):

| ADR | Title |
|---|---|
| 0001 | Four core document types |
| 0003 | Distillation flows downhill only |
| 0004 | Task files are gitignored |
| 0005 | Template placeholder syntax `{{name}}` |
| 0007 | Bug report is diagnosis-only |
| 0008 | Empirical proof is framework-level |
| 0010 | Writes single-thread through orchestrator |
| 0014 | Delegation vs internal recursion |
| 0015 | Framework versioning (**extended**, not replaced — gains the language axis + one-way trigger, §25) |
| 0016 | Skill bodies are self-contained |
| 0017 | No always-loaded skills |
| 0021 | Verification contract |
| 0022 | Acceptance criteria are executable checks |
| 0023 | Harness-enforcement contract |
| 0026 | Machine-readable conformance contract + fixtures |

0015 is annotated "extended": its body is unchanged, but a new ADR (§30.3) scopes it to the package axis and adds the language axis. ADRs 0021/0022/0023/0026 are kept verbatim and additionally gain a one-line note that they are *verification layers of the single SOL `VERIFY BY` model*; the note is a status annotation, not a body edit.

**Group B — Amended via a new superseding ADR** (original body immutable; superseded by a 0027+ ADR that carries the recast):

| ADR | Original decision | Superseded by (new ADR) recasts it as |
|---|---|---|
| 0006 | Skeptic owns `fix` tasks | Skeptic is a **profile** on `fix`/`review` passes (§27) |
| 0009 | Personas are mindsets | personas are **heuristic profiles** (§27) |
| 0013 | Iron law + red-flags pattern | the iron law becomes a profile's `Refuses` table (§27.2) |
| 0018 | Commands resolve through `AGENTS.md` | `VERIFY BY` adapters resolve through `AGENTS.md > Commands` (§15, §31.3) |
| 0019 | Personas ship as individual skills | a standalone file is **one carrier option** for a profile (§27.1) |
| 0020 | Activation by self-assessment | doctrine is **load what the task names**; description-match is the fallback (§26.4) |
| 0024 | Self-reviewed vs reviewed confidence tiers | confidence tiers **map to the verdict taxonomy** (§14, the 7-value model) |
| 0025 | Orchestration coordination artifact | owned/forbidden paths become the **write-surface model** lowered by `lower`/`decompose` (§18, §19) |

**Group C — Already superseded** (no new action; recorded for completeness):

| ADR | Status |
|---|---|
| 0002 | Personas pair 1:1 with task types — **superseded by 0020** (and now by the profile × pass model, §27.4) |

### 30.3 New kernel ADRs (0027+)

The rework introduces the following new ADRs. Each records a kernel decision that MUST NOT be left implicit in prose; the parenthetical names the section that specifies the decision in full.

| New ADR (topic) | Records |
|---|---|
| SOL is the obligation language | SOL is the single home of obligation semantics (§5, §6) |
| APS is the prose standard | APS is the controlled-prose standard around SOL (§7) |
| The 9-pass model | `author → lint → improve → lower → decompose → implement → verify → review → promote` (§9) |
| The unified artifact set | the kernel artifact set incl. trace, VERDICT block, finding, memory (§20, §29) |
| The source-authority two-axis model | domain axis × artifact axis, lexicographic (§22) |
| The memory model | two-tier, provenance-anchored promotion (§23) |
| The golden corpus | positive + negative conformance fixtures over the three domains (§33) |
| The unified `SOL-<LAYER><NNN>` lint namespace | one prefix, five layers; APS- retired as a *code* prefix (§8) |
| The 7-value verdict model | 4 core + 3 lifecycle verdicts (§14) |

The last two are explicitly added because the lint-namespace unification and the verdict-model decision are kernel-level decisions that must be recorded as ADRs, not buried in the language reference. A conformant repo MUST carry these ADRs (or equivalents) so the chain explains why the lint namespace and verdict set have their shape.

## 31. The AGENTS.md bootloader

`AGENTS.md` is the **always-loaded bootloader**: the one file every task reads first. Because it is always on, its content is the most expensive context in the system and the most exposed to adherence decay. The kernel therefore caps it hard and restricts what may live in it.

### 31.1 The density cap

> **Normative.** `AGENTS.md` (and any always-loaded kernel bootloader prose) MUST NOT exceed a **hard cap of 200 lines / 25 KB**. It SHOULD target **~50–150 lines**. It MUST contain only persistent facts and gap-filling content; everything procedural or conditional MUST move to lazily-loaded pass guides (§26), profiles (§27), or reference docs.

Rationale (this specification Q-density-1): **minimize always-on density to protect adherence and control cost.** The cap is *not* anchored on a claim that models cannot follow many instructions — the IFScale "68%@500" figure is real but MUST NOT be cited as a capability *ceiling* — its actual finding (accuracy degrades with density, primacy bias toward earlier instructions `[IFSCALE]`) *supports* the cap; a 2026 vendor re-run on a keyword-inclusion proxy reports higher counts `[ARIZE26]` but is preliminary, non-peer-reviewed evidence and is not the load-bearing rationale. The durable mechanism is the bloat-versus-gap-filling tradeoff: bloat costs success rate and tokens; gap-filling content (facts the model genuinely lacks) earns its place.

A conformant repo MUST include a regression check that fails when `AGENTS.md` exceeds the hard cap.

### 31.2 What goes in vs what stays out

| Belongs in `AGENTS.md` (facts) | MUST move out (procedures/conditionals) |
|---|---|
| persistent project facts the model cannot infer | step-by-step pass procedures → pass guides (§26) |
| the **Commands** contract — `cmd*` binding rows (§31.3) | how to perform a review/audit/migration → pass guides |
| one-line **pointers** into memory (`memory/INDEX.md`) | full memory content → `memory/` (§23) |
| the language-reference pointer (where SOL/APS live) | the SOL/APS manual itself → `docs/language/` |
| a small set of universal startup + universal "do not" rules | conditional, task-kind-specific rules → task templates / profiles |

The startup block names the **load-what-the-task-names** doctrine (§26.4) and the universal invariants (assigned-scope-only, evidence-for-every-claim, handle-promotions-before-close, no chat-over-spec authority). It also names the **Swarm workspace** — `.swarm/` in an adopted project (§20.5) — so the agent knows where the canonical artifacts it is governed by live. A representative compliant bootloader:

```markdown
# AGENTS.md

## Swarm startup
1. Read the current task file first.
2. The Swarm workspace is `.swarm/`.
3. Treat `.swarm.md` blocks as authoritative over prose summaries.
4. Use assigned obligation IDs as scope.
5. Load only the pass/profile/context files the task names.
6. Map every completion claim to evidence.
7. Promote durable discoveries before closing.

## Universal rules
- Do not implement behavior outside assigned obligations.
- Do not treat chat as higher authority than an approved spec or ADR.
- Do not close a task with unhandled promotion items.
- Do not claim completion without evidence.

## Compatibility
`.agents/` MAY hold compatibility files for agent tools.
Canonical Swarm artifacts live in `.swarm/`.

## Commands
<!-- cmd* bindings, §31.3 -->
```

The full SOL or APS manual MUST NOT be pasted into `AGENTS.md`; if a task needs the language reference, it reads `.swarm/kernel/language/SOL.md` / `APS.md` (the installed kernel, §20.5) — `AGENTS.md` carries at most a one-line pointer, never the manual. A "universal workflow rule" promotion (the §10 / §23 promotion target) resolves, per the G9 tie-break (this specification), to a **pass-guide edit plus at most a one-line pointer in `AGENTS.md`** — never an inline procedure. Rationale: ADR 0017 and the density cap reserve `AGENTS.md` for persistent *facts*; procedures live in pass guides.

### 31.3 The Commands contract

`AGENTS.md` holds the **Commands** contract: the project-level table of `cmd*` slots that `VERIFY BY` adapters resolve through (§15, ADR 0018 / its superseding ADR, this specification). A `VERIFY BY <type>:<adapter>:<artifact>` clause names a proof type and an `<adapter>`; the adapter is a `cmd*` slot defined here.

```markdown
## Commands
| Slot          | Command                  | Resolves proof types  |
| ------------- | ------------------------ | --------------------- |
| cmdTest       | `npm test`               | test                  |
| cmdLint       | `npm run lint`           | static                |
| cmdTypecheck  | `npm run typecheck`      | static                |
| cmdBenchmark  | `npm run bench`          | perf                  |
| cmdValidate   | `npm run validate`       | static (aggregate)    |
| cmdFormat     | `npm run format --check` | (format hygiene)      |
```

Normatively:

- A `VERIFY BY` adapter MUST resolve to a `cmd*` slot present in the `AGENTS.md` Commands table; an unresolved adapter is a verification-layer lint defect (`SOL-V002`, §8) and a `BLOCKED` verdict at the gate (§14).
- The Commands table is **soft control** (§17): it names what a future launcher would run; the kernel ships no runtime that executes it. `AGENTS.md` MUST NOT claim it enforces or runs these commands.
- The Commands contract is a *fact* (a binding), which is why it is one of the few procedural-adjacent things permitted in the bootloader: it is data the model and a future launcher both need, not a procedure.

A conformant repo MUST populate the Commands table for every proof type any of its `VERIFY BY` clauses reference; a missing required `cmd*` row is one of the negative conformance-fixture classes (§33).
