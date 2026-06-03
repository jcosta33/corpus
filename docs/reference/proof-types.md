# Proof Types and the `VERIFY BY` Binding

> Swarm's reference for proof types and the `VERIFY BY` binding: the nine closed proof types and the binding grammar that attaches a proof to an obligation.

Swarm is markdown-only, provider-neutral, and has **no runtime**. Nothing here is shipped code: the linter, the `VERIFY BY` resolver, and the proof runner are all **contracts** a future tool builds against. A proof can *falsify* an obligation but may never silently amend its intent, and **schema-valid output is not a proof** — shape is not truth (the `CODE IS REALITY` invariant, §2).

A verdict is only as trustworthy as the proof behind it. `VERIFY BY` is the clause that attaches a proof to an obligation; the `<type>` it names is drawn from a **closed set of exactly nine proof types**.

## The nine proof types (closed)

`VERIFY BY` binds an obligation to **exactly one** of nine proof types. The set is closed: a conformant linter MUST reject any `<type>` outside it as `SOL-V009` (unknown-proof-type). This canonical set resolves the earlier 11-type and 7-type proposals into one.

| # | Proof type | One-line definition |
| --- | --- | --- |
| 1 | `static` | A non-executing analysis of source: type-check, lint, dependency-boundary check, schema validation of source. |
| 2 | `test` | An executable test that drives the system and asserts an observable outcome. |
| 3 | `contract` | A verification that a declared boundary (an `INTERFACE`) honours its `RETURNS`/`ACCEPTS`/`ERRORS` shape — a consumer/provider contract test, pact, or schema-conformance check at a boundary. |
| 4 | `property` | A generative/property-based check that asserts a universally-quantified property over many generated inputs. |
| 5 | `model` | Model-checking OR an economical proof of a property — **not** a full theorem per obligation. |
| 6 | `perf` | A measured performance/throughput/latency assertion against a threshold. |
| 7 | `security` | A security-specific oracle: SAST/DAST, secret scan, authz/authn test, dependency-vuln gate. |
| 8 | `manual` | A recorded human judgment against the obligation — the **honest escape hatch** when no executable oracle exists. |
| 9 | `monitor` | A runtime/production observation (logs, metrics, alerts, canary). Runtime evidence maps here. |

### Two normative notes

- **`unit`/`integration`/`e2e` are scope qualifiers under `test`, not separate types.** They are written `test:unit:`, `test:integration:`, `test:e2e:` in the binding. A conformant linter MUST treat `unit`, `integration`, or `e2e` appearing as a top-level `<type>` as `SOL-V009` (unknown-proof-type; use the qualifier form instead).
- **`runtime` maps to `monitor`.** There is no `runtime` proof type; any "verified in production / observed at runtime" claim binds as `monitor`.

## The `VERIFY BY` binding syntax

The surface clause is `VERIFY BY` — two words, uppercase (per the keyword convention, §5) — followed by a typed reference. The surface form is always `VERIFY BY`; `VERIFY_BY` is surface-illegal.

```ebnf
verify_line  = "VERIFY BY", ws, verify_ref, nl;
verify_ref   = typed_ref | bare_ref;
typed_ref    = proof_type, [ ":", test_scope ], ":", adapter, ":", artifact, [ "#", selector ];
proof_type   = "static" | "test" | "contract" | "property" | "model"
             | "perf" | "security" | "manual" | "monitor";
test_scope   = "unit" | "integration" | "e2e";   (* only legal when proof_type = "test" *)
bare_ref     = ? opaque proof reference with no proof_type segment;
               structurally valid, raises the §15 advisory untyped-binding smell ?;
adapter      = ident;            (* resolves through AGENTS.md > Commands *)
artifact     = path | ident | quoted_string;
selector     = ident | path-fragment;   (* a case/scenario/property name *)
```

Segment by segment:

