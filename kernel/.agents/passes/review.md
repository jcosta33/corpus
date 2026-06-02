# The `review` pass

> Authoritative source: 04-verification.md §14 (the merge gate) + §17 (the CONTRADICTED resolution protocol §17.4, the untrusted-source boundary §17.5, and the model-judge discipline §17.6) + 06-artifacts.md §21.5 (`review.md` / the `VERDICT` block). This is a reference projection; where it and the spec disagree, the spec governs.

`review` is the eighth of the **nine passes** of the Swarm compiler pipeline (`author -> lint -> improve -> lower -> decompose -> implement -> verify -> review -> promote`). This page is the short reference view for that single pass; the long-form contract is the spec.

Like every Swarm pass, `review` has **no runtime**: it is a contract a human, an agent following a pass guide, or a future tool performs. Nothing here is shipped code (§2, Principle 1). Every "gate", "check", or "enforcement" named below is **manual today** — a deterministic home a future harness MUST provide, never a thing Swarm runs (§17.1).

## What the pass does

The `review` pass **renders the merge-gate judgment**: it compares trace claims against the obligations they purport to satisfy, records one `VERDICT` per required proof binding, and decides — for the whole change set — whether promotion is permitted. Its single durable artifact is `review.md`, and **that artifact *is* the verdict record** (§14.5, §21.5). The kernel ships **no** `verdict.md`; a repo that records verdicts in a standalone `verdict.md` is non-conformant (§14.5).

| Aspect | Value |
|---|---|
| Phase (§the pipeline) | **REVIEW** |
| Input artifacts | `trace.md` (implementation claims), the `spec.swarm.md` obligations, recorded verification evidence (§15), diffs |
| Output artifact | `review.md` — the canonical container of `VERDICT` blocks |
| Default proof suite for the `review` task kind (§15.8) | `manual @ REVIEW` over the recorded evidence; re-run of the bound `cmd*` proofs |
| Lint layer (§14.3) | `SOL-V` (VERIFICATION) — well-formedness of verdicts |

## The verdict vocabulary it records

`review` records **verdicts**, and the verdict vocabulary is **exactly seven values**, partitioned into two disjoint roles: a verdict carries exactly **one CORE** value and **zero or more LIFECYCLE** decorators (§14.1).

The **four CORE run results** are mutually exclusive — one bound proof, on one run, lands in exactly one (§14.1.1):

| CORE | Meaning |
|---|---|
| `PASS` | A bound proof ran and its result satisfies the obligation. |
| `FAIL` | A bound proof ran and its result contradicts the obligation. |
| `BLOCKED` | A bound proof could not run (missing prerequisite, tool, adapter, environment, or fixture). The truth is *unknown*, not false. |
| `UNVERIFIED` | No acceptable proof was bound, or a binding exists but no run was attempted. |

`BLOCKED` and `UNVERIFIED` MUST NOT be conflated: `BLOCKED` is an environment fix, `UNVERIFIED` is a binding/execution gap. A reviewer who cannot tell which applies MUST record `UNVERIFIED` (the weaker, more honest claim) (§14.1.1).

The **three LIFECYCLE decorators** annotate a core value with a governance fact that arises *after* or *around* the run (§14.1.2):

| LIFECYCLE | Decorates | Mandatory fields |
|---|---|---|
| `WAIVED` | `FAIL` or `UNVERIFIED` only | authority, reason, expiry |
| `STALE` | a prior `PASS` only | prior-verdict ref, changed-surface |
| `CONTRADICTED` | any core value | two conflicting evidence refs |

`WAIVED` MUST decorate only `FAIL`/`UNVERIFIED` (there is no reason to waive a `PASS`); `STALE` MUST decorate only a prior `PASS` (a `FAIL`/`BLOCKED`/`UNVERIFIED` was never trusted, so it cannot go stale); `CONTRADICTED` MAY decorate any core, because contradiction is a relationship between *two* evidence sources (§14.1.2).

The verdict line grammar is `VERDICT <id>: <CORE> [(<lifecycle> by <authority>: <reason>)]`, with `<id>` reusing the judged obligation's surface id (`AC-001`, `C-001`, `I-001`, `IF-001`), followed by `REASON` and one or more `EVIDENCE` clauses (§14.2). A `QUESTION` is never judged; a `TRACE` is the *input* to judgment; a `VERDICT` *is* the recorded judgment (§14).

## The merge gate (the one normative predicate)

