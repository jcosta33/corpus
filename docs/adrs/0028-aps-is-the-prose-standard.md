---
type: adr
id: 0028-aps-is-the-prose-standard
status: accepted
created: 2026-06-02
updated: 2026-06-02
supersedes:
superseded_by:
---

# ADR-0028: APS is the prose standard

## Context

A Swarm spec is mostly prose: the words that surround, introduce, and accompany SOL obligation blocks. In the pre-kernel model nothing said whether that prose *bound* anything. A reader — human or agent — could not tell which sentence was a load-bearing requirement and which was commentary, so a vague adjective in a paragraph and a vague adjective inside an obligation read as equally authoritative. Prose is also the least stable carrier of meaning a future conformant tool will encounter: §7.6 anchors APS on five durable mechanisms — format/order sensitivity, multi-turn decay, lost-in-the-middle context rot [[LOSTMID]](../research/sources.md#LOSTMID), always-on density cost, and requirement-ambiguity degrading generated code — none of which a dated capability number can paper over. Without a standard for prose, the typed SOL surface could be silently contradicted, diluted, or competed with by the words around it.

## Decision

APS (Agent Prose Semantics) is the controlled-prose standard for everything in a Swarm artifact that is *not* a SOL block (§7). Its doctrine is the authority rule (§7.1): all load-bearing meaning MUST live in SOL blocks and the typed IR; prose, skills, personas, and `AGENTS.md` are non-authoritative delivery layers that carry context and guidance but never binding force. A conformant tool, author, or downstream agent MUST NOT treat any prose span as a source of an obligation, verdict, verification requirement, or authority ranking — if a fact is load-bearing it MUST be promoted into a typed block; until it is, it has no force. APS constrains how prose is written (word-economy §7.1.2, conformant properties §7.1.3, the high-risk word catalogue §7.3, the same-line-makes-it-observable rule §7.4) so prose can never compete with or contradict an obligation, and maps each prose rule family to a `SOL-P` lint code (§7.5). The full specification is §7.

## Alternatives considered

| Alternative | Why rejected |
| --- | --- |
| Let prose carry obligation force directly (no SOL/prose split) | Prose is an unreliable carrier across turns and agents — format/order sensitivity, multi-turn decay, and context rot (§7.6) — so binding on it makes meaning unstable; only the typed surface is stable enough to bind on (§7.1.1). |
| Apply prose rules uniformly everywhere, ignoring position | The force of an APS rule depends on *where* a span sits; a vague word in commentary merely explains, while the same word inside an obligation changes what gets built. A uniform rule would either over-block commentary or under-protect binding clauses (§7.2). |
| Resolve vague wording by open-ended stylistic rewriting | The defect is a *missing observable criterion*, not bad style; only the named `CONCRETIZE`/`QUANTIFY` improve operations with an explicit exit condition close `SOL-P005`. Free rewriting has no exit condition and may drift from intent (§7.4). |
| Keep the `APS-` code prefix for prose diagnostics | One greppable namespace (`SOL-<LAYER><NNN>`) serves one tool; "APS" survives only as the *name* of the standard and MUST NOT appear in any diagnostic code (§7.5, §8.5). |
| Anchor the density discipline on a model-accuracy ceiling (a dated instruction-following benchmark figure) | No such figure is cited as a capability ceiling; the standard rests on a durable adherence-and-cost mechanism, not a transient number that ages out (§7.6). |

## Consequences

### Positive

- A reader always knows where authority lives: in SOL blocks, never in the surrounding prose. Prose can be loose where it only explains and is held strictly where it would otherwise bind.
- Prose can never silently contradict or dilute an obligation, because it carries no obligation force to contradict *with* (§7.1.1).
- The binding/commentary boundary is decidable from block type alone (§7.2), so a future conformant tool needs no heuristic to know which force to apply.

### Negative

- Authors must internalise the discipline: any load-bearing intent left in prose has *no force* until promoted to a typed block, so a paragraph that "obviously" states a requirement still binds nothing.
- The high-risk word catalogue and same-line rule add authoring friction inside binding clauses; a vague word there is blocking until repaired by a named improve op.

### Neutral / tradeoffs

- Prose remains a first-class delivery layer — it is not banned, only de-authorised. Context, rationale, and retrieval keywords still belong in prose; the word-economy rule (§7.1.2) governs which words earn their place.
- Position-sensitive codes (e.g. `SOL-P056`) carry two severities — advisory in commentary, blocking in a binding clause — which a tool and author must track per span.

## Status

Accepted (v0.1).

## Affected obligations / constraints

- Adds: the prose-authority contract (all load-bearing meaning lives in SOL/IR; prose is a non-authoritative delivery layer carrying no obligation force) and the binding-clause-vs-commentary boundary as the standard governing all non-SOL prose (§7).
- Modifies: none.
- Supersedes: none.
