# First-party vendor research for Corpus skills

Fetched 2026-11-05. Scope: first-party docs, changelogs, and repositories only. Every bullet gives
the URL, the page date (or "undated, fetched 2026-11-05"), and the Corpus skill it bears on.
"Unverified" means the fact came only from a search-result summary or a secondary source, not from
the primary page.

Baseline measured locally: corpus-spec 113 lines / 5,112 bytes, description 438 chars;
corpus-campaign 139 lines / 6,663 bytes, description 321 chars; corpus-research 89 lines / 4,364 bytes,
description 316 chars; corpus-audit 61 lines / 2,795 bytes, description 326 chars. Each skill repeats
the same Artifact, Output, and Close blocks (about 15 lines).

## 1. Anthropic: Agent Skills spec and authoring guidance

- Open spec frontmatter: `name` is 1-64 chars, lowercase a-z, 0-9, and hyphens, no leading, trailing,
  or double hyphen, and must match the directory name. `description` is 1-1024 chars and "should
  describe both what the skill does and when to use it". Optional fields: `license`, `compatibility`
  (max 500), `metadata`, `allowed-tools` (experimental). https://agentskills.io/specification,
  undated, fetched 2026-11-05. Bears on: all four (frontmatter compliance; all four descriptions are
  well under 1024).
- Spec on progressive disclosure: metadata about 100 tokens; body "< 5000 tokens recommended"; "Keep
  your main SKILL.md under 500 lines"; keep file references "one level deep". The body has "no format
  restrictions". https://agentskills.io/specification, undated, fetched 2026-11-05. Bears on: all
  four. The largest Corpus skill is about 6.7 KB (roughly 1,700 tokens), so size limits are not
  binding. Cuts have to be justified by attention and correctness, not by caps.
- `anthropics/skills/spec/agent-skills-spec.md` now only points to agentskills.io.
  https://github.com/anthropics/skills (last push 2026-10-28). Bears on: all.
- Authoring best practices: "Default assumption: Claude is already very smart. Only add context
  Claude doesn't already have." Each paragraph has to justify its token cost.
  https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices, undated,
  fetched 2026-11-05. Bears on: all four. Cut explanations of things the model knows, such as git
  worktree mechanics in corpus-campaign and GRADE vocabulary in corpus-research.
- Best practices: descriptions must be third person, because "The description is injected into the
  system prompt". Name and description cannot contain XML tags, and the name cannot contain the
  words `anthropic` or `claude`. Same URL, undated. Bears on: all four. Corpus descriptions are
  imperative ("Write...", "Map..."), not first or second person, so they are acceptable.
- Best practices: "Set appropriate degrees of freedom". Use low freedom (exact scripts) for fragile
  operations and high freedom where context decides. Same URL. Bears on: corpus-spec (the exact
  three-item AC block is low freedom on purpose), corpus-campaign (the operating loop).
- Best practices: "Avoid offering too many options. Provide a default (with escape hatch)." Same URL.
  Bears on: corpus-research (the claim/evidence table), corpus-campaign (model-tier list).
- Best practices: "Build evaluations BEFORE writing extensive documentation". Create three scenarios,
  measure a no-skill baseline, then "Write minimal instructions". Same URL. Bears on: all four. No
  Corpus skill ships evals; `skills/README.md` should say whether design evidence substitutes for
  them.
- Best practices: the "plan-validate-execute" pattern uses an intermediate plan file plus a
  validation script. "Prefer scripts for deterministic operations." Same URL. Bears on: corpus-spec.
  Its `## Verify` checklist (frontmatter, unique AC IDs, three-item block, no TBD) is deterministic
  and could be a bundled script instead of prose.
- Best practices checklist: "No time-sensitive information"; "Consistent terminology throughout".
  Same URL. Bears on: all four.
- Claude Code skills doc: in the skill listing, the combined `description` + `when_to_use` "is
  truncated at 1,536 characters". "Put the key use case first." Body: "Keep SKILL.md under 500
  lines." https://code.claude.com/docs/en/skills, undated (references v2.1.309), fetched 2026-11-05.
  Bears on: all four (descriptions fit).
- Claude Code skills doc, compaction: "the most recent invocation of each skill is re-attached,
  keeping the first 5,000 tokens of each", with a "combined budget of 25,000 tokens" filled from the
  most recently invoked skill. "older skills can drop out entirely." Same URL. Bears on: all four.
  Load-bearing rules must sit early in each file. corpus-campaign's merge and close rules sit at the
  bottom; they currently fit in 5,000 tokens but would be the first to go if the skill grew.
- Claude Code skills doc: the frontmatter fields `disable-model-invocation`, `user-invocable`,
  `context: fork` + `agent`, `paths`, `allowed-tools`, `disallowed-tools`, `model`, `effort`, and
  `hooks` exist. Claude Code ignores `metadata`, `license`, and `compatibility`. `context: fork` runs
  the skill in a subagent that "doesn't see your conversation history" and "only makes sense for
  skills with explicit instructions". Same URL. Bears on: corpus-audit and corpus-research (both
  could run as `context: fork` with `agent: Explore` for read-only isolation), corpus-campaign (a
  candidate for `disable-model-invocation: true`, since it is a deliberate, side-effectful setup).
