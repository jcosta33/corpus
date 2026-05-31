# 12 · Prior art

> **TL;DR.** Swarm is intellectually aligned with the bleeding edge of agentic coding (mid-2026). The field has converged on a handful of patterns — spec-before-code, downhill distillation, AGENTS.md as cross-tool standard, skills as progressive disclosure, context isolation via subagents — and Swarm matches each one. Where the field is divided (single-threaded vs orchestrator-worker, persona ceremony, TDD-as-iron-law, session-start hooks), Swarm picks a defensible position and explains why. The biggest single thing that distinguishes Swarm is making the *forbidden flows* explicit.

---

## 📚 Sources

The bibliography for the field landscape, late-2025 through mid-2026:

- **[S1]** Cognition AI. *Don't Build Multi-Agents.* Walden Yan. cognition.ai/blog/dont-build-multi-agents (June 2025).
- **[S2]** Cognition AI. *Multi-Agents: What's Actually Working.* cognition.ai/blog/multi-agents-working (April 2026 — the "10 months later" reversal).
- **[S3]** Anthropic. *How we built our multi-agent research system.* anthropic.com/engineering/multi-agent-research-system (June 2025).
- **[S4]** Anthropic. *Claude Code best practices.* code.claude.com/docs/en/best-practices (current).
- **[S5]** Anthropic. *2026 Agentic Coding Trends Report.* resources.anthropic.com (early 2026).
- **[S6]** Anthropic / Boris Cherny. *Claude Code subagents course.* anthropic.skilljar.com (2026).
- **[S7]** GitHub. *Spec Kit.* github.com/github/spec-kit. Plus Microsoft Developer Blog companion piece.
- **[S8]** BMAD-METHOD. github.com/bmad-code-org/BMAD-METHOD and ArceApps deep-dive (Sep 2025).
- **[S9]** Jesse Vincent (obra). *Superpowers* skills framework. github.com/obra/superpowers and Marc Nuri's analysis (May 2026).
- **[S10]** OpenAI. *Codex AGENTS.md guide* and *Agent Skills.* developers.openai.com/codex.
- **[S11]** AGENTS.md — open standard now stewarded by the Agentic AI Foundation under the Linux Foundation. agents.md.
- **[S12]** IndyDevDan. *Top 2% Agentic Engineering Roadmap 2026.* agenticengineer.com (April 2026).
- **[S13]** CodeScene. *Agentic AI coding best-practice patterns.* codescene.com (Feb 2026).
- **[S14]** OpenSpec, Kiro (AWS), Augment Code's "Intent" — comparative analysis at augmentcode.com (March 2026).
- **[S15]** Diátaxis documentation framework — diataxis.fr (2024 onward).

---

## ✅ Convergent patterns (Swarm matches)

The field has converged on six patterns. Swarm matches all six.

### 1. Spec-before-code is now the default

Every major framework — Spec Kit, BMAD, OpenSpec, Superpowers, Kiro, Augment's Intent — leads with a written specification that the agent implements against. Spec-driven development is now defined as a methodology where specifications become *executable, first-class artifacts* that directly generate implementations rather than merely guiding them.

The Anthropic 2026 Trends Report calls this the standard pattern at "Phase 2" maturity (feature-level autonomy with human review), where most leading teams now operate. Blink reports that vague prompts versus brief written specs differ by ~60% in rollback rate.

**Swarm's position:** the spec grounds Feature Development. This is the field consensus, not a novelty.

### 2. research → plan → execute → review → ship

Named slightly differently across sources — Karpathy's "agentic engineering," IndyDevDan's "in-loop / out-loop," Anthropic's "explore → plan → code → verify," Superpowers' six-phase workflow — but structurally identical.

**Swarm's position:** the distillation chain (research → spec → task → code → audit) is the same shape with different names.

### 3. AGENTS.md is the cross-tool standard

