---
type: adr
id: adr-0098
status: accepted
created: 2026-06-23
updated: 2026-06-23
---

# ADR-0098 — Portability: ship a Codex emitter + the universal AGENTS.md discipline; drop Antigravity

## Context

[ADR-0092](./0092-corpus-agents-member.md) founded corpus-agents as a **Claude-Code-first**
agent-definition catalog and held a portable layer behind a "do-not-found" gate (needs ≥2 runners
demonstrating value). The prior deep-research survey (corpus-hq) found the gate's second-runner question
is now answerable: **OpenAI Codex** reads file-based agent definitions (`.codex/agents/*.toml`,
`developer_instructions` + optional `model`), and **`AGENTS.md` is an open cross-tool format** read by
Codex, Cursor, Copilot, Gemini CLI, and Aider. The owner directed building the portable layer now —
**Codex + the universal layer, drop Antigravity, reuse as much as possible and duplicate as little.**

## Decision

**Ship a Codex emitter as a generator over the single-source definitions, formalize the `AGENTS.md`
universal-discipline layer, and drop Antigravity. Enforcement does not travel — only the prose
discipline.**

1. **Codex TOML emitter — `corpus agents emit --codex`** (corpus-cli). Reads the corpus-agents
   `agents/*.md` definitions and **generates** `.codex/agents/<name>.toml` (`developer_instructions` =
   the markdown body). It is **reuse, not duplication**: the `agents/*.md` files stay the single source;
   the TOML is generated, so the two never drift by hand (re-run to regenerate; the files say "do not
   hand-edit"). No agent is launched and no network is touched — it emits a definition, never runs one,
   so the reconcile-only posture holds ([ADR-0077](./0077-corpus-cli-reconcile-only-harness.md)). It is a
   **runner adapter** (like `corpus run`'s launcher), so it lives in corpus-cli's Workspace leaf, NOT the
   agent-agnostic Core — naming a runner is exactly what Core's boundary forbids.

2. **The universal `AGENTS.md` discipline layer** (corpus-agents). The shared discipline — evidence over
   assertion ([ADR-0056](./0056-adversarial-self-review-completion-discipline.md)), reconcile-only /
   no self-issued verdict (ADR-0077 D8), the delegation trace as reviewability not a guarantee
   ([ADR-0088](./0088-delegation-provenance.md)), honesty levels
   ([ADR-0063](./0063-honesty-framework-and-tooling-boundary.md)) — is single-sourced in corpus-agents'
   `AGENTS.md`, which is the open format that ports to every AGENTS.md-reading runner. The per-worker
   `agents/*.md` files are the Claude-Code specialization of that universal contract. **No
   hand-duplicated per-worker `SKILL.md`** is added (it would duplicate the bodies, against the
   reuse-don't-duplicate directive); the universal layer is the AGENTS.md prose + the emitter.

3. **Enforcement does not travel — honest scope** ([ADR-0063](./0063-honesty-framework-and-tooling-boundary.md)).
   The `tools` allowlist and the `hooks/` (read-only guard, delegation trace) are **Claude-Code
   structural mechanisms** — they do not port. Every emitted Codex file carries a header saying so; a
   Codex adopter gets the prose discipline and scopes tools in their own config. Level for the emitter
   and the universal layer: **toolable** (the tool is `corpus agents emit`). The portability claim is
   "the discipline is portable," never "the enforcement is portable."

4. **Drop Antigravity.** Google Antigravity's managed agents are configured **programmatically**, not
   via a portable definition file, so there is no honest file-emitter target. The universal `AGENTS.md`
   discipline reaches it without an adapter; building an Antigravity emitter would be inventing a file
   format Antigravity does not consume. No Antigravity emitter ships.

5. **The measurement wave stays the honest exception** (ADR-0092's gate). Demonstrating value across ≥2
   _real external_ runner teams is un-fabricatable; it remains a standing owner-run activity, recorded
   as the named exception — not a build item.

## Consequences

- corpus-cli gains the `agents` command (`emit --codex`), a `codexToml` renderer + `emit_agents` engine
  in the Workspace leaf, the catalog entry, and the dispatch parity (AC-004). Hand-rolled TOML (no
  dependency); the `"""`-escaping is tested (a body with `\`, `"`, and `"""` round-trips).
- corpus-agents' `AGENTS.md` gains a **Portability** section (the universal layer + what does/doesn't
  travel); `docs/runners.md` is refreshed to "Codex emitter shipped."
- The Claude-Code-first founding stance is preserved: Claude Code reads the `agents/*.md` natively; the
  emitter is an _addition_ for a second runner, not a re-platforming.
- This is a conscious owner override of ADR-0092's hold-until-2-runners gate, narrowed: the **emitter +
  universal layer** ship now (the second runner, Codex, is real and the cost is a generator); the
  **value-measurement wave** — the part the gate actually protected — stays the honest exception.