- Claude Code skills doc: "Seeing a skill trigger tells you Claude found it, not that it did what you
  intended." Measure triggering and output quality separately. Same URL. Bears on: all four.
- `skill-creator` SKILL.md: "currently Claude has a tendency to 'undertrigger' skills ... make the
  skill descriptions a little bit 'pushy'". It also says "If you find yourself writing ALWAYS or
  NEVER in all caps ... that's a yellow flag". Claude "only consults skills for tasks it can't easily
  handle on its own". https://github.com/anthropics/skills/blob/main/skills/skill-creator/SKILL.md
  (485 lines; last commit 2026-04-20). Bears on: all four descriptions (each ends with a "Do not use"
  clause that works against under-triggering) and the rule bodies (Corpus uses "Never" in several
  places).
- `anthropics/skills` catalog contains no spec, audit, research, or plan skill. The closest is
  `doc-coauthoring` (375 lines, last commit 2025-12-04), which covers "technical specs, decision
  docs", PRDs, design docs, and RFCs in three stages: Context Gathering, Refinement & Structure, and
  Reader Testing. https://github.com/anthropics/skills/tree/main/skills/doc-coauthoring. Bears on:
  corpus-spec.
- In `doc-coauthoring`, Reader Testing has the agent "Generate 5-10 questions that readers would
  realistically ask", then "invoke a sub-agent with just the document content and the question",
  then run a separate sub-agent check for "ambiguity, false assumptions, contradictions", and loop
  back to refinement. Same URL. Bears on: corpus-spec. Corpus has no fresh-reader test of the
  artifact itself, only a structural Verify.
- Other catalog sizes, for calibration: `mcp-builder` 252 lines, `discernment-nudge` 209 lines,
  `webapp-testing` 95 lines. https://github.com/anthropics/skills (fetched 2026-11-05). Bears on: all
  four. Anthropic's own instruction-only skills run 95-485 lines, so Corpus (61-139) is already at
  the short end.
- Engineering post "Equipping agents for the real world with Agent Skills": "When the SKILL.md file
  becomes unwieldy, split its content into separate files". Start with evaluation; "Monitor how
  Claude uses your skill in real scenarios". Open standard released Dec 18, 2025.
  https://www.anthropic.com/engineering/equipping-agents-for-the-real-world-with-agent-skills,
  published Oct 16, 2025 (updated Dec 18, 2025). Bears on: all four.

## 2. Anthropic: Claude Code native features that overlap Corpus

- Plan mode: Claude "reads files, runs shell commands to explore, and writes a plan, but does not edit
  your source". Enter with Shift+Tab, `/plan [description]`, or `--permission-mode plan`. Ctrl+G
  edits the plan. Approval options are auto mode, auto-accept, manual approval, or "No, keep
  planning". `showClearContextOnPlanAccept` adds an approve-and-clear option. Plan files live in
  `~/.claude/plans/` or `plansDirectory`. https://code.claude.com/docs/en/permission-modes, undated,
  fetched 2026-11-05. Bears on: corpus-spec. Native plan mode covers the plan; it produces no stable
  IDs, Verify lines, or ready/draft status. method.md already says Corpus does not replace plan mode.
- Ultraplan has been removed. The page says "Anthropic has removed the Ultraplan research preview"
  and points to plan mode or cloud sessions instead. https://code.claude.com/docs/en/ultraplan,
  undated, fetched 2026-11-05. Bears on: corpus-spec (do not reference it).
- Best practices, spec recipe: "Interview me until you could write the spec, then write it to
  SPEC.md." "Once SPEC.md exists, start a fresh session to build from it". SPEC.md is "the file
  you'll point the reviewer at later". https://code.claude.com/docs/en/best-practices, undated,
  fetched 2026-11-05. Bears on: corpus-spec. This is the native version of Corpus's core
  spec→implement→review loop, with no ID or format discipline.
- Best practices, review: "use a subagent to review the rate limiter diff against SPEC.md, check every
  requirement is implemented ... report gaps that affect correctness and skip style". "A reviewer
  that's asked to find problems will always find *something*. If you fix every finding, you end up
  with extra abstraction layers and tests for cases that can't happen." Same URL. Bears on:
  method.md review section and corpus-spec Close. This supports writing no review file and judging
  each AC.
- Best practices, unattended-run checklist: "Does it know what done looks like? A goal condition, a
  spec file, or a failing test"; "Can it check its own work?"; "What's it allowed to touch?"; "What
  stops it?"; "Where does the result go, and who signs off?" Same URL. Bears on: corpus-campaign. Its
  Completion contract, Authorities, and Stops already map onto these five questions.
