# Study map of the pre-Corpus repository (`jcosta33/suspec`)

Research record, 2026-11-04. A read-only study of the repository at `main` = `d3f14fb` (2026-08-26),
before it became Corpus. It is the evidence behind
[ADR-0187](../adrs/0187-retire-checker-mcp-website-and-setup-policy.md),
[ADR-0188](../adrs/0188-corpus-name.md), and [ADR-0189](../adrs/0189-four-artifact-authors.md). The
proposal it fed is [the shape proposal](corpus-shape-2026-11-05.md). Paths and line numbers describe
`d3f14fb`, not the current tree. Evidence files that back this map in more detail:

- [history.md](corpus-study-2026-11-05/history.md): era and rename reconstruction from git.
- [adrs-0001-0060.md](corpus-study-2026-11-05/adrs-0001-0060.md),
  [adrs-0061-0120.md](corpus-study-2026-11-05/adrs-0061-0120.md), and
  [adrs-0121-0186.md](corpus-study-2026-11-05/adrs-0121-0186.md): per-ADR tables, status mismatches,
  concept fates, external-repo dependency, and name evidence.

`path:line` cites are repo-relative unless prefixed. The sibling map of `jcosta33/skills` stays
with that repository.

## 0. Verification failures first

- `sh scripts/lint-all.sh` (the repo's `cmdCheck`, `AGENTS.md:46`) **fails today**. Five gates
  pass; the sixth reports:

  ```
  Suspec repository suspec-cli not found under /Volumes/Development
    ^ lint-method-topology FAILED
  ```

  `scripts/lint-method-topology.sh:25-26` requires sibling checkouts whose `package.json` names are
  `suspec-cli` and `suspec-mcp`. Those repos no longer exist (see §5).
- CI's push/PR job (`.github/workflows/method-gates.yml:27-46`) skips that gate, so CI on `main` can be
  green while `cmdCheck` is red. The `workflow_dispatch` job (`method-gates.yml:48-58`) checks out
  `jcosta33/suspec-mcp` and `jcosta33/suspec-cli`. Both now return 404 (`gh api repos/jcosta33/suspec-cli`
  → `Not Found (HTTP 404)`), so that job cannot pass.

## 1. Architecture overview

The repo is a **canon**: method prose, a machine checks contract, an ADR ledger, and the seven
artifact-author skills. It holds no runtime. `AGENTS.md:3-5` states it: "Canon lives here. Runtime does
not… Sibling repositories own the CLI and the MCP adapter."

| Part | Path | Role | Who consumes it |
| --- | --- | --- | --- |
| Product entry | `README.md` | pitch, install (`npx skills add jcosta33/suspec`), CLI pointer, repository table | humans |
| Agent rules | `AGENTS.md`; `CLAUDE.md` and `GEMINI.md` are symlinks to it | authority map, writing rules, layout, `cmdCheck` | agents editing this repo |
| Artifact authors | `skills/sus-*/SKILL.md` (7), `skills/README.md`, `skills/sources.md` | executable procedures, one per artifact type | installed via `npx skills` (on this machine, `~/.agents/.skill-lock.json` has all 7 from `jcosta33/suspec`, installed 2026-09-25) |
| Human method | `docs/01…10-*.md`, `docs/ADOPTING.md`, `docs/README.md`, `docs/artifact-registry.md` | guides | humans |
| Reference | `docs/reference/*.md` (16) | formats, checks, glossary, principles, review stances, etc. | humans, skills by restatement |
| Tutorial and examples | `docs/tutorial/` (5), `docs/examples/` (4) | worked runs | humans |
| Evidence | `docs/research/sources.md` (118 KB, 190 anchors) | bibliography for `[[KEY]]` citations | docs, ADRs |
| Decisions | `docs/adrs/` (184 numbered ADRs, 0011/0012 vacant, plus the 250-line `README.md` ledger) | decision history | humans |
| Machine contract | `checks/checks.yaml` (v0.27.0), `checks/README.md`, `checks/fixtures/` | deterministic check IDs, packet schemas, oracle data | **only** `suspec-cli`, now deleted (`checks.yaml:1-11`: "Inert: nothing in this repository runs it… The reference consumer is suspec-cli's `suspec check`") |
| Global agent policy | `policy/agent.md`, `policy/agent-policy-predecessors.txt` | interaction rules installed by `suspec setup` | **only** `suspec-cli`. The owner's harness files carry `~/.agents/AGENTS.md`'s owner-policy block instead; none carries a Suspec block (grep of `~/.claude/CLAUDE.md`, `~/.codex/AGENTS.md`, `~/.config/opencode/AGENTS.md`, `~/.gemini/GEMINI.md`: 0 hits) |
| Gates | `scripts/*.sh` (7), `.github/workflows/method-gates.yml` | documentation and skill hygiene | CI, `cmdCheck` |

The method in one line (`README.md:73-83`, `docs/02-basic-workflow.md:24-37`): state intent inline
when it fits one sentence; escalate to a spec, task, inventory, change plan, or campaign only when
the work earns it; implement from an absolute artifact path; a non-implementer reviews on the native
PR; optionally run `suspec check`; route durable lessons to native memory or project records; close
the transient artifact set with Delete, Leave, or Promote.

Artifacts live outside repositories at `~/.agents/artifacts/<workspace>/`
(`docs/03-where-files-live.md:5-13`).

Real usage on this machine (frontmatter `type:` within the first 12 lines, depth ≤ 3 under
`~/.agents/artifacts`): campaign 14, audit 13, research 9, task 5, change-plan 4, inventory 2,
**spec 0**, plus 1 retired `panel`. None of the 5 tasks conforms to the contract: their statuses
are `published-awaiting-fresh-review-and-ci`, `prepared` and `ready-for-review`, all outside
`checks.yaml:128`'s enum, and none names a source spec.

## 2. Era timeline

Detail and commit lists: [history.md](corpus-study-2026-11-05/history.md) §1.

| # | Era | Dates | Defining commits / ADRs | What the tree held |
| --- | --- | --- | --- | --- |
| 0 | Swarm scaffold and personas | 05-05 → 05-31 | `144e8b6` (first commit, "upd", 238 "Swarm" hits, `swarm-spec.md`) | `scaffold/`, 13 `docs/personas/the-*.md`, `write-*` skills |
| 1 | Swarm kernel (compiler, SOL, APS, nine passes) | 05-31 → 06-07 | `f894110`, kernel ADRs 0027–0041 (`30f2a52`) | `kernel/.agents/{language,passes,profiles,conformance}`, `docs/{language,model,passes}` |
| 2 | Spec-repo pivot | 06-07 | ADR-0050/0051/0053/0054 (`03c2266`, `b292f1f`, `5779543`) | `kernel/`→`install/`→`starter-kit/`, compiler vocabulary dropped |
| 3 | Practical-first repositioning | 06-11 | ADR-0057–0068 (`10c238b`, 303 files, the largest commit) | kernel docs deleted; kit = `starter-kit/{agent,advanced,templates,…}` |
| 4 | Workspace-shaped starter kit | 06-12 | ADR-0069–0073 | `conformance/`→`checks/` (`77e6bb0`), `evals/` deleted |
| 5 | Repo-family split | 06-13 → 06-21 | ADR-0074/0075 (`17b96ed`, `e957b6a`), CLI ADR-0077, MCP ADR-0085, agents ADR-0092 | starter kit, skills catalog, producer workspace (`-hq`, later `-works`) move to sibling repos |
| 6 | Corpus name | 06-23 → 06-30 | `3e32399`, `e9ed49b`, `d182340` | `scripts/` (`58d973c`) and CI (`a051bf3`) appear 06-27 |
| 7 | Suspec v1 and integrity repair | 06-30 → 07-05 | `367d995`, `3c69191`, `fad0458` | same layout |
| 8 | Personal harness; starter kit retired in canon | 07-09 | ADR-0137 (`2ecfefa`), ADR-0138 (`c6d16ee`), ADR-0139 | the kit had already left the repo at `e957b6a` (06-13) |
| 9 | Skills are the product (v3) | 07-10 → 07-18 | ADR-0140–0143 (`1cd468c`), ADR-0149–0153 (`be42e20`, which introduces `sus-*`), ADR-0164 (`1a4a0e2`, SOL retired) | `.agents/` mirrors deleted; repo has no skills |
| 10 | Global agent policy and native delivery | 08-08 → 08-26 | ADR-0171/0172 (`0bc15b8`, adds `policy/`) through ADR-0185 (`b14abb6`) | setup targets, campaign authority, single-file skills, native review (review packet dropped, `b5a0a46`) |
| 11 | Artifact authors return | 08-26 | ADR-0186 (`d3f14fb`) | `skills/` returns with 7 `sus-*`; universal methods go to `jcosta33/skills`; panel becomes chat-only |

Retirements of note:
- **Starter kit:** left the repo at ADR-0075 (`e957b6a`, 06-13); retired as a product by ADR-0138.
- **Review packet** (`type: review`): deleted at ADR-0184 (`b5a0a46`); now a blocking unknown type
  (`checks/fixtures/violations.md:60`).
- **SOL:** retired by ADR-0164.
- **Panel artifact:** retired by ADR-0186.

## 3. Concept inventory

### 3a. Live concepts (current canon)

| Concept | Meaning | Defined | Used |
| --- | --- | --- | --- |
| Artifact types: spec, task, inventory, change-plan, audit, research, campaign | the seven Suspec artifacts, one writer each | `docs/reference/artifact-formats.md:18-31`; `checks/checks.yaml:25-29` (checked: spec, task, change-plan, campaign; recognized-unchecked: inventory, audit, research) | `AGENTS.md:26-27`, every skill, `scripts/lint-artifact-skills.sh:337`, `lint-method-topology.sh:132-138` |
| ID prefixes `SPEC- TASK- INV- CHANGE- AUDIT- RESEARCH- CAMPAIGN-` | one prefix per type | `artifact-formats.md:22-28` | skills' frontmatter blocks; `lint-artifact-skills.sh:337` |
| Requirement / AC block | `### AC-NNN` + one `When`, one `Then` with exactly one binding word, one `Verify with`, in order | `artifact-formats.md:58-66`; `checks.yaml:56-61`; C004/C028 | `sus-spec/SKILL.md:67-75`, docs/04, cheatsheet, all fixtures |
| Spec status `draft` / `ready` | `ready` = no blocking decision; only `ready` dispatches or reviews | `checks.yaml:66`; `artifact-formats.md:52-56` | sus-spec, sus-task, docs/04, docs/06 |
| Task status `ready / running / review-ready / closed` | packet lifecycle; evidence required from `review-ready` | `checks.yaml:128`; `artifact-formats.md:106-111` | sus-task, C023/C024 |
| Task required sections | Source, Scope, Do not change, Affected areas, Verify, Agent instructions, Run order, Findings, Run summary | `checks.yaml:131-140` | `sus-task/SKILL.md:80-103`; plus `## Preservation scope`, which the skill adds (`sus-task:88`) and the contract never names |
| `## Execution` | changed files, verify output, scope drift, and blockers recorded on the spec when the work is not split | `artifact-formats.md:68-70` | `docs/02:30-31`, `docs/06:5-6`, `docs/07:70`, tutorial 02, examples. **`sus-spec` never mentions it.** |
| Preservation guarantee `PG-NNN`; `preserves:` | plan-local preserved behavior; or `SPEC-id#AC-NNN` | `sus-change-plan:52-66`; `checks.yaml:89` (C010) | docs/05, fixtures/transformation |
| Evidence receipt (`E-NNN`), run note | untyped sidecars | `artifact-formats.md:113-139` | docs/08:33-35, output-economy.md:29-31 |
| Artifact location `~/.agents/artifacts/<workspace>/` | agent-neutral, outside repos; collision means ask; blocked write offers grant, another directory, or cancel | `docs/03-where-files-live.md:5-33` | every skill's `## Artifact`; `lint-artifact-skills.sh:244-253` |
| Disposition: Delete / Leave / Promote | one human close choice for the whole transient set | `docs/03:51-63` | every skill's `## Close`; tutorial 04; lint `:257-259` |
| Proportional rigor / escalation | least structure that changes execution or review | `docs/reference/rigor-escalation.md:3-22`; `docs/01:22-34` | README:37-48, cheatsheet:11 |
| "Key" and "Scaffold" | keys = intent, review, findings on every change; scaffold = everything earned | `docs/reference/glossary.md:6-7` | `docs/01:31`. ADR-0144 origin. |
| Independent review | a non-implementer judges on the native PR; the implementer cannot accept | `docs/08:3-9`; glossary:20 | README:46-48, 96-97; docs/02, 07; sus-task:105-107; sus-campaign:96-97 |
| Review judgments Supported / Unsupported / Unverified / Blocked | per-requirement verdict | `docs/08:16-23` | cheatsheet:43-50 |
| Human decision Accept / Request changes / Defer / Accept with named risk | after assessment | `docs/08:52-64` | — |
| Delivery control strength: advisory / deterministic local / isolated authority | honest enforcement class | `AGENTS.md:24-25`; `sus-campaign:24-36`; `docs/07:56-58`; `principles.md:12-13` | `lint-artifact-skills.sh:292-302` pins the wording |
| Campaign: ledger, Authorities, Operating loop, Stops, completion contract | restartable multi-PR goal; mutable state lives in one project-native ledger | `sus-campaign:122-181`; `artifact-formats.md:191-227`; C029–C031 | docs/07:45-66, docs/10:47-49, glossary:17,32-33 |
| Worktree lane | one worktree, one branch, one owner | `glossary.md:33`; `sus-campaign:38-46` | docs/07:31-43 |
| Honesty levels convention / checklist / toolable / enforced | how strongly a rule binds | `docs/reference/checks.md:10-19` (ADR-0063) | ADR prose; `.../cross-folder-source/EXPECTED.md:37` |
| Command slots `cmd*`; `AGENTS.md > Commands` | advisory adapter names | `checks.yaml:216-236` | `AGENTS.md:46` |
| Placeholder namespaces `cmd`, `project:`, `<vendor>:` | ownership of `{{…}}` prefixes | `checks.yaml:238-251` | — |
| Core checks C001–C031 (active: 001-004, 007-011, 015, 019, 021-025, 028-031) | deterministic structure checks | `checks.yaml:81-111`; `docs/reference/checks.md:44-69` | docs/04:51-52 cite C007 and C021 by ID |
| Writing watchlist | vague-word families | `docs/reference/checks.md:84-98` | — (not in sus-spec) |
| Findings (not an artifact) | lesson candidates; ephemeral or routed to memory or a project channel | `artifact-formats.md:141-148`; `docs/09` | distillation.md, memory.md |
| Distillation, drift, lineage, source authority, local checks, output economy | single-page principles | `docs/reference/{distillation,drift,lineage,source-authority,local-checks,output-economy}.md` | cross-linked only |
| Universal methods (Revolver, Triple-check, Bulletproof, Demolition, Settle, Panel, drill, remember, promote, debloat, ask-user, dissect) | live in `jcosta33/skills` | `docs/reference/review-stances.md`, `agent-guides.md`, `glossary.md:13,18-20,27,30-31`, `memory.md:19-21`, `output-economy.md:9-10` | `docs/01:14-15`, `docs/02:5-6`, rigor-escalation:8,14-15 |
| Six-step sequence | `intent -> spec -> implement -> review -> check -> findings` | `docs/01:33-34`, `docs/02:25`, cheatsheet:8 | ADR-0057's six steps were a different sequence (Pull→Spec→Task→Run→Review→Close); see `_work/adrs-0001-0060.md` §3 |

### 3b. Duplicates, overlaps, drifted terms

- **Inventory vs audit.** Both are present-state, evidence-anchored, prescription-free. Inventory maps
  (`sus-inventory:8,19-29`); audit grades risk (`sus-audit:8,22-23`). Their bodies share about 60% of
  their text (placement, output, close, picker), and the method steps overlap (freeze scope, trace,
  anchor to `file:line`, expose unknowns).
- **Inventory sections disagree.** `artifact-formats.md:154-161` lists Scope, Observed structure,
  Interfaces, Tests, Unknowns, Observed constraints. `sus-inventory:19-29` prescribes modules,
  interfaces, behavior, data/state, tests, unknowns, and declares no section names.
- **Task vs campaign dispatch.** Both define write-disjoint parallel dispatch: `sus-task:44-48` and
  `sus-campaign:48-58,110-111`.
- **Task vs `## Execution`.** The same run record has two homes (`artifact-formats.md:68-70`).
- **Spec vs change plan.** A preservation guarantee is a requirement with `When: always`; the plan
  must reference a spec (`docs/05:42-56`), yet real usage has 4 change plans and 0 specs.
- **"Six-step"** is reused with a new meaning. Detail: [adrs-0001-0060.md](corpus-study-2026-11-05/adrs-0001-0060.md) §3.
- **Boilerplate copied seven times.** Placement, Output, Close and the picker paragraph are near
  verbatim in all seven skills, by design (standalone rule, `skills/README.md:39-40`). This is about
  20–25 lines per skill.
- **Campaign rules duplicated.** `docs/07:45-66` restates the campaign skill in prose, and
  `artifact-formats.md:191-227` restates it again.
- **"Check" means three things:** the CLI checker, the writing watchlist, and each skill's
  `## Verify` (`sus-spec:80-91` performs C001–C028 by hand).

### 3c. Dead concepts that still have live references

| Dead concept | Retired by | Live reference |
| --- | --- | --- |
| `panel` artifact type | ADR-0186; `d3f14fb` body: "the reference pages drop it in the same change" | `checks/README.md:53` (closed values list `panel`); `docs/reference/cheatsheet.md:25` |
| Structured `verify` fence / command-match check (C013) | C013 RESERVED (`checks.yaml:92`) | `docs/08-reviewing-output.md:37-38`; `docs/10-integrations.md:51-52` ("command matches for structured `verify` blocks") |
| `suspec check --contract` | no current doc defines it | `docs/reference/cheatsheet.md:71` |
| Deterministic checker (whole CLI) | repos deleted 2026-11-04 | about 40 `suspec check` lines (§4c) |
| `suspec setup` and global policy install | repos deleted | README:26-35, ADOPTING:51-72, cli.md, output-economy:7-8, artifact-registry:7 |
| MCP tools `suspec_check`, `suspec_get_checks`, `suspec://checks` | repos deleted | `docs/artifact-registry.md:8`, `docs/10:14-23` |
| "Claims need sources" principle | absent from `principles.md` | `docs/research/sources.md:3,638` |
| Reserved-check list | — | `checks/README.md:21` lists 6 reserved IDs, omitting C005, C006, C014, C017 and C018; `checks.yaml` and `checks.md:69` list 11 |
| Old skill names `sus-review`, `sus-panel`, `disrespec`, `fork-me` | ADR-0184/0186 | README:23-24, ADOPTING:25 (cutover advice, intentional) |
| Personas, SOL, APS, nine passes, kernel, overlays, seven-value verdict, heuristic profiles, write-surface model, workspace, intake, review packet, starter kit, living specs, step bars | ADRs 0036–0164 | **ADR bodies only.** `scripts/lint-method-topology.sh:139` keeps a stale-name denylist. About 50 constructs in 0001–0060 alone, of which about 8 survive (`_work/adrs-0001-0060.md` §3) |

## 4. Skill inventory

All seven pass `scripts/lint-artifact-skills.sh` (`lint-artifact-skills: OK`). Line counts: `wc -l`.

| Skill | Lines | Artifact / prefix | Purpose (one line) | Triggers (from `description`) | Excludes | Concepts it carries |
| --- | --- | --- | --- | --- | --- | --- |
| `sus-spec` | 105 | `spec` / `SPEC-` | decided intent under test | intent or consequential open behavior must become requirements and ACs before implementation | direct implementation, small clear work, factual verification, implementation planning | AC block, draft/ready, sources list, structural Verify (C001–C028 by hand), picker |
| `sus-task` | 121 | `task` / `TASK-` | split a ready spec into collision-proof packets | parallel slices, per-repo/platform contexts, change-plan waves | unspecced work, no dispatch boundary | ready-only source, verbatim AC copy, write-disjointness, Run order, Verify evidence, review-ready freeze |
| `sus-inventory` | 72 | `inventory` / `INV-` | map present reality | wide change lacks a proven map | implementation, narrow path tracing (= `dissect`), small work | evidence-per-sentence, zero-caller claims need a command |
| `sus-change-plan` | 95 | `change-plan` / `CHANGE-` | behavior-preserving staged transformation | refactor, rewrite, migration, upgrade, perf, schema, wide cleanup | implementation, net-new features, single-seam work (= `drill`) | baseline, PG-NNN, waves, cutover/rollback, shim removal, call-site counting, perf protocol |
| `sus-audit` | 70 | `audit` / `AUDIT-` | evidenced present-state risks | debt surveys, cleanup assessments, benchmarks, quality assessments, fresh passes | conformance review, rotating adversarial review (= `revolver`), option research | Blocker/Major/Minor, evidence + failure mode + blast radius |
| `sus-research` | 140 | `research` / `RESEARCH-` | decision-grade evidence | options, APIs, products, markets, competitors, customers, reviews, UX, positioning | settled fact-checking (= `bulletproof`), audits, intent | claim/evidence table, GRADE-style downgrades, confidence tiers, synthetic-respondent rule, TAM/SAM/SOM, `R-NNN` |
| `sus-campaign` | 195 | `campaign` / `CAMPAIGN-` | restartable multi-PR goal contract | one durable objective, write-disjoint streams, native ledger, delivery gates | single-PR goals, plan-only asks | ledger, control strength, lanes, dispatch, model-tier routing, PR/review publication rules, pickup loop |

Relation to `jcosta33/skills`:
- **Same edit contract.** `skills/README.md:35-51` mirrors that repo's `AGENTS.md`.
- **Semantic hand-offs only.** The lint forbids naming siblings (`lint-artifact-skills.sh:222-233`):
  - `drill` → change plan
  - `dissect` → inventory
  - `revolver` and `bulletproof` → audit
  - Close → `promote`
- **Origin.** `jcosta33/skills` deleted these same seven files (plus `sus-panel`) in its `7939d3f`
  (sibling map §3).
- **Lock entries on this machine.** The seven are installed from `jcosta33/suspec` and twelve
  methods from `jcosta33/skills`.

Gate pins that make the skill wording rigid: `lint-artifact-skills.sh` requires literal phrases. Examples:
- `'Suspec supplies no reviewer or stance count.'` (`:315`)
- the three control-strength labels (`:292-302`)
- model-routing sentences (`:322-330`)
- spec, task and change-plan section literals (`:353-369`)

Any rewrite must change the gate in the same commit.

## 5. Rename history

### 5a. When and why

| Rename | Commits | Date | Stated reason |
| --- | --- | --- | --- |
| Swarm → Corpus (brand prose) | `3e32399` (99 files, ADR bodies included) and `b3b146b` | 2026-06-23 | none; body lists scope only |
| swarm → corpus (identifiers, URLs, `.swarm/`, CLI) | `e9ed49b` "rename", empty body, 105 files | 2026-06-23 | none |
| file renames (logo, `01-what-is-*`, ADRs 0050/0060/0077/0085/0091/0092) | `d182340` | 2026-06-23 | none |
| `corpus-hq` → `corpus-works` | `ffe396c` | 2026-06-24 | subject only |
| Corpus → Suspec (everything) | `367d995` "Rename Corpus to Suspec", empty body, 148 files, 8 path renames | 2026-06-30 | **none; no ADR** |
| "golden corpus" → "fixture set" | `3c69191` | 2026-06-30 | "Remove remaining Corpus references" |
| repair of the rename sweep | `fad0458` (07-02) and `619dc4e` (07-13) | — | `367d995` find-replaced the common noun "corpus" inside immutable ADR bodies |

No ADR decides any product rename (all three `corpus-study-2026-11-05/adrs-*` reports, §name-evidence). GitHub kept the old
names as redirects. Checked 2026-11-04 with `gh api repos/jcosta33/<name>`:

| Old repo name | Resolves to |
| --- | --- |
| `swarm` | `jcosta33/suspec` |
| `corpus` | `jcosta33/suspec` |
| `corpus-skills` | `jcosta33/skills` |
| `suspec-skills` | `jcosta33/skills` |
| `corpus-cli`, `corpus-mcp`, `corpus-website`, `corpus-starter-kit`, `corpus-agents`, `corpus-works`, `suspec-agents`, `suspec-works`, `suspec-starter-kit` | 404 |

The repo description still reads "The Suspec framework: a lightweight spec and review workflow for
teams using coding agents."

Corruption from the Corpus→Suspec sweep that was never repaired:
- `docs/adrs/0033…:60` "suspec framing"
- `docs/adrs/0066:50` "(suspec framing)"
- `docs/adrs/0097:68` "docs suspec maxes"
- `docs/adrs/README.md:67` and `:240` ("memory, suspec, lint namespace")

### 5b. Impact list: every place the name appears today

Totals: 85 capitalized "Suspec" plus 44 lowercase `suspec` tokens outside `docs/adrs/`; 1,158
occurrences in 150 ADR files. Capitalized "Corpus" and every "Swarm" appear nowhere. Lowercase
`corpus-*` repo names appear in ADRs 0136–0144, 0164 and 0172 (for example `0172:29`
`corpus/policy/economy.md`, `0143:164-167`).

| Kind | Where (non-ADR) |
| --- | --- |
| GitHub repo name, remote | `jcosta33/suspec`; `git remote -v` = `https://github.com/jcosta33/suspec.git`; repo description |
| Local checkout path | `/Volumes/Development/suspec`. `scripts/lint-product-citations.sh:60-79` and `lint-count-ranges.sh:50-67` resolve the repo by the name `suspec` |
| File and dir names | `docs/01-what-is-suspec.md`; `skills/sus-{audit,campaign,change-plan,inventory,research,spec,task}/` |
| ADR file names (sealed) | `0050-suspec-is-a-spec-repo-discipline.md`, `0060-suspec-workspace.md`, `0077-suspec-cli-…`, `0085-suspec-mcp-…`, `0091-suspec-update-check.md`, `0092-suspec-agents-member.md` |
| Skill identifiers | frontmatter `name: sus-*`; H1s `# Sus Spec` … `# Sus Task`; catalog rows `skills/README.md:20-28`; `artifact-formats.md:22-28` writer column; `lint-artifact-skills.sh:12-18,337`; `lint-method-topology.sh:132-138`; `test-lint-artifact-skills.sh` (for example `rm -rf "$fixture/skills/sus-spec"`) |
| Skill descriptions and bodies | `sus-spec:3,12` ("verifiable Suspec spec", "Suspec spec workflow"); `sus-task:3,12`; `sus-inventory:16`; `sus-change-plan:16`; `sus-campaign:80-81,88` ("Suspec supplies no…", pinned by the gate at `lint-artifact-skills.sh:315`) |
| Install commands | `README.md:16`; `skills/README.md:10-12`; `docs/ADOPTING.md:8`: `npx skills add jcosta33/suspec …` |
| CLI names and verbs | `suspec check` (about 40 lines: README:67; docs/02:34; 05:58; 06:23; 08:43-46; ADOPTING:45,80; tutorial 01:62, 03:15; examples ×3; cli.md; cheatsheet:69-71; checks.md:7; glossary:29; local-checks:20; `checks.yaml:8`; fixtures EXPECTED ×3); `suspec setup` (README:30-31, ADOPTING:56-71, docs/10:23, cli.md:8, output-economy:8) |
| Repo URLs | `github.com/jcosta33/suspec-cli` (10: README:26,105; skills/README:16; docs/10:8,11; artifact-registry:6,7; cli.md:3,13; ADOPTING:33); `…/suspec-mcp` (4: README:106; docs/10:16,18; artifact-registry:8) |
| MCP identifiers | `suspec_check`, `suspec_get_checks`, `suspec://checks` (`artifact-registry.md:8`) |
| Env vars | `SUSPEC_HISTORY_BASE` (workflow:35, lint-accepted-adrs:7); `SUSPEC_FAMILY_ROOTS` (workflow:41, lint-count-ranges); `SUSPEC_CANON`, `SUSPEC_CLI`, `SUSPEC_MCP`, `SUSPEC_BIN` (lint-method-topology:24-26,88-92); script locals `SUSPEC_ROOT`, `SUSPEC_MAIN_DIR`, `SUSPEC_MCP_DIR`, `SUSPEC_CLI_DIR` |
| CI | `method-gates.yml:3` ("current Suspec repositories"), `:15,19` input descriptions, `:53-58` checkout names and `family/suspec/…` paths |
| Gate strings | `lint-method-topology.sh:15,20` ("Suspec repository … not found"), `:32` (`repository: jcosta33\/suspec`), `:62,147` (`suspec-agents`, `agents/suspec-`); `lint-product-citations.sh:5,24,46,79-81,111`; `lint-count-ranges.sh:8,20,48` |
| Prose (capitalized) | `docs/research/sources.md` (21); ADOPTING (14 total incl. lowercase); docs/10 (11); README (11); skills/README (6); docs/08, 01 (5 each); docs/03 (4); glossary, cheatsheet, artifact-formats, artifact-registry, docs/02, AGENTS (3 each); the rest 1–2 each (full list: `grep -rci suspec --exclude-dir=adrs`) |
| Badges | none exist |
| Cross-repo (sibling) | `jcosta33/skills`: README:17-18 (cutover names), :47-49 (link to `jcosta33/suspec`); `skills/drill/SKILL.md:29` "No Suspec artifact"; `scripts/lint-current.sh:375,379`; `scripts/lint-released-changelog.sh:8` (`SUSPEC_SKILLS_HISTORY_BASE` fallback); CHANGELOG released sections (frozen) |
| Installed state | `~/.agents/.skill-lock.json` entries `sus-*` with `source: jcosta33/suspec`; `~/.agents/skills/sus-*`; symlinks `~/.claude/skills/sus-* -> ../../.agents/skills/sus-*` |

Constraint on any rename: `scripts/lint-accepted-adrs.sh:5-6` pins `EXPECTED_COUNT=184` and a
SHA-256 digest of every numbered ADR file, and fails on any change since the PR base (`:9-29`).
Renaming the six `*-suspec-*` ADR files or editing ADR bodies trips it. The ledger
`docs/adrs/README.md` is not sealed.

## 6. Stale external references

`jcosta33/suspec-cli`, `suspec-mcp` and `suspec-website` all return 404. `suspec-starter-kit` also
404s.

| Target | Non-ADR references |
| --- | --- |
| `suspec-cli` | `README.md:26,105`; `skills/README.md:16`; `docs/10-integrations.md:8,11`; `docs/artifact-registry.md:6,7`; `docs/reference/cli.md:3,13`; `docs/ADOPTING.md:30-40` (clone/install block); `checks/checks.yaml:8`; `checks/README.md:4`; `checks/fixtures/transformation/EXPECTED.md:8`; `.github/workflows/method-gates.yml:14-15,55`; `scripts/lint-method-topology.sh:25,42,88-121` (needs `$cli/.github/workflows/gate.yml` and `$cli/src/generated/agentPolicy.ts`); `scripts/lint-product-citations.sh:81,99`; `scripts/lint-count-ranges.sh:68` |
| `suspec-mcp` | `README.md:106`; `docs/10:16-18`; `docs/artifact-registry.md:8`; `method-gates.yml:18-19,54`; `lint-method-topology.sh:26,43,92`; `lint-product-citations.sh:19,80,98`; `lint-count-ranges.sh:68` |
| `suspec-website` | **no non-ADR reference.** ADRs only: 0074:15, 0093:77-80, 0144:103-104, 0164:79-87 (as `corpus-website`) |
| CLI-only behavior described as current | every `suspec check` / `suspec setup` line in §5b; `docs/reference/cli.md` whole file; `checks/checks.yaml` whole file ("reference consumer"); `policy/` (installed only by `suspec setup`, `docs/reference/cli.md:21-23`) |
| ADRs deciding CLI, MCP or website contracts | 0061–0119: about 40 of 60 ([adrs-0061-0120.md](corpus-study-2026-11-05/adrs-0061-0120.md) §4); 0121–0186: 0121, 0125–0130, 0134–0144, 0152–0154, 0158, 0159, 0164–0166, 0172–0181, 0183–0186 (`_work/adrs-0121-0186.md` §5). No ADR records the deletion. |
| `SUSPEC_STATE_DIR`, `suspec done`, `suspec store`, `suspec promote` | ADR bodies only: 0137:53,56-57; 0139:63-80; 0141; 0142. No current doc uses them. |

## 7. Open problems

1. **`cmdCheck` is red** (§0). The only CI job that would exercise the topology gate depends on
   deleted repos.
2. **The product's stated distinct mechanism has no implementation.** `README.md:95` says "Its
   distinct mechanism is deterministic reconciliation keyed to requirement IDs." The checker was
   `suspec-cli`. `checks.yaml` and the fixtures now have no consumer (`checks.yaml:1-2`: "Inert").
3. **Panel retirement is half done.** `d3f14fb`'s body promises the reference pages drop `panel`;
   `checks/README.md:53` and `cheatsheet.md:25` still list it.
4. **Dead C013 machinery is documented as live** (`docs/08:37-38`, `docs/10:51-52`).
5. **Change-plan reference resolution assumes per-feature folders.** `docs/03:45-46` and C010 scan
   `spec.md` in sibling folders. The skills prescribe no file name, and the docs show three
   conventions: `spec-checkout.md` (`docs/07:7`), `checkout-expiry-spec.md` (tutorial 01:21), and
   `checkout/spec.md` (examples/large-pr-review:6).
6. **The ADR immutability rule is violated in practice.**
   - Status lines are out of sync with the ledger in 17+ files: 0032, 0045, 0048–0052, 0058, 0060,
     0067, 0069, 0073–0075, 0100, 0104 and 0114.
   - About 50 accepted bodies carry later addenda.
   - Ledger back-references are missing for about 40 rows.
   - The ledger calls C012, C013 and C016 "upheld" while `checks.yaml` reserves them.

   Detail is in the §2 sections of the `corpus-study-2026-11-05/adrs-*` reports.
7. **Accepted ADRs are dead without supersession.** Examples: 0031, 0034–0039, 0071, 0082, 0089,
   0091, 0108, 0116, 0124, 0126–0129, 0131, and every CLI/MCP/setup ADR.
8. **The policy contradicts live ADRs.** `policy/agent.md` lacks ADR-0133's examine-don't-ruminate
   rule and ADR-0142's native-memory routing ([adrs-0121-0186.md](corpus-study-2026-11-05/adrs-0121-0186.md) §2.6).
9. **`checks/README.md:21` disagrees with `checks.yaml` on reserved IDs.**
10. **`docs/research/sources.md:3,638` cites a principle that does not exist** ("Claims need
    sources").
11. **`sus-spec` omits `## Execution`,** which docs/02, 06, 07 and the tutorial make the
    unsplit-work run record.
12. **Lint pins prose.** `lint-artifact-skills.sh` freezes wording, so every editorial improvement is
    a two-file change and the gate tests phrasing rather than structure.
13. **Real usage diverges from the contract** (§1). There are no specs, and the tasks ignore the task
    schema. The method's center of gravity in practice is campaign, audit and research.
