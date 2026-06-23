# Integrations

_Works today — plain markdown plus your agent; no Corpus tooling required._

Corpus is plain markdown any agent reads and writes. Integrating it takes two moves, neither
needing tooling: put the agent guides where your CLI looks, and get tracker items into your
workspace.

## Where the agent guides go

The starter kit ships its agent guides at `.agents/skills/`: the core loop (`write-spec`,
`implement-task`, `review-output`) plus the workspace authoring guides
([the index](reference/agent-guides.md)). Each is a folder with a `SKILL.md` inside. A `SKILL.md`
is ordinary markdown with a short description header. Agent CLIs auto-discover it; humans just
read it. The guides are **filesystem-based** — no install step, registry, or build. An agent
discovers one by reading the directory, so adding or editing a guide is a file change. (Whether a
running session picks it up mid-stream depends on the CLI.) Where to copy them:

| Agent CLI                          | Where the guides go                                                                                                                                    |
| ---------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Claude Code                        | nothing to do — the kit ships `.claude/skills` as a symlink to `.agents/skills/`                                                                       |
| Codex                              | `.codex/`, or reference the guides from `AGENTS.md` (Codex reads it natively)                                                                          |
| Cursor                             | `.cursor/rules/` — one guide → one `.mdc` rule file (manual conversion; scope with globs, not always-on; frontmatter schema in Cursor's rules docs)    |
| GitHub Copilot                     | reference the guides from `.github/copilot-instructions.md` (Copilot reads it natively): inline the core loop, point to `.agents/skills/` for the rest |
| Anything else (or no skill system) | they already sit in `.agents/skills/` as plain docs — point to them from `AGENTS.md`                                                                   |

This fails silently. If your CLI scans a fixed directory and the guides sit elsewhere, nothing
errors — they just never activate. Put them where your CLI looks, then test by asking the agent
to name the guides it can see.

The guides are agent-neutral. Nothing assumes a particular CLI, model, or vendor. Copy the same
folders into whichever tool your team uses next.

## Pulling work from your tracker

Work can start anywhere: a tracker (Jira, Linear, GitHub Issues, Notion), a doc, a conversation,
your own idea. When it starts in an external tool, **Pull** — the first step of the
[loop](02-basic-workflow.md) — captures that item into your workspace before anyone interprets it.

1. Open the ticket. Copy its content — title, description, acceptance notes, the lot.
2. Paste it **verbatim** into a new file in `intake/`, using the
   [intake template](https://github.com/jcosta33/corpus-starter-kit/blob/main/templates/intake.md). Record the source, URL, and capture date
   in the frontmatter. Don't edit the paste. The intake preserves what was actually asked; the
   spec is where interpretation happens.
3. When you write the spec, cite the intake file in its `sources` list.

The whole integration is a copy-paste. It buys ticket → spec provenance: when the upstream ticket
is later edited or deleted, your spec still anchors to what was asked. Intake is recommended
whenever work originates in an external tool, never required. The optional `corpus pull` captures a
tracker item into `intake/` for you; by hand, you or your agent copy-paste it.

## The boundary

**Corpus organizes the work; your agent does the coding.** Corpus never calls a model, edits a
file, or runs a command. It does not replace your tracker, your PRs, or your CI. The tracker stays
where work is requested. The PR stays how code merges. CI stays how tests run. Corpus is the
markdown layer between them: the spec the agent works from, the
[task packet](06-creating-tasks.md) that bounds the run, the
[review packet](08-reviewing-output.md) that shows a human where to look.

## Any agent — or no agent

Nothing in the loop requires an agent. A human developer can take a task packet, do the work,
paste real test output into the review packet, and [save a finding](09-saving-findings.md) at
Close — same files, same evidence rules. Teams mixing agents and humans on one board run one
process.

## Next

- [Where files live](03-where-files-live.md) — the workspace these integrations feed.
- [Adopting Corpus](ADOPTING.md) — one copy of the kit, including the guide wiring.
