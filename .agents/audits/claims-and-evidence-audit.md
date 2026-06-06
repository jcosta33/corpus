---
type: audit
id: claims-and-evidence-audit
status: open-backlog
created: 2026-06-04
updated: 2026-06-06
scope: docs/ + kernel/ (the shipped framework); the claims, approaches, and sources behind them
method: 6-cluster adversarial audit with live web verification of every cited source + prior-art analogy
---

# Audit — claims, approaches, and evidence

> **Update (2026-06-06):** O-1 actioned — `[SCRATCHPAD]` relabeled "ICLR 2022 Workshop (DL4C)" in
> `sources.md` + `task-files.md`. The remaining O-2..O-15 (attribution-hygiene) stay an open backlog.

> **Observation-only.** This audit records what *is* — which claims the framework makes, what
> grounds each, and whether the source verifies — and recommends where to reinforce, alter, or
> improve. It prescribes no inline edits; the `## Recommended obligations` section names candidate
> changes for a future `author`/`implement` pass to act on. It asserts no new intended behaviour.
> Held to the framework's own §0.7 discipline (`docs/PRINCIPLES.md:105-110`, "real science, not
> astrology"): a load-bearing empirical claim must cite a **verified** source that says what is
> claimed; non-peer-reviewed sources may only illustrate, never carry a `MUST`; a fact-shaped
> statement that is uncited and unlabelled is a defect.

## Scope

**In scope.** The shipped framework — `docs/` (incl. `research/sources.md`, `passes/`, `model/`,
`language/`, `reference/`, `adrs/`, `PRINCIPLES.md`, `NON-GOALS.md`, `positioning.md`) and the
`kernel/` payload. Three layers were examined: (1) **cited empirical claims** — every entry in
`docs/research/sources.md` and the `[[KEY]]` citations grounded on it; (2) **prior-art analogies**
invoked to justify design; (3) **major design approaches** and **uncited empirical-flavored
self-claims**. Every reachable source was web-fetched/searched (June 2026) to confirm its venue and
that it states the claimed finding, and to look for stronger or contradicting evidence.

**Out of scope.** `docs/_legacy/` (archived pre-pivot tree — examined only to flag contamination,
see O-12) and `.agents/specs/swarm/` (the frozen build source). No code behaviour (the repo is
markdown-only, no runtime).

## Observations

### The headline: the evidence base is sound; the defects are attribution hygiene

- **O-0 (positive, load-bearing).** Every **headline number** in the corpus was web-verified and
  matches its source: Tree-of-Thoughts 4%→74% (`sources.md:12`), Reflexion 91% vs 80% pass@1
  (`:15`), Plan-and-Solve "outperforms zero-shot CoT by a large margin" (`:21`), Lost-in-the-Middle
  U-curve (`:28`), the AGENTS.md study's 1.6×/0.01 and 2.5×/0.05 command-use figures, MAST's
  41.8/36.9/21.3 failure split, SWE-bench 7.8%/6.2pp, Lean ~4.9%, Dafny 82%/68→96%. **No fabricated
  or `Rejected` arXiv id (2511.10954 / 2510.27502 / 2511.21345) resurfaces as fact** anywhere in
  `docs/` or `kernel/`; the three appear only inside the `Rejected` table and explicit "do-not-cite"
  prose. The `§0.7` reject-discipline is holding. Several source *corrections* are §0.7 working
  exactly right: MAST's FC1 is named "System Design" not "Specification"; the two-tier memory model
  is grounded on MemGPT, not the non-existent "TierMem"; LOSTMID is TACL 2024 and is **explicitly
  guarded** ("'context rot' is a later popular term, not coined here", `sources.md:28`; the cap is
  "not a capability ceiling", repeated ~6×). This is the best-disciplined citation in the corpus.
- **The defects below are, with no exception, labeling / tier / attribution / citation-placement
  problems — not number defects and not fabrication.** Every load-bearing *finding* is real. What
  is at risk is the *credibility of the "peer-reviewed / verified / web-verified" labels* — which is
  precisely what §0.7 polices.

### Source-attribution defects (MAJOR)

