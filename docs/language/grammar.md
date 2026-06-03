# The SOL Grammar — Consolidated EBNF Reference

> Swarm's single formal grammar for the SOL surface language: the complete EBNF for everything you write inside a `*.swarm.md` file, the lint constraints attached to each production, and the v0.1 rules for opacity and deferral.

This page is the **complete, formal grammar** for SOL (the Swarm Obligation Language) — the human-authored `.swarm.md` surface syntax. A conformant `.swarm.md` parser MUST accept exactly the language this grammar generates and MUST reject any input outside it. Where [SOL.md](SOL.md) *teaches* the surface with prose, tables, and worked examples, this page is the **lossless reference**: every production, in one place, with no narrative gaps.

It is **markdown-only and provider-neutral**: nothing here is shipped code. A "parser" is the contract a future tool builds against; this repository runs no parser, linter, or lowering step. The grammar is the contract; the tool, when it exists, conforms to it.

This grammar fixes a single surface shape and **rejects** three alternative shapes — the fenced `:::TYPE …:::END` form, the significant-indentation `Indent`/`Dedent` form, and the colon-less header form. Each of those is **non-conformant**; this EBNF is the only normative shape. *Design rationale:* one greppable surface, machine-detectable inside free Markdown, with no construct a Markdown renderer can reflow away.

---

## 1. The surface-vs-IR layering (read this first)

There is one master layering of the language, and this page describes only one half of it.

- **Surface** — what a human writes — is **English-shaped UPPERCASE keywords** (`VERIFY BY`, `DEPENDS ON`, `OWNED BY`). This grammar is the surface.
- **IR** — what a tool *emits*, never authored — is **snake_case fields** (`verify_by`, `depends_on`, `owner`).

The EBNF below is the human surface; it never describes the IR. Wherever a surface keyword appears here, the corresponding snake_case field is reserved for the IR layer and MUST NOT appear at the surface. The IR envelope is specified separately in [the IR schema](../reference/ir-schema.md); this separation is one of the framework's load-bearing invariants. Keywords are UPPERCASE and case-sensitive; lowercase `must`/`should`/`may` and lowercase keywords carry no force and are parsed as prose.

---

## 2. The line-oriented model

The grammar is **line-oriented**. A block is a bare header line `TYPE PREFIX-NNN:` followed by contiguous non-blank body lines, terminated by the next block header, a blank line, or a Markdown heading (`#`). There is **no closing delimiter and no significant indentation**.

In v0.1 the arguments of conditions (`WHERE`/`WHILE`/`WHEN`/`IF`) are **opaque text** (`condition_text` below): the structured expression sublanguage and the timing keywords (`WITHIN`, `BEFORE`, `UNTIL`, `IMMEDIATELY`, `EVENTUALLY`) are deferred to v0.2. The opacity and deferral rules are normative and appear in full in §4.

---

## 3. Normative EBNF

This is the single normative grammar for the SOL surface syntax. The IR/JSON layer is not specified here (see [the IR schema](../reference/ir-schema.md)); surface keywords are space-separated uppercase, IR fields are snake_case.