The **merge gate** is the single normative predicate that decides whether a change set may be promoted. It is evaluated over the set of **required** obligations — every `REQ`, `CONSTRAINT`, `INVARIANT`, and `INTERFACE` in scope, each with its required `VERIFY BY` bindings (§14.4).

> **Merge gate (normative, §14.4).** A change set MAY be promoted **if and only if**, for **every required `VERIFY BY` binding** of every required obligation, the binding's latest verdict is `PASS` or `WAIVED`, **and none** is `STALE`, `CONTRADICTED`, `FAIL`, `BLOCKED`, or `UNVERIFIED`. "Latest" is the verdict from the most recent recorded run for that binding.

There is **one `VERDICT` per required `VERIFY BY` binding** (§15.7): an obligation with three required bindings contributes three verdicts, and *all* must pass-or-waive. The node-level `status` is the **aggregate** over an obligation's bindings (blocking if any binding blocks, else `PASS`).

The per-value disposition under the gate (§14.4):

| Latest verdict | Disposition |
|---|---|
| `PASS` (no lifecycle) | **Passes** the gate. |
| `WAIVED` (on `FAIL`/`UNVERIFIED`, fields valid, not expired) | **Passes** the gate. |
| `FAIL` | Blocks. Fix code or amend the obligation. |
| `BLOCKED` | Blocks. Fix the environment/adapter, then re-run. |
| `UNVERIFIED` | Blocks. Bind a proof and run it, or `WAIVE`. |
| `PASS (STALE)` | Blocks. Forces the 3-way reconcile (§16.3). |
| any `(CONTRADICTED)` | Blocks. Routes to review with the stronger oracle authoritative (§17.4). |

A conformant repo MUST NOT promote while any required obligation is in a blocking disposition. Because Swarm has no runtime, this gate is enforced by a **deterministic check outside the model** when one exists (CI, a PreToolUse hook, a merge-blocking status) and is **manual today** — the spec MUST NOT claim it is automatically enforced (§14.4, §17.1).

A `WAIVED` verdict passes the gate **only while its waiver is live**: a waiver auto-expires on the next source-hash change of the waived obligation, and an expired waiver reverts to its underlying `FAIL`/`UNVERIFIED` so the gate blocks again (§14.4, §17.3). There are **no permanent waivers** (§17.3).

## Resolving a `CONTRADICTED` verdict (§17.4)

`CONTRADICTED` arises when two proofs disagree, or when a `TRACE`/code disagrees with the obligation. The `review` pass owns its resolution, which is normative (§17.4):

1. **Block at the merge gate.** A `CONTRADICTED` on any required obligation blocks promotion. Contradiction is never resolved by picking the more convenient result.
2. **Route to review.** The reviewer MUST record **both** conflicting evidence refs (the two `EVIDENCE` lines required by `SOL-V005`).
3. **The stronger oracle is authoritative pending reconciliation.** Using the fixed proof-strength order (§15.6) — `model > property | contract > test > static > manual | monitor` — the stronger proof's result is the *working assumption* while the contradiction is open. This does **not** close the contradiction; it keeps review from being paralysed. Example: a `contract` `PASS` is presumptively authoritative over a `manual` `FAIL`, but the obligation stays `CONTRADICTED` (and gate-blocking) until reconciled. **Equal-strength case:** when both proofs share a rank (two `test`s, `property` vs `contract`, `manual` vs `monitor`), neither is stronger — no working assumption is set, and the contradiction MUST NOT auto-resolve to either side; it routes to an independent reviewer or a higher-rank re-proof.
4. **Reconcile (never silently).** Reconciliation re-runs the disagreeing proofs, fixes the weaker oracle, corrects the code, or amends the obligation — the same not-silent discipline as the 3-way reconcile (§16.3). The `CONTRADICTED` decorator is removed only when both proofs agree (or one is withdrawn as invalid with a recorded reason).

> Rationale (§17.4): block-plus-stronger-oracle keeps the gate honest (no silent pick-the-pass) while keeping review actionable. Executable oracles outrank an LLM-judge `manual` verdict because judge bias is a known failure mode — an executable result is harder to fool than a narrative judgment.

Adequacy can override strength **within a recorded contradiction**: a `test` carrying strong mutation/metamorphic evidence over the disputed surface MAY be treated as authoritative over a nominally-stronger proof that exercised neither — but the override is a recorded judgment, never a silent re-rank, and never closes the contradiction on its own (§15.10.3).

