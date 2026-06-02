# ADR 0005: Placeholder syntax `{{name}}`

## Status

Accepted

## Context

Templates must bind to project-specific commands and paths without hardcoding tooling (pnpm vs cargo vs maven).

## Decision

Use **mustache-style** placeholders: `{{cmdValidate}}`, `{{slug}}`, etc., resolved from `AGENTS.md` / project conventions. Agents never invent concrete commands inside framework templates.

## Consequences

- Positive: language-agnostic scaffolds; one framework repo serves many stacks.
- Negative: launcher or human must fill bindings — undocumented placeholders are blocked at pre-flight where enforced.
