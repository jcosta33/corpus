# Sources — the framework's evidence bibliography

> This is the single bibliography the framework's **inline `[[KEY]]` citations resolve to**. Research is referenced *contextually* — each `[[KEY]]` sits in the doc whose claim it grounds (passes, language, library, model, ADRs, positioning) and links to its entry here; there is no separate "research layer" of standalone essays, only this ledger. It is held to the **§0.7 discipline** ("real science, not astrology"): every load-bearing empirical claim cites a **verified** entry below, with the recorded caveats. Entries marked **caveated** (non-peer-reviewed) MUST NOT carry a `MUST`-level claim. Entries in **Rejected** MUST NOT be cited — they are recorded so a fabricated citation is never silently re-introduced.
>
> This bibliography was assembled **after web-verification** (June 2026). Several headline figures that circulate in the skill-authoring literature rested on **fabricated/misattributed arXiv ids** and were rejected (see below). A few entries were already verified by the framework's own bibliography elsewhere; this ledger **reuses that key** rather than re-deriving it.

---

## Verified — primary research (peer-reviewed, finding confirmed)

<a id="TREEOFTHOUGHTS"></a>
**[TREEOFTHOUGHTS] Tree of Thoughts: Deliberate Problem Solving with Large Language Models.** Yao, Yu, Zhao, Shafran, Griffiths, Cao, Narasimhan. **NeurIPS 2023**, arXiv:2305.10601. *Verified (June 2026, direct fetch).* On **Game of 24**, GPT-4 with chain-of-thought solved **4%** of tasks; Tree-of-Thoughts reached **74%**. Grounds: deliberate plan/search over flat generation (the `decompose`/planning rationale).

<a id="REFLEXION"></a>
**[REFLEXION] Reflexion: Language Agents with Verbal Reinforcement Learning.** Shinn, Cassano, Berman, Gopinath, Narasimhan, Yao. **NeurIPS 2023**, arXiv:2303.11366. *Verified (June 2026, direct fetch — abstract states the figure verbatim).* Verbal self-reflection between trials yields **91% pass@1 on HumanEval vs the 80% GPT-4 baseline**. Grounds: the **forced-visible-output / verbal-feedback** discipline behind empirical-proof (a written artefact converts an implicit signal into a durable, checkable one).

<a id="SCRATCHPAD"></a>
**[SCRATCHPAD] Show Your Work: Scratchpads for Intermediate Computation with Language Models.** Nye, Andreassen, Gur-Ari, Michalewski, Austin, Bieber, Dohan, Lewkowycz, Bosma, Luan, Sutton, Odena. **ICLR 2022 Workshop (DL4C)**, arXiv:2112.00114. *Verified (June 2026; venue is a workshop poster, not a main-conference acceptance — audit O-1).* Emitting intermediate steps to a "scratchpad" **dramatically improves** multi-step computation (long addition → program execution). Grounds: externalising intermediate work (the trace / task-file rationale).

<a id="PLANSOLVE"></a>
**[PLANSOLVE] Plan-and-Solve Prompting: Improving Zero-Shot Chain-of-Thought Reasoning.** Wang, Xu, Lan, Hu, Lan, Lee, Lim. **ACL 2023**, arXiv:2305.04091. *Verified (June 2026, direct fetch).* Devise a plan that divides the task into subtasks, then execute it; **consistently outperforms zero-shot CoT** across arithmetic/commonsense/symbolic reasoning. Grounds: plan-before-execute (the `lower`/`decompose` rationale).

<a id="FORMATFREE"></a>
**[FORMATFREE] Let Me Speak Freely? A Study on the Impact of Format Restrictions on Performance of Large Language Models.** Tam, Wu, Tsai, Lin, Lee, Chen. **EMNLP 2024 (Industry Track)**, arXiv:2408.02442 (ACL Anthology 2024.emnlp-industry.91). *Verified (June 2026, ACL Anthology + abstract fetch).* Format restriction **degrades reasoning** — JSON-mode is worst on reasoning tasks such as GSM8K, looser prompts score higher, and the effect intensifies with stricter constraints — while the **same structure helps** classification/extraction; parsing-error rates are ~0%, so the loss is reasoning-order compression, not malformed output. Grounds: structure the *frame*, not the reasoning; the evidence-before-conclusion ordering rule; reason free-form, then emit the structured artifact.

