# Task files

> **Why most workflow skills ship a `references/task-template.md`, why a few deliberately don't, and the empirical case for externalising task state into a markdown file at all.**

Agent context is finite. A long-running task accumulates intermediate findings, half-formed hypotheses, abandoned plan branches, and decisions whose rationale lives only in the chat. When the next session opens — or even just when the model's attention is pulled to a new sub-task — that state is gone unless it has been written to disk.

Task files are Swarm's response. They are the **agent's working memory, externalised**.

---

## What this isn't: a replacement for Plan-mode files

Modern agent harnesses already produce planning artefacts. Cursor's *Plan mode* and Claude Code's */plan* both write a markdown plan to disk before execution; that plan describes intent, decomposition, and ordering. Swarm's task templates are **not a replacement for those plans** — they are an *auxiliary* to them.

| | Plan-mode artefact (Cursor, Claude Code, etc.) | Swarm's task template |
| --- | --- | --- |
| **Voice** | Descriptive — *"we will do X, then Y"* | Imperative — *"validate after every batch; paste the output here"* |
| **Primary purpose** | Decompose a goal into ordered steps before execution | Carry the **operational discipline** through execution: self-review gates, validation pastes, hypothesis tracking, decisions, promotion of durable findings |
| **What it captures** | The plan | The plan's *application* — observed behaviour, paste-output proofs, what was tried and discarded, what to promote out of the file |
| **Lifetime** | Often session-scoped; superseded once the work begins | Lives across sessions; the agent re-reads it on resume; the `## Self-review` block must be empirically backed before close |
| **Failure mode it prevents** | Starting code without thinking | Skipping verification, losing findings, conflating observation with inference, finalising without paste-output proof |

The two are complementary. A consuming repo can use Plan mode to draft the *plan*, then instantiate one of Swarm's task templates to carry the *imperative discipline* — the validation gates, the forced visible output, the iteration trail, the decision log. The plan answers *what to do*; the task file answers *how to know it was done correctly*.

> If your harness's plan-mode file is doing the imperative work too — listing self-review gates, demanding paste-output, tracking hypotheses — you don't need a task template on top. The empirical case below applies to the *function* (externalising state with imperative gates), not to a specific file. Swarm ships templates because most plan-mode artefacts stop at the descriptive layer.

---

## The empirical chain

```mermaid
flowchart LR
    A["Lost in the Middle [5]<br/>Context Rot [30]<br/>U-curve attention"] --> P[Externalize working state]
    B["Show Your Work [24]<br/>Plan-and-Solve [25]<br/>Tree of Thoughts [26]<br/>Reflexion [27]"] --> P
    C["More with Less [31]<br/>quadratic token cost"] --> P
    D["Anthropic [20]<br/>three-file canonical pattern"] --> P
    E["InfiAgent [29]<br/>21x ablation"] --> P
    F["Anthropic harnesses [21][22]<br/>file-based handoffs"] --> P
    G["Claude Code Tasks [23]<br/>v2.1.16 disk-persistent"] --> P
    P --> R[references/task-template.md]
```

Eight independent sources converge on the same finding: **agents perform measurably better when working state lives in a file rather than only in context**.

---

## Anthropic's canonical pattern

The most authoritative single source is Anthropic's own engineering guidance [\[20\]](./sources.md#20). It defines a **three-file note-taking pattern** for long-running agents:

| Anthropic file    | Purpose                                                 | Maps to our task-template section(s)                   |
| ----------------- | ------------------------------------------------------- | ------------------------------------------------------ |
| `task_plan.md`    | The plan — what we're trying to do, in order            | `## Objective` + `## Plan` + `## Progress checklist`   |
| `progress_log.md` | Running session log — what was tried, what was observed | `## Findings` (with `[pending]` / `[confirmed]` flags) |
| `decisions.md`    | Durable design choices and their rationale              | `## Decisions`                                         |

Swarm's templates collapse the three files into one. The trade-off is deliberate:

- **One file** = one resumption point. The agent reads a single task file (`.agents/tasks/<slug>.md`) to recover state, not three.
- **One file** = single artefact to manage per task. Simpler to gitignore, simpler to clean up at task close.
- **Three files** would mean per-task subdirectories and a coordination concern about which file is authoritative when they disagree.

