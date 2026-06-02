# 📋 Task: integration

> **TL;DR.** Wire a third-party SDK, API, or MCP server into the codebase per a spec. Same persona as `feature` (The Builder), specialised constraints around credential handling, error semantics, and protocol fidelity. Output: working integration + tests + handoff to The Skeptic.

> 📦 **This page is documentation.** The `integration` task type uses the same template as `feature`: [`/scaffold/.agents/skills/write-feature/references/task-template.md`](../../scaffold/.agents/skills/write-feature/references/task-template.md), with `Type: integration` and the additions noted below.

---

## 🎯 When to use

An `integration` task is right when:

- A spec defines integrating an external system (Stripe SDK, third-party API, MCP server, OAuth provider, etc.).
- The work primarily involves wiring an external surface, not building new internal behaviour.
- Credential handling, error mapping, and protocol fidelity are first-order concerns.

If you're *consuming* an already-integrated SDK to add a feature, that's `feature`, not `integration`. Integration is the wiring step.

---

## 🧬 Metadata

| Field                | Value                                              |
| -------------------- | -------------------------------------------------- |
| **Source doc**       | `spec.md`                                          |
| **Lead persona**     | [The Builder](../personas/the-builder.md) (in integration mode) |
| **Secondary**        | [The Skeptic](../personas/the-skeptic.md), [The Architect](../personas/the-architect.md) (boundary review) |
| **Output**           | Working integration with credential handling + tests |
| **Recommended skills** | `write-feature`, `empirical-proof` (the Builder mindset is carried by `write-feature`; `persona-architect` for boundary review) |
| **Verification gate slots** | `cmdInstall` (pre), `cmdValidate` (periodic + post), `cmdTest` (post including integration tests), `acceptance-criteria-coverage` + `integration-boundary` (self-review) |

---

## 🔒 Integration-specific constraints (in addition to feature constraints)

1. **Credentials via scoped environment variables.** Never hardcode API keys.
2. **Robust handshake handling.** Network errors, rate limits, retries — explicit per the SDK's contract or RFC.
3. **Bridge errors at the boundary.** Map external errors into the project's error taxonomy at the integration point; don't leak external error shapes into business logic.
4. **Test the contract** (or document why a contract test isn't feasible — e.g., the third-party charges per request and we use a sandbox env).
5. **Document the SDK / API version** in the integration's adjacent doc (in `docs/` or as a comment) so future upgrades have a reference point.

---

## Required gates: `integration-boundary` + `acceptance-criteria-coverage`

An integration task routes to The Builder and the `write-feature` skill bundle, so it inherits the feature task's `acceptance-criteria-coverage` gate ([ADR 0022](../adrs/0022-acceptance-criteria-are-executable-checks.md)): each acceptance criterion is mapped to its check binding (`test` / `command` / `manual`) and the result pasted in `Self-review`.

On top of that, the `integration-boundary` gate is **required** for every integration task (defined in [`reference/verification-gates.md`](../reference/verification-gates.md)). It is the boundary-discipline of the integration-specific constraints above, turned into pasted evidence in `Self-review`:

- **Secret-grep negative** — a `grep` over the diff/worktree proving no credential is hardcoded (secrets resolve via scoped environment variables).
- **SDK / API version pin** — the integrated artifact's version is pinned (not `latest`) and recorded in an adjacent doc or comment.
- **Contract / integration test** — a test exercises the boundary, or a one-line reason a contract test isn't feasible (e.g. the third party charges per request and only a sandbox is available).

This gate lives here (the discipline) and in the `### Integration boundary` block of the shared template (the pasted proof). The feature template carries that block as an optional stanza, used when `Type: integration`.

---

## Canonical template (agent artefact)

Uses **`/scaffold/.agents/skills/write-feature/references/task-template.md`** with **`Type: integration`**. Routing still selects The Builder (`write-feature` skill bundle) — the task type specialises *proof obligations*, not persona.

### Why a distinct `integration` type exists

| Driver | Explanation |
|--------|----------------|
| **Secret & boundary hazard class** | External IO raises incident severity curve; embedding extra Self-review probes + grep-style negative proofs lowers silent leakage regressions. |
| **Architect coupling** | Specs seldom encode handshake edge matrices fully; secondary reviewer listing anticipates escalation path reducing reinterpretation churn. |

### Conceptual deltas on top of feature template

Consumers extend the scaffolded feature task instance with:

- **`## Integration target`** capturing system identity (name, pinned artifact/API version, auth surface references, authoritative external docs URLs).
- **Constraint amplification** repeating non-negotiables: secrets only via environment indirection; map foreign failures into domestic error taxonomy before domain layers.
- **`### Integration boundary` Self-review stanza** (the `integration-boundary` gate) — forces pasted evidence: secret-grep negative, SDK/API version pin, and a contract/integration test (or the one-line reason one isn't feasible).

Markdown for these deltas is authored in generated task files, not duplicated from `/docs`.

---

## ⚠️ Common anti-patterns

- Hardcoded credentials ("just for testing")
- Letting external error shapes leak into business logic
- Skipping the contract / integration test
- Pinning to `latest` instead of an explicit version
- "I'll add error handling later"
- Bundling integration setup with consumer feature work

---

## See also

- [`tasks/feature.md`](feature.md) — the parent template
- [`personas/the-builder.md`](../personas/the-builder.md)
- [`personas/the-architect.md`](../personas/the-architect.md) — consult on boundary decisions
- [`skills/write-feature.md`](../skills/write-feature.md)