<a id="SELFCORRECT"></a>
**[SELFCORRECT] When Can LLMs Actually Correct Their Own Mistakes? A Critical Survey of Self-Correction of LLMs.** Kamoi, Zhang, Zhang, Han, Zhang. **TACL 2024**, arXiv:2406.01297. *Verified (June 2026, direct fetch).* No prior work shows reliable self-correction from *prompted* self-feedback; self-correction succeeds only where a **reliable external signal** is available (or after large-scale fine-tuning). Grounds: the reliability lever is an external deterministic check, not the model judging itself.

<a id="ATTRFIRST"></a>
**[ATTRFIRST] Attribute First, then Generate: Locally-attributable Grounded Text Generation.** Slobodkin, Hirsch, Cattan, Schuster, Dagan. **ACL 2024**, arXiv:2403.17104. *Verified (June 2026, direct fetch).* Selecting source evidence *before* generating (content-selection → planning → generation) yields locally-attributable text with **more concise, verifiable citations** at equal quality. Grounds: the evidence-first ordering rule and provenance-as-binding (cite the supporting span, then state the claim).

<a id="TRUSTALIGN"></a>
**[TRUSTALIGN] Measuring and Enhancing Trustworthiness of LLMs in RAG through Grounded Attributions and Learning to Refuse.** Song, Sim, Bhardwaj, Chieu, Majumder, Poria. **ICLR 2025 (Oral)**, arXiv:2409.11242. *Verified (June 2026, direct fetch).* An alignment method (Trust-Align) that rewards **grounded attribution and refusing when unsupported** materially raises measured trustworthiness across model families; plain prompting / in-context learning does not. Grounds: provenance-or-refuse — an unsupported claim should be withheld, not emitted.

<a id="CORRELATED"></a>
**[CORRELATED] Correlated Errors in Large Language Models.** Kim, Garg, Peng, Garg. **ICML 2025**, arXiv:2506.07962. *Verified (June 2026, direct fetch).* Across 350+ models, models **agree ~60% of the time when both are wrong**, and error-correlation persists across distinct architectures and providers and *grows* with capability — an "algorithmic monoculture" that undermines majority voting, ensembling, and LLM-as-judge. Grounds: do not treat agreement / voting / same-family self-critique as a correctness signal.

<a id="MINJA"></a>
**[MINJA] Memory Injection Attacks on LLM Agents via Query-Only Interaction (MINJA).** Dong, Xu, He, Li, Tang, Liu, Liu, Xiang. **NeurIPS 2025**, arXiv:2503.03704. *Verified (June 2026, OpenReview + search).* A query-only attacker injects malicious records into an agent's memory (~98% injection success; ~70–77% downstream attack success) that later fire on benign queries. Grounds **threat-motivated design, not a measured reliability gain**: the epistemic-stance boundary — durable memory/findings carry stance + provenance so a lower-stance or injected record cannot masquerade as authoritative. *The attack is measured; Swarm's defense against it is design, not a measured delta.*

<a id="SWEBENCH-ADQ"></a>
**[SWEBENCH-ADQ] Are "Solved Issues" in SWE-bench Really Solved Correctly? An Empirical Study.** Wang, Pradel, Liu. **ICSE 2026**, arXiv:2503.15223. *Verified (June 2026, venue + finding; figures per audit O-0).* Differential patch testing (PatchDiff) finds **7.8%** of "passing" patches fail the developer suite, inflating reported resolution rates by **~6.2 absolute points** (a "~14.5 pt" figure is fabricated — do not cite). Grounds: oracle adequacy — passing the bundled suite overstates correctness; require a stronger/independent oracle (the `verify` rationale).

<a id="UTBOOST"></a>
**[UTBOOST] UTBoost: Rigorous Evaluation of Coding Agents on SWE-Bench.** Yu, Zhu, He, Kang. **ACL 2025** (Anthology 2025.acl-long.189), arXiv:2506.09289. *Verified (June 2026, ACL Anthology + finding).* Generated tests uncovered **345 erroneous patches** wrongly labeled passed, impacting **40.9%** of SWE-Bench Lite and **24.4%** of SWE-Bench Verified leaderboard entries. Grounds (with [SWEBENCH-ADQ]): independent corroboration of SWE-bench oracle inadequacy.