- **O-1 — `[SCRATCHPAD]` venue misattributed (MAJOR).** `docs/research/sources.md:18` lists Nye et
  al. *Show Your Work* (arXiv:2112.00114) under **"Verified — primary research (peer-reviewed)"** and
  as **"ICLR 2022"**, repeated verbatim at `docs/research/task-files.md:15` and grounded across ~9
  sites (`body-anatomy.md:56`, `self-containment.md:65`, `scope.md:100`, `workspace.md:74`,
  `implement.md:92`, `artifacts/task.md:3`, `positioning.md:39`). **Web-verified:** the paper was an
  **ICLR 2022 *Workshop* (Deep Learning for Code / DL4C) poster**, not a main-conference acceptance
  (iclr.cc/virtual/2022/7445 → "Poster in Workshop"; OpenReview venue field `ICLR.cc/2022/Workshop/DL4C`).
  The *finding* ("scratchpads dramatically improve multi-step computation") is verified verbatim from
  the abstract; only the peer-review **status** is inflated — and it is inflated in the very section
  that promises peer review. Blast radius: the externalised-state thesis leans on it, though always
  as "grounds/rationale", never a hard `MUST`.
  *(Resolved: `sources.md:18` was corrected to "ICLR 2022 Workshop (DL4C)"; the `docs/research/` topical
  dump files cited above as sites — `task-files.md`, `body-anatomy.md`, `self-containment.md`, `scope.md` —
  have since been removed, their evidence folded contextually into the framework docs via inline `[[KEY]]`
  citations.)*
