# The future `swarm` CLI

*Future automation — a contract for tooling that does not exist yet; nothing on this page runs today.*

> **None of this exists yet.** There is no `swarm` binary in this repository, and the markdown
> workflow never requires one. The reference implementation in progress is **swarm-cli**. This page
> is the contract that implementation builds against — and the level tag for every rule on it is
> the same: **toolable**, the tool being swarm-cli. Until that ships, everything below is
> documentation of work you and your agent do by hand with the templates.

A CLI earns its place by making each step of the loop — Pull → Spec → Task → Run → Review → Close —
cheaper without taking it over. Every command below answers the same five questions: what does it
read, what does it write, does it run an agent, what state changes, and what should you do next.
A command that cannot answer all five does not belong in the set.

## The command set

| Command | One line | Milestone |
|---|---|---|
| `swarm init` | scaffold a workspace from the starter kit | M1 |
| `swarm pull <ticket>` | snapshot an external ticket into `intake/` | M1 |
| `swarm spec new <slug>` | start a spec from the template | M1 |
| `swarm spec check <file>` | check a spec against the checks catalogue | M1 |
| `swarm inventory new <slug>` | start an inventory for brownfield work | M2 |
| `swarm change new <slug>` | start a change plan | M2 |
| `swarm task new --from <id>` | cut a task packet from a spec or change plan | M1 |
| `swarm worktree create <task>` | create the task's worktree and branch | M2 |
| `swarm run <task> --agent <name>` | launch an external coding agent on the task | M2 |
| `swarm review <task>` | draft the review packet from the diff and the task | M1 |
| `swarm status` | print the derived workboard | M1 |
| `swarm close <task>` | findings prompt, board update, cleanup | M2 |

**Milestone 1** needs no agent execution at all: `init`, `pull`, `spec new`, `spec check`,
`task new`, `review`, `status`. It is pure file preparation and checking — useful on day one,
testable without any model. **Milestone 2** adds the execution conveniences: `inventory new`,
`change new`, `worktree create`, `run`, `close`. **Milestone 3** adds the supercharge layer (the
MCP server, hook generation, deterministic coverage/drift, per-task cost attribution).

## Composable parts: standalone and Swarm-composed

swarm-cli is a **reconcile-only harness**: it *prepares*, *launches*, and *reconciles* agent runs;
it never *performs* the coding loop (ADR-0077). Three design rules make it both a standalone tool
for any agentic work and the thing that supercharges the Swarm loop — *parts individually usable,
maximally valuable together*:

- **Every command is a well-behaved Unix part** (toolable): `--json` output, meaningful exit codes
  (`0` clean / `1` warnings / `2` error), stdout-for-data / stderr-for-messages, and a
  `--no-workspace` fallback that degrades like `git` run outside a repo. Extensions are `swarm-*`
  executables discovered on `PATH` (the `git`/`kubectl` convention), so `pull` connectors and
  agent adapters drop in without a rebuild. A reconcile-only **core library** holds the logic so
  editors, CI, and the MCP server reuse it without shelling out.
- **Standalone primitives** are useful without adopting Swarm at all: `swarm worktree` (a
  one-worktree-per-task manager with per-worktree runtime-isolation config — port range, scratch
  DB, copied fixtures — that interops with `claude --worktree`), `swarm run --agent` (a uniform
  headless wrapper that normalizes each agent CLI's flags and output), `swarm spec check` (a
  spec linter that drops into pre-commit/CI on its exit code), and `swarm status` (a derived
  read-model). `cost` and `notify` ship as `swarm-*` plugins, not core.
