# Swarm Kernel Specification v0.1 — Part 10: Appendices A–G

<!-- Part 10 of the Swarm Kernel Specification (App. A–G). All parts share one section numbering (§0–§35 + Appendices A–G); cross-references of the form “§N” resolve via the index in [README.md](./README.md). -->

## Appendix A — Consolidated SOL grammar (EBNF)

This appendix is the single normative grammar for the SOL surface syntax (the human-authored `.swarm.md` language). It supersedes the three competing grammars in the research corpus (the fenced `:::TYPE …:::END` + in-block YAML form, the significant-indentation `Indent`/`Dedent` form, and the colon-less header form); each of those is non-conformant. A conformant `.swarm.md` parser MUST accept exactly the language this grammar generates and MUST reject any input outside it. The IR/JSON layer is NOT specified here — see §12 and Appendix C; surface keywords are space-separated uppercase, IR fields are snake_case (per the master surface-vs-IR layering, §3, §4).

The grammar is **line-oriented**: a block is a bare header line `TYPE PREFIX-NNN:` followed by contiguous non-blank body lines, terminated by the next block header, a blank line, or a Markdown heading (`#`). There is no closing delimiter and no significant indentation. Keywords are UPPERCASE and case-sensitive; lowercase `must`/`should`/`may` and lowercase keywords carry no force and are parsed as prose (§5, §7). In v0.1 the arguments of conditions (`WHERE`/`WHILE`/`WHEN`/`IF`) are **opaque text** (`condition_text` below): the structured expression sublanguage and the timing keywords (`WITHIN`, `BEFORE`, `UNTIL`, `IMMEDIATELY`, `EVENTUALLY`) are deferred to v0.2 (see §35, Appendix E).

### A.1 Normative EBNF

```ebnf
(* ===== Document and frontmatter ===== *)
document          = [ frontmatter ], { markdown_line | blank | surface_decl | block };

frontmatter       = "---", nl,
                    fm_language, fm_aps, fm_spec_version,
                    { fm_other },
                    "---", nl;
fm_language       = "swarm_language", ":", ws, "SOL/", version_num, nl; (* discriminator, e.g. SOL/0.1 *)
fm_aps            = "aps_version", ":", ws, version_num, nl;             (* e.g. 0.1 *)
fm_spec_version   = "spec_version", ":", ws, semver, nl;                 (* content version, e.g. 0.1.0 *)
fm_other          = yaml_key, ":", ws, yaml_scalar, nl;                  (* spec id, title, status, owners, imports *)

markdown_line     = ? any line not beginning a block header and not "---" ?, nl;
blank             = ws, nl;

(* ===== Surface declarations (lock groups are named SURFACEs; there is no `locks` primitive) ===== *)
surface_decl      = "SURFACE", ws, surface_name, ws, "=", ws,
                    glob, { ws, ",", ws, glob },
                    [ ws, "[", surface_attr, "]" ], nl;     (* attr per G7: append-only|integration|shared *)
surface_attr      = "append-only" | "integration" | "shared";

(* ===== Block: bare header dispatches to a type-specific, line-grouped body =====
   The body of any block is the maximal run of contiguous non-blank lines after the
   header, terminated by the next block_header, a blank line, or a Markdown heading.
   The header type selects which body production those grouped lines MUST satisfy. *)
block             = ( req_header, nl, req_body        )
                  | ( constraint_header, nl, constraint_body )
                  | ( invariant_header, nl, invariant_body  )
                  | ( interface_header, nl, interface_body  )
                  | ( question_header, nl, question_body   )
                  | ( trace_header, nl, trace_body      )
                  | ( verdict_header, nl, verdict_body    );

req_header        = "REQ", ws, req_id, ":";
constraint_header = "CONSTRAINT", ws, constraint_id, ":";
invariant_header  = "INVARIANT", ws, invariant_id, ":";
interface_header  = "INTERFACE", ws, interface_id, ":";
question_header   = "QUESTION", ws, question_id, ws, question_tag, ":";
trace_header      = "TRACE", ws, trace_id, ":";
verdict_header    = "VERDICT", ws, obligation_id, ":", ws, verdict_value; (* value on header line *)

(* ===== Identifiers: per-type short prefixes. Surface ids only; IR ids may be namespaced. ===== *)
req_id            = "AC-", digits;
constraint_id     = "C-", digits;
invariant_id      = "I-", digits;
interface_id      = "IF-", digits;
question_id       = "Q-", digits;
trace_id          = "T-", digits;
obligation_id     = req_id | constraint_id | invariant_id;   (* VERDICT reuses the judged obligation id *)
cross_spec_ref    = spec_id, ":", ( req_id | constraint_id | invariant_id
                                    | interface_id | question_id | trace_id );
digits            = digit, { digit };

(* ===== REQ clause grammar, in canonical order ===== *)
req_body          = [ where_clause ]
                    [ while_clause ]
                    [ when_clause ]
                    [ if_clause ]
                    actor_clause
                    { and_actor_clause }      (* AND THE …: permitted; lowered to multiple IR obligations (G3) *)
                    [ because_clause ]
                    [ except_clause ]
                    verify_line
                    { metadata_clause };

where_clause      = "WHERE", ws, condition_text, nl;
while_clause      = "WHILE", ws, condition_text, nl;
when_clause       = "WHEN", ws, condition_text, nl;        (* THEN forbidden after WHEN *)
if_clause         = "IF", ws, condition_text, [ ws, "THEN" ], nl; (* THEN optional sugar after IF only *)
condition_text    = ? opaque free text, one line (no structured expression in v0.1) ?;

actor_clause      = "THE", ws, actor, ws, modal, ws, response, nl;
and_actor_clause  = "AND", ws, "THE", ws, actor, ws, modal, ws, response, nl;
actor             = ? noun phrase naming the responsible agent/system ?;
response          = ? verb phrase: the required behavior ?;

because_clause    = "BECAUSE", ws, prose_text, nl;          (* mandatory companion to SHOULD/SHOULD NOT *)
except_clause     = "EXCEPT", ws, prose_text, nl;          (* alternative companion to SHOULD/SHOULD NOT *)

(* ===== CONSTRAINT ===== *)
constraint_body   = actor_clause
                    { and_actor_clause }
                    [ because_clause ]
                    [ except_clause ]
                    verify_line
                    { metadata_clause };

(* ===== INVARIANT: <property> MUST|MUST NOT <hold> (no ALWAYS/NEVER) ===== *)
invariant_body    = property, ws, inv_modal, ws, hold_text, nl,
                    verify_line,
                    { metadata_clause };
property          = ? noun phrase naming the invariant property/state ?;
inv_modal         = "MUST" | "MUST NOT";                       (* only these two for INVARIANT *)
hold_text         = ? verb phrase asserting the held property ?;

(* ===== INTERFACE: RETURNS, ACCEPTS, ERRORS, OWNED BY; requires VERIFY BY contract (Theme-5 gap-fill) ===== *)
interface_body    = signature, ws, "RETURNS", ws, type_ref, nl,
                    [ accepts_block ]
                    [ errors_block ]
                    verify_line,                                (* MUST be a contract: proof (lint SOL-V…) *)
                    [ owned_by_clause ]
                    { metadata_clause };
signature         = "`", ? function/endpoint signature ?, "`";
type_ref          = "`", ? type expression ?, "`" | bare_type;
accepts_block     = "ACCEPTS:", nl, list_item, { list_item };
errors_block      = "ERRORS:", nl, list_item, { list_item };
list_item         = ws, "-", ws, prose_text, nl;
owned_by_clause   = "OWNED BY", ws, owner_ref, nl;

(* ===== QUESTION: tag + AFFECTS ===== *)
question_tag      = "[", ( "blocking" | "non-blocking" ), "]";  (* lowercase tag, on the header line *)
question_body     = question_text, nl,
                    "AFFECTS", ws, ref_list, nl;
question_text     = ? opaque free text stating the ambiguity ?;

(* ===== TRACE: IMPLEMENTS, PRESERVES, CHANGED, PROOF ===== *)
trace_body        = "IMPLEMENTS", ws, ref_list, nl,
                    [ "PRESERVES", ws, ref_list, nl ]
                    [ "CHANGED", ws, path_list, nl ]
                    proof_line, { proof_line };
proof_line        = "PROOF", ws, verify_ref, ws, proof_result, nl;
proof_result      = "passed" | "failed" | "blocked" | "unverified";

(* ===== VERDICT: core value on header; REASON, EVIDENCE in body ===== *)
verdict_body      = "REASON", ws, prose_text, nl,
                    "EVIDENCE", ws, evidence_ref, nl;
verdict_value     = verdict_core, [ ws, verdict_lifecycle ];
verdict_core      = "PASS" | "FAIL" | "BLOCKED" | "UNVERIFIED";
verdict_lifecycle = "(", lifecycle, " by ", authority, ": ", reason, ")";
lifecycle         = "WAIVED" | "STALE" | "CONTRADICTED";

(* ===== VERIFY BY binding : typed, closed 9-set ===== *)
verify_line       = "VERIFY BY", ws, verify_ref, nl;
verify_ref        = proof_type, ":", adapter, ":", artifact, [ "#", selector ];
proof_type        = "static" | "test" | "contract" | "property" | "model"
                  | "perf"   | "security" | "manual" | "monitor";          (* closed; no other type is legal *)
adapter           = ? project free-string; resolves through AGENTS.md > Commands (cmd* slot) ?;
artifact          = ? project free-string; file/target the adapter runs ?;
selector          = ? optional sub-target, e.g. a test name or invariant name ?;
(* test scope qualifiers are spelled in the adapter position: test:unit:… test:integration:… test:e2e:… *)

(* ===== Trailing metadata clauses (surface = space-separated UPPERCASE) ===== *)
metadata_clause   = depends_on | touches | writes | reads | affects | risk;
depends_on        = "DEPENDS ON", ws, ref_list, nl;
touches           = "TOUCHES", ws, surface_list, nl;
writes            = "WRITES", ws, surface_list, nl;
reads             = "READS", ws, surface_list, nl;
affects           = "AFFECTS", ws, ref_list, nl;
risk              = "RISK", ws, ( "low" | "medium" | "high" | "critical" ), nl;

(* ===== Modal terminals: exactly five. SHALL / SHALL NOT removed; CAN / WILL are NOT modals. ===== *)
modal             = "MUST NOT" | "MUST" | "SHOULD NOT" | "SHOULD" | "MAY"; (* longest-match: NOT before bare *)
(* "SHALL", "SHALL NOT": illegal as modals (lint SOL-S003-family / removed).                              *)
(* "CAN", "WILL": non-modal; if used as a modal in a binding clause, lint SOL-P003 (informal force). *)

(* ===== Shared lexical productions ===== *)
ref_list          = ref, { ws, ",", ws, ref };
ref               = req_id | constraint_id | invariant_id | interface_id
                  | question_id | trace_id | cross_spec_ref;
surface_list      = surface_ref, { ws, ",", ws, surface_ref };
surface_ref       = surface_name | glob;
path_list         = path, { ws, ",", ws, path };
surface_name      = ident, { ".", ident };          (* e.g. auth.code, checkout.tests *)
owner_ref         = ident, { ( "-" | ":" | "/" ), ident }; (* surface / team / module *)
evidence_ref      = ? reference to proof output, log, or artifact ?;
authority         = ? human name or spec-owner / profile id ?;
reason            = ? one-line justification text ?;
prose_text        = ? free APS-governed prose (§7) ?;
spec_id           = ident;
ident             = letter, { letter | digit | "-" | "_" };
bare_type         = ident;
glob              = ? path glob, e.g. src/auth/** ?;
path              = ? repository-relative file path ?;
semver            = digits, ".", digits, ".", digits;
version_num       = digits, ".", digits;
digit             = "0" | "1" | "2" | "3" | "4" | "5" | "6" | "7" | "8" | "9";
letter            = ? Unicode letter ?;
yaml_key          = ident;
yaml_scalar       = ? YAML scalar value ?;
ws                = ( " " | "\t" ), { " " | "\t" };
nl                = "\n" | "\r\n";
```

