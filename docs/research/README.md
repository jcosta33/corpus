# Research: the evidence behind Swarm's design

> The evidence behind Swarm's pass-guide, profile, and bootloader design. This is the **cited research layer** — the one corner of `docs/` that deliberately carries `[KEY]` citations. Every load-bearing empirical claim on these pages resolves to a verified entry in [`sources.md`](sources.md), used with its recorded caveats; everywhere else in `docs/` is self-standing prose that needs no citation to stand.

Swarm makes a handful of structural bets: a method for a pass is a [pass guide](../library/pass-guides.md) that loads only when a task names it; a cognitive stance is a [heuristic profile](../library/heuristic-profiles.md) applied over a pass; persistent project facts and commands live in an always-loaded [`AGENTS.md`](../model/source-artifacts.md) bootloader held under a hard density cap; working state lives on disk in [`task.md`](../artifacts/task.md) and the [`.swarm/` workspace](../model/workspace.md); and a completion claim is invalid unless it shows its work. This layer is where those bets are checked against the literature — not asserted, *grounded*. Each page below grounds one part of the kernel's design on evidence that survived web-verification.

---

## What the evidence does and does not support

The honest synthesis is narrow on purpose. The literature **supports** a small set of well-established directions: that deliberate plan-then-search beats flat generation ([TREEOFTHOUGHTS](sources.md#TREEOFTHOUGHTS), [PLANSOLVE](sources.md#PLANSOLVE)); that externalising intermediate work to a durable artefact improves multi-step performance ([SCRATCHPAD](sources.md#SCRATCHPAD)); that a written, re-readable reflection turns an implicit signal into a checkable one and lifts task success ([REFLEXION](sources.md#REFLEXION)); that accuracy degrades for information buried in the middle of a long context ([LOSTMID](sources.md#LOSTMID)); and that repository commands are used far more when named in the context file than when left to narrative ([AGENTSMD-HARM](sources.md#AGENTSMD-HARM)). On top of these primaries the layer leans on **official guidance** — Anthropic's skill-authoring and context-engineering docs, the Open Agent Skills spec, the `AGENTS.md` convention, and Claude Code's disk-persistent tasks ([SKILLBP](sources.md#SKILLBP), [CTXENG](sources.md#CTXENG), [SKILLSPEC](sources.md#SKILLSPEC), [AGENTSMD-CONV](sources.md#AGENTSMD-CONV), [CCTASKS](sources.md#CCTASKS)) — cited as design guidance, not measured fact. What the evidence does **not** support is a set of headline figures that circulate in the skill-authoring literature: a "21× file-state degradation," a "24–68% turn-cost" reduction, and an "agentic failures are context failures" claim were each traced to **fabricated/misattributed arXiv ids** that resolve to unrelated physics and signal-processing papers, and are recorded as **rejected** in [`sources.md`](sources.md#rejected--do-not-cite-fabricated--misattributed) so they are never silently reintroduced. Three further sources — a self-published activation measurement, a two-reliability-problems write-up, and practitioner authoring catalogues ([ACTIVATION-BLOG](sources.md#ACTIVATION-BLOG), [TWOPROBLEMS](sources.md#TWOPROBLEMS), [PRACTITIONER](sources.md#PRACTITIONER)) — are **caveated**: cited only as preliminary, non-peer-reviewed *direction*, never to ground a `MUST`. The result is a layer that grounds the kernel's structure on verified primaries and authoritative guidance, names every weaker source as weak, and grounds each claim on a verified alternative rather than a fabricated figure.

---

## The pages and the kernel decisions they ground

Each topical page grounds one kernel decision on the relevant research. The middle column is where that decision actually lives in the framework's own (self-standing) docs.

| Research page | Kernel decision it grounds | Lives in |
| --- | --- | --- |
| [Activation](activation.md) — load what the task names; description-match as fallback; the directive four-clause form as an authoring heuristic | The **loading doctrine**: a `task.md` names its pass guide(s) and profile(s) and the agent loads exactly those; self-activation is a degraded fallback | [Pass guides — the loading doctrine](../library/pass-guides.md), [`task.md`](../artifacts/task.md) |
| [The shape of a pass-guide body](body-anatomy.md) — numbered rules + one-line rationale, `## Anti-patterns`, references one hop away, modest length | The **pass-guide / profile body contract** (the ~500-line authoring ceiling, explain-the-why, the `## Refuses` table) | [Pass guides — the contract](../library/pass-guides.md), [Heuristic profiles](../library/heuristic-profiles.md) |
| [Execution drift](execution.md) — why a loaded guide's late steps get silently skipped, and the forced-visible-output fix | The **empirical-proof rule**: "tests passed" with no command/exit/output is `UNVERIFIED`, not `PASS` | [The `verify` pass](../passes/verify.md), [The `implement` pass](../passes/implement.md) |
| [Self-containment](self-containment.md) — restate inline, never link a sibling for semantics; reach commands through one indirection | The **self-contained-guide rule** and the **`VERIFY BY` → `AGENTS.md > Commands`** adapter indirection | [Pass guides](../library/pass-guides.md), [The `verify` pass](../passes/verify.md) |
| [Externalising state to files](task-files.md) — why a unit of work is a file on disk, not only context | The **`task.md` + `.swarm/` workspace** model (the `sources/ status/ generated/` split) and the `AGENTS.md` density cap | [Workspace model](../model/workspace.md), [`task.md`](../artifacts/task.md), [Source artifacts](../model/source-artifacts.md) |
| [Scope](scope.md) — the gating question, how-to-work vs what-to-run, the seven exclusions | What is admitted to the **conditioning layer** vs re-homed to overlays, `AGENTS.md`, or SOL/IR | [Pass guides](../library/pass-guides.md), [Overlays](../library/overlays.md), [Heuristic profiles](../library/heuristic-profiles.md) |

Two threads run across every page and are worth reading as a pair: the **density discipline** (the always-loaded `AGENTS.md` bootloader is capped at ≤200 lines / ≤25 KB, justified by the [LOSTMID](sources.md#LOSTMID) U-curve *traded against* the bloat-versus-gap-filling cost — never by a hard capability ceiling) and the **forced-visible-output discipline** (a completion claim must paste its evidence, grounded on [REFLEXION](sources.md#REFLEXION) and the [`verify` pass](../passes/verify.md) empirical-proof rule). The pages cross-link each other freely; that is allowed because the self-containment constraint binds *guide bodies*, not `docs/`.

---

## Why this is the one cited corner of `docs/`

Everywhere else in `docs/` is written to stand on its own: a reader should understand a pass, an artifact, or a principle without chasing a citation. This layer is the deliberate exception. It exists because some of the kernel's choices are *empirical* bets, and an empirical bet should be auditable against its evidence rather than taken on faith. So `docs/research/` carries `[KEY]` citations, and a single file governs what may be cited: [`sources.md`](sources.md) is the **only** citable bibliography for this layer. It is held to the kernel's **evidence discipline — "real science, not astrology"** ([Principles § Evidence discipline](../PRINCIPLES.md), the docs-side home of the spec's §0.7): a claim either cites a Verified entry, or carries an explicit "preliminary / non-peer-reviewed" caveat naming a Caveated entry, or it is not made. New sources are web-verified before they are added, and rejected ids are recorded so a fabrication can never re-enter silently. If a finding cannot point into `sources.md` under that discipline, it does not belong on these pages.

This is also a **markdown-only, no-runtime** layer. Every "checker", "linter", "loader", or "regenerating pass" named across these pages is a *contract a future Swarm tool would build against*, not behaviour the framework ships today ([Principles § NO RUNTIME](../PRINCIPLES.md)). The research grounds *why* the kernel is shaped the way it is; the contracts it describes are made real elsewhere.

---

## See also

- [Sources](sources.md) — the verified / caveated / rejected bibliography every citation on these pages resolves to, and the discipline that governs it.
- [Principles](../PRINCIPLES.md) — the evidence discipline (§0.7's docs home), the NO RUNTIME invariant, and the density-cap rationale this layer is held to.
- [Pass guides](../library/pass-guides.md) and [Heuristic profiles](../library/heuristic-profiles.md) — the conditioning-layer contracts most of these pages ground.
- [The `verify` pass](../passes/verify.md) — the empirical-proof / forced-visible-output rule the execution and self-containment pages rest on.
- [Workspace model](../model/workspace.md) and [`task.md`](../artifacts/task.md) — the on-disk state surfaces the task-files page grounds.
