# 09 · Empirical proof

> **TL;DR.** Every persona's `## Self-review` is a hard gate. Every claim is backed by **pasted command output** — verbatim, the actual lines from the actual run. Paraphrase is not proof. "Tests passed" is not proof; the last two lines of the test runner is proof. This applies regardless of persona — Builders, Skeptics, Researchers, and Architects all paste output. The discipline targets the framework's most insidious failure mode — hallucinated completion — by making missing evidence *conspicuous*. Be precise about what that buys: pasted output is **agent-self-attested** (conspicuousness, not enforcement); mechanical enforcement is a runtime's job ([ADR 0023](../adrs/0023-harness-enforcement-contract.md)).

---

## 🎯 The failure mode being defeated

Coding agents are pattern-completers. The pattern of "successful task" includes confident-sounding completion language — "✅ all tests pass", "the implementation is complete", "looks good". The agent will complete that pattern even when the underlying claim is false.

This is **hallucinated completion**. It is not deceit; the agent is not "lying". It is a probabilistic system completing the most likely continuation. But in production, the result is identical to a lie: code ships that doesn't work, tests are claimed but never run, the build is "good" until CI tells you it isn't.

Empirical proof is the framework's structural defence — *structural* in the precise sense that an empty `[Paste output]` block is **conspicuous** where a free-text "✅ done" is not. Omission becomes visible.