### A.2 Lint constraints attached to grammar productions

Each grammar production carries one or more well-formedness checks from the unified lint namespace `SOL-<LAYER><NNN>` (§8, Appendix B). The codes below are the canonical, renumbered identifiers; the legacy `SOL-S007`/`SOL-S010` syntax codes are remapped into the `SOL-V` verification layer because a missing or malformed proof binding is a verification defect, not a parse defect. A `SOL-S###` code is raised when the input cannot be parsed by the production; a `SOL-P###`/`SOL-V###` code is raised when the input parses but violates a higher-layer rule.

| Code | Layer | Severity | Production / trigger | Diagnostic |
|------|-------|----------|----------------------|------------|
| `SOL-S001` | SYNTAX | BLOCKING | `where_clause`/`while_clause`/`when_clause`/`if_clause` present with no following `actor_clause` | Precondition (`WHERE`/`WHILE`/`WHEN`/`IF`) with no actor clause; add `THE <actor> <MODAL> <response>`. |
| `SOL-S002` | SYNTAX | BLOCKING | `actor_clause` missing the `THE <actor>` head after a trigger | Missing actor after trigger; use `THE <actor>`. |
| `SOL-S003` | SYNTAX | BLOCKING | `actor_clause`/`and_actor_clause` with no `modal` terminal | Actor clause with no modal; use `MUST`, `MUST NOT`, `SHOULD`, `SHOULD NOT`, or `MAY` (`SHALL`/`CAN`/`WILL` are not modals). |
| `SOL-S004` | SYNTAX | BLOCKING | Two `block_header` productions share the same `*_id` within one spec file | Duplicate block ID (intra-spec); renumber the second block. (Cross-spec collisions are `SOL-M001`.) |
| `SOL-S011` | SYNTAX | BLOCKING | `block_header` with no `*_id` | Missing obligation ID after the block type; add `PREFIX-NNN:`. |
| `SOL-S005` | SYNTAX | BLOCKING | `*_id` prefix does not match `block_header` type (e.g. `CONSTRAINT AC-001:`) | ID prefix/block-type mismatch; `REQ→AC-`, `CONSTRAINT→C-`, `INVARIANT→I-`, `INTERFACE→IF-`, `QUESTION→Q-`, `TRACE→T-`. |
| `SOL-S006` | SYNTAX | BLOCKING | `actor_clause` modal is `SHOULD`/`SHOULD NOT` with no `because_clause` or `except_clause` in the same block | `SHOULD`/`SHOULD NOT` used without `BECAUSE` or `EXCEPT`. |
| `SOL-S009` | SYNTAX | BLOCKING | `trace_body` `IMPLEMENTS`/`PRESERVES` `ref` resolving to no known obligation | `TRACE` references an unknown obligation ID. |
| `SOL-P003` | PROSE | BLOCKING | `modal` slot filled by `CAN`/`WILL` or a lowercase/informal modal in a binding clause | Missing or informal modality in a binding clause; use a real uppercase modal. |
| `SOL-P004` | PROSE | ADVISORY (warning) | `req_body`/`constraint_body` with more than two chained `and_actor_clause` (per G3) | Bundled/overloaded obligation; `AND THE` chaining beyond two — consider `ATOMIZE` into separate obligations (permitted, lowered to multiple IR obligations). |
| `SOL-V001` | VERIFICATION | BLOCKING | binding obligation (`REQ`/`CONSTRAINT`/`INVARIANT`/`INTERFACE`) with no `verify_line` (was `SOL-S007`) | Missing `VERIFY BY` for a binding obligation. |
| `SOL-V009` | VERIFICATION | BLOCKING | `verify_ref` whose `proof_type` is outside the closed 9-set | Unknown proof type; use one of `static, test, contract, property, model, perf, security, manual, monitor`. |
| `SOL-V005` | VERIFICATION | BLOCKING | `verdict_value` `verdict_core` outside the four core values, or `verdict_lifecycle` missing a mandatory field (was `SOL-S010`) | `VERDICT` value outside `PASS`/`FAIL`/`BLOCKED`/`UNVERIFIED`, or a lifecycle decorator missing authority/reason (`WAIVED` also requires expiry). |
| `SOL-V006` | VERIFICATION | BLOCKING | `INTERFACE` `verify_line` whose `proof_type` ≠ `contract` (Theme-5 gap-fill) | `INTERFACE` MUST be verified by a `contract:` binding. |

Notes on opacity and deferral (normative for v0.1):

1. `condition_text`, `question_text`, `response`, `hold_text`, and `prose_text` are **opaque single-line text** in v0.1. No structured expression grammar (operators, comparisons, `AND`/`OR`) is defined; a parser MUST NOT attempt to tokenize their interior. The expression sublanguage is deferred to v0.2 (§35).
2. Timing keywords `WITHIN`, `BEFORE`, `UNTIL`, `IMMEDIATELY`, `EVENTUALLY` are **not productions in this grammar**; they are reserved for v0.2 (FRETish temporal semantics). Their appearance in a `.swarm.md` is parsed as opaque prose and SHOULD raise an advisory pointing to the deferral.
3. `ALWAYS`/`NEVER` (legacy INVARIANT openers), `EXPOSES`/`INPUT`/`OUTPUT` (legacy INTERFACE), and `MAP`/`TO`/`ORDER`/`ASK` (legacy TASK-MAP/QUESTION) are removed and have no production; they MUST be rejected.
4. `THEN` is legal only as the optional trailing sugar of `if_clause`; after `WHEN`/`WHILE` it MUST be rejected as a parse error.

## Appendix B — Full lint-code catalogue and legacy translation table

This appendix is the normative catalogue of every v0.1 lint diagnostic. It is the authority for tool authors who build a `lint-spec` checker (a CONTRACT, never shipped by this repo — see §17) and for the conformance corpus (§33). Section numbers in cross-references resolve against the document outline (for example §8 is the lint-taxonomy chapter that frames these codes; §10 the improve ops; §14 verdicts; §18 orchestration).

### B.1 Namespace, layers, and the diagnostic record

A conformant Swarm lint code MUST match the single grammar:

```ebnf
lint_code = "SOL-", layer, number;
layer     = "S" | "P" | "M" | "V" | "O";
number    = digit, digit, digit;          (* zero-padded, 3 digits *)
```

There is exactly one prefix (`SOL-`) and exactly five layer letters. `APS-` is retired as a *code* prefix; `APS` survives only as the name of the controlled-prose standard (§7). The five layers and their 1:1 mapping to compiler phases (§9) are fixed:

| Layer | Name | Detects | Phase it guards |
|---|---|---|---|
| `S` | SYNTAX | Parser-detectable well-formedness of a single block | `PARSE` |
| `P` | PROSE | Controlled-prose / requirement-smell, single-obligation-local (the former APS layer; absorbs `SOL-L###`) | `NORMALIZE` (`lint`/`improve`) |
| `M` | SEMANTIC | Cross-reference defects: duplicate id, contradiction, unbound ref | `NORMALIZE` |
| `V` | VERIFICATION | Proof-binding defects: missing / stale / non-observable proof | `VERIFY` |
| `O` | ORCHESTRATION | Planning / parallelism defects: write-conflict-marked-parallel, dep cycle, blocking QUESTION reaching lowering | `LOWER` |

#### B.1.1 100-block allocation, append-only, tombstoning

Each layer is a 100-block. Within `SOL-P###`, codes `001`–`049` are reserved for BLOCKING prose rules and `050`–`099` for ADVISORY prose rules; this split is normative for the P layer only. The catalogue is **append-only**: a code, once published, MUST NOT be renumbered, MUST NOT change layer, and MUST NOT have its meaning silently repurposed. A retired code MUST be **tombstoned** — its row is retained with the marker `TOMBSTONED` in the short-name column, a `superseded-by` pointer where one exists, and the number MUST NOT be reissued. Rationale: one tool, one greppable namespace, stable across versions (ESLint/Clippy append-only-with-tombstone convention).

#### B.1.2 Diagnostic record shape

Every diagnostic a checker emits MUST be a record of exactly this shape, and the IR `diagnostics[]` array (§12) MUST carry records of this shape:

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

| Field | Type | Meaning |
|---|---|---|
| `code` | string | The `SOL-<LAYER><NNN>` code (B.1). |
| `severity` | `"BLOCKING"` \| `"ADVISORY"` | Effect on the build, per B.1.3. |
| `layer` | `"S"`\|`"P"`\|`"M"`\|`"V"`\|`"O"` | MUST equal the code's layer letter (redundant-but-checkable). |
| `span` | object | Source location: at minimum `{file, block}`; `line`/`col` SHOULD be present when available. |
| `message` | string | Human-readable one-line defect description. |
| `suggest` | string | The improve op (§10) or fix that resolves it; MUST name a closed op where one applies, never an open-ended rewrite. |

#### B.1.3 Severity model

Severity is **binary and intrinsic**: a rule is `BLOCKING` iff the defect changes *what* gets built (incomplete / non-binding / untestable / ambiguous / unschedulable); `ADVISORY` iff it only affects *how the text reads*. BLOCKING diagnostics MUST fail the relevant gate (lint gate for S/P/M, merge gate for V/O — §14); ADVISORY diagnostics MUST NOT block by default.

- The legacy `Error`/`Warning` axis maps onto this: legacy `Error` → `BLOCKING`, legacy `Warning` → `ADVISORY` (with the re-layerings overriding the *code*, not the severity intent).
- **Project severity overrides** (G1) are permitted: a project MAY promote an ADVISORY to BLOCKING (strict mode) or demote a BLOCKING via a recorded waiver, through the `swarm.config` waiver schema (deferred-precise to v0.2; the default severities in this appendix are normative until overridden).
- **Binding-clause vs commentary** (G2): a span is *binding* iff it lies inside a typed obligation block (REQ / CONSTRAINT / INVARIANT); otherwise it is *commentary*. Codes flagged "binding-only" below fire as BLOCKING in a binding span and are suppressed (or downgraded to ADVISORY where noted) in commentary.

### B.2 Layer S — SYNTAX (parser well-formedness)