<a id="SELFPREFER"></a>
**[SELFPREFER] LLM Evaluators Recognize and Favor Their Own Generations.** Panickssery, Bowman, Feng. **NeurIPS 2024**, arXiv:2404.13076. *Verified (June 2026, venue + finding).* An LLM evaluator scores its **own** outputs higher than human annotators judge they merit (self-preference), and the bias rises **linearly with the model's self-recognition** — its ability to tell its own text apart. Grounds: the implementer-≠-reviewer rule — an author MUST NOT render the `manual` judgment on its own output.

<a id="JUDGEBIAS"></a>
**[JUDGEBIAS] Judging LLM-as-a-Judge with MT-Bench and Chatbot Arena.** Zheng, Chiang, Sheng, Zhuang, Wu, Zhuang, Lin, Li, Li, Xing, Gonzalez, Stoica. **NeurIPS 2023 (Datasets & Benchmarks)**, arXiv:2306.05685. *Verified (June 2026, venue + finding).* Documents the structural biases of an LLM judge: **self-enhancement** (rates its own outputs more favourably), **position** (favours the first/last answer), and **verbosity** (favours longer answers). Grounds: judge bias is directional and predictable, so a `manual` verdict needs a recorded, independent, non-author judge.

## Verified — reused from the kernel bibliography

These were already verified by the framework's bibliography elsewhere; the entries below restate them so this layer is self-contained.

<a id="LOSTMID"></a>
**[LOSTMID] Lost in the Middle: How Language Models Use Long Contexts.** Liu et al., **TACL 2024**. The U-shaped attention curve — accuracy degrades for information in the middle of long contexts. (Per the kernel entry: "context rot" is a *later popular term*, not coined here; do not attribute it to this paper.) Grounds: the AGENTS.md density cap and the "minimize always-on context" discipline.

<a id="SCOT"></a>
**[SCOT] Structured Chain-of-Thought Prompting for Code Generation.** Li, Li, Li, Jin. **ACM TOSEM 34(2), Art. 37, 2025** (DOI 10.1145/3690635; preprint arXiv:2305.06599). *Verified (peer-reviewed; reused from the kernel bibliography.)* A *structured* intermediate (program-structured reasoning) beats free-form CoT for code generation (the paper reports +13.79% Pass@1). Grounds: a structured intermediate measurably beats free prose for downstream code work (the `lower` / IR rationale).

<a id="SMELLS"></a>
**[SMELLS] Rapid Quality Assurance with Requirements Smells.** Femmer, Méndez Fernández, Wagner, Eder. **Journal of Systems and Software 123 (2017): 190–213** (DOI 10.1016/j.jss.2016.02.047). *Verified (peer-reviewed; reused from the kernel bibliography.)* Lightweight lexical detection of requirements "smells" (vague terms, comparatives, …) is feasible but **precision is bounded** (the study reports roughly 48–59% precision at ~82–87% recall). Grounds: prose-smell checks are **advisory, never blocking** — only a defined grammar (the SOL layer) reaches blocking precision.

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

<a id="SPECKIT"></a>
**[SPECKIT] GitHub Spec Kit — Spec-Driven Development toolkit.** GitHub, 2025. *Verified (June 2026, repo + docs + GitHub blog).* Scaffolds **per-feature spec folders** — `specs/<NNN-feature>/` holding the spec + plan + tasks + research co-located — alongside a project-wide principles file (`memory/constitution.md`) and shared `templates/`; the flow is Spec → Plan → Tasks → Implement across 30+ agents. <https://github.com/github/spec-kit> · <https://github.github.com/spec-kit/> — *vendor toolkit; cite as convention, not a measured study.* Grounds: the per-feature `specs/<feature>/` home (a feature's supporting artifacts co-located with the spec they serve).

<a id="KIRO"></a>
**[KIRO] Amazon Kiro — spec-driven development.** AWS, 2025. *Verified (June 2026, kiro.dev/docs/specs).* Organizes each feature as `.kiro/specs/<feature>/` with `requirements.md` + `design.md` + `tasks.md`, and writes requirements in **EARS** (Easy Approach to Requirements Syntax) — the same controlled-clause shape Swarm's SOL uses. <https://kiro.dev/docs/specs/> — *vendor; cite as convention.* Grounds (with [SPECKIT]): the convergent per-feature-folder convention, and EARS as an established requirements-clause syntax.

<a id="ADR-CONV"></a>
**[ADR-CONV] Architecture Decision Records — the convention.** Nygard (2011); MADR template (adr.github.io); Fowler. *Verified (June 2026).* Decisions are recorded as short, immutable, **sequentially-numbered** Markdown files in a dedicated in-repo directory (`decisions/` or `docs/adr/`), one decision per file, superseded rather than rewritten. <https://adr.github.io/madr/> · <https://martinfowler.com/bliki/ArchitectureDecisionRecord.html> — *established convention.* Grounds: the project-wide `decisions/` home for ADRs and the supersession ledger.

