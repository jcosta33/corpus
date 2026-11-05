# Corpus: what the 2025–2026 skill and spec ecosystem teaches the four artifact authors

Research record, 2026-11-05. The subject was `main` at `ae6d2e8`, with skills `corpus-spec` (113
lines), `corpus-audit` (61), `corpus-research` (89), and `corpus-campaign` (139). The top five
recommendations (§6) and the cleanups of §3 and §5 were implemented in
[ADR-0190](../adrs/0190-tracker-first-and-shorter-authors.md) and
[ADR-0191](../adrs/0191-author-refinements-and-adoption-residue.md). The before/after test is in
[the progression record](progression-2026-11-05/README.md).

Raw notes, one bullet per source with URL, date, and the skill it bears on:

- [first-party.md](corpus-ecosystem-2026-11-05/first-party.md): vendor docs
- [community.md](corpus-ecosystem-2026-11-05/community.md): framework source files
- [practice.md](corpus-ecosystem-2026-11-05/practice.md): practitioner reports and studies

## 0. Verification status first

- **I checked these myself**, against the live page, `gh api`, or the local filesystem:
  - every local-usage figure in §1;
  - the Claude Code `/goal` and skills-compaction pages;
  - Kiro bugfix specs;
  - SWE-Skills-Bench;
  - the Anthropic context-engineering post;
  - the Thoughtworks "agent instruction bloat" entry;
  - the Scott Logic numbers;
  - OpenSpec #2139 and Superpowers #2587;
  - repo star counts and push dates;
  - the Agent OS changelog quote.
- **Subagents fetched everything else.** Treat it as a claim index, with the source named in each
  row.
- **The subagents could not open these:**
  - Reddit (the fetch tool refused it);
  - the OpenAI harness-engineering post (HTTP 403);
  - skillsmp.com (HTTP 403);
  - the Tessl registry;
  - task-master prompt bodies;
  - Superpowers #2612, #2551, and #1152, the TiCoder and Tests-as-Prompt papers, and the Tencent
    false-positive study (search snippets only).
- **Corrections to subagent claims:**
  - "Gemini CLI was replaced by Antigravity CLI." The banner says only "Unpaid tier and Google One
    users: Gemini CLI was replaced by Antigravity CLI on June 18th, 2026"
    (geminicli.com/docs/cli/plan-mode, fetched 2026-11-05). It is not a full retirement.
  - "Compaction keeps only the first 5,000 tokens, so campaign's bottom rules are at risk." This is
    true of Claude Code (code.claude.com/docs/en/skills, undated). The largest Corpus skill is
    6.7 KB, about 1.7k tokens, so it survives whole. It does not bind Corpus.
- **Sibling skills changed during this session.**
  - At 00:56, `jcosta33/skills` replaced `ask-user` with `settle` and removed `promote` from
    `~/.agents/skills`.
  - Rows below that name a sibling skill use the installed state at the time of writing.
- **Empirical gaps** (no source found):
  - no study isolates acceptance-criteria quality against agent success;
  - no study compares native plan mode with a spec framework head to head;
  - no framework or study names a multi-PR campaign contract as an artifact type.

## 1. Local evidence that reframes the question

These facts come from José's own machine and outrank any ecosystem opinion.

