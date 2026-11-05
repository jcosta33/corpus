# Proposed Corpus shape for the pre-Corpus repository

Research record, 2026-11-04. This is the proposal that
[ADR-0187](../adrs/0187-retire-checker-mcp-website-and-setup-policy.md),
[ADR-0188](../adrs/0188-corpus-name.md), and [ADR-0189](../adrs/0189-four-artifact-authors.md)
accepted. It is built on [the study map](corpus-study-2026-11-05.md) (cited below as "map §N") and
the evidence files in [corpus-study-2026-11-05](corpus-study-2026-11-05/history.md). The skill drafts
quoted here were measured when written. Later skills supersede them:
[ADR-0190](../adrs/0190-tracker-first-and-shorter-authors.md) and
[ADR-0191](../adrs/0191-author-refinements-and-adoption-residue.md).

## Summary

- **What goes.** Everything that served the CLI, the MCP server, the website, or `suspec setup`:
  - `checks/` (the contract, its README, and 24 fixtures);
  - `policy/`;
  - four of the seven scripts, and the dispatch CI job;
  - `docs/reference/cli.md` and every `suspec check` and `suspec setup` instruction.

  One new ADR records the retirement. ADR bodies stay sealed.
- **Rename.** The GitHub repo becomes `jcosta33/corpus`. The skills become `corpus-*`. ADR files,
  ADR bodies and released history stay frozen.
- **Skills.** Seven become four, and 798 lines become 402:
  - `corpus-spec` absorbs change plan and task;
  - `corpus-audit` absorbs inventory;
  - `corpus-research` and `corpus-campaign` stay, trimmed.
- **Docs.** 38 files become 3: `method.md`, `formats.md`, `glossary.md`. `research/sources.md`
  and the ADR ledger stay.
- **Gates.** Seven scripts become three, and two CI jobs become one. `cmdCheck` goes green again.

## 1. Retirement list (goal 1)

Verdicts:
- **delete:** remove the file or section.
- **rewrite:** keep it but drop the retired content.
- **history:** leave it untouched as the record.

### 1a. Files and directories

| Path | Verdict | Reason |
| --- | --- | --- |
| `checks/checks.yaml` | delete | `checks.yaml:1-11`: "Inert… The reference consumer is suspec-cli's `suspec check`". No consumer remains. The rules it owns survive as each skill's `## Verify` and as `docs/formats.md`. |
| `checks/README.md` | delete | describes oracle data for `suspec-cli` (`checks/README.md:3-5`) |
| `checks/fixtures/` (24 files) | delete | "a fixture is evidence" (`checks/README.md:62`) only while a checker runs against it |
| `policy/agent.md` | delete | its only installer is `suspec setup` (`docs/reference/cli.md:8-10,21-23`). The owner's harness files carry the `~/.agents/AGENTS.md` owner-policy block, and none has a Suspec block (map §1). |
| `policy/agent-policy-predecessors.txt` | delete | upgrade-integrity digests for `suspec setup` (ADR-0177) |
| `scripts/lint-method-topology.sh` | delete | cross-repo topology: needs `$cli/.github/workflows/gate.yml` and `$cli/src/generated/agentPolicy.ts` (`:40-121`). Its canon-only checks guard files this proposal deletes (`checks.yaml` rows, the glossary and review-stances literals). This is the gate that makes `cmdCheck` red today. |
| `scripts/lint-product-citations.sh` | delete | scans `suspec-cli`/`suspec-mcp` READMEs (`:79-99`). Its two canon rules (no ADR/AUDIT/DOI in product READMEs; no ADR, GitHub or DOI references in skill bodies) fold into `lint-artifact-skills.sh`, which already rejects `ADR-[0-9]+` (`:222`). |
| `scripts/lint-count-ranges.sh` | delete | 114 lines, mostly family-root discovery for `suspec-cli`/`suspec-mcp` (`:42-73`). The one useful grep (no `0NNN–0NNN` ranges in root bootstrap files) folds into `lint-all.sh` as about 3 lines. |
| `scripts/test-lint-artifact-skills.sh` | delete | a mutation test of phrase pins that this proposal removes. A structural lint of about 80 lines can be reviewed by reading it. |
| `scripts/lint-artifact-skills.sh` | rewrite | keep the structural checks (manifest equals catalog equals dirs; frontmatter; 500 lines; single Markdown file; no symlinks; links stay in the package; no sibling names; type and ID-prefix ownership; `## Artifact`/`## Close`). Drop every literal-phrase pin (`:287-369`), which freezes wording, not structure (map §7.12). Add the two folded citation rules. |
| `scripts/lint-accepted-adrs.sh` | rewrite | keep the seal. Rename `SUSPEC_HISTORY_BASE` to `CORPUS_HISTORY_BASE`. Bump `EXPECTED_COUNT` and the digest in each commit that adds an ADR. |
| `scripts/lint-all.sh` | rewrite | run `lint-accepted-adrs`, `lint-artifact-skills`, and the root-range grep. Drop the `REPO_PARENT_DIR` family argument (`:16-22`). |
| `.github/workflows/method-gates.yml` | rewrite | delete the `workflow_dispatch` inputs (`:13-21`) and the whole `method-gates` job (`:48-58`), which checks out the deleted repos. The `local-gates` job becomes one step, `sh scripts/lint-all.sh`, with `CORPUS_HISTORY_BASE`. |
| `docs/reference/cli.md` | delete | the CLI contract page |
| `docs/10-integrations.md` | delete | CLI and MCP sections (`:6-23`), plus "command matches for structured `verify` blocks" (`:51-52`, dead C013). The surviving "project systems keep their owners" list (`:35-45`) moves into `docs/method.md`. |
| `docs/artifact-registry.md` | delete | three of its six rows are CLI, policy and MCP (`:6-8`). The rest is one README sentence. |
| `docs/ADOPTING.md` | delete | CLI install (`:28-49`) and policy setup (`:51-72`). The skill install and the `sus-*` cutover move to README. |
| `docs/reference/checks.md` | delete | the C001–C031 table mirrors `checks.yaml`. The **writing watchlist** (`:84-98`) moves to `docs/formats.md`. |
| `docs/reference/local-checks.md` | delete | its layer table names `suspec check` (`:20`). The one surviving rule ("hosted CI optional; local proof binds state, command, exit, output") moves to `method.md`. |
| `docs/reference/output-economy.md` | delete | the global-policy bullet is CLI-only (`:7-8`). The rest restates every skill's `## Output`. |
| `docs/reference/cheatsheet.md` | delete | restates formats; lists the dead `panel` type (`:25`) and `suspec check --contract` (`:71`) |
| `docs/tutorial/` (5 files) | delete | every step runs `suspec check` (`01:62`, `03:15`). The walk-through restates the guides. |
| `docs/examples/` (4 files) | delete | each ends in `suspec check`. One short inline example moves into `method.md`. |
| `suspec check` / `suspec setup` lines elsewhere | rewrite | README:26-35,64-71,105-106; docs/02:34; 05:58; 06:23-25; 08:40-50; glossary:29. These files are themselves merged or rewritten (§4). |

