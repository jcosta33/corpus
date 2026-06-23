# The `corpus` CLI — design and boundary

*The reference CLI (**corpus-cli**) is optional; the markdown workflow never requires it. This page is
its **design of record** — why the CLI is shaped the way it is, and what it must never become
([ADR-0077](../adrs/0077-corpus-cli-reconcile-only-harness.md)). It is not a status page: the live,
drift-checked command set is corpus-cli's own command catalogue, where *advertised == dispatchable* is
a tested invariant; per-command usage and flags live in the
[corpus-cli README](https://github.com/jcosta33/corpus-cli#commands), and the checks it runs are
[checks.md](checks.md). This page records the shape, not the surface.*

## The shipped surface

corpus-cli ships the prepare-and-reconcile loop with no agent execution of its own — pure file
preparation and checking, useful on day one and testable without any model: **`init`** and
**`update`** (scaffold the kit, then refresh the kit-owned guidance conflict-safely), **`check`** (the
checks contract), **`new`** (spec, task, or change-plan), **`worktree`**, **`status`**, **`review`** (reconcile a
run; `--write` drafts the packet), **`pull`** and **`promote`** (the two boundary-safe prepare verbs),
**`run --agent`** (launch a prepared task and record the launch envelope — the agent performs the
loop), **`show`**, and **`agents emit --codex`** (project the agent definitions to a second runner).
The interactive dashboard (`corpus` with no command) reaches every flow, and the **`corpus-mcp`** server
([ADR-0085](../adrs/0085-corpus-mcp-adapts-the-json-contract.md)) serves the same scope/requirements/
checks data over MCP. The catalogue and the README carry the authoritative flags, exit codes, and
per-command detail — this page does not restate them.

Every check is **toolable**: it becomes **enforced** only in an adopting repo that wires the kit's
commit/CI hooks, where the team's gate (or the agent CLI's hook runtime) enforces — never "Corpus
enforcing." The checks themselves (C001–C017, the review-packet evidence rules) are defined in
[checks.md](checks.md).

corpus-cli is a **reconcile-only harness** (ADR-0077): it prepares, launches, and reconciles agent
runs against declared intent; it never performs the coding loop. Each command earns its place by
that test and by answering the same five questions — what it reads, what it writes, whether it runs
an agent, what state changes, and what to do next — _and_ by being a well-behaved standalone Unix
part. A command that cannot answer all five, or that only makes sense inside the full loop, does
not belong in the set.

## Not in the set

Three dispositions, each a decision rather than a backlog position:

- **Non-goals — never built, by design.** A board-mutating close (a `status.md`-mutating `corpus
close`) — the board stays hand-edited; a CLI that writes it would adjudicate the human-owned verdict
  ([ADR-0077](../adrs/0077-corpus-cli-reconcile-only-harness.md) / ADR-0084). `compile`,
  `lower`/`decompose`, `graph` — Corpus generates no code from a spec and splits no spec into tasks
  (judgment work). Architecture enforcement — a team binds its own linter via a `CONSTRAINT` + the
  `static` verify method. The finding scaffold ships instead as the boundary-safe `corpus promote`.
- **Deferred — specified, built on demonstrated demand, not to fill a roadmap.** `corpus inventory new`
  (the brownfield inventory scaffold — change-plan scaffolding already ships as `corpus new
change-plan`), per-adapter hook generation (the
  toolable→enforced bridge, below), the run-record `commands[]` field + `corpus review` reading it (the
  launch envelope, the delegation-provenance block, and `changed_files` already ship — ADR-0088), the
  strict `format: sol` parser (the plain two-tier form ships; a SOL spec is read as plain today), and
  per-task cost attribution (a `corpus-*` plugin, not core). The evidence to date prioritizes the
  review-gate reconcile over generation volume, so these wait for the demand that justifies them.
- **Measured and dropped.** The oversized-packet size band — measured ~15% false-positive on real
  task diffs, so the band is specified-not-shipped and the diff size surfaces as neutral info in
  `corpus review` instead ([ADR-0097](../adrs/0097-mint-c016-c017-defer-oversized.md)).

## Composable parts: standalone and Corpus-composed

corpus-cli is a **reconcile-only harness**: it _prepares_, _launches_, and _reconciles_ agent runs;
it never _performs_ the coding loop (ADR-0077). Three design rules make it both a standalone tool
for any agentic work and the thing that supercharges the Corpus loop — _parts individually usable,
maximally valuable together_:

