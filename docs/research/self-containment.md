# Self-containment of pass guides

> A reader following one pass guide should be able to perform its pass without hopping to a sibling guide for what a word means or what discipline applies. A guide restates inline what it needs, and reaches a project's concrete commands through one portable indirection — the `AGENTS.md > Commands` table — rather than through a link to another guide. This is the research grounding for the kernel's self-contained-guide rule and its no-cross-guide-semantics prohibition.

This page is part of the **cited research layer**. Load-bearing empirical claims here cite a verified entry in [sources.md](sources.md); the design decisions they ground live in the framework's own docs (linked throughout). It grounds the kernel's self-containment rule on the skill-authoring evidence, in the kernel's own vocabulary — pass guides and heuristic profiles.

---

## The portability pressure

A **pass guide** is a reusable, lazily-loaded procedural module for one of the nine passes (`author -> lint -> improve -> lower -> decompose -> implement -> verify -> review -> promote`). It is vendored selectively: a consuming project copies the subset of guides its work needs and leaves the rest. A **heuristic profile** is an optional cognitive stance applied over a pass; it ships the same way.

The structural consequence drives everything below: **a guide cannot assume any sibling guide or profile is present in context.** If a guide *expected* the proof discipline carried by the `empirical-proof` fragment, that discipline would have to be either restated where the guide needs it, or re-derivable from the guide alone. A guide body that links a sibling assumes a layout the consumer may not have reproduced.

