# Swarm Kernel Specification v0.1 — Part 01: The SOL language

<!-- Part 01 of the Swarm Kernel Specification (§5–§6). All parts share one section numbering (§0–§35 + Appendices A–G); cross-references of the form “§N” resolve via the index in [README.md](./README.md). -->

## 5. SOL surface syntax

### 5.1 Scope and layering

This section specifies the *surface syntax* of SOL (Swarm Obligation Language): the concrete, human-authored form that appears inside `*.swarm.md` files. SOL surface syntax is the only SOL form a human writes; the snake_case IR/JSON layer (§12) is *emitted*, never authored. This is the master layering of the language: **surface is English-shaped UPPERCASE keywords; IR is snake_case fields.** Where this section gives a surface keyword (`VERIFY BY`, `DEPENDS ON`, `OWNED BY`), the corresponding IR field name (`verify_by`, `depends_on`, `owned_by`) is reserved for §12 and MUST NOT appear at the surface.

A conformant SOL document is a Markdown document (`*.swarm.md`) in which obligation content is expressed as SOL *blocks* interleaved with APS-controlled prose (§7). The full normative grammar lives in Appendix A; this section fixes the lexical and block-delimiting rules that grammar presupposes, and §6 gives the per-block clause grammars.

> Rationale: a single line-oriented EBNF supersedes all three competing research grammars. This section and §6 are that grammar's prose form; Appendix A is its formal form. The two MUST agree.

### 5.2 The block header — the one normative delimiter

A SOL block is introduced by a **bare header line** of the exact form:

```ebnf
block_header = block_type, ws, id, ":", nl;
block_type   = "REQ" | "CONSTRAINT" | "INVARIANT" | "INTERFACE"
             | "QUESTION" | "TRACE" | "VERDICT";
```

The header is a single line consisting of the block-type keyword, one or more spaces, the block id, and a **mandatory trailing colon**. Example:

```sol
REQ AC-001:
```

The trailing colon is REQUIRED. A header without it (`REQ AC-001`) is not a block header; it is prose, and any obligation clauses that follow are unparsed. A parser MUST treat the colon as the delimiter that opens a block body.

> Rationale: EARS, FRETish, and Gherkin all use leading-keyword bare lines; bare headers are used throughout. The mandatory colon (from an earlier research draft) makes the header unambiguously machine-detectable inside free Markdown.

A QUESTION header additionally carries a blocking tag *before* the colon (§6.5); this is the only header variation:

```sol
QUESTION Q-001 [blocking]:
```

### 5.3 Body line-grouping rule

A block **body** is the maximal run of contiguous non-blank lines immediately following the header, terminated by the first of:

1. the next block header (any of the seven `block_type` keywords beginning a line, with a trailing colon);
2. a **blank line** (one or more consecutive newline-only lines);
3. a **Markdown heading** line (a line beginning with one or more `#` followed by a space).

No other construct closes a body. This rule replaces both the fenced `:::TYPE …:::END` delimiter and significant indentation (see §5.4). Worked example — three blocks separated by blank lines and a heading:

```sol
REQ AC-001:
WHEN the refresh token is expired
THE client MUST clear the local session
VERIFY BY test:cmdTest:auth-refresh-expired-token

CONSTRAINT C-001:
THE auth client MUST NOT import from `server/*`
VERIFY BY static:cmdLint:dependency-boundary-check

## Invariants

INVARIANT I-001:
A user MUST NOT have more than one active refresh token family
VERIFY BY property:cmdTest:token-family-invariant
```

Here the blank line after `… local session` would also have closed `AC-001`; the `VERIFY BY` line is part of `AC-001` because it is contiguous. The `## Invariants` heading closes nothing that was still open (a blank line already closed `C-001`), and a parser MUST NOT absorb a heading into a body.

A conformant author MUST NOT place a blank line *inside* a block body, because the blank line terminates the body. Multi-item clauses (e.g. INTERFACE `ERRORS:`) therefore use contiguous indented bullet continuation lines, never blank-separated lists (§6.4).

### 5.4 Rejected surface forms (and why)

The following alternative surface forms are **rejected** for SOL v0.1. Each MAY be revisited only as noted.

| Rejected form | Example | Rationale (one clause) | Future status |
|---|---|---|---|
| Fenced block delimiter | `:::REQ AC-001 …:::END` | A second nested fence is fragile to parse inside Markdown and redundant with the bare-header rule. | MAY become an OPTIONAL editor-robustness alias in a later version; never normative in v0.1. |
| In-block YAML metadata | `verify: …` as a YAML key inside a block | Metadata-as-YAML splits one obligation across two syntaxes and breaks line-grouping; clauses are inline keyword lines instead. | Rejected; metadata is expressed as surface clauses (§6.8). |
| Significant indentation (Indent/Dedent) | indentation level encoding block nesting | Markdown renderers collapse and reflow indentation, so indentation cannot carry meaning. | Rejected; structure is carried by the line-grouping rule (§5.3). |

> Rationale: `:::`+in-block YAML is malformed in source and fragile to parse; significant indentation is destroyed by Markdown rendering. Indentation that *does* appear (e.g. bullet continuation under `ERRORS:`) is decorative continuation, not semantic nesting.

### 5.5 Keywords, case, and prose

SOL keywords are **UPPERCASE and case-sensitive**. The keyword set is closed (block types §5.2, modals §5.6, clause keywords per block in §6). A token that is not an uppercase keyword in keyword position is treated as one of:

- **prose** — free APS-controlled text (§7) outside any block, or
- **opaque condition text** — the lowercase text following a condition keyword (`WHERE`/`WHILE`/`WHEN`/`IF`) or forming an actor/response.

Lowercase `must`, `should`, `may`, `can`, `will` are **plain prose** and carry no normative force. Only the uppercase modals (§5.6) bind.

**Conditions are opaque text in v0.1.** The text after `WHEN`, `WHILE`, `WHERE`, or `IF` is captured verbatim as a string; SOL v0.1 defines no expression sublanguage, operators, or boolean structure over conditions. Example:

```sol
REQ AC-002:
WHILE the user is unauthenticated
WHEN the user opens `/settings`
THE client MUST redirect to `/login`
VERIFY BY test:cmdTest:unauthenticated-settings-redirect
```

`the user is unauthenticated` and ``the user opens `/settings` `` are opaque strings; a tool MUST NOT attempt to evaluate them.

> Rationale: the expression sublanguage is DEFERRED to v0.2. Treating conditions as opaque keeps v0.1 parseable without committing to semantics that timing/expression work (§35) will define.

### 5.6 The modal set

SOL v0.1 defines exactly **five modals**, uppercase only:

| Modal | Force |
|---|---|
| `MUST` | Required; non-satisfaction is non-compliance. |
| `MUST NOT` | Forbidden. |
| `SHOULD` | Strong default; non-satisfaction REQUIRES a same-block `BECAUSE` or `EXCEPT`. |
| `SHOULD NOT` | Strong prohibition; REQUIRES a same-block `BECAUSE` or `EXCEPT`. |
| `MAY` | Optional; carries no obligation. |

`SHALL` and `SHALL NOT` are **REMOVED** from SOL: RFC 8174 makes `MUST` ≡ `SHALL`, so `SHALL` is redundant, and courts/plain-language standards read "shall" inconsistently. `SHALL`/`SHALL NOT` are recognized only as **deprecated migration aliases** of `MUST`/`MUST NOT`: a parser accepts them on input, `lint` flags them advisory (`SOL-P003`-family), and the `NORMALIZE` improve op (§10) rewrites them to `MUST`/`MUST NOT`. They MUST NOT appear in canonical or new sources, and no template emits them.

`CAN` and `WILL` are **non-modal** (capability and prediction, respectively) and are **forbidden in binding clauses**; their use where a modal is expected is a `SOL-P003` warning (informal/missing modality).

`SHOULD` and `SHOULD NOT` without an accompanying `BECAUSE` or `EXCEPT` in the same block is a defect (`SOL-P003`-family; grammar-level `SOL-S006`).

```sol
REQ AC-010:
WHEN a request lacks a correlation id
THE gateway SHOULD generate one
BECAUSE downstream tracing requires a stable id per request
VERIFY BY test:cmdTest:gateway-correlation-id
```

> Rationale: MUST/MUST NOT/SHOULD/SHOULD NOT/MAY are the RFC 2119/8174 force-bearing words; `SHALL` is redundant; `CAN`/`WILL` carry no force and invite ambiguity.

### 5.7 The ID convention

Each block carries a **per-type short id** of the form `PREFIX-NNN`, where the prefix is fixed by block type:

| Block type | ID prefix | Example |
|---|---|---|
| `REQ` | `AC-` | `AC-001` |
| `CONSTRAINT` | `C-` | `C-001` |
| `INVARIANT` | `I-` | `I-001` |
| `INTERFACE` | `IF-` | `IF-001` |
| `QUESTION` | `Q-` | `Q-001` |
| `TRACE` | `T-` | `T-001` |
| `VERDICT` | — (reuses the judged obligation's id) | `VERDICT AC-001:` |

`NNN` is one or more decimal digits. A prefix that does not match its block type is a `SOL-S005` error (prefix↔type mismatch). IDs MUST be unique within a single `*.swarm.md` spec (an intra-spec duplicate is `SOL-S004`; a cross-spec collision is `SOL-M001`).

A **cross-spec reference** qualifies the id with the source spec id using a **hash** separator: `spec-id#AC-001` (e.g. `auth-refresh#AC-001`). The hash is chosen over a colon because `:` is already the block-header delimiter (`REQ AC-001:`) and the `verify_ref` delimiter (`type:adapter:artifact`), whereas `#` already denotes "a target within a named container" (it is the `verify_ref` selector separator, §15); a colon-qualified `auth-refresh:AC-001` is a single-pass tokenizer ambiguity against a block header, which the hash form removes. Example: a TRACE in one spec referencing an obligation in `auth-refresh`:

```sol
TRACE T-003:
IMPLEMENTS auth-refresh#AC-001
CHANGED src/auth/client.ts
PROOF test:cmdTest:auth-refresh-expired-token passed
```

Dotted / namespaced ids (`REQ.auth-refresh.AC-001`) are **IR-only** (§12); they MUST NOT appear at the surface. The single-spec-prefix form `CO-NNN` is rejected at the surface.

> Rationale: per-type prefixes give stable, opaque traceability keys decoupled from text; the dotted form belongs to the IR namespace.

### 5.8 Frontmatter

Every `*.swarm.md` source spec MUST begin with a YAML frontmatter block. The version fields are normalized (G10) as:

| Field | Form | Meaning |
|---|---|---|
| `swarm_language` | `SOL/0.1` | The SOL language discriminator (the "which grammar/blocks/modals/lint-codes" axis, §25). MUST be present. |
| `aps_version` | `0.1` | The APS prose-standard version (§7). MUST be present. |
| `spec_version` | `0.1.0` | The spec *content* version (semver of this document's intent). MUST be present. |
| `title` | string | Human title. |
| `status` | `draft \| approved \| superseded` | Lifecycle status of the spec. |
| `owners` | list | Accountable owners. |
| `imports` | list of spec ids | Specs whose obligations this spec may reference cross-spec (§5.7). |

```sol
---
swarm_language: SOL/0.1
aps_version: 0.1
spec_version: 0.1.0
title: Auth refresh
status: draft
owners: [auth-team]
imports: [session-core]
---

# Spec: Auth refresh
```

> Rationale (G10): three distinct version axes MUST never be merged — `swarm_language` is the language discriminator, `spec_version` is content, and (when a tool exists) `provenance.compiler_version` is the tool version. The frontmatter carries the first two; the IR echoes all three (§12).

### 5.9 Interleaving SOL and prose

SOL blocks and APS prose coexist in one `*.swarm.md`. Prose is **commentary**; a typed obligation block is **binding** (G2): a span is *binding* iff it lies inside a `REQ`, `CONSTRAINT`, or `INVARIANT` block, and *commentary* otherwise. This boundary governs which lint codes apply (a high-risk word is blocking in a binding clause, advisory in commentary — §7, §8). Load-bearing meaning (modality, actor, trigger, verification binding) MUST live in SOL blocks, never in surrounding prose.

---

## 6. SOL block-type reference

SOL v0.1 defines exactly **seven block types**. Three carry **binding force** (they are *obligation blocks*): `REQ`, `CONSTRAINT`, `INVARIANT`. The remaining four declare boundaries (`INTERFACE`), mark ambiguity (`QUESTION`), claim implementation (`TRACE`), or judge an obligation (`VERDICT`). `TASK-MAP`, `FINDING`, and `ADR` are **not** SOL block types — they are downstream artifacts (§21).

This section gives, per block: purpose; whether it binds; the clause grammar in canonical order; semantics; and at least one worked example. Clause keywords are uppercase and case-sensitive (§5.5). The trailing **metadata clauses** `DEPENDS ON`, `TOUCHES`, `WRITES`, `READS`, `AFFECTS`, and `RISK <low|medium|high|critical>` are available on obligation blocks (REQ/CONSTRAINT/INVARIANT) and feed orchestration (§18); they are space-separated uppercase at the surface and lower to snake_case edges/scalars in the IR (§12).

### 6.1 REQ — required behavior

**Purpose.** A `REQ` declares a required behavior: under stated conditions, an actor must produce an observable response. **Binding: yes** (obligation block).

**Clause grammar (canonical order).** Clauses MUST appear in this order; bracketed clauses are optional:

```ebnf
req_block = "REQ", ws, ac_id, ":", nl,
            [ "WHERE", ws, cond, nl ],
            [ "WHILE", ws, cond, nl ],
            [ "WHEN", ws, cond, nl ],
            [ "IF", ws, cond, [ ws, "THEN" ], nl ],
            actor_clause, { and_actor_clause },
            [ "BECAUSE", ws, prose, nl ],
            [ "EXCEPT", ws, prose, nl ],
            verify_line,
            { metadata_clause };
actor_clause     = "THE", ws, actor, ws, modal, ws, response, nl;
and_actor_clause = "AND", ws, "THE", ws, actor, ws, modal, ws, response, nl;
verify_line      = "VERIFY BY", ws, verify_ref, nl;
metadata_clause  = depends_on | touches | writes | reads | affects | risk;
```

Notes on the order and keywords:

- `WHERE` (optional ubiquitous context) → `WHILE` (state/precondition) → `WHEN` (trigger/event) → `IF` (fault/error condition). These four are the EARS condition keywords; their text is opaque (§5.5).
- **`THEN` is optional sugar after `IF` only** (the EARS unwanted-behavior pattern). It MUST NOT appear after `WHEN`, `WHILE`, or `WHERE`. `IF … THEN …` and `IF … <newline> THE …` are equivalent.
- `THE <actor> <MODAL> <response>` is the mandatory consequence. A condition keyword with no following actor clause is `SOL-S001` (dangling condition); an actor clause with no modal is `SOL-S003`.
- **`AND THE` chaining is permitted.** Each `AND THE …` adds a second consequence; on lowering, each `THE …`/`AND THE …` becomes a **separate IR obligation** (§11). More than two chained consequences emits a **warning** (`SOL-P004`-adjacent, atomize suggested), never a hard error (G3).
- `BECAUSE` (rationale) and `EXCEPT` (exception) are optional, but one of them is REQUIRED whenever any consequence uses `SHOULD`/`SHOULD NOT` (§5.6).
- `VERIFY BY` is REQUIRED for a binding REQ; its absence is `SOL-V001`. The reference grammar is `<type>:<adapter>:<artifact>[#selector]` (§15).

**Worked example — multi-consequence with trigger:**

```sol
REQ AC-001:
WHEN the user submits the signup form
AND the email field is empty
THE client MUST show "Email is required"
AND THE client MUST NOT send a signup request
VERIFY BY test:cmdTest:signup-empty-email
DEPENDS ON AC-000
WRITES src/signup/**
RISK medium
```

This lowers to two IR obligations (one per `THE`/`AND THE`), both carrying the same `WHEN … AND …` conditions and the same `verify_by`. `the email field is empty` is opaque condition text appended to the `WHEN` trigger.

**Worked example — `IF … THEN` unwanted-behavior:**

```sol
REQ AC-003:
IF the payment provider times out THEN
THE server MUST NOT create an order
AND THE server MUST record a retryable payment attempt
VERIFY BY test:cmdTest:payment-timeout
```

### 6.2 CONSTRAINT — restriction on the solution space

**Purpose.** A `CONSTRAINT` restricts *how* obligations may be satisfied — it bounds the solution space rather than requesting a behavior. **Binding: yes** (obligation block).

There is no separate `POLICY` block type. Authority and enforcement attributes of a constraint are **metadata** (e.g. `OWNED BY` on the surface, `authority` in the IR), not a distinct block type.

**Clause grammar (canonical order).**

```ebnf
constraint_block = "CONSTRAINT", ws, c_id, ":", nl,
                   [ "WHERE", ws, cond, nl ],
                   actor_clause, { and_actor_clause },
                   [ "BECAUSE", ws, prose, nl ],
                   [ "EXCEPT", ws, prose, nl ],
                   verify_line,
                   { metadata_clause };
```

**Semantics.** A CONSTRAINT identifies the actor/surface being constrained and the forbidden or required limit, using a modal (typically `MUST NOT`). It is not a behavior request; it persists across tasks as a guard. A CONSTRAINT MUST carry a `VERIFY BY` binding (a static check, a contract, or `manual:` review); its absence is `SOL-V001`.

**Worked example:**

```sol
CONSTRAINT C-001:
THE auth client MUST NOT import from `server/*`
BECAUSE the client bundle must not embed server-only secrets
VERIFY BY static:cmdLint:dependency-boundary-check
AFFECTS src/auth/**
```

### 6.3 INVARIANT — always-held property

**Purpose.** An `INVARIANT` declares a property that MUST hold at all times, not a one-time behavior. **Binding: yes** (obligation block).

**Clause grammar (canonical order).**

```ebnf
invariant_block = "INVARIANT", ws, i_id, ":", nl,
                  property, ws, ( "MUST" | "MUST NOT" ), ws, predicate, nl,
                  [ "BECAUSE", ws, prose, nl ],
                  verify_line,
                  { metadata_clause };
```

**Semantics.** The invariant body is `<property> MUST|MUST NOT <hold>`. The words `ALWAYS` and `NEVER` are **removed** (redundant with the always-held semantics of the block; ASD-STE100 one-word-one-meaning); an author MUST NOT write `ALWAYS`/`NEVER`. An INVARIANT MUST NOT describe a one-time triggered behavior (that is a `REQ`).

An INVARIANT **PREFERS** a `property`, `model`, or `static` proof, because those proof types can assert a property over all states. Binding an INVARIANT *only* to a non-observable unit `test` is a **`SOL-V` warning** (a single example execution does not establish an always-held property) — see §15 for the proof taxonomy and §16 for why a once-green test is not perpetually valid.

**Worked example:**

```sol
INVARIANT I-001:
A user MUST NOT have more than one active refresh token family
VERIFY BY property:cmdTest:token-family-invariant
```

> Rationale (Theme-5 gap-fill): proof strength `model > property/contract > test > static > manual/monitor` (§15) is why an INVARIANT prefers the upper end; a bare unit test understates the obligation.

### 6.4 INTERFACE — declared boundary

**Purpose.** An `INTERFACE` names a boundary, API, function, schema, command, module, or contract. It declares the surface other obligations reference. **Binding: no** (it declares boundaries; it does not by itself command behavior), but it **REQUIRES a verification binding** (see below).

**Clause grammar (canonical order).**

```ebnf
interface_block = "INTERFACE", ws, if_id, ":", nl,
                  signature, ws, "RETURNS", ws, return_type, nl,
                  [ "ACCEPTS", ":", nl, bullet_list ],
                  [ "ERRORS", ":", nl, bullet_list ],
                  [ "OWNED BY", ws, owner, nl ],
                  verify_line;
bullet_list = { ws, "-", ws, item, nl };
```

`ACCEPTS:` and `ERRORS:` introduce contiguous bullet continuation lines (not blank-separated — a blank line would close the body, §5.3). `OWNED BY` records the owning surface/team/module.

**Semantics and the required contract binding.** An INTERFACE **MUST carry a `VERIFY BY contract:` binding** — a `contract`-type proof asserting that the named boundary's shape (signature, accepted inputs, returned type, declared errors) matches reality. An INTERFACE with **no** `VERIFY BY` at all is `SOL-V001` (no-verification-path); an INTERFACE that carries a `VERIFY BY` whose proof type is **not** `contract` is `SOL-V006` (interface-without-contract). An undeclared interface referenced by an obligation is `SOL-M004`.

**Worked example:**

```sol
INTERFACE IF-001:
`refreshSession` RETURNS `Session | AuthExpired`
ACCEPTS:
  - `refreshToken: string`
ERRORS:
  - network-timeout
  - invalid-refresh-token
OWNED BY auth-client
VERIFY BY contract:cmdContract:refresh-session-contract
```

### 6.5 QUESTION — marked ambiguity

**Purpose.** A `QUESTION` records an explicit unresolved ambiguity. **Binding: no.**

**Clause grammar (canonical order).** The blocking tag appears in the header, before the colon:

```ebnf
question_block = "QUESTION", ws, q_id, ws, blocking_tag, ":", nl,
                 question_text, nl,
                 "AFFECTS", ws, affects_ref, nl;
blocking_tag = "[blocking]" | "[non-blocking]";
```

The `[blocking|non-blocking]` tag is REQUIRED. `AFFECTS` names the obligation ids or surfaces the answer would change.

**Semantics.** A **blocking** QUESTION prevents lowering of any obligation it `AFFECTS`. A blocking QUESTION that reaches the lower pass (§11) is an **orchestration error** (`SOL-O`-class): it means an unresolved decision is being compiled into tasks. A **non-blocking** QUESTION may remain open if it does not affect assigned obligations. Behavioral uncertainty MUST be lifted into a QUESTION rather than left as hedged prose (`SOL-P008`).

**Worked example:**

```sol
QUESTION Q-001 [blocking]:
Should expired sessions redirect to `/login` or show an inline re-auth modal?
AFFECTS AC-001
```

### 6.6 TRACE — implementation claim

**Purpose.** A `TRACE` records a claim that obligations were implemented, naming the changed surfaces and the proofs run. **Binding: no** (it claims; it is judged by VERDICT). A TRACE is the input to the review pass (§14).

**Clause grammar (canonical order).**

```ebnf
trace_block = "TRACE", ws, t_id, ":", nl,
              "IMPLEMENTS", ws, id_list, nl,
              [ "PRESERVES", ws, id_list, nl ],
              "CHANGED", ws, path_list, nl,
              { "PROOF", ws, verify_ref, ws, proof_result, nl };
```

**Semantics.** `IMPLEMENTS` lists the REQ ids the change satisfies; `PRESERVES` lists the CONSTRAINT/INVARIANT ids the change must not violate; `CHANGED` names the modified surfaces (the basis for staleness detection, §16); each `PROOF` line names a verification reference (`verify_ref`, §15) and its observed `proof_result` — one of `passed | failed | blocked | unverified` (Appendix A); `manual` is a proof *type* (§15), never a result. A TRACE referencing an unknown obligation is `SOL-S009`; a TRACE that claims implementation with no `PROOF` is `SOL-M007`. A `PROOF` line MUST reference real output — an unqualified "tests passed" is not an admissible proof (§15, §17).

**Worked example:**

```sol
TRACE T-001:
IMPLEMENTS AC-001, AC-002
PRESERVES C-001
CHANGED src/auth/client.ts, src/auth/session-store.ts
PROOF test:cmdTest:auth-refresh-expired-token passed
PROOF test:cmdTest:auth-refresh-no-loop passed
PROOF static:cmdLint:dependency-boundary-check passed
```

### 6.7 VERDICT — judgment of an obligation

**Purpose.** A `VERDICT` records the review judgment of one obligation. **Binding: no.** A VERDICT **reuses the judged obligation's id** (it does not mint a new id); its container is `review.md` (§21) — there is no `verdict.md`.

**Clause grammar (canonical order).**

```ebnf
verdict_block = "VERDICT", ws, judged_id, ":", ws, core_value,
                [ ws, "(", lifecycle, " by ", authority, ": ", reason_txt, ")" ], nl,
                [ "REASON", ws, prose, nl ],
                [ "EVIDENCE", ws, reference, nl ];
core_value = "PASS" | "FAIL" | "BLOCKED" | "UNVERIFIED";
lifecycle  = "WAIVED" | "STALE" | "CONTRADICTED";
```

**Semantics.** A VERDICT carries exactly one **core** value plus an optional **lifecycle decorator** in parentheses (the full 7-value model and the merge gate are specified in §14). The four core values:

| Core | Meaning |
|---|---|
| `PASS` | A bound proof ran and succeeded; evidence satisfies the obligation. |
| `FAIL` | A bound proof ran and failed, or the diff contradicts the obligation. |
| `BLOCKED` | The proof could not run (prerequisite, tool, or environment missing). |
| `UNVERIFIED` | No acceptable proof was bound, or none was executed. |

A value outside the core four is a lint error (was `SOL-S010`, now `SOL-V`-family). The lifecycle decorators `WAIVED`, `STALE`, `CONTRADICTED` and their mandatory fields (authority/reason/expiry, etc.) are specified in §14 and §16. `REASON` gives the human justification; `EVIDENCE` references the inspected proof output.

**Worked example — plain PASS:**

```sol
VERDICT AC-001: PASS
REASON The branch clears the local session and redirects to `/login` when token expiry is simulated.
EVIDENCE test:cmdTest:auth-refresh-expired-token output in review log
```

**Worked example — waived FAIL (lifecycle decorator):**

```sol
VERDICT AC-002: FAIL (WAIVED by auth-team: flaky e2e env, expires 2026-07-01)
REASON The e2e proof could not be stabilized this cycle.
EVIDENCE test:cmdTest:auth-refresh-no-loop intermittent failure log
```

### 6.8 Metadata clauses (orchestration inputs)

The following clauses MAY trail any obligation block (REQ/CONSTRAINT/INVARIANT). They carry no behavioral force themselves; they feed orchestration and the safe-parallelism predicate (§18). Surface form is space-separated uppercase; IR form is snake_case (§12).

| Surface clause | Meaning | IR lowering |
|---|---|---|
| `DEPENDS ON <id-list>` | Hard ordering against other obligations. | `depends_on` edges |
| `TOUCHES <surface-list>` | Optional, advisory: surfaces incidentally affected, weaker than `WRITES`. **Not consumed by the safe-parallelism predicate** (§18), which reads only `WRITES`/`READS`; `TOUCHES` is documentation, never a conflict or staleness signal. | `touches` scalar |
| `WRITES <surface-list>` | Write surfaces this obligation owns. | `writes` set / conflict edges |
| `READS <surface-list>` | Read set. | `reads` set |
| `AFFECTS <surface-or-id-list>` | Impact set (downstream effect). | `affects` edges |
| `RISK <low\|medium\|high\|critical>` | Risk tier. | `risk` scalar |

```sol
REQ AC-005:
WHEN a checkout completes
THE server MUST emit an `order.created` event
VERIFY BY test:cmdTest:order-created-event
DEPENDS ON AC-004
WRITES src/orders/**
READS src/catalog/**
AFFECTS analytics-pipeline
RISK high
```

A lock group is expressed as a named `SURFACE` (`SURFACE x = …`), never a `locks` primitive (§18); `WRITES`/`READS` over surfaces is the basis of write-disjointness analysis.