These fire at `PARSE`; all are BLOCKING (a malformed block cannot be parsed into a node). Resolution is a direct edit to fix the structure — no improve op applies (improve ops operate on already-parseable obligations).

| Code | Severity | Short name | Definition | Resolves by |
|---|---|---|---|---|
| `SOL-S001` | BLOCKING | dangling-precondition (syntax) | A trigger clause (`WHERE`/`WHILE`/`WHEN`/`IF`) is present but no `THE <actor> <MODAL> <response>` actor-clause follows in the block. | Edit: add the missing actor-clause. (Prose-layer companion: `SOL-P001`.) |
| `SOL-S002` | BLOCKING | unknown-block-or-keyword | Block header is not one of the 7 types, or a body line uses an unknown/malformed clause keyword. | Edit: use a valid block type (§6) / clause keyword (§5). |
| `SOL-S003` | BLOCKING | actor-clause-no-modal | An actor-clause is present with no modal (`MUST`/`MUST NOT`/`SHOULD`/`SHOULD NOT`/`MAY`). | Edit: insert a valid modal (§5). (Note: multiple chained `AND THE` modals are *permitted* and lowered to several IR obligations, G3; only total absence of a modal trips S003.) |
| `SOL-S004` | BLOCKING | duplicate-block-id | Two blocks share the same surface id within one spec (intra-spec duplicate). | Edit: renumber. (Cross-spec collisions are `SOL-M001`.) |
| `SOL-S011` | BLOCKING | missing-obligation-id | A block header is present but carries no `*_id` after the block type (block type is recognized but ID is absent). | Edit: add a valid `PREFIX-NNN` id after the block type. |
| `SOL-S012` | BLOCKING | required-section-missing | A `spec.swarm.md` is missing a required top-level section from the ordered set of §21.2.1 (e.g. `## Intent`, `## Non-goals`, `## Obligations`), or carries them out of order. Document-level structural defect, distinct from the per-obligation scope gap `SOL-O004`. | Edit: add the missing `## ` section heading (or reorder) per §21.2.1. |
| `SOL-S005` | BLOCKING | prefix↔type-mismatch | The id prefix does not match the block type (e.g. `REQ C-001:`). | Edit: use the canonical prefix (REQ→`AC-`, CONSTRAINT→`C-`, INVARIANT→`I-`, INTERFACE→`IF-`, QUESTION→`Q-`, TRACE→`T-`). |
| `SOL-S006` | BLOCKING | should-without-because | `SHOULD`/`SHOULD NOT` used without an accompanying `BECAUSE` or `EXCEPT` clause in the same block (§5.6). | Edit: add a `BECAUSE` or `EXCEPT` clause, or strengthen to `MUST`/`MUST NOT`. |
| `SOL-S007` | BLOCKING | malformed-header | Block header is missing the mandatory trailing colon, or the id is malformed (spaces, illegal characters). | Edit: write `TYPE PREFIX-NNN:`. |
| `SOL-S008` | BLOCKING | non-control-first-line | The first non-empty line of a block is not a control sentence (metadata or prose appears before the obligation sentence). | Edit: lead with the actor-clause / control sentence. |
| `SOL-S010` | BLOCKING | unknown-metadata-field | A trailing metadata field is not one of the closed set (`DEPENDS ON`/`TOUCHES`/`WRITES`/`READS`/`AFFECTS`/`RISK`/`OWNED BY`). | Edit: use a valid field (§5) or move the text to commentary. |

Note: legacy `SOL-S007`/`SOL-S010` (verification / verdict-value checks) and legacy `SOL-S008` (planner parallelism) do **not** keep these S-numbers — they re-layer to V and O respectively (see B.6). The S007/S008 rows above are the *re-allocated* v0.1 syntax meanings; `SOL-S010` is re-allocated from the legacy verdict-value check (now `SOL-V005`) to `unknown-metadata-field`.

### B.3 Layer P — PROSE (controlled-prose / requirement-smell)

P-layer rules are single-obligation-local. `001`–`049` are BLOCKING; `050`–`099` are ADVISORY. Each maps to a closed improve op (§10), never an open rewrite.

#### B.3.1 Blocking prose rules

| Code | Severity | Short name | Definition | Resolves by |
|---|---|---|---|---|
| `SOL-P001` | BLOCKING | dangling-condition | A trigger with no modal *consequence* at the prose level (semantically empty even if syntactically a sentence). | `CLARIFY` / `ATOMIZE`: supply the consequence. |
| `SOL-P002` | BLOCKING | missing-actor | The obligation has no responsible actor. | `CONCRETIZE`: name the actor. |
| `SOL-P003` | BLOCKING | missing/informal-modality | No modal, or lowercase `should`/`must`/`may` used where binding force is intended. | `NORMALIZE`: uppercase to the correct modal (was `APS-M001`). |
| `SOL-P004` | BLOCKING | bundled/overloaded-obligation | One sentence carries multiple separable obligations. | `ATOMIZE`: split into one obligation per block (was `APS-O001`; >2 chained `AND THE` also warns, G3). |
| `SOL-P005` | BLOCKING | vague-quality-no-criterion | A vague-quality / high-risk word in a binding clause with no same-line observable criterion. | `CONCRETIZE` or `QUANTIFY` (was `APS-A001`). |
| `SOL-P006` | BLOCKING | undefined-term | An undefined term used in a binding clause (not resolvable via in-file `TERM` or `memory/glossary.md`). | `CLARIFY` / `BIND`: define the term. |
| `SOL-P007` | BLOCKING | negation-ambiguity | A bare `MUST NOT` whose scope is ambiguous; not paired with the affirmative behavior. | `CLARIFY`: state the affirmative alongside the prohibition. |
| `SOL-P008` | BLOCKING | uncaptured-uncertainty | Behavioral uncertainty left in prose, not lifted to a `QUESTION` block. | `CLARIFY`: raise a `QUESTION` (was `APS-Q001`). |

