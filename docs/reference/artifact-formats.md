# Artifact formats

_Works today — plain markdown plus your agent; no Corpus tooling required._

This is the catalogue of every file type a Corpus workspace may contain: what each artifact is
for, its frontmatter, its required sections, and the few rules that carry real weight. The full
shapes live in the kit templates — this page links them and never restates them. Where each file
sits in the workspace is [where files live](../03-where-files-live.md).

## How a file is identified

Every Corpus artifact is a plain `.md` file. The frontmatter `type:` line identifies it — agents
and tools read `type:`, never the filename or the directory. Name your files whatever reads well;
the type travels with the file.

The type values:

> `intake` · `spec` · `task` · `review` · `finding` · `status` · `inventory` · `change-plan` ·
> `audit` · `bug-report` · `adr` · `research` · `prd` · `rfc` · `threat-model` · `release-note`

This is a convention — nothing in this repo enforces it. corpus-cli's `corpus check` reads
`type:` to decide what to check; until you run a tool like that, treat a missing or wrong `type:`
as a review checklist item.

Two frontmatter selectors matter beyond `type:`:

- `format: sol` on a spec opts that one file into the stricter requirement notation
  ([structured requirements](structured-requirements.md)). Same data, stricter surface; review
  reads both forms identically.
- Everything else is per-artifact, listed below.

**ID conventions.** Artifacts: `SPEC-*`, `TASK-*`, `REVIEW-*`, `FINDING-*`, `AUDIT-*`, `INV-*`, `CHANGE-*`.
Within a spec: requirements `AC-NNN` (constraints `C-NNN` and invariants `I-NNN` in SOL form).
Within a research doc: findings `R-NNN`. A preservation guarantee with no spec id: `PG-NNN`.
Cross-file references join with `#`: `SPEC-checkout#AC-003`, `payments-survey#R-002`.

## Naming

