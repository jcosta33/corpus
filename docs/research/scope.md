# Scope: what belongs in the conditioning layer

> Swarm's conditioning layer — its pass guides and heuristic profiles — is a small, vendorable set of *methods*. This page is the research note behind the line that decides what is allowed in: the gating question that keeps a guide portable, the *how-to-work* (pass guide) versus *what-to-run* (`AGENTS.md` Commands) split, and the seven things the layer deliberately refuses, each re-homed to where the kernel already keeps it.

This is a `docs/research/` page: it carries `[KEY]` citations because the split it defends rests on evidence, and `docs/research/` is the one corner of the docs that grounds its claims explicitly. Every empirical claim below resolves to a verified entry in [sources.md](sources.md); a non-peer-reviewed source is named as preliminary and never as a `MUST`.

The kernel object this page is about is the **conditioning layer**: the [pass guides](../library/pass-guides.md) (a reusable *method* for a named pass) and [heuristic profiles](../library/heuristic-profiles.md) (a cognitive *stance* over a pass). It is deliberately *not* about the [overlay](../library/overlays.md) layer — project-local rules — nor about [`AGENTS.md`](../reference/glossary.md), the always-loaded bootloader. The whole point of a scoping rule is to keep those three apart.

---

## The gating question

When a candidate guide or profile is proposed, one question decides whether it belongs in the conditioning layer:

> *Could this be vendored by a team using a different language, a different framework, a different CI provider, and a different agent CLI — and still produce its intended behaviour, with no other guide in context?*

If **yes**, it is a method that travels — a pass guide or a profile, and it belongs in the layer. If **no**, it is coupled to something — a stack, a tool, a project's house rules, or a sibling guide — and it belongs somewhere else the kernel already provides: an [overlay](../library/overlays.md), the consuming repo's [`AGENTS.md`](../reference/glossary.md), or that repo's own non-stdlib guides.

The question is a portability test, and portability is the kernel's reason for the conditioning layer to exist at all. A pass guide is **self-contained** by contract — "a reader following one guide should not have to hop across a chain of other guides to perform the pass" ([pass guides](../library/pass-guides.md)) — and a profile's whole job is to be applied uniformly across whatever pass it sharpens. A guide that fails the gating question would break that contract the moment a consumer vendored it into the wrong stack.

---

## How-to-work vs what-to-run

The sharpest line the gating question draws is between two things that look adjacent but live in different layers:

| | Lives in | Carries | Portable? |
|---|---|---|---|
| **How to work** | a pass guide / profile | the *method* for a pass — the questions, the order, the evidence to gather | Yes — the same method runs in any repo |
| **What to run** | `AGENTS.md > Commands` | the *concrete command* for this repo — `npm test`, `cargo test`, `mvn verify` | No — it is this project's tooling |

A pass guide says *run the project's validation command*; it never says `npm run validate`, because the moment it names a concrete command it stops being vendorable. The concrete command lives in the consuming repo's `AGENTS.md > Commands` table, and the obligation reaches it through a single indirection: a `VERIFY BY <type>:<adapter>:<artifact>` clause names a portable proof `<type>` and a project `<adapter>`, and the `<adapter>` resolves to a `cmd*` slot in `AGENTS.md > Commands` ([verify pass](../passes/verify.md); specified in [ADR-0038](../adrs/0038-verify-by-adapters-through-commands.md)). The guide carries the method; the table carries the command; the proof binding is the seam between them.