- Best practices, "What you can stop doing": "Add IMPORTANT or ALL CAPS" ("piling on emphasis mostly
  makes Claude over-apply the rule"); "Delegate to a subagent for a better answer" ("doesn't make the
  answer any better. A fresh reviewer does help"); "Tell Claude to keep going, loop until done"
  ("more likely to cause over-work"); "Describe your architecture and file layout in CLAUDE.md"
  ("Claude reads the repo itself"). Same URL. Bears on: corpus-campaign (model-tier and dispatch
  prose), corpus-audit (the Map should record what is not obvious from code, not restate layout).
- Best practices: "If you keep adding emphasis to a CLAUDE.md line and Claude still misses it, that's
  a sign the line belongs in a hook." "`CLAUDE.md` is for guidelines, and Claude is allowed to decide
  a guideline doesn't apply." Same URL. Bears on: corpus-campaign (the advisory vs deterministic local
  vs isolated authority distinction matches vendor framing).
- `/goal`: "a model checks whether the condition holds" after each turn. The evaluator is the "small
  fast model" and "doesn't run commands or read files independently, so write the condition as
  something Claude's own output can demonstrate". A good condition has "One measurable end state",
  "A stated check", and "Constraints that matter". Max "4,000 characters". The goal survives
  `--resume`/`--continue` but is "session-scoped". "Implementing a design doc until all acceptance
  criteria hold" is a listed use. https://code.claude.com/docs/en/goal, undated, fetched 2026-11-05.
  Bears on: corpus-campaign (its completion contract could be written to fit a `/goal` condition) and
  corpus-spec (a ready spec plus `/goal every AC in <path> has a passing Verify with` is the native
  loop). `/goal` covers continuation within one session. It does not cover multi-PR lanes,
  authorities, or a cross-session ledger.
- `/batch <instruction>`: "decomposes the work into 5 to 30 independent units, and presents a plan.
  Once approved, spawns one background subagent per unit in an isolated worktree. Each subagent
  implements its unit, runs tests, and opens a PR". https://code.claude.com/docs/en/commands, undated,
  fetched 2026-11-05. Bears on: corpus-spec `## Split` and corpus-campaign Dispatch/Lanes. For
  mechanical fan-out, native `/batch` already does write-disjoint decomposition plus a
  worktree-per-unit PR.
- `/code-review` (alias `/review` since v2.1.223) runs as a background forked subagent "that never
  saw your conversation", with effort levels low..max, `--fix`, `--comment`, `--max-findings`. "It
  doesn't read REVIEW.md"; it follows CLAUDE.md. `/simplify` covers cleanup, `/verify` runs the app,
  `/security-review` reviews the branch diff. https://code.claude.com/docs/en/code-review-local and
  https://code.claude.com/docs/en/commands, undated, fetched 2026-11-05. Bears on: method.md "native
  independent review" (confirmed native), corpus-campaign Delivery review prose (could defer to these
  by name).
- `/deep-research <question>` is a bundled workflow that "Fans out web searches on a question across
  several angles, fetches and cross-checks the sources it finds, votes on each claim, and returns a
  cited report with claims that didn't survive cross-checking filtered out". Uncheckable claims are
  listed "as unverified instead of counting it as refuted". https://code.claude.com/docs/en/workflows,
  undated, fetched 2026-11-05. Bears on: corpus-research. Native tooling now does source gathering and
  cross-checking. Corpus's distinct value is decision framing, the source-competence match, confidence
  grading, and the no-decision rule.
- Dynamic workflows are listed for "codebase audits, large migrations, and cross-checked research".
  The example prompt: "audit every route handler ... and adversarially verify each finding before
  reporting it". Same URL. Bears on: corpus-audit (a native fan-out audit engine exists; Corpus audit
  remains the artifact shape and evidence rules).
- Memory: CLAUDE.md "target under 200 lines per CLAUDE.md file. Longer files consume more context and
  reduce adherence." Auto memory loads "first 200 lines or 25KB". Claude Code reads AGENTS.md only
  when no CLAUDE.md exists in the working directory or above it (default `claude-md-or-agents-md`;
  needs v2.1.277+). https://code.claude.com/docs/en/memory, undated, fetched 2026-11-05. Bears on:
  method.md "findings → native memory" routing, and the Corpus repo's own `CLAUDE.md`→AGENTS.md
  pointer.

## 3. Anthropic engineering: long-running agents and context

- "Effective harnesses for long-running agents": an initializer agent writes a feature list "over 200
  features", all failing, each with a `passes` field that coding agents may only flip. They chose
  JSON because the model is "less likely to inappropriately change or overwrite JSON files compared
  to Markdown files". `claude-progress.txt` + git history + `init.sh`; "only one feature at a time".
  Failure modes: one-shotting, premature "declares the job done", half-finished undocumented state,
  features marked complete without e2e testing.
  https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents, published
  Nov 26, 2025. Bears on: corpus-campaign (it keeps status in the project-native ledger, not in
  Markdown, which matches the JSON-over-Markdown finding) and corpus-spec `## Execution` (a
  free-form Markdown status the implementer edits is the format Anthropic found least robust).
