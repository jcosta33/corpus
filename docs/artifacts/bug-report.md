# `bug-report.md`

A bug-report is a diagnosis-only source artifact: it reproduces a defect, isolates its root cause against the artifacts that ground it, and names the obligation the defect violates — without prescribing the fix. It is a parent of a fix task, never a fix itself, and it carries no obligations of its own.

## Purpose & epistemic stance

A bug-report asserts one kind of knowledge: **a defect that is real and understood**. Its stance is **diagnosis-only** — it establishes that an observed failure reproduces deterministically and states the precise cause, and it stops there. It is forensic discovery of a defect, not a statement of intended behavior and not a remedy.

This stance exists because diagnosis and remedy use different proofs and different discipline: reproducing and isolating a defect is evidence work; choosing and writing a patch (with its regression suite) is intent work. Combining them in one document biases toward premature fixes and under-documented regressions. Keeping them in separate hops costs an extra step on a trivial bug but buys clean accountability — the report proves *what is broken*; the downstream fix proves *what was made right*.

What a bug-report MUST NOT do:

- It MUST NOT prescribe an implementation. A bug-report names the cause; it does not state the patch, the diff, the design of the remedy, or "the function should return X instead of null." The remedy is a downstream decision owned by the **fix task** the report promotes into. A bug-report that dictates the fix has crossed from diagnosis into intent and broken its stance.
- It MUST NOT carry its own obligation blocks. A bug-report MUST NOT author `REQ`, `CONSTRAINT`, `INVARIANT`, or `INTERFACE` blocks. It references the *existing* obligation the defect violates; it declares no new intended behavior of its own force. If the defect reveals that **no** existing obligation covers the broken behavior, that gap is itself a finding the promoted fix task must reconcile — the bug-report records the gap, it does not author the missing obligation.
- It MUST NOT assert intended behavior. Stating what the system *should* do is intent and belongs to a `spec.swarm.md`. A bug-report states what the system *does* (Actual) against what an existing obligation already requires (Expected); the delta is the defect, not a new requirement.

This stance is held by the framework's distillation-loss and source-authority discipline — when a diagnosis crosses into a fix task, the loss budget governs what may be dropped and a diagnosis-only artifact MUST NOT silently override a higher-authority spec — not by a gatekeeper tool (Swarm has no runtime): a conformant repository MUST NOT ship a tool whose job is to police artifact composition.

## Filename & placement

A bug-report is a **working artifact**, not a compiler-visible source. Swarm partitions every pipeline file by whether its name carries the literal `.swarm.` infix before the final extension:

- The human-authored, compiler-visible spec is `*.swarm.md` — the only hand-written file that carries the infix.
- Emitted, contract-shaped outputs are `*.swarm.*` (e.g. `*.swarm.ir.json`, `*.swarm.trace.md`).
- Working artifacts — including this one — are plain `.md` with **no** `.swarm.` infix.

Therefore the file is named `bug-report.md` (or a descriptive `<topic>.bug-report.md` / `<topic>.md` in a folder that scopes it). It MUST NOT be named `*.swarm.md`; doing so would mark a diagnosis as a compiler-visible source spec and is a placement defect. A conformant tool treats the missing infix as sufficient proof not to parse the file as a spec.

In an adopted project's `.swarm/` workspace, a bug-report is **durable source material** and lives under sources:

- `.swarm/sources/bug-reports/` — the canonical home; a bug-report records durable diagnostic knowledge about a defect and is committed.
- It does **not** live in `.swarm/generated/` (that holds recreatable execution packets — task frames, traces, reviews) or in `.swarm/status/` (observed satisfaction and drift, which never redefines intent).
- On resolution, a retired bug-report moves to `.swarm/archive/`, linked to the fix task it promoted into — it is not silently deleted.

A conformant kernel ships the `bug-report.md` template, but a conformant repository need not contain any bug-report instance; bug-reports are **conditional** (Tier-3 stdlib source-doc), written only when an observed defect is worth diagnosing and routing to a fix.

## Required sections / fields, in order

### Frontmatter contract

YAML frontmatter delimited by `---`, with at minimum:

| Field | Meaning |
| --- | --- |
| `type: bug-report` | Names the artifact class. Required. |
| `id: <slug>` | The report slug (matches the filename / any index entry). Required. |
| `status: open` | The report's state, advancing forward (e.g. `open` → resolved on promotion / archival). Required. |
| `created` / `updated` | Provenance timestamps: `created` at first diagnosis, `updated` on each transition. Required. |

### Body sections

In order, every conformant bug-report MUST contain these four sections:

| Section | Meaning |
| --- | --- |
| `## Symptom` | The observable failure in one or two sentences, from the perspective of whoever (human, agent, CI) saw it. States what *is* wrong, never the fix. |
| `## Reproduction` | The minimal, deterministic sequence that produces the symptom: ordered **Steps**, the **Expected** behavior, the **Actual** behavior, and the **Conditions** (environment, version, config) that affect reproducibility. Once a reliable reproduction exists, all other attempts are noise. |
| `## Root cause` | The cause stated precisely — file, line, what state combines with what input to produce the symptom. Diagnosis only: name the cause, do **not** prescribe the fix. ("`getPricing()` returns null when the cache is cold and the upstream is rate-limited; the caller treats null as 'fall back to default' instead of failing" is a diagnosis; "make `getPricing()` throw" is a prescription and is forbidden here.) |
| `## Affected obligations` | The existing obligation the defect violates, listed as a reference only — the spec id plus the local obligation id (`<spec-id>#<REQ\|CONSTRAINT\|INVARIANT\|INTERFACE>-NNN`) — and how it is violated. If no obligation covers the broken behavior, say so explicitly: that gap is a finding the promoted fix task must reconcile. **Author no obligation blocks here.** |

## Copyable template

The copyable skeleton is `starter-kit/.agents/templates/bug-report.md`. That file is the empty starting point an author copies to create a new bug-report; **this page is its contract** — the meaning of each field, the diagnosis-only boundary, and the placement rules the skeleton is filled in against. In an adopted project the same skeleton is installed at `.swarm/kernel/templates/bug-report.md`.

## Related

- `docs/passes/author.md` — the pass that preserves the diagnosis-only stance and promotes a bug-report forward; the diagnosis becomes a **fix task** (`task_kind: fix`), never a fix the report dictates and never directly into code.
- `docs/passes/implement.md` — the pass that consumes the promoted fix task and produces the remedy, with the fix carrier profile selected by task kind.
- `docs/artifacts/task.md` — the fix task a bug-report promotes into; the artifact that carries the remedy as a lowered work packet against obligations.
- `docs/artifacts/spec.md` — the obligation source whose existing `REQ`/`CONSTRAINT`/`INVARIANT`/`INTERFACE` the defect violates and which the `## Affected obligations` section references; where any uncovered-behavior gap is reconciled.
- `docs/artifacts/audit.md` — the sibling observation-only source artifact; an audit records present-state risk (promoting into a spec) where a bug-report root-causes a specific reproduced defect (promoting into a fix task).
- `docs/artifacts/finding.md` — the sibling evidence artifact; an uncovered-obligation gap surfaced during diagnosis is a finding the fix task must reconcile.
