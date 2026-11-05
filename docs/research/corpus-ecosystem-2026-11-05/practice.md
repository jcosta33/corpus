# Practitioner feedback and empirical evidence on specs, plans, and artifact skills (2025-2026)

Compiled 2026-11-05 for Corpus (`/Volumes/Development/corpus`). Scope: practitioner reports and
empirical studies, not vendor docs or framework source. Every item below was opened unless marked
`UNVERIFIED`. Evidence classes: opinion, anecdote (first-hand use, n=1 or few), anecdote+measure
(first-hand with numbers), expert-panel (Thoughtworks Radar), survey/mining, benchmark, controlled
study. "Vendor-internal" marks a vendor reporting its own evals.

Corpus skill tags: SPEC, AUDIT, RESEARCH, CAMPAIGN, ALL (applies to every skill or to skill
design), MISSING (missing artifact type), SHOULD-NOT-EXIST.

## A. Spec-driven development: hands-on critiques

- **Böckeler, "Understanding Spec-Driven-Development: Kiro, spec-kit, and Tessl"** —
  https://martinfowler.com/articles/exploring-gen-ai/sdd-3-tools.html — 2025-10-15 — anecdote
  (expert hands-on). Kiro turned a small bug into 4 user stories and 16 acceptance criteria; Spec Kit
  produced repetitive Markdown that was tedious to review ("I'd rather review code than all these
  markdown files"); the agent ignored research notes that described existing classes and recreated
  them; small work packages run against the idea of SDD; the split between functional and technical
  content was unclear. Lesson: a spec costs review time per line, and agents still drift from it.
  -> SPEC (supports the no-file inline path; argues for a hard size budget on Requirements and for
  keeping implementation detail out).
- **HN thread on the Böckeler article** — https://news.ycombinator.com/item?id=45610996 —
  2025-10-16/17 — anecdote (many commenters). Wins: a single plain Markdown spec file without a
  framework (esafak, raphinou); a per-task subagent plus orchestrator raised trust (yoaviram).
  Losses: the agent "declares the sprint as done even though tests still fail" (yoaviram); users
  call for BDD or tests as the living spec instead of Markdown (bonesss, gsadaka); nobody knows when
  specs merge into one truth (iamdeedubs). -> SPEC (Verify with must be executable and rerun by a
  non-implementer; Corpus already rejects a repository-wide spec baseline, which this supports).
- **Zaninotto (Marmelab), "Spec-Driven Development: The Waterfall Strikes Back"** —
  https://marmelab.com/blog/2025/11/12/spec-driven-development-waterfall-strikes-back.html —
  2025-11-12 — opinion + anecdote. Spec Kit output for "show the current date" was 8 files and 1,300
  lines; an agent ticked "verify implementation" without writing tests; returns diminish on large
  existing codebases. Proposes an assumption-test loop with no spec documents. -> SPEC (cut
  ceremony; completion claims need evidence), SHOULD-NOT-EXIST (for small or exploratory work).
- **Eberhardt (Scott Logic), "Putting Spec Kit Through Its Paces"** —
  https://blog.scottlogic.com/2025/11/26/putting-spec-kit-through-its-paces-radical-idea-or-reinvented-waterfall.html
  — 2025-11-26 — anecdote+measure (n=1 feature, then one increment). Spec Kit: 33.5 min agent time,
  2,577 Markdown lines, 689 lines of code, 3.5 h review. Iterative prompting on the same feature:
  8 min agent time, ~1,000 lines of code, no Markdown, 15 min review, 9 min fixes; he estimates
  about 10x faster overall. The one real bug (an unpopulated variable) was something the spec could
  not express. -> SPEC (strongest numeric case for the inline path and for refusing long specs;
  review time is the cost to cap, not agent time).
- **Kent Beck via Fowler, "Fragments: January 8"** — https://martinfowler.com/fragments/2026-01-08.html
  — 2026-01-08 — opinion. Writing the full spec before implementation assumes you learn nothing
  while implementing. -> SPEC (supports Corpus's "when code or evidence contradicts the spec, stop
  and update"; argues against front-loading every AC).
- **Beck, "Augmented Coding: Beyond the Vibes"** —
  https://newsletter.kentbeck.com/p/augmented-coding-beyond-the-vibes — 2025-06-25 — anecdote.
  plan.md was a list of tests worked one at a time; the agent piled on complexity, looped, added
  features nobody asked for, and disabled or deleted tests. -> SPEC (an AC list maps well onto a
  test list; add "never delete or weaken a test to pass" as a preservation rule; keep structural and
  behavioral waves separate, which Waves already do).
- **Steinberger, "Just Talk To It"** — https://steipete.me/posts/just-talk-to-it — about Oct 2025
  (the page shows no date) — anecdote. He dropped big-spec-then-build ("the old way of thinking")
  for discussion plus iteration, and writes specs only for tricky features. A fresh context reading
  a plan "would easily add 10 minutes to everything". -> SPEC, SHOULD-NOT-EXIST (adversarial: with
  a strong model, the conversation is the spec for most work).
- **Hashimoto, "My AI Adoption Journey"** — https://mitchellh.com/writing/my-ai-adoption-journey —
  2026-02-05 — anecdote. For vague requests he plans and executes in separate sessions; giving
  agents a way to verify their own work cut regressions; he adds one AGENTS.md line per repeated
  mistake. -> SPEC (a spec is a planning-session output, not ceremony), ALL (prefer verification
  tools over prose).
- **Reed, "My LLM codegen workflow atm"** — https://harper.blog/2025/02/16/my-llm-codegen-workflow-atm/
  — 2025-02-16 — anecdote. Greenfield: spec.md from one-question-at-a-time interviews, then
  prompt_plan.md and todo.md. Brownfield: plan per task, not per project. Risk: getting "over my
  skis" when going fast. -> SPEC (one-question interview equals grilling), CAMPAIGN (todo state
  lived in a file; Corpus correctly pushes that state to a ledger).
- **Huntley, "Ralph Wiggum as a software engineer"** — https://ghuntley.com/ralph/ — 2025-07-14 —
  anecdote. One spec per file; fix_plan.md is disposable and gets regenerated from specs plus code
  when it drifts; one item per loop; failures include re-implementing existing code after a bad
  search, placeholder stubs, and wrong direction traced to contradictory specs. -> CAMPAIGN
  (supports "snapshots rot, goals survive": regenerate plans from live state), SPEC
  (self-contradictory requirements are a top failure; check for conflicts at handoff).
- **Ronacher, "What actually is Claude Code's plan mode?"** —
  https://lucumr.pocoo.org/2025/12/17/what-is-plan-mode/ — 2025-12-17 — analysis + anecdote. Plan
  mode is a Markdown file plus an injected prompt; read-only is enforced only by prompt; he prefers
  a reviewable file on disk that is concise, recommends one approach, and lists critical paths.
  -> SPEC (adversarial: a bare plan file is native and free; corpus-spec earns its place only through
  testable ACs, a non-implementer review, and the structural/Split sections).

## B. Expert-panel signals (Thoughtworks Technology Radar)

- **SDD technique, Assess** — https://www.thoughtworks.com/radar/techniques/spec-driven-development
  — Nov 2025 (Vol 33), absent from later editions — expert-panel. Warns of "a bias toward heavy
  up-front specification and big-bang" delivery. -> SPEC.
- **GitHub Spec Kit, Assess** — https://www.thoughtworks.com/radar/languages-and-frameworks/github-spec-kit
  — 2026-04-15 — expert-panel. Two camps: minimal structure on strong agents versus defined
  workflows. Problems: instruction bloat leading to context rot, defensive checks nobody needed, and
  verbose Markdown adding cognitive load. Trimming generated files and moving guidance into skills
  helped. Experienced engineers got the most value. -> SPEC, ALL.
- **OpenSpec, Trial** — https://www.thoughtworks.com/en-us/radar/tools/openspec — Nov 2026 —
  expert-panel. Delta specs on brownfield code gave more predictable output with fewer unintended
  changes. The main risk is Markdown volume and keeping the persistent spec current. -> SPEC
  (supports change-scoped specs; Corpus's choice of no persistent spec baseline avoids the upkeep
  risk entirely).
- **AI-driven documentation sprawl, Caution** —
  https://www.thoughtworks.com/radar/techniques/ai-driven-documentation-sprawl — 2026-11-04 —
  expert-panel. Spec tools such as Spec Kit and BMAD produce Markdown that skips quality gates and
  becomes a "big ball of documentation mud" that misleads agents. Remedies: prune on a schedule,
  keep one authoritative source per topic, review generated docs critically. -> ALL (justifies
  writing artifacts outside the repo and the Delete/Leave/Promote close; argues for making Delete
  the default).
- **Agent instruction bloat, Caution** —
  https://www.thoughtworks.com/radar/techniques/agent-instruction-bloat — 2026-04-15, updated
  2026-11 — expert-panel. Instructions grow long, contradictory, and stale. Convert them to hooks and
  checks; re-evaluate each against every new model and delete what is no longer needed
  ("progression testing"); use progressive disclosure. -> ALL (the four SKILL.md files are
  instruction sets; schedule a deletion pass per model generation).
- **Agent skill cognitive surrender, Caution** —
  https://www.thoughtworks.com/radar/techniques/agent-skill-cognitive-surrender — 2026-11-04 —
  expert-panel. Teams adopt large generic skill libraries unread. As models improve, generic skills
  become obsolete, and domain-specific curated skills hold their value. -> ALL, SHOULD-NOT-EXIST
  (pressure on generic procedure in corpus-research and corpus-audit; their value must sit in
  owner-specific rules).
- **Grilling, Trial** — https://www.thoughtworks.com/radar/techniques/grilling — 2026-11-04 —
  expert-panel. The agent questions the human before work and the answers get recorded. Warns
  against long interviews; ask only about decisions that matter. -> SPEC (matches Method step 2;
  supports its "ask only about material..." limit).
- **Risk-tiered human oversight, Trial** —
  https://www.thoughtworks.com/radar/techniques/risk-tiered-human-oversight — 2026-11-04 —
  expert-panel. Humans make the highest-risk or irreversible changes, review mid-risk ones, and
  low-risk changes auto-merge through CI. Uniform scrutiny is "oversight theater". -> CAMPAIGN
  (Authorities could name a risk tier per operation; supports proportional review).
- **Interactive visual plans with agents, Trial** —
  https://www.thoughtworks.com/radar/techniques/interactive-visual-plans-with-agents — 2026-11-04
  — expert-panel. HTML/MDX plans with diagrams and wireframes are easier to review than long text
  plans. Stay iterative, not exhaustive. -> SPEC (long text is the review bottleneck).
- **Coding agent swarms, Caution** — https://www.thoughtworks.com/radar/techniques/coding-agent-swarms
  — 2026-04-15 — expert-panel. The showcased successes (a C compiler, a browser) had detailed
  existing specs and test suites. Prerequisites: a durable work ledger and a merge mechanism.
  -> CAMPAIGN (supports ledger plus write-disjoint dispatch; parallelism pays only with a measurable
  oracle).
- **Unattended overnight agentic builds, Trial** —
  https://www.thoughtworks.com/radar/techniques/unattended-overnight-agentic-builds — 2026-11-04 —
  expert-panel. Entry requirements: a sandbox, up-front specs that define done, feedback sensors,
  and a tested validation harness, because overnight output is too large for line-by-line review.
  -> SPEC, CAMPAIGN (supportive: specs earn their cost when nobody watches the work).
- **Codebase cognitive debt, Caution** — https://www.thoughtworks.com/radar/techniques/codebase-cognitive-debt
  — 2026-04-15 — expert-panel. AI-speed change outruns team understanding; fitness functions and
  sensors help. -> AUDIT (supportive: an evidenced current-state map has value for the human).

## C. Engineering posts from model vendors (vendor-internal evidence)

- **Shihipar (Anthropic), "The new rules of context engineering for Claude 5 generation models"** —
  https://claude.dev/blog/the-new-rules-of-context-engineering-for-claude-5-generation-models/ —
  2026-07-24 — vendor-internal (Anthropic's own coding evals, no per-task breakdown). Anthropic cut
  more than 80% of Claude Code's system prompt with no measurable eval loss; overlapping and
  contradictory rules hurt. The six shifts: rules to judgement, examples to interface design, all
  upfront to progressive disclosure, repetition to simple tool descriptions, CLAUDE.md memory to
  auto-memory, and "simple specs" to "rich references". Plan and spec files should prefer things
  written in code, such as test suites, HTML mockups, and rubrics. Skills should be lightweight
  guides that encode owner-specific opinions. -> ALL (cut rules a strong model follows by
  default), SPEC (make Verify with point at tests or code, not prose; consider an executable test
  list as the requirements body).
- **Young (Anthropic), "Effective harnesses for long-running agents"** —
  https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents — 2025-11-26 —
  vendor engineering experience. A feature list in JSON, every item starting as failing; agents may
  only flip `passes`. JSON was chosen over Markdown because the model is less likely to rewrite it.
  Seen failures: one-shotting, premature victory, completion without end-to-end tests, sessions
  starting from a broken state. -> CAMPAIGN (supports keeping mutable status out of the Markdown
  campaign and in a structured ledger; the pickup loop should verify that the base is green first),
  SPEC (an implementer must not edit requirements; tests are protected).
- **Lopopolo (OpenAI), "Harness engineering"** — https://openai.com/index/harness-engineering/ —
  about Feb 2026 — `UNVERIFIED primary` (HTTP 403). Read only via the summary at
  https://www.engineering.fyi/article/harness-engineering-leveraging-codex-in-an-agent-first-world:
  one big AGENTS.md crowds out task context, rots, and cannot be verified; the replacement is about
  100 lines as a map into docs/ (which includes exec-plans), invariants enforced by custom linters,
  and "if it isn't discoverable in the repo, it effectively doesn't exist for the agent." -> ALL
  (contrast: OpenAI keeps plans in the repo; Corpus keeps them outside, so promotion is the only
  route to durability).

## D. Frameworks of practice

- **Böckeler, "Harness engineering for coding agent users"** —
  https://martinfowler.com/articles/harness-engineering.html — 2026-04-02 (supersedes 2026-02-17)
  — opinion/framework. Markdown guides (AGENTS.md, skills) are inferential and only "increase the
  probability"; computational sensors (linters, types, structural tests) are deterministic. Pair
  guides with sensors, and when an issue recurs, harden the harness. -> ALL (each rule in a Corpus
  skill that can become a script should, like the spec Verify list), SPEC.
- **Osmani, "How to write a good spec for AI agents"** — https://addyosmani.com/blog/good-spec/ —
  2026-01-13 — opinion. Cites the "curse of instructions": compliance falls as rules are added. An
  "overbearing spec can actually confuse more than help" on small tasks. Feed each step only its
  section. Boundaries in three tiers: Always, Ask first, Never. -> SPEC (dispatch the relevant
  slice, which Split does).
- **Grove (OpenAI), "The New Code"** — https://ai.engineer/talks/8rABwKRsec4-specifications-are-the-new-code
  — AI Engineer World's Fair 2025 (the page shows no date; mid-2025) — opinion. Specs as the
  durable unit; each clause should link to concrete examples that act as tests. -> SPEC
  (supportive of AC plus Verify with; his examples are executable, not prose).
- **Willison, "Claude Skills are awesome"** — https://simonwillison.net/2025/Oct/16/claude-skills/ —
  2025-10-16 — opinion. A skill costs a few dozen tokens until loaded, and its simplicity is its
  strength. -> ALL.
- **Willison, conformance-suites tag** — https://simonwillison.net/tags/conformance-suites/ — posts
  from 2026-01-10 to 2026-10-30 — opinion + case reports (Ladybird LibJS port with byte-for-byte
  output parity; Bun's Zig-to-Rust rewrite against its TypeScript test suite; whenwords, a library
  that is only a spec plus YAML tests). Conformance suites are "the cheat code" for large agent
  work. -> SPEC (Structural change: name differential or conformance checks against a trusted
  implementation as the preferred preservation oracle).

## E. GitHub issues and discussions (framework failure modes)

- **spec-kit Discussion #2914, "Dealing with fairly complex features"** —
  https://github.com/github/spec-kit/discussions/2914 — 2026-06-10 — anecdote. Agents lose track of
  the plan and tasks around context compaction; the maintainer advises capping tasks per run or
  splitting into sub-features. -> CAMPAIGN, SPEC (Waves sized to one context; restart from the
  artifact, not from memory).
- **superpowers #512, plan length** — https://github.com/obra/superpowers/issues/512 — 2026-02-20 —
  anecdote+measure. Plans of 1,750 to 3,000+ lines (about 110 KB) against a 124-line spec, a build
  costing "$50+", and plans that write the code and tests up front ("TDD micromanagement").
  -> SPEC (confirms keeping mechanisms out of requirements; consider a hard length cap).
- **superpowers #750, token use** — https://github.com/obra/superpowers/issues/750 — 2026-03-15 —
  anecdote. Skipping the spec-review gate cut usage about 50%; the enforced flow focused on approval
  gates and variants rather than the user's goal; credits ran out within a day. -> SPEC, CAMPAIGN
  (every mandatory gate multiplies cost; gate by risk).
- **superpowers #2587, structural problems surface late** —
  https://github.com/obra/superpowers/issues/2587 — 2026-10-22 — anecdote+measure. Every task
  passed its per-task review, yet a broad review after task 8 found 9 structural problems
  (duplicated rules, optional fields scattered across types). Review and fixes took 8.5 h against
  7 h of implementation. A design-shape check by a fresh reviewer before handoff caught 7 blocking
  problems in plan text. -> SPEC (Split: per-slice review cannot see cross-slice duplication; add a
  pre-dispatch whole-design review and a post-merge broad review), CAMPAIGN (same for multi-PR).
- **superpowers #2612, #2551, #1152** (830k-token coordinator; implementer contexts of 300k+; one
  plan exhausting a 5 h budget) — `UNVERIFIED` (seen only in search snippets, not opened).
- **OpenSpec #1260, specs silently skipped** — https://github.com/Fission-AI/OpenSpec/issues/1260
  — 2026-06-25 — anecdote. The agent skipped a dependency step, and the tool counted file existence
  as done. Fixed in PR #1412. -> SPEC (the Verify list must check content, not presence).
- **OpenSpec #2139, requirement bloat** — https://github.com/Fission-AI/OpenSpec/issues/2139 —
  2026-10-22 — anecdote+measure (one project with 800 agent-written requirements). 81% of
  requirements had more than one SHALL, and the multi-SHALL share of new requirements rose from 57%
  to 90% in weeks; a 10-word edit produced a 180-word MODIFIED block. -> SPEC (directly validates
  "exactly one strength word" and "split obligations that fail independently"; keep them as
  mechanical checks).
- **OpenSpec #2201, drift check** — https://github.com/Fission-AI/OpenSpec/issues/2201 —
  2026-11-04 — feature request. Agents edit files outside the plan and tick tasks whose files were
  never touched ("phantom completions"); proposes comparing `git diff --name-only` with the declared
  paths. -> SPEC (Split already lists permitted write paths; a deterministic check against the diff
  is the missing sensor), CAMPAIGN.
- **BMAD critiques** (DEV Community comparison, Augment guide, Fontoura guide mentioning a forced
  "at least three issues" review rule) — `UNVERIFIED` (search snippets only).

## F. Empirical studies: context files, instructions, context length

- **Gloaguen, Mündler, Müller, Raychev, Vechev, "Evaluating AGENTS.md"** —
  https://arxiv.org/abs/2602.11988 — 2026-02-12 (v3 2026-09-29) — controlled study (four agents,
  SWE-bench Lite plus a new benchmark from repositories with developer-written context files).
  Context files "do not generally improve task success rates" and raise inference cost more than
  20%. Agents follow the files' instructions; repository overviews do not help. Useful only for
  non-standard practices. -> ALL (skills are context too: every rule costs tokens and gets
  followed literally, so a wrong or needless rule does harm), AUDIT (an audit Map handed to an
  agent as context is unlikely to help it; its value is to the human and to review).
