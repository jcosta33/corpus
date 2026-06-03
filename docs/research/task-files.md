# Externalising state to files

> The research grounding for why Swarm keeps a long-running unit of work in a file on disk — the `task.md` frame plus the `.swarm/` workspace around it — rather than only in the model's context window. This is a page in the **cited research layer**: every load-bearing claim below resolves to a verified entry in [sources.md](sources.md), used with its recorded caveats.

A model's context window is finite, and a unit of work that spans more than a few turns accumulates more than fits: the plan, the obligations in scope, what has been tried, what was observed, which hypotheses were ruled out, and the rationale behind each decision. When attention is pulled to a new sub-task — or a session ends — anything that lived only in the conversation is gone. The kernel's answer is to externalise that working state into files: a [`task.md`](../artifacts/task.md) frame for one pass, sitting in the [`.swarm/` workspace](../model/workspace.md) whose `sources/ status/ generated/` split records desired intent, observed satisfaction, and recreatable execution material as three separate, durable surfaces.

This page is the research backing for that design. It is **markdown-only and has no runtime** (every "checker", "loader", or "regenerating pass" named here is a contract a future Swarm toolchain would build against, not shipped code); it grounds *why* the kernel externalises state, not *what* a `task.md` means — that contract lives in [`docs/artifacts/task.md`](../artifacts/task.md).

---

## The convergent finding: externalised intermediate work helps

Four independent lines of evidence converge on one claim — a model reasoning over a multi-step problem does measurably better when its intermediate work is written down rather than held implicitly.