| ID | Fact | Evidence |
| --- | --- | --- |
| L1 | Sourdaw files Corpus-shaped work as GitHub issues, not as files. | Title-prefix counts on `jcosta33/sourdaw`, all states: `spec(` 119, `task(` 147, `research(` 11, `audit(` 5 (`gh issue list`, 2026-11-05). Issue #4372 is a `spec(` issue whose body uses the exact `### AC-NNN` When/Then/Verify-with block. |
| L2 | Sourdaw's rules make the local file a draft that dies on filing. | Sourdaw `AGENTS.md` under "Artifacts": "The issue body is the original; delete any local copy after filing." and "Planning handed to future agents lives in GitHub issues, never a plan file." `.github/ISSUE_TEMPLATE/` has a form for each Corpus artifact type (spec, campaign, audit, research, plus the old inventory, task, and change_plan). |
| L3 | The form shapes have drifted from the skill shapes. | Sourdaw `spec.yml` fields are Subsystem, Priority, Intent, Requirements, Boundary, Sources; the skill uses Non-goals and Affected areas, and has no Boundary. `audit.yml` has Subsystem, Frozen SHA, Goal and exclusions, Findings, Unverified; the skill has Scope, Map, Risks, Unknowns. The most recent real audit (a local audit draft dated 2026-10-29) uses Scope and evidence, Findings, Limitations. |
| L4 | Real campaigns are short and follow the shape. | A local campaign draft dated 2026-10-26, with Sourdaw issue #4375 as its ledger, has frontmatter plus the five required sections plus Constraints, roughly 50 lines. Its Authorities bullets point at native commands (`lane:publish`, `review:repair`, `issue:reconcile`), not at rules restated from the skill. |
| L5 | Real research is technical, legal, or licensing decisions. None is market sizing. | The 11 `research(` titles, e.g. "choose the FFmpeg build, linking, and patent posture", "can the Anticipatory Music Transformer weights ship in a commercial DAW?", "select the capability-secure script runtime". The local research drafts are the same kind. |
| L6 | The sibling method skills run 9–23 lines; the Corpus skills run 61–139. | `wc -l ~/.agents/skills/*/SKILL.md`: bulletproof 9, debloat 12, drill 13, panel 10, settle 11, revolver 23. |
| L7 | Global policy already states the ask rule each Corpus skill repeats. | `~/.agents/AGENTS.md:44`: "ask with options and a recommendation". `settle` covers the same ground ("Recommendation first, three options…"). Each Corpus skill repeats "recommendation first, two or three real options, each with its cost". |

**Consequence.** "spec 0" in the earlier study map ([shape proposal](corpus-shape-2026-11-05.md) §3) undercounted. The spec format
is José's most-used Corpus format by far. It lives in the tracker, so `~/.agents/artifacts` sees
almost none of it. Recommendations below weigh the issue form as the real destination.

## 2. Ecosystem facts, by evidence class

### 2a. First-party (vendor documentation and vendor engineering posts)

| ID | Fact | Source, date |
| --- | --- | --- |
| F1 | The open spec caps `SKILL.md` at 500 lines and recommends a body under 5,000 tokens. Corpus is far inside both, so length cuts must rest on attention and correctness, not limits. | agentskills.io/specification (undated, fetched 2026-11-05) |
| F2 | Anthropic: "Claude is already very smart. Only add context Claude doesn't already have." Build evals and a no-skill baseline first, and use scripts for deterministic checks. | platform.claude.com …/agent-skills/best-practices (undated) |
| F3 | Anthropic removed "over 80% of Claude Code's system prompt for models like Claude Opus 5 and Claude Fable 5 with no measurable loss on our coding evaluations". Skills should be "lightweight guides" that "encode particular opinions… particular to you". "A spec may also be a detailed test suite". | Thariq Shihipar (Anthropic MTS), claude.dev blog, 2026-07-24 (checked) |
| F4 | Claude Code `/goal`: a small fast model judges a ≤4,000-character condition after every turn, from the transcript only; it "doesn't run commands or read files". Listed use: "Implementing a design doc until all acceptance criteria hold". Good conditions have "One measurable end state", "A stated check", and "Constraints that matter". | code.claude.com/docs/en/goal (undated, checked) |
| F5 | Codex goals template: "<desired end state> verified by <specific evidence> while preserving <constraints>", and "should not be marked complete because the model believes it is probably done". | OpenAI goals cookbook (undated; subagent-fetched) |
| F6 | Claude Code `/deep-research` "fetches and cross-checks the sources it finds, votes on each claim", filters failed claims, and lists unverifiable ones. | code.claude.com/docs/en/workflows (undated; subagent-fetched) |
| F7 | Claude Code `/batch` splits work into 5–30 independent units, one worktree-isolated subagent per unit, each opening a PR. | code.claude.com/docs/en/commands (undated; subagent-fetched) |
| F8 | Claude Code's native spec recipe: "Interview me until you could write the spec, then write it to SPEC.md", implement in a fresh session, and review against the spec, "skip style". | code.claude.com/docs/en/best-practices (undated; subagent-fetched) |
| F9 | Anthropic long-running harness: feature status kept as JSON because the model is "less likely to inappropriately change or overwrite JSON files compared to Markdown files"; agents declared victory early. | anthropic.com/engineering/effective-harnesses-for-long-running-agents, 2025-11-26 |
| F10 | Anthropic harness design: errors in an over-detailed planner spec "cascade into the downstream implementation"; agents "reliably skew positive when grading their own work"; sprint decomposition was dropped with Opus 4.6. | anthropic.com/engineering/harness-design-long-running-apps, 2026-03-24 |
| F11 | OpenAI ExecPlan requires living Progress, Surprises & Discoveries, Decision Log, and Outcomes & Retrospective sections, so work can restart "from only the ExecPlan". An OpenAI employee's `execplans` skill writes outside the repo to `~/.codex/execplans/`. Cursor, Gemini CLI, and VS Code all keep plans outside the repo by default. | developers.openai.com/cookbook/articles/codex_exec_plans (undated, page marked archived); github.com/friel-openai/plans.md (created 2026-04-08) |
| F12 | Kiro bugfix spec: Current Behavior ("WHEN … THEN the system [incorrect]"), Expected ("SHALL"), and Unchanged ("SHALL CONTINUE TO"). Its tests show the bug reproduces, the fix works, and the unchanged behavior holds. | kiro.dev/docs/specs/bugfix-specs, updated 2026-08-04 (checked) |
| F13 | Kiro best practice: "A quick fix in chat is fine for straightforward issues like typos". Kiro also offers a Quick Spec "without approval gates". | kiro.dev docs, 2026-09-25 and 2026-10-15 |
| F14 | Spec Kit v1.3.0 (2026-11-03) caps quality work: at most 3 `[NEEDS CLARIFICATION]` markers in `/specify` and at most 5 questions in `/clarify`. `/analyze` is a read-only consistency check capped at 50 findings. `/checklist` is "Unit Tests for English". `/converge` checks code against the spec. | github/spec-kit docs and templates (147k stars, pushed 2026-11-04) |
| F15 | Anthropic's `doc-coauthoring` skill reader-tests a document: a fresh subagent gets only the document and one question. | anthropics/skills, last commit 2025-12-04 |