### 1b. ADRs

Recording rule: one new ADR, **ADR-0187 "Retire the checker, MCP adapter, website, and setup
policy"**. No per-ADR note.
- The ledger's own governance says amending means "publishing a new, superseding ADR; the original
  remains byte-identical and only its ledger row gains the new disposition"
  (`docs/adrs/README.md:12-14`).
- `lint-accepted-adrs.sh` digest-seals every numbered ADR body.
- So ADR-0187 carries a disposition table, each affected ledger row gains "superseded by 0187" or
  "narrowed by 0187", and the seal moves to the new count and digest in the same commit.

The classification below comes from the three `corpus-study-2026-11-05/adrs-*` reports (their per-ADR tables and
external-dependency tables) and the ADR titles. Writing ADR-0187 must re-read each body to confirm
the boundary.

| Disposition after ADR-0187 | ADRs | Why |
| --- | --- | --- |
| superseded (the whole decision is tool, contract, or setup) | 0066, 0070, 0077, 0078, 0079, 0083, 0085, 0086, 0087, 0090, 0097, 0116, 0125, 0126, 0127, 0128, 0129, 0143, 0152, 0153, 0158, 0159, 0165, 0171, 0172, 0173, 0174, 0175, 0177, 0185 | each mints or reshapes a check ID, the CLI or MCP surface, or the setup/policy installer (`_work/adrs-0061-0120.md` §4; `_work/adrs-0121-0186.md` §5) |
| narrowed (the method survives; only tool clauses die) | 0062, 0063 ("enforced" level loses its only tool), 0074 (family = corpus + skills), 0080 (spec-scoped IDs stay as a format rule), 0094, 0103, 0113, 0117, 0121, 0134, 0137, 0138, 0140 ("tools reinforce" loses its tools), 0164, 0166, 0176, 0178, 0186 | mixed decisions |
| already superseded; no change | 0084, 0106, 0107, 0130, 0135, 0136, 0139, and the starter-kit chain under 0138 | the ledger already records them |
| history (untouched) | every other ADR | — |

ADR-0187 also records what the ledger never did: `suspec-cli`, `suspec-mcp` and `suspec-website`
were deleted from GitHub on 2026-11-04 (map §6).

## 2. Rename plan (goal 2)

### 2a. Hit list by kind

Full `file:line` list: map §5b.

