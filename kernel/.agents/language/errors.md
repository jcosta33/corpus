# Swarm Lint Codes — `SOL-<LAYER><NNN>` Error Reference

> Authoritative source: `.agents/specs/swarm/02-aps-and-lint.md` §8 (the unified `SOL-<LAYER>NNN` lint taxonomy) and `.agents/specs/swarm/10-appendices.md` Appendix B (the full catalogue + legacy translation table). This is a reference projection; where it and the spec disagree, the spec governs.

Swarm is markdown-only and has no runtime. A *checker* that emits these codes is a **contract** a future `lint-spec` tool builds against — never shipped code in this repo (Principle 1, §17). This page is the reader-facing index of every v0.1 diagnostic; the spec sections above are the long-form law.

---

## 1. The namespace

Every diagnostic code matches one grammar (Appendix B.1):

```ebnf
lint_code = "SOL-", layer, number;
layer     = "S" | "P" | "M" | "V" | "O";
number    = digit, digit, digit;          (* zero-padded, 3 digits *)
```

One prefix (`SOL-`), exactly **five layers** (S/P/M/V/O), a three-digit number. `APS-` is **retired as a code prefix** — "APS" survives only as the *name* of the controlled-prose standard (§7) and MUST NOT appear in any code (§8.5). Each layer is a 100-block, **append-only with tombstoning**: a retired code keeps its row marked `TOMBSTONED`, carries a `superseded-by` pointer where one exists, and its number is never reissued (Appendix B.1.1).

### The five layers

Each layer maps 1:1 to a compiler phase/pass (§9). A code's letter tells you the phase it belongs to and which gate it blocks at.

| Layer | Letter | Detects | Phase it guards | Gate it blocks at |
|---|---|---|---|---|
| SYNTAX | `S` | Parser-detectable well-formedness of a single block | `PARSE` | lint → `lower` gate |
| PROSE | `P` | Controlled-prose / requirement-smell, single-obligation-local (the former APS layer; absorbs legacy `SOL-L###`) | `NORMALIZE` (`lint`/`improve`) | lint → `lower` gate |
| SEMANTIC | `M` | Cross-reference: duplicate id, contradiction, unbound ref | `NORMALIZE` | lint → `lower` gate |
| VERIFICATION | `V` | Proof-binding: missing / stale / non-observable proof | `VERIFY` | merge gate (§14) |
| ORCHESTRATION | `O` | Planning / parallelism: write-conflict, dep cycle, blocking `QUESTION` reaching lowering | `LOWER` (raised by `lower`/`decompose`, surfaced by the lint gate) | merge gate (§14) |

### The diagnostic record

Every emitted diagnostic is the **checker-emit / SARIF-authoring** record (Appendix B.1.2):

```json
{
  "code": "SOL-P005",
  "severity": "BLOCKING",
  "layer": "P",
  "span": { "file": "auth.swarm.md", "block": "AC-001", "line": 12, "col": 9 },
  "message": "vague-quality word 'fast' with no same-line observable criterion",
  "suggest": "CONCRETIZE or QUANTIFY: bind a measurable threshold on the same line"
}
```

`severity` is `BLOCKING` | `ADVISORY`; `span` is at minimum `{ file, block }`. The IR (§12.8 / Appendix C) lowers the same diagnostic to `{ code, level, node, source, message, suggest }`, mapping `severity → level` (`BLOCKING → error`, `ADVISORY → warning`), `span → source { file, line_start, line_end }`, with `code` identical at both layers. `suggest` MUST name a closed improve op (§10) wherever one applies — never an open-ended rewrite.

---

## 2. Severity: BLOCKING vs ADVISORY

Severity is **binary and intrinsic** (§8.2, Appendix B.1.3):

- **BLOCKING** iff the defect changes *what gets built* — the obligation is incomplete, non-binding, untestable, ambiguous, contradictory, or unsafe to parallelize. Carries `severity: BLOCKING` (IR `level: error`) and MUST be resolved before the artifact passes its layer's gate; none may remain at promotion unless waived.
- **ADVISORY** iff the defect affects only *how the text reads* — style, length, voice, redundancy. Carries `severity: ADVISORY` (IR `level: warning`) and does not block on its own.