- **Khatri, "Do Context Files Help Coding Agents? A Two-Agent Ablation Study"** —
  https://arxiv.org/abs/2607.27250 — 2026-07-28 — controlled study (Claude Code and Codex, 17
  tasks, 288 runs). No measurable correctness effect (bounded at roughly 10-15 pp); failures came
  from implementation skill, not missing repository knowledge. -> ALL, SHOULD-NOT-EXIST (adversarial
  against context-style artifacts).
- **Lulla et al., "On the Impact of AGENTS.md Files on the Efficiency of AI Coding Agents"** —
  https://arxiv.org/abs/2601.20404 — 2026-01-28 — controlled comparison (10 repositories, 124
  PRs). Median runtime 28.64% lower and output tokens 16.58% lower with AGENTS.md; completion
  "comparable". -> ALL (brief context can save cost without changing correctness).
- **Chatlatanagulchai et al., "Agent READMEs"** — https://arxiv.org/abs/2511.12884 — 2025-11-17
  (v2 2026-08-09) — mining study (2,303 files, 1,925 repositories). Files grow by "frequent, small
  additions" and are hard to read; security appears in 14.8% of files and performance in 14.5%.
  -> ALL (accretion is the default failure); AUDIT (non-functional risk is rarely written down
  anywhere, which favors an assessed Risks section).
