---
type: adversarial-review
id: CODEX-PROMPTLY-VALIDATION-CLOSEOUT-ADVERSARIAL-REVIEW
status: recorded
subject:
  - /Users/josecosta/dev/promptly@e0a70de
  - /Users/josecosta/dev/promptly-docs@8f4c3c6
date: 2026-06-13
reviewer: codex
stance: skeptic
---

# Promptly validation closeout adversarial review

## Scope

This review attacks the last Promptly effort:

- `/Users/josecosta/dev/promptly` commit `e0a70de`
  (`chore: close validation baseline`)
- `/Users/josecosta/dev/promptly-docs` commit `8f4c3c6`
  (`docs: close validation and plan reliability run`)
- the closeout evidence in Promptly-docs reviews, finding, status board, and
  `CHANGE-030-reliability-ux-swarm-stress-test`

This is not an independent merge-gate verdict. It is a skeptic self-critique:
try to refute the work, record the holes, and leave better test targets for the
next Swarm run.

## Evidence rerun

Promptly and Promptly-docs started clean:

```text
$ git status --short
exit 0
```

Promptly code state:

```text
$ git log --oneline --decorate -3
exit 0
e0a70de (HEAD -> main) chore: close validation baseline
df0b4cd fix: wait for model status before completing load
42b5f4e feat: add Promptly UX field-test improvements
```

Promptly-docs state:

```text
$ git log --oneline --decorate -3
exit 0
8f4c3c6 (HEAD -> main) docs: close validation and plan reliability run
d7f2041 docs: initialize Promptly Swarm workspace
```

Promptly formatting passed from the committed tree:

```text
$ pnpm exec prettier --check .
exit 0
Checking formatting...
All matched files use Prettier code style!
```

Promptly TypeScript passed:

```text
$ pnpm compile
exit 0
$ tsc --noEmit
```

Promptly lint passed with warning-level residuals:

```text
$ pnpm lint
exit 0
$ eslint .

✖ 19 problems (0 errors, 19 warnings)
```

Promptly build passed:

```text
$ pnpm build
exit 0
$ wxt build
WXT 0.20.6
...
✔ Built extension in 2.707 s
Σ Total size: 9.58 MB
✔ Finished in 2.777 s
```

Promptly Vitest passed:

```text
$ pnpm exec vitest run
exit 0
Test Files  14 passed (14)
Tests  115 passed (115)
Duration  2.23s
```

Promptly-docs diff checks passed:

```text
$ git diff --check
exit 0
```

## Findings

### P1 - The validation baseline is green, but the validation sequence is not durable

The closeout claim that the automated baseline can pass is true from a clean
checkpoint. The stronger claim that the requested validation sequence is stable
is false: running `pnpm build` and `pnpm exec vitest run` regenerated tracked
`.wxt` files in a non-Prettier shape, making the next full Prettier check fail.

Evidence:

```text
$ git status --short
exit 0
 M .wxt/eslint-auto-imports.mjs
 M .wxt/tsconfig.json
 M .wxt/types/globals.d.ts
 M .wxt/types/i18n.d.ts
 M .wxt/types/imports-module.d.ts
 M .wxt/types/imports.d.ts
 M .wxt/types/paths.d.ts
```

```text
$ pnpm exec prettier --check .
exit 1
Checking formatting...
[warn] .wxt/eslint-auto-imports.mjs
[warn] .wxt/tsconfig.json
[warn] .wxt/types/globals.d.ts
[warn] .wxt/types/i18n.d.ts
[warn] .wxt/types/imports-module.d.ts
[warn] .wxt/types/imports.d.ts
[warn] .wxt/types/paths.d.ts
[warn] Code style issues found in 7 files. Run Prettier with --write to fix.
```

The Promptly-docs finding does mention this limitation, and
`CHANGE-030-reliability-ux-swarm-stress-test` includes it in the baseline. The
remaining issue is product-side durability: a developer who runs the commands in
the listed order can end with a dirty or formatting-failing tree unless they know
to run Prettier again afterward.

Recommended next test target: make `TASK-032-extension-validation-harness` or a
separate baseline-hardening task decide whether tracked `.wxt` files should be
ignored, generated through a formatting hook, or excluded from Prettier.

### P2 - Runtime validation is honestly blocked, but still underdiagnosed

The closeout did the right thing by marking popup, overlay, and response
recovery runtime behavior as Blocked instead of Pass. The evidence proves that
the extension did not register in the attempted temporary profiles; it does not
prove why.

Recorded evidence in Promptly-docs:

```text
$ PROMPTLY_BROWSER_CHANNEL=chromium node /private/tmp/promptly-runtime-check.mjs
exit 1
Fail: runtime automation - browserContext.waitForEvent: Timeout 20000ms exceeded while waiting for event "serviceworker"
    at /private/tmp/promptly-runtime-check.mjs:73:28
```

```text
$ node -e "const fs=require('fs');const p='/private/tmp/promptly-direct-chrome-profile-closeout/Default/Preferences';const pref=JSON.parse(fs.readFileSync(p,'utf8'));console.log(Object.keys(pref.extensions?.settings||{}).length);console.log(Object.keys(pref.extensions?.settings||{}).join('\\n'));"
exit 0
0
```

Skeptic objection: this narrows the failure to extension registration, but it
does not distinguish Chrome policy, command-line flag behavior, invalid unpacked
extension shape, MV3 service-worker startup failure, WXT output assumptions, or
Playwright channel limitations.

Recommended next test target: make extension registration itself the first
runtime requirement, with a small checklist that records Chrome version, profile
path, extension id, `chrome://extensions` error text if visible, manifest parse
status, service-worker URL, and profile extension settings count.

### P2 - The validation fix commit is too broad to review comfortably

The commit closed the baseline, but it did so with a very large mixed diff:
approval config, Storybook/Vitest setup, TypeScript fixes, ESLint config, WXT
generated files, repo-wide formatting, import/order rewrites, JSON formatting,
and lockfile churn.

Evidence:

```text
$ git show --stat --oneline --summary -1
exit 0
e0a70de chore: close validation baseline
...
104 files changed, 11328 insertions(+), 7543 deletions(-)
create mode 100644 .storybook/vitest.setup.ts
create mode 100644 pnpm-workspace.yaml
```

Skeptic objection: this makes the commit functionally useful but review-hostile.
The risk is not that it is wrong, but that behavior-bearing fixes are buried
inside mechanical churn. The next run should split mechanical formatting,
generated-file policy, and behavior changes when the repo state allows it.

Recommended next test target: Swarm task packets should explicitly call out
whether a task is allowed to run repo-wide auto-fixers. If yes, the task should
expect a mechanical-only commit before behavior changes.

### P2 - Task packets were useful, but not consistently first-class execution drivers

The Promptly UX task files were real artifacts with source links, scope,
affected files, verification, and agent instructions. They were useful for
constraining scope. They were not consistently tested as cold-start worker
boot packets.

Evidence that the task files existed and carried implementation instructions:

```text
$ rg -n "^## Source|^## Scope|^## Delegation packet|^## Agent instructions|Read the source spec|Worker ownership|status:" /Users/josecosta/dev/promptly-docs/tasks/020-model-lifecycle.md /Users/josecosta/dev/promptly-docs/tasks/021-overlay-polish.md /Users/josecosta/dev/promptly-docs/tasks/022-response-recovery.md
exit 0
/Users/josecosta/dev/promptly-docs/tasks/022-response-recovery.md:8:status: implemented-needs-human
/Users/josecosta/dev/promptly-docs/tasks/022-response-recovery.md:13:## Source
/Users/josecosta/dev/promptly-docs/tasks/022-response-recovery.md:18:## Scope
/Users/josecosta/dev/promptly-docs/tasks/022-response-recovery.md:40:## Delegation packet
/Users/josecosta/dev/promptly-docs/tasks/022-response-recovery.md:42:Worker ownership is limited to response recovery behavior in the two affected
/Users/josecosta/dev/promptly-docs/tasks/022-response-recovery.md:57:## Agent instructions
/Users/josecosta/dev/promptly-docs/tasks/022-response-recovery.md:59:1. Read the source spec and change plan first.
/Users/josecosta/dev/promptly-docs/tasks/020-model-lifecycle.md:8:status: implemented-needs-human
/Users/josecosta/dev/promptly-docs/tasks/020-model-lifecycle.md:13:## Source
/Users/josecosta/dev/promptly-docs/tasks/020-model-lifecycle.md:18:## Scope
/Users/josecosta/dev/promptly-docs/tasks/020-model-lifecycle.md:51:## Agent instructions
/Users/josecosta/dev/promptly-docs/tasks/020-model-lifecycle.md:53:1. Read the source spec and change plan first.
/Users/josecosta/dev/promptly-docs/tasks/021-overlay-polish.md:10:status: implemented-needs-human
/Users/josecosta/dev/promptly-docs/tasks/021-overlay-polish.md:15:## Source
/Users/josecosta/dev/promptly-docs/tasks/021-overlay-polish.md:22:## Scope
/Users/josecosta/dev/promptly-docs/tasks/021-overlay-polish.md:54:## Agent instructions
```

Evidence that Jobs 020 and 021 used task packets but did not test worker boot:

```text
$ rg -n "The task packet was enough|No scout or worker" .agents/audits/codex/promptly-field-test-job-020-model-lifecycle.md .agents/audits/codex/promptly-field-test-job-021-overlay-polish.md
exit 0
.agents/audits/codex/promptly-field-test-job-020-model-lifecycle.md:38:the popup work from becoming a broader model-provider redesign. The task packet
.agents/audits/codex/promptly-field-test-job-020-model-lifecycle.md:53:No scout or worker participated in this job.
.agents/audits/codex/promptly-field-test-job-021-overlay-polish.md:34:full feature spec. The task packet was enough for implementation because it
.agents/audits/codex/promptly-field-test-job-021-overlay-polish.md:47:No scout or worker participated in this job.
```

Evidence that Job 022 was the strongest delegated-task datapoint:

```text
$ rg -n "Worker .*launched from the task packet|reported using|Delegation improved|read the task/spec|late delegation|task packet" .agents/audits/codex/promptly-field-test-job-022-response-recovery.md .agents/audits/codex/promptly-field-test-rollup.md
exit 0
.agents/audits/codex/promptly-field-test-job-022-response-recovery.md:34:and excluded persistence/history browsing. The task packet was enough for the
.agents/audits/codex/promptly-field-test-job-022-response-recovery.md:44:Worker `019ebdf4-5684-7771-9f6c-5aee56693a43` was launched from the task packet
.agents/audits/codex/promptly-field-test-job-022-response-recovery.md:50:The worker changed only `ResponseDisplay.tsx`. It reported using
.agents/audits/codex/promptly-field-test-job-022-response-recovery.md:104:model lifecycle or overlay positioning files. The task packet's non-goals kept
.agents/audits/codex/promptly-field-test-rollup.md:65:### Delegation improved with a task packet
.agents/audits/codex/promptly-field-test-rollup.md:68:subagent datapoints: it read the task/spec, used a narrow write scope, reported
```

Evidence that the later validation closeout did not have its own task packet:

```text
$ find /Users/josecosta/dev/promptly-docs/tasks -maxdepth 1 -type f -print | sort
exit 0
/Users/josecosta/dev/promptly-docs/tasks/011-enabled-state.md
/Users/josecosta/dev/promptly-docs/tasks/012-theme-selector.md
/Users/josecosta/dev/promptly-docs/tasks/013-copy-response.md
/Users/josecosta/dev/promptly-docs/tasks/014-overlay-close-cancel.md
/Users/josecosta/dev/promptly-docs/tasks/020-model-lifecycle.md
/Users/josecosta/dev/promptly-docs/tasks/021-overlay-polish.md
/Users/josecosta/dev/promptly-docs/tasks/022-response-recovery.md
/Users/josecosta/dev/promptly-docs/tasks/README.md
```

Skeptic objection: the field test showed that task files help scope work, but
it only weakly proved the Swarm promise that a fresh worker can boot from a task
packet and its linked artifacts. The validation closeout then bypassed task
packets entirely by following the user's explicit plan directly. That was
reasonable for the closeout, but it means the closeout did not exercise the
task-driven part of Swarm.

Secondary status concern: the task packet frontmatter still says
`implemented-needs-human`, while the board and reviews now use the sharper
state `automated pass; runtime blocked`. The linked review/finding explains the
truth, but task packet status is stale enough to mislead a worker that starts
only from the task file.

Recommended next test target: require delegated-worker run records to include a
boot manifest: AGENTS file read, task packet read, linked spec/bug/change-plan
read, skills loaded, and write ownership acknowledged before edits. Also update
task packet status whenever closeout changes review state.

### P2 - Warning-level lint debt includes runtime-adjacent files

Lint exits 0, so the closeout did not overstate command status. The residual
warnings are still meaningful because they include React hook dependency
warnings in overlay code, not only cosmetic import warnings.

Evidence:

```text
$ pnpm lint
exit 0
$ eslint .

/Users/josecosta/dev/promptly/src/modules/selection/presentations/hooks/useDraggable.ts
  56:6  warning  React Hook useEffect has a missing dependency: 'handleRef'. Either include it or remove the dependency array  react-hooks/exhaustive-deps

/Users/josecosta/dev/promptly/src/modules/selection/presentations/views/PromptOverlay/PromptOverlay.tsx
  252:6  warning  React Hook useEffect has a missing dependency: 'handleClose'. Either include it or remove the dependency array  react-hooks/exhaustive-deps

✖ 19 problems (0 errors, 19 warnings)
```

