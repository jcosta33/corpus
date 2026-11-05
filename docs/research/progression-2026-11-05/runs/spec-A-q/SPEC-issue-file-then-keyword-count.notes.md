# Run notes: SPEC-issue-file-then-keyword-count

Spec: [SPEC-issue-file-then-keyword-count.md](./SPEC-issue-file-then-keyword-count.md)
Filing payload: [SPEC-issue-file-then-keyword-count.fields.json](./SPEC-issue-file-then-keyword-count.fields.json)

Read at `jcosta33/sourdaw` commit `aa4d3e02f4951f8dfca455e92cb9b56bf9ed388e` (local `main` equals
`origin/main`).

## Evidence

- `.github/ISSUE_TEMPLATE/spec.yml`: the Requirements field description already states "Exactly
  one MUST / MUST NOT / SHOULD / SHOULD NOT / MAY in Then", and its placeholder is the
  `### AC-001` / `- When:` / `- Then:` / `- Verify with:` shape. Nothing enforces it.
- `scripts/fileTrackerIssue.ts`: `renderIssueSubmission` (lines 134-164) validates only required
  fields, dropdown options, and a blank title. `runCli` (lines 456-497) renders before branching on
  `--create`, so a throw during render exits 1 in preview and before `createIssue` reaches the
  injected `GhRunner`. The template stem is resolved at line 472; `spec` has no alias.
- `scripts/__tests__/fileTrackerIssue.spec.ts`: `runCli` cases already assert zero `gh` calls
  through `fakeGh` (for example lines 468, 525, 537, 566). The `filing` fixture (line 403) files a Spec with
  Requirements `r`, which has no AC heading; AC-015 keeps it valid.
- `scripts/runVitestZeroTestGuard.ts` forwards its arguments to `vitest run`, and
  `scripts/vitestZeroTestReport.ts:75` fails a run whose `-t` filter executes no assertion, so each
  `Verify with` command fails until its named case exists.
- `AGENTS.md` lines 278 (focused test command) and 456-470 (filing route, milestone and project
  rules).
- Tracker search (`gh issue list --state all`) for `issue:file`, `fileTrackerIssue`,
  `normative keyword`, `BCP 14`, and `spec form validation` found no existing issue for this rule.
  Related open tracker work: #5944, #5670.

## Settled without the human

Each is reversible and decided by convention or code; none blocks.

- Keyword set and case: whole uppercase words only, following RFC 8174, which gives the BCP 14
  keywords their meaning only in capitals. Lowercase `must` and words such as `MAYBE` do not count
  (AC-010, AC-011).
- `MUST NOT` and `SHOULD NOT` are single keywords, so a lone negated keyword passes (AC-008,
  AC-009).
- Count occurrences, not distinct keywords. `MUST … MUST` is two obligations, which the form's
  "exactly one" and the split-obligation rule both forbid (AC-006).
- Preview without `--create` rejects too, so preview predicts what `--create` would do. This matches
  the existing Features-route and `--project` refusals, which also fail before rendering output
  (AC-013).
- Name every offending AC ID, not only the first, so one run lists every repair (AC-005).
- Inline code spans in a `Then` line are counted like other text. The form states no exception, and
  rewording fixes a false positive.
- Scope is the Spec form only. The Task form pastes Spec AC blocks verbatim and could adopt the rule
  later; the intent names only Spec.
- Subsystem `build`, priority `P3`, matching the open `fix(tracker)` tooling issues. No milestone:
  none of the open milestones fits, and `AGENTS.md` says to leave it empty rather than force a fit.
  No `--project`: the Spec form already adds `project:features`.

## Questions for the human

None blocking. Recorded per the trial rules: none needed.

## Filing (not performed in this trial)

Would run from `/Volumes/Development/sourdaw` and land as a new issue in `jcosta33/sourdaw` with
labels `status:tracking`, `project:features`, and `priority:P3`, title
`spec(build): issue:file rejects a Spec AC whose Then line holds more than one normative keyword`:

```
pnpm issue:file spec --title "issue:file rejects a Spec AC whose Then line holds more than one normative keyword" --fields <this directory>/SPEC-issue-file-then-keyword-count.fields.json --create
```

The preview (same command without `--create`) was run and rendered that title and those labels.
After filing, the issue is the spec and these files are spent.

## Verify report

- Every AC has exactly `When`, `Then`, `Verify with`, in that order.
- Every `Then` line has exactly one keyword (checked with the counting rule this spec defines).
- No `TBD`, `TODO`, `???`, or blocking question in this `ready` spec.
- Local sources resolve: this file and the fields JSON exist beside the spec.
- Not verified: the `Verify with` commands were not run, because the named cases do not exist yet
  and each is expected to fail until the implementation lands.
