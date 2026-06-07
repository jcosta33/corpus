---
type: audit
id: sim-parallel-memory-drift
status: draft
created: 2026-06-07
updated: 2026-06-07
---

# Audit: parallel decomposition, memory promotion, and drift detection under NO-RUNTIME

> Stance: **observation-only**. This audit records what *is* in the shipped framework
> (`docs/` + `starter-kit/`) for the scale+durability journey — decompose a spec into parallel
> packets, coordinate writes, merge, promote durable findings, track status, detect drift. It
> records present-state risk in the *specification of the discipline*; it prescribes no fix and
> authors no obligation block. The framework ships NO RUNTIME: every "graph computed", "disjointness
> proved", "staleness fired", "queue resolved" is an act a human or future tool performs by hand. The
> central risk class is exactly that gap — load-bearing invariants stated as MUSTs with no enforcer.

## Scope

- **In scope:** the decompose/promote pass specs (`docs/passes/{decompose,promote}.md`), their
  starter-kit step guides + references (`starter-kit/.agents/skills/pass-decompose-spec/`,
  `pass-promote-findings/`), the coordination/memory/finding/status artifact contracts
  (`docs/artifacts/{task-orchestration,memory,finding,status}.md`), and the
  drift/promotion/source-authority/workspace references
  (`docs/reference/{drift-and-staleness,promotion-protocol}.md`,
  `docs/model/{source-authority,workspace}.md`).
- **Out of scope:** the SOL grammar, the verify/review verdict model internals, the lint-code
  catalogue mechanics, ADR supersession history. Cited only where the journey touches them.
- **Reviewed against the goal:** a reviewer must be able to trust that a parallel run produces a
  consistent, non-lossy merge; that promoted memory is provenanced, non-poisoned, and recallable;
  and that drift in code/specs/findings is *noticeable*. The framework is markdown-only by design;
  this audit does not fault it for lacking a runtime — it surfaces where the *discipline* leaves a
  load-bearing invariant unenforced, ambiguous, or silently violable by a human/agent following the
  guides exactly.

## Observations

Each observation states what is true today in the shipped docs, cites evidence, and carries a
severity calibrated by blast radius (BLOCKER = silent data loss / corruption / poisoned authority;
MAJOR = a load-bearing invariant routinely unenforceable or under-specified; MINOR = a narrower gap
or sharp edge).

### O1 — The safe-parallelism predicate is provably correct only if a human computes glob-overlap correctly, with no checker [BLOCKER]

- **Evidence:** `docs/passes/decompose.md:189-223` defines `merge_safe` as "Swarm's **one**
  safe-parallelism predicate … Conformant tools and authors MUST use it verbatim", with overlap
  defined as pattern-*language* intersection over a glob lattice (`:215-223`): "**String inequality
  does NOT imply disjointness.**" `:5` and `:148` confirm NO RUNTIME — "Plan derivation *is* the
  `decompose` step … never the output of a shipped emitter". The skill guide repeats it as a manual
  step (`pass-decompose-spec/SKILL.md:74-86`) and flags the failure (`:130`): treating
  `src/auth/**` vs `src/auth/client.ts` as disjoint is the named anti-pattern.
- **Observation:** the entire write-side safety of a parallel run rests on a human (or LLM) computing
  glob-language intersection — `**` spanning segments, `*` not crossing `/` — by hand, with no tool
  in the framework to check it. The doc itself states "two implementations derive the identical
  conflict graph from the same spec" (`:223`) as a *requirement on a future tool*, not a property the
  framework guarantees today. An agent that eyeballs two surface strings as "different, therefore
  disjoint" co-schedules two writers onto the same file. The result is precisely the silent merge
  corruption `SOL-O001` is raised to ERROR to prevent (`decompose.md:247`,
  `task-orchestration.md:24`) — but `SOL-O001` is itself only "enforced by hand or by the documented
  lint step, aspirational until tooling exists" (`source-authority.md:118` for the sibling M-codes;
  `decompose.md:268` "manual today, tool-enforced later").
- **Severity reasoning:** glob-overlap is the single computation the disjointness proof reduces to,
  and LLMs are demonstrably weak at exactly this kind of syntactic set reasoning. A wrong call is not
  caught by review-of-the-plan (a reviewer re-derives the same way) and surfaces only as a real merge
  conflict or, worse, a clean merge that drops one writer's edit. Blast radius = lost work across the
  whole fan-out.