The discipline is the same; the artefact count differs. Each task template encodes the same lifecycle Anthropic describes — pre-flight read, in-flight update, pre-close promotion — inside the consolidated single-file format.

---

## Where the task file lives: gitignored, local, personal

Task files are **the dev's personal working memory, not a team artefact**. They live at `.agents/tasks/<slug>.md` on the dev's machine (gitignored) and are never committed.

| | Task file | Deliverable |
| --- | --- | --- |
| **What it is** | The agent's scratchpad: plan, progress, decisions, hypothesis tracker, paste-output verifications, distillation-loss notes | The artefact the work produces: spec, audit, bug-report, ADR, code change + regression test |
| **Where it lives** | The gitignored `.agents/tasks/` folder (`.agents/tasks/<slug>.md`) | The project's docs / source tree (`<your-specs-dir>/<slug>.md`, `<your-audits-dir>/<slug>.md`, the source files themselves) |
| **Lifetime** | Until the deliverable lands; then discarded (no archival value) | As long as the project itself |
| **Visible in PRs** | No | Yes |
| **Per-machine** | Yes | No, shared via git |

If the task file were committed instead, the repo would accumulate thousands of stale scratchpads within weeks — and the deliverables (which *are* worth keeping in git history) would be diluted in a sea of working memory. The split is structural: the task file is the *workspace*, the deliverable is the *output*.

> **Setup:** add `.agents/tasks/` to `.gitignore`. The template's `## Deliverable` block is the part that gets promoted to the deliverable's final home; everything outside that block stays on the dev's machine.

---

## The empirical evidence

### Scratchpads make multi-step reasoning easier

