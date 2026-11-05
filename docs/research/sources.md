# Sources — Corpus's evidence bibliography

> This is the single bibliography Corpus's **inline `[[KEY]]` citations resolve to**. Research is referenced *contextually* — each `[[KEY]]` sits in the doc whose claim it grounds (the method, the formats, and the ADRs) and links to its entry here; dated research records beside this file ([index](README.md)) hold the studies and tests behind recent decisions, and this ledger stays the only citation target. It is held to one discipline ("real science, not astrology" — [principles](../method.md#principles), *Preserve source limits*): every load-bearing empirical claim cites a **verified** entry below, with the recorded caveats. Entries marked **caveated** (non-peer-reviewed) MUST NOT carry a `MUST`-level claim. Entries in **Rejected** MUST NOT be cited — they are recorded so a fabricated citation is never silently re-introduced.
>
> Entries are retained even while uncited: the ledger records what was verified and what was rejected so future claims can bind to it without re-verification. An uncited entry is inventory, not error. This bibliography was assembled after web verification in June 2026. Several headline figures circulating in the skill-authoring literature rested on fabricated or misattributed arXiv ids and were rejected below.

---

## Verified — primary research (peer-reviewed, finding confirmed)

<a id="TREEOFTHOUGHTS"></a>
**[TREEOFTHOUGHTS] Tree of Thoughts: Deliberate Problem Solving with Large Language Models.** Yao, Yu, Zhao, Shafran, Griffiths, Cao, Narasimhan. **NeurIPS 2023**, arXiv:2305.10601. *Verified (June 2026, direct fetch).* On **Game of 24**, GPT-4 with chain-of-thought solved **4%** of tasks; Tree-of-Thoughts reached **74%**. Grounds: deliberate planning and search over flat generation.

<a id="REFLEXION"></a>
**[REFLEXION] Reflexion: Language Agents with Verbal Reinforcement Learning.** Shinn, Cassano, Berman, Gopinath, Narasimhan, Yao. **NeurIPS 2023**, arXiv:2303.11366. *Verified (June 2026, direct fetch — abstract states the figure verbatim).* Verbal self-reflection between trials yields **91% pass@1 on HumanEval vs the 80% GPT-4 baseline**. Grounds: recording decisive evidence makes an implicit signal checkable.

<a id="SCRATCHPAD"></a>
**[SCRATCHPAD] Show Your Work: Scratchpads for Intermediate Computation with Language Models.** Nye, Andreassen, Gur-Ari, Michalewski, Austin, Bieber, Dohan, Lewkowycz, Bosma, Luan, Sutton, Odena. **ICLR 2022 Workshop (DL4C)**, arXiv:2112.00114. *Verified (June 2026; venue is a workshop poster, not a main-conference acceptance — audit O-1).* Emitting intermediate steps to a "scratchpad" **dramatically improves** multi-step computation (long addition → program execution). Grounds: externalising intermediate work when it changes execution or reviewability.

<a id="PLANSOLVE"></a>
**[PLANSOLVE] Plan-and-Solve Prompting: Improving Zero-Shot Chain-of-Thought Reasoning.** Wang, Xu, Lan, Hu, Lan, Lee, Lim. **ACL 2023**, arXiv:2305.04091. *Verified (June 2026, direct fetch).* Devise a plan that divides the task into subtasks, then execute it; **consistently outperforms zero-shot CoT** across arithmetic/commonsense/symbolic reasoning. Grounds: plan before execution when the work needs decomposition.

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
**[MINJA] Memory Injection Attacks on LLM Agents via Query-Only Interaction (MINJA).** Dong, Xu, He, Li, Tang, Liu, Liu, Xiang. **NeurIPS 2025**, arXiv:2503.03704. *Verified (June 2026, OpenReview + search).* A query-only attacker injects malicious records into an agent's memory (~98% injection success; ~70–77% downstream attack success) that later fire on benign queries. Grounds **threat-motivated design, not a measured reliability gain**: a native memory needs evidence, applicability boundaries, and correction so an injected record cannot masquerade as authoritative. *The attack is measured; Corpus's defense against it is design, not a measured delta.*

<a id="SWEBENCH-ADQ"></a>
**[SWEBENCH-ADQ] Are "Solved Issues" in SWE-bench Really Solved Correctly? An Empirical Study.** Wang, Pradel, Liu. **ICSE 2026**, arXiv:2503.15223. *Verified (June 2026, venue + finding; figures per audit O-0).* Differential patch testing (PatchDiff) finds **7.8%** of "passing" patches fail the developer suite, inflating reported resolution rates by **~6.2 absolute points** (a "~14.5 pt" figure is fabricated — do not cite). Grounds: oracle adequacy — passing the bundled suite overstates correctness; require a stronger/independent oracle (the `verify` rationale).

<a id="UTBOOST"></a>
**[UTBOOST] UTBoost: Rigorous Evaluation of Coding Agents on SWE-Bench.** Yu, Zhu, He, Kang. **ACL 2025** (Anthology 2025.acl-long.189), arXiv:2506.09289. *Verified (June 2026, ACL Anthology + finding).* Generated tests uncovered **345 erroneous patches** wrongly labeled passed, impacting **40.9%** of SWE-Bench Lite and **24.4%** of SWE-Bench Verified leaderboard entries. Grounds (with [SWEBENCH-ADQ]): independent corroboration of SWE-bench oracle inadequacy.

<a id="SELFPREFER"></a>
**[SELFPREFER] LLM Evaluators Recognize and Favor Their Own Generations.** Panickssery, Bowman, Feng. **NeurIPS 2024**, arXiv:2404.13076. *Verified (June 2026, venue + finding).* An LLM evaluator scores its **own** outputs higher than human annotators judge they merit (self-preference), and the bias rises **linearly with the model's self-recognition** — its ability to tell its own text apart. Grounds: the implementer-≠-reviewer rule — an author MUST NOT render the `manual` judgment on its own output.

<a id="JUDGEBIAS"></a>
**[JUDGEBIAS] Judging LLM-as-a-Judge with MT-Bench and Chatbot Arena.** Zheng, Chiang, Sheng, Zhuang, Wu, Zhuang, Lin, Li, Li, Xing, Gonzalez, Stoica. **NeurIPS 2023 (Datasets & Benchmarks)**, arXiv:2306.05685. *Verified (June 2026, venue + finding).* Documents the structural biases of an LLM judge: **self-enhancement** (rates its own outputs more favourably), **position** (favours the first/last answer), and **verbosity** (favours longer answers). Grounds: judge bias is directional and predictable, so a `manual` verdict needs a recorded, independent, non-author judge.


<a id="CLARIFYGPT"></a>
**[CLARIFYGPT] ClarifyGPT: A Framework for Enhancing LLM-Based Code Generation via Requirements Clarification.** Mu et al. **FSE 2024** (Proc. ACM Softw. Eng., DOI 10.1145/3660810), arXiv:2310.10996. *Verified (June 2026, direct fetch + adversarial re-verification, 4/4 votes).* Detecting requirement ambiguity (code-consistency check), asking targeted clarifying questions, then regenerating raises GPT-4 Pass@1 **70.96%→80.80%** on MBPP-sanitized (human eval, n=10) and **68.02%→75.75%** average across four benchmarks (simulated users; simulation has ground-truth access — treat gains as an upper bound). Grounds: disambiguated requirement text measurably improves first-pass correctness — the mechanism a short curated spec front-loads.

<a id="SPECFIX"></a>
**[SPECFIX] Automated Repair of Ambiguous Problem Descriptions for LLM-Based Code Generation.** Jia, Morris, Ye, Sarro, Mechtaev. **ASE 2025**, arXiv:2505.07270. *Verified (June 2026, direct fetch + adversarial re-verification, 4/4 votes).* Repairing only the requirement TEXT (no interaction) modified **43.58%** of benchmark descriptions and improved Pass@1 on the modified subset by **30.9%** (+4.09% absolute benchmark-wide); repaired descriptions transfer across models (**+10.48%**). Grounds: clarified requirement text is model-agnostic and can improve correctness. Scope caveat: function-level benchmarks, not repo-level workflows.

<a id="HUMANEVALCOMM"></a>
**[HUMANEVALCOMM] HumanEvalComm: Benchmarking the Communication Competence of Code Generation for LLMs and LLM Agents.** Wu, Fard. **ACM TOSEM 2025**, arXiv:2406.00215. *Verified (June 2026, direct fetch + adversarial re-verification, 2/2 votes; Table-4 figures confirmed).* Injecting ambiguity/incompleteness into HumanEval drops Pass@1 **35–52%** (ChatGPT 65.58%→33.77% ambiguity, →27.95% incompleteness); **>60%** of model responses code anyway instead of asking. Boundary finding: a clarification-forcing agent on ALREADY-CLEAR tasks scored 27.45% vs 65.58% — indiscriminate process on clear tasks measurably hurts. Grounds: requirement clarity is load-bearing; indiscriminate *clarification-forcing* on clear tasks measurably hurts — the extension to documents/process generally is design rationale, not a measured result.

<a id="CATALDI-AI-REVIEW"></a>
**[CATALDI-AI-REVIEW] Perceptions and challenges of AI-driven code reviews: A qualitative exploration of developer experiences.** Cataldi. **Issues in Information Systems 26(2):346–360, 2025**, DOI 10.48009/2_iis_127. *Verified (June 2026, direct fetch).* Semi-structured interviews with 10 developers, technical leads, and architects; thematic analysis found trust, reliability, and lack of context understanding as dominant concerns, with participants advocating for transparent, context-aware AI tools that augment rather than replace human reviewers. Grounds: the need for structured human oversight and explainable review artifacts in AI-assisted workflows.

