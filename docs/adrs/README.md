# Architecture Decision Records (Swarm kernel)

Each ADR is a dated, immutable record of one load-bearing decision — its **context**, the **decision**, and its **consequences** — so a fork can judge whether the choice still fits. The full truth of any decision is the **chain** of ADRs that touch it, not the latest one alone.

This ledger is the index. It carries a row for **every** ADR — kept, amended, already-superseded, and new — with its current disposition (§30 of the kernel spec).

## Governance (Nygard immutability, §30.1)

> An accepted ADR **MUST NOT** be edited in place. "Amending" a decision means publishing a **new, superseding ADR**; the original keeps its body and gains only a `Superseded by ADR-NNNN` status line. Rewriting an ADR destroys the historical record that makes the chain auditable.

Two consequences of that rule govern this ledger:

- **Numbers `0011` and `0012` are intentionally vacant** — vacated in an earlier consolidation and left unfilled so references to higher numbers do not shift.
- **The pre-kernel ADRs (`0001`–`0026`) are immutable history.** Their bodies still name the pre-kernel vocabulary and paths (`scaffold/`, `personas/`, the consolidated `SKILL.md`, the earlier flow-graph) **as they were decided**. Those bodies are *not* subject to the kernel's active-construct rules (the §34 / A19–A28 retirements) — those rules govern canonical/active prose, not the historical record. The **current** truth of any amended decision is its superseding `0027+` ADR; read the chain, not the earlier body in isolation.

## The ledger

