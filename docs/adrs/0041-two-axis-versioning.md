---
type: adr
id: 0041-two-axis-versioning
status: accepted
created: 2026-06-02
updated: 2026-06-02
supersedes:
superseded_by:
---

# ADR-0041: Two-axis versioning (language axis added alongside the package axis)

> **Refined by [ADR-0050](./0050-swarm-is-a-spec-repo-discipline.md).** The **language axis** below
> (`swarm_language: SOL/0.1` in spec frontmatter) is unchanged and is the only load-bearing version. The
> **package axis's adopter-side marker** (the `.swarm-version` mirror an adopted repo kept) is **dropped** —
> nothing reads it in a no-runtime, copy-the-files world, and the language version already travels with each
> spec. The producer keeps its own `.swarm-version` only as a release tag.

## Context

[0015](./0015-versioning-scheme.md) established a single framework version (`.agents/.swarm-version`) so a consuming repo could pin *which package* of templates and skills it vendored. The kernel introduces a second thing that versions independently: the **language** itself — the SOL grammar, the seven block types, the five modals, the clause keywords, and the `SOL-<LAYER><NNN>` lint codes (§4–§8). The meaning of the language and the package that delivers it move on different cadences: a template typo fix ships a new package without touching the grammar, and a new modal or lint code changes what every template must teach. Conflating the two into one number is a category error (§25) — the same mistake as versioning a language and its toolchain together. [0015](./0015-versioning-scheme.md)'s decision is correct for the package axis but silent on the language axis, and Nygard immutability (§30.1) forbids editing it in place to add one.

## Decision

ADR 0015 is **extended, not replaced** (§30.2): the package axis it established is kept verbatim, and a **second, independent language axis is added alongside it**. A conformant repo MUST track both and MUST NOT merge them (§25.1):

- **Language version** — the SOL + APS feature set. Carried **per file** in frontmatter as `swarm_language` (the SOL discriminator, e.g. `SOL/0.1`) and `aps_version` (e.g. `0.1`), so one repo MAY hold `spec.swarm.md` files at different language versions mid-migration (§25.1.1).
- **Framework / package version** — the kernel payload, templates, pass guides, profiles, flow-graph. A single semver in `starter-kit/.agents/.swarm-version`, mirrored by an adopted project as `.agents/swarm.version` (§25.1.2). This is exactly [0015](./0015-versioning-scheme.md)'s field, unchanged.

The axes are coupled by **one directional rule** (§25.2): any change to the language version MUST force at least a framework MINOR (additive) or MAJOR (breaking) release; a framework release MAY occur with no language change. The trigger is one-way — language ⇒ framework, never framework ⇒ language — and is advisory while either axis is at major-version-zero (SemVer 2.0.0 §4). The emitted IR/plan MUST echo three distinct fields and merge none of them: `meta.language` (the grammar discriminator), `meta.version` (the spec-content semver), and `provenance.compiler_version` (the tool version, unset today — NO RUNTIME) (§25.3).

## Alternatives considered

| Alternative | Why rejected |
| --- | --- |
| Keep one version number (extend [0015](./0015-versioning-scheme.md) to also mean the language) | Category error: language meaning and package delivery move on different cadences, so SemVer is only meaningful when each public API is named separately (§25.1). |
| Edit ADR 0015 to add the language axis | Violates Nygard immutability (§30.1): an accepted ADR is never edited in place; an extension is published as a new superseding/extending ADR. |
| Replace 0015 with a fresh versioning ADR | 0015's package-axis decision is still correct and in force; replacing it would discard a valid decision rather than extend it (§30.2 records 0015 as *kept, extended*). |
| Make the one-way trigger a hard guarantee from v0.1 | While both axes are at 0.y, SemVer §4 permits anything to change; the floor is advisory until each axis reaches 1.0, after which it is a one-directional floor, not a fixed release cadence (§25.2). |

## Consequences

### Positive

- A repo can migrate `spec.swarm.md` files to a new language version file-by-file while the package version moves on its own semver track.
- "Which grammar does this file speak?" and "which package shipped this repo?" are answered by two named, independently-pinned fields instead of one overloaded number.
- 0015's package-axis decision survives intact; the chain (0015 → 0041) records *why* a second axis was added without rewriting history.

### Negative

- Two version fields to maintain and reason about instead of one; the one-way trigger is a discipline an author/maintainer must apply by hand until a conformant tool enforces it.

### Neutral / tradeoffs

- The trigger is advisory at 0.y (§25.2) — recorded here as the present scope, not a defect.
- `provenance.compiler_version` is unset today because there is no runtime (§2); the field exists so a future tool has a typed home for it.

## Status

Accepted (v0.1).

Extends ADR-0015 (adds the language axis alongside the package axis; 0015's body stays immutable per §30.1 — this ADR carries the extension). Does not supersede it: 0015's package-axis decision remains in force.

## Affected obligations / constraints

- Adds: the language version axis (`swarm_language`, `aps_version`, per-file) and the one-way language⇒framework release trigger (§25.1–§25.2); the three distinct version fields in the IR/plan (§25.3).
- Modifies: the scope of ADR-0015 — its single version is now explicitly the *package* axis, with the language axis tracked separately.
- Supersedes: nothing (0015 is extended, not replaced).