### 2b. Community frameworks (source files read; maintainer practice, not controlled evidence)

| ID | Finding | Source, date |
| --- | --- | --- |
| C1 | Agent OS v3: "Implementation/orchestration phases retired—frontier models handle this well on their own now". | buildermethods/agent-os `CHANGELOG.md`, v3.0.0 2026-01-20 (5.6k stars; quote checked) |
| C2 | BMAD v6: its tools are "independent tools, not stages", and an obvious low-risk edit needs none of them. The build plan template targets 900–1,300 tokens ("Above 1600 = high risk of context rot"), records a `baseline_revision`, and freezes Intent, Always/Never boundaries, and an I/O and edge-case matrix once approved. | bmad-code-org/BMAD-METHOD v6.12.4, 2026-10-14; `skills/bmad-build/plan-template.md`, 2026-10-31 (55k stars) |
| C3 | BMAD reviewers read the plan last, treating it as "testimony, not evidence". A deletion check asks whether removed code carried a contract that was neither re-established nor deliberately retired. | `bmad-build/references/claims-check.md`, `deletion-check.md` |
| C4 | BMAD research gives each claim one of four outcomes: verified, disputed, unverified, or overturned. Disputed figures sit side by side and are never averaged. "Independent" means a different publisher with different data. Confidence is per claim. | `bmad-deep-recon/references/verification.md` |
| C5 | Superpowers plans: a "Review Focus" section names the input classes the spec implies but no test covers. Each task has an Interfaces block giving the exact signatures it consumes and produces. "A plan longer than the code it describes has written the code instead." Deviations are recorded as `Ruling: <what> — <why> — <cost if wrong>`. | obra/superpowers `skills/writing-plans`, `executing-plans`, v7.0.2 2026-11-03 (312k stars; checked) |
| C6 | Trail of Bits audit-context: for each function, record what the code takes on faith and what makes it true, or "nothing found"; quote disagreeing records side by side rather than reconcile them. | trailofbits/skills, 2026-09-16 (8k stars) |
| C7 | HumanLayer and BMAD codebase research hide the intended change from the researcher ("how does a job run end?", not "where would cancellation go?"). Finding headings state what is true; each reference list says whether it is exhaustive or a sample. | humanlayer `create-research*` skills, 2026-10-22; `bmad-deep-recon/references/codebase.md` |
| C8 | mattpocock `research` is 832 bytes: a fresh agent, primary sources only, one cited file. `to-spec`: test at "the highest seam possible… the ideal number is one". `to-tickets`: wide refactors run expand, migrate in batches, contract. `to-spec` publishes straight to the issue tracker. | mattpocock/skills, 2026-08-19 (313k stars) |
| C9 | OpenSpec delta specs mark ADDED, MODIFIED, and REMOVED requirements. | Fission-AI/OpenSpec v1.16.0 `docs/concepts.md` (74k stars) |
| C10 | Tessl ships behavioural evals beside each skill (`task.md` plus `criteria.json`), including "trivial change needs no spec". Its skills are about 3 KB. | tesslio/spec-driven-development-tile, 2026-03-30 |

