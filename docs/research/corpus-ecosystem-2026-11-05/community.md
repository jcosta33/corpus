# Community frameworks and skill catalogs vs Corpus (research notes, 2026-11-05)

Method: repo metadata and file trees via `gh api` (stars, `pushed_at`, releases, last commit per path); file bodies via raw.githubusercontent.com, read in full or grepped. Stars and dates are as of 2026-11-05. "Unverified" marks anything not read from the primary file.

Corpus baseline read: `skills/corpus-{spec,audit,research,campaign}/SKILL.md` (113 / 61 / 89 / 139 lines), `docs/method.md` (245 lines).

## Repository snapshot

| Repo | Stars | Last push | Latest release |
| --- | --- | --- | --- |
| obra/superpowers | 312,421 | 2026-11-03 | v7.0.2, 2026-11-03 |
| mattpocock/skills | 313,272 | 2026-11-04 | n/a |
| github/spec-kit | 147,274 | 2026-11-04 | v1.3.0, 2026-11-03 |
| Fission-AI/OpenSpec | 73,951 | 2026-11-04 | v1.16.0, 2026-10-30 |
| gsd-build/get-shit-done | 64,162 | 2026-05-31 | v1.43.0-rc2, 2026-05-17 |
| bmad-code-org/BMAD-METHOD | 55,002 | 2026-11-03 | v6.12.4, 2026-10-14 |
| wshobson/agents | 42,202 | 2026-11-02 | n/a |
| claude-task-master (eyaltoledano) | 28,300 | 2026-04-28 | 0.43.1, 2026-03-31 |
| humanlayer/humanlayer | 12,798 | 2026-11-02 | n/a |
| trailofbits/skills | 8,007 | 2026-11-04 | n/a |
| buildermethods/agent-os | 5,580 | 2026-10-07 | v3.0.0, 2026-01-20 |
| Pimzino/spec-workflow-mcp | 4,308 | 2026-07-03 | n/a |
| gotalab/cc-sdd | 3,753 | 2026-10-22 | v3.1.0, 2026-09-23 |
| traycerai/traycer | 1,653 | 2026-11-04 | n/a |
| tesslio/spec-driven-development-tile | 57 | 2026-03-30 | n/a |
| anthropics/skills | 187,412 | 2026-10-28 | n/a |
| ComposioHQ/awesome-claude-skills | 78,744 | 2026-09-18 | n/a |
| hesreallyhim/awesome-claude-code | 57,261 | 2026-11-04 | n/a |
| VoltAgent/awesome-agent-skills | 36,848 | 2026-11-02 | n/a |
| travisvn/awesome-claude-skills | 15,706 | 2026-04-28 | n/a |

## obra/superpowers (v7.0.2)

