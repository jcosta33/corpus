# Principles

> Swarm's reference for the load-bearing invariants and standing principles of the kernel: the tiebreakers that decide cases when two design choices collide. The installable payload that carries these principles into an adopted project ships under [`starter-kit/`](../starter-kit/).

Swarm treats a **specification as source code** and a **fleet of agents as the compiler**. Human intent is written as controlled markdown (the source); agents compile it into work that is implemented, verified against the original obligations, and promoted into durable memory. Everything below holds in *every* part of the framework — no construct may contradict an invariant.

The single object every principle turns on is the **obligation graph**: a typed graph whose nodes are obligations (and the verdicts rendered on them) and whose edges are the relationships among them. Specs produce obligations; the compiler lowers them into a plan and tasks; tasks implement them; traces claim them; verification proves them; reviews judge them; memory records durable discoveries about them.

---

## The five invariants

These are absolute. No later rule, template, pass guide, or profile may weaken them.

### 1. NO RUNTIME

Swarm is **markdown-only**. Everything that "runs" — parser, normalizer, planner, scheduler, differ, checker, LSP, CLI — is documented as a **contract a future tool builds against**, never as software this repository ships.

- **Rationale.** The repository is documentation plus a kernel payload. Shipping a runtime would couple Swarm to one environment and break provider-neutrality.
- **Consequence.** Any section describing tool behavior frames it as "the contract a future tool builds against." No file may claim a CLI is required, or that automation already exists. Every "runs" verb resolves to a future-tool contract.

> **Tiebreaker.** When tempted to describe a capability as something Swarm *does*: ask whether this repository ships code that does it. It does not. Restate it as a contract a future tool must satisfy.

### 2. SOFT vs HARD control

Prose, SOL, APS, pass guides, profiles, and `AGENTS.md` are **soft control** — context and guidance. They must not be presented as enforcement. Anything that must hold *regardless of the model* requires a **deterministic check outside the model** (a hook, CI step, permission rule, or schema validator) — the **hard control** lane.

- **Rationale.** Model adherence is probabilistic (prompt-format sensitivity, multi-turn decay, lost-in-the-middle / context-rot); only an external deterministic check can guarantee a property.
- **Consequence.** The spec maps each `CONSTRAINT`, `INVARIANT`, stop-rule, and secret-redaction need to its eventual deterministic home, and states plainly that **today the hard lane is aspirational/manual** — there is no runtime. No file may claim Swarm enforces behavior through code.

> **Tiebreaker.** When a property "must" hold: name the deterministic check outside the model that would enforce it, and mark it aspirational until a tool exists. The markdown layer makes omission conspicuous; it cannot guarantee.

### 3. SURFACE vs IR layering

Swarm has two layers: a **human surface** — English-shaped UPPERCASE space-separated keywords inside `*.swarm.md` — and a **machine IR/JSON layer** of snake_case fields. The surface is authored; the IR is emitted.

- **Rationale.** The surface optimizes for human readability and model comprehension; the IR optimizes for deterministic analysis. Conflating them produces fragile syntax.
- **Consequence.** Surface keywords are space-separated uppercase (`VERIFY BY`, `DEPENDS ON`, `OWNED BY`, `WRITES`, `READS`, `AFFECTS`); IR fields are snake_case (`verify_by`, `depends_on`, `writes`, `reads`, `affects`); surface ids are short (`AC-001`), IR node ids may be namespaced (`REQ.<spec>.AC-001`).

### 4. CODE IS REALITY

Code and tests are implementation **reality**: they can **falsify** an obligation, but they must not **silently amend** intent.

- **Rationale.** A passing or failing test is evidence about whether intent was met, not a re-statement of what intent *is*. Intent lives only in obligations.
- **Consequence.** When code disagrees with an obligation, the verdict is `STALE` or `CONTRADICTED`, and the conflict routes to an explicit three-way reconcile — re-run the proof, amend/supersede the obligation, or fix the code — never a silent re-bless of either.

### 5. SCHEMA-VALID OUTPUT IS NOT VERIFICATION

A structurally valid artifact — schema-valid IR, well-formed trace — is **not** a verified one. **Shape is not truth.**