The format originated at OpenAI Codex and is now supported by Cursor, Aider, Devin, Factory, Jules (Google), Junie (JetBrains), Warp, Zed, opencode, and others — stewarded by the Agentic AI Foundation under the Linux Foundation. The OpenAI monorepo alone reportedly ships 88 nested AGENTS.md files, with the *closest file in the directory tree* winning. Codex extends this with `AGENTS.override.md` for monorepo subdirectories that need different rules.

**Swarm's position:** AGENTS.md is the canonical entry point. See [`reference/agents-md.md`](../reference/agents-md.md) for Swarm's adoption of the open standard, including hierarchical override semantics.

### 4. Skills as progressive disclosure

Anthropic's skills format (October 2025) — a folder containing `SKILL.md` plus optional scripts and references, loaded on demand based on the description field — has been adopted nearly verbatim by OpenAI Codex. The file format for an agent and a subagent is identical; both are Markdown files with YAML frontmatter — the distinction is entirely behavioural, about the role the instance plays at runtime. Skills carry deep domain knowledge; the description field is the trigger.

**Swarm's position:** the `.agents/skills/` directory and `description` field already match this. Two refinements borrowed from the field:

- Skills as folders with subdirectories (`references/`, `scripts/`, `examples/`) for further progressive disclosure
- Skill descriptions written *for the model* ("when should I fire?"), not as content summaries

### 5. Context isolation via subagents

This is the single biggest architectural lesson of 2025–2026. Subagents run in separate context windows and report back summaries — since context is the fundamental constraint, subagents are one of the most powerful tools available. Anthropic's research system showed subagents outperforming single-agent setups by 90.2% on breadth-first tasks.

**Swarm's position:** see [`10-subagent-strategy.md`](10-subagent-strategy.md). Read-side parallelism encouraged; write-side single-threaded.

### 6. Gitignored task-local files

This is universal and quiet — every framework that has thought hard about it ends up gitignoring task scratch files.

**Swarm's position:** matches. See [ADR 0004](../adrs/0004-task-files-are-gitignored.md).

---

## ⚖️ Divergent patterns (Swarm picks a side)

Where the field is divided, Swarm picks a position.

### 🎯 Single-threaded writes vs orchestrator-worker

The most important strategic question in agentic coding right now.

- **Cognition (June 2025, *Don't Build Multi-Agents*):** Most multi-agent setups are limited to read-only subagents because of context-engineering constraints. Devin runs a single agent thread for writes.
- **Anthropic (June 2025):** Their Research system uses an orchestrator-worker pattern. Internal evaluations: 90.2% improvement over single-agent on breadth-first tasks.
- **Cognition's reversal (April 2026):** A narrower class works, where agents contribute intelligence while writes stay single-threaded.

The synthesis: **read-side parallelism is fine; write-side parallelism causes coordination failure.**

**Swarm's position:** matches the synthesis. Subagents permitted for research/audit/review; writes serialised through the Lead Engineer pattern. See [`10-subagent-strategy.md`](10-subagent-strategy.md) and [ADR 0010](../adrs/0010-write-side-single-threaded.md).

### 🎭 Persona ceremony

Three points on the spectrum:

| Framework        | Ceremony level | Approach                                                  |
| ---------------- | -------------- | --------------------------------------------------------- |
| **Spec Kit**     | None           | The user is the orchestrator; commands like `/specify`, `/plan`, `/tasks` structure prompts to a single agent |
| **Superpowers**  | Mid            | No named human-style personas. Skills represent practices (TDD, debugging, code review). The discipline lives in the skills |
| **BMAD-METHOD**  | High           | 21+ named personas — Mary the Analyst, Preston the PM, Winston the Architect, etc. The BMad Master Orchestrator coordinates handoffs through YAML configs. Coordination overhead and learning curve noted by reviewers |

**Swarm's position:** sits between Superpowers and BMAD. 13 personas, but they describe *mindsets* (Builder, Skeptic, Specifier) rather than roleplaying named characters. No "BMad Master." The hedge against ceremony creep:

- Persona profiles are short (one screen)
- Hard rules and forbidden actions, not prose backstories
- Suggested 1:1 task mapping (the agent may re-assess)

See [ADR 0009](../adrs/0009-personas-are-mindsets.md).

### 🧪 TDD as iron law vs flexible

- **Superpowers:** Code written before the test gets deleted. RED-GREEN-REFACTOR with no exceptions. Includes a "red flags" list of rationalisations the agent is most likely to use to skip the rule.
- **BMAD:** QA as a separate phase — Quinn the QA Engineer takes over after Devon the Dev finishes.
- **Spec Kit, Cognition, Anthropic:** Treat tests as part of the spec's acceptance criteria but don't enforce ordering.

**Swarm's position:** test-first ordering is a project decision, not a framework decision. Tests are required (verification gates + Self-review), but ordering relative to implementation is flexible. Projects can adopt TDD-as-iron-law via a project-specific skill (Superpowers' approach is fully compatible with Swarm).

