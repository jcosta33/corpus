---
type: audit
id: AUDIT-issue-file-route
---

# Audit: the `pnpm issue:file` filing route

## Scope

- Repository: `/Volumes/Development/sourdaw`, branch `main`, commit
  `aa4d3e02f4951f8dfca455e92cb9b56bf9ed388e`, tree `636b7da94610a5ef0f3f9bdfd52ea35dd973aca3`.
  The tracked tree was clean at freeze. Untracked paths existed only under `.agents/`, `.local/`, and
  `.review-private/`, and none of them is on this route.
- Goal: map how `pnpm issue:file` works today, from the package script to the `gh` call, ahead of a
  planned change to its validation.
- Mode: map only. Risk assessment was not requested, so this audit has no `## Findings` section.
- Exclusions: lane worktrees under `.agents/worktrees/`, which are other checkouts, and the
  gitignored review bundles under `.agents/review-bundles/` (`.gitignore:28`), which hold copies of
  `AGENTS.md`. The internals of the `gh` CLI and of GitHub are excluded except for read-only live
  metadata reads. The sibling scripts `issue:claim` and `issue:reconcile` are excluded.
- Open scope question (no human available): does "validation" include the input checks that `gh`
  and GitHub perform, such as milestone resolution and project attach? Recommended answer: yes, as
  consumers only. They appear below as faith dependencies and are not mapped internally.

## Map

### Entry point and consumers

- `package.json:73` maps `"issue:file"` to `node scripts/fileTrackerIssue.ts`. It runs directly. It
  does not go through `scripts/trustedGithubWriteBootstrap.ts`, unlike `issue:claim` and
  `issue:reconcile` at `package.json:71-72`.
- Node runs the `.ts` file directly. `package.json:6` sets `"type": "module"`, `package.json:9-10`
  requires engines `node >=24.15.0 <25`, and `.nvmrc` pins `24.19.0`.
- The module runs as a CLI only when it is the process entry
  (`scripts/fileTrackerIssue.ts:499-501`). Otherwise it is a library of exports.
- References in tracked files. This is a whole-tree search, excluding `.agents/worktrees/` and
  `.agents/review-bundles/`:
  `git ls-files | grep -v -E "^\.agents/(worktrees|review-bundles)/" | xargs grep -ln -E "fileTrackerIssue|issue:file"`
  returned only:
  - `AGENTS.md`. `CLAUDE.md`, `CODEX.md`, `GEMINI.md`, `KIMI.md`, and `ZCODE.md` are symlinks to
    it, confirmed with `ls -la`.
  - `package.json`
  - `oxlint.craft-baseline.mjs`
  - `scripts/prValidationScope.ts`
  - `scripts/fileTrackerIssue.ts`
  - `scripts/__tests__/fileTrackerIssue.spec.ts`
- No tracked file under `.agents/`, including `.agents/skills/` and `.agents/decisions/`, references
  the script. The search returned no match. Nothing under `.github/` references it either: a
  `grep -rln` over `.github` returned nothing.
- The only code importer is the spec, at `scripts/__tests__/fileTrackerIssue.spec.ts:7-18`. Agents
  and humans call it through the documented command (`AGENTS.md:456-473`).

### Contract as documented (`AGENTS.md:456-473`)

- `.github/ISSUE_TEMPLATE/*.yml` is declared "the schema" (`AGENTS.md:456`). The command form is
  given at `AGENTS.md:459`.
- Milestones are set by title. "validation against **open** milestones rejects it before filing"
  (`AGENTS.md:465`). The script itself has no milestone check. See the faith dependencies below.
- Routing rules for Features, Bugs, and Refactors are stated at `AGENTS.md:467-472`. The code that
  implements them is described under routing below.
- After filing, the caller attaches sub-issues by hand (`AGENTS.md:461`). No sanctioned script edits
  an issue after it is filed, apart from claim and reconcile (`AGENTS.md:473-476`).

