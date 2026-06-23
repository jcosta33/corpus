---
type: adr
id: 0042-skill-carrier-and-standalone-conditioning
status: accepted
created: 2026-06-03
updated: 2026-06-03
supersedes:
superseded_by:
---

# ADR-0042: Skills carry as `SKILL.md`, and conditioning ships as many standalone, surgically-activated skills

> **Refined by [ADR-0051](./0051-complete-the-spec-repo-pivot.md).** The `SKILL.md` carrier + surgical
> activation are unchanged, but the catalogue **splits by role**: the starter kit ships the **20 authoring
> skills**; the **17 code-implementation skills** (per-kind implement guides, code personas,
> `implement-and-verify`) are `docs/library/code-skills/` reference, not bundled. The 13-persona closed set is
> intact (6 authoring + 7 code).

## Context

The kernel's procedural conditioning layer shipped as eight files named `GUIDE.md` under `starter-kit/.agents/skills/`. Four problems compounded:

1. **The carrier filename is not the one agent tools discover.** The Open Agent Skills convention and the agent CLIs that load skills discover and activate a `SKILL.md` by its `name` + `description` frontmatter. The framework's own activation evidence [[ACTIVATION-BLOG]](../research/sources.md#ACTIVATION-BLOG) treats the `SKILL.md` `description` as the most load-bearing line — the field an agent scans to decide whether to pull a skill into context. A file named `GUIDE.md` carries the same skill-shaped frontmatter but is not discovered as a skill, so the kernel's pass guides silently opted out of the "load what the task names / description-match fallback" activation path (§26.4, [0037](./0037-load-what-the-task-names.md)). The build-source layout never specified the filename; `GUIDE.md` was a generation-time choice that leaked the "pass guide, not standalone skill" relabeling ([0036](./0036-heuristic-profile-model.md)) into the filename, where it breaks interoperability.

2. **One implement guide bundled nine task kinds under one broad description** — the "Everything Skill" anti-pattern [[ACTIVATION-BLOG]](../research/sources.md#ACTIVATION-BLOG): a description broad enough to cover all nine implementation kinds is too broad to activate surgically, and an agent loading it carries all nine kinds' procedures.

3. **Only one of the thirteen heuristic profiles shipped as a loadable file** (the Skeptic, inlined in the review guide). The other twelve stances existed in the model but no agent could load them.

4. **The `author` pass shipped no guide at all** — nothing taught an agent how to author a `*.md` spec, an audit, a research doc, or a bug-report *the Corpus way* (SOL blocks, the artifact contracts, the epistemic stances).

The authoring research is explicit that each unit of conditioning should be a **self-contained, surgically-described `SKILL.md`** so only the one the task needs loads — bundling forces an agent to read all of them to find the relevant one ([[SKILLSPEC]](../research/sources.md#SKILLSPEC): one self-contained skill per folder, only the one the task names loads).

## Decision

1. **The carrier file for every pass guide, heuristic profile, and cross-cutting fragment is `SKILL.md`** (renamed from `GUIDE.md`). It is discoverable and activatable by the Open Agent Skills convention. The "pass guide" / "profile" identity is preserved in the body prose and a `type:` frontmatter field; the rename is to the filename only.

2. **Conditioning ships as many standalone, surgically-`description`-activated skills, not a few bundled guides.** Specifically: one skill per implementation `task_kind` (the `write-*` set), one skill per authored artifact (`write-spec`/`write-audit`/`write-research`/`write-bug-report`, and the `prd`/`rfc` authoring skills), and **all thirteen heuristic profiles as standalone files**. Each carries a tight `description` (an `ALWAYS apply when… / Skip when…` form) so it activates only for the task kinds it fits.

3. **The pass × profile routing is unchanged** ([0029](./0029-nine-pass-compiler-model.md), [0036](./0036-heuristic-profile-model.md)). This is a carrier/packaging decision — 0036 already holds that a profile's "carrier is an implementation detail." A task still names a pass and MAY name the profile and skill it activates; description-matching remains the launcher-less fallback ([0037](./0037-load-what-the-task-names.md)).

4. Every skill stays **self-contained** ([0016](./0016-skills-are-self-contained.md)), **lazily loaded** ([0017](./0017-no-always-load-skills.md)), and **SOFT control that owns no semantics** (§26.1): it cites SOL/IR, the artifact contracts, the `docs/reference/` templates, and the `docs/research/sources.md` bibliography, but defines none of them.

This record **refines, and does not supersede,** ADRs 0016, 0017, 0019, 0029, 0036, and 0037.

## Alternatives considered

| Alternative | Why rejected |
| --- | --- |
| Keep `GUIDE.md` | Not the filename agent tools discover/activate; opts the kernel's own guides out of the activation mechanism its research calls load-bearing. |
| Keep one implement guide with nine branches | The "Everything Skill" anti-pattern: one broad description can't activate surgically, and the agent carries all nine kinds at once. |
| Keep profiles inlined in pass guides / ship only a few | An agent can't load a stance that has no file; bundling forces reading all stances to find one. Standalone + surgical descriptions cost less context, not more. |
| Leave the `author` pass guide-less | Leaves agents with no conditioning for authoring the Corpus way — the highest-leverage gap. |

## Consequences

### Positive

- Pass guides, profiles, and the per-kind/author skills are discoverable and activate surgically by description; an agent loads only what the task needs.
- The `author` pass gains real conditioning; all thirteen stances become loadable; per-kind implement depth is restored without reintroducing the persona×task-type routing matrix 0036 removed.

### Negative

- The shipped skill count grows substantially (~37 files — `pass-improve-spec` and `pass-lower-spec` were added later so all nine passes have a guide; see [0048](./0048-installed-payload-is-the-runtime-surface.md)'s Update). This is acceptable because the ~15/25 practitioner ceiling concerns *broad* descriptions causing mis-activation, not file count; surgical descriptions + name-based loading keep per-task context small.

### Neutral / tradeoffs

- The framework statements that "five stdlib pass guides ship in v0.1" are replaced by the larger shipped set; the flow-graph, conformance manifest, and the `docs/library/pass-guides.md` catalogue are updated. The frozen build-source spec is not re-synced, so its stdlib-guide count intentionally lags.

## Status

Accepted (v0.1).

## Affected obligations / constraints

- Adds: the `SKILL.md` carrier contract; the standalone per-`task_kind`, per-artifact, and per-profile skill set; surgical-`description` activation as the shipped norm.
- Modifies: the carrier filename (`GUIDE.md` → `SKILL.md`) and the shipped-skill inventory (the "five stdlib pass guides" packaging).
- Refines: [0016](./0016-skills-are-self-contained.md), [0017](./0017-no-always-load-skills.md), [0019](./0019-personas-ship-as-individual-skills.md), [0029](./0029-nine-pass-compiler-model.md), [0036](./0036-heuristic-profile-model.md), [0037](./0037-load-what-the-task-names.md).

> **Ledger note (2026-06-11):** refined by ADR-0064; per-kind routing clauses partially superseded by ADR-0068.
