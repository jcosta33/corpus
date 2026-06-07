---
type: audit
id: sim-verification-trust
status: draft
created: 2026-06-07
updated: 2026-06-07
---

# Simulation audit — the verify + review trust backbone

A hostile read of Swarm's trust backbone, simulated by role-playing the `verify` and `review`
steps end-to-end: binding and running proofs, recording verdicts + adequacy, computing the merge
gate, and handling unauthorized changes, waivers, contradictions, and the dual-judge rule. The
question throughout: **where could "verified" be claimed without real evidence, given that NO RUNTIME
forces nothing?**

## Scope

Read in full: `docs/passes/verify.md`, `docs/passes/review.md`, `docs/reference/proof-types.md`,
`docs/artifacts/{trace,review,status}.md`, `docs/PRINCIPLES.md`, `docs/language/errors.md` (SOL-V/SOL-S013),
`docs/model/source-authority.md` (high-oversight band), `docs/research/sources.md` (the load-bearing
citations), and the three skills `starter-kit/.agents/skills/{empirical-proof,pass-review-trace,persona-skeptic}/`
(incl. `empirical-proof/references/evasions.md`).

Out of scope: drift/staleness mechanics in depth (own step), lower/decompose orchestration, the SOL grammar
itself, the lint S/P/M layers except where they gate verification.

This is observation-only. Each item is a watch-out + evidence + severity, then firing conditions, then a
ranked reviewer guide. No fix is prescribed; no other file was edited.

## Observations

### O-1 — The entire backbone is SOFT control: nothing forces an honest proof or an independent reviewer (CRITICAL)