The **high-risk-word list** (the union of the brief's subjective/promotional list + Femmer loopholes & comparatives + Tjong/Berry quantifiers/connectives) and the **same-line-makes-it-observable rule** govern `SOL-P005`/`SOL-P056`: a high-risk word is permitted only when the same sentence, bullet, or immediately-following line converts it to observable behavior (actor+action+object, a measurable threshold, or a named verification target); otherwise the rule fires BLOCKING and is fixed by `CONCRETIZE`/`QUANTIFY` — never an open-ended rewrite.

#### B.3.2 Advisory prose rules

| Code | Severity | Short name | Definition | Resolves by |
|---|---|---|---|---|
| `SOL-P050` | ADVISORY | pronoun | Vague pronoun with non-unique antecedent. | `CLARIFY` (was `APS-A002` / `SOL-L103`). |
| `SOL-P051` | ADVISORY | passive-voice | Passive voice in an obligation sentence. | `NORMALIZE` (was `SOL-L105`). |
| `SOL-P052` | ADVISORY | sentence-length | Obligation sentence exceeds ~20 words. | `COMPRESS` / `ATOMIZE`. |
| `SOL-P053` | ADVISORY | non-present-non-active | Non-present-tense or non-active phrasing. | `NORMALIZE`. |
| `SOL-P054` | ADVISORY | prose-noise | Decorative phrase that adds no constraint. | `COMPRESS` (was `APS-P001`). |
| `SOL-P055` | ADVISORY | redundancy | Repeated context that adds no constraint. | `COMPRESS` (was `APS-R001`). |
| `SOL-P056` | ADVISORY / BLOCKING | comparative-no-baseline | Comparative/superlative with no baseline. **BLOCKING in a binding clause, ADVISORY in commentary** (G2). | `QUANTIFY`: supply the baseline. |
| `SOL-P057` | ADVISORY | terminology-drift | A term in a binding clause or commentary is used inconsistently with its `memory/glossary.md` definition (a synonym, casing variant, or competing label for an already-defined term). Advisory: the term still resolves, so it is not the blocking `SOL-P006` undefined-term defect. | `NORMALIZE`: replace the variant with the canonical glossary term. |

### B.4 Layer M — SEMANTIC (cross-reference)

M-layer rules fire at `NORMALIZE` after all blocks are parsed; they are cross-obligation. All BLOCKING (a broken reference or a contradiction changes what is built).

| Code | Severity | Short name | Definition | Resolves by |
|---|---|---|---|---|
| `SOL-M001` | BLOCKING | actor/object-incompleteness | A referenced actor, object, or surface is unresolved across the spec / imports (also catches cross-spec id collision). | `BIND` / `CONCRETIZE`: resolve or declare the referent (was `APS-C001` completeness + `SOL-M201`/`SOL202`). |
| `SOL-M002` | BLOCKING | contradiction | Two obligations contradict on the same normalized subject/action/object/trigger key (e.g. `MUST` vs `MUST NOT`). | `DECONFLICT` (was `APS-X001` / `SOL207` / `SOL-M202`). |
| `SOL-M003` | BLOCKING | unbound-cross-reference | A `DEPENDS ON` / `IMPLEMENTS` / `PRESERVES` reference names an id that does not exist. | `BIND`: fix the reference (was `SOL202` unresolved-dependency, kept in M). |
| `SOL-M004` | BLOCKING | authority-conflict | A lower-authority block attempts to weaken a higher-authority obligation (source-authority order, §22). | `DECONFLICT` / amendment (was `SOL206`). |

Note: legacy `SOL-M003`/`SOL-M007`/`SOL-M008` (proof-binding semantics) and `SOL-M009` (planner) do **not** retain M-numbers — they re-layer to V and O (B.6). The M003 row above is the re-allocated v0.1 meaning (unbound cross-reference), not the legacy proof-binding meaning.

### B.5 Layer V — VERIFICATION (proof-binding)

V-layer rules fire at `VERIFY`; they gate the merge gate (§14). The `VERIFY BY <type>:<adapter>:<artifact>[#selector]` binding (§15) is the subject.

| Code | Severity | Short name | Definition | Resolves by |
|---|---|---|---|---|
| `SOL-V001` | BLOCKING | no-verification-path | An obligation block (REQ/CONSTRAINT/INVARIANT) or an INTERFACE has no `VERIFY BY` binding. | `BIND`: attach a `VERIFY BY` (was `APS-V001` / `SOL204` / `SOL-V401` / `SOL-M203`). |
| `SOL-V002` | BLOCKING | proof-not-executable | The bound adapter does not resolve through AGENTS.md > Commands, or the artifact is missing. | `BIND`: point at a resolvable cmd* adapter (§15). |
| `SOL-V003` | ADVISORY / BLOCKING | non-observable-proof | The bound proof is non-observable (e.g. an INVARIANT bound only to a non-observable unit `test`). ADVISORY by default; BLOCKING under strict mode. | `BIND`: prefer `property`/`model`/`static` for INVARIANT; `contract` for INTERFACE (was `SOL-V403`). |
| `SOL-V004` | BLOCKING | stale-proof | A prior `PASS` whose evidence no longer matches the current source content-hash or a changed write-surface; surfaces as the `STALE` verdict (§16). | 3-way reconcile (re-run / amend / fix code) — never silent re-bless (was `SOL-V402` / `SOL-S007`-staleness). |
| `SOL-V005` | BLOCKING | bad-verdict-value | A `VERDICT` core value is not one of `PASS`/`FAIL`/`BLOCKED`/`UNVERIFIED`, OR a lifecycle decorator is missing its mandatory fields (WAIVED→authority+reason+expiry; STALE→prior-verdict ref+changed-surface; CONTRADICTED→two conflicting evidence refs). (was `SOL-S010`) | Edit: use a valid verdict line (§14) (was `SOL-S010`). |
| `SOL-V006` | BLOCKING | interface-without-contract | An `INTERFACE` whose `VERIFY BY` proof_type is not `contract`. | `BIND`: use `contract:` as the proof type for INTERFACE bindings (was `SOL-V403`-family). |
| `SOL-V007` | BLOCKING | invalid-lifecycle-decoration | A lifecycle decorator applied to the wrong core value (e.g. `WAIVED` on a `PASS`/`BLOCKED`, or `STALE` on anything other than a prior `PASS`). | Edit: remove or correct the lifecycle decorator per §14.1.2. |
| `SOL-V008` | BLOCKING | missing-verdict-at-merge-gate | A required `VERIFY BY` binding has no `VERDICT` at the merge gate (counts as `UNVERIFIED` at the gate; see §14.4). | `BIND`: run the proof and record a verdict, or `WAIVE`. |
| `SOL-V009` | BLOCKING | unknown-proof-type | A `verify_ref` whose `proof_type` is outside the closed 9-set (`static`, `test`, `contract`, `property`, `model`, `perf`, `security`, `manual`, `monitor`). | Edit: use one of the nine canonical proof types (§15.1). |

### B.6 Layer O — ORCHESTRATION (planning / parallelism)

O-layer rules fire at `LOWER`; they gate plan emission (§13) and safe parallelism (§18).

| Code | Severity | Short name | Definition | Resolves by |
|---|---|---|---|---|
| `SOL-O001` | BLOCKING | conflicting-tasks-parallel | The plan marks two work packets parallel that share a write surface or an interface/migration node (violates the safe-parallelism predicate, §18). Raised from Warning to ERROR per the kernel decision. | `SCOPE`: serialize, or split write surfaces (was `SOL208` / `SOL-M009` / legacy `SOL-O001` Warning). |
| `SOL-O002` | BLOCKING | dependency-cycle | A `DEPENDS ON` cycle exists in the lowered DAG. | `SCOPE` / `DECONFLICT`: break the cycle (was `SOL203` / `SOL-M205`). |
| `SOL-O003` | BLOCKING | blocking-question-reaches-lowering | An unresolved `blocking` `QUESTION` reaches the `LOWER` pass (lowering MUST NOT proceed past an open blocking question). | `CLARIFY`: answer/close the QUESTION before lowering (was `SOL-S008` / `SOL205`). |
| `SOL-O004` | ADVISORY | scope-too-broad | An obligation has no `WRITES`/`READS`/`AFFECTS`, leaving it unscoped (serializes by default and harms planning). | `SCOPE`: declare write/read/affect surfaces (was `SOL305`). |
| `SOL-O005` | BLOCKING | owned-path-outside-write-surface | A work packet writes a path outside its declared `WRITES` surface (the two-tier lowering check, G7). | `SCOPE`: declare the path, or stop writing it (new in v0.1). |
| `SOL-O006` | ADVISORY | import-policy-overlap | An imported file creates a duplicate/overlapping policy obligation. | `DECONFLICT` / `COMPRESS` (was `SOL306`). |

### B.7 Improve-op ↔ lint-code map (normative)

The closed 10-op improve set (§10) is wired to the codes above; this is the canonical detect→repair mapping (×). Each op is strictly semantics-preserving; any intent change routes to amendment/review, never improve.

| Improve op | Resolves codes |
|---|---|
| `NORMALIZE` | `SOL-P003`, `SOL-P051`, `SOL-P053` |
| `ATOMIZE` | `SOL-P004` (and `SOL-P052` by splitting) |
| `CONCRETIZE` | `SOL-P005`, `SOL-P002`, `SOL-M001` |
| `QUANTIFY` | `SOL-P005`, `SOL-P056` |
| `BIND` | `SOL-V001`, `SOL-V002`, `SOL-V003`, `SOL-V006`, `SOL-V009`, `SOL-M003`, `SOL-P006` |
| `SCOPE` | `SOL-O004`, `SOL-O005`, `SOL-O001`, `SOL-O002` |
| `CLARIFY` | `SOL-P008`, `SOL-P001`, `SOL-P007`, `SOL-P050`, `SOL-O003` |
| `DECONFLICT` | `SOL-M002`, `SOL-M004`, `SOL-O006` |
| `COMPRESS` | `SOL-P054`, `SOL-P055`, `SOL-O006` |
| `PROMOTE` | (no lint code — routes through the promotion protocol, §23/§30) |

### B.8 Legacy translation table (old → new)

This is the authoritative legacy-code mapping; the remaps in this appendix (§B.8) define it. Every legacy code cited anywhere in the source corpus MUST be rewritten to its v0.1 code. The mapping is one-way; legacy codes MUST NOT appear in any conformant artifact.

#### B.8.1 APS family (retired prefix)

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
| `APS-S001` | `SOL-S012` | missing scope/non-goals as a document-level section gap → required-section-missing (§21.2.1); a per-obligation scope gap (no `WRITES`/`READS`/`AFFECTS`) remains `SOL-O004` |
| `APS-T001` | `SOL-M001` | traceability id → semantic completeness |
| `APS-V001` | `SOL-V001` | no verification path |
| `APS-X001` | `SOL-M002` | contradiction |

#### B.8.2 an earlier research draft flat scheme (SOL00x / 10x / 20x / 30x)

| Legacy code | v0.1 code | Note |
|---|---|---|
| `SOL001` | `SOL-S010` | invalid/missing frontmatter (metadata) |
| `SOL002` | `SOL-S002` | unknown block type |
| `SOL003` | `SOL-S007` | invalid block id |
| `SOL004` | — (TOMBSTONED) | `:::END` removed; bare-header form (§5) makes this moot |
| `SOL005` | `SOL-S008` | first line not a control sentence |
| `SOL006` | `SOL-S010` | unknown metadata field |
| `SOL007` | `SOL-S010` | duplicate scalar field |
| `SOL101` | `SOL-S001` / `SOL-P001` | `WHEN`/`IF` without consequence (syntax + prose companion) |
| `SOL102` | `SOL-S001` | `THEN` without modal obligation |
| `SOL103` | `SOL-S003` / `SOL-P003` | REQ lacks modal |
| `SOL104` | — (TOMBSTONED) | `ALWAYS`/`NEVER` removed from INVARIANT (§5/§6) |
| `SOL105` | `SOL-S002` | malformed QUESTION |
| `SOL201` | `SOL-S004` / `SOL-M001` | duplicate id (intra-spec → S004; cross-spec → M001) |
| `SOL202` | `SOL-M003` | unresolved dependency reference |
| `SOL203` | `SOL-O002` | dependency cycle |
| `SOL204` | `SOL-V001` | missing verification binding |
| `SOL205` | `SOL-O003` | blocking QUESTION unresolved at lowering |
| `SOL206` | `SOL-M004` | authority conflict |
| `SOL207` | `SOL-M002` | contradiction |
| `SOL208` | `SOL-O001` | planner marks conflicting tasks parallel |
| `SOL301` | `SOL-P005` | ambiguous adjective/adverb |
| `SOL302` | `SOL-P005` | unverifiable wording |
| `SOL303` | `SOL-P004` | low singularity (multiple obligations) |
| `SOL304` | `SOL-O004` | missing owner/priority (scope/governance) |
| `SOL305` | `SOL-O004` | scope too broad for planning |
| `SOL306` | `SOL-O006` | imported-file policy overlap |
| `SOL307` | `SOL-P052` / `SOL-P054` | overlong block body |

Allocation rule applied above: flat `SOL00x/10x → SOL-S`; `SOL20x → SOL-M` (cross-ref) / `SOL-V` (proof) / `SOL-O` (planner); `SOL30x → SOL-P`.

#### B.8.3 `swarm-an earlier research draft scheme (SOL-S00x / SOL-L1xx / SOL-M2xx / SOL-O3xx / SOL-V4xx)

| Legacy code | v0.1 code | Note |
|---|---|---|
| `SOL-S001` | `SOL-S001` | trigger, no consequence (unchanged) |
| `SOL-S002` | `SOL-S002` | unknown keyword / malformed block (unchanged) |
| `SOL-S003` | `SOL-S003` | actor-clause modal check (singularity warning is now `SOL-P004`, G3) |
| `SOL-S004` | `SOL-S004` | duplicate id (unchanged) |
| `SOL-L101` | `SOL-P005` | subjective/promotional term (`SOL-L → SOL-P`) |
| `SOL-L102` | `SOL-P005` | ambiguous qualifier / loophole |
| `SOL-L103` | `SOL-P050` | vague pronoun |
| `SOL-L104` | `SOL-P004` | bundled obligation |
| `SOL-L105` | `SOL-P051` | passive voice |
| `SOL-M201` | `SOL-M001` | unresolved actor/term/surface |
| `SOL-M202` | `SOL-M002` | contradiction |
| `SOL-M203` | `SOL-V001` | missing `VERIFY BY` (re-layered S/M → V) |
| `SOL-M204` | `SOL-O005` / `SOL-V001` | declared write surface missing |
| `SOL-M205` | `SOL-O002` | dependency cycle |
| `SOL-O001` | `SOL-O001` | parallel write-surface conflict (severity raised to BLOCKING) |
| `SOL-V401` | `SOL-V001` | proof missing / not executable |
| `SOL-V402` | `SOL-V004` | stale proof (→ `STALE` verdict, §16) |
| `SOL-V403` | `SOL-V003` | non-observable proof |

#### B.8.4 Cross-layer re-layerings

| Legacy code | v0.1 code | Re-layering |
|---|---|---|
| `SOL-S007` | `SOL-V001` | verification → V |
| `SOL-S010` (legacy) | `SOL-V005` | verdict-value check → V (the v0.1 `SOL-S010` slot is re-allocated to `unknown-metadata-field`, B.2) |
| `SOL-S008` | `SOL-O003` | planner / blocking-QUESTION → O |
| `SOL-M003` | `SOL-V001` | proof-binding → V |
| `SOL-M007` | `SOL-V003` | proof-observability → V |
| `SOL-M008` | `SOL-V004` | proof-staleness → V |
| `SOL-M009` | `SOL-O001` | planner parallelism → O |

Where a single legacy code maps to two v0.1 codes (e.g. `SOL101 → SOL-S001`/`SOL-P001`, `SOL201 → SOL-S004`/`SOL-M001`), the split is by phase: the syntactic facet fires at `PARSE` (S), the semantic/prose facet at `NORMALIZE` (P/M). A migration tool MUST emit both where both facets are present and MUST NOT collapse them.

### B.9 Conformance note

A conformant `lint-spec` checker (a CONTRACT, never shipped per Principle 1, §17) MUST: (1) emit only `SOL-<LAYER><NNN>` codes; (2) emit the diagnostic record of B.1.2; (3) apply the default severities in this appendix, overridable only through the recorded `swarm.config` waiver schema (G1); (4) never reuse a tombstoned number; (5) name a closed improve op in `suggest` wherever B.7 supplies one. The golden corpus (§33, G12) labels good/bad prose so the `SOL-P` rules' precision/recall (target ≥0.90 / ≥0.85) is measurable.

## Appendix C — IR JSON Schema

This appendix is the normative, contract-only data definition of the `*.swarm.ir.json` envelope first introduced in §12 (the intermediate representation) and bound to the surface language in §4–§6. It specifies the envelope shape, the three independent version fields, and the normalized `verify_by[]` element.

**Contract-not-executor rule (normative).** This schema is *versioned, inert data*, per Invariant 1 (NO RUNTIME, §2). The kernel ships this schema and conformant example instances; it ships **no emitter, parser, validator, or CLI** that produces `*.swarm.ir.json`. A conformant Swarm repo MUST carry this schema verbatim under `docs/language/` (with a self-contained copy in the scaffold); a tool, when one exists, MAY validate against it. The schema is "the contract a future tool builds against," never "a tool Swarm provides." `*.swarm.ir.json` is therefore a *reserved, documented* filename (§20), not an artifact any shipped process writes.

**Surface-vs-IR rule (normative).** Every field name in this schema is `snake_case` (the IR layer). It is the lowering of an English-shaped uppercase SOL surface keyword (§5): `verify_by` ← `VERIFY BY`, `depends_on` ← `DEPENDS ON`, `writes` ← `WRITES`, `reads` ← `READS`, `affects` ← `AFFECTS`, `owner` ← `OWNED BY`. There is **no `locks` field on either layer**; a lock group is a named `SURFACE` whose member paths appear in `writes[]` (§18). Relationships (`depends_on`, `blocks`, `conflicts_with`, `verified_by`, `affects`, `implements`, `preserves`) live **only** in `edges[]`; they MUST NOT be duplicated as node scalars — `edges[]` is the single source of relationship truth.

**Three-version rule (normative).** The envelope carries exactly three version fields and they MUST NOT be merged: `meta.language` is the **SOL language discriminator** (e.g. `SOL/0.1`) — which grammar, blocks, modals, and lint codes apply; `meta.version` is the **spec content version** — the SemVer of the authored `*.swarm.md` source; `provenance.compiler_version` is the **tool version** that emitted this IR, recorded only when a tool exists. A tool MUST NOT infer either of the other two from any one of them.

### C.1 The envelope schema

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "$id": "https://swarm.dev/schema/0.1/swarm.ir.json",
  "title": "Swarm IR envelope (*.swarm.ir.json)",
  "type": "object",
  "additionalProperties": false,
  "required": ["meta", "nodes", "edges", "diagnostics", "provenance"],
  "properties": {
    "meta": {
      "type": "object",
      "additionalProperties": false,
      "required": ["id", "title", "language", "version", "status"],
      "properties": {
        "id":      { "type": "string", "description": "Spec id (slug); e.g. auth-refresh" },
        "title":   { "type": "string" },
        "language":{ "const": "SOL/0.1", "description": "SOL language discriminator; never merged with version" },
        "version": { "type": "string", "pattern": "^[0-9]+\\.[0-9]+\\.[0-9]+$", "description": "Spec content SemVer; never merged with language" },
        "status":  { "enum": ["draft", "review", "approved", "superseded"] },
        "owners":  { "type": "array", "items": { "type": "string" }, "default": [] },
        "imports": { "type": "array", "items": { "type": "string", "description": "Path to an imported *.swarm.md" }, "default": [] }
      }
    },

    "nodes": {
      "type": "array",
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": ["id", "kind", "source"],
        "properties": {
          "id":   { "type": "string", "description": "IR node id; MAY be namespaced, e.g. REQ.auth-refresh.AC-001 (surface id is the short AC-001)" },
          "kind": { "enum": ["REQ", "CONSTRAINT", "INVARIANT", "INTERFACE", "QUESTION", "TRACE", "VERDICT"] },
          "authority": { "type": "string", "description": "Domain authority rank label (Axis B, §22): e.g. security, architecture, product" },
          "modality":  { "enum": ["MUST", "MUST NOT", "SHOULD", "SHOULD NOT", "MAY"], "description": "Binding force; obligation kinds (REQ/CONSTRAINT/INVARIANT) only" },
          "clauses": {
            "type": "object",
            "additionalProperties": false,
            "description": "Lowered SOL clauses (§6); null/absent for inapplicable slots",
            "properties": {
              "where":     { "type": ["string", "null"] },
              "while":     { "type": ["string", "null"] },
              "trigger":   { "type": ["string", "null"], "description": "Lowering of WHEN/IF [THEN]" },
              "subject":   { "type": ["string", "null"], "description": "The actor in THE <actor> <MODAL> <response>" },
              "modal":     { "enum": ["MUST", "MUST NOT", "SHOULD", "SHOULD NOT", "MAY", null] },
              "predicate": { "type": ["string", "null"], "description": "The response/predicate" },
              "timing":    { "type": ["string", "null"], "description": "RESERVED; timing keywords deferred to SOL/0.2 (§35)" }
            }
          },
          "owner":  { "type": ["string", "null"], "description": "Lowering of OWNED BY" },
          "risk":   { "enum": ["low", "medium", "high", "critical", null] },
          "reads":  { "type": "array", "items": { "type": "string" }, "default": [] },
          "writes": { "type": "array", "items": { "type": "string", "description": "Write surface path/glob or named SURFACE member" }, "default": [] },
          "affects":{ "type": "array", "items": { "type": "string" }, "default": [] },
          "verify_by": {
            "type": "array",
            "default": [],
            "items": {
              "type": "object",
              "additionalProperties": false,
              "required": ["type", "adapter", "ref"],
              "properties": {
                "type":     { "enum": ["static", "test", "contract", "property", "model", "perf", "security", "manual", "monitor"], "description": "Closed 9-type proof taxonomy" },
                "adapter":  { "type": "string", "description": "Resolves through AGENTS.md > Commands (a cmd* slot); free string" },
                "ref":      { "type": "string", "description": "Artifact reference; free string" },
                "selector": { "type": ["string", "null"], "description": "Lowering of #selector; e.g. a test name or invariant name" },
                "gate":     { "enum": ["required", "advisory"], "default": "required" }
              }
            }
          },
          "status": { "enum": ["PASS", "FAIL", "BLOCKED", "UNVERIFIED", "WAIVED", "STALE", "CONTRADICTED"], "description": "4 core + 3 lifecycle; UNVERIFIED is the default before a verdict exists" },
          "source": {
            "type": "object",
            "additionalProperties": false,
            "required": ["file", "line_start", "line_end"],
            "properties": {
              "file":         { "type": "string" },
              "line_start":   { "type": "integer", "minimum": 1 },
              "line_end":     { "type": "integer", "minimum": 1 },
              "content_hash": { "type": ["string", "null"], "description": "Hash of the obligation source span; drives STALE drift (§16)" }
            }
          },
          "provenance": { "type": "array", "items": { "type": "string" }, "default": [], "description": "Per-node trace/finding references (§23)" }
        }
      }
    },

    "edges": {
      "type": "array",
      "description": "Single source of relationship truth; relationships are NOT also node scalars",
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": ["from", "to", "type"],
        "properties": {
          "from": { "type": "string", "description": "Source node id" },
          "to":   { "type": "string", "description": "Target node id" },
          "type": { "enum": ["depends_on", "blocks", "conflicts_with", "verified_by", "affects", "implements", "preserves"] },
          "hard": { "type": "boolean", "default": true, "description": "true = hard ordering/conflict; false = soft/advisory" }
        }
      }
    },

    "diagnostics": {
      "type": "array",
      "description": "SARIF-shaped; attach to a node or a source span",
      "items": {
        "type": "object",
        "additionalProperties": false,
        "required": ["code", "level", "message"],
        "properties": {
          "code":    { "type": "string", "pattern": "^SOL-[SPMVO][0-9]{3}$", "description": "Unified lint namespace (§8)" },
          "level":   { "enum": ["error", "warning", "info"] },
          "node":    { "type": ["string", "null"], "description": "Node id the diagnostic is bound to, if any" },
          "source": {
            "type": ["object", "null"],
            "additionalProperties": false,
            "properties": {
              "file":       { "type": "string" },
              "line_start": { "type": "integer", "minimum": 1 },
              "line_end":   { "type": "integer", "minimum": 1 }
            }
          },
          "message": { "type": "string" },
          "suggest": { "type": ["string", "null"], "description": "Optional fix hint (the improve op or repair)" }
        }
      }
    },

    "provenance": {
      "type": "object",
      "additionalProperties": false,
      "required": ["hash"],
      "properties": {
        "hash":             { "type": "string", "description": "Hash of the source *.swarm.md this IR was emitted from" },
        "compiler_version": { "type": ["string", "null"], "description": "Tool version; null until a tool exists; never merged with meta.language or meta.version" },
        "compiled_at":      { "type": ["string", "null"], "format": "date-time" }
      }
    }
  }
}
```

### C.2 Annotated example instance

A minimal 3-node graph: one `REQ` (verified by a test and a property), one `INTERFACE` it depends on (which MUST itself carry a `contract` proof, §15), and one diagnostic. `edges[]` carries every relationship; no relationship is repeated as a node scalar.

```json
{
  "meta": {
    "id": "auth-refresh",
    "title": "Access token refresh",
    "language": "SOL/0.1",
    "version": "0.1.0",
    "status": "draft",
    "owners": ["@auth-platform"],
    "imports": ["shared/security.swarm.md"]
  },
  "nodes": [
    {
      "id": "REQ.auth-refresh.AC-001",
      "kind": "REQ",
      "authority": "security",
      "modality": "MUST",
      "clauses": {
        "where": null, "while": null,
        "trigger": "response.status == 401 AND refresh_token present",
        "subject": "web-client",
        "modal": "MUST",
        "predicate": "retry original_request once",
        "timing": null
      },
      "owner": "@web-platform",
      "risk": "medium",
      "reads": [], "writes": ["web/src/http/client.ts"], "affects": [],
      "verify_by": [
        { "type": "test",     "adapter": "cmdTest", "ref": "web/tests/auth-refresh-401.spec.ts", "selector": null, "gate": "required" },
        { "type": "property", "adapter": "cmdTest", "ref": "web/tests/auth-refresh.properties.ts", "selector": "no_unbounded_retry", "gate": "required" }
      ],
      "status": "UNVERIFIED",
      "source": { "file": "auth-refresh.swarm.md", "line_start": 18, "line_end": 29, "content_hash": "sha256:9f1c…" },
      "provenance": []
    },
    {
      "id": "INTERFACE.auth-refresh.IF-001",
      "kind": "INTERFACE",
      "authority": "architecture",
      "owner": "@auth-platform",
      "verify_by": [
        { "type": "contract", "adapter": "cmdValidate", "ref": "openapi/auth.yaml", "selector": "POST /token/refresh", "gate": "required" }
      ],
      "status": "UNVERIFIED",
      "source": { "file": "auth-refresh.swarm.md", "line_start": 31, "line_end": 38, "content_hash": "sha256:2ab7…" },
      "provenance": []
    }
  ],
  "edges": [
    { "from": "REQ.auth-refresh.AC-001", "to": "INTERFACE.auth-refresh.IF-001", "type": "depends_on", "hard": true },
    { "from": "INTERFACE.auth-refresh.IF-001", "to": "REQ.auth-refresh.AC-001", "type": "verified_by", "hard": false }
  ],
  "diagnostics": [
    { "code": "SOL-V001", "level": "warning", "node": "REQ.auth-refresh.AC-001", "source": null,
      "message": "INVARIANT-class property bound to a unit test; prefer property|model|static.", "suggest": "BIND a property: or model: proof" }
  ],
  "provenance": {
    "hash": "sha256:c0ffee…",
    "compiler_version": null,
    "compiled_at": "2026-05-31T12:00:00Z"
  }
}
```

Notes on the instance: `meta.language` (`SOL/0.1`), `meta.version` (`0.1.0`), and `provenance.compiler_version` (`null`, no tool exists) are the three distinct version fields and are never collapsed; the `verify_by[].adapter` values (`cmdTest`, `cmdValidate`) are AGENTS.md > Commands slots, not commands the kernel runs (§15, §31); node `status` is `UNVERIFIED` because no `VERDICT` block has judged either obligation yet (§14); the diagnostic `code` matches `^SOL-[SPMVO][0-9]{3}$` (§8).

## Appendix D — Worked example: auth-refresh, full pipeline

This appendix carries the `auth-refresh` obligation set through every pass of the pipeline (§9), in order: authored source, lint, improve, IR, task frame, trace, review with merge gate, and promotion. Identifiers, hashes, and verdicts are stable across stages so the chain reads as a single run. It is the positive (`must-compile`) `auth-refresh` golden-corpus fixture (§33), exercising a dangling-condition defect (`SOL-S001`), a `SHOULD` without `BECAUSE` (`SOL-P003`), a missing-verification defect (`SOL-V001`), the no-unbounded-retry `INVARIANT`, and a blocking `QUESTION`. Terms are defined in Appendix F; the IR conforms to Appendix C; the grammar to Appendix A.

### D.1 Stage 1 — authored `spec.swarm.md` (pass: `author`)

The human-authored source artifact (the only `.swarm.` artifact a human writes, §20). Frontmatter is normalized per G10 (§25): `swarm_language` is the language discriminator, `aps_version` the prose-standard version, `spec_version` the spec content version.

```sol
---
type: spec
swarm_language: SOL/0.1
aps_version: 0.1
spec_version: 0.1.0
id: auth-refresh
status: draft
---