- **Every command is a well-behaved Unix part** (toolable): `--json` output, meaningful exit codes
  (`0` clean / `1` warnings / `2` error), stdout-for-data / stderr-for-messages, and a
  `--no-workspace` fallback that degrades like `git` run outside a repo. Extensions are `corpus-*`
  executables discovered on `PATH` (the `git`/`kubectl` convention), so `pull` connectors and
  agent adapters drop in without a rebuild. A reconcile-only **core library** holds the logic so
  editors, CI, and the MCP server reuse it without shelling out.
- **Standalone primitives** are useful without adopting Corpus at all: `corpus worktree` (a
  one-worktree-per-task manager with per-worktree runtime-isolation config — port range, scratch
  DB, copied fixtures — that interops with `claude --worktree`), `corpus run --agent` (M1 launches a
  prepared task in its worktree and records the launch; the headless wrapper that normalizes each
  agent CLI's output is a follow-up), `corpus check` (a
  spec linter that drops into pre-commit/CI on its exit code), and `corpus status` (a derived
  read-model). `cost` and `notify` ship as `corpus-*` plugins, not core.
- **The workspace composes them** into the loop: one command's `--json` output is the next's input
  (`corpus check`'s diagnostics → `corpus new`'s scope → `run`'s launch envelope → `review`'s coverage
  rows → the human's by-hand close). Each still runs alone.

The two capabilities Corpus owns that the field leaves open — both depending on the task packet's
**declared scope** — are **deterministic coverage / executable-criteria checking** (`corpus check`)
and **reconciling the agent's self-report against the actual diff** (`review`).

## Per-command contracts

### `corpus init`

- **Reads:** nothing (an existing workspace, when refreshing templates).
- **Writes:** the complete workspace — the copy-whole [corpus-starter-kit](https://github.com/jcosta33/corpus-starter-kit)
  template: `AGENTS.md` (+ the `CLAUDE.md`/`GEMINI.md` symlinks), `.agents/skills/` (the core
  loop plus the workspace authoring guides), `templates/`, `advanced/`, the seeded flow folders
  (`specs/`, `intake/`, `tasks/`, `reviews/`, `findings/`, `inventory/`, `change-plans/`),
  `decisions/`, `examples/`, and `status.md`. Equivalent to copying the template repo whole.
- **Runs an agent?** No.
- **State change:** an empty directory becomes a workspace.
- **Next:** `corpus pull` a ticket, or `corpus new spec` from the template.

### `corpus pull <ticket>`

- **Reads:** the external tracker (Jira, GitHub, Linear, …) through a configured connector.
- **Writes:** one snapshot file, e.g. `intake/jira/JIRA-123.md` — the verbatim ticket text plus
  `source`, `url`, and `captured` date, per the intake template.
- **Runs an agent?** No. And it **never auto-writes a spec** — normalizing a ticket into
  requirements is judgment work, not transcription.
- **State change:** the upstream ticket has a stable, citable snapshot in the workspace.
- **Next:** `corpus new spec --from` that snapshot.

### `corpus new spec <slug> [--from <intake>]`

Spec and task creation are consolidated under one verb, `corpus new <task|spec>`; this is its spec form.

- **Reads:** `templates/spec.md`; the intake snapshot when `--from` is given.
- **Writes:** `specs/<slug>/spec.md` at `status: draft`, sources pre-filled.
- **Runs an agent?** No — it scaffolds the draft; filling the requirement text is a human's job.
- **State change:** a spec exists and is linked to its source.
- **Next:** fill in requirements and open questions, then `corpus check`.

### `corpus check [file]`

- **Reads:** one spec — simple form or SOL form (`format: sol`).
- **Writes:** nothing (optionally `--json` for a pipeline).
  Prints findings under the two-way split from [checks.md](checks.md): hard errors (a checker
  must reject) and warnings (a checker should flag). Exit codes: `0` clean, `1` warnings, `2` hard
  errors — so it drops into pre-commit/CI as a standalone linter.
- **Runs an agent?** No.
- **State change:** none — purely diagnostic. This is the credibility anchor of the whole
  command set: the checks catalogue is the contract, `corpus check` is its implementation. It
  parses the spec's markdown into an internal structure (no `ir.json` artifact, ADR-0077) and over
  that structure runs the **executable-criteria check** (every requirement names a runnable
  checker, not just prose) and, across the workspace, **deterministic coverage/drift**: a
  requirement id with no covering task, or an AC whose named check no longer exists, is a finding —
  computed mechanically, never by an LLM "interpreting". A workspace-level check also flags a
  leftover `{{placeholder}}` in a _live_ `AGENTS.md` or board (the clause-(a) workspace-validity
  gate in [checks.md](checks.md)).
- **Next:** fix the gaps; `corpus new task` once clean.

### `corpus new task --from <SPEC-id | CHANGE-id> [--scope AC-…]`

The task form of `corpus new <task|spec>`.

- **Reads:** the named spec and/or change plan.
- **Writes:** `tasks/<slug>.md` — a task packet whose Scope section is copied from the named
  requirements. It never invents scope: an empty `--scope` copies nothing silently.
- **Runs an agent?** No.
- **State change:** a bounded packet exists that an agent can be pointed at.
- **Next:** `corpus worktree create`, or hand the packet to your agent directly.

### `corpus worktree <create|list|remove|prune> [slug]`

`worktree` takes `create` / `list` / `remove` / `prune`; the contract below is the `create` form
(`list` shows worktrees, `remove` tears one down, `prune` clears stale ones).

- **Reads:** the task packet and `.corpus/config.yaml` (where the code repo is).
- **Writes:** a git worktree and branch (`corpus/<spec-slug>/<task-slug>`) in the code repo; a record under
  `.corpus/work/tasks/` so later commands find it.
- **Runs an agent?** No.
- **State change:** the task has an isolated place to run — one worktree per task.
- **Next:** `corpus run`, or hand the worktree to your agent directly.

### `corpus run <task> --agent <name>`

- **Reads:** the task packet, the agent adapter from `.corpus/config.yaml`.
- **Writes:** a run record under `.corpus/work/`. The code changes are the **agent's** writes,
  in the task worktree.
- **Runs an agent?** Yes — it launches the external agent CLI in the task's worktree with the
  adapter's startup instruction. It **never becomes the agent**: no model loop, no chat, no
  edits of its own. And it makes **no correctness guarantee** — the agent writes the same code
  it would write anyway; the value is the bounded packet going in and the evidence coming out.
- **State change:** the task is running (or has run) with a recorded start point.
- **Handoff/provenance (toolable):** M1 records the **launch envelope** — task id, adapter/worker
  identity, worktree/branch, the source handed in, the exit — under `.corpus/work/` (ADR-0076), the
  same provenance facts the task packet's Provenance line records by hand. Generating a richer worker
  handoff from the task packet (single-sourcing the delegation payload rather than relying on the
  adapter's startup instruction) is a follow-up; it does not change the markdown-first model.
- **Next:** `corpus review`.

### `corpus review <task> [--agent <name>]`

- **Reads:** the task packet, the worktree diff, the spec and change plan it names.
- **Writes:** `reviews/<slug>.md` — a draft packet from the template: changed files listed,
  one coverage row per in-scope requirement, evidence slots filled where output exists,
  human-attention candidates flagged from the exception triggers. It also **reconciles the agent's
  self-report against the actual diff** — the run summary's claimed changed-files / Verify pastes
  vs the worktree diff — and routes the mismatches (claimed-but-not-changed, changed-but-unclaimed,
  out-of-scope edits) to Human attention. This is distinctive because it needs the packet's
  declared scope as ground truth (ADR-0077).
- **Runs an agent?** Optional, to collect evidence into the draft. **Agent fill stays a draft**:
  the review result (Pass / Fail / Unverified / Blocked) is a human decision, and an empty
  Evidence cell still reads Unverified, never Pass. The CLI routes exceptions; it never adjudicates.
- **State change:** the diff has a review packet a human can inspect by exception.
- **Next:** a human works the Human attention list, then closes by hand — `corpus promote` scaffolds
  any finding; the board edit is the human's (no board-mutating `corpus close`, see _Not in the set_).

### `corpus status`

- **Reads:** every spec, task, review, and finding in the workspace.
- **Writes:** nothing. It prints the derived artifact-level board — per-spec tasks and their
  review status, review-ready tasks with no review packet, and the needs-human list. (Full
  per-requirement coverage is the deferred M3 coverage engine, not this command.) The committed
  `status.md` board stays hand-edited; this command is how a machine answers the same questions
  without anyone maintaining a table.
- **Runs an agent?** No.
- **State change:** none.
- **Next:** whatever the board shows red.

## Example sequence (shipped commands only)

The loop end to end, using only what ships. The Close step is the human's: record any durable
finding (`corpus promote` scaffolds one), then hand-edit the board and remove the worktree — there is
no board-mutating `corpus close` (see _Not in the set_). The brownfield path (inventory → change plan →
per-wave tasks) runs the same way by hand; its discipline is [advanced-lifecycle.md](advanced-lifecycle.md).

```text
# Feature                                       # Bug
corpus pull JIRA-123                             corpus pull GH-456
corpus new spec checkout-discounts \             corpus check specs/payments/spec.md
  --from intake/jira/JIRA-123.md                corpus new task --from SPEC-payments --scope AC-007
corpus check specs/checkout-discounts/…          corpus worktree create TASK-payment-5xx
corpus new task --from SPEC-checkout-discounts   corpus run TASK-payment-5xx --agent opencode
corpus worktree create TASK-checkout-discounts   corpus review TASK-payment-5xx
corpus run TASK-checkout-discounts --agent claude  # human closes: promote a finding, edit the board
corpus review TASK-checkout-discounts
# human closes: promote a finding, edit the board
```

## Local state in a code repo: the gitignored `.corpus/` directory

Today a code repo needs nothing from Corpus — at most a one-line `AGENTS.md` pointer to the
workspace, with task packets handed to the agent by paste or path. That stays true. When the CLI
exists, it may own one **fully gitignored** local-state directory in a code repo:

```text
.corpus/            # machine state, in the .git/ / node_modules/ sense — never committed
  config.yaml      # where the workspace is, which agents are available
  work/            # active task worktree records, draft review packets
    tasks/  reviews/
  cache/           # derived read-models, parsed artifacts
  tmp/
```

Three rules bound it:

- It is **never committed** and never required by the markdown workflow. Deleting `.corpus/`
  loses nothing durable.
- Committed Corpus content in code repos stays out of bounds — specs, reviews, and findings
  belong to the workspace. This is a convention; nothing in this repository enforces it.
- It appears on this page only. No other page in these docs asks a code repo to carry anything.

### `config.yaml` shape

```yaml
knowledge: # where the workspace lives
  type: git
  path: ../corpus-workspace
  default_branch: main
project:
  id: my-app
  code_repo: .
agents:
  default: claude
  available: [claude, codex, opencode]
```

Several code repos may each point `knowledge.path` at the same workspace — one workspace that
governs several code repos (the multi-repo workspace) composes from these per-repo contracts
as written. Orchestration _across_ governed repos from the workspace side is outside the
command contracts on this page; it waits for its own decision record.

## Agent adapters

The CLI coordinates existing coding agents; it ships none. An **adapter** is a three-field
record, not a process:

| Field                 | Meaning                                                     |
| --------------------- | ----------------------------------------------------------- |
| `command`             | the executable that launches the agent CLI                  |
| `working_directory`   | always the **task's own worktree** — one worktree, one task |
| `startup_instruction` | the bootstrap pointer aiming the agent at the task packet   |

```yaml
agents:
  claude:
    command: claude
    working_directory: task_worktree
    startup_instruction: "Read AGENTS.md, then read the task file you were given."
  codex:
    command: codex
    working_directory: task_worktree
    startup_instruction: "Read AGENTS.md, then read the task file you were given."
  opencode:
    command: opencode
    working_directory: task_worktree
    startup_instruction: "Read the task file first; stay inside its scope."
```

Any agent you can launch from a shell fits the record — aider, Cursor's CLI, and whatever ships
next. The adapter carries no provider credentials and no model settings; those belong to the
agent CLI's own configuration.

A fourth conceptual field is **how to read the agent's structured output back**. Mature agent
CLIs have converged on the same headless-event vocabulary — `init` · `assistant` · `tool_call` ·
`result`, plus a final message, cost, and exit code — emitted as JSON / stream-JSON. corpus-cli
adopts that vocabulary as its **canonical adapter event contract** (carrying a contract version
against vendor churn) and maps each tool's native schema onto it, normalizing the result into the
run record. Corpus invents no new event vocabulary; an adapter is thin because the contract already
exists in the wild.

## Beyond the loop: the MCP server and hook generation

Two **toolable** capabilities generalize the adapter model across vendors without N bespoke
integrations — both strictly _prepare_, never _perform_:

- **A Corpus MCP server.** Instead of one adapter per agent, expose the task packet's scope, the
  parsed requirements, and the checks contract over MCP — so any MCP-capable agent (Claude, Codex,
  Gemini, Goose) natively queries "what are this task's requirements, scope, and checks." It is a
  peer to the shell-out adapters (which cover agents without MCP); it **shipped** as `corpus-mcp` (v0.1.0, ADR-0085), shelling out to the CLI `--json` contract. This
  _serves Corpus data over MCP_ (prepare); it is **not** the agent's tool-calling MCP runtime, which
  stays the agent's per the boundary below.
- **Per-adapter hook generation.** Emit the agent CLI's own hook config (e.g. `hooks.json` /
  `settings.json`) wiring a task's declared write-set and `checks.yaml` into its PostToolUse/Stop
  hooks. This is the bridge from a `toolable`/`checklist` rule to **enforcement performed by the
  agent CLI's hook runtime** — corpus-cli _generates_ the config; it does not run the loop, and the
  enforcement is the agent's, recorded as such (never claimed as Corpus enforcing). Opt-in per
  adapter capability; agents without hooks simply don't get it.

## The run record

One machine record is reserved: the **run record** — the machine form of an agent run summary the
review packet's evidence cells are filled from:
`{ task_id, changed_files[], commands[]: {cmd, exit, output_ref}, out_of_scope[], findings[],
provenance? }`. The `provenance?` block follows the **delegation-provenance contract** (ADR-0088) —
the worker, why it was delegated to, its inputs, the context filtered, its tools, whether it could
edit, and the evidence it returned — a record, never a verdict. It is the reconciliation substrate
`corpus run` writes and `corpus review` reads (ADR-0072, ADR-0076, ADR-0088). `corpus run` writes, today, that envelope (task id, adapter, worktree/branch, source, exit)
**plus** the delegation-provenance block and the `changed_files` snapshot (ADR-0088 producer 1); only
`commands[]` and `corpus review` reading the record stay deferred. The fixtures ship none.

There is **no Corpus `ir.json` / `plan.json` artifact** (ADR-0077). To check a spec, corpus-cli
parses its markdown into an internal structure; it may project that structure as optional `--json`
for interop (a CI step or another tool consuming the analysis). That projection is a tool output,
not a Corpus file — adopters never create or see one, and **markdown stays the only Corpus
artifact**. The deterministic coverage/drift checks (below) run on the parsed markdown, not on a
required file.

## What the CLI must never own

The boundary: the CLI **prepares and reconciles**; the agent **performs the coding loop**.

| The CLI owns                          | The agent CLI owns — never Corpus |
| ------------------------------------- | --------------------------------- |
| scaffolding, intake snapshots         | the LLM chat / conversation UI    |
| spec drafting and checking            | the model reasoning loop          |
| task packets, worktrees, branch names | file-editing mechanics            |
| launching adapters                    | provider auth and credentials     |
| review-packet drafting, status, close | the tool-calling / MCP runtime    |
| findings prompt, ledger entries       | prompt-streaming UX               |

A `corpus` CLI that absorbed anything from the right column would have become a coding agent —
and Corpus coordinates agents; it does not compete with them. The same restraint repeats in
`run`'s contract: launching is the whole job.

## Source-surface policies

When the CLI maps a code repo (for inventories, drift checks, and review drafting), every source
surface carries one of these policies. The policy decides what an edit to that surface means:

| Policy       | Meaning                                                         | Edit policy                                                                  |
| ------------ | --------------------------------------------------------------- | ---------------------------------------------------------------------------- |
| `generated`  | emitted from a named source artifact (an OpenAPI doc, a schema) | never hand-edit — change the source and regenerate; a hand-edit is a finding |
| `governed`   | implementation under a spec requirement                         | edit with a requirement id; the change appears in review coverage            |
| `observed`   | existing code no spec claims yet                                | editable; needs an inventory/audit and a spec before it counts as governed   |
| `external`   | vendor / third-party code you do not own                        | do not modify — fix upstream or wrap                                         |
| `deprecated` | scheduled for removal or migration                              | migration/removal edits only, until cutover                                  |

`observed` is the honest brownfield default: real code with no requirement behind it, never
silently treated as governed. The set also rejects the fantasy that code is regenerated from
specs — only a surface explicitly marked `generated` is emitted, and only from a named artifact.

## Related

- [checks.md](checks.md) — the catalogue `corpus check` implements, with the hard-error/warning split.
- [structured-requirements.md](structured-requirements.md) — the requirement record corpus-cli parses a spec into (tool-internal; optional `--json`).
- [advanced-lifecycle.md](advanced-lifecycle.md) — the full lifecycle behind the deferred `lower`/`decompose` verbs.
- [memory.md](memory.md) — findings, promotion (`corpus promote`), and the Close-step discipline.
- [artifact-formats.md](artifact-formats.md) — the markdown artifacts every command reads and writes.