- `skills/writing-plans/SKILL.md` is 204 lines, last changed 2026-09-25. Header has Goal / Architecture / Tech Stack / Spec path / Global Constraints / **Review Focus**. Task = "smallest unit that carries its own test cycle and is worth a fresh reviewer's gate"; step = "one action with a checkable result" (write failing test, run it, implement, run, commit). https://github.com/obra/superpowers/blob/main/skills/writing-plans/SKILL.md. Bears on: corpus-spec. Corpus has no plan artifact and should not add one. The task-sizing sentence is the best granularity rule found; it fits Corpus Waves and Split rows.
- The same file adds a **Review Focus** section: "the five input classes or failure modes the spec implies but no task's tests exercise", each pinned by a test in its owning task. Bears on: corpus-spec. This is a sharp, cheap addition. Corpus requirements cover stated behavior only; nothing forces the author to list implied but unstated inputs.
- Same file, proportion rule: "A plan longer than the code it describes has written the code instead"; lines that decide nothing ("TBD", "handle edge cases") are the opposite failure. Bears on: corpus-spec Verify. It is a one-line proportion check Corpus could use.
- Same file, a **Task Interfaces block**, "Consumes / Produces: exact signatures", so a worker who sees only its own task learns its neighbours' names. Bears on: corpus-spec Split. Corpus says "Sequence interface-defining work first" but never makes a slice state the interface it produces or consumes.
- `skills/executing-plans/SKILL.md` (323 lines) and `skills/subagent-driven-development/SKILL.md` (339 lines) share a git-ignored ledger at `.superpowers/sdd/<plan>/progress.md`. Its first line is the plan's identity; `Task N: complete` lines are the resume points. "after compaction, trust the ledger and `git log` over your own recollection". https://github.com/obra/superpowers/blob/main/skills/executing-plans/SKILL.md. Bears on: corpus-campaign (Corpus puts progress in the project-native ledger, which is the stronger choice for multi-PR work) and corpus-spec `## Execution`.
- Same files use a ruling convention: `Ruling: <what you decided> — <why> — <what it costs if wrong>`. "Deviating from the plan without a ledgered ruling is a decision made in secret." There are exactly four stop conditions: irreversible, security-sensitive, external side effect, and "plan so broken that every path forward is a guess". Bears on: corpus-spec `## Execution` (scope drift). It is a compact format to adopt for drift records.
- `skills/brainstorming/SKILL.md` (316 lines) writes a design doc to `docs/superpowers/specs/YYYY-MM-DD-<topic>-design.md`. It has two sizes (short or full), always contains an **Approaches** part, and has a **builder check**: a fresh subagent reads the doc as a builder, and its questions are sorted into three piles, "Answered already / Minor (settle yourself, mark as your call) / Theirs". Bears on: corpus-spec Method step 2. This duplicates `drill`/`panel` in José's set, so do not import it. The "mark it in the document as your call" idea is useful: Corpus settles reversible conventions silently and has no list of agent-made calls for the human to scan.
- `skills/verification-before-completion/SKILL.md` (120 lines): "NO COMPLETION CLAIMS WITHOUT FRESH VERIFICATION EVIDENCE", plus a Claim / Requires / Not-sufficient table. Bears on: method.md Evidence. This duplicates `bulletproof` and the Corpus Evidence section; nothing to import.
- The SDD reviewer grades findings Critical / Important / Minor. One fix pass covers Critical and Important; Minor goes to the ledger; a round cap applies; "Silent discards are forbidden". `skills/subagent-driven-development/references/fix-loop.md` (4,314 bytes, read only via the SKILL.md references). Bears on: corpus-audit grading (Blocker/Major/Minor is equivalent). No change.
- Superpowers is long. Five core skills run 120–339 lines plus prompt files and scripts. Corpus is already 2–4x shorter per skill. Superpowers gets its correctness from scripts (`task-start`, `task-done`, `sdd-workspace`), not prose.

## BMAD Method (v6.12.4)

- The v6.12 shape has no `bmad-create-story`, `document-project` or `shard-doc` skill in `skills/`. Per the tree on 2026-11-05 it has `bmad-prd`, `bmad-architecture` (spine template), `bmad-agent-po` (tickets: ticket/bug/spike templates and tickets.toml, synced to GitHub/Jira/Linear/Notion/Trello/repo), `bmad-build`, `bmad-deep-recon` (research plus codebase), `bmad-project-context`, `bmad-shard-pro`, `bmad-retrospective`, `bmad-review`, `bmad-prfaq`, and `bmad-forge-idea`. https://github.com/bmad-code-org/BMAD-METHOD/tree/main/skills. The v6-alpha story-file shape I expected is gone or renamed; I did not search history to confirm when.
- `docs/plan/choose-a-planning-path.md` calls BMAD's tools "independent tools, not stages", and says "You don't need BMad for an obvious, low-risk edit". The intent bar is: "what should be true when the work is done, what must not change, and what is out of scope". Bears on: method.md Proportional rigor. The ecosystem has converged on Corpus's position.
- `skills/bmad-build/plan-template.md` (last bmad-build commit 2026-10-31) is the best single-change contract found. https://github.com/bmad-code-org/BMAD-METHOD/blob/main/skills/bmad-build/plan-template.md. Bears on: corpus-spec.
  - **Size target**: "Target: 900–1300 tokens… Above 1600 = high risk of context rot." Corpus has no size ceiling on a spec.
  - `<frozen-after-approval>` wraps Intent, Boundaries (Always/Never) and the **I/O & Edge-Case Matrix** (Scenario / Input-State / Expected / Error handling). Agent-owned append-only sections follow it: Code Map, Implementation Notes, Plan Change Log, Review Triage Log.
  - The template says "Delete this section… Do not write 'N/A' or 'None'". This matches Corpus "only when they carry information".
  - Frontmatter `baseline_revision` is "the commit the work starts from, set before any code change". Corpus spec has no frozen base commit; corpus-audit does.
