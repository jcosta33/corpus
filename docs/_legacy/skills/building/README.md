<div align="center">

# 📚 The science behind Swarm's skills

[![Spec](https://img.shields.io/badge/spec-agentskills.io-blue?style=flat-square)](https://agentskills.io)
[![Evidence](https://img.shields.io/badge/grounded%20in-empirical%20data-orange?style=flat-square)](./sources.md)

</div>

> Skills are agent prompts. Like any prompt, they have measurable failure modes. This directory documents the empirical evidence that shaped every structural choice in Swarm's skill layer — from the wording of a `description` field to the absence of any "always-loaded" skill.

Every choice in Swarm's shipped skills (under `.agents/skills/` in the scaffold), in the [writing-skills guide](../../guides/writing-skills.md), and in the `AGENTS.md` command contract traces to one of the documents below. If a contributor asks **"why is the description in this form?"**, **"why is there no always-loaded skill?"**, or **"why don't skills reference each other?"** — the answer is here, with a citation, not a hunch.

---

## What's in this directory

| Document | What it documents |
| --- | --- |
| [**Activation**](./activation.md) | Why every `description` is in directive form, the exclusion-clause discipline, the compliance ceiling |
| [**Body anatomy**](./body-anatomy.md) | Numbered rules with rationale, length budgets, anti-patterns sections, reference depth |
| [**Execution**](./execution.md) | The two reliability problems; the forced-visible-output fix; Reflexion as the deeper pattern |
| [**Self-containment**](./self-containment.md) | Why skills don't reference each other; the `AGENTS.md` contract; file-based state externalisation |
| [**Task files**](./task-files.md) | How task templates relate to plan-mode files; why most workflow skills ship one and a few don't; Anthropic's three-file canonical pattern |
| [**Scope**](./scope.md) | What belongs in the skill layer, what deliberately doesn't, and the principle behind each exclusion |
| [**Sources**](./sources.md) | Full bibliography. Every claim in this directory cites one of these |

---

## The findings, in one paragraph

A controlled 650-trial experiment measured Claude Code skill activation across three description styles and four environment conditions [\[3\]](./sources.md#3). Passive *"Use when …"* descriptions activated 50–77 % of the time and **collapsed to 37 % under hooks**. Directive descriptions — *"ALWAYS apply this skill when … Do not Y. Skip for Z."* — activated **100 % of trials**, with ~20× higher odds (CMH OR = 20.6, p < 0.0001). A separate analysis distinguished that activation failure from a different failure mode where late-stage verification steps inside an already-loaded skill get **silently skipped** because they delay output without producing visible content [\[4\]](./sources.md#4) — the same verbal-feedback discipline Reflexion [\[27\]](./sources.md#27) showed lifts HumanEval pass@1 from 80 % to 91 %. Anthropic's official guidance adds a 500-line body cap [\[2\]](./sources.md#2) anchored in the U-shaped attention curve [\[5\]](./sources.md#5)[\[30\]](./sources.md#30), and a **canonical three-file note-taking pattern** for long-running tasks (`task_plan` / `progress_log` / `decisions`) [\[20\]](./sources.md#20) — vendor-grade validation of file-based state externalisation, which an InfiAgent ablation [\[29\]](./sources.md#29) measured at **21× performance degradation when removed**. The ETH Zurich `AGENTS.md` study [\[32\]](./sources.md#32) closes the loop: tool-specific commands have **2.5× the impact when present**, but LLM-generated narrative context costs **+20 % for –3 % success** — the empirical case for Swarm's split between universal *how-to-work* skills and project-specific `AGENTS.md` *what-to-run* commands.

Everything in this directory applies that paragraph to specific structural choices in Swarm's skill layer.

---

## How the principles map to the scaffold

```mermaid
flowchart LR
    A["Empirical findings<br/>(see Sources)"] --> B("6 design principles")
    B --> C1["description: directive form"]
    B --> C2["body: numbered rules + anti-patterns"]
    B --> C3["length: ~200 lines, 500 cap"]
    B --> C4["verification: forced visible output"]
    B --> C5["skills: self-contained"]
    B --> C6["state: externalised to task files"]
    C1 --> D1[".agents/skills/*/SKILL.md frontmatter"]
    C2 --> D2[".agents/skills/*/SKILL.md body"]
    C3 --> D2
    C4 --> D3["empirical-proof, write-testing, write-research"]
    C5 --> D4["no cross-skill links + AGENTS.md contract"]
    C6 --> D5[".agents/skills/*/references/task-template.md"]
```

Each principle has a dedicated document in this directory; the [Sources](./sources.md) page lists the primary evidence behind every link in the chain.

---

## Living document

This is a working record, not a frozen artefact. When a new primary source materially changes a design choice, the relevant document and the [Sources](./sources.md) entry are updated together. If a source's URL goes dead, the citation is replaced or marked `[archived]`.

---

<div align="center">
<sub>Grounded in primary sources · Maintained alongside the skills they explain.</sub>
</div>