### 🎬 Session start hooks

Superpowers ships a session-start hook that injects a short bootstrap document — reportedly under two thousand tokens — telling the agent to invoke a relevant skill before doing anything else. This is what makes the framework work in practice: skills don't apply themselves; the hook ensures they're considered.

**Swarm's position:** specified. See [`reference/agents-md.md`](../reference/agents-md.md). The framework recommends an AGENTS.md leading instruction (or equivalent CLI hook) that says: "First action — read your task file, then load the skills whose descriptions match the work." The mechanism is at the agent CLI layer; the *content* of the hook is framework-defined.

---

## 🆕 Patterns Swarm is borrowing (in this revision)

The frontier research surfaced six gaps in earlier Swarm drafts. The current docs address all six:

| Gap (from frontier research)                   | How addressed                                                                |
| ---------------------------------------------- | ---------------------------------------------------------------------------- |
| 1. No subagent strategy                        | New concept doc: [`10-subagent-strategy.md`](10-subagent-strategy.md)        |
| 2. AGENTS.md not specified                     | New reference: [`reference/agents-md.md`](../reference/agents-md.md)         |
| 3. No session-start hook spec                  | Specified in [`reference/agents-md.md`](../reference/agents-md.md)            |
| 4. No "iron law + red flags" pattern           | Adopted in persona profiles; see each [`personas/`](../personas/) page       |
| 5. Research is reactive, not proactive         | Research is the preparation phase of `research-writing`; the recommended routing is "research-first when scope is unclear" (the `write-research` skill carries the discipline) |
| 6. No session-resumption semantics             | Documented in [`11-session-lifecycle.md`](11-session-lifecycle.md)            |

---

## 🪞 The comparison table

|                            | Spec Kit         | BMAD-METHOD          | Superpowers                 | Cognition / Devin  | Anthropic Research    | **Swarm**                          |
| -------------------------- | ---------------- | -------------------- | --------------------------- | ------------------ | --------------------- | ---------------------------------- |
| Primary unit of work       | Spec command     | Story file           | Skill-driven task           | Devin session      | Lead Researcher query | **Task file**                      |
| Spec required for features | ✅ Yes           | ✅ Yes (PRD + arch)  | ✅ Yes (after brainstorming) | ⚠️ Implicit (plan.md) | n/a (research)        | ✅ **Yes**                         |
| Personas                   | None             | 21+ named characters | None (skill-based)          | None               | Lead + Subagents      | **13 mindsets (8 ship as skills), 1:1 suggested** |
| Skills format              | n/a              | YAML workflows       | SKILL.md (Anthropic format) | n/a                | SKILL.md              | **SKILL.md**                       |
| Subagent strategy          | n/a              | Persona-handoff      | Subagent-per-task           | Read-only only     | Orchestrator-worker   | **Read-side parallel; write-side single-threaded** |
| Validation enforcement     | Manual           | QA agent phase       | TDD iron law                | CI before merge    | Citation agent        | **Named gate slots + Self-review hard gate** |
| Cross-tool portability     | Yes (30+ agents) | Yes (multi-IDE)      | Yes (6 hosts)               | Devin-only         | Anthropic-only        | **Tool-agnostic by design**        |
| Session start hook         | n/a              | YAML state           | Bootstrap doc               | Cloud session      | n/a                   | **Specified via AGENTS.md**        |
| Sequencing rules           | Implicit         | Phase-based          | Skill-based                 | Implicit           | Orchestration prompts | **Explicit recommended-routing rules** |
| Forbidden-flows table      | Implicit         | Implicit             | Implicit                    | Implicit           | n/a                   | **Explicit (this is novel)**       |

