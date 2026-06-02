# Architecture Decision Records (framework)

Lightweight decisions behind Swarm's load-bearing conventions. Each ADR captures **context**, **decision**, and **consequences** so forks can judge whether the choice still fits.

Older exploratory specs (merged into `/docs`) referred to decisions by number; those references resolve here.

Numbers **0011 and 0012 are intentionally vacant** — they were vacated during an earlier consolidation and are left unfilled for historical continuity, so existing references to higher numbers don't shift.

| ADR | Title |
|-----|-------|
| [0001](./0001-four-doc-types.md) | Four core document types |
| [0002](./0002-personas-1-to-1-with-task-types.md) | Personas pair 1:1 with task types — **Superseded by [0020](./0020-activation-by-self-assessment.md)** |
| [0003](./0003-distillation-is-unidirectional.md) | Distillation flows downhill only |
| [0004](./0004-task-files-are-gitignored.md) | Task files are gitignored |
| [0005](./0005-placeholder-syntax.md) | Template placeholder syntax `{{name}}` |
| [0006](./0006-skeptic-owns-fix-tasks.md) | Skeptic mindset on `fix` tasks |
| [0007](./0007-bug-report-as-meta-task.md) | Bug report is diagnosis-only |
| [0008](./0008-empirical-proof-as-framework-primitive.md) | Empirical proof is framework-level |
| [0009](./0009-personas-are-mindsets.md) | Personas are mindsets, not org roles |
| [0010](./0010-write-side-single-threaded.md) | Writes single-thread through orchestrator |
| [0013](./0013-iron-law-red-flags-pattern.md) | Persona profiles use iron law + red flags |
| [0014](./0014-recursion-renamed-delegation.md) | User-facing "delegation" vs internal recursion |
| [0015](./0015-versioning-scheme.md) | Framework versioning for consumers |
| [0016](./0016-skills-are-self-contained.md) | Skill bodies are self-contained |
| [0017](./0017-no-always-load-skills.md) | No always-loaded skills |
| [0018](./0018-agents-md-command-contract.md) | Commands resolve through the `AGENTS.md` contract |
| [0019](./0019-personas-ship-as-individual-skills.md) | Personas ship as individual skills |
| [0020](./0020-activation-by-self-assessment.md) | Activation by self-assessment |
| [0021](./0021-verification-contract.md) | Verification contract — required validations bind through `AGENTS.md > Commands` |
| [0022](./0022-acceptance-criteria-are-executable-checks.md) | Acceptance criteria are expressible as runnable checks |
| [0023](./0023-harness-enforcement-contract.md) | Harness-enforcement contract (what a compliant runtime must honour) |
| [0024](./0024-confidence-tiers.md) | Self-reviewed vs independently-reviewed confidence tiers |
| [0025](./0025-orchestration-coordination-artifact.md) | Orchestration coordination artifact (ownership / hand-off / liveness / merge-intent) |
| [0026](./0026-conformance-contract.md) | Machine-readable conformance contract + fixtures |