- **Jaroslawicz et al., "How Many Instructions Can LLMs Follow at Once?" (IFScale)** —
  https://arxiv.org/abs/2507.11538 — 2025-07-15 — benchmark (20 models). The best frontier models
  reach 68% at 500 instructions; there is a primacy bias toward earlier instructions. -> ALL (put
  the decisive rule first; fewer rules per skill).
- **Qi et al., "AgentIF"** — https://arxiv.org/abs/2505.16944 — 2025-05-22 — benchmark (707
  instructions from 50 real agent applications; average 1,723 words, 11.9 constraints). Models
  "generally perform poorly", worst on complex constraint structures and tool specifications.
  -> ALL (conditional, nested rules are the weakest kind; prefer flat rules).
- **Hong, Troynikov, Huber (Chroma), "Context Rot"** — https://www.trychroma.com/research/context-rot
  — 2025-07-14 — controlled benchmark (18 models). Performance falls with input length even on
  trivial tasks; a focused ~300-token input beats ~113k tokens on LongMemEval; similar-but-wrong
  distractors hurt. -> RESEARCH, CAMPAIGN (a pickup should read the minimum; stale sibling
  artifacts act as distractors).
- **SkillsBench (Li et al.)** — https://arxiv.org/abs/2602.12670 — 2026-02-13 (v4 2026-06-14) —
  benchmark (87 tasks, 18 model-harness configurations). Curated skills raised pass rate from 33.9%
  to 50.5%; focused skills with at most three modules beat exhaustive bundles. A self-generated
  skills result (-1.3 pp) appears in secondary summaries only: `UNVERIFIED` from the abstract.
  -> ALL (keep each skill focused).