[\[24\]](./sources.md#24) Nye et al., _Show Your Work_ (ICLR 2022). Letting a model emit intermediate steps to a scratchpad improves accuracy on multi-step problems. The original framing is per-prompt (the scratchpad is the model's own working buffer), but it generalises directly to agent tasks: the task file is the durable scratchpad.

> _"Even though models must predict many more tokens, they still perform better at predicting final results because individual prediction steps are easier."_

### Explicit plans beat ad-hoc execution

[\[25\]](./sources.md#25) Wang et al., _Plan-and-Solve Prompting_ (ACL 2023). Devise an explicit plan before executing, then carry out subtasks. Outperforms vanilla zero-shot CoT across arithmetic, commonsense, and symbolic reasoning benchmarks.

The `## Plan` and `## Progress checklist` sections in every task template are the externalised version of the same discipline.

### Multi-path search outperforms linear chains

[\[26\]](./sources.md#26) Yao et al., _Tree of Thoughts_ (NeurIPS 2023). On Game of 24, GPT-4 jumps from 4 % (CoT) to **74 % (ToT)** when allowed to explore, evaluate, and backtrack across reasoning paths.

Templates capture this pattern where it matters: `write-bug-report` and `fix-flaky-test` both ship a `## Hypothesis tracker` so competing explanations are tracked, evaluated, and pruned in writing rather than implicitly.

### Verbal reflection beats no reflection

[\[27\]](./sources.md#27) Shinn et al., _Reflexion_ (NeurIPS 2023). Verbal self-reflection between trials, stored as text and re-read on the next attempt, drives **91 % pass@1 on HumanEval (vs 80 % GPT-4 baseline, +11 pp)**.

Swarm's `## Self-review` discipline is the per-task version of this pattern. For iterative skills (`write-fix`, `fix-flaky-test`), the per-trial version lives in the `## Iteration trail` and `## Hypothesis tracker` sections — what was tried, what failed, what to try next.

### Removing the file destroys performance

[\[29\]](./sources.md#29) Yu et al., _InfiAgent_ (2026). The single most direct piece of evidence in this document: an ablation study where removing file-based state externalization caused **a 21x performance degradation on long-horizon tasks**. The architecture combines a file system with a k-most-recent action window — implicit in the `## Findings` and `## Decisions` sections of our templates.

### Context engineering, not model scale, is the bottleneck

[\[28\]](./sources.md#28) Yuksel, _PAACE_ (Dec 2025). _"Modern agentic failures are overwhelmingly context failures, not model failures."_ Plan-aware context selection — the task file _is_ the plan, and the agent re-reads only the relevant section per turn — is the practical realisation.

### Long contexts have super-linear cost

[\[30\]](./sources.md#30) Hong et al., _Context Rot_ (Chroma, Jul 2025); [\[31\]](./sources.md#31) Gao & Peng, _More with Less_ (ByteDance, Oct 2025). Performance degrades non-uniformly as input grows; token cost grows quadratically with conversation turns. **Implication for templates: keep them short.** Swarm's templates target <200 lines for exactly this reason — see [Body anatomy § Length](./body-anatomy.md#length-target-200-lines-hard-cap-500).

### Vendor patterns echo the same structure

[\[21\]](./sources.md#21) Anthropic harnesses; [\[22\]](./sources.md#22) Long-running app harness design; [\[23\]](./sources.md#23) Claude Code Tasks system v2.1.16. Every major implementation converges on the same shape: a markdown file on disk that survives session boundaries. Whether that file is committed depends on its role — some teams check plan files into the repo so they double as a team artefact, while Anthropic's three-file pattern [\[20\]](./sources.md#20) and the Claude Code Tasks system [\[23\]](./sources.md#23) treat them as local working state. **Swarm follows the latter** — task files are personal, gitignored, and discarded once the deliverable lands.

---

## Decision rubric: when does a skill warrant a task template?

A `references/task-template.md` is a structural commitment. Every time the skill activates, the agent's prior is _"instantiate this template into a tasks file"_. That's load-bearing context with the same diminishing-returns curve as the body itself.

A skill warrants a `task-template.md` **iff at least three of the six criteria hold**:

| Criterion                             | Question                                    | Evidence                                                                                          |
| ------------------------------------- | ------------------------------------------- | ------------------------------------------------------------------------------------------------- |
| **M** Multi-session                   | Realistic to span >1 agent session          | [\[21\]](./sources.md#21)[\[22\]](./sources.md#22)[\[23\]](./sources.md#23) — file-based handoffs |
| **I** Iterative gates                 | Validate → fix → re-validate cycles         | [\[27\]](./sources.md#27) — Reflexion's iteration loop                                            |
| **H** Hypothesis tracking             | Multiple competing explanations to evaluate | [\[26\]](./sources.md#26) — Tree of Thoughts                                                      |
| **P** Multi-stage plan                | ≥4 distinct phases                          | [\[25\]](./sources.md#25) — Plan-and-Solve                                                        |
| **S** State separate from deliverable | Working state is not the final artefact     | [\[20\]](./sources.md#20) — three-file pattern                                                    |
| **G** Verification gates              | Paste-output empirical proof required       | [\[4\]](./sources.md#4) — execution failure mode                                                  |

---

## Applied in Swarm's skills

### Skills that ship a template

Every multi-stage `write-*` skill, plus `fix-flaky-test` and `adversarial-review`, ships a `references/task-template.md`. All score ≥3 on the MIHPSG rubric. The shape of the score predicts the shape of the template:

| Score profile                                                                                                                                                                          | Examples                                                                                | What ships                                                                                                                                                                  |
| -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Full house (M·I·H·P·S·G ≈ 6/6)** — multi-session, iterative, hypothesis search, multi-stage plan, state separate from deliverable, paste-output gates                                | `write-bug-report`, `fix-flaky-test`, `write-fix`                                       | Full template with `## Hypothesis tracker` (or `## Iteration trail` for `write-fix`), paste-output `## Verification outputs`, `## Self-review`, `## Findings` / `## Decisions` |
| **Plan + state + gates (M·P·S·G ≈ 5/6)** — multi-session, multi-stage, state separate, paste-output gates; no formal hypothesis tracking                                              | `write-feature`, `write-refactor`, `write-rewrite`, `write-migration`, `write-testing`, `write-performance` | Same plan / progress / verification scaffold without a hypothesis tracker; `write-performance` carries a single `## Hypothesis` field rather than a multi-row tracker         |
| **Authorial — plan + decisions, light gates (≈ 3–4/6)** — multi-stage authoring with state separate from the final document, but the deliverable itself is the proof of correctness | `write-spec`, `write-research`, `write-audit`, `write-documentation`, `adversarial-review` | Plan + decisions + findings + self-review; lighter paste-output gates because the deliverable itself is the proof                                                            |

### Skills that deliberately ship none

The rubric exempts two structural categories: persona skills and cross-cutting quality-gate skills. Both sit outside the per-task scaffold model — personas condition mindset for whichever workflow is in play; quality gates surface inside that workflow's task file rather than owning their own.

| Category                                     | Why                                                                                                                                                                                                                            |
| -------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| All `persona-*` skills                       | Single-load mindset conditioning, not a workflow. The persona scopes _how_ the agent thinks during whichever workflow it accompanies; the working state belongs to the workflow's task file, not the persona's.               |
| `empirical-proof`, `distillation-discipline` | Cross-cutting quality-gate skills whose discipline lives entirely in `SKILL.md` and surfaces inside whichever workflow's task file is in play (`## Self-review`, `## Distillation Loss Statement`). No scaffold of their own.   |

> The same principle covers a third (currently empty) case: any future single-shot workflow skill whose deliverable doubles as the working state should ship no template — the deliverable file is the working state, and a parallel scaffold would just shadow it. If the deliverable and the working state are the same document, ship none.

---

## Counter-evidence: when state externalization hurts

The same body of research that justifies task files also bounds them. Externalisation is not free — and beyond a threshold it inverts.

| Source                                                         | Failure mode                                                            | Implication                                                                                                             |
| -------------------------------------------------------------- | ----------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------- |
| [\[32\]](./sources.md#32) ETH Zurich, _Evaluating AGENTS.md_   | LLM-generated context files cost +20 % with -3 % success                | Don't auto-generate or pad templates; tool-specific commands are 50× more impactful than narrative content              |
| [\[33\]](./sources.md#33) Lulla et al., _AGENTS.md efficiency_ | Efficiency gains plateau; redundancy penalises                          | Each section must earn its keep                                                                                         |
| [\[31\]](./sources.md#31) ByteDance, _More with Less_          | Quadratic token cost with turns; 75th-percentile turn cap saves 24–68 % | Templates >200 lines push load-bearing content into the U-curve trough [\[5\]](./sources.md#5)[\[30\]](./sources.md#30) |
| [\[6\]](./sources.md#6) "Template Theatre" anti-pattern        | Templates that ship but rarely apply pollute the agent's prior          | Skills whose discipline lives entirely in `SKILL.md` (personas, cross-cutting quality gates) ship no per-task scaffold  |

The decision rubric above is the applied form of these constraints.

---

## What good looks like in Swarm's skills

| Property                                                      | How it's enforced                                                                                                                                                                                                                                                                                                          |
| ------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Templates target <200 lines**                               | Most ship under 200 lines; the U-curve [\[5\]](./sources.md#5)[\[30\]](./sources.md#30) is the binding constraint. The state-heaviest template, `fix-flaky-test`'s, runs longer (Test under stabilisation · Flake category · Reproduction protocol · Reproduction evidence · Hypothesis tracker · Root cause · Plan · Fix evidence) — every section is load-bearing for that workflow. The 500-line hard cap [\[2\]](./sources.md#2) still applies. |
| **No cross-skill references**                                 | Templates name the _concept_ (e.g., "the project's benchmark command"), not a sibling skill — see [Self-containment](./self-containment.md)                                                                                                                                                                                  |
| **Section discipline maps to Anthropic's three-file pattern** | Plan + Progress = task_plan; Findings = progress_log; Decisions = decisions [\[20\]](./sources.md#20)                                                                                                                                                                                                                        |
| **Iterative skills carry an iteration trail**                 | `write-fix` ships `## Iteration trail`; `fix-flaky-test` augments `## Hypothesis tracker` with a `Next adjustment` column — both per Reflexion [\[27\]](./sources.md#27)'s verbal-feedback loop                                                                                                                              |
| **No template ships without ≥3 of MIHPSG**                    | A handful of skills deliberately ship none on this basis                                                                                                                                                                                                                                                                    |
| **No `## Domain skills` placeholder section**                 | Removed from all task templates — the section was an empty placeholder after the self-containment cleanup, costing tokens against the compliance ceiling [\[32\]](./sources.md#32) without doing measurable work                                                                                                            |

---

## See also

- [Body anatomy § Length](./body-anatomy.md#length-target-200-lines-hard-cap-500) — the U-curve constraint that bounds template size.
- [Self-containment](./self-containment.md) — why templates name concepts, not sibling skills.
- [Execution](./execution.md) — Reflexion's verbal-feedback loop is the per-rule version of the per-task discipline here.
- [Sources](./sources.md) — full bibliography.
