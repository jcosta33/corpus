---
type: adr
id: adr-0077
status: accepted
created: 2026-06-13
updated: 2026-06-13
---

# ADR-0077 — corpus-cli is a reconcile-only harness of composable parts

## Context

RFC-corpus-cli-vision (`corpus-hq/specs/corpus-cli-vision/rfc.md`, accepted by the owner 2026-06-13)
proposed a direction for corpus-cli, grounded in a six-lens deep-research survey (~120 sources,
`research.md`). Three pressures forced the decision: corpus-cli's on-paper design (in-repo specs
001, 005–009) is **SOL-era** and predates the practical-first repositioning; the agentic-CLI
market has **converged** on a substrate (headless invocation, structured JSON events, hooks, MCP,
worktree-per-task) and left two gaps open that map onto Corpus's strengths; and the owner's brief
requires the CLI to both **supercharge Corpus** and be **useful standalone for any agentic work**,
honoring the "parts individually usable, maximally valuable together" thesis. The owner also
resolved the `ir.json` question (Option A, below).

This design is derived **fresh** — from the field research and Corpus's own principles, not from
prior takes. The pre-existing `docs/reference/future-cli.md` sketch and the SOL-era specs
(001, 005–009) are **suggestive priors to mine, not a contract to inherit**: their command
inventory, milestones, and SOL-parsing center are not assumed here. Where they still fit the fresh
design they are kept; where they drag (a verb-per-loop-step organizing principle, SOL as the
parsing center), they are dropped.

## Decision

corpus-cli is **a reconcile-only harness for agentic work**: composable parts that _prepare_,
_launch_, and _reconcile_ agent runs — each useful standalone, all composed by the Corpus workspace
into the loop. It never _performs_ the coding loop. Each rule carries an honesty level (ADR-0063).

1. **Organizing principle: capability engines, not a verb per loop-step.** The design's spine is
   four reconcile-only **capability engines** — **check** (parse a spec, verify executable
   criteria, compute coverage/drift), **launch** (worktree + adapter + run record + provenance),
   **reconcile** (diff vs self-report → review draft, status, gated close), and **prepare**
   (scaffold/intake/packet drafting, the lightest — a command only when it does more than copy a
   template). The command _names_ are a surface derived from these engines and the standalone-part
   test, **re-derived per phase — never inherited** from the prior future-cli verb list. These
   engines arrange as **three layers**: (a) a reconcile-only **core library** the CLI thinly wraps
   (importable by editors/CI/the MCP server without shelling out); (b) **standalone primitives**
   usable without adopting Corpus; (c) a **Corpus-aware composition layer** that supercharges the
   loop. _Level: convention (architecture)._
2. **The Unix contract — every command is a well-behaved part.** `--json` output, meaningful exit
   codes (0 clean / 1 warnings / 2 error), stdout-for-data / stderr-for-messages, a
   `--no-workspace` fallback that degrades like `git` outside a repo, and a `corpus-*` PATH-plugin
   convention for extensions. This is what lets a command be adopted one at a time. _Level:
   toolable._
3. **Standalone primitives (Layer 1):** `corpus worktree` (one-worktree-per-task + per-worktree
   runtime-isolation config; interops with `claude --worktree`), `corpus run --agent` (a uniform
   headless wrapper normalizing each agent's flags + output), `corpus spec check` (a standalone
   spec linter), `corpus status` (a derived read-model). `cost` and `notify` ship as `corpus-*`
   PATH-plugins, not core (resolves RFC Q-004 — keep the core reconcile-only). _Level: toolable._
4. **The canonical adapter event contract.** Adopt the converged vocabulary
   (`init` / `assistant` / `tool_call` / `result`, + final message, cost, exit code) and map each
   agent CLI's native JSON/stream-JSON onto it; **carry a contract version** against vendor churn
   (resolves RFC Q-001). Corpus invents no new event vocabulary. _Level: toolable._
5. **Supercharge (Layer 2):** a **Corpus MCP server** (serves the task packet scope, the parsed
   requirements, and the checks contract — one surface for every MCP-capable agent); **per-adapter
   hook generation** (wires a task's write-set + `checks.yaml` into the agent CLI's hooks);
   **launch-envelope provenance** on `corpus run`; **diff-vs-self-report reconciliation** in
   `corpus review`; **deterministic coverage/drift**; **gated close**; **per-task cost
   attribution**. Sequencing: **shell-out adapters first (M2), the MCP server at M3** (resolves
   RFC Q-005 — ship both, shell-out covers agents without MCP). Provenance emits the ADR-0076
   Provenance line now; **track Agent Trace** as the interop JSONL format, adopt only once it
   settles (resolves RFC Q-003). _Level: toolable; hook-based enforcement is performed by the
   agent CLI's hook runtime, recorded as such — never enforcement by corpus-cli._
