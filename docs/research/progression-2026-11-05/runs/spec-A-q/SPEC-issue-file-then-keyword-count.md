---
type: spec
id: SPEC-issue-file-then-keyword-count
status: ready
sources:
  - https://github.com/jcosta33/sourdaw/blob/aa4d3e02f4951f8dfca455e92cb9b56bf9ed388e/scripts/fileTrackerIssue.ts
  - https://github.com/jcosta33/sourdaw/blob/aa4d3e02f4951f8dfca455e92cb9b56bf9ed388e/.github/ISSUE_TEMPLATE/spec.yml
  - https://github.com/jcosta33/sourdaw/blob/aa4d3e02f4951f8dfca455e92cb9b56bf9ed388e/scripts/__tests__/fileTrackerIssue.spec.ts
  - ./SPEC-issue-file-then-keyword-count.notes.md
  - ./SPEC-issue-file-then-keyword-count.fields.json
---

# issue:file rejects a Spec AC whose Then line holds more than one normative keyword

## Intent

The Spec form already tells authors to put exactly one `MUST`, `MUST NOT`, `SHOULD`, `SHOULD NOT`, or
`MAY` in each `Then` line, but `pnpm issue:file spec` files whatever it is given. Agents filing specs,
and the implementers who later receive their acceptance criteria, must be able to rely on every filed
Spec AC carrying one obligation. `pnpm issue:file spec` must refuse a Requirements field in which any
acceptance criterion's `Then` line holds more than one of those keywords, name every offending AC ID
in its error, and do so before `gh` runs, with or without `--create`.

An acceptance criterion is a `### AC-<digits>` heading inside the Requirements field, optionally
followed by a short name; its `Then` line is the first line under that heading that starts with
`- Then:`, read to the end of that line. A keyword counts only as a whole, uppercase word.
`MUST NOT` and `SHOULD NOT` count as one keyword each, and a repeated keyword counts once per
occurrence.

The rule stops there. It does not reject a `Then` line with no keyword, inspect the `When` or
`Verify with` lines, check AC numbering, order, or item set, or apply to any form other than Spec.

## Requirements

### AC-001 Two keywords never reach gh
- When: `pnpm issue:file spec --title … --fields … --create` receives a Requirements field in which one AC's `Then` line contains both `MUST` and `MAY`
- Then: the command MUST NOT invoke `gh`
- Verify with: `pnpm guard --profile focused -- pnpm test:run scripts/__tests__/fileTrackerIssue.spec.ts -t "then keyword count: two keywords never reach gh"`

### AC-002 Two keywords exit 1
- When: `pnpm issue:file spec --title … --fields … --create` receives a Requirements field in which one AC's `Then` line contains both `MUST` and `MAY`
- Then: the command MUST exit with status 1
- Verify with: `pnpm guard --profile focused -- pnpm test:run scripts/__tests__/fileTrackerIssue.spec.ts -t "then keyword count: two keywords exit 1"`

### AC-003 The error names the offending AC
- When: the Requirements field holds `### AC-001` with one keyword in its `Then` line and `### AC-002` with two
- Then: the error printed to stderr MUST contain `AC-002`
- Verify with: `pnpm guard --profile focused -- pnpm test:run scripts/__tests__/fileTrackerIssue.spec.ts -t "then keyword count: error names the offending AC"`

### AC-004 The error leaves compliant ACs out
- When: the Requirements field holds `### AC-001` with one keyword in its `Then` line and `### AC-002` with two
- Then: the error printed to stderr MUST NOT contain `AC-001`
- Verify with: `pnpm guard --profile focused -- pnpm test:run scripts/__tests__/fileTrackerIssue.spec.ts -t "then keyword count: error leaves compliant ACs out"`

### AC-005 The error names every offending AC
- When: the Requirements field holds `### AC-002` and `### AC-003`, each with two keywords in its `Then` line
- Then: the error printed to stderr MUST contain both `AC-002` and `AC-003`
- Verify with: `pnpm guard --profile focused -- pnpm test:run scripts/__tests__/fileTrackerIssue.spec.ts -t "then keyword count: error names every offending AC"`