**Where Corpus is ahead** (community comparison):

- Spec Kit, OpenSpec, cc-sdd, and BMAD use Given/When/Then with no command. Corpus requires one
  strength word and an executable `Verify with:`.
- ExecPlan, Superpowers, and task-master copy mutable state into the plan. Corpus points at a native
  ledger instead.
- No framework names control strength.

### 2c. Practitioner reports and studies (evidence class in each row)

| ID | Lesson | Source, date, class |
| --- | --- | --- |
| P1 | Spec Kit produced 2,577 lines of Markdown for 689 lines of code and took 3.5 hours of review. Iterative prompting took 8 minutes of agent time and 24 minutes of review and testing: "around ten times faster". The article's own per-step sums disagree with its totals. | Scott Logic (Eberhardt), 2025-11-26; first-hand, one feature (checked) |
| P2 | Kiro turned a small bug into 4 user stories and 16 acceptance criteria; the author would "rather review code than all these markdown files". "Show the current date" produced 8 files and 1,300 lines. Both authors report agents ignoring the spec. | martinfowler.com (Böckeler), 2025-10-15; marmelab, 2025-11-12; expert hands-on and opinion |
| P3 | Thoughtworks Radar Vol 35 (Nov 2026): "agent instruction bloat" is rated **Caution**: "convert any instructions you can into deterministic hooks or checks", then re-test the rest against each new model and delete what is no longer needed ("progression testing"). The same volume flags "AI-driven documentation sprawl" (Spec Kit and BMAD named). | thoughtworks.com/radar, updated 2026-11-04; expert panel (checked) |
| P4 | Skills barely moved coding pass rates: "from 76.6% to 76.9%"; "92 of 98 skills have no statistically significant effect"; harmful skills "anchor the agent on their own templates and override the task's explicit instructions" (down to −17 points). Counterpoint: SkillsBench found curated, focused skills added 16.6 pp. | SWE-Skills-Bench arXiv 2603.15401 v2, 2026-10-27, benchmark (checked); SkillsBench arXiv 2602.12670, 2026, benchmark |
| P5 | Context files give no general success gain and cost over 20% more inference; agents follow them literally. | Gloaguen et al. arXiv 2602.11988, 2026-02-12, controlled; Khatri arXiv 2607.27250, 2026-07, controlled (288 runs) |
| P6 | Instruction compliance falls with rule count, with a bias toward earlier rules; nested conditional constraints fare worst. | IFScale arXiv 2507.11538, 2025-07; AgentIF arXiv 2505.16944, 2025-05; benchmarks |
| P7 | In an 800-requirement agent-written spec, 81% of requirements carried more than one SHALL, and the share among new ones rose from 57% to 90% on the same model. "Agents copy the shape of the specs around them". | OpenSpec #2139, 2026-10-22; first-hand with measurements (checked) |
| P8 | Agents edit outside declared scope and tick phantom completions. Proposed fix: compare `git diff --name-only` with the declared paths. | OpenSpec #2201 (2026-11-04) and #1260 (2026-06-25); feature request and report |
| P9 | Per-task review passed every task, yet a broad review found 9 structural problems. A design-shape review before handoff caught 7 blockers. Plans ran 1,750–3,000+ lines for a 124-line spec. | Superpowers #2587, 2026-10-22 (checked); #512, 2026-02-20; first-hand |
| P10 | Research agents cite links that resolve (94%+ valid) but don't support the claim: factual accuracy 39–77%, falling about 42% as tool calls rose from 2 to 150. | "Cited but Not Verified" arXiv 2605.06635, 2026-05; DeepTRACE arXiv 2509.04499; benchmarks |
| P11 | LLM review false positives: 56.3% of 31,073 CodeRabbit comments were rejected; LLMs flag correct code as failing its spec, and asking for explanations made it worse. | arXiv 2607.03316, 2026-07, mining study; arXiv 2508.12358, 2025 |
| P12 | Tests in the prompt nearly double correctness for some models, but agents also delete or disable tests. Conformance suites are "the cheat code" for ports. | arXiv 2512.21028, 2025-12, controlled; Beck, 2025-06-25, first-hand; Willison conformance-suites tag, 2026 |
| P13 | The case against: native plan mode is a Markdown file plus a prompt; Steinberger writes specs only for tricky features; a full up-front spec assumes you learn nothing while building; METR speedup intervals cross zero. The case for: Thoughtworks makes up-front "done" specs a precondition for unattended overnight builds (Trial), and swarms need a durable ledger and a merge mechanism (Caution). | Ronacher 2025-12-17; steipete c. Oct 2025; Fowler fragment 2026-01-08; METR 2026-02-24; Thoughtworks Radar Nov 2026 and Apr 2026 |

