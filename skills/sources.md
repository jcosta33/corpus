# Sources — artifact-author skill design

Design evidence for the skills under `skills/`. Primary and official sources outrank summaries. A
source supports only claims inside its competence.

This ledger grounds how the artifact authors are written. Load-bearing empirical claims in Suspec's
prose cite [the product bibliography](../docs/research/sources.md) instead.

## Maintenance

- Update this file in the same change as any externally grounded skill or design rule.
- State what each source supports and where its authority ends.
- Lead with primary research, specifications, and official vendor documentation.
- Label secondary and practitioner material as bounded hypotheses.
- Bound field reports by harness, model, version, and date. Never generalize one setup into a
  portable guarantee.
- Remove a source when its claim leaves or the source no longer supports it.

## Campaign Coordination

- **Follow a goal, OpenAI.** Defines a durable coding goal by one objective, a verifiable stopping
  condition, source pointers, progress proof, checkpoints, and compact status. Warns against loose
  backlogs and accumulated one-off instructions.
  <https://learn.chatgpt.com/use-cases/follow-goals>
- **Effective harnesses for long-running agents, Anthropic.** Reports one-shot implementation,
  undocumented partial work, and premature completion across fresh contexts; uses incremental work
  and structured continuity artifacts. First-party experiment, not a universal file contract.
  <https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents>
- **Magentic-One, Microsoft Research.** Separates stable task planning from mutable progress
  tracking in a two-ledger orchestrator and replans on stalls.
  <https://www.microsoft.com/en-us/research/articles/magentic-one-a-generalist-multi-agent-system-for-solving-complex-tasks/>
- **Adding sub-issues, GitHub.** Defines project-native hierarchical work relationships and progress
  across repositories. <https://docs.github.com/en/issues/tracking-your-work-with-issues/using-issues/adding-sub-issues>
- **Git worktree documentation.** Defines linked worktrees, concurrent branch checkout, locking,
  cleaning, and branch-in-use safeguards. <https://git-scm.com/docs/git-worktree>
- **Git switch documentation.** Defines branch creation, detached checkout, and dirty-state behavior.
  <https://git-scm.com/docs/git-switch>
- **About pull request reviews, GitHub.** Defines review comments, approvals, change requests,
  conversation resolution, and protected-branch integration.
  <https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/reviewing-changes-in-pull-requests/about-pull-request-reviews>
- **Commenting on a pull request, GitHub.** Defines line comments, replies, suggestions, and
  conversation resolution.
  <https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/reviewing-changes-in-pull-requests/commenting-on-a-pull-request>
- **Small CLs, Google Engineering Practices.** Supports one self-contained change, early splitting,
  reviewable size, and separate refactors while rejecting a universal numeric limit.
  <https://google.github.io/eng-practices/review/developer/small-cls.html>
- **The Promise and Reality of Continuous Integration Caching.** Ghaleb, da Costa, and Zou,
  arXiv:2601.19146. Preliminary CI evidence: caching can cut build time, but stale artifacts remain
  common. It does not directly measure local worktree dependencies. <https://arxiv.org/abs/2601.19146>
- **About pull requests, GitHub.** Defines draft and ready-for-review states.
  <https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/proposing-changes-to-your-work-with-pull-requests/about-pull-requests>
- **Pull-request review summary update, GitHub.** A request-changes review needs no summary when its
  inline comments already carry the findings.
  <https://github.blog/changelog/2026-02-19-access-all-pull-request-comments-without-leaving-the-new-files-changed-page/>
- **About protected branches, GitHub.** Defines required review, stale-approval dismissal,
  conversation resolution, and merge queues.
  <https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches/about-protected-branches>
- **Approving a pull request with required reviews, GitHub.** Defines approval and change-request
  clearance. <https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/reviewing-changes-in-pull-requests/approving-a-pull-request-with-required-reviews>
- **Pull requests REST API, GitHub.** Defines expected-head validation for merge requests and the
  write permission required to merge; hard separation therefore requires a credential boundary.
  <https://docs.github.com/en/rest/pulls/pulls>