<a id="DIATAXIS"></a>
**[DIATAXIS] Diátaxis — a systematic framework for technical documentation.** Procida. *Verified (June 2026, diataxis.fr).* Organizes documentation by user need into four distinct modes — tutorials, how-to guides, reference, explanation — kept separate because each serves a different purpose. <https://diataxis.fr/> — *reference framework.* Grounds: doc-organization-by-purpose (informs the skills / reference split; a full re-org of `docs/` was considered and declined as high-churn, low-payoff).

<a id="REDEFO"></a>
**[REDEFO] Requirements Development and Formalization for Reliable Code Generation: A Multi-Agent Vision.** Sun et al. (Weisong Sun, corresponding). **ASE 2025 (NIER track)**, arXiv:2508.18675. *Verified (June 2026, conf.researchr.org + arXiv).* A **vision** paper (New Ideas & Emerging Results — peer-reviewed venue, **no measured outcomes**): proposes Analyst + Formalizer agents that turn ambiguous NL requirements into **formal specifications** to bridge NL→code, with human-in-the-loop review at critical points. Cite as **design rationale / corroboration only** (never a measured `MUST`) — it corroborates the spec-as-contract + clarify-before-build direction; the *measured* grounding for that spine remains [PLANCODER]/[SEMAP]/[MAST]/[SMELLS].

## Caveated — non-peer-reviewed (cite ONLY as preliminary; never load-bearing)

Treated as the kernel treats its own non-peer-reviewed sources: usable to *illustrate* a direction, never to ground a `MUST`. Their headline statistics are single-author/blog measurements, not controlled peer-reviewed studies.

<a id="ACTIVATION-BLOG"></a>
**[ACTIVATION-BLOG] Why Claude Code Skills Don't Activate — And How to Fix It.** Seleznov, Medium, 2026. A self-published 650-trial measurement reporting directive descriptions activating far more reliably than passive ones (the "OR ≈ 20.6 / 100% activation" figures). **Non-peer-reviewed; the specific numbers are NOT load-bearing.** The *direction* (directive, exclusion-bearing descriptions help) is used only as illustration; the kernel's primary mechanism is "load what the task names" (§26.4), with description-match as the fallback.

### Preprints — web-verified arXiv (finding confirmed; cite as preliminary, never a `MUST`)

A web-verified arXiv preprint is stronger than a blog post but is **not peer-reviewed**: it may *corroborate* or *illustrate* a direction, never carry a `MUST`. Each finding below was confirmed against the source (June 2026).

<a id="AGENTSMD-HARM"></a>
**[AGENTSMD-HARM] Evaluating AGENTS.md.** Gloaguen, Mündler, Müller, Raychev, Vechev (ETH Zürich + LogicStar.ai). **arXiv:2602.11988** (preprint). *Verified (June 2026).* Two findings: (1) repository-specific commands are used far more often when **named** in the context file than when not (≈1.6×, *p*=0.01; ≈2.5×, *p*=0.05) — corroborates the Commands contract; (2) **over-specification hurts** — LLM-*generated* narrative context files reduced task success by ~3% while raising inference cost by **over 20%**, and even developer-written ones gave only a small gain at added cost. Its efficiency companion **(Lulla et al., arXiv:2601.20404) is a *contrasting* result** — developer-written `AGENTS.md` *reduced* runtime (~28.6%) and tokens (~16–20%); the two do not jointly establish "narrative is costly" and must not be cited as if they do. Grounds: the minimality / anti-bloat discipline (fewer, scoped, command-naming context files; not more narrative). *Where the `AGENTS.md > Commands` contract cites this (ADR-0018, ADR-0038), treat it as **corroborating** evidence — the contract's normative force rests on the [AGENTSMD-CONV] convention and the design reasoning, not on this preprint.*

<a id="FORMATTAX"></a>
**[FORMATTAX] The Format Tax.** Lee et al. **arXiv:2604.03616** (preprint). *Verified (June 2026).* The cost of format-restriction is paid mostly at the *prompt* (~−3.9pp), not the decoder (~−1.6pp); **decoupling** (reason free-form, then emit) recovers +6.8 / +9.2pp, and frontier models pay near-zero tax. Corroborates [FORMATFREE]; grounds the reason-then-emit rule.