- **Han et al., "SWE-Skills-Bench"** — https://arxiv.org/abs/2603.15401 — 2026-03-16 (v2
  2026-10-27) — benchmark (real repositories at pinned commits, requirement docs with acceptance
  criteria, deterministic tests). Pass rate 76.6% without skills against 76.9% with; 92 of 98
  skills had no significant effect; harmful skills (down to -17 points) "anchor the agent on their
  own templates and override the task's explicit instructions". -> ALL (strongest adversarial
  item: a template-heavy skill can lower success; Corpus shapes must yield to the task),
  SHOULD-NOT-EXIST (generic procedure for coding tasks).

## G. Empirical studies: productivity, long horizons, multi-agent work

- **METR, "We are changing our developer productivity experiment design"** —
  https://metr.org/blog/2026-02-24-uplift-update/ — 2026-02-24 — controlled study with documented
  selection bias (57 developers, 800+ tasks). The original 2025 RCT found AI made tasks 19% slower
  (CI +2% to +39%). Late 2025: returning developers -18% (CI -38% to +9%), new developers -4% (CI
  -15% to +9%). 30-50% of developers withheld tasks they would not do without AI; running parallel
  agents broke time tracking. -> ALL (no workflow, Corpus included, has measured uplift; the owner
  should measure his own), CAMPAIGN (parallel agents are now normal practice).