This split is the configuration the evidence supports. The ETH Zürich evaluation of `AGENTS.md` files [[AGENTSMD-HARM]](sources.md#AGENTSMD-HARM) found that **repository-specific commands are used far more often when they are named in the context file than when they are not**, while LLM-*generated* narrative context can cost more than it returns. (A specific "~50×" multiplier for that lift circulates in the skill-authoring literature; the multiplier is **not** repeated here as fact — the verified, load-bearing finding is the *direction*: name the commands, minimise the narrative. See the rejected-claims note below.) The reading is direct: the *what-to-run* signal pays off precisely because it is named where the agent will look — `AGENTS.md` — and the *how-to-work* method stays in a portable guide that names no command at all.

---

## The seven exclusions, re-homed to the kernel

The conditioning layer refuses seven categories of content. Each maps cleanly onto a place the kernel already keeps that content — the conditioning layer does not so much *forbid* these as *route* them to their correct home.

### 1. No engineering-domain knowledge

`auth-patterns`, `observability`, `caching`, `incident-response`, `idempotency` — these describe *what an engineer should know about a problem*, not *how an agent should work a pass*. A guide that prescribed one auth pattern would couple to a stack; a guide that enumerated every pattern would be an everything-guide that violates the body-size discipline of [skill authoring best practice](sources.md#SKILLBP). Either way it fails the gating question.

**Re-home:** the consuming repo's architecture and convention rules. In the kernel these are **[overlays](../library/overlays.md)** — the home for project-local architecture and testing-policy rules: they encode project-local convention, and that is exactly what an overlay is for. An overlay is `READS`-/`AFFECTS`-scoped to its passes and loaded only when a task names it, so domain knowledge that is true *here* never contaminates the shared stdlib guides.

### 2. No stack-specific or vendor-specific guides

`react-19-best-practices`, `postgres-index-patterns`, `aws-vpc-conventions` — a guide that speaks React is dead weight in a Python service, and forces the agent to disambiguate which guide applies. It fails the gating question on the first clause (a different language).

**Re-home:** an **[overlay](../library/overlays.md)** in the consuming project, or a stack-specific guide the project installs in its own non-stdlib guide directory. The stdlib pass-guide set stays universal; a project layers stack flavour on top without editing the kernel.

### 3. No internal-product or vendor-specific docs

Internal product knowledge, business-logic wikis, vendor runbooks — same coupling failure as the first two. They are true for one product and wrong to bake into a shared kernel.

**Re-home:** an **[overlay](../library/overlays.md)** (the `## Rules` / domain-rules slot), or the product repo's own `AGENTS.md > Architecture`. The conditioning layer is generic so it can be vendored across products.

### 4. No automation, scripts, CI, or evaluation harnesses in the layer

This exclusion is structural to the kernel, not just a scoping preference. **NO RUNTIME** (Invariant 1, [PRINCIPLES](../PRINCIPLES.md)) means every "checker", "linter", or "validator" the framework names is *a contract a future tool builds against*, never software the layer ships. A guide is text a human or an agent reads; it executes nothing and enforces nothing.

**Re-home:** the maintainer's own CI, *outside* the layer. The kernel keeps validation as a markdown **contract** — conformance is "a regression check that confirms no pass guide, profile, fragment, or `AGENTS.md` section defines modality, authority order, or verification semantics" ([pass guides](../library/pass-guides.md)) — and that check, when a tool exists to run it, lives in the maintainer's CI, not bundled into the guides it checks. Putting automation in the layer would choose one runtime and break provider-neutrality, the exact failure Invariant 1 exists to prevent.

### 5. No "core" / "loader" / "index" guide that other guides depend on

`personas-core`, `write-core`, any loader a guide assumes is already present. This breaks self-containment directly: a guide that depends on a sibling being loaded can no longer be vendored independently. The kernel forbids it by the dependency rule — guides form a one-way, acyclic chain (`language definitions → artifact contracts → pass contracts → pass guides → heuristic profiles → project overlays`), and **a guide MUST NOT introduce a circular dependency** ([pass guides](../library/pass-guides.md)).

**Re-home:** nothing — the pattern is simply rejected. The kernel demonstrates the alternative: the [heuristic profiles](../library/heuristic-profiles.md) ship one file per stance with no shared core, and each is independently vendorable.

### 6. No guide designed to "always load"

A guide whose description matches every task ("handles all X", "use on every request") is the wrong primitive. Persistent context — facts, conventions, the project's commands — belongs in the always-loaded bootloader, not paid for on every activation. This is settled in the kernel by **[ADR-0017](../adrs/0017-no-always-load-skills.md): no always-loaded skills** and reinforced by the loading doctrine (below): a pass guide "MUST NOT be always-loaded … there is no standing gatekeeper that pre-loads guides; that would itself be an always-loaded skill (forbidden)" ([pass guides](../library/pass-guides.md)).

The cost discipline behind this is **Lost-in-the-Middle** [[LOSTMID]](sources.md#LOSTMID): accuracy degrades for information buried in the middle of a long context, so always-on conditioning is not free — it pushes load-bearing instructions toward the low-attention middle and competes for a finite budget. The kernel frames this as the bloat-versus-gap-filling tradeoff that motivates the `AGENTS.md` density cap (≤200 lines / ≤25 KB, [glossary](../reference/glossary.md)); it does **not** claim a hard capability ceiling. The point is a tradeoff, not a cliff: an always-loaded guide spends the scarce budget on a procedure most tasks do not need.

**Re-home:** persistent facts and routing pointers go into **[`AGENTS.md`](../reference/glossary.md)**, the always-loaded bootloader — the one place content is *meant* to always load, held to its density cap. Any discipline that would otherwise be pushed into an always-loaded skill lives in the task templates and the kernel's concept docs instead.

### 7. No guide that owns semantics

This is the exclusion that distinguishes a pass guide from an unconstrained skill: a pass guide carries a discipline preventing it from quietly owning semantics ([pass guides](../library/pass-guides.md)). A guide that defined a verdict value, a proof type, or a clause keyword would make a spec's *meaning* depend on whether an optional guide happened to load.

**Re-home:** SOL and the typed IR. The **semantic-ownership prohibition** is the one rule a pass guide must never break: "No pass guide may define, redefine, or be required to interpret SOL or APS semantics" ([pass guides](../library/pass-guides.md)). A correctly authored `*.swarm.md` is readable by a strong model with **no guide loaded at all**. This is why the layer is *soft control* (Invariant 2): it influences how work is done and binds nothing the kernel marks authoritative.

---

## Activation is by loading, not by description

A scoping rule is only as good as the mechanism that loads the things it admits, and the kernel's primary mechanism is **load what the task names** — the loading doctrine ([ADR-0037](../adrs/0037-load-what-the-task-names.md), [pass guides](../library/pass-guides.md)). A `task.md` names, in its frontmatter, the pass guide(s) and profile(s) it activates for the pass it frames; the agent loads exactly those and nothing else. The state the task tracks lives in `task.md` and the `.swarm/` workspace (`sources/`, `status/`, `generated/`) — see the [workspace model](../model/workspace.md).

Description-match self-activation is the **fallback**, retained for the launcher-less case where a task is dropped into an arbitrary agent CLI with no router. The four-clause directive description form is an authoring heuristic that helps that fallback fire correctly; the *direction* that directive, exclusion-bearing descriptions activate more reliably is reported by a preliminary, non-peer-reviewed measurement [[ACTIVATION-BLOG]](sources.md#ACTIVATION-BLOG) — illustrative only, never load-bearing. It is **not** true that "the description is the most load-bearing line": the task naming the guide is. This matters for scoping because exclusion #6 (no always-load) is enforceable precisely *because* loading is task-driven — there is no ambient description-matcher pulling guides in unbidden.

---

## Forced-visible output: the proof side of the same discipline

The conditioning layer's refusal to own semantics has a companion on the verification side: a completion claim must carry visible, re-runnable evidence. "Tests passed" with no command, exit code, or output is **not** a proof — it reads as `UNVERIFIED`, never `PASS` ([verify pass](../passes/verify.md)). This is the empirical-proof discipline the kernel ships as a cross-cutting fragment behind `verify` and `review` ([pass guides](../library/pass-guides.md)).

The grounding is [[REFLEXION]](sources.md#REFLEXION): verbal self-reflection between trials reached **91% pass@1 on HumanEval versus the 80% GPT-4 baseline** — a written, checkable artefact converts an implicit signal into a durable one. Externalising intermediate work to a scratchpad similarly improves multi-step computation [[SCRATCHPAD]](sources.md#SCRATCHPAD). The scoping connection: a guide cannot *assert* a proof exists (that would be owning verification semantics); it can only carry the *method* for producing visible evidence, and the verdict is rendered against the kernel's proof model, not the guide.

---

## A rejected claim, replaced

A figure circulating in the skill-authoring literature — a "**~50×** lift" in command usage from naming commands in the context file — is drawn from the ETH `AGENTS.md` study. The verified entry [[AGENTSMD-HARM]](sources.md#AGENTSMD-HARM) confirms the *direction* (commands named in context are used far more often) but this layer does **not** carry the specific multiplier as a load-bearing fact, so this page states the direction and omits the number. Separately, two figures this layer **rejects outright** circulate alongside it, because their arXiv ids resolve to unrelated papers — a "21× file-state degradation" and a "24–68% turn-cost" reduction ([sources.md, Rejected](sources.md)). Neither appears here. Where that literature uses them to ground externalised state, the verified alternatives are [[CTXENG]](sources.md#CTXENG), [[CCTASKS]](sources.md#CCTASKS), and [[SCRATCHPAD]](sources.md#SCRATCHPAD).

---

## Related

- [Pass guides](../library/pass-guides.md) — the *how-to-work* layer this page scopes; the semantic-ownership prohibition and the loading doctrine.
- [Heuristic profiles](../library/heuristic-profiles.md) — the cognitive-stance layer; the alternative to a shared "core" guide.
- [Overlays](../library/overlays.md) — the re-home for exclusions 1–3: project-local architecture, stack, and domain rules.
- [Workspace model](../model/workspace.md) — `task.md` plus the `.swarm/` `sources/ status/ generated/` state the conditioning layer reads.
- [The `verify` pass](../passes/verify.md) — the "tests passed without output is invalid" rule and the proof model a guide applies but never defines.
- [ADR-0037](../adrs/0037-load-what-the-task-names.md) and [ADR-0038](../adrs/0038-verify-by-adapters-through-commands.md) — load-what-the-task-names, and `VERIFY BY` adapters resolving through `AGENTS.md > Commands`.
- [PRINCIPLES](../PRINCIPLES.md) — Invariant 1 (NO RUNTIME) behind exclusion #4, and Invariant 2 (soft vs hard control) behind exclusion #7.
- [Sources](sources.md) — the bibliography every citation above resolves to, including the rejected-claims register.
