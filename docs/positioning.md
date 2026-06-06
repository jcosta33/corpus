# Positioning

> Where Swarm sits next to its neighbours — spec-driven tools, agent frameworks, prompt libraries, and requirement languages — and the agentic failure modes it is built to position against. This page is a map, not a manifesto: for the invariants that make the differences load-bearing, read [`PRINCIPLES.md`](./PRINCIPLES.md); for the boundaries that say what Swarm refuses to be, read [`NON-GOALS.md`](./NON-GOALS.md); for the one-paragraph statement of what Swarm *is*, read the [root README](../README.md).

Swarm is a **markdown-only, provider-neutral, obligation-centered specification compiler**: a controlled-markdown spec is the source code, a fleet of agents is the compiler, and the central object is the **obligation graph**. Most of the tools Swarm is compared to are doing a genuinely different job — and the comparison is most useful once that is clear. The short version: Swarm differs on three axes at once. It centers an **obligation graph** rather than a document or a persona; it produces **verified output** (every required obligation must carry a passing verdict at the merge gate) rather than text a human still has to trust; and it ships **no runtime** — everything that "runs" is a contract a future tool builds against.

---

## What Swarm is, next to its neighbours

The agentic-tooling landscape sorts into four families. Swarm overlaps each one at a single point and diverges everywhere else. The table below is the map; the prose after it names the one thing that separates Swarm from each family.

| Family | Representative members | What it centers / does | Where Swarm differs |
|---|---|---|---|
| **Spec-driven tools** | spec-first scaffolds and command suites that turn a written spec into an implementation | A spec *document* the agent implements against; the spec guides, and a human reviews the result | Swarm's spec is not prose-that-guides — its load-bearing meaning is carried as **typed obligations** that lower into an **obligation graph**. The merge gate is a property of that graph (*every required obligation carries a passing verdict*), not a human's read of a document. |
| **Agent frameworks** | orchestrators, single-threaded session agents, orchestrator-worker research systems | The *agent loop* — how a model is driven, how subagents are spawned, how tools are called | Swarm owns no model loop. It is **no-runtime**: it coordinates existing agent CLIs as worker backends through adapters and never becomes one. It governs the intent structure and the proof, not the chat UI, tool-calling runtime, or provider auth. |
| **Prompt / skill libraries** | curated collections of reusable instructions, practices, and skill files | A *library* of prompts or skills you pick from to steer a single agent | Swarm's reusable methods (**pass guides**) and cognitive stances (**heuristic profiles**) are components of one compiler, each parameterizing a named pass — not standalone gadgets. The unit is the obligation-bounded task, not the prompt. |
| **Requirement languages** | controlled-language requirement notations, structured-spec DSLs | A *formal notation* for requirements, validated for shape and consistency | Swarm's surface (SOL inside readable markdown) exists to bind **proof**: an obligation is satisfied only when a bound proof actually ran and produced inspectable evidence. Schema-valid is explicitly *not* verified. Swarm is not a general-purpose language; it is a spine inside prose whose endpoint is verified work. |

Three differences recur across every row, and together they are the position:

1. **Obligation graph as the IR.** Other families center a document, an agent, a library, or a notation. Swarm centers a typed graph of obligations and the verdicts rendered on them. Every pass reduces to an operation on that graph. The design rationale is that a graph is the only object that can answer the one question the merge gate asks — *is every required obligation satisfied?* — without a human re-reading the whole spec. (See [overlays](./library/overlays.md) for why the portable *methods* stay separate from this graph.)

2. **Verified output, not trusted output.** Swarm's confidence gate is not "the agent says it's done" and not "the document looks complete." It is a bound proof — across the proof types (`static`, `test`, `contract`, `property`, `model`, `perf`, `security`, `manual`, `monitor`) — declared with `VERIFY BY` and judged into one of the verdicts (`PASS`, `FAIL`, `BLOCKED`, `UNVERIFIED`, plus the lifecycle verdicts `WAIVED`, `STALE`, `CONTRADICTED`). A "tests passed" message is not, by itself, proof; proof is bound explicitly to an obligation. [[REFLEXION]](research/sources.md#REFLEXION)

