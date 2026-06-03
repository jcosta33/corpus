# Activation: how a pass guide or profile is selected

> This is the CITED research layer. It is the one corner of `docs/` that deliberately carries `[KEY]` citations; every load-bearing empirical claim points to a verified entry in [`sources.md`](sources.md), used with its recorded caveats. Everywhere else in `docs/` is self-standing.

When an agent is about to run a pass, *something* has to put the right method in front of it: the [pass guide](../library/pass-guides.md) for that pass, and the [heuristic profile](../library/heuristic-profiles.md) that sharpens it. This page is about that selection step — how the conditioning a pass needs gets into context, and how *not* to get it wrong.

Swarm's answer has two tiers, and the order matters. The **primary** mechanism is **load what the task names**: the [`task.md`](../artifacts/task.md) names its pass guide(s) and profile, and the agent loads exactly those. The **fallback**, for the case where there is no task and no router, is description-matching: a guide carries a self-activating `description`, and an agent matches it against the work in front of it. The fallback is a degraded mode, not the contract. Much of the skill-authoring literature has these the other way around — it treats the `description` line as the single most load-bearing thing in a skill. The kernel rejects that framing ([ADR-0037](../adrs/0037-load-what-the-task-names.md)); this page records why.

---

## Primary: load what the task names

A pass guide and a profile are **lazily loaded** — never resident in context. The canonical way each activates is by being **named in the task that frames the pass**. A `task.md` SHOULD name, in its frontmatter, the pass guide(s) and profile(s) it activates; when named, the agent **MUST load exactly those, and SHOULD NOT load others**. The binding looks like this:

```text
task.md frontmatter:
  task_kind: fix
  pass: implement
  pass_guides: [write-fix, fix-flaky-test]
  profile: skeptic
```

The agent loads `write-fix`, `fix-flaky-test`, and the Skeptic profile for this `implement` pass — and nothing else.

Two reasons make naming the primary path rather than the fallback:

