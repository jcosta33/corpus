# ADR 0016: Skill bodies are self-contained

## Status

Accepted

## Context

Skills are vendored à la carte: a consumer copies the subset of `/scaffold/.agents/skills/` their work needs and leaves the rest. A `SKILL.md` body that links a sibling skill, or points at a framework-internal path (`.agents/...`, `docs/agents/...`), assumes a layout the consumer may not have reproduced.

Anti-pattern catalogues converge on this as the **Reference Illusion**: a skill referencing files or skills that aren't guaranteed to exist on the consumer's machine, leaving a dead reference that silently degrades behaviour rather than failing loudly. The agent reads instructions pointing at something that isn't there and quietly does less.

## Decision

A `SKILL.md` **body** is self-contained. It carries no cross-skill "See also" links and no framework-internal paths. Anything a sibling skill would have supplied is **restated inline** in the prose that needs it.

The two permitted outward references are deliberate and portable:

- the consuming repo's **`AGENTS.md > Commands`** entries (the command contract — see [0018](./0018-agents-md-command-contract.md)), which a vendored repo is expected to provide and which degrade gracefully when absent; and
- the skill's own **`references/`** directory (its task template / worked example / evasions list), which ships *with* the skill.

This rule binds the `SKILL.md` body only. Documentation under `docs/` may cross-link freely — self-containment is a skill-portability constraint, not a docs constraint.

## Consequences

- Positive: any subset of skills vendors cleanly; no dead links, no assumed sibling, no assumed repo layout.
- Positive: each skill reads as a complete unit, which is also how the model consumes it at activation time.
- Negative: deliberate duplication across skills (shared discipline restated rather than linked) — accepted as the cost of portability, and kept honest by the distillation discipline that governs what gets copied where.

## Alternatives rejected

- **Link the sibling skill ("see `write-fix`").** Concrete and shorter, but structurally wrong: a consumer who vendored only one of the two has a body that names a skill that isn't loaded. The Reference Illusion in its purest form.
- **Point at the framework docs for the shared rule.** Couples the skill to a `docs/` tree the consumer never copied; the same dead-reference failure, one directory over.
