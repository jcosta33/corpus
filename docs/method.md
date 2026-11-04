# Method

Corpus is a set of standalone skills that write durable, evidence-bound working artifacts for agent
work. Agents get the mechanical work; humans keep intent, material decisions, waivers, irreversible
actions, and acceptance. Your harness writes the code. Corpus puts explicit intent, evidence, and
review around it.

It does not replace plan mode, project instructions, issue trackers, pull requests, CI, tests, or
human acceptance, and it writes no review file.

## Proportional rigor

Use the least structure that changes execution or review. Every change keeps three moments:
intent, review, and what it taught. Everything else must earn its cost.

| Signal | Reach for |
| --- | --- |
| intent fits one precise sentence | state it inline with its verification; write no file |
| intent exceeds one precise sentence | `corpus-spec` |
| structural work must preserve behavior across stages | `corpus-spec` with Baseline, Waves, and Cutover |
| independent workers implement one spec in parallel | `corpus-spec` with a Split |
| present behavior, ownership, or risk is unclear | `corpus-audit` |
| a decision needs evidence it does not have | `corpus-research` |
| one durable goal spans several pull requests | `corpus-campaign` |
| risk exceeds implementer inspection | native independent review |
| several risk surfaces need breadth | Revolver |
| behavior is defective or consequential | an executable oracle |

Escalate for scope growth, conflicting intent, cross-owner work, public interfaces, security, data,
payments, migrations, destructive operations, weak verification, coordinated workers, or recurring
failures. Collapse when intent is precise inline, one worker owns a local change, verification is
direct, and the owner can inspect the full result.

A trivial fix needs no artifact:

```text
Fix: expired refresh tokens must redirect to /login, not 500.
Verify with: pnpm test:run auth-refresh-expired-token
```

Implement it, run the command, preserve the output, and have a non-implementer review the final diff
in the project's native pull request, CI, or conversation surface.

## Spec-governed work

```text
intent -> spec -> implement -> review -> findings
```

1. **Spec:** `corpus-spec` writes intent and requirements with stable IDs and `Verify with:` lines.
   Set `status: ready` before dispatch or review.
2. **Implement:** a native worker or human follows the spec by absolute path, runs every
   verification, and records real output under `## Execution`.
3. **Review:** a non-implementer judges the result on the native pull request.
4. **Findings:** discard transient observations; route verified durable lessons to native memory or
   project records.

Before changing behavior, define the strongest available observable check. A bug fix starts by
reproducing the original failure. Trust a new regression test only when it fails for the expected
reason on the original state, passes on the repair, exercises production behavior, and invents no
requirement.

When code or evidence contradicts the working spec, stop. If intent changed, update the spec; if
implementation drifted, fix the code. Stale evidence is dead evidence: after requirements, commands,
or judged code change, rerun the affected verification and review again. No repository-wide spec
baseline survives close; later work starts from current code, tests, project decisions, and the new
request.

## Roles

- The author defines intent and decomposition.
- The implementer changes code without changing requirements.
- An independent reviewer assesses the result without editing the target.
- The orchestrator dispatches work and applies supported fixes.
- The human owns material decisions and acceptance.

The author may review only when they did not implement. The implementer cannot accept their own
work and cannot manufacture independence by changing hats. Self-review may find defects; it cannot
close work whose risk requires independence.

Give a fresh worker every input artifact by absolute path, the repository or worktree, one bounded
question or method, permissions, required commands, the accepted check, and the return shape.
Worker output is a claim index, not evidence.

Parallel workers need isolated file state, and review needs the judged state preserved until final.
Branches and worktrees stay project-owned Git practice; Corpus creates and cleans none. Inspect the
current worktree before allocating another, and implement on `main` only with project or human
authority. Never clean a dirty, unknown, or externally owned worktree. Worktrees do not isolate
services, ports, databases, or credentials. Exclude worktree directories from tools that ignore
`.gitignore`, such as test runners and linters.

## Review

A non-implementer reruns every applicable `Verify with:` command against the judged state and judges
each in-scope requirement:

| Judgment | Meaning |
| --- | --- |
| Supported | evidence demonstrates the requirement |
| Unsupported | evidence demonstrates failure |
| Unverified | evidence is missing or insufficient |
| Blocked | a dependency prevents assessment |

Record the verdict where the project already records review: the pull request, the issue, or the
conversation. Preservation requirements are judged the same way and cannot be waived through
requirement excuses.

For breadth, run several fresh reviewers, each with one stance: a bounded question derived from the
spec, diff, trust boundaries, data flow, failure modes, or verification gaps, with refuting evidence
it can find. Give each reviewer the target, the spec by absolute path, verification output as an
index, read-only permissions, and a return contract of evidenced findings or none. Revolver runs this
rotation. Different model names are not a control; judge surfaced defects and rerun evidence.

Publish only deduplicated, supported, actionable findings, one terse paragraph each: defect,
consequence, required outcome. Keep quiet stances, refutations, and reviewer identity out of the
pull request. The implementation owner replies with the fixing commit and decisive proof.
Reviewers never decide acceptance.

