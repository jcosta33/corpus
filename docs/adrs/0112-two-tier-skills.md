---
type: adr
id: adr-0112
status: accepted
created: 2026-06-26
updated: 2026-06-26
---

# ADR-0112 — Two-tier skills: a framework-free universal catalog, a Corpus-coupled kit

## Context

[ADR-0111](./0111-kit-skill-scope.md) drew the kit/catalog line as "Corpus-concept builders + core-loop
methods → kit; styles / stances / depth → catalog." That made the catalog a catch-all and left the
catalog's skills **shot through with Corpus concepts** — most reference `spec` / `task packet` /
`review packet` / `AC`, and `adversarial-review` even bundled a `type: review` packet template. A skill
that names a Corpus artifact cannot be installed and used in a non-Corpus repo, which defeats the whole
point of an installable catalog. A research pass (deep-research, 105 agents, 19 confirmed claims) also
established the adopted-skill anatomy: a skill earns use by **changing a default** (not restating one),
fitting **one purpose**, triggering off its **description**, **explaining the why** over all-caps
imperatives, staying **<500 lines** with progressive disclosure, and accreting a **Gotchas** section —
over-specification *measurably* hurts ([[AGENTSMD-HARM]]).

## Decision

**Partition skills by *coupling*, as a binary — there is no middle tier.**

1. **The universality test.** A skill is **universal** iff its body **and** its bundled files name
   **zero** Corpus concepts — no `spec`, `task` / task packet, `review` / review packet, `finding`,
   acceptance criterion / `AC`, `## Execution`, `type: spec|task|review`, status board, or
   `SPEC-`/`TASK-`/`REVIEW-` id, and no citation of a Corpus ADR (an ADR reference is itself a coupling
   smell). The moment it names one, it is a **Corpus** skill.

2. **Placement is the binary.** **Framework-free → the catalog** (corpus-skills): the universal
   disciplines and stances, installable into any repo (`npx skills`) with zero Corpus knowledge.
   **Corpus-coupled → the kit** (`.agents/skills/`): every skill that operates a Corpus concept —
   the artifact builders, the core-loop methods, **and** the `write-*` task-implementation depth.

3. **The kit is an always-core + an opt-in Corpus-depth group.** The minimal core (the loop +
   the always-needed authoring) ships first; the `write-*` kind-specialised implementers are **opt-in
   depth** an adopter prunes or ignores (progressive disclosure keeps their always-on cost ~one
   description each). This is [ADR-0105](./0105-stretch-and-collapse.md) stretch-collapse applied to
   skills: depth is summoned, not forced.

_Level: convention._

## Consequences

- The catalog becomes genuinely universal — a developer with no Corpus install gets the ultimate
  versions of the fundamental disciplines (review, the stances, evidence, concision, flaky-test).
- The kit holds every Corpus-coupled skill in one home (no homeless "Corpus-coupled depth").
- **Moves:** `write-feature/-fix/-refactor/-rewrite/-migration/-performance/-testing/-documentation`
  relocate catalog → kit; the catalog's long-form `implement-task` folds into the kit's. The universal
  set (`adversarial-review`, `persona-skeptic/-challenger/-surveyor`, `empirical-proof`, `concise-output`,
  `fix-flaky-test`) is stripped framework-free — `adversarial-review` loses its `type:review` template
  (its Corpus review-packet building already lives in the kit's `review-output`).
- The anatomy upgrades (Gotchas, explain-why, behavior-changing) apply to **both** tiers.
- **Migration tail:** the relocation is mechanical; no artifact format changes.

## Affected obligations / constraints

- **Refines:** [ADR-0111](./0111-kit-skill-scope.md) (catalog = universal-only, not the catch-all;
  Corpus-coupled depth is kit-side) and [ADR-0064](./0064-minimal-kit-tiering.md) (kit = always-core +
  opt-in Corpus-depth group). **Reaffirms:** [ADR-0105](./0105-stretch-and-collapse.md) (depth is a
  dial), [ADR-0093](./0093-collapse-1to1-personas.md), single-sourcing. **Grounded by:** [[AGENTSMD-HARM]]
  (over-specification harm) + the deep-research skill-anatomy synthesis.
- **Does NOT change:** the artifact formats, the core loop, the verdict model, or the checks contract.
  Accepted ADRs 0064/0111 are refined here, not edited in place (Nygard immutability).
