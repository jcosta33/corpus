---
type: adr
id: 0027-sol-is-the-obligation-language
status: accepted
created: 2026-06-02
updated: 2026-06-02
supersedes:
superseded_by:
---

# ADR-0027: SOL is the obligation language

## Context

In a prose-first model, obligation force is carried by ordinary English: a paragraph that says "the client must clear the session" is indistinguishable in form from one that says "the client should probably clear the session," and a reader (human or model) must infer which words bind. That inference is unstable — the same hedged requirement yields functionally divergent implementations across runs (§6.5). It also leaves no machine-detectable boundary between a binding span and surrounding commentary, so there is no precise place for verification bindings, modality, actor, or trigger to live. Three competing research grammars (EARS, FRETish, Gherkin) each proposed a leading-keyword shape, but none was adopted as *the* single home of obligation semantics (§5.1). Corpus needs one place where "this binds, with this force" is structurally true rather than inferred.

## Decision

SOL — bare-header obligation blocks of the exact form `TYPE PREFIX-NNN:` (§5.2) — is the single home of obligation semantics. The language is closed and fixed: exactly **seven block types** (`REQ`, `CONSTRAINT`, `INVARIANT`, `INTERFACE`, `QUESTION`, `TRACE`, `VERDICT`), of which three carry binding force (`REQ`, `CONSTRAINT`, `INVARIANT`) (§6); and exactly **five modals** (`MUST`, `MUST NOT`, `SHOULD`, `SHOULD NOT`, `MAY`), uppercase and case-sensitive (§5.6). A span is *binding* iff it lies inside a binding block, and *commentary* otherwise (§5.9). Load-bearing meaning — modality, actor, trigger, verification binding — MUST live in SOL blocks; prose is APS commentary around SOL, and lowercase `must`/`should`/`may` carry no normative force (§5.5, §5.9). The full specification is §5 (surface syntax) and §6 (the per-block clause grammars).

## Alternatives considered

| Alternative | Why rejected |
| --- | --- |
| Obligation force in prose (lowercase `must`/`should`) | No machine-detectable binding boundary; the same hedged requirement diverges across runs. Lowercase modals are plain prose with no force (§5.5, §6.5). |
| Adopt one research grammar wholesale (EARS / FRETish / Gherkin) | Each is a partial surface; none is a closed obligation language with a fixed block + modal + verification model. SOL's line-oriented grammar supersedes all three (§5.1). |
| Fenced block delimiters (`:::REQ … :::END`) | A second nested fence is fragile to parse inside Markdown and redundant with the bare-header rule (§5.4). |
| In-block YAML metadata (`verify:` as a YAML key) | Splits one obligation across two syntaxes and breaks the line-grouping rule; clauses are inline keyword lines instead (§5.4). |
| Admit `SHALL`/`SHALL NOT` as distinct modals | RFC 2119 makes `MUST` ≡ `SHALL`, so `SHALL` is redundant and read inconsistently elsewhere; the closed modal set is the five `MUST`/`MUST NOT`/`SHOULD`/`SHOULD NOT`/`MAY`, and `SHALL` is not among them (§5.6). |
| Allow `CAN`/`WILL` as binding | Capability and prediction carry no obligation force and invite ambiguity; forbidden in binding clauses (§5.6). |

## Consequences

### Positive

- "Does this bind, and with what force?" is answered by structure (block type + uppercase modal), not by reading intent into prose.
- A conformant tool has one well-defined surface to parse for obligation semantics; the binding/commentary boundary (§5.9) is exactly where lint codes, verification bindings, and the lower pass attach.
- The closed keyword set (seven types, five modals) is small enough to learn and stable enough to build conformant tooling against.

### Negative

- Authors MUST learn a constrained keyword surface rather than write free prose; ordinary English no longer binds, by design.
- Meaning is partitioned: anything load-bearing left in prose silently loses force, which the binding/commentary rule makes a discipline authors must keep.

### Neutral / tradeoffs

- SOL fixes the *force* model only; conditions remain opaque text in v0.1 (§5.5) and the expression sublanguage is deferred — recorded here as the present scope, not a gap.
- Surface SOL is the only authored form; the snake_case IR is emitted, never written (§5.1), so this decision governs what humans write, not the lowered representation.

## Status

Accepted (v0.1).

## Affected obligations / constraints

- Adds: SOL as the single home of obligation semantics — the closed seven-block, five-modal surface (§5–§6); the binding-vs-commentary boundary (§5.9).
- Modifies: prose's role — it is APS commentary around SOL, never the carrier of obligation force (§5.5, §5.9).
- Supersedes: nothing.

> **Ledger note (2026-06-11):** partially superseded by ADR-0058 (SOL becomes the optional stricter surface, a notation).