A **slug** is the kebab-case name an artifact chain shares: `specs/auth-refresh/spec.md` →
`tasks/auth-refresh-client.md` → `reviews/auth-refresh-client.md`. Flat files (`tasks/<slug>.md`)
and numbered folders (`tasks/012-<slug>/task.md`) are both valid — pick one and stay with it.
The review packet is named after its task's slug. ID prefixes: `SPEC- TASK- REVIEW- FINDING-
INV- CHANGE-`, requirement ids `AC-NNN` (`C-`/`I-` in SOL form); keep one casing for slugs.

## Core artifacts

### intake — what was actually asked

Template: [`templates/intake.md`](https://github.com/jcosta33/corpus-starter-kit/blob/main/templates/intake.md) · lives in `intake/`

A verbatim snapshot of the upstream item — ticket, issue, page — captured before anyone
interprets it. Recommended when work originates in an external tracker; never required.

- Frontmatter: `type: intake`, `source`, `url`, `captured`. No id, no status.
- Body: the upstream content **pasted verbatim** — never edited, never summarized. The spec
  interprets; the intake preserves. Without it, upstream edits silently orphan the spec.
- The spec cites the intake file in its `sources` — that's the whole linkage.

### spec — what should be true

Template: [`templates/spec.md`](https://github.com/jcosta33/corpus-starter-kit/blob/main/templates/spec.md) · lives in `specs/<feature>/spec.md`

The durable statement of intended behavior: requirements an agent can build from and a review
can check. Supporting docs (audit, research, prd, rfc) sit in the same feature folder, the
convention spec-driven toolkits converge on
[[SPECKIT]](../research/sources.md#SPECKIT) [[KIRO]](../research/sources.md#KIRO).

- Frontmatter: `type: spec`, `id: SPEC-*`, `title`, `status` (draft / ready; the richer states —
  in-progress, blocked, done, stale — live on the workboard, not here), `owner`, `sources` —
  plus optional `format: sol`.
- Sections: Intent · Non-goals · Requirements · Open questions · Affected areas · Dropped from
  sources (optional, recommended).
- Each requirement is a `### AC-NNN — name` heading: one sentence of observable behavior
  ("When X, the component must Y.") and a `Verify with:` line. That line is the highest-value
  line in the file — a runnable check outperforms prose plans as task input (preliminary evidence)
  [[ORACLESWE]](../research/sources.md#ORACLESWE).
- An open question keeps a spec out of `status: ready` unless marked "(non-blocking)" (plain form) / `[non-blocking]` (SOL form) — checklist level.
- Specs are amended in place after review feedback: edit the requirement, keep its ID. What the
  sources asked for but the spec deliberately drops goes under "Dropped from sources" — that's
  where design rationale survives.

Full writing guidance: [writing specs](../04-writing-specs.md) and [checks](checks.md).

### task — the packet that bounds one agent run

Template: [`templates/task.md`](https://github.com/jcosta33/corpus-starter-kit/blob/main/templates/task.md) · lives in `tasks/`

One agent run gets one task packet: its sources, the requirement ids in scope, what not to
touch, and how to verify.

- Frontmatter: `type: task`, `id: TASK-*`, `source` (a spec and/or a change plan),
  `scope` (requirement ids), `status` (ready / running / review-ready / closed).
- Sections: Source · Scope ("Implement or preserve") · Do not change · Affected areas · Verify ·
  Agent instructions · Findings · Run summary (the handoff digest — changed files, results
  citing the Verify pastes, out-of-scope edits, blocked questions, and — for a delegated/worker-run
  task only — an optional Provenance line: sources read, guide(s) loaded, worker identity,
  isolation mode; it cites the evidence, never re-pastes it).
- Every Verify item is a runnable command tied to a requirement id; the agent pastes real
  output — a claim without output counts as unverified.
- The agent instructions tell the agent to stop and say why when a requirement can't be met as
  written, rather than improvising — preliminary evidence places the planner→coder handoff as
  the dominant multi-agent failure surface [[PLANCODER]](../research/sources.md#PLANCODER).
- The Findings section collects durable discoveries during the run; the Close step moves them
  to `findings/`.

### review — the record of work

Template: [`templates/review.md`](https://github.com/jcosta33/corpus-starter-kit/blob/main/templates/review.md) · lives in `reviews/`

The review packet turns an agent run into requirement coverage, evidence, and a short
human-attention list. It is the durable record of the work — the PR links it; reviewing the
packet is reviewing the change.

- Frontmatter: `type: review`, `id: REVIEW-*`, `task`, `pr`, `reviewer` (the named human or
  fresh session — never the implementing one),
  `status: draft | pass | waived | blocked | needs-human` (`waived` = merged with a recorded
  waiver: who · which rows · why · expiry).
- Sections: Summary · Changed files · Requirement coverage · Change-plan coverage (only when
  the task executes a change plan) · Human attention · Open decisions (optional; only when the work
  closes with a decision the human must make — ADR-0089) · Task status (confirm the board row and the
  task packet's own `status:` are updated together at closeout) · Suggested decision.
- Coverage rows are `ID | Result | Evidence | Human attention`, results
  **Pass · Fail · Unverified · Blocked**.

The load-bearing rules:

- **A Pass needs pasted output, a CI link, or, for a manual Verify method, a named human's
  recorded observation (who judged, what they saw). An empty Evidence cell means Unverified,
  never Pass** (checklist level). "Tests passed" without the output is not evidence
  [[EVIBOUND]](../research/sources.md#EVIBOUND).
- **Spot-check at least one green row's evidence yourself** (convention level) — structure alone
  doesn't remove the reviewer's bias toward agent output
  [[SELFPREFER]](../research/sources.md#SELFPREFER) [[JUDGEBIAS]](../research/sources.md#JUDGEBIAS).
- **Human attention routes the exceptions, not the diff**: unverified or failed requirements ·
  out-of-scope changes · risky files · missing test output · changed public interfaces · DB
  migrations · security-sensitive changes · new finding candidates · blocked questions · missing
  or unconvincing worker-boot provenance for a delegated task.
- **Open decisions frames a fork, not a finding** (convention; ADR-0089): include it only when the
  work closes with a decision the human must make — the orchestrator is deep in another agent's
  context and the agent that did the work is the one still holding this one's. Each open decision
  carries: the decision · 2–4 comparable options — the case _for and against_, not a lone
  recommendation [[EVALAI]](../research/sources.md#EVALAI) · a recommendation + a brief why · the
  context/impact the human may not hold · what it blocks. The section **routes** the decision — it
  presents and recommends, the human decides (a fact, never a verdict — ADR-0077 Decision 8). Keep the
  "why" short and verification-oriented (how sure · what would change it · what it blocks), not a
  persuasion essay [[OVERTRUST-CFF]](../research/sources.md#OVERTRUST-CFF); list options, never tally
  them; skip the whole section when nothing is open.
- A review judges; it does not author. A gap it uncovers in what _should_ have been required
  becomes a spec amendment or a finding — never a requirement written into the review.

The extended result lifecycle (Waived, Stale, Contradicted) belongs to the
[advanced lifecycle](advanced-lifecycle.md); the results above are the working set.

### finding — what survives the session

Template: [`templates/finding.md`](https://github.com/jcosta33/corpus-starter-kit/blob/main/templates/finding.md) · lives in `findings/`

One durable lesson, saved before the task closes. The Close-step rule: _before closing a task,
record anything durable as a finding._

- Frontmatter: `type: finding`, `id: FINDING-*`, `status: candidate | accepted | stale`,
  `from` (the task or review that produced it), `date`, `related` (requirement ids).
- Sections: What we learned · Evidence · Where it applies · Where it does not apply ·
  Future guidance.
- **One finding, one claim.** A finding that bundles several facts can't be checked, scoped, or
  retired as a unit — split it.
- **A finding must be falsifiable.** Without evidence — the review packet, PR, or pasted output
  that grounds it — it is chat, not memory: nothing can ever re-verify or retire it.
- **A finding names its scope.** "Where it applies / does not apply" is what lets a future task
  match the lesson to a situation; an unscoped fact is dead weight.
- A finding records what was _learned_, never what the system is required to do. If a discovery
  implies a requirement, that goes into a spec — an authoring act, not a filing one.

Findings start as `candidate`; the status board lists those pending acceptance. Teams that
outgrow grep-and-board recall graduate to the [advanced memory model](memory.md).

### status — the workboard

Template: [`templates/status.md`](https://github.com/jcosta33/corpus-starter-kit/blob/main/templates/status.md) · lives at the workspace root

A hand-edited board: one row per spec, task, review, and finding with its state and link, plus a
Human-attention list (blocking questions on draft specs · tasks with no review packet · findings
pending acceptance). Stale specs are flagged here.

- Frontmatter: `type: status` — nothing else.
- One honest rule (checklist level): **a "verified" or "done" claim on the board links its
  review packet.** No link, no claim.

The board is a human summary, not a derivation — the machine-derived per-spec table is the
[coverage read-model](#the-coverage-read-model-future-cli) below, which no shipped tool
produces today.

## Conditionally-core artifacts

Written when the work is structural or brownfield; skipped otherwise. The skip is required, not
a concession — indiscriminate clarification-forcing on work that doesn't need it measurably hurts — extending that to artifacts is design rationale
[[HUMANEVALCOMM]](../research/sources.md#HUMANEVALCOMM)
[[ASKORASSUME]](../research/sources.md#ASKORASSUME). No inventory for a single-file cleanup; no
change plan for an obvious bug fix.

### inventory — the map of what exists

Template: [`templates/inventory.md`](https://github.com/jcosta33/corpus-starter-kit/blob/main/templates/inventory.md) · lives in `inventory/`

The brownfield prerequisite: reconstruct what exists before anyone draws new boundaries.

- Frontmatter: `type: inventory`, `id: INV-*`, `title`, `status`, `owner`, `sources`, `created`.
- Sections: Scope · Current modules · Current interfaces (callers, observed contracts) ·
  Observed behavior · Known risks · Existing tests · Unknowns.
- **It observes and maps; it never judges (that's the audit) and never prescribes (that's the
  change plan).** Three documents, three stances — don't blend them.
- Every Observed-behavior row carries evidence: a test, a `file:line`, an output.
- Unknowns is the honest edge of the map: who may depend on shapes and values you cannot see
  from here. With enough users, every observable behavior is depended on by someone — the
  unknowns list is where that risk gets a name.

### change-plan — how the codebase changes safely

Template: [`templates/change-plan.md`](https://github.com/jcosta33/corpus-starter-kit/blob/main/templates/change-plan.md) · lives in `change-plans/`

A spec answers "what behavior should exist"; a change plan answers "how does the codebase change
safely" — for refactors, rewrites, migrations, dependency upgrades, performance, test-infra,
mechanical and architecture cleanups, and schema changes (the `kind` values).

- Frontmatter: `type: change-plan`, `id: CHANGE-*`, `title`, `status`, `kind`, `owner`,
  `sources` (inventory / audit / spec / finding), `preserves` (spec requirement ids), `created`.
- Sections: Intent · Why · Baseline · Target state · Behavioral preservation guarantees ·
  Non-goals · Affected surfaces · Risk areas · Transformation waves · Cutover conditions ·
  Rollback criteria · Verification strategy · Review focus · Task split.

The load-bearing rules:

- **Preservation guarantees are enumerated, never gestured at.** The table is
  `ID | Behavior | Verify with` — "no behavior change" is not a guarantee; a list of behaviors
  with checks is. Guarantee rows reuse the spec's own requirement ids via `preserves`; a
  guarantee with no spec id gets `PG-NNN` and usually signals a spec amendment is owed.
- **Affected surfaces count callers, not just edit sites.** When the surface is a shared
  signature or interface, the surfaces that change include its callers — enumerate them from the
  inventory's `Current interfaces (callers)` column, not only the files you touch (convention; see
  [Brownfield & change plans](../05-brownfield-and-change-plans.md)).
- **Each wave leaves the codebase green** and names its verify step; use a bridge release where
  external consumers exist.
- A task executing a wave names the plan in its `source` and reads its Scope as "implement or
  preserve"; its review packet carries the Change-plan coverage table — same
  `ID | Result | Evidence` columns as requirement coverage.
- The plan's benefit is a convention — no controlled study of the document itself exists; the
  recorded ground is the planning literature and the mature migration ecosystems it distills.

## Advanced artifacts

Each advanced artifact is allowed to assert exactly one kind of knowledge — its stance — and the
stances do not mix. The shared rule: **promotion into a spec is an authoring act.** Content from
any of these gains requirement force only when someone writes it into a spec with its own
`AC-NNN` and `Verify with:` line; nothing becomes binding by sitting in its source document
(convention level). Templates ship in [`advanced/`](https://github.com/jcosta33/corpus-starter-kit/tree/main/advanced/)
except where noted.

### audit — observation only

`type: audit`. Present-state risk, debt, and drift, as they exist today. **An audit never
prescribes**: it records what _is_, grounds every observation in evidence (`file:line`, command
output), and calibrates severity by blast radius — the remedy belongs to a downstream spec or
task. Recommending candidate requirements in prose is expected; writing requirements into the
audit is not. The recommended first artifact for brownfield teams.

### bug-report — diagnosis only

`type: bug-report`. Reproduces a defect deterministically, isolates the root cause, and names
the requirement it violates. **A bug report never fixes**: diagnosis is evidence work, the patch
is intent work, and combining them biases toward premature fixes. The fix is a task that cites
the report. If no existing requirement covers the broken behavior, the report records the gap —
and amending the spec is the fix task's first move.

### adr — the immutable decision

`type: adr`. One architecture decision in Nygard form — context, decision, consequences,
status — kept as short, sequentially-numbered files in `decisions/`, one decision per file
[[ADR-CONV]](../research/sources.md#ADR-CONV). **Once accepted, an ADR is never edited in
place**: amending means writing a new superseding ADR; the old one keeps its body and gains only
a "Superseded by ADR-NNNN" line. The truth of a decision is the full chain, not the latest file —
a reversed decision is recorded as supersession, never as a quiet edit.

### research — inquiry, no decision

`type: research`. One decision-informing question, surveyed against checkable sources. Findings
are numbered spans (`R-NNN`: claim, evidence, confidence) that downstream docs cite as
`<id>#R-NNN` instead of copying; open questions carry forward instead of being quietly settled;
the closing recommendation is advisory — **research commits to no decision**. One research doc
may feed many specs, ADRs, and findings; an accepted `R-NNN` can graduate to a standalone finding.

### prd — product intent

`type: prd`. The problem, the affected users, and the outcomes that define success — _what is
wanted and why_, nothing about mechanism. Non-goals are mandatory: an intent without a boundary
is a defect. A PRD is non-authoritative until a spec is authored from it; afterward it remains
the citable record of why the requirements exist.

### rfc — one proposal, decision requested

`type: rfc`. One technical proposal put forward for a decision: the problem, the advocated
approach, the alternatives weighed, and the exact decision requested — so _why this approach and
not the others_ outlives the change. **An RFC commits nothing** until the decision is made; the
Alternatives section is mandatory, and "none considered" is a defect. It promotes to an ADR (the
decision) and/or a spec (the behavior).

### threat-model — threat observation

`type: threat-model`. What could go wrong on a security-sensitive surface: assets, attacker
model, threats, observed exposure. A stance like the audit's, pointed at attack surfaces — it
states no countermeasure requirements of its own. A modelled threat becomes binding only when
authored into a spec as a requirement with its own id and verification.

### release-note — a named type only

`type: release-note`. The reserved type for human-facing release summaries kept in the
workspace, so tools and agents can tell them apart from everything else. No template ships —
shape it to your audience.

## The coverage read-model (future CLI)

A machine-derived per-spec table no shipped tool produces today. For one spec, one row per
requirement: the latest review result, the review packet that produced
it, the evidence link, and a staleness flag (the requirement text changed after the result was
recorded). Everything in it derives from the spec and the review packets — it authors nothing
and re-judges nothing, which is exactly why it should be machine-written.

(`corpus status` ships today and prints the derived board; deriving _this_ per-spec
requirement-coverage table from `specs/` and `reviews/` is the deferred coverage engine — today the
hand-edited workboard plus the review packets are the record, and assembling the table by hand
for one spec is occasionally worth it before a large merge.) The contract lives in
[future-cli.md](future-cli.md).

## Related

- [Where files live](../03-where-files-live.md) — the workspace tree these artifacts sit in
- [`templates/`](https://github.com/jcosta33/corpus-starter-kit/tree/main/templates/) — the core template texts (the frozen shapes)
- [Structured requirements](structured-requirements.md) — the optional `format: sol` surface
- [Checks](checks.md) — common mistakes a review inspects, per artifact
- [Memory](memory.md) — the advanced recall model findings graduate into
- [Advanced lifecycle](advanced-lifecycle.md) — the full step and result taxonomy
- [Future CLI](future-cli.md) — the contracts for tooling that does not exist yet
