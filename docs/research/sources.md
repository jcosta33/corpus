# Sources — the evidence base for `docs/research/`

> This is the bibliography for Swarm's research layer. It is held to the **§0.7 discipline** ("real science, not astrology"): every load-bearing empirical claim in `docs/research/` cites a **verified** entry below, with the recorded caveats. Entries marked **caveated** (non-peer-reviewed) MUST NOT carry a `MUST`-level claim. Entries in **Rejected** MUST NOT be cited — they are recorded so a fabricated citation is never silently re-introduced.
>
> This bibliography was assembled **after web-verification** (June 2026). Several headline figures that circulate in the skill-authoring literature rested on **fabricated/misattributed arXiv ids** and were rejected (see below). A few entries were already verified by the framework's own bibliography elsewhere; this layer **reuses that key** rather than re-deriving it.

---

## Verified — primary research (peer-reviewed, finding confirmed)

<a id="TREEOFTHOUGHTS"></a>
**[TREEOFTHOUGHTS] Tree of Thoughts: Deliberate Problem Solving with Large Language Models.** Yao, Yu, Zhao, Shafran, Griffiths, Cao, Narasimhan. **NeurIPS 2023**, arXiv:2305.10601. *Verified (June 2026, direct fetch).* On **Game of 24**, GPT-4 with chain-of-thought solved **4%** of tasks; Tree-of-Thoughts reached **74%**. Grounds: deliberate plan/search over flat generation (the `decompose`/planning rationale).

<a id="REFLEXION"></a>
**[REFLEXION] Reflexion: Language Agents with Verbal Reinforcement Learning.** Shinn, Cassano, Berman, Gopinath, Narasimhan, Yao. **NeurIPS 2023**, arXiv:2303.11366. *Verified (June 2026, direct fetch — abstract states the figure verbatim).* Verbal self-reflection between trials yields **91% pass@1 on HumanEval vs the 80% GPT-4 baseline**. Grounds: the **forced-visible-output / verbal-feedback** discipline behind empirical-proof (a written artefact converts an implicit signal into a durable, checkable one).

<a id="SCRATCHPAD"></a>
**[SCRATCHPAD] Show Your Work: Scratchpads for Intermediate Computation with Language Models.** Nye, Andreassen, Gur-Ari, Michalewski, Austin, Bieber, Dohan, Lewkowycz, Bosma, Luan, Sutton, Odena. **ICLR 2022**, arXiv:2112.00114. *Verified (June 2026, direct fetch).* Emitting intermediate steps to a "scratchpad" **dramatically improves** multi-step computation (long addition → program execution). Grounds: externalising intermediate work (the trace / task-file rationale).

<a id="PLANSOLVE"></a>
**[PLANSOLVE] Plan-and-Solve Prompting: Improving Zero-Shot Chain-of-Thought Reasoning.** Wang, Xu, Lan, Hu, Lan, Lee, Lim. **ACL 2023**, arXiv:2305.04091. *Verified (June 2026, direct fetch).* Devise a plan that divides the task into subtasks, then execute it; **consistently outperforms zero-shot CoT** across arithmetic/commonsense/symbolic reasoning. Grounds: plan-before-execute (the `lower`/`decompose` rationale).

## Verified — reused from the kernel bibliography

These were already verified by the framework's bibliography elsewhere; the entries below restate them so this layer is self-contained.

<a id="LOSTMID"></a>
**[LOSTMID] Lost in the Middle: How Language Models Use Long Contexts.** Liu et al., **TACL 2024**. The U-shaped attention curve — accuracy degrades for information in the middle of long contexts. (Per the kernel entry: "context rot" is a *later popular term*, not coined here; do not attribute it to this paper.) Grounds: the AGENTS.md density cap and the "minimize always-on context" discipline.

<a id="AGENTSMD-HARM"></a>
**[AGENTSMD-HARM] Evaluating AGENTS.md** (Gloaguen, Mündler, Müller, Raychev, Vechev, ETH Zürich SRI) **and** its efficiency companion (Lulla et al.). Per the kernel entry: repository-specific commands are used far more often when named in the context file than when not; LLM-*generated* narrative context can cost more than it returns. Grounds: the `AGENTS.md > Commands` contract (name the commands; minimise narrative).

## Verified — official guidance (authoritative vendor/spec docs, not empirical claims)

<a id="SKILLBP"></a>
**[SKILLBP] Skill authoring best practices.** Anthropic Claude API docs. Official guidance: the **~500-line body cap**, third-person descriptions, progressive disclosure, the *explain-the-why* pattern, anti-patterns. <https://docs.anthropic.com/en/docs/agents-and-tools/agent-skills/best-practices> — *official guidance, not a measured study; cite as design guidance.*

