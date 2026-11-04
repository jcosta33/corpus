# Review

Finished work goes on trial against the ready spec. A non-implementer judges the result on the
project's native PR, CI, or conversation surface. Use [Revolver, Triple-check, or
Bulletproof](reference/review-stances.md) when breadth or depth earns them. Neither writes a Suspec
artifact.

The implementer cannot accept their own work and cannot render the verdict. Direct self-review may
find defects; it cannot close work that requires independence.

## What independent review does

Rerun every applicable `Verify with:` command against the judged state. Worker output remains a
claim. Treat empty or stale evidence as unverified.

Judge each in-scope requirement:

| Judgment      | Meaning                               |
| ------------- | ------------------------------------- |
| Supported     | evidence demonstrates the requirement |
| Unsupported   | evidence demonstrates failure         |
| Unverified    | evidence is missing or insufficient   |
| Blocked       | a dependency prevents assessment      |

Record the verdict where the project already records review: the PR, the issue, or the conversation.
Do not write `type: review`.

When a task executed a change-plan wave, judge preservation guarantees the same way. Preservation
failures cannot be waived through requirement excuses.

## Evidence

Keep short decisive output once. Move dominating raw output into an adjacent
[evidence receipt](reference/artifact-formats.md#evidence-receipt) and link its stable anchor beside a
verbatim excerpt.

## Human decision

After assessment, the human selects:

- **Accept:** every in-scope requirement is supported and no blocker remains.
- **Request changes:** unsupported rows or material findings remain.
- **Defer:** blocked work or unresolved material decisions remain.
- **Accept with named risk:** requirements are supported, but the owner deliberately accepts a
  remaining material finding.

Never offer plain Accept while a material finding remains. Before acceptance, fix and verify it or
record its named owner, accepted-risk decision, reason, and follow-up in the project's decision
channel.

The review remains live through findings and requested fixes. Close the complete transient artifact
set only after no downstream step needs it; see [artifact close](03-where-files-live.md#close).

Next: [findings and memory](09-saving-findings.md). Previous: [execution](07-running-agents.md).