<a id="EVIBOUND"></a>
**[EVIBOUND] Evidence-Bound Autonomous Research.** Chen. **arXiv:2511.05524** (preprint; small N=8 — illustrative). *Verified (June 2026).* Prompt-only completion governance produced ~100% hallucinated "done" claims; **dual machine-checkable gates drove that to 0%**. Illustrates: bind "done"/"true" to a checkable evidence anchor, not a prose assertion.

<a id="SWESKILLS"></a>
**[SWESKILLS] SWE-Skills-Bench.** Han et al. **arXiv:2603.15401** (preprint). *Verified (June 2026).* Of 49 candidate skills, **39 gave zero improvement and 3 actively degraded performance (−9 to −10pp)** via stale / version-mismatched guidance and "template interference." Grounds: staleness/conflict lint + minimality (an inert or stale doc is a liability, not a neutral addition).

<a id="ORACLESWE"></a>
**[ORACLESWE] ORACLE-SWE.** Li et al. **arXiv:2604.07789** (preprint). *Verified (June 2026).* A **reproduction test** is far more valuable than prose plans for issue resolution (plans were not worth isolating as a signal). Grounds: machine-*checkable*/executable evidence beats machine-*readable* prose.

<a id="CITECHECK"></a>
**[CITECHECK] Citation-resolution checking.** Rao et al. **arXiv:2604.03173**; CiteGuard **arXiv:2510.17853** (preprints). *Verified (June 2026).* An automated citation-resolving checker cut non-resolving citations **16%→0.6% (≈26×)** and **6.1%→0.1% (≈79×)**, *p*<10⁻³⁵; LLMs otherwise fabricate **78–90%** of citations, and structured validation recovers near-human accuracy. Grounds: provenance pays off only when an automated pass **resolves the referent** (provenance must be lint-enforced, not a convention).

<a id="NOFREE"></a>
**[NOFREE] No Free Labels.** **arXiv:2503.05061** (preprint). *Verified (June 2026).* LLM-judge / reward-model agreement collapses (κ ≈ 0.86 → 0.30) without a reference answer. Grounds: an LLM judge without a grounded reference is not a verifier.

<a id="CONSENSUS"></a>
**[CONSENSUS] Consensus is Not Verification.** **arXiv:2603.06612** (preprint). *Verified (June 2026).* Multi-agent voting / self-consistency **amplifies shared errors** rather than catching them. Grounds (with [CORRELATED]): consensus is not a correctness signal.

<a id="MULTITURN-LOST"></a>
**[MULTITURN-LOST] LLMs Get Lost in Multi-Turn Conversation.** **arXiv:2505.06120** (preprint). *Verified (June 2026).* Multi-turn performance drops ~39% with a ~112% rise in unreliability, triggered by **under-specification**. Affirms: keep load-bearing meaning on a stable, typed surface, re-read each pass; prose is an unreliable cross-turn carrier.

<a id="MAST"></a>
**[MAST] Multi-Agent System failure Taxonomy (MAST).** Cemri et al. **arXiv:2503.13657** (preprint; venue unconfirmed). *Verified (June 2026; finding confirmed, venue not).* 14 failure modes across three categories — **system-design & specification ≈41.8%, inter-agent misalignment ≈36.9%, verification ≈21.3%** (so specification + verification ≈ 63%). *Note (audit O-0):* the first category is "System Design / poor specification," not "Specification" alone. Grounds: why Swarm hardens the specification and verification layers; the inter-agent contract gap.

<a id="SEMAP"></a>
**[SEMAP] Structured/contract-based multi-agent protocol (SEMAP).** Mao et al. **arXiv:2510.12120** (preprint). *Verified (June 2026).* Contracts + structured inter-agent messaging + lifecycle verification cut failures **64–70%**, with the largest single win in **under-specification (71–73%)**. Grounds: the SOL/contract + verification-gate spine; the inter-agent coordination contract.

<a id="REPORTLOGIC"></a>
**[REPORTLOGIC] Agent-report quality axis.** **arXiv:2602.18446** (preprint). *Verified (June 2026).* A primary quality axis of an agent's report is an explicit **claim → support** structure. Grounds: the evidence-before-conclusion / claim-must-carry-evidence rule for findings and audits.