The surface model is strictly binary: every code lowers to `error` or `warning`. The third IR `level` value `note` has **no surface producer in v0.1** (§8.2).

Two position-sensitive rules are re-classified by the binding-clause vs commentary boundary (§7.2): **`SOL-P056`** (comparative without baseline) is BLOCKING inside an obligation block, ADVISORY in commentary; the high-risk-word rules (§7.3–§7.4) are BLOCKING only inside binding clauses.

### Severity overrides and waivers (§8.6)

Default severities are fixed by the spec. A project may adjust them through one config surface (`swarm.config.json`/`.yaml`, or the `lint:` section of `.swarm/config.yaml`), with exactly two legal moves:

1. **Promote (strict mode):** raise an ADVISORY to `error`. Always permitted; no record needed.
2. **Demote (waiver):** lower a BLOCKING to `warning` or `off`. Permitted **only** with a recorded waiver carrying `code`, `scope`, `to`, `authority`, `reason`, `expiry`, `recorded_at` (all required). `to: off` is not an IR `level` — it suppresses the diagnostic from `diagnostics[]`. A waiver **auto-expires** at its `expiry` date *and* on the next change to the waived obligation's source content-hash, whichever comes first. A demotion without a complete waiver record is itself a conformance defect.

A `swarm.config` MUST NOT redefine, rename, invent, or re-layer codes. A lint-severity demotion is distinct from a `WAIVED` verdict (§14): the former silences a *diagnostic*, the latter accepts a *failing proof*.

---

## 3. The full catalogue

Every v0.1 code, by layer, with `{code, severity, layer, message, resolves-by}`. "Resolves by" names a closed improve op (§10) where one applies, otherwise a direct edit. Source: Appendix B.2–B.6.

### 3.1 Layer S — SYNTAX (fire at `PARSE`; all BLOCKING)

A malformed block cannot be parsed into a node, so every S code is BLOCKING and resolved by a direct **edit** — no improve op applies (improve ops operate only on already-parseable obligations).

| Code | Severity | Layer | Message (short name + defect) | Resolves by |
|---|---|---|---|---|
| `SOL-S001` | BLOCKING | S | dangling-precondition (syntax): a trigger clause (`WHERE`/`WHILE`/`WHEN`/`IF`) present but no `THE <actor> <MODAL> <response>` actor-clause follows. | Edit: add the missing actor-clause. (Prose companion: `SOL-P001`.) |
| `SOL-S002` | BLOCKING | S | unknown-block-or-keyword: header is not one of the 7 block types, or a body line uses an unknown/malformed clause keyword. | Edit: use a valid block type (§6) / clause keyword (§5). |
| `SOL-S003` | BLOCKING | S | actor-clause-no-modal: an actor-clause with no modal (`MUST`/`MUST NOT`/`SHOULD`/`SHOULD NOT`/`MAY`). | Edit: insert a valid modal (§5). (Chained `AND THE` modals are permitted; only total absence trips this.) |
| `SOL-S004` | BLOCKING | S | duplicate-block-id: two blocks share the same surface id within one spec (intra-spec). | Edit: renumber. (Cross-spec collisions are `SOL-M001`.) |
| `SOL-S005` | BLOCKING | S | prefix↔type-mismatch: the id prefix does not match the block type (e.g. `REQ C-001:`). | Edit: use the canonical prefix (REQ→`AC-`, CONSTRAINT→`C-`, INVARIANT→`I-`, INTERFACE→`IF-`, QUESTION→`Q-`, TRACE→`T-`). |
| `SOL-S006` | BLOCKING | S | should-without-because: `SHOULD`/`SHOULD NOT` used without an accompanying `BECAUSE` or `EXCEPT` in the same block (§5.6). | Edit: add a `BECAUSE`/`EXCEPT`, or strengthen to `MUST`/`MUST NOT`. |
| `SOL-S007` | BLOCKING | S | malformed-header: header is missing the mandatory trailing colon, or the id is malformed (spaces, illegal characters). | Edit: write `TYPE PREFIX-NNN:`. |
| `SOL-S008` | BLOCKING | S | non-control-first-line: a trailing metadata clause (`DEPENDS ON`/`WRITES`/…) or free prose appears before the block's control content (leading EARS condition or `THE <actor> <MODAL>` clause). A leading condition clause is control content and does not trip this. | Edit: lead with the condition/actor clause; move metadata to the trailing block. |
| `SOL-S010` | BLOCKING | S | unknown-metadata-field: a trailing metadata field is outside the closed set (`DEPENDS ON`/`TOUCHES`/`WRITES`/`READS`/`AFFECTS`/`RISK`/`DOMAIN`/`OWNED BY`). | Edit: use a valid field (§5) or move the text to commentary. |
| `SOL-S011` | BLOCKING | S | missing-obligation-id: a header is present but carries no `*_id` after the block type (type recognized, id absent). | Edit: add a valid `PREFIX-NNN` id after the block type. |
| `SOL-S012` | BLOCKING | S | required-section-missing: a `spec.swarm.md` is missing a required top-level section from the ordered set of §21.2.1 (e.g. `## Intent`, `## Non-goals`, `## Obligations`), or carries them out of order. Document-level companion of the per-obligation `SOL-O004`. | Edit: add the missing `## ` section heading (or reorder) per §21.2.1. |
| `SOL-S013` | BLOCKING | S | untrusted-source-character: an agent-read artifact contains a zero-width, bidirectional-control, other non-printing, or homoglyph-suspect codepoint in obligation/instruction bytes — hidden-instruction injection (§17.5.1) `[RULESBACKDOOR]`. | Edit: strip the offending codepoints or re-author in printable characters. |
| `SOL-S014` | BLOCKING | S | missing-required-clause: a block omits a clause its grammar makes mandatory — e.g. a `TRACE` with `IMPLEMENTS` but no `PROOF` line (§6.6). | Edit: add the required clause (for `TRACE`, at least one `PROOF` line). |

