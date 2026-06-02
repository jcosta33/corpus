# Versioning

> Authoritative source: `.agents/specs/swarm/07-governance-memory.md` §25 (the three version axes — language SOL/x.y, framework/package, spec content — and the editions/MSRV analogues). This is a reference projection; where it and the spec disagree, the spec governs.

Swarm has **two independent version axes**. The spec is emphatic that conflating them is a category error: one tracks the *meaning of the language*, the other tracks *the package that delivers it*. A conformant repo MUST track both and MUST NOT merge them into a single number (§25, §25.1).

A third version — the **spec content version** — is not a system-wide axis but a per-document fact: the semver of *one* spec's intent. It surfaces as its own field in the IR/plan (§25.3) and in frontmatter (§25.4), so a complete count of *fields a reader sees* is **three**, drawn from **two** axes.

## The two axes

| Axis | What it versions | Where it lives | Cadence |
| ---- | ---------------- | -------------- | ------- |
| **Language version** | The SOL + APS feature set: grammar, the 7 block types, the 5 modals, the clause keywords, the `SOL-<LAYER>NNN` lint codes (§4–§8) | Per-file frontmatter: `swarm_language` + `aps_version` | Small, slow-moving: `0.1`, `0.2`, `1.0` |
| **Framework / package version** | The scaffold, templates, skills / pass guides, personas / profiles, flow-graph | `scaffold/.agents/.swarm-version` → `.swarm/VERSION` (semver) | Ordinary semver; may move many times between language bumps |