- `skills/bmad-build/references/claims-check.md`: the reviewer reads the plan only after tracing code, "the claims cannot steer it retroactively". It treats the plan as "testimony, not evidence" and tries to falsify each claim. `deletion-check.md` asks whether removed code "carried behavior or a contract that the change neither re-established nor intentionally retired". Bears on: method.md Review and `revolver`. The ordering rule (trace first, read claims last) is worth one line in method.md Review. The deletion check sharpens corpus-spec Structural change.
- `skills/bmad-deep-recon/references/codebase.md` (codebase research): questions must "send researchers to every part of the code the ask depends on, none stating the intent… 'how does a job run end?', not 'where would cancellation go?'". It also says: "An ask from a ticket… also gets a question on how that code is tested". Prior docs are opened only when the ask names them, "since a document in context gets repeated whether or not it still holds". Bears on: corpus-audit. Corpus already says "Re-derive current state before reading a prior audit". The intent-blind question rule is new and strong.
- Same skill, `## Decisions found`: it proposes an ADR for each hard-to-reverse decision found in history that no ADR covers. It uses three tests (hard to reverse, surprising without context, a real trade-off) taken from mattpocock (below). Bears on: corpus-audit and the ADR question.
- `skills/bmad-deep-recon/references/verification.md`: claim outcomes are **verified / disputed / unverified / overturned**. A disputed claim reports both figures and is never averaged. Independent means "a different publisher with different underlying data", so syndication does not count. Confidence is "per-claim, never per-section". A red-team step gives a fresh skeptic subagent the conclusion with no evidence, and it hunts for the bear case; "Zero findings after a real search is itself reportable". Bears on: corpus-research. Corpus has the confidence ladder but not the four-state claim outcome or the never-average rule. The red-team step duplicates `revolver`/`panel`.
- `skills/bmad-agent-po/assets/bug-template.md` has sections Description / Reproduction / **Cause Hypothesis ("Never a prescribed fix")** / AC. AC #3 is "Or: no change is needed, with proof". Severity runs P0–P3. `spike-template.md` is a question with a timebox and four ACs (compared, prototyped, recorded, accepted). Bears on: missing artifact types. A spike is corpus-research. A bug report belongs in the issue tracker, not Corpus.
- `bmad-shard-pro`: shards are 3–14 KB; "Leave it as it is" is the first option; the 200-line first-read assumption. Bears on: nothing directly. Corpus artifacts are short-lived and small.

## OpenSpec (v1.16.0)

- `schemas/spec-driven/templates/{proposal,spec,design,tasks}.md` (last change 2026-09-29) are tiny (218–1,468 bytes). The proposal has Why / What Changes / Capabilities (New, Modified) / Impact. The spec has `### Requirement:` plus `#### Scenario:` WHEN/THEN. The design has Context / Goals-Non-goals / Decisions / Risks-Trade-offs. Tasks are numbered checkbox groups. https://github.com/Fission-AI/OpenSpec/tree/main/schemas/spec-driven/templates. Bears on: corpus-spec. The Corpus AC block is stricter and better: one strength word, a Verify-with command, and one obligation per block. OpenSpec scenarios carry no verification command.
- `docs/concepts.md`: delta specs use `## ADDED / MODIFIED / REMOVED Requirements`. MODIFIED replaces the whole requirement; archive merges the delta into `openspec/specs/` and moves the change folder to `changes/archive/YYYY-MM-DD-*`. A zero-delta change must set `skip_specs: true`, and "Do not invent a requirement just to satisfy validation". https://github.com/Fission-AI/OpenSpec/blob/main/docs/concepts.md. Bears on: corpus-spec. Corpus deliberately keeps no living spec baseline ("No repository-wide spec baseline survives close"), so full delta merging does not apply. A cheap import: in a structural-change spec, label each requirement as new, changed, removed or preserved. Corpus already marks preserved behavior with `When: always`. A REMOVED marker would force naming intentionally retired behavior, which pairs with the BMAD deletion check.