## When the oracle is a model judge (§17.6)

Because Swarm ships no runtime, **every verdict today is recorded by a human or agent**, and the `review` task kind's default suite is `manual @ REVIEW` (§15.8). So the de-facto oracle for many obligations is an **LLM judge** rendering a `manual` verdict. The proof-strength order already ranks `manual`/`monitor` last (§15.6) because such judgments are fallible: judge bias is documented and directional (position/verbosity/self-preference, even at ~80% human-agreement) `[MTBENCH]`; a single judgment is not internally reliable `[TRUSTJUDGE]`; and a judge that shares lineage with the generator inflates its own kin via preference leakage `[PREFLEAK]`.

Any `manual`/judge-rendered verdict MUST satisfy all four requirements (§17.6.1). These are SOFT-control contracts today, with a deterministic home in a `review.md` schema validator / CI gate when a harness exists:

| # | Requirement | Disposition if violated (§17.6.2) |
|---|---|---|
| 1 | **Record judge identity** — the model (name + version/family) or named human, in the optional `judge` adjunct on the trace-provenance record (§16.1). | Unrecorded judge → treated as `UNVERIFIED` (joins the §15.9 non-proofs); raise a `SOL-V` judge-provenance smell. |
| 2 | **No shared lineage with the generator** — not the same model, not teacher→student inheritance, not the same model family `[PREFLEAK]`. | Verdict does not count; re-judge by an unrelated oracle. **BLOCKING.** |
| 3 | **Implementer ≠ reviewer** — the agent/human that implemented the change MUST NOT render its own `manual` verdict (self-preference hazard `[MTBENCH]`; the soft-oracle analogue of "no self-issued waiver", §17.3). | Treated as `UNVERIFIED`; require an independent reviewer. **BLOCKING.** |
| 4 | **Dual independent judgment for `RISK high`/`critical`** — two independent judges (two unrelated models, or a model plus a human), neither sharing lineage (per 2), neither the implementer (per 3) `[TRUSTJUDGE]`. | Single judgment → `UNVERIFIED` (dual owed). Judges that **disagree** → decorate `CONTRADICTED` (record the two judgments as the two evidence refs) → route through §17.4. |

> Rationale (§17.6): ranking a judgment last does nothing if the judgment is silently biased — a self-judged, same-family, single-shot `manual` `PASS` would otherwise sail through whenever no executable proof contests it. The discipline is "no astrology for agents" applied to the one oracle Swarm cannot make executable: when the oracle is a model, **name it, isolate it, and double it where the risk is highest**.

## The untrusted-source boundary the reviewer must hold (§17.5)

Every artifact `review` reads is agent-readable markdown, which is also an attack surface: the "Rules File Backdoor" hides attacker instructions in rule files via zero-width and bidirectional-control characters `[RULESBACKDOOR]`, a compromised dependency can write a malicious `AGENTS.md` `[NVIDIA-AGENTSMD]`, this class has reached RCE in a shipped agent (Cursor ≤ v1.7, CVSS 3.1 base 8.8 HIGH) `[CVE-2025-61592]`, and prompt injection — including the indirect, file-borne variant — is the #1 LLM risk `[OWASP-LLM01]`. Consistent with §17.1, none of the controls below is shipped tooling; each is a contract a future harness builds against and is **manual today**.

- **Non-printing-character rejection (`SOL-S013`, HARD lane, §17.5.1).** A SYNTAX-layer diagnostic REJECTS any agent-read artifact containing zero-width, bidirectional-control, other non-printing control characters (outside `\t`/`\n`), or homoglyph-suspect mixed-script identifiers. Because the check is purely lexical it sits in the **HARD/deterministic lane**; it is **BLOCKING** and its eventual home is a PreToolUse hook or CI gate. Resolution: strip the offending codepoints or re-author in printable characters.
- **Source-authority rule for externally-authored sources (SOFT/governance, §17.5.2).** An `audit.md`/`research.md`/`bug-report.md` whose provenance lies **outside the repo trust boundary** MUST be flagged approval-required and **never auto-promotable**. An external source carries the *lowest* applicable source authority and MUST NOT silently amend an approved `spec.swarm.md` (a lower-ranked actor amending a higher-ranked artifact is `SOL-M002`). A source whose provenance cannot be established as in-boundary is treated as external by default. This composes with `SOL-S013`: the lexical check cleans the *bytes*, the source-authority rule governs the *trust* of the source those bytes came from.