### 3.2 Layer P — PROSE (fire at `NORMALIZE`; `001–049` BLOCKING, `050–099` ADVISORY)

P-layer rules are single-obligation-local; each maps to a closed improve op (§10), never an open rewrite. The `001–049` / `050–099` split is normative for the P layer only (Appendix B.1.1).

| Code | Severity | Layer | Message (short name + defect) | Resolves by |
|---|---|---|---|---|
| `SOL-P001` | BLOCKING | P | dangling-condition: a trigger with no modal *consequence* at the prose level (semantically empty even if syntactically a sentence). | `CLARIFY` / `ATOMIZE`: supply the consequence. |
| `SOL-P002` | BLOCKING | P | missing-actor: the obligation has no responsible actor. | `CONCRETIZE`: name the actor. |
| `SOL-P003` | BLOCKING | P | missing/informal-modality: no modal, or lowercase `should`/`must`/`may` used where binding force is intended. | `NORMALIZE`: uppercase to the correct modal. |
| `SOL-P004` | BLOCKING / ADVISORY | P | bundled/overloaded-obligation: one clause bundling multiple separable obligations is BLOCKING; a permitted `AND THE` chain beyond two is an ADVISORY warning (G3). | `ATOMIZE`: split into one obligation per block. |
| `SOL-P005` | BLOCKING | P | vague-quality-no-criterion: a vague-quality / high-risk word in a binding clause with no same-line observable criterion (§7.3–§7.4). | `CONCRETIZE` or `QUANTIFY`. |
| `SOL-P006` | BLOCKING | P | undefined-term: an undefined term in a binding clause (not resolvable via in-file `TERM` or `memory/glossary.md`). | `CLARIFY` / `BIND`: define the term. |
| `SOL-P007` | BLOCKING | P | negation-ambiguity: a bare `MUST NOT` whose scope is ambiguous, not paired with the affirmative behavior. | `CLARIFY`: state the affirmative alongside the prohibition. |
| `SOL-P008` | BLOCKING | P | uncaptured-uncertainty: behavioral uncertainty left in prose, not lifted to a `QUESTION` block. | `CLARIFY`: raise a `QUESTION`. |
| `SOL-P050` | ADVISORY | P | pronoun: a vague pronoun with a non-unique antecedent. | `CLARIFY`. |
| `SOL-P051` | ADVISORY | P | passive-voice: passive voice in an obligation sentence. | `NORMALIZE`. |
| `SOL-P052` | ADVISORY | P | sentence-length: obligation sentence exceeds ~20 words. | `COMPRESS` / `ATOMIZE`. |
| `SOL-P053` | ADVISORY | P | non-present-non-active: non-present-tense or non-active phrasing. | `NORMALIZE`. |
| `SOL-P054` | ADVISORY | P | prose-noise: a decorative phrase that adds no constraint. | `COMPRESS`. |
| `SOL-P055` | ADVISORY | P | redundancy: repeated context that adds no constraint. | `COMPRESS`. |
| `SOL-P056` | ADVISORY / BLOCKING | P | comparative-no-baseline: a comparative/superlative with no baseline. **BLOCKING in a binding clause, ADVISORY in commentary** (G2, §7.2). | `QUANTIFY`: supply the baseline. |
| `SOL-P057` | ADVISORY | P | terminology-drift: a term used inconsistently with its `memory/glossary.md` definition (synonym, casing variant, competing label). Advisory because the term still resolves — so not the blocking `SOL-P006`. | `NORMALIZE`: replace the variant with the canonical glossary term. |
| `SOL-P058` | ADVISORY | P | deprecated-modal-alias: `SHALL`/`SHALL NOT` used as a modal — a recognized deprecated alias of `MUST`/`MUST NOT` (§5.6). | `NORMALIZE`: rewrite to `MUST`/`MUST NOT`. |

