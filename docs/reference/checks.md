# Checks

Checks catch common Suspec mistakes.

Use this page as a review checklist.

`suspec check` implements the toolable subset. The CLI command catalogue is the source for what
ships today.

## Honesty levels

| Level | Meaning |
| --- | --- |
| convention | expected practice; not checked |
| checklist | reviewer inspects it |
| toolable | a tool can check it |
| enforced | a configured gate blocks on it |

This docs repo enforces nothing by itself.

## Core checks

| ID | Name | Check | Severity |
| --- | --- | --- | --- |
| C001 | `unique-ids` | Requirement IDs are unique within a file. | hard |
| C002 | `duplicate-id` | No other workspace file uses the same frontmatter `id:`. Requirement IDs are spec-scoped. | hard |
| C003 | `verify-with` | Every requirement has `Verify with:` or `VERIFY BY`. | hard |
| C004 | `one-strength-word` | Each requirement uses one binding word. | warning |
| C005 | `non-goals-present` | Non-goals section exists and is non-empty. | warning |
| C006 | `open-questions-present` | Open questions section exists, even if it says `None`. | warning |
| C007 | `no-tbd-at-ready` | `status: ready` has no `TBD`, `TODO`, `???`, or blocking open question. | hard |
| C008 | `sources-named` | Frontmatter `sources:` names at least one origin. | warning |
| C009 | `broken-source-link` | Workspace paths and cross-reference IDs resolve. | hard |
| C010 | `preserves-refs-resolve` | Change-plan `preserves:` entries resolve to requirements or `PG-NNN`. | hard |
| C011 | `waves-present` | Migration, rewrite, and schema-change plans have waves with verify steps. | warning |
| C012 | `coverage` | Review coverage rows match the task scope and source spec. | warning |
| C013 | `verify-evidence-binding` | Structured `verify` blocks match the requirement command and row result. | warning |
| C014 | `do-not-change-touched` | Changed files are reconciled against `Do not change`. | warning |
| C015 | `citation-resolves` | `[[KEY]]` citations resolve to anchors in the named `sources.md`. | warning |
| C016 | `pass-needs-evidence` | A `Pass` row with empty evidence is invalid. | hard |
| C017 | `orphaned-reference` | A bundled skill reference file is not named by its sibling `SKILL.md`. | warning |
| C018 | `malformed-requirement-heading` | A `###` heading shaped like a requirement id but letter-suffixed (`AC-004a`) — it parses as prose and silently vanishes from scope and coverage. | warning |

Notes:

- `AC-NNN` IDs are unique within a spec, not across the workspace. Cross-spec references use `SPEC-id#AC-NNN`.
- A `Verify with:` command that does not exist yet is not a spec defect. The requirement is `Unverified` until evidence exists.
- The oversized-packet size band is specified-not-shipped. `suspec review` reports diff size as neutral information.

## Workspace validity

A valid workspace has:

- populated `AGENTS.md`
- core templates present
- at least one spec that passes core checks

Keep live `AGENTS.md` and board files free of `{{placeholder}}` text. Templates may keep
placeholders.

## Task and review packet checks

| Check | Rule |
| --- | --- |
| `non-empty-paste` | Completion claims need pasted output or a CI link. |
| `no-open-critical` | Terminal task or review status has no unresolved blocking question. |
| `trigger-coverage` | Human attention considered every trigger class or marked it `n/a`. |
| `verify-evidence-binding` | Structured evidence matches its requirement row and command. |

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

## SOL checks

SOL-specific checks apply only to specs with `format: sol`.

The core C checks apply to both plain and SOL specs.

SOL-specific codes are the reference contract. Use the CLI catalogue to confirm which are
implemented in your installed version.

### Structure

| Code | Check |
| --- | --- |
| SOL-S001 | trigger without actor line |
| SOL-S002 | unknown block type or clause |
| SOL-S003 | actor line missing strength word |
| SOL-S004 | duplicate block ID |
| SOL-S005 | ID prefix does not match block type |
| SOL-S006 | `SHOULD` or `SHOULD NOT` lacks `BECAUSE` or `EXCEPT` |
| SOL-S007 | malformed header |
| SOL-S008 | metadata or prose before first control line |
| SOL-S010 | unknown metadata field |
| SOL-S011 | recognized block type with no ID |
| SOL-S012 | required spec section missing or out of order |
| SOL-S013 | hidden control or homoglyph characters |
| SOL-S014 | required clause missing |

### Prose

| Code | Check |
| --- | --- |
| SOL-P001 | condition has no consequence |
| SOL-P002 | actor missing |
| SOL-P003 | strength word missing or lowercase |
| SOL-P004 | multiple behaviors in one clause |
| SOL-P005 | watchlist word without same-line criterion |
| SOL-P006 | undefined term |
| SOL-P007 | bare `MUST NOT` with no affirmative behavior |
| SOL-P008 | uncertainty left in requirement prose |
| SOL-P050 | pronoun has no unique antecedent |
| SOL-P051 | passive voice hides actor |
| SOL-P052 | sentence is too long |
| SOL-P053 | not present tense / active voice |
| SOL-P054 | decorative phrase adds no constraint |
| SOL-P055 | repeated context adds nothing |
| SOL-P056 | comparative has no baseline |
| SOL-P057 | term drifts from glossary |
| SOL-P058 | `SHALL` used as a strength word |

### Cross-reference

| Code | Check |
| --- | --- |
| SOL-M001 | actor, object, surface, or ID resolves nowhere |
| SOL-M002 | direct contradiction |
| SOL-M003 | `DEPENDS ON`, `IMPLEMENTS`, or `PRESERVES` reference missing |
| SOL-M004 | lower-authority file weakens higher-authority requirement |

### Verification

| Code | Check |
| --- | --- |
| SOL-V001 | requirement, constraint, invariant, or interface lacks `VERIFY BY` |
| SOL-V002 | `VERIFY BY` target does not resolve |
| SOL-V003 | evidence cannot observe the claim |
| SOL-V004 | pass recorded against changed text or code |
| SOL-V005 | invalid result or lifecycle marker |
| SOL-V006 | interface not verified by contract check |
| SOL-V007 | lifecycle marker on wrong result |
| SOL-V008 | required binding has no result |
| SOL-V009 | unknown evidence type |
| SOL-V010 | manual or waived result lacks named human |
| SOL-V011 | evidence does not state what it exercised |

### Splitting

| Code | Check |
| --- | --- |
| SOL-O001 | parallel tasks write same files |
| SOL-O002 | dependency cycle |
| SOL-O003 | blocking question reaches task split |
| SOL-O004 | requirement lacks write/read scope |
| SOL-O005 | task writes outside scope |
| SOL-O006 | imported file duplicates policy requirement |
| SOL-O007 | requirement assigned to no task |
| SOL-O008 | requirement assigned to two implementing tasks |

## Severity split

Hard:

- C001, C002, C003, C007, C009, C010, C016
- all SOL-S
- SOL-P001-SOL-P008
- all SOL-M
- SOL-V001, SOL-V002, SOL-V004-SOL-V010
- SOL-O001, SOL-O002, SOL-O003, SOL-O005, SOL-O007, SOL-O008

Warning:

- C004, C005, C006, C008, C011, C012, C013, C014, C015, C017, C018
- SOL-P050-SOL-P058
- SOL-V003, SOL-V011
- SOL-O004, SOL-O006

Teams may promote warnings to blocking in their own gates.

## Related

- [Structured requirements](structured-requirements.md)
- [Writing specs](../04-writing-specs.md)
- [Reviewing output](../08-reviewing-output.md)
- [Artifact formats](artifact-formats.md)