```ebnf
(* ===== Document and frontmatter ===== *)
document          = [ frontmatter ], { markdown_line | blank | surface_decl | block };

frontmatter       = "---", nl, fm_field, { fm_field }, "---", nl;        (* YAML mapping — keys are UNORDERED *)
fm_field          = yaml_key, ":", ws, yaml_scalar, nl;
(* REQUIRED keys (each appears exactly once, in any order): type (= spec), id,
   swarm_language (SOL/x.y), aps_version (x.y), spec_version (semver),
   status (draft|review|approved|superseded).
   OPTIONAL keys: title, owners, imports, domain, created, updated. *)

markdown_line     = ? any line not beginning a block header and not "---" ?, nl;
blank             = ws, nl;

(* ===== Surface declarations (lock groups are named SURFACEs; there is no `locks` primitive) ===== *)
surface_decl      = "SURFACE", ws, surface_name, ws, "=", ws,
                    glob, { ws, ",", ws, glob },
                    [ ws, "[", surface_attr, "]" ], nl;     (* attr: append-only|integration|shared *)
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
cross_spec_ref    = spec_id, "#", ( req_id | constraint_id | invariant_id
                                    | interface_id | question_id | trace_id );
digits            = digit, { digit };

(* ===== REQ clause grammar, in canonical order ===== *)
req_body          = [ where_clause ]
                    [ while_clause ]
                    [ when_clause ]
                    [ if_clause ]
                    actor_clause
                    { and_actor_clause }      (* AND THE …: permitted; lowered to multiple IR obligations *)
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
constraint_body   = [ where_clause ]
                    actor_clause
                    { and_actor_clause }
                    [ because_clause ]
                    [ except_clause ]
                    verify_line
                    { metadata_clause };

(* ===== INVARIANT: <property> MUST|MUST NOT <hold> (no ALWAYS/NEVER) ===== *)
invariant_body    = property, ws, inv_modal, ws, hold_text, nl,
                    [ because_clause ],
                    verify_line,
                    { metadata_clause };
property          = ? noun phrase naming the invariant property/state ?;
inv_modal         = "MUST" | "MUST NOT";                       (* only these two for INVARIANT *)
hold_text         = ? verb phrase asserting the held property ?;

(* ===== INTERFACE: RETURNS, ACCEPTS, ERRORS, OWNED BY; requires VERIFY BY contract ===== *)
interface_body    = signature, ws, "RETURNS", ws, type_ref, nl,
                    [ accepts_block ]
                    [ errors_block ]
                    [ owned_by_clause ]
                    verify_line;                                (* OWNED BY before VERIFY BY; INTERFACE carries no scope/metadata clauses *)
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
                    "EVIDENCE", ws, evidence_ref, nl, { "EVIDENCE", ws, evidence_ref, nl };
verdict_value     = verdict_core, [ ws, verdict_lifecycle ];
verdict_core      = "PASS" | "FAIL" | "BLOCKED" | "UNVERIFIED";
verdict_lifecycle = "(", lifecycle, " by ", authority, ": ", reason, [ ";", ws, lifecycle_fields ], ")";
lifecycle_fields  = field, { ";", ws, field };          (* WAIVED→expiry (lifecycle_field); STALE→changed-surface (lifecycle_field; prior-verdict given as the reason); CONTRADICTED→its two evidence refs carried as EVIDENCE body lines, not lifecycle_fields *)
field             = field_key, ws, field_value;         (* e.g. "expiry 2026-07-01" *)
lifecycle         = "WAIVED" | "STALE" | "CONTRADICTED";

(* ===== VERIFY BY binding : typed, closed 9-set ===== *)
verify_line       = "VERIFY BY", ws, verify_ref, nl;
verify_ref        = typed_ref | bare_ref;
typed_ref         = proof_type, [ ":", test_scope ], ":", adapter, ":", artifact, [ "#", selector ];
proof_type        = "static" | "test" | "contract" | "property" | "model"
                  | "perf"   | "security" | "manual" | "monitor";          (* closed; no other type is legal *)
test_scope        = "unit" | "integration" | "e2e";                        (* only when proof_type = "test" *)
bare_ref          = ? opaque proof ref, no proof_type segment; valid but raises the advisory untyped-binding smell ?;
adapter           = ? project free-string; resolves through AGENTS.md > Commands (cmd* slot) ?;
artifact          = ? project free-string; file/target the adapter runs ?;
selector          = ? optional sub-target, e.g. a test name or invariant name ?;
(* test scope qualifiers are spelled in the adapter position: test:unit:… test:integration:… test:e2e:… *)

(* ===== Trailing metadata clauses (surface = space-separated UPPERCASE) ===== *)
metadata_clause   = depends_on | touches | writes | reads | affects | risk | domain;
depends_on        = "DEPENDS ON", ws, ref_list, nl;
touches           = "TOUCHES", ws, surface_list, nl;
writes            = "WRITES", ws, surface_list, nl;
reads             = "READS", ws, surface_list, nl;
affects           = "AFFECTS", ws, ref_list, nl;
risk              = "RISK", ws, ( "low" | "medium" | "high" | "critical" ), nl;
domain            = "DOMAIN", ws, domain_name, nl;                       (* per-obligation Axis-B domain *)
domain_name       = "enforced-policy" | "compliance" | "security" | "architecture"
                  | "product" | "team" | "task-map" | "memory";

(* ===== Modal terminals: exactly five. SHALL / SHALL NOT are not modals; CAN / WILL are not modals. ===== *)
modal             = "MUST NOT" | "MUST" | "SHOULD NOT" | "SHOULD" | "MAY"; (* longest-match: NOT before bare *)
(* "SHALL", "SHALL NOT": recognized deprecated aliases of MUST / MUST NOT (lint SOL-P058 advisory; NORMALIZE rewrites them).                              *)
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
prose_text        = ? free APS-governed prose ?;
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

---

## 4. Opacity and deferral (normative for v0.1)

These rules are part of the grammar's contract. A conformant parser MUST honor them.

1. **Opaque single-line text.** `condition_text`, `question_text`, `response`, `hold_text`, and `prose_text` are opaque single-line text in v0.1. No structured expression grammar (operators, comparisons, `AND`/`OR`) is defined; a parser MUST NOT attempt to tokenize their interior. The expression sublanguage is deferred to v0.2.
2. **Timing keywords are deferred.** `WITHIN`, `BEFORE`, `UNTIL`, `IMMEDIATELY`, `EVENTUALLY` are **not productions in this grammar**; they are reserved for v0.2 (FRETish temporal semantics). Their appearance in a `.swarm.md` is parsed as opaque prose and SHOULD raise an advisory pointing to the deferral.
3. **Rejected keywords.** `ALWAYS`/`NEVER` (as INVARIANT openers), `EXPOSES`/`INPUT`/`OUTPUT` (as INTERFACE clauses), and `MAP`/`TO`/`ORDER`/`ASK` are not part of the grammar and have no production; they MUST be rejected.
4. **`THEN` placement.** `THEN` is legal only as the optional trailing sugar of `if_clause`; after `WHEN`/`WHILE` it MUST be rejected as a parse error.
5. **Indentation is non-semantic.** A block body **clause** line MAY carry leading whitespace; that whitespace is stripped before the line is matched against its body production. Block **headers** (`req_header`, `constraint_header`, … and `surface_decl`) MUST remain flush-left (no leading whitespace). The `[ ws ]` allowance applies only to body clause lines.
6. **SOL has no comment token.** There is no `comment` production anywhere in this grammar. `#` is reserved exclusively for the `cross_spec_ref` separator (`spec_id#id`) and the `verify_ref` `#selector`. A trailing or standalone `# …` annotation is therefore **not** part of the language; any `# …` annotation surrounding an example is editorial marginalia, not a parseable line a conformant parser admits.
7. **Opaque-text line continuation.** Where a clause's value is opaque text (`condition_text`, `question_text`, `response`, `hold_text`, `prose_text` — note 1; in particular a `REASON` line's `prose_text` in `verdict_body`), a following physical line that does **not** begin with a recognized keyword (a block header, a clause keyword such as `EVIDENCE`/`AFFECTS`/`VERIFY BY`, or a metadata field) is a **continuation** of the preceding clause: it is joined to that clause's opaque text (with a single separating space) before matching. This is why a `VERDICT`'s `REASON` may wrap across two physical lines while `verdict_body` shows `REASON` as a single logical clause. The continuation joins text only; it never introduces structure (no expression grammar — note 1).