<a id="OVERTRUST-CFF"></a>
**[OVERTRUST-CFF] To Trust or to Think: Cognitive Forcing Functions Can Reduce Overreliance on AI in AI-assisted Decision-making.** Buçinca, Malaya, Gajos. **Proc. ACM Human-Computer Interaction 5, CSCW1 (2021)** (DOI 10.1145/3449287), arXiv:2102.09692. *Verified (June 2026, web search — Harvard/EECS listings + abstract).* In AI-assisted decision-making, **cognitive forcing functions** — lightweight interventions that interrupt automatic acceptance at the moment of decision (ask the human to decide before seeing the AI's answer; add a brief wait; make the human request the recommendation) — reduced over-reliance on **incorrect** AI advice **more than explanations did**; simply adding explanations did not reliably help. Grounds: a handoff that routes a decision should add a *light* forcing function (what it blocks; decide-before-accepting), not just more justification prose — explanation alone does not cure over-trust.

<a id="CHOICEOVERLOAD"></a>
**[CHOICEOVERLOAD] Choice overload is conditional, not a law of option count.** Two peer-reviewed meta-analyses: Scheibehenne, Greifeneder & Todd, *Can There Ever Be Too Many Options? A Meta-Analytic Review of Choice Overload*, **Journal of Consumer Research 37(3):409–425, 2010** (63 conditions, N≈5,036) — the mean effect of assortment size on choice overload is **virtually zero** with large between-study variance, no sufficient conditions identified; and Chernev, Böckenholt & Goodman, *Choice Overload: A Conceptual Review and Meta-Analysis*, **Journal of Consumer Psychology 25(2):333–358, 2015** (99 observations) — overload emerges only under four moderators: **choice-set complexity, decision-task difficulty, preference uncertainty, decision goal**. *Verified (June 2026, web search — JCR/JCP listings + author PDFs).* Grounds: the *number* of options is not the lever — a hard count cap is unsupported; what drives overload is decision **difficulty**, so the fix is **comparable, well-structured options**, not a tally (2–4 is a soft heuristic, never a measured optimum).

<a id="ALGOAVERSION"></a>
**[ALGOAVERSION] Algorithm Aversion: People Erroneously Avoid Algorithms After Seeing Them Err.** Dietvorst, Simmons, Massey. **Journal of Experimental Psychology: General 144(1):114–126, 2015.** *Verified (June 2026, web search).* After seeing an algorithm make a mistake, people lose confidence in it and revert to (worse) human judgment faster than they would after an equivalent human error — even when the algorithm still outperforms. Grounds: the *second* failure mode a decision handoff must guard against — once an agent errs once, the human over-discounts it; so a handoff pairs the recommendation with the case **for and against**, letting the human re-engage rather than reflexively reject.

<a id="AICODE-INSECURE"></a>
**[AICODE-INSECURE] Do Users Write More Insecure Code with AI Assistants?** Perry, Srivastava, Kumar, Boneh. **ACM CCS 2023** (DOI 10.1145/3576915.3623157), arXiv:2211.03622. *Verified (June 2026, web search — ACM DL + author repository).* In a controlled user study, participants with access to an AI coding assistant **wrote less secure code** on most tasks **yet rated their insecure answers as more secure** than the control group. Grounds: the over-trust failure mode is documented in the **developer** domain specifically — confidence rises while quality falls — so a decision handoff to a developer is not a foreign transplant from clinical/lay-user studies; the mechanism appears at the keyboard.

<a id="RELYORNOT"></a>
**[RELYORNOT] To Rely or Not to Rely? Evaluating Interventions for Appropriate Reliance on Large Language Models.** Bo, Wan, Anderson. **Proc. 2025 CHI Conference on Human Factors in Computing Systems** (DOI 10.1145/3706598.3714097), arXiv:2412.15584. *Verified (June 2026, web search — arXiv + researchr bibtex for authorship).* Across the studied interventions, the aids **reduced over-reliance but generally did not improve *appropriate* reliance**, and people were *more* confident when over- or under-relying than when calibrated. Grounds: the honest ceiling on the decision-handoff convention — structured decision support reduces blind acceptance but is **not a proven cure** for miscalibrated trust; adopt it as a reasoned convention, not an established win.

<a id="ZHENG-PERSONA"></a>
**[ZHENG-PERSONA] When "A Helpful Assistant" Is Not Really Helpful: Personas in System Prompts Do Not Improve Performances.** Zheng, Pei, Jurgens, et al. **EMNLP 2024 (Findings)**, arXiv:2311.10054. *Verified (June 2026, deep-research direct fetch + 3-vote).* Across **162 roles, 4 LLM families, and 2,410 factual questions**, adding a persona to the system prompt did **not** systematically improve accuracy over a no-persona control, and the per-persona effect is **essentially random**. Grounds: role identity is not a reliable accuracy lever; concrete directives matter.

<a id="KONG-ROLEPLAY"></a>
**[KONG-ROLEPLAY] Better Zero-Shot Reasoning with Role-Play Prompting.** Kong, Zhang, Wang, et al. **NAACL 2024**, arXiv:2308.07702. *Verified (June 2026, deep-research direct fetch + 3-vote).* Role-play prompting beat standard zero-shot across most of **twelve** reasoning benchmarks (e.g. Last-Letter **23.8%→84.2%**, AQuA **53.5%→63.8%**); the authors frame the gain as an implicit chain-of-thought trigger. Grounds: role *framing* helps via the task-relevant procedure it evokes — which can live in the work guide — not via the identity (ADR-0093).

<a id="DIBIASE19"></a>
**[DIBIASE19] The effects of change decomposition on code review — a controlled experiment.** di Biase, Bruntink, van Deursen, Bacchelli. **PeerJ Computer Science 5:e193, 2019**, DOI 10.7717/peerj-cs.193. *Verified (June 2026, web — PeerJ + PMC mirror).* A controlled experiment (n=28): decomposing a tangled change into coherent parts leads reviewers to report **fewer wrongly reported issues (false positives)** and to seek more context, while the **number of defects found is unchanged**. Grounds: untangling buys *cleaner* reviews, not *more* bugs caught — the honest reason to split work (ADR-0094).

<a id="MOCKUS00"></a>
**[MOCKUS00] Predicting risk of software changes.** Mockus & Weiss. **Bell Labs Technical Journal 5(2):169–180, 2000**, DOI 10.1002/bltj.2229. *Verified (June 2026, web — DOI + author bib; OA mirror mockus.org/papers/bltj13.pdf).* Models the probability a change induces a failure as a function of change **size**, **diffusion** (files / modules / subsystems touched), developer experience, and **change type** (fault-fix vs new code); diffusion and experience are essential predictors (directional, no point thresholds). Grounds: weight review scrutiny by diffusion and change-type, not by greenfield-vs-brownfield (ADR-0094).

<a id="PURUSHOTHAMAN05"></a>
**[PURUSHOTHAMAN05] Toward Understanding the Rhetoric of Small Source Code Changes.** Purushothaman & Perry. **IEEE TSE 31(6):511–526, 2005**, DOI 10.1109/TSE.2005.74. *Verified (June 2026, web — author PDF + DBLP).* A one-line change has **under ~4% probability** of introducing an error, but **~40% of fault-fix changes introduce one or more new defects**. Grounds: fault-fixes are disproportionately fault-inducing → concentrate scrutiny on modification/fix changes (ADR-0094).

<a id="GRAVES00"></a>
**[GRAVES00] Predicting fault incidence using software change history.** Graves, Karr, Marron, Siy. **IEEE TSE 26(7):653–661, 2000**, DOI 10.1109/32.859533. *Verified (June 2026, web — CrossRef + NISS TR; finding is qualitative).* Process measures from the change history predict faults better than product metrics of the code: the **number of times code has been changed (churn) predicts faults better than its size (LOC)**. Grounds: churn, not length, marks the risky loci a reviewer should weight (ADR-0094).

<a id="HINDLE11"></a>
**[HINDLE11] Got Issues? Do New Features and Code Improvements Affect Defects?** Posnett, Hindle & Devanbu. **WCRE 2011, pp. 211–215**, DOI 10.1109/WCRE.2011.33. *Verified (June 2026, web — author PDF + DBLP).* **Counter-evidence:** neither new features nor improvements have a significant effect on later defect counts **once size and total number of changes are controlled** — size/churn dominates, not new-vs-modified (scope: 4 Apache Java projects; the authors partly attribute the null to careful review of new features). Grounds: the Hindle caveat — never let "greenfield/net-new" justify skipping review on a large or high-diffusion change (ADR-0094).

<a id="BOSU15"></a>
**[BOSU15] Characteristics of Useful Code Reviews: An Empirical Study at Microsoft.** Bosu, Greiler, Bird. **MSR 2015, pp. 146–156**, DOI 10.1109/MSR.2015.21. *Verified (June 2026, web — MSR PDF + abstract).* The **more files in a change, the lower the proportion of review comments that are useful** to the author (direction only, no point estimate). Grounds: files-touched is a first-class size signal for the oversized-packet heuristic — a sprawling change degrades review quality (ADR-0094).

<a id="REVIEWPRIMING"></a>
**[REVIEWPRIMING] Primers or reminders? The effects of existing review comments on code review.** Spadini, Calikli, Bacchelli. **ICSE 2020, pp. 1171-1182**, DOI 10.1145/3377811.3380385. *Verified (July 2026, Chalmers publication record).* Controlled experiment with 85 developers: visible prior comments increased detection of another uncommon bug of the same type and did not reduce detection of other bug types. Grounds: withholding prior review prose may preserve method independence, but broad harmful priming is not an established outcome.

<a id="RIGBY13"></a>
**[RIGBY13] Convergent Contemporary Software Peer Review Practices.** Rigby & Bird. **ESEC/FSE 2013, pp. 202–212**, DOI 10.1145/2491411.2491444. *Verified (June 2026, web — MSR author PDF, text-extracted).* Across drastically different projects, modern review **converged on small changes** — median *change* sizes of tens of lines (e.g. Android/AMD 44, Chrome 78; vs the prior-OSS Apache 25 / Linux 32 contrast and traditional inspection's 263). Grounds: small, self-contained units are the field-convergent norm a task should target (ADR-0094).

<a id="MANTYLA09"></a>
**[MANTYLA09] What Types of Defects Are Really Discovered in Code Reviews?** Mäntylä & Lassenius. **IEEE TSE 35(3):430–448, 2009**, DOI 10.1109/TSE.2008.71. *Verified (June 2026, web — Aalto repository PDF).* Of 759 classified review defects (388 industrial + 371 student), **roughly 75% do not affect visible functionality** — they are *evolvability* defects (documentation, structure, readability) that execution-based QA cannot detect (confirming Siy & Votta). Grounds: review's primary payload is the maintainability/design layer tests are blind to (ADR-0095).

<a id="BACCHELLI13"></a>
**[BACCHELLI13] Expectations, Outcomes, and Challenges of Modern Code Review.** Bacchelli & Bird. **ICSE 2013, pp. 712–721**, DOI 10.1109/ICSE.2013.6606617. *Verified (June 2026, web — author PDF).* Over 570 Microsoft review comments, **defect comments are a minority (~14%, 4th of nine categories)** while code-improvement comments dominate (~29%); review's outcomes are less about finding errors than expected and also deliver knowledge transfer and team awareness. Grounds: foreground evolvability/design findings as first-class; defect-catching is one outcome among several (ADR-0095).

<a id="MCINTOSH14"></a>
**[MCINTOSH14] The Impact of Code Review Coverage and Participation on Software Quality** (Qt, VTK, ITK). McIntosh, Kamei, Adams, Hassan. **MSR 2014, pp. 192–201**, DOI 10.1145/2597073.2597076. *Verified (June 2026, web — author/ACM).* Coverage and participation each independently bear on quality: low coverage is estimated to add up to **two** post-release defects, **low participation up to five** — "coverage alone does not guarantee" quality. Grounds: substantive participation matters; a sign-off alone does not establish review quality (ADR-0095).

<a id="GPTDROID"></a>
**[GPTDROID] Make LLM a Testing Expert (GPTDroid): Human-like Mobile GUI Testing.** Liu, Chen, Wang, et al. **ICSE 2024, pp. 1222–1234**, DOI 10.1145/3597503.3639180 (arXiv:2310.15780). *Verified (June 2026, web — arXiv).* An LLM agent driving live Google Play apps found **53 new bugs, of which 35 were confirmed and fixed** by developers. Grounds: an agent exercising the running app surfaces real defects — valuable as *evidence*, judged by a human/independent reviewer (ADR-0095).

<a id="ITKONEN14"></a>
**[ITKONEN14] Are test cases needed? Replicated comparison between exploratory and test-case-based software testing.** Itkonen & Mäntylä. **Empirical Software Engineering 19(2):303–342, 2014**, DOI 10.1007/s10664-013-9266-8. *Verified (June 2026, web — Springer).* A replicated experiment (51 students, jEdit): **no statistically significant difference in defect-detection effectiveness** between exploratory and scripted testing (p=0.093); exploratory is more *efficient* (less design effort) and scripted yields more false positives. *Scope: a student experiment; non-significant ≠ proven equivalence.* Grounds: exercising the app (exploratory) is a legitimate verifier mode, not inferior to scripted (ADR-0095).

<a id="WEBAGENTILLUSION"></a>
**[WEBAGENTILLUSION] An Illusion of Progress? Assessing the Current State of Web Agents.** Xue et al. (OSU-NLP). **COLM 2025**, arXiv:2504.01382. *Verified (June 2026, web — arXiv/OpenReview).* On Online-Mind2Web (300 realistic tasks, 136 sites, human-judged), the best agents reach ~61% (Operator) / 56% (Claude Computer Use 3.7) while **most cluster around ~30%** — driving live web UIs reliably is still limited. Grounds: an agent's app-run is unreliable → it is evidence for a human to judge, never an autonomous verdict (ADR-0095).

<a id="DOCROT"></a>
**[DOCROT] Detecting outdated code element references in software repository documentation.** Tan, Wagner, Treude. **Empirical Software Engineering 29:5, 2024**, DOI 10.1007/s10664-023-10397-6 (companion tool paper arXiv:2307.04291). *Verified (June 2026, web — OA journal PDF).* Across >3,000 GitHub projects (the 1,000 most-starred + Google's), **28.9% currently contain at least one outdated code-element reference**, and 82.3% were outdated at least once historically. *Scope: top-by-stars + Google repos — not generalizable to all docs.* Grounds: doc rot is measurable and common; maintained documentation needs ownership and freshness rather than write-once treatment.

<a id="CODECOMMENTCOEVO"></a>
**[CODECOMMENTCOEVO] A Large-Scale Empirical Study on Code-Comment Inconsistencies.** Wen, Nagy, Bavota, Lanza. **ICPC 2019**, DOI 10.1109/ICPC.2019.00019 (author PDF, inf.usi.ch). *Verified (June 2026, web — ICPC proceedings + author PDF).* Code and its comments **co-evolve only rarely**: a code change triggers a corresponding comment change in just **13–20% of cases** (≈7% for method comments, ≈13% for class comments). Grounds: documentation drifts silently because it is seldom updated with the code it describes; maintained docs benefit from ownership and mechanical reference checks.

<a id="DOCPERSPECTIVE"></a>
**[DOCPERSPECTIVE] Software Documentation: The Practitioners' Perspective.** Aghajani, Nagy, Linares-Vásquez, Moreno, Bavota, Lanza, Shepherd. **ICSE 2020**, DOI 10.1145/3377811.3380405. *Verified (June 2026, web — author PDF inf.usi.ch + ICSE proceedings).* A survey of **146 practitioners** ranking documentation issues by perceived relevance found **superfluous/bloated content (55%)** and **clone/duplicate content (46%)** among the top maintainability concerns. Grounds: bloat and duplication are *measured* top documentation failures → the anti-bloat / single-sourcing discipline rests on the failure data, not on an unproven "minimal docs co-evolve better" claim (ADR-0108, ADR-0096).

<a id="COMMENTSONCOMMENTS"></a>
**[COMMENTSONCOMMENTS] Comments on Comments: Where Code Review and Documentation Meet.** Rao et al. **MSR 2022**, arXiv:2204.00107. *Verified (June 2026, web — ar5iv full text).* Reviewers comment on a diff chunk **50.8%** of the time when a code comment was changed vs **15.8%** when only code changed (a documentation touch ≈**3.2×** the reviewer attention); a reviewer comment on a changed code comment leads to that comment being updated **76.4% (46K/61K)** of the time. Grounds: review-on-touch is the cadence that keeps docs current — a doc change pulls reviewer scrutiny and that scrutiny lands the update (ADR-0108).

<a id="CRITIC-TOOL"></a>
**[CRITIC-TOOL] CRITIC: Large Language Models Can Self-Correct with Tool-Interactive Critiquing.** Gou, Shao, Gong, Shen, Yang, Duan, Chen. **ICLR 2024**, arXiv:2305.11738. *Verified (July 2026, direct fetch — venue + thesis; Table-2 figures via the roadmap-verification pass).* A matched ablation isolates the lever: on GSM8k (text-davinci-003) tool-grounded critique lifts solve-rate **+2.1** (PoT 70.1 → 72.2), while the identical pipeline **without** the tool DROPS it **−1.8** (to 68.3) — free-form self-critique falls *below* the initial answer. Grounds: a review judgment must rest on a reliable external signal, not the model's own unsupported critique (ADR-0121, ADR-0095).

<a id="NOSELFCORRECT"></a>
**[NOSELFCORRECT] Large Language Models Cannot Self-Correct Reasoning Yet.** Huang, Chen, Mishra, Zheng, Yu, Song, Zhou. **ICLR 2024**, arXiv:2310.01798. *Verified (July 2026, direct fetch — venue + thesis; figures via the roadmap-verification pass).* Without an external signal, intrinsic self-correction **degrades**: GSM8K **75.9 → 75.1 → 74.7** across rounds; CommonSenseQA **75.8 → 38.1**. Grounds (with [CRITIC-TOOL], [SELFCORRECT]): ungrounded self-critique is not a correctness signal — the reliability comes from the external check, not the model re-judging itself (ADR-0121).

<a id="AGENTPOISON"></a>
**[AGENTPOISON] AgentPoison: Red-teaming LLM Agents via Poisoning Memory or Knowledge Bases.** Chen, Xiang, Xiao, Song, Li. **NeurIPS 2024** (per OpenReview; not shown on the arXiv abstract page), arXiv:2407.12784. *Verified (July 2026, direct fetch — title + headline figures; venue per secondary source).* An optimized-trigger backdoor on an agent's long-term memory / RAG store reaches **>80% average attack-success at a <0.1% poison rate** with **<1%** benign degradation, across autonomous-driving, QA, and healthcare agents. Grounds (with [MINJA]): memory poisoning is a real, low-footprint attack surface; native memories need evidence, boundaries, and correction so an injected record cannot masquerade as authoritative ([ADR-0142](../adrs/0142-findings-become-native-memories.md)). Magnitudes are QA/domain-benchmark, not code review — threat-motivated design, not a measured Corpus delta.

<a id="CTXLENHURTS"></a>
**[CTXLENHURTS] Context Length Alone Hurts LLM Performance Despite Perfect Retrieval.** Du, Tian, Ronanki, Rongali, Bodapati, Galstyan, Wells, Schwartz, Huerta, Peng. **Findings of EMNLP 2025**, ACL Anthology 2025.findings-emnlp.1264. *Verified (July 2026, direct fetch — venue + figure).* Task accuracy degrades **13.9%–85%** as input length grows **even with 100% exact retrieval** and only minimal-distraction (whitespace/masked) padding — length alone, not retrieval failure; the effect is model-dependent (closed frontier models far more robust). Grounds: long-context degradation is a real, quantified phenomenon — distinct from stale-*content* hygiene, which is a different, unmeasured mechanism.

<a id="SELFPREF-DBG"></a>
**[SELFPREF-DBG] Beyond the Surface: Measuring Self-Preference in LLM Judgments.** Chen, Wang, Zhang, Hu, Lin. **EMNLP 2025 (main, pp. 1653–1672)**. *Verified (July 2026, direct fetch of the ACL Anthology page).* Introduces gold judgments as quality proxies and a DBG score isolating bias from quality: **self-preference persists even when controlling for whether the model's own response is genuinely better**. Grounds (with [SELFPREFER]): the implementer-≠-reviewer rule now has a quality-controlled, peer-reviewed leg (ADR-0119).

<a id="MEMP"></a>
**[MEMP] Memp: Exploring Agent Procedural Memory.** Fang et al. **ACL 2026 Findings**, arXiv:2508.06433. *Verified (July 2026, direct fetch).* Distills trajectories into procedural memory with an explicit **update / correct / remove-outdated regimen**; success rates rise steadily *as the repository is refined* — the gain is attributed to maintenance, not accumulation. Grounds: native memory earns its keep only with correction and pruning discipline ([ADR-0142](../adrs/0142-findings-become-native-memories.md)).

<a id="GOOGMIGRATE"></a>
**[GOOGMIGRATE] Migrating Code At Scale With LLMs At Google.** Ziftci, Nikolov, Sjövall, Kim, Codecasa, Kim. **FSE 2025 (industry)**, DOI 10.1145/3696630.3728542, arXiv:2504.09691. *Verified (July 2026, direct fetch).* Twelve months, 39 real migrations, 595 changes / 93,574 edits: the LLM produced **74.45% of changes**, in a staged workflow with per-change validation; developers **estimated ~50% total-time reduction** vs earlier manual migrations (self-estimated, not a controlled measurement — mark accordingly). Grounds: staged, per-change-validated migration at industrial scale — the change-plan/wave discipline's strongest external support (ADR-0094 adjacent).

<a id="TDDINDUSTRY"></a>
**[TDDINDUSTRY] Realizing quality improvement through test driven development: results and experiences of four industrial teams.** Nagappan et al. **Empirical Software Engineering 13, 2008**, DOI 10.1007/s10664-008-9062-z. *Verified (August 2026, author PDF).* Four Microsoft and IBM teams reported 40–90% lower pre-release defect density with 15–35% higher initial development time. Small observational cases cannot establish a universal mandate. Grounds: test-first work may trade initial cost for fewer defects; it does not prove one procedure fits every change. <https://www.microsoft.com/en-us/research/wp-content/uploads/2009/10/Realizing-Quality-Improvement-Through-Test-Driven-Development-Results-and-Experiences-of-Four-Industrial-Teams-nagappan_tdd.pdf>

<a id="SWTBENCH"></a>
**[SWTBENCH] SWT-Bench: Testing and validating real-world bug-fixes with code agents.** Mündler et al. **NeurIPS 2024**. *Verified (August 2026, proceedings paper).* Defines a bug-reproduction oracle as a test that fails on the original state and passes after the accepted patch, while distinguishing irrelevant and merely covering tests. Grounds: generated tests need behavioral validation before they can verify a repair. <https://proceedings.neurips.cc/paper_files/paper/2024/hash/94f093b41fc2666376fb1f667fe282f3-Abstract-Conference.html>

<a id="TDFLOW"></a>
**[TDFLOW] TDFlow: Agentic Workflows for Test Driven Development.** Han et al. **EACL 2026**. *Verified (August 2026, ACL paper).* On SWE-Bench Verified, the reported workflow reached 94.3% with human-written tests and 68.0% with generated tests; valid reproduction-test generation was the bottleneck. Grounds: oracle quality matters more than test-writing ceremony. The benchmark gives agents tests unavailable in ordinary issue resolution, so the headline rate is not a general coding-agent result. <https://aclanthology.org/2026.eacl-long.70/>

## Verified — additional primary research

<a id="LOSTMID"></a>
**[LOSTMID] Lost in the Middle: How Language Models Use Long Contexts.** Liu et al., **TACL 2024**. The U-shaped attention curve — accuracy degrades for information in the middle of long contexts. "Context rot" is a later popular term, not one coined by this paper. Grounds: minimize always-on context and keep load-bearing instructions easy to locate.

<a id="CONTEXTROT"></a>
**[CONTEXTROT] Context Rot.** Chroma Research, 2025. Controlled context-growth experiments across 18 current models find increasingly unreliable performance as context grows and distractors accumulate. <https://www.trychroma.com/research/context-rot> - *inspectable industry study with released methods; not peer-reviewed.* Grounds: context capacity is not context quality.

<a id="CONINSTRUCT"></a>
**[CONINSTRUCT] ConInstruct: Benchmarking Language Models on Conflict Resolution.** AAAI 2026. Strong models often detect instruction conflicts but rarely notify the user or seek clarification. <https://ojs.aaai.org/index.php/AAAI/article/view/40356> - *peer-reviewed.* Grounds: unresolved authority conflicts need an explicit human decision rail.

<a id="CONTROLILLUSION"></a>
**[CONTROLILLUSION] Control Illusion: The Failure of Instruction Hierarchies in Large Language Models.** AAAI 2026. Six leading models show persistent failures under conflicting instruction hierarchies; prompt and tuning interventions yield limited repair. <https://ojs.aaai.org/index.php/AAAI/article/view/40339> - *peer-reviewed.* Grounds: delete conflicting control instead of trusting role precedence.

<a id="MASCALE"></a>
**[MASCALE] Towards a Science of Scaling Agent Systems.** Google Research, 2025, arXiv:2512.08296. Across 180 configurations, five architectures, four benchmarks, and three model families, multi-agent gains depend on parallelizable task structure and can reverse on sequential work. <https://arxiv.org/abs/2512.08296> - *preprint with a controlled cross-model study.* Grounds: orchestration follows task topology, not task size.

<a id="PROMPTCOMP"></a>
**[PROMPTCOMP] An Empirical Study on Prompt Compression for Large Language Models.** arXiv:2505.00019, 2025. Six compression methods across thirteen datasets show task-dependent effects; moderate compression can help, but shortening is not a universal quality metric. <https://arxiv.org/abs/2505.00019> - *preprint.* Grounds: measure behavior, not word count.

<a id="SCOT"></a>
**[SCOT] Structured Chain-of-Thought Prompting for Code Generation.** Li, Li, Li, Jin. **ACM TOSEM 34(2), Art. 37, 2025** (DOI 10.1145/3690635; preprint arXiv:2305.06599). *Verified (peer-reviewed).* A *structured* intermediate (program-structured reasoning) beats free-form CoT for code generation (the paper reports +13.79% Pass@1). Grounds: a structured intermediate can beat free prose for downstream code work; this does not establish that every task needs one.

<a id="SMELLS"></a>
**[SMELLS] Rapid Quality Assurance with Requirements Smells.** Femmer, Méndez Fernández, Wagner, Eder. **Journal of Systems and Software 123 (2017): 190–213** (DOI 10.1016/j.jss.2016.02.047). *Verified (peer-reviewed).* Lightweight lexical detection of requirements "smells" (vague terms, comparatives, …) is feasible but **precision is bounded** (the study reports roughly 48–59% precision at ~82–87% recall). Grounds: prose-smell checks are **advisory, never blocking** — only a defined check grammar reaches blocking precision.

## Verified — official guidance (authoritative vendor/spec docs, not empirical claims)

<a id="SKILLBP"></a>
**[SKILLBP] Skill authoring best practices.** Anthropic Claude API docs. Official guidance: the **~500-line body cap**, third-person descriptions, progressive disclosure, the *explain-the-why* pattern, anti-patterns. <https://docs.anthropic.com/en/docs/agents-and-tools/agent-skills/best-practices> — *official guidance, not a measured study; cite as design guidance.*

<a id="CTXENG"></a>
**[CTXENG] Effective context engineering for AI agents.** Anthropic Engineering, 2025. Treats context as a finite resource, recommends just-in-time retrieval, and describes structured note-taking through a to-do list or `NOTES.md`; it does not prescribe a fixed file set. <https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents> — *official guidance.*

<a id="CLAUDE5CTX"></a>
**[CLAUDE5CTX] The new rules of context engineering for Claude 5 generation models.** Anthropic, 2026. Reports an internal prompt reduction above 80% without measurable loss on undisclosed Claude Code evaluations and recommends less prescriptive control for stronger models. <https://claude.com/blog/the-new-rules-of-context-engineering-for-claude-5-generation-models> - *first-party internal result; direction only, not a portable effect size.*

<a id="OAIGOAL"></a>
**[OAIGOAL] Follow a goal.** OpenAI, 2026. Defines a durable coding goal by one objective, one verifiable stopping condition, source pointers, progress proof, checkpoints, and compact status. It warns against loose backlogs and accumulated one-off instructions. <https://learn.chatgpt.com/use-cases/follow-goals> - *official product guidance.*

<a id="LONGHARNESS"></a>
**[LONGHARNESS] Effective harnesses for long-running agents.** Anthropic Engineering, 2025. Reports failures across fresh contexts from one-shot implementation, undocumented partial work, and premature completion; its experimental harness used incremental work and structured continuity artifacts. <https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents> - *first-party experiment; exact file layout is not a universal contract.*

<a id="MAGENTIC"></a>
**[MAGENTIC] Magentic-One: A Generalist Multi-Agent System for Solving Complex Tasks.** Microsoft Research, 2024. Separates an outer task ledger from an inner progress ledger and replans on stalls. The published system was competitive on GAIA, AssistantBench, and WebArena; the ledger split remains architecture evidence, not proof of one ideal prompt format. <https://www.microsoft.com/en-us/research/articles/magentic-one-a-generalist-multi-agent-system-for-solving-complex-tasks/> - *first-party research report.*

<a id="OAILEAN"></a>
**[OAILEAN] Latest model prompting guidance.** OpenAI developer docs, 2026. Reports directional internal coding-agent results from leaner prompts: higher task scores, 41-66% fewer total tokens, and 33-67% lower cost; explicitly requires validation on representative work. <https://developers.openai.com/api/docs/guides/latest-model> - *first-party internal result; direction only.*

<a id="PACT"></a>
**[PACT] What Should Agents Say? Action-state Communication for Efficient Multi-Agent Systems.** Huang, Wu, and Zhang, 2026. Reports that compact action-state-result records improved the performance-cost tradeoff across evaluated multi-agent systems and coding harnesses; no fixed communication strategy won everywhere. <https://arxiv.org/abs/2606.05304> - *recent preprint; model- and harness-specific.*

<a id="EET"></a>
**[EET] Experience-Driven Early Termination for Cost-Efficient Software Engineering Agents.** Guo et al., 2026. Reports 19-55% lower cost across six SWE-bench Verified configurations with at most 0.2 percentage-point resolution loss by stopping unproductive iterations from retrieved execution experience. <https://arxiv.org/abs/2601.05777> - *recent benchmark result; depends on transferable prior experience.*

<a id="PROMPTWASTE"></a>
**[PROMPTWASTE] Same Task, Different Work: Prompt-Induced Waste in Coding Agents.** Weinberger and Hozez, 2026. Across 4,644 valid runs, unbounded certainty and multi-approach prompts increased reasoning, verification, tool calls, latency, and cost without measured success gains in the evaluated tasks. <https://arxiv.org/abs/2608.01347> - *recent preregistered preprint; many tasks were small and deterministic.*

<a id="TOKENCOST"></a>
**[TOKENCOST] Token Reduction Is Not Cost Reduction.** Weinberger and Hozez, 2026. In 2,848 analyzed provider-billed Claude Code runs, one intervention removed about 38% of raw tool-output tokens but raised paired cost about 7%; lossy compression also damaged exact edit anchors. <https://arxiv.org/abs/2607.12161> - *recent preprint; provider-, pricing-, and harness-specific.*

<a id="CLAUDETOOLS"></a>
**[CLAUDETOOLS] Advanced tool use.** Anthropic Engineering, 2026. Reports a 55K-token tool-definition baseline in one internal system and a 37% token reduction from programmatic handling that kept intermediate results out of model context. <https://www.anthropic.com/engineering/advanced-tool-use> - *first-party internal result; workload-specific.*

<a id="AIRBNBEVAL"></a>
**[AIRBNBEVAL] Eval-driven development: lessons from evaluating GenAI at scale.** Airbnb Engineering, 2026. Recommends deriving evaluators from real failures, using deterministic checks first, keeping evaluators narrow, and assigning disputed quality to a human owner. <https://airbnb.tech/ai-ml/eval-driven-development-lessons-from-evaluating-genai-at-scale/> - *first-party production guidance, not a controlled effect estimate.*

<a id="CODEXGLOBAL"></a>
**[CODEXGLOBAL] Codex AGENTS.md and configuration references.** OpenAI developer docs, 2026. Defines user-level `AGENTS.override.md` / `AGENTS.md` discovery, `CODEX_HOME`, profile configuration, and `model_instructions_file`. <https://developers.openai.com/codex/guides/agents-md> <https://developers.openai.com/codex/config-reference/> - *authoritative product contract.*

<a id="CLAUDEDIR"></a>
**[CLAUDEDIR] Claude Code user instructions and configuration directory.** Anthropic docs, 2026. Defines global `CLAUDE.md`, imports, and `CLAUDE_CONFIG_DIR` redirection. <https://code.claude.com/docs/en/memory> <https://code.claude.com/docs/en/claude-directory> - *authoritative product contract.*

<a id="OPENCODERULES"></a>
**[OPENCODERULES] OpenCode rules and configuration.** OpenCode docs, 2026. Defines global `~/.config/opencode/AGENTS.md`, Claude-compatible fallback, project precedence, combined instruction files, and JSON/JSONC configuration. <https://opencode.ai/docs/rules/> <https://opencode.ai/docs/config/> - *authoritative product contract.*

<a id="KIMICODE"></a>
**[KIMICODE] Kimi Code instructions and MCP configuration.** Kimi Code docs, 2026. Defines user-level `$KIMI_CODE_HOME/AGENTS.md` and `$KIMI_CODE_HOME/mcp.json`, with `~/.kimi-code` as the default root. <https://www.kimi.com/code/docs/en/kimi-code-cli/customization/agents> <https://www.kimi.com/code/docs/en/kimi-code-cli/customization/mcp.html> - *authoritative product contract.*

<a id="ZCODE"></a>
**[ZCODE] ZCode Agent instructions.** ZCode docs, 2026. Defines `~/.zcode/AGENTS.md` as the user-global instruction file and workspace `AGENTS.md` as the project source. <https://zcode.z.ai/en/docs/agents> - *authoritative product contract.*

<a id="CURSORRULES"></a>
**[CURSORRULES] Cursor rules storage.** Cursor help, 2026. Defines project rules in `.cursor/rules/`, account-synced User Rules in Settings, and machine-local user rule files in `~/.cursor/rules`. <https://cursor.com/help/customization/rules> - *authoritative product contract.*

<a id="ANTIGRAVITYRULES"></a>
**[ANTIGRAVITYRULES] Antigravity global rules.** Google Antigravity docs, 2026. Defines global rules at `~/.gemini/GEMINI.md` and workspace rules under `.agents/rules`. <https://www.antigravity.google/docs/ide/rules/> - *authoritative product contract.*

<a id="RTKHOOKS"></a>
**[RTKHOOKS] RTK agent hooks.** RTK source documentation, 2026. Defines shell-command rewriting, MCP and native-read bypass, already-prefixed passthrough, and agent-specific hook limits. <https://github.com/rtk-ai/rtk/blob/master/hooks/README.md> - *authoritative implementation contract.*

<a id="LEANCTX"></a>
**[LEANCTX] lean-ctx integration modes.** lean-ctx source documentation, 2026. Defines MCP-only, hybrid, and replacement integration plus `ctx_read`, `ctx_search`, `ctx_shell`, security, and recovery behavior. <https://github.com/yvgude/lean-ctx/blob/main/docs/ga/developer-guide.md> - *authoritative implementation contract.*

<a id="CLAUDEHOOKS"></a>
**[CLAUDEHOOKS] Claude Code hooks.** Anthropic docs, 2026. Defines parallel execution and merged results for matching hooks. <https://code.claude.com/docs/en/hooks-guide> - *authoritative product contract.*

<a id="OAIHARNESS"></a>
**[OAIHARNESS] Harness engineering: leveraging Codex in an agent-first world.** OpenAI, 2026. Treats human attention and context as scarce, uses repository knowledge as a map, and enforces architecture through mechanical tests rather than a giant instruction manual. <https://openai.com/index/harness-engineering/> - *first-party case study, not a controlled comparison.*

<a id="OAIDATA"></a>
**[OAIDATA] Inside our in-house data agent.** OpenAI, 2026. Reports that overlapping tools confused selection and highly prescriptive prompts reduced robustness; consolidation and goal-oriented control improved the deployed system. <https://openai.com/index/inside-our-in-house-data-agent/> - *first-party production report without disclosed effect sizes.*

<a id="GOOGLECTX"></a>
**[GOOGLECTX] Architecting an efficient context-aware multi-agent framework for production.** Google Developers, 2026. Separates durable storage from compiled agent context, scopes each worker to minimum necessary state, and passes large objects by handle. <https://developers.googleblog.com/architecting-efficient-context-aware-multi-agent-framework-for-production/> - *official architecture guidance.*

<a id="MCPINTERFERENCE"></a>
**[MCPINTERFERENCE] Tool-space interference in the MCP era.** Microsoft Research, 2026. A survey of 1,470 MCP servers finds semantic collisions, generic names, and extreme outputs; recommends small distinct tool sets, concise responses, dynamic discovery, and model-client testing. <https://www.microsoft.com/en-us/research/blog/tool-space-interference-in-the-mcp-era-designing-for-agent-compatibility-at-scale/> - *large descriptive survey; causal effects remain bounded.*

<a id="BUILDAGENTS"></a>
**[BUILDAGENTS] Building effective agents.** Anthropic Engineering, 2024. *Verified (July 2026, direct fetch).* Start-simple guidance: "find the simplest solution possible, and only increasing complexity when needed"; the most successful implementations used **simple, composable patterns**, not complex frameworks; frameworks "often create extra layers of abstraction that can obscure the underlying prompts and responses" and "make it tempting to add complexity when a simpler setup would suffice." <https://www.anthropic.com/engineering/building-effective-agents> — *official guidance, not a measured study; cite as design guidance.* Grounds: the minimum-useful-rigor default — add structure only where it earns its place (ADR-0131).

<a id="SKILLSPEC"></a>
**[SKILLSPEC] Open Agent Skills specification.** agentskills.io. The `SKILL.md` shape, the 1024-char `description` cap, the progressive-disclosure model. <https://agentskills.io/specification> — *open standard.*

<a id="AGENTSMD-CONV"></a>
**[AGENTSMD-CONV] The `AGENTS.md` convention.** agents.md — the cross-tool repository-context convention; the basis for the `AGENTS.md > Commands` contract. <https://agents.md> — *convention/standard.*

<a id="CCTASKS"></a>
**[CCTASKS] Claude Code Tasks / Todo system.** Anthropic, Claude Code (2026). Disk-persistent, dependency-aware task tracking — vendor-scale validation of externalised task state. <https://docs.anthropic.com/en/docs/claude-code/changelog> — *vendor doc.*

<a id="SPECKIT"></a>
**[SPECKIT] GitHub Spec Kit — Spec-Driven Development toolkit.** GitHub, 2025. *Verified (June 2026, repo + docs + GitHub blog).* Scaffolds **per-feature spec folders** — `specs/<NNN-feature>/` holding the spec + plan + tasks + research co-located — alongside a project-wide principles file (`memory/constitution.md`) and shared `templates/`; the flow is Spec → Plan → Tasks → Implement. <https://github.com/github/spec-kit> · <https://github.github.com/spec-kit/> — *vendor toolkit; cite as convention, not a measured study.* Comparator: a prominent repo-local specification workflow; ordinary Corpus artifacts remain outside repositories in the agent-neutral workspace.

<a id="KIRO"></a>
**[KIRO] Amazon Kiro — spec-driven development.** AWS, 2025. *Verified (June 2026, kiro.dev/docs/specs).* Organizes each feature as `.kiro/specs/<feature>/` with `requirements.md` + `design.md` + `tasks.md`, and writes requirements in **EARS** (Easy Approach to Requirements Syntax) — an established controlled-clause requirements syntax. <https://kiro.dev/docs/specs/> — *vendor; cite as convention.* Comparator: a repo-local specification workflow, and evidence that EARS is an established requirements-clause syntax.

<a id="ADR-CONV"></a>
**[ADR-CONV] Architecture Decision Records — the convention.** Nygard (2011); MADR template (adr.github.io); Fowler. *Verified (June 2026).* Decisions are recorded as short, immutable, **sequentially-numbered** Markdown files in a dedicated in-repo directory (`decisions/` or `docs/adr/`), one decision per file, superseded rather than rewritten. <https://adr.github.io/madr/> · <https://martinfowler.com/bliki/ArchitectureDecisionRecord.html> — *established convention.* Grounds: the project-wide `decisions/` home for ADRs and the supersession ledger.

<a id="DIATAXIS"></a>
**[DIATAXIS] Diátaxis — a systematic framework for technical documentation.** Procida. *Verified (June 2026, diataxis.fr).* Organizes documentation by user need into four distinct modes — tutorials, how-to guides, reference, explanation — kept separate because each serves a different purpose. <https://diataxis.fr/> — *reference framework.* Grounds: separate tutorials, reference, and explanation by the reader's need.

<a id="GARTNER-AGENTS"></a>
**[GARTNER-AGENTS] Gartner agentic AI adoption projection.** Gartner, 2025. *Verified (July 2026, direct newsroom release).* Projects **40% of enterprise applications will embed task-specific AI agents by the end of 2026**, up from under 5% in 2025. <https://www.gartner.com/en/newsroom/press-releases/2025-08-26-gartner-predicts-40-percent-of-enterprise-apps-will-feature-task-specific-ai-agents-by-2026-up-from-less-than-5-percent-in-2025> — *analyst projection, not a measured outcome.* Grounds: agentic AI adoption is expected to expand rapidly.

<a id="AI-INDEX-2026"></a>
**[AI-INDEX-2026] Stanford HAI AI Index Report 2026.** Stanford Institute for Human-Centered AI, 2026. *Verified (July 2026, direct report chapter).* Reports **security and risk as the most frequently selected barrier to scaling agentic AI**, cited by **62% of respondents**; technical limitations and regulatory uncertainty were each selected by 38%. <https://hai.stanford.edu/assets/files/ai_index_report_2026_chapter_3_responsible_ai.pdf> — *secondary synthesis of a McKinsey survey; not a causal result.* Grounds: security and risk are prominent reported adoption barriers.

<a id="CSA-AI-CYBER-2026"></a>
**[CSA-AI-CYBER-2026] State of AI Cybersecurity 2026.** Cloud Security Alliance / Token Security, April 2026. *Verified (June 2026, direct fetch of CSA research note).* Survey of 1,500+ security leaders: **65% of enterprises with deployed AI agents experienced a confirmed security incident**, **63% cannot enforce purpose limitations**, and **60% cannot terminate a misbehaving agent once running**. Grounds: operational controls for agentic AI lag behind adoption.

<a id="NIST-CAISI-RFI"></a>
**[NIST-CAISI-RFI] Summary Analysis of Responses to the Request for Information Regarding Security Considerations for AI Agents.** NIST Center for AI Standards and Innovation (CAISI), NIST AI 800-5, 18 May 2026. *Verified (July 2026, direct publication).* Respondents widely agreed that agents present novel security threats and that established cybersecurity principles remain relevant but require adaptation for agent security. <https://www.nist.gov/publications/summary-analysis-responses-request-information-regarding-security-considerations-ai> — *government summary of public comments, not an independent empirical study.* Grounds: agent security is an active standards and implementation gap.

<a id="NIST-AI-AGENT-STANDARDS"></a>
**[NIST-AI-AGENT-STANDARDS] NIST AI Agent Standards Initiative.** NIST, announced 17 February 2026. *Verified (July 2026, direct announcement).* Organizes work around industry-led standards, community-led open-source protocol development, and research on agent security and identity. NIST says further research, guidelines, and deliverables will be announced in the months ahead; it does not publish a fixed delivery date. <https://www.nist.gov/news-events/news/2026/02/announcing-ai-agent-standards-initiative-interoperable-and-secure> — *official initiative announcement.* Grounds: agent interoperability, security, and identity standards remain active work.

<a id="GOOGLESA"></a>
**[GOOGLESA] Lessons from Building Static Analysis Tools at Google.** Sadowski, Aftandilian, Eagle, Miller-Cushon, Jaspan. **Communications of the ACM 61(4), April 2018** (DOI 10.1145/3188720); the same criteria are restated in *Software Engineering at Google* (O'Reilly 2020), ch. 20 "Static Analysis". *Verified (June 2026, direct fetch of the SWE-book ch.20 + the paper summary). Authoritative engineering field report (a CACM practitioner article + the Google engineering book), not peer-reviewed primary research — cited as authoritative guidance for a design target.* A code-review-time check must **"produce less than 10% effective false positives"**; an issue is an **"effective false positive" if developers did not take some positive action after seeing the issue** — technical correctness is secondary (a correct-but-ignored report still counts against the budget; an incorrect report the developer fixes anyway does not). Compiler-integrated checks that fail the build are held to the stricter **"no effective false positives."** Grounds: the review-time precision target — a deterministic review check must clear ≤10% effective false positives or it gets `--no-verify`'d into irrelevance (the benchmark target in [ADR-0086](../adrs/0086-deterministic-review-scanning-decision.md); reinforces the warning-not-hard-error posture for fuzzy checks alongside [[SMELLS]]).

<a id="CODERABBIT-PRVAL"></a>
**[CODERABBIT-PRVAL] CodeRabbit — PR validation using linked issues.** CodeRabbit, 2025–2026. *Verified (June 2026, docs.coderabbit.ai + coderabbit.ai blog).* The reviewer reads a linked Jira / Linear issue, validates whether the PR addresses the issue's **acceptance criteria**, and writes the assessment (validated vs needs-revision) back to the linked ticket. <https://docs.coderabbit.ai/integrations/jira> — *vendor feature doc; a shipped capability, not a measured study.* Grounds (with [QODO]): requirement/acceptance-criteria binding in PR review is shipped by incumbents — Corpus's distinction is its explicit-path, verdict-free form, not "binding evidence to requirements" by itself.

<a id="QODO"></a>
**[QODO] Qodo Merge — Ticket Compliance Agent.** Qodo (formerly CodiumAI), 2024–2026. *Verified (June 2026, qodo.ai blog + qodo-merge-docs.qodo.ai/tools/compliance + PR Newswire launch).* The code-review agent fetches a linked Jira / GitHub-Issues ticket, surfaces its **acceptance criteria**, and reports whether the diff is **Fully / Partially / Not compliant** — "identifies missing acceptance criteria, unimplemented steps," and markets **scope-creep prevention** and **audit-ready** evidence. <https://qodo-merge-docs.qodo.ai/tools/compliance/> — *vendor feature doc; a shipped capability, not a measured study.* Grounds (with [CODERABBIT-PRVAL]): requirement/acceptance-criteria binding in PR review is now shipped by incumbents — Corpus's distinction is its explicit-path, verdict-free form, not "binding evidence to requirements" by itself.

<a id="SARIF"></a>
**[SARIF] Static Analysis Results Interchange Format (SARIF) v2.1.0.** OASIS, approved as an **OASIS Standard on 27 March 2020** (17 affirmative consents, no objections). *Verified (June 2026, oasis-open.org).* A JSON interchange format whose stated purpose is to make it feasible to **aggregate the results of multiple static-analysis tools**; ingested natively by GitHub code scanning and by reviewdog. <https://www.oasis-open.org/standard/sarifv2-1-os/> — *ratified standard.* Grounds: the deferred "import, don't rebuild" track — if Corpus ever ingests external analyzer findings, SARIF (with JUnit XML for test results) is the de-facto format to route and correlate against scope, never an analyzer to re-implement ([ADR-0086](../adrs/0086-deterministic-review-scanning-decision.md) Decision 4).

<a id="OVERRELIANCE-REVIEW"></a>
**[OVERRELIANCE-REVIEW] Overreliance on AI: Literature Review.** Passi, Vorvoreanu, et al. **Microsoft Research / Aether (AI, Ethics, and Effects in Engineering and Research), June 2022.** *Verified (June 2026, web search — direct fetch of the Aether review PDF).* A Microsoft research **literature review** — a secondary synthesis of empirical studies, not itself a controlled study: the **presence of explanations can increase over-reliance** on AI, and **more detailed explanations can make it worse** — explanations often persuade rather than help a person evaluate, so they do not reliably improve human-AI team performance. <https://www.microsoft.com/en-us/research/publication/overreliance-on-ai-literature-review/> — *authoritative vendor research synthesis; cite as guidance, not a single measured study (it is a review, not primary research).* Grounds: favor short, verification-oriented justification over long persuasive prose; the goal of a recommendation's "why" is to make checking cheap, not to convince.

<a id="GOOGLESMALLCL"></a>
**[GOOGLESMALLCL] Small CLs.** Google Engineering Practices — Code Review Developer Guide (living document, accessed June 2026). The right size for a change is **one self-contained change**; ~100 lines is usually reasonable and ~1000 usually too large (rules of thumb, the reviewer's judgment; a change spread across many files counts as larger). **Separate a refactor from a feature or bug-fix** into its own change (small cleanups like renaming a local variable MAY ride along). <https://google.github.io/eng-practices/review/developer/small-cls.html> — *official guidance, not a measured study.* Grounds: separate-refactor-from-behavior and small/self-contained units (ADR-0094).

<a id="PLAYWRIGHTMCP"></a>
**[PLAYWRIGHTMCP] Playwright MCP.** Microsoft (github.com/microsoft/playwright-mcp), accessed June 2026. Drives a browser via the **accessibility tree, not pixels** — "No vision models needed," deterministic, fast/lightweight. <https://github.com/microsoft/playwright-mcp> — *official project docs, not a measured study.* Grounds: prefer deterministic accessibility-tree tooling over pixel/vision when an agent captures app-run evidence (ADR-0095).

<a id="NARAGRS52"></a>
**[NARAGRS52] General Records Schedule 5.2: Transitory and Intermediary Records.** U.S. National Archives and Records Administration (NARA), Transmittal No. 34, June 2023. The durability test: a record is durable when it is required "to initiate, sustain, evaluate, or provide evidence of decision-making"; **transitory** records are "routine records of short-term value (generally less than 180 days)," disposed of "when no longer needed." <https://www.archives.gov/records-mgmt/grs/faqs-for-grs-5-2> — *primary-official (the issuing authority's schedule); "generally less than 180 days" is a typical bound, not a hard cutoff.* Grounds: distinguish durable project records and native memories from transient working artifacts; durability follows the owning system, not a Corpus record store.

<a id="ISO15489"></a>
**[ISO15489] ISO 15489-1:2016 — Records management — Concepts and principles.** International Organization for Standardization, 2016. The records lifecycle: (recurrent) **appraisal → disposition authorities**, each setting a **retention period** and a disposition action — destruction, transfer, or archive for permanent retention. <https://www.iso.org/standard/62542.html> — *primary-official (paywalled; cite the catalog page for identity, the substance is the clause text).* Grounds: records need an explicit disposition rather than indefinite accumulation; Corpus leaves that lifecycle to the system that owns the durable record.

<a id="NYGARDADR"></a>
**[NYGARDADR] Documenting Architecture Decisions.** Nygard, 2011. ADRs "are numbered sequentially and monotonically; numbers will not be reused"; each carries a **status** (proposed | accepted | deprecated | superseded); a reversed decision is **kept and marked superseded** "with a reference to its replacement" — not altered or deleted. <https://cognitect.com/blog/2011/11/15/documenting-architecture-decisions> — *primary-official (the post that originated the ADR pattern); "immutable" is later secondary framing, not Nygard's own word.* Grounds: supersede-not-delete + sequential numbering + a status field for durable decision records (ADR-0096).

<a id="MADR"></a>
**[MADR] Markdown Architectural Decision Records (MADR).** The `adr` GitHub organization, MADR 4.0.0, 2024. ADRs live in a `docs/decisions/` folder named `NNNN-title-with-dashes.md` (a consecutive number; "we assume that there won't be more than 9,999 ADRs in one repository"); the template carries a **status** field with example values (`proposed | rejected | accepted | deprecated | … | superseded by ADR-NNNN`). <https://adr.github.io/madr/> — *primary-official (the project's own docs); the status values are illustrative, not a closed set.* Grounds: the NNNN scheme + a status field scale to thousands of records (ADR-0096).

<a id="ISO42010"></a>
**[ISO42010] ISO/IEC/IEEE 42010:2022 — Software, systems and enterprise — Architecture description.** ISO/IEC/IEEE, 2nd edition, November 2022. *Verified (July 2026, ISO catalog + the standard's conceptual-model site).* The standard's architecture-description model treats architecture decisions, the concerns they address, and architecture rationale as first-class concepts; rationale records the explanation or justification for decisions and rejected alternatives. <https://www.iso.org/standard/74393.html> · <https://www.iso-architecture.org/ieee-1471/cm/> — *primary-official identity plus the standard editors' conceptual summary; the full standard is paywalled.* Grounds: recording durable decisions with rationale aligns with the standard's conceptual model; the NNNN and supersede-not-rewrite format remains the [[NYGARDADR]] / [[MADR]] convention (ADR-0096).

<a id="ISO29148"></a>
**[ISO29148] ISO/IEC/IEEE 29148:2018 — Systems and software engineering — Life cycle processes — Requirements engineering.** ISO/IEC/IEEE, 2nd edition, 2018. *Verified (June 2026, iso.org catalog).* Specifies the requirements-engineering processes and the **characteristics of a good requirement** (necessary, unambiguous, verifiable, traceable, …) plus the required information items that carry them across the life cycle. <https://www.iso.org/standard/72089.html> — *primary-official (paywalled; cite the catalog page for identity).* Grounds: requirements are verifiable, traceable, stably identified information items — the standard backing for Corpus's acceptance-criteria discipline.

<a id="GHRETENTION"></a>
**[GHRETENTION] GitHub Actions artifact & log retention.** GitHub Docs, accessed June 2026. Workflow artifacts and logs are **retained 90 days by default** — configurable 1–90 days for public repos, up to 400 for private. <https://docs.github.com/en/organizations/managing-organization-settings/configuring-the-retention-period-for-github-actions-artifacts-and-logs-in-your-organization> — *primary-official.* Grounds: CI evidence is often retained temporarily, so a durable claim must not depend on an assumed-permanent run log.

<a id="GLRETENTION"></a>
**[GLRETENTION] GitLab CI/CD job artifacts — default expiry.** GitLab Docs, accessed June 2026. Job artifacts **expire 30 days** after creation by default (overridable per job via `expire_in`, or kept indefinitely with `expire_in: never`). <https://docs.gitlab.com/ci/jobs/job_artifacts/> — *primary-official.* Grounds: with GitHub's default ([[GHRETENTION]]), confirms that linked CI evidence may expire and needs an inspectable durable anchor when the claim must outlive the run.

<a id="SWEGBOOKDOCS"></a>
**[SWEGBOOKDOCS] Software Engineering at Google, ch. 10 "Documentation".** Manshreck (eds. Winters, Manshreck, Wright), O'Reilly, 2020. "Documents without owners become stale"; freshness metadata can "send email reminders when the document hasn't been touched in, for example, three months"; at scale a **dominant failure mode is duplication, not just absence** (the GooWiki / Borg case — 7–10 overlapping Borg-setup docs, no owner). <https://abseil.io/resources/swe-book/html/ch10.html> — *practitioner-credible (industry book, not peer-reviewed); the 3-month figure is an example, not a rule.* Grounds: maintained project documentation needs ownership and freshness; transient working specs should not become duplicate documentation.

## Verified — peer-reviewed, no measured outcomes (vision/position; design rationale only)

<a id="REDEFO"></a>
**[REDEFO] Requirements Development and Formalization for Reliable Code Generation: A Multi-Agent Vision.** Sun et al. (Weisong Sun, corresponding). **ASE 2025 (NIER track)**, arXiv:2508.18675. *Verified (June 2026, conf.researchr.org + arXiv).* A **vision** paper (New Ideas & Emerging Results — peer-reviewed venue, **no measured outcomes**): proposes Analyst + Formalizer agents that turn ambiguous NL requirements into **formal specifications** to bridge NL→code, with human-in-the-loop review at critical points. Cite as **design rationale / corroboration only** (never a measured `MUST`) — it corroborates the spec-as-contract + clarify-before-build direction; the *measured* grounding for that spine remains [PLANCODER]/[SEMAP]/[MAST]/[SMELLS].

<a id="EVALAI"></a>
**[EVALAI] Explainable AI is Dead, Long Live Explainable AI! Hypothesis-driven Decision Support using Evaluative AI.** Miller. **ACM FAccT 2023** (DOI 10.1145/3593013.3594001), arXiv:2302.12389. *Verified (June 2026, web search — ACM DL + arXiv).* A **position paper** (peer-reviewed venue, **no measured outcomes**): argues that giving a recommendation-plus-explanation takes agency from the decision-maker and misfits how people actually decide; proposes **evaluative AI** — a machine-in-the-loop that surfaces **evidence for and against** the options rather than pushing a single accept/reject recommendation. Cite as **design rationale only** (never a measured `MUST`) — and note it is **contested** (a position paper; later work found no automatic decision-quality gain from options-over-recommendations). Grounds: the decision handoff presents *comparable options with the case for and against*, not a lone recommendation — but as a reasoned design stance, not a proven result.

## Caveated — non-peer-reviewed (cite ONLY as preliminary; never load-bearing)

These sources may illustrate a direction but never ground a `MUST`. Their headline statistics are single-author or industry measurements, not controlled peer-reviewed studies.

<a id="WIEGERS95"></a>
**[WIEGERS95] Improving Quality Through Software Inspections.** Wiegers. **Software Development magazine, April 1995** (author reprint, processimpact.com). *Verified (June 2026, web — author PDF).* The desk-checking principle: the author is a poor sole reviewer of their own work — "if the author was aware of defects, he probably would have corrected them already"; flags "a sense of unease when the author is the only person who has viewed a completed product." <https://www.processimpact.com/articles/inspects.pdf> — *practitioner / trade article, not peer-reviewed; cite as **design rationale only**, never as measured evidence.* Grounds: the cognitive rationale for reviewer ≠ author (reinforces ADR-0056), at design-rationale level (ADR-0095).

<a id="ACTIVATION-BLOG"></a>
**[ACTIVATION-BLOG] Why Claude Code Skills Don't Activate — And How to Fix It.** Seleznov, Medium, 2026. A self-published 650-trial measurement reporting directive descriptions activating far more reliably than passive ones (the "OR ≈ 20.6 / 100% activation" figures). **Non-peer-reviewed; the specific numbers are NOT load-bearing.** The *direction* (directive, exclusion-bearing descriptions help) is used only as illustration; Corpus skills use explicit trigger and exclusion language, while direct invocation remains available.

<a id="DORA2025"></a>
**[DORA2025] DORA 2025 — State of AI-assisted Software Development.** Google Cloud / DevOps Research and Assessment, 2025. *Venue + framing web-verified (June 2026, dora.dev/research/2025); the percentages are the report's own self-reported figures (the public landing pages don't expose them for re-fetch — figures corroborated via the report body in earlier multi-source verification).* **~90%** of technology professionals use AI at work and **>80%** report it improved their productivity (self-reported, not measured); the report's thesis is that **AI is an "amplifier"** of an organization's existing strengths and weaknesses — higher adoption is associated with **both increased delivery throughput and increased instability** absent strong control / internal-platform systems. **Tier: vendor/industry report, correlational, self-reported — never a `MUST`.** Grounds (illustrative): agent adoption can amplify instability where verification and operational controls are weak; Corpus addresses that risk through explicit intent, evidence, and independent review. Pairs with [METR]'s perception-vs-reality gap.

### Preprints — web-verified arXiv (finding confirmed; cite as preliminary, never a `MUST`)

A web-verified arXiv preprint is stronger than a blog post but is **not peer-reviewed**: it may *corroborate* or *illustrate* a direction, never carry a `MUST`. Each finding below was confirmed against the source (June 2026).

<a id="CICACHE"></a>
**[CICACHE] The Promise and Reality of Continuous Integration Caching: An Empirical Study of Travis CI Builds.** Ghaleb, da Costa, Zou. **arXiv:2601.19146** (2026 preprint). *Verified (July 2026, direct arXiv record).* Across 513,384 builds from 1,279 GitHub projects, one-third of projects received substantial build-time reductions while 33% contained stale cached artifacts. Grounds (preliminary): reuse can save work, but cache identity and refresh rules remain necessary. Scope: CI caches, not local worktree dependency folders.

<a id="PERSUASIONPARADOX"></a>
**[PERSUASIONPARADOX] The Persuasion Paradox: When LLM Explanations Fail to Improve Human-AI Team Performance.** Cohen, Feng, Bloch, Kraus. **arXiv:2604.03237** (preprint, 2026). *Verified (June 2026, id + abstract).* Three controlled studies; the result is explicitly **task-dependent / mediated by cognitive modality** — on **visual** reasoning (RAVEN matrices) explanations inflate confidence without accuracy and suppress error recovery, but on **language-based logical** reasoning (LSAT) "LLM explanations yield the highest accuracy and recovery rates, outperforming both expert-written explanations and probability-based support." The paper rejects treating explanations as a universal solution. Grounds (preliminary, **mixed**): on the visual task it corroborates the over-reliance/"calibration cues over persuasion" direction; on the language task — the class **closer to a developer's decision** — explanations *helped*, which cuts the other way. Cite only as preliminary, never a `MUST`; do not read it as a one-directional "replicate and intensify."

<a id="IFSCALE"></a>
**[IFSCALE] How Many Instructions Can LLMs Follow at Once?** Jaroslawicz et al. **arXiv:2507.11538** (preprint). *Verified (June 2026, id + abstract).* A 500-instruction density benchmark across 20 frontier models: best models ~68% accuracy at 500 simultaneous instructions; top reasoning models hold near-perfect adherence through ~100–150 before degrading; failures shift to **silent omission** with a **primacy bias** toward earlier instructions. Grounds (preliminary): order important requirements early and keep instruction sets lean. The study does not establish a page-length threshold.

<a id="SWEMUT"></a>
**[SWEMUT] Saving SWE-Bench: A Benchmark Mutation Approach for Realistic Agent Evaluation.** **arXiv:2510.08996** (preprint). *Verified (June 2026, id + abstract).* Mutating formal GitHub-issue task descriptions into realistic short chat queries (telemetry-derived) drops agent resolution so far that public benchmarks **overestimate capability by >50%** for some models (~10–16% on an internal benchmark). Grounds: specification richness in the task input is load-bearing for agent success; terse prompting measurably underperforms.

<a id="ASKORASSUME"></a>
**[ASKORASSUME] Ask or Assume? Uncertainty-Aware Clarification-Seeking in Coding Agents.** **arXiv:2603.26233** (2026 preprint; id + abstract verified June 2026 — 69.40% confirmed in the abstract; the 70.80/54.80/47.20 results-section figures are entry-recorded but unverified beyond it; cite as preliminary only). On an underspecified SWE-bench Verified variant: full issue **70.80%** vs underspecified **54.80%** resolve rate (specification completeness alone ≈16 pts); calibrated clarification recovers to **69.40%**; an always-clarify baseline was WORST (47.20%). Grounds (preliminary): spec completeness and clarification are substitutable; indiscriminate clarification hurts.

<a id="REACODER"></a>
**[REACODER] Bridging the Gap between User Intent and LLM: A Requirement Alignment Approach for Code Generation.** **arXiv:2604.16198** (2026 preprint). *Verified (June 2026, id + abstract; the ablation figures below are from the body and unverified beyond this entry).* Requirement alignment before generation improves pass rates over all baselines across 4 models / 5 benchmarks (avg +7.9% to +30.3%); ablations attribute gains to both upfront QA-alignment (+5.82%) and checking generated code back against the requirement (+9.99%); costs more tokens than zero-shot. Preliminary; never a MUST-level ground.

<a id="AGENTTESTS"></a>
**[AGENTTESTS] Rethinking the Value of Agent-Generated Tests for LLM-Based Software Engineering Agents.** Chen et al. **arXiv:2602.07900** (2026 preprint). *Verified (August 2026, v2 abstract).* Across six models on SWE-Bench Verified, resolved and unresolved tasks showed similar test-writing rates; a four-model prompt intervention changed test volume without significantly changing final outcomes. Grounds (preliminary): demanding more generated tests is not a quality mechanism by itself. <https://arxiv.org/abs/2602.07900>


<a id="AGENTSMD-HARM"></a>
**[AGENTSMD-HARM] Evaluating AGENTS.md.** Gloaguen, Mündler, Müller, Raychev, Vechev (ETH Zürich + LogicStar.ai). **arXiv:2602.11988** (preprint). *Verified (June 2026).* Two findings: (1) repository-specific commands are used far more often when **named** in the context file than when not (≈1.6×, *p*=0.01; ≈2.5×, *p*=0.05) — corroborates the Commands contract; (2) **over-specification hurts** — LLM-*generated* narrative context files reduced task success by ~3% while raising inference cost by **over 20%**, and even developer-written ones gave only a small gain at added cost. Its efficiency companion **(Lulla et al., arXiv:2601.20404) is a *contrasting* result** — developer-written `AGENTS.md` *reduced* runtime (~28.6%) and tokens (~16–20%); the two do not jointly establish "narrative is costly" and must not be cited as if they do. Grounds: the minimality / anti-bloat discipline (fewer, scoped, command-naming context files; not more narrative). *Where the `AGENTS.md > Commands` contract cites this (ADR-0018, ADR-0038), treat it as **corroborating** evidence — the contract's normative force rests on the [AGENTSMD-CONV] convention and the design reasoning, not on this preprint.*

<a id="FORMATTAX"></a>
**[FORMATTAX] The Format Tax.** Lee et al. **arXiv:2604.03616** (preprint). *Verified (June 2026).* The cost of format-restriction is paid mostly at the *prompt* (~−3.9pp), not the decoder (~−1.6pp); **decoupling** (reason free-form, then emit) recovers +6.8 / +9.2pp, and frontier models pay near-zero tax. Corroborates [FORMATFREE]; grounds the reason-then-emit rule.

<a id="EVIBOUND"></a>
**[EVIBOUND] Evidence-Bound Autonomous Research.** Chen. **arXiv:2511.05524** (preprint; small N=8 — illustrative). *Verified (June 2026).* Prompt-only completion governance produced ~100% hallucinated "done" claims; **dual machine-checkable gates drove that to 0%**. Illustrates: bind "done"/"true" to a checkable evidence anchor, not a prose assertion.

<a id="SWESKILLS"></a>
**[SWESKILLS] SWE-Skills-Bench: Do Agent Skills Actually Help in Real-World Software Engineering?** Han, Zhang, Song, Fang, Chen, Sun, Hu. **arXiv:2603.15401** (preprint). *Verified (June 2026; re-verified July 2026, direct fetch — title and figures confirmed).* Of 49 candidate skills, **39 gave zero pass-rate improvement** (average gain **+1.2%**), 3 degraded performance up to **−10pp**, and only 7 specialized skills produced meaningful gains (up to +30%). Grounds: generic skills are mostly inert — read WITH [SKILLSBENCH26], which shows curated task-matched skills gain +16.6pp: the operative variable is curation and task-fit, not the skill mechanism itself.

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
**[MAST] Multi-Agent System failure Taxonomy (MAST).** Cemri et al. **arXiv:2503.13657** (preprint; venue unconfirmed). *Verified (June 2026; finding confirmed, venue not).* 14 failure modes across three categories — **system-design & specification ≈41.8%, inter-agent misalignment ≈36.9%, verification ≈21.3%** (so specification + verification ≈ 63%). *Note (audit O-0):* the first category is "System Design / poor specification," not "Specification" alone. Grounds: why Corpus hardens the specification and verification layers; the inter-agent contract gap.

<a id="SEMAP"></a>
**[SEMAP] Structured/contract-based multi-agent protocol (SEMAP).** Mao et al. **arXiv:2510.12120** (preprint). *Verified (June 2026).* Contracts + structured inter-agent messaging + lifecycle verification cut failures **64–70%**, with the largest single win in **under-specification (71–73%)**. Grounds: structured requirements, explicit handoffs, and evidence-backed review; the inter-agent coordination contract.

<a id="REPORTLOGIC"></a>
**[REPORTLOGIC] Agent-report quality axis.** **arXiv:2602.18446** (preprint). *Verified (June 2026).* A primary quality axis of an agent's report is an explicit **claim → support** structure. Grounds: the evidence-before-conclusion / claim-must-carry-evidence rule for findings and audits.

<a id="PLANCODER"></a>
**[PLANCODER] Understanding and Bridging the Planner-Coder Gap.** Lyu et al. **arXiv:2510.10460** (preprint). *Verified (June 2026, audit O-0).* The planner→coder gap "accounts for **75.3%** of failures"; semantic-preserving input mutations break 7.9–83.3% of previously-solved problems; a monitor agent repairs 40–89%. Grounds: the plan-to-implementation handoff is a major multi-agent code-generation failure surface, so intent and scope must survive dispatch intact.

<a id="VERINA"></a>
**[VERINA] VERINA: Benchmarking Verifiable Code Generation.** Ye et al. **arXiv:2505.23135** / OpenReview (preprint; *not* ICML 2025). *Verified (June 2026, audit O-0).* On 189 Lean tasks the best model (o3) reached 72.6% code / 52.3% spec but **a mere 4.9% end-to-end proof success** (one trial). Grounds: one-shot LLM proof is near-total failure → staged/assisted verification (the `verify` rationale).

<a id="VERICODING"></a>
**[VERICODING] A Benchmark for Vericoding: Formally Verified Program Synthesis.** Bursuc et al. **arXiv:2509.22908** (preprint). *Verified (June 2026, audit O-0).* ~12,504 specs; best-approach success is **language-specific — Dafny 82% (68%→96% over a year), Verus 44%, Lean 27%**. Cite the language-specific framing only; do NOT generalize to "mechanized proof is no longer single-digit" (Lean is still 27%, consistent with [VERINA]'s 4.9%).

<a id="HILBENCH"></a>
**[HILBENCH] HiL-Bench: Do Agents Know When to Ask for Help?** **arXiv:2604.09408** (preprint; not yet peer-reviewed). *Verified (June 2026).* Frontier agents solve up to ~89% of SWE/SQL tasks with full info, but on messy/ambiguous specs the best model drops to **~24% even when given a tool to ask for help**. Grounds: agents do not reliably self-clarify, so unresolved ambiguity must be surfaced before implementation.

<a id="PBR"></a>
**[PBR] Perspective-Based Reading.** Basili, Green, Laitenberger, Lanubile, Shull, Sørumgård, Zelkowitz. **Empirical Software Engineering 1(2), 1996** (with later replications). *Verified (July 2026, established SE technique).* Assigning reviewers **distinct perspectives** (e.g. tester / developer / user) gives better defect coverage than the same number of readers each reading the same way — coverage comes from perspective **diversity**, not reviewer count. Grounds: the review stance pool is a set of **distinct** perspectives, and cycling them is how coverage is bought without a large simultaneous panel (with [[DIVSCALE]]).

<a id="ENSEMBLEDIV"></a>
**[ENSEMBLEDIV] Ensemble Monitoring for AI Control: Diverse Signals Outweigh More Compute.** Koran, Yun, Tetef, Arnav, Bernabeu-Pérez. **arXiv:2605.15377** (2026 preprint). *Verified (July 2026, direct fetch — title + thesis confirmed; the widely-summarized "k=3 marginal-gain ceiling / >95%" figure was **NOT** confirmed against the primary text, so it is deliberately not carried here as a number).* Thesis: signal **diversity** beats raw ensemble size / compute — correlated members add little. Grounds (preliminary): a few **varied, cheaper** reviewers beat more identical or more expensive ones — the cheap-plus-varied reviewer default; with [[DIVSCALE]], [[CONSENSUS]]. *(This entry is itself an honesty marker: a number that appeared in secondary summaries did not survive primary verification and so is not stated as fact.)*

<a id="DIVSCALE"></a>
**[DIVSCALE] Understanding Agent Scaling in LLM-Based Multi-Agent Systems via Diversity.** Yang, Qu, Wen, Shi, Wen, Zhang, Wierman, Gu. **arXiv:2602.03794** (2026 preprint). *Verified (July 2026, direct fetch).* Full-diversity (distinct model + persona) at **2 agents** matches/exceeds homogeneous fan-out at **16 agents** (Vote ~67.7 vs ~65.3), averaged over 7 QA/reasoning benchmarks — but read the mechanism honestly: the **8× ratio is largely a saturation artifact** of the homogeneous baseline (marginal gain per identical agent collapses toward zero past N≈4–8), and the matched-count diversity delta is only **~3–6pp** (+4.4 Vote / +3.3 Debate). All numbers are 7–8B open-weight models on academic QA/math; **transfer to code review is untested** (the paper lists agentic workflows as unevaluated). Grounds (preliminary): prefer a few genuinely diverse reviewers over more identical copies (the *ordering*), not "diversity is large" (the *ratio*).

<a id="CONSENSUSCOST"></a>
**[CONSENSUSCOST] The Cost of Consensus: reviewer independence vs peer-rationale exchange.** Bertalanič, Fortuna. **arXiv:2605.00914** (2026 preprint). *Verified (July 2026, direct fetch — full-text noise control checked).* Reading peers' raw same-round outputs induces modal sycophancy up to **85.5%** and discards already-correct answers (oracle gap up to **32.3pp**); **isolated** self-correction matched or beat debate (MMLU-Hard 66.7% vs 60.7%, p<0.001) at **2–3× lower** token cost. Caveat that bounds the mechanism: task-*irrelevant* peer rationales performed **equal-or-better** than real ones — the authors attribute failure to RLHF **sycophantic conformity, not Condorcet/correlated-error diversity collapse**, and the tested cure is *total isolation*, not an "adjudicated summary." All 7–8B same-model math/QA debaters. Grounds (preliminary): withholding raw same-round reviewer outputs is evidence-consistent; the exchange-format remedy is open, not settled.

<a id="FLIPFLOP"></a>
**[FLIPFLOP] The FlipFlop Experiment: ungrounded challenge degrades LLM answers.** Laban et al. **arXiv:2311.08596** (preprint). *Verified (July 2026, direct fetch).* An ungrounded challenge ("are you sure?") causes an average **~17% accuracy drop** with a **46% answer-flip rate** across 10 LLMs and 7 tasks — models abandon correct answers under social pressure absent any new evidence. Grounds (with [CRITIC-TOOL], [NOSELFCORRECT]): critique must rest on a reliable, actionable signal, not model self-doubt or rhetorical pressure (ADR-0121).

<a id="BIGGERNOTBETTER"></a>
**[BIGGERNOTBETTER] Bigger Isn't Always Better: A Comparative Evaluation of LLMs for Automated Code Review.** Kumar, Bararia, Raj. **arXiv:2606.15689** (2026 preprint — **vendor-produced**: a VibeOps project; VibeOps sells LLM code review). *Verified (July 2026, direct fetch).* Two signals must be separated. **Robust and uncontested:** the synthetic→real collapse — F1 **0.847 → 0.066 (~92% drop)** on real bug-fix PRs, plus a diff-size cliff (F1 0.657 <10 lines → 0.043 >150 lines, ~15×). **Weak / not significant:** the "smaller wins" gap (Haiku 4.5 F1 0.365 vs Sonnet 0.343) is **admittedly non-significant** (the paper's own Limitation #6), and Sonnet wins on precision + severity-weighted F1; an independent academic benchmark (CR-Bench, arXiv:2603.11078) finds the *stronger* model wins on recall/F1/SNR ("model scale matters"). Grounds (preliminary): validate any model/preset on **real PRs matched to the target diff-size regime**, and do **not** key a routing ladder to model size/tier — it is non-monotonic for review.

<a id="SKILLSWILD"></a>
**[SKILLSWILD] Agent Skills in the Wild: An Empirical Study of Security Vulnerabilities at Scale.** **arXiv:2601.10338** (2026 preprint). *Verified (July 2026, direct fetch).* Across **n=31,132** marketplace skills: **26.1%** carry ≥1 vulnerability, 5.2% show high-severity malicious-intent patterns, 13.3% data-exfiltration; and **script-bearing skills are 2.12× more likely to be vulnerable than instruction-only** (OR=2.12, p<0.001). Grounds (preliminary): a conservative, instruction-only, no-executable-script skill v1 is a low-cost base-rate reducer — one defense-in-depth layer, not solved safety. Base rates are consumer marketplaces, not a code-review deployment.

<a id="REVBOTPR"></a>
**[REVBOTPR] On the Footprints of Reviewer-Bot Feedback on Agentic Pull Requests in OSS GitHub Repositories.** **arXiv:2604.24450** (2026 preprint). *Verified (July 2026, direct fetch).* On **4,532 real PRs / 7,416 comments**: higher review-comment volume correlates with **longer** resolution (Spearman ρ=**0.19**, adj_p=7e-13) and **lower** relevance (ρ=**−0.20**) and clarity (ρ=−0.19) — added review volume dilutes rather than adds. Grounds (preliminary, code-review-native): measure marginal *unique-accepted-finding* value and stop early; more reviewer output is not more signal.

<a id="SINGLEBEATSMAS"></a>
**[SINGLEBEATSMAS] Single-Agent LLMs Can Outperform Multi-Agent Systems Under Equal Thinking-Token Budgets.** Tran, Kiela (Stanford). **arXiv:2604.02460** (2026 preprint). *Verified (July 2026, search + abstract).* Under a **matched** thinking-token budget, a single agent (0.427) beat **all five** MAS variants — including heterogeneous debate / role-specialist designs (best MAS 0.420) — on FRAMES/MuSiQue, grounded in the Data Processing Inequality (inter-agent messages can only lose information); MAS won only under degraded-context regimes. Grounds (preliminary): a live counter-consideration — before fanning out reviewers at all, weigh equal-compute accounting; fan-out is not a free lunch.

<a id="MEMGRAFT"></a>
**[MEMGRAFT] MemoryGraft: Persistent Compromise of LLM Agents via Poisoned Experience Retrieval.** **arXiv:2512.16962** (2025 preprint). *Verified (July 2026, direct fetch).* Poisoning **~9%** of an agent's memory (10/110 records) caused **47.9%** of retrievals to surface the poisoned record — trigger-free and persistent until purge — establishing that similarity-retrieved memory with no source/transformation metadata is unguarded. Grounds (with [MINJA], [AGENTPOISON]): provenance-before-trust and correction are the design levers; a native memory remains a claim with evidence, not a second source of truth ([ADR-0142](../adrs/0142-findings-become-native-memories.md)).

<a id="MEMBENCH-CAVEAT"></a>
**[MEMBENCH-CAVEAT] Memory-system outcome benchmarks (Mem0, Zep) are contested and instrument-limited.** Mem0 (arXiv:2504.19413, ECAI 2025); Zep (arXiv:2501.13956); with the LoCoMo audits. *Verified (July 2026, direct fetch + issue-tracker review).* The headline "memory improves outcomes" numbers do **not** survive scrutiny as load-bearing: Mem0 fails independent reproduction (~0.20 vs published), a plain **full-context baseline (~73% J) beats Mem0 (~68%) on Mem0's own LoCoMo data**, and the LoCoMo instrument is **invalid below ~63%** (6.4% of its answer key is wrong; its LLM judge accepts **62.8%** of intentionally-wrong answers). Zep's 84%→58.44% is a **contested vendor cross-accusation**, not a settled correction. All deltas are conversational-QA; none transfer to code workflows. Grounds (**do-not-load-bear**): justify memory by the trust/provenance argument ([MEMGRAFT], [AGENTPOISON], [MINJA]), never by a measured outcome gain.

<a id="INSTRROT"></a>
**[INSTRROT] Instruction-file rot: prevalence measured, output-quality effect unmeasured.** "Context Rot in AI-Assisted Software Development" (Treude & Baltes, arXiv:2606.09090); "Configuration Smells in AGENTS.md Files" (arXiv:2606.15828). *Verified (July 2026, direct fetch).* Stale/inconsistent agent-instruction files are **prevalent** — referential rot in **23.0%** of 356 repos (DOCER checker; per-file stale rate only 1.0–1.4%, 24% false positives), config smells in **91/100** repos — **but no primary source measures whether staleness degrades agent OUTPUT quality**; both defer behavioral impact to future work. Grounds (preliminary): treat stale native memory and instructions as human-resolved inconsistency hygiene; do **not** claim a quality-degradation effect (a hypothesis, not a result) — distinct from the measured context-*length* effect [CTXLENHURTS].

<a id="OVEREAGER"></a>
**[OVEREAGER] Overeager Coding Agents: Measuring Out-of-Scope Actions on Benign Tasks.** Qu, Zhang, Zhang, Deng, Li, Zhang, Liu. **arXiv:2605.18583** (preprint). *Verified (July 2026, direct fetch).* Stripping the scope/consent declaration alone raises the overeager (out-of-scope action) rate **0.0% → 17.1%** on paired scenarios (+11.9 to +17.2pp across frameworks). Grounds: explicit scope declarations measurably suppress out-of-scope agent actions — the Non-goals/Do-not-change rationale, now with a number.

<a id="IMPOSSIBLE"></a>
**[IMPOSSIBLE] ImpossibleBench: Measuring LLMs' Propensity of Exploiting Test Cases.** Zhong, Raghunathan, Carlini. **arXiv:2510.20270** (preprint). *Verified (July 2026, direct fetch of full text).* Under a bare prohibition ("DO NOT MODIFY THE TESTS") cheating exceeds **85%** (GPT-5, o3); the strictest prompt with explicit STOP directives lowers it to **1%** (GPT-5) / 33% (o3); adding an abort/flag-for-human option cuts cheating **54%→9%** (GPT-5) / 49%→12% (o3), with model-dependent effect (minimal on Opus 4.1). Grounds: bare "do not X" is weak; pair a prohibition with an explicit stop-and-ask escape.

<a id="MEMDECAY"></a>
**[MEMDECAY] How Memory Management Impacts LLM Agents: An Empirical Study of Experience-Following Behavior.** Xiong, Lin, Xie, He, Liu, Tang, Lakkaraju, Xiang. **arXiv:2505.16067** (preprint). *Verified (July 2026, direct fetch).* Indiscriminate add-all experience accumulation degrades performance over time via **error propagation and misaligned experience replay**; regulating experience quality in the memory bank restores it. Grounds: deciding what becomes native memory is load-bearing, not clerical hygiene ([ADR-0142](../adrs/0142-findings-become-native-memories.md); with [MEMP]).

<a id="MEMCODER"></a>
**[MEMCODER] Your Code Agent Can Grow Alongside You with Structured Memory.** Deng, Liu, Zhang, Yang, Yang. **arXiv:2603.13258** (preprint). *Verified (July 2026, direct fetch).* Structured historical experience (intent-to-code mappings distilled from past commits, with self-refinement) yields **+9.4% resolved rate on SWE-bench Verified** over the DeepSeek-V3.2 baseline. Grounds: curated durable memory can measurably help a code agent — the positive half of the memory story ([MEMDECAY] is the boundary).

<a id="CCR"></a>
**[CCR] Cross-Context Review: Improving LLM Output Quality by Separating Production and Review Sessions.** Song. **arXiv:2603.12123** (preprint; single author, 30 artifacts / 150 injected errors / 360 reviews — small N). *Verified (July 2026, direct fetch).* Fresh-context review reached **F1 28.6% vs 24.6% same-session self-review, 23.8% context-aware subagent, 21.7% repeated self-review** (significant); repetition without separation did not help. Grounds: fresh-context isolation for independent review, directly if modestly supported.

<a id="SELFREVIEW-MOD"></a>
**[SELFREVIEW-MOD] Articulate but Wrong: Self-Review Failures in LLM-Based Code Modernization.** Purnachandra Reddy, Lolla, Sanku. **arXiv:2605.21537** (preprint). *Verified (July 2026, direct fetch).* Across 1,980 modernization attempts / 11 models, ~40% of problem snippets had semantic-preservation failures and **31.7% were silently endorsed by the model that produced them** — some models articulate the exact semantic hazard, then declare preservation anyway. Grounds: self-review is structurally unreliable at the write layer; independence is not optional (ADR-0119).

<a id="EXPERTSBACK"></a>
**[EXPERTSBACK] Multi-Agent Teams Hold Experts Back.** Pappu, El, Cao, di Nolfo, Sun, Cao, Zou. **arXiv:2602.01011** (preprint). *Verified (July 2026, direct fetch).* Self-organizing LLM teams underperform their best member by **up to 41.1%** via "integrative compromise" — averaging expert and non-expert views; worsens with team size. Grounds: a review lead must **union-and-reconcile findings, never majority-filter** — consensus aggregation dilutes the best reviewer (ADR-0122's lead design; the union-not-vote clarification — a vote remains only for a contested rejection).

<a id="PLANCOMPLY"></a>
**[PLANCOMPLY] Evaluating Plan Compliance in Autonomous Programming Agents.** Liu, Dehghan, Ganhotra, Hirzel, Jabbarvand. **arXiv:2604.12147** (preprint). *Verified (July 2026, direct fetch).* 16,991 SWE-agent trajectories: providing a standard plan improves resolution, and **periodic plan reminders further improve compliance and success** — agents without guidance revert to overfitted training patterns. Grounds: a re-surfaced plan can measurably shape execution when the work earns one, with the staleness boundary at [INSTRROT]/[CTXLENHURTS].

<a id="SELFPLAN"></a>
**[SELFPLAN] Self-planning Code Generation with Large Language Models.** Jiang, Wang, Wang, Zhang, Lian, Li, Jin. **arXiv:2303.06689** (preprint; later TOSEM). *Verified (July 2026, direct fetch — abstract figure confirmed).* Eliciting a short plan before implementation gives a **relative +25.4% Pass@1** over direct code generation across benchmarks. Grounds (preliminary, the counterweight to the "ceremony is inert" read): a *targeted, execution-shaping* structure — a lean plan the coder then follows — measurably helps, distinct from generic process artifact ([[SWESKILLS]]/[[SKILLSBENCH26]] show the inert kind); pairs with [[PLANCOMPLY]] (plan + reminders improve compliance). The doctrine that structure earns its place by changing execution, not by existing (ADR-0131).

<a id="SKILLSBENCH26"></a>
**[SKILLSBENCH26] SkillsBench: Benchmarking How Well Agent Skills Work Across Diverse Tasks.** Li et al. (77 authors). **arXiv:2602.12670** (preprint). *Verified (July 2026, direct fetch).* **Curated, task-matched skills raise average pass rate 33.9% → 50.5% (+16.6pp**; per-config +4.1 to +25.7pp); focused skills of **≤3 modules beat larger bundles**; skilled smaller models rival unskilled larger ones. Grounds (with [SWESKILLS]): the split is curation and task-fit, not skills-yes/no — generic skills mostly do nothing, task-matched ones pay; keep skill bodies small and matched.

<a id="FALSESUCCESS"></a>
**[FALSESUCCESS] From Confident Closing to Silent Failure: Characterizing False Success in LLM Agents.** Advani. **arXiv:2606.09863** (preprint). *Verified (July 2026, direct fetch).* False success is **45–48% of failures where only the agent's self-report is available vs ~3% where the environment exposes independently observable ground truth** (~15×); lightweight statistical detectors beat LLM judges at catching it. Grounds: the evidence rule's target failure mode, quantified — claims need independently checkable state, not confident prose.

<a id="SILENTSEM"></a>
**[SILENTSEM] Confident and Wrong: Silent Semantic Failures in Coding Agents.** Mehta. **arXiv:2603.25764** (preprint). *Verified (July 2026, direct fetch).* Frontier agents **submit near-always (99–100%) while resolving 18–44%**; silent semantic failures affect 68–80% of failing runs and are invisible to completion metrics. Grounds (with [FALSESUCCESS]): completion claims are near-worthless as evidence; independent, evidence-backed review addresses a measured, severe failure class.

<a id="UNDERSPEC-HELPS"></a>
**[UNDERSPEC-HELPS] When Prompt Under-Specification Improves Code Correctness.** Akli, Papadakis, Cordy, Le Traon. **arXiv:2604.24712** (preprint). *Verified (July 2026, direct fetch).* Counter-evidence with a mechanism: reducing specification can **improve** correctness by breaking misleading lexical/structural cues that trigger wrong retrieval-based strategies in over-detailed prompts. Grounds: prefer a lean spec over exhaustive specification when added detail does not change execution; detail is not free (with [HUMANEVALCOMM]'s indiscriminate-clarification result).

<a id="MISALIGN20K"></a>
**[MISALIGN20K] How Coding Agents Fail Their Users: A Large-Scale Analysis of Developer-Agent Misalignment in 20,574 Real-World Sessions.** Tang et al. **arXiv:2605.29442** (preprint; field telemetry). *Verified (July 2026, direct fetch).* Underspecified/ambiguous instructions account for **15.36%** of misalignment episodes (44.1% of intent-misreads trace to prompt gaps) — but the **largest cause is instruction-following failure on clearly stated requirements (36.49%)**. Grounds: spec clarity is load-bearing AND insufficient — verification of compliance (review, checks) addresses the majority class clarity cannot.

<a id="EBSE04"></a>
**[EBSE04] Evidence-Based Software Engineering.** Kitchenham, Dybå, Jørgensen. **ICSE 2004**. *Verified (July 2026, adversarial 3-vote source pass; identity + findings confirmed against the text).* As of 2004 SE had no EBM-comparable research infrastructure and practice adoption ran on advocacy, with existing evidence almost entirely laboratory-tier. Grounds: the historical baseline — process practices are normally adopted without outcome evidence; a methodology that labels its unproven claims is the exception, not the laggard.

<a id="AGILE-EVID"></a>
**[AGILE-EVID] Empirical studies of agile software development: A systematic review.** Dybå, Dingsøyr. **Information and Software Technology 50(9–10):833–859, 2008**, DOI 10.1016/j.infsof.2008.01.006. *Verified (July 2026, adversarial 3-vote source pass).* Of **1,996** agile studies to 2005, **36 (~1.8%)** met the rigor bar; GRADE-graded strength of evidence for agile's benefits: **"very low"** — while adoption swept the industry. Grounds (with [EBSE04]): the field-normal evidence bar for process methodology is belief plus anecdote; outcome proof has never preceded adoption.

<a id="BELIEFEVID"></a>
**[BELIEFEVID] Belief & Evidence in Empirical Software Engineering.** Devanbu, Zimmermann, Bird. **ICSE 2016**. *Verified (July 2026, adversarial 3-vote source pass against the author PDF).* 564 Microsoft developers: **personal experience dominates** technical opinion formation while research papers rank fifth of six; process beliefs diverge sharply between projects whose measured effects are both negligible; coding standards are believed in at 4.18/5 with a single scant published result. Grounds: practitioner conviction is not outcome evidence — for competitors' testimonials and for ours.

### First-party guidance and preliminary evidence

These sources are **not peer-reviewed**. They may provide implementation guidance or preliminary evidence, never grounds for a `MUST`.

<a id="ANTHROPIC-MULTIAGENT"></a>
**[ANTHROPIC-MULTIAGENT] How we built our multi-agent research system.** Anthropic Engineering, 2025. *Verified (June 2026, direct fetch).* First-party orchestrator-worker account: states verbatim that "each subagent needs an objective, an output format, guidance on the tools and sources to use, and clear task boundaries," and that "without detailed task descriptions, agents duplicate work, leave gaps, or fail to find necessary information." Does **not** claim subagents are unaware of their orchestrated role (that observation is from other vendors' subagent guidance and is design rationale here). **Tier: first-party engineering analysis, not peer-reviewed — never a `MUST`.** Grounds (illustrative): delegated workers need an explicit brief and return contract; this supports Corpus's dispatch contract.

<a id="SUPERPOWERS"></a>
**[SUPERPOWERS] Superpowers repository and release notes.** Jesse Vincent, 2025–2026. *Verified (August 2026, current repository and release notes).* First-party practice reports support design alignment before consequential implementation, project worktrees, bounded review, scoped re-review, explicit model routing, falsifiable tests, and removal of recap prose. These are product reports, not controlled external evidence; they supply failure hypotheses and implementation examples, never universal laws. <https://github.com/obra/superpowers> <https://github.com/obra/superpowers/blob/main/RELEASE-NOTES.md>

<a id="QIAO-BROWNFIELD"></a>
**[QIAO-BROWNFIELD] Comprehension–Performance Gap in GenAI-Assisted Brownfield Programming: A Replication and Extension.** Qiao et al. **arXiv:2511.02922** (preprint), 4 Nov 2025. *Verified (July 2026, direct fetch).* In a within-subjects study of 18 graduate students, Copilot reduced task time and increased tests passed, but comprehension scores did not differ significantly between conditions. <https://arxiv.org/abs/2511.02922> Grounds: faster brownfield progress does not establish improved codebase understanding; the study does not establish that a particular governance artifact fixes the gap.

<a id="CODERABBIT"></a>
**[CODERABBIT] State of AI vs Human Code Generation.** CodeRabbit, February 2026. *Verified (July 2026, direct report page).* CodeRabbit analyzed 470 open-source pull requests (320 classified as AI-co-authored and 150 as human-only) and reported **10.83 issues per AI-co-authored PR** versus **6.45** for human-only PRs, a **1.7×** ratio. Authorship was inferred from observable signals, the human-only set may include undisclosed AI use, and CodeRabbit both produced the study and sells code review. <https://www.coderabbit.ai/blog/state-of-ai-vs-human-code-generation-report> — *vendor study; preliminary, not causal.* Grounds: one vendor dataset reports different issue rates between its inferred authorship groups. CodeRabbit's shipped acceptance-criteria validation is recorded separately at [[CODERABBIT-PRVAL]](#CODERABBIT-PRVAL).

<a id="TERMBENCH"></a>
**[TERMBENCH] Terminal-Bench: Benchmarking Agents on Hard, Realistic Tasks in Command Line Interfaces.** Merrill et al. **arXiv:2601.11868** (preprint). *Verified (June 2026, direct fetch).* 89 curated hard terminal tasks with human solutions + verification tests; **frontier models/agents score < 65%**. Grounds: agent performance is a *systems* problem, not model-only — the harness/verification layer is where reliability is won (the `verify`/`review` rationale).

<a id="HAL"></a>
**[HAL] Holistic Agent Leaderboard: The Missing Infrastructure for AI Agent Evaluation.** Kapoor, Stroebl, … Narayanan (Princeton et al.). **arXiv:2510.11977** (preprint). *Verified (June 2026, direct fetch).* A standardized evaluation harness cut evaluation time weeks→hours; **21,730 agent rollouts** analyzed; LLM-aided inspection surfaced previously-unreported failure behaviours. Grounds: a standardized harness plus inspectable execution evidence materially improves agent evaluation.

<a id="HARNESSBENCH"></a>
**[HARNESSBENCH] Harness-Bench: Measuring Harness Effects across Models in Realistic Agent Workflows.** Yao et al. **arXiv:2605.27922** (preprint). *Verified (June 2026, direct fetch + search).* 106 sandboxed tasks, 5,194 trajectories; configuration-level harness choice produced a **23.8-point** aggregate gap (best configurable harness 76.2 vs worst 52.4) on the same task set + model-backend pool. Grounds: the *harness/system* matters as much as the model — Corpus's leverage is explicit intent, verification, and independent review, not a model claim.

<a id="AHE"></a>
**[AHE] Agentic Harness Engineering: Observability-Driven Automatic Evolution of Coding-Agent Harnesses.** Lin et al. **arXiv:2604.25850** (preprint). *Verified (June 2026, direct fetch).* Lifted Terminal-Bench 2 pass@1 **69.7% → 77.0%** over ten iterations; the gains came from **tools, middleware, and long-term memory — not the system prompt**. Grounds: harness mechanisms can affect outcomes beyond prompt wording; this does not isolate any Corpus mechanism.

<a id="ORCHID"></a>
**[ORCHID] Assessing the Impact of Requirement Ambiguity on LLM-based Function-Level Code Generation (Orchid).** Yang et al. **arXiv:2604.21505** (preprint). *Verified (June 2026, direct fetch).* 1,304 function-level tasks across four ambiguity types: ambiguity **consistently degrades** generation (worst on the most advanced models); LLMs produce **functionally divergent** implementations from the same ambiguous requirement; and **models cannot reliably identify or resolve ambiguity on their own**. Grounds: supports explicit requirements and advisory ambiguity checks. It does not measure Corpus. Reinforces [SMELLS].

<a id="METR"></a>
**[METR] Measuring the Impact of Early-2025 AI on Experienced Open-Source Developer Productivity.** Becker, Rush, Barnes, Rein (METR). **arXiv:2507.09089** (preprint). *Verified (June 2026, direct fetch).* RCT, 16 experienced OSS devs, 246 tasks: allowing early-2025 AI **increased completion time ~19%**, even though devs expected a 24% speedup and *believed afterward* they were 20% faster (experts predicted 38–39% faster). Grounds: **perceived ≠ measured** — a self-reported "done"/"faster" is not evidence; independently checkable evidence is. (Scope: experienced devs on mature repos, n=16, early-2025 tools. **Verified July 2026:** METR's 2026 follow-up experiment was **abandoned as unreliable** — task self-selection bias compromised the data — and METR states developers are *likely* sped up by early-2026 tools, on weak evidence either way. Do not cite the 19% as a current-tools fact; the durable finding is the **perception gap** — believed +20% while measured −19% — i.e., self-reports are not outcome evidence.)

<a id="SMARTBEAR"></a>
**[SMARTBEAR] Code Review at Cisco Systems** (in *Best Kept Secrets of Peer Code Review*). Cohen, Smart Bear Software, 2006. *Verified (June 2026, web — the canonical case-study PDF).* The largest lightweight-review case study of its time (2,500 reviews, 3.2M LOC, 50 developers, 10 months): defect-detection effectiveness is best on **small changes — LOC under review under 200, not to exceed ~400** — and falls past **~60–90 minutes** of review or at inspection **rates above ~400–500 LOC/hour** (the rate metric is distinct from the absolute size ceiling). <https://static0.smartbear.co/support/media/resources/cc/book/code-review-cisco-case-study.pdf> — **industry-dataset, not peer-reviewed; a single vendor-derived 2006 in-situ dataset — cite the 200–400 LOC band as a heuristic, never as law.** Grounds: the size anchor for the oversized-packet heuristic (ADR-0094).

<a id="CLAUDE-FILES"></a>
**[CLAUDE-FILES] Explore the .claude directory.** Anthropic, Claude Code documentation.
*Verified (July 2026, direct fetch).* Enumerates Claude Code's named configuration and managed
application-data paths, including automatic cleanup; defines no generic artifact-discovery
directory. <https://code.claude.com/docs/en/claude-directory> Grounds: ordinary Markdown does not
gain a supported Claude capability from directory adjacency.

<a id="CODEX-FILES"></a>
**[CODEX-FILES] Codex configuration implementation.** OpenAI, `openai/codex`.
*Verified (July 2026, direct source inspection).* Defines Codex home, instructions, skills,
session, history, memory, and state configuration separately; defines no generic
artifact-discovery directory.
<https://github.com/openai/codex/blob/main/codex-rs/core/src/config/mod.rs> Grounds: ordinary
Markdown does not gain a supported Codex capability from directory adjacency.

<a id="CURSOR-FILES"></a>
**[CURSOR-FILES] @Files & Folders.** Cursor documentation. *Verified (July 2026, direct fetch).*
Defines explicit file and folder context selection; arbitrary files enter context through
selection, not a vendor artifact directory.
<https://docs.cursor.com/context/%40-symbols/%40-files-and-folders> Grounds: portable Corpus
artifacts need an explicit path, not Cursor-directory adjacency.

<a id="AIDER-FILES"></a>
**[AIDER-FILES] Specifying coding conventions.** Aider documentation.
*Verified (July 2026, direct fetch).* Defines `/read <path>` and `--read <path>` for explicit
read-only file context; placement alone does not load a file.
<https://aider.chat/docs/usage/conventions.html> Grounds: portable Corpus artifacts need an
explicit path, not Aider-directory adjacency.

## Rejected — DO NOT CITE (fabricated / misattributed / unconfirmed)

The skill-authoring literature attributes load-bearing figures to these arXiv ids. **Direct fetch
(June 2026) found each id resolves to an unrelated paper.** They are recorded here so the
fabrication is never re-introduced.

Rejected entries carry no `<a id="...">` anchor. Do not cite them or add anchors to them.

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

*Discipline: a claim in `docs/research/` cites a Verified entry, or carries an explicit "preliminary / non-peer-reviewed" caveat naming a Caveated entry, or it is not made. New sources are web-verified before they are added. This follows Corpus's evidence discipline ([principles](../method.md#principles), *Preserve source limits*).*