| ADR | Title | Disposition |
|-----|-------|-------------|
| [0001](./0001-four-doc-types.md) | Four core document types | **Kept** — recast onto the unified artifact set by [0030](./0030-unified-artifact-set.md) |
| [0002](./0002-personas-1-to-1-with-task-types.md) | Personas pair 1:1 with task types | Superseded by [0020](./0020-activation-by-self-assessment.md), and now by the profile × pass model ([0036](./0036-heuristic-profile-model.md), §27.4) |
| [0003](./0003-distillation-is-unidirectional.md) | Distillation flows downhill only | **Kept** |
| [0004](./0004-task-files-are-gitignored.md) | Task files are gitignored | **Kept** |
| [0005](./0005-placeholder-syntax.md) | Template placeholder syntax `{{name}}` | **Kept** |
| [0006](./0006-skeptic-owns-fix-tasks.md) | Skeptic mindset on `fix` tasks | Amended → Superseded by [0036](./0036-heuristic-profile-model.md) (Skeptic is a profile on `fix`/`review` passes) |
| [0007](./0007-bug-report-as-meta-task.md) | Bug report is diagnosis-only | **Kept** — the epistemic-stance invariant of the `bug-report.md` source artifact (§29) |
| [0008](./0008-empirical-proof-as-framework-primitive.md) | Empirical proof is framework-level | **Kept** |
| [0009](./0009-personas-are-mindsets.md) | Personas are mindsets, not org roles | Amended → Superseded by [0036](./0036-heuristic-profile-model.md) (personas become heuristic profiles) |
| [0010](./0010-write-side-single-threaded.md) | Writes single-thread through orchestrator | **Kept** — preserved by the write-surface model ([0039](./0039-write-surface-model.md)) |
| *0011* | *(intentionally vacant)* | — |
| *0012* | *(intentionally vacant)* | — |
| [0013](./0013-iron-law-red-flags-pattern.md) | Iron law + red-flags persona format | Amended → Superseded by [0036](./0036-heuristic-profile-model.md) (iron law → a profile's `## Refuses` table, §27.2) |
| [0014](./0014-recursion-renamed-delegation.md) | Delegation vs internal recursion | **Kept** |
| [0015](./0015-versioning-scheme.md) | Framework versioning for consumers | **Kept, extended** by [0041](./0041-two-axis-versioning.md) — scoped to the *package* axis; the *language* axis is added alongside (§25) |
| [0016](./0016-skills-are-self-contained.md) | Skill bodies are self-contained | **Kept** — governs pass-guide bodies (§26) |
| [0017](./0017-no-always-load-skills.md) | No always-loaded skills | **Kept** — pass guides and profiles are lazily loaded (§26.4, §31) |
| [0018](./0018-agents-md-command-contract.md) | Commands resolve through the `AGENTS.md` contract | Amended → Superseded by [0038](./0038-verify-by-adapters-through-commands.md) (`VERIFY BY` adapters resolve through `AGENTS.md > Commands`) |
| [0019](./0019-personas-ship-as-individual-skills.md) | Personas ship as individual skills | Amended → Superseded by [0036](./0036-heuristic-profile-model.md) (a standalone file is *one* carrier option, §27.1) |
| [0020](./0020-activation-by-self-assessment.md) | Activation by self-assessment | Amended → Superseded by [0037](./0037-load-what-the-task-names.md) (doctrine is "load what the task names"; description-match is the fallback) |
| [0021](./0021-verification-contract.md) | Verification contract | **Kept** — a verification layer of the single SOL `VERIFY BY` model (§15) |
| [0022](./0022-acceptance-criteria-are-executable-checks.md) | Acceptance criteria are executable checks | **Kept** — a verification layer of the SOL `VERIFY BY` model (§15) |
| [0023](./0023-harness-enforcement-contract.md) | Harness-enforcement contract | **Kept** — a verification layer of the SOL `VERIFY BY` model (§15) |
| [0024](./0024-confidence-tiers.md) | Self-reviewed vs independently-reviewed confidence tiers | Amended → Superseded by [0035](./0035-seven-value-verdict-model.md) (tiers map onto the 7-value verdict taxonomy) |
| [0025](./0025-orchestration-coordination-artifact.md) | Orchestration coordination artifact | Amended → Superseded by [0039](./0039-write-surface-model.md) (owned/forbidden paths → the lowered write-surface) |
| [0026](./0026-conformance-contract.md) | Machine-readable conformance contract + fixtures | **Kept** — a verification layer of the SOL `VERIFY BY` model (§15); realized by the golden corpus ([0033](./0033-golden-corpus.md)) |
| [0027](./0027-sol-is-the-obligation-language.md) | SOL is the obligation language | **New (kernel)** — §5, §6 |
| [0028](./0028-aps-is-the-prose-standard.md) | APS is the prose standard | **New (kernel)** — §7 |
| [0029](./0029-nine-pass-compiler-model.md) | The 9-pass compiler model | **New (kernel)** — §9 |
| [0030](./0030-unified-artifact-set.md) | The unified artifact set | **New (kernel)** — §20, §29 |
| [0031](./0031-source-authority-two-axis.md) | The source-authority two-axis model | **New (kernel)** — §22 |
| [0032](./0032-memory-model.md) | The memory model | **New (kernel)** — §23 |
| [0033](./0033-golden-corpus.md) | The golden corpus | **New (kernel)** — §33 |
| [0034](./0034-unified-lint-namespace.md) | The unified `SOL-<LAYER><NNN>` lint namespace | **New (kernel)** — §8 |
| [0035](./0035-seven-value-verdict-model.md) | The 7-value verdict model | **New (kernel)** — §14; **supersedes** [0024](./0024-confidence-tiers.md) |
| [0036](./0036-heuristic-profile-model.md) | Personas become heuristic profiles | **New (kernel)** — §27; **supersedes** [0006](./0006-skeptic-owns-fix-tasks.md), [0009](./0009-personas-are-mindsets.md), [0013](./0013-iron-law-red-flags-pattern.md), [0019](./0019-personas-ship-as-individual-skills.md) |
| [0037](./0037-load-what-the-task-names.md) | Loading doctrine: load what the task names | **New (kernel)** — §26.4; **supersedes** [0020](./0020-activation-by-self-assessment.md) |
| [0038](./0038-verify-by-adapters-through-commands.md) | `VERIFY BY` adapters resolve through `AGENTS.md` Commands | **New (kernel)** — §15, §31.3; **supersedes** [0018](./0018-agents-md-command-contract.md) |
| [0039](./0039-write-surface-model.md) | The write-surface model | **New (kernel)** — §18, §19; **supersedes** [0025](./0025-orchestration-coordination-artifact.md) |
| [0040](./0040-kernel-payload-directory.md) | The kernel payload ships under `kernel/` | **New (kernel)** — §20.5, §34.0 (rename from `scaffold/`, pulled forward from the v0.2 deferral) |
| [0041](./0041-two-axis-versioning.md) | Two-axis versioning (language axis + package axis) | **New (kernel)** — §25; **extends** [0015](./0015-versioning-scheme.md) |
| [0042](./0042-skill-carrier-and-standalone-conditioning.md) | Skills carry as `SKILL.md`; conditioning ships as many standalone surgically-activated skills | **New (kernel)** — §26, §27; **refines** [0016](./0016-skills-are-self-contained.md), [0017](./0017-no-always-load-skills.md), [0019](./0019-personas-ship-as-individual-skills.md), [0029](./0029-nine-pass-compiler-model.md), [0036](./0036-heuristic-profile-model.md), [0037](./0037-load-what-the-task-names.md) |

## The new kernel ADRs (0027+), by topic

The rework introduced sixteen ADRs. The nine the spec enumerates as mandatory kernel decisions (§30.3) record decisions that must not be left implicit in prose:

| ADR | Records | Spec |
|-----|---------|------|
| [0027](./0027-sol-is-the-obligation-language.md) | SOL is the single home of obligation semantics | §5, §6 |
| [0028](./0028-aps-is-the-prose-standard.md) | APS is the controlled-prose standard around SOL | §7 |
| [0029](./0029-nine-pass-compiler-model.md) | `author → lint → improve → lower → decompose → implement → verify → review → promote` | §9 |
| [0030](./0030-unified-artifact-set.md) | the kernel artifact set incl. trace, VERDICT block, finding, memory | §20, §29 |
| [0031](./0031-source-authority-two-axis.md) | domain axis × artifact axis, lexicographic | §22 |
| [0032](./0032-memory-model.md) | two-tier, provenance-anchored promotion | §23 |
| [0033](./0033-golden-corpus.md) | positive + negative conformance fixtures over the three domains | §33 |
| [0034](./0034-unified-lint-namespace.md) | one prefix, five layers; APS violations surface under the `SOL-` prefix, not a separate `APS-` code prefix | §8 |
| [0035](./0035-seven-value-verdict-model.md) | 4 core + 3 lifecycle verdicts | §14 |

The remaining seven carry the Group-B recasts, the kernel-rename/versioning extensions, and the skill-carrier packaging refinement: [0036](./0036-heuristic-profile-model.md) (profiles, §27), [0037](./0037-load-what-the-task-names.md) (loading doctrine, §26.4), [0038](./0038-verify-by-adapters-through-commands.md) (the `VERIFY BY`/Commands binding, §15/§31.3), [0039](./0039-write-surface-model.md) (the write-surface, §18/§19), [0040](./0040-kernel-payload-directory.md) (the `kernel/` payload, §20.5/§34), [0041](./0041-two-axis-versioning.md) (two-axis versioning, §25), and [0042](./0042-skill-carrier-and-standalone-conditioning.md) (skills carry as `SKILL.md` + standalone surgically-activated conditioning, §26/§27; refines [0016](./0016-skills-are-self-contained.md), [0017](./0017-no-always-load-skills.md), [0019](./0019-personas-ship-as-individual-skills.md), [0029](./0029-nine-pass-compiler-model.md), [0036](./0036-heuristic-profile-model.md), [0037](./0037-load-what-the-task-names.md)).

A conformant repo MUST carry these ADRs (or equivalents) so the chain explains why the obligation language, prose standard, pipeline, artifact set, authority model, memory, corpus, lint namespace, and verdict set have their shape.
