# Sources

> **Every claim in this directory cites at least one entry below. A claim without a citation is opinion, not finding** — cribbed from the `write-research` skill's rule 2. Where a primary source was unavailable, the most authoritative secondary source is cited and labelled.

---

## Primary research

<a id="3"></a>
**[3] Why Claude Code Skills Don't Activate — And How to Fix It.** Ivan Seleznov, Medium, Feb 2026. Controlled study of **650 automated trials** — 3 description variants × 4 environment conditions × 18 queries × 3 reps — with ground-truth verification via `cclogviewer`; statistical analysis via Cochran-Mantel-Haenszel and Fisher's exact tests. Open data and analysis at <https://github.com/SeleznovIvan/claude-skills-test>. <https://medium.com/@ivan.seleznov1/why-claude-code-skills-dont-activate-and-how-to-fix-it-86f679409af1>

<a id="4"></a>
**[4] Claude Skills Have Two Reliability Problems, Not One.** Marc Bara, Medium, Mar 2026. Distinguishes activation failure from a separate execution failure mode (steps inside an already-loaded skill being silently skipped); documents the visible-output-forcing fix. <https://medium.com/@marc.bara.iniesta/claude-skills-have-two-reliability-problems-not-one-299401842ca8>

<a id="5"></a>
**[5] Lost in the Middle: How Language Models Use Long Contexts.** Liu, Lin, Hewitt, et al., _Transactions of the Association for Computational Linguistics_, vol. 12, 2024. The U-shaped attention curve in long context; tested on GPT-3.5-Turbo, Claude-1.3, MPT-30B-Instruct, LongChat-13B. <https://aclanthology.org/2024.tacl-1.9/>

<a id="24"></a>
**[24] Show Your Work: Scratchpads for Intermediate Computation with Language Models.** Nye, Andreassen, Gur-Ari, et al., ICLR 2022 (preprint Nov 2021). Foundational evidence that letting a model emit intermediate steps to a "scratchpad" improves accuracy on multi-step problems even when the model must predict many more tokens — individual prediction steps become easier. <https://arxiv.org/abs/2112.00114>

<a id="25"></a>
**[25] Plan-and-Solve Prompting: Improving Zero-Shot Chain-of-Thought Reasoning.** Wang, Xu, Lan, et al., ACL 2023. Devise an explicit plan before execution, then carry out subtasks; outperforms vanilla zero-shot CoT across arithmetic, commonsense, and symbolic reasoning benchmarks. <https://arxiv.org/abs/2305.04091>

<a id="26"></a>
**[26] Tree of Thoughts: Deliberate Problem Solving with Large Language Models.** Yao, Yu, Zhao, et al., NeurIPS 2023. Multiple reasoning paths with self-evaluation and backtracking; on Game of 24, GPT-4 jumps from 4 % (CoT) to **74 % (ToT)**. <https://arxiv.org/abs/2305.10601>

<a id="27"></a>
**[27] Reflexion: Language Agents with Verbal Reinforcement Learning.** Shinn, Cassano, Berman, et al., NeurIPS 2023. Verbal self-reflection between trials acts as a "semantic gradient signal"; **91 % pass@1 on HumanEval (vs 80 % GPT-4 baseline, +11 pp)**. Foundation for the iteration-trail discipline used in `write-fix` and `fix-flaky-test`. <https://arxiv.org/abs/2303.11366>

<a id="28"></a>
**[28] PAACE: A Plan-Aware Automated Agent Context Engineering Framework.** Yuksel, preprint Dec 2025. _"Modern agentic failures are overwhelmingly context failures, not model failures."_ Plan-aware context selection over flat retrieval. <https://arxiv.org/abs/2511.21345>. _Secondary citation_ — preprint metadata only; full text not yet verified line-by-line.

<a id="29"></a>
**[29] InfiAgent: An Infinite-Horizon Framework for General-Purpose Autonomous Agents.** Yu et al., 2026. File-centric architecture with k-most-recent action window plus workspace state snapshot; ablation removing file-based state externalization causes **21x performance degradation** on long-horizon tasks. Direct empirical support for externalized task files. <https://arxiv.org/abs/2511.10954>. _Secondary citation_ — abstract and ablation table verified; full architectural details summarised.

<a id="30"></a>
**[30] Context Rot: How Increasing Input Tokens Impacts LLM Performance.** Hong, Troynikov, Huber, _Chroma technical report_, July 2025. Eighteen LLMs evaluated; performance degrades non-uniformly as input grows, including in the _middle_ and _end_ of long contexts. Stronger and broader than the original Lost in the Middle finding. <https://research.trychroma.com/context-rot>

<a id="31"></a>
**[31] More with Less: An Empirical Study of Turn-Control Strategies for Efficient Coding Agents.** Gao & Peng, ByteDance, Oct 2025. Quadratic token-cost growth with conversation turns; a fixed turn limit at the 75th percentile cuts cost **24–68 %** with minimal solve-rate impact. Evidence that long task files have super-linear cost. <https://arxiv.org/abs/2510.27502>

