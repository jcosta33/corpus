# Pass guides

> Swarm's reference for **pass guides**: the reusable, lazily-loaded procedural modules that document *how* to run a named pass — never *what the language means* — together with how procedural modules map onto the nine passes, the loading doctrine, the cross-cutting fragments, and the pass-guide contract.

A **pass guide** is a procedural module that documents how to perform one of the **nine passes** of the Swarm compiler pipeline (`author -> lint -> improve -> lower -> decompose -> implement -> verify -> review -> promote`) — and nothing more. It is a reusable *method* an agent loads when a task names it: the prose recipe for executing a pass well, the questions to ask, the order to work in, the evidence to gather. It is **SOFT control** (Invariant 2): it influences how an agent works but binds nothing the kernel marks authoritative. Where a guide and the language reference disagree, the language reference governs.

Like everything in Swarm, a pass guide has **no runtime**: it is text a human, an agent, or a future harness reads. Loading a guide changes how work gets done; it never executes anything and never enforces anything.

## The one rule a pass guide must never break

> **The semantic-ownership prohibition.** No pass guide may define, redefine, or be required to interpret SOL or APS semantics. All load-bearing meaning lives in SOL and the typed IR; a pass guide is a procedure, not a semantic home.

This is the load-bearing constraint of the whole pass-guide layer. A pass guide MUST NOT define a block type, a modal, a clause keyword, a verdict value, a proof type, a lint code, or any IR field. Those live exclusively in the language reference. A guide MAY cite, link to, or quote that reference, but the citation is **non-authoritative delivery** — the authoritative text is the reference itself.

The reason is adherence: meaning that lived in a lazily-loaded, optional guide would make the meaning of a spec depend on whether that guide happened to load. So a correctly written `*.swarm.md` file MUST be understandable to a strong model **without any guide loaded**, because it uses the controlled obligation language and stable formal blocks. The guide tells you how to *work*; the spec already tells you what the work *means*.

A conformant repo confirms, by regression check, that no pass guide, profile, fragment, or `AGENTS.md` section defines modality, authority order, or verification semantics.

## How procedural modules map onto the nine passes

The pass-guide layer organizes the framework's procedural modules — each a self-contained recipe a model loads to do a unit of work [[SKILLBP]](../research/sources.md#SKILLBP) — under a discipline that keeps any one module from quietly owning semantics. Every procedural module is exactly one of three things: a **pass guide** (one per pass), a **cross-cutting fragment** (shared procedure), or a **profile** (a cognitive stance, documented separately).

The mapping is **many-modules-to-one-pass**: a single pass MAY carry more than one guide. The `implement` pass, for instance, carries one guide per implementation kind.

| Procedural module | Role | Owning pass |
|---|---|---|
| `write-spec` | author guide | `author` (spec) |
| `write-research` | author guide | `author` (research) |
| `write-audit` | author guide | `author` (audit) |
| `write-bug-report` | author guide | `author` (bug-report) |
| `write-prd` | author guide | `author` (prd) |
| `write-rfc` | author guide | `author` (rfc) |
| `write-feature` | implement guide | `implement` |
| `write-fix` | implement guide | `implement` |
| `write-refactor` | implement guide | `implement` |
| `write-rewrite` | implement guide | `implement` |
| `write-migration` | implement guide | `implement` |
| `write-performance` | implement guide | `implement` |
| `write-testing` | implement guide | `implement` |
| `write-documentation` | implement guide | `implement` |
| `fix-flaky-test` | narrow implement guide | `implement` |
| `adversarial-review` | the Skeptic profile over `review` — not a standalone module | `review` |
| `empirical-proof` | cross-cutting fragment | shared (behind `verify` / `review`) |
| `distillation-discipline` | cross-cutting fragment | shared (behind `lower` / `decompose` / `promote`) |
| `persona-architect` | a profile | `author` (spec) |
| `persona-auditor` | a profile | `author` (audit) |
| `persona-janitor` | a profile | `implement` |
| `persona-migrator` | a profile | `implement` |
| `persona-performance-surgeon` | a profile | `implement` |
| `persona-skeptic` | a profile | `review` / `verify` |
| `persona-surveyor` | a profile | `author` (research) |
| `persona-lead-engineer` | a profile | `decompose` / merge-gate |

Three rows are normative and worth calling out:

