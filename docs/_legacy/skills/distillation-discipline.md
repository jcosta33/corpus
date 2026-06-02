# Skill (documentation): `distillation-discipline`

> **For agents:** instructions → [`/scaffold/.agents/skills/distillation-discipline/SKILL.md`](../../scaffold/.agents/skills/distillation-discipline/SKILL.md)

---

## TL;DR

Compressing an artefact without confessing what was truncated is covert loss. Accountability requires enumerating the deliberate omissions — a **Distillation Loss Statement** appended to every doc distilled from upstream. The skill self-activates when transforming a high-verbosity document (research) into a lower-verbosity one (spec, audit, task), or finalising a long-running investigation; it stays out of net-new authoring with no upstream to distil from.

## What the skill actually enforces

The verbosity gradient is `research → spec/audit/bug-report → task → terminal output`, and every transition drops something. The skill permits dropping conversational fluff and exploratory narrative, and forbids dropping load-bearing content: architectural constraints, API payload shapes, acceptance criteria, identified risks, and `[CRITICAL]` open questions. The Loss Statement must list **explicit removed claims** mapped to the rationale for dropping them — "removed fluff" is a non-statement; "dropped the comparison of three sorting algorithms (we picked merge-sort)" is real.

The body carries a **four-tests result table** (🎯 Requirements, 🧬 Behavior, 🔍 Edge case, 🧪 Empirical) with one row per upstream load-bearing item, and a **pre-deliver visibility gate**: the distilled doc is not delivered until that table is in the task file and every row is ✅. A row marked `dropped (without justification)` is a gate failure — halt and revise.

## Loss budgets versus zero-loss choke points

Transitions carry a declared tolerance, encoded in the body's budget table:

- `research → spec/audit/bug-report` — 🟡 high; narratives and explored alternatives are fair to drop.
- `spec → task` — 🟢 zero; architectural constraints and data shapes survive verbatim. This is the critical choke point: parsing a spec into sub-tasks is forbidden from shedding any constraint.
- `bug-report → task` — 🟢 zero; reproduction and root cause preserved.

The author's job here is not poetry reduction — it is conserving the invariants a downstream reader will need.

## Why the template forces an explicit field

Invisible mental accounting evaporates mid-edit. A dedicated `## Distillation Loss Statement` section makes the omission reviewable: a reader can hold the upstream and downstream docs side by side and verify nothing load-bearing went missing.

## The sister discipline: promotion

Distillation flows downhill; promotion flows back up. When a task discovers something durable, the finding is promoted into the upstream doc (audit, spec, research, bug-report) before the task closes — not silently dropped. The two disciplines together keep the document graph honest in both directions.

## When upstream distillation was careless

A downstream symptom worth watching: an implementer that repeatedly halts on ambiguity is often reading a spec that quietly shed a constraint during `spec → task`, not writing inferior code. Treat recurrent blockers as evidence to re-audit the distillation, not to pressure the implementer.

## Bundled resources

- `references/worked-example.md` — the full Stripe research → spec walk-through, including the four-tests result table for that example. (The SKILL body inlines a one-pair excerpt; the reference carries the full version.)

## Related

- [Distillation concept](../concepts/03-distillation.md)
- [ADR 0003: distillation is unidirectional](../adrs/0003-distillation-is-unidirectional.md)
- [Architect persona](../personas/the-architect.md) — ships as `persona-architect`