### Control flow of `runCli` (`scripts/fileTrackerIssue.ts:456-497`)

1. `parseCliArgs(argv)` runs (`:176-236`).
   - `--help` must be `argv[0]` to count as help (`:185-187`).
   - `argv[0]` must be a template name that does not start with `--` (`:188-191`).
   - Recognized flags: `--create` (boolean), `--title`, `--fields`, `--milestone`, and `--project`.
     Any other flag fails with `unknown option` (`:233`).
   - `optionValue` (`:238-252`) rejects a missing value, a value starting with `--`, and a value
     that is empty after trimming. It returns the trimmed value.
   - A repeated `--milestone` or `--project` fails (`:215-217`, `:223-225`). A repeated `--title` or
     `--fields` silently keeps the last value: no duplicate guard exists at `:204-213`.
   - `--project` rejects `"`, `,`, CR, and LF (`:227-229`).
2. A missing template, title, or fields value fails with the usage message (`:468-470`).
3. Templates are resolved from `.github/ISSUE_TEMPLATE`, relative to the script file (`:471`).
   `resolveTemplatePath` (`:53-61`) lowercases the name, applies the aliases at `:33-37`
   (`bug`→`bug_report`, `feature`→`feature_request`, `change-plan`→`change_plan`), and requires
   `<stem>.yml` to exist.
4. A guard runs before any parsing (`:473-478`). If `--project` matches `/^Sourdaw Features$/iu`
   and the template stem is `bug_report` or `change_plan` (`:43`), the run fails with
   `<template> cannot target Sourdaw Features`.
5. `parseIssueForm` (`:63-100`) reads the YAML with regexes. It does not use a YAML library.
   - `title` must be a double-quoted JSON string (`quotedScalar`, `:281-287`).
   - `labels` must be an inline JSON array (`jsonScalar`, `:289-295`).
   - `name` is a plain scalar (`:297-303`).
   - The `body:` line is required (`:67-70`).
   - Items are split on `\n  - type: ` (`:71-74`) and `markdown` items are skipped (`:78`).
   - `id` and `label` are required for each item (`:81-85`).
   - `required` means the text `required: true` appears anywhere in the item block (`:87`).
   - `value: |` becomes `defaultValue` (`blockScalar`, `:317-343`).
   - `options:` list items become `options` (`listScalar`, `:345-365`).
6. `readFields(--fields)` (`:371-383`).
   - If the trimmed text starts with `{`, it is parsed as inline JSON. Otherwise it is treated as a
     file path and the file is read and parsed (`:372-374`).
   - The result must be a non-array object (`:375-377`).
   - Strings pass unchanged. Finite numbers and booleans become strings. Every other type fails with
     `field <key> must be a string` (`:385-396`).
   - Keys that the form does not declare are accepted and then ignored: the render loop at
     `:143-158` walks only `form.fields`.
7. `renderIssueSubmission` (`:134-164`).
   - It fails when the title subject is empty after any `type(scope):` prefix is stripped
     (`titleSubject`, `:126-132`; check at `:138-140`).
   - For each form field, the provided value is used, else the form default. A value that is only
     whitespace counts as absent (`nonempty`, `:274-279`).
   - A required field with no value fails with `missing required field: <id>` (`:146-149`). An
     optional field with no value renders `_No response_` (`:150`).
   - Fields with options go through `resolveOption` (`:254-272`). The value must equal an option,
     prefix one followed by a space or ` (`, or equal one of the ` / `-separated parts before a
     trailing parenthetical. Anything else fails with `invalid <id>: <value>`. The canonical option
     text is what gets rendered.
   - Free-text values are only trimmed at the end (`:153`). No length, content, or markdown checks
     were found in `:134-164`.
   - The label list starts as a copy of the form labels. It gains `priority:<value>` only when the
     field id is `priority` and the value matches `/^P[0-3]$/` (`:154-156`).
   - The body is a list of `### <label>\n\n<value>` sections (`:157`, `:162`).
   - The title comes from `composeIssueTitle` (`:102-110`), using the `scope` field value as the
     scope token (`:160`). A title already in `type(scope): ` form is kept, with `(scope)`
     substituted. Otherwise the form prefix is prepended with `(scope)` substituted, and a leading
     `<scope>: ` is removed from the subject (`:112-124`).
