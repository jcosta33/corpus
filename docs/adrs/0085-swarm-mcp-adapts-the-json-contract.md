---
type: adr
id: adr-0085
status: accepted
created: 2026-06-18
updated: 2026-06-18
---

# ADR-0085 — corpus-mcp adapts the CLI's `--json` contract (shells out), not the core library

## Context

ADR-0077 (the reconcile-only harness) and `future-cli.md` § "Beyond the loop" sketch a **Corpus MCP
server** that exposes the task packet's scope, parsed requirements, and the checks contract to any
MCP-capable agent — described there as _reusing the reconcile-only core library without shelling out_.
When the MCP server (`corpus-mcp`, a sibling package — the family's "many libraries, not a framework"
shape) was actually built, the opposite coupling was chosen: it **shells out** to the `corpus` CLI's
public `--json` contract rather than importing corpus-cli's internals. This ADR records that deviation
so it is explicit, not silent (the implementing review flagged that an ADR was owed).

## Decision

`corpus-mcp` is a **thin MCP stdio adapter over the `corpus` CLI's `--json` interface**. It spawns
`corpus <cmd> --json` with a fixed argv array (a controlled subprocess — never a shell string, never a
client-injected flag) and reshapes the output into MCP tools/resources/prompts. It **does not import
corpus-cli's Core**. The two repos couple only through the public, tested `--json` contract.

Why this over ADR-0077's "reuse the core library" sketch:

1. **Footprint.** The MCP SDK pulls ~16 transitive dependencies; keeping it in a separate package
   preserves corpus-cli's deliberate 2-runtime-dependency minimalism — every CLI user would otherwise
   pay an 8× dependency tax for a server they may never run.
2. **"Many libraries, nothing entirely depends on anything else."** A tool coupled through another's
   public JSON interface does not _entirely depend on_ it; importing the core library would tie
   corpus-mcp to internal module shapes that are not a stable library API.
3. **Parse in one place (no drift).** All Corpus semantics stay in corpus-cli Core, surfaced as `--json`;
   corpus-mcp re-parses nothing. A zod **drift tripwire** in corpus-mcp guards the consumed shapes, so a
   CLI change fails a test rather than silently producing wrong output.
4. The read surface corpus-cli grows to feed this (a `corpus show <task|spec|review|checks> --json`
   family, wrapping parsers that already exist) is **independently useful** — scriptable reads in their
   own right.

## Alternatives considered

| Alternative                                                    | Why weaker                                                                                                                                                                                                                                                                                                        |
| -------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Import the reconcile-only core library** (ADR-0077's sketch) | Couples corpus-mcp to corpus-cli's _internal_ modules (no published, stable library API today), pulls corpus-cli + its tree as a dependency, and ties their versions. The public `--json` contract is the looser, already-tested seam. Rejected for v0; revisitable if a `corpus-core` library is ever extracted. |
| **Build the MCP server inside corpus-cli**                     | Imposes the MCP SDK's ~16-dep, 8× footprint expansion on every corpus-cli install, and introduces a persistent event-loop process model into an otherwise request-response CLI. Rejected — it taxes users who never use MCP and dilutes the footprint that is part of corpus-cli's identity.                      |
| **Extract a shared `corpus-core` package now**                 | The cleanest long-term coupling, but a premature, large refactor before the MCP value is proven. Deferred.                                                                                                                                                                                                        |

## Consequences

Accepted. **Refines ADR-0077 D1a**: the MCP server adapts the CLI's `--json` contract rather than
importing the core library. corpus-cli stays read/reconcile-only and minimal-footprint, and grows a
small, independently-useful `corpus show … --json` read family (the loader surface the MCP needs).
`corpus-mcp` is its own package, independently versioned, carrying the MCP SDK's dependencies alone. The
reconcile-only boundary (ADR-0077 D8) holds end to end — corpus-mcp issues no verdict and writes nothing;
it relays the CLI's facts (and the human-recorded board state) verbatim under a `noVerdictIssued`
guarantee. Neutral: one subprocess per tool call (acceptable for interactive single-agent use; the
synchronous `spawnSync` blocks the event loop during each ~tens-of-ms call — a recorded v0 limitation,
a candidate async refactor if concurrency is ever needed). Honors ADR-0063 (the adapter claims a level,
never enforcement).