| Kind | Changes to | Notes |
| --- | --- | --- |
| GitHub repo | `jcosta33/suspec` → `jcosta33/corpus`; description "The Suspec framework…" → Corpus wording | `jcosta33/corpus` is today a redirect to this same repo, so the name is reclaimable. GitHub then redirects `suspec` → `corpus`. |
| Local remote | `git remote set-url origin https://github.com/jcosta33/corpus.git` | — |
| Skill dirs and `name:` | `skills/sus-*` → `skills/corpus-{spec,audit,research,campaign}` | the three merged skills simply disappear (§3) |
| Skill H1s and descriptions | `# Sus Spec` → `# Corpus Spec`; "verifiable Suspec spec" → drafts in §3 | — |
| Catalog and gates | `skills/README.md` rows; `lint-artifact-skills.sh` expected list and `writer_types`; `docs/formats.md` writer column | — |
| Install commands | `npx skills add jcosta33/corpus …` in README and `skills/README.md` | — |
| Env var | `SUSPEC_HISTORY_BASE` → `CORPUS_HISTORY_BASE` (workflow, `lint-accepted-adrs.sh`) | the other `SUSPEC_*` vars die with their scripts (§1a) |
| File names | `docs/01-what-is-suspec.md` disappears into `docs/method.md` | — |
| Prose | every surviving "Suspec" in README, AGENTS, skills, docs, `docs/research/sources.md` (21), and the ledger's front matter (`docs/adrs/README.md:3-4`) | edit by hand, file by file. No `sed` across files: the 2026-06-30 sweep corrupted ADR bodies twice (`fad0458`, `619dc4e`). |
| Cross-repo (`jcosta33/skills`, a separate commit there) | README:17-18 (cutover names), 47-49 (link); `skills/drill/SKILL.md:29` "No Suspec artifact" → "No Corpus artifact"; `scripts/lint-current.sh:375,379` patterns; `scripts/lint-released-changelog.sh:8` `SUSPEC_SKILLS_HISTORY_BASE` fallback | owned by that repo's session |

**Frozen:**
- ADR files and bodies, including the six `*-suspec-*` filenames (`0050`, `0060`, `0077`, `0085`,
  `0091`, `0092`). The seal rejects any change.
- ADR titles quoted in ledger rows (they are historical titles).
- Git history and commit messages.
- `jcosta33/skills` CHANGELOG released sections.
- Sealed ADR bodies keep the lowercase common noun "corpus" and the old `corpus-*` repo names. Any
  future grep for "corpus" will match them, which is one more reason never to sweep `docs/adrs/`.

**ADR-0188 "Corpus name"** records the full chain:
- Swarm → Corpus (`3e32399`, 2026-06-23)
- Corpus → Suspec (`367d995`, 2026-06-30, no stated reason)
- Suspec → Corpus (this change)
- the frozen surfaces above

No ADR records any of the earlier renames (map §5a).

### 2b. Order of operations

1. **Retire** (one commit on `main`, product still named Suspec):
   - apply §1a;
   - add ADR-0187 and its ledger dispositions;
   - bump the seal.

   `cmdCheck` goes green here.
2. **Rename on GitHub:** `gh repo rename corpus -R jcosta33/suspec`, update the description, then
   `git remote set-url origin https://github.com/jcosta33/corpus.git`. Redirects keep every old
   link working, so this is safe before the content lands.
3. **Rename and consolidate** (one breaking commit, `feat!:`):
   - skill dirs and drafts (§3);
   - the docs collapse (§4);
   - prose and the env var;
   - ADR-0188 and ADR-0189 (the four-author set), ledger rows, and the seal bump.

   Rename and consolidation share one commit because every skill body is rewritten anyway, so
   installers cut over once, not twice.
4. **Machine cutover** (§2c).
5. **`jcosta33/skills` pointers:** a separate commit in that repo.
6. **Rename the local checkout** `/Volumes/Development/suspec` → `/Volumes/Development/corpus`, last,
   once no other session is using it. No remaining script resolves the repo by directory name after
   §1a.

### 2c. Install cutover

On this machine:
- **Lock file:** `~/.agents/.skill-lock.json` has the seven `sus-*` entries with
  `source: jcosta33/suspec`, updated 2026-09-25.
- **Real directories:** `~/.agents/skills/sus-*`.
- **Symlinks** to them in `~/.claude/skills` (7), `~/.zcode/skills` (7), `~/.aider-desk/skills` (7),
  and `~/.kilocode/skills` (8, including a leftover `sus-panel`).
- `npx skills add` does not prune (README:23).

```bash
npx skills remove -g -a claude-code zcode aider-desk kilo sus-audit sus-campaign sus-change-plan sus-inventory sus-research sus-spec sus-task sus-panel
```

```bash
npx skills add jcosta33/corpus -g -a claude-code zcode aider-desk kilo
```

Verify:
- the lock file has exactly four `corpus-*` entries with `source: jcosta33/corpus` and no `sus-*`;
- `~/.agents/skills` and each harness dir list the four `corpus-*` and no `sus-*`.

The agent IDs come from the lock file's `lastSelectedAgents`. Confirm `kilo` against the CLI's agent
list before running.

Existing artifacts under `~/.agents/artifacts/` keep their old `type:` values. They are transient
Markdown and need no migration. The README carries the same two commands for other users.

## 3. Skill verdicts (goal 3)

Real usage on this machine (map §1): campaign 14, audit 13, research 9, task 5 (none conformant, none
names a spec), change-plan 4, inventory 2, **spec 0**.

