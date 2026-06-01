# Swarm Kernel Specification v0.1 — Part 02: APS and the lint taxonomy

<!-- Part 02 of the Swarm Kernel Specification (§7–§8). All parts share one section numbering (§0–§35 + Appendices A–G); cross-references of the form “§N” resolve via the index in [README.md](./README.md). -->

## 7. APS — Agent Prose Semantics (the controlled-prose standard)

APS (Agent Prose Semantics) is the controlled-prose standard that governs every word of natural-language prose that surrounds, introduces, or accompanies SOL blocks in a Swarm spec or working artifact. SOL (§5, §6) is the obligation language; APS is the standard for everything that is *not* a SOL block. This section defines APS normatively: its doctrine (§7.1), the binding-clause vs commentary boundary (§7.2), the high-risk word catalogue (§7.3), the "same line makes it observable" rule (§7.4), the mapping from APS rule families to `SOL-P` lint codes (§7.5), and the durable rationale that anchors the whole standard (§7.6).

### 7.1 Doctrine: prose is a non-authoritative delivery layer

#### 7.1.1 The authority rule (normative)

All **load-bearing meaning** in a Swarm repo — modality, actor, trigger/state, verification binding, authority order, conflict resolution, and trace schema — MUST live in SOL blocks (§6) and the typed IR (§12). Prose, skills (§26), personas (§27), and `AGENTS.md` (§31) are **non-authoritative delivery layers**: they carry context and guidance, never binding force.

A Swarm tool, author, or downstream agent MUST NOT treat any prose span as a source of an obligation, a verdict, a verification requirement, an authority ranking, or any other load-bearing fact. If a fact is load-bearing, it MUST be expressed as (or promoted into) a typed SOL block; until it is, it has no force.

*Rationale (terse):* prompt-format sensitivity (up to ~40% on identical content for weaker models such as GPT-3.5-turbo; larger models are more robust `[FORMAT]`; more broadly, meaning-preserving format choices alone swing few-shot accuracy by up to 76 points with only weak cross-model transfer `[SCLAR]`, and example/prompt order can swing results between near-SOTA and random `[PROMPTORDER]`), multi-turn reliability decay, and lost-in-the-middle / context-rot degradation — relevant information in the middle of a long context is used markedly worse than at the ends `[LOSTMID]` — make prose an unreliable carrier of meaning across turns and agents; only the typed surface and its IR are stable enough to bind on (see §7.6).

#### 7.1.2 The word-economy rule (normative)

Every word of Swarm prose SHOULD do at least one of the following jobs. A word that does none of them is prose noise and SHOULD be removed (advisory `SOL-P054`, see §8.4).

| Job | Meaning |
|---|---|
| constrain behavior | states or qualifies what something must do |
| clarify context | supplies the situation an obligation answers |
| define scope | bounds what is and is not in play |
| identify evidence | names how a claim is checked |
| bind traceability | links to a stable id (`AC-001`, `T-001`, a finding) |
| aid retrieval | a keyword a future agent will search for |
| mark uncertainty | flags a gap to be lifted to a `QUESTION` (§6) |
| explain rationale | records *why*, durably |

#### 7.1.3 Properties of conformant prose (normative)

Good Swarm prose is **concrete, observable, atomic, scoped, verifiable, traceable, non-decorative, and low-entropy**. An author MUST prefer observable verbs (`return`, `show`, `reject`, `record`, `persist`, `redirect`, `retry`, `deny`, `notify`, `log`, …) over vague action verbs (`handle`, `support`, `manage`, `improve`, `optimize`, `streamline`, `enhance`, `modernize`, `clean up`, `make robust`). A vague action verb in prose is governed by the high-risk word rules (§7.3, §7.4).

```text
Bad (decorative, vague verb, no observable behavior):
  Improve checkout so it handles failures gracefully.

Good (every clause observable; the load-bearing meaning is in SOL):
  REQ AC-001:
  IF the payment provider times out
  THEN THE server MUST NOT create an order
  AND THE server MUST record a retryable payment attempt
  AND THE client MUST show "Payment temporarily unavailable"
  VERIFY BY test:cmdTest:payment-timeout.test#no-order
```

### 7.2 The binding-clause vs commentary boundary (normative)

The force of every APS rule depends on **where** a prose span sits. The boundary is mechanical and parser-decidable:

- A span is **BINDING** if and only if it is inside a typed obligation block — `REQ`, `CONSTRAINT`, or `INVARIANT` (the three obligation block types that carry binding force, §4, §6).
- A span is **COMMENTARY** in every other position: ordinary Markdown prose; headings; `INTERFACE`, `QUESTION`, `TRACE`, and `VERDICT` block bodies; the `BECAUSE` rationale of an obligation; and any `## Context` section.

APS prose rules apply **with full force** (BLOCKING where the rule is blocking) inside BINDING spans, and **as advisories only** inside COMMENTARY spans. One consequence is pinned explicitly: a comparative or superlative without a baseline is BLOCKING (`SOL-P056` promoted) inside a binding clause and ADVISORY (`SOL-P056` default) in commentary.

*Rationale (terse):* commentary explains and may be loose; a binding clause *is* the obligation, so an unobservable word inside it directly changes what gets built (§8.2). The boundary is decidable from block type alone, so a future linter needs no heuristic to apply it.

```text
COMMENTARY (advisory only — "messy" is tolerated, it explains):
  ## Context
  The existing auth flow is messy and users see repeated failed refresh calls.

BINDING (full force — an unobservable word here is blocking SOL-P005):
  REQ AC-001:
  WHEN the session is expired
  THE client MUST redirect to `/login`
  VERIFY BY test:cmdTest:expired-session-redirect.test
```

### 7.3 The high-risk word catalogue (normative)

A **high-risk word** is a word or phrase that, used in a binding clause without a same-line observable criterion, leaves *what gets built* underdetermined. The catalogue below is the canonical union of three research vocabularies. It is **closed for v0.1** in the sense that these families are the lint-checked set; a project MAY extend its own list via configuration (§8.6), but MUST NOT shrink the kernel set.

| Family | High-risk words / phrases (non-exhaustive within family) | Source | Default lint |
|---|---|---|---|
| Subjective / promotional | `robust`, `clean`, `simple`, `intuitive`, `user-friendly`, `easy to use`, `modern`, `seamless`, `flexible`, `elegant`, `beautiful`, `polished`, `nice`, `flamboyant`, `innovative`, `world-class`, `correct`, `appropriate`, `proper`, `reasonable` | brief §8.2 + Femmer subjective | `SOL-P005` |
| Non-verifiable quality | `fast`, `performant`, `scalable`, `secure`, `safe`, `reliable`, `consistent`, `graceful`, `sufficient`, `adequate` | brief §8.2 + Femmer open-ended | `SOL-P005` |
| Vague action verbs | `handle`, `support`, `manage`, `improve`, `optimize`, `enhance`, `streamline`, `modernize`, `clean up`, `make robust` | brief §8.3 | `SOL-P005` |
| Loopholes | `as far as possible`, `if practical`, `where feasible`, `if possible`, `to the extent practicable` | Femmer loopholes | `SOL-P005` |
| Ambiguous qualifiers | `significant`, `minimal`, `almost always`, `as needed`, `where appropriate` | Femmer / Tjong | `SOL-P005` |
| Comparatives / superlatives | `better`, `faster`, `more efficient`, `higher`, `best`, `highest`, `most`, `optimal` | Femmer comparatives | `SOL-P056` (blocking in binding clause) |
| Quantifiers (ambiguous scope) | `all`, `any`, `every`, `some`, `each`, plural nouns used as the actor | Tjong / Berry | `SOL-P005` (scope) |
| Connectives (ambiguous bundling) | `and`, `or`, `and/or`, `but`, `also` joining separable obligations | Tjong / Berry | `SOL-P004` (bundling) |
| Ambiguous exceptions | `unless`, `except where` (without a positive reformulation) | Berry | `SOL-P005` / prefer `IF`/`WHEN` |
| Vague references | `it`, `they`, `this`, `that`, `the above`, `the previous one`, `this thing` (no unique antecedent) | Femmer pronouns | `SOL-P050` (advisory) / `SOL-P002` (if it hides the actor) |

A bare `MUST NOT` prohibition with no paired affirmative behavior is a related negation hazard (`SOL-P007`, §8.3): the author MUST state what the actor does instead, because negated instructions are a documented model-inversion risk (§7.6).

### 7.4 The "same line makes it observable" rule (normative)

A high-risk word (§7.3) appearing in a **binding** clause is permitted **if and only if** the same sentence, the same bullet, or the immediately-following line converts it into observable behavior by supplying at least one of:

1. an **actor + action + object** triple (who does what to what), or
2. a **measurable threshold** (a number, bound, rate, or comparison with units), or
3. a **named verification target** (a `VERIFY BY` binding, §15, or a named test/contract/metric).

