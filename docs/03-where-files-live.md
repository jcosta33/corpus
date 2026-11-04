# Artifact location and close

## Placement

Place ordinary Suspec artifacts under:

```text
~/.agents/artifacts/<workspace>/
```

Resolve `~` to the absolute home path. Derive `<workspace>` from the repository basename or, outside
a repository, the working-directory basename. Carry the absolute artifact path through every
handoff.

This location is agent-neutral because artifacts are plain Markdown, not harness state. Plan Mode,
vendor-native plans, native memory, source code, build output, and harness-managed state remain with
their owners.

The root is a directory, not a database. Suspec creates no registry, resolver, configuration,
lifecycle state, cleanup command, symlink, or background process.

## Conflicts

Never overwrite unrelated work. A collision is a decision, not permission to guess. Require a
distinct human-readable name; do not hash paths or create identity state.

If the root is unwritable, offer:

1. grant access and retry;
2. choose another agent-neutral user directory;
3. cancel.

Never fall back to vendor storage, the repository, or an OS temporary directory.

## Explicit handoffs

Writers resolve and report absolute paths. Dispatch prompts name every input path and next consumer.
When no consumer remains, the current consumer is final and presents close. The human owns the
disposition.

No tool lists, discovers, or resumes work. Lost the handoff? Find it manually under the known
workspace and pass the absolute path again.

## Close

Keep an artifact while a current or expected step needs it. The final consumer presents one choice for
the complete transient artifact and sidecar set:

- **Delete:** selection confirms removal; verify every selected path is absent. A failed path blocks
  close and stays reported.
- **Leave:** keep it at its current neutral paths.
- **Promote:** sanitize and move it into a project-owned durable destination, repair references, and
  validate.

Do not ask at creation or after each revision. Never choose for the human; silence is not Leave.
Promotion never creates Suspec storage or pushes implicitly.

## Durable value

| Live content      | Durable owner                                               |
| ----------------- | ----------------------------------------------------------- |
| intended behavior | code, tests, public contracts, or a project decision record |
| verification      | CI, tests, and PR discussion                                |
| review exceptions | the project action taken on them                            |
| durable lesson    | native memory, issue, test, or maintained documentation     |
| split task        | none; the spec remains the contract                         |
| change strategy   | landed code and project records                             |

Working files are not a second source of truth. A whole artifact enters a repository only through
explicit promotion into a project-owned channel. The adopter otherwise receives no Suspec directory,
configuration, scaffold, or gitignore entry.

During live work, code that contradicts intent triggers re-verification and a decision: update the
active spec when intent changed; fix code when implementation drifted. After close, current code and
durable project records govern.

Next: [specs](04-writing-specs.md). Previous: [workflow](02-basic-workflow.md).