8. `routeIssueSubmission` (`:166-174`).
   - A Features project adds `project:features` if it is missing.
   - A Bugs or Refactors project (`:42`) removes `project:features`.
   - Any other project, or no project, leaves the labels unchanged.
   - Matching uses `/iu` regexes. The comment at `:46` says this matches gh's Go `EqualFold`.
9. Without `--create`, the run prints the submission JSON (`{title, labels, body}`) to stdout and
   returns 0 (`:484-487`). This is the preview path, and it never calls the runner.
10. With `--create`, `createIssue` (`:439-454`) runs.
    - It calls the injected `GhRunner` with `ghIssueCreateArgs` (`:398-410`): `issue create --title
      … --body …`, one `--label` per label, then `--milestone` and `--project` if they are truthy.
      The body travels as one argv element, not as a file.
    - The default runner is `spawnSync('gh', args, {encoding: 'utf8'})`. It has no `cwd` and no
      `--repo`, so `gh` picks the repository from the process working directory (`:434-437`).
    - A nonzero exit fails with stderr. With `--project` set, a note says the issue may already
      exist (`ghIssueCreateFailure`, `:419-425`; the reasoning is in the comment at `:412-418`).
    - On success, the run parses the issue number from the last URL segment of stdout and requires
      a positive safe integer (`:448-453`). It then prints `{url, number, title, labels}` (`:489-491`).
11. Every thrown error is caught. The message goes to stderr and the exit code is 1 (`:493-496`).
    `fail` throws a plain `Error` (`:367-369`).

### Validation inventory: where each check runs

| Check | Location | Before `gh`? |
| --- | --- | --- |
| Argument shape: template position, unknown flags, missing or empty values, values that look like flags | `scripts/fileTrackerIssue.ts:185-252` | yes |
| Duplicate `--milestone` or `--project` | `:215-217`, `:223-225` | yes |
| Single project title (no `"`, `,`, CR, or LF) | `:227-229` | yes |
| Template exists (after alias and lowercase) | `:53-61` | yes |
| Bug or Change plan form cannot target Features | `:473-478` | yes |
| Form file is structurally parseable | `:63-100`, `:281-303` | yes |
| Fields JSON is an object with scalar values | `:371-396` | yes |
| Title subject is not empty | `:138-140` | yes |
| Required fields are present | `:146-149` | yes |
| Dropdown values resolve to an option | `:153`, `:254-272` | yes |
| Milestone exists, is open, and matches by title | none in repo; delegated to `gh` (help text at `:464-465`, `AGENTS.md:465`) | no, done by `gh` |
| Project exists and can be attached | none in repo; delegated to `gh` | no, done by `gh` |
| Labels exist on the repository | none in repo; delegated to `gh` and GitHub | no, done by `gh` |
| Issue URL in `gh` output is readable | `:448-453` | after |

### Templates (the schema)

`.github/ISSUE_TEMPLATE/` contains `audit`, `bug_report`, `campaign`, `change_plan`,
`feature_request`, `inventory`, `research`, `spec`, and `task` forms, plus `config.yml`.

The header lines below come from `grep -n -E "^(name|title|labels):|id:|required:"` over each file.