- **METR, time horizons page** — https://metr.org/time-horizons/ — last updated 2026-09-08 —
  benchmark. Measurements above 16 h are unreliable with the current suite; holistic scoring
  "substantially reduces" AI performance compared with algorithmic scoring. -> CAMPAIGN (multi-PR
  goals still exceed reliable autonomy; keep the human acceptance step), SPEC (passing tests is not
  holistic acceptance).
- **Cemri et al., "Why Do Multi-Agent LLM Systems Fail?" (MAST)** — https://arxiv.org/abs/2503.13657
  — 2025-03-17 (v3 2025-10-26) — annotated trace study (1,600+ traces, seven frameworks). Gains
  from multi-agent setups on benchmarks are "often minimal"; failures fall into system design,
  inter-agent misalignment, and task verification. -> CAMPAIGN (the dispatch packet and the
  verification gate address the two named failure classes; parallelism needs justification).
- **Taghavi and Bhavani, "Spec Kit Agents"** — https://arxiv.org/abs/2604.05278 — 2026-04-07 —
  controlled study (128 runs, 32 features, 5 repositories). Read-only repository probing and
  validation hooks per phase raised LLM-judged quality by +0.15 on a 1-5 scale (about 3%) and
  SWE-bench Lite by 1.7 pp. -> SPEC (gain is small; grounding in the repository, not the document,
  carried it, which supports Method step 1).

