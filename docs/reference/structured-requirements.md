# Structured requirements (SOL)

*Works today — plain markdown plus your agent; no Corpus tooling required.*

SOL is Corpus's stricter spec surface — a structured requirements notation, selected per file
with `format: sol` in the spec's frontmatter — the frontmatter field is the entire selector. (Some external
material suffixes SOL files `.swarm.md`; Corpus treats that as a harmless private filename
convention carrying no meaning of its own.) The default spec form is plain markdown:
`### AC-NNN` headings with one behavior sentence and a `Verify with:` line (see
[Writing specs](../04-writing-specs.md)). SOL trades a little writing freedom for shapes a
reviewer can scan and a parser can read: fixed clause order, explicit strength words, and a
resolved verification binding on every requirement. Reach for it on high-risk work, or when
you want a spec that swarm-cli can check mechanically. The requirement shape follows the
EARS controlled-requirements pattern, which has industry precedent in agent-facing spec
tooling [[KIRO]](../research/sources.md#KIRO).

## Two surfaces, one model

This section is the normative home of the shared data model — every other page and template
links here; none restates it. Plain markdown and SOL are two surfaces over **one requirement
record**; nothing downstream — task packets, review packets, checks — depends on which
surface a spec uses.

**1. The requirement record.** Every requirement, in either form, is the same
form-agnostic record:

```
{ id, strength, statement, verify_refs[], kind, edges[] }
```

and every spec adds one spec-level record:
`{ intent, non_goals[], open_questions[], affected_areas[], sources[] }`.
`edges` holds relationships to other requirements (dependencies, affected ids). SOL writes
them as metadata clauses; in plain form they live in prose, or are simply absent.

**2. Spec-scoped ID namespace.** A plain `### AC-001` heading and a SOL `REQ AC-001:` header mint
the _same_ id. Ids are unique **within a file** (C001) and **scoped to their spec** — a bare
`AC-001` may recur in another spec; a reference that crosses a spec boundary qualifies as
`SPEC-x#AC-NNN` ([ADR-0080](../adrs/0080-spec-scoped-requirement-ids.md)). Rewriting a spec from
plain form to SOL (or back) keeps every id — references from tasks, reviews, and findings never break.

**3. Shared strength words.** The strength scale is one enum across both surfaces. Plain form
uses one lowercase binding word per requirement sentence (_must_, _must not_, _should_,
_should not_, _may_); SOL uses the same words uppercase, as explicit tokens. See
[Strength words](#strength-words).

**4. One verification field, two precisions.** Plain `Verify with: <ref>` is an _unresolved
note_ — a pointer the reviewer chases; if the named test or command does not exist yet, the
requirement reviews as **Unverified**, never as a broken spec. SOL
`VERIFY BY <method>:<adapter>:<artifact>` is a _resolved binding_ — method named, runner
named, target named. A change plan's preservation guarantees use this same field with the
same two precisions; guarantee rows reuse the spec's own requirement ids via `preserves:`
(a plan-local guarantee gets `PG-NNN` — usually a sign a spec amendment is owed). There is
no third verification surface. Review consumes only `{ id, verify_ref, result }` with results
Pass / Fail / Unverified / Blocked — identical over both forms.

The same two-precisions split has a symmetric move on the evidence side. Plain free-form evidence — a sentence or a backticked snippet in the review packet's Evidence cell — is an _unresolved proof_: a reviewer reads it and judges whether it backs the requirement. A fenced `verify` block keyed to the requirement id, naming the command in a closed-value `cmd="…"` token and carrying a `result` enum (`pass`/`fail`), is a _resolved proof_: its closed-value info-string carries the machine-read signal, while its fenced body holds the verbatim, unparsed, self-reported paste. Once the `verify_ref` command is lifted to a discrete field (the spec-side parse work named in [ADR-0083](../adrs/0083-verify-evidence-reconcile.md), future), a reconcile can match the recorded `cmd` by exact string against that `verify_ref` and the `result` token exactly — surfacing the consistency fact that the recorded evidence names the requirement's own command and a pass (the named command is _recorded_ as having run and passed, not proven to have executed — the body stays unparsed). The block keys on the requirement id within its single source spec ([ADR-0080](../adrs/0080-spec-scoped-requirement-ids.md)), the same id that threads spec → task → review; it is the evidence-side counterpart of plain-vs-resolved, frozen in ADR-0083. Review still consumes only `{ id, verify_ref, result }` with results Pass / Fail / Unverified / Blocked — the structured-evidence block surfaces a fact for the reconcile; it never issues the result.

**5. Kind is a projection.** Plain form has one kind: _requirement_. SOL refines kind with
its block types — requirement (`REQ`), constraint (`CONSTRAINT`), invariant (`INVARIANT`),
interface (`INTERFACE`), open question (`QUESTION`). No plain-form block syntax is ever
invented; a plain spec that needs those distinctions switches the file to `format: sol`.

**6. Checks key on the record, never on the surface.** The core spec checks (unique ids, a
verification note per requirement, one binding strength word, no `TBD` in `status: ready`)
apply to the record and therefore to both forms; the SOL-only checks add shape rules this
page defines. The catalogue lives in [Checks](checks.md) — reference implementation:
`swarm check` in swarm-cli. The checks fixtures (`checks/` in the Corpus repo) ship surface-equivalence pairs (one
plain, one SOL, identical record sets) to keep the two surfaces from forking.

## Selecting SOL

The selector is the frontmatter field alone. (Some external material marks SOL files with a
`.swarm.md` filename suffix; Corpus treats that as a harmless private convention — the filename
carries no meaning, only `format: sol` does.)

`format: sol` in the frontmatter is the entire selector — per file, opt-in, reversible:

```yaml
---
type: spec
id: SPEC-auth-refresh
title: Auth refresh
status: draft
owner: auth-team
sources:
  - intake/AUTH-731.md
format: sol
---
```

Everything else about the file is an ordinary spec (see
[Artifact formats](artifact-formats.md)): markdown headings and prose stay; the requirements
are written as SOL blocks instead of `### AC-NNN` headings. Prose around blocks is
commentary — binding meaning (condition, actor, strength, verification) lives inside the
blocks. That separation is a convention nothing in this repo enforces; review inspects it as
a checklist item.

## How a block is written

- A block opens with a **bare, flush-left header line**: the block keyword, the id, and a
  **trailing colon** — `REQ AC-001:`. Without the colon the line is plain prose.
- The **body** is the contiguous run of non-blank lines after the header. The next block
  header, a blank line, or a markdown heading closes it — there is no closing delimiter and
  no significant indentation. Never put a blank line inside a block.
- Keywords and strength words are **uppercase and case-sensitive**. Lowercase _must_ /
  _should_ in body text is prose and carries no force.
- Condition text is **opaque**: what follows `WHEN` / `WHILE` / `WHERE` / `IF` is captured
  verbatim as one line of text. No expression syntax exists inside it.

Each block type has a fixed id prefix:

| Block        | Id prefix | Example  |
| ------------ | --------- | -------- |
| `REQ`        | `AC-`     | `AC-001` |
| `CONSTRAINT` | `C-`      | `C-001`  |
| `INVARIANT`  | `I-`      | `I-001`  |
| `INTERFACE`  | `IF-`     | `IF-001` |
| `QUESTION`   | `Q-`      | `Q-001`  |

Ids are unique within a file. A duplicate id is flagged today — `swarm check` runs the **core**
checks (C001 unique-ids, C003 verify-present, C004 one-strength-word, C007 no-TBD) on a `format: sol`
spec, the same as on a plain spec. A **wrong prefix** is a SOL-specific structural check
(`SOL-S005` in [Checks](checks.md)) that is **planned, not yet shipped** in swarm-cli 1.0.0.

> **What `swarm check` validates on a SOL spec today (1.0.0):** the core checks above — so a duplicate
> id or a missing `VERIFY BY` is caught. The SOL-_specific_ structural codes (the `SOL-S` / `SOL-P` /
> `SOL-M` / `SOL-V` families: wrong prefix, strength-without-rationale, mention resolution, binding
> shape) are the documented contract but are **not yet implemented** — treat them as the writing
> convention until they ship, not as mechanically enforced. (Honesty level per
> [ADR-0063](../adrs/0063-honesty-framework.md): _toolable, planned_ — not _enforced_.)

## Block shapes

### REQ — required behavior

Under stated conditions, an actor produces an observable response. Clauses appear in
canonical order; bracketed clauses are optional:

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

- The condition keywords are the EARS keywords [[KIRO]](../research/sources.md#KIRO), in
  order: `WHERE` (optional-feature inclusion), `WHILE` (state), `WHEN` (trigger), `IF`
  (fault/error). A requirement with no condition keyword is ubiquitous — it always applies.
- `THEN` is optional sugar after `IF` only; never after `WHEN` / `WHILE` / `WHERE`.
- `THE <actor> <STRENGTH> <response>` is the mandatory consequence. The strength word is the
  first uppercase strength token in the line (longest match — `MUST NOT` before `MUST`);
  everything before it is the actor, everything after is the response. If the actor or
  response itself contains a strength word, backtick it or reword — a parser will not guess.
- `AND THE …` chaining is permitted; each consequence is a separate requirement record
  sharing the conditions and the verification binding. Long chains read better as blocks.
- `BECAUSE` (rationale) and `EXCEPT` (exception) are optional — except that a `SHOULD` /
  `SHOULD NOT` consequence needs one of them in the same block (checklist item; the mechanical
  `SOL-P` check for this is _planned, not yet shipped_ — see the caveat under Ids above).
- `VERIFY BY` is expected on every `REQ` — the highest-value line in the block
  [[ORACLESWE]](../research/sources.md#ORACLESWE). A missing one IS flagged today: `swarm check`
  runs the core C003 verify-present check on a `format: sol` spec (toolable, shipped).

### CONSTRAINT — restriction on the solution space

Bounds _how_ requirements may be satisfied rather than requesting a behavior; it persists
across tasks as a guard. Same consequence shape as `REQ`, with `WHERE` as the only condition
keyword:

```sol
CONSTRAINT C-001:
THE auth client MUST NOT import from `server/*`
BECAUSE the client bundle must not embed server-only secrets
VERIFY BY static:cmdLint:dependency-boundary-check
AFFECTS src/auth/**
```

A constraint verifies like anything else — a static check, a contract, or `manual:` review.

### INVARIANT — always-held property

A property that holds at all times, not a one-time behavior. Body shape is
`<property> MUST|MUST NOT <hold>`; only those two strength words apply. Don't write
`ALWAYS` / `NEVER` — the block's semantics already say it.

```sol
INVARIANT I-001:
A user MUST NOT have more than one active refresh token family
VERIFY BY property:cmdTest:token-family-invariant
```

Prefer a `property`, `model`, or `static` verification method here — those can assert a
property over all states, where a single unit test samples one. A one-time triggered
behavior belongs in a `REQ` instead.

### INTERFACE — declared boundary

Names a boundary — API, function, schema, command — that other requirements reference.

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

`ACCEPTS:` and `ERRORS:` introduce contiguous bullet lines (a blank line would close the
block). An interface verifies with a `contract:` method — a check that the declared shape
matches reality (checklist item; toolable via swarm-cli's `swarm check`).

### QUESTION — marked ambiguity

Records an unresolved ambiguity instead of hedged prose. The `[blocking|non-blocking]` tag
is part of the header, before the colon:

```sol
QUESTION Q-001 [blocking]:
Should expired sessions redirect to `/login` or show an inline re-auth modal?
AFFECTS AC-001
```

A spec with an open blocking question is not `status: ready` — do not prepare tasks from the
requirements it `AFFECTS` until it is answered. This is a convention the review step
inspects, not something any tool blocks today.

## Strength words

SOL recognizes these strength words and no others:

| Word         | Force                                                         |
| ------------ | ------------------------------------------------------------- |
| `MUST`       | Required; not satisfying it fails review.                     |
| `MUST NOT`   | Forbidden.                                                    |
| `SHOULD`     | Strong default; needs a same-block `BECAUSE` or `EXCEPT`.     |
| `SHOULD NOT` | Strong prohibition; needs a same-block `BECAUSE` or `EXCEPT`. |
| `MAY`        | Optional; carries no obligation.                              |

`SHALL` / `SHALL NOT` are not strength words — write `MUST` / `MUST NOT`. `CAN` and `WILL`
state capability or prediction and carry no force; don't use them where a strength word
belongs. In a plain-markdown spec the same scale appears as one lowercase binding word per
requirement sentence ("the component must …").

## VERIFY BY — the resolved verification binding

```
VERIFY BY <method>[:<scope>]:<adapter>:<artifact>[#<selector>]
```

- **method** — one of: `static`, `test`, `contract`, `property`, `model`, `perf`,
  `security`, `manual`, `monitor`.
- **scope** — only when the method is `test`: `unit`, `integration`, or `e2e` (`test:e2e:…`).
- **adapter** — the runner, resolved through the workspace `AGENTS.md > Commands` table (the
  `cmd*` slots): the binding names _how to run it_ without hard-coding a shell line. In a
  workspace with per-context Commands sub-tables, the adapter resolves against the sub-table
  the task's Affected areas name, falling back to the single table otherwise.
- **artifact** — the file or target the adapter runs; the optional `#selector` narrows to a
  sub-target such as one test name.

A bare reference with no method segment is legal but weaker — the reviewer has to infer how
to check it. Method strength and selection guidance live in [Checks](checks.md); how results
land in the review packet is [Reviewing output](../08-reviewing-output.md).

## Metadata clauses

These may trail a `REQ`, `CONSTRAINT`, or `INVARIANT`. They carry no behavioral force; they
inform task splitting and review routing.

| Clause                               | Meaning                                                                               |
| ------------------------------------ | ------------------------------------------------------------------------------------- |
| `DEPENDS ON <id-list>`               | Hard ordering against other requirements.                                             |
| `WRITES <path-list>`                 | Surfaces this requirement's implementation owns (conflict basis when splitting work). |
| `READS <path-list>`                  | Read set.                                                                             |
| `AFFECTS <id-or-path-list>`          | Downstream impact set.                                                                |
| `RISK <low\|medium\|high\|critical>` | Risk tier — feeds review-by-exception.                                                |

## Cross-file references

Qualify an id with its spec id using a hash: `SPEC-auth-refresh#AC-001`. The hash (not a
colon) keeps references unambiguous — the colon already ends block headers and separates
`VERIFY BY` segments. Tasks, review packets, and findings use the same form.

## Grammar (EBNF appendix)

Nothing in this repo parses SOL. This grammar is the contract swarm-cli's parser builds
against (toolable); when you write SOL without tooling, treat it as the writing convention
plus the review checklist above. Trimmed to the productions that matter:

```ebnf
block        = req | constraint | invariant | interface | question;

req          = "REQ", ws, ac_id, ":", nl, req_body;
constraint   = "CONSTRAINT", ws, c_id, ":", nl, constraint_body;
invariant    = "INVARIANT", ws, i_id, ":", nl, invariant_body;
interface    = "INTERFACE", ws, if_id, ":", nl, interface_body;
question     = "QUESTION", ws, q_id, ws,
               "[", ( "blocking" | "non-blocking" ), "]", ":", nl, question_body;

ac_id        = "AC-", digits;   c_id  = "C-", digits;   i_id = "I-", digits;
if_id        = "IF-", digits;   q_id  = "Q-", digits;

req_body     = [ "WHERE", ws, condition, nl ]
               [ "WHILE", ws, condition, nl ]
               [ "WHEN",  ws, condition, nl ]
               [ "IF",    ws, condition, [ ws, "THEN" ], nl ]
               actor_clause, { "AND", ws, actor_clause }
               [ "BECAUSE", ws, prose, nl ]
               [ "EXCEPT",  ws, prose, nl ]
               verify_line,
               { metadata_clause };
actor_clause = "THE", ws, actor, ws, strength, ws, response, nl;

constraint_body = [ "WHERE", ws, condition, nl ]
                  actor_clause, { "AND", ws, actor_clause }
                  [ "BECAUSE", ws, prose, nl ]
                  [ "EXCEPT",  ws, prose, nl ]
                  verify_line,
                  { metadata_clause };

invariant_body  = property, ws, ( "MUST" | "MUST NOT" ), ws, predicate, nl,
                  [ "BECAUSE", ws, prose, nl ],
                  verify_line,
                  { metadata_clause };

interface_body  = signature, ws, "RETURNS", ws, type_ref, nl,
                  [ "ACCEPTS:", nl, bullet, { bullet } ]
                  [ "ERRORS:",  nl, bullet, { bullet } ]
                  [ "OWNED BY", ws, owner, nl ]
                  verify_line;
bullet          = ws, "-", ws, prose, nl;

question_body   = question_text, nl,
                  "AFFECTS", ws, ref_list, nl;

verify_line  = "VERIFY BY", ws, verify_ref, nl;
verify_ref   = method, [ ":", scope ], ":", adapter, ":", artifact, [ "#", selector ];
method       = "static" | "test" | "contract" | "property" | "model"
             | "perf" | "security" | "manual" | "monitor";
scope        = "unit" | "integration" | "e2e";        (* only when method = "test" *)

metadata_clause = "DEPENDS ON", ws, ref_list, nl
                | "WRITES",  ws, path_list, nl
                | "READS",   ws, path_list, nl
                | "AFFECTS", ws, ref_list, nl
                | "RISK",    ws, ( "low" | "medium" | "high" | "critical" ), nl;

strength     = "MUST NOT" | "MUST" | "SHOULD NOT" | "SHOULD" | "MAY";  (* longest match *)

ref_list     = ref, { ",", ws, ref };
ref          = ac_id | c_id | i_id | if_id | q_id | cross_ref;
cross_ref    = spec_id, "#", ( ac_id | c_id | i_id | if_id | q_id );
path_list    = path, { ",", ws, path };
digits       = digit, { digit };
(* condition, prose, actor, response, property, predicate, question_text:
   opaque one-line text — no expression syntax inside.
   "#" appears only in cross_ref and the verify_ref selector;
   SOL has no comment token. *)
```

## Versioning

The notation is unversioned: there is no version field in a spec's frontmatter and no
versioned grammar name. Framework releases are git tags on this repository; `format: sol`
is the parser hook for swarm-cli — the only thing a tool needs to decide how to read the
file.

## Related

- [Writing specs](../04-writing-specs.md) — the plain-markdown default and when to step up to SOL.
- [Checks](checks.md) — the common mistakes to check for, over both surfaces.
- [Artifact formats](artifact-formats.md) — spec frontmatter and the other file types.
- [Reviewing output](../08-reviewing-output.md) — how verification results become review results.
- [Future CLI](future-cli.md) — how swarm-cli parses this notation internally (no `ir.json`
  artifact; optional `--json` for interop, per ADR-0077).