---

## 5. Lint constraints attached to grammar productions

Each grammar production carries one or more well-formedness checks from the unified lint namespace `SOL-<LAYER><NNN>`. A `SOL-S###` code is raised when the input cannot be parsed by the production; a `SOL-P###`/`SOL-V###` code is raised when the input parses but violates a higher-layer rule. The full catalogue lives on the [lint reference](errors.md); the codes below are the subset directly attached to grammar productions.

A note on layering: a missing or malformed proof binding (`VERIFY BY`) and a malformed `VERDICT` value are **verification** defects, not parse defects, so they carry `SOL-V` codes even though they read like syntax. This is why what looks like "a missing `VERIFY BY`" fires at the verification layer rather than at parse.

| Code | Layer | Severity | Production / trigger | Diagnostic |
|------|-------|----------|----------------------|------------|
| `SOL-S001` | SYNTAX | BLOCKING | `where_clause`/`while_clause`/`when_clause`/`if_clause` present with no following `actor_clause` | Precondition (`WHERE`/`WHILE`/`WHEN`/`IF`) with no actor clause; add `THE <actor> <MODAL> <response>`. |
| `SOL-S002` | SYNTAX | BLOCKING | `block_header` is not one of the 7 block types, or a body line uses an unknown/malformed clause keyword | Unknown block type or clause keyword; use a valid block type / clause keyword. (A trigger with no following `actor_clause` is `SOL-S001`.) |
| `SOL-S003` | SYNTAX | BLOCKING | `actor_clause`/`and_actor_clause` with no `modal` terminal | Actor clause with no modal; use `MUST`, `MUST NOT`, `SHOULD`, `SHOULD NOT`, or `MAY` (`SHALL`/`CAN`/`WILL` are not modals). |
| `SOL-S004` | SYNTAX | BLOCKING | Two `block_header` productions share the same `*_id` within one spec file | Duplicate block ID (intra-spec); renumber the second block. (Cross-spec collisions are `SOL-M001`.) |
| `SOL-S011` | SYNTAX | BLOCKING | `block_header` with no `*_id` | Missing obligation ID after the block type; add `PREFIX-NNN:`. |
| `SOL-S005` | SYNTAX | BLOCKING | `*_id` prefix does not match `block_header` type (e.g. `CONSTRAINT AC-001:`) | ID prefix/block-type mismatch; `REQ→AC-`, `CONSTRAINT→C-`, `INVARIANT→I-`, `INTERFACE→IF-`, `QUESTION→Q-`, `TRACE→T-`. |
| `SOL-S006` | SYNTAX | BLOCKING | `actor_clause` modal is `SHOULD`/`SHOULD NOT` with no `because_clause` or `except_clause` in the same block | `SHOULD`/`SHOULD NOT` used without `BECAUSE` or `EXCEPT`. |
| `SOL-P003` | PROSE | BLOCKING | `modal` slot filled by `CAN`/`WILL` or a lowercase/informal modal in a binding clause | Missing or informal modality in a binding clause; use a real uppercase modal. |
| `SOL-P004` | PROSE | BLOCKING / ADVISORY | `req_body`/`constraint_body` bundling separable obligations into one clause (BLOCKING), or more than two chained `and_actor_clause` (ADVISORY warning) | Bundled/overloaded obligation: a single clause carrying multiple separable obligations is BLOCKING (`ATOMIZE`); the *permitted* `AND THE` chain beyond two is a non-blocking warning (lowered to multiple IR obligations). |
| `SOL-V001` | VERIFICATION | BLOCKING | binding obligation (`REQ`/`CONSTRAINT`/`INVARIANT`/`INTERFACE`) with no `verify_line` | Missing `VERIFY BY` for a binding obligation. |
| `SOL-V009` | VERIFICATION | BLOCKING | `verify_ref` whose `proof_type` is outside the closed 9-set | Unknown proof type; use one of `static, test, contract, property, model, perf, security, manual, monitor`. |
| `SOL-V005` | VERIFICATION | BLOCKING | `verdict_value` `verdict_core` outside the four core values, or `verdict_lifecycle` missing a mandatory field | `VERDICT` value outside `PASS`/`FAIL`/`BLOCKED`/`UNVERIFIED`, or a lifecycle decorator missing authority/reason (`WAIVED` also requires expiry). |
| `SOL-V006` | VERIFICATION | BLOCKING | `INTERFACE` `verify_line` whose `proof_type` ≠ `contract` | `INTERFACE` MUST be verified by a `contract:` binding. |