The **high-risk-word list** (subjective/promotional terms + Femmer loopholes & comparatives + Tjong/Berry quantifiers/connectives `[SMELLS]`) and the **same-line-makes-it-observable rule** govern `SOL-P005`/`SOL-P056`: a high-risk word is permitted only when the same sentence, bullet, or immediately-following line converts it to observable behavior (actor+action+object, a measurable threshold, or a named verification target); otherwise the rule fires BLOCKING.

### 3.3 Layer M — SEMANTIC (fire at `NORMALIZE`, cross-obligation; all BLOCKING)

A broken reference or contradiction changes what is built, so every M code is BLOCKING (Appendix B.4).

| Code | Severity | Layer | Message (short name + defect) | Resolves by |
|---|---|---|---|---|
| `SOL-M001` | BLOCKING | M | actor/object-incompleteness: a referenced actor, object, or surface is unresolved across the spec / imports (also catches cross-spec id collision). | `BIND` / `CONCRETIZE`: resolve or declare the referent. |
| `SOL-M002` | BLOCKING | M | contradiction: two obligations share a **contradiction key** (normalized actor + trigger/state + the `affects[]` ∪ `writes[]` surface set, case-folded/whitespace-collapsed exact match) and carry **opposed modalities** (positive vs negative force, or `MUST NOT` vs `MAY`). **Exact-key match only in v0.1**; paraphrase/entailment contradiction is out of scope. | `DECONFLICT`. |
| `SOL-M003` | BLOCKING | M | unbound-cross-reference: a `DEPENDS ON` / `IMPLEMENTS` / `PRESERVES` reference names an id that does not exist. | `BIND`: fix the reference. |
| `SOL-M004` | BLOCKING | M | authority-conflict: a lower-authority block attempts to weaken a higher-authority obligation (source-authority order, §22). | `DECONFLICT` / amendment. |

### 3.4 Layer V — VERIFICATION (fire at `VERIFY`; gate the merge gate, §14)

The subject is the `VERIFY BY <type>:<adapter>:<artifact>[#selector]` binding (§15). Most are BLOCKING; `SOL-V003` and `SOL-V011` are ADVISORY by default and promote under strict mode (Appendix B.5).

