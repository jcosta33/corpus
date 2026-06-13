---
type: adr
id: adr-0077
status: accepted
created: 2026-06-13
updated: 2026-06-13
---

# ADR-0077 — swarm-cli is a reconcile-only harness of composable parts

## Context

RFC-swarm-cli-vision (`swarm-hq/specs/swarm-cli-vision/rfc.md`, accepted by the owner 2026-06-13)
proposed a direction for swarm-cli, grounded in a six-lens deep-research survey (~120 sources,
`research.md`). Three pressures forced the decision: swarm-cli's on-paper design (in-repo specs
001, 005–009) is **SOL-era** and predates the practical-first repositioning; the agentic-CLI
market has **converged** on a substrate (headless invocation, structured JSON events, hooks, MCP,
worktree-per-task) and left two gaps open that map onto Swarm's strengths; and the owner's brief
requires the CLI to both **supercharge Swarm** and be **useful standalone for any agentic work**,
honoring the "parts individually usable, maximally valuable together" thesis. The owner also
resolved the `ir.json` question (Option A, below).

## Decision

swarm-cli is **a reconcile-only harness for agentic work**: composable parts that *prepare*,
*launch*, and *reconcile* agent runs — each useful standalone, all composed by the Swarm workspace
into the loop. It never *performs* the coding loop. Each rule carries an honesty level (ADR-0063).

1. **Three layers.** (a) A reconcile-only **core library** (parse markdown → internal structure,
   checks runner, packet drafting, review reconciliation, derived status) the CLI thinly wraps,
   importable by editors/CI/the MCP server without shelling out. (b) **Standalone primitives**
   usable without adopting Swarm. (c) A **Swarm-aware composition layer** that supercharges the
   loop. *Level: convention (architecture).*
2. **The Unix contract — every command is a well-behaved part.** `--json` output, meaningful exit
   codes (0 clean / 1 warnings / 2 error), stdout-for-data / stderr-for-messages, a
   `--no-workspace` fallback that degrades like `git` outside a repo, and a `swarm-*` PATH-plugin
   convention for extensions. This is what lets a command be adopted one at a time. *Level:
   toolable.*
3. **Standalone primitives (Layer 1):** `swarm worktree` (one-worktree-per-task + per-worktree
   runtime-isolation config; interops with `claude --worktree`), `swarm run --agent` (a uniform
   headless wrapper normalizing each agent's flags + output), `swarm spec check` (a standalone
   spec linter), `swarm status` (a derived read-model). `cost` and `notify` ship as `swarm-*`
   PATH-plugins, not core (resolves RFC Q-004 — keep the core reconcile-only). *Level: toolable.*
4. **The canonical adapter event contract.** Adopt the converged vocabulary
   (`init` / `assistant` / `tool_call` / `result`, + final message, cost, exit code) and map each
   agent CLI's native JSON/stream-JSON onto it; **carry a contract version** against vendor churn
   (resolves RFC Q-001). Swarm invents no new event vocabulary. *Level: toolable.*
5. **Supercharge (Layer 2):** a **Swarm MCP server** (serves the task packet scope, the parsed
   requirements, and the checks contract — one surface for every MCP-capable agent); **per-adapter
   hook generation** (wires a task's write-set + `checks.yaml` into the agent CLI's hooks);
   **launch-envelope provenance** on `swarm run`; **diff-vs-self-report reconciliation** in
   `swarm review`; **deterministic coverage/drift**; **gated close**; **per-task cost
   attribution**. Sequencing: **shell-out adapters first (M2), the MCP server at M3** (resolves
   RFC Q-005 — ship both, shell-out covers agents without MCP). Provenance emits the ADR-0076
   Provenance line now; **track Agent Trace** as the interop JSONL format, adopt only once it
   settles (resolves RFC Q-003). *Level: toolable; hook-based enforcement is performed by the
   agent CLI's hook runtime, recorded as such — never enforcement by swarm-cli.*
