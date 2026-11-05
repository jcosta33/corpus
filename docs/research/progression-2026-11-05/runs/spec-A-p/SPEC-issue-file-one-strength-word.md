---
type: spec
id: SPEC-issue-file-one-strength-word
status: ready
sources:
  - ../../../../../sourdaw/scripts/fileTrackerIssue.ts
  - ../../../../../sourdaw/scripts/__tests__/fileTrackerIssue.spec.ts
  - ../../../../../sourdaw/.github/ISSUE_TEMPLATE/spec.yml
  - https://github.com/jcosta33/sourdaw/issues/4528
---

# issue:file rejects a spec AC whose Then carries more than one strength word

## Intent

`pnpm issue:file spec …` must refuse a Spec whose Requirements field holds any acceptance
criterion whose `Then` carries more than one of `MUST`, `MUST NOT`, `SHOULD`, `SHOULD NOT`, or
`MAY`. The error names every offending AC ID. The refusal happens before anything reaches GitHub,
in preview and with `--create` alike.

The Spec form already states the rule in its Requirements description ("Exactly one MUST / MUST
NOT / SHOULD / SHOULD NOT / MAY in Then", `.github/ISSUE_TEMPLATE/spec.yml:58`). Nothing enforces
it. `renderIssueSubmission` (`scripts/fileTrackerIssue.ts:137`) checks only that required fields
are present and that dropdown values are valid. Open Spec #4528 shows the gap: its AC-001 `Then`
reads "it MUST NOT own an audio path, and its fader, mute, and solo MUST cascade…", which is two
obligations that can fail independently.

Counting rules, settled here as reversible conventions:

- Count occurrences, not distinct words. `MUST … MUST` is two obligations, and the form asks for
  exactly one.
- `MUST NOT` and `SHOULD NOT` each count as one, never as `MUST` or `SHOULD` plus a stray `NOT`.
- Only uppercase whole words count, as RFC 8174 defines these keywords. Lowercase `must` and
  tokens such as `MAYBE` or `MUST_RUN` do not count.
- An AC is a `### AC-NNN` heading, with or without a ` - Short name` suffix, and runs to the next
  `###` heading. Its `Then` item runs from `- Then:` to the next list item or heading, so an
  indented continuation line belongs to it.

## Requirements

### AC-001 - Reject a two-keyword Then before gh runs
- When: `runCli` receives `spec --create` with Requirements `### AC-002 - Keep takes\n- When: a take is recorded\n- Then: the store MUST persist the take and MUST NOT drop its markers\n- Verify with: x`, using an injected gh runner
- Then: `runCli` MUST return 1 with zero recorded gh calls
- Verify with: `pnpm test:run scripts/__tests__/fileTrackerIssue.spec.ts`

### AC-002 - Name the offending AC
- When: the AC-001 input is rejected
- Then: the stderr message MUST contain `AC-002`
- Verify with: `pnpm test:run scripts/__tests__/fileTrackerIssue.spec.ts`

### AC-003 - Name every offending AC
- When: Requirements hold `AC-001` and `AC-003` with two keywords in `Then` each, and `AC-002` with one
- Then: the stderr message MUST contain both `AC-001` and `AC-003`
- Verify with: `pnpm test:run scripts/__tests__/fileTrackerIssue.spec.ts`

### AC-004 - Reject in preview too
- When: the AC-001 input is given without `--create`
- Then: `runCli` MUST return 1 without writing a submission to stdout
- Verify with: `pnpm test:run scripts/__tests__/fileTrackerIssue.spec.ts`

### AC-005 - Count a repeated keyword twice
- When: an AC's `Then` reads `the mixer MUST mute the group and MUST restore it on unmute`
- Then: `runCli` MUST return 1 and name that AC
- Verify with: `pnpm test:run scripts/__tests__/fileTrackerIssue.spec.ts`

### AC-006 - Count a negated keyword once
- When: every AC's `Then` holds exactly one of `MUST NOT` or `SHOULD NOT` and no other keyword
- Then: the preview MUST return 0 and print the rendered submission
- Verify with: `pnpm test:run scripts/__tests__/fileTrackerIssue.spec.ts`

### AC-007 - Ignore lowercase keywords
- When: an AC's `Then` reads `the command MUST exit 1 when the user must retry`
- Then: the preview MUST return 0
- Verify with: `pnpm test:run scripts/__tests__/fileTrackerIssue.spec.ts`

### AC-008 - Ignore tokens that only contain a keyword
- When: an AC's `Then` reads ``the runner MUST set `MUST_RUN` and keep MAYBE unset``
- Then: the preview MUST return 0
- Verify with: `pnpm test:run scripts/__tests__/fileTrackerIssue.spec.ts`

### AC-009 - Read a wrapped Then
- When: an AC's `Then` holds one `MUST` on the `- Then:` line and a second `MUST` on the indented continuation line below it
- Then: `runCli` MUST return 1 and name that AC
- Verify with: `pnpm test:run scripts/__tests__/fileTrackerIssue.spec.ts`

### AC-010 - Keep conforming specs filing unchanged
- When: always
- Then: a Spec whose Requirements contain no AC with more than one keyword in `Then`, including free text with no AC heading, MUST render the same title, labels, body, and gh argv as before this change
- Verify with: `pnpm test:run scripts/__tests__/fileTrackerIssue.spec.ts`, including the unchanged existing `runCli` cases that file `spec` with Requirements `r`

### AC-011 - Leave a conforming AC unnamed
- When: the AC-003 input is rejected
- Then: the stderr message MUST NOT contain `AC-002`
- Verify with: `pnpm test:run scripts/__tests__/fileTrackerIssue.spec.ts`

## Non-goals

- Rejecting a `Then` with no keyword. The intent covers only more than one; a zero-keyword gate
  is a separate decision.
- Checking other forms. The Task form pastes Spec AC blocks verbatim, so it inherits a valid
  Spec's ACs; it is not gated here.
- Checking Spec fields other than Requirements, or validating the When and Verify with items.
- Exempting AC text inside fenced code blocks.
- Re-checking issues already filed, including #4528.
- Changing `.github/ISSUE_TEMPLATE/spec.yml`. Its description already states the rule.

## Affected areas

- `scripts/fileTrackerIssue.ts`: the check runs on the rendered Spec Requirements value, after
  template resolution and before `createIssue`, in the path shared by preview and `--create`.
- `scripts/__tests__/fileTrackerIssue.spec.ts`: new `runCli` cases through the existing
  injected `fakeGh` runner, never a `node:child_process` mock.