---

## 🪜 Where Swarm is well-positioned

1. **Task-as-source-of-truth framing.** Most frameworks lead with the spec or the persona. Swarm leads with the task and arranges everything else around it. This is closer to how Cognition describes Devin internally and matches IndyDevDan's "talk to your lead agent" framing for 2026.

2. **Explicit forbidden flows.** No other framework writes them out as a table the way Swarm does. Spec Kit, Superpowers, BMAD all have these implicitly. Making them explicit is genuinely novel — and load-bearing for the determinism guarantee.

3. **Persona ceremony pitched correctly.** Mindsets, not characters. Hard rules and forbidden actions, not roleplay. Suggested 1:1 task mapping the agent may re-assess. A better middle ground than Spec Kit's "no personas" or BMAD's "21+ characters."

4. **Tool-agnostic validation gates.** Most frameworks bake in `pnpm test` or `cargo check`. Swarm's named-slot approach is portable in a way the others aren't.

5. **Distillation directionality.** The unidirectional flow (research → spec → task → code → audit) matches the universal pattern but Swarm states it as a hard constraint rather than a convention. The "code → spec back-fill is forbidden" rule isn't stated anywhere else, even though everyone implicitly believes it.

---

## 🎯 What this research did not resolve

- Whether the convergence around AGENTS.md will hold or whether a vendor will fragment it (Cursor's `.cursor/rules/` and Claude's `.claude/skills/` already coexist).
- Whether Anthropic's orchestrator-worker pattern transfers cleanly to coding tasks. Anthropic's own engineering docs are explicit that multi-agent systems excel at problems that can be divided into parallel strands of *research*, but are less effective for tightly interdependent tasks such as *coding*. The Cognition reversal qualifies this but doesn't refute it.
- Long-term cost. Multi-agent systems consume roughly 15× more tokens than single-agent chats. This is fine for research workflows but punishing for routine implementation work.
- **Memory.** None of the frameworks reviewed have a satisfactory answer for cross-session, cross-worktree, cross-project knowledge accumulation. This is probably the next frontier. Swarm provides a partial answer (the resumption record + promotion protocol) within a single project.
- **Verifiable output (where Swarm sits today).** Spec-driven development is defined around specs that *directly generate implementations* [S5][S7]. Swarm sits at the **conditioning** layer of this, not the **compiler** layer: its specs are prose whose acceptance criteria are interpreted downstream into tests, and its confidence gate is agent-self-attested empirical proof, not independent execution. Closing that gap — executable acceptance criteria, an independent verification contract, machine-checkable conformance — is the subject of [`agents-as-compiler-readiness`](../../.agents/audits/agents-as-compiler-readiness.md) and the verification-contract ADRs (0021–0026).

---

## 📜 Citations format

When citing prior art in Swarm docs, use the bracketed-source format with the bibliography above. Example:

> Spec-driven development is now defined as a methodology where specifications become executable, first-class artefacts [S5][S7].

This keeps the docs traceable without inflating the prose with full URLs.

---

## See also

- [`PRINCIPLES.md`](../PRINCIPLES.md) — the load-bearing constraints
- [`NON-GOALS.md`](../NON-GOALS.md) — the negative space
- [`reference/agents-md.md`](../reference/agents-md.md) — Swarm's adoption of the open standard
- [`10-subagent-strategy.md`](10-subagent-strategy.md) — the Cognition / Anthropic synthesis
- [`adrs/`](../adrs/) — the design decisions, with alternatives considered