**Net reading.**

- Every evidence class points the same way: short, opinionated skills whose rules a strong model
  would not otherwise follow, with anything checkable moved into a check (F2, F3, P3, P4, P6).
- Corpus's distinctive rules are the ones the evidence backs:
  - one obligation per requirement (P7);
  - an executable `Verify with:` (P12, C8);
  - status kept out of Markdown (F9);
  - a "none observed" result allowed (P11);
  - no self-acceptance (F10).
- Most of the cuttable text is generic delivery method that a strong model or the project already
  supplies (C1, F3, L4).

## 3. Per-skill recommendations

Each row gives the action, the evidence, and the line effect. Line effects are my estimates from
reading each skill, not measured drafts. A contract change travels as a unit, so each row also lists
the `docs/formats.md` or `docs/method.md` edit it needs.

### `corpus-spec` (113 lines; estimated 70–80 after)

| # | Action | Evidence | Effect |
| --- | --- | --- | --- |
| S1 | **Delete `## Split`.** Parallel work already has three owners: the campaign's Dispatch rule ("dependency-ready and write-disjoint"), Sourdaw `task(` issues (147), and native `/batch`. Keep one line in the method's signal table pointing there. If Split stays, add the Superpowers interface line and make write-path conformance a diff check. | L1, F7, C5, P8, P9 | −12 lines; formats.md Split paragraph, glossary row, and method table row go with it |
| S2 | **Replace `## Verify` with one sentence.** Five of its seven bullets restate `## Shape`. Anthropic says to move deterministic checks into scripts, and Thoughtworks says to turn rules into checks. Keep only what Shape does not say: "no `TBD`/`TODO`/`???` or blocking question at `ready`; every local source resolves." | F2, P3 | −8 lines |
| S3 | **Move `## Execution` out of the spec and into the PR or issue.** Real spec issues carry no Execution section (L1). Markdown status gets rewritten (F9). Method.md already makes the PR the review surface. Keep the two decisive rules (missing output is unverified; the implementer cannot accept) in method.md, where they already appear. | L1, F9 | −5 lines; formats.md `## Execution` paragraph and glossary row |
| S4 | **Name the tracker form as the primary destination.** When the project declares an issue form for specs, the skill drafts in the form's own fields and files it; the `~/.agents` file is a draft. This matches how José works (L2) and mattpocock's `to-spec` (C8). It also resolves the Boundary vs Non-goals drift (L3): adopt one name in both places. | L1–L3, C8 | ±0 to +2 lines; method.md "Where artifacts live" and Close |
| S5 | **Sharpen Structural change with three short clauses, and cut the generic prose around them:** (a) order Waves as expand, migrate in batches, contract; (b) every removed behavior is named as retired or re-established (BMAD deletion check, OpenSpec REMOVED); (c) prefer differential or conformance checks, and no wave may weaken or delete a test to go green. Drop "Map an unfamiliar area before planning" (the audit's job) and the old-call-site census sentence, which (a) subsumes. | C3, C8, C9, P12, F10 | ±0 lines |
| S6 | **Add one bugfix line instead of a bugfix type:** a defect fix is one requirement for the new behavior plus `When: always` requirements for the behavior that must stay unchanged, verified by a check that fails on the original state. Kiro's three-part form maps one-to-one onto the AC block. | F12, method.md "A bug fix starts by reproducing" | +2 lines |
| S7 | **Cut the ask clause from Method step 2.** `settle` and global policy own how to ask (L7). Keep only the scope of what to ask about (material behavior, public contracts, security, cost, irreversible choices). If a cap is wanted, borrow Spec Kit's: at most five questions. | L7, F14 | −1 line |
| S8 | **Make the inline path the loud first step, not step 3.** Measured review cost (P1, P2) and Kiro's own threshold (F13) say most changes need no file. | P1, P2, F13 | ±0 lines |

**Keep as is:** the AC block, one strength word, "Split obligations that fail independently"
(P7 is direct evidence), and "Name a mechanism only when a public contract makes it observable"
(F10: over-specified planners cascade errors).

**Do not import:** Spec Kit `/clarify`, `/analyze`, or `/checklist`; a fresh-reader test (F15); or
BMAD's frozen I/O matrix. The first three duplicate `drill` and `settle`; the reader test duplicates
`revolver`, which reviews "plans, or documents". BMAD's 1,600-token ceiling is worth stating only if
the owner sees specs grow (P7). The AC format makes requirement growth visible already.

### `corpus-audit` (61 lines; estimated 55–60 after)

| # | Action | Evidence | Effect |
| --- | --- | --- | --- |
| A1 | **Rename the sections to what real audits use:** `## Scope` (frozen state, goal, exclusions), `## Findings`, `## Unverified`. Make `## Map` optional, for the pre-change map case. Real audits are finding-led (L3), and Sourdaw's form has no Map. | L3 | ±0 lines; formats.md Audit paragraph |
| A2 | **Add one Map line:** "for each component, what it takes on faith and what enforces it, or `nothing found`." This turns the map into a risk feed without prescribing anything. | C6 | +1 line |
| A3 | **Add one clause to the negative-claim rule:** every reference list says whether it is exhaustive or a sample. | C7 | +0 lines (append to existing sentence) |
| A4 | **Add one line for pre-change maps:** phrase questions without the intended change, so the map is not steered toward it. | C7 | +1 line |
| A5 | **Cut the ask clause in Method 1** (owned by `settle`) and the five-bullet Map checklist. A strong model maps modules, callers, data, and tests unprompted (F2, F3). Keep the evidence rules, which models do not follow by default (P11). | L7, F2, F3, P11 | −6 lines |

**Keep:** "None observed in scope", the run requirement for dynamic behavior, "no prescriptions"
(GSD's concerns template prescribes fixes, and Corpus is stricter; C-notes), and the
Blocker/Major/Minor grading. P11 shows these rules are the ones LLM reviewers break.

**Keep the conformance exclusion.** Spec Kit `/converge` and Kiro sync treat a spec-vs-code check as
first-class (F14). Corpus routes that check to native review and `revolver`, so admitting it here
would duplicate them.

### `corpus-research` (89 lines; estimated 60–65 after)

| # | Action | Evidence | Effect |
| --- | --- | --- | --- |
| R1 | **Cut the market, customer, and competitor paragraph** (TAM, SAM, SOM; synthetic respondents; `most`/`common` denominators), and the four market rows of `skills/sources.md`. None of José's research is market work (L5). YAGNI; re-add if it appears. | L5 | −7 lines in the skill; sources.md Research Method trims |
| R2 | **Replace the upgrade/downgrade sentence and the four-level confidence ladder with per-claim outcomes:** verified, disputed (both figures shown, never averaged), unverified, overturned; plus a confidence word. It is shorter, maps to what reviewers check, and method.md already says "never average disagreement into certainty". | C4, method.md | −4 lines |
| R3 | **Add a passage-level support check:** each load-bearing finding quotes the passage that supports it. Resolving links is not support. Bound search breadth rather than stacking sources. | P10 | +1 line |
| R4 | **Delegate gathering to native deep research when present.** Corpus-research keeps what `/deep-research` lacks: locking the decision and the reversing evidence, matching each claim to a competent source, and leaving the decision with the human. | F6, C8 | +1 line, enables cutting generic search prose |
| R5 | **Trim the source-competence table to the rows José's questions hit:** standard or contract, API support, product behavior, comparative performance, and licensing or legal (a new row; see L5's patent and weights-licensing questions). Drop prevalence, actor intent, and user experience unless they are used. | L5 | −2 lines |
| R6 | **Cut the ask clause** (owned by `settle`). | L7 | −1 line |

### `corpus-campaign` (139 lines; estimated 60–70 after)

| # | Action | Evidence | Effect |
| --- | --- | --- | --- |
| K1 | **Collapse `### Lanes`, `### Dispatch`, and `### Delivery`** (about 55 lines) into one rule: each operation the campaign uses names its owner, strength, mechanism, and failure behavior under Authorities, and project rules govern how it runs. The real campaign does exactly this by pointing at native commands (L4). These sections teach generic delivery method that Sourdaw's `AGENTS.md` and global policy already own. Agent OS retired the same layer (C1), and Anthropic cut generic prompt text with no loss (F3). Keep the three rules a strong model would not infer: never seize an active or unknown lane; the orchestrator never hijacks another owner's branch; the merge binds to the expected head, and drift resets checks and review. | L4, C1, F3, P3 | −45 to −50 lines |
| K2 | **Delete the model-tier paragraph.** It is harness and owner policy (global `CLAUDE.md` already governs subagent models), and it rots with each model generation (P3, "progression testing"). | P3, global CLAUDE.md | −7 lines |
| K3 | **Write the completion contract in the Codex goal form:** "end state, verified by evidence, while preserving constraints". It should be demonstrable from the session's own output, so a pickup can hand it to native `/goal` (≤4,000 characters). Then the operating loop's "repeat until" clause rides a native evaluator instead of prose. | F4, F5 | ±0 lines |
| K4 | **Add one line to the operating loop:** review the whole design before dispatching parallel streams, and run one broad review after merges. Per-slice review missed 9 structural problems in P9. | P9 | +1 line |
| K5 | **Cut the ask clause** (owned by `settle`). | L7 | −1 line |

**Keep:**

- The ledger pointer and the ban on checkboxes, counts, SHAs, and snapshots. F9 and P13 (swarms need
  a durable ledger) support it. ExecPlan and Superpowers do the opposite and pay for it.
- The authority strengths. No framework has them.
- `status: ready` gating.

**Do not import** ExecPlan's living Progress and Decision Log sections (F11). The native ledger is
their owner, and Markdown status rots (F9).

### Shared blocks (all four)

- The Artifact, Output, and Close blocks are 19 identical lines in each skill, 76 of 402 skill lines
  (community subagent, measured).
- The standalone rule forbids factoring them out. Two cuts still apply:
  - Make Delete the stated default in Close, for drafts promoted into a project record. P3's
    documentation-sprawl warning and L2's "delete any local copy after filing" both support it.
  - Shorten the unwritable-directory fallback paragraph to one sentence.

## 4. Missing artifact types, and types that should not exist

### Missing: none worth adding

| Ecosystem type | Who ships it | Verdict for Corpus |
| --- | --- | --- |
| Design doc / technical plan | Kiro, Spec Kit, OpenSpec, Superpowers, Antigravity | Skip. Native plan mode and `panel` own it. Agent OS retired its equivalent (C1). |
| Task list / waves | Kiro, Spec Kit, BMAD, Superpowers | Skip. Sourdaw tracks tasks as issues (L1); `/batch` handles mechanical fan-out (F7). |
| Living execution log | ExecPlan, Anthropic harness | Skip. The ledger and the PR own it (F9). |
| Constitution / steering | Spec Kit, Kiro, Agent OS, BMAD | Skip. The repository `AGENTS.md` owns it, and P5 says such files rarely help. |
| Clarify / analyze / checklist | Spec Kit, cc-sdd | Skip. `drill` and `settle` own it; borrow only the five-question cap (S7). |
| Spec-vs-code converge | Spec Kit, Kiro, Tessl | Skip. Native review and `revolver` own it. |
| Bugfix spec | Kiro | Fold into spec as one line (S6). |
| ADR | mattpocock, BMAD, wshobson | Skip. Sourdaw owns `.agents/decisions/`. If a rule is wanted where promotion happens, use mattpocock's three tests: hard to reverse, surprising without context, the product of a real trade-off. |
| Postmortem / retro | BMAD, mattpocock, wshobson (not read) | Skip. A durable lesson goes to native memory or a project record (method.md "Durable value"). |
| PRD / story | BMAD, task-master | Skip. Spec Intent and the tracker cover it. |

None of the first-party tools surveyed ships a postmortem, ADR, or bug-report type (first-party
subagent).

### Should not exist (or should shrink)

1. **`corpus-spec`'s Split and Execution sections** (S1, S3). Three other owners already exist for
   each.
2. **`corpus-campaign`'s Lanes, Dispatch, Delivery, and model-tier content** (K1, K2). It is generic
   orchestration method that the project and the harness own.
3. **`corpus-research`'s market-research apparatus** (R1). It has no use on record.
4. **Every skill should stay.** No skill should be deleted outright:
   - **spec:** the AC format is José's most-used Corpus format (L1). No ecosystem format pairs one
     strength word with an executable check.
   - **audit:** native tools offer no evidence-bound, prescription-free map.
   - **research:** `/deep-research` gathers sources, but decision framing and source competence are
     not native (F6).
   - **campaign:** no framework or vendor ships a multi-PR contract with a ledger pointer and
     authority strengths (P13).
5. **Adversarial check, against keeping them.**
   - P4 says most skills do nothing measurable, and template-heavy ones hurt by overriding the task.
     The answer is not deletion. It is: (a) the cuts above; (b) one stated line that the task's
     explicit instructions and the project's forms outrank the skill's shape (S4 does this for
     spec); (c) progression-test each skill against the current model, as Tessl does (C10) and
     Thoughtworks recommends (P3).
   - The edit contract keeps skills Markdown-only, so evals belong in `scripts/` or beside
     `skills/`, not in a skill payload.

## 5. Removable versioning, upgrade, and adoption material

José is the only consumer, so these carry no load:

- `README.md:19`: "Re-running `add` does not prune. Remove any earlier `sus-*` skills by name before
  adding." The cutover already happened: the installer lock held only `corpus-*` on 2026-11-05.
- `skills/README.md:15-19`: the `sus-*` removal block.
- `skills/README.md:7-13`: three install variants (`-a codex`, `-a claude-code`, `--skill`). One
  line, or none, serves the owner.
- `README.md` "Fit" section and the "Use Corpus when…" pitch. This is adoption copy; the method's
  signal table already says when to reach for each skill.
- `docs/method.md:166`: "adopter repositories receive no Corpus directory…". Say "repositories".
- **Leave alone:** ADR-0015 (versioning scheme) and ADR-0041 (two-axis versioning) are sealed
  history. Per `AGENTS.md`, ADR bodies are never rewritten. No current doc, script, or workflow
  carries version, release, or semver logic: `grep -niE 'version|release|tag'` over
  `.github/workflows/*` and `scripts/*.sh` returned nothing.

## 6. Top five recommendations

1. **Make the project's tracker form the spec's primary destination** (S4, and Close defaulting to
   Delete after filing). Evidence: L1–L3. 119 Sourdaw spec issues already use the AC block, and the
   local copy is deleted by project rule. Also reconcile the form/skill drift (Boundary vs Non-goals;
   Findings/Unverified vs Map/Risks/Unknowns), so the skill and the form are one shape.
2. **Collapse `corpus-campaign`'s Lanes, Dispatch, Delivery, and model-tier sections** into the
   Authorities rule, plus three non-obvious bans (K1, K2). About −55 lines. Evidence: L4, C1, F3, P3.
3. **Delete `corpus-spec`'s Split and Execution sections, and shrink Verify to one sentence** (S1–S3).
   About −25 lines. Evidence: L1, F7, F9, F2, P3, P8.
4. **Cut market research from `corpus-research` and switch to per-claim outcomes with a
   passage-level support check** (R1–R3). About −10 lines, and the change addresses the measured
   failure of research agents. Evidence: L5, C4, P10.
5. **Sharpen without growth:**
   - drop the ask clause in all four (owned by `settle`; L7);
   - add expand/migrate/contract, retired-behavior, and never-weaken-tests clauses to Structural
     change (S5; C3, C8, P12);
   - add the audit's assumption line (A2; C6);
   - write the completion contract in a `/goal`-ready form (K3; F4, F5).

   Then progression-test each skill against the current model (P3, P4, C10).

Estimated effect: the four skills go from 402 to roughly 250–280 lines. Spec stays the longest. The
rules the evidence backs — one obligation per requirement, an executable verify line, status kept in
a ledger, a "none observed" result allowed, no self-acceptance — all survive.