| Code | Severity | Layer | Message (short name + defect) | Resolves by |
|---|---|---|---|---|
| `SOL-V001` | BLOCKING | V | no-verification-path: an obligation block (REQ/CONSTRAINT/INVARIANT) or an INTERFACE has no `VERIFY BY` binding. | `BIND`: attach a `VERIFY BY`. |
| `SOL-V002` | BLOCKING | V | proof-not-executable: the bound adapter does not resolve through AGENTS.md > Commands, or the artifact is missing. | `BIND`: point at a resolvable cmd* adapter (§15). |
| `SOL-V003` | ADVISORY / BLOCKING | V | non-observable-proof: the bound proof is non-observable (e.g. an INVARIANT bound only to a non-observable unit `test`). ADVISORY by default; BLOCKING under strict mode. | `BIND`: prefer `property`/`model`/`static` for INVARIANT; `contract` for INTERFACE. |
| `SOL-V004` | BLOCKING | V | stale-proof: a prior `PASS` whose evidence no longer matches the current source content-hash, a changed write surface, a changed proof-exercised read surface (§16.5c), or a rebound adapter (§16.5d); surfaces as the `STALE` verdict (§16). | 3-way reconcile (re-run / amend / fix code) — never a silent re-bless. |
| `SOL-V005` | BLOCKING | V | bad-verdict-value: a `VERDICT` core value is not one of `PASS`/`FAIL`/`BLOCKED`/`UNVERIFIED`, OR a lifecycle decorator is missing its mandatory fields (WAIVED→authority+reason+expiry; STALE→prior-verdict ref+changed-surface; CONTRADICTED→two conflicting evidence refs). | Edit: use a valid verdict line (§14). |
| `SOL-V006` | BLOCKING | V | interface-without-contract: an `INTERFACE` whose `VERIFY BY` proof_type is not `contract`. | `BIND`: use `contract:` as the proof type for INTERFACE bindings. |
| `SOL-V007` | BLOCKING | V | invalid-lifecycle-decoration: a lifecycle decorator applied to the wrong core value (e.g. `WAIVED` on a `PASS`/`BLOCKED`, or `STALE` on anything other than a prior `PASS`). | Edit: remove or correct the lifecycle decorator per §14.1.2. |
| `SOL-V008` | BLOCKING | V | missing-verdict-at-merge-gate: a required `VERIFY BY` binding has no `VERDICT` at the merge gate (counts as `UNVERIFIED`; §14.4). | `BIND`: run the proof and record a verdict, or `WAIVE`. |
| `SOL-V009` | BLOCKING | V | unknown-proof-type: a `verify_ref` whose `proof_type` is outside the closed 9-set (`static`, `test`, `contract`, `property`, `model`, `perf`, `security`, `manual`, `monitor`). | Edit: use one of the nine canonical proof types (§15.1). |
| `SOL-V010` | BLOCKING | V | missing-human-authority: a high-oversight-band obligation (§22.7) carries a `manual`/`WAIVED` verdict with no named human authority. | Edit: record the human authority on the `manual @ REVIEW` verdict / waiver (§17.3, §22.7). |
| `SOL-V011` | ADVISORY / BLOCKING | V | oracle-adequacy-unrecorded: a proof does not record what it exercised relative to the obligation predicate where §15.10 requires it. ADVISORY by default; BLOCKING in strict mode for `RISK high`/`critical`. | Edit: add the `oracle_adequacy` record (§15.10.1). |

### 3.5 Layer O — ORCHESTRATION (fire at `LOWER`; gate plan emission and the merge gate)

These guard safe parallelism (§18) and the coverage gates (§11.6.2). `SOL-O004` and `SOL-O006` are ADVISORY; the rest are BLOCKING (Appendix B.6).