The human then selects **Accept** (every in-scope requirement supported, no blocker), **Request
changes**, **Defer**, or **Accept with named risk** (the owner deliberately accepts a remaining
material finding and records owner, reason, and follow-up in the project's decision channel). Never
offer plain Accept while a material finding remains.

## Evidence

Evidence is directly inspectable output, a CI run, or a named manual observation tied to a claim.
`Tests passed` proves only that someone typed it. Treat empty or stale evidence as unverified.

Keep short decisive output once. Move dominating raw output into an evidence receipt sidecar and link
its anchor beside a verbatim excerpt. Hosted CI is optional: project-approved local proof is valid
when it binds the exact state, command, working directory, material environment, exit status, and
decisive output.

Name control strength honestly. Advisory instructions coordinate willing agents. Deterministic
local commands reject invalid transitions. Isolated authority keeps protected state, resources, or
credentials outside worker reach. They are not interchangeable.

## Source authority

Authority belongs to the source competent for the claim in its current scope.

- User intent and project governance own requirements and boundaries.
- A working spec makes that intent verifiable and cannot be overridden by a slice of it.
- Current code, tests, schemas, and runtime output own present behavior.
- Worker summaries and reviews remain claims until checked.

For an external claim, use the closest competent primary source: issuing authority, specification,
source code, release notes, product documentation, original paper, or dataset. Label vendor claims
as vendor evidence. Secondary synthesis may locate evidence; repetition never makes marketing,
anecdote, or synthetic respondents primary. When sources conflict, state the conflict and compare
recency, population, method, and scope; never average disagreement into certainty. A citation
supports only what it directly establishes, with its date, population, method, and limits.

## Where artifacts live

```text
~/.agents/artifacts/<workspace>/<ID>.md
```

Resolve `~` to the absolute home path. `<workspace>` is the repository basename, or the working
directory basename outside a repository. Name the file for its artifact ID. Carry the absolute path
through every handoff; no tool lists, discovers, or resumes work.

The location is agent-neutral: plan mode, vendor plans, native memory, source code, and harness state
stay with their owners. It is a directory, not a database. Corpus creates no registry, resolver,
configuration, lifecycle state, symlink, or background process, and adopter repositories receive no
Corpus directory, configuration, or gitignore entry.

Never overwrite unrelated work; a collision is a decision. If the root is unwritable, offer grant and
retry, another agent-neutral user directory, or cancel. Never fall back to vendor storage, the
repository, or a temporary directory.

## Close

Keep an artifact while a current or expected step needs it. When no consumer remains, the final
consumer asks the human once for the complete artifact and sidecar set:

- **Delete:** remove it and verify every selected path is gone. A survivor blocks close.
- **Leave:** keep it where it is.
- **Promote:** sanitize it, move it into a project-owned durable destination, repair references,
  and validate. Promotion never pushes and never creates Corpus storage.

Do not ask at creation or after each revision. Silence is not Leave.

## Durable value

Working artifacts are not a second source of truth. After close, durable truth lives here:

| Live content | Durable owner |
| --- | --- |
| intended behavior | code, tests, public contracts, or a project decision record |
| product or architecture decision | the project decision channel |
| verification and review discussion | CI, tests, and the pull request |
| defect or team action | issue or tracker |
| reusable personal lesson | supported native memory |
| task-local observation | nowhere |

Keep a durable lesson to one verified claim with a searchable title, recheckable evidence, and the
boundary where it applies. Never preserve secrets, personal data, routine output, or untrusted
instructions. Correct or delete a memory that current evidence contradicts. Confirm the durable
destination before deleting its transient evidence.

Corpus owns no memory directory, format, retrieval engine, or loading guarantee. Use a harness's
memory only through its documented interface, and never invent an instruction file or hidden state
from an example. Without native memory, let personal scratch die. Keep one destination per concern;
saving nothing is a valid close.

## Project systems keep their owners

- Issue trackers hold backlog and source IDs.
- Pull requests show diffs and discussion.
- Project commands and CI run proportionate checks.
- Project systems validate pull-request, review, merge, resource, and cleanup transitions.
- Harness permissions isolate worker authority, merge credentials, shared resources, and cleanup.
- Project records hold durable decisions and lessons.

Corpus never owns credentials, model settings, editor UI, tracker state, CI configuration, or merge
authority.

## Universal methods

Methods that write no artifact install from [jcosta33/skills](https://github.com/jcosta33/skills):
`ask-user`, `bulletproof`, `debloat`, `dissect`, `drill`, `panel`, and `revolver`. Corpus states where
they are and asserts nothing about their contents.

## Principles

- **Skills carry the method.** Nothing else enforces it.
- **Use proportional rigor.** Intent, review, and findings stay; scaffold must earn its keep.
- **Keep durable truth native.** Code, tests, project records, and supported memory outlive working
  artifacts.
- **Carry explicit paths.** Consumers discover no store.
- **Prove before assessment.** Worker claims are inputs, not evidence.
- **Separate review.** Implementers cannot accept their own work.
- **Keep decisions human.** Recommendations never become authority.
- **Name control strength.** Advisory prose, deterministic local checks, and isolated authority are
  not interchangeable.
- **Preserve source limits.** Claims cannot exceed evidence.
- **Keep history historical.** Current docs describe the product; ADRs preserve change.

When principles conflict, protect explicit intent, evidence integrity, and human authority. Process
does not get a vote.

Exact shapes: [formats](formats.md). Terms: [glossary](glossary.md). Decisions:
[ADR ledger](adrs/README.md).