| Skill | Lines now | Verdict | What it uniquely prevents | Reason |
| --- | --- | --- | --- | --- |
| `sus-spec` | 105 | **keep → `corpus-spec`** | implementing unresolved intent; untestable requirements | the AC block is the method's one irreducible format |
| `sus-change-plan` | 95 | **merge → `corpus-spec`** | structural change without proven preservation and rollback | a preservation guarantee is a requirement with `When: always`; Baseline, Waves and Cutover are optional spec sections. The merge removes the second artifact, `PG-NNN`, `preserves:`, and C010's sibling-`spec.md` lookup, which the flat placement never supported (map §7.5). In practice the owner writes change plans without specs. |
| `sus-task` | 121 | **merge → `corpus-spec` `## Split`** | two parallel workers colliding; an obligation dropped or duplicated in a split | the prevention is one table: requirement IDs, write paths, ordering. The packet ceremony (9 required sections, verbatim copies, status enum, Run summary) existed for the checker. All 5 real tasks ignore it. |
| `sus-audit` | 70 | **keep → `corpus-audit`** | unevidenced claims about present code; prescriptions disguised as findings | most-used present-state skill |
| `sus-inventory` | 72 | **merge → `corpus-audit`** | unevidenced current-state maps before wide change | same discipline as audit; the only difference is "grade risks or not", now one step |
| `sus-research` | 140 | **keep → `corpus-research`** | decisions on mismatched or counterfeit evidence | unique source-competence rules; trimmed by about 50 lines |
| `sus-campaign` | 195 | **keep → `corpus-campaign`** | snapshot rot, lane seizure, false enforcement claims, self-acceptance across PRs | the most-used skill; trimmed by about 55 lines |

Before → after: 7 skills / 798 lines → 4 skills / 402 lines (`wc -l` on the drafts).

| Skill | Before | After |
| --- | --- | --- |
| `corpus-spec` | 321 (spec 105 + change-plan 95 + task 121) | 113 |
| `corpus-audit` | 142 (audit 70 + inventory 72) | 61 |
| `corpus-research` | 140 | 89 |
| `corpus-campaign` | 195 | 139 |

What every draft drops:
- the duplicated "cut repetition before handoff" paragraph, which `debloat` and the owner policy
  already cover;
- the picker mechanics paragraph, now one clause;
- Enter-on-request boilerplate.

Each Artifact/Output/Close block shrinks to about 14 lines. A new convention lands: the file name is
the artifact ID (`<ID>.md`), which real usage already follows (`CAMPAIGN-…`, `AUDIT-…`, `INV-…`). It
removes the three conflicting naming examples (map §7.5).

Structural checks I ran on the drafts:
- the frontmatter rules from `lint-artifact-skills.sh:80-104` (description ≤ 1024 characters, no
  `: `, not self-naming);
- no sibling names;
- no `ADR-`, URLs, or links.

All passed. Artifact types after the change: `spec`, `audit`, `research`, `campaign`. Evidence
receipts and run notes remain untyped sidecars.

### `corpus-spec` (113 lines)

````markdown
---
name: corpus-spec
description: Write, revise, or check a verifiable change contract before implementation. Use when intent or consequential behavior must become requirements with acceptance checks, when a refactor, migration, rewrite, upgrade, or schema or performance change must preserve behavior through staged waves and rollback, or when parallel workers need a write-disjoint split. Do not use for small clear fixes, direct implementation, or factual verification.
---

# Corpus Spec

A spec is decided intent under test. Nothing else belongs.

## Method

1. Read project rules, current code, tests, related decisions, and open issues.
2. Settle discoverable facts and reversible conventions yourself. Ask the human only about
   material behavior, public contracts, security, cost, or irreversible choices: recommendation
   first, two or three real options, each with its cost.
3. If one precise sentence governs the work, state it inline with its verification. Write no file.
4. Otherwise write the spec. Any unresolved blocking choice keeps `status: draft` and blocks
   dependent work.

## Shape

```yaml
---
type: spec
id: SPEC-{{slug}}
status: draft
sources:
  - ISSUE-123
  - ../relative/source.md
---
```

`# {{title}}`, then non-empty `## Intent` and `## Requirements`. Add `## Non-goals`,
`## Open questions`, or `## Affected areas` only when they carry information.

```markdown
### AC-001 - Short name
- When: one concrete condition, or `always` for an invariant
- Then: the actor MUST do one observable thing
- Verify with: `exact command` or a named manual check
```

Use exactly those three items, in that order, and nothing else under the heading. Use exactly one
of `MUST`, `MUST NOT`, `SHOULD`, `SHOULD NOT`, or `MAY` in `Then`. Split obligations that fail
independently. Name a mechanism only when a public contract makes it observable.

## Structural change

For a refactor, migration, rewrite, upgrade, schema change, or performance change, also write:

- `## Baseline`: current structure and behavior, each with `file:line`, test, or command evidence.
  Map an unfamiliar area before planning.
- Preserved behavior as requirements with `When: always`. Verify each with a golden, differential,
  or property check that fails on drift. A green suite proves only what it executes.
- `## Waves`: the smallest ordered steps that each leave build and tests green. Give each its
  affected surfaces, verification, and rollback point.
- `## Cutover`: entry, completion, abort, and restore conditions.

Give every compatibility shim a path and a removal condition. Count old call sites across source,
tests, generated code, dynamic dispatch, and configuration; the target is zero outside named
shims. Measure performance before and after with one protocol: workload, environment, warmup,
samples, statistic, and ceiling.

## Split

Only when independent workers implement in parallel, add `## Split` with one row per slice:
requirement IDs, permitted write paths, excluded paths, `Starts after`, and `May run with`.

- Each requirement belongs to exactly one slice, unless each repository or platform verifies the
  whole obligation itself.