## H. Empirical studies: tests as specification

- **Ben Sghaier, Delcourt, Sahraoui, "Artificial or Just Artful?"** — https://arxiv.org/abs/2512.21028
  — 2025-12-24 — controlled study (BigCodeBench Hard, five LLMs). Tests in the prompt nearly double
  correctness for some models; models use the tests even when told not to and adapt code when tests
  conflict with instructions. -> SPEC (executable checks steer agents more than prose; a visible
  Verify test can be gamed, so review must rerun it against production behavior, which Corpus
  requires).
- **Liang et al., "Do Code Language Models Use Tests?"** — https://arxiv.org/abs/2607.26244 —
  2026-07-28 (v2 2026-09-07) — controlled study. Correct expected outputs improve MBPP+ accuracy for
  all five models; choosing high-detection test suites finds 30.3 pp more errors but does not change
  generation. -> SPEC (tests help as specification; pick checks for detection power when verifying).
- TiCoder (arXiv 2404.10100) and "Tests as Prompt" (arXiv 2505.09027) — `UNVERIFIED` (search
  snippets only).

## I. Empirical studies: research agents and citation accuracy

- **Venkit et al., "DeepTRACE"** — https://arxiv.org/abs/2509.04499 — 2025-09-02 — audit benchmark
  (GPT-4.5/5, You.com, Perplexity, Copilot, Gemini). Citation accuracy ranges from 40% to 80%;
  large shares of statements are unsupported by the systems' own sources; debate answers are
  one-sided. -> RESEARCH (validates the source-competence table and counter-evidence mapping;
  require claim-level support checks).