The official Open Agent Skills specification models exactly this independent-loading shape — metadata-first, body loaded on match, references scoped to the unit — so a guide is consumed as a complete unit at load time, not as one node in an assumed dependency graph ([SKILLSPEC](sources.md#SKILLSPEC)). The framework adopts that property as a hard rule for its procedural layer.

---

## Rule 1 — restate inline, never link a sibling for semantics

The kernel fixes this as the **self-contained-guide rule** ([ADR-0016](../adrs/0016-skills-are-self-contained.md)): a guide body carries no cross-guide "See also" links and no framework-internal paths. Anything a sibling guide would have supplied is **restated inline**, usually as one or two sentences in the prose that needs it.

The failure mode this avoids is the *Reference Illusion* — a guide pointing at a file or sibling that is not guaranteed to exist on the consumer's machine, leaving a dead reference that silently degrades behaviour rather than failing loudly. The agent reads an instruction aimed at something that is not there and quietly does less. An inline one-sentence restatement has no such failure mode: it is always present because it is in the file the agent is already reading.

This rule binds the **guide body** only. Documentation under `docs/` — including this research layer — cross-links freely; self-containment is a guide-portability constraint, not a docs constraint. That is why this page may link a dozen siblings while the guide it describes may link none.

### The no-cross-guide-semantics prohibition

There is a second, sharper rule layered on the first: a guide MUST NOT define, redefine, or be required to interpret what the language means. All load-bearing meaning — block types, modals, verdict values, proof types, lint codes, IR fields — lives in the SOL/APS language reference and the typed IR, never in a guide. A guide is a *procedure*, not a semantic home. (The procedural-layer contract, the one-way dependency direction, and the mapping of the guide set onto the nine passes are specified in [the pass-guides reference](../library/pass-guides.md).)

The reason is adherence. Meaning that lived in a lazily-loaded, optional guide would make the meaning of a spec depend on whether that guide happened to load — so a correctly authored `*.swarm.md` file must be understandable to a strong model with **no guide loaded at all**. Self-containment of the guide and self-standing-ness of the spec are two sides of the same constraint: the guide cannot reach into a sibling for semantics, and the spec does not need the guide for semantics either.

---

## Rule 2 — reach project commands through `AGENTS.md > Commands`

Guides are stack-agnostic; the consuming repo holds the project-specific values. Hardcoding `pnpm tsc --noEmit && pnpm lint` into a guide couples it to one stack and breaks every other consumer. The portable indirection is the **`AGENTS.md > Commands` contract**.

`AGENTS.md` is the always-loaded **bootloader** — persistent facts and pointers, hard-capped at ≤200 lines / ≤25 KB — that carries a `## Commands` table mapping contract names to project commands and to `{{cmd*}}` placeholder slots ([the workspace model](../model/workspace.md), [the glossary](../reference/glossary.md)). In the kernel, the thing that resolves through that table is the proof binding: a `VERIFY BY <type>:<adapter>:<artifact>` clause's `<adapter>` segment resolves to a `cmd*` slot in the consuming repo's Commands table ([ADR-0038](../adrs/0038-verify-by-adapters-through-commands.md), superseding the earlier skill-prose framing of [ADR-0018](../adrs/0018-agents-md-command-contract.md)). The obligation stays portable; only the Commands table changes when a spec moves between repos. An adapter with no matching row reads as `BLOCKED` (`SOL-V002`), an honest "could not run" — never a silently-assumed pass.

The empirical case for naming commands in the context file is direct. Evaluations of `AGENTS.md` find that repository-specific commands are used **far more often when named in the context file than when not** — and, from the efficiency companion, that LLM-*generated* narrative context can cost more than it returns ([AGENTSMD-HARM](sources.md#AGENTSMD-HARM)). Two design instructions follow, both of which the contract honours: **name the commands**, and **minimise narrative**. The cross-tool `AGENTS.md` convention — adopted across agent CLIs — is the basis the contract extends ([AGENTSMD-CONV](sources.md#AGENTSMD-CONV)).

The independent-loading and progressive-disclosure shape that makes this indirection portable in the first place is the official skill model: a unit declares its description and surface, and resolves project specifics through a named entry rather than an inlined command ([SKILLSPEC](sources.md#SKILLSPEC), [SKILLBP](sources.md#SKILLBP)).

When a value falls outside the Commands contract, the convention is uniform: the guide **names the descriptive concept** ("the project's benchmark command"), tells the agent to **ask the user** for the concrete value, and flags it — it never invents a concrete command. A guide does not add `AGENTS.md` sections unilaterally; a recurring question is promoted into the contract instead.

---

## Why the density cap forces inline restatement

The `AGENTS.md` ≤200-line / ≤25 KB cap is not arbitrary. It rests on **Lost-in-the-Middle**: the U-shaped attention curve where a model's accuracy degrades for information buried in the middle of a long context ([LOSTMID](sources.md#LOSTMID)). An always-loaded bootloader that grew without bound would push its own load-bearing facts into the low-attention middle and dilute everything an agent must reliably act on.

This is a **bloat-versus-gap-filling tradeoff**, not a hard capability ceiling: more always-on context costs attention and tokens, while too little leaves a guide reaching for something that is not there. The self-contained-guide rule sits on the *gap-filling* side of that tradeoff — inline restatement keeps a guide's needs in the one file the agent is reading — and the bootloader cap sits on the *bloat* side, keeping the always-on surface small enough that its facts stay in the attended region. The two rules are complementary halves of one density discipline.

---

## State externalisation makes self-containment real

Inline restatement keeps a guide independent of its siblings' *text*. File-based state keeps it independent of its siblings' *memory*. If one pass had to rely on another keeping a shared in-memory picture of what was decided, the guides would be implicitly coupled through the agent's working memory — and "self-contained guide" would be a polite fiction.

The kernel's answer is to externalise state to disk. Long-running work writes to `task.md` and the `.swarm/` workspace — `sources/` (desired truth), `status/` (observed satisfaction and drift), `generated/` (execution packets) — so each pass reads prior findings from the file and records its own decisions back to it, assuming nothing about what a sibling kept in attention ([the workspace model](../model/workspace.md)).

The research backs the *shape* of this from three converging angles, none of them load-bearing on a single contested statistic:

- Emitting intermediate steps to an external scratchpad rather than holding them in latent state **substantially improves** multi-step computation ([SCRATCHPAD](sources.md#SCRATCHPAD)).
- Anthropic's context-engineering guidance treats context as a finite resource and recommends an explicit on-disk note-taking pattern (`task_plan` / `progress_log` / `decisions`) rather than relying on the model to carry state ([CTXENG](sources.md#CTXENG)).
- The Claude Code Tasks system is vendor-scale validation of disk-persistent, dependency-aware task state ([CCTASKS](sources.md#CCTASKS)).

> **A claim this page does not make.** A headline "21× file-state degradation" figure circulates in the skill-authoring literature, attributed to an arXiv id that, on direct fetch, resolves to an unrelated condensed-matter physics paper. That figure is rejected and is **not** repeated here; the case for externalised state rests instead on the three verified sources above (see [sources.md](sources.md) → Rejected).

For self-containment specifically, the implication is structural: **state is shared through the file, not through implicit context.** A pass that needs prior findings reads them from `task.md`; a pass that records a decision writes it there. No pass assumes another kept anything in attention.

---

## Loading: named by the task, not by a sibling

Self-containment also shapes *how* a guide activates. The kernel's primary mechanism is **load what the task names**: a `task.md` names, in its frontmatter or assignment block, the pass guide(s) and profile(s) it activates, and the agent loads exactly those ([ADR-0037](../adrs/0037-load-what-the-task-names.md), [the pass-guides reference](../library/pass-guides.md)). Description-match self-activation is the **fallback** for the launcher-less case — a degraded mode, not the contract. Crucially, neither path lets one guide pull in another: a guide activates because the task named it (or its description matched the task), never because a sibling guide mentioned it. Routing stays orthogonal to which guides are independent.

This is why no "loader" or "core" index guide exists. A standing gatekeeper that pre-loaded guides would itself be an always-loaded module — forbidden — and would not be guaranteed present on a consumer's machine. The independence is preserved precisely by having nothing that knits the guides together at load time.

---

## What the cost buys

The cost of self-containment is deliberate duplication: the same discipline — *paste the actual command output, not a paraphrase* — appears inline in the `empirical-proof` fragment, in the `implement` guide's self-review, in the `review` guide. That restatement is intentional, kept honest by the distillation discipline that governs what gets copied where, not a TODO.

| Benefit | Mechanism |
| --- | --- |
| **Selective vendoring works** | Any subset of the catalogue copies in cleanly; nothing breaks because no guide assumes a sibling is present. |
| **Guides stay stack-agnostic** | The same guide body runs in a TypeScript monorepo, a Rust crate, or a Python service — only the `AGENTS.md > Commands` table differs. |
| **Reviews are local** | A guide's correctness is determined by reading just that guide plus the Commands contract — no cross-guide interaction to model. |
| **Forks are cheap** | A team vendors a single guide without porting a dependency graph. |

One discipline ties back to the proof model rather than to portability: the *forced-visible-output* rule that several guides restate — "tests passed" with no pasted command, exit code, or output is not a proof — is grounded on verbal self-reflection turning an implicit signal into a durable, checkable artifact ([REFLEXION](sources.md#REFLEXION)), and is the `empirical-proof` discipline the `verify` and `review` passes apply.

> Caveat on the practitioner literature: non-peer-reviewed catalogues name the *Reference Illusion* anti-pattern and distinguish activation failure from silent step-skipping ([PRACTITIONER](sources.md#PRACTITIONER), [TWOPROBLEMS](sources.md#TWOPROBLEMS)). These are cited as **preliminary, illustrative** framing only; the load-bearing version of the forced-output discipline is [REFLEXION](sources.md#REFLEXION), and the load-bearing case for naming commands is [AGENTSMD-HARM](sources.md#AGENTSMD-HARM).

---

## See also

### Sibling research pages

- [Activation](activation.md) — why "load what the task names" is primary and description-match is the fallback; the directive description form as an authoring heuristic, not the primary loader.
- [Task files and state externalisation](task-files.md) — the file-based state that lets self-contained guides coordinate without shared memory.
- [Scope](scope.md) — the same self-containment principle that excludes any "loader" or "core" index guide.
- [Sources](sources.md) — the bibliography every cited claim above resolves to.

### Framework docs the decisions live in

- [Pass guides](../library/pass-guides.md) — the procedural-layer contract, the loading doctrine, and the semantic-ownership prohibition.
- [Heuristic profiles](../library/heuristic-profiles.md) — profiles ship and activate under the same self-containment rule as guides.
- [Workspace model](../model/workspace.md) — `AGENTS.md` as bootloader, the density cap, and the `task.md` + `.swarm/` state surfaces.
- [The `verify` pass](../passes/verify.md) and [the `review` pass](../passes/review.md) — the proof model and the forced-visible-output / empirical-proof rule.
- [ADR-0016](../adrs/0016-skills-are-self-contained.md), [ADR-0037](../adrs/0037-load-what-the-task-names.md), [ADR-0038](../adrs/0038-verify-by-adapters-through-commands.md) — the self-contained-guide rule, the loading doctrine, and the `VERIFY BY` → `AGENTS.md > Commands` indirection.