- Run slices in parallel only when they are write-disjoint and share no interface, schema,
  generated file, or build configuration. Unknown scope conflicts with everything.
- Sequence interface-defining work first.
- Dispatch each worker the spec path and its row.

## Verify

Before handoff, confirm:

- valid frontmatter and unique `AC-` IDs;
- a non-empty Intent;
- the exact three-item block and one strength word in every requirement;
- no `TBD`, `TODO`, `???`, or blocking question at `status: ready`;
- every local source resolves;
- every wave names verification;
- every split slice is write-disjoint, and every requirement is covered once.

In check-only mode, report exact errors without editing.

The implementer records changed files, each verification command with its exit status and
decisive output, scope drift, and blocked questions under `## Execution`. Missing output is
unverified. The implementer cannot accept their own work; a non-implementer reviews on the native
pull request.

## Artifact

Write `~/.agents/artifacts/<workspace>/<ID>.md` with `~` expanded. `<workspace>` is the repository
or working-directory basename. Put sidecars, such as evidence receipts and run notes, beside it and
link them. Never overwrite; on a collision, ask for a name. If the directory is unwritable, offer
grant and retry, another user directory, or cancel. Never fall back to the repository, a vendor
directory, or a temporary path. Write local source references relative to the artifact; hand off
absolute paths.

## Output

Return only clickable links to the artifact and its sidecars, labelled `~/.agents/...`, with
absolute destinations. Explain only a blocker, a failed write, incomplete verification, or an
irreversible-action confirmation.

## Close

When no downstream step needs the set, ask the human once: Delete, Leave, or Promote into
project-owned records. After Delete, confirm every path is gone; a survivor blocks close.
````

### `corpus-audit` (61 lines)

````markdown
---
name: corpus-audit
description: Map or assess present code from direct evidence. Use for a current-state map before wide change, debt surveys, cleanup or quality assessments, single-implementation benchmarks, or fresh passes over prior audits. Do not use for conformance review against a spec, tracing one narrow path, adversarial review, or option research.
---

# Corpus Audit

Observe. Prove. Prescribe nothing.

## Method

1. Lock the goal, surface, and exclusions. Ask the human when scope is materially ambiguous:
   recommendation first, two or three real options, each with its cost.
2. Freeze the repository state and record its commit or tree ID.
3. Map what exists:
   - modules and their observed responsibilities;
   - interfaces, with direct and dynamic callers;
   - externally visible behavior;
   - data, state, side effects, configuration, generated surfaces, and external consumers;
   - tests, and the behavior each one actually controls.
4. Assess only when asked. State each risk as evidence, failure mode, firing condition, and blast
   radius. Grade it Blocker, Major, or Minor by impact and reach.
5. List unknowns, with the search boundary and the missing evidence.

Anchor every claim to `file:line`, a search result, or pasted output. A negative claim, such as
zero callers or no match, needs the whole-scope command and its result. Dynamic behavior, such as
timing, concurrency, cleanup, or lifecycle, needs a run; static reading cannot prove it. Re-derive
current state before reading a prior audit, and recheck every citation you keep. With no supported
risk, write `None observed in scope`. Strip fixes, target states, and requirements.

## Shape

```yaml
---
type: audit
id: AUDIT-{{slug}}
---
```

Use the sections `## Scope` (with the frozen state), `## Map`, `## Risks` (only when assessed), and
`## Unknowns`.

## Artifact

Write `~/.agents/artifacts/<workspace>/<ID>.md` with `~` expanded. `<workspace>` is the repository
or working-directory basename. Put sidecars, such as evidence receipts and run notes, beside it and
link them. Never overwrite; on a collision, ask for a name. If the directory is unwritable, offer
grant and retry, another user directory, or cancel. Never fall back to the repository, a vendor
directory, or a temporary path. Write local source references relative to the artifact; hand off
absolute paths.

## Output

Return only clickable links to the artifact and its sidecars, labelled `~/.agents/...`, with
absolute destinations. Explain only a blocker, a failed write, incomplete verification, or an
irreversible-action confirmation.

## Close

When no downstream step needs the set, ask the human once: Delete, Leave, or Promote into
project-owned records. After Delete, confirm every path is gone; a survivor blocks close.
````

### `corpus-research` (89 lines)

````markdown
---
name: corpus-research
description: Research a decision until evidence can carry it. Use when comparing options, evaluating APIs, libraries, or products, sizing markets, mapping competitors, studying customers or reviews, inspecting UX, or testing positioning. Do not use for checking one settled claim, assessing present code, or writing requirements.
---

# Corpus Research

One question. Fit evidence. No counterfeit certainty.

## Method

Lock the decision, segment, scope, horizon, and the evidence that would reverse the answer. Map the
options and the counter-evidence before chasing the first attractive answer. Ask the human only when
scope is materially ambiguous: recommendation first, two or three real options, each with its cost.

Match each claim to a competent source:

