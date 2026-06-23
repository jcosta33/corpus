---
type: adr
id: adr-0088
status: accepted
created: 2026-06-20
updated: 2026-06-20
---

# ADR-0088 — Delegation provenance: a reviewable trace when an agent delegates to a subagent (neutral contract, runner-specific producers, fact-not-verdict)

## Context

Corpus's provenance and reviewability spine — ADR-0076 (worker provenance) and ADR-0077 (reconcile-only)
— covers human/lead → worker handoffs recorded in markdown, but **not agent → subagent delegation**: a
main agent spawning a Claude Code subagent, or handing off through the OpenAI Agents SDK. That
delegation leaves no reviewable trace today — who was delegated to, why, with what inputs, what context
was filtered, what tools it held, whether it could edit, what evidence it returned. Two gaps:
`swarm run` records only the launch envelope (`{task_id, adapter, worktree, branch, source, exit}`; the
`changed_files[]/commands[]` stream is the deferred D1 item), and **in-session subagents — spawned by
the parent through the runner's own Agent tool — never touch the CLI at all**.

swarm-hq #43 (the swarm-agents exploration) identified a reviewable delegation trace as the
genuinely-new, agent-neutral contribution a `swarm-agents` member would make.
`RFC-delegation-provenance` argued the approach; this ADR freezes the contract.

## Decision

1. **A delegation-provenance trace is a neutral, frozen contract.** Per agent → subagent handoff, a
   trace records exactly these fields, extending ADR-0076's Provenance line and the reserved run-record
   form (`docs/reference/future-cli.md`):
   - `worker` — the subagent / role identity (the adapter name, or the subagent definition's name).
   - `reason` — why it was delegated to (the task or instruction it received).
   - `inputs` — what it was given (the prompt / task; references it was pointed at).
   - `filtered` — what history / context was withheld (`fresh-context`, `inherited`, or a description).
   - `tools` — the tools it was granted.
   - `could_edit` — whether it could write / edit source (`true` / `false`).
   - `evidence` — what it returned (the result digest or an artifact reference).
   - `started` / `finished` / `exit` — timing and outcome, where the producer knows them.

2. **A trace is a record, never a verdict (ADR-0077 Decision 8).** No field carries
   Pass/Fail/Unverified/Blocked. A missing or thin trace is a human-attention fact, not a corruption —
   the human still owns the review result. *Level: convention (ADR-0063) this cycle — no checker mints
   it.*

3. **The contract is neutral; producers are runner-specific.** Two producers emit conformant data for
   the surface each can see:
   - **Producer 1 — `swarm run --agent` launches.** swarm-cli extends its run-record toward the D1 form:
     `changed_files[]` (the worktree diff after the agent exits) plus a `provenance` block carrying the
     fields it knows (`worker`/adapter, `reason`/task, worktree, isolation, `exit`). **Additive** — old
     run-records stay valid; no field becomes required. `commands[]` (the agent's internal commands) the
     interactive launcher cannot observe; it stays deferred.
   - **Producer 2 — in-session subagents.** A Claude Code `SubagentStart` / `SubagentStop` hook recipe
     appends a trace line to `.swarm/work/delegations.ndjson` — because in-session subagents bypass
     `swarm run` entirely. Runner-specific (Claude-Code-first); shipped as an opt-in recipe in the kit's
     `advanced/`, lower-staleness than agent frontmatter (a shell hook keyed to a stable event name).

4. **The trace audits delegation; it never runs it.** The producers ship records, never an executor.
   The only sanctioned launcher remains `swarm run --agent`, which never becomes the agent (ADR-0077). A
   launched run that bypassed both producers leaves no trace — so the *absence* of orchestration is
   observable. This is the structural defense against a hidden multi-agent runtime.

5. **Convention-first, not a check (yet).** No C0xx mint and no contract-version bump this cycle (the
   trace is a record, not a spec/review structure `swarm check` reconciles). A check ("a launched run
   recorded a provenance trace") is deferred to a separate decision, minted only if review keeps
   catching missing traces — the ADR-0063 anti-enforcement-theater rule and the ADR-0086/0087
   measure-first precedent.

## Alternatives considered

| Alternative | Why weaker |
|---|---|
| Do nothing (status quo) | Agent → subagent delegation stays unreviewable; the provenance/reviewability spine degrades as multi-agent work grows — the exact gap #43 found. |
| A multi-agent runtime / orchestrator that owns delegation | Violates ADR-0077 (no model loop, no center) and breaks the constellation (members depend on a hub). The trace audits delegation; it never runs it. |
| Provenance only in `swarm run`'s record (no hook producer) | Misses in-session subagents entirely — the majority of Claude-Code delegation never touches the CLI. The two-producer split is what makes the contract complete. |
| Mint a check (C0xx) requiring a trace now | Premature enforcement theater (ADR-0063); start as a convention/record and measure first (the ADR-0086/0087 precedent). |

## Consequences

Accepted: the delegation-provenance contract is canon — a neutral, verdict-free trace with a frozen
schema and two runner-specific producers. Honors ADR-0077 D8 (a fact, never a verdict), ADR-0063
(convention this cycle; toolable/enforced only on a later measured decision), and extends ADR-0076 plus
the `future-cli.md` run-record form. The producers — the swarm-cli run-record D1 extension and the
Claude Code hook recipe — land per `CHANGE-delegation-provenance`; the experimental `swarm-reviewer`
probe is the first subject to measure. Nothing is enforced — a missing trace never blocks anything —
until a future gate decides otherwise.

## Propagation

`docs/reference/future-cli.md` (the run-record `provenance` block references this contract) ·
`docs/adrs/README.md` (the index row) · `swarm-cli` (`swarm run` run-record extension — producer 1,
`CHANGE-delegation-provenance` W2) · `../swarm-starter-kit/advanced/` (the Claude Code hook recipe —
producer 2, W3). No `checks.yaml` change (convention-first). The swarm-hq workspace cuts and reviews the
producer tasks.
