# The shape of a pass-guide body

> Why a pass-guide body uses **numbered rules each paired with a one-line rationale**, ships a `## Anti-patterns` section, keeps its referenced material **one hop away**, and lands at a **modest target length**. This is an evidence-grounded note in Swarm's research layer: it carries `[KEY]` citations to [`sources.md`](sources.md), unlike the rest of `docs/`, which is self-standing.

A [pass guide](../library/pass-guides.md) loading is necessary but not sufficient. A guide that is read but not *acted on* fails as quietly as one that never loads. The body's shape is what decides whether its procedure actually fires while an agent runs a pass — and the same shape governs a [heuristic profile](../library/heuristic-profiles.md), whose seven-section contract is a stricter instance of the same discipline. This page is about that shape.

A pass-guide body is markdown a human or an agent reads. **There is no runtime here**: every "limit", "cap", and "check" below is a *contract* a future toolchain would build against, not behaviour Swarm ships. The body shapes how work gets done; it never enforces anything.

---

## 1. Target a modest length; keep the body short by moving, not stretching

**Rationale.** Long bodies bury their middle. *Lost in the Middle* documents a U-shaped attention curve: a model recovers information at the start and end of a long context reliably, and degrades on information in the middle ([LOSTMID](sources.md#LOSTMID)). A rule stranded in the middle of a sprawling body is read but not consistently applied — the same failure as a rule that never loaded.

Two length numbers apply, and they govern **different surfaces** — do not conflate them:

| Surface | Number | Where it comes from |
|---|---|---|
| A **pass-guide / profile body** | **~500-line cap** | Official skill-authoring guidance ([SKILLBP](sources.md#SKILLBP)) — design guidance, not a measured threshold. |
| The **`AGENTS.md` bootloader** | **≤200 lines / ≤25 KB** density cap | The always-loaded entry point's budget — see [source artifacts](../model/source-artifacts.md) and [the loading doctrine](../library/pass-guides.md#the-loading-doctrine-load-what-the-task-names). |

The ~500-line figure is an authoring ceiling for a *lazily-loaded* guide; the ≤200-line / ≤25 KB cap is the budget for the *always-loaded* `AGENTS.md`, which every agent in the repo carries on every task. They are different because their costs are different: a guide is paid for only when a task names it, whereas every line in `AGENTS.md` is paid for always.

> **The durable rationale for the `AGENTS.md` cap is the bloat-versus-gap-filling tradeoff, not a capability ceiling.** Always-on context competes for the model's attention against the task itself ([LOSTMID](sources.md#LOSTMID)); a leaner bootloader leaves more of that attention for the work. This is why `AGENTS.md` carries persistent *facts* and the `## Commands` contract, while *procedures* live in pass guides that load on demand — the framework's split between what is always-on and what is paid-for-on-use (see [the `promote` pass](../passes/promote.md), which forbids inlining a procedure into the bootloader). We do **not** claim a hard "capability falls off a cliff past N lines" threshold; the claim is the cheaper, well-supported one: minimise what is always resident so the U-curve works for you, not against you.

**Applied in Swarm.** A short body is not achieved by deleting rules; it is achieved by **moving** them. When a guide grows, the next question is "what should the guide *cite* instead of restate?" — pushing definitional weight back onto the artifact and language references the guide depends on, never duplicating them. A profile, capped tighter by its seven-section contract, is the limit case of the same move.

---

## 2. Each rule carries a one-line rationale (explain-the-why)

**Rationale.** A bare imperative covers only the cases its author imagined; the *why* is what lets a model extend the rule to a case the author did not anticipate. Official guidance pairs each rule with a brief rationale for exactly this reason and flags bare ALL-CAPS `MUST`/`NEVER` blocks, on their own, as a yellow signal ([SKILLBP](sources.md#SKILLBP)). The deliberative gain is real: structured, reasoned guidance outperforms flat directives on multi-step tasks ([PLANSOLVE](sources.md#PLANSOLVE), [TREEOFTHOUGHTS](sources.md#TREEOFTHOUGHTS) — Tree-of-Thoughts lifts Game-of-24 solve rate from 4% to 74% by reasoning over a plan rather than emitting a flat answer).

**Applied in Swarm.** A pass-guide `## Procedure` numbers its steps, and each load-bearing step states the failure mode it prevents. A bare imperative with no rationale is the prose equivalent of a magic constant: it works for the cases the author pictured and breaks on the next one. (Practitioner authoring catalogues name this the "explain-the-why" pattern — see [PRACTITIONER](sources.md#PRACTITIONER); *preliminary, non-peer-reviewed*, cited only as an authoring heuristic.)

---

## 3. Ship an `## Anti-patterns` section, not just rules

**Rationale.** Positive rules describe the happy path; without named negatives an agent has no prior for the edge cases that do not fit it, so it invents a fix — often the wrong one. A profile makes this structural: its `## Refuses` red-flag table is an *enumerated* refusal set, each row a concrete trap paired with the action the stance takes, precisely so a reader can audit what the stance will and will not let through (see [heuristic profiles](../library/heuristic-profiles.md#the-refuses-red-flag-table)). Documenting failure modes seen in real runs is repeatedly called out as load-bearing content in practitioner catalogues ([PRACTITIONER](sources.md#PRACTITIONER); *preliminary, non-peer-reviewed* — used here only to name the pattern, never to ground a quantitative claim).

**Applied in Swarm.** Every pass guide names the anti-patterns its pass invites; a profile renders the same content as its `## Refuses` table. The negative space — naming what does *not* belong in this guide and where it lives instead — is the counterpart move that keeps the body from absorbing adjacent material.

---

## 4. Keep referenced material exactly one hop away

**Rationale.** Progressive disclosure is the loading model: metadata is cheap and always present, the body loads when the pass is engaged, and deeper material loads only when the procedure reaches for it ([SKILLSPEC](sources.md#SKILLSPEC), [CTXENG](sources.md#CTXENG)). Official guidance warns against *deeply nested* references: when a file points at another file that points at a third, an agent tends to partial-read and miss content, so referenced material should sit one hop from the body ([SKILLBP](sources.md#SKILLBP)). Reference depth turns into partial reads, which turn into silent omissions in the pass's behaviour.

**Applied in Swarm.** A pass-guide body is **self-contained**: a reader following one guide should not have to chase a chain of other guides to perform the pass ([pass guides](../library/pass-guides.md#the-pass-guide-contract)). A guide MAY depend on — cite or quote — the language definitions, artifact contracts, and pass contracts upstream of it, in the one-way, acyclic direction the contract fixes; it MUST NOT introduce a circular hop or require the reader to interpret meaning that lives upstream.

---

## 5. State lives in `task.md` and the `.swarm/` workspace, not inlined in the body

**Rationale.** Externalising intermediate work to a durable scratchpad improves multi-step performance ([SCRATCHPAD](sources.md#SCRATCHPAD)) and is the basis for the three-file note-taking pattern in official context-engineering guidance ([CTXENG](sources.md#CTXENG)) and for disk-persistent, dependency-aware task tracking at vendor scale ([CCTASKS](sources.md#CCTASKS)). The body of a guide is the reusable *method*; the per-run working state is a separate object with its own lifecycle.

**Applied in Swarm.** Working state is not carried in the guide body. A task names the guides and profiles it loads in [`task.md`](../artifacts/task.md), and per-run state lives in the [`.swarm/` workspace](../model/workspace.md) — `sources/` for desired truth, `status/` for observed satisfaction and drift, `generated/` for the recreatable execution packets. A guide body that tried to carry run state would both bloat (fighting rule 1) and duplicate the workspace contract.

> In the kernel the working state is the workspace itself, not a per-guide template; the guide body stays a pure method.

---

## Anti-patterns

Concrete failure modes in pass-guide bodies, each with its correction.

- ❌ **Raising the length cap to fit more rules.** → Move definitional weight to the references the guide cites; a longer body buries its own middle ([LOSTMID](sources.md#LOSTMID)).
- ❌ **Treating the ~500-line guide cap and the ≤200-line `AGENTS.md` cap as one number.** → They govern different surfaces (paid-on-use vs always-on). Sizing a lazily-loaded guide to the bootloader's budget over-constrains it; sizing the bootloader to the guide's ceiling violates the density cap.
- ❌ **Inlining a multi-step procedure into `AGENTS.md`.** → `AGENTS.md` carries persistent facts plus the `## Commands` contract; the procedure belongs in a pass guide ([promote](../passes/promote.md#g9--universal-workflow-rule-promotions-never-inline-procedure)).
- ❌ **Bare `MUST`/`NEVER` imperatives with no rationale.** → Pair each rule with the failure mode it prevents, so the model can extend it to an unanticipated case ([SKILLBP](sources.md#SKILLBP)).
- ❌ **Rules only, no `## Anti-patterns` / `## Refuses`.** → Name the negatives; without them the agent improvises on the edge cases.
- ❌ **Chained references (`references/a.md` → `references/b.md`).** → Keep referenced material one hop from the body to avoid partial reads ([SKILLBP](sources.md#SKILLBP)).
- ❌ **Defining a block type, modal, verdict, or lint code inside the body.** → That meaning lives in the language reference; a guide cites it, never mints it ([pass guides](../library/pass-guides.md#the-one-rule-a-pass-guide-must-never-break)).
- ❌ **Carrying per-run state in the body.** → State lives in [`task.md`](../artifacts/task.md) and the [`.swarm/` workspace](../model/workspace.md).
- ❌ **"Tests passed" with no command, exit code, or pasted output.** → The empirical-proof discipline rejects a completion claim with no forced-visible output as `UNVERIFIED` ([verify](../passes/verify.md), [REFLEXION](sources.md#REFLEXION) — a written, checkable artefact converts an implicit signal into a durable one).

---

## What a well-shaped body looks like

The [pass-guide contract](../library/pass-guides.md#the-pass-guide-contract) fixes the section skeleton. The rules above describe how to fill it:

```markdown
# Pass guide: <name>

## Purpose          # the failure mode this guide exists to prevent
## Consumes
## Produces
## Preserves
## Rejects
## Procedure         # numbered steps; each load-bearing step states its why (rule 2)
1.
2.
## Output contract
## Self-review delta
```

A profile fills the stricter [seven-section contract](../library/heuristic-profiles.md#the-profile-contract), with its `## Refuses` table doing the anti-patterns work (rule 3). Both stay short by citing upstream rather than restating it (rule 1), keep referenced material one hop away (rule 4), and leave run state to the workspace (rule 5).

---

## See also

- [Sources](sources.md) — the bibliography every citation on this page resolves against.
- [Pass guides](../library/pass-guides.md) — the procedural-module contract this body shape fills, and the loading doctrine that activates it.
- [Heuristic profiles](../library/heuristic-profiles.md) — the stricter seven-section sibling, where `## Refuses` carries the anti-patterns.
- [Source artifacts](../model/source-artifacts.md) — the `AGENTS.md` bootloader and its ≤200-line / ≤25 KB density cap.
- [The workspace](../model/workspace.md) — where per-run state lives instead of in the body.
- [The `verify` pass](../passes/verify.md) and [the `promote` pass](../passes/promote.md) — the empirical-proof rule and the no-inline-procedure rule the anti-patterns reference.
