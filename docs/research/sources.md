# Sources — the framework's evidence bibliography

> This is the single bibliography the framework's **inline `[[KEY]]` citations resolve to**. Research is referenced *contextually* — each `[[KEY]]` sits in the doc whose claim it grounds (the happy-path pages, reference pages, examples, and ADRs) and links to its entry here; there is no separate "research layer" of standalone essays, only this ledger. It is held to the **§0.7 discipline** ("real science, not astrology"): every load-bearing empirical claim cites a **verified** entry below, with the recorded caveats. Entries marked **caveated** (non-peer-reviewed) MUST NOT carry a `MUST`-level claim. Entries in **Rejected** MUST NOT be cited — they are recorded so a fabricated citation is never silently re-introduced.
>
> Entries are retained even while uncited — the ledger records what was verified (and what was rejected) so future claims can bind to it without re-verification; an uncited entry is inventory, not error. This bibliography was assembled **after web-verification** (June 2026). Several headline figures that circulate in the skill-authoring literature rested on **fabricated/misattributed arXiv ids** and were rejected (see below). A few entries were already verified by the framework's own bibliography elsewhere; this ledger **reuses that key** rather than re-deriving it.

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
**[MINJA] Memory Injection Attacks on LLM Agents via Query-Only Interaction (MINJA).** Dong, Xu, He, Li, Tang, Liu, Liu, Xiang. **NeurIPS 2025**, arXiv:2503.03704. *Verified (June 2026, OpenReview + search).* A query-only attacker injects malicious records into an agent's memory (~98% injection success; ~70–77% downstream attack success) that later fire on benign queries. Grounds **threat-motivated design, not a measured reliability gain**: the epistemic-stance boundary — durable memory/findings carry stance + provenance so a lower-stance or injected record cannot masquerade as authoritative. *The attack is measured; Corpus's defense against it is design, not a measured delta.*

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
**[SPECFIX] Automated Repair of Ambiguous Problem Descriptions for LLM-Based Code Generation.** Jia, Morris, Ye, Sarro, Mechtaev. **ASE 2025**, arXiv:2505.07270. *Verified (June 2026, direct fetch + adversarial re-verification, 4/4 votes).* Repairing only the requirement TEXT (no interaction) modified **43.58%** of benchmark descriptions and improved Pass@1 on the modified subset by **30.9%** (+4.09% absolute benchmark-wide); repaired descriptions transfer across models (**+10.48%**). Grounds: a clarified spec is a durable, model-agnostic artifact — clearer written requirements causally improve correctness. Scope caveat: function-level benchmarks, not repo-level workflows.

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
**[ZHENG-PERSONA] When "A Helpful Assistant" Is Not Really Helpful: Personas in System Prompts Do Not Improve Performances.** Zheng, Pei, Jurgens, et al. **EMNLP 2024 (Findings)**, arXiv:2311.10054. *Verified (June 2026, deep-research direct fetch + 3-vote).* Across **162 roles, 4 LLM families, and 2,410 factual questions**, adding a persona to the system prompt did **not** systematically improve accuracy over a no-persona control, and the per-persona effect is **essentially random**. Grounds: a persona's *identity* is not a reliable lever on objective tasks — the value of a "stance" is its concrete directives, not the role label (the basis for collapsing the 1:1 authoring personas, ADR-0093).

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

