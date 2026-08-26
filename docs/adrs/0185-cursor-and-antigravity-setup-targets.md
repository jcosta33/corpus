---
type: adr
id: adr-0185
status: accepted
created: 2026-08-17
---

# ADR-0185 - Cursor and Antigravity setup targets

## Context

[ADR-0175](./0175-single-context-gateway.md) named Codex, Claude Code, Kimi Code, ZCode, and OpenCode
as explicit setup targets. Cursor and Antigravity now have documented user-level instruction files
[[CURSORRULES]](../research/sources.md#CURSORRULES)
[[ANTIGRAVITYRULES]](../research/sources.md#ANTIGRAVITYRULES).

## Decision

1. **Add two identifiers.** `suspec setup` accepts `cursor` and `antigravity` beside the existing
   explicit harness names.
2. **Cursor uses the documented file-backed user-rule directory.** Setup writes
   `~/.cursor/rules/AGENTS.md`. It requires `~/.cursor`. If `~/.cursor/rules` is missing, install
   creates that one leaf directory. If the path exists and is not a safe directory, setup stops.
   Account-synced Settings User Rules stay unobservable and do not redirect installation.
3. **Antigravity uses the documented global rules file.** Setup writes `~/.gemini/GEMINI.md`. It
   does not chase `AGENTS.md`, Antigravity subdirectories, or workspace `.agents/rules`.
4. **Keep the rest of setup unchanged.** Check, preview, `--yes`, reversal, envelope version, and
   the absent MCP surface do not change.

## Narrowed decisions

- [ADR-0174](./0174-fixed-native-instruction-targets.md): ordinary native files remain the targets;
  Cursor and Antigravity now have named files.
- [ADR-0175](./0175-single-context-gateway.md): the explicit target set grows by those two names.

## Consequences

- Cursor and Antigravity receive the same policy bytes as the other harnesses.
- Gemini CLI shares `~/.gemini/GEMINI.md`; setup reports that fact and still uses the documented
  Antigravity file.

## Status

Accepted (2026-08-17). Narrows ADR-0174 and ADR-0175.
