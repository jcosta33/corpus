# The `review` pass

`review` is the eighth of the **nine passes** of the Swarm compiler pipeline (`author -> lint -> improve -> lower -> decompose -> implement -> verify -> review -> promote`). This file is the working contract for that single pass: the merge gate (§14), the `CONTRADICTED` resolution protocol (§17.4), the untrusted-source boundary (§17.5), the model-judge discipline (§17.6), and the `review.md` artifact (§21.5).

Like every Swarm pass, `review` has **no runtime**: it is a contract a human, an agent following a pass guide, or a future tool performs. Nothing here is shipped code (§2, Principle 1). Every "gate", "check", or "enforcement" named below is **manual today** — a deterministic home a future harness MUST provide, never a thing Swarm runs (§17.1).

## What the pass does

The `review` pass **renders the merge-gate judgment**: it compares trace claims against the obligations they purport to satisfy, records one `VERDICT` per required proof binding, and decides — for the whole change set — whether promotion is permitted. Its single durable artifact is `review.md`, and **that artifact *is* the verdict record** (§14.5, §21.5). The kernel ships **no** `verdict.md`; a repo that records verdicts in a standalone `verdict.md` is non-conformant (§14.5).

| Aspect | Value |
|---|---|
| Phase (§the pipeline) | **REVIEW** |
| Input artifacts | `trace.md` (implementation claims), the `spec.swarm.md` obligations, recorded verification evidence (§15), diffs |
| Output artifact | `review.md` — the canonical container of `VERDICT` blocks |
| Default proof suite for the `review` task kind (§15.8) | `manual @ REVIEW` over the recorded evidence; re-run of the bound `cmd*` proofs |
| Lint layer (§14.3) | `SOL-V` (VERIFICATION) — well-formedness of verdicts (see ../passes/lint.md) |

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

Because Swarm ships no runtime, **every verdict today is recorded by a human or agent**, and the `review` task kind's default suite is `manual @ REVIEW` (§15.8). So the de-facto oracle for many obligations is an **LLM judge** rendering a `manual` verdict. The proof-strength order already ranks `manual`/`monitor` last (§15.6) because such judgments are fallible: judge bias is documented and directional (position, verbosity, and self-preference effects persist even when a judge agrees with humans most of the time); a single judgment is not internally reliable; and a judge that shares lineage with the generator inflates its own kin via preference leakage.

Any `manual`/judge-rendered verdict MUST satisfy all four requirements (§17.6.1). These are SOFT-control contracts today, with a deterministic home in a `review.md` schema validator / CI gate when a harness exists:

| # | Requirement | Disposition if violated (§17.6.2) |
|---|---|---|
| 1 | **Record judge identity** — the model (name + version/family) or named human, in the optional `judge` adjunct on the trace-provenance record (§16.1). | Unrecorded judge → treated as `UNVERIFIED` (joins the §15.9 non-proofs); raise a `SOL-V` judge-provenance smell. |
| 2 | **No shared lineage with the generator** — not the same model, not teacher→student inheritance, not the same model family (preference leakage). | Verdict does not count; re-judge by an unrelated oracle. **BLOCKING.** |
| 3 | **Implementer ≠ reviewer** — the agent/human that implemented the change MUST NOT render its own `manual` verdict (self-preference hazard; the soft-oracle analogue of "no self-issued waiver", §17.3). | Treated as `UNVERIFIED`; require an independent reviewer. **BLOCKING.** |
| 4 | **Dual independent judgment for `RISK high`/`critical`** — two independent judges (two unrelated models, or a model plus a human), neither sharing lineage (per 2), neither the implementer (per 3). | Single judgment → `UNVERIFIED` (dual owed). Judges that **disagree** → decorate `CONTRADICTED` (record the two judgments as the two evidence refs) → route through §17.4. |

> Rationale (§17.6): ranking a judgment last does nothing if the judgment is silently biased — a self-judged, same-family, single-shot `manual` `PASS` would otherwise sail through whenever no executable proof contests it. The discipline is "no astrology for agents" applied to the one oracle Swarm cannot make executable: when the oracle is a model, **name it, isolate it, and double it where the risk is highest**.

## The untrusted-source boundary the reviewer must hold (§17.5)

Every artifact `review` reads is agent-readable markdown, which is also an attack surface: a "rules file backdoor" can hide attacker instructions in rule files via zero-width and bidirectional-control characters, a compromised dependency can write a malicious `AGENTS.md`, this class of attack has reached remote code execution in shipped coding agents, and indirect, file-borne prompt injection is a leading LLM risk. Consistent with §17.1, none of the controls below is shipped tooling; each is a contract a future harness builds against and is **manual today**.

- **Non-printing-character rejection (`SOL-S013`, HARD lane, §17.5.1).** A SYNTAX-layer diagnostic REJECTS any agent-read artifact containing zero-width, bidirectional-control, other non-printing control characters (outside `\t`/`\n`), or homoglyph-suspect mixed-script identifiers. Because the check is purely lexical it sits in the **HARD/deterministic lane**; it is **BLOCKING** and its eventual home is a PreToolUse hook or CI gate. Resolution: strip the offending codepoints or re-author in printable characters.
- **Source-authority rule for externally-authored sources (SOFT/governance, §17.5.2).** An `audit.md`/`research.md`/`bug-report.md` whose provenance lies **outside the repo trust boundary** MUST be flagged approval-required and **never auto-promotable**. An external source carries the *lowest* applicable source authority and MUST NOT silently amend an approved `spec.swarm.md` (a lower-ranked actor amending a higher-ranked artifact is `SOL-M004`). A source whose provenance cannot be established as in-boundary is treated as external by default. This composes with `SOL-S013`: the lexical check cleans the *bytes*, the source-authority rule governs the *trust* of the source those bytes came from.

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

## Related

Sibling payload files that `review` reads from, writes to, or hands off to:

- `../passes/verify.md` — the pass that records the verification evidence (§15) `review` judges.
- `../passes/implement.md` — produces the `trace.md` claims that are the input to judgment.
- `../passes/promote.md` — the ninth pass, gated by the merge-gate result `review` renders.
- `../passes/lint.md` — the `SOL-V` / `SOL-S` / `SOL-M` lint floors the reviewer enforces (`SOL-V005`/`V007`/`V008`, `SOL-S013`, `SOL-M002`).
- `../templates/review.md` — the `review.md` artifact template (frontmatter + sections enumerated above).
- `../templates/trace.md`, `../templates/spec.swarm.md` — the input artifacts the verdicts are bound against.
- `../templates/audit.md`, `../templates/research.md`, `../templates/bug-report.md` — externally-authorable sources governed by the source-authority rule (§17.5.2).
- `../skills/persona-skeptic/SKILL.md` — the profile `review` runs under (`review[profile: skeptic]`).