### O2 — "Unscoped serializes" depends on the author having declared WRITES; a missing WRITES that the author *forgot* is indistinguishable from honest absence [BLOCKER]

- **Evidence:** `decompose.md:207` — "**Unscoped serializes.** An obligation with no `WRITES` clause
  is treated as conflicting with *every* other obligation … MUST NOT be co-scheduled in a parallel
  batch." But `WRITES` is `MAY carry` metadata on an obligation (`decompose.md:39` — "MAY carry
  scope-declaration metadata"). The drift page states the hard limit plainly
  (`drift-and-staleness.md:87`): "what is unhashed is unseen … An obligation whose true read set
  exceeds its declared `READS` is a soft-control gap to be caught in review, not a guarantee this
  page makes."
- **Observation:** the safe default ("unscoped → serialize") only protects work whose scope the
  author *omitted entirely*. It does **not** protect work whose author declared a `WRITES` set that
  is *narrower than the truth* — e.g. `WRITES auth.client.code` on an obligation whose implementation
  also touches `auth.config`. That obligation looks fully scoped, gets a clean `merge_safe: true`
  against a batch-mate that legitimately owns `auth.config`, and the two writers collide at a surface
  the conflict graph could not see. The `OWNED ⊆ WRITES` rule (`decompose.md:225-247`) detects an
  *owned path* outside declared WRITES, but only if the lead actually projects and declares that
  owned path — a worker that *writes* outside its OWNED set at implement-time is caught only by the
  merge-gate condition 5 (`task-orchestration.md:166`), which is again a hand-checked predicate.
- **Severity reasoning:** under-declared WRITES is the *common* authoring error (people scope what
  they're thinking about, not what they'll touch), and unlike a total omission it defeats the one
  default the framework leans on. Same blast radius as O1 — silent cross-writer corruption.

### O3 — Disjointness is required "before any worker is spawned" but workers diverge *during* execution with nothing observing them [BLOCKER]

- **Evidence:** `task-orchestration.md:15` — "that pairwise-disjointness MUST be confirmed *before*
  any worker is spawned." `:117` — "a worker hung `in-progress` or silently diverging is otherwise
  invisible state — Swarm has no runtime to detect it." The only liveness mechanism is the manually
  updated `Last progress` column and the STALL threshold "no progress across **two consecutive
  checks**" (`task-orchestration.md:120`), which is itself "a chosen design constant … not an
  empirical borrowing." The merge-gate re-check of conflict (condition 5, `:166`) is evaluated by a
  reviewer at merge time.
- **Observation:** disjointness is proven against the *plan's declared* OWNED sets up front. Nothing
  in the discipline observes whether a worker, mid-task, writes a file outside its OWNED set (a real
  agent editing a shared import, a config, a generated file). The FORBIDDEN column
  (`task-orchestration.md:82`) "makes the boundary explicit and reviewable" but is inert text — there
  is no pre-commit hook, no worktree write-guard in the framework (the worktree gives *path* isolation
  only in that each task has its own checkout; `:152` explicitly scopes the guarantee to file/path
  disjointness and excludes runtime resources). Two worktrees can both edit the same logical surface
  and only collide at merge — discovered by a human, late.
- **Severity reasoning:** this is the gap between a *statically* proven plan and a *dynamically*
  unfaithful execution. It is the dominant real-world multi-agent failure (an agent helpfully "fixes"
  a neighbouring file). No part of the shipped framework can catch it before merge; the merge gate
  catches it only if the human reviewer re-derives overlap (see O1). Blast radius = the whole run.

### O4 — Finding staleness is structurally weaker than verdict staleness: one scalar `content_hash`, no per-surface/exercised set, no comparator [MAJOR]

- **Evidence:** the trace-provenance schema records `per_surface_hash[]` with an `exercised` bool per
  surface, enabling the precise 4-condition staleness rule (`drift-and-staleness.md:13-89`). A
  *finding*, by contrast, carries a single `content_hash` — "Hash of the cited **source/surfaces**"
  (singular field) (`finding.md:53`, `promote.md:59`, `promotion-protocol.md:86`). The comparator is
  not shipped for either: "Swarm ships the **fields** … it does **not** ship the comparator …
  aspirational/manual today" (`promote.md:119`, `promotion-protocol.md:107`).
