# The advanced lifecycle

*Advanced design note — internal rationale; not needed to use Corpus.*

The six-step loop — **Pull → Spec → Task → Run → Review → Close** — is the default way to work
([basic workflow](../02-basic-workflow.md)). Underneath it sits a finer-grained **nine-step
lifecycle** that names every transformation a piece of work can pass through:

```text
author → lint → improve → lower → decompose → implement → verify → review → promote
```

This page defines those steps, maps them onto the six-step loop, and carries the machinery the
happy-path pages deliberately leave out: the improve operations, the full review-result model,
the merge gate in plain words, the rules for running tasks in parallel, and drift. Nothing here is
software — every step is performed today by a person or an agent following a guide.

## When to use the full lifecycle (risk scaling)

The six steps are the default; the full lifecycle is for **high-risk changes**. Treat a change as
high-risk when it touches security-sensitive surfaces, public interfaces, or data migrations; when
several agents will work in parallel on the same feature; or when a wrong result is expensive to
detect or undo. For everything else, collapse the lifecycle into the six steps — and keep the
skip-paths: forced clarification on already-clear tasks measurably hurts (the document analogue is design rationale)
[[HUMANEVALCOMM]](../research/sources.md#HUMANEVALCOMM)
[[ASKORASSUME]](../research/sources.md#ASKORASSUME), so skipping is required practice, not a
concession. This is a convention — nothing in this repo enforces it.

## The nine steps

| Step | What it does | Covered by |
|---|---|---|
| `author` | Write the source document — usually a spec; for brownfield or structural work, an inventory, change plan, or audit. | the `write-spec` guide (kit core); `write-inventory`, `write-change-plan`, `write-audit` (kit) |
| `lint` | Read the spec against the [common mistakes to check for](checks.md) without changing a word. Diagnose only. | the `spec-check` guide (kit) |
| `improve` | Repair what `lint` found — the operations below — without changing what the spec means. | the `spec-check` guide (kit) |
| `lower` | Restate each requirement as a structured item with a stable ID, its verification method, its dependencies, and the files it may touch. | the `split-work` guide (kit) |
| `decompose` | Split the structured requirements into bounded tasks whose written files do not overlap, and order them by dependency. | the `split-work` guide (kit) |
| `implement` | Do the work inside one task's scope; record what changed, the commands run, and their real output. | the `implement-task` guide (kit core) |
| `verify` | Run every verification method named by the task and record a result per requirement. Evidence-gathering only — no judgment. | the `implement-task` guide; the reviewer re-runs |
| `review` | Judge the agent's claims against the requirements and the evidence; fill the review packet; decide the merge gate. | the `review-output` guide (kit core) |
| `promote` | Save anything durable as a finding, update the workboard, close. | the `save-findings` guide (kit) |

Three boundaries keep the steps honest:

- **`lint` never edits; `improve` is the only step that may rewrite the spec** — and only without
  changing meaning. A meaning change is an amendment and goes back through review.
- **`lower` and `decompose` are distinct:** `lower` structures the requirements; `decompose`
  partitions the work. Deliberate decomposition into bounded sub-units beats flat one-shot
  generation over a whole spec [[TREEOFTHOUGHTS]](../research/sources.md#TREEOFTHOUGHTS), and a
  structured intermediate beats free-form prose as input to code generation
  [[SCOT]](../research/sources.md#SCOT).
- **`verify` gathers; `review` judges.** A pasted test run is evidence; calling it a Pass is a
  judgment that belongs to review.

Checking a spec is toolable — swarm-cli's `swarm check` is the reference implementation of the
checks `lint` reads; until you run it, treat `lint` as a review checklist. The output of `lower`
and `decompose` is the **task files themselves** — there is no separate machine artifact; swarm-cli
parses the markdown internally and may project `--json` for interop (no `ir.json`/`plan.json` file,
per [ADR-0077](../adrs/0077-swarm-cli-reconcile-only-harness.md)).

## Six steps ↔ nine steps

| Six-step loop | Nine-step lifecycle | Notes |
|---|---|---|
| Pull | intake capture | Pull is input capture, not a transformation: the ticket lands as an intake file the lifecycle starts from. |
| Inventory *(conditional)* | `author` (inventory) | Brownfield prerequisite — map what exists before drawing new boundaries. |
| Spec | `author` → `lint` → `improve` | Spec collapses three steps: write, check, repair. |
| Change Plan *(conditional)* | `author` (change plan) | Structural work — how the codebase changes safely, wave by wave. |
| Task | `lower` → `decompose` | Prepare tasks and split work. |
| Run | `implement` → `verify` | The agent works, then every verification method runs. |
| Review | `review` | The review packet and the merge gate. |
| Close | `promote` (+ status update) | Save findings, update the workboard. |

The two conditional steps appear only for structural or brownfield work; a feature from a clean
ticket never sees them.

## Two checkpoints between the steps

Two checkpoints bracket the task-preparation steps. Neither writes anything — each is a question
asked before advancing, and both are review checklist items today. swarm-cli's `swarm check`
flags part of the first — an open blocking question, a leftover `TBD` at `status: ready`
(toolable); the unresolved-contradiction and lingering-ambiguity calls stay review judgment, and
nothing enforces either.

- **Clarify before splitting** (between `improve` and `lower`). Work is not split while the spec
  carries an open blocking question, an unresolved contradiction between requirements, or an
  ambiguity nobody has lifted into an explicit interpretation. The cheapest place to resolve any of
  these is before an agent starts generating — preliminary evidence places the planner→coder
  handoff as the dominant multi-agent failure surface
  [[PLANCODER]](../research/sources.md#PLANCODER), and ambiguity that survives into the tasks is
  exactly what strands a coding agent mid-run
  [[HILBENCH]](../research/sources.md#HILBENCH).
- **Coverage before running** (between `decompose` and `implement`). Every in-scope requirement is
  assigned to exactly one task — none unassigned, none assigned twice, with one context
  carve-out (platform or repo, the latter only when the requirement is independently
  verifiable in each repo): the same requirement may scope to N context tasks when each
  verifies it whole in its own context, and it reads green at spec level only when every
  context task shows Pass —
  and everything a task
  points at (a requirement ID, a verification method) resolves to something that exists. The first
  half forbids stranding a requirement; the second forbids a task built on a phantom.

## The improve operations

The rule first: **improve repairs the text, never the intent.** Any edit that adds, removes,
weakens, or strengthens a requirement — a new actor, a changed trigger, a relaxed constraint — is
an amendment, not an improvement, and routes back through review. This is a checklist rule: the
reviewer inspects an improved spec's diff for smuggled meaning changes.

| # | Operation | Repairs |
|---|---|---|
| 1 | NORMALIZE | Informal or non-canonical phrasing → the standard requirement form, no meaning changed. |
| 2 | ATOMIZE | One requirement bundling several separable behaviors → one requirement each, with its own ID. |
| 3 | CONCRETIZE | A vague quality word ("robust", "fast") → observable behavior: actor + action + object. |
| 4 | QUANTIFY | An unbounded quality → a measurable threshold or named measurable criterion. |
| 5 | BIND | A requirement with no verification method → a runnable `Verify with:` line. |
| 6 | SCOPE | Missing non-goals, applicability, or affected areas → stated explicitly. |
| 7 | CLARIFY | Ambiguity buried in prose → an explicit interpretation, or an open question. |
| 8 | DECONFLICT | Two requirements that contradict → resolved against the higher-authority source, or raised as an amendment. |
| 9 | COMPRESS | Noise and redundancy → removed, so every agent reads the text the same way. |
| 10 | PROMOTE | A durable fact stranded in a task file → moved to a finding, the spec, or a decision record with provenance. |

Two distinctions worth pinning: CONCRETIZE and QUANTIFY answer the same vagueness — the first with
observable behavior (qualitative), the second with a threshold (quantitative); pick whichever the
requirement's nature demands. And ATOMIZE is not decomposition: ATOMIZE splits one bundled
requirement *inside* the spec; splitting the *work* is the `decompose` step.

Why this discipline earns its place: ambiguous or incomplete task input measurably degrades agent
code correctness [[ORCHID]](../research/sources.md#ORCHID)
[[HUMANEVALCOMM]](../research/sources.md#HUMANEVALCOMM), and models usually code anyway instead of
asking [[HUMANEVALCOMM]](../research/sources.md#HUMANEVALCOMM)
[[HILBENCH]](../research/sources.md#HILBENCH). Repairing the requirement text recovers the loss,
and the repaired text transfers across models [[CLARIFYGPT]](../research/sources.md#CLARIFYGPT)
[[SPECFIX]](../research/sources.md#SPECFIX). The highest-leverage repair is BIND: an executable
acceptance criterion outperforms prose plans as task input (preliminary evidence)
[[ORACLESWE]](../research/sources.md#ORACLESWE). And preliminary multi-agent evidence places the
planner→coder handoff as the dominant failure surface
[[PLANCODER]](../research/sources.md#PLANCODER) — which is why CLARIFY and DECONFLICT run *before*
work is split, not after an agent has already guessed.

## The full review-result model

The happy-path review results are **Pass, Fail, Unverified, Blocked** — one per requirement, one
row each in the review packet ([reviewing output](../08-reviewing-output.md); format:
[artifact-formats](artifact-formats.md)). The full model adds three **lifecycle values** that
annotate a core result rather than replace it. They appear when work spans time, exceptions, or
disagreement. (The glossary's internal name for a recorded result is a *verdict*.)

The core results — exactly one per requirement per run:

| Result | Meaning |
|---|---|
| Pass | The verification ran and the requirement held. |
| Fail | The verification ran and the requirement did not hold. |
| Blocked | The verification could not run — a tool, fixture, or environment was missing. Truth unknown, not false. |
| Unverified | No verification method was bound, or none was run. |

Blocked and Unverified route differently — Blocked is an environment fix, Unverified is a missing
binding or a skipped run. A reviewer who cannot tell which happened records Unverified, the weaker
and more honest claim. And "tests passed" with no command, exit code, or output is not evidence of
anything [[EVIBOUND]](../research/sources.md#EVIBOUND) — an empty Evidence cell means Unverified,
never Pass.

The lifecycle values — each with required fields, without which it cannot be audited:

| Value | Annotates | Meaning | Required fields |
|---|---|---|---|
| Waived | Fail or Unverified only | The miss is explicitly accepted as an exception. | who waived it · why · expiry date |
| Stale | a prior Pass only | The evidence no longer matches the current text or code (drift). | the prior result · what changed |
| Contradicted | any result | Two pieces of evidence disagree, or the claim disagrees with the requirement. | both conflicting evidence references |

Three placement rules follow from the meanings: a Pass is never waived (there is nothing to
excuse); only a Pass can go Stale (a Fail was never trusted, so it cannot lapse); Contradicted can
land anywhere, because contradiction is a relationship between two pieces of evidence regardless of
either's own result. A waiver with no expiry is a zombie — there are no permanent waivers, and a
waiver lapses when the waived requirement's text changes.

## The merge gate, in plain words

> A change set may merge **only when every requirement in scope shows Pass or a live Waived — and
> none shows Fail, Blocked, Unverified, Stale, or Contradicted** on its latest recorded result.

One guard rail: an empty scope never passes by vacuity. A change no requirement covers does not
merge "because nothing failed" — it waits until a spec amendment covers it, the change is reverted,
or the review packet records it as an accepted out-of-scope change with a reason.

**Post-merge evidence** (infra applies, soak metrics): when a requirement's only honest
evidence is producible after merge, the row records **Blocked** — never a courtesy Unverified —
the human routes it as an exception and records the waiver (who · why · expiry, the annotation's
required fields), and the merge proceeds on the waiver with the packet status `waived`. A
follow-up review row supplies the Pass when the post-merge evidence lands, and the waiver
lapses. Merged packets are never edited — closure is a new row, not a mutation.

This is a review checklist item today — the reviewer reads the gate off the packet's coverage
table. It is toolable: a future `swarm review` in swarm-cli could compute it mechanically from the
same table; until then nothing enforces it.

## When evidence disagrees (Contradicted)

Contradiction is never resolved silently, and never by picking the more convenient result.

1. **Block.** A Contradicted result on any in-scope requirement blocks the merge.
2. **Record both.** The review packet carries both conflicting evidence references — that is what
   makes the disagreement reconcilable later.
3. **Stronger evidence is the working assumption.** While the contradiction is open, the stronger
   evidence (a runnable check over a narrative judgment; output over a summary) is presumed right —
   a *working assumption* that keeps review actionable, not a resolution. Equal-strength evidence
   sets no assumption; it routes to an independent reviewer or a stronger re-check.
4. **Reconcile.** Re-run both checks, fix the weaker one, fix the code, or amend the requirement.
   The Contradicted mark comes off only when the evidence agrees — or one side is withdrawn as
   invalid, with the reason written down.

## Running tasks in parallel

> **Safe parallelism.** Two tasks may run in parallel **iff** they are **dependency-independent**
> (neither needs the other's output) **and write-disjoint** (their affected files share nothing).
> Anything unscoped, or anything sharing a written file, serializes by default. Review capacity and
> merge collisions — not agent count — are the binding constraint.

When several agents do run at once, keep one **coordination record** beside the tasks. Its
essentials, all convention — nothing enforces them:

- **Worker tracker** — one row per worker: its owned paths (which must be pairwise disjoint across
  workers — confirm this *before* spawning anyone), the forbidden paths (everyone else's owned
  paths), branch, and status. One worktree per task; never reused.
- **Hand-off per worker** — objective, expected deliverable, acceptance bar (which requirements
  must reach Pass), and boundaries — recorded as data and carried verbatim into the worker's task
  file, so the boundary the lead wrote and the boundary the worker sees are the same text.
- **Decisions log** — a worker whose progress marker has not advanced across two consecutive checks
  is stalled; the lead takes one recorded action — re-plan, re-scope, escalate, or abandon — and
  writes down why.
- **Merge log** — merge order, conflicts, and how each was resolved. A non-trivial conflict
  resolution must show that *both* sides' intent survived — a green suite alone is necessary but
  not sufficient when the suite may not cover the interaction.

## Drift

A prior Pass goes **Stale** when the requirement's text changes or a file its verification
exercised changes after the result was recorded — the green row is then a claim about a system that
no longer exists. Reconcile by re-running the verification, amending the requirement to match
reality, or fixing the code — never by leaving the stale row standing. The triggers and the
three-way reconcile live in [drift](drift.md).

## Related

- [Basic workflow](../02-basic-workflow.md) — the six-step loop this page deepens.
- [Reviewing output](../08-reviewing-output.md) — the review packet and the core results, in
  happy-path form.
- [Checks](checks.md) — the common mistakes `lint` reads and `improve` repairs.
- [Structured requirements](structured-requirements.md) — the stricter notation high-risk specs
  may opt into.
- [Review stances](review-stances.md) — the optional reading postures that sharpen these steps,
  and the judge-independence rules.
- [Step bars](step-bars.md) — the per-step quality bars, including the finer-step bars for
  this lifecycle.
- [Drift](drift.md) — staleness triggers and the three-way reconcile, in full.
- [Future CLI](future-cli.md) — the reserved machine formats and commands a future tool would add
  to this lifecycle.