(Block-type, modal, and lint-layer counts above are the kernel's fixed vocabulary — 7 block types, 5 modals, 5 lint layers S/P/M/V/O — defined in §4–§8; this projection reproduces them, it does not redefine them.)

### Language version — "which grammar does this file speak?"

The language version answers **"which grammar, blocks, modals, and lint codes does this file speak?"** It is carried **per file**, so a single repo MAY hold `spec.swarm.md` files at different language versions during a migration (§25.1.1). Two frontmatter fields carry it:

- `swarm_language` — the **SOL discriminator**, written `SOL/0.1`.
- `aps_version` — the **APS prose-standard version**, written `0.1`.

### Framework / package version — "which scaffold shipped this repo?"

The framework version answers **"which scaffold, templates, and pass guides shipped this repo?"** It is a single semver string in `scaffold/.agents/.swarm-version`; an adopted project mirrors it as `.swarm/VERSION` (§25.1.2, §20.5.1). It is **never** written in per-file frontmatter (§25.4). The spec notes this *extends* the earlier ADR that established `.agents/.swarm-version` — the ADR is scoped to the package axis, and the language axis is added alongside it, not in place of it (§25.1.2, §30).

## The one-way trigger

The axes are independent, but coupled by exactly **one** directional rule (§25.2):

> **Any change to the SOL/APS language version MUST force at least a framework MINOR release** — additive language change → framework MINOR; breaking language change → framework MAJOR. The framework MAY release any number of versions (PATCH / MINOR / MAJOR) **without** changing the language version.

```text
language change ──(MUST)──▶ framework MINOR (additive) or MAJOR (breaking)
framework change ──(MAY)──▶ no language change required
```

The rationale: a new keyword or lint code changes what the templates and pass guides must teach, so the package that ships them MUST move; but fixing a template typo or adding a skill never touches the grammar, so the language MUST stay pinned. The trigger runs **one way only** — language ⇒ framework, never framework ⇒ language (§25.2).

**0.y.z caveat (do not over-read the trigger).** While both axes sit at major-version-zero, SemVer 2.0.0 §4 holds that *anything MAY change at any time* `[SEMVER]`, so the trigger is **advisory until each axis reaches 1.0**. Even after 1.0 it is a one-directional *floor* — a language change forces at least a framework MINOR — not a promise that every framework release re-issues the language (§25.2).

## Editions / MSRV analogues

The two-axis split is modelled on mature language ecosystems where the *language* version is deliberately not the same number as the *toolchain* that delivers it (§25.1 rationale):

- **Rust** `[RUSTED]` separates editions (a per-crate, opt-in language epoch), `rust-version` (the MSRV floor), and the cargo / rustc release number. These are independent axes joined by a one-way constraint — the same shape as Swarm's language ⇒ framework trigger. The spec is careful **not** to borrow Rust's "~3-year edition cadence": `[RUSTED]` does not guarantee a fixed schedule, so Swarm claims a *floor*, not a *cadence* (§25.2).
- **C#** `[CSLANG]` has a `LangVersion` that is overridable from its target-framework default **but bounded by the installed compiler**. The spec cites this with the corrected framing required by `sources.md`: the language version is decoupled from the *target-framework default*, **not** independent of the compiler/SDK. Swarm does not claim its language axis is "decoupled from the toolchain."

The takeaway the spec draws from both: the *language API* (grammar + lint codes) and the *package API* (template sections + skills + flow-graph) are versioned as **separately-named public APIs**, because SemVer is only meaningful once each public API is named explicitly `[SEMVER]` (§25.1).

## Three distinct fields in the IR / plan

The emitted IR (§12) and plan (§13) MUST echo **three distinct fields**, and a conformant tool MUST NOT merge any two of them (§25.3):

| Field | Axis / meaning | Example |
| ----- | -------------- | ------- |
| `meta.language` | The SOL **discriminator** — which grammar this IR was parsed under | `"SOL/0.1"` |
| `meta.version` | The **spec content version** — the semver of *this spec's intent*, independent of language and framework | `"0.1.0"` |
| `provenance.compiler_version` | The **tool version** that emitted the IR, when a tool exists | `null` / unset today (no runtime, §2) |

```json
{
  "meta": {
    "language": "SOL/0.1",
    "version": "0.1.0",
    "title": "auth-refresh"
  },
  "provenance": {
    "compiler_version": null
  }
}
```

These answer three different questions — *which grammar* (`meta.language`), *which revision of this spec's intent* (`meta.version`), and *which tool produced this* (`provenance.compiler_version`) — and a single number cannot answer all three (§25.3). `provenance.compiler_version` is `null` today because Swarm has no runtime: the parser, linter, and checker are contracts a future tool builds against, never shipped code (§2).

## G10 — canonical frontmatter

To make the three-field mapping unambiguous, the kernel pins **one** frontmatter vocabulary across all `.swarm.md` and template files (§25.4, rule G10):

```text
---
swarm_language: SOL/0.1   # SOL discriminator (= meta.language in the IR)
aps_version: 0.1          # APS prose-standard version
spec_version: 0.1.0       # spec content version (= meta.version in the IR)
---
```

| Frontmatter field | Maps to IR field | Axis |
| ----------------- | ---------------- | ---- |
| `swarm_language: SOL/0.1` | `meta.language` | Language (discriminator) |
| `aps_version: 0.1` | (not echoed in IR; governs the `SOL-P…` prose lint layer) | Language |
| `spec_version: 0.1.0` | `meta.version` | Spec content |

**Conformance note (§25.4).** Earlier draft templates write `swarm_language: 0.1` (a bare number). The normalized form is `swarm_language: SOL/0.1` (with the `SOL/` discriminator) plus a separate `spec_version`. A conformant repo MUST use the normalized form; a bare `swarm_language: 0.1` is a `SOL-S…`-class frontmatter diagnostic (the `SOL-S` structural lint layer, §4–§8). The framework version is **never** written in per-file frontmatter — it lives only in the framework version file (`scaffold/.agents/.swarm-version`; `.swarm/VERSION` in an adopted project, §20.5.1).

## Preserved / Dropped / Still-uncertain

**Preserved (the load-bearing claims this projection keeps):**
- The two independent axes and the MUST-not-merge rule (§25.1).
- The per-file vs single-file homes for each axis (§25.1.1, §25.1.2).
- The one-way `language ⇒ framework MINOR/MAJOR` trigger and its 0.y.z advisory caveat (§25.2).
- The three never-merged IR/plan fields and the no-runtime `compiler_version: null` (§25.3).
- The G10 canonical frontmatter, its field-to-IR mapping, and the `SOL-S` diagnostic for the bare-number form (§25.4).
- The Rust-editions/MSRV and C# `LangVersion` analogues, with the `sources.md` corrections (no guaranteed cadence `[RUSTED]`; compiler-bounded, not toolchain-independent `[CSLANG]`).

**Dropped (left to the spec — out of scope for a versioning reference view):**
- The full §22 source-authority ladder, §23 memory model, and §24 distillation rules that surround §25 in the same spec part.
- The ADR-0015 extension mechanics and §30 amendment process (named only as a pointer here).
- The internal definitions of the 7 block types, 5 modals, and the `SOL-<LAYER>NNN` lint families — referenced by count and layer, defined in §4–§8.

**Still-uncertain (the spec itself defers; this projection does not resolve):**
- Exact post-1.0 behaviour of the trigger as a floor — the spec marks it advisory under SemVer 0.y.z and a one-directional floor thereafter, but does not pin a release cadence (§25.2).
- The eventual real `compiler_version` value, which awaits a tool that does not yet exist (§25.3, §2).