- **Onweller et al., "Cited but Not Verified"** — https://arxiv.org/abs/2605.06635 — 2026-05-07 —
  benchmark (14 LLMs). Link validity above 94% and relevance above 80%, yet factual accuracy only
  39-77%; accuracy drops about 42% as tool calls rise from 2 to 150. -> RESEARCH (sharpen: a link
  that resolves proves nothing; verify that the quoted passage supports the claim; more searching
  lowers accuracy, so bound breadth and verify load-bearing findings rather than collecting).

## J. Empirical studies: LLM code review and assessment precision

- **Jin and Chen, "Uncovering Systematic Failures of LLMs in Verifying Code Against Natural Language
  Specifications"** — https://arxiv.org/abs/2508.12358 — 2025-08-17 (ASE 2025 NIER) — controlled
  study. LLMs often classify correct code as failing its requirements; prompts asking for
  explanations and corrections raised misjudgment. -> AUDIT (an LLM risk assessment skews
  false-positive; requiring a firing condition and evidence is the right control), SPEC review.
- **Zeng et al., "SWR-Bench"** — https://arxiv.org/abs/2509.01494 — 2025-09-01 (v2 2026-06-05) —
  benchmark. Aggregating several reviews raised F1 by up to 43.67%. -> review method (supports
  several fresh reviewers; outside the four skills).