<a id="RIGBY13"></a>
**[RIGBY13] Convergent Contemporary Software Peer Review Practices.** Rigby & Bird. **ESEC/FSE 2013, pp. 202–212**, DOI 10.1145/2491411.2491444. *Verified (June 2026, web — MSR author PDF, text-extracted).* Across drastically different projects, modern review **converged on small changes** — median *change* sizes of tens of lines (e.g. Android/AMD 44, Chrome 78; vs the prior-OSS Apache 25 / Linux 32 contrast and traditional inspection's 263). Grounds: small, self-contained units are the field-convergent norm a task should target (ADR-0094).

<a id="MANTYLA09"></a>
**[MANTYLA09] What Types of Defects Are Really Discovered in Code Reviews?** Mäntylä & Lassenius. **IEEE TSE 35(3):430–448, 2009**, DOI 10.1109/TSE.2008.71. *Verified (June 2026, web — Aalto repository PDF).* Of 759 classified review defects (388 industrial + 371 student), **roughly 75% do not affect visible functionality** — they are *evolvability* defects (documentation, structure, readability) that execution-based QA cannot detect (confirming Siy & Votta). Grounds: review's primary payload is the maintainability/design layer tests are blind to (ADR-0095).

<a id="BACCHELLI13"></a>
**[BACCHELLI13] Expectations, Outcomes, and Challenges of Modern Code Review.** Bacchelli & Bird. **ICSE 2013, pp. 712–721**, DOI 10.1109/ICSE.2013.6606617. *Verified (June 2026, web — author PDF).* Over 570 Microsoft review comments, **defect comments are a minority (~14%, 4th of nine categories)** while code-improvement comments dominate (~29%); review's outcomes are less about finding errors than expected and also deliver knowledge transfer and team awareness. Grounds: foreground evolvability/design findings as first-class; defect-catching is one outcome among several (ADR-0095).

<a id="MCINTOSH14"></a>
**[MCINTOSH14] The Impact of Code Review Coverage and Participation on Software Quality** (Qt, VTK, ITK). McIntosh, Kamei, Adams, Hassan. **MSR 2014, pp. 192–201**, DOI 10.1145/2597073.2597076. *Verified (June 2026, web — author/ACM).* Coverage and participation each independently bear on quality: low coverage is estimated to add up to **two** post-release defects, **low participation up to five** — "coverage alone does not guarantee" quality. Grounds: participation (substantive engagement), not a sign-off, is the gate (ADR-0095).

<a id="GPTDROID"></a>
**[GPTDROID] Make LLM a Testing Expert (GPTDroid): Human-like Mobile GUI Testing.** Liu, Chen, Wang, et al. **ICSE 2024, pp. 1222–1234**, DOI 10.1145/3597503.3639180 (arXiv:2310.15780). *Verified (June 2026, web — arXiv).* An LLM agent driving live Google Play apps found **53 new bugs, of which 35 were confirmed and fixed** by developers. Grounds: an agent exercising the running app surfaces real defects — valuable as *evidence*, judged by a human/independent reviewer (ADR-0095).

<a id="ITKONEN14"></a>
**[ITKONEN14] Are test cases needed? Replicated comparison between exploratory and test-case-based software testing.** Itkonen & Mäntylä. **Empirical Software Engineering 19(2):303–342, 2014**, DOI 10.1007/s10664-013-9266-8. *Verified (June 2026, web — Springer).* A replicated experiment (51 students, jEdit): **no statistically significant difference in defect-detection effectiveness** between exploratory and scripted testing (p=0.093); exploratory is more *efficient* (less design effort) and scripted yields more false positives. *Scope: a student experiment; non-significant ≠ proven equivalence.* Grounds: exercising the app (exploratory) is a legitimate verifier mode, not inferior to scripted (ADR-0095).

<a id="WEBAGENTILLUSION"></a>
**[WEBAGENTILLUSION] An Illusion of Progress? Assessing the Current State of Web Agents.** Xue et al. (OSU-NLP). **COLM 2025**, arXiv:2504.01382. *Verified (June 2026, web — arXiv/OpenReview).* On Online-Mind2Web (300 realistic tasks, 136 sites, human-judged), the best agents reach ~61% (Operator) / 56% (Claude Computer Use 3.7) while **most cluster around ~30%** — driving live web UIs reliably is still limited. Grounds: an agent's app-run is unreliable → it is evidence for a human to judge, never an autonomous verdict (ADR-0095).

<a id="DOCROT"></a>
**[DOCROT] Detecting outdated code element references in software repository documentation.** Tan, Wagner, Treude. **Empirical Software Engineering 29:5, 2024**, DOI 10.1007/s10664-023-10397-6 (companion tool paper arXiv:2307.04291). *Verified (June 2026, web — OA journal PDF).* Across >3,000 GitHub projects (the 1,000 most-starred + Google's), **28.9% currently contain at least one outdated code-element reference**, and 82.3% were outdated at least once historically. *Scope: top-by-stars + Google repos — not generalizable to all docs.* Grounds: doc rot is measurable and common → durable artifacts need freshness + ownership, not write-once (ADR-0096).

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
**[KIRO] Amazon Kiro — spec-driven development.** AWS, 2025. *Verified (June 2026, kiro.dev/docs/specs).* Organizes each feature as `.kiro/specs/<feature>/` with `requirements.md` + `design.md` + `tasks.md`, and writes requirements in **EARS** (Easy Approach to Requirements Syntax) — the same controlled-clause shape Corpus's SOL uses. <https://kiro.dev/docs/specs/> — *vendor; cite as convention.* Grounds (with [SPECKIT]): the convergent per-feature-folder convention, and EARS as an established requirements-clause syntax.

<a id="ADR-CONV"></a>
**[ADR-CONV] Architecture Decision Records — the convention.** Nygard (2011); MADR template (adr.github.io); Fowler. *Verified (June 2026).* Decisions are recorded as short, immutable, **sequentially-numbered** Markdown files in a dedicated in-repo directory (`decisions/` or `docs/adr/`), one decision per file, superseded rather than rewritten. <https://adr.github.io/madr/> · <https://martinfowler.com/bliki/ArchitectureDecisionRecord.html> — *established convention.* Grounds: the project-wide `decisions/` home for ADRs and the supersession ledger.

<a id="DIATAXIS"></a>
**[DIATAXIS] Diátaxis — a systematic framework for technical documentation.** Procida. *Verified (June 2026, diataxis.fr).* Organizes documentation by user need into four distinct modes — tutorials, how-to guides, reference, explanation — kept separate because each serves a different purpose. <https://diataxis.fr/> — *reference framework.* Grounds: doc-organization-by-purpose (informs the skills / reference split; a full re-org of `docs/` was considered and declined as high-churn, low-payoff).

<a id="GARTNER-AGENTS"></a>
**[GARTNER-AGENTS] Gartner agentic AI adoption projection.** Gartner, cited in CSA/Token Security/Speakeasy industry analyses, 2025–2026. *Verified (June 2026, multiple independent citations).* Projects **40% of enterprise applications will embed task-specific AI agents by end of 2026**, up from under 5% in 2025. Grounds: agentic AI is moving into production faster than governance standards can keep pace.

<a id="AI-INDEX-2026"></a>
**[AI-INDEX-2026] Stanford HAI AI Index Report 2026.** Stanford Institute for Human-Centered AI, 2026. *Verified (June 2026, cited in Speakeasy/Elementum industry analyses).* Identifies **security and risk as the primary barrier to scaling agentic AI**, cited by **62% of organizations**. Grounds: governance, not model capability, is the current enterprise bottleneck.

<a id="CSA-AI-CYBER-2026"></a>
**[CSA-AI-CYBER-2026] State of AI Cybersecurity 2026.** Cloud Security Alliance / Token Security, April 2026. *Verified (June 2026, direct fetch of CSA research note).* Survey of 1,500+ security leaders: **65% of enterprises with deployed AI agents experienced a confirmed security incident**, **63% cannot enforce purpose limitations**, and **60% cannot terminate a misbehaving agent once running**. Grounds: operational controls for agentic AI lag behind adoption.

<a id="NIST-CAISI-RFI"></a>
**[NIST-CAISI-RFI] Request for Information Regarding Security Considerations for Artificial Intelligence Agents.** NIST Center for AI Standards and Innovation (CAISI), docket NIST-2025-0035, Federal Register, 8 Jan 2026. *Verified (June 2026, direct fetch via CSA research note).* Formal U.S. government acknowledgment that conventional cybersecurity approaches do not translate cleanly to autonomous agent deployments; comment period closed 9 Mar 2026. Grounds: agent-specific security controls are an active standards gap.

<a id="NIST-AI-AGENT-STANDARDS"></a>
**[NIST-AI-AGENT-STANDARDS] NIST AI Agent Standards Initiative.** NIST, announced 17 Feb 2026. *Verified (June 2026, direct fetch via CSA research note).* Multi-year standards effort organized around industry-led facilitation, open-source interoperability (MCP/A2A), and research on agent authentication/identity; first substantive deliverables not expected before late 2026. Grounds: enforceable, agent-specific security standards are not available today.

<a id="GOOGLESA"></a>
**[GOOGLESA] Lessons from Building Static Analysis Tools at Google.** Sadowski, Aftandilian, Eagle, Miller-Cushon, Jaspan. **Communications of the ACM 61(4), April 2018** (DOI 10.1145/3188720); the same criteria are restated in *Software Engineering at Google* (O'Reilly 2020), ch. 20 "Static Analysis". *Verified (June 2026, direct fetch of the SWE-book ch.20 + the paper summary). Authoritative engineering field report (a CACM practitioner article + the Google engineering book), not peer-reviewed primary research — cited as authoritative guidance for a design target.* A code-review-time check must **"produce less than 10% effective false positives"**; an issue is an **"effective false positive" if developers did not take some positive action after seeing the issue** — technical correctness is secondary (a correct-but-ignored report still counts against the budget; an incorrect report the developer fixes anyway does not). Compiler-integrated checks that fail the build are held to the stricter **"no effective false positives."** Grounds: the review-gate precision target — a deterministic review check must clear ≤10% effective false positives or it gets `--no-verify`'d into irrelevance (the benchmark target in [ADR-0086](../adrs/0086-deterministic-review-scanning-decision.md); reinforces the warning-not-hard-error posture for fuzzy checks alongside [[SMELLS]]).

<a id="CODERABBIT-PRVAL"></a>
**[CODERABBIT-PRVAL] CodeRabbit — PR validation using linked issues.** CodeRabbit, 2025–2026. *Verified (June 2026, docs.coderabbit.ai + coderabbit.ai blog).* The reviewer reads a linked Jira / Linear issue, validates whether the PR addresses the issue's **acceptance criteria**, and writes the assessment (validated vs needs-revision) back to the linked ticket. <https://docs.coderabbit.ai/integrations/jira> — *vendor feature doc; a shipped capability, not a measured study.* Grounds (with [QODO]): requirement/acceptance-criteria binding in PR review is shipped by incumbents — so Corpus's differentiation narrows to the deterministic / local-spec-keyed / verdict-free / git-durable *form* ([ADR-0086](../adrs/0086-deterministic-review-scanning-decision.md)), not to "binding evidence to requirements" as such.

<a id="QODO"></a>
**[QODO] Qodo Merge — Ticket Compliance Agent.** Qodo (formerly CodiumAI), 2024–2026. *Verified (June 2026, qodo.ai blog + qodo-merge-docs.qodo.ai/tools/compliance + PR Newswire launch).* The code-review agent fetches a linked Jira / GitHub-Issues ticket, surfaces its **acceptance criteria**, and reports whether the diff is **Fully / Partially / Not compliant** — "identifies missing acceptance criteria, unimplemented steps," and markets **scope-creep prevention** and **audit-ready** evidence. <https://qodo-merge-docs.qodo.ai/tools/compliance/> — *vendor feature doc; a shipped capability, not a measured study.* Grounds (with [CODERABBIT-PRVAL]): requirement/acceptance-criteria binding in PR review is now shipped by incumbents — so Corpus's differentiation narrows to the deterministic, local-spec-keyed, verdict-free, git-durable *form*, not to "binding evidence to requirements" as such ([ADR-0086](../adrs/0086-deterministic-review-scanning-decision.md)).

<a id="SARIF"></a>
**[SARIF] Static Analysis Results Interchange Format (SARIF) v2.1.0.** OASIS, approved as an **OASIS Standard on 27 March 2020** (17 affirmative consents, no objections). *Verified (June 2026, oasis-open.org).* A JSON interchange format whose stated purpose is to make it feasible to **aggregate the results of multiple static-analysis tools**; ingested natively by GitHub code scanning and by reviewdog. <https://www.oasis-open.org/standard/sarifv2-1-os/> — *ratified standard.* Grounds: the deferred "import, don't rebuild" track — if Corpus ever ingests external analyzer findings, SARIF (with JUnit XML for test results) is the de-facto format to route and correlate against scope, never an analyzer to re-implement ([ADR-0086](../adrs/0086-deterministic-review-scanning-decision.md) Decision 4).

<a id="OVERRELIANCE-REVIEW"></a>
**[OVERRELIANCE-REVIEW] Overreliance on AI: Literature Review.** Passi, Vorvoreanu, et al. **Microsoft Research / Aether (AI, Ethics, and Effects in Engineering and Research), June 2022.** *Verified (June 2026, web search — direct fetch of the Aether review PDF).* A Microsoft research **literature review** — a secondary synthesis of empirical studies, not itself a controlled study: the **presence of explanations can increase over-reliance** on AI, and **more detailed explanations can make it worse** — explanations often persuade rather than help a person evaluate, so they do not reliably improve human-AI team performance. <https://www.microsoft.com/en-us/research/publication/overreliance-on-ai-literature-review/> — *authoritative vendor research synthesis; cite as guidance, not a single measured study (it is a review, not primary research).* Grounds: favor short, verification-oriented justification over long persuasive prose; the goal of a recommendation's "why" is to make checking cheap, not to convince.

<a id="GOOGLESMALLCL"></a>
**[GOOGLESMALLCL] Small CLs.** Google Engineering Practices — Code Review Developer Guide (living document, accessed June 2026). The right size for a change is **one self-contained change**; ~100 lines is usually reasonable and ~1000 usually too large (rules of thumb, the reviewer's judgment; a change spread across many files counts as larger). **Separate a refactor from a feature or bug-fix** into its own change (small cleanups like renaming a local variable MAY ride along). <https://google.github.io/eng-practices/review/developer/small-cls.html> — *official guidance, not a measured study.* Grounds: separate-refactor-from-behavior and small/self-contained units (ADR-0094).

<a id="PLAYWRIGHTMCP"></a>
**[PLAYWRIGHTMCP] Playwright MCP.** Microsoft (github.com/microsoft/playwright-mcp), accessed June 2026. Drives a browser via the **accessibility tree, not pixels** — "No vision models needed," deterministic, fast/lightweight. <https://github.com/microsoft/playwright-mcp> — *official project docs, not a measured study.* Grounds: prefer deterministic accessibility-tree tooling over pixel/vision when an agent captures app-run evidence (ADR-0095).

<a id="NARAGRS52"></a>
**[NARAGRS52] General Records Schedule 5.2: Transitory and Intermediary Records.** U.S. National Archives and Records Administration (NARA), Transmittal No. 34, June 2023. The durability test: a record is durable when it is required "to initiate, sustain, evaluate, or provide evidence of decision-making"; **transitory** records are "routine records of short-term value (generally less than 180 days)," disposed of "when no longer needed." <https://www.archives.gov/records-mgmt/grs/faqs-for-grs-5-2> — *primary-official (the issuing authority's schedule); "generally less than 180 days" is a typical bound, not a hard cutoff.* Grounds: the durable-vs-ephemeral split — decisions/specs/findings are durable, review/check/run output is transitory (ADR-0096).

<a id="ISO15489"></a>
**[ISO15489] ISO 15489-1:2016 — Records management — Concepts and principles.** International Organization for Standardization, 2016. The records lifecycle: (recurrent) **appraisal → disposition authorities**, each setting a **retention period** and a disposition action — destruction, transfer, or archive for permanent retention. <https://www.iso.org/standard/62542.html> — *primary-official (paywalled; cite the catalog page for identity, the substance is the clause text).* Grounds: artifacts carry a retention schedule and an explicit disposition, not indefinite accumulation (ADR-0096).

<a id="NYGARDADR"></a>
**[NYGARDADR] Documenting Architecture Decisions.** Nygard, 2011. ADRs "are numbered sequentially and monotonically; numbers will not be reused"; each carries a **status** (proposed | accepted | deprecated | superseded); a reversed decision is **kept and marked superseded** "with a reference to its replacement" — not altered or deleted. <https://cognitect.com/blog/2011/11/15/documenting-architecture-decisions> — *primary-official (the post that originated the ADR pattern); "immutable" is later secondary framing, not Nygard's own word.* Grounds: supersede-not-delete + sequential numbering + a status field for durable decision records (ADR-0096).

<a id="MADR"></a>
**[MADR] Markdown Architectural Decision Records (MADR).** The `adr` GitHub organization, MADR 4.0.0, 2024. ADRs live in a `docs/decisions/` folder named `NNNN-title-with-dashes.md` (a consecutive number; "we assume that there won't be more than 9,999 ADRs in one repository"); the template carries a **status** field with example values (`proposed | rejected | accepted | deprecated | … | superseded by ADR-NNNN`). <https://adr.github.io/madr/> — *primary-official (the project's own docs); the status values are illustrative, not a closed set.* Grounds: the NNNN scheme + a status field scale to thousands of records (ADR-0096).

<a id="GHRETENTION"></a>
**[GHRETENTION] GitHub Actions artifact & log retention.** GitHub Docs, accessed June 2026. Workflow artifacts and logs are **retained 90 days by default** — configurable 1–90 days for public repos, up to 400 for private. <https://docs.github.com/en/organizations/managing-organization-settings/configuring-the-retention-period-for-github-actions-artifacts-and-logs-in-your-organization> — *primary-official.* Grounds: CI/run artifacts are ephemeral by industry default — the anchor for the review/run retention window (ADR-0096).

<a id="GLRETENTION"></a>
**[GLRETENTION] GitLab CI/CD job artifacts — default expiry.** GitLab Docs, accessed June 2026. Job artifacts **expire 30 days** after creation by default (overridable per job via `expire_in`, or kept indefinitely with `expire_in: never`). <https://docs.gitlab.com/ci/jobs/job_artifacts/> — *primary-official.* Grounds: with GitHub's 90-day default ([[GHRETENTION]]), brackets the 30–90-day transitory-retention band (ADR-0096).

<a id="SWEGBOOKDOCS"></a>
**[SWEGBOOKDOCS] Software Engineering at Google, ch. 10 "Documentation".** Manshreck (eds. Winters, Manshreck, Wright), O'Reilly, 2020. "Documents without owners become stale"; freshness metadata can "send email reminders when the document hasn't been touched in, for example, three months"; at scale a **dominant failure mode is duplication, not just absence** (the GooWiki / Borg case — 7–10 overlapping Borg-setup docs, no owner). <https://abseil.io/resources/swe-book/html/ch10.html> — *practitioner-credible (industry book, not peer-reviewed); the 3-month figure is an example, not a rule.* Grounds: named ownership + freshness review + consolidate-to-canonical for durable specs (ADR-0096).

## Verified — peer-reviewed, no measured outcomes (vision/position; design rationale only)

<a id="REDEFO"></a>
**[REDEFO] Requirements Development and Formalization for Reliable Code Generation: A Multi-Agent Vision.** Sun et al. (Weisong Sun, corresponding). **ASE 2025 (NIER track)**, arXiv:2508.18675. *Verified (June 2026, conf.researchr.org + arXiv).* A **vision** paper (New Ideas & Emerging Results — peer-reviewed venue, **no measured outcomes**): proposes Analyst + Formalizer agents that turn ambiguous NL requirements into **formal specifications** to bridge NL→code, with human-in-the-loop review at critical points. Cite as **design rationale / corroboration only** (never a measured `MUST`) — it corroborates the spec-as-contract + clarify-before-build direction; the *measured* grounding for that spine remains [PLANCODER]/[SEMAP]/[MAST]/[SMELLS].

<a id="EVALAI"></a>
**[EVALAI] Explainable AI is Dead, Long Live Explainable AI! Hypothesis-driven Decision Support using Evaluative AI.** Miller. **ACM FAccT 2023** (DOI 10.1145/3593013.3594001), arXiv:2302.12389. *Verified (June 2026, web search — ACM DL + arXiv).* A **position paper** (peer-reviewed venue, **no measured outcomes**): argues that giving a recommendation-plus-explanation takes agency from the decision-maker and misfits how people actually decide; proposes **evaluative AI** — a machine-in-the-loop that surfaces **evidence for and against** the options rather than pushing a single accept/reject recommendation. Cite as **design rationale only** (never a measured `MUST`) — and note it is **contested** (a position paper; later work found no automatic decision-quality gain from options-over-recommendations). Grounds: the decision handoff presents *comparable options with the case for and against*, not a lone recommendation — but as a reasoned design stance, not a proven result.

## Caveated — non-peer-reviewed (cite ONLY as preliminary; never load-bearing)

Treated as the kernel treats its own non-peer-reviewed sources: usable to *illustrate* a direction, never to ground a `MUST`. Their headline statistics are single-author/blog measurements, not controlled peer-reviewed studies.

<a id="WIEGERS95"></a>
**[WIEGERS95] Improving Quality Through Software Inspections.** Wiegers. **Software Development magazine, April 1995** (author reprint, processimpact.com). *Verified (June 2026, web — author PDF).* The desk-checking principle: the author is a poor sole reviewer of their own work — "if the author was aware of defects, he probably would have corrected them already"; flags "a sense of unease when the author is the only person who has viewed a completed product." <https://www.processimpact.com/articles/inspects.pdf> — *practitioner / trade article, not peer-reviewed; cite as **design rationale only**, never as measured evidence.* Grounds: the cognitive rationale for reviewer ≠ author (reinforces ADR-0056), at design-rationale level (ADR-0095).

<a id="ACTIVATION-BLOG"></a>
**[ACTIVATION-BLOG] Why Claude Code Skills Don't Activate — And How to Fix It.** Seleznov, Medium, 2026. A self-published 650-trial measurement reporting directive descriptions activating far more reliably than passive ones (the "OR ≈ 20.6 / 100% activation" figures). **Non-peer-reviewed; the specific numbers are NOT load-bearing.** The *direction* (directive, exclusion-bearing descriptions help) is used only as illustration; the kernel's primary mechanism is "load what the task names" (§26.4), with description-match as the fallback.

<a id="DORA2025"></a>
**[DORA2025] DORA 2025 — State of AI-assisted Software Development.** Google Cloud / DevOps Research and Assessment, 2025. *Venue + framing web-verified (June 2026, dora.dev/research/2025); the percentages are the report's own self-reported figures (the public landing pages don't expose them for re-fetch — figures corroborated via the report body in earlier multi-source verification).* **~90%** of technology professionals use AI at work and **>80%** report it improved their productivity (self-reported, not measured); the report's thesis is that **AI is an "amplifier"** of an organization's existing strengths and weaknesses — higher adoption is associated with **both increased delivery throughput and increased instability** absent strong control / internal-platform systems. **Tier: vendor/industry report, correlational, self-reported — never a `MUST`.** Grounds (illustrative): agent adoption raises instability *unless* a verification/control layer exists — the gap Corpus's merge gate fills; pairs with [METR]'s perception-vs-reality gap.

### Preprints — web-verified arXiv (finding confirmed; cite as preliminary, never a `MUST`)

A web-verified arXiv preprint is stronger than a blog post but is **not peer-reviewed**: it may *corroborate* or *illustrate* a direction, never carry a `MUST`. Each finding below was confirmed against the source (June 2026).

<a id="PERSUASIONPARADOX"></a>
**[PERSUASIONPARADOX] The Persuasion Paradox: When LLM Explanations Fail to Improve Human-AI Team Performance.** Cohen, Feng, Bloch, Kraus. **arXiv:2604.03237** (preprint, 2026). *Verified (June 2026, id + abstract).* Three controlled studies; the result is explicitly **task-dependent / mediated by cognitive modality** — on **visual** reasoning (RAVEN matrices) explanations inflate confidence without accuracy and suppress error recovery, but on **language-based logical** reasoning (LSAT) "LLM explanations yield the highest accuracy and recovery rates, outperforming both expert-written explanations and probability-based support." The paper rejects treating explanations as a universal solution. Grounds (preliminary, **mixed**): on the visual task it corroborates the over-reliance/"calibration cues over persuasion" direction; on the language task — the class **closer to a developer's decision** — explanations *helped*, which cuts the other way. Cite only as preliminary, never a `MUST`; do not read it as a one-directional "replicate and intensify."

<a id="IFSCALE"></a>
**[IFSCALE] How Many Instructions Can LLMs Follow at Once?** Jaroslawicz et al. **arXiv:2507.11538** (preprint). *Verified (June 2026, id + abstract).* A 500-instruction density benchmark across 20 frontier models: best models ~68% accuracy at 500 simultaneous instructions; top reasoning models hold near-perfect adherence through ~100–150 before degrading; failures shift to **silent omission** with a **primacy bias** toward earlier instructions. Grounds (preliminary): order requirements by importance; keep specs short — a 1–2-page spec sits inside the measured near-ceiling regime.

<a id="SWEMUT"></a>
**[SWEMUT] Saving SWE-Bench: A Benchmark Mutation Approach for Realistic Agent Evaluation.** **arXiv:2510.08996** (preprint). *Verified (June 2026, id + abstract).* Mutating formal GitHub-issue task descriptions into realistic short chat queries (telemetry-derived) drops agent resolution so far that public benchmarks **overestimate capability by >50%** for some models (~10–16% on an internal benchmark). Grounds: specification richness in the task input is load-bearing for agent success; terse prompting measurably underperforms.

<a id="ASKORASSUME"></a>
**[ASKORASSUME] Ask or Assume? Uncertainty-Aware Clarification-Seeking in Coding Agents.** **arXiv:2603.26233** (2026 preprint; id + abstract verified June 2026 — 69.40% confirmed in the abstract; the 70.80/54.80/47.20 results-section figures are entry-recorded but unverified beyond it; cite as preliminary only). On an underspecified SWE-bench Verified variant: full issue **70.80%** vs underspecified **54.80%** resolve rate (specification completeness alone ≈16 pts); calibrated clarification recovers to **69.40%**; an always-clarify baseline was WORST (47.20%). Grounds (preliminary): spec completeness and clarification are substitutable; indiscriminate clarification hurts.

<a id="REACODER"></a>
**[REACODER] Bridging the Gap between User Intent and LLM: A Requirement Alignment Approach for Code Generation.** **arXiv:2604.16198** (2026 preprint). *Verified (June 2026, id + abstract; the ablation figures below are from the body and unverified beyond this entry).* Requirement alignment before generation improves pass rates over all baselines across 4 models / 5 benchmarks (avg +7.9% to +30.3%); ablations attribute gains to both upfront QA-alignment (+5.82%) and checking generated code back against the requirement (+9.99%); costs more tokens than zero-shot. Preliminary; never a MUST-level ground.


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
**[MAST] Multi-Agent System failure Taxonomy (MAST).** Cemri et al. **arXiv:2503.13657** (preprint; venue unconfirmed). *Verified (June 2026; finding confirmed, venue not).* 14 failure modes across three categories — **system-design & specification ≈41.8%, inter-agent misalignment ≈36.9%, verification ≈21.3%** (so specification + verification ≈ 63%). *Note (audit O-0):* the first category is "System Design / poor specification," not "Specification" alone. Grounds: why Corpus hardens the specification and verification layers; the inter-agent contract gap.

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

### Industry reports and vendor analyses — web-verified (June 2026)

These sources are **not peer-reviewed**; they ground market-gap observations and should be cited only as preliminary/contextual evidence, never as a `MUST`.

<a id="ANTHROPIC-MULTIAGENT"></a>
**[ANTHROPIC-MULTIAGENT] How we built our multi-agent research system.** Anthropic Engineering, 2025. *Verified (June 2026, direct fetch).* First-party orchestrator-worker account: states verbatim that "each subagent needs an objective, an output format, guidance on the tools and sources to use, and clear task boundaries," and that "without detailed task descriptions, agents duplicate work, leave gaps, or fail to find necessary information." Does **not** claim subagents are unaware of their orchestrated role (that observation is from other vendors' subagent guidance and is design rationale here). **Tier: first-party engineering analysis, not peer-reviewed — never a `MUST`.** Grounds (illustrative): delegated workers need an explicit brief and a return contract — the worker-provenance surface (ADR-0076).

<a id="PRACTICALLOGIX-PARADOX"></a>
**[PRACTICALLOGIX-PARADOX] The AI Code Quality Paradox.** Practical Logix, 3 May 2026. *Verified (June 2026, direct fetch).* Synthesizes Stack Overflow 2025 (n=49,000+), DORA 2025 (n≈5,000), CodeRabbit Feb 2026 (470 PRs), and Cortex 2026: **84%** daily AI-tool adoption, **29%** trust in AI-generated code accuracy, AI-generated PRs averaged **1.7×** as many issues as human PRs. Grounds: trust gap and quality-tax are observable market conditions.

<a id="VIBECODER-AUDIT"></a>
**[VIBECODER-AUDIT] Audit Trails for AI Generated Code Compliance Guide.** Vibecoder blog, 29 Apr 2026. *Verified (June 2026, direct fetch).* A 2025 compliance survey of 400 regulated-industry organizations found **73% require AI-generation audit trails for production code**, up from 18% in 2024. Identifies four components: prompt history, generation provenance, review documentation, version-control linkage. Grounds: audit-ready provenance is becoming a market-access requirement.

<a id="AUGMENT-SDD-BROWNFIELD"></a>
**[AUGMENT-SDD-BROWNFIELD] Spec-Driven Development for Brownfield Enterprise Codebases.** Augment Code, 19 Mar 2026. *Verified (June 2026, direct fetch).* Recommends **change-level specs** scoped to a single modification as the practical answer to comprehensive specs being impossible at enterprise scale; defines four elements: current behavior, target behavior, invariants, scope boundary. Grounds: brownfield SDD needs narrow, incremental specs.

<a id="QIAO-BROWNFIELD"></a>
**[QIAO-BROWNFIELD] Comprehension–Performance Gap in GenAI-Assisted Brownfield Programming: A Replication and Extension.** Qiao et al. **arXiv:2511.02922** (preprint), 4 Nov 2025. *Verified (June 2026, direct fetch).* Students showed no significant comprehension improvement with Copilot in brownfield tasks (mean 55% vs 61% without, p=0.42); qualitative responses indicated Copilot was treated as a code generator and its explanations too localized to build system-level understanding. Grounds: AI tools accelerate brownfield output without improving understanding → governance layer must enforce comprehension artifacts.

<a id="INNOBU-LOCKIN"></a>
**[INNOBU-LOCKIN] AI Agent Platforms 2026: Vendor Lock-in and the Right Enterprise Strategy.** Innobu, 9 Apr 2026. *Verified (June 2026, direct fetch).* Cites **57%** of IT leaders spent >$1M on platform migrations, typical migration cost **2×** initial investment, **78%** use two or more LLM families, **46%** struggle with integration into existing systems. Grounds: enterprises need portable, multi-model governance.

<a id="SOLOBUSINESSHUB-SKILLS"></a>
**[SOLOBUSINESSHUB-SKILLS] The AI Agent Skills Boom – Reshaping Development in 2026.** Solo Business Hub, 22 Jan 2026. *Verified (June 2026, direct fetch).* Reports 100,000+ skill installs and 70–90% time savings claims; frames Agent Skills as modular SKILL.md folders. Grounds: skill ecosystem is growing rapidly and needs governance conventions.

<a id="SERENITIESAI-SKILLS"></a>
**[SERENITIESAI-SKILLS] AI Agent Skills Guide 2026: Build Skills for 16+ AI Tools.** Serenities AI, 5 Mar 2026. *Verified (June 2026, direct fetch).* Reports security researchers identified **341 malicious skills** by Feb 2026 with risks including data exfiltration, credential theft, and prompt injection; recommends auditing skills like npm packages. Grounds: skill supply-chain governance is an emerging requirement.

<a id="AGENTMELT-LOCKIN"></a>
**[AGENTMELT-LOCKIN] AI Agent Vendor Lock-In: 7 Ways to Avoid It.** AgentMelt, 10 Apr 2026. *Verified (June 2026, direct fetch).* Lists lock-in vectors: model dependency, proprietary orchestration, data/conversation history, integration layer, pricing structure; recommends open standards (MCP, OpenAPI), own eval sets, and exportable workflows. Grounds: portability is a design requirement, not an afterthought.

<a id="AQUILAX-VIBE"></a>
**[AQUILAX-VIBE] Why People Are Not Using Vibe Coding for Everything.** Aquilax AI, 13 Mar 2026. *Verified (June 2026, direct fetch).* Argues regulated industries cannot adopt "vibe coding" because AI-generated code lacks provenance, design rationale, and review trail; notes SOC 2 Type II, ISO 27001, and FedRAMP auditors are increasingly asking about AI tooling controls. Grounds: regulated adoption requires documented human oversight.

<a id="FORGEPROOF-2026"></a>
**[FORGEPROOF-2026] ForgeProof — Code Provenance for the AI Era.** Flying Cloud Technology, 2026. *Verified (June 2026, direct fetch).* Vendor framing for CMMC, EU AI Act Article 12, EU Cyber Resilience Act, NIST AI 100-4; positions code provenance as mandatory for defense contractors, government procurement, regulated industries, and open-source maintainers. Grounds: regulatory pressure for AI code traceability is increasing.

<a id="ONA-MIGRATIONS"></a>
**[ONA-MIGRATIONS] The evolution of code migrations from rules-based tools to agents.** Ona, 20 Oct 2025. *Verified (June 2026, direct fetch).* Enterprise migrations were historically rule-based (OpenRewrite) and confined to large tech companies with Java codebases; agents present an opportunity to democratize migration but brownfield orchestration remains hard. Grounds: brownfield transformation is an underserved, high-value niche.

<a id="NASHTECH-LEGACY"></a>
**[NASHTECH-LEGACY] Modernising legacy systems without breaking the business.** NashTech, 19 Jun 2025. *Verified (June 2026, direct fetch).* Reports GenAI productivity gains for greenfield development but "less benefits in brownfield or legacy modernisation projects." Grounds: brownfield is the harder problem and current tools under-serve it.

<a id="EMERGENTMIND-BROWNFIELD"></a>
**[EMERGENTMIND-BROWNFIELD] Brownfield Programming Tasks: Legacy & AI.** Emergent Mind topic summary, 9 Nov 2025. *Verified (June 2026, direct fetch).* Synthesizes Qiao et al. and Shihab et al.: GenAI enables rapid progress but developers do not exhibit improved legacy-system understanding; workflows shift to "prompt–response–implement" with acceptance often occurring without critical evaluation. Grounds: process discipline must compensate for comprehension gaps introduced by AI assistance.

<a id="RJNTI-AI-QUALITY"></a>
**[RJNTI-AI-QUALITY] Evaluating the Reliability, Security, and Quality of AI-Generated Code.** RJPN / IJNTI, 5 May 2026. *Verified (June 2026, direct fetch of PDF).* Synthesis of 20+ empirical studies; reports Stack Overflow 2025 found **33%** fully trust AI outputs yet **60%** accept suggestions without thorough validation, and documents "false sense of security" and junior-developer over-reliance effects. Grounds: trust behavior and stated trust diverge; governance must enforce verification.

<a id="YAITEC-NOCODE"></a>
**[YAITEC-NOCODE] No-code tools for building AI agents: best platforms compared.** YAITEC, 31 May 2026. *Verified (June 2026, direct fetch).* Reports the no-code AI workflow market expanding at 31–38% CAGR and projected to reach **$25 billion by 2030**, with 84% of organizations using low-code/no-code tools. Grounds: low-code/no-code AI platforms are proliferating, increasing demand for lightweight governance that does not add platform lock-in.

<a id="CODERABBIT"></a>
**[CODERABBIT] CodeRabbit State of AI vs Human Code Generation.** CodeRabbit, Feb 2026. *Verified (June 2026, via Practical Logix synthesis).* Analysis of 470 open-source GitHub pull requests (320 AI-co-authored, 150 human-only); AI-generated PRs averaged **10.83 issues** vs **6.45** for human-written PRs, a **1.7×** multiplier. Grounds: AI-generated code carries a measurable quality tax. (CodeRabbit's *shipped* PR-validation-against-acceptance-criteria feature — the load-bearing competitive fact — is recorded separately as official guidance at [[CODERABBIT-PRVAL]](#CODERABBIT-PRVAL); this entry is the non-peer-reviewed measurement only.)

> *The six entries below were sourced from an LLM-generated brief whose footnote **numbering** was scrambled (the wrong footnote pointed at each id). Each id was re-fetched and resolves to the **named** paper with a matching venue + finding — so the ids below are the corrected mapping, not the brief's.*

<a id="TERMBENCH"></a>
**[TERMBENCH] Terminal-Bench: Benchmarking Agents on Hard, Realistic Tasks in Command Line Interfaces.** Merrill et al. **arXiv:2601.11868** (preprint). *Verified (June 2026, direct fetch).* 89 curated hard terminal tasks with human solutions + verification tests; **frontier models/agents score < 65%**. Grounds: agent performance is a *systems* problem, not model-only — the harness/verification layer is where reliability is won (the `verify`/`review` rationale).

<a id="HAL"></a>
**[HAL] Holistic Agent Leaderboard: The Missing Infrastructure for AI Agent Evaluation.** Kapoor, Stroebl, … Narayanan (Princeton et al.). **arXiv:2510.11977** (preprint). *Verified (June 2026, direct fetch).* A standardized evaluation harness cut evaluation time weeks→hours; **21,730 agent rollouts** analyzed; LLM-aided inspection surfaced previously-unreported failure behaviours. Grounds: a standardized harness + trace inspection (the trace / review / ledger discipline) materially improves agent evaluation.

<a id="HARNESSBENCH"></a>
**[HARNESSBENCH] Harness-Bench: Measuring Harness Effects across Models in Realistic Agent Workflows.** Yao et al. **arXiv:2605.27922** (preprint). *Verified (June 2026, direct fetch + search).* 106 sandboxed tasks, 5,194 trajectories; configuration-level harness choice produced a **23.8-point** aggregate gap (best configurable harness 76.2 vs worst 52.4) on the same task set + model-backend pool. Grounds: the *harness/system* matters as much as the model — Corpus's leverage is the system layer (specs, verification, trace), not the model.

<a id="AHE"></a>
**[AHE] Agentic Harness Engineering: Observability-Driven Automatic Evolution of Coding-Agent Harnesses.** Lin et al. **arXiv:2604.25850** (preprint). *Verified (June 2026, direct fetch).* Lifted Terminal-Bench 2 pass@1 **69.7% → 77.0%** over ten iterations; the gains came from **tools, middleware, and long-term memory — not the system prompt**. Grounds: invest in structured persistence (memory, traces, adapters) over prompt cleverness.

<a id="ORCHID"></a>
**[ORCHID] Assessing the Impact of Requirement Ambiguity on LLM-based Function-Level Code Generation (Orchid).** Yang et al. **arXiv:2604.21505** (preprint). *Verified (June 2026, direct fetch).* 1,304 function-level tasks across four ambiguity types: ambiguity **consistently degrades** generation (worst on the most advanced models); LLMs produce **functionally divergent** implementations from the same ambiguous requirement; and **models cannot reliably identify or resolve ambiguity on their own**. Grounds: SOL/EARS structured obligations + the prose-smell lint (vague terms, missing verification, ambiguous refs) reduce exactly the ambiguity models can't self-fix. Reinforces [SMELLS].

<a id="METR"></a>
**[METR] Measuring the Impact of Early-2025 AI on Experienced Open-Source Developer Productivity.** Becker, Rush, Barnes, Rein (METR). **arXiv:2507.09089** (preprint). *Verified (June 2026, direct fetch).* RCT, 16 experienced OSS devs, 246 tasks: allowing early-2025 AI **increased completion time ~19%**, even though devs expected a 24% speedup and *believed afterward* they were 20% faster (experts predicted 38–39% faster). Grounds: **perceived ≠ measured** — a self-reported "done"/"faster" is not evidence; a machine-checkable verdict is. (Scope: experienced devs on mature repos, n=16. A 2026 follow-up reportedly did not replicate the slowdown — claim surfaced in the external validation survey, **unverified here**; do not cite the 19% figure as settled.)

<a id="SMARTBEAR"></a>
**[SMARTBEAR] Code Review at Cisco Systems** (in *Best Kept Secrets of Peer Code Review*). Cohen, Smart Bear Software, 2006. *Verified (June 2026, web — the canonical case-study PDF).* The largest lightweight-review case study of its time (2,500 reviews, 3.2M LOC, 50 developers, 10 months): defect-detection effectiveness is best on **small changes — LOC under review under 200, not to exceed ~400** — and falls past **~60–90 minutes** of review or at inspection **rates above ~400–500 LOC/hour** (the rate metric is distinct from the absolute size ceiling). <https://static0.smartbear.co/support/media/resources/cc/book/code-review-cisco-case-study.pdf> — **industry-dataset, not peer-reviewed; a single vendor-derived 2006 in-situ dataset — cite the 200–400 LOC band as a heuristic, never as law.** Grounds: the size anchor for the oversized-packet heuristic (ADR-0094).

## Rejected — DO NOT CITE (fabricated / misattributed / unconfirmed)

The skill-authoring literature attributes load-bearing figures to these arXiv ids. **Direct fetch (June 2026) found each id resolves to an unrelated paper.** They are recorded here so the fabrication is never re-introduced (per the kernel's reject discipline).

> **Invariant (ADR-0090):** a Rejected entry MUST NOT carry an `<a id="…">` anchor. Because rejected entries are anchor-less by construction, any spec `[[KEY]]` citing one **dangles** and the C015 `citation-resolves` check ([ADR-0087](../adrs/0087-citation-anchor-check.md)) surfaces it — the high-precision safeguard that makes a separate "cited a Rejected source" tier check unnecessary (ADR-0090). Do not add an anchor to a rejected entry; doing so would silently make a forbidden citation resolve clean.

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