The lint layers are **S/P/M/V/O** (Syntax / Prose / seMantic / Verification / Orchestration). This page reproduces only the production-attached subset; the cross-reference (`SOL-M`) and orchestration (`SOL-O`) layers, the severity model, and the diagnostic-record shape are on the [lint reference](errors.md).

---

## Related

Other framework pages that extend or consume this grammar:

- [SOL — the Swarm Obligation Language (surface reference)](SOL.md) — the prose-and-examples teaching companion to this formal grammar; the seven block types, the five modals, and the seven-value verdict model in narrative form.
- [The IR schema](../reference/ir-schema.md) — the snake_case `*.swarm.ir.json` envelope this surface lowers into; the other half of the surface-vs-IR layering.
- [Lint codes](errors.md) — the full `SOL-<LAYER><NNN>` catalogue and severity model behind the production-attached codes cited here.
- [APS — the controlled-prose standard](APS.md) — the prose layer (`prose_text`) SOL blocks interleave with, and the high-risk-word rules.
- [Proof types](../reference/proof-types.md) — the closed nine proof types and `VERIFY BY` adapter resolution that `verify_ref` binds.
- [Language versioning](versioning.md) — the version axes that decide which grammar (`SOL/x.y`) applies, and the deferral of the v0.2 expression and timing sublanguages noted in §4.
