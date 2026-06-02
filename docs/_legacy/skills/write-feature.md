# Skill (documentation): `write-feature`

> **For agents:** instructions → [`/scaffold/.agents/skills/write-feature/SKILL.md`](../../scaffold/.agents/skills/write-feature/SKILL.md)

---

## TL;DR

Contain implementation optimism: halt-on-ambiguity beats silent interpretation, and opportunistic refactors that launder scope through "cleanup" are forbidden. The skill self-activates when the user asks to implement, build, or add a feature, when a spec is referenced, or when an acceptance criterion is named — even without an explicit spec — and stays out of bug-fix, behaviour-preserving refactor, and behaviour-changing rewrite work.

## What the skill actually enforces

**Read the spec in full before coding** and map every acceptance criterion to an implementation step *before* implementation starts. **Survey existing patterns** before adding a helper or type — reinvention is forbidden; if existing patterns don't fit, say so in `## Decisions`. **Halt on ambiguity** into `## Blockers` rather than inventing the requirement. **No opportunistic refactoring** — architectural debt spotted in passing gets *promoted* to an audit, not silently fixed. **Run validation after every batch** (catching a violation at batch 3 is cheaper than at batch 12) and **paste the verbatim output** into the progress checklist. Tests are part of the deliverable, not a "later".

**Map every acceptance criterion to its check and paste the result** — the `acceptance-criteria-coverage` gate ([ADR 0022](../adrs/0022-acceptance-criteria-are-executable-checks.md)). The spec binds each criterion to a check (`test` / `command` / `manual`); the Builder honours that binding in `## Self-review`, listing each criterion, its bound check, and the pasted result of running it. A `test`-bound criterion counts only when its oracle is shown valid (fails when violated, passes when satisfied — proven by assertion-flip), never a tautology. A green toolchain suite proves the code is *well-formed*; this mapping proves it does what the spec *asked* — the difference between toolchain health and correctness.

## Behavioural angle: incremental validation

Per-batch validation exploits **immediate error signals**, shrinking the diff-to-defect linkage before the context window truncates and the agent forgets what it touched. It contrasts with the refactor discipline's neutral-behaviour stance: mixing feature work with refactoring statistically elevates regressions, because the refactor's behaviour changes hide behind the feature's expected acceptance noise.

## The Builder mindset lives here

There is no separate "Builder" persona skill. The implementing mindset — conservative, spec-faithful, halts rather than guesses — is carried by this skill itself (the personas catalogue lists Builder as one of the six mindsets carried by its matching workflow skill). Load `write-feature` and you have both the procedure and the stance.

## Why separate from the empirical-proof skill

`write-feature` carries the behavioural guardrails (survey, halt, no scope creep, per-batch cadence); `empirical-proof` carries the paste mechanics (verbatim output, one proof per claim, re-run after every change). They are orthogonal layers — feature work loads both, and neither subsumes the other.

## Command resolution

The skill resolves the project's validate and test commands by name through `AGENTS.md > Commands` (with an optional architectural dep-validation command outside the standard contract — ask the user if the project uses one). If `AGENTS.md` is missing or an entry is undefined, it asks the user which command to run rather than guessing.

## Failure signals

Repeated implementer blockers usually mean upstream spec debt, not a slow implementer — escalate to a spec-authoring loop rather than applying pressure. Project-specific rigor (stricter typing, extra lint gates) belongs in an overlay skill under `.agents/skills/domain/`, not in a fork of this one.

## Bundled resources

- `references/task-template.md` — a fillable feature-task template with progress checklist, decisions log, findings, blockers, next steps, and a Self-review hard gate. Copy it into your task file location, substitute the placeholders with project values, and fill it in as you work.

## Related

- [Builder persona rationale](../personas/the-builder.md) — the implementing mindset (carried by this skill; not shipped as a separate persona skill)
- [Task: feature](../tasks/feature.md)
- [Empirical-proof skill](empirical-proof.md)
