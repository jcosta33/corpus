# Sources — artifact-author skill design

Design evidence for the skills under `skills/`. Primary and official sources outrank summaries. A
source supports only claims inside its competence.

This ledger grounds how the artifact authors are written. Load-bearing empirical claims in Corpus's
prose cite [the product bibliography](../docs/research/sources.md) instead.

## Maintenance

- Update this file in the same change as any externally grounded skill or design rule.
- State what each source supports and where its authority ends.
- Lead with primary research, specifications, and official vendor documentation.
- Label secondary and practitioner material as bounded hypotheses.
- Bound field reports by harness, model, version, and date. Never generalize one setup into a
  portable guarantee.
- Remove a source when its claim leaves or the source no longer supports it.

## Skill Economy

- **SWE-Skills-Bench.** arXiv:2603.15401, v2 October 2026. Skills raised the average pass ratio only
  from 76.6% to 76.9%; 92 of 98 had no significant effect; harmful skills anchored agents on their
  own templates. Benchmark of coding tasks; grounds cutting rules a strong model already follows.
  <https://arxiv.org/abs/2603.15401>
- **Agent instruction bloat, Thoughtworks Technology Radar Vol 35 (Caution, November 2026).**
  Convert instructions into deterministic checks where possible and re-test the rest against each
  new model. Expert panel judgement, not a measurement.
  <https://www.thoughtworks.com/radar/techniques/agent-instruction-bloat>

## Spec Structural Change

- **to-tickets, mattpocock/skills.** Sequences a wide refactor as expand, migrate call sites in
  batches, then contract once no caller remains. Practitioner skill, not a measurement.
  <https://github.com/mattpocock/skills/blob/main/skills/engineering/to-tickets/SKILL.md>
- **BMAD deletion check.** Asks whether removed code carried behavior or a contract the change
  neither re-established nor intentionally retired. Practitioner framework.
  <https://github.com/bmad-code-org/BMAD-METHOD/blob/main/skills/bmad-build/references/deletion-check.md>
- **Augmented coding: beyond the vibes, Kent Beck, June 2025.** First-hand report of agents deleting
  or disabling tests to make them pass. One practitioner's experience; grounds the never-weaken-tests
  rule, not its prevalence. <https://newsletter.kentbeck.com/p/augmented-coding-beyond-the-vibes>

## Audit Mapping

- **audit-context-building, Trail of Bits.** Records for each function what it takes on faith and
  what makes that true, marking unenforced assumptions `nothing found`. Practitioner skill.
  <https://github.com/trailofbits/skills/blob/main/plugins/audit-context-building/skills/audit-context-building/SKILL.md>

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
- **About protected branches, GitHub.** Defines required review, stale-approval dismissal,
  conversation resolution, and merge queues.
  <https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches/about-protected-branches>
- **Pull requests REST API, GitHub.** Defines expected-head validation for merge requests and the
  write permission required to merge; hard separation therefore requires a credential boundary.
  <https://docs.github.com/en/rest/pulls/pulls>
- **GitHub Issues and milestones.** Issues carry work discussion and assignment; milestones group
  issue and pull-request progress.
  <https://docs.github.com/en/issues/tracking-your-work-with-issues/learning-about-issues/about-issues>
  <https://docs.github.com/en/issues/using-labels-and-milestones-to-track-work/about-milestones>

- **Keep Claude working toward a goal, Anthropic.** A small fast model judges a goal condition of
  up to 4,000 characters after each turn, from the conversation alone; good conditions name one
  measurable end state, a stated check, and constraints. Grounds the completion-contract form.
  <https://code.claude.com/docs/en/goal>
- **Using goals in Codex, OpenAI.** Template "desired end state verified by specific evidence while
  preserving constraints"; a goal is not complete because the model believes it is probably done.
  <https://developers.openai.com/cookbook/examples/codex/using_goals_in_codex>
- **Agent OS changelog, v3.0.0.** Retired its implementation and orchestration phases because
  frontier models handle them unaided. Practitioner framework decision, not a measurement; grounds
  leaving generic delivery method to the project and the model.
  <https://github.com/buildermethods/agent-os/blob/main/CHANGELOG.md>

## Research Method

- **GRADE handbook.** Defines evidence-certainty levels and explicit downgrade/upgrade factors.
  <https://gdt.gradepro.org/app/handbook/handbook.html>
- **GRADE: an emerging consensus on rating quality of evidence and strength of recommendations.**
  Guyatt et al., BMJ 2008. Foundational account of evidence-quality grading.
  <https://pmc.ncbi.nlm.nih.gov/articles/PMC2335261/>
- **PRISMA 2020 statement.** Page et al., BMJ 2021. Defines transparent reporting for systematic
  evidence searches and synthesis. <https://www.ncbi.nlm.nih.gov/pmc/articles/PMC8005924/>
- **AAPOR Disclosure Standards.** Requires population, sample, mode, dates, weighting, quality
  checks, precision limits, and limitations for survey evidence.
  <https://aapor.org/standards-and-ethics/disclosure-standards/>

- **Cited but Not Verified.** Onweller et al., arXiv:2605.06635, May 2026. Deep-research agents
  kept links above 94% valid and relevance above 80%, but factual accuracy was 39–77% and fell about
  42% as tool calls rose from 2 to 150. Grounds passage-level support and bounded search breadth.
  Benchmark on named frontier models. <https://arxiv.org/abs/2605.06635>
- **BMAD deep-recon verification reference.** Defines per-claim verified, disputed, unverified, and
  overturned outcomes; disputed figures are both reported and never averaged; independence means a
  different publisher with different underlying data. Practitioner framework, not a measurement.
  <https://github.com/bmad-code-org/BMAD-METHOD/blob/main/skills/bmad-deep-recon/references/verification.md>

## Citation Discipline

- Verify identity, title, date, and locator before citing.
- Label secondary sources and use them only for their analysis or to locate primary evidence.
- Record contradictory evidence and material rejected sources.
- Replace dead links or mark them unavailable; never silently retain an unverifiable claim.