# Spec: Silent token refresh on 401

## Intent
When an access token expires mid-session the client transparently refreshes it
and replays the original request, without ever looping.

## Interfaces

INTERFACE IF-001:
`refreshSession` RETURNS `Session | AuthExpired`
ERRORS:
  - network-timeout
  - invalid-refresh-token
OWNED BY auth-client

## Obligations

REQ AC-001:
WHEN a request returns 401 AND a refresh token is present
THE auth client MUST call `refreshSession` once
AND THE auth client MUST replay the original request with the new session
VERIFY BY test:cmdTest:web/tests/auth-refresh-401.spec.ts#replays-after-refresh
DEPENDS ON IF-001
WRITES web/src/http/client.ts
RISK high

REQ AC-002:
WHEN the refresh token is expired
THE auth client SHOULD clear the local session
AND THE auth client MUST redirect to `/login`

## Invariants

INVARIANT I-001:
the retry count for a single original request MUST NOT exceed one

## Questions

QUESTION Q-001 [blocking]:
Should an expired refresh token redirect to `/login` or open an inline re-auth modal?
AFFECTS AC-002
```

### D.2 Stage 2 — lint diagnostics (pass: `lint`)

The `lint` pass emits SARIF-shaped diagnostic records `{code, severity, layer, span, message, suggest}` in the unified `SOL-<LAYER><NNN>` namespace (§8). Three diagnostics fire on the authored source; each names the closed `improve` op (§10) that repairs it. All three are BLOCKING because each changes *what* gets built (§8.4 binding-clause rule, G2).

```text
SOL-V001  ERROR  layer=V  AC-002:L1-L4
  message: obligation AC-002 has no VERIFY BY binding; no verification path.
  suggest: improve op BIND — add VERIFY BY <type>:<adapter>:<artifact>.