### AC-006 A repeated keyword counts twice
- When: `pnpm issue:file spec … --create` receives an AC whose `Then` line contains `MUST` twice and no other keyword
- Then: the command MUST NOT invoke `gh`
- Verify with: `pnpm guard --profile focused -- pnpm test:run scripts/__tests__/fileTrackerIssue.spec.ts -t "then keyword count: repeated keyword is rejected"`

### AC-007 A negated keyword beside another keyword is rejected
- When: `pnpm issue:file spec … --create` receives an AC whose `Then` line contains `SHOULD NOT` and `MAY`
- Then: the command MUST NOT invoke `gh`
- Verify with: `pnpm guard --profile focused -- pnpm test:run scripts/__tests__/fileTrackerIssue.spec.ts -t "then keyword count: negated keyword beside another is rejected"`

### AC-008 A lone MUST NOT is one keyword
- When: `pnpm issue:file spec … --create` receives ACs whose only keyword in each `Then` line is `MUST NOT`
- Then: the command MUST invoke `gh issue create` exactly once
- Verify with: `pnpm guard --profile focused -- pnpm test:run scripts/__tests__/fileTrackerIssue.spec.ts -t "then keyword count: lone MUST NOT files"`

### AC-009 A lone SHOULD NOT is one keyword
- When: `pnpm issue:file spec … --create` receives ACs whose only keyword in each `Then` line is `SHOULD NOT`
- Then: the command MUST invoke `gh issue create` exactly once
- Verify with: `pnpm guard --profile focused -- pnpm test:run scripts/__tests__/fileTrackerIssue.spec.ts -t "then keyword count: lone SHOULD NOT files"`

### AC-010 Lowercase words are not keywords
- When: `pnpm issue:file spec … --create` receives an AC whose `Then` line contains one `MUST` and the lowercase words `may` and `should`
- Then: the command MUST invoke `gh issue create` exactly once
- Verify with: `pnpm guard --profile focused -- pnpm test:run scripts/__tests__/fileTrackerIssue.spec.ts -t "then keyword count: lowercase words are not keywords"`

### AC-011 Words containing a keyword are not keywords
- When: `pnpm issue:file spec … --create` receives an AC whose `Then` line contains one `MUST` and the uppercase word `MAYBE`
- Then: the command MUST invoke `gh issue create` exactly once
- Verify with: `pnpm guard --profile focused -- pnpm test:run scripts/__tests__/fileTrackerIssue.spec.ts -t "then keyword count: containing words are not keywords"`

### AC-012 Only the Then line is counted
- When: `pnpm issue:file spec … --create` receives an AC whose `When` and `Verify with` lines each contain `MUST` and `MAY` and whose `Then` line contains exactly one keyword
- Then: the command MUST invoke `gh issue create` exactly once
- Verify with: `pnpm guard --profile focused -- pnpm test:run scripts/__tests__/fileTrackerIssue.spec.ts -t "then keyword count: only the Then line is counted"`

### AC-013 Preview rejects too
- When: `pnpm issue:file spec --title … --fields …` without `--create` receives an AC whose `Then` line contains both `MUST` and `MAY`
- Then: the command MUST exit with status 1
- Verify with: `pnpm guard --profile focused -- pnpm test:run scripts/__tests__/fileTrackerIssue.spec.ts -t "then keyword count: preview rejects too"`

### AC-014 A compliant Spec still files
- When: `pnpm issue:file spec … --create` receives a Requirements field in which every AC's `Then` line contains exactly one keyword
- Then: the command MUST invoke `gh issue create` exactly once
- Verify with: `pnpm guard --profile focused -- pnpm test:run scripts/__tests__/fileTrackerIssue.spec.ts -t "then keyword count: compliant spec files"`

### AC-015 Requirements without AC headings stay accepted
- When: always
- Then: a Spec whose Requirements field contains no `### AC-` heading MUST pass this rule
- Verify with: `pnpm guard --profile focused -- pnpm test:run scripts/__tests__/fileTrackerIssue.spec.ts -t "hands the parsed milestone and project to gh|reaches gh only with --create"`, the existing cases that file a Spec with Requirements `r`, kept unedited

## Sources

- Run notes, evidence, and settled choices: [SPEC-issue-file-then-keyword-count.notes.md](./SPEC-issue-file-then-keyword-count.notes.md)
- Exact filing payload: [SPEC-issue-file-then-keyword-count.fields.json](./SPEC-issue-file-then-keyword-count.fields.json)