<a id="CTXENG"></a>
**[CTXENG] Effective context engineering for AI agents.** Anthropic Engineering, 2025. Context as a finite resource; the **three-file note-taking pattern** (`task_plan` / `progress_log` / `decisions`). <https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents> — *official guidance.*

<a id="SKILLSPEC"></a>
**[SKILLSPEC] Open Agent Skills specification.** agentskills.io. The `SKILL.md` shape, the 1024-char `description` cap, the progressive-disclosure model. <https://agentskills.io/specification> — *open standard.*

<a id="AGENTSMD-CONV"></a>
**[AGENTSMD-CONV] The `AGENTS.md` convention.** agents.md — the cross-tool repository-context convention; the basis for the `AGENTS.md > Commands` contract. <https://agents.md> — *convention/standard.*

<a id="CCTASKS"></a>
**[CCTASKS] Claude Code Tasks / Todo system.** Anthropic, Claude Code (2026). Disk-persistent, dependency-aware task tracking — vendor-scale validation of externalised task state. <https://docs.anthropic.com/en/docs/claude-code/changelog> — *vendor doc.*

## Caveated — non-peer-reviewed (cite ONLY as preliminary; never load-bearing)

Treated exactly as the kernel treats `[ARIZE26]`/`[DETERMINISM]`: usable to *illustrate* a direction, never to ground a `MUST`. Their headline statistics are single-author/blog measurements, not controlled peer-reviewed studies.

<a id="ACTIVATION-BLOG"></a>
**[ACTIVATION-BLOG] Why Claude Code Skills Don't Activate — And How to Fix It.** Seleznov, Medium, 2026. A self-published 650-trial measurement reporting directive descriptions activating far more reliably than passive ones (the "OR ≈ 20.6 / 100% activation" figures). **Non-peer-reviewed; the specific numbers are NOT load-bearing.** The *direction* (directive, exclusion-bearing descriptions help) is used only as illustration; the kernel's primary mechanism is "load what the task names" (§26.4), with description-match as the fallback.

<a id="TWOPROBLEMS"></a>
**[TWOPROBLEMS] Claude Skills Have Two Reliability Problems, Not One.** Bara, Medium, 2026. Distinguishes activation failure from silent execution-step-skipping; motivates forced-visible-output. **Non-peer-reviewed; illustrative only** (the load-bearing version of this is [REFLEXION] + empirical-proof).

<a id="PRACTITIONER"></a>
**[PRACTITIONER] Practitioner skill-authoring catalogues.** Safonova ("I validated 100+ Claude Code Skills", Substack); Ibryam ("Skill Authoring Patterns", Generative Programmer); BSWEN (skill-count vs startup cost); the anti-patterns catalogue. **Practitioner sources, caveated** — useful for named anti-patterns and authoring heuristics, never for a quantitative claim.

## Rejected — DO NOT CITE (fabricated / misattributed)

The skill-authoring literature attributes load-bearing figures to these arXiv ids. **Direct fetch (June 2026) found each id resolves to an unrelated paper.** They are recorded here so the fabrication is never re-introduced (per the kernel's reject discipline).

| Circulating claim | Cited as | What the id actually is | Verdict |
| --- | --- | --- | --- |
| "21× degradation when file-based state externalization is removed" (InfiAgent) | arXiv:2511.10954 | *Kapitza-Dirac interference of Higgs waves in superconductors* (condensed-matter physics) | **REJECTED — misattributed; the 21× figure is unverifiable and MUST NOT be cited.** File-state externalization is instead grounded on [CTXENG] + [CCTASKS] + [SCRATCHPAD]. |
| "fixed turn limit at p75 cuts cost 24–68%" (More with Less) | arXiv:2510.27502 | *Reference Equations of State for Density Prediction in Regasified LNG Mixtures* (chemical physics) | **REJECTED — misattributed.** |
| "agentic failures are overwhelmingly context failures" (PAACE) | arXiv:2511.21345 | *Blind Turbo Demodulation for Differentially Encoded OFDM* (signal processing) | **REJECTED — misattributed** (the source that circulated it flagged it as unverified). |

---

*Discipline: a claim in `docs/research/` cites a Verified entry, or carries an explicit "preliminary / non-peer-reviewed" caveat naming a Caveated entry, or it is not made. New sources are web-verified before they are added. This follows the framework's §0.7 evidence discipline.*