- **O-2 — `[AGENTSMD-HARM]` companion mis-paired + affiliation imprecise + missing id (MAJOR).**
  `docs/research/sources.md:30-31` attributes "LLM-generated narrative context can cost more than it
  returns" jointly to the ETH study **and** "its efficiency companion (Lulla et al.)." **Web-verified:**
  the cost claim is from the *primary* paper (Gloaguen et al., **arXiv:2602.11988**; "increase
  inference cost by over 20%"); the **Lulla companion (arXiv:2601.20404) found the *opposite* on cost**
  — developer-written AGENTS.md *reduces* runtime (~28.6%) and tokens (~16–20%). Citing the two as
  jointly establishing "narrative is costly" is muddled. Also: affiliation is given as "ETH Zürich
  SRI" (verified: **ETH Zürich + LogicStar.ai**), and the entry carries **no arXiv id** — the only
  primary entry that doesn't. The grounded sub-claim ("repository commands are used far more when
  named") is real and verified (1.6/0.01, 2.5/0.05). Load-bearing at `ADR-0018:18`, `ADR-0038:22`
  (the Commands contract), `scope.md:34`, `self-containment.md:41`, `task-files.md:69`.
- **O-3 — `[CTXENG]` "three-file note-taking pattern" not in the source (MAJOR).**
  `docs/research/sources.md:38-39` attributes a specific "**three-file note-taking pattern
  (`task_plan` / `progress_log` / `decisions`)**" to Anthropic's "Effective context engineering"
  article. **Web-verified (two fetches + search):** the article describes only generic "**structured
  note-taking / agentic memory**", and its only concrete examples are "`NOTES.md`" and "a to-do
  list" — it never names three files, those field names, or a "three-file" pattern. The triad is
  Swarm's own decomposition presented as Anthropic's prescription. Propagates to a whole table at
  `task-files.md:28-36` (headed "[CTXENG] file") and `self-containment.md:66`. The "context as a
  finite resource" half *is* verified verbatim. Most-cited source in its cluster; concrete and
  falsifiable — a §0.7 reviewer fetching the URL would not find the named pattern.
- **O-4 — `[CCTASKS]` cited URL does not state the claim (MAJOR/MINOR).** `docs/research/sources.md:48`
  grounds "disk-persistent, dependency-aware task tracking" on
  `docs.anthropic.com/en/docs/claude-code/changelog`. **Web-verified:** that page (now
  `code.claude.com/docs/en/changelog`) carries **no** Tasks entry describing disk-persistence or a
  dependency DAG. The underlying fact is true and well-attested elsewhere (Claude Code "Tasks",
  Jan 2026: disk-persistent under `~/.claude/tasks`, `addBlockedBy`/`addBlocks` DAG — a strong
  `blocked_by` correspondence), but the dereferenced citation does not confirm it — the same
  defect-shape as a misattribution.

### At-point-of-use citation gaps (MAJOR — by the framework's own §0.7 bar)

- **O-5 — the pass docs assert verified figures as fact-shaped prose with no citation (MAJOR).**
  `docs/passes/lint.md` and `improve.md` carry **zero** `[[KEY]]` citations; `lower.md`/`verify.md`
  cite only internal artifacts. Yet they state quantitative claims: the planner→coder gap is "the
  **majority** of end-to-end failures" (`lint.md:179`, `lower.md:78` — `[PLANCODER]`, 75.3% verified);
  "Lean proof success on the order of 5%" (`verify.md:208` — `[VERINA]` 4.9% verified); "Dafny roughly
  82%, climbing 68→96%" (`[VERICODING]` verified); "7.8% of patches… ~6 absolute points… ~41%/24% of
  SWE-bench" (`verify.md:282` — `[SWEBENCH-ADQ]` 7.8%/6.2pp + `[UTBOOST]` 40.9%/24.4%, verified).
  Every figure is accurate and appropriately hedged — but `PRINCIPLES.md:110` says a fact-shaped,
  uncited, unlabelled statement is a defect, and these docs hold themselves to a lower bar than
  SOL.md / positioning.md / the ADRs (which cite at point-of-use). Pure attribution hygiene; no
  number changes. **The single most actionable fortification in the audit.**
- **O-6 — `NON-GOALS.md` N4 batch-invariance claim is uncited in `docs/` (MAJOR).** N4
  (`docs/NON-GOALS.md:25`) states batch-invariant kernels "have been shown to make repeated
  completions on identical inputs converge to a single output" — a "have been shown" empirical claim
  with **no citation at the point of assertion**. The groundable source (`[DETERMINISM]`, Thinking
  Machines Lab, "Defeating Nondeterminism in LLM Inference", Sep 2025, non-peer-reviewed lab blog)
  and its caveat exist only in the **frozen** `.agents/specs/swarm/sources.md:257` — not in `docs/`.
  (This claim was softened earlier by dropping its specific numbers, but "have been shown" remains an
  uncited empirical assertion resting on a non-peer-reviewed blog.)
- **O-7 — split bibliographies / dangling keys (MAJOR, traceability).** `docs/research/sources.md:52`
  refers to keys `[ARIZE26]` / `[DETERMINISM]` as "the kernel's" bibliography, but **neither is
  defined in `docs/` or the shipped `kernel/`** — they live only in the frozen
  `.agents/specs/swarm/sources.md`. A reader in `docs/` cannot resolve them, breaking the §0.7
  promise that a cited key resolves to a verified entry *in scope*. Two diverging bibliographies will
  drift.

### Tier / labeling defects (MAJOR–MINOR)

- **O-8 — `[AGENTSMD-HARM]` is an arXiv preprint sitting in the "Verified" tier and grounding a
  `MUST` (MAJOR, overlaps O-2).** §0.7 says non-peer-reviewed sources "may only illustrate, never
  carry a `MUST`"; this preprint grounds the normative Commands contract (`ADR-0018`/`ADR-0038`).
  Mitigated (the contract is primarily a design choice and the direction is genuinely supported), but
  the tier label over-promises.
- **O-9 — `[SKILLBP]` mis-grounds "explain-the-why" + the ALL-CAPS yellow-signal (MINOR).**
  `sources.md:36` and `body-anatomy.md:32` attribute the "explain-the-why" pattern and "flags bare
  ALL-CAPS MUST/NEVER as a yellow signal" to Anthropic best-practices. **Web-verified:** the page
  contains neither; it suggests the opposite on emphasis ("use stronger language like 'MUST'").
  "Explain-the-why" is correctly grounded on `[PRACTITIONER]` elsewhere — so this is a
  wrong-source attribution, not a fabrication. The verified `[SKILLBP]` sub-claims (≤500-line body,
  third-person descriptions, one-hop references) are textbook-accurate.
- **O-10 — Diátaxis over-stated in `ADR-0001:11` (MINOR).** ADR-0001 invokes "Diátaxis, GitHub Spec
  Kit separation" as "converging on multiple kinds of upstream truth" to justify the four doc types
  (research/spec/audit/bug-report). **Web-verified:** Diátaxis's four are *documentation genres*
  (tutorial/how-to/reference/explanation); Spec Kit's are spec/plan/tasks. Both support the
  *principle* (distinct epistemic jobs → distinct artifacts), neither supports Swarm's *specific
  four*. Decorative, not load-bearing (the decision stands on its own reasoning). ADR-0001 is under
  the immutable-ADR rule, so any correction is a superseding/clarifying note.
- **O-11 — `lint` "highest-leverage pass" / PlanSolve "measurably beats" superlatives (MINOR).**
  `lint.md:7` asserts "the highest-leverage pass" — an unfalsifiable ranking against 8 others, stated
  as fact. `lower.md:91` states "a structured intermediate measurably beats free prose for downstream
  code work" — an empirical-shaped extension beyond what Plan-and-Solve measured, presented
  declaratively without its own citation (though `[SCOT]`, arXiv:2305.06599, +13.79% Pass@1, *does*
  verify this exact direction and could ground it).

### Contamination residue (MINOR — out of canonical scope)

- **O-12 — `docs/_legacy/` still asserts the rejected figures as fact, unbanner­ed (MINOR).** The
  archived tree carries the fabricated **21×** ("the single most direct piece of evidence",
  `_legacy/skills/building/task-files.md:113`) and **24–68%** figures as live claims with the
  now-debunked arXiv ids, and `_legacy/README.md` still calls itself "the canonical home" / "🟢
  Stable" with no archived banner. It is grep-findable and git-tracked; a future reader or workflow
  could resurface the figures as fact. Out of the audited surface, flagged so it is not re-promoted.

### Confirmed solid (reinforce / leave)

- **O-13.** The prior-art cluster is **evidence-clean**: OpenAPI / Terraform / Smithy / Kubernetes
  spec-vs-status, SARIF (result-in-run ⇒ verdict-in-`review.md`), EARS (WHEN/WHILE/WHERE/IF + the
  Rolls-Royce CS-E figures), RFC 2119/8174 (MUST≡SHALL → SHALL redundant), Diátaxis-as-doc-frames
  (the documentarian profile), Nygard ADR immutability (and the framework *dogfoods* it), Open Agent
  Skills (SKILL.md / 1024-char cap / progressive disclosure), agents.md — **all verified exact**. The
  brief's expected "LLVM IR / AST" analogy **is not asserted anywhere** (grep-clean); the compiler
  grounding actually used is generic ("IR", "lowering", a phase-vs-pass *inversion* of the Dragon
  Book's common case) and is correct and honestly scoped.
- **O-14.** The caveated tier is handled correctly: `[ACTIVATION-BLOG]`, `[TWOPROBLEMS]`,
  `[PRACTITIONER]` are all real, correctly attributed, and at **every** canonical use site explicitly
  marked preliminary/illustrative — **none sits on a `MUST`**; where a nearby rule is normative the
  weight is carried by official sources (`[SKILLBP]`/`[SKILLSPEC]`). The 650-trial / OR≈20.6 / "100%
  activation" figures appear in canonical docs **only inside disclaimers**.
- **O-15.** The design layer is internally coherent and appropriately grounded: the
  agents-as-compiler thesis (prior art labelled "design rationale"; `[SCOT]` as the empirical leg),
  the 9-pass model, the 7-value verdict, the merge gate, NO-RUNTIME/SOFT-vs-HARD, the SOL surface
  (EARS/RFC-2119/STE/FRET all verified), profile×pass routing, two-axis source authority, the
  two-tier memory model, and conformance-as-inert-data (precision/recall correctly labelled "design
  targets, not measurements"). The ≤200-line AGENTS.md cap (on `[LOSTMID]`) and the ~500-line skill
  cap (on `[SKILLBP]`/`[SKILLSPEC]`) are kept distinct and correctly attributed.

## Risks

- **R-1 (credibility).** The two MAJOR source defects (O-1 SCRATCHPAD venue, O-2/O-8 AGENTSMD-HARM
  tier + companion) sit on the framework's *peer-reviewed/verified* labels. A skeptic who dereferences
  either finds the label over-promised — which discredits the whole bibliography by association, even
  though every number is real. The §0.7 discipline is the framework's differentiator ("real science,
  not astrology"); a label that doesn't hold undercuts that differentiator more than a missing source
  would.
- **R-2 (self-consistency).** O-5 means the framework's own pass docs violate the §0.7 rule it levies
  on everyone else (fact-shaped + uncited + unlabelled). The gap between stated discipline and
  pass-layer practice is the most visible internal inconsistency.
- **R-3 (re-contamination).** O-7 (dangling keys to the frozen bibliography) + O-12 (unbannered
  fabricated figures in `_legacy/`) are the two channels by which a rejected/unverifiable figure could
  slip back into canonical text — exactly the failure §0.7 exists to prevent.
- **R-4 (single-source concentration).** `[REFLEXION]` grounds the entire forced-visible-output
  primitive across ~20 sites, several only thematically adjacent. Not a defect, but a fragility: if
  that one citation were ever challenged, ~20 claims wobble at once.

## Recommended obligations

*Candidate fortifications for a future pass — recommendations, not edits. Priority-ordered. None
requires changing a verified number; all are attribution/labeling/citation hygiene + reinforcement.*

1. **Correct the two venue/tier over-statements (O-1, O-2, O-8).** Relabel `[SCRATCHPAD]` "ICLR 2022
   **Workshop (DL4C)**" everywhere (`sources.md:18`, `task-files.md:15`, …); keep it as a corroborated
   primary with the workshop qualifier (ToT/PlanSolve/Reflexion converge on the same direction). For
   `[AGENTSMD-HARM]`: add arXiv id **2602.11988**, fix affiliation to "ETH Zürich + LogicStar.ai",
   re-attribute the cost claim to the primary (and recast the Lulla companion honestly as a
   *contrasting* result), and either move it to a caveated tier or reframe the ADR-0018/0038 citations
   as *supporting* the design choice rather than *grounding* a `MUST`.
2. **Re-attribute `[CTXENG]` (O-3).** State what the source says — "context as a finite resource;
   structured note-taking / agentic memory (`NOTES.md`, a to-do list)" — and present the
   `task_plan`/`progress_log`/`decisions` triad explicitly as **Swarm's own decomposition**, not
   Anthropic's. Fix `sources.md:39`, `task-files.md:28-36`, `self-containment.md:66`.
3. **Close the pass-doc citation gap (O-5).** Add `[[PLANCODER]]`, `[[HILBENCH]]`, `[[VERINA]]`,
   `[[VERICODING]]`, `[[SWEBENCH-ADQ]]`, `[[UTBOOST]]` at point-of-use in `lint`/`improve`/`lower`/
   `verify` (or a per-doc Related/sources link) — and mirror into the kernel twins. No figure changes.
4. **Ground or label N4 (O-6) and resolve the split bibliography (O-7).** Port the `[DETERMINISM]`
   citation + "lab blog, not peer-reviewed" caveat into `NON-GOALS.md` N4 (or recast N4 as pure
   design rationale). Decide which `sources.md` is canonical for `docs/`; add `[ARIZE26]`/
   `[DETERMINISM]` (Caveated tier) to `docs/research/sources.md`, or reword `:52` to not reference
   unresolvable keys.
5. **Repoint `[CCTASKS]` (O-4)** to the canonical Tasks documentation that states disk-persistence +
   the dependency DAG, then state the `addBlockedBy ↔ blocked_by` correspondence more strongly (it is
   under-sold).
6. **Fix the minor attributions (O-9, O-10, O-11).** Drop "explain-the-why" + the ALL-CAPS
   yellow-signal from the `[SKILLBP]` entry (keep under `[PRACTITIONER]`). Reword `ADR-0001:11`
   (as a clarifying note) to claim the *principle*, not Swarm's specific four. Soften `lint`
   "highest-leverage" and `lower.md:91` "measurably beats" to design rationale — or ground the latter
   on `[SCOT]`, which verifies it.
7. **Reinforce where evidence already exists (improve).** Add `[[MAST]]` at the failure-mode taxonomy
   (`positioning.md:32-43` — the empirical heart of "why Swarm", currently under-leveraged). Add
   point-of-use citations to the standards already named: EARS→Mavin (IEEE RE 2009) in `SOL.md`/
   `glossary.md`; Nygard 2011 in `adrs/README.md`; `diataxis.fr` in the documentarian profile;
   `[MEMGPT]` in `ADR-0032`. Note the no-runtime asymmetry in the OpenAPI/Terraform analogy
   (`compiler-pipeline.md:19`). Diversify `[REFLEXION]`'s ~20-site load with a second primary (R-4).
8. **Strengthen the directive-description footing (improve, verify first).** The directive
   four-clause form currently rests only on the caveated `[ACTIVATION-BLOG]`. Anthropic's own
   `skill-creator` guidance ("descriptions should be a little pushy because Claude tends to
   under-trigger… use this skill … even if they do not explicitly ask") is an **official-tier**
   corroborator. **Verify the exact artifact** that contains this wording before adding it (it was
   not on the current best-practices page) — then add it and demote `[ACTIVATION-BLOG]` to a mere
   illustration. (arXiv:2602.20426 on tool-description rewriting is a *preprint* second
   corroboration — Caveated tier only, do not promote.)
9. **Neutralize the contamination channel (O-12).** Add an "ARCHIVED / superseded / contains
   since-rejected figures — see `docs/research/sources.md` Rejected" banner to `_legacy/README.md`
   and the affected `building/` files, or drop the fabricated-figure paragraphs, or remove `_legacy/`
   from the tracked tree.

---

*No framework changes were made by this audit. Every recommendation is reinforce / alter / improve —
the framework's evidence is sound; this fortifies the attribution discipline around it.*