- **The task is the authoritative place to record what loads.** Routing through always-evaluated `description` fields makes routing depend on `description` quality: a vague or over-broad description mis-fires, and the agent has no authoritative statement of what it *should* have loaded for the pass it is in. The task file makes the routing decision explicit and auditable instead of implied by a heuristic ([ADR-0037](../adrs/0037-load-what-the-task-names.md)).
- **Naming exactly what loads minimizes always-on density.** Leaning on always-evaluated descriptions pushes toward more conditioning being ambiently present every turn. That works against the density discipline that protects adherence and cost — the same discipline behind the `AGENTS.md` cap discussed below. The grounded mechanism is the U-shaped attention curve: accuracy degrades for information buried in the middle of a long context, so every line that is *always* present competes for adherence and is paid for on every turn ([LOSTMID](sources.md#LOSTMID)). The kernel states the density rationale as the **bloat-versus-gap-filling tradeoff**, not as a claim that models *cannot* follow many instructions — see [Principles § Load-bearing meaning lives only in SOL + IR](../PRINCIPLES.md) and the [APS density note](../language/APS.md).

Loading (which conditioning is in context) stays **orthogonal** to verification (what proof a task must carry once active). Naming a guide neither adds nor relaxes any obligation; it only decides what method the agent reads.

---

## Fallback: description-matching, a degraded mode

There is a real case the primary path does not cover: a task dropped into an arbitrary agent CLI with no launcher and no naming — the launcher-less case. For that case, and only that case, the fallback applies: an agent MAY match a guide's self-activating `description` against the task in front of it. It is supported, but it is **not the contract**. An unnamed task silently drops to this degraded mode, which is why the kernel pushes authors to name their guides in `task.md`.

There is no standing gatekeeper that pre-loads guides per pass. Such a gatekeeper would itself be an always-loaded skill — forbidden ([ADR-0017](../adrs/0017-no-always-load-skills.md)) — and would not be guaranteed present on a consumer's machine.

Because the fallback exists, the authoring quality of the `description` still matters whenever the primary path is absent. The rest of this page is about writing that `description` well — but read it as *making the fallback dependable*, not as the activation mechanism.

---

## The directive four-clause form (an authoring heuristic)

When a guide does carry a `description` for the fallback, the kernel uses a **directive, exclusion-bearing form** rather than a passive one. The directional evidence for preferring directive over passive descriptions is *preliminary and non-peer-reviewed*: a self-published 650-trial measurement reports directive, exclusion-bearing descriptions activating more reliably than passive ones ([ACTIVATION-BLOG](sources.md#ACTIVATION-BLOG)). **Its specific odds-ratio and "100% activation" figures are not load-bearing and are not repeated here** — they are a single-author blog measurement, not a controlled study. We adopt the *direction* (directive descriptions help the fallback) as an authoring heuristic; we do not state its numbers as fact.

The form is four clauses, in order:

```text
<WHAT verb> <object>.
ALWAYS apply when <trigger 1>, <trigger 2>, or <trigger 3> — even if <implicit signal>.
Do not <forbidden default behaviour> directly.
Skip for <out-of-scope task-kind 1> or <out-of-scope task-kind 2>.
```

| Clause | What it does |
| --- | --- |
| **WHAT verb + object** | Names the action concretely so the agent can pattern-match the work against it instead of an abstract noun phrase. |
| **ALWAYS apply when…** | States the triggers the guide is for. The *even if…* qualifier captures implicit signals the work carries but does not say literally. |
| **Do not `<X>` directly** | Blocks the bypass action — the default the agent would take if it had decided not to load the guide at all. |
| **Skip for `<Y>`** | Names the **task-kinds** this guide is not for, so it does not fire on neighbouring work. |

The form is an **authoring heuristic for the fallback**, consistent with the official skill-authoring guidance on third-person, concrete descriptions ([SKILLBP](sources.md#SKILLBP)) and the `description` field of the Open Agent Skills spec ([SKILLSPEC](sources.md#SKILLSPEC)). It is not a kernel obligation, and it is **not** the primary loader: under the loading doctrine the primary signal is the `task.md` naming, and the directive `description` only earns its weight when the task did not name anything.

---

## Exclusions name task-kinds, not sibling guides

One rule is worth stating sharply: the `Skip for…` clause names **task-kinds**, never sibling guide names. Where two guides could plausibly match the same work, each rules out the other's *task-kind* — the agent matches the work against whichever guide's `ALWAYS apply when…` clause triggers, with no guide having to know which siblings are installed.

Naming a sibling guide by name would be tempting (more concrete, fewer characters) but structurally wrong. A consumer who vendored only one guide and not its neighbour would have a `description` that references a guide that is not present — a dangling reference. Naming the *task-kind* gives the agent the same disambiguation signal without coupling the `description` to a particular catalogue. This matters because Swarm's profiles and guides are independently vendorable: the [profile × pass routing model](../library/heuristic-profiles.md) selects a stance from the pass and `task_kind` alone, with no per-task-type lookup matrix. Both the directive form and the task-kind-only exclusion rule serve the same end — a `description` that disambiguates by *shape*, so the fallback stays dependable even when the obvious neighbour is missing.

---

## What this page does *not* claim

This page deliberately declines three claims common in the skill-authoring literature, because they fail Swarm's evidence discipline ("real science, not astrology" — [Principles § Evidence discipline](../PRINCIPLES.md)):

- **No "the description is the most load-bearing line."** Under the kernel, the most load-bearing routing signal is the `task.md` naming; the `description` is the fallback. The common framing inverts the doctrine.
- **No headline activation figures.** The literature quotes an odds ratio and "100% activation" rates as established fact. Those come from a single non-peer-reviewed measurement ([ACTIVATION-BLOG](sources.md#ACTIVATION-BLOG)); only the *direction* is cited here, and only as preliminary.
- **No "compliance ceiling" or capability-ceiling claim.** A common brevity argument rests on a misattributed degradation figure and on a vendor study's "+20% tokens / −3% success" numbers used as a hard ceiling. The density rationale here rests instead on the U-shaped attention finding ([LOSTMID](sources.md#LOSTMID)) plus the bloat-versus-gap-filling tradeoff — *not* on any claim that models cannot follow many instructions. The fabricated "21× file-state" and "24–68% turn-cost" figures that circulate in that literature are recorded as **rejected** in [`sources.md`](sources.md) and MUST NOT be reintroduced.

A separate, real concern the literature raises — that an agent might *activate* a method and then silently skip a step — is addressed in the kernel as the **forced-visible-output** / empirical-proof rule: a `PASS` whose evidence is the bare phrase "tests passed", with no command, exit code, or output, is invalid ([verify pass](../passes/verify.md)). The grounded version of "make the work visible so it can be checked" is the verbal-feedback finding behind self-reflection ([REFLEXION](sources.md#REFLEXION)) and the scratchpad finding for externalising intermediate work ([SCRATCHPAD](sources.md#SCRATCHPAD)); the practitioner write-up that named the two-problems distinction ([TWOPROBLEMS](sources.md#TWOPROBLEMS)) is illustrative only.

---

## The Commands contract is a separate indirection

One thing the `description` and the `task.md` naming do **not** carry is the project's concrete commands. Activation routes a *method* into context; it does not resolve *what to run*. That resolution lives in the always-loaded `AGENTS.md` bootloader (capped at ≤200 lines / ≤25 KB to hold the density discipline above), whose `Commands` table is the `{{cmd*}}` contract that `VERIFY BY` adapters resolve through ([ADR-0038](../adrs/0038-verify-by-adapters-through-commands.md)). Keeping these separate is deliberate: a portable obligation names a logical adapter, the project's `AGENTS.md` names the concrete command, and the loaded pass guide names neither. The `AGENTS.md` convention this builds on is documented in [AGENTSMD-CONV](sources.md#AGENTSMD-CONV); the finding that repository-specific commands are used far more when named in the context file is [AGENTSMD-HARM](sources.md#AGENTSMD-HARM).

---

## See also

- [Pass guides](../library/pass-guides.md) — the loading doctrine in full, the pass-guide contract, and the installed guides.
- [Heuristic profiles](../library/heuristic-profiles.md) — the profile × pass routing model that selects a stance from the pass and `task_kind`.
- [`task.md`](../artifacts/task.md) — where a task names the pass guides and profile to load (the primary mechanism).
- [ADR-0037](../adrs/0037-load-what-the-task-names.md) — the decision that made "load what the task names" canonical and demoted description-matching to the fallback.
- [Principles](../PRINCIPLES.md) — the density discipline and the evidence discipline this page is held to.
- [Sources](sources.md) — the bibliography every citation above points into.
