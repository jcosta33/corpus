---
type: adr
id: adr-0113
status: accepted
created: 2026-06-27
updated: 2026-06-27
---

# ADR-0113 — Citations live in docs, not in products (the product-vs-docs boundary)

## Context

The Phase 3 family sweep (workflow `wf9rvvwys`, the AUDIT-family pass) confirmed the
re-architecture this program shipped was right in **file structure** — 8→6 agents, 7→11 skills,
corpus-mcp at 0.2.0, the catalog/kit split of [ADR-0112](./0112-two-tier-skills.md) — but the
**doc / reference layer drifted**, and every recurring issue mapped to a missing automated gate.

The concrete drift the sweep found: the **citation / product-pollution** and **count-drift**
classes had **recurred** in corpus-mcp and the kit. This program had already run a manual
strip-and-rule pass, but that pass covered only the **catalog and the agents** — so ADR-####
/ AUDIT-#### citations and repo / GitHub / DOI URLs leaked back into MCP tool strings and kit
files. Humans caught the recurrence in the sweep; no gate did. A citation embedded in a
product string is not just untidy: when a skill or agent is installed standalone, a
cross-folder link like `(./docs/...)` or an ADR reference resolves to nothing — the
self-containment break [ADR-0112](./0112-two-tier-skills.md) §1 already names as a coupling
smell, now observed leaking into shipped strings rather than skill bodies.

The boundary this program kept enforcing **by hand** was never written down as a decision. This
ADR writes it down.

## Decision

**Product-facing files carry zero sourcing; sourcing lives only under `docs/`.**

1. **The product surface — zero citations, zero source URLs.** These files MUST carry no
   `ADR-####` / `AUDIT-####` citation and no repo / GitHub / DOI URL:
   - agent definition **bodies** (corpus-agents),
   - **`SKILL.md` bodies** (the catalog and the kit),
   - MCP tool **`title` / `description` / `inputSchema` `.describe()` strings** (corpus-mcp),
   - product **READMEs**.

2. **The docs surface cites freely.** Everything under `docs/` — and the science / sources pages
   — sources normally; citing the evidence is *their job*. The boundary is between **what ships
   as product behavior** and **what documents it**.

3. **Two reasons it is a boundary, not a style choice:**
   (a) **Self-containment** — a cross-folder citation link 404s the moment the skill or agent is
   installed standalone, away from the `docs/` it pointed at;
   (b) **Separation of concerns** — sourcing is a documentation concern, not product behavior; a
   tool description's job is to tell an agent what the tool does, not to footnote why.

4. **Code comments are out of scope.** A comment is maintainer rationale, not a shipped product
   string; it may carry an ADR reference. The rule governs strings the *product emits or
   displays*, not the source that explains them to a maintainer.

_Level: convention (in force now, by discipline + review)._ The policy is **in force today**:
this program stripped corpus-skills, corpus-agents, corpus-mcp, and the kit, and codified the
rule in corpus-skills `docs/self-containment.md` Rule 3 and corpus-agents `docs/sources.md`.
What holds it today is **discipline and review**, not a tool.

The **enforcement path** is a per-repo CI regex-lint scanning the designated product paths for
`ADR-####` / `AUDIT-####` tokens and source URLs. That lint is the **toolable** path and is
**NOT YET SHIPPED** — it is not enforced, does not block, and is not guaranteed; the recurrence
the sweep found is exactly what an unbuilt gate fails to prevent. Per the honesty framework
([ADR-0063](./0063-honesty-framework-and-tooling-boundary.md)), do not describe this rule as
enforced until that lint ships in each repo.

## Consequences

- **Cost — the rule lives on humans until the lint ships.** A convention held by review is
  exactly the regime where the sweep already caught one recurrence. Until the regex-lint lands
  per repo, a new citation can leak into a product string between reviews; this ADR makes the
  leak a named, greppable violation, not a silent one.
- **A reader of a tool description or a `SKILL.md` loses the inline "why."** The sourcing is one
  hop away under `docs/` instead of in front of them. This is the deliberate trade: the product
  string stays installable and self-contained, and the evidence stays where it can be maintained.
- **The boundary is mechanical and auditable.** "Does this file ship as product, or document it?"
  decides every case, and the violation is a regex — which is what makes the future CI lint cheap
  to build.
- **Comments are explicitly spared**, so maintainer rationale near code is not collateral damage;
  the rule does not push ADR references out of the codebase, only out of emitted strings.

## Affected obligations / constraints

- **Refines:** [ADR-0111](./0111-kit-skill-scope.md) and [ADR-0112](./0112-two-tier-skills.md)
  (the catalog/kit split and the universality / self-containment work — this names the product
  surfaces a citation must stay off of, and the standalone-install 404 it prevents).
  **Grounded by:** the honesty model [ADR-0063](./0063-honesty-framework-and-tooling-boundary.md)
  (the rule is a convention now; its CI lint is toolable, not shipped) and the AUDIT-family Phase 3
  sweep (`wf9rvvwys`).
- **Does NOT change:** the artifact formats, the catalog/kit boundary itself, the core loop, or
  the checks contract. Accepted ADRs 0111/0112/0063 are refined here by reference, never edited
  (Nygard immutability).