SOL-P003  ERROR  layer=P  AC-002:L2 ("THE auth client SHOULD clear the local session")
  message: SHOULD without an accompanying BECAUSE or EXCEPT clause.
  suggest: improve op NORMALIZE — add BECAUSE <reason>, or raise to MUST.

SOL-S001  ERROR  layer=S  I-001:L1
  message: INVARIANT predicate uses the bare noun phrase "MUST NOT exceed one"
           with no observable subject binding; reads as a dangling condition.
  suggest: improve op CONCRETIZE — name the measured quantity and threshold.
```

A fourth, non-blocking note records that `Q-001` is `[blocking]` and `AFFECTS AC-002`, so `AC-002` MUST NOT reach the `lower` pass until the question is resolved (`SOL-O…` orchestration class; see §9, §18).

### D.3 Stage 3 — improved `spec.swarm.md` (pass: `improve`)

The `improve` pass applies the named ops — `BIND`, `NORMALIZE`, `CONCRETIZE` — strictly preserving intent (§10). `Q-001` is resolved out-of-band by the spec owner (decision: redirect to `/login`); the resolution is recorded and `Q-001` is removed, unblocking `AC-002`. Only the changed blocks are shown.

```sol
REQ AC-002:
WHEN the refresh token is expired
THE auth client MUST clear the local session
AND THE auth client MUST redirect to `/login`
VERIFY BY test:cmdTest:web/tests/auth-refresh-expired.spec.ts#clears-and-redirects
DEPENDS ON IF-001
WRITES web/src/http/client.ts
RISK medium

INVARIANT I-001:
the retry count for a single original request MUST NOT exceed 1
VERIFY BY property:cmdTest:web/tests/auth-refresh.properties.ts#no_unbounded_retry
```

`NORMALIZE` resolved `SHOULD` to `MUST` (the spec owner judged the session-clear mandatory, so no `BECAUSE` is needed); `CONCRETIZE` fixed the threshold to the literal `1` and named the measured quantity; `BIND` attached a `test` proof to `AC-002` and a `property` proof to `I-001` (an `INVARIANT` prefers `property|model|static`, §15). All three diagnostics now clear.

### D.4 Stage 4 — IR excerpt (pass: `lower`)

The `lower` pass emits the typed IR (`auth-refresh.swarm.ir.json`) conforming to Appendix C: surface keywords become snake_case fields, relationships move into `edges[]` (the single source of relationship truth — never node scalars), and node ids are namespaced. A 3-node slice is shown.

```json
{
  "meta": {
    "id": "auth-refresh",
    "title": "Silent token refresh on 401",
    "language": "SOL/0.1",
    "version": "0.1.0",
    "status": "draft"
  },
  "nodes": [
    {
      "id": "INTERFACE.auth-refresh.IF-001",
      "kind": "INTERFACE",
      "clauses": { "returns": "Session | AuthExpired" },
      "owner": "auth-client",
      "verify_by": [
        { "type": "contract", "adapter": "cmdValidate",
          "ref": "openapi/auth-refresh.yaml", "selector": null, "gate": "required" }
      ],
      "status": "UNVERIFIED",
      "source": { "file": "auth-refresh.swarm.md", "line_start": 9, "line_end": 15,
                  "content_hash": "sha256:1f4a…c0" }
    },
    {
      "id": "REQ.auth-refresh.AC-001",
      "kind": "REQ",
      "modality": "MUST",
      "clauses": { "trigger": "a request returns 401 AND a refresh token is present",
                   "subject": "auth client",
                   "predicate": "call refreshSession once and replay the original request" },
      "risk": "high",
      "writes": ["web/src/http/client.ts"],
      "verify_by": [
        { "type": "test", "adapter": "cmdTest",
          "ref": "web/tests/auth-refresh-401.spec.ts",
          "selector": "replays-after-refresh", "gate": "required" }
      ],
      "status": "UNVERIFIED",
      "source": { "file": "auth-refresh.swarm.md", "line_start": 19, "line_end": 27,
                  "content_hash": "sha256:9b2e…41" }
    },
    {
      "id": "INVARIANT.auth-refresh.I-001",
      "kind": "INVARIANT",
      "modality": "MUST NOT",
      "clauses": { "predicate": "retry count for a single original request exceeds 1" },
      "verify_by": [
        { "type": "property", "adapter": "cmdTest",
          "ref": "web/tests/auth-refresh.properties.ts",
          "selector": "no_unbounded_retry", "gate": "required" }
      ],
      "status": "UNVERIFIED",
      "source": { "file": "auth-refresh.swarm.md", "line_start": 39, "line_end": 42,
                  "content_hash": "sha256:7d10…aa" }
    }
  ],
  "edges": [
    { "from": "REQ.auth-refresh.AC-001", "to": "INTERFACE.auth-refresh.IF-001",
      "type": "depends_on", "hard": true },
    { "from": "REQ.auth-refresh.AC-001", "to": "INVARIANT.auth-refresh.I-001",
      "type": "affects", "hard": false }
  ],
  "diagnostics": [],
  "provenance": { "hash": "sha256:c33b…9e", "compiler_version": null,
                  "compiled_at": "2026-05-31T00:00:00Z" }
}
```

`compiler_version` is `null` because no tool is shipped (Invariant 1, NO RUNTIME, §2); the IR here is the contract a future tool emits against (§12), produced by hand for the fixture.

### D.5 Stage 5 — `task.md` work packet (passes: `decompose`, `implement`)

The `decompose` pass projects the IR into a work packet whose write surfaces are a subset of the assigned obligations' `WRITES` (the two-tier lowering rule, §11.4, §18; violation = `SOL-O005`, G7). The `implement` pass executes it. Only the load-bearing frame is shown.

```text
---
type: task
id: auth-refresh-client
status: active
task_kind: feature
source:.agents/specs/auth-refresh.swarm.md
assigned_obligations: [AC-001, AC-002]
invariants: [I-001]
interfaces: [IF-001]
write_surfaces: [web/src/http/client.ts]
verification_bindings:
  - AC-001: test:cmdTest:web/tests/auth-refresh-401.spec.ts#replays-after-refresh
  - AC-002: test:cmdTest:web/tests/auth-refresh-expired.spec.ts#clears-and-redirects
  - I-001:  property:cmdTest:web/tests/auth-refresh.properties.ts#no_unbounded_retry
parallel_group: client-edits
blocked_by: []
---

# Task: Implement auth-refresh client behavior

## 3. Do not do
- Do not implement unassigned obligations.
- Do not change behavior outside web/src/http/client.ts.