6. **The IR is tool-internal — there is no Corpus `ir.json` artifact (resolves RFC Q-002, owner's
   Option A).** corpus-cli must parse a spec's markdown into an internal structure to check it; it
   may project that structure as optional `--json` for interop. That is the whole of it: **markdown
   stays the only Corpus artifact**, adopters never create or see an `ir.json`/`plan.json`, and
   canon documents **no frozen machine-artifact schema**. The deterministic-coverage/drift wedge
   runs on the parsed markdown, not on a required file. _Level: toolable (the `--json` projection);
   the parse structure is an implementation detail._
7. **The two defensible wedges.** Own what the field leaves open and what depends on Corpus's
   declared scope: **deterministic coverage / executable-criteria checking** (the field ships
   LLM-interpreted prose "without guarantees"; Corpus checks mechanically) and **reconciling the
   agent's self-report against the actual diff** (no mainstream tool does it). _Level:
   positioning._
8. **The boundary — what corpus-cli must never own.** The model/reasoning loop, the chat UI,
   file-editing mechanics, provider auth, the MCP _runtime_, the **sandbox/container runtime**
   (adopt `@anthropic-ai/sandbox-runtime` / container-use / `claude --worktree` as substrates the
   adapter selects), and **the review verdict** (agent fill is a draft; empty Evidence reads
   Unverified; the human owns Pass/Fail/Unverified/Blocked). Absorbing any of these would make
   corpus-cli a coding agent. _Level: convention (the hard line)._
9. **Two co-equal surfaces — scriptable and interactive.** Every flow ships both a **direct**
   command (the Unix contract of Decision 2 — `--json`, exit codes, scriptable) and a **beautiful
   interactive TUI** flow (prompts, live progress, coloured per-finding feedback); `corpus` with no
   command opens a dashboard that reaches every flow. The TUI is a frontend over the same core
   library (Decision 1a) — it invokes only the reconcile-only engines and is emphatically **not**
   the chat UI / model loop of the Decision 8 boundary. Interactivity is **gated on a TTY and the
   absence of `--json`**, so a prompt can never break the Unix contract for pipes, scripts, or CI.
   A standing principle: every flow in every milestone ships both forms. _Level: convention
   (architecture); the flows are toolable._

## Alternatives considered

The RFC weighs six in full; the load-bearing rejections: the **SOL-era "canonical 14 / fixed
pipeline / merge-gate-over-specs" design** (predates practical-first; over-indexes on SOL and a
spec-only gate — this ADR re-baselines it); **building an orchestration/multi-agent/sandbox
runtime** (crosses the boundary — adopt substrates, don't rebuild); **auto-decompose / `parse-prd`**
(the field's loudest failure — decomposition stays judgment work); **emitting review verdicts**
(violates ADR-0063 — the CLI routes, never adjudicates); and **a monolithic workflow command**
(forecloses piecemeal adoption — the Unix-part design is the answer).

## Consequences

Accepted. **`future-cli.md` is reframed from "the contract" to a suggestive illustrative surface of
this design** (it is a prior sketch, not the design of record — this ADR is): its header now points
here, the layered/standalone framing, the Unix contract, the canonical adapter event contract, the
MCP server, hook generation, and the reconciliation/coverage/gated-close capabilities are written
in (all toolable, milestone-tagged), and the **reserved `*.ir.json`/`*.plan.json` schema is
trimmed** per Decision 6 — the run record stays (the reconciliation substrate), the frozen IR/plan
schema goes, replaced by "corpus-cli parses the
markdown; optional `--json`." **Refines ADR-0054** (the structured form is now explicitly
tool-internal, not a documented Corpus artifact) and **ADR-0072/0076** (the run record + Provenance
line are the reconciliation substrate the run/review commands fill). **Re-baselines the SOL-era
corpus-cli specs (001, 005–009)**: `worktree`/`check`/`promote` survive as Layer-1/2 commands;
001's SOL-compiler framing and the SOL-`ir.json` substrate are superseded; new specs are cut per
phase (M1 standalone parts → M2 launch/reconcile → M3 supercharge). The RFC + research are the
recorded inputs in corpus-hq. corpus-cli's existing internal `Sol` IR (`buildIr`) is exactly the
tool-internal structure Decision 6 endorses — no artifact, kept.

## Propagation

`docs/reference/future-cli.md` (reframe to a suggestive surface of this design + write in the new capabilities + trim the IR/plan schema), `docs/reference/structured-requirements.md`

- `docs/reference/advanced-lifecycle.md` (reword the "reserved machine format" phrasing to
  tool-internal/`--json`), ledger row, RFC → accepted + its `spec.ir.json` references softened,
  corpus-hq board + the SOL-era spec dispositions. No corpus-cli code change in this decision (the
  phase specs drive that).