## github/spec-kit (v1.3.0; GitHub-owned OSS, included as the reference SDD toolkit)

- `templates/spec-template.md`: prioritized user stories (P1/P2…), each "INDEPENDENTLY TESTABLE… viable MVP", plus Given/When/Then; `FR-###` requirements with inline `[NEEDS CLARIFICATION: …]`; `SC-###` measurable success criteria; Assumptions. https://github.com/github/spec-kit/blob/main/templates/spec-template.md. Bears on: corpus-spec. The inline clarification marker inside a requirement is the same idea as Corpus `status: draft` with Open questions, but local to the requirement.
- `templates/commands/clarify.md`: a coverage taxonomy marked Clear / Partial / Missing (scope, data model, UX states, NFRs, integrations, edge cases, constraints, terminology, completion signals, placeholders). Hard cap of 5 questions, asked one at a time, and only questions that "materially impact architecture, data modeling, task decomposition, test design…". Bears on: corpus-spec Method step 2, and duplicates `drill`. Corpus could borrow a question cap.
- `templates/commands/analyze.md`: a read-only cross-artifact pass (Duplication / Ambiguity / Underspecification / Constitution / Coverage / Inconsistency) graded CRITICAL–LOW, reporting coverage % of requirements with at least one task. Bears on: corpus-spec check-only mode. Corpus Verify already covers the structural checks. The ambiguity pass (vague adjectives without numbers) is the missing bit.
- `templates/commands/converge.md` (2026-09-18) assesses the present code against spec/plan/tasks and appends unbuilt work as a new `## Phase N: Convergence`. It is "APPEND-ONLY, NEVER REWRITE" and leaves the file byte-for-byte unchanged when clean. Bears on: corpus-audit's exclusion of conformance review. The ecosystem treats spec-vs-code gap review as its own pass. Corpus leaves it to native review plus `revolver`, which is correct for a solo developer.
- The constitution (`templates/constitution-template.md`, 2,346 bytes) is treated as non-negotiable; conflicts are automatically CRITICAL. Bears on: missing artifact types. For José, repo `AGENTS.md` already fills this role. Do not add it.

## Tessl spec-driven-development tile (last commit 2026-03-30)

- `skills/{requirement-gathering,spec-writer,spec-verification,work-review}/SKILL.md` are each about 3 KB. `.spec.md` files have `targets:` globs and inline `[@test] path` links beside each requirement. `scripts/validate-specs.sh` and `check-spec-links.sh` verify the links. https://github.com/tesslio/spec-driven-development-tile. Bears on: corpus-spec. `Verify with:` is the same idea. The `targets:` glob in Tessl matches Corpus Split write paths and Affected areas.
- The tile ships `evals/<behaviour>/{task.md,criteria.json}`, including `trivial-change-exception`, `skip-spec-pushback` and `spec-drift-after-refactor`. Bears on: every Corpus skill. These are cheap behavioural evals for the "don't write a spec for a trivial fix" branch and for drift handling. Corpus `skills/` has design evidence, but I did not check whether it has executable evals.
- The Tessl registry and platform (tessl.io usage specs, `tesslio/cli`) are a vendor product. I did not fetch them (unverified); another agent covers first-party docs.

## cc-sdd (Kiro-style, v3.1.0)