If none of these is present on the same line, the word is a **blocking `SOL-P005`** (or `SOL-P056` for an unbaselined comparative, or `SOL-P004` for a bundling connective).

The repair MUST be a **named improve operation** (§10) — `CONCRETIZE` (replace the vague word with observable behavior) or `QUANTIFY` (replace an unbounded quality with a threshold) — with an explicit exit condition. An author or tool MUST NOT resolve `SOL-P005` by open-ended stylistic rewriting; the defect is a missing observable criterion, and only `CONCRETIZE`/`QUANTIFY` close it.

```text
Blocking (high-risk "fast" in a binding clause, no same-line criterion):
  REQ AC-002:
  THE search endpoint MUST be fast        -> SOL-P005 (blocking)

Permitted via QUANTIFY (same-line measurable threshold):
  REQ AC-002:
  WHEN the index holds <= 1,000,000 rows
  THE search endpoint MUST return results within a 200 ms p95 latency
  VERIFY BY perf:cmdBenchmark:search-latency.bench#p95
```

### 7.5 APS rule families mapped to `SOL-P` codes (normative)

Every APS rule family resolves to exactly one prose-layer lint code in the unified taxonomy (§8). `APS-` codes are retired (§8.5); the mapping below is canonical and supersedes the earlier `APS-*` table. Full definitions live in §8.2–§8.4; the legacy translation table lives in Appendix B.

| APS rule family | `SOL-P` code | Severity | Repair op (§10) |
|---|---|---|---|
| Dangling condition (trigger, no modal consequence) | `SOL-P001` | BLOCKING | author rewrite / `NORMALIZE` |
| Missing actor | `SOL-P002` | BLOCKING | `CONCRETIZE` |
| Missing / informal modality (`should`→`SHOULD`) | `SOL-P003` | BLOCKING | `NORMALIZE` |
| Bundled / overloaded obligation (connectives) | `SOL-P004` | BLOCKING | `ATOMIZE` |
| Vague-quality word, no same-line observable | `SOL-P005` | BLOCKING | `CONCRETIZE` / `QUANTIFY` |
| Undefined term in a binding clause | `SOL-P006` | BLOCKING | `CLARIFY` / `BIND` (glossary) |
| Negation ambiguity (bare `MUST NOT`) | `SOL-P007` | BLOCKING | `CLARIFY` (pair affirmative) |
| Uncaptured behavioral uncertainty not lifted to `QUESTION` | `SOL-P008` | BLOCKING | `CLARIFY` |
| Pronoun / vague reference | `SOL-P050` | ADVISORY | `CONCRETIZE` |
| Passive voice | `SOL-P051` | ADVISORY | `NORMALIZE` |
| Sentence length (> ~20 words) | `SOL-P052` | ADVISORY | `ATOMIZE` / `COMPRESS` |
| Non-present / non-active tense | `SOL-P053` | ADVISORY | `NORMALIZE` |
| Prose noise (decorative phrase) | `SOL-P054` | ADVISORY | `COMPRESS` |
| Redundancy (repeated context, no new constraint) | `SOL-P055` | ADVISORY | `COMPRESS` |
| Comparative / superlative without baseline | `SOL-P056` | ADVISORY in commentary, **BLOCKING in a binding clause** | `QUANTIFY` |
| Terminology drift (term inconsistent with `memory/glossary.md`) | `SOL-P057` | ADVISORY | `NORMALIZE` |

Cross-layer companions an APS reviewer commonly meets (defined in §8): `SOL-M001` actor/object incompleteness, `SOL-M002` contradiction, `SOL-V001` no verification path.

### 7.6 Rationale anchor (normative framing) and the superseded figure

APS exists because of a **durable mechanism**, not a transient capability ceiling. Specifications, refs, and ADRs that justify APS MUST anchor on the following five properties, and MUST NOT anchor on any dated model-accuracy number:

1. **Format and order sensitivity** — meaning-preserving reformatting alone changes few-shot accuracy by up to 76 points (LLaMA-2-13B) and ~10 points on average across 50+ tasks, with format performance only weakly correlated between models `[SCLAR]` (cf. the older model-specific ~40% figure for GPT-3.5-turbo on code translation `[FORMAT]`); example/prompt ordering can independently swing results between near-SOTA and random `[PROMPTORDER]`; controlled, predictable prose shape reduces this variance.
2. **Multi-turn decay** — reliability drops ≈39% across multi-turn generation `[MULTITURN]` as early loose assumptions compound; stable artifacts beat accumulating chat.
3. **Context rot / lost-in-the-middle** — relevant content buried in long inputs is used markedly less reliably than content at the beginning or end of the context `[LOSTMID]`; low-entropy prose keeps the load-bearing signal legible.
4. **Minimize always-on density to protect adherence and control cost** — every always-loaded normative line competes for adherence and is paid for on every turn; APS removes non-load-bearing words so the surviving instructions are followed and cheap.
5. **Requirement ambiguity degrades generated code** — ambiguous task descriptions drop Pass@1 by 25–30% and contradictory ones by up to 40% (GPT-4 falls from 73.8% to 6.7% on contradictory HumanEval descriptions) `[AMBIGCODE]`, with >30% degradation on frontier models across a 1,304-task ambiguity benchmark `[ORCHID]`; APS lints buried ambiguity (`SOL-P008`) and lifts it into a `QUESTION` (§6.5) before lowering, removing the defect at its source.

