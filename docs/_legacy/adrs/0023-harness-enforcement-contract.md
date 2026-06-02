# ADR 0023: The harness-enforcement contract (what a compliant runtime must honour)

## Status

Accepted

## Context

The [agents-as-compiler readiness audit](../../.agents/audits/agents-as-compiler-readiness.md) found that Swarm's confidence gate is **self-attested**: the agent runs a command and pastes the output into the task file. The `empirical-proof` skill itself concedes the output is "still gameable with fabricated output" and vulnerable to "selective tail-paste." Nothing mechanically re-runs the verifier or blocks promotion on failure, because Swarm has no runtime ([PRINCIPLES.md](../PRINCIPLES.md) #1, [0017](./0017-no-always-load-skills.md)). The framework's strength is *conspicuousness* — an empty paste block is visible where a confident "✅" is not — not *enforcement*.

The over-claim was framing this discipline as a "hard gate" / "non-negotiable" without stating that, absent a re-running harness, the gate is the agent grading itself. The framework cannot ship an enforcer, but it *can* specify the contract a compliant runtime (the Swarm CLI, or any launcher) must honour — turning "discipline" into an enforceable interface for anyone who builds the runtime.

## Decision

The framework **specifies** (does not ship) a harness-enforcement contract. A launcher is **enforcement-compliant** if it:

1. **Re-runs the bound `{{cmd*}}` commands** for each required slot in the task's verification suite ([0021](./0021-verification-contract.md)) in a clean checkout — it does not trust the agent's pasted output.
2. **Blocks promotion** (`status: done` / merge) on any required check exiting non-zero, on any `[Paste output]` slot left empty or placeholder, or on any `[CRITICAL]` open question outstanding.
3. **Emits a tamper-evident trace** — command, exit code, and output captured by the harness (not transcribed by the agent), so a human can spot-check by exception rather than re-deriving trust from prose the agent chose to paste.

The `AGENTS.md > Commands` table ([0018](./0018-agents-md-command-contract.md)) is the attachment point: the harness binds the same slots the agent references. Where no harness is present, the gate degrades to its self-attested form — and the docs must say so plainly (see Consequences). This contract is the **enforcement** half of the compiler goal; [0021](./0021-verification-contract.md) is the **specification** half (which checks), [0022](./0022-acceptance-criteria-are-executable-checks.md) the **intent** half (checks that encode the spec).

## Consequences

- Positive: gives the future Swarm CLI (or any launcher) a precise, testable interface — the framework defines *what enforcement means* without becoming a runtime.
- Positive: lets the docs state the honest boundary — "self-attested unless a harness enforces it" — wherever the gate is claimed, instead of implying compiler-grade enforcement the prose layer cannot deliver.
- Negative: until a compliant harness exists, the gate remains self-attested; this ADR raises the ceiling (a defined enforcement target) without, by itself, reaching it.
- Negative: a tamper-evident trace implies the runtime, not the gitignored task file, is the audit surface — a shift consumers should understand.

## Alternatives rejected

- **Call empirical-proof a "hard gate" and stop.** The audit's BLOCKER-adjacent finding: it over-claims enforcement the markdown layer cannot provide, and never names the self-attestation reality where the claim is made.
- **Build the enforcer into this repo.** Violates Principle 1 (no runtime). The contract belongs in the framework; the enforcer belongs in the CLI.
- **Drop the confidence claim entirely.** Throws away the real value (conspicuousness + a defined enforcement target). Scoping the claim honestly and specifying the contract keeps both.