<a id="32"></a>
**[32] Evaluating AGENTS.md: Are Repository-Level Context Files Helpful for Coding Agents?** Gloaguen, Mündler, Müller, Raychev, Vechev (ETH Zürich SRI Lab), Feb 2026. LLM-generated context files cost +20 % with –3 % success on SWE-bench Lite; developer-written context files yield ~+4 % success at +19 % cost. Repository-specific tools are used **2.5 times per instance when mentioned in the context file vs <0.05 times when not** — a ~50× lift on the directly addressable signal. Validates the `AGENTS.md > Commands` contract design and the minimalism principle (commands beat narrative). Code and benchmark: <https://github.com/eth-sri/agentbench>. <https://arxiv.org/abs/2602.11988>

<a id="33"></a>
**[33] On the Impact of AGENTS.md Files on the Efficiency of AI Coding Agents.** Lulla, Mohsenimofidi, Galster, Zhang, Baltes, Treude, Jan 2026. Paired same-task / same-repository study over 124 pull requests across 10 repositories. Presence of `AGENTS.md` is associated with **lower median wall-clock runtime (≈28.6 %)** and **reduced output token consumption (≈16.6 %)** while task-completion behaviour stays comparable. Companion to [\[32\]](#32) — efficiency gains without performance regression. <https://arxiv.org/abs/2601.20404>

---

## Specifications and official guidance

<a id="1"></a>
**[1] Open Agent Skills specification.** agentskills.io. Defines `SKILL.md`, frontmatter rules, the 1024-character `description` cap, file layout, and the progressive-disclosure model. <https://agentskills.io/specification>

<a id="2"></a>
**[2] Skill authoring best practices.** Claude API Docs (Anthropic). Official guidance: 500-line body cap, third-person descriptions, progressive disclosure, the _Explain-the-Why_ pattern, evaluation-driven development, anti-patterns. <https://docs.anthropic.com/en/docs/agents-and-tools/agent-skills/best-practices>

<a id="9"></a>
**[9] Optimizing skill descriptions.** agentskills.io. Open-spec guidance: imperative phrasing, user-intent framing, explicit context lists, conciseness. <https://agentskills.io/skill-creation/optimizing-descriptions>

<a id="16"></a>
**[16] Equipping agents for the real world with Agent Skills.** Anthropic Engineering, originally published 2025-10-16; updated with the open-standard release notice 2025-12-18. The original design rationale for the spec. <https://www.anthropic.com/engineering/equipping-agents-for-the-real-world-with-agent-skills>

<a id="17"></a>
**[17] Extend Claude with skills.** Claude Code docs. Skill loading model in Claude Code specifically. <https://docs.anthropic.com/en/docs/claude-code/skills>

<a id="19"></a>
**[19] agents.md.** The open `AGENTS.md` convention adopted by Cursor, Codex, Claude Code, OpenCode, and others; basis for Swarm's `AGENTS.md > Commands` contract. <https://agents.md>

<a id="20"></a>
**[20] Effective context engineering for AI agents.** Anthropic Engineering, Sep 29 2025. Official Anthropic guidance on context as a finite resource. Defines the **canonical three-file note-taking pattern**: `task_plan.md` for the plan, `progress_log.md` for the running session log, `decisions.md` for durable design choices. The discipline behind Swarm's task-template sections. <https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents>

<a id="21"></a>
**[21] Effective harnesses for long-running agents.** Anthropic Engineering, Nov 2025. Initializer + coding-agent + `claude-progress.txt` pattern using the Claude Agent SDK; the Initializer creates an `init.sh`, a git repo with first commit, the progress file, and a JSON feature list with 200+ items; the Coding Agent reads git logs and the progress file at every session start, picks one feature, runs end-to-end browser tests via the Puppeteer MCP, and commits before exit. Two-context-window architecture; predecessor of [\[22\]](#22)'s three-agent design. <https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents>

<a id="22"></a>
**[22] Harness design for long-running application development.** Anthropic Engineering, Mar 2026. Three-agent harness (Planner + Generator + Evaluator) with structured-artefact handoffs; sprint contracts (success criteria graded against pre-committed rubrics) negotiated before the Generator writes code; context resets via clearing-and-handoff rather than compaction. <https://www.anthropic.com/engineering/harness-design-long-running-apps>

<a id="23"></a>
**[23] Todo Lists / Tasks system.** Anthropic, Claude Code v2.1.16, Jan 2026. Disk-persistent task tracking for multi-session work, with dependency declaration and cross-session collaboration. Validates the externalised-task-file pattern at vendor scale. <https://docs.anthropic.com/en/docs/claude-code/changelog>

---

## Practitioner analyses and pattern catalogues

<a id="6"></a>
**[6] Skill Creation Anti-Patterns.** _Some Claude Skills_. Catalogue: Reference Illusion, Description Soup, Template Theater, The Everything Skill, Tool Overload, Missing Exclusions. <https://someclaudeskills.com/docs/skills/skill_coach/references/anti-patterns/>. _Secondary source._

<a id="7"></a>
**[7] I validated 100+ Claude Code Skills.** Olga Safonova, Substack. Frequency analysis of common skill-authoring mistakes (missing WHEN triggers, missing WHAT verbs, wordy passive trigger phrases). <https://olgasafonova.substack.com/p/i-validated-100-claude-code-skills>. _Secondary source_ — direct fetch timed out; relied on indexed search-engine summary.

<a id="8"></a>
**[8] Skill Authoring Patterns from Anthropic's Best Practices.** Bilgin Ibryam, _Generative Programmer_, Apr 2026. Distils Anthropic's docs and the `skill-creator` source into 14 named patterns covering discovery, context economy, instruction calibration, workflow control, and executable code. Cites the `skill-creator` `SKILL.md` (Anthropic's own dogfooded skill) directly, plus practitioner writing from Hassid, Pachaar, Tort Mario, Xu, and Siva. <https://generativeprogrammer.com/p/skill-authoring-patterns-from-anthropics>

<a id="34"></a>
**[34] Plugin skills load full SKILL.md content at startup, not frontmatter-only.** anthropics/claude-code issue #44371, Apr 2026 (still open, labelled `bug` · `has repro` · `area:skills` · `performance`). Reproducible measurement: 28 skills (~34K tokens) → cold start of 4+ minutes vs 3–4 seconds with no skills installed. Scaling is non-linear per skill count. Documents the gap between Claude Code's current implementation and the progressive-disclosure model the open spec [\[1\]](#1) and Anthropic's own docs [\[17\]](#17) describe. Cross-referenced by issues #16160 (lazy-loading feature request), #43816 (`SkillSearch` proposal), #46383 (`auto_invoke: false` flag), #46952 (token-overlap matcher), #49170 (35 % context consumed by auto-loaded plugin docs), #50079 (130K-token skill injection on language-detection failure). <https://github.com/anthropics/claude-code/issues/44371>.

<a id="35"></a>
**[35] Claude Code Skills Context Window Impact: How Many Is Too Many?** BSWEN, Mar 2026. Practitioner measurement of skill-count vs startup cost: each skill adds ~100 tokens of always-on metadata at session start; 45 skills consume ~4,500 tokens before the user prompt. Author's rule of thumb: **15 optimal · 20 good · 25 acceptable · 30 warning · 45+ problem**. The signal is that even disciplined directive descriptions cannot escape the eager-loading cost documented in [\[34\]](#34); selective install is the only consumer-side defence. <https://docs.bswen.com/blog/2026-03-28-claude-skills-context-window/>. _Secondary source_ — single-author measurement, not a controlled study.

---

## Reference implementations and ecosystem

<a id="10"></a>
**[10] vercel-labs/skills CLI README.** Vercel Labs. Confirms `npx skills add <repo> -g` for cross-agent user-global install. <https://github.com/vercel-labs/skills>

<a id="11"></a>
**[11] anthropics/skills.** Anthropic's reference skills repo (PDF, DOCX, XLSX, `skill-creator`); Claude Code marketplace install path. <https://github.com/anthropics/skills>

<a id="12"></a>
**[12] vercel-labs/agent-skills.** Vercel's official skills; reference for repo layout. <https://github.com/vercel-labs/agent-skills>

<a id="13"></a>
**[13] elastic/agent-skills.** Elastic's official Elasticsearch / Kibana skills; example of `claude plugin install` distribution. <https://github.com/elastic/agent-skills>

<a id="14"></a>
**[14] wshobson/agents.** "Intelligent automation and multi-agent orchestration for Claude Code" — 78 plugins, ~150 specialised skills, modular plugin marketplace. <https://github.com/wshobson/agents>

<a id="15"></a>
**[15] addyosmani/agent-skills.** "Production-grade engineering skills for AI coding agents" — Gemini CLI user-global install path. <https://github.com/addyosmani/agent-skills>

<a id="18"></a>
**[18] `agentskills/agentskills` `skills-ref` library.** Reference validator implementing the open spec. <https://github.com/agentskills/agentskills/tree/main/skills-ref>. _Summary citation_ — README and source layout were inspected, not the full source.

---

## Citation discipline for this directory

- Primary sources are preferred. Where one is cited as primary, the original study, paper, or specification is the single source of truth.
- Secondary sources are labelled _secondary_ and accompanied by an explanation if the primary was unavailable.
- Dead links are replaced; if no replacement exists, the entry is annotated `[archived]`.
- New citations land alongside the change they justify — never after the fact. A new source materialises in the same PR as the design choice it grounds; reviewers can trace every claim back to the entry that introduced it.
