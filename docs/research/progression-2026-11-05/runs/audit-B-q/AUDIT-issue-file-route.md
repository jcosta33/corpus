---
type: audit
id: AUDIT-issue-file-route
---

# Issue-filing route behind `pnpm issue:file`

## Scope

- Goal: map the current route from `pnpm issue:file` to `gh issue create`, ahead of a planned change
  to its validation. Map only; risk was not requested and is not assessed.
- Surface: the package script, `scripts/fileTrackerIssue.ts`, the issue forms it reads, its spec,
  the agent contract that documents it, and the repository tooling that names it.
- Exclusions: `pnpm issue:claim` and `pnpm issue:reconcile` (separate routes through
  `scripts/trustedGithubWriteBootstrap.ts`), GitHub-side project automation, and gh internals.
- Frozen state: `/Volumes/Development/sourdaw`, branch `main`, commit
  `aa4d3e02f4951f8dfca455e92cb9b56bf9ed388e`, tree `636b7da94610a5ef0f3f9bdfd52ea35dd973aca3`.
  `git diff --quiet HEAD -- scripts .github package.json AGENTS.md` printed `clean in scope`.
  Untracked directories exist only under `.agents/`, `.local/`, and `.review-private/`. The last
  commit touching the script and the forms is `ee8939c9c4` (2026-10-25, #5667).
- Path alias: `S/` below means `../../../../../sourdaw/`, relative to this artifact.
- Scope question recorded for the owner (no human was available): should the map include the
  sibling tracker routes `issue:claim` and `issue:reconcile`?
  - Recommended: no. Map `issue:file` only. Cost: a validation change that should also hold for
    claim or reconcile needs a second map.
  - Option: include all three tracker routes. Cost: roughly triples the surface; they use a
    different bootstrap (`S/package.json:71-72`).
  - This audit proceeded on the recommendation.

## Map

### Entry and process boundary

- `S/package.json:73` maps `issue:file` to `node scripts/fileTrackerIssue.ts`. It runs the
  TypeScript source directly under Node, with no build step. Installed Node is `v24.22.2`, and
  `S/package.json:9-10` requires `>=24.15.0 <25`.
- Unlike its siblings, it is not routed through the trusted write bootstrap:
  `S/package.json:71-72` sends `issue:reconcile` and `issue:claim` through
  `scripts/trustedGithubWriteBootstrap.ts`. Running `grep -n -E "issue:file|fileTrackerIssue"
  scripts/trustedGithubWriteBootstrap.ts` printed no match and exited 1.
- Main guard: `S/scripts/fileTrackerIssue.ts:499-501` calls
  `process.exit(runCli(process.argv.slice(2)))` only when the file is the process entry.
- Exit codes: `runCli` returns 0 on help, dry run, or create (`:466`, `:486`, `:492`). It returns
  1 on any thrown error, after printing the message to stderr (`:493-496`). Every validation
  failure goes through `fail()`, which throws `Error` (`:367-369`). The catch also traps
  non-`fail` throws: `JSON.parse` syntax errors and `readFileSync` errors.

### Pipeline order inside `runCli` (`S/scripts/fileTrackerIssue.ts:456-497`)

1. **Argument parse** with `parseCliArgs` (`:176-236`):
   - Help is recognized only as `argv[0] === '--help'` (`:185-187`).
   - `argv[0]` is the template; it must exist and must not start with `--` (`:188-191`).
   - Flags: `--create` (boolean, `:199-202`), `--title`, `--fields`, `--milestone`, and
     `--project`. Any other token fails with `unknown option` (`:233`).
   - Repeating `--milestone` or `--project` fails (`:215-217`, `:223-225`). A repeated `--title`
     or `--fields` silently keeps the last value: those branches have no duplicate check
     (`:204-213`).
   - `optionValue` (`:238-252`) rejects a missing value, a value starting with `--`, and a
     whitespace-only value, then returns the trimmed value.
   - `--project` also rejects `"`, `,`, CR, and LF (`:227-229`).
   - `--milestone` gets no local check beyond `optionValue`.
2. **Required arguments**: template, title, and fields path must all be present (`:468-470`).
3. **Template resolution** with `resolveTemplatePath` (`:53-61`). The name is lowercased, then
   mapped through the aliases `bug`, `feature`, and `change-plan` (`:33-37`). The file
   `<stem>.yml` must exist. The templates directory is resolved relative to the script file, not
   the working directory (`:471`).
4. **Features-target refusal** (`:473-478`): `bug_report` and `change_plan`
   (`NON_FEATURES_TEMPLATES`, `:43`) fail when `--project` matches `/^Sourdaw Features$/iu`
   (`:41`). The `/iu` flags give Unicode simple case folding; the comment at `:46` says this
   matches gh's Go `EqualFold`. That equivalence is not verified here (see Unknowns).
5. **Form parse** with `parseIssueForm` (`:63-100`). This is a regex parser, not a YAML library:
   - `title` must be a double-quoted JSON scalar (`:281-287`).
   - `labels` must be a JSON array literal (`:289-295`).
   - `name` is a plain scalar (`:297-303`). It is parsed but never read: `grep -n "\.name"` over
     the script and its spec printed no match.
   - The body is split on `\n  - type: ` (`:71-74`), and `markdown` items are skipped (`:78`).
   - Each remaining item needs `id` and `label` (`:81-85`).
   - `required` is true when `/required:\s*true/` appears anywhere in the item text (`:87`).
   - Defaults come only from a `value: |` block scalar (`:88`, `:317-343`).
   - Options come from an `options:` list (`:89`, `:345-365`).
6. **Field input** with `readFields` (`:371-383`):
   - A source that starts with `{` after leading whitespace is parsed as inline JSON. Anything
     else is read as a file path (`:372-374`).
   - The parsed value must be a non-array object (`:375-377`).
   - Values may be strings, finite numbers (stringified), or booleans (`'true'`/`'false'`).
     Any other value type fails (`:385-396`).
7. **Render** with `renderIssueSubmission` (`:134-164`):
   - The title subject must be non-empty after stripping a `type(scope):` prefix (`:138-140`,
     `:126-132`).
   - Fields are iterated in form order (`:143`). JSON keys that match no form field id are never
     read.
   - A blank or absent value falls back to the form default (`:145`).
   - A still-missing required field fails with `missing required field: <id>` (`:146-149`).
   - A missing optional field renders `_No response_` (`:150`).
   - Option fields resolve the raw value through `optionMatchesToken` (`:153`, `:254-272`). It
     accepts an exact match, a prefix followed by a space or ` (`, or any `/`-separated alias
     with the trailing parenthetical removed. A miss fails with `invalid <id>`.
   - A `priority` field whose value is `P0`–`P3` appends the label `priority:<value>`
     (`:154-156`).
   - The body is `### <label>\n\n<value>` sections joined by blank lines (`:157`, `:162`).
   - The title is built by `composeIssueTitle(prefix, title, fields.scope)` (`:160`, `:102-110`):
     - It uses the raw `scope` input, not the resolved option.
     - An input title already in `type(scope): ` form is kept, and only `(scope)` is substituted.
     - Otherwise the form prefix gets `(scope)` replaced, and a leading `<scope>: ` is stripped
       from the subject (`:112-124`).
8. **Project label routing** with `routeIssueSubmission` (`:166-174`):
   - A Features project adds `project:features` when it is absent.
   - `Sourdaw Bugs` or `Sourdaw Refactors` (`:42`, also `/iu`) removes it.
   - Any other project, or no project, leaves the labels unchanged.
9. **Dry run**: without `--create`, the submission `{title, labels, body}` is printed as JSON
   and gh is never reached (`:484-487`).
10. **Create** with `createIssue` (`:439-454`), through the runner (`:432-437`):
    - `ghIssueCreateArgs` (`:398-410`) builds
      `issue create --title <t> --body <b> [--label <l>]... [--milestone <m>] [--project <p>]`.
      Milestone and project are appended only when truthy.
    - The default runner is `spawnSync('gh', args, {encoding: 'utf8'})` (`:434-437`). It uses no
      shell, and the working directory and environment are inherited. A null exit status maps
      to 1.
    - On a nonzero status the message is the stderr text, plus a hedge when `--project` was set:
      "the issue may already have been created" (`:419-425`). The doc comment at `:412-418`
      attributes this to gh attaching projects in a second mutation.
    - On success, the last `/` segment of the stdout URL must be a positive safe integer
      (`:448-452`).
    - The script then prints `{url, number, title, labels}` as JSON (`:489-491`).

### Validation located elsewhere

- **Milestone**: the script never looks up milestones. `--milestone` passes straight through to
  gh (`:403-405`). The help text says it "matches an open milestone by title,
  case-insensitively" and that "a milestone number does not resolve" (`:464-465`).
  `S/AGENTS.md:464-465` says "validation against **open** milestones rejects it before filing".
  Both describe gh-side behavior; neither is enforced in this file.
- **Project existence**: there is no local check that a project exists. gh resolves the title.
- **Labels**: there is no local check that a label exists. Labels come from the form header plus
  the priority and route labels.

### Data inputs: issue forms (`S/.github/ISSUE_TEMPLATE/`)

From `grep -n -E "^(name|title|labels|body):"` and the `id:` / `required: true` lines per file:

| Form (alias) | Title prefix | Header labels | Has `priority` field |
| --- | --- | --- | --- |
| `audit.yml` | `audit(scope): ` | `status:tracking` | no |
| `bug_report.yml` (`bug`) | `fix(scope): ` | `bug`, `status:ready` | yes, required |
| `campaign.yml` | `feat(campaign): ` | `epic`, `status:tracking`, `project:features` | yes, required |
| `change_plan.yml` (`change-plan`) | `change(scope): ` | `status:tracking` | yes, required |
| `feature_request.yml` (`feature`) | `feat(scope): ` | `enhancement`, `status:ready`, `project:features` | yes, required |
| `inventory.yml` | `inventory(scope): ` | `status:tracking` | no |
| `research.yml` | `research(scope): ` | `status:tracking` | no |
| `spec.yml` | `spec(scope): ` | `status:tracking`, `project:features` | yes, required |
| `task.yml` | `task(scope): ` | `status:ready` | yes, required |

- `config.yml` sits in the same directory and has no `title:` line. Passing `config` as the
  template would resolve to it under `resolveTemplatePath`. This is static reading only; the run
  was not permitted (see Unknowns).
- `campaign.yml` has no `scope` field, so its prefix stays `feat(campaign): `.
- These forms also drive the GitHub web form UI (`config.yml` sets `blank_issues_enabled: false`).
  The script parses them independently of GitHub's own form schema.

### Documentation and contract surfaces

- `S/AGENTS.md:456-479` documents the command, the schema location, milestone-by-title, and the
  Features routing rules.
- `CLAUDE.md`, `CODEX.md`, `GEMINI.md`, `KIMI.md`, and `ZCODE.md` are symlinks to `AGENTS.md`
  (`ls -la` shows `-> AGENTS.md`), so the documentation has one source.
- The in-script help text is at `S/scripts/fileTrackerIssue.ts:459-466`, and the usage string at
  `:50-51`.

### Repository tooling that names the route

- `S/scripts/prValidationScope.ts:36` lists `fileTrackerIssue` in `REVIEW_TOOLING`. Through
  `isReviewTooling` (`:143-162`), a pull request that changes only `scripts/fileTrackerIssue.ts`
  or `scripts/__tests__/fileTrackerIssue*.spec.ts` gets the reason "known review tooling;
  security/static checks without browser execution" (`:168-169`).
- `S/.github/workflows/validation.yml:269-283` sets `tooling=true` for a `tooling` profile on
  `pull_request`. The `tooling-unit` job (`:562-565`, run step `:595-596`) then runs
  `pnpm test:run scripts` with five unrelated specs excluded. `fileTrackerIssue.spec.ts` is not
  among the exclusions.
- `S/oxlint.craft-baseline.mjs:36` and `:878` list the script under the burn-down exemptions for
  `no-conditional-empty-spread` (`:19`) and `no-control-flow-ternary` (`:856`). The file header
  (`:2-7`) says a path leaves a list once it complies and none is ever added.
- `S/scripts/__tests__/healthGatesWorkflow.spec.ts:3177-3185` asserts that exempting
  `.github/ISSUE_TEMPLATE/**` from the validation path filter throws "repository metadata is
  machine-read and must not be exempt". Form edits therefore count as code for path filtering.
- Whole-scope negative check: `git ls-files | xargs grep -ln -E
  "fileTrackerIssue|issue:file|ISSUE_TEMPLATE"` printed only `AGENTS.md`, its five symlinks,
  `oxlint.craft-baseline.mjs`, `package.json`, the spec, `healthGatesWorkflow.spec.ts`, the
  script itself, and `prValidationScope.ts`.
- Running `grep -rn` for the same terms in `.github/workflows` printed no match.
- Running `grep -rln` for `issue:file|fileTrackerIssue` in `.agents/skills`, `.agents/decisions`,
  and `.claude` printed no match and exited 1.
- The only importer of the module's exports is the spec (`S/scripts/__tests__/fileTrackerIssue.spec.ts:7-18`).

### Tests and what each controls

The spec is `S/scripts/__tests__/fileTrackerIssue.spec.ts`. It reads the real forms from
`process.cwd()/.github/ISSUE_TEMPLATE` (`:20`), so it must run from the repository root.

A fresh run passed 47 of 47 tests in 1 file. The receipt is
[AUDIT-issue-file-route.vitest.txt](AUDIT-issue-file-route.vitest.txt). The command was
`./node_modules/.bin/vitest run scripts/__tests__/fileTrackerIssue.spec.ts --exclude '.agents/**'
--reporter=verbose`.

Without `--exclude`, the same filter collected 10 files: the root spec plus 9 copies under
`.agents/artifacts/5852-parent-0f-pnpm-store/…` (`vitest list --filesOnly` output).

What each block controls:

- `parseIssueForm` (`:26-57`):
  - Only the Feature, Spec, and Campaign forms carry `project:features`.
  - Markdown blocks are excluded.
  - Spec field order and prefix are fixed.
  - The Campaign `operating_loop` default is captured and required.
- `renderIssueSubmission` (`:59-152`): headings, the Campaign default fill, Bug scope-token and
  slash-alias option resolution, and the missing-required-field failure.
- `composeIssueTitle` (`:154-183`): no double prefix, a conventional title is kept, parentheses
  inside the scope are handled, and the scope is interpolated.
- `resolveTemplatePath` (`:185-197`): aliases and case variants.
- `readFields` (`:199-213`): inline JSON with number coercion, and a JSON file path. Boolean
  coercion and non-object rejection are not exercised.
- `renderIssueSubmission title` (`:215-242`): a blank title, a prefix with no subject, and an
  invalid dropdown value.
- `research options field` (`:244-250`): the Research `options` textarea is not treated as a
  dropdown.
- `ghIssueCreateArgs` (`:252-305`): argv order and conditional metadata.
- `parseCliArgs` (`:307-399`):
  - Dry-run default and flag reading.
  - A missing value, and an option swallowed as a value.
  - A repeated `--milestone` or `--project`.
  - CSV project rejection.
  - Repeated `--title` or `--fields` behavior is not exercised.
- `runCli` (`:401-594`), with an injected `fakeGh` runner (`:446-457`, rationale at `:441-445`):
  - A Task stays unrouted.
  - Features routing works in preview and create, including the `ſ` long-s fold.
  - Bugs and Refactors routes strip the Features label.
  - Bug and Change plan forms are refused on Features before gh.
  - CSV project syntax is refused before gh.
  - Milestone and project reach gh argv (`:545-558`).
  - gh is reached only with `--create`.
  - The project-attach failure hedge appears, and is absent without a project.
- The default `spawnGh` runner and the real gh process are never exercised by any test: every
  `runCli` call in the spec passes `gh.run`.

## Unknowns

- **Dry-run CLI behavior for edge inputs** (`--help`, the `config` template, a form without a
  priority field). Search boundary: static reading of `fileTrackerIssue.ts`. Missing evidence: a
  dry run. Running `node scripts/fileTrackerIssue.ts` without `--create` was refused by this
  session's permission classifier ("External System Writes"), so these behaviors are inferred
  from code only.
- **gh-side milestone validation.** Unconfirmed: that gh rejects closed milestones and milestone
  numbers before filing, as `S/AGENTS.md:465` and the help text state. Search boundary: this
  repository. Missing evidence: gh `2.103.3` source or a controlled run. A real run would be a
  public write and was not attempted.
- **gh title folding.** Unconfirmed: that gh's project-title resolution uses Go `EqualFold` and
  matches JavaScript `/iu` folding, as the comment at `S/scripts/fileTrackerIssue.ts:46` says.
  Missing evidence: gh source for project lookup.
- **Two-step project attach.** Unconfirmed: that `gh issue create --project` creates the issue and
  then attaches the project in a separate mutation, exiting nonzero without printing the URL on
  attach failure (`:412-418`). Missing evidence: gh source at the installed version.
- **Repository target.** Not established: which repository gh writes to. The runner passes no
  `--repo`, so gh resolves it from the inherited working directory and environment (for example
  `GH_REPO`). `git remote -v` shows `origin https://github.com/jcosta33/sourdaw.git`. Running the
  script from a lane worktree or another directory was not observed.
- **GitHub-side automation after filing** (Features auto-add on `project:features`, and the
  exclusion of `bug`) is described at `S/AGENTS.md:467`. It lives in GitHub project settings,
  outside the repository, and was not inspected.
- **Full CI path for a validation change.** Not read: how the `decide` job's scope plan assigns
  the `tooling` profile end to end (`S/scripts/prValidationScope.ts` beyond `:143-170`, and
  `S/.github/workflows/pr-checks.yml`).