- **The workspace composes them** into the loop: one command's `--json` output is the next's input
  (`spec check`'s diagnostics → `task new`'s scope → `run`'s launch envelope → `review`'s coverage
  rows → `close`'s gate). Each still runs alone.

The two capabilities Swarm owns that the field leaves open — both depending on the task packet's
**declared scope** — are **deterministic coverage / executable-criteria checking** (`spec check`)
and **reconciling the agent's self-report against the actual diff** (`review`).

## Per-command contracts

### `swarm init`

- **Reads:** nothing (an existing workspace, when refreshing templates).
- **Writes:** the complete workspace — the copy-whole [swarm-starter-kit](https://github.com/jcosta33/swarm-starter-kit)
  template: `AGENTS.md` (+ the `CLAUDE.md`/`GEMINI.md` symlinks), `.agents/skills/` (the core
  loop plus the workspace authoring guides), `templates/`, `advanced/`, the seeded flow folders
  (`specs/`, `intake/`, `tasks/`, `reviews/`, `findings/`, `inventory/`, `change-plans/`),
  `decisions/`, `examples/`, and `status.md`. Equivalent to copying the template repo whole.
- **Runs an agent?** No.
- **State change:** an empty directory becomes a workspace.
- **Next:** `swarm pull` a ticket, or write a spec from the template.

### `swarm pull <ticket>`

- **Reads:** the external tracker (Jira, GitHub, Linear, …) through a configured connector.
- **Writes:** one snapshot file, e.g. `intake/jira/JIRA-123.md` — the verbatim ticket text plus
  `source`, `url`, and `captured` date, per the intake template.
- **Runs an agent?** No. And it **never auto-writes a spec** — normalizing a ticket into
  requirements is judgment work, not transcription.
- **State change:** the upstream ticket has a stable, citable snapshot in the workspace.
- **Next:** `swarm spec new --from` that snapshot.

### `swarm spec new <slug> [--from <intake>] [--agent <name>]`

- **Reads:** `templates/spec.md`; the intake snapshot when `--from` is given.
- **Writes:** `specs/<slug>/spec.md` at `status: draft`, sources pre-filled.
- **Runs an agent?** Only with `--agent`: an external agent CLI drafts the requirement text.
  The output is still a draft — a human owns the spec before it is `ready`.
- **State change:** a spec exists and is linked to its source.
- **Next:** fill in requirements and open questions, then `swarm spec check`.

### `swarm spec check <file>`

- **Reads:** one spec — simple form or SOL form (`format: sol`).
- **Writes:** nothing (optionally a report file with `--report`, or `--json` for a pipeline).
  Prints findings under the two-way split from [checks.md](checks.md): hard errors (a checker
  must reject) and warnings (a checker should flag). Exit codes: `0` clean, `1` warnings, `2` hard
  errors — so it drops into pre-commit/CI as a standalone linter.
- **Runs an agent?** No.
- **State change:** none — purely diagnostic. This is the credibility anchor of the whole
  command set: the checks catalogue is the contract, `swarm spec check` is its implementation. It
  parses the spec's markdown into an internal structure (no `ir.json` artifact, ADR-0077) and over
  that structure runs the **executable-criteria check** (every requirement names a runnable
  checker, not just prose) and, across the workspace, **deterministic coverage/drift**: a
  requirement id with no covering task, or an AC whose named check no longer exists, is a finding —
  computed mechanically, never by an LLM "interpreting". A workspace-level check also flags a
  leftover `{{placeholder}}` in a *live* `AGENTS.md` or board (the clause-(a) workspace-validity
  gate in [checks.md](checks.md)).
- **Next:** fix the gaps; `swarm task new` once clean.

### `swarm inventory new <slug> [--agent <name>]`

- **Reads:** `templates/inventory.md`; with `--agent`, the code area being mapped.
- **Writes:** `inventory/<slug>.md`. An agent may draft the module/interface/behavior tables;
  the draft is reviewed before a change plan trusts it.
- **Runs an agent?** Optional, draft-only.
- **State change:** the terrain for a structural change is mapped.
- **Next:** `swarm change new`.

### `swarm change new <slug>`

- **Reads:** `templates/change-plan.md`; the inventory, audit, or spec it cites.
- **Writes:** `change-plans/<slug>.md` with sources and preservation rows pre-linked.
- **Runs an agent?** No.
- **State change:** a planned transformation exists with preservation guarantees to review against.
- **Next:** `swarm task new --from CHANGE-<slug>` per wave.

### `swarm task new --from <SPEC-id | CHANGE-id> [--scope AC-…]`

- **Reads:** the named spec and/or change plan.
- **Writes:** `tasks/<slug>.md` — a task packet whose Scope section is copied from the named
  requirements. It never invents scope: an empty `--scope` copies nothing silently.
- **Runs an agent?** No.
- **State change:** a bounded packet exists that an agent can be pointed at.
- **Next:** `swarm worktree create`, or hand the packet to your agent directly.

### `swarm worktree create <task>`

- **Reads:** the task packet and `.swarm/config.yaml` (where the code repo is).
- **Writes:** a git worktree and branch (`swarm/<spec-slug>/<task-slug>`) in the code repo; a record under
  `.swarm/work/tasks/` so later commands find it.
- **Runs an agent?** No.
- **State change:** the task has an isolated place to run — one worktree per task.
- **Next:** `swarm run`.

### `swarm run <task> --agent <name>`

- **Reads:** the task packet, the agent adapter from `.swarm/config.yaml`.
- **Writes:** a run record under `.swarm/work/`. The code changes are the **agent's** writes,
  in the task worktree.
- **Runs an agent?** Yes — it launches the external agent CLI in the task's worktree with the
  adapter's startup instruction. It **never becomes the agent**: no model loop, no chat, no
  edits of its own. And it makes **no correctness guarantee** — the agent writes the same code
  it would write anyway; the value is the bounded packet going in and the evidence coming out.
- **State change:** the task is running (or has run) with a recorded start point.
- **Handoff/provenance (toolable):** because `swarm run` owns the launch, it can generate the
  worker handoff from the task packet and record the **launch envelope** — sources handed in,
  guide(s), worker identity, worktree/branch — the same provenance facts the task packet's
  Provenance line records by hand today (ADR-0076). This single-sources the delegation payload
  rather than relying on an ad-hoc prompt; it waits on the CLI and does not change the
  markdown-first model.
- **Next:** `swarm review`.

### `swarm review <task> [--agent <name>]`

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
- **Next:** a human works the Human attention list; then `swarm close`.

### `swarm status`

- **Reads:** every spec, task, review, and finding in the workspace.
- **Writes:** nothing. It prints the derived read-model — per-spec coverage, tasks without
  review packets, open questions. The committed `status.md` board stays hand-edited; this
  command is how a machine answers the same questions without anyone maintaining a table.
- **Runs an agent?** No.
- **State change:** none.
- **Next:** whatever the board shows red.

### `swarm close <task>`

- **Reads:** the task and its review packet.
- **Writes:** prompts for findings (the Close rule: record anything durable before closing —
  see [memory.md](memory.md) for what "resolved" means); updates the board; removes the
  worktree and the `.swarm/work/` record; optionally appends a ledger entry (below).
- **Runs an agent?** No.
- **State change:** the task is closed, its lessons saved, its scratch gone.
- **Next:** done — or the follow-up task the review demanded.

## Deferred verbs

These are deliberately not in the set. Each has a reason, not just a backlog position.

| Verb | Why deferred |
|---|---|
| `compile` | Swarm is not a compiler; nothing is generated from a spec. |
| `lower` / `decompose` | splitting a spec into tasks is judgment work; the discipline lives in [advanced-lifecycle.md](advanced-lifecycle.md), not a command |
| `graph` | dependency/coverage visualization — a luxury after the basics work |
| `checks` | a fixture-running checker beyond `spec check`; the fixtures already serve as swarm-cli's test data |
| `promote` | finding routing stays a prompt inside `close`, not its own engine |
| `trace validate` | checking an agent's run summary against the actual diff folds into `review` drafting first |

## Example sequences

```text
# Feature                                     # Bug
swarm pull JIRA-123                           swarm pull GH-456
swarm spec new checkout-discounts \           swarm spec check specs/payments/spec.md
  --from intake/jira/JIRA-123.md              swarm task new --from SPEC-payments --scope AC-007
swarm spec check specs/checkout-discounts/…   swarm worktree create TASK-payment-5xx
swarm task new --from SPEC-checkout-discounts swarm run TASK-payment-5xx --agent opencode
swarm worktree create TASK-checkout-discounts swarm review TASK-payment-5xx
swarm run TASK-checkout-discounts \           swarm close TASK-payment-5xx
  --agent claude
swarm review TASK-checkout-discounts
swarm close TASK-checkout-discounts
```

```text
# Refactor (structural, behavior-preserving)  # Brownfield rewrite
swarm inventory new billing-module            swarm inventory new legacy-auth
swarm change new billing-split                # audit written by hand or agent
swarm task new --from CHANGE-billing-split    swarm spec new auth-v2
swarm worktree create TASK-billing-wave-1     swarm change new auth-cutover
swarm run TASK-billing-wave-1 --agent codex   swarm task new --from CHANGE-auth-cutover   # per wave
swarm review TASK-billing-wave-1              # …then worktree / run / review / close per task
swarm close TASK-billing-wave-1
```

## Local state in a code repo: the gitignored `.swarm/` directory

Today a code repo needs nothing from Swarm — at most a one-line `AGENTS.md` pointer to the
workspace, with task packets handed to the agent by paste or path. That stays true. When the CLI
exists, it may own one **fully gitignored** local-state directory in a code repo:

```text
.swarm/            # machine state, in the .git/ / node_modules/ sense — never committed
  config.yaml      # where the workspace is, which agents are available
  work/            # active task worktree records, draft review packets
    tasks/  reviews/
  cache/           # derived read-models, parsed artifacts
  tmp/
```

Three rules bound it:

- It is **never committed** and never required by the markdown workflow. Deleting `.swarm/`
  loses nothing durable.
- Committed Swarm content in code repos stays out of bounds — specs, reviews, and findings
  belong to the workspace. This is a convention; nothing in this repository enforces it.
- It appears on this page only. No other page in these docs asks a code repo to carry anything.

### `config.yaml` shape

```yaml
knowledge:                       # where the workspace lives
  type: git
  path: ../swarm-workspace
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
as written. Orchestration *across* governed repos from the workspace side is outside the
command contracts on this page; it waits for its own decision record.

## Agent adapters

The CLI coordinates existing coding agents; it ships none. An **adapter** is a three-field
record, not a process:

| Field | Meaning |
|---|---|
| `command` | the executable that launches the agent CLI |
| `working_directory` | always the **task's own worktree** — one worktree, one task |
| `startup_instruction` | the bootstrap pointer aiming the agent at the task packet |

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
`result`, plus a final message, cost, and exit code — emitted as JSON / stream-JSON. swarm-cli
adopts that vocabulary as its **canonical adapter event contract** (carrying a contract version
against vendor churn) and maps each tool's native schema onto it, normalizing the result into the
run record. Swarm invents no new event vocabulary; an adapter is thin because the contract already
exists in the wild.

## Beyond the loop: the MCP server and hook generation

Two **toolable** capabilities generalize the adapter model across vendors without N bespoke
integrations — both strictly *prepare*, never *perform*:

- **A Swarm MCP server.** Instead of one adapter per agent, expose the task packet's scope, the
  parsed requirements, and the checks contract over MCP — so any MCP-capable agent (Claude, Codex,
  Gemini, Goose) natively queries "what are this task's requirements, scope, and checks." It is a
  peer to the shell-out adapters (which cover agents without MCP), shipped after them (M3).
- **Per-adapter hook generation.** Emit the agent CLI's own hook config (e.g. `hooks.json` /
  `settings.json`) wiring a task's declared write-set and `checks.yaml` into its PostToolUse/Stop
  hooks. This is the bridge from a `toolable`/`checklist` rule to **enforcement performed by the
  agent CLI's hook runtime** — swarm-cli *generates* the config; it does not run the loop, and the
  enforcement is the agent's, recorded as such (never claimed as Swarm enforcing). Opt-in per
  adapter capability; agents without hooks simply don't get it.

## The run record

One machine record is reserved: the **run record** — the machine form of an agent run summary the
review packet's evidence cells are filled from:
`{ task_id, changed_files[], commands[]: {cmd, exit, output_ref}, out_of_scope[], findings[],
provenance? }`. It is the reconciliation substrate `swarm run` writes and `swarm review` reads
(ADR-0072, ADR-0076). Nothing produces it today; the fixtures ship none.

There is **no Swarm `ir.json` / `plan.json` artifact** (ADR-0077). To check a spec, swarm-cli
parses its markdown into an internal structure; it may project that structure as optional `--json`
for interop (a CI step or another tool consuming the analysis). That projection is a tool output,
not a Swarm file — adopters never create or see one, and **markdown stays the only Swarm
artifact**. The deterministic coverage/drift checks (below) run on the parsed markdown, not on a
required file.

## What the CLI must never own

The boundary: the CLI **prepares and reconciles**; the agent **performs the coding loop**.

| The CLI owns | The agent CLI owns — never Swarm |
|---|---|
| scaffolding, intake snapshots | the LLM chat / conversation UI |
| spec drafting and checking | the model reasoning loop |
| task packets, worktrees, branch names | file-editing mechanics |
| launching adapters | provider auth and credentials |
| review-packet drafting, status, close | the tool-calling / MCP runtime |
| findings prompt, ledger entries | prompt-streaming UX |

A `swarm` CLI that absorbed anything from the right column would have become a coding agent —
and Swarm coordinates agents; it does not compete with them. The same restraint repeats in
`run`'s contract: launching is the whole job.

## Source-surface policies

When the CLI maps a code repo (for inventories, drift checks, and review drafting), every source
surface carries one of these policies. The policy decides what an edit to that surface means:

| Policy | Meaning | Edit policy |
|---|---|---|
| `generated` | emitted from a named source artifact (an OpenAPI doc, a schema) | never hand-edit — change the source and regenerate; a hand-edit is a finding |
| `governed` | implementation under a spec requirement | edit with a requirement id; the change appears in review coverage |
| `observed` | existing code no spec claims yet | editable; needs an inventory/audit and a spec before it counts as governed |
| `external` | vendor / third-party code you do not own | do not modify — fix upstream or wrap |
| `deprecated` | scheduled for removal or migration | migration/removal edits only, until cutover |

`observed` is the honest brownfield default: real code with no requirement behind it, never
silently treated as governed. The set also rejects the fantasy that code is regenerated from
specs — only a surface explicitly marked `generated` is emitted, and only from a named artifact.

## Related

- [checks.md](checks.md) — the catalogue `swarm spec check` implements, with the hard-error/warning split.
- [structured-requirements.md](structured-requirements.md) — the requirement record swarm-cli parses a spec into (tool-internal; optional `--json`).
- [advanced-lifecycle.md](advanced-lifecycle.md) — the full lifecycle behind the deferred `lower`/`decompose` verbs.
- [memory.md](memory.md) — findings, promotion, and the ledger entry `swarm close` may append.
- [artifact-formats.md](artifact-formats.md) — the markdown artifacts every command reads and writes.