- `tools/cc-sdd/templates/shared/settings/templates/specs/requirements.md` uses EARS acceptance criteria: "When [event] / If [trigger], then / While [precondition] / Where [feature included] / The [system] shall". https://github.com/gotalab/cc-sdd. Bears on: corpus-spec `When:`. EARS adds state-driven (`While`) and unwanted-behavior (`If…then`) forms. Corpus's `When:` line can express both if the skill says so in one clause. No format change is needed.
- `tasks.md` template: `(P)` parallel marker, `_Boundary:_` (components) only for P tasks, `_Depends:_` only for non-obvious dependencies, `_Requirements:_` IDs only, and "At least one detail item should state the observable completion condition". Bears on: corpus-spec Split. Same idea, lighter notation.
- The `kiro-validate-gap` skill compares approved requirements against existing code. Rules: "Information over Decisions", extend/new/hybrid options, and append to `research.md` rather than overwrite. Bears on: corpus-audit and corpus-research boundaries. Corpus keeps these separate, which is cleaner.

## Agent OS (buildermethods, v3.0.0)

- `CHANGELOG.md` [3.0] 2026-01-20 retired spec writing, task breakdown, and implementation orchestration: "Spec creation now defers to Plan Mode… Implementation/orchestration phases retired—frontier models handle this well on their own now". What remains is standards discover/inject plus `/shape-spec`, which saves plan.md / shape.md / standards.md / references.md / visuals/. https://github.com/buildermethods/agent-os/blob/main/CHANGELOG.md. Bears on: corpus-spec and corpus-campaign. This is the strongest community signal to keep Corpus off plan and task territory. Corpus already says it "does not replace plan mode".

## claude-task-master (0.43.1, last push 2026-04-28)

- PRD → `tasks.json` with dependencies and a complexity report (`.taskmaster/reports/task-complexity-report*.json`). I only read the tree, not the prompt bodies, so details are unverified. Bears on: corpus-campaign. The task graph belongs in the project tracker; Corpus's ledger pointer is the better choice. Activity has slowed: no push in six months.

## spec-workflow-mcp (Pimzino)

- `src/markdown/templates/tasks-template.md`: each task has File, Purpose, `_Leverage: <existing files>_`, `_Requirements: 1.1_`, and `_Prompt: Role | Task | Restrictions | Success_`. There is a dashboard approval workflow and "Implementation Logs" (README). https://github.com/Pimzino/spec-workflow-mcp. Bears on: corpus-campaign Dispatch. Corpus's dispatch list already covers Role/Task/Restrictions/Success. `_Leverage:_` (name the code to reuse) is a small, useful slot that pushes reuse onto the author.

## Traycer

- Epic → Phase breakdown → per-phase plan → verification against plan. PR #2354, merged 2026-10-05, turns the IDE extension page into a retirement notice in favor of Traycer Desktop. https://github.com/traycerai/traycer/pull/2354. Phase fields (`id`, `title`, `promptForAgent`, `referredFiles`) come only from an unofficial prompt copy at systemprompts.org, so they are unverified. Bears on: corpus-campaign (phases are equivalent to ledger items). Nothing to import.

## ExecPlan community skills

- `tiann/execplan-skill` (71 stars, last push 2025-12-20) wraps OpenAI's `PLANS.md` (`references/PLANS.md`, 14,638 bytes). Its rules: fully self-contained for a novice; it must be possible to "restart from _only_ the ExecPlan"; mandatory living sections Progress (timestamped checkboxes), Surprises & Discoveries (with evidence snippets), Decision Log, and Outcomes & Retrospective; prose-first; Idempotence and Recovery. https://github.com/tiann/execplan-skill. Bears on: corpus-campaign. ExecPlan copies mutable state into the plan; Corpus deliberately points at the ledger. For multi-PR work Corpus is right. **Surprises & Discoveries with evidence** is the one section Corpus lacks: its findings route to native memory only at close.
- Other ExecPlan skills found by code search have 0–3 stars (grp06/slop-janitor `execplan-create`/`execplan-improve`, jesse-black/execplan-skills, majiayu000/claude-skill-registry copies). Low signal; not read.

## mattpocock/skills

