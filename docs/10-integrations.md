# Integrations

*Works today — plain markdown plus your agent; no Swarm tooling required.*

Swarm is plain markdown that any agent can read and write. Integrating it means two small things:
putting the agent guides where your CLI actually looks, and getting tracker items into your
workspace. Neither requires tooling.

## Where the agent guides go

The starter kit ships three agent guides — `write-spec`, `implement-task`, `review-output` — each
a folder with a `SKILL.md` inside. A `SKILL.md` is ordinary markdown with a short description
header, so agent CLIs can auto-discover it and humans can just read it. Where to copy them:

| Agent CLI                          | Where the guides go                                                                      |
| ---------------------------------- | ---------------------------------------------------------------------------------------- |
| Claude Code                        | nothing to do — the kit ships `.claude/skills` as a symlink to `.agents/skills/`         |
| Codex                              | `.codex/`, or reference the guides from `AGENTS.md` (Codex reads it natively)            |
| Cursor                             | `.cursor/rules/` — one guide → one `.mdc` rule file (manual conversion; scope with globs rather than always-on; current frontmatter schema: Cursor's rules docs) |
| GitHub Copilot                     | reference the guides from `.github/copilot-instructions.md` (Copilot reads it natively); link or inline the three core guides |
| Anything else (or no skill system) | they already sit in `.agents/skills/` as plain docs — point to them from `AGENTS.md`     |

One caution: this fails silently. If your CLI scans a fixed directory and the guides sit somewhere
else, nothing errors — they simply never activate. Put them where your CLI actually looks, and
test by asking the agent to name the guides it can see.

The guides are agent-neutral: nothing in them assumes a particular CLI, model, or vendor. Copy the
same folders into whichever tool your team uses next.

## Pulling work from your tracker

Work usually starts in Jira, Linear, GitHub Issues, or Notion. **Pull** — the first step of the
[loop](02-basic-workflow.md) — captures that item into your workspace before anyone interprets it:

1. Open the ticket. Copy its content — title, description, acceptance notes, the lot.
2. Paste it **verbatim** into a new file in `intake/`, using the
   [intake template](https://github.com/jcosta33/swarm-starter-kit/blob/main/templates/intake.md). Record the source, URL, and capture date
   in the frontmatter. Don't edit the paste — the intake preserves what was actually asked; the
   spec is where interpretation happens.
3. When you write the spec, cite the intake file in its `sources` list.

That's the whole integration: a copy-paste. It buys you ticket → spec provenance — when the
upstream ticket is later edited or deleted, your spec still anchors to what was asked. Intake is
recommended whenever work originates in an external tool, never required. (Future CLI:
`swarm pull` will capture a tracker item into `intake/` for you — today you or your agent
copy-pastes it.)

## The boundary

**Swarm organizes the work; your agent does the coding.** Swarm never calls a model, edits a file,
or runs a command — and it does not replace your tracker, your PRs, or your CI. The tracker stays
where work is requested; the PR stays how code merges; CI stays how tests run. Swarm is the
markdown layer between them: the spec the agent works from, the
[task packet](06-creating-tasks.md) that bounds the run, and the
[review packet](08-reviewing-output.md) that shows a human where to look.

## Any agent — or no agent

Nothing in the loop requires an agent at all. A human developer can take a task packet, do the
work, paste real test output into the review packet, and
[save a finding](09-saving-findings.md) at Close — the same files, the same evidence rules. Teams
mixing agents and humans on the same board need no separate process.

## Next

- [Where files live](03-where-files-live.md) — the workspace these integrations feed.
- [Adopting Swarm](ADOPTING.md) — one copy of the kit, including the guide wiring.
