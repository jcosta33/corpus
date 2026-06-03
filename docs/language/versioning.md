# Versioning

> Swarm's reference for versioning: the two independent version axes, the one-way trigger between them, and the three version fields a reader sees in frontmatter and the IR.

Swarm carries **two independent version axes**. Conflating them is a category error: one tracks the *meaning of the language*, the other tracks *the package that delivers it*. A conformant repo MUST track both and MUST NOT merge them into a single number (§25, §25.1).

This framework is **language v0.1**. The framework package that delivers it carries its own semver, independent of that `0.1`.

A third version — the **spec content version** — is not a system-wide axis but a per-document fact: the semver of *one* spec's intent. It surfaces as its own field in the IR/plan (§25.3) and in frontmatter (§25.4), so a complete count of *fields a reader sees* is **three**, drawn from **two** axes.

## The two axes

This is the normative labelling convention for both axes — what each one versions, where it is carried, and how fast it moves (§0.5, §25.1):

| Axis | What it versions | Carried in | Cadence |
| ---- | ---------------- | ---------- | ------- |
| **Language version** | The SOL + APS feature set: grammar, the 7 block types, the 5 modals, the clause keywords, the `SOL-<LAYER>NNN` lint codes (§4–§8) | `*.swarm.md` frontmatter as the discriminator `swarm_language: SOL/0.1` (plus `aps_version`); echoed in the IR as `meta.language` | Small, slow-moving: `0.1`, `0.2`, `1.0` |
| **Framework / package version** | The kernel payload, templates, pass guides, and profiles (the flow-graph and skills that ship with the package) | `kernel/.agents/.swarm-version` → an adopted project mirrors it as `.swarm/VERSION` (semver) | Ordinary, fast semver; may move many times between language bumps |

(Block-type, modal, and lint-layer counts above are the kernel's fixed vocabulary — 7 block types, 5 modals, 5 lint layers S/P/M/V/O — defined in §4–§8; this page reproduces them, it does not redefine them.)

### Language version — "which grammar does this file speak?"

The language version answers **"which grammar, blocks, modals, and lint codes does this file speak?"** It is carried **per file**, so a single repo MAY hold `spec.swarm.md` files at different language versions during a migration (§25.1.1). Two frontmatter fields carry it:

- `swarm_language` — the **SOL discriminator**, written `SOL/0.1`.
- `aps_version` — the **APS prose-standard version**, written `0.1`.

This document is language `0.1`; later language epochs are `0.2`, then `1.0`.

### Framework / package version — "which kernel payload shipped this repo?"

The framework version answers **"which kernel payload, templates, and pass guides shipped this repo?"** It is a single semver string in `kernel/.agents/.swarm-version`; an adopted project mirrors it as `.swarm/VERSION` (§25.1.2, §20.5.1). It is **never** written in per-file frontmatter (§25.4). This *extends* the earlier ADR that established `.agents/.swarm-version` — that ADR is scoped to the package axis, and the language axis is added alongside it, not in place of it (§25.1.2).

## The one-way trigger

The axes are independent, but coupled by exactly **one** directional rule (§25.2):

> **Any change to the SOL/APS language version MUST force at least a framework MINOR release** — additive language change → framework MINOR; breaking language change → framework MAJOR. The framework MAY release any number of versions (PATCH / MINOR / MAJOR) **without** changing the language version.

```text
language change ──(MUST)──▶ framework MINOR (additive) or MAJOR (breaking)
framework change ──(MAY)──▶ no language change required
```

The rationale: a new keyword or lint code changes what the templates and pass guides must teach, so the package that ships them MUST move; but fixing a template typo or adding a skill never touches the grammar, so the language MUST stay pinned. The trigger runs **one way only** — language ⇒ framework, never framework ⇒ language (§25.2).

**0.y.z caveat (do not over-read the trigger).** While both axes sit at major-version-zero, semantic versioning holds that *anything MAY change at any time* below `1.0`, so the trigger is **advisory until each axis reaches 1.0**. Even after 1.0 it is a one-directional *floor* — a language change forces at least a framework MINOR — not a promise that every framework release re-issues the language (§25.2).

## Editions / MSRV analogues

The two-axis split follows the design seen in mature language ecosystems, where the *language* version is deliberately not the same number as the *toolchain* that delivers it (design rationale, §25.1):

- **Rust** separates editions (a per-crate, opt-in language epoch), `rust-version` (the MSRV floor), and the cargo / rustc release number. These are independent axes joined by a one-way constraint — the same shape as Swarm's language ⇒ framework trigger. Swarm deliberately does **not** borrow Rust's "~3-year edition cadence": that ecosystem does not guarantee a fixed schedule, so Swarm claims a *floor*, not a *cadence* (§25.2).
- **C#** has a `LangVersion` that is overridable from its target-framework default **but bounded by the installed compiler**. The accurate framing matters here: the language version is decoupled from the *target-framework default*, **not** independent of the compiler/SDK. Swarm likewise does not claim its language axis is "decoupled from the toolchain."

The takeaway from both: the *language API* (grammar + lint codes) and the *package API* (template sections + skills + flow-graph) are versioned as **separately-named public APIs**, because semantic versioning is only meaningful once each public API is named explicitly (§25.1).

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

**Conformance note (§25.4).** The canonical form is `swarm_language: SOL/0.1` (with the `SOL/` discriminator) plus a separate `spec_version`. A conformant repo MUST use this form; a bare `swarm_language: 0.1` (a number with no discriminator) is a `SOL-S…`-class frontmatter diagnostic (the `SOL-S` structural lint layer, §4–§8). The framework version is **never** written in per-file frontmatter — it lives only in the framework version file (`kernel/.agents/.swarm-version`; `.swarm/VERSION` in an adopted project, §20.5.1).

## Related

- [SOL](./SOL.md) — the grammar, 7 block types, and 5 modals that the language axis versions.
- [APS](./APS.md) — the prose standard carried by `aps_version`.
- [Errors](./errors.md) — the `SOL-<LAYER>NNN` lint catalogue, including the `SOL-S` frontmatter diagnostics referenced above.
- [Source artifacts](../model/source-artifacts.md) — the IR and plan that echo `meta.language` and `meta.version`.