- **Observation:** a finding's freshness collapses many cited surfaces into one opaque hash with no
  per-surface or exercised-path granularity, so (a) a finding cannot express "stale only if the
  surface I actually relied on changed" the way a verdict can, and (b) there is no defined procedure
  for *what bytes* the finding's `content_hash` covers when its evidence cites several files plus a
  command output. Combined with the missing comparator, a `promoted` finding never actually flips to
  `stale` unless a human re-hashes it by hand and happens to notice. The `applies-when`/`Load when`
  pairing (`promotion-mechanics.md:22`) must be kept in sync by hand across two files, with the doc
  itself noting a drift between them "means the recall map points at a fact under conditions the fact
  itself disclaims" — again unenforced.
- **Severity reasoning:** memory is the layer designed to *outlive* a task and be recalled blind by a
  future agent. A finding that has silently gone false but never flips `stale` is authority-rot: the
  future task loads it via `Load when`, trusts it, and builds on a dead fact. Blast radius is wide
  (every future task whose trigger matches) but the failure is gradual and detectable on careful
  review, hence MAJOR not BLOCKER.

### O5 — The poisoning defense (`validated`) hinges on correctly *classifying* a source as "high-consequence" or "externally-authored" — itself an unenforced human judgement [MAJOR]

- **Evidence:** `promote.md:114` / `promotion-protocol.md:96` / `pass-promote-findings/SKILL.md:76`
  — the untrusted-source boundary: "A `pending` finding produced by an externally-authored source …
  MUST NOT skip `validated`." `validated` requires "independent corroboration — a second finding, a
  re-run proof, or a reviewer who is *not* the promoting agent." But what counts as
  "high-consequence" is left to the guide ("The exact `validated`-corroboration procedure … is bound
  here as a requirement; the `promote` stdlib step guide supplies the recipe", `promote.md:125`), and
  "externally-authored" is a category the promoting agent itself must recognise.
- **Observation:** the memory-poisoning countermeasure is gated on the *promoting agent* labelling
  the input correctly. A poisoned fact arriving through a benign-looking channel (a finding the agent
  authored from a doc it was told to trust) is exactly the input the agent will *not* classify as
  untrusted — the attack works by not looking like an attack. "Independent corroboration" by "a
  reviewer who is not the promoting agent" has no teeth when the same agent plays both roles in a
  solo run, which the producer-repo workflow (and many adopters) will. There is no mechanism
  distinguishing a genuine second finding from the same agent re-asserting the first.
- **Severity reasoning:** the whole `validated` tier exists to stop poisoning at ingestion
  (`promotion-protocol.md:94`). If the trigger for it is self-assessed by the agent that may already
  be compromised or simply credulous, the defense is advisory. Promoted memory carries real authority
  downstream (ranked above task/chat, `source-authority.md:23`), so a poisoned `promoted` finding is
  durable, indexed, and recalled-as-true. MAJOR.

### O6 — The close gate ("no item `pending`") is satisfiable by *enumerating* discoveries — but nothing enumerates them; an un-noticed discovery is an un-queued discovery [MAJOR]

- **Evidence:** `promote.md:77` close gate — "A task MUST NOT close while any promotion item is
  `pending`." Rule 1 (`pass-promote-findings/SKILL.md:43-45`): "Enumerate every discovery the task
  surfaced … A discovery left out is a silent drop." The defense against silent drops is "Recording
  the rejection keeps the queue falsifiable" — i.e. it only catches discoveries that *made it into
  the queue*.
- **Observation:** the gate enforces resolution of *queued* items; it cannot enforce that a discovery
  was queued in the first place. A durable fact an agent noticed but didn't write down never becomes
  a `pending` item, so the gate passes vacuously. There is no cross-check (e.g. against the trace's
  surfaced anomalies or the review's findings) that would reveal a discovery the agent simply failed
  to log. The whole apparatus rests on the honesty/completeness of one enumeration step the agent
  performs from memory.
- **Severity reasoning:** this is the standard "you can only gate what you can see" gap, but it is
  load-bearing here because promotion is the *only* path from task to durable memory — a missed
  discovery is permanently lost on reconciliation when the execution packets are discarded
  (`promotion-protocol.md:111`, `task-orchestration.md:140`). MAJOR: silent knowledge loss, but
  per-item not corrupting.

### O7 — Drift detection cannot see undeclared reads, and the framework openly concedes this — so a passing proof can mask real behavioral drift [MAJOR]

- **Evidence:** `drift-and-staleness.md:87` (Scope limit): the rule "does **not** and **cannot**
  detect behavioral drift through an *undeclared* dependency, a hidden global, or an environmental
  input … Swarm therefore claims **declared-drift detection**, never full behavioral-drift
  detection." Condition (c) (`:82`) only hashes `READS` surfaces "that lie on the evidence path" —
  i.e. those the author declared *and* the proof exercised.
- **Observation:** an obligation whose true read set exceeds its declared `READS` has missing hashes,
  so a change to that undeclared dependency never fires `STALE`; the recorded `PASS` stays green and
  authoritative while the behaviour has actually drifted. This is honestly disclosed, but it means
  "STALE blocks the merge gate" (`:55`) is a guarantee only over *declared* surfaces. The residual is
  pushed to "caught in review" — a soft control — and to `property`/`metamorphic` oracles that "reduce
  the gap, they do not erase it" (`:87`).
- **Severity reasoning:** drift coverage (`drift-and-staleness.md:103`) is reported as a metric that
  looks like a safety property but measures only declared-surface staleness; a reviewer reading "0%
  drift" may over-trust it. The honesty of the disclosure and the review backstop keep this MAJOR.

### O8 — Status, ledger, and INDEX consistency are entirely hand-maintained derived projections with no regeneration tool [MAJOR]

- **Evidence:** the status "is rebuilt by a human or an agent following the verify, review, and
  promote step guides" (`status.md:5`); it "MUST NOT be the only home of any fact" and is "regenerated
  … by the verify, review, and promote steps" (`status.md:17-18`). The INDEX "MUST NOT duplicate or
  restate the body" and a divergence is "advisory drift, never … a second source of truth"
  (`memory.md:17`). The ledger is "append-only … a correction is a *new* entry" with no compactor
  shipped (`promotion-protocol.md:113,126`).
- **Observation:** three derived read-models (status, INDEX, ledger) must each be kept consistent with
  their upstream sources by hand. Nothing regenerates a status from traces, reconciles an INDEX row
  against its finding's actual status, or proves a ledger entry compacted everything it claims. A
  status whose `updated` falls behind change is "itself a signal" (`status.md:53`) — but only to a
  human who looks. An INDEX row can point at a `stale`/`rolled-back` finding while still reading
  `promoted` until someone edits both. The framework explicitly forbids shipping a tool to police
  this (`status.md:20`: "a conformant repository MUST NOT ship a tool whose job is to police whether
  a status has overstepped").
- **Severity reasoning:** these are the artifacts a *future* task and the merge gate consult to make
  decisions. Stale projections feed wrong gate verdicts and wrong recall. Hand-maintenance across
  three files multiplies drift surface. MAJOR — wrong decisions, but each detectable by re-derivation.

### O9 — The conflict graph and coordination record are single-spec; cross-spec parallel writes have no disjointness proof [MAJOR]

- **Evidence:** the plan's `meta.id` "matches the source structured form's `meta.id`"
  (`decompose.md:165`); the predicate operates on "the typed graph" of one `*.swarm.ir.json`
  (`decompose.md:21`). The coordination record's frontmatter binds one `source: spec.swarm.md` and
  one `parallel_group` (`task-orchestration.md:62-64`); FORBIDDEN is "the union of every *other*
  worker's OWNED paths" *within that run* (`:82`). Yet a launcher "MAY interleave steps across
  multiple specs and MAY run write-disjoint `implement` packets in parallel" (`implement.md:28`).
- **Observation:** the safe-parallelism proof is computed over one spec's obligations. When two
  *different* specs' runs execute concurrently (explicitly permitted), no single conflict graph or
  coordination record spans them, so two workers from two specs can be each individually
  `merge_safe: true` within their own run while writing the same surface across runs. The disjointness
  invariant has no cross-spec scope. Cross-spec references exist as a syntax (`SOL.md:124`) but a
  *cross-spec import/namespace mechanism is an explicit NON-GOAL* (`NON-GOALS.md:57` D3), so there is
  no declared way to even express a shared surface across specs.
- **Severity reasoning:** any multi-feature repo running two parallel decompositions at once hits
  this. The single-spec assumption is implicit and never flagged as a precondition of the safety
  proof. MAJOR — real, but only fires when concurrent *cross-spec* runs touch a shared surface.

### O10 — INTENT-PRESERVED-PROOF for merges depends on the resolver choosing and running the right equivalence oracle, by hand [MAJOR]

- **Evidence:** `task-orchestration.md:125-127` — the merge log "MUST carry an
  **INTENT-PRESERVED-PROOF** column for every non-trivial conflict … 'Tests pass on the merged
  branch' is necessary but … **not sufficient**" and the recommended oracle is a
  property/differential/metamorphic check "on the conflicted region." `decompose` skill repeats it as
  an anti-pattern (`pass-decompose-spec/SKILL.md:136`).
- **Observation:** the strongest merge-integrity rule in the journey requires the human resolving a
  conflict to (a) recognise the conflict as "non-trivial", (b) select an adequate equivalence oracle,
  and (c) actually run it and paste the result. All three are unenforced judgement calls. A resolver
  who records "suite green" for a genuinely non-trivial semantic conflict produces a merge-log row
  that *looks* compliant; nothing distinguishes it from a real property check. The "trivial
  fast-forward MAY record the green suite alone" carve-out (`:127`) gives a tempting off-ramp the
  resolver self-applies.
- **Severity reasoning:** a wrong merge resolution that drops one branch's intent is exactly the
  outcome the parallel-write discipline exists to prevent, and it lands in `main`. The proof is the
  only guard, and it is self-attested. MAJOR (BLOCKER-adjacent — bounded only because it requires an
  actual semantic conflict to fire).

### O11 — A single finding promoted to a pattern, and rollback re-opening obligations, are correctness rules with no enforcer and no transactional guarantee [MINOR]

- **Evidence:** "A single finding MUST NOT be promoted directly to a pattern" (`promote.md:44`,
  `pass-promote-findings/SKILL.md:91`); rollback "re-opens any obligation it had narrowed"
  (`promote.md:115`, SKILL rule 9). The ledger/INDEX edits and obligation re-opening are separate
  manual writes.
- **Observation:** rollback is described as a multi-write act (retraction row in INDEX + re-open
  obligations + ledger entry) with no atomicity — a human can record the retraction and forget to
  re-open the obligation it had narrowed, leaving an obligation silently weakened by a now-withdrawn
  fact. The one-finding-to-pattern rule is a discipline a counting check could enforce but no shipped
  tool does. The `validated` "second corroborating finding" can, in a solo run, be the same insight
  written twice.
- **Severity reasoning:** narrower blast radius (a specific obligation or pattern), and the immutable
  append-only ledger preserves enough trail to detect the inconsistency later. MINOR.

### O12 — `max_parallel`, `lane`, `batch`, STALL threshold are advisory launcher hints a consuming repo may read as guarantees [MINOR]

- **Evidence:** `max_parallel` "is an **advisory parallelism hint for a launcher**" (`decompose.md:165`);
  `lane`/`batch` "Launcher hint only; absence does not affect safety" (`:182`); the two-check STALL
  threshold is "a chosen design constant … not an empirical borrowing" (`task-orchestration.md:120`).
- **Observation:** several fields that look like operational controls are explicitly non-binding on
  safety. A reader who sets `max_parallel: 1` expecting serialization, or trusts `batch` ordering as
  a merge guarantee, is relying on launcher behaviour Swarm does not specify or ship. The two-check
  STALL constant has no grounding; a real stalled agent may sit `in-progress` indefinitely between
  checks a human forgets to perform.
- **Severity reasoning:** misread expectations, not corruption; the docs are explicit that these are
  hints. MINOR.

## Risks

Failure modes that could fire but were not observed firing (no runtime exists to fire them); each
names the trigger.

- **R1 [BLOCKER]** — Silent merge corruption / lost edits — **fires when:** a human or agent computes
  glob-overlap wrong (O1) or declares WRITES narrower than the implementation's true footprint (O2),
  marks the pair `merge_safe: true`, and two worktrees edit the same surface; the bad merge lands in
  `main` because the merge-gate re-check (`task-orchestration.md:166`) is re-derived the same wrong
  way.
- **R2 [BLOCKER]** — Cross-spec write collision — **fires when:** two specs' decompositions run
  concurrently (permitted by `implement.md:28`) and write the same surface; neither single-spec
  conflict graph or coordination record can see the other (O9), and no cross-spec surface declaration
  exists to express the conflict (NON-GOAL D3).
- **R3 [MAJOR]** — Authority-rot via stale-but-green memory — **fires when:** a `promoted` finding's
  cited source changes, but no one re-hashes its scalar `content_hash` (no comparator, O4), so it
  stays `promoted`; a future task matches its `Load when` and builds on a dead fact.
- **R4 [MAJOR]** — Memory poisoning surviving the `validated` gate — **fires when:** a poisoned or
  credulous fact is not self-classified by the promoting agent as high-consequence/externally-authored
  (O5), or its "independent corroboration" is the same agent re-asserting it in a solo run.
- **R5 [MAJOR]** — Permanent knowledge loss at reconciliation — **fires when:** a discovery is never
  enumerated into the promotion queue (O6) and the execution packets are discarded after the ledger
  entry is written (`promotion-protocol.md:111`).
- **R6 [MAJOR]** — Over-trusted drift coverage — **fires when:** behaviour drifts through an
  undeclared read/global (O7); `drift_coverage` still reads 0% and the merge gate stays green, masking
  real divergence.
- **R7 [MAJOR]** — Stale read-models feeding wrong gate/recall decisions — **fires when:** status,
  INDEX, or ledger fall behind their sources because no tool regenerates them (O8), and a merge gate
  or future recall consults the stale projection.
- **R8 [MAJOR]** — False merge-integrity record — **fires when:** a resolver records "suite green" for
  a non-trivial semantic conflict instead of running an equivalence oracle (O10); the merge-log row
  looks compliant and the dropped intent ships.
- **R9 [MINOR]** — Silently-weakened obligation after rollback — **fires when:** a `rolled-back`
  finding's INDEX retraction is recorded but the obligation it had narrowed is not re-opened (O11).
- **R10 [MINOR]** — Misread launcher hints — **fires when:** an adopter treats `max_parallel`/`batch`/
  the STALL constant as binding safety or liveness guarantees (O12).

## Critical watch-outs for a reviewer (ranked)

1. **Re-derive every `merge_safe: true`, do not trust the plan's word (O1, O2, R1).** The entire
   write-side safety reduces to glob-overlap a human computed with no checker, and "under-declared
   WRITES" defeats the one safe default. For any parallel batch, independently compute pattern-language
   intersection of the OWNED sets — `**` spans segments — and sanity-check that each obligation's
   declared WRITES actually covers what its implementation will touch. A wrong call here is silent and
   irreversible once merged.

2. **Treat the disjointness proof as up-front-only; assume workers drifted (O3, R1).** Nothing
   observes a worker mid-run. At merge, do not assume a worker stayed inside its OWNED set — diff each
   branch against its FORBIDDEN paths explicitly. The framework concedes a diverging worker is
   "invisible state."

3. **Check whether two parallel runs span different specs (O9, R2).** The safety proof is single-spec
   and never flags this as a precondition. If concurrent decompositions touch a shared surface, no
   artifact in the framework can see the collision.

4. **Audit promoted memory for stale-but-green and poisoning (O4, O5, R3, R4).** Finding staleness is
   one scalar hash with no comparator and no exercised-surface granularity; the `validated`
   poison-gate is self-triggered by the promoting agent. Manually re-hash high-stakes findings against
   their cited sources, and reject "second finding" corroboration that is the same agent's restated
   first claim.

5. **Verify INTENT-PRESERVED-PROOF was actually run, not asserted (O10, R8).** For every non-trivial
   merge conflict, confirm a real property/differential/metamorphic oracle ran on the conflicted
   region; "suite green" is the named-insufficient answer the resolver is tempted to self-apply.

6. **Re-derive the status/INDEX/ledger projections; don't trust their `updated` stamp (O8, R7).** All
   three are hand-maintained with no regenerator; an INDEX row can read `promoted` over a withdrawn
   finding, a status can lag its traces.

7. **Probe for discoveries that never entered the promotion queue (O6, R5).** The close gate only
   resolves *queued* items; cross-check the trace/review for facts the agent noticed but never logged,
   because they vanish at reconciliation.

8. **Remember the disclosed scope limit on drift (O7, R6).** "0% drift coverage" means
   declared-surface freshness only; undeclared reads and hidden globs are unseen by construction.

9. **Confirm rollback completeness and pattern provenance (O11, R9).** A `rolled-back` finding must
   also re-open any obligation it narrowed; a pattern must cite ≥2 genuinely independent findings.

10. **Read `max_parallel`/`lane`/`batch`/STALL-threshold as non-binding hints (O12, R10).** None is a
    safety or liveness guarantee the framework ships.