- "Harness design for long-running application development": planner → generator → evaluator. The
  planner expands 1-4 sentences into a product spec that stays at product level, because "the errors
  in the spec would cascade into the downstream implementation". Sprint contract: generator proposes
  what it will build and how it will be verified, evaluator agrees "before any code is written". Agents
  "reliably skew positive when grading their own work". With Opus 4.6, sprint decomposition was
  removed and the evaluator moved to one pass at the end. The planner was kept because "without it
  the generator under-scoped". https://www.anthropic.com/engineering/harness-design-long-running-apps,
  published Mar 24, 2026. Bears on: corpus-spec (supports "Name a mechanism only when a public
  contract makes it observable"; Waves are worth keeping only for rollback and preservation, not as
  model scaffolding), method.md (implementer cannot accept own work).
- `anthropics/cwc-long-running-agents` (Code with Claude 2026 take-home): three primitives,
  "Default-FAIL contract", "Fresh-context evaluator" (no Write/Edit, returns `PASS`/`NEEDS_WORK`), and
  "Agent-maintained handoff" (`PROGRESS.md` with `## Done`, `## In progress`, `## Next`, `## Notes`).
  "This is the layer most sensitive to model capability ... re-evaluate how much of CLAUDE.md you
  still need after each model release." The README says `/goal` "gives you a generator/evaluator loop
  out of the box". https://github.com/anthropics/cwc-long-running-agents, created 2026-05-06, last
  push 2026-05-13 ("not maintained"). Bears on: corpus-campaign (re-simplify on model upgrades;
  native `/goal` first), corpus-spec (default-FAIL means every AC is Unverified until evidence is
  opened, which matches method.md's judgments).
- "Effective context engineering for AI agents": the system-prompt "right altitude" sits between
  "hardcoding complex, brittle logic" and "vague, high-level guidance". Aim for "the smallest possible
  set of high-signal tokens". Subagents return "a condensed, distilled summary ... (often 1,000-2,000
  tokens)". Structured note-taking such as NOTES.md or a to-do list.
  https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents, published
  Sep 29, 2025. Bears on: all four (length discipline), corpus-campaign (the worker return shape).

## 4. OpenAI Codex

- PLANS.md / ExecPlan cookbook: required sections are Purpose / Big Picture, Progress (checkboxes
  with timestamps), Surprises & Discoveries, Decision Log, Outcomes & Retrospective, Context and
  Orientation, Plan of Work, Concrete Steps, Validation and Acceptance, Idempotence and Recovery,
  Artifacts and Notes, Interfaces and Dependencies. The four living sections are "not optional". "it
  should always be possible to restart from _only_ the ExecPlan and no other work". "enable a complete
  novice to implement the feature end-to-end". "Write in plain prose"; checklists only in Progress.
  Failure modes: code that "compiles but does nothing meaningful", outsourcing key decisions to the
  reader, undefined jargon, "as defined previously". A similar file let Codex work "for more than
  seven hours from a single prompt". https://developers.openai.com/cookbook/articles/codex_exec_plans,
  page undated and marked archived, fetched 2026-11-05. Publish date Oct 7, 2025 and author Aaron
  Friel come only from secondary sources (unverified). Bears on: corpus-campaign (it is "restartable"
  but holds no decision log and pushes status to the ledger), corpus-spec (`## Execution` is
  post-hoc only, with no Surprises or Decision Log). Corpus lacks a living decision log.
- `friel-openai/plans.md` `execplans` skill (59 lines + 282-line `references/PLANS.md`): "Default to an
  ExecPlan for any moderately complex task instead of relying on the plan tool". When no location is
  given, "create it outside the repo, usually under `~/.codex/execplans/`, with a descriptive
  date-prefixed filename". "Do not repeat the full ExecPlan in commentary or final messages".
  https://github.com/friel-openai/plans.md, created 2026-04-08. It is an OpenAI-employee repo, so it is
  semi-first-party. The Codex skills page lists "Exec Plan" only as a personal skill. Bears on: all
  four. This is independent vendor precedent for Corpus's outside-repo artifact path and links-only
  output. It also shows the progressive-disclosure split (short SKILL.md plus a long reference), which
  Corpus does not use.
- Codex skills: `SKILL.md` must include `name` and `description`. Scan paths are `.agents/skills`
  (cwd up to repo root) and `$HOME/.agents/skills`; admin skills in `/etc/codex/skills`. The initial
  skill list uses "at most 2% of the context window, or 8,000 characters if the window size is
  unknown". Optional `agents/openai.yaml` with `allow_implicit_invocation: false`.
  https://learn.chatgpt.com/docs/build-skills (redirected from developers.openai.com/codex/skills),
  undated, fetched 2026-11-05. Bears on: all four (description budget is shared across every skill;
  shorter descriptions leave room).
- Codex best practices: plan "If the task is complex, ambiguous, or hard to describe well". Toggle
  `/plan` or Shift+Tab. "configure Codex to follow a PLANS.md or execution-plan template for
  longer-running or multi-step work". "A short, accurate AGENTS.md is more useful than a long file full
  of vague rules." Make a skill "if you keep reusing the same prompt or correcting the same workflow";
  start with "2 to 3 concrete use cases". `/review` modes: against base branch, uncommitted, a
  commit, custom instructions. Listed mistake: "Running live tasks on the same files without using Git
  worktrees". https://learn.chatgpt.com/guides/best-practices, undated, fetched 2026-11-05. Bears on:
  corpus-spec (native plan), corpus-campaign (worktrees), all (skill-scope rule).
- Codex Goals cookbook: "Goals are persistent objectives in Codex that keep a thread working toward a
  defined outcome across turns." Statuses: "active, paused, complete, or budget-limited". Template:
  "<desired end state> verified by <specific evidence> while preserving <constraints>". "A Goal should
  not be marked complete because the model believes it is probably done." "Do not use a Goal when the
  finish line is vague." "Do not use a Goal to hide uncertainty." "Reaching a budget limit is not the
  same as completing the objective."
  https://developers.openai.com/cookbook/examples/codex/using_goals_in_codex, undated, fetched
  2026-11-05. Bears on: corpus-campaign (the completion contract could adopt this one-line template
  verbatim).
- Codex long-running work: if the outcome is unclear, "begin with /plan so ChatGPT can interview you
  and turn the result into measurable success criteria, then start the refined goal with /goal".
  "Starting a goal doesn't grant ChatGPT broader access." "avoid letting two chats change the same
  files"; use Git worktrees. https://learn.chatgpt.com/docs/long-running-work.md, undated, fetched
  2026-11-05. Bears on: corpus-campaign, corpus-spec (vendor sequence plan → goal mirrors spec →
  implement).
- Goal objective limit is 4,000 chars ("put the details in a file and point the goal at that file").
  `features.goals` is stable and on by default. Unverified: from a search summary of
  developers.openai.com/codex/config-reference and slash-commands pages; the cookbook page I fetched
  did not state it. Bears on: corpus-campaign.
- "Run long horizon tasks with Codex" blog: four repo files. `Prompt.md` (goals, non-goals, hard
  constraints, deliverables, "Done when"), `Plan.md` (milestones "small enough to complete in one
  loop", acceptance criteria with validation commands, stop-and-fix rule, decision notes), `Implement.md`
  (runbook: plan is source of truth, validate after each milestone), `Documentation.md` (status,
  "Decisions made (and why)", "Known issues / follow-ups").
  https://developers.openai.com/blog/run-long-horizon-tasks-with-codex, undated (references early-2026
  events), fetched 2026-11-05. Bears on: corpus-spec (Prompt.md ≈ Intent/Non-goals/Requirements),
  corpus-campaign (Implement.md ≈ operating loop; Documentation.md is the decision/status log Corpus
  pushes to the ledger).
- Codex plan-mode TUI offers three exits: implement in the same context, start a new context carrying
  the plan, or keep planning. Unverified: source is GitHub issue openai/codex#38305, not official docs.
- Codex cloud tasks: not fetched. Unverified.

## 5. Gemini CLI, now Antigravity CLI

- Gemini CLI has been replaced. The Google Developers Blog says Antigravity CLI keeps "the most critical
  features of Gemini CLI: Agent Skills, Hooks, Subagents, and Extensions" (now plugins), with no "1:1
  feature parity right out of the gate". The Gemini CLI plan-mode page carries a banner that Gemini CLI
  "was replaced by Antigravity CLI on June 18th, 2026".
  https://developers.googleblog.com/an-important-update-transitioning-gemini-cli-to-antigravity-cli/,
  published May 19, 2026. Bears on: method/README harness lists (any "Gemini CLI" target is stale; the
  repo AGENTS.md mentions `GEMINI.md`).
- Gemini CLI plan mode is "a read-only environment for architecting robust solutions before
  implementation". It may write only `.md` files in the plans directory. The default is
  `~/.gemini/tmp/<project>/<session-id>/plans/`, "a managed temporary directory outside your project".
  Skills may be activated in plan mode ("use the <skill-name> skill to plan…"). No plan template is
  given. https://geminicli.com/docs/cli/plan-mode/, last updated Jun 18, 2026. Bears on: corpus-spec
  (skills are explicitly designed to shape native plan mode, so corpus-spec can be the template plan
  mode fills).
- The same page names Conductor as the reference "custom planning workflow for spec-driven
  development" built from tracks in a `conductor/` directory. Same URL. Bears on: corpus-spec,
  corpus-campaign.
- Conductor (`gemini-cli-extensions/conductor`) is now "A plugin for AI coding agents (Antigravity,
  Claude Code)". Skills: setup 241 lines, new-track 177, implement 139, review 222, status 71, revert
  124. new-track writes `spec.md` (Overview, Functional Requirements, Non-Functional Requirements,
  Acceptance Criteria, Out of Scope) and `plan.md` (Phases → Tasks → Sub-tasks, plus a "Phase
  Verification & Checkpoint" meta-task per phase), and registers the track in `conductor/tracks.md`.
  The spec is the "Source of Truth" capturing "the 'What' and the 'How'". Setup creates
  product/tech/workflow context and per-language code styleguides.
  https://github.com/gemini-cli-extensions/conductor, created 2025-12-17, last push 2026-09-01.
  Bears on: corpus-spec (Conductor puts What and How in one spec; Corpus keeps mechanism out),
  corpus-campaign (track registry ≈ ledger, though Conductor keeps it in-repo as Markdown).
- Antigravity `/plan` "facilitates structured planning, codebase exploration, and requirements
  discovery". It drafts an "Implementation Plan" artifact "with clear task breakdowns and verification
  checkpoints". `/grill-me` runs "Socratic design interviews". Other artifact types listed:
  Implementation plan, Walkthrough, Visual screenshots. https://antigravity.google/docs/plan/,
  undated, fetched 2026-11-05. Bears on: corpus-spec (a clarify/interview step exists natively).
- Antigravity `/goal` changes only stopping behavior, not permissions or review policies. Recommended:
  run `/plan` or `/grill-me` before `/goal`. Unverified: from a search summary of
  https://antigravity.google/docs/commands/goal/, not fetched directly. Bears on: corpus-campaign.

## 6. Cursor

- Plan Mode: Shift+Tab. "Agent asks clarifying questions". Plans "are saved by default in your home
  directory"; "Save to workspace" moves them into the repo. Use it for "complex features with multiple
  valid approaches", many-file work, unclear requirements, and architectural decisions. "For quick
  changes or tasks you've done many times before, jumping straight to Agent mode is fine." Rather than
  patching a drifting agent, revert, refine the plan, and rerun.
  https://cursor.com/docs/agent/planning, undated, fetched 2026-11-05. Bears on: corpus-spec (revert
  and re-plan matches method.md "When code or evidence contradicts the working spec, stop"; home-dir
  default matches Corpus's outside-repo path).
- Cursor skills: project `.agents/skills/` and `.cursor/skills/`, user `~/.agents/skills/` and
  `~/.cursor/skills/`. It "also loads skills from Claude and Codex directories". Frontmatter `name`
  (must match folder), `description`, `paths`, `disable-model-invocation`. Only `~/.cursor/skills/`
  syncs to Cloud Agents; project skills and `~/.agents/skills/` stay local.
  https://cursor.com/docs/context/skills, undated, fetched 2026-11-05. Bears on: all four
  (distribution; `~/.agents/skills` is now a cross-vendor path for Cursor, Codex, and Copilot).
- Cursor rules: "Keep rules under 500 lines." Avoid "Documenting common commands. Agent already knows
  tools like npm, git, and pytest" and "Adding instructions for rare edge cases". "Start simple and add
  a rule only after Agent repeats the same mistake." https://cursor.com/docs/context/rules, undated,
  fetched 2026-11-05. Bears on: all four (cut rare-edge-case clauses unless an observed failure
  justifies them; corpus-campaign's git and worktree mechanics are candidates).

## 7. Kiro (AWS)

- Specs have three phases and three files: `requirements.md` (or `bugfix.md`), `design.md`, and
  `tasks.md`. Feature specs come in Requirements-First and Design-First variants. "Quick Spec"
  auto-generates all three "without approval gates". "Analyze Requirements" checks for inconsistencies,
  ambiguities, and gaps before design (IDE only). Running all tasks "builds a dependency graph and
  groups independent tasks into waves", parallel within a wave and sequential across waves.
  https://kiro.dev/docs/specs/, updated Oct 15, 2026. Bears on: corpus-spec (`## Split` with `Starts
  after`/`May run with` is the same dependency-wave idea; Kiro computes it from tasks, Corpus asks the
  author to declare it).
- Requirements use EARS: "WHEN [condition/event] THE SYSTEM SHALL [expected behavior]". `design.md`
  "documents technical architecture, sequence diagrams, and implementation considerations".
  https://kiro.dev/docs/specs/feature-specs/, updated Aug 4, 2026. Bears on: corpus-spec (When/Then +
  one RFC-2119 word is EARS-equivalent; Kiro adds a separate design artifact that Corpus does not
  have).
- Bugfix spec, `bugfix.md`: "Current Behavior (Defect)" as "WHEN [condition] THEN the system [incorrect
  behavior]"; "Expected Behavior (Correct)" with "SHALL"; "Unchanged Behavior (Regression Prevention)"
  as "WHEN [condition] THEN the system SHALL CONTINUE TO [existing behavior]". Design records root cause,
  fix approach, and properties covering bug-exists, fix-works, and unchanged-still-works. Tasks include
  property-based tests. https://kiro.dev/docs/specs/bugfix-specs/, updated Aug 4, 2026. Bears on:
  corpus-spec. Corpus can express this with ACs (`When: always` for preserved behavior), but it has no
  named bugfix form. method.md's "A bug fix starts by reproducing the original failure" matches the
  bug-exists property.
- Best practices: "A quick fix in chat is fine for straightforward issues like typos." Use a Bugfix
  Spec for "critical code paths, repeated regressions, or unclear root causes". Feature Spec when
  "exploring unfamiliar territory", iterating, or needing approval checkpoints. "Generate spec" turns a
  vibe chat into a spec. "Store specs directly in your project repository alongside the code they
  describe." "Sync Files" marks completed tasks.
  https://kiro.dev/docs/specs/best-practices/, updated Sep 25, 2026. Bears on: corpus-spec
  (proportional-rigor table already matches the chat-vs-spec threshold; Kiro diverges on location,
  keeping specs in the repo where Corpus keeps them outside).
- Correctness: Kiro "extracts properties from EARS-formatted requirements" and runs PBT with
  shrinking. When a property fails, it offers to fix spec, implementation, or test. PBT is "not formal
  verification"; "a weak or wrong property can pass while the behavior is still incorrect". PBTs are
  optional by default. https://kiro.dev/docs/specs/correctness/, updated Aug 4, 2026. Bears on:
  corpus-spec Structural change ("golden, differential, or property check that fails on drift").
- Steering: `product.md`, `tech.md`, `structure.md`. Inclusion modes `always` (default), `fileMatch`,
  `manual`, `auto` (needs name + description). Kiro reads AGENTS.md from `~/.kiro/steering/` or the
  workspace root; "AGENTS.md files do not support inclusion modes and are always included".
  https://kiro.dev/docs/steering/, updated Oct 21, 2026. Bears on: none directly. Steering is project
  instructions, which Corpus defers to.
- Hooks: JSON in `.kiro/hooks/`, Command or Agent actions, triggers including `PostFileSave`, `Stop`,
  `PreToolUse`, `PostToolUse`. https://kiro.dev/docs/hooks/, updated Oct 21, 2026. Bears on:
  corpus-campaign ("deterministic local" authority can be a hook).

## 8. GitHub: Spec Kit and Copilot

- Spec Kit is active: v1.3.0 released 2026-11-03, last push 2026-11-04. Command templates: `specify`
  349 lines, `clarify` 291, `plan` 170, `tasks` 220, `analyze` 255, `checklist` 379, `implement` 222,
  `constitution` 179, and the newer `converge` 279 (first commit 2026-06-17).
  https://github.com/github/spec-kit/tree/main/templates. Bears on: corpus-spec. GitHub's single
  spec-phase commands are each longer than any Corpus skill.
- `spec-template.md`: User Scenarios & Testing (prioritized user stories P1/P2/P3, each independently
  testable, plus Edge Cases), Requirements (`FR-001: System MUST ...`, Key Entities), Success Criteria
  (`SC-001` measurable, "technology-agnostic"), Assumptions.
  https://github.com/github/spec-kit/blob/main/templates/spec-template.md, fetched 2026-11-05. Bears
  on: corpus-spec. Corpus has no priority tiers, no separate measurable outcomes, and no Assumptions
  section. FR-NNN with MUST matches AC-NNN.
- `/specify` "LIMIT: Maximum 3 [NEEDS CLARIFICATION] markers total". It self-validates against a
  quality checklist, "max 3 iterations". The spec template says to "Focus on WHAT users need and WHY"
  and avoid "HOW to implement (no tech stack, APIs, code structure)".
  https://github.com/github/spec-kit/blob/main/templates/commands/specify.md and
  https://github.com/github/spec-kit/blob/main/spec-driven.md, fetched 2026-11-05. Bears on:
  corpus-spec (a cap on open questions; Corpus's draft-until-resolved rule has no cap).
- `/clarify`: "Identify underspecified areas ... by asking up to 5 highly targeted clarification
  questions and encoding answers back into the spec". It runs a taxonomy coverage scan (Clear / Partial
  / Missing) and ends with a coverage summary (Resolved / Deferred / Clear / Outstanding).
  https://github.com/github/spec-kit/blob/main/templates/commands/clarify.md. Bears on: corpus-spec
  Method step 2 (Corpus asks "only about material behavior..." with no quota or coverage scan).
- `/plan` produces `plan.md` (Summary, Technical Context, Constitution Check, Project Structure,
  Complexity Tracking) plus `research.md` (Phase 0, "resolve all NEEDS CLARIFICATION"), `data-model.md`,
  `contracts/`, and `quickstart.md`. Phase -1 gates come from the constitution.
  https://github.com/github/spec-kit/blob/main/templates/commands/plan.md and plan-template.md. Bears
  on: corpus-spec (no design/plan artifact), corpus-research (Spec Kit's research.md is per-feature
  unknown resolution, narrower than corpus-research).
- `/tasks` writes `tasks.md` in the format `[ID] [P?] [Story] Description`, where `[P]` marks a
  parallel-safe task. Phases: Setup, Foundational (blocking), one phase per user story (MVP first),
  Polish. Includes Dependencies & Execution Order and Parallel Opportunities; test tasks are "OPTIONAL
  - only if tests requested". https://github.com/github/spec-kit/blob/main/templates/tasks-template.md.
  Bears on: corpus-spec `## Split` (`[P]` is a lighter-weight write-disjointness marker).
- `/analyze`: "non-destructive cross-artifact consistency and quality analysis across spec.md,
  plan.md, and tasks.md". "STRICTLY READ-ONLY". "Limit to 50 findings total". Categories: Duplication,
  Ambiguity, Underspecification, Constitution Alignment, Coverage Gaps, Inconsistency. Constitution
  conflicts are "automatically CRITICAL". Output table: ID, Category, Severity, Location(s), Summary,
  Recommendation. https://github.com/github/spec-kit/blob/main/templates/commands/analyze.md. Bears
  on: corpus-spec "check-only mode" (Corpus checks structure only, not semantic consistency or
  coverage).
- `/checklist` is "Unit Tests for English": it tests "whether the requirements are well-written,
  complete, unambiguous, and ready for implementation - NOT whether the implementation works". Items
  `CHK001...`. It is "a reviewer-owned requirements-quality review artifact"; "`[x]` does NOT mean
  implementation work is complete". https://github.com/github/spec-kit/blob/main/templates/commands/checklist.md
  and checklist-template.md. Bears on: corpus-spec Verify (the same idea, as an artifact Corpus does
  not ship).
- `/converge`: "Assess the current codebase against the feature's spec, plan, and tasks, then append
  any remaining unbuilt work as new tasks to tasks.md". Added 2026-06-17.
  https://github.com/github/spec-kit/blob/main/templates/commands/converge.md. Bears on: corpus-audit
  (Corpus explicitly excludes "conformance review against a spec" from audit) and method.md review.
  GitHub treats spec-vs-code gap finding as a first-class step.
- Constitution (`memory/constitution.md`): "the architectural DNA of the system". Example articles:
  Library-First, CLI Interface, Test-First ("confirmed to FAIL (Red phase)"), Simplicity ("Maximum 3
  projects"), Anti-Abstraction, Integration-First. Articles IV-VI are left to each project.
  https://github.com/github/spec-kit/blob/main/spec-driven.md, fetched 2026-11-05. Bears on: none
  directly. Corpus defers standing principles to project instructions; Spec Kit makes them a gate.
- VS Code Plan agent: it "researches your project without editing project files". The plan includes
  "implementation steps, relevant files, and verification steps" and "should identify the files and
  code patterns in your project, not just list generic tasks". Local harness stores the plan in session
  memory at `/memories/session/plan.md`, "not as a project file". Review checklist: Scope, Project fit,
  Explicit decisions and assumptions, Verification steps. "Use a separate planning step when the
  approach is uncertain or a change spans multiple parts of your project"; for "a small, well-defined
  edit", implement directly. `/research <topic>` (Insiders, preview) produces a Markdown report with
  citations. https://code.visualstudio.com/docs/agents/run/planning, updated 11/4/2026. Bears on:
  corpus-spec (same threshold; plan stored outside the repo), corpus-research (native cited research
  report).
- Visual Studio Plan agent saves plans to `.copilot/plans/` and offers "Implement plan". Unverified:
  from a search summary citing https://github.blog/changelog/2026-06-04-github-copilot-in-visual-studio-may-update/.
- Copilot custom agents: `.github/agents/*.agent.md`, `description` required, `tools`, `mcp-servers`,
  `model`, `target`. "The prompt can be a maximum of 30,000 characters."
  https://docs.github.com/en/copilot/how-tos/use-copilot-agents/coding-agent/create-custom-agents,
  undated, fetched 2026-11-05. Bears on: none directly.
- Copilot agent skills: project `.github/skills`, `.claude/skills`, or `.agents/skills`; personal
  `~/.copilot/skills` or `~/.agents/skills`. Surfaces: Copilot app, CLI, cloud agent, code review, and
  agent mode in VS Code, VS, and JetBrains. "Supported locations depend on the surface."
  https://docs.github.com/en/copilot/concepts/agents/about-agent-skills, undated, fetched 2026-11-05.
  Bears on: all four (distribution via `~/.agents/skills` reaches Copilot too).
- Copilot coding agent "can research a repository, plan changes, and implement them in the
  background", one branch and one PR per task, with session logs. No named spec artifact.
  https://docs.github.com/en/copilot/concepts/agents/coding-agent/about-coding-agent, undated,
  fetched 2026-11-05. Bears on: corpus-campaign (one PR per task matches "one reviewable concern per
  pull request").

## Not fetched or unverified

- Codex cloud tasks docs: not fetched.
- Antigravity `/goal` page: search summary only.
- Visual Studio Plan agent `.copilot/plans/`: search summary only.
- Codex goal 4,000-char limit and `features.goals` config: search summary only.
- PLANS.md cookbook publish date (Oct 7, 2025) and author: secondary sources only.
- Kiro "Plan mode": listed in Kiro navigation, content not fetched.
- Claude Code skills page beyond 100,000 chars (evaluation section tail): not read.