<a id="PLANCODER"></a>
**[PLANCODER] Understanding and Bridging the Planner-Coder Gap.** Lyu et al. **arXiv:2510.10460** (preprint). *Verified (June 2026, audit O-0).* The planner→coder gap "accounts for **75.3%** of failures"; semantic-preserving input mutations break 7.9–83.3% of previously-solved problems; a monitor agent repairs 40–89%. Grounds: the planner→coder handoff is the dominant multi-agent code-gen failure surface (the `lint`/`lower` CLARIFY-gate rationale).

<a id="VERINA"></a>
**[VERINA] VERINA: Benchmarking Verifiable Code Generation.** Ye et al. **arXiv:2505.23135** / OpenReview (preprint; *not* ICML 2025). *Verified (June 2026, audit O-0).* On 189 Lean tasks the best model (o3) reached 72.6% code / 52.3% spec but **a mere 4.9% end-to-end proof success** (one trial). Grounds: one-shot LLM proof is near-total failure → staged/assisted verification (the `verify` rationale).

<a id="VERICODING"></a>
**[VERICODING] A Benchmark for Vericoding: Formally Verified Program Synthesis.** Bursuc et al. **arXiv:2509.22908** (preprint). *Verified (June 2026, audit O-0).* ~12,504 specs; best-approach success is **language-specific — Dafny 82% (68%→96% over a year), Verus 44%, Lean 27%**. Cite the language-specific framing only; do NOT generalize to "mechanized proof is no longer single-digit" (Lean is still 27%, consistent with [VERINA]'s 4.9%).

<a id="HILBENCH"></a>
**[HILBENCH] HiL-Bench: Do Agents Know When to Ask for Help?** **arXiv:2604.09408** (preprint; not yet peer-reviewed). *Verified (June 2026).* Frontier agents solve up to ~89% of SWE/SQL tasks with full info, but on messy/ambiguous specs the best model drops to **~24% even when given a tool to ask for help**. Grounds: agents don't reliably self-clarify → clarify-before-lower (the CLARIFY-gate rationale).

## Rejected — DO NOT CITE (fabricated / misattributed / unconfirmed)

The skill-authoring literature attributes load-bearing figures to these arXiv ids. **Direct fetch (June 2026) found each id resolves to an unrelated paper.** They are recorded here so the fabrication is never re-introduced (per the kernel's reject discipline).

| Circulating claim | Cited as | What the id actually is | Verdict |
| --- | --- | --- | --- |
| "21× degradation when file-based state externalization is removed" (InfiAgent) | arXiv:2511.10954 | *Kapitza-Dirac interference of Higgs waves in superconductors* (condensed-matter physics) | **REJECTED — misattributed; the 21× figure is unverifiable and MUST NOT be cited.** File-state externalization is instead grounded on [CTXENG] + [CCTASKS] + [SCRATCHPAD]. |
| "fixed turn limit at p75 cuts cost 24–68%" (More with Less) | arXiv:2510.27502 | *Reference Equations of State for Density Prediction in Regasified LNG Mixtures* (chemical physics) | **REJECTED — misattributed.** |
| "agentic failures are overwhelmingly context failures" (PAACE) | arXiv:2511.21345 | *Blind Turbo Demodulation for Differentially Encoded OFDM* (signal processing) | **REJECTED — misattributed** (the source that circulated it flagged it as unverified). |

**Also do-not-cite-as-fact (web-checked June 2026):**

- **"17.1% performance drop / a 7B model beats a 70B model" under format restriction** — traced only to a vendor blog with **no primary source**; **unconfirmed**. (The peer-reviewed version of this direction is [FORMATFREE].)
- **Piskala, "50% error reduction / 75% cycle-time" from spec-driven development (arXiv:2602.00180)** — position/survey, secondhand and uncontrolled; **not a measured result.**
- **Registered reports with no results yet** — *Spec-Driven Code Generation* (arXiv:2601.03878) and *Specification as a Quality Gate* (arXiv:2603.25773) report **no measured outcomes** (design/protocol/opinion only); cite as design rationale at most, never as evidence.
- **The "Tessl / Guillermo Rauch / specs-are-the-new-code" attribution** — **mistaken** (no evidence Rauch is associated with it); do not repeat it.

---

*Discipline: a claim in `docs/research/` cites a Verified entry, or carries an explicit "preliminary / non-peer-reviewed" caveat naming a Caveated entry, or it is not made. New sources are web-verified before they are added. This follows the framework's §0.7 evidence discipline.*
