---
type: adr
id: 0054-drop-compiler-vocabulary
status: accepted
created: 2026-06-07
updated: 2026-06-07
supersedes:
superseded_by:
---

# ADR-0054: Drop the residual compiler vocabulary (complete the de-cosplay)

## Context

An earlier de-cosplay sweep dropped the *product-noun* "compiler" framing ("specification compiler",
"agents-as-compiler") but **kept precise-seeming internal terms**: the artifact class label
**"compiler-visible"**, the structured-form provenance fields **`compiler_version`** / **`compiled_at`**, the
conformance tier **"Corpus-compilable"**, and assorted "compile" metaphors. An adversarial skeptic review of
the whole repo found these residuals sitting on the most-read contract pages (≈42 "compiler-visible" + ~60
"compiler" occurrences) — in direct tension with the understated positioning ([ADR-0053](./0053-structured-spec-and-review-system.md)
§4 bans "compiler" as a public term) and with **Invariant 1 (NO RUNTIME): there is no compiler.** Telling
adopters "Corpus is not a compiler" while the artifact catalogue they copy verbatim still classifies files as
"compiler-visible" and stamps a `compiler_version` field is dishonest framing.

## Decision

Remove the residual compiler vocabulary **completely** from reader-facing content (the immutable ADR bodies
keep theirs as history):

- **Artifact class label: "compiler-visible" → "Corpus-format".** The `spec.md` naming marks Corpus's parse/emit
  format; a *conformant tool* (never Corpus itself) parses or emits it. ("Corpus-parsed" phrasing → "parsed",
  for the same NO-RUNTIME reason.)
- **Structured-form provenance fields: `compiler_version` → `tool_version`, `compiled_at` → `emitted_at`.**
  This is a **schema contract change**. It is safe because the structured form ships **no emitter or
  consumer** (Invariant 1): the schema, the three golden-corpus fixtures, and the worked examples are renamed
  together in this change, and no deployed tool reads the old names.
- **Conformance tier: "Corpus-compilable" → "lowerable".** The `lower` step name is kept; the tier means an
  approved spec can be lowered into tasks deterministically.
- **Incidental "compile" metaphors:** "must compile" → "must lower cleanly"; "lint/compile findings" → "lint
  findings"; "compiled into tasks/the graph" → "lowered into …".
- **KEPT (not Corpus-as-compiler roleplay):** the `lower` step name, the `*.ir.json` / `*.plan.json`
  reserved filenames, and genuine references to *other* ecosystems' compilers (the C# `LangVersion` analogy in
  `versioning.md`; the adopter's own code compiler in the code-migration skills).

This **completes the de-cosplay** and enforces [ADR-0053](./0053-structured-spec-and-review-system.md) §4 and
Invariant 1 in the contract layer, not just the on-ramp. It changes **no** closed set, the SOL grammar, the
nine steps, or the verdict model; the only contract change is the two renamed structured-form provenance
field names.

## Alternatives considered

| Alternative | Why rejected |
| --- | --- |
| Keep "compiler-visible" / `compiler_version` as precise *internal* terms (the earlier de-cosplay's choice) | The skeptic audit showed they read as "Corpus is a compiler" on the most-copied contract pages, undercutting ADR-0053 §4 and contradicting NO RUNTIME. "Internal" terms that ship in the artifact catalogue an adopter copies are not internal. |
| Rename the reader-facing label but keep the schema field | `compiler_version` is the *same* roleplay, in the contract instance an adopter copies verbatim. Half-honest is the dishonesty the audit flagged. |
| Rename the `*.ir.json` filename too | Out of scope: the filename is a stable reserved contract name (kept by the prior de-cosplay) and contains no "compiler" token. |

## Consequences

- **Positive:** one honest, consistent vocabulary; the NO-RUNTIME framing now holds in the contract layer, not
  only the pitch; ADR-0053's overclaim ban is enforceable against the artifact pages.
- **Negative:** a reserved-schema-field rename touching the schema + 3 fixtures + 3 examples — coordinated in
  this one change; cheap because no shipped tool consumes the field.
- **Neutral:** no closed set, grammar, step, or verdict change.

## Status

Accepted (v0.1). The vocabulary sweep + the schema-field rename + the fixture/example updates are this change.

## Affected obligations / constraints

- Enforces: [0053](./0053-structured-spec-and-review-system.md) §4 (overclaim ban) and Invariant 1 (NO
  RUNTIME) in the contract layer.
- Grounded by: the skeptic adversarial audit (this session).
- Contract change: the structured-form `provenance` fields `tool_version` (was `compiler_version`) and
  `emitted_at` (was `compiled_at`).
- Does NOT change: any closed set, the SOL grammar, the nine steps, the verdicts, or the artifact set.

> **Ledger note (2026-06-11):** refined by ADR-0057, ADR-0059.

> **Ledger note (2026-06-12):** register sweep completed at the tree level by ADR-0070
> (`conformance/` → `checks/`).
