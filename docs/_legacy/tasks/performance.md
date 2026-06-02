# 📋 Task: performance

> **TL;DR.** Optimise a specific bottleneck under a measured target. Lead persona is The Performance Surgeon. Numbers, not vibes. Every change benchmarked before and after under the same protocol. Never regress correctness for speed.

> 📦 **This page is documentation.** The actual task template lives at [`/scaffold/.agents/skills/write-performance/references/task-template.md`](../../scaffold/.agents/skills/write-performance/references/task-template.md).

---

## 🎯 When to use

A `performance` task is right when:

- A benchmark report (or a spec / audit / bug-report) identifies a perf issue with a measured baseline.
- A target is stated (e.g., "p95 latency ≤ 50 ms").
- Correctness preservation is the floor.

If the perf issue isn't measured yet, do `audit-writing` (or a research-writing task to establish the benchmarking methodology) first.

---

## 🧬 Metadata

| Field                | Value                                              |
| -------------------- | -------------------------------------------------- |
| **Source doc**       | `benchmark report` / `spec.md` / `audit.md` / `bug-report.md` |
| **Lead persona**     | [The Performance Surgeon](../personas/the-performance-surgeon.md) |
| **Secondary**        | [The Skeptic](../personas/the-skeptic.md) (review) |
| **Output**           | Faster code path, target hit, no correctness regression |
| **Recommended skills** | `write-performance`, `empirical-proof`, `persona-performance-surgeon` |
| **Verification gate slots** | `cmdInstall` + baseline `cmdBenchmark` (pre), `cmdTest` (after each change), target `cmdBenchmark` (post), `cmdTest` (post) |

---

## Canonical template (agent artefact)

The verbatim Markdown template (persona directive, placeholders, gated `Self-review`) lives under **`/scaffold/.agents/templates/`**. Install by copying [`/scaffold`](../../scaffold/README.md); do not paste large template bodies from framework docs into downstream repos — that guarantees drift.

### Why these structural clusters exist

Every task template shares the same structural clusters; see [Why these structural clusters exist](README.md#why-these-structural-clusters-exist) in the task-type overview for the shared rationale.

---

## ⚠️ Common anti-patterns

- "It feels faster"
- Optimising without baseline
- Skipping the test suite ("it's just a perf change")
- Comparing benchmarks under different conditions
- Optimising the wrong bottleneck
- Making code unreadable for marginal gains

---

## See also

- [`personas/the-performance-surgeon.md`](../personas/the-performance-surgeon.md)
- [`documents/extended.md`](../documents/extended.md) — benchmark report format
- [`skills/write-performance.md`](../skills/write-performance.md) — the recommended skill
- [`skills/empirical-proof.md`](../skills/empirical-proof.md)