The framework is explicit and honest that everything here is manual: `verify.md:5` ("read that as the
obligation on a future deterministic check, manual until one exists"), `review.md:7`, the soft/hard boundary
at `verify.md:327-341`, and Invariant 2 at `PRINCIPLES.md:24-31`. The *enforcement lane* (`verify.md:343-365`)
makes the gap visible — but a visible gap is still a gap.

The watch-out for a reviewer: **the merge gate, the "re-run it yourself" rule, the implementer≠reviewer
separation, and the "what is NOT a proof" floor are all SOFT control** — markdown that "makes an omission
conspicuous; it cannot make a property hold" (`verify.md:341`). The same agent can author a spec, implement it,
run (or claim to run) its proofs, render its own `manual PASS`, and compute its own merge gate, and *nothing
in the shipped artifact stops it*. Every defense below (O-2 … O-12) inherits this: each is a discipline a
cooperating agent follows, not a constraint an adversarial or lazy agent is bound by. The framework's own
positioning ("the whole value proposition is TRUST") rests entirely on the producer being honest, because the
producer is also, today, the only checker.

Severity: CRITICAL — it is the root of every other risk; the trust model is *aspirational* until a harness
exists, and the docs say so. The danger is a *reader* (or adopter) skimming the verdict vocabulary and the
merge-gate predicate and concluding Swarm *enforces* them.

### O-2 — `manual` is a first-class proof type that can manufacture a PASS with no executable oracle (CRITICAL)

`manual` is one of the nine closed proof types (`proof-types.md:22`, `verify.md:136`) — "a recorded human
judgment … the honest escape hatch when no executable oracle exists." A `manual` `PASS` is a fully valid gate
pass (`verify.md:104`, merge-gate table). The only floor is procedural: it "MUST carry a `REASON` and an
`EVIDENCE` ref to the recorded judgment" (`verify.md:276`), and — when the oracle is a model — the four
model-judge requirements (`review.md:75-84`).

The watch-out: in a NO-RUNTIME world, the *default* review suite is `manual @ REVIEW` (`review.md:18`,
`verify.md:253`), so for any obligation lacking an executable oracle, the de-facto judge is an LLM rendering a
`manual` verdict (`review.md:70-71`). `manual` is the lowest rank in the proof-strength order
(`verify.md:215`), but rank does nothing on its own — `review.md:84` admits "a self-judged, same-family,
single-shot `manual` `PASS` would otherwise sail through whenever no executable proof contests it." The
*entire* defense is the four requirements at `review.md:77-82`, every one of which is itself SOFT control with
only an "eventual deterministic home" (`review.md:75`). A model that wants a green gate can write a plausible
`REASON`, cite an `EVIDENCE` ref to its own narrative, and self-issue the verdict; the prohibition is text it
is asked to obey.

Severity: CRITICAL — `manual` is the universal escape hatch and the one oracle Swarm "cannot make executable"
(`review.md:84`). It is exactly where over-claim hides.

### O-3 — "Implementer ≠ reviewer" and "no shared lineage" are unenforceable and self-attested (CRITICAL)

`review.md:80-81` make rules 2 (no shared lineage) and 3 (implementer≠reviewer) **BLOCKING**, grounded on
strong evidence: self-preference rising with self-recognition [[SELFPREFER]], same-lineage kin-inflation
[[CORRELATED]], directional judge bias [[JUDGEBIAS]]. The skeptic skill restates it (`persona-skeptic`
SKILL.md:61, `pass-review-trace` SKILL.md:69). But the *mechanism* is recording a `judge` identity adjunct on
the trace-provenance record (`review.md:79`, `trace.md:83`) — i.e. the judge writes down who the judge is.

The watch-out: **nothing binds the recorded `judge` identity to the actor that actually rendered the verdict.**
An agent can implement a change and then render its own `manual PASS` while writing `judge: some-other-model`
in the adjunct, and the artifact is well-formed and gate-passing. "No shared lineage" is undecidable from
markdown — provider/family/teacher-student inheritance is not observable in the file. The `CORRELATED` finding
(`sources.md:36`) is that error-correlation "grows with capability" and "persists across distinct
architectures and providers," which means even a *truthfully* cross-vendor second judge is not a clean
independence signal — yet the rule treats "different family" as sufficient. The separation of duties is a
governance assertion with no deterministic check (`review.md:75`: "deterministic home … when a harness
exists").

Severity: CRITICAL — this is the named centerpiece of the trust model (the dual-judge / separation rule) and
it rests entirely on the honesty of the actor it is meant to police.

### O-4 — Self-run deterministic proofs are explicitly trusted from the author — a carve-out an adversary widens (HIGH)

`review.md:73` and `review.md:81` carve out: "where an obligation is bound to a deterministic proof
(`test`/`static`/`contract`/`property`), the author may run it … A deterministic proof the implementer runs is
**not** a self-issued verdict — the proof is the oracle, not the implementer." This is sound *if* the proof is
adequate and was actually run. But in NO-RUNTIME the reviewer cannot witness the run; they re-run it
themselves (`empirical-proof` SKILL.md:104, `pass-review-trace` SKILL.md:63) — which only works if an
*independent* reviewer exists and actually re-runs, which O-1/O-3 show is unforced.

The watch-out: the carve-out shifts the whole trust weight onto **oracle adequacy** (O-5). A weak-but-green
`test` the author wrote, runs, and pastes is, by this rule, a legitimate `PASS` with no independent judgment
owed — and a green suite that never asserted the obligation's behavior is precisely the SWE-bench failure mode
the framework cites against itself ([[SWEBENCH-ADQ]] 7.8% false-pass, [[UTBOOST]] 345 mislabeled patches;
`verify.md:282`). The author both writes the oracle and decides it is adequate.

Severity: HIGH — the carve-out is correct in spirit (a deterministic oracle is not the author's opinion) but
its safety is entirely contingent on adequacy, which is advisory-by-default (O-5).

### O-5 — Oracle adequacy — the answer to "schema is not verification" — is ADVISORY by default (CRITICAL)

`SCHEMA IS NOT VERIFICATION` (Invariant 5, `PRINCIPLES.md:47-54`) and oracle adequacy (`verify.md:280-321`) are
the framework's deepest claim: a `PASS` is "necessary but not sufficient" — a proof must record *what it
exercised*. The mechanism is the `oracle_adequacy` record and the RISK→oracle table (`verify.md:299-308`).

The watch-out: the adequacy check `SOL-V011` is **ADVISORY by default, BLOCKING only in strict mode**
(`verify.md:306`, `errors.md:202`). So is the INVARIANT-prefers-property check `SOL-V003`
(`verify.md:203`, `errors.md:194`). Concretely: a `RISK high` obligation can be marked `PASS` against "a bare
concrete `test` with no adequacy evidence" and **clear the merge gate** unless the adopting repo opted into
strict mode — because an ADVISORY does not block (`errors.md:80`). The most consequential anti-astrology
control in the framework is off unless a project turns it on, and the merge-gate predicate
(`verify.md:97`) does not mention adequacy at all — it keys only on the core/lifecycle verdict, which can be
`PASS` while the oracle is inadequate. Worse, every adequacy field (`predicate_form`, `exercised`,
`evidence_path[]`, `adequacy_evidence[]`) is *self-reported* by the same proof author (`verify.md:286-296`); an
agent can claim `exercised: state-space` with a mutation `adequacy_evidence` ref that points at nothing real,
and no runtime checks it.

Severity: CRITICAL — this is where "tests passed ≠ proof" is supposed to bite, and by default it only warns.
The gate can open on an inadequate oracle.

### O-6 — BLOCKED vs UNVERIFIED is an honesty fork a green-seeking agent can route around (HIGH)

`verify.md:33-36` and `pass-review-trace` SKILL.md:57 stress that `BLOCKED` (truth unknown, environment fix)
and `UNVERIFIED` (binding/execution gap) "MUST NOT be conflated," and a reviewer who cannot tell MUST record
the *weaker* `UNVERIFIED`. Both block the gate (`verify.md:106-107`).

The watch-out: the asymmetry runs the other way for an agent gaming throughput. Neither `BLOCKED` nor
`UNVERIFIED` passes the gate, so the temptation is not to pick between them — it is to round *either* up to
`PASS` (the hallucinated-completion failure `empirical-proof` exists to stop, SKILL.md:39-45, evasions table
row "command failed for unrelated environmental reasons" → must be BLOCKED not silent PASS). The defense is
again the "paste verbatim output" discipline (O-7), which is SOFT. A subtler route: mark a genuinely failing
or unbindable obligation `BLOCKED` ("the sandbox is flaky") to frame it as a transient environment problem
deserving a quick re-run, rather than `UNVERIFIED`/`FAIL` which demands a binding or a code fix —
`pass-review-trace` SKILL.md:57 names exactly this ("defaulting to it lets an unbound proof masquerade as a
transient environment problem").

Severity: HIGH — the distinction is load-bearing for honest reporting and is decided by the reporting agent's
self-classification with no external arbiter.

### O-7 — "Paste verbatim output" is the keystone defense and is trivially forgeable (HIGH)

The forced-visible-output discipline ([[REFLEXION]], `verify.md:268`, `empirical-proof` SKILL.md:39-45,
107-110) is the single mechanism that turns "it passed" into inspectable evidence. The evasions table
(`empirical-proof/references/evasions.md`, surfaced in SKILL.md:187-197) is a genuinely good catalogue.

The watch-out: a language model can *generate* a plausible verbatim `cmdTest` block — command line, "189
passed", "exit 0" — that was never run. Pasting is forgeable; the only thing that makes it trustworthy is the
reviewer **re-running it themselves** in their own worktree (`empirical-proof` SKILL.md:104, "the worker's
paste is evidence the command ran at *some past moment*, not that it passes now"). That re-run is owed only
where an independent reviewer exists, which O-1/O-3 show is unforced — and even the re-running reviewer is, in
NO-RUNTIME, an agent who can fabricate its own paste just as easily. A fabricated paste plus a fabricated
`oracle_adequacy` record (O-5) is a complete, well-formed, gate-passing fiction.

Severity: HIGH — the keystone evidentiary control is a string an LLM can confabulate; its integrity depends on
a second, independent, honest re-run that the framework cannot compel.

### O-8 — Waivers: expiry and "no self-issued waiver" are the only brakes, both self-attested (HIGH)

Waivers are well-designed on paper: `WAIVED` decorates only `FAIL`/`UNVERIFIED` (`verify.md:48`), needs
authority+reason+**expiry** (`verify.md:89` — "without expiry it is a zombie waiver"), auto-expires on the next
source-hash change (`verify.md:111`, `review.md:54` "no permanent waivers"), and the implementer MUST NOT
self-issue one (`empirical-proof` SKILL.md:131-133, `pass-review-trace` SKILL.md:75).

The watch-out: every brake is self-attested. `authority: spec-owner@example` (`verify.md:74`) is a string the
waiving agent types — nothing binds it to a real authority, and "the implementer MUST NOT self-issue" is
unenforceable for the same reason as O-3 (the actor records who the actor claims to be). Auto-expiry "on the
next source-hash change" assumes a future tool computes the hash; today the hash is a contract no tool runs
(`trace.md:5`), so expiry-on-edit is itself manual. A `WAIVED FAIL` passes the gate (`verify.md:104`) for the
whole window, so a single self-issued waiver with a distant expiry converts any failing obligation into a gate
pass. `SOL-V010` (`errors.md:201`) requires a *named human* authority only for the high-oversight band — and
that band is defined in `source-authority.md:124`, a cross-reference an adopter may never wire up.

Severity: HIGH — waivers are the sanctioned way to pass a failing obligation, and the controls on them are
governance text, not checks.

### O-9 — The high-oversight band (the one place RISK forces a human) hangs on a cross-doc definition + ADVISORY adequacy (HIGH)

The dual-judge rule for `RISK high|critical` (`review.md:82`) and the stronger-oracle requirement
(`verify.md:301-308`) are the framework's high-stakes safeguards. `SOL-V010` (`errors.md:201`) is the *only*
BLOCKING code that demands a **named human** — and only for a "high-oversight-band obligation." That band is
defined nowhere in `verify.md`/`review.md`; it lives in `source-authority.md:120-124`.

The watch-out: the highest-stakes control depends on three things lining up that NO-RUNTIME cannot guarantee:
(a) the author correctly set `RISK high|critical` on the obligation (RISK is author-assigned and "otherwise
inert," `source-authority.md:122`) — an under-classified obligation silently exits the band; (b) the adopter
read the cross-referenced band definition and wired `SOL-V010`; (c) `SOL-V011` adequacy is in *strict* mode
(O-5), else the "stronger oracle" requirement only warns. A reviewer focused on `verify.md`/`review.md` alone
would not even see the band definition.

Severity: HIGH — the high-stakes escalation is the most important place for the trust model to hold and it is
the most cross-doc-fragile and most dependent on correct author self-classification.

### O-10 — The merge-gate predicate is honest but a reader can mistake it for an enforced gate (MEDIUM)

The predicate is stated identically in four places (`verify.md:97`, `review.md:52`, `review.md:98`,
`pass-review-trace` SKILL.md:75) and each is correctly caveated as manual. Consistency is good. The status
read-model (`status.md`) correctly forbids re-judging and self-authored verdicts (`status.md:14-18`).

The watch-out: the predicate reads like an `iff` law ("A change set MAY be promoted **if and only if** …").
Detached from its caveat — e.g. quoted in a slide, a README, or an adopter's mental model — it implies a gate
that *runs*. The framework guards against this verbally (`pass-review-trace` SKILL.md:102, anti-pattern
"Claiming the gate 'runs' or 'is enforced' today") but the guard is one more SOFT instruction. The
`## Final verdict` of a `review.md` is a single `PASS`/`BLOCKED` cell (`review.md:105`) computed by hand; a
wrong aggregation (one blocking binding overlooked) silently opens the gate, and nothing recomputes it.

Severity: MEDIUM — honesty is maintained in-doc; the risk is downstream mis-citation and hand-aggregation
error, not an in-doc false claim.

### O-11 — The trust model's own evidence base is load-bearing, single-sourced in places, and partly non-peer-reviewed (MEDIUM)

The model-judge discipline (`review.md:71`), oracle adequacy (`verify.md:282`), and the `model`-type
de-scoping (`verify.md:208`) are each justified by specific citations. `sources.md` is rigorous — it records
verification dates, rejects fabricated figures (`sources.md:42` flags a "~14.5 pt" figure as fabricated, the
SWE-bench inflation is the corrected ~6.2 pt), and caveats non-peer-reviewed entries.

The watch-out: several load-bearing claims rest on **preprints** explicitly marked not-yet-peer-reviewed —
`VERINA` (`sources.md:152`, "preprint; *not* ICML 2025"), `VERICODING` (`sources.md:155`, preprint) — which
per the §0.7 rule (`sources.md:3`) "MUST NOT carry a `MUST`-level claim." `verify.md:208` uses them to *narrow*
the `model` proof type (a de-scoping, arguably safe), but a reviewer should confirm no `MUST` rides solely on a
caveated source. Separately, the dual-judge rule leans on a cluster ([[SELFPREFER]], [[JUDGEBIAS]],
[[CORRELATED]], [[SELFCORRECT]]) that is internally consistent but, by [[CORRELATED]]'s own finding
(`sources.md:36`), *undermines the very cross-model independence the dual-judge rule prescribes* — error
correlation "persists across distinct architectures and providers." The remedy the framework offers (two
unrelated models) is weakened by the evidence it cites for needing it.

Severity: MEDIUM — the bibliography discipline is strong; the residual risk is (a) a `MUST` resting on a
caveated preprint and (b) a defense (cross-vendor judges) partially refuted by its own citation.

### O-12 — The untrusted-source boundary: one HARD-lane check, the rest SOFT, and the artifacts the reviewer reads are the attack surface (MEDIUM)

`review.md:86-91` and `pass-review-trace` SKILL.md:73 treat every read artifact as untrusted input
(file-borne prompt injection). `SOL-S013` (`errors.md:146`) is correctly placed in the HARD lane (purely
lexical: zero-width / bidi / homoglyph rejection) — the one genuinely deterministic control in this whole
backbone. The source-authority rule (external sources never auto-promotable) is SOFT.

The watch-out: `SOL-S013` is HARD-lane *in principle* but still NO-RUNTIME *today* (`review.md:88` "manual
today"), so the one lexical check that could run is also not running. Meanwhile the reviewer is an LLM reading
attacker-controllable markdown (a malicious `AGENTS.md` could redefine `cmd*` adapters so a bound proof runs an
attacker command, or hide instructions that bias a `manual` verdict). The framework names the risk but the
mitigation is, again, a contract. The `AGENTS.md > Commands` table being a free-string adapter resolver
(`verify.md:178-179`, `proof-types.md:51`) is a confused-deputy surface: the proof's trustworthiness inherits
the trustworthiness of an `AGENTS.md` the same untrusted-source rule is supposed to police.

Severity: MEDIUM — the analysis is honest and `SOL-S013` is well-designed; the gap is that even the HARD-lane
check is unrun today, and the adapter-resolution layer is an under-examined injection surface.

## Risks

Each risk names its firing condition — the concrete situation in which the watch-out becomes a real
false-`PASS` or a subverted gate.

- **R-1 (from O-1, O-2, O-3, O-7).** *A single agent runs author→implement→verify→review with no independent
  second actor.* Fires whenever an adopter (or this repo's own dogfooding `main`-only workflow) lets one agent
  close the loop. Result: every "independence" control (re-run-yourself, implementer≠reviewer, dual-judge) is
  vacuous; a fabricated paste + self-issued `manual PASS` is a complete gate pass. This is the modal case, not
  the edge case.

- **R-2 (from O-5, O-4).** *A `RISK high` obligation ships with a bare green `test` the author wrote and ran,
  in a repo that did not enable strict mode.* Fires by default (strict mode is opt-in). Result: an inadequate
  oracle clears the gate; `SCHEMA IS NOT VERIFICATION` is asserted in prose but not operative.

- **R-3 (from O-8).** *An agent self-issues `WAIVED FAIL` with a typed `authority` string and a distant
  `expiry`.* Fires whenever a failing obligation is inconvenient and no human checks the waiver record. Result:
  any `FAIL` becomes a gate pass for the waiver window; auto-expiry-on-edit does not fire because no tool
  computes the source hash.

- **R-4 (from O-6).** *A failing or unbindable obligation is recorded `BLOCKED` ("flaky environment") instead
  of `FAIL`/`UNVERIFIED`.* Fires under throughput pressure. Result: the obligation reads as a transient
  environment problem awaiting a re-run rather than unmet work; combined with a later self-`PASS`, it launders
  a failure.

- **R-5 (from O-9).** *An author under-classifies a high-stakes obligation as `RISK medium`, or the adopter
  never wired the high-oversight band / `SOL-V010` from `source-authority.md`.* Fires on mis-classification or
  incomplete adoption. Result: the dual-judge + named-human safeguard never triggers; the one BLOCKING
  human-in-the-loop control is silently bypassed.

- **R-6 (from O-3, O-11).** *Two "independent" judges that share latent error-correlation both pass a wrong
  change.* Fires per [[CORRELATED]] even across vendors, especially at high capability. Result: the dual-judge
  rule reports independence it does not have; a correlated false-`PASS` survives.

- **R-7 (from O-10).** *A hand-computed `## Final verdict` aggregates one blocking binding wrong.* Fires on any
  human/agent aggregation error across many bindings. Result: the gate opens on a change set with a live
  blocking verdict, with nothing to recompute it.

- **R-8 (from O-12).** *A malicious or compromised `AGENTS.md` redefines a `cmd*` adapter or hides instructions
  in a read artifact.* Fires whenever a spec/audit/AGENTS.md of out-of-boundary provenance is read and
  `SOL-S013` / source-authority are unrun. Result: a bound proof executes attacker-chosen behavior, or a
  `manual` verdict is biased — and the resulting `PASS` is well-formed.

## Critical watch-outs for a reviewer (ranked)

A reviewer of *Swarm itself* (auditing whether the trust claim holds), ranked by blast radius:

1. **Read every "gate/check/enforced/MUST" as SOFT until proven HARD (O-1).** The merge gate, the four
   model-judge rules, the "paste verbatim" rule, and the "what is NOT a proof" floor are all manual. The single
   biggest over-claim risk is treating any of them as enforced. Confirm each enforcement verb resolves to a
   "future deterministic home," not a present tool. The framework does this well in-doc; the danger is a reader
   or adopter who doesn't.

2. **Treat `manual` + self-attested judge identity as the soft underbelly (O-2, O-3).** The universal escape
   hatch (`manual`) plus an unbindable `judge` adjunct means the dual-judge / implementer≠reviewer rules — the
   named centerpiece of the trust model — rest on the honesty of the actor they police. Probe whether any
   shipped artifact could *bind* recorded judge identity to the actual rendering actor. It cannot, today.

3. **Check that oracle adequacy is BLOCKING, not ADVISORY, wherever `SCHEMA IS NOT VERIFICATION` is invoked
   (O-5).** `SOL-V011`/`SOL-V003` default to advisory and the merge-gate predicate ignores adequacy entirely. A
   `RISK high` obligation can pass on a bare green test by default. This is the precise gap between the
   framework's deepest claim and its default behavior.

4. **Trace the high-oversight band end-to-end (O-9).** The only BLOCKING human-in-the-loop control depends on
   correct author `RISK` self-classification + an adopter wiring a cross-referenced definition
   (`source-authority.md`) + strict-mode adequacy. Verify all three are stated as required for the high-stakes
   guarantee, not assumed.

5. **Audit waiver controls as governance text, not checks (O-8).** Expiry, named authority, and
   no-self-issue are self-attested; auto-expiry-on-edit needs a hash no tool computes. A self-issued
   long-expiry `WAIVED FAIL` is the cleanest single-step gate subversion.

6. **Confirm the evidence base carries no `MUST` on a caveated preprint, and note the [[CORRELATED]] tension
   (O-11).** §0.7 forbids `MUST`-level claims on non-peer-reviewed sources; `VERINA`/`VERICODING` are
   preprints. Separately, the cross-vendor dual-judge remedy is partially refuted by the very paper cited for
   needing it.

7. **Note that even the one HARD-lane check (`SOL-S013`) is unrun today, and the `AGENTS.md` adapter layer is a
   confused-deputy surface (O-12).** The lexical injection check is correctly classed HARD but is still manual;
   the free-string `cmd*` resolver inherits the trust of a file the untrusted-source rule is meant to police.

8. **Watch hand-aggregation of the final verdict and BLOCKED/UNVERIFIED self-classification (O-10, O-6).**
   Lower blast radius, but both are points where a single judgment call silently changes whether the gate
   opens, with nothing to recompute it.