## 6. Verification matrix
| Obligation | Required proof              | Actual proof                          | Status |
| ---------- | --------------------------- | ------------------------------------- | ------ |
| AC-001     | test:#replays-after-refresh | auth-refresh-401.spec.ts passed       | pass   |
| AC-002     | test:#clears-and-redirects  | auth-refresh-expired.spec.ts passed   | pass   |
| I-001      | property:#no_unbounded_retry| auth-refresh.properties.ts passed     | pass   |
```

### D.6 Stage 6 — `trace.md` excerpt (pass: `verify`)

The `verify` pass records a `TRACE` block plus the provenance the drift join depends on (§16, G11): per-binding `source_hash` (echoing the IR node `content_hash`), per-surface file hash, adapter, core verdict, and confidence tier.

```text
---
type: trace
id: auth-refresh-client-trace
source_task:.agents/tasks/auth-refresh-client.md
source_spec:.agents/specs/auth-refresh.swarm.md
---

# Trace: auth-refresh client

TRACE T-001:
IMPLEMENTS AC-001, AC-002
PRESERVES I-001
CHANGED web/src/http/client.ts
PROOF test:cmdTest:web/tests/auth-refresh-401.spec.ts#replays-after-refresh passed
PROOF test:cmdTest:web/tests/auth-refresh-expired.spec.ts#clears-and-redirects passed
PROOF property:cmdTest:web/tests/auth-refresh.properties.ts#no_unbounded_retry passed

## Provenance
| binding | source_hash      | per_surface_hash               | adapter | verdict | tier   |
| ------- | ---------------- | ------------------------------ | ------- | ------- | ------ |
| AC-001  | sha256:9b2e…41   | client.ts=sha256:5510…b3       | cmdTest | PASS    | high   |
| AC-002  | sha256:e8f7…2d   | client.ts=sha256:5510…b3       | cmdTest | PASS    | high   |
| I-001   | sha256:7d10…aa   | properties.ts=sha256:aa90…1c   | cmdTest | PASS    | high   |
```

### D.7 Stage 7 — `review.md` excerpt and merge-gate outcome (pass: `review`)

The `review` pass (run under the `skeptic` profile, §27) consumes the trace and emits per-obligation `VERDICT` lines carrying a core value optionally decorated with a lifecycle value (§14). `AC-001` and `I-001` are clean `PASS`. `AC-002` is shown with a lifecycle decorator: its bound test PASSed, but `web/src/http/client.ts` was edited after the recorded PASS, so its source no longer matches — it is decorated `STALE` (§16). Per the merge gate, a STALE required obligation is NOT mergeable until reconciled.

```text
---
type: review
id: auth-refresh-client-review
source_trace:.agents/traces/auth-refresh-client-trace.md
source_spec:.agents/specs/auth-refresh.swarm.md
---

# Review: auth-refresh client

## Obligation verdicts

VERDICT AC-001: PASS
REASON Replay-after-refresh test exercises a 401 with a present refresh token and asserts one replay.
EVIDENCE auth-refresh-401.spec.ts output in review log

VERDICT AC-002: PASS (STALE by source-hash: client.ts modified after last PASS at sha256:5510…b3)
REASON Prior PASS evidence no longer matches current write-surface hash; requires 3-way reconcile.
EVIDENCE prior verdict + changed-surface diff in review log

VERDICT I-001: PASS
REASON Property test fails on any path producing retry_count > 1; current run is green.
EVIDENCE auth-refresh.properties.ts output in review log

## Merge gate
Gate: every required obligation is PASS or WAIVED; none STALE/CONTRADICTED/FAIL/BLOCKED/UNVERIFIED.
Result: BLOCKED — AC-002 is STALE. Re-run the bound proof against the current surface
(reconcile option 1), then re-evaluate. After re-run AC-002 → PASS, the gate opens.
```

### D.8 Stage 8 — promotion (pass: `promote`)

After reconcile (`AC-002` re-run → PASS, gate open), a durable discovery from the task is promoted into a `finding.md` carrying full provenance (§23; schema G11): `origin_obligations`, `origin_traces`, the pass+profile that produced it, reviewer/tool, `content_hash`, confidence, and applies-when bounds. The `memory/INDEX.md` MAP gains one link with a "Load when" condition; no procedure is inlined there (§23, §31).

```text
---
type: finding
id: refresh-storm-on-shared-401
status: promoted
related_obligations: [AC-001, I-001]
confidence: high
---

# Finding: A single expired token can fan out to N concurrent 401s

## Claim
Concurrent in-flight requests each see the 401 and independently call refreshSession;
without a single-flight guard this violates I-001 in aggregate even though each request
retries at most once.