## The `review.md` artifact (§21.5)

`review.md` IS the verdict record — the canonical container of `VERDICT` blocks (§14.5, §21.5.1). A conformant `review.md` MUST contain:

| Section | Meaning |
|---|---|
| frontmatter | `type: review`, `id`, `source_trace`, `source_spec`, `reviewed_output`, `pass`, `profile` (e.g. `skeptic`), `created`. |
| `## Per-obligation verdicts` | One `VERDICT` block per judged obligation, using the canonical verdict line plus `REASON`/`EVIDENCE`. |
| `## Obligation-verdict matrix` | A compact table: obligation id → core → lifecycle → evidence checked. |
| `## Constraint and invariant verdicts` | The same, for `C-` and `I-` ids. |
| `## Unauthorized changes` | Every change not traceable to an authorizing obligation, judged allowed / suspect / reject. |
| `## Final verdict` | The merge-gate result at the change-set level (PASS / BLOCKED). |
| `## Promotion queue` | Items to promote, with target + status. |

Three lint floors the reviewer enforces by hand or via the `lint-spec` pass today (`SOL-V` layer, §14.3): a non-`PASS/FAIL/BLOCKED/UNVERIFIED` core or a lifecycle missing its mandatory fields is `SOL-V005` (BLOCKING); a misplaced `WAIVED`/`STALE` is `SOL-V007` (BLOCKING); a required obligation with no `VERDICT` at the gate is `SOL-V008` (BLOCKING, and counts as `UNVERIFIED`). A `WAIVED` MUST name authority + reason + expiry; a `STALE` MUST cite the prior-verdict ref + changed surface; a `CONTRADICTED` MUST cite the two conflicting evidence refs (§14.3, §21.5.1).

What `review` MUST reject as a non-proof (never `PASS`, §15.9): schema-valid output (shape is not truth), "tests passed" with no command/exit-code/output, and a `manual` verdict with no recorded reasoning.

## Preserved / Dropped / Still-uncertain

**Preserved** (projected faithfully from the named sections):

- The seven-value verdict model (4 core + 3 lifecycle), the decoration rules, and the `VERDICT <id>: <CORE> [(lifecycle …)]` line grammar (§14.1–§14.2).
- The full merge-gate predicate and its per-value disposition table, one-verdict-per-binding, node-level aggregate status, and "manual today / deterministic-home-when-it-exists" framing (§14.4, §15.7).
- The four-step `CONTRADICTED` resolution protocol including the equal-strength case and the not-silent reconcile, with the proof-strength order it depends on (§17.4, §15.6).
- The four model-judge requirements and their lint dispositions, with the empirical rationale `[MTBENCH]`/`[TRUSTJUDGE]`/`[PREFLEAK]` (§17.6).
- The untrusted-source boundary: the `SOL-S013` HARD lexical check and the SOFT source-authority rule, with their threat citations (§17.5).
- The `review.md` contract: required frontmatter and sections, and the `SOL-V005`/`V007`/`V008` lint floors plus the lifecycle field requirements (§21.5, §14.3).

**Dropped** (out of scope for this single-pass projection; lives in the spec):

- The full proof taxonomy and `VERIFY BY` binding syntax, the two-layer `AGENTS.md` adapter resolution, type-selection rules, and per-task default suites — §15 (referenced here only where the gate and tie-break need them).
- Drift and staleness mechanics in full: the trace-provenance schema, the staleness rule, the 3-way reconcile, drift coverage, proof-exercised staleness, and surface policies — §16 (referenced only as the destination of a `PASS (STALE)`).
- The wider soft/hard control boundary, the enforcement-lane artifact (G4), and the WAIVER lifecycle beyond what the gate consumes — §17.1–§17.3.
- The `review.md` template body, and the other artifact contracts (`spec`, `task`, `trace`, `finding`, `adr`, memory) — the rest of §21.

**Still-uncertain** (the spec governs; not pinned here):

- Whether `review` gains or keeps a stdlib pass guide profile beyond `review[profile: skeptic]` — the pass-guide inventory lives in §9 / §26, outside the named sources.
- The exact `review.md` schema-validator shape that will become the deterministic home for the `SOL-V` and §17.6 checks — the spec fixes the contract, not the validator (§17.1, §17.6.1).
- How `adequacy_evidence` overrides (§15.10.3) interact with a specific contradiction in practice — the spec states the rule; the reviewer's recorded reasoning supplies the per-case application.