| Code | Severity | Layer | Message (short name + defect) | Resolves by |
|---|---|---|---|---|
| `SOL-O001` | BLOCKING | O | conflicting-tasks-parallel: the plan marks two work packets parallel that share a write surface or an interface/migration node (violates the safe-parallelism predicate, §18). Raised from Warning to ERROR per the kernel decision. | `SCOPE`: serialize, or split write surfaces. |
| `SOL-O002` | BLOCKING | O | dependency-cycle: a `DEPENDS ON` cycle exists in the lowered DAG. | `SCOPE` / `DECONFLICT`: break the cycle. |
| `SOL-O003` | BLOCKING | O | blocking-question-reaches-lowering: an unresolved `blocking` `QUESTION` reaches the `LOWER` pass (lowering MUST NOT proceed past an open blocking question). | `CLARIFY`: answer/close the QUESTION before lowering. |
| `SOL-O004` | ADVISORY | O | scope-too-broad: an obligation has no `WRITES`/`READS`/`AFFECTS`, leaving it unscoped (serializes by default and harms planning). | `SCOPE`: declare write/read/affect surfaces. |
| `SOL-O005` | BLOCKING | O | owned-path-outside-write-surface: a work packet writes a path outside its declared `WRITES` surface (the two-tier lowering check, G7). | `SCOPE`: declare the path, or stop writing it. |
| `SOL-O006` | ADVISORY | O | import-policy-overlap: an imported file creates a duplicate/overlapping policy obligation. | `DECONFLICT` / `COMPRESS`. |
| `SOL-O007` | BLOCKING | O | uncovered-obligation: a lowered obligation maps to no task packet (the §11.6.2 coverage gate). An orphan TRACE/VERDICT target resolving to no obligation is `SOL-M003`, not this. | `SCOPE` / `decompose`: assign the obligation to a packet. |
| `SOL-O008` | BLOCKING | O | double-owned-obligation: a lowered obligation is assigned to more than one `implement` packet (§11.6.2). Appearing across *different* passes (implement/verify/review) is legitimate and does NOT trip this. | `SCOPE` / `decompose`: assign the obligation to exactly one implement packet. |

---

## 4. Principal BLOCKING set (quick index)

The canonical blocking set called out inline in §8.3, for the common case: **S** — `SOL-S001`, `SOL-S003`, `SOL-S005`, `SOL-S006`, `SOL-S012`. **P** — the blocking prose set `SOL-P001`–`SOL-P008`. **M** — `SOL-M001`, `SOL-M002`. **V** — `SOL-V001`. **O** — `SOL-O001`, `SOL-O005`.

The principal ADVISORY prose set (§8.4) is `SOL-P050`–`SOL-P058`.

---

## 5. Improve-op ↔ lint-code map

The closed **10-op improve set** (§10) is the canonical detect→repair wiring (Appendix B.7). Each op is strictly semantics-preserving; any intent change routes to amendment/review, never improve. `PROMOTE` carries no lint code (it routes through the promotion protocol, §23/§30).

| Improve op | Resolves codes |
|---|---|
| `NORMALIZE` | `SOL-P003`, `SOL-P051`, `SOL-P053`, `SOL-P057`, `SOL-P058` |
| `ATOMIZE` | `SOL-P004` (and `SOL-P052` by splitting) |
| `CONCRETIZE` | `SOL-P005`, `SOL-P002`, `SOL-M001` |
| `QUANTIFY` | `SOL-P005`, `SOL-P056` |
| `BIND` | `SOL-V001`, `SOL-V002`, `SOL-V003`, `SOL-V006`, `SOL-V008`, `SOL-M003`, `SOL-P006` |
| `SCOPE` | `SOL-O001`, `SOL-O002`, `SOL-O004`, `SOL-O005`, `SOL-O007`, `SOL-O008` |
| `CLARIFY` | `SOL-P008`, `SOL-P001`, `SOL-P007`, `SOL-P050`, `SOL-O003` |
| `DECONFLICT` | `SOL-M002`, `SOL-M004`, `SOL-O006` |
| `COMPRESS` | `SOL-P054`, `SOL-P055`, `SOL-O006` |
| `PROMOTE` | (no lint code — promotion protocol, §23/§30) |

---

## 6. Legacy translation table (old → new)

`APS-` is retired; every legacy `APS-*` code, every flat legacy research code (`SOL00x`/`10x`/`20x`/`30x`), and every legacy `SOL-L###`/`SOL-M2xx`/`SOL-V4xx` code remaps into `SOL-<LAYER><NNN>`. Legacy codes are **non-normative aliases retained for migration only** and MUST NOT appear in any conformant artifact (§8.5, Appendix B.8). The full tables live in Appendix B.8; the most-cited remaps:

| Legacy code | v0.1 code | Note |
|---|---|---|
| `APS-A001` | `SOL-P005` | vague-quality, no observable criterion |
| `APS-A002` | `SOL-P050` | pronoun ambiguity |
| `APS-C001` | `SOL-M001` | actor/object incompleteness |
| `APS-M001` | `SOL-P003` | informal modality |
| `APS-O001` | `SOL-P004` | bundled/overloaded obligation |
| `APS-P001` | `SOL-P054` | prose noise |
| `APS-Q001` | `SOL-P008` | uncaptured behavioral uncertainty |
| `APS-R001` | `SOL-P055` | redundancy |
| `APS-S001` | `SOL-S012` | document-level section gap (per-obligation scope gap stays `SOL-O004`) |
| `APS-T001` | `SOL-M001` | traceability id → semantic completeness |
| `APS-V001` | `SOL-V001` | no verification path |
| `APS-X001` | `SOL-M002` | contradiction |
| `SOL-L###` | `SOL-P###` | the whole legacy prose layer absorbs into P |

**Splits by phase.** Where one legacy code maps to two v0.1 codes — e.g. `SOL101 → SOL-S001`/`SOL-P001`, `SOL201 → SOL-S004`/`SOL-M001` — the syntactic facet fires at `PARSE` (S) and the semantic/prose facet at `NORMALIZE` (P/M); a migration tool MUST emit both where both are present (Appendix B.8.4). **Tombstoned** legacy codes (`SOL004` `:::END` removed; `SOL104` `ALWAYS`/`NEVER` removed from INVARIANT) have no successor.

---

## 7. Conformance

A conformant `lint-spec` checker (a CONTRACT, never shipped — Principle 1, §17) MUST (Appendix B.9): (1) emit only `SOL-<LAYER><NNN>` codes; (2) emit the diagnostic record of §1; (3) apply the default severities here, overridable only through the recorded `swarm.config` waiver schema; (4) never reuse a tombstoned number; (5) name a closed improve op in `suggest` wherever §5 supplies one. The golden corpus (§33) sets an aspirational target of ≥0.90 precision / ≥0.85 recall for the `SOL-P` rules — design rationale, set above the field-measured lightweight-smell-detection ceiling of ~59% precision / ~82% recall with high variation `[SMELLS]`, and **not** an achieved result.

---

## Preserved / Dropped / Still-uncertain

**Preserved (this projection keeps):** the full per-layer catalogue of every v0.1 code — 13 S, 17 P (8 blocking, `SOL-P001`–`SOL-P008`; 9 advisory, `SOL-P050`–`SOL-P058`), 4 M, 11 V, 8 O — each with `{code, severity, layer, message, resolves-by}`; the five-layer namespace and grammar; the binary intrinsic severity model with the two position-sensitive re-classifications (`SOL-P056`, high-risk words); the override/waiver rules and required fields; the improve-op map (all 10 ops, including the no-code `PROMOTE`); the principal blocking/advisory quick index; and the most-cited legacy remaps.

**Dropped (left to the spec):** the long-form rationale anchors of §7.6 (format/order sensitivity, multi-turn decay, lost-in-the-middle, density economics, ambiguity-degrades-code) beyond the single-line evidence tags; the high-risk-word lexicon itself (§7.3) and the same-line-observable mechanics (§7.4); the complete `swarm.config` JSON schema and example (§8.6); the full IR `diagnostics[]` schema (§12.8 / Appendix C); the exhaustive legacy tables B.8.2–B.8.4 (only the APS family and headline remaps are reproduced); and all phase/pass, verdict, proof-type, and orchestration definitions that these codes reference (§9, §14, §15, §18).

**Still-uncertain (per the spec itself):** `SOL-M002` contradiction is **exact-key match only in v0.1** — paraphrase/entailment contradiction is explicitly out of scope and may at most be surfaced as an advisory judge-rendered diagnostic. The IR `level: note` value has **no surface producer in v0.1** (reserved for a future emitter). Project severity-override precision is marked deferred-precise to v0.2 in Appendix B.1.3 (the §8.6 waiver schema is the v0.1 surface). New-in-v0.1 codes (`SOL-O005`, `SOL-S013`) have no legacy alias.