| Claim | Strong evidence | Common mismatch |
| --- | --- | --- |
| Standard or contract | Current specification | Tutorial paraphrase |
| API support | Versioned docs, source, executable contract | Another version's review |
| Product behavior | Safe recorded exercise | Marketing copy |
| Comparative performance | Matched benchmark with method, data, and variance | Undisclosed vendor workload |
| Causal effect | Design controlling alternatives, with uncertainty | Before/after correlation |
| Prevalence | Disclosed sampling frame and denominator | Collected examples |
| Actor intent | Contemporaneous first-party record | Later inference |
| User experience | Sampled, disclosed research | One anecdote |

For every load-bearing source, record provenance, date, version, method, population, sample size,
conflicts of interest, and whether it reports observation or inference. Downgrade for confounding,
selective reporting, indirectness, staleness, imprecision, undisclosed method, or unresolved
contradiction. Upgrade only for a stronger design or independent replication. Say why.

For market, customer, and competitor work, fix the segment, geography, and horizon. Pricing proves
price, marketing proves positioning, and sampled reviews prove only sampled experience. Claims such
as `most`, `common`, or `users expect` need a searched population, a denominator, and contrary
cases. Synthetic respondents generate hypotheses only; label them and name the real-data check. A
market size shows formulas, units, dated sources, assumptions, sensitivity, and separate TAM, SAM,
and SOM.

Exercise current product behavior when that is lawful, safe, and affordable. Record version,
account, region, date, action, and untouched output. Mark unreachable claims `[unconfirmed]`. Reject
a source only for a named defect, never by venue alone.

Rate confidence:

- `High`: direct, recent, segment-matched, and independently triangulated.
- `Moderate`: direct but partial.
- `Low`: indirect, stale, small-sample, single-source, marketing, or synthetic.
- `Very low`: assumption-heavy.

Name every downgrade.

## Shape

```yaml
---
type: research
id: RESEARCH-{{slug}}
---
```

Use only the sections that carry payload: Question and scope, Method and coverage, Findings,
Options, Open questions, and Recommendation.

Give each finding a stable `R-NNN`, one claim, its exact evidence, a confidence, and its decision
relevance. Keep observation, source claim, inference, and recommendation separate. Tie the
recommendation to finding IDs. When the evidence cannot support a direction, name the test that
would. The decision stays human.

## Artifact

Write `~/.agents/artifacts/<workspace>/<ID>.md` with `~` expanded. `<workspace>` is the repository
or working-directory basename. Put sidecars, such as evidence receipts and run notes, beside it and
link them. Never overwrite; on a collision, ask for a name. If the directory is unwritable, offer
grant and retry, another user directory, or cancel. Never fall back to the repository, a vendor
directory, or a temporary path. Write local source references relative to the artifact; hand off
absolute paths.

## Output

Return only clickable links to the artifact and its sidecars, labelled `~/.agents/...`, with
absolute destinations. Explain only a blocker, a failed write, incomplete verification, or an
irreversible-action confirmation.

## Close

When no downstream step needs the set, ask the human once: Delete, Leave, or Promote into
project-owned records. After Delete, confirm every path is gone; a survivor blocks close.
````

### `corpus-campaign` (139 lines)

````markdown
---
name: corpus-campaign
description: Write or revise a restartable goal contract for one delivery campaign that spans several pull requests. Use when one durable objective needs dependency-aware, write-disjoint streams, a project-native progress ledger, and named delivery authorities. Do not use when the goal fits one pull request or only a plan is wanted.
---

# Corpus Campaign

Snapshots rot. Goals survive.

## Method

Read project governance, governing requirements, dependency state, delivery commands, branch
protection, release constraints, worktrees, and the live tracker. Lock one objective and one
verifiable stopping condition. Reject unrelated backlog.

Pick one project-native issue, epic, or equivalent ledger. It owns work items, dependencies,
assignments, pull requests, and status. The campaign points to it and never copies its mutable
state. Keep the ledger self-contained: no transient artifact names, paths, or links.

### Authority

For each operation the campaign uses (lane allocation, verification, heavyweight execution,
publication, review, merge, cleanup), record the owner, strength, mechanism, and failure behavior in
the ledger:

- **Advisory:** instructions coordinate willing agents. Claim no rejection.
- **Deterministic local:** a project command rejects an invalid transition.
- **Isolated authority:** workers cannot reach the protected state, resource, or credential.

A claim that a worker cannot bypass a boundary requires isolation. Missing authority blocks only the
operations that depend on it; independent work continues. A trusted owner may bootstrap a missing
control while its guarded transition stays blocked. Hosted status checks are optional;
project-approved local proof is valid.

### Lanes

Inspect `git worktree list`, the branches, and tracked and untracked state. Classify every lane by
path, branch, owner, and state. Never seize an active or unknown lane, and force-clean nothing.

- Keep one branch and one implementation owner per lane.
- Reuse only a clean, released lane.
- Size parallelism from proven independent work, machine limits, verification cost, and reviewer
  capacity.
- Implementing on `main` needs named project or owner authority.

### Dispatch

Dispatch only work that is dependency-ready and write-disjoint. Sequence shared contracts, generated
surfaces, unknown scope, and overlapping files.

Give each owner the objective, ledger, repository, lane, branch, scope, exclusions, dependencies,
acceptance checks, and pull-request policy. Require back only status, changed paths, branch, pull
request, head, decisive checks, and blockers.