- **Rationale.** Structured output constrains form but cannot prove values are correct. "Tests passed" without observable output is not a proof. [[REFLEXION]](research/sources.md#REFLEXION)
- **Consequence.** Every completion claim maps to independent deterministic or evidentiary verification; a `VERDICT` of `PASS` requires a bound proof that actually ran and produced inspectable evidence, not the mere existence of a syntactically valid trace.

> **Tiebreaker.** When a claim rests on "it parsed" or "the tests are green" with nothing pasted: that is shape, not truth. Demand the bound proof and its inspectable evidence.

---

## Standing principles

The invariants are absolute; the principles below are the design stances the specification relies on. They follow from, and never override, the five invariants.

### Provider-neutral

Swarm makes **no assumption about which model or agent** executes it — not Claude, Codex, Cursor, Gemini, Aider, or any specific tool.

- **Rationale.** The contracts must outlive any single vendor and any single capability ceiling.
- **Consequence.** No section may hard-code provider-specific behavior; capability claims must be dated and treated as evidence, not load-bearing assumptions.

### Markdown-only with a self-contained kernel payload

Swarm is delivered as markdown, and the kernel payload must be **self-contained**: its SOL and APS references must not depend on the repository's `docs/` tree.

- **Rationale.** A vendored kernel payload travels into a foreign repository where `docs/` will not exist.
- **Consequence.** The language references are duplicated into the kernel payload, and the duplication is kept consistent by the conformance contract.

### Edges are the single source of relationship truth

In the IR, **relationships live only on `edges[]`** — never duplicated as node scalars.

- **Rationale.** A relationship recorded in two places will drift; one canonical location keeps graph analyses (topo-sort, cycle detection, write-conflict, traceability) sound.
- **Consequence.** `depends_on`, `blocks`, `conflicts_with`, `verified_by`, `affects`, `implements`, and `preserves` are edge types; a node must not also carry the same relationship as a scalar field.

### Distillation discipline

Meaning must be **preserved across every lowering**. Each downstream transformation has a fixed budget of *permitted* loss and a fixed set of *forbidden* loss.

- **Rationale.** A compiler that drops obligations, modalities, or verification bindings during lowering produces work that does not match intent.
- **Consequence.** Dropping an obligation id, modality, actor, trigger, response, constraint, invariant, or verification binding during lowering is a **distillation error**.

### Load-bearing meaning lives only in SOL + IR

**All load-bearing meaning** — modality, actor, trigger/state, verification binding, authority order, conflict resolution, trace schema — lives in **SOL and the typed IR**, and never in prose, pass guides, profiles, or `AGENTS.md`.

- **Rationale.** Prose-delivered semantics are unreliable: model adherence degrades under prompt-format sensitivity, multi-turn reliability decay [[MULTITURN-LOST]](research/sources.md#MULTITURN-LOST), and lost-in-the-middle / context-rot [[LOSTMID]](research/sources.md#LOSTMID), and an always-loaded instruction file behaves as context rather than as enforced configuration.
- **Consequence.** Prose and pass guides are non-authoritative *delivery* layers; a regression check must confirm that no pass guide, profile, or `AGENTS.md` section defines modality, authority order, or verification semantics. Always-loaded normative prose is capped (≤200 lines / ≤25 KB) [[LOSTMID]](research/sources.md#LOSTMID), with everything procedural moved to lazily-loaded pass guides and profiles — to protect adherence and cost, not because models "cannot follow many instructions."

### Unitary at rest, modular in execution

Swarm's organizing slogan is **"unitary at rest, modular in execution."**

- **Unitary at rest.** Swarm installs as one coherent framework. The language, artifact contracts, passes, templates, pass guides, and memory model arrive together and are internally consistent — there is no menu of disconnected features to assemble.
- **Modular in execution.** At run time, only the pass, profile, and context a single task needs are loaded. A task names the pass guide and profile it requires; nothing else is in context. This protects instruction-adherence and token cost without fragmenting the framework. [[CTXENG]](research/sources.md#CTXENG)
- **Consequence.** The conceptual model is unitary: every piece is a component of one compiler, not an independent gadget. A repository binds the framework as one whole; what varies at run time is only which pass, profile, and context a given task loads.

### Evidence discipline — real science, not astrology

Swarm holds itself to the same standard it imposes on agents: **real science, not astrology.** Every load-bearing empirical claim and every standards-grounded normative choice must be grounded in a verified finding, used with its recorded caveats. This is Swarm's own discipline, applied to its own text and to every artifact a conformant repository produces.

- **Rationale.** A fact-shaped claim with no grounding is indistinguishable from invention; treating one as evidence corrupts every downstream verdict that rests on it.
- **Consequence.** A claim that is not backed by a verified finding must be stated as **design rationale**, not as evidence. A finding marked rejected, fabricated, or unverifiable must not be cited as fact — neither in canonical text nor in any produced artifact. A new empirical claim introduced by an amendment must first establish its grounding. **A fact-shaped statement that cites no verified source and is not labelled design rationale is a defect.**

---

## The workspace model (design)

These are design/layout principles for an adopted project, not empirical claims. The concrete layout is in [`model/workspace.md`](model/workspace.md); this section states the principles behind it.

### Swarm is a spec-repo discipline; the code repo stays pristine

Swarm lives in a **spec / documentation repo** (intent — authored and reviewed under `.agents/`). A **code repo** that consumes specs stays clean: no required Swarm footprint, at most one opt-in `implement-and-verify` skill, with all Swarm scratch gitignored and durable outcomes pushed back to the spec repo as linked PRs. Co-located is the degenerate one-repo case. ([ADR-0050](adrs/0050-swarm-is-a-spec-repo-discipline.md))

- **Rationale.** Intent is curated by a few and consumed by many across repos; one spec can govern several code repos. Developers reject tools that litter their codebase, so a code repo keeps only its real sources of truth and its code. A NO-RUNTIME framework also cannot justify a filing cabinet of directories nothing reads.
- **Consequence.** A spec repo prescribes only the flow folders it uses (`skills/`, `reference/`, `templates/`, `specs/`, `memory/`); a code repo prescribes none. No `.swarm/` mount, no version file, no empty tree. Project conventions live in the root `AGENTS.md`, not an overlays directory.

### SOL is an authoring aid, not a reading burden

SOL's English-shaped keywords exist to force the **author** to be unambiguous, testable, and bounded. A capable agent **reads** a good SOL spec with no grammar manual.

- **Rationale.** The value of the controlled language is paid at authoring time; the spec is then a self-legible interface. Shipping a "how to read SOL" skill into every code repo would be both pollution and redundant.
- **Consequence.** A code repo needs **no** SOL reference cards and no SOL-reading skill — the spec (delivered, or referenced by id) is the whole interface. The reference cards are authoring tools and live in the spec repo.

### Source, status, and generated are separate categories

Desired state (`sources/`), observed state (`status/`), and generated execution material (`generated/`) are **distinct artifact categories**. A spec is the desired-state artifact and is never edited to record pass/fail.

- **Rationale.** Recording observed satisfaction back into the intent artifact destroys the boundary between *what is required* and *what was observed* — the same conflation Invariant 4 (code is reality) forbids between obligation and evidence.
- **Consequence.** Desired behavioral intent lives in `sources/` (`*.swarm.md`); observed satisfaction and drift live in `status/`; derived task frames, traces, and reviews live in `generated/`. A `VERDICT`/`STALE`/`CONTRADICTED` result is recorded as a status/verdict artifact, never folded into the source spec's obligation text.

### Specs own intent; code owns realization

A `spec.swarm.md` owns desired behavioral **intent**; code owns implementation **reality**; the trace/review/status layer reconciles the two. Code is not a disposable bundle regenerated from the spec.

- **Rationale.** This *strengthens* Invariant 4 by stating its converse: just as code may not silently amend intent, the spec may not silently overwrite code as though code were a derived output. Treating code as regenerable-from-spec would license a model to rewrite an existing codebase from intent alone, discarding the implementation reality that Invariant 4 makes load-bearing evidence.
- **Consequence.** Manual and agent edits to governed code are legitimate and reconcile through trace/review/status; no canonical text may claim application code is disposable, must always be regenerated, or that manual edits are forbidden — except where a per-surface policy explicitly declares it `generated`.

### The ledger preserves compact history

Completed traces and reviews **compact** into ledger entries — covered obligations, changed surfaces, proof, verdicts, and promotions — rather than being retained forever as live scratchpads.

- **Rationale.** Keeping every task frame, trace, and review as an eternal working file accretes execution-local scratch into the durable record, blurring settled history from in-flight work.
- **Consequence.** After merge or abandonment, `generated/` traces/reviews reduce to a ledger entry preserving obligation coverage, changed surfaces, bound proof, review verdicts, and promotion results. Generated task frames are execution-local and are not a durable source of truth; the durable home is the source artifact plus the ledger entry and any promoted finding/ADR/amendment.

### Swarm is a toolchain, not an agent CLI

Swarm owns the **intent structure** — language, artifacts, passes, templates, the trace/review protocol, the memory model, and orchestration contracts — and coordinates existing agent CLIs as worker backends. It does not own the model loop, chat UI, tool-calling runtime, provider auth, or MCP runtime, and must not replace an agent CLI.

- **Rationale.** The orchestrator-worker boundary keeps coordination spec-driven where naive parallel coding agents fail: most coding tasks have few truly parallel sub-tasks, agents coordinate poorly in real time, and conflicting concurrent decisions favor single-threaded, full-context execution.
- **Consequence.** Every description of CLI/worktree/ledger automation is the **contract a future Swarm toolchain builds against** (Invariant 1, no runtime), never a runtime this repository ships. The toolchain prepares work and validates trace/review/promotion; a coordinated agent CLI performs the coding loop. No canonical text may frame Swarm as an agent runtime or chat assistant.

---

## How to use these principles

1. **In an amendment (ADR).** Cite the invariant or principle that motivates the decision. A change to any of these is an amendment that must be recorded as a new ADR and, if it touches the language, must bump the language version.
2. **In review.** Ask which principle a change serves and which (if any) it conflicts with. The five invariants are absolute tiebreakers; the standing principles never override them.
3. **As a skim test.** A doc, template, pass guide, or profile that violates an invariant without explanation is a defect, not a style choice.

## Related

- [Non-goals](./NON-GOALS.md) — what Swarm deliberately is not, the negative space these principles protect.
- [The compiler pipeline](./model/compiler-pipeline.md) — the seven phases and nine passes the obligation graph flows through.
- [The `.swarm/` workspace](./model/workspace.md) — how the source / status / generated categories above lay out on disk.
- [Source authority](./model/source-authority.md) — the amendment and authority rules an ADR cites when changing a principle.
- [Architecture decision records](./adrs/README.md) — the recorded amendments; a change to any invariant or principle lands as a new ADR.