- `skills/engineering/research/SKILL.md` is **832 bytes**. It runs a background agent with a fresh context that uses primary sources only, follows each claim back to its owning source, writes one cited Markdown file, and saves it where the repo keeps notes. https://github.com/mattpocock/skills/blob/main/skills/engineering/research/SKILL.md. Bears on: corpus-research (89 lines). This is the floor for a research skill. Corpus's extra weight (source-competence table, confidence ladder, market rules) earns its keep only for non-API research such as market, customer or causal questions.
- `skills/engineering/domain-modeling/ADR-FORMAT.md`: an ADR can be one paragraph of context, decision and why. Status, Considered Options and Consequences are optional. Offer an ADR only when it is **hard to reverse AND surprising without context AND the result of a real trade-off**. https://github.com/mattpocock/skills/blob/main/skills/engineering/domain-modeling/ADR-FORMAT.md. Bears on: the ADR question. This is the best ADR rule found, and BMAD copied it.
- `skills/engineering/to-spec/SKILL.md` (3,043 bytes, 2026-08-19) synthesizes the conversation with no interview and **publishes the spec to the issue tracker**. Its seam rule: "Use the highest seam possible… the ideal number is one". Implementation decisions name modules, not file paths, because paths "may end up being outdated very quickly". Bears on: corpus-spec. The seam rule sharpens `Verify with:`. Publishing to the tracker is the alternative to Corpus's out-of-repo artifact.
- `skills/engineering/to-tickets/SKILL.md`: tracer-bullet vertical slices "sized to fit in a single fresh context window". Wide refactors are the exception, run as **expand → migrate batches → contract**, each step a ticket blocked by the previous. Bears on: corpus-spec Waves. Corpus states shims and a zero-call-site target but not the expand/migrate/contract order.
- `skills/engineering/retro/SKILL.md`: a session retro sorts improvements into navigation, automated checks ("a mechanical violation gets a deterministic check, full stop"), coding standards, AGENTS.md size, tool economy, no-ops, and information access. Bears on: missing postmortem/retro type. `promote` plus `debloat` already cover this for José.
- `.out-of-scope/*.md`: rejected scope is kept as files (e.g. `question-limits.md`, `new-skills.md`). Bears on: Corpus ADR practice. Not needed; Corpus ADRs already hold this.

## HumanLayer (RPI)

- `apps/riptide-pi-extension/skills/create-research-questions/SKILL.md` and `create-research/SKILL.md` (17 KB, last change 2026-10-22). Question writing is a separate phase from research. Questions must not ask "what should be built", so the researcher documents the present without the intent. Template rules: "There is no 'implementation' section - that is intentional"; each finding header "asserts what's true, not the topic"; a `Testing patterns` subsection per concept ("If no tests exist, say so explicitly"); and Code References note "when the list is exhaustive for a given area vs. when it covers key files". https://github.com/humanlayer/humanlayer/tree/main/apps/riptide-pi-extension/skills. Bears on: corpus-audit. Three sharpenings: assertion headers, an exhaustive-vs-sampled marker on every map list, and a per-area test note. Corpus already has "tests, and the behavior each one actually controls".

## get-shit-done (v1.43.0-rc2, last push 2026-05-31)

- `get-shit-done/templates/verification-report.md`: status is `passed | gaps_found | human_needed`. It has Observable Truths (VERIFIED / FAILED / UNCERTAIN), Required Artifacts, and **Key Link Verification**, which checks that the wiring between artifacts exists, to catch stubs (e.g. "onSubmit handler is console.log only"). https://github.com/gsd-build/get-shit-done/blob/main/get-shit-done/templates/verification-report.md. Bears on: method.md Review. Corpus's Supported / Unsupported / Unverified / Blocked is equivalent. The key-link check (artifact exists but is not wired) is a reviewer stance worth naming.
- `templates/codebase/concerns.md` includes "Fix approach" per concern. Bears on: corpus-audit. Corpus's "Prescribe nothing" is stricter and better for independence; GSD mixes audit with plan.
- `templates/research.md` (18 KB) has Locked Decisions / Claude's Discretion / Deferred; Don't Hand-Roll; Common Pitfalls; and Sources split into Primary (HIGH), Secondary (MEDIUM), Tertiary (LOW). Bears on: corpus-research. "Don't Hand-Roll" (what to reuse instead of building) is a decision-relevant section Corpus lacks for API and library research. The rest is heavier than Corpus.

