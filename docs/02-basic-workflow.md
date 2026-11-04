# Workflow

## Pick the skill the work needs

Campaigns own one durable multi-pull-request goal. Specs own verifiable intent. Drill locks one
seam before write. Change plans own staged preservation and rollback. Independent review is a
non-implementer on the native PR.

## Trivial work

State the correction and proof inline:

```text
Fix: expired refresh tokens must redirect to /login, not 500.
Verify with: pnpm test:run auth-refresh-expired-token
```

Implement, run the command, and preserve the output. A non-implementer reviews the final diff and
output in the project's native PR, CI, or conversation surface. Do not manufacture a file to prove a
process happened.

## Spec-governed work

```text
intent -> spec -> implement -> review -> findings
```

1. **Spec:** `sus-spec` writes intent and requirements with stable IDs and `Verify with:` lines.
   Set `status: ready` before dispatch or review.
2. **Implement:** a native worker or human follows the spec by absolute path, runs every verification,
   and records real output under `## Execution`.
3. **Review:** a non-implementer judges the result on the native PR, via Revolver, Triple-check, or
   Bulletproof. No Suspec review file.
4. **Findings:** discard transient observations; route verified durable lessons through
   [memory or project records](09-saving-findings.md).

The implementer may not call self-review independent. Work that earns independent review stays
blocked until a non-implementer can judge it.

## Escalation

Escalate only when the [signal earns the rigor](reference/rigor-escalation.md).

A task narrows a source spec; it never adds requirements. A change plan adds transformation order and
preservation context; it never replaces the spec. `drill` locks one seam; it never writes
`type: change-plan`.

## Proof, not claims

- Preserve fresh output for every verification claim.
- Treat empty evidence as unverified, never as proof.
- Expose blocked and unverified work.
- Keep acceptance human-owned. The implementer cannot accept.

Next: [artifact location and close](03-where-files-live.md). Previous:
[what Suspec is](01-what-is-suspec.md).