Be honest about the ceiling, though. This is **self-attestation, not enforcement**: the agent pastes its *own* output, and the discipline concedes it is "still gameable with fabricated output" and selective tail-paste ([`skills/empirical-proof.md`](../skills/empirical-proof.md)). The markdown layer cannot re-run a command or block `status: done` (Swarm has no runtime — [PRINCIPLES.md](../PRINCIPLES.md) #1). Mechanical enforcement — re-running the bound commands in a clean checkout and blocking promotion on failure or empty paste — is the job of a **compliant runtime**, specified by [ADR 0023](../adrs/0023-harness-enforcement-contract.md), not of this layer. And whether the discipline actually *reduces* hallucinated completion is an empirical hypothesis Swarm has **not yet measured** (it is grounded in the activation/Reflexion evidence, not a Swarm-specific benchmark — see [`.agents/research/empirical-evidence.md`](../../.agents/research/empirical-evidence.md)). The honest claim is: conspicuousness + a defined enforcement target, not compiler-grade enforcement.

---

## 🔒 The hard gate

Every task template ends with a `## Self-review` section. Every Self-review section opens with the same incantation:

> **Hard gate.** The task is not complete until every question below has a written answer directly beneath it. An unanswered question is a skipped check.

And every Self-review section contains a `### Verification outputs` subsection with explicit `[Paste output]` placeholders:

```markdown
### Verification outputs (paste actual command output — do not paraphrase)

- `git status` →
- `{{cmdValidate}}` (last 2 lines):
- `{{cmdTest}}` (last 2 lines):
```

The agent fills these in with the actual command output. Not "✅ passing" — the literal lines.

---

## 🧪 What proof looks like

### ✅ Good — verbatim pasted output

```markdown
- `{{cmdValidate}}` (last 2 lines):

  ```
  ✓ 247 files passed
  Done in 12.4s
  ```

- `{{cmdTest}}` (last 2 lines):

  ```
  Tests:       189 passed, 189 total
  Time:        4.832 s
  ```
```

### ❌ Bad — paraphrased

```markdown
- `{{cmdValidate}}` (last 2 lines): Everything passes ✅
- `{{cmdTest}}` (last 2 lines): All 189 tests green
```

The bad version is *plausible*. It might even be *true*. But the framework treats it as unverified — paraphrase doesn't satisfy the gate. The agent must paste the actual output.

### ❌ Bad — partial paste

```markdown
- `{{cmdTest}}` (last 2 lines): "Tests: 189 passed"
```

Two issues:
1. Missing the second line (the framework asks for the last *two* lines deliberately — the runner's summary plus its timing/exit conditions).
2. Quoted, not pasted in a code block. The agent's quoting introduces a layer of interpretation; the paste should be raw.

---

## 📜 Core rules

The empirical-proof discipline is codified in [`skills/empirical-proof.md`](../skills/empirical-proof.md). Six rules:

### Rule 1: Never assume success

Writing the code is 10% of the job. Verifying it works in *the current environment* is 90%. The agent does not get to assume the test command's output without running it.

### Rule 2: Verbatim pasting

When filling out Self-review, paste the *verbatim* output. No paraphrasing, no summarising, no "✅ passing". Use a fenced code block. Include the last two lines (or more if asked) — the runner's summary plus its timing/exit conditions.

### Rule 3: One verification per claim

Each claim in the task — "the build passes", "the tests pass", "the linter is clean", "no architectural violations", "the migration covers all callsites" — gets its own pasted verification. Bundling claims into a single "all good" hides which check actually ran.

### Rule 4: Re-run after every change

Verifications go stale fast. If the agent makes a change after the verification, the verification is invalid. The agent re-runs and re-pastes. This is especially load-bearing during refactor and migration tasks where the *every-N-files* validation rule fires repeatedly.

### Rule 5: Run yourself; do not trust upstream

When the Skeptic reviews a worker's branch, the Skeptic runs `{{cmdValidate}}` and `{{cmdTest}}` *themselves*, in their own worktree, with the worker's branch checked out. The worker's pasted output does not satisfy the Skeptic's gate — only the Skeptic's *own* run does.

### Rule 6: Paste, don't quote

Use raw fenced code blocks for output. Do not transform the output (no quoting, no Markdown styling, no annotation in the middle of the paste). Treat the output as data: copy it in, leave it alone.

---

## 🎭 What different personas paste

The empirical-proof discipline applies universally, but each persona pastes the proof relevant to their work:

| Persona                 | Required empirical proofs                                                          |
| ----------------------- | ---------------------------------------------------------------------------------- |
| The Builder             | `{{cmdValidate}}`, `{{cmdTypecheck}}`, `{{cmdTest}}`, `git status`                |
| The Skeptic             | `{{cmdValidate}}` (run by you), `{{cmdTest}}` (run by you), `git diff --stat`     |
| The Architect           | `git status` showing zero source/config files modified, pattern-survey evidence    |
| The Janitor             | `{{cmdValidateDeps}}` at each checkpoint, final `{{cmdValidateDeps}}`, `git status` |
| The Lead Engineer       | Per-worker review output (run by you), final merged-branch `{{cmdValidate}}`/`{{cmdTest}}`, the merge log |
| The Researcher          | Source URLs / citations / commit refs                                              |
| The Surveyor            | Screenshots or specific URLs of cited competitor behavior                          |
| The Bug Hunter          | Reproduction command output (the bug actually fires), bisect output if applicable, file:line of root cause |
| The Auditor             | File:line for every finding, validation output for any structural claim, search results proving "no callers" claims |
| The Migrator            | Per-wave `{{cmdValidate}}` output, callsite count before/after, `git status` after each wave |
| The Performance Surgeon | Baseline `{{cmdBenchmark}}`, target `{{cmdBenchmark}}`, full `{{cmdTest}}` (no regressions), profile data if applicable |
| The Test Author         | `{{cmdTest}}` showing new tests pass, `{{cmdTest}}` showing tests fail when assertion is flipped |
| The Documentarian       | Code examples actually run (output captured), behavior claims cross-checked (file:line cited) |

Each persona's profile lists their proofs in detail. See [`personas/`](../personas/).

---

## 🧬 Type-specific proof requirements

Some task types have proof requirements that go beyond the persona's defaults:

### Refactor: per-checkpoint dependency validation

The refactor task fires `{{cmdValidateDeps}}` *every 10 files* (the framework's standing convention for batched validation during structural changes). Each checkpoint's output gets pasted. This catches architectural drift early — a violation introduced at file 3 is easier to fix than the same violation discovered after file 47.

### Migration: per-wave validation

The migration task plans waves; each wave ends with `{{cmdValidate}}` *and* `{{cmdTest}}`. Both outputs paste into Self-review. The codebase must compile and pass tests *after each wave*, not only at the end. Letting two waves' worth of breakage accumulate is a known anti-pattern.

### Performance: before-and-after benchmarks under the same protocol

The performance task pastes the *baseline* benchmark output and the *final* benchmark output, both run under the same measurement protocol. Different conditions give different numbers; the comparison is meaningless without protocol equivalence.

### Bug-report: reproduction proof

The bug-report task's proof is *the bug actually firing*. The reproduction command output is pasted; it shows the bug's symptom. Speculation about root cause without reproduction is forbidden — see [`personas/the-bug-hunter.md`](../personas/the-bug-hunter.md).

### Testing: the assertion-flip proof

The testing task pastes the test runner output showing the new tests pass *and* the output showing they fail when the assertion is flipped. A test that passes when commented out is a maintenance burden, not a test. The flip-proof confirms the test actually tests something.

### Documentation: example execution

The documentation task pastes the output of every code example, proving each one runs as written. Examples that don't run are worse than no examples — they actively mislead.

---

## 🪞 Why "show, don't tell"

The phrase comes from creative writing — but the framework's adoption is structural. *Telling* relies on trust; *showing* relies on evidence. In a context where the writer is a probabilistic system optimised to sound confident, evidence is the only signal that survives.

The cost of pasting two lines of output is trivial (a few seconds, a few hundred tokens). The cost of trusting an unverified claim compounds — through reviews that don't catch the failure, through merges that break in CI, through bugs that ship to users. The asymmetry justifies the discipline.

---

## 🚫 Common evasions

The framework anticipates the rationalisations and forbids them:

| Evasion                                                                       | Framework response                                                                |
| ----------------------------------------------------------------------------- | --------------------------------------------------------------------------------- |
| "The output is too long to paste."                                            | The framework asks for the last 2 lines, not the whole log. If even 2 lines is too long, paraphrase the *body* and paste the *summary*. |
| "I already ran it earlier in the session."                                    | Re-run after every change. The earlier run is stale.                              |
| "It's obvious from the diff that the test passes."                            | Diff doesn't run tests. Run the tests; paste the output.                          |
| "The CI will catch it."                                                       | The framework's discipline is the agent's gate, not the CI's. CI confirms; the agent is responsible. |
| "It would slow down the session."                                             | The session's value is correctness, not speed.                                    |
| "I'm reviewing in good faith — pasting is performative."                      | The framework treats trust as a vulnerability to remove, not a virtue to celebrate. |
| "The test command failed for environmental reasons unrelated to my changes."  | Surface the env issue in `## Blockers`. Do not silently mark the task complete.  |

The persona profiles' "Red flags" sections enumerate persona-specific rationalisations. See [`personas/the-skeptic.md`](../personas/the-skeptic.md) for the canonical example.

---

## 🧯 What happens when proof can't be produced

Sometimes the agent legitimately can't produce a proof — the test runner is broken in the worktree, the benchmark requires hardware the agent doesn't have, the dependency-graph tool isn't installed.

The framework's response: **document the gap, don't paper over it.**

```markdown
- `{{cmdValidateDeps}}` (last 2 lines):

  > **Could not run** — `dependency-cruiser` not installed in this worktree.
  > See `## Blockers` for follow-up.
```

Then in `## Blockers`:

```markdown
- `{{cmdValidateDeps}}` not runnable — `dependency-cruiser` missing. Either install
  it (preferred) or mark the slot `n/a` for this task type with a one-line justification.
  Recorded so the next session is not blocked again.
```

The blocker is real and visible; the gate isn't bypassed silently.

---

## 🛠️ The skill that codifies this

The discipline lives in [`skills/empirical-proof.md`](../skills/empirical-proof.md), which self-activates (by its directive description) for tasks that produce code or run verifications. The skill's six rules (above) are restated by the persona skills and the workflow skills.

---

## See also

- [`skills/empirical-proof.md`](../skills/empirical-proof.md) — the codified skill
- [`skills/adversarial-review.md`](../skills/adversarial-review.md) — the Skeptic's verification rules
- [`personas/the-skeptic.md`](../personas/the-skeptic.md) — the canonical "I run things myself" persona
- [`tasks/`](../tasks/) — every task template includes a Self-review hard gate
- [ADR 0008](../adrs/0008-empirical-proof-as-framework-primitive.md) — why this is a framework-level rule rather than per-persona advice