The implementation owner edits, tests, commits, pushes, and repairs review findings. The orchestrator
coordinates and verifies; it never hijacks another owner's branch.

Choose the cheapest adequate model tier:

- economy only for bounded mechanical work with a decisive oracle;
- standard for contained work;
- strongest for architecture, security, migrations, cross-repository judgment, or unresolved
  ambiguity.

Escalate a blocked or disputed step, then return to the cheaper tier.

### Delivery

Define the strongest observable check before changing behavior, and reproduce a bug before fixing it.
Trust a regression test only when it fails on the defect and passes on the repair.

Keep one reviewable concern per pull request, and merge in dependency order. Follow repository
conventions; without them, use an imperative title, Summary, and Verification. Mark a pull request
ready only after required checks pass.

Review with the smallest set of fresh reviewers that covers the material risks. Give each reviewer
the head, diff, requirements, and one risk. Publish only verified, actionable defects as line or
file comments, each stating defect, consequence, and required outcome. The implementation owner
cannot accept its own work; a distinct reviewer validates each repair.

Before merge, reconcile governing artifacts, head, base, proof, and review state, and bind the merge
to the expected head. Drift resets the affected checks and review. Delete only campaign-owned merged
branches and campaign-created worktrees.

Humans own intent, material decisions, waivers, irreversible authority, and acceptance. They may
delegate execution to a named orchestrator or project mechanism. Ask them for those choices:
recommendation first, two or three real options, each with its cost. Keep the campaign `draft` until
every blocking choice is resolved.

## Shape

```yaml
---
type: campaign
id: CAMPAIGN-{{slug}}
status: draft
ledger: {{project-native-url}}
sources:
  - {{governing-artifact-or-url}}
---
```

Write each of these sections exactly once: `## Objective`, `## Completion contract`,
`## Authorities`, `## Operating loop`, and `## Stops`. Add `## Constraints`, `## Non-goals`, or
`## Workstreams` only when they carry information. Workstreams may name stable ledger IDs only.

The operating loop runs on every pickup:

1. Read the campaign and every authority.
2. Reconcile repository, ledger, pull-request, worktree, and verification state from live evidence.
   Repair ledger drift before trusting its status.
3. Select the highest-priority dependency-ready work that fits current capacity.
4. Execute it through project implementation, verification, review, and merge gates.
5. Record progress in the ledger.
6. Repeat until the completion contract passes or a named human decision blocks progress.

Keep checkboxes, counts, SHAs, lane occupancy, pull-request snapshots, and session diaries out of the
campaign. Use `status: ready` only when every authority is reachable from the execution environment
and every operation names an owner, strength, mechanism, and failure behavior.

## Artifact

Write `~/.agents/artifacts/<workspace>/<ID>.md` with `~` expanded. `<workspace>` is the repository
or working-directory basename. Put sidecars, such as evidence receipts and run notes, beside it and
link them. Never overwrite; on a collision, ask for a name. If the directory is unwritable, offer
grant and retry, another user directory, or cancel. Never fall back to the repository, a vendor
directory, or a temporary path. Write local source references relative to the artifact; hand off
absolute paths.

## Output

Return only clickable links to the artifact and its sidecars, labelled `~/.agents/...`, with
absolute destinations. Explain only a blocker, a failed write, incomplete verification, or an
irreversible-action confirmation.

## Close

When no downstream step needs the set, ask the human once: Delete, Leave, or Promote into
project-owned records. After Delete, confirm every path is gone; a survivor blocks close.
````

## 4. Repo shape after the change

```text
corpus/
├── README.md                 what Corpus is, the four skills, install and cutover, when to use none
├── AGENTS.md                 repo rules; CLAUDE.md and GEMINI.md stay symlinks
├── LICENSE
├── .gitignore
├── .github/workflows/method-gates.yml   one job: sh scripts/lint-all.sh
├── scripts/
│   ├── lint-all.sh           cmdCheck: seal + skill gate + root ADR-range grep
│   ├── lint-accepted-adrs.sh ADR immutability seal
│   └── lint-artifact-skills.sh structural skill gate (about 80 lines)
├── skills/
│   ├── README.md             catalog (4 rows) and edit contract
│   ├── sources.md            design evidence for the skills
│   ├── corpus-spec/SKILL.md
│   ├── corpus-audit/SKILL.md
│   ├── corpus-research/SKILL.md
│   └── corpus-campaign/SKILL.md
└── docs/
    ├── method.md             the method on one page
    ├── formats.md            the four artifact shapes, sidecars, writing watchlist
    ├── glossary.md           surviving terms only
    ├── research/sources.md   bibliography that ADR and doc citations resolve to
    └── adrs/                 ledger README.md, 184 sealed ADRs, 0187–0189
```