Skeptic objection: runtime acceptance is already blocked, and two warnings point
at runtime surfaces involved in overlay drag and close behavior. These should
not block the completed closeout, but they should be treated as review focus in
the next reliability run rather than background noise.

Recommended next test target: include hook dependency warnings in the audit for
Job 031 or Job 032 and either fix them or explicitly record why they are safe.

### P3 - Test output remains noisy

Vitest passes, but Storybook browser tests still emit controlled-form warnings
for Checkbox and Switch stories. This is not a product failure by itself, but it
reduces the signal value of future test runs.

Evidence:

```text
$ pnpm exec vitest run
exit 0
stderr | src/components/Switch/Switch.stories.tsx > Default
You provided a `checked` prop to a form field without an `onChange` handler.
...
stderr | src/components/Checkbox/Checkbox.stories.tsx > Checked
You provided a `checked` prop to a form field without an `onChange` handler.
...
Test Files  14 passed (14)
Tests  115 passed (115)
```

Recommended next test target: either make those stories explicitly read-only or
provide handlers so future warnings are more likely to mean new trouble.

### P3 - Promptly-docs status is accurate, but terse

The status board now says `automated pass; runtime blocked`, which is the right
high-level state. It does not expose the generated-file instability or lint
warning debt on the board itself, but the linked finding and change plan do.

Evidence:

```text
$ rg -n "automated pass|runtime blocked|WXT|19 problems|extension registers" reviews/020-model-lifecycle.md reviews/021-overlay-polish.md reviews/022-response-recovery.md findings/020-promptly-ux-field-test-validation.md change-plans/020-promptly-ux-field-test.md change-plans/030-reliability-ux-swarm-stress-test.md status.md
exit 0
status.md:40:| CHANGE-020-promptly-ux-field-test | change-plan | implemented; automated pass; runtime blocked | `change-plans/020-promptly-ux-field-test.md` |
findings/020-promptly-ux-field-test-validation.md:65:✖ 19 problems (0 errors, 19 warnings)
findings/020-promptly-ux-field-test-validation.md:108:WXT build/test activity regenerated tracked `.wxt` files in a non-Prettier
change-plans/030-reliability-ux-swarm-stress-test.md:48:- WXT build/test activity can regenerate tracked `.wxt` files in non-Prettier
change-plans/030-reliability-ux-swarm-stress-test.md:51:- Runtime validation is blocked until the built extension registers in a local
```

Recommended next test target: no immediate status edit is required, but future
status rows should consider a compact "automation pass; sequence dirties tree"
state if this remains unresolved.

## What survived attack

- The runtime UX work was not falsely accepted. The reviews use Blocked or
  Unverified for runtime behavior rather than turning build success into a
  product Pass.
- Promptly-docs is git-backed and clean.
- Promptly is clean again after restoring the WXT generated files with Prettier.
- The next reliability plan already targets the core failure mode: extension
  registration before popup or overlay assertions.
- The Promptly UX task files had enough structure to constrain implementation
  scope; Job 022 showed a task packet can materially improve delegated-worker
  behavior.
- Swarm framework files were not modified by the Promptly closeout.

## Consolidated next moves

1. Treat generated `.wxt` durability as a first-class reliability issue, not a
   footnote.
2. Make extension registration a standalone runtime gate before any popup,
   overlay, streaming, retry, or clear assertion.
3. Split future baseline-cleanup work into mechanical and behavior-bearing
   commits when practical.
4. Add a delegated-worker boot manifest to the next Swarm run: record task,
   linked artifacts, skills, and write scope before edits.
5. Update task packet statuses when closeout changes review state, so workers
   starting from the task file do not inherit stale state.
6. Investigate hook dependency warnings before relying on overlay drag/close
   runtime behavior as stable.
7. Reduce Storybook warning noise so future browser test output is easier to
   review.

## Cleanup evidence

After restoring generated files with Prettier, Promptly returned to a clean
state:

```text
$ ./node_modules/.bin/prettier --write .wxt/eslint-auto-imports.mjs .wxt/tsconfig.json .wxt/types/globals.d.ts .wxt/types/i18n.d.ts .wxt/types/imports-module.d.ts .wxt/types/imports.d.ts .wxt/types/paths.d.ts
exit 0
.wxt/eslint-auto-imports.mjs 17ms
.wxt/tsconfig.json 2ms
.wxt/types/globals.d.ts 17ms
.wxt/types/i18n.d.ts 6ms
.wxt/types/imports-module.d.ts 3ms
.wxt/types/imports.d.ts 7ms
.wxt/types/paths.d.ts 3ms
```

```text
$ git status --short
exit 0
```

```text
$ pnpm exec prettier --check .
exit 0
Checking formatting...
All matched files use Prettier code style!
```