- **`<type>`** is the closed, lint-typed, IR-typed dimension. For `test`, an optional scope qualifier (`unit`/`integration`/`e2e`) follows the type as its own segment — `test:<scope>:<adapter>:<artifact>`, e.g. `test:unit:cmdTest:...` — modelled by the grammar as `proof_type [: test_scope] : adapter : artifact`.
- **`<adapter>`** is a **project free-string** that resolves to a command slot in `AGENTS.md > Commands` (§15.3); the `cmd*` placeholder slots *are* the adapters.
- **`<artifact>`** is a **project free-string**: a file, test id, suite name, or contract file.
- **`<selector>`** (optional, after `#`) narrows the artifact to a single case, scenario, or property.

The IR field name for this clause is `verify_by[]` (snake_case — §12), normalized to `{type, adapter, ref, selector, gate}`.

### Worked examples

```sol
REQ AC-001:
WHEN the refresh token is expired
THE client MUST clear the local session
VERIFY BY test:unit:cmdTest:auth-refresh-expired-token#clears_session
```

```sol
CONSTRAINT C-001:
THE auth client MUST NOT import from `server/*`
VERIFY BY static:cmdLint:dependency-boundary#no-server-imports
```

```sol
INTERFACE IF-001:
`refreshSession` RETURNS `Session | AuthExpired`
ERRORS:
  - network-timeout
  - invalid-refresh-token
OWNED BY auth-client
VERIFY BY contract:cmdContract:refresh-session.pact#refreshSession
```

### Bare (untyped) references

A bare `VERIFY BY <ref>` with no `type:` segment is **structurally valid** but raises an advisory untyped-binding smell (`SOL-V`-family). The typed `type:adapter:artifact` form is REQUIRED wherever a type-driven rule fires:

- an `INTERFACE` binding, which MUST be `contract` (`SOL-V006`);
- an `INVARIANT` type-preference (`SOL-V003`);
- an obligation entering a `CONTRADICTED` proof-strength tie-break (§17);
- a per-task default-suite check (§15.8).

A spec imported from outside the framework MAY carry bare refs; the `improve`/`NORMALIZE` pass upgrades them to typed bindings.

## Why the boundary matters (design rationale)

The taxonomy is deliberately *closed* so that a future linter can reason about it: the `<type>` is analyzable, while `<adapter>` and `<artifact>` stay free strings (kept in `AGENTS.md`) so the same spec ports across repos. (Cross-reference: the two-layer obligation/adapter model is §15.3.)

The closed set tracks the **test-oracle problem**: when a precise oracle is unavailable, a single concrete example cannot stand in for an obligation's predicate, so generative property-based and metamorphic checks are the principled response — they assert a quantified property rather than a single hand-picked case. This is why `property` and `model` are first-class types rather than scope notes under `test`, and why `manual` is named honestly rather than disguised as a passing test. A binding that resolves only to "schema-valid output" or a bare "tests passed" is not a proof and yields `UNVERIFIED`, not `PASS` (the *what is NOT a proof* floor, §15.9): a passing or schema-valid signal that does not actually exercise the obligation's predicate is an inadequate oracle, and inadequate oracles must not be allowed to manufacture a `PASS` [[REFLEXION]](../research/sources.md#REFLEXION).

A bound proof produces exactly one CORE verdict — `PASS`, `FAIL`, `BLOCKED`, or `UNVERIFIED` (§14.1) — and the lifecycle decorators (`WAIVED`/`STALE`/`CONTRADICTED`) annotate that result; the full seven-value verdict model and the merge gate live in §14.

## Related

- [SOL — The Swarm Obligation Language](../language/SOL.md) — the surface syntax that hosts the `VERIFY BY` clause.
- [Errors and lint codes](../language/errors.md) — the `SOL-V` family, including `SOL-V009` (unknown-proof-type) and `SOL-V006` (`INTERFACE` must be `contract`).
- [The IR and Plan JSON Schemas](ir-schema.md) — the `verify_by[]` IR field and its `{type, adapter, ref, selector, gate}` normalization.
- [Drift and staleness](drift-and-staleness.md) — the `WAIVED`/`STALE`/`CONTRADICTED` lifecycle decorators that annotate a verdict.
- [Glossary](glossary.md) — the CORE verdict vocabulary (`PASS`/`FAIL`/`BLOCKED`/`UNVERIFIED`) and proof terms used here.