| Form | Title prefix | Labels | Has `priority` | Has `scope` |
| --- | --- | --- | --- | --- |
| `audit.yml` | `audit(scope): ` | `status:tracking` | no | yes |
| `bug_report.yml` | `fix(scope): ` | `bug`, `status:ready` | yes | yes |
| `campaign.yml` | `feat(campaign): ` | `epic`, `status:tracking`, `project:features` | yes | no |
| `change_plan.yml` | `change(scope): ` | `status:tracking` | yes | yes |
| `feature_request.yml` | `feat(scope): ` | `enhancement`, `status:ready`, `project:features` | yes | yes |
| `inventory.yml` | `inventory(scope): ` | `status:tracking` | no | yes |
| `research.yml` | `research(scope): ` | `status:tracking` | no | yes |
| `spec.yml` | `spec(scope): ` | `status:tracking`, `project:features` | yes | yes |
| `task.yml` | `task(scope): ` | `status:ready` | yes | yes |

- Priority options are `P0` through `P3` (for example `.github/ISSUE_TEMPLATE/bug_report.yml:33-43`).
  So the forms without a priority field (audit, inventory, research) never gain a `priority:` label
  through this route. This follows from `scripts/fileTrackerIssue.ts:154-156` and the table above.
- `config.yml:1` sets `blank_issues_enabled: false`. `config.yml:6-14` names projects 2, 3, and 4
  as "Bugs", "Roadmap", and "Refactors". Live titles differ for project 3 (see below).
- The script and the GitHub web form share the same files. The parser expects formatting
  conventions (quoted `title`, inline JSON `labels`, two-space `- type:` items) that GitHub's form
  schema does not itself require. Nothing in the repository checks that conformance except the spec
  tests that parse the live templates (`scripts/__tests__/fileTrackerIssue.spec.ts:20-57`).

### Live tracker metadata (read-only, 2026-11-05, `gh version 2.103.3`)

```
$ gh project list --owner jcosta33 --format json -q '.projects[] | "\(.number)\t\(.title)\t\(.closed)"'
4	Sourdaw Refactors	false
3	Sourdaw Features	false
2	Sourdaw Bugs	false
```

The labels used by the route all exist. `gh label list --limit 300`, filtered, returned:
`bug`, `enhancement`, `epic`, `priority:P0`-`P3`, `project:features`, `status:active`,
`status:needs-evidence`, `status:ready`, `status:tracking`.

Open milestones (`gh api 'repos/:owner/:repo/milestones?state=open&per_page=100' -q '.[].title'`):
Reliability & security, Audio fidelity, Native plugin hosting, UX & documentation, Campaign
closure, Electron shell & native audio backend, Mixing harness, Arrangement & sequencing.

The repository resolved as `jcosta33/sourdaw` (`gh repo view`).

### Faith dependencies: what the route assumes and what enforces it

- That `gh` rejects a milestone that does not exist or is not open, and resolves titles without
  regard to case. In the repository this exists only as help text (`:464-465`) and documentation
  (`AGENTS.md:465`). Enforcing code in the repository: nothing found. Tests use a fake runner.
- That `gh` attaches `--project` in a second mutation, so a failure can leave a filed issue behind.
  This exists only as a comment (`:412-418`) and a test of the message text
  (`scripts/__tests__/fileTrackerIssue.spec.ts:570-584`, comment at `:570-574`). Enforcing code in the repository:
  nothing found.
- That gh matches project titles with Go `EqualFold`, equivalent to `/iu`. This exists only as a
  comment (`:46`). Tests cover `ſ` (long s) folding against the regex only
  (`spec.ts:472-501`, `:503-526`). Enforcing code in the repository: nothing found.
- That the `gh` working directory and authentication pick the right repository. There is no
  `--repo` and no `cwd` (`:434-437`). Enforcing code: nothing found.
- That `gh` prints the issue URL as the last line of stdout. This is enforced at `:448-453`, which
  fails on an unreadable URL after the issue has already been created.
- That templates follow the parser's formatting conventions. This is enforced only by the spec
  tests that parse the live forms (`spec.ts:26-57`) and by `fail` calls at parse time.
- Project title constants (`:39-42`) are not read from live metadata. Enforcing code: nothing
  found. They match the live titles above at freeze.

### Tests and the behavior each controls

`scripts/__tests__/fileTrackerIssue.spec.ts` (594 lines, Vitest):