- **Scratchpads make multi-step reasoning easier.** [SCRATCHPAD](sources.md#SCRATCHPAD) (Nye et al., *Show Your Work*, ICLR 2022) shows that letting a model emit intermediate steps to a scratchpad dramatically improves accuracy on multi-step computation. The original framing is per-prompt — the scratchpad is the model's own working buffer — but it generalises directly to an agent task: a `task.md`'s `## Implementation or pass trace` and verification matrix are the durable, cross-session form of that buffer.
- **Explicit plans beat ad-hoc execution.** [PLANSOLVE](sources.md#PLANSOLVE) (Wang et al., *Plan-and-Solve*, ACL 2023) shows that devising an explicit plan that divides a task into subtasks, then executing it, consistently outperforms vanilla zero-shot chain-of-thought. In the kernel this is the [`lower`](../passes/lower.md) / [`decompose`](../passes/decompose.md) discipline: a spec's obligation graph is partitioned into bounded, write-disjoint `task.md` frames *before* any one of them is implemented.
- **Multi-path search outperforms a single linear chain.** [TREEOFTHOUGHTS](sources.md#TREEOFTHOUGHTS) (Yao et al., NeurIPS 2023) reports GPT-4 jumping from 4% (chain-of-thought) to 74% (tree-of-thoughts) on Game of 24 when allowed to explore, evaluate, and backtrack across reasoning paths. The kernel's projection of this is deliberately narrow: where competing explanations must be tracked and pruned, that happens in writing — in a task's `## Promotion queue` and the diagnostic stance of the [Bug Hunter](../library/heuristic-profiles.md) and [Skeptic](../library/heuristic-profiles.md) profiles — not implicitly in the model's head.
- **Verbal reflection beats no reflection.** [REFLEXION](sources.md#REFLEXION) (Shinn et al., NeurIPS 2023) reports 91% pass@1 on HumanEval versus an 80% GPT-4 baseline when verbal self-reflection is stored as text between trials and re-read on the next attempt. This is the same mechanism the kernel uses for its `## Self-review` block and the `empirical-proof` discipline: a written artefact converts an implicit signal into a durable, checkable one.

The throughline: a file on disk turns transient reasoning into a re-readable artefact. That is the entire premise of carrying a unit of work in a `task.md` rather than in conversation.

---

## Official guidance converges on the same shape

Two pieces of authoritative vendor guidance describe the same pattern, independent of the academic results above. They are *design guidance*, not measured studies — cite them as such.

**The three-file note-taking pattern.** Anthropic's context-engineering guidance ([CTXENG](sources.md#CTXENG)) treats context as a finite resource and recommends a three-file note-taking pattern for long-running agents:

| [CTXENG](sources.md#CTXENG) file | Purpose | Where it lands in the kernel |
| --- | --- | --- |
| `task_plan` | the plan — what we are doing, in order | the `task.md` `## Parent contract` + `## Scope` + `## Assigned obligations` |
| `progress_log` | running log — what was tried, what was observed | the `task.md` `## Implementation or pass trace` + `## Verification matrix` |
| `decisions` | durable design choices and rationale | a [`finding`](../artifacts/finding.md) / [`adr`](../artifacts/adr.md) the `## Promotion queue` routes to via the [`promote`](../passes/promote.md) pass |

The kernel does **not** collapse all three into one undifferentiated file. It separates them along a sharp axis — not "plan vs log vs decisions" but **desired vs observed vs generated** (see below). The `task.md` carries the plan and the running trace; the *durable* decisions are not kept inside the task scratchpad at all — they are promoted out, into `sources/` (a finding or ADR) or `memory/`, so the task frame stays a recreatable execution packet and the decision becomes part of the project's durable record.

**Disk-persistent tasks are a vendor-scale validation.** Anthropic's Claude Code ships a disk-persistent, dependency-aware task/todo system ([CCTASKS](sources.md#CCTASKS)). That a production agent harness persists task state to disk — with explicit inter-task dependencies — is independent validation of the kernel's stance: a unit of work is a file with a parent contract and `blocked_by` edges, not a transient list in context. The kernel's `task.md` frontmatter carries exactly those fields (`blocked_by`, `parallel_group`, `produces`) so the disjointness and ordering a future launcher needs survive across sessions.

---

## How the kernel separates state: the `.swarm/` workspace

Externalised state is not a single per-task file in a flat folder. The kernel structures it as the [workspace model](../model/workspace.md): externalised state is partitioned by *which question it answers*, and one partition must never silently overwrite another.

| Partition | Answers | Holds | Committed? |
| --- | --- | --- | --- |
| [`sources/`](../model/source-artifacts.md) | desired truth — what the project *intends* | specs, PRDs, RFCs, research, audits, findings, ADRs | yes |
| [`status/`](../artifacts/status.md) | observed satisfaction + drift — what the code is *observed* to do now | per-spec satisfaction reports, task/worktree state | yes |
| `generated/` | execution packets — recreatable from `sources/` | the lowered `task.md` frames, traces, reviews | mostly gitignored |

A [`task.md`](../artifacts/task.md) is **generated/derived execution material**: it carries no original intent, it is recreatable from its source spec by the `lower`/`decompose` pass, so it lives under `.swarm/generated/tasks/` and is mostly gitignored. The durable summary of a completed task is *compacted into* [`.swarm/ledger/`](../model/workspace.md) rather than kept as a permanent scratchpad — which is what lets `generated/` be safely discarded. A task packet is personal, gitignored, and discarded once the deliverable lands, routed through a typed workspace rather than a flat folder: the durable facts are lifted out into `status/`, `memory/`, and `ledger/`; only the recreatable packet is thrown away.

The same separation prevents observed reality from masquerading as authored intent: a [`status`](../artifacts/status.md) artifact records the latest verdict per obligation beside the spec, never inside it, so the spec stays a stable statement of intent while observation churns next to it.

---

## The counter-evidence: externalisation is not free

The same research base that justifies externalised state also bounds it. A fabricated arXiv figure that circulates in the skill-authoring literature would purport to ground an upper bound (a claimed "21× degradation when file-state externalisation is removed"). That id was misattributed — it resolves to an unrelated condensed-matter physics paper — and it is **rejected**: it is not cited here, and its number is not repeated (see [sources.md § Rejected](sources.md#rejected--do-not-cite-fabricated--misattributed)). The bound is real; the figure was not.

The verified bound is the **density / Lost-in-the-Middle tradeoff**. [LOSTMID](sources.md#LOSTMID) (*Lost in the Middle*, TACL 2024) establishes a U-shaped attention curve: a model retrieves information from the start and end of a long context far more reliably than from the middle. The implication for externalised state is direct and two-sided:

- **Externalising helps** because it keeps the live context small — the agent re-reads the *relevant* section of a file per turn rather than carrying the whole history forward.
- **Over-externalising hurts** because an always-loaded file that grows without bound pushes its own load-bearing lines into the U-curve trough, where they are least likely to be attended to.

This is exactly the tradeoff the kernel's **density cap** balances: always-loaded normative prose — most concretely the [`AGENTS.md` bootloader](#agentsmd-the-always-loaded-bootloader) — is capped at **≤200 lines / ≤25 KB**, with everything procedural moved to lazily-loaded [pass guides](../library/pass-guides.md) and [profiles](../library/heuristic-profiles.md). The cap's rationale is the [LOSTMID](sources.md#LOSTMID) U-curve *plus* a bloat-versus-gap-filling tradeoff — a context file too thin omits the commands an agent needs, a context file too fat buries them — and is held "to protect adherence and cost, **not** because models cannot follow many instructions" (see [PRINCIPLES § Load-bearing meaning lives only in SOL + IR](../PRINCIPLES.md)). There is no capability-ceiling claim here, and this page introduces none.

A complementary, verified bound comes from [AGENTSMD-HARM](sources.md#AGENTSMD-HARM) (*Evaluating AGENTS.md*, ETH Zürich, plus its efficiency companion): repository-specific commands are used far more often when *named* in the context file than when not, while LLM-*generated* narrative context can cost more than it returns. The design lesson the kernel takes from this is "name the commands, minimise the narrative" — which is exactly the [`AGENTS.md > Commands`](#agentsmd-the-always-loaded-bootloader) contract below, not a padded scratchpad.

> Practitioner and preliminary sources point the same direction. [TWOPROBLEMS](sources.md#TWOPROBLEMS) distinguishes activation failure from silent step-skipping, and [PRACTITIONER](sources.md#PRACTITIONER) catalogues "template theatre" — scaffolds that ship but rarely apply. These are **non-peer-reviewed and illustrative only**; the load-bearing version of the discipline is [REFLEXION](sources.md#REFLEXION) plus the empirical-proof rule, not these blog measurements. They are noted to show the direction is widely observed, never to ground a `MUST`.

---

## Externalised state must carry forced-visible proof

Externalising state is necessary but not sufficient: a written task frame is only as trustworthy as the evidence pasted into it. The kernel's **forced-visible-output rule** closes the gap — *"`Tests passed` without output is invalid: a `PASS` whose `EVIDENCE` is the bare phrase 'tests passed', with no command, exit code, run output, or selector resolution, is `UNVERIFIED`"* (see [the `verify` pass](../passes/verify.md)). This is the empirical-proof projection of [REFLEXION](sources.md#REFLEXION): a verdict that lives only as an unbacked claim in context is exactly the implicit signal Reflexion shows is weaker than a written, re-readable one. A `task.md`'s `## Verification matrix` is where that proof is pasted, per obligation, so the claim and its evidence travel together.

The proof binding itself resolves through the always-loaded bootloader.

### `AGENTS.md`: the always-loaded bootloader

[`AGENTS.md`](../model/workspace.md) is the one always-loaded file in an adopted project — the bootloader that tells an agent how to *start* correctly. Because it is always-on, it carries the density cap above (≤200 lines / ≤25 KB). Its load-bearing payload is a **Commands table**: the `{{cmd*}}` placeholder slots in that table are the adapters that a `VERIFY BY <type>:<adapter>:<artifact>` proof binding resolves through ([ADR 0018](../adrs/0018-agents-md-command-contract.md), [ADR 0038](../adrs/0038-verify-by-adapters-through-commands.md), and [the `verify` pass § two-layer resolution](../passes/verify.md)). Keeping the proof *type* in the obligation and the *command* in `AGENTS.md` is what lets the same spec port across repositories: only the Commands table changes. A binding whose adapter has no matching Commands row is not silently passed — it is `BLOCKED`, never `PASS`. The [AGENTSMD-HARM](sources.md#AGENTSMD-HARM) finding — named commands beat narrative — is the empirical reason this contract is a *table of commands*, not prose.

---

## Activation: load what the task names

A note on how an externalised method reaches the agent at all, under the kernel's loading doctrine.

The kernel's **primary** activation mechanism is *load what the task names*: a [`task.md`](../artifacts/task.md) names, in its frontmatter, the [pass guide(s)](../library/pass-guides.md) and [profile(s)](../library/heuristic-profiles.md) it activates for its pass, and the agent loads exactly those and nothing else. Description-match self-activation — matching a guide's `description` field against the task — is a **degraded-mode fallback**, retained only for the launcher-less case where a task is dropped into an arbitrary agent CLI with no router. The directive, exclusion-bearing four-clause description form is an authoring heuristic that helps the *fallback* fire; it is **not** the primary loader, and it is not "the most load-bearing line." Its only supporting source, [ACTIVATION-BLOG](sources.md#ACTIVATION-BLOG), is a **non-peer-reviewed self-published measurement**; its specific activation numbers are not load-bearing, and only the *direction* (directive descriptions help the fallback) is used, as illustration. This matters for externalised state because it is *why* a `task.md` carries explicit `pass_guides` / `profile` fields: the file names its own method so activation does not depend on a description match.

---

## See also

- [sources.md](sources.md) — the bibliography every citation on this page resolves to, with caveats and the rejected-claim record.
- [`docs/artifacts/task.md`](../artifacts/task.md) — the contract for the `task.md` frame whose research backing this page is.
- [`docs/artifacts/status.md`](../artifacts/status.md) — the observed-state read-model that absorbs time-varying verdicts so a spec stays stable intent.
- [`docs/model/workspace.md`](../model/workspace.md) — the `.swarm/` `sources/ status/ generated/` split and the always-loaded `AGENTS.md` bootloader.
- [`docs/library/pass-guides.md`](../library/pass-guides.md) and [`docs/library/heuristic-profiles.md`](../library/heuristic-profiles.md) — the lazily-loaded method and stance layers a task names, and the loading doctrine.
- [`docs/passes/verify.md`](../passes/verify.md) — the forced-visible-output rule and the two-layer proof resolution through `AGENTS.md > Commands`.
- [`docs/PRINCIPLES.md`](../PRINCIPLES.md) — the density-cap rationale and the evidence discipline this research layer is held to.
