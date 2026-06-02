# 📋 Task: testing

> **TL;DR.** Add or improve test coverage. Lead persona is The Test Author. Test behaviour, not implementation. One test, one reason to fail. Verify each test fails when the assertion is flipped — paste the proof.

> 📦 **This page is documentation.** The actual task template lives at [`/scaffold/.agents/skills/write-testing/references/task-template.md`](../../scaffold/.agents/skills/write-testing/references/task-template.md).

---

## 🎯 When to use

A `testing` task is right when:

- A spec, audit, or bug-report identifies a coverage gap.
- The deliverable is *the test*, not the feature.
- The work is bounded enough to constitute a session of its own (large coverage projects decompose into multiple `testing` tasks).

If you're adding tests *as part of* a feature task, that's `feature` — the Builder's hard constraint already requires tests.

---

## 🎯 When a test is a spec's oracle

When a `testing` task authors the test that a spec acceptance criterion points to (the criterion's check binding is `test`, per [ADR 0022](../adrs/0022-acceptance-criteria-are-executable-checks.md)), two *separate* proofs are required, and the self-review records both:

- **Assertion-flip** — flip the assertion, the test fails; restore, it passes. Proves the test fires, not a tautology.
- **Criterion encoding** — the test asserts the behaviour the *criterion* describes, in the criterion's own terms (not an adjacent passing condition), and fails when the *criterion* is violated. Proves the test verifies the right thing.

A green test that flips correctly but tests an adjacent path satisfies the first proof and fails the second. If a criterion cannot be turned into a fail-when-violated test, that's a finding for the spec author (rebind to `command` / `manual`) — not licence to ship a green-but-irrelevant test.

---

## 🧬 Metadata

| Field                | Value                                              |
| -------------------- | -------------------------------------------------- |
| **Source doc**       | `spec.md` / `audit.md` / `bug-report.md` / `test plan` |
| **Lead persona**     | [The Test Author](../personas/the-test-author.md) |
| **Secondary**        | [The Skeptic](../personas/the-skeptic.md) (review) |
| **Output**           | New test cases; coverage gap closed                |
| **Recommended skills** | `write-testing`, `empirical-proof` (the Test Author mindset is carried by `write-testing`) |
| **Verification gate slots** | `cmdInstall` (pre), `cmdTest` (after each new test), `cmdTest` + coverage report (post), `cmdValidate` (post), `assertion-flip-proof` (self-review), criterion-encoding mapping for any acceptance-criterion-bound test (self-review) |

---

## Canonical template (agent artefact)

The verbatim Markdown template (persona directive, placeholders, gated `Self-review`) lives under **`/scaffold/.agents/templates/`**. Install by copying [`/scaffold`](../../scaffold/README.md); do not paste large template bodies from framework docs into downstream repos — that guarantees drift.

### Why these structural clusters exist

Every task template shares the same structural clusters; see [Why these structural clusters exist](README.md#why-these-structural-clusters-exist) in the task-type overview for the shared rationale.

---

## ⚠️ Common anti-patterns

- Testing implementation details (private methods, internal state)
- Bundling assertions
- Chasing coverage numbers
- Tests that pass when commented out
- Order-dependent tests
- Mocking the implementation instead of the contract

---

## See also

- [`personas/the-test-author.md`](../personas/the-test-author.md)
- [`documents/extended.md`](../documents/extended.md) — test plan format (when used)
- [`skills/write-testing.md`](../skills/write-testing.md) — the recommended skill (carries the Test Author mindset)
- [`skills/empirical-proof.md`](../skills/empirical-proof.md)
