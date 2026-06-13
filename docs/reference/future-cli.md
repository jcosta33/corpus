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
`change new`, `worktree create`, `run`, `close`.

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
- **Writes:** nothing (optionally a report file with `--report`). Prints findings under the
  two-way split from [checks.md](checks.md): hard errors (a checker must reject) and warnings
  (a checker should flag). Exit code is nonzero on hard errors.
- **Runs an agent?** No.
- **State change:** none — purely diagnostic. This is the credibility anchor of the whole
  command set: the checks catalogue is the contract, `swarm spec check` is its implementation.
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
- **Next:** `swarm review`.

### `swarm review <task> [--agent <name>]`

- **Reads:** the task packet, the worktree diff, the spec and change plan it names.
- **Writes:** `reviews/<slug>.md` — a draft packet from the template: changed files listed,
  one coverage row per in-scope requirement, evidence slots filled where output exists,
  human-attention candidates flagged from the exception triggers.
- **Runs an agent?** Optional, to collect evidence into the draft. **Agent fill stays a draft**:
  the review result (Pass / Fail / Unverified / Blocked) is a human decision, and an empty
  Evidence cell still reads Unverified, never Pass.
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

## Reserved machine records

Two artifact names are reserved for machine emission and exist only as contracts here:
`<spec>.ir.json` (the typed requirement records + edges of one spec) and `<spec>.plan.json`
(the schedulable work-packet projection). A third reserved sketch is the **run record** — the
machine form of an agent run summary the packet's evidence cells are filled from:
`{ task_id, changed_files[], commands[]: {cmd, exit, output_ref}, out_of_scope[], findings[] }`.
None of these is produced by anything today; the fixtures deliberately ship none.

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

## Reserved machine artifacts

Two filenames are reserved for the CLI's machine-readable outputs. No tool emits them today;
they are documented data shapes so that any future producer and consumer interoperate.

| File | What it is |
|---|---|
| `<spec>.ir.json` | the **structured form** of one spec — its requirements as typed records |
| `<spec>.plan.json` | the **plan** — those records grouped into schedulable work packets |

Both are defined once over the requirement record of
[structured-requirements.md](structured-requirements.md) — the simple form and the SOL form of a
spec produce the **same** structured form, because they encode the same records.

### The structured form (`*.ir.json`)

A single JSON object with the top-level keys `meta`, `nodes`, `edges`, `diagnostics`,
`provenance` — all present even when empty; a validating consumer rejects unknown top-level keys.

- **`meta`** mirrors the spec frontmatter: `{ id, title, status, owner, sources[], format? }`.
  There is no version field; the provenance hash pins the revision.
- **`nodes[]`** — one record per requirement:

  | Field | Meaning |
  |---|---|
  | `id` | the stable id (`AC-001`); addressed across specs as `SPEC-x#AC-001` |
  | `kind` | `requirement` in the simple form; SOL refines it (`constraint`, `invariant`, `interface`, `question`) |
  | `strength` | the one binding word: `must`, `must-not`, `should`, `should-not`, `may` |
  | `statement` | the requirement sentence itself |
  | `verify_refs[]` | the verification bindings (below) |
  | `reads[]` / `writes[]` | declared surfaces — the input to parallel-safety |
  | `result` | `pass` \| `fail` \| `unverified` \| `blocked`; defaults to `unverified` |
  | `lifecycle[]` | decorators kept separate from `result`: any of `waived`, `stale`, `contradicted` |
  | `source` | `{ file, line_start, line_end, content_hash }` — the hash drives staleness; it is tool-stamped, and a hand-written hash is untrusted until recomputed |

- **`verify_refs[]`** — each entry `{ method, adapter, ref, selector?, gate }`. `method` is one
  of the verification methods (`test`, `static`, `contract`, `property`, `model`, `perf`,
  `security`, `manual`, `monitor`); `gate` is `required` or `advisory`. A simple-form
  `Verify with:` line populates `ref` alone; a SOL `VERIFY BY <type>:<adapter>:<artifact>`
  binding fills every field. Same record, two precisions.
- **`edges[]`** — `{ from, to, type, hard }`, `type` one of `depends_on`, `blocks`,
  `conflicts_with`, `verified_by`, `affects`, `implements`, `preserves`. **Edges are the single
  source of relationship truth**: a relationship between two nodes appears exactly once, as an
  edge, never duplicated as a node field — a relationship stored twice can disagree; one
  representation cannot.
- **`diagnostics[]`** — `{ code, level, node | span, message, suggest? }`. `code` is a check id
  from [checks.md](checks.md); `level` is `error` / `warning` / `note`, matching the
  hard-error/warning split. Diagnostics never leak into a node's `result`.
- **`provenance`** — `{ hash, tool_version, emitted_at }`. `tool_version` is `null` today
  for the most honest reason available: there is no emitter to stamp it.

### The plan (`*.plan.json`)

A single JSON object with the top-level keys `meta`, `packets`, `edges`, `provenance`.

- **`meta`** — `{ id, derived_from, max_parallel? }`; `derived_from` names the source
  `*.ir.json`; `max_parallel` is an advisory hint, `null` when unspecified.
- **`packets[]`** — one schedulable unit each:

  | Field | Meaning |
  |---|---|
  | `id` | packet id, unique in the plan (`WP-001`) |
  | `step` | the lifecycle step it runs — `author`, `lint`, `improve`, `lower`, `decompose`, `implement`, `verify`, `review`, `promote` (see [advanced-lifecycle.md](advanced-lifecycle.md)) |
  | `inputs[]` / `outputs[]` | the requirement ids consumed; the artifacts produced |
  | `reads[]` / `writes[]` | the surfaces touched; every write surface is a subset of its inputs' declared writes |
  | `depends_on[]` | packet ids that must finish first (each also present as an edge) |
  | `lane` / `batch` | launcher hints only; absence changes no safety result |
  | `merge_safe` | the safety verdict, below |

- **The safe-parallelism predicate.** Two packets may run in parallel **iff** they are
  dependency-independent (neither reachable from the other along `depends_on` edges) **and**
  write-disjoint (no shared write surface, no read/write conflict on one surface). Anything
  unscoped or sharing a surface serializes by default. `merge_safe` is the static verdict;
  a launcher may serialize further but never parallelizes what the plan marks unsafe.
- **No `locks` field exists** — a lock group is just a named coarse write surface, so lock
  analysis *is* write-set analysis.
- **`edges[]` / `provenance`** — same shapes as the structured form; the relevant packet edge
  types are `depends_on` and `conflicts_with`.

## Related

- [checks.md](checks.md) — the catalogue `swarm spec check` implements, with the hard-error/warning split.
- [structured-requirements.md](structured-requirements.md) — the requirement record both reserved artifacts are defined over.
- [advanced-lifecycle.md](advanced-lifecycle.md) — the full lifecycle behind the deferred `lower`/`decompose` verbs.
- [memory.md](memory.md) — findings, promotion, and the ledger entry `swarm close` may append.
- [artifact-formats.md](artifact-formats.md) — the markdown artifacts every command reads and writes.