- `parseIssueForm` (`:26-57`): which forms carry `project:features`, that markdown is excluded,
  the spec form's field order, and the campaign `operating_loop` default.
- `renderIssueSubmission` (`:59-152`) and title checks (`:215-242`): headings, defaults, scope
  token and alias resolution, missing required fields, blank or prefix-only titles, and invalid
  dropdown values.
- `composeIssueTitle` (`:154-183`), `resolveTemplatePath` (`:185-197`), `readFields` (`:199-213`),
  and the research `options` field (`:244-250`).
- `ghIssueCreateArgs` (`:252-305`): argv order (labels, then milestone, then project) and empty
  metadata.
- `parseCliArgs` (`:307-399`): missing values, values that look like flags, duplicate
  milestone or project, and the CSV project rejection.
- `runCli` (`:401-594`), through the injected `fakeGh` runner (`:446-456`; the reason is at
  `:441-445` and `scripts/fileTrackerIssue.ts:427-432`): default task labels, Features routing in
  both preview and create, Bugs and Refactors suppression, refusal of Bug or Change plan forms on
  Features, CSV refusal, milestone and project forwarding, the dry run without `--create`, and the
  failure message with and without a project.
- No test found for a duplicate `--title` or `--fields`, or for undeclared field keys. Source
  checked: the `describe`/`it` list from
  `grep -n -E "^\s*(describe|it|test)\(" scripts/__tests__/fileTrackerIssue.spec.ts`.

### CI and lint surfaces

- `scripts/prValidationScope.ts:27-37` lists `fileTrackerIssue` in `REVIEW_TOOLING`.
  `isReviewTooling` (`:143-162`) treats both `scripts/fileTrackerIssue.ts` and its spec as review
  tooling. `toolingReason` (`:164-172`, used at `:381`) labels them "known review tooling;
  security/static checks without browser execution".
- `.github/workflows/validation.yml:562-595`: the `tooling-unit` job runs when
  `needs.decide.outputs.tooling == 'true'`. It executes
  `pnpm test:run scripts --exclude=…`, and that exclusion list does not cover
  `fileTrackerIssue.spec.ts`.
- `oxlint.craft-baseline.mjs` exempts `scripts/fileTrackerIssue.ts` from two rules:
  `no-conditional-empty-spread` (`:36`, matching the spreads at `fileTrackerIssue.ts:95-96`) and
  `no-control-flow-ternary` (`:878`). The header at `:2-7` says a path leaves a list only once the
  file complies with that rule.

### History

`git log --oneline -5 -- scripts/fileTrackerIssue.ts` returns four commits: the route was
introduced in #2149, metadata flags arrived in #2281, scope handling in #3433, and explicit Features
label routing in #5667, the latest.

## Unverified

- Runtime behavior of the CLI. Nothing was executed: the trial rules forbid running `pnpm
  issue:file`, and running Vitest could write caches into the repository. Missing evidence: a dry
  run of `runCli` and a run of `scripts/__tests__/fileTrackerIssue.spec.ts`.
- `gh` and GitHub behavior that the route relies on: milestone matching, the non-atomic project
  attach, `EqualFold` project matching, URL output, and label rejection. Boundary: repository
  source and comments only. Missing evidence: `cli/cli` source at v2.103.3
  (`pkg/cmd/issue/create/create.go`, `api` issue creation) or a controlled run.
- Whether the `decide` job reliably sets the `tooling` profile for a change to
  `scripts/fileTrackerIssue.ts`. Read: `validation.yml:20`, `:43-45`, `:253-300`, and
  `prValidationScope.ts:370-395`. The full `decide` script and `pr-checks.yml` were not read.
- Instruction files outside this repository, such as global agent context and other agent skills,
  that may tell agents to call `pnpm issue:file`. Boundary: tracked files in
  `/Volumes/Development/sourdaw` only.
- Lane worktrees under `.agents/worktrees/` hold their own copies of the script and were excluded.
  Their versions may differ from `main`.
