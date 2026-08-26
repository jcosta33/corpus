# Checks

Checks catch common Suspec mistakes.

Use this page as a review checklist.

`suspec check` implements the deterministic subset. See the [CLI contract](cli.md) for commands,
companions, path resolution, and exits.

## Honesty levels

| Level | Meaning |
| --- | --- |
| convention | expected practice; not checked |
| checklist | reviewer inspects it |
| toolable | a tool can check it |
| enforced | a shipped tool rejects it (blocking exit) |

This docs repo enforces nothing by itself.

## Artifact recognition

`type:` is required. `spec`, `task`, `change-plan`, and `campaign` have deterministic checker
faces. `inventory`, `audit`, and `research` are recognized and return
`checked: false`. A missing or unknown type is a blocking usage error. `type: review` is unknown.

Each checked JSON report repeats its checked artifact `type` with `level`, `path`, and
`diagnostics`. An unchecked report repeats its type and carries `checked: false`. Only the optional
`(file set)` C002 report has no artifact type.

Frontmatter accepts one strict subset: an optional UTF-8 BOM; required opening and closing `---`;
top-level keys matching `[A-Za-z0-9_-]+`; string scalars; flat inline or block string lists; and
comments outside quotes. Strings are never coerced to booleans, numbers, or null. Duplicate keys,
malformed quotes or brackets, nesting, maps, multiline scalars, anchors, aliases, tags, empty list
heads, and scalar/list field-shape mismatches are blocking parse errors. Unknown extra keys are
allowed when they obey the subset.

Field shapes are exact: `type` and `id` are scalars on every recognized artifact; spec `sources`;
task `source` and `scope`; change-plan `sources` and `preserves`; and campaign `sources` are lists.
Their other defined fields are scalars.
Declared option values are exact and case-sensitive. Spec status is `draft` or `ready`; task status
uses the closed set below. A present value outside its declared set is a blocking contract error.

## Core checks

| ID | Name | Check | Severity |
| --- | --- | --- | --- |
| C001 | `unique-ids` | Requirement IDs are unique within a file. | hard-error |
| C002 | `duplicate-id` | No other file checked in the same invocation uses the same frontmatter `id:`. Requirement IDs are spec-scoped. | hard-error |
| C003 | `verify-with` | Every requirement has a non-empty `Verify with:`. | hard-error |
| C004 | `one-strength-word` | Each requirement's `Then` value uses exactly one binding word. | hard-error |
| C007 | `no-tbd-at-ready` | `status: ready` has no `TBD`, `TODO`, `???`, or blocking open question. | hard-error |
| C008 | `sources-named` | Frontmatter `sources:` names at least one origin. | warning |
| C009 | `broken-source-link` | Path-shaped source refs resolve against the spec's own directory (artifact-relative). Bare tracker IDs are exempt. | hard-error |
| C010 | `preserves-refs-resolve` | Change-plan `preserves:` entries resolve to requirements or `PG-NNN`; `SPEC-id#AC-NNN` refs resolve against the plan's sibling specs. | hard-error |
| C011 | `waves-present` | Migration, rewrite, and schema-change plans have waves with verify steps. | warning |
| C015 | `citation-resolves` | `[[KEY]]` citations resolve to anchors in the named `sources.md`, itself resolved against the spec's own directory. | warning |
| C019 | `malformed-requirement-heading` | A `###` heading shaped like a requirement id but with a lowercase split-suffix (`AC-004a`) — it parses as prose and silently vanishes from scope and coverage. | warning |
| C021 | `intent-present` | A spec has a non-empty `## Intent`. | hard-error |
| C022 | `task-shape` | Task type, non-empty ID/source/scope, field shapes, status, exactly-once required H2 sections, and non-empty dependency handoff match the contract. | hard-error |
| C023 | `task-evidence` | No evidence check runs at `ready` or `running`. At `review-ready` or `closed`, `## Verify` contains a numeric exit plus non-empty fenced raw output, a visible `CI:` or `CI link:` URL, or justified `n/a`. A fence is claim-only when its entire trimmed body matches <code>^(all )?(tests?&#124;checks?) (pass(ed)?&#124;succeeded)\.?$</code> case-insensitively. Any placeholder fence fails even beside valid output; visible placeholders fail case-insensitively. | hard-error |
| C024 | `closed-task-resolved` | A closed task contains no `TBD`, `TODO`, `???`, or non-empty canonical blocker labeled `Blocked questions:`, `Blocking:`, or `Open question (blocking):` after an unordered or ordered list marker; `none` and `n/a` are resolved. Fences and comments are excluded; inline code is live text. | hard-error |
| C025 | `spec-shape` | A spec has a non-empty ID, `draft` or `ready` status, exactly one `Intent` and `Requirements` section, and at least one parsed requirement. | hard-error |
| C028 | `requirement-shape` | Each requirement contains non-empty `When` and `Then` items followed by one `Verify with` item, with no other live body line. C003 owns an empty verification value. | hard-error |
| C029 | `campaign-shape` | A campaign has scalar type, ID, status, and ledger; list sources; `draft` or `ready` status; and exactly one non-empty Objective, Completion contract, Authorities, Operating loop, and Stops section. | hard-error |
| C030 | `campaign-authority` | Local ledger and source refs resolve artifact-relative, absolute local refs fail, and the campaign contains no Markdown task-list checkbox that duplicates ledger state. | hard-error |
| C031 | `campaign-ready` | A ready campaign contains no `TBD`, `TODO`, `???`, or non-empty canonical blocking label. | hard-error |

C005, C006, C012, C013, C014, C016, C017, C018, C020, C026, and C027 are reserved and never reused.

Notes:

- `AC-NNN` IDs are unique within a spec, not across files. Cross-spec references use `SPEC-id#AC-NNN`.
- A named `Verify with` method that does not exist yet is not a spec defect. The requirement is
  unverified until evidence exists.
- Diff size remains reviewer judgment; no packet-size threshold is asserted.
- Comparing changed files with `Do not change` needs the live diff and remains a reviewer checklist
  item.
- References resolve artifact-relative everywhere. A spec citing a file two folders up writes
  the relative path from its own directory (`../../sources/sup-204.md`); no root is ever inferred.
- A task is dispatched only when its source spec's status is exactly `ready`. Draft, missing, and
  unknown statuses are blocking.

## Writing watchlist

These words are allowed only when the same line makes them checkable.

| Family | Examples | Better form |
| --- | --- | --- |
| subjective | robust, clean, simple, intuitive | state observable behavior |
| quality without measure | fast, secure, reliable | give threshold or named test |
| vague verbs | handle, support, improve | name actor, action, object |
| loopholes | where feasible, if practical | make it required or remove it |
| ambiguous qualifiers | significant, minimal | quantify |
| comparatives | better, faster | name baseline and margin |
| broad quantifiers | all, any, every, some | name the exact set |
| bundling | and, or, and/or | split requirements |
| vague references | it, this, above | name the thing |

## Related

- [Writing specs](../04-writing-specs.md)
- [Reviewing output](../08-reviewing-output.md)
- [Artifact formats](artifact-formats.md)