| Piece | Purpose | Built from |
| --- | --- | --- |
| `docs/method.md` | proportional rigor (the signal table), roles and separation, independent review and judgments, human decision, evidence and receipts, artifact location and close, durable-value routing, "project systems keep their owners", principles | `docs/01`, `02`, `03`, `07`, `08`, `09`; `reference/{principles,rigor-escalation,distillation,memory,agent-guides,local-checks}` |
| `docs/formats.md` | frontmatter and sections for spec, audit, research and campaign; AC block; sidecars; reference rules; writing watchlist | `reference/artifact-formats.md`, `reference/checks.md:84-98` |
| `docs/glossary.md` | terms that survive. Universal methods get one row pointing to `jcosta33/skills`. | `reference/glossary.md` |
| `skills/sources.md` | evidence for skill design rules; remove sources whose rules left with the merged skills | as today |
| `docs/research/sources.md` | **leave** (rename prose; fix the nonexistent "Claims need sources" principle at `:3,638`). ADR bodies link into it; pruning would break sealed links. | as today |

Other pieces that no longer earn their place:

| Piece | Verdict | Reason |
| --- | --- | --- |
| `docs/04`, `05`, `06` (specs, brownfield, tasks guides) | delete | `corpus-spec` and `formats.md` carry the rules |
| `docs/README.md` (index) | delete | three docs files need no index; README links them |
| `docs/reference/review-stances.md` | delete | Revolver and Triple-check procedures live in `jcosta33/skills` (it already deep-links there, `:38,48`) |
| `docs/reference/{drift,lineage,source-authority}.md` | delete | drift and lineage restate `method.md`; source authority restates `corpus-research` |
| `AGENTS.md` authority lines for `checks/`, `policy/`, `docs/reference/checks.md` | rewrite | they point at deleted files (`AGENTS.md:10-16`) |
| `AGENTS.md` "seven" artifact types (`:26-27`) | rewrite | four types plus untyped sidecars |
| `test-lint-artifact-skills.sh` | delete | see §1a |

Docs footprint: 38 files outside `adrs/` and `research/` become 3.

## 5. Open decisions (product identity)

1. **What Corpus claims to be once the checker is gone.** `README.md:95` says "Its distinct mechanism
   is deterministic reconciliation keyed to requirement IDs." That mechanism leaves with the CLI.
   - **(a) Recommended:** "Four standalone skills that write durable, evidence-bound working
     artifacts for agent work, with humans on decisions and acceptance." Claim review separation and
     evidence discipline, not determinism.
   - (b) Spec-driven framing: keep the spec as the center and the others as support. Real usage has
     0 specs against 14 campaigns, so this would misdescribe how Corpus is used.
   - (c) Keep a deterministic claim by shipping a small in-repo checker. This re-adds the machinery
     goal 3 removes.
2. **Does the global agent policy stay part of the product?**
   - **(a) Recommended:** drop it. You already maintain `~/.agents/AGENTS.md` and mirror it to every
     harness; `policy/agent.md` is a stale subset (it lacks ADR-0133's examine-don't-ruminate rule
     and ADR-0142's memory routing).
   - (b) Keep it as a copy-paste snippet in `method.md` with no installer.
3. **One repo or two.**
   - **(a) Recommended:** keep the ADR-0186 split. `jcosta33/corpus` holds the artifact authors;
     `jcosta33/skills` holds the universal methods.
   - (b) Merge the methods back. That doubles the catalog to install and couples twelve
     framework-free skills to the Corpus name.
4. **ADR history.**
   - **(a) Recommended:** keep all 184 sealed ADRs in place. They are cheap, and they are the only
     record of why.
   - (b) Archive pre-0137 ADRs behind a tag and start a short ledger. Corpus would then present a
     smaller history, but every back-link from the remaining ADRs would break.

Engineering calls I made rather than ask:
- merge three skills into one, and inventory into audit;
- file name = artifact ID;
- one retirement ADR, not per-ADR notes;
- delete the mutation test;
- keep `docs/research/sources.md` whole;
- rename and consolidation in one breaking commit.

## 6. Later (park until the shape is settled)

- **Ledger and file disagree.** 17+ ADR files' status lines disagree with the ledger: 0032, 0045,
  0048–0052, 0058, 0060, 0067, 0069, 0073–0075, 0100, 0104, 0114 (`corpus-study-2026-11-05/adrs-*` §2).
- **Missing back-references.** About 40 ledger rows lack "narrowed by" entries; the 0157 row claims
  links its file never makes ([adrs-0121-0186.md](corpus-study-2026-11-05/adrs-0121-0186.md) §2.2-2.3).
- **Wrong "upheld" labels.** The ledger calls C012, C013 and C016 "upheld" while `checks.yaml`
  reserves them. This becomes moot with §1a.
- **Accepted ADRs dead without supersession** that are not CLI-related: 0031, 0034–0039, 0071, 0082,
  0089, 0108, 0124, 0131.
- **Unrepaired rename corruption:** `0033:60`, `0066:50`, `0097:68`, and the ledger at
  `README.md:67,240`.
- **Edited "immutable" bodies.** About 50 ADR bodies carry addenda despite the rule; the seal
  freezes them as they are.
- **Contradictions the merge removes or must restate:**
  - `## Execution` is absent from `sus-spec`;
  - inventory section names disagree between the skill and formats;
  - `checks/README.md:21` reserved list;
  - `panel` in `checks/README.md:53` and the cheatsheet;
  - dead C013 verify fences in docs/08 and docs/10.
- **Skills-repo tensions:** see the sibling map §3. Examples: `drill` vs ADR-0184; picker copies vs
  ADR-0157.