- **`adversarial-review` is the Skeptic profile over `review`.** It is **not** a standalone procedural module. Its adversarial method is the **Skeptic profile** applied to the `review` (and `verify`) passes, because skepticism is a *parameter to a pass*, not a separate pass of its own.
- **`fix-flaky-test` is a narrow `implement` guide.** Its procedure is specific enough (de-flaking a non-deterministic test) to stand as its own guide rather than collapse into the general fix guide.
- **The thirteen `persona-*` modules are profiles.** A profile is a heuristic stance — what an agent looks for and refuses — not a procedure module. All thirteen ship as standalone `persona-*/SKILL.md` files; they are catalogued on their own page, and this page covers the procedure layer.

### What ships in v0.1

The pass-guide set spans all nine passes as a *contract*, and v0.1 ships a full procedural set: **four pass guides**, **nine per-kind `implement` guides**, **six author guides**, and **two cross-cutting fragments** — twenty-one procedural modules in all. Mapped onto the nine passes: `author` is served by the six author guides (`write-spec`, `write-audit`, `write-research`, `write-bug-report`, `write-prd`, `write-rfc`); `lint`, `decompose`, `review`, and `promote` each have a dedicated pass guide; `implement` is served by the nine per-kind guides; `verify` is served by the `empirical-proof` fragment; and `improve` and `lower` ship **no guide** (they are contract-only). A guide-less pass is **not** a conformance gap: the pass contract is the binding artifact, and the guide is an optional aid to performing it. The thirteen `persona-*` profiles ship alongside these modules but are catalogued on [heuristic profiles](heuristic-profiles.md), not here.

The `lint` and `decompose` guides have no antecedent in the mapping table above: that table populates guides only on `author` and `implement`, and the single module touching `decompose` is the Lead Engineer *profile*, not a guide.

## The two cross-cutting fragments

Two procedural disciplines apply across multiple passes, so they ship as **fragments** rather than as guides bound to a single pass. A fragment has the same shape as a pass guide (the contract below) but is **named by another guide** rather than by a task's `task_kind` — a guide composes it the way a function calls a helper.