- **GitHub Issues and milestones.** Issues carry work discussion and assignment; milestones group
  issue and pull-request progress.
  <https://docs.github.com/en/issues/tracking-your-work-with-issues/learning-about-issues/about-issues>
  <https://docs.github.com/en/issues/using-labels-and-milestones-to-track-work/about-milestones>
- **Realizing quality improvement through test driven development.** Nagappan et al., Empirical
  Software Engineering 2008. Four industrial teams reported lower defect density with higher initial
  development time; small observational cases do not establish a universal procedure.
  <https://www.microsoft.com/en-us/research/wp-content/uploads/2009/10/Realizing-Quality-Improvement-Through-Test-Driven-Development-Results-and-Experiences-of-Four-Industrial-Teams-nagappan_tdd.pdf>
- **SWT-Bench.** Mündler et al., NeurIPS 2024. Distinguishes fail-before/pass-after bug reproduction
  tests from irrelevant or merely covering generated tests.
  <https://proceedings.neurips.cc/paper_files/paper/2024/hash/94f093b41fc2666376fb1f667fe282f3-Abstract-Conference.html>
- **TDFlow.** Han et al., EACL 2026. Reports 94.3% on SWE-Bench Verified with human-written tests and
  68.0% with generated tests; oracle generation, not test execution, was the bottleneck. The setup
  exposes tests unavailable in ordinary issue resolution.
  <https://aclanthology.org/2026.eacl-long.70/>
- **Rethinking the Value of Agent-Generated Tests.** Chen et al., arXiv:2602.07900. A six-model
  observational study and four-model prompt intervention found more generated tests did not
  significantly change final outcomes. Preliminary.
  <https://arxiv.org/abs/2602.07900>

## Research Method

- **GRADE handbook.** Defines evidence-certainty levels and explicit downgrade/upgrade factors.
  <https://gdt.gradepro.org/app/handbook/handbook.html>
- **GRADE: an emerging consensus on rating quality of evidence and strength of recommendations.**
  Guyatt et al., BMJ 2008. Foundational account of evidence-quality grading.
  <https://pmc.ncbi.nlm.nih.gov/articles/PMC2335261/>
- **PRISMA 2020 statement.** Page et al., BMJ 2021. Defines transparent reporting for systematic
  evidence searches and synthesis. <https://www.ncbi.nlm.nih.gov/pmc/articles/PMC8005924/>
- **ICC/ESOMAR International Code on Market, Opinion and Social Research and Data Analytics.**
  Professional requirements for legality, transparency, privacy, method disclosure, and human
  oversight. <https://iccwbo.org/news-publications/business-solutions/iccesomar-international-code-market-opinion-social-research-data-analytics/>
- **AAPOR Disclosure Standards.** Requires population, sample, mode, dates, weighting, quality
  checks, precision limits, and limitations for survey evidence.
  <https://aapor.org/standards-and-ethics/disclosure-standards/>
- **Using LLMs for Market Research.** Brand, Israeli, and Ngwe. Tests synthetic consumer responses
  and records failures to generalize across categories and segments.
  <https://papers.ssrn.com/sol3/papers.cfm?abstract_id=4395751>
- **Large Language Models for Market Research: A Data-Augmentation Approach.** Wang, Zhang, and
  Zhang, Marketing Science 2026. Reports benefits from calibrated augmentation and bias from naive
  substitution. <https://doi.org/10.1287/mksc.2025.0009>
- **Using large language models to generate silicon samples in consumer and marketing research.**
  Sarstedt et al., Psychology & Marketing 2024. Reviews domain-dependent strengths and limits of
  synthetic samples. <https://doi.org/10.1002/mar.21982>

## Citation Discipline

- Verify identity, title, date, and locator before citing.
- Label secondary sources and use them only for their analysis or to locate primary evidence.
- Record contradictory evidence and material rejected sources.
- Replace dead links or mark them unavailable; never silently retain an unverifiable claim.