- **Chowdhury et al., "code review agents" (MSR 2026)** — https://arxiv.org/abs/2604.03196 —
  2026-04-03 — mining study (3,109 PRs). PRs reviewed only by an agent merged at 45.20% against
  68.37% for human-only review; 12 of 13 agents averaged signal ratios below 60%. Correlational.
  -> AUDIT, review (human acceptance stays).
- **Lin, Liang, Thongtanunam, Tantithamthavorn, "Is Agentic Code Review Helpful?"** —
  https://arxiv.org/abs/2607.03316 — 2026-07-03 (v2 2026-07-23) — mining study (31,073 CodeRabbit
  comments, 239 repositories). 36.4% accepted, 56.3% rejected, mostly invalid suggestions (false
  positives, redundant, out of scope) and misalignment with developer intent. -> AUDIT (findings
  need evidence and an in-scope firing condition; "None observed in scope" is a legitimate result,
  and forcing findings would add noise).
- Tencent static-analysis false-positive study (arXiv 2601.18844) — `UNVERIFIED` (search snippet
  only).

## Not found or not reachable

- Reddit: the fetch tool refuses reddit.com, so no r/ClaudeAI, r/ChatGPTCoding, r/cursor, or
  r/ExperiencedDevs threads are cited.
- No controlled study was found that varies natural-language acceptance-criteria quality alone and
  measures agent success. No study was found that compares native plan mode against a spec
  framework head to head.
- No practitioner or empirical source was found on restartable multi-PR "campaign contracts" as an
  artifact type. The nearest evidence is Anthropic's long-running harness, Huntley's disposable
  plans, Thoughtworks' swarm and overnight-build blips, and the spec-kit and Superpowers
  context-exhaustion threads.