## Trail of Bits skills

- `plugins/audit-context-building/skills/audit-context-building/SKILL.md` (3,991 bytes, 2026-09-16): "Build understanding, not verdicts"; no fixes or severities. For each function it records what must be true (with the line), **what it takes on faith and what establishes it**, its callees and their needs, and open questions. "Assumptions marked `nothing found`… the most useful thing to hand the hunting phase." "Where two records disagree, both are quoted rather than quietly reconciled." "The workflow is what enforces this, not this text." https://github.com/trailofbits/skills/tree/main/plugins/audit-context-building. Bears on: corpus-audit Map. This is the strongest sharpening found: add "assumptions with what enforces them, or `nothing found`" to the Map list. It is short and converts a static map into a risk feed without prescribing.
- Other relevant plugins (not read in full): `code-maturity-assessor`, `differential-review`, `spec-to-code-compliance`, `fp-check`, `patching-bugs/{reproduce-bug,validate-bug,prove-patch}`, `regression-hunt/*`. These are mostly security-domain. The patching-bugs skills are 2–7 KB each.

## Catalogs and marketplaces

- `anthropics/skills/skills/` holds document and creative skills plus `skill-creator`, `doc-coauthoring`, `mcp-builder` and `webapp-testing`. It has no audit, research or ADR skill (listing read 2026-11-05). This is first-party, so I did not analyze it further.
- `wshobson/agents`: `plugins/documentation-generation/skills/architecture-decision-records/SKILL.md` (5 KB) is a generic Context/Decision/Consequences template with a write/skip table. `plugins/incident-response/skills/postmortem-writing/SKILL.md` exists but was not read (unverified). Low craft compared with mattpocock's ADR rule.
- GitHub code search for SKILL.md files: `postmortem` (SethGammon/Citadel, Dimon94/skills, …), `ADR` (linuxfoundation/crowd.dev `.claude/skills/adr`, app-sre/qontract-reconcile, product-on-purpose/pm-skills `develop-adr`), and `deep research` (199-biotechnologies/claude-deep-research-skill, 1,208 stars, 108-line SKILL.md with quick/standard/deep/ultradeep modes). None beat the sources above. None read in full except the deep-research skill's outline.
- `skillsmp.com` returned HTTP 403 to WebFetch (unverified). The awesome lists (ComposioHQ, VoltAgent, travisvn, hesreallyhim) were checked for metadata only; their entries were not individually audited (unverified).

## Cross-cutting findings for Corpus

- **Duplication inside Corpus:** the Artifact, Output and Close blocks (19 lines, measured) repeat word for word in all four skills, 76 of 402 skill lines. The ecosystem factors shared rules out: BMAD uses `customize.toml` plus scripts, superpowers uses `references/`, and cc-sdd uses `rules/`. Standalone Agent Skills cannot share files across skill folders unless installed together. Moving the block to a `references/artifact.md` per skill would not cut tokens at load time, so leave it unless a shared install is guaranteed.
- **Corpus is already at the short end.** Tessl uses about 3 KB per skill, mattpocock 0.8–6 KB, Corpus 3–7 KB, and superpowers and BMAD 10–20 KB plus references. The community skills that stay correct while short push enforcement into scripts or evals. Tessl ships evals for "trivial change → no spec". Trail of Bits says "The workflow is what enforces this, not this text."
- **Where the ecosystem does better than Corpus:**
  - The BMAD frozen-after-approval intent block plus append-only change and triage logs is a cleaner plan-drift record than a single `## Execution`.
  - The BMAD and superpowers spec size ceiling.
  - Superpowers Review Focus.
  - Trail of Bits assumption-with-enforcer mapping.
  - The HumanLayer and BMAD intent-blind audit questions.
- **Where Corpus is ahead:**
  - The one-strength-word AC block with an executable `Verify with:`; most frameworks use Given/When/Then with no command.
  - The audit's no-prescription rule; GSD mixes fixes in.
  - The ledger-pointer campaign; ExecPlan, superpowers and task-master copy mutable state.
  - Named control strength (advisory, deterministic local, isolated authority), which no framework found states.
