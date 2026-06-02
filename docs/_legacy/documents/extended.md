# 🛠️ Extended document types

> **TL;DR.** Specialised variants of the four core types. Optional but increasingly common — projects adopt them when the structure earns its keep. They are not required for framework conformance.

---

## 🧭 The catalogue

| Doc                  | Specialises             | Where it lives                | Authoring persona              |
| -------------------- | ----------------------- | ----------------------------- | ------------------------------ |
| [ADR](#-adr)         | spec (decision-only)    | `.agents/adrs/`               | The Architect                  |
| [constitution](#-constitution) | spec (project-wide) | `.agents/constitution.md`   | Human / The Architect          |
| [migration plan](#-migration-plan) | spec (mechanical change) | `.agents/migrations/` | The Architect (with The Migrator's input) |
| [benchmark report](#-benchmark-report) | audit (perf-specialised) | `.agents/benchmarks/` | The Performance Surgeon |
| [cleanup list](#-cleanup-list) | audit (deletion) | `.agents/cleanups/`         | The Auditor                    |
| [test plan](#-test-plan) | spec (test scope)     | `.agents/test-plans/`         | The Test Author                |
| [audit brief](#-audit-brief) | spec (small, up-front) | `.agents/audit-briefs/`   | Human / The Architect          |
| [research question](#-research-question) | spec (small, up-front) | `.agents/research-questions/` | Human                |
| [review scope](#-review-scope) | spec (small, up-front) | `.agents/review-scopes/`  | Human / The Lead Engineer      |

These are *specialisations*, not new epistemic stances. An ADR is conceptually a small decision-only spec; a benchmark report is an audit specialised to performance.

---

## 🪧 ADR

> **Architecture Decision Record.** An immutable record of an architecturally significant decision. Y-Statement format: Context · Decision · Consequences. Authored by The Architect, often during a `spec-writing` session.

### When to use

- A structural decision affects multiple specs / modules / future contributors
- The decision has alternatives worth recording
- The decision is *immutable* — when superseded, write a new ADR; do not amend the old one

### Where it lives

`.agents/adrs/{NNNN-slug}.md` (zero-padded sequence number)

### Template (Y-Statement / Nygard-derived)

```markdown
# ADR <NNNN>: <Decision title>

## Status

Proposed / Accepted / Deprecated / Superseded by ADR <NNNN>

## Date

YYYY-MM-DD

## Context

The forces at play. The problem we're addressing. What's true today that makes the decision necessary.

## Decision

What we're going to do. Stated as a present-tense imperative ("we use X", "we forbid Y").

## Considered and rejected

Each alternative we evaluated, with the reason it was rejected.

- _<Alternative A>_ — rejected because <reason>.
- _<Alternative B>_ — rejected because <reason>.

## Consequences

### Positive

- <consequence>

### Negative

- <consequence>

### Neutral

- <consequence — important but neither good nor bad>

## See also

- Related ADRs: <list>
- Spec(s) this informs: <list>
```

### Example

```markdown
# ADR 0017: PKCE flow is server-driven, not client-driven

## Status
Accepted

## Date
2026-04-22

## Context
We need to support OAuth2 PKCE on /api/login (per `.agents/research/oauth2-pkce.md`). RFC 7636's
spirit is that the *client* generates the verifier and challenge, but our SPA topology has the
client and server already share trust via session cookies; the server can generate the verifier
and store it with the same security properties.

## Decision
The server generates `code_verifier` and `code_challenge`, stores the state↔verifier mapping in
`tokenStore` for 5 minutes, and returns the `code_challenge` (not the verifier) to the client.

## Considered and rejected
- _Client-generated verifier (RFC 7636 default)._ Rejected because it shifts trust to the client
  (which is fine in a true public-client scenario, but our SPA is hybrid with session cookies)
  and complicates audit logging.
- _No PKCE; rely on client_secret in the SPA._ Rejected because storing the secret in browser
  code violates `constitution.md` §4.1 (no secrets in client code).

## Consequences
### Positive
- All authorisation happens server-side; audit trail complete.
- No client-side cryptographic implementation to maintain.

### Negative
- The server's verifier store becomes a hot path; needs rate limiting and TTL discipline.
- Diverges slightly from RFC 7636's default flow; future contributors may be surprised.

### Neutral
- Requires extending `tokenStore` with `storeStateVerifier` / `retrieveStateVerifier`.

## See also
- ADR 0014: tokenStore is the canonical token persistence layer
- Spec: `.agents/specs/oauth2-pkce.md`
- Research: `.agents/research/oauth2-pkce.md`
```

---

## 📜 Constitution

> **The project's non-negotiable baselines.** Tech-stack constraints, code-quality standards, security mandates, architectural invariants. The "supreme law" of the project — every spec, audit, and ADR is constrained by it.

### When to use

- The project has invariants that apply to *every* task (security mandates, layering rules, language version pins)
- A single document captures these better than scattering them across multiple specs / ADRs
- The constitution is read by every persona before serious work

### Where it lives

`.agents/constitution.md` (single file, project-wide)

### Template

```markdown
# Project constitution

## Status

Active — last revised YYYY-MM-DD

## Authority

This document is the supreme guideline. Specs, ADRs, and audits operate within its constraints.
Changes to the constitution require human approval and a corresponding ADR.

## §1. Tech stack

- Language: <e.g., TypeScript ≥ 5.5>
- Runtime: <e.g., Node.js LTS>
- Test runner: <e.g., vitest>
- Package manager: <e.g., pnpm ≥ 9>

## §2. Code quality

- §2.1 Cryptographic randomness: use the standard library's secure RNG; `Math.random` is forbidden
  for security-relevant code.
- §2.2 ...

## §3. Architecture

- §3.1 Presentation logic must not import database connection logic directly; everything flows
  through the public contracts in `src/services/`.
- §3.2 ...

## §4. Security

- §4.1 No secrets in client-bundled code; all secrets sourced from server-side env vars.
- §4.2 All external API credentials scoped to the smallest privilege necessary.
- §4.3 ...

## §5. Testing

- §5.1 Every public function has at least one behaviour test.
- §5.2 ...

## See also

- ADRs that informed each section: <list>
```

The constitution is **referenced** from every spec / audit / ADR. Citing the constitutional rules a document depends on is a recommended discipline carried by each authoring skill — there is no gatekeeper skill enforcing it.

---

## 🚚 Migration plan

> **A spec specialised for mechanical change across many call sites.** Adds wave plan, callsite tracker, and shim contract sections to the standard spec template.

### Where it lives

`.agents/migrations/{{slug}}.md`

### Template (additions to the spec template)

```markdown
# Migration plan: <From X to Y>

[ standard spec sections: Status / Author / Context / Linked docs / Goal / Scope / Acceptance criteria / Design decisions / Constraints ]

## Wave plan

| Wave | Scope | Callsite count | Validation gate |
| ---- | ----- | -------------- | --------------- |
| 1    |       |                | `cmdValidate`   |
| 2    |       |                | `cmdValidate`   |
| ...  |       |                |                 |

## Compatibility shims

| Shim path | Forwards to | Removable when |
| --------- | ----------- | -------------- |
|           |             |                |

## Callsite tracker

Total callsites of the old API: <count>. Tracking by wave (filled in during migration).

| Wave | Callsites in scope | Migrated | Remaining |
| ---- | ------------------ | -------- | --------- |

## Risks specific to migration

- Partial-state risk: <mitigation>
- Rollback path: <described>
```

The migration plan is consumed by a `migration` task with The Migrator. See [`tasks/migration.md`](../tasks/migration.md).

---

## 📊 Benchmark report

> **An audit specialised for performance.** Establishes a measured baseline, target, and methodology. Authored by The Performance Surgeon.

### Where it lives

`.agents/benchmarks/{{slug}}.md`

### Template (additions to the audit template)

```markdown
# Benchmark report: <bottleneck>

[ standard audit sections: Status / Author / Context / Linked docs / Goal / Scope ]

## Methodology

- Hardware: <description>
- Environment: <description>
- Input(s): <description>
- Load profile: <description>
- Warmup runs: <N>
- Sample count: <N>
- Statistical aggregate: <p50 / p95 / p99 / etc.>

## Baseline

```
[paste baseline benchmark output]
```

## Target

- Metric: <name>
- Value: <target>
- Hard ceiling: <regression threshold>

## Findings (perf-specific)

(Same severity scale as audit; "Needed" entries describe what would close the perf gap.)

## Suggested approaches

(Optimisation hypotheses; sequenced if multiple interact.)
```

The benchmark report is consumed by a `performance` task. See [`tasks/performance.md`](../tasks/performance.md).

---

## 🧹 Cleanup list

> **An audit specialised for deletion.** Items to remove, each with a safety proof.

### Where it lives

`.agents/cleanups/{{slug}}.md`

### Template (additions to the audit template)

```markdown
# Cleanup list: <area>

[ standard audit sections ]

## Items to remove

| # | Path | Why safe to remove | Verification |
| - | ---- | ------------------ | ------------ |
| 1 |      |                    | `git grep` evidence + dynamic-dispatch check |

## Removal sequence

If items have ordering dependencies, document.
```

Consumed by a `refactor` task (Janitor uses the safety proofs). See [`tasks/refactor.md`](../tasks/refactor.md).

---

## 🧪 Test plan

> **A spec specialised for test coverage.** Used when the testing scope is too large for a single task file.

### Where it lives

`.agents/test-plans/{{slug}}.md`

### Template (additions to the spec template)

```markdown
# Test plan: <area>

[ standard spec sections ]

## Coverage gap

What behaviour is currently untested or undertested.

## Test cases

| Behaviour | Inputs / setup | Expected outcome | Priority |
| --------- | -------------- | ---------------- | -------- |

## Test placement

Per the project's testing-layout conventions.
```

Consumed by a `testing` task. See [`tasks/testing.md`](../tasks/testing.md).

---

## 📋 Audit brief / Research question / Review scope

> **Tiny up-front specs that frame an authoring task.** Optional — when the framing fits in the task file's `## Objective`, you don't need a separate doc.

When to use a separate brief:

- The framing has *structured content* (lists of items, specific scope boundaries, exit criteria)
- Multiple stakeholders need to see and approve the framing before the authoring task starts
- The framing is itself a small artefact worth preserving (e.g., a research question that informs the resulting research file)

### Audit brief template

```markdown
# Audit brief: <area>

## Goal

What "good" looks like for the audited area.

## Scope

In / out.

## Exit criteria

What conditions mean the audit is "done". (E.g., "all public surfaces of `src/payments/` reviewed
for thread-safety claims; risks documented".)

## Linked docs

Anything the auditor should read first.
```

### Research question template

```markdown
# Research question: <topic>

## The question

One or two sentences.

## Decision this informs

What downstream choice the research will support.

## Constraints

(Bounded scope; what's in / out.)

## Sources to consult (optional starting list)

A few suggested entry points; the Researcher may go beyond.
```

### Review scope template

```markdown
# Review scope: <branch / area>

## What is being reviewed

Branch name, or area of code, or specific PR.

## Focus areas

- Architectural: yes / no
- Security: yes / no
- Performance: yes / no
- (Any specific concerns the reviewer should look for)

## Reference materials

The original spec / audit / bug-report the work was driven from.
```

---

## 🪞 Why the extended types are optional

The four core types cover most projects. The extended types appear when the *additional structure* earns its keep — when the missing structure was actually causing failure modes.

A small project shouldn't adopt every extended type day one. Adopt them as the work demands:

- ADR when you find yourself making the same decision twice without recording it
- constitution when invariants are getting forgotten across specs
- migration plan when you face your first multi-wave migration
- benchmark report when "make it faster" tasks need empirical baselines
- test plan when coverage projects exceed one session
- audit brief / research question / review scope when up-front framing is being lost

The framework graduates an extended type to canonical only when many projects independently demand it.

---

## See also

- [`README.md`](README.md) — the documents catalogue
- [`spec.md`](spec.md), [`audit.md`](audit.md), [`bug-report.md`](bug-report.md), [`research.md`](research.md) — the four core types
- [`concepts/05-document-types.md`](../concepts/05-document-types.md) — the conceptual frame
- [ADR 0001](../adrs/0001-four-doc-types.md) — why the core is exactly four