| Fragment | Discipline it carries | Passes that compose it |
|---|---|---|
| `empirical-proof` | the proof / `VERIFY BY` discipline — every completion claim maps to an independent, re-runnable proof; "tests passed" with no pasted output is not a proof [[REFLEXION]](../research/sources.md#REFLEXION) | `verify`, `review` |
| `distillation-discipline` | the loss-budget discipline — what MUST be preserved and what MAY be dropped when meaning crosses an artifact boundary | `lower`, `decompose`, `promote` |

Neither fragment defines semantics. `empirical-proof` does not define the proof taxonomy or the verdict model — it carries the *procedure* for applying the proof discipline the language reference owns. `distillation-discipline` does not define the loss-budget table — it carries the *procedure* for distilling accountably (making each boundary crossing's loss visible, via a `Preserved / Dropped / Still-uncertain` statement) against the budget the reference owns.

## The loading doctrine: load what the task names

> **Load the pass guide(s) and profile(s) that the task file names.** Description-matching is the launcher-less fallback, not the primary mechanism.

A pass guide is **lazily loaded** — never always-on. The canonical way it activates is by being **named in the task** that frames the pass:

- A `task.md` SHOULD name, in its frontmatter or assignment block, the pass guide(s) and profile(s) it activates for the pass it frames. When named, the agent **MUST load exactly those, and SHOULD NOT load others** — because always-on density harms adherence and cost [[LOSTMID]](../research/sources.md#LOSTMID).
- When no launcher and no explicit naming is present, an agent MAY fall back to matching a guide's self-activating `description` field against the task. This is a **degraded mode**, retained for the launcher-less case (a task dropped into an arbitrary agent CLI with no router) — not the contract.
- A pass guide MUST NOT be always-loaded. There is no standing gatekeeper that pre-loads guides; that would itself be an always-loaded skill (forbidden) and would not be guaranteed present on a consumer's machine.

The recommended primary path — naming the guides in the task — looks like this:

```text
task.md frontmatter:
  task_kind: fix
  pass: implement
  pass_guides: [write-fix, fix-flaky-test]
  profiles: [skeptic]
```

The agent loads `write-fix`, `fix-flaky-test`, and the Skeptic profile for this `implement` pass, and **nothing else**. Routing (which conditioning loads) stays **orthogonal** to verification (what proof a task must carry once active): they are independent axes, and naming a guide neither adds nor relaxes any obligation.

## The pass-guide contract

Every pass guide declares the following sections. A conformant guide satisfies this contract:

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

Guide bodies are **self-contained**: a reader following one guide should not have to hop across a chain of other guides to perform the pass. A guide MAY *depend on* — cite, link, or quote — the shared language definitions, artifact contracts, and pass contracts upstream of it. What it MUST NOT do:

- **MUST NOT introduce a circular dependency.** Dependency direction is one-way and acyclic:

  ```text
  language definitions -> artifact contracts -> pass contracts -> pass guides -> heuristic profiles -> project overlays
  ```

  A guide depends only on nodes to its left; nothing to its left depends on a guide.
- **MUST NOT be required to interpret SOL.** A correctly authored spec is readable without the guide; the guide only says how to run the pass over it.
- **MUST NOT override an approved obligation.** A guide is procedure; it cannot weaken, waive, strengthen, or reinterpret an obligation the spec already approved. Waiver authority is a human or the spec owner — never a guide.
- **MUST NOT be always-loaded.** It is lazily loaded by name, per the doctrine above.

## Authoring a pass guide

The contract above says *which sections* a guide declares. This section is the authoring heuristic: how to write the `description` line and shape the body so the guide both loads when the task names it and fires once loaded.

### The directive `description` (for the fallback path)

Recall the loading doctrine: the primary path is **load what the task names**, and description-matching is the launcher-less fallback. When the task does the naming, the `description` is never consulted — but a guide can be dropped into an arbitrary agent CLI with no router, and in that degraded mode the `description` is the only thing the agent scans to decide whether to load the guide. So author it well: write it in the **directive four-clause form**, in order.

```text
<WHAT verb> <object>.
ALWAYS apply when <trigger 1>, <trigger 2>, or <trigger 3> — even if <implicit signal>.
Do not <forbidden default behaviour> directly.
Skip for <out-of-scope task_kind 1> or <out-of-scope task_kind 2>.
```

- **WHAT verb + object** — name the action concretely so the agent can pattern-match the task against it.
- **ALWAYS apply when …** — force unconditional activation; the *"even if …"* qualifier catches implicit triggers the task didn't state literally.
- **Do not … directly** — block the bypass: the path the agent takes when it decides *not* to load the guide.
- **Skip for …** — name the *task kinds* this guide is not for, never a sibling guide's name. Naming task kinds keeps the fallback working even when a consumer vendored only this guide and not its neighbour, and it prevents directive saturation when several guides overlap on a trigger.

The directive form is an authoring heuristic for this fallback path, not an obligation: when the task names the guide, naming wins and the `description` is bypassed. The third-person, concrete `description` form follows the official skill-authoring guidance [[SKILLBP]](../research/sources.md#SKILLBP) and the Open Agent Skills `description` field [[SKILLSPEC]](../research/sources.md#SKILLSPEC). The directional, preliminary evidence that directive descriptions activate more reliably than passive *"Use when …"* phrasings is recorded under [[ACTIVATION-BLOG]](../research/sources.md#ACTIVATION-BLOG) (non-peer-reviewed; preliminary).

### The body skeleton

A guide body satisfies the contract sections, and within them follows a stable shape so the rules actually fire once the guide loads:

- **Numbered rules, each with a one-line rationale** — `1. <Rule>` … `N. <Rule>`, every rule paired with one or two sentences of *why*. The rationale is the "explain-the-why" discipline [[SKILLBP]](../research/sources.md#SKILLBP): a bare imperative works only for the cases the author imagined, while the rationale lets the agent extend the rule to a case the author never anticipated.
- **An `## Anti-patterns` section** — concrete failure modes with their corrections, not just rules. Without negative examples the agent has no prior for the edge cases that miss the happy path, and it tends to invent a fix that is often wrong.
- **References exactly one hop away** — material the guide cites sits one level deep; a referenced file does not itself link to another referenced file. This is progressive disclosure: cheap metadata is always present, the body loads when the pass is engaged, and deeper material loads only when the procedure reaches for it [[SKILLSPEC]](../research/sources.md#SKILLSPEC). Chained references get partial-read and silently dropped [[SKILLBP]](../research/sources.md#SKILLBP), so the hop limit is structural, not stylistic.
- **A target length aligned to the density cap** — keep the body under the ~500-line authoring ceiling [[SKILLBP]](../research/sources.md#SKILLBP) and well under the length the AGENTS.md bootloader's density cap allows, so that nothing load-bearing sits in the low-attention middle of a long context [[LOSTMID]](../research/sources.md#LOSTMID). These are two budgets for two surfaces: the ~500-line ceiling governs a *lazily-loaded* guide (paid only when a task names it), while the bootloader's cap governs the *always-on* `AGENTS.md` (paid every turn) — size each to its own surface, never the other's. When a body grows past the practical target, the question is "what moves one hop out to a referenced file?", not "can the body be longer?".

## The installed guides

The four pass guides, the nine per-kind `implement` guides, the six author guides, and the two cross-cutting fragments ship under `kernel/.agents/skills/`. Each is a self-contained `SKILL.md` carrying the contract above, plus a self-activating `description` for the launcher-less fallback. (The thirteen `persona-*/SKILL.md` profiles ship under the same path; they are catalogued on [heuristic profiles](heuristic-profiles.md).)

| Installed module | Role | Pass |
|---|---|---|
| `kernel/.agents/skills/pass-lint-spec/` | pass guide | `lint` |
| `kernel/.agents/skills/pass-decompose-spec/` | pass guide | `decompose` |
| `kernel/.agents/skills/pass-review-trace/` | pass guide (carries the Skeptic profile) | `review` |
| `kernel/.agents/skills/pass-promote-findings/` | pass guide | `promote` |
| `kernel/.agents/skills/write-feature/` | per-kind `implement` guide | `implement` |
| `kernel/.agents/skills/write-fix/` | per-kind `implement` guide | `implement` |
| `kernel/.agents/skills/write-refactor/` | per-kind `implement` guide | `implement` |
| `kernel/.agents/skills/write-rewrite/` | per-kind `implement` guide | `implement` |
| `kernel/.agents/skills/write-migration/` | per-kind `implement` guide (covers migration + upgrade) | `implement` |
| `kernel/.agents/skills/write-performance/` | per-kind `implement` guide | `implement` |
| `kernel/.agents/skills/write-testing/` | per-kind `implement` guide | `implement` |
| `kernel/.agents/skills/write-documentation/` | per-kind `implement` guide | `implement` |
| `kernel/.agents/skills/fix-flaky-test/` | narrow `implement` guide (loaded under `task_kind: fix`) | `implement` |
| `kernel/.agents/skills/write-spec/` | author guide | `author` |
| `kernel/.agents/skills/write-audit/` | author guide | `author` |
| `kernel/.agents/skills/write-research/` | author guide | `author` |
| `kernel/.agents/skills/write-bug-report/` | author guide | `author` |
| `kernel/.agents/skills/write-prd/` | author guide | `author` |
| `kernel/.agents/skills/write-rfc/` | author guide | `author` |
| `kernel/.agents/skills/empirical-proof/` | cross-cutting fragment | `verify`, `review` |
| `kernel/.agents/skills/distillation-discipline/` | cross-cutting fragment | `lower`, `decompose`, `promote` |

These directories sit under a `skills/` path for cross-tool compatibility; in kernel vocabulary they are pass guides, per-kind implement guides, author guides, and fragments. The two guide-less passes (`improve`, `lower`) ship no module here — their pass contracts stand on their own.

## Related

- [The compiler pipeline](../model/compiler-pipeline.md) — the nine passes and seven phases a guide runs against, and the per-pass guide/fragment packaging (ADR-0042).
- [The `lint` pass](../passes/lint.md), [the `decompose` pass](../passes/decompose.md), [the `implement` pass](../passes/implement.md), [the `review` pass](../passes/review.md), and [the `promote` pass](../passes/promote.md) — the contracts the dedicated pass guides and the per-`task_kind` implement guides perform.
- [The `verify` pass](../passes/verify.md) — the proof model and verdict vocabulary the `empirical-proof` fragment applies but never defines.
- [The `task.md` artifact](../artifacts/task.md) — where a task names the pass guides and profiles to load.
- [SOL](../language/SOL.md) and [the errors reference](../language/errors.md) — the authoritative homes of the meaning a pass guide MUST NOT own.
- [The distillation loss budget](../reference/distillation-loss-budget.md) — the budget the `distillation-discipline` fragment applies across boundary-crossing passes.
- [The glossary](../reference/glossary.md) — canonical definitions of *pass guide*, *profile*, *pass*, and *phase*.