6. **The IR is tool-internal — there is no Swarm `ir.json` artifact (resolves RFC Q-002, owner's
   Option A).** swarm-cli must parse a spec's markdown into an internal structure to check it; it
   may project that structure as optional `--json` for interop. That is the whole of it: **markdown
   stays the only Swarm artifact**, adopters never create or see an `ir.json`/`plan.json`, and
   canon documents **no frozen machine-artifact schema**. The deterministic-coverage/drift wedge
   runs on the parsed markdown, not on a required file. *Level: toolable (the `--json` projection);
   the parse structure is an implementation detail.*
7. **The two defensible wedges.** Own what the field leaves open and what depends on Swarm's
   declared scope: **deterministic coverage / executable-criteria checking** (the field ships
   LLM-interpreted prose "without guarantees"; Swarm checks mechanically) and **reconciling the
   agent's self-report against the actual diff** (no mainstream tool does it). *Level:
   positioning.*
8. **The boundary — what swarm-cli must never own.** The model/reasoning loop, the chat UI,
   file-editing mechanics, provider auth, the MCP *runtime*, the **sandbox/container runtime**
   (adopt `@anthropic-ai/sandbox-runtime` / container-use / `claude --worktree` as substrates the
   adapter selects), and **the review verdict** (agent fill is a draft; empty Evidence reads
   Unverified; the human owns Pass/Fail/Unverified/Blocked). Absorbing any of these would make
   swarm-cli a coding agent. *Level: convention (the hard line).*

## Alternatives considered

The RFC weighs six in full; the load-bearing rejections: the **SOL-era "canonical 14 / fixed
pipeline / merge-gate-over-specs" design** (predates practical-first; over-indexes on SOL and a
spec-only gate — this ADR re-baselines it); **building an orchestration/multi-agent/sandbox
runtime** (crosses the boundary — adopt substrates, don't rebuild); **auto-decompose / `parse-prd`**
(the field's loudest failure — decomposition stays judgment work); **emitting review verdicts**
(violates ADR-0063 — the CLI routes, never adjudicates); and **a monolithic workflow command**
(forecloses piecemeal adoption — the Unix-part design is the answer).

## Consequences

Accepted. **Amends the `future-cli` contract**: adds the layered/standalone framing, the Unix
contract, the canonical adapter event contract, the MCP server, hook generation, and the
reconciliation/coverage/gated-close capabilities (all toolable, milestone-tagged); and **trims the
reserved `*.ir.json`/`*.plan.json` schema** per Decision 6 — the run record stays (the
reconciliation substrate), the frozen IR/plan schema goes, replaced by "swarm-cli parses the
markdown; optional `--json`." **Refines ADR-0054** (the structured form is now explicitly
tool-internal, not a documented Swarm artifact) and **ADR-0072/0076** (the run record + Provenance
line are the reconciliation substrate the run/review commands fill). **Re-baselines the SOL-era
swarm-cli specs (001, 005–009)**: `worktree`/`check`/`promote` survive as Layer-1/2 commands;
001's SOL-compiler framing and the SOL-`ir.json` substrate are superseded; new specs are cut per
phase (M1 standalone parts → M2 launch/reconcile → M3 supercharge). The RFC + research are the
recorded inputs in swarm-hq. swarm-cli's existing internal `Sol` IR (`buildIr`) is exactly the
tool-internal structure Decision 6 endorses — no artifact, kept.

## Propagation

`docs/reference/future-cli.md` (amend + trim the IR/plan schema), `docs/reference/structured-requirements.md`
+ `docs/reference/advanced-lifecycle.md` (reword the "reserved machine format" phrasing to
tool-internal/`--json`), ledger row, RFC → accepted + its `spec.ir.json` references softened,
swarm-hq board + the SOL-era spec dispositions. No swarm-cli code change in this decision (the
phase specs drive that).