**Superseded figure (MUST NOT cite as a ceiling).** The IFScale "68% accuracy at 500 instructions" figure MUST NOT be cited as a capability ceiling or as the justification for APS density limits. The real finding is that instruction-following accuracy *degrades* with density — even the best frontier models reach only ~68% at 500 instructions, with a primacy bias toward earlier instructions `[IFSCALE]` — which *supports* a density cap rather than refuting it. (A non-peer-reviewed 2026 vendor re-run reports much higher counts on a keyword-inclusion proxy task `[ARIZE26]`; it is preliminary evidence only and MUST NOT be cited as an established capability ceiling.) Any numeric capability claim that survives MUST carry an "evidence as of <date>" caveat. The density discipline rests on adherence-and-cost economics (#4), not on a claim that models cannot follow many instructions.

---

## 8. The unified lint taxonomy (SOL-<LAYER><NNN>)

### 8.1 Namespace, layers, and the diagnostic record

#### 8.1.1 One prefix, five layers (normative)

Every Swarm diagnostic code MUST use the single namespace `SOL-<LAYER><NNN>`: the literal prefix `SOL`, a hyphen, one uppercase **layer letter**, and a three-digit number. There are exactly five layers, each mirroring a compiler pass 1:1 (§9), and each a **100-block** (codes numbered within `001`–`099`, `100`–`199`, … per layer), **append-only with tombstoning**: a retired code is marked tombstoned in the catalogue (Appendix B) and its number is never reused.

| Layer | Letter | Domain | Mirrors pass / phase | Block range |
|---|---|---|---|---|
| SYNTAX | `S` | Parser-detectable well-formedness | `lint` / `PARSE` | `SOL-S001…` |
| PROSE | `P` | Controlled-prose / requirement-smell, single-obligation-local (the former APS layer; absorbs old `SOL-L`) | `lint` / `NORMALIZE` | `SOL-P001…` |
| SEMANTIC | `M` | Cross-reference: duplicate id, contradiction, unbound ref | `improve` / `NORMALIZE` | `SOL-M001…` |
| VERIFICATION | `V` | Proof-binding: missing / stale / non-observable proof | `verify` / `VERIFY` | `SOL-V001…` |
| ORCHESTRATION | `O` | Planning / parallelism: write-conflict, dep cycle, blocking `QUESTION` reaching lowering | `decompose` / `LOWER` | `SOL-O001…` |

*Rationale (terse):* one tool, one greppable namespace; the layers track established requirement-quality characteristic families (design rationale) and map onto the pipeline phases — a code's letter indicates the phase it belongs to (the `O` layer is raised by any LOWER-phase pass — `lower` or `decompose` — and surfaced by the `lint` gate) and which guide repairs it.

#### 8.1.2 The diagnostic record shape (normative)

Every emitted diagnostic MUST be the object `{ code, severity, layer, span, message, suggest }`. This is the surface contract; the IR carries the same data SARIF-shaped (the `level` severity vocabulary follows SARIF `[SARIF]`) in `diagnostics[]` (§12), with `code` identical across both.

| Field | Type | Meaning |
|---|---|---|
| `code` | string | A `SOL-<LAYER><NNN>` code from this taxonomy / Appendix B |
| `severity` | enum | `error` (blocking) \| `warning` (advisory) \| `off` (after a recorded waiver, §8.6) |
| `layer` | enum | `S` \| `P` \| `M` \| `V` \| `O` (redundant with `code`'s letter; explicit for filtering) |
| `span` | object | Source location: `{ file, line_start, line_end }`, or a node id (`AC-001`) |
| `message` | string | One-line human-readable defect statement |
| `suggest` | string \| null | The named repair: an improve op (§10) or a concrete fix; `null` if none |

```json
{
  "code": "SOL-P005",
  "severity": "error",
  "layer": "P",
  "span": { "file": "auth-refresh.swarm.md", "line_start": 22, "line_end": 22 },
  "message": "Vague-quality word 'gracefully' in a binding clause with no same-line observable criterion.",
  "suggest": "CONCRETIZE: replace with actor+action+object, or bind a VERIFY BY target."
}
```

### 8.2 BLOCKING vs ADVISORY (normative)

A rule is **BLOCKING** if and only if its defect changes **what gets built** — the obligation is incomplete, non-binding, untestable, ambiguous, contradictory, or unsafe to parallelize. A blocking diagnostic carries `severity: error`, and the merge gate (§14) MUST NOT pass an artifact while any blocking diagnostic is unresolved (unless waived, §8.6). That a defect changes what gets built is detectable cheaply *before* generation: a small parameter-efficiently-finetuned classifier reaches F1 0.804 / MCC 0.745, beating frontier LLMs (≈0.47–0.52 F1), and finds under-specification the most severe defect `[SPECVALIDATOR]` — supporting BLOCKING status for actor/object incompleteness (`SOL-M001`) and uncaptured ambiguity (`SOL-P008`).

A rule is **ADVISORY** if and only if its defect affects only **how it reads** — style, length, voice, redundancy — without changing the built behavior. An advisory diagnostic carries `severity: warning` and does not block on its own.

The binding-clause vs commentary boundary (§7.2) re-classifies position-sensitive codes: `SOL-P056` (comparative without baseline) is BLOCKING inside an obligation block and ADVISORY in commentary; the high-risk word rules of §7.3–§7.4 are BLOCKING only inside binding clauses.

### 8.3 Principal BLOCKING codes (inline)

The codes below are the canonical blocking set. One-line definitions follow; the full catalogue is Appendix B.

**S layer — well-formedness:**

| Code | Defect |
|---|---|
| `SOL-S001` | Precondition (`WHEN`/`IF`/`WHILE`) with no actor clause / no modal consequence (dangling condition). |
| `SOL-S003` | Actor clause (`THE <actor> …`) with no modal verb. |
| `SOL-S005` | ID prefix does not match block type (e.g. `REQ C-001:`). |
| `SOL-S006` | `SHOULD` / `SHOULD NOT` used without an accompanying `BECAUSE` or `EXCEPT`. |
| `SOL-S012` | A `spec.swarm.md` missing a required top-level section (§21.2.1), or carrying the required sections out of mandated order (document-level companion of the per-obligation `SOL-O004`). |

**P layer — controlled prose (the blocking set `SOL-P001`–`SOL-P008`):**

| Code | Defect |
|---|---|
| `SOL-P001` | Dangling condition: trigger present, no modal consequence (prose-layer companion of `SOL-S001`). |
| `SOL-P002` | Missing actor: an action with no `THE <actor>` subject. |
| `SOL-P003` | Missing / informal modality (e.g. lowercase `should` where a binding modal is intended). |
| `SOL-P004` | Bundled / overloaded obligation: separable obligations joined by `and`/`or`/`and/or` in one clause. |
| `SOL-P005` | Vague-quality / high-risk word in a binding clause with no same-line observable criterion (§7.3–§7.4). |
| `SOL-P006` | Undefined term used in a binding clause (no `TERM` / `memory/glossary.md` definition). |
| `SOL-P007` | Negation ambiguity: bare `MUST NOT` not paired with the affirmative behavior that should happen instead. |
| `SOL-P008` | Uncaptured behavioral uncertainty: an ambiguity stated in prose that should be lifted to a `QUESTION` block. |

**M layer — semantic:**

| Code | Defect |
|---|---|
| `SOL-M001` | Actor / object incompleteness: the obligation names a modal but not a resolvable actor *and* object. |
| `SOL-M002` | Contradiction: two obligations bind opposite outcomes to the same trigger/state, or trace/code disagrees with an obligation. |

**V layer — verification:**

| Code | Defect |
|---|---|
| `SOL-V001` | Missing verification path: a binding obligation (`REQ`/`CONSTRAINT`/`INVARIANT`) with no `VERIFY BY` (§15). |

**O layer — orchestration:**

| Code | Defect |
|---|---|
| `SOL-O001` | Write-conflict marked parallel: two work packets sharing a write surface scheduled to run in parallel (§18). |
| `SOL-O005` | Owned path outside declared write surface: a `task-orchestration.md` owned path not a subset of the assigned obligations' `WRITES` (§18, §19). |

### 8.4 Principal ADVISORY codes (inline)

The advisory prose set is `SOL-P050`–`SOL-P056`. They emit `warning` and never block on their own (subject to strict mode, §8.6).

| Code | Defect (style only) |
|---|---|
| `SOL-P050` | Pronoun / vague reference without a unique antecedent. |
| `SOL-P051` | Passive voice where an active actor+action is clearer. |
| `SOL-P052` | Sentence length exceeds ~20 words. |
| `SOL-P053` | Non-present or non-active tense. |
| `SOL-P054` | Prose noise: a decorative phrase that adds no constraint, context, or evidence. |
| `SOL-P055` | Redundancy: repeated context that adds no new constraint. |
| `SOL-P056` | Comparative / superlative without a baseline — **advisory in commentary, blocking in a binding clause** (§7.2). |

### 8.5 `APS-` retirement and the full catalogue

`APS-` is **retired as a code prefix.** "APS" survives only as the *name* of the prose standard (§7); it MUST NOT appear in any diagnostic code. Every legacy `APS-*` code, every flat legacy research code (`SOL101`/`SOL201`/`SOL301`), and every legacy `SOL-L###` code is remapped into the `SOL-<LAYER><NNN>` namespace. The complete per-layer catalogue and the full legacy translation table (e.g. `APS-A001→SOL-P005`, `APS-O001→SOL-P004`, `APS-P001→SOL-P054`, `APS-R001→SOL-P055`, `APS-Q001→SOL-P008`, `APS-V001→SOL-V001`, `APS-X001→SOL-M002`, `SOL-L###→SOL-P###`) live in **Appendix B**. Tools and authors MUST cite only the unified codes; the legacy codes are non-normative aliases retained for migration only.

### 8.6 Severity override and the waiver record (normative)

Default severities (§8.2–§8.4) are fixed by this specification. A project MAY adjust them only through one configuration surface — a root `swarm.config.json`/`swarm.config.yaml`, or equivalently the `lint:` section of the adopted-project `.swarm/config.yaml` (§20.5.1) — validated against the schema below. There are exactly two legal adjustments:

1. **Promote (strict mode):** raise an ADVISORY code to `error`. Always permitted; no record required beyond the config entry.
2. **Demote (waiver):** lower a BLOCKING code to `warning` or `off`. Permitted **only** with a recorded waiver carrying an authority, a reason, and an expiry. A demotion without a complete waiver record is itself a conformance defect.

A `swarm.config` MUST NOT redefine, rename, or invent codes; it MUST NOT change a code's `layer`; and it MUST NOT demote a blocker by any means other than a waiver record.

```json
{
  "$schema": "swarm.config/0.1",
  "language": "SOL/0.1",
  "severity_overrides": {
    "SOL-P052": "error",        // strict: promote advisory -> error
    "SOL-P056": "error"
  },
  "waivers": [
    {
      "code": "SOL-V001",
      "scope": "AC-014",                 // code OR a specific obligation id / glob
      "to": "warning",                   // warning | off
      "authority": "spec-owner:j.costa", // human or spec owner (see §14 / G5)
      "reason": "Upstream metrics adapter not yet wired; manual check tracked in TASK-22.",
      "expiry": "2026-07-01",            // ISO date; auto-expires (see below)
      "recorded_at": "2026-05-31"
    }
  ]
}
```

The **waiver-record fields** are: `code` (required), `scope` (required — a code applies repo-wide; an obligation id/glob narrows it), `to` (required, `warning` or `off`), `authority` (required), `reason` (required), `expiry` (required, ISO date), `recorded_at` (required). A waiver with any required field missing is invalid and the demotion does not take effect. Consistent with the verdict model (§14) and G5, a waiver **auto-expires** at its `expiry` date *and* on the next change to the waived obligation's source content-hash (whichever comes first), preventing zombie waivers; on expiry the code returns to its default severity. A severity demotion at the lint layer is distinct from a `WAIVED` verdict at the verification layer (§14): the former silences a *diagnostic*, the latter accepts a *failing proof* — both require the same authority+reason+expiry discipline.

*Rationale (terse):* one config, two legal moves — strict-up freely, blocking-down only on the record — keeps every relaxation of the kernel's defaults auditable, time-boxed, and attributable.