3. **No runtime.** Swarm ships markdown and an inert kernel payload. The thing that would schedule passes, diff specs, or check conformance is a contract a future tool builds against — never software this repository provides. This is what keeps Swarm provider-neutral; the other families each couple to a harness, a model, or a stack. The full boundary is in [`NON-GOALS.md`](./NON-GOALS.md).

---

## The failure modes Swarm positions against

Coding agents fail in predictable ways. The brittleness is not random — it recurs as a small set of patterns, and each one is the reason a corresponding part of the kernel exists. Swarm's whole shape is a response to this taxonomy.

| Failure mode | What it looks like | What in the kernel answers it |
|---|---|---|
| **Drift** | The agent solves *a* problem, not *the* problem; the work wanders away from the ask. | Obligations are the named, typed unit of intent; a task frame carries exactly the obligations it must satisfy, so there is nothing to drift *toward*. (See [the verify pass](./passes/verify.md) for why even a loaded guide's steps get skipped without forced evidence.) |
| **Architecture conflict** | The agent introduces a pattern the codebase has explicit rules against — because nobody told it the rules. | `CONSTRAINT` and `INVARIANT` obligations make the house rules first-class and reviewable; overlays carry project-local rules into the relevant pass. |
| **Hallucinated completion** | "Done." The build was never checked, the tests never ran — and the agent believes it shipped. | The merge gate is a property of the obligation graph, not a self-report: every required obligation must carry a passing verdict bound to a proof that actually ran. Schema-valid is not verified. |
| **No resumable trail** | The session ends mid-stride; the next session starts from scratch and re-discovers the same things. | State is externalised to durable artifacts — sources, status, traces, reviews — rather than held in a conversation [[SCRATCHPAD]](research/sources.md#SCRATCHPAD). (See [the workspace](./model/workspace.md) for the resumption record.) |
| **Repeated mistakes** | The same class of bug reappears across sessions because nothing captured the lesson. | The `promote` pass folds durable discoveries back into project memory, so a lesson learned once is recallable. |
| **Coordination failure** | Two agents working on related changes produce inconsistent results because they could not see each other's context. | The plan carries a write-conflict graph and a safe-parallelism predicate; reads may parallelise, but writes that touch the same surface are serialised. |

These share one root cause: the agent works without **grounded, verified conditioning**. It has the model, the tools, and a prompt — but not the frame a human in the room would have brought, and no independent check that what it produced is actually what was asked. Swarm supplies the frame as an obligation graph and the check as bound proof. Where each of these claims rests on evidence, that evidence is cited inline through the framework docs (via `[[KEY]]`) and catalogued in [`docs/research/sources.md`](./research/sources.md); the design rationale for treating them as load-bearing is in [`PRINCIPLES.md`](./PRINCIPLES.md).

A note on what Swarm does *not* claim to have solved: live multi-agent orchestration, cross-project memory, and long-context coherence remain open. Swarm holds a defensible position on the divided questions — read-side parallelism is fine, write-side parallelism causes coordination failure; obligations and proofs are specified, not the generative process that satisfies them — but it does not pretend the frontier is settled. The boundaries it deliberately declines are enumerated in [`NON-GOALS.md`](./NON-GOALS.md).

---

## See also

- [Root README](../README.md) — what Swarm is, in one paragraph: spec-as-source, agents-as-compiler.
- [`PRINCIPLES.md`](./PRINCIPLES.md) — the five invariants the differences above turn on (NO RUNTIME first).
- [`NON-GOALS.md`](./NON-GOALS.md) — the deliberate boundaries: what Swarm refuses to be.
- [`docs/research/sources.md`](./research/sources.md) — the source bibliography the inline `[[KEY]]` citations resolve to.