## Provenance
- origin_obligations: [REQ.auth-refresh.AC-001, INVARIANT.auth-refresh.I-001]
- origin_traces: [auth-refresh-client-trace#T-001]
- pass: verify; profile: skeptic
- reviewer_or_tool: review.md (human review)
- content_hash: sha256:9b2e…41
- confidence: high

## Applies when
- Multiple requests can be in flight when a token expires.

## Does not apply when
- The client serializes all auth-bearing requests.
```

```text
# memory/INDEX.md  (excerpt)
- [Refresh storm on shared 401](../findings/refresh-storm-on-shared-401.md)
  — Load when: implementing or reviewing concurrent token-refresh paths.
```

---

## Appendix E — Residual gaps and v0.1 judgment calls (G1–G12)

The this specification (§(b) of this specification) enumerates twelve residual gaps requiring an author's judgment. This appendix states each as the NORMATIVE v0.1 position, using the recommended resolution, and cross-references the body section that owns it. Nothing here is left implicit; an item is "Revisit in v0.2?" only where this specification expects the resolution to deepen (it does not reopen the v0.1 disposition).

| Gap | The question | v0.1 disposition (normative) | Owner | Revisit in v0.2? |
| --- | --- | --- | --- | --- |
| **G1** | Is there a config schema to promote advisories→errors (strict mode) or demote a blocker with a recorded waiver? | A `swarm.config` file MAY carry a `severity_overrides` map (`code → BLOCKING\|ADVISORY\|OFF`) and a `waivers[]` list; each waiver MUST record `{code, span_or_obligation, authority, reason, expires_on, source_hash}`. A demotion-to-OFF without a waiver record is itself a lint error. Absent the file, the default severities (§8) hold. | §8, §17 | Yes — add inheritance/profile layering. |
| **G2** | Where is the binding-clause vs commentary boundary that gates many `SOL-P` codes? | A span is **binding iff it lies inside a typed obligation block** (`REQ`, `CONSTRAINT`, `INVARIANT`); every other span is **commentary**. Comparatives, loopholes, and high-risk words are BLOCKING in binding spans and ADVISORY in commentary. This is normative, not heuristic. | §7, §8 | No. |
| **G3** | Does `AND THE` chaining violate single-obligation discipline? | `AND THE <actor> <MODAL> <response>` chaining is **permitted**; the `lower` pass MUST split each conjunct into a distinct IR obligation. More than two chained obligations in one block emits a non-blocking `SOL-P004`-adjacent **warning** suggesting `ATOMIZE`; it is never a hard error. | §6, §10, §11 | No. |
| **G4** | What is the enforcement-lane artifact mapping each CONSTRAINT/INVARIANT/stop-rule to its deterministic home? | The kernel defines a first-class **enforcement-lane artifact** (one table) mapping each `CONSTRAINT`/`INVARIANT`/stop-rule/secret-redaction obligation to its eventual deterministic home (`PreToolUse` hook, CI step, permission deny, schema validator). It is **aspirational/manual today** (Invariant 1/2) and MUST be labeled as such; it claims no live enforcement. | §17 | Yes — bind each row to a shipped hook/CI contract. |
| **G5** | Who holds waiver authority, and does WAIVED auto-expire? | Waiver authority is **human or spec-owner only** (never a tool, never an agent profile acting alone). A `WAIVED` decorator **auto-expires on the next source-hash change** of the waived obligation (preventing zombie waivers); an expired waiver reverts the obligation to its undecorated core verdict and re-closes the merge gate. | §14 | No. |
| **G6** | What is the action on `CONTRADICTED` at the merge gate, beyond the proof-strength ordering? | On `CONTRADICTED`, the merge gate **blocks and routes to review**; the obligation's core verdict is taken from the **stronger oracle** per the proof-strength order (`model > property/contract > test > static > manual/monitor`), and the weaker proof is recorded as superseded evidence. A tie at equal strength escalates to `manual`. | §14, §15 | Yes — formal weighting for LLM-judge proofs. |
| **G7** | What is the READS conflict rule, and how are shared/global surfaces handled? | read/read is **always parallel-safe**; read/write on the same surface is a **conflict edge** (conflict-serializability). A `SURFACE` MAY carry an attribute — `SURFACE <name> = … [append-only\|integration\|shared]` — so shared/global/append-only surfaces (lockfiles, CI config, manifests) are not treated as ordinary write conflicts and do not trigger blanket staleness. A new lint code **`SOL-O005`** ("owned path outside declared write surface") enforces the two-tier lowering check. | §8, §16, §18 | No. |
| **G8** | What is the full `*.swarm.plan.json` schema, given the unreconciled source field sets? | The plan schema follows the **same method as the IR**: a **graph envelope** plus a **rich task payload**. Each task carries `{id, pass, profile, derived_from[], reads[], writes[], depends_on[], verify_by[], merge_safe}`. There is **no `locks` field** — a lock group is a named `SURFACE`. The plan is **documented-as-contract only**; no tool emits it (Invariant 1). | §13 | Yes — batching/lane fields once a launcher exists. |
| **G9** | What does a "universal workflow rule" promotion actually become, given the ≤200-line AGENTS.md cap? | A workflow-rule promotion becomes a **pass-guide edit plus a one-line AGENTS.md pointer**, never inline procedure in the bootloader. Only persistent *facts* (ADR 0017) live in `AGENTS.md`; the procedure lives in the named pass guide the pointer references. | §23, §26, §31 | No. |
| **G10** | What is the canonical frontmatter field-name and value vocabulary? | Frontmatter is normalized to three fields: **`swarm_language: SOL/0.1`** (language discriminator), **`aps_version: 0.1`** (prose-standard version), **`spec_version: 0.1.0`** (spec content version, SemVer). These map one-to-one onto the three IR version fields (`meta.language`, n/a, `meta.version`) and MUST NOT be merged. | §25 | No. |
| **G11** | What is the exact trace-provenance schema the drift join and conformance checker depend on? | Every recorded PASS MUST carry `{source_hash, per_surface_hash[], adapter, verdict, tier, origin_obligations[], origin_traces[]}`. This single schema is referenced identically by drift/staleness (§16), the memory model's promotion provenance (§23), and the verdict model (§14). | §14, §16, §23 | No. |
| **G12** | What baseline measures the SOL-P high-risk-word false-positive rate? | The golden corpus (§33) ships a **labeled good/bad prose fixture set** with a stated **precision/recall baseline of 0.90 precision / 0.85 recall** for the `SOL-P` rules, so the high-risk-word list's false-positive rate is measurable rather than asserted. | §33 | Yes — raise the recall target as the corpus grows. |

---

## Appendix F — Glossary

One crisp definition per term, consistent with the body. Each entry cross-references the owning section. Terms are alphabetized.

| Term | Definition |
| --- | --- |
| **adapter** | The project-specific tool an obligation's proof resolves to; the `<adapter>` slot of `VERIFY BY <type>:<adapter>:<artifact>` resolves through `AGENTS.md` > Commands `cmd*` placeholder slots (§15, §31). |
| **AGENTS.md** | The always-loaded bootloader of persistent facts and pointers, hard-capped at ≤200 lines / ≤25 KB; carries the Commands table the adapters resolve through but never defines modality, authority, or verification semantics (§31). |
| **APS** | Agent Prose Semantics — the controlled-prose standard governing the readable prose around SOL blocks; the name survives, but `APS-` is retired as a lint-code prefix (the rules now live under `SOL-P###`) (§7). |
| **block type** | One of the seven SOL block kinds (`REQ`, `CONSTRAINT`, `INVARIANT`, `INTERFACE`, `QUESTION`, `TRACE`, `VERDICT`), each with a fixed id prefix and clause grammar (§4, §6). |
| **conformance** | The property of a repository that ships the language reference docs, the seven core templates, a populated `AGENTS.md` bootloader, and `.agents/.swarm-version` (§20, §32). |
| **CONSTRAINT** | An obligation block (id `C-NNN`) that restricts *how* obligations may be satisfied rather than requesting behavior; carries binding force (§6). |
| **decompose** | The pass that projects the IR into work packets (`task.md`), enforcing that owned write surfaces are a subset of assigned obligations' `WRITES`; a pass, not an improve op (§9, §11). |
| **distillation loss budget** | The discipline that names what each compilation step Preserved, Dropped, and left Still-uncertain, bounding the meaning lost when prose intent is lowered toward code (§24). |
| **drift** | The condition where an obligation's source or a declared write surface changes after its last PASS, detected by content-hash comparison and surfaced as the `STALE` lifecycle decorator (§16). |
| **EARS** | Easy Approach to Requirements Syntax — the trigger/condition keyword family (`WHEN`, `WHILE`, `WHERE`, `IF [THEN]`) that shapes the SOL `REQ` clause order (§5, §6). |
| **edge** | A typed relationship in the IR (`depends_on`, `blocks`, `conflicts_with`, `verified_by`, `affects`, `implements`, `preserves`); edges are the single source of relationship truth, never duplicated as node scalars (§12). |
| **enforcement lane** | The first-class (today aspirational/manual) mapping of each CONSTRAINT/INVARIANT/stop-rule to its eventual deterministic home outside the model — hook, CI, permission, or schema (§17). |
| **finding** | A plain `.md` artifact recording one durable project fact with mandatory provenance; the unit of promotion into spec, ADR, audit, or memory (§23, §29). |
| **IR** | The intermediate representation — the typed `{meta, nodes[], edges[], diagnostics[], provenance}` JSON envelope (`*.swarm.ir.json`) emitted from the surface spec; documented as a contract, not shipped by any tool (§12, Appendix C). |
| **INVARIANT** | An obligation block (id `I-NNN`) asserting a property that must remain preserved over time; prefers `property\|model\|static` proofs; carries binding force (§6, §15). |
| **kickback** | The re-entry of the `implement` pass after a `FAIL` or `UNVERIFIED` verdict; a control-flow event, never a task type (§28). |
| **lifecycle decorator** | One of `WAIVED`, `STALE`, `CONTRADICTED` — a parenthetical that decorates a core verdict to record its status over time (§14). |
| **lint layer** | One of the five letters in `SOL-<LAYER><NNN>` — `S` syntax, `P` prose, `M` semantic, `V` verification, `O` orchestration — each a 100-block, append-only with tombstoning (§8). |
| **lower** | The pass (and conceptual phase) that translates the improved surface spec into the typed IR (§9, §11). |
| **merge gate** | The pass/fail decision that permits a merge iff every required obligation is `PASS` or `WAIVED` and none is `STALE`, `CONTRADICTED`, `FAIL`, `BLOCKED`, or `UNVERIFIED` (§14). |
| **obligation** | A binding clause carried by a `REQ`, `CONSTRAINT`, or `INVARIANT` block; the unit that is verified, traced, and gated (§4, §6). |
| **obligation graph** | The dependency-and-conflict graph the IR encodes via `edges[]`, over which Swarm's core analyses (topo-sort, cycle detection, write-conflict, traceability) run (§3, §12). |
| **pass** | One of the nine schedulable transformations (`author → lint → improve → lower → decompose → implement → verify → review → promote`) that a task performs over its source artifacts (§9). |
| **pass guide** | A skill reframed as procedural guidance for performing a pass; it never owns SOL or APS semantics, which must be understandable without it (§26). |
| **phase** | One of the seven conceptual compiler stages (`PARSE → NORMALIZE → LOWER → EXECUTE → VERIFY → REVIEW → PROMOTE`) onto which passes map (§9). |
| **plan** | The `*.swarm.plan.json` artifact — a graph envelope plus rich task payload derived from the IR; documented as a contract only, with no `locks` primitive (§13). |
| **profile** | A persona reframed as a heuristic parameter on a pass (e.g. `review[profile: skeptic]`), carrying Prevents/Default-questions/Required-evidence/Refuses/Applies-when (§27). |
| **promotion** | The protocol that moves a durable discovery out of task-local state into a finding, spec amendment, ADR, audit, or memory entry, with provenance, before task close (§23, §29). |
| **proof type** | One of the nine closed verification kinds (`static, test, contract, property, model, perf, security, manual, monitor`) that types a `VERIFY BY` binding (§15). |
| **REQ** | An obligation block (id `AC-NNN`) defining a required behavior in EARS-shaped clause order; carries binding force (§6). |
| **SOL** | The obligation language — the English-shaped, uppercase-keyword controlled notation, embedded in Markdown, in which obligations are authored (§4, §5, Appendix A). |
| **source authority** | The two-orthogonal-axis ordering (domain first, then artifact) that resolves which obligation governs when two conflict; code and tests may falsify but never silently amend intent (§22). |
| **STALE** | The lifecycle decorator marking a prior PASS whose recorded source or write-surface hash no longer matches current state; blocks the merge gate and forces a 3-way reconcile (§14, §16). |
| **surface** | The human-authored layer — English-shaped uppercase space-separated keywords in `.swarm.md` — as distinct from the snake_case IR layer (§4, §5). |
| **SURFACE** | A named coarse write-surface group (`SURFACE <name> = …`), optionally attributed `append-only\|integration\|shared`; replaces any `locks` primitive (§4, §18, G7). |
| **task_kind** | The frontmatter enum that parameterizes the `implement`/`author` passes (e.g. `feature`, `fix`, `refactor`, `review`, `spec-writing`, `orchestration`); the 18 canonical values are defined in §28. |
| **trace** | The emitted artifact (`*.swarm.trace.md`) recording a `TRACE` block — implementation claims, changed surfaces, proof references — plus the provenance the drift join consumes (§16, §21). |
| **VERDICT** | The judgment block (reusing the judged obligation's id) carrying one core value (`PASS`, `FAIL`, `BLOCKED`, `UNVERIFIED`) optionally decorated with a lifecycle value; lives inside `review.md`, never a standalone file (§14). |
| **VERIFY BY** | The surface clause binding an obligation to its proof: `VERIFY BY <type>:<adapter>:<artifact>[#selector]`; the IR field name is `verify_by` (§15). |
| **write surface** | A file or glob an obligation declares it may modify via `WRITES`; the unit of write-conflict and parallel-safety analysis, and the projection an owned path must be a subset of (§18). |

## Appendix G — Rework brief

A single copy-paste brief that drives an agent through the repository rework. It is self-contained: it names only this specification and its sections, introduces no new vocabulary, and adds no authority of its own. Paste it verbatim as a task prompt; it points back into the spec for every load-bearing detail.

```text
SWARM REPO REWORK — AGENT BRIEF

OBJECTIVE
  Build the markdown-only Swarm kernel: a provider-neutral, no-runtime
  specification framework. Everything that "runs" is a CONTRACT a future
  tool builds against — never shipped code. You produce only Markdown,
  templates, fixtures, and inert data files.

AUTHORITY ORDER (highest first)
  1. This specification (swarm-kernel.md) — the single source of truth.
  2. Explicit user instructions for this rework.
  3. Existing repo content, only where it does not contradict (1) or (2).
  Resolve every conflict in favor of (1). Do not import authority from any
  prior draft, skill, or persona.

DO NOT
  - Ship a parser, CLI, LSP, linter, checker, planner, scheduler, or any
    runtime. (Invariant: NO RUNTIME.)
  - Use hybrid or fenced SOL. Blocks are bare-header "TYPE PREFIX-NNN:";
    never ":::REQ...:::END".
  - Use any retired alias: no canonical SHALL/SHALL NOT (use MUST/MUST NOT),
    no VERIFY_BY underscore (use "VERIFY BY"), no TASK-MAP, no fenced SOL,
    no APS- lint prefix, no POLICY/INV block headers, no verdict.md file.
  - Let any pass guide, profile, or AGENTS.md section define modality,
    authority order, or verification semantics. Those live only in SOL/IR.

CANONICAL CONTENT (one line each — the spec is authoritative)
  - SOL is bare-header line-oriented Markdown: "TYPE PREFIX-NNN:".
  - Proof binding is "VERIFY BY <type>:<adapter>:<artifact>[#selector]";
    a bare ref is valid but advisory; adapter resolves through
    AGENTS.md > Commands.
  - 7 block types: REQ(AC), CONSTRAINT(C), INVARIANT(I), INTERFACE(IF),
    QUESTION(Q), TRACE(T), VERDICT(reuses judged id).
  - 5 modals: MUST, MUST NOT, SHOULD, SHOULD NOT, MAY (uppercase;
    SHOULD/SHOULD NOT need BECAUSE or EXCEPT).
  - Verdicts: 4 core (PASS/FAIL/BLOCKED/UNVERIFIED) + 3 lifecycle
    decorators (WAIVED/STALE/CONTRADICTED).
  - review.md is the review artifact; VERDICT is a block inside it,
    never a standalone verdict.md.
  - Skills become pass guides (one per pass; soft control only).
  - Personas become heuristic profiles (e.g. review[profile: skeptic]).
  - AGENTS.md is the bootloader: persistent facts + the Commands table,
    capped at <=200 lines / <=25 KB; procedures move to pass guides.
  - Source files carry the *.swarm.md suffix; task/review/finding/adr/
    audit/research/bug-report are plain.md.

POINTERS (read before producing each part)
  - §20.0 — the full artifact layout and the.swarm. infix rule. Do NOT
    re-derive or duplicate the tree; follow §20.0 exactly.
  - §34 — the acceptance gate A1–A28; the rework promotes only when every
    check passes (§34.7). Run the gate per migration wave (§34.0) and once
    at the end.
  - §34.6 — the regression greps: each retired construct (A19–A28) is a
    search that MUST return zero matches in shipped files.

DONE WHEN
  All of A1–A28 (§34) pass, every §34.6 grep returns nothing, and the
  seven migration waves (§34.0) have each produced their mandatory outputs.
```
