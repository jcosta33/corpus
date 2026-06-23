---
type: adr
id: 0038-verify-by-adapters-through-commands
status: accepted
created: 2026-06-02
updated: 2026-06-02
supersedes: [0018]
superseded_by:
---

# ADR-0038: VERIFY BY adapters resolve through AGENTS.md Commands

## Context

Pre-kernel Corpus faced a portability problem: an obligation that wants to be proven must name a command to run, but the command line is project-specific (`npm test` vs `cargo test` vs `mvn verify`). [0018](./0018-agents-md-command-contract.md) answered this for *skills* — skill bodies referenced commands by contract name, resolving through an `AGENTS.md > Commands` table — but it framed the indirection around skill prose and `{{cmd*}}` template placeholders, not around a verification binding. The kernel removes skills as semantic owners (§26) and makes the proof binding (`VERIFY BY`) the thing that names a command. That leaves [0018](./0018-agents-md-command-contract.md)'s good idea — one Commands table as the single source of truth — bound to a surface the kernel no longer uses. §15 and §31.3 re-anchor the same indirection on the kernel's actual proof model.

## Decision

A `VERIFY BY <type>:<adapter>:<artifact>` clause names a closed, analyzable proof `<type>` (§15.1) and a project free-string `<adapter>`; the `<adapter>` resolves to a `cmd*` slot in the consuming repo's `AGENTS.md > Commands` table (§15.3, §31.3). This is the framework's **single indirection** binding an abstract, portable proof to a concrete project command:

- The **obligation layer** (SOL, in `*.md`) declares *what kind of proof* and *which logical command + artifact* prove the obligation. `<type>` is closed and lint-typed; `<adapter>` and `<artifact>` are free strings, so the obligation ports across repos unchanged.
- The **project layer** (`AGENTS.md > Commands`) names the concrete command for *this* repo. The `cmd*` placeholder rows **are** the adapters; only this table changes when a `spec.md` moves between repos. Naming a repository's commands in the context file — rather than narrating them — is the contract that makes those commands reliably reachable [[AGENTSMD-HARM]](../research/sources.md#AGENTSMD-HARM).

A binding whose `<adapter>` has no matching Commands row is `SOL-V002` (proof-not-executable), which surfaces as `BLOCKED` at the merge gate (§14.4), not `PASS` — the missing binding is recorded as honestly unknown, never silently passed. The Commands table is **soft control** (§17): it names what a future launcher *would* run; the kernel ships no runtime, and `AGENTS.md` MUST NOT claim it enforces or runs these commands (§31.3). The full proof taxonomy, binding grammar, default proof-type → `cmd*` mapping, and the Commands contract are specified in §15.1–§15.3 and §31.3.

## Alternatives considered

| Alternative | Why rejected |
| --- | --- |
| Hardcode concrete commands in the `VERIFY BY` clause | Forks the obligation per stack and leaks tooling into a portable spec; the same `spec.md` would no longer port across repos (§15.3 rationale). |
| Keep [0018](./0018-agents-md-command-contract.md)'s skill-prose indirection (commands named in skill bodies) | The kernel removes skills as the carrier of command references; skills are pass guides that MUST NOT own semantics (§26.1). Binding the indirection to a skill body leaves it on a surface the kernel no longer uses. |
| Put the concrete command in the proof `<type>` | `<type>` is the closed, IR-typed, analyzable dimension (§15.1); putting a project command there would make the closed set un-closeable and break cross-repo portability. |
| Resolve `<adapter>` against a per-repo runtime config the kernel ships | Corpus ships no runtime (§2); there is nothing to resolve against. The resolution target must be a markdown fact a human or future launcher reads — the `AGENTS.md` table. |
| Treat a missing adapter binding as `PASS` (assume the proof exists) | Shape is not truth (§2); an unresolved adapter proves nothing. It must read as `BLOCKED`/`SOL-V002`, the honest "could not run" (§14.1.1, §31.3). |

## Consequences

### Positive

- One indirection, one source of truth: the proof type stays in the portable obligation, the command stays in `AGENTS.md`, so a spec moves between repos by changing only the Commands table (§15.3).
- The `<type>` segment is closed and analyzable, so a conformant tool can apply type-selection rules (§15.4), the proof-strength order (§15.6), and per-task default suites (§15.8) without ever reading a concrete command.
- An unresolved adapter is a typed, locatable defect (`SOL-V002` → `BLOCKED`), not a silent gap — the contract makes the missing binding conspicuous at the gate.

### Negative

- A consuming repo MUST populate the Commands table for every proof type any `VERIFY BY` clause references; a missing required `cmd*` row blocks verification (and is a negative conformance-fixture class, §33).
- Two surfaces must stay coherent — the obligation's `<adapter>` and the `AGENTS.md` slot — and the binding is only as trustworthy as the human/launcher that keeps them aligned (no runtime checks this today).

### Neutral / tradeoffs

- The resolution is markdown-only and soft control today (§2, §17): the adapter "resolves" by a human or future launcher reading the table; the contract specifies what a conformant tool MUST honour, not anything that runs now.

## Status

Accepted (v0.1).

Supersedes ADR-0018 (recasts "commands resolve through the `AGENTS.md` contract" from a skill-prose indirection onto the SOL `VERIFY BY` model: the `<adapter>` segment of a proof binding is the thing that resolves through `AGENTS.md > Commands`, and the `cmd*` slots are the adapters).

## Affected obligations / constraints

- Adds: the two-layer `VERIFY BY <type>:<adapter>:<artifact>` resolution — closed proof `<type>` + project `<adapter>` resolving to an `AGENTS.md > Commands` `cmd*` slot (§15.3); the unresolved-adapter defect `SOL-V002` → `BLOCKED` disposition (§31.3, §14.4).
- Modifies: the `AGENTS.md > Commands` contract is now consumed by `VERIFY BY` adapters rather than by skill-body prose references (§31.3).
- Supersedes: ADR-0018's skill-prose command indirection and its `{{cmd*}}` placeholder framing — command resolution is now anchored on the proof binding, with the `cmd*` rows serving as the proof adapters (§15, §31.3).
