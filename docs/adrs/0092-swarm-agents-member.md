---
type: adr
id: adr-0092
status: accepted
created: 2026-06-21
updated: 2026-06-23
---

# ADR-0092 — `swarm-agents`: a Claude-Code-first member of self-contained, useful worker definitions (records, never an executor; toolable-not-enforced)

> **Ledger note (2026-06-23):** the portable-layer hold here is **narrowed** by
> [ADR-0098](./0098-codex-emitter-and-universal-layer.md) — the Codex emitter + the universal
> `AGENTS.md` discipline ship now (the second runner, Codex, is real). The part this gate actually
> protected — **value measured across ≥2 real external runner teams** — is preserved unchanged as the
> honest exception. The founding Claude-Code-first stance stands; the emitter is an addition.

## Context

ADR-0088 froze the delegation-provenance contract and shipped two producers; a `swarm-reviewer` probe
and the producer-2 hook landed as experimental tenants in `swarm-starter-kit/advanced/.claude/`.
swarm-hq #43 left the standalone `swarm-agents` repo on a **do-not-found hold**
([FINDING-delegation-provenance-measurement]) gated on (1) **≥2 *demonstrated* runner projections** and
(2) **measured per-role value**.

A 2026-06-21 refresh ([SURVEY-swarm-agents-shipping]) confirms Claude Code subagents are a mature,
file-based authoring surface, and that the runner *ecosystem* matured (Copilot, Gemini CLI, Cursor are
file-based-agent runners). **Honest status: gate-1 is still UNMET** — it required ≥2 runners
*demonstrating swarm-agents' value*, and v1 is Claude-Code-only, so it demonstrates value on zero other
runners. The owner has decided to found the member now regardless. This ADR records that as a
**conscious override** of the unmet measure-first gate, conditioned on a post-ship measurement wave —
not a claim that the gate cleared.

## Decision

1. **Found `swarm-agents`** — a derived-content, markdown-only family member (sibling to swarm-skills;
   no runtime, no checks). It ships **Claude-Code-first** worker definitions for Corpus roles, the
   producer-2 delegation hook, a read-only-guard hook, and the evidence docs behind them.

2. **The model: self-contained, *useful* worker definitions — persona-optional.** Each `swarm-*` agent
   is selected on **usefulness as a delegated subagent** (where fresh-context isolation + tool-scoping +
   the trace add value), not on mapping to a persona. Each agent body **carries its own discipline**,
   grounded in the durable canon ADRs (ADR-0056 self-review, ADR-0077 reconcile-only/no-verdict,
   ADR-0088 trace), and **stands alone** — it does not depend on the swarm-skills personas (whose own
   quality is a separate, later evaluation). An optional one-line "pairs with persona-X / the Y guide if
   you use them" see-also is allowed; nothing is load-bearing on it. People copy the one agent they need.

3. **Two honesty tiers (ADR-0063 levels).** *Tier 1 — read-only:* the `tools` allowlist excludes
   Edit/Write and a `PreToolUse` guard blocks write-ish Bash; this is **toolable/partial** — it narrows
   the surface, it does not guarantee behavior (the inherit-all default, a parent in
   `bypassPermissions`/`acceptEdits`/`auto`, fork mode, plugin-loaded subagents that ignore hooks, and
   bare-name-Bash-deny bypasses such as claude-code#25000 all defeat it). *Tier 2 — bounded authoring:*
   value is the baked-in discipline + isolation + the trace, **explicitly not enforcement**. **Nothing
   in swarm-agents is labeled "enforced."** A trace + scoping buys reviewability/attribution, not a
   behavioral guarantee.

4. **Records, never an executor (ADR-0077/0088 spine).** A catalog of definitions + a hook are records;
   they run nothing. The only sanctioned launcher stays `swarm run --agent`, which never becomes the
   agent. swarm-agents is **not** an orchestrator/runtime; the absence of orchestration stays
   observable. The README must not present it as a runtime.

5. **Producer-2 home moves to `swarm-agents`.** The delegation hook (ADR-0088 producer 2) relocates from
   `swarm-starter-kit/advanced/` to `swarm-agents`; the kit redirects to it; the `swarm-reviewer` probe
   is promoted (single source — removed from the kit). **This supersedes the producer-2 destination in
   ADR-0088's Propagation line; ADR-0088's body is left intact** (it remains the contract of record).

6. **Convention-first; founding conditioned on measurement.** No `checks.yaml` change (ADR-0088 D5
   holds). The override carries a **measurement wave** running [FINDING-delegation-provenance-measurement]'s
   protocol (enforcement-vs-prose, trace utility, non-redundancy) on the shipped agents; a role that
   shows no value is trimmed. That wave is the honest condition on "found now, measure later."

## Alternatives considered

| Alternative | Why weaker |
|---|---|
| Keep the probe + hook in the kit's `advanced/` | Diverges from the family pattern (every other capability is its own member); leaves swarm-agents permanently "experimental" with no home for the broader catalog. |
| A portable cross-runner format now | No shared schema exists (field sets diverge; enforcement/provenance don't travel) — [SURVEY-swarm-agents-shipping] F5. Claude-Code-first + later mapping docs is the honest scope. |
| Wait for measured value before founding | The measure-first gate; the owner chose to ship on ecosystem readiness + product judgment, conditioned on the post-ship measurement wave. Recorded as an override, not a met gate. |
| Make agents projections of the personas | The personas' own quality is unaudited; coupling swarm-agents to them imports that risk. Self-contained, canon-grounded agents stand alone (Decision 2). |

## Consequences

Accepted: `swarm-agents` is a founded, Claude-Code-first family member of self-contained useful worker
definitions, honestly scoped (toolable/partial for read-only; discipline+isolation+trace for authoring;
nothing "enforced"), honoring ADR-0077 D8 (a record, never a verdict) and ADR-0063 (levels). The
producer-2 hook + the `swarm-reviewer` probe move there; the kit redirects. The founding is an explicit
override of an unmet measure-first gate, conditioned on a measurement wave that can trim the catalog.
ADR-0088 remains the contract of record; only its producer-2 *destination* is superseded here.

## Propagation

`swarm/docs/adrs/README.md` (the index row) · `swarm-starter-kit/advanced/README.md` (redirect to
`swarm-agents`; remove the promoted probe) · `../swarm-agents/` (the new member: agents, hooks,
docs) · `swarm/CLAUDE.md` + `../swarm-hq/CLAUDE.md` (governed-repos list) · `../swarm-hq/status.md`
(board) · the swarm-hq workspace cuts/reviews the build waves ([specs/swarm-agents/spec.md]). No
`checks.yaml` change (convention-first).
