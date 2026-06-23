---
type: adr
id: adr-0086
status: accepted
created: 2026-06-19
updated: 2026-06-19
---

# ADR-0086 — Deterministic review scanning is the shipped reconcile wedge: accept C014, gate the measurement track, reject the off-boundary asks

## Context

Two strategy reports proposed making "deterministic review scanning" — a git-diff/risk reconciler that
reads the task/spec/change-plan, reads the diff, and enriches the review with evidence gaps and
human-attention items — a major new direction for the Corpus CLI. Examined against the code, the proposed
heart of that capability **already ships**: `swarm review` reconciles, on a verdict-free report (ADR-0077
Decision 8), coverage (C012), verify-evidence binding (C013), scope divergence, the run-summary↔diff
self-report mismatch (both directions), empty-evidence Pass rows, and the packet-structural facts. So the
reports are mostly a **decision, measurement, and positioning** agenda, not a build list. This ADR records
what to accept, defer, reject, and correct.

Two findings shape the decision.

**The differentiation must be re-grounded, not retracted.** The competitive landscape moved: AI review tools
now ship requirement-binding. CodeRabbit validates a PR against the acceptance criteria of a linked Jira or
Linear issue and writes the assessment back to the ticket [[CODERABBIT-PRVAL]](../research/sources.md#CODERABBIT-PRVAL);
Qodo Merge's Ticket Compliance Agent fetches ticket context, reports "missing acceptance criteria" and a
Fully/Partially/Not-compliant level, and markets scope-creep prevention and audit-ready evidence
[[QODO]](../research/sources.md#QODO). "No tool binds evidence to requirements" is therefore false. What
stays distinct — the *form* Corpus's differentiation leads with — is: Corpus's reconciliation is
**deterministic** (no model, reproducible, exit-coded 0/1/2), keyed to a **local structured spec/task
packet** (not a remote tracker ticket), **verdict-free** (the human owns Pass/Fail/Unverified/Blocked,
ADR-0077 D8), and **durable in git** (a persisted, independent review packet, not an ephemeral PR comment).

**A precision target the reports got wrong.** The proposal stakes success on keeping false-positive
human-attention items "under 30%." Google's field experience sets the bar far tighter: a code-review-time
check must "produce less than 10% effective false positives," where an issue is an *effective* false positive
"if developers did not take some positive action after seeing the issue" — technical correctness is
secondary to whether the developer acted [[GOOGLESA]](../research/sources.md#GOOGLESA). A 30% rate is three
times the documented abandonment threshold; on the strongest available evidence it would get the check
`--no-verify`'d into irrelevance — the same noisy-check death spiral the SMELLS-precision rule already keeps
fuzzy checks at *warning* to avoid (ADR-0083).

## Decision

Six points. Each carries its honesty level (ADR-0063).

1. **Name the wedge — positioning, not a build.** "Deterministic review scanning" is the already-shipped
   reconcile capability of `swarm review`, not a new subsystem. Its differentiation is the four-property
   form above: **deterministic · local-spec/task-keyed · verdict-free · git-durable**. *Level: convention
   (positioning).*

2. **ACCEPT C014 `do-not-change-touched`** (warning). A changed file matching a task packet's `## Do not
   change` entry is surfaced as a protected-path fact routed to Human attention. This closes a verified gap:
   `## Do not change` is a required task-packet section, but nothing reads it — a touched protected file is
   caught today only indirectly via `outsideScope`, which misses a protected file that lies *inside* the
   declared Affected areas. The match is closed-value (an exact path/prefix compare, the same matcher and
   `{{placeholder}}`-skip as Affected areas); the *intent* is human (whether the touch was justified is the
   reviewer's call, ADR-0077 D8), so it ships at **warning**, the same fact-class and severity as
   `outsideScope`, with a recorded path to promote once field-tested (the ADR-0079/0083 conservative
   precedent). *Level: toolable.* Detailed in Propagation.

3. **ACCEPT the measurement track as the gating next investment.** A review-gate benchmark — precision *and*
   recall on a seeded corpus of scope-drift, do-not-change-touch, and claim-vs-diff cases — is the next
   investment, and it doubles as the real-world test of the `swarm review --json` surface the MCP adapter
   consumes (ADR-0085). It is recorded here as committed-next; it is a program, cut as its own swarm-hq spec,
   not built by this ADR. *Level: convention.*

4. **DEFER behind a measure-first gate** (each earns a build only once the benchmark shows the review gate
   catches real failures at ≤10% effective false positives): SARIF 2.1.0 (a ratified OASIS standard
   [[SARIF]](../research/sources.md#SARIF)) / JUnit XML (a de-facto test-results format) import-and-correlate
   (the future shape is *route-and-correlate-against-scope*, never re-implement an analyzer); a mechanical risky-path matcher
   (the trigger taxonomy already ships as the `trigger-coverage` human-attention checklist — mechanizing it
   moves a rule from checklist to toolable, exactly the precision-minefield the gate must clear first); and
   project-policy config (which, if built, reuses the existing `.swarm/config.yaml` home, not a parallel
   file). Deferred, not rejected.

5. **REJECT as non-goals.**
   - **`swarm verify` executing the project's commands.** Running build/test commands crosses the ADR-0077
     D8 reconcile-only boundary ("never the sandbox/container runtime") and strains swarm-cli's deliberate
     two-dependency footprint (ADR-0085). Capturing *already-run* evidence (the pasted output C013 reads) is
     in-bounds; swarm-cli *spawning* the commands is not. If ever wanted, it belongs in a `swarm-*` PATH
     plugin (ADR-0077 D3), never the core.
   - **Per-language analysis adapters.** Eight ecosystem toolchains as dependencies invert swarm-cli from a
     markdown reconciler into a polyglot analyzer — the "static analyzer" the reports themselves disclaim —
     and re-introduce the architecture-enforcement bet the validated direction refuted. The recorded answer
     is BYO: a team binds its own analyzers via its own gate; swarm-cli reconciles only.
   - **A rival `SCOPE-/EVIDENCE-/RISK-/CHANGE-/REVIEW-` check-ID namespace.** The proposed scheme re-labels
     facts the C0xx contract already emits (scope drift = `scopeDivergence`/`outsideScope`; empty-evidence
     Pass = `emptyEvidencePassRows`; change-plan = C010/C011; packet structure = `packetStructural`). A
     parallel namespace forks the single, drift-guarded contract id space. Any genuinely new fact extends the
     C0xx series (as C014 does), never a rival scheme.
   - **A standalone `swarm scan` verb.** The "deterministic facts, no execution, no verdict" contract it
     promises *is* the shipped `swarm review`. A second verb splits one reconcile surface into two; net-new
     diff facts land inside `swarm review`.
   - **An "Agent Work Protocol" category coinage.** The term is unused in the market (the buyer-facing term
     is "spec-driven development"), "Protocol" already names interop wire-formats (MCP, ACP) Corpus does not
     ship, and no user-facing doc carries it today. Corpus keeps its shipped identity — "a lightweight spec
     and review workflow for teams using coding agents" — sharpened on the *reviewable-evidence* angle, not a
     new noun.

6. **CORRECT the precision target.** The benchmark (Decision 3) measures against **≤10% effective false
   positives** [[GOOGLESA]](../research/sources.md#GOOGLESA), adopting the "no positive action taken"
   definition as the metric, not the reports' <30%. Recall (of seeded failures, how many the gate surfaces)
   is measured alongside, but precision is first: recall pressure never promotes a fuzzy check to hard error
   (the ADR-0083 split holds — closed-value/git-fact checks may earn hard error; prose-shaped checks stay
   warnings).

## Alternatives considered

| Alternative | Why weaker |
|---|---|
| **Build the reports' L1 contract-reconciliation layer** | It already ships in `reconcileReview.ts` (coverage, verifyBinding, scopeDivergence, selfReport, emptyEvidencePassRows, packetStructural). Building it again duplicates the engine. Rejected. |
| **Adopt the reports' new check-ID namespace** | Forks the single C0xx contract and re-labels shipped facts under a rival scheme (Decision 5). Rejected. |
| **Fold do-not-change into C012 or leave it to `outsideScope`** | C012 is an id-set coverage reconcile, a different fact class (the same separation ADR-0083 drew for C013 vs C012); `outsideScope` misses a protected file *inside* Affected areas. A clean C014 keeps the cite clarity and the distinct fact. Rejected. |
| **Build `swarm verify` / language adapters / SARIF import now** | Crosses the reconcile-only boundary and/or the two-dependency footprint, or front-loads a deferred layer before the measure gate (Decisions 4–5). Rejected/deferred. |
| **Accept the reports' <30% false-positive target** | Three times Google's field-validated ≤10% effective-FP abandonment threshold [[GOOGLESA]]; a 30%-noise check gets ignored. Rejected (Decision 6). |
| **Adopt "Agent Work Protocol" as the category** | An unused coinage that collides with MCP/ACP and contradicts the shipped tagline (Decision 5). Rejected. |

## Consequences

Accepted. C014 is the one new check this ADR mints; everything else is a positioning correction, a recorded
deferral, or a recorded non-goal. The reconcile-only boundary (ADR-0077 D8) and the two-dependency footprint
(ADR-0085) are reaffirmed: C014 surfaces a fact routed to Human attention, never a verdict, and adds no
dependency.

Honesty level: C014 is **toolable** — a future `swarm review`/`swarm check` surfaces it; until a team wires
its CI to that output, nothing is **enforced** (the gate is the team's, never Corpus's, ADR-0063). The
positioning narrowing (Decision 1) is a convention; the differentiation prose is corrected, not enforced.

Positive: the review wedge gains one clean, deterministic, in-boundary fact; the strategy is re-grounded
honestly against incumbents that now ship requirement-binding; the precision bar is set to the evidence, not
a guess. Negative: a second scope-related fact to teach beside `outsideScope`; a contract-version bump.
Neutral: a team may treat the C014 warning as blocking by its own CI policy — the team's gate, not Corpus's.

This refines ADR-0077 (D7 names deterministic review scanning as one of the two wedges; this names it as the
*shipped* one and holds D8's verdict-free boundary for C014). It builds on ADR-0079 (C012) and ADR-0083
(C013) for the conservative-shipping + coordinated-landing pattern, and relates to the evidence-validated
direction recorded in the swarm-hq workspace (the review-gate-teeth + measure-first track).

## Propagation

The C014 mint lands **coordinated** (the ADR-0079/0083 rule: the `checks.yaml` rule + version bump ship
*with* the swarm-cli implementation, so the drift guard never reds between commits). Docs-first
single-sourcing: the human-readable contract and this ADR land first; the `checks.yaml` data + the CLI move
in lockstep.

- **The C-id mint — C014 `do-not-change-touched`** (warning): a new row in `checks/checks.yaml` and its
  definition in `reference/checks.md` (the core-checks table + the Warning row of the severity split) and
  the one-liner in `reference/cheatsheet.md`. A V17 violation fixture under `checks/fixtures/`. Core C-ids
  are not a registered cardinality, so no closed-set count moves.
- **The contract version bump — `0.6.0 → 0.7.0`** in `checks.yaml`, moved in lockstep with swarm-cli's
  pinned `CONTRACT_VERSION` so the drift-guard test never reds in between.
- **The swarm-cli build.** `parseTaskPacket` gains a `## Do not change` reader (sharing the Affected-areas
  extraction, including the `{{placeholder}}` skip); `reconcileFacts` gains a `do_not_change_touched` fact
  (matched per-entry, so an empty Do-not-change list surfaces nothing); `reconcileReview` threads
  `doNotChangeTouched` onto the verdict-free `ReviewReport` and into the warning level; the human-attention
  render gains its bullet. Fixtures add the do-not-change-touch case (incl. the file that is *inside*
  Affected areas yet still protected). swarm-mcp's `ReviewReportSchema` may mirror the new field additively
  (safe against its drift tripwire; not required).
- **The differentiation prose** narrows onto the four properties in `README.md` (the neighbor map).
  ADR-0060's gap claim — a *persisted, independent, exception-routing* review packet — is already correctly
  scoped (it never claimed nobody binds evidence to requirements), so it stays as recorded; this ADR
  sharpens it forward rather than rewriting it (the ADR ledger is append-only). The research bibliography
  gains the verified entries cited above ([[GOOGLESA]](../research/sources.md#GOOGLESA),
  [[CODERABBIT-PRVAL]](../research/sources.md#CODERABBIT-PRVAL), [[QODO]](../research/sources.md#QODO),
  [[SARIF]](../research/sources.md#SARIF)).
- **The measurement track and every deferred layer (Decisions 3–4)** are FUTURE — cut as their own swarm-hq
  specs, gated on the benchmark. This ADR builds none of them.

Refines ADR-0077 (D7/D8); builds on ADR-0079, ADR-0083; honors ADR-0063 (honesty levels) and ADR-0060 (the
differentiation answer it sharpens). Does not re-open the spec-scoped-id question (closed by ADR-0080).
