# Suspec repository history (read-only study)

Repository: `/Volumes/Development/suspec`, branch `main`, remote `origin https://github.com/jcosta33/suspec.git`.
`main` holds 430 commits, from `144e8b6` (2026-05-05) to `d3f14fb` (2026-08-26). Per month: May 12, June 282,
July 114, August 22. `git rev-list --all` counts 450. The extra 20 are `refs/notes/ai` commits.
`origin/merge-skills-repo` points at `969940f`, which is already on `main`. No tags.
All dates are author dates (`--date=short`). Everything below comes from `git log`, `git show`, or `git ls-tree`,
or from plain `grep` over the HEAD worktree.

## 1. Era timeline

| # | Era | Range (first → last defining commit) | What the tree contained |
|---|---|---|---|
| 0 | **Swarm scaffold + personas** | `144e8b6` 2026-05-05 "upd" → `185fcfe` 2026-05-31 | `scaffold/{.agents,docs,AGENTS.md,CLAUDE.md,GEMINI.md}`, `docs/{concepts,documents,guides,personas,reference,skills,tasks}`, root `swarm-spec.md`, `framework.md`, `task-*.md`. `docs/personas/` holds 13 `the-*.md` personas. `scaffold/.agents/skills/` holds 14 skills. `253a670` (05-05) adds `docs/adrs/`. `969940f` (05-30) "Merge refined skills repo into Swarm's skill layer" vendors `../skills` and brings 23 skills (`write-*`, 7 `persona-*`). |
| 1 | **Swarm kernel (compiler / SOL / APS / passes)** | `f894110` 2026-05-31 "Add Swarm kernel specification (v0.1)" → `0cb5110`/`5779543` 2026-06-07 (compiler vocabulary dropped, ADR-0054) | `.agents/specs/` holds the kernel spec. `bc83e3d` (06-02) archives the old docs to `docs/_legacy/`. `9f04284` (06-02) adds `docs/{language,model,passes,reference}`. `b41c127` (06-02) renames `scaffold/` → `kernel/`. `f8df373` builds the `kernel/.agents/` payload: `language/SOL.md`, `APS.md`, `passes/*.md`, `profiles/`, `conformance/`, `templates/spec.swarm.md`, `.swarm-version`. `30f2a52` adds the kernel ADRs 0027–0041. `docs/artifacts/` and `docs/library/` (06-02), `evals/rubrics/` (06-02), and `docs/research/` (06-03) follow. `0855b1f` (06-04) yields 34 standalone `SKILL.md` files. `a59be46` (06-07) retires "kernel": `kernel/` → `install/`. |
| 2 | **Spec-repo pivot** | `03c2266` 2026-06-07 ADR-0050 → `b292f1f` ADR-0051 → `6f2abca` ADR-0053 → `5779543` ADR-0054 (all 06-07) | `install/` → `starter-kit/` (`03c2266`). `conformance/` is added (`b292f1f`). `docs/library/code-skills/` holds 17 code skills as reference. `.agents/specs/` is removed in `4eb408e`. |
| 3 | **Practical-first repositioning** | `d31eec7` 2026-06-11 checkpoint → `5f2404b` ADRs 0057–0068 → `10c238b` 2026-06-11 rebuild | `10c238b` (303 files, the largest commit) deletes `docs/{artifacts,language,model,passes}`. The kit becomes `starter-kit/{agent,advanced,templates,examples,decisions}`. |
| 4 | **Workspace-shaped starter kit / multi-repo workspace** | `4d8c850` 2026-06-12 ADRs 0069–0071 → `85138d1` 2026-06-12 ADR-0073 | `77e6bb0` (06-12) renames `conformance/` → `checks/`. `cf1d6be` (06-12) reshapes `starter-kit/` into a full workspace (`specs/ tasks/ reviews/ findings/ intake/ inventory/ change-plans/`). `f4594e0` deletes `evals/`. |
| 5 | **Repo-family split** | `17b96ed` 2026-06-13 ADR-0074 → `e957b6a` 2026-06-13 ADR-0075; CLI `9099c37` 06-13 ADR-0077; MCP `4fc50e2` 06-18 ADR-0085; agents `1f47557` 06-21 ADR-0092 | `17b96ed` moves `.agents/{specs,audits,change-plans}` to `swarm-hq`, and moves the guides plus `docs/library/` to `swarm-skills`. `e957b6a` deletes `starter-kit/` entirely (to `jcosta33/swarm-starter-kit`). From here the repo holds `docs/`, `checks/`, `.agents/skills` (3 dev mirrors), and the root files. The CLI (`swarm-cli`) is first named in `a360c09` (06-06). Its first ADR is 0077. |
| 6 | **Corpus name** | `3e32399` 2026-06-23 → `367d995` 2026-06-30 (7 days) | The layout stays the same. `58d973c` (06-27) adds `scripts/`. `a051bf3` (06-27) adds `.github/workflows/method-gates.yml`. ADR-0111/0112 (`502bbc2`, `9f2fff7`, 06-26) define the two-tier skills: a Corpus-coupled kit plus a universal catalog. |
| 7 | **Suspec v1 (rename + integrity)** | `367d995` 2026-06-30 → `176e914` 2026-07-05 | Same layout. `fad0458` (07-02) repairs ADR bodies that the rename corrupted. |
| 8 | **Personal harness / starter kit retired** | `2ecfefa` 2026-07-09 ADR-0137 → `c6d16ee` 2026-07-09 ADR-0138 → `f45ca62` ADR-0139 | Only canon changes. The kit was already out of this repo since `e957b6a`. |
| 9 | **v3: skills are the product** | `1cd468c` 2026-07-10 ADR-0140–0143 → `d70c3d5` (v3 rewrite) → `be42e20` 2026-07-13 ADR-0149–0153 | `eb4abd1` (07-12) deletes `suspec-logo.png` and `.claude/launch.json`. `be42e20` (07-13) deletes `.agents/` (including the `SKILLS-MANIFEST.md` skill mirrors) and `.claude/skills`, and introduces the `sus-*` skill names (ADR-0151). `1a4a0e2` (07-18) retires SOL (ADR-0164, contract 0.22.0). |
| 10 | **Global agent policy / native delivery** | `0bc15b8` 2026-08-08 ADR-0171/0172 adds `policy/` → `b95e5e9` 08-09 ADR-0175 → `61117cd` 08-10 ADR-0178 → `b14abb6` 08-26 ADR-0185 | `policy/` is added. ADR-0180–0185 cover evidence-bounded execution, panels, single-file skills, native review, and Cursor/Antigravity targets. |
| 11 | **Artifact authors return with canon** | `d3f14fb` 2026-08-26 ADR-0186 | `skills/` returns with 7 `sus-*` skills (`sus-audit`, `sus-campaign`, `sus-change-plan`, `sus-inventory`, `sus-research`, `sus-spec`, `sus-task`) plus `README.md` and `sources.md`. The commit body says universal methods move to `jcosta33/skills`. |

Corrections to the brief's era list:
- ADR-0137 is "personal harness" (`2ecfefa`). "Skills are the product" is ADR-0140 (`1cd468c`).
- The starter kit left this repo at ADR-0075 (`e957b6a`, 06-13). ADR-0138 (`c6d16ee`, 07-09) retired the separate kit repo in canon.

## 2. Product renames

The name at the first commit was **Swarm**. `144e8b6` contains `swarm-spec.md` ("# Spec: Swarm framework repository") and 238 occurrences of "Swarm". No Corpus or Suspec brand appears there.

| Commit | Date | Subject | What changed | Stated reason |
|---|---|---|---|---|
| `3e32399` | 2026-06-23 | rebrand: Swarm → Corpus across docs/ADRs/checks/README (brand prose only) | 99 files, +318/−304. Capitalized "Swarm" → "Corpus" in every `.md`, including immutable ADR bodies 0001–0099. Lowercase `swarm` was kept on purpose (body text below). Also added `.claude/launch.json` and `.env.example` (website leftovers). | The body says what and what was kept ("Lowercase technical `swarm` preserved everywhere — CLI command, swarm-* repo compounds, github.com/jcosta33/swarm URLs, .swarm/ …"). It gives **no reason** for the new name. No ADR. |
| `b3b146b` | 2026-06-23 | rebrand follow-up: cover file types the .md sed missed | 1 file (`.env.example`: "Swarm website" → "Corpus website"). The body mentions "Swarm/Calma", but `git log -S'Calma'` returns nothing. | No reason. |
| `e9ed49b` | 2026-06-23 | rename (empty body, no co-author trailer) | 105 files, +2025/−1999. Lowercase technical identifiers: `` `swarm `` CLI → `` `corpus `` (217 word hits), `swarm-cli`→`corpus-cli`, `swarm-hq`→`corpus-hq`, `swarm-skills`/`-agents`/`-mcp`/`-starter-kit`/`-core`/`-bench`/`-website` → `corpus-*`, `.swarm/`→`.corpus/`, `.agents/.swarm-version`→`.corpus-version`, `swarm-reviewer`→`corpus-reviewer`, `github.com/jcosta33/swarm*`→`corpus*` (70 starter-kit URLs, 14 skills, 5 cli, 1 each hq/agents/repo). ADR link slugs point at the planned new filenames. The same commit also reformats emphasis `*x*` → `_x_`. | None. |
| `d182340` | 2026-06-23 | Rename framework artifacts to Corpus | 9 path renames: `swarm-logo.png`→`corpus-logo.png`, `docs/01-what-is-swarm.md`→`01-what-is-corpus.md`, ADR files 0050/0060/0077/0085/0091/0092 `swarm-*`→`corpus-*`. `.gitignore`: `SWARM_COMPREHENSIVE_REPORT.md`→`CORPUS_…`. | None. |
| `a6e2694` | 2026-06-23 | chore: clean stale repo metadata | Removes `.env.example` and rewrites the logo. | None. |
| `ffe396c` | 2026-06-24 | docs: prescribe works suffix for workspace repos | `corpus-hq` → `corpus-works`, including the URL. | Subject only. |
| `367d995` | 2026-06-30 | Rename Corpus to Suspec (empty body) | 148 files, +1036/−990. `Corpus`→`Suspec` (178), `` `corpus ``→`` `suspec `` (129), `corpus-cli`→`suspec-cli` (62+), `corpus-works`→`suspec-works`, `.corpus/`→`.suspec/`, `.corpus-version`, `corpus-skills`/`-mcp`/`-agents`/`-starter-kit`/`-core`/`-bench`/`-reviewer` → `suspec-*`, `CORPUS_`→`SUSPEC_`. URLs: `jcosta33/corpus`→`suspec` (and every sibling). The workflow checks out `jcosta33/suspec-*`. 8 path renames: `docs/01-what-is-suspec.md`, ADRs 0050/0060/0077/0085/0091/0092 → `suspec-*`, `suspec-logo.png`. | None. No ADR. |
| `3c69191` | 2026-06-30 | Remove remaining Corpus references | 16 files. The common noun "golden corpus" becomes "fixture set": ADR `0033-golden-corpus.md`→`0033-golden-fixture-set.md`, `checks/fixtures/prose-corpus/`→`prose-fixtures/`. Drops the `suspec:corpus` old-name fallback pairs from 4 scripts. | None. |
| `fad0458` | 2026-07-02 | Integrity pass: repair rename-sweep corruption | Restores the wording of ADRs 0019/0040/0048/0049/0065/0076/0087/0090/0096/0097 and of `checks/`. Adds the ledger note in `docs/adrs/README.md`. | Body: the `367d995` rename "find-replaced the COMMON NOUN \"corpus\" and one kernel/ directory reference inside immutable ADR bodies, producing nonsense (\"the conformance suspec\" …)". |
| `619dc4e` | 2026-07-13 | fix: restore accepted ADR history | A second repair: "A terminology sweep rewrote accepted decision bodies". Touches 19 ADRs. | Body. |

Lesser identifier renames (`git log -S`):
- `kernel/` → `install/` (`a59be46`, 06-07) → `starter-kit/` (`03c2266`, 06-07).
- The ledger row for ADR-0040 still reads "kernel payload ships under `starter-kit/`". `03c2266` introduced that wording by sweeping the directory name.

Commits mentioning each name. `-S` counts are case-sensitive substring hits; message counts are case-sensitive unless marked `-i`.

| Name | Message mentions (`--grep`) | Message mentions (`-i`) | Diff count changes (`-S`) | Diff lines (`-G -i`) | First / last message mention |
|---|---|---|---|---|---|
| Swarm | 45 | 146 | 139 | 223 | `1b62724` 05-05 / `b3b146b` 06-23 |
| Corpus | 9 | 51 (includes the common noun "golden corpus") | 21 | 125 | `6069f69` 05-31 (common noun) / `c851c00` 07-16 |
| Suspec | 11 | 39 | 54 (2 false hits: "Suspect" in `253a670`, `969940f`) | 145 | `367d995` 06-30 / `b14abb6` 08-26 |

State at HEAD (plain `grep -rI --exclude-dir=.git`):
- 0 "Swarm" and 0 "swarm". The renames rewrote even the "immutable" ADR bodies.
- 0 "Corpus".
- "suspec": 396 capitalized and 960 lowercase occurrences across 200 files. 7 tracked paths contain `suspec`: `docs/01-what-is-suspec.md` and ADRs 0050, 0060, 0077, 0085, 0091, 0092.
- 50 lowercase "corpus" lines remain, in 21 files. These fall into two groups.
  - (a) The common noun, for example "fixture corpus" in ADR-0048/0065/0096/0097.
  - (b) Sibling repo names written **after** the Suspec rename: `corpus-cli`, `corpus-skills`, `corpus-mcp`, `corpus-agents`, `corpus-works`, `corpus-website`, `corpus/policy/economy.md`. They appear in ADRs 0136–0144, 0164, and 0172, added between `2ecfefa` (07-09) and `1a4a0e2` (07-18). ADR-0139 cites local basenames `corpus` and `corpus-works`.

## 3. Other renames, retirements, big deletions

Directory events: `+` means the directory appeared, `−` means it disappeared.

| Commit | Date | Event |
|---|---|---|
| `bc83e3d` | 06-02 | `docs/{adrs,concepts,documents,guides,personas,reference,skills,tasks}` → `docs/_legacy/` |
| `b41c127` | 06-02 | `scaffold/` → `kernel/` |
| `3703138` | 06-02 | −`kernel/docs/` |
| `cd14736` | 06-06 | −`docs/_legacy/` (143 files) |
| `a59be46` | 06-07 | `kernel/` → `install/` |
| `03c2266` | 06-07 | `install/` → `starter-kit/` |
| `6fd4436` | 06-07 | −`starter-kit/overlays/` |
| `4eb408e` | 06-07 | −`.agents/specs/`; `evals/rubrics/` → `evals/` |
| `10c238b` | 06-11 | −`docs/{artifacts,language,model,passes}` (the kernel docs) |
| `77e6bb0` | 06-12 | `conformance/` → `checks/` (ADR-0070) |
| `f4594e0` | 06-12 | −`evals/` (step bars replace evals, ADR-0071) |
| `17b96ed` | 06-13 | −`.agents/{specs,audits,change-plans}`, −`docs/library/` |
| `e957b6a` | 06-13 | −`starter-kit/` (entire kit) |
| `d182340` | 06-23 | `swarm-logo.png` → `corpus-logo.png` |
| `367d995` | 06-30 | `corpus-logo.png` → `suspec-logo.png` |
| `eb4abd1` | 07-12 | −`suspec-logo.png`, −`.claude/launch.json`, −`scripts/check-catalog-freshness.sh`, −`scripts/lint-artifact-refs.sh` |
| `be42e20` | 07-13 | −`.agents/` (skill mirrors + `SKILLS-MANIFEST.md`), −`.claude/skills` |
| `0bc15b8` | 08-08 | +`policy/` |
| `d3f14fb` | 08-26 | +`skills/` |

Top 20 commits by files changed (`--shortstat`):

| Files | Commit | Date | Subject |
|---|---|---|---|
| 303 | `10c238b` | 06-11 | Rebuild: practical-first repositioning (ADRs 0057-0068) |
| 192 | `d31eec7` | 06-11 | checkpoint: pre-repositioning working tree |
| 165 | `03c2266` | 06-07 | ADR-0050: Swarm is a spec-repo discipline |
| 164 | `a59be46` | 06-07 | Goldilocks rebalance + retire "kernel" |
| 164 | `969940f` | 05-30 | Merge refined skills repo into Swarm's skill layer |
| 153 | `144e8b6` | 05-05 | upd (initial) |
| 148 | `367d995` | 06-30 | Rename Corpus to Suspec |
| 143 | `cd14736` | 06-06 | Prune docs/_legacy/ |
| 140 | `0cb5110` | 06-07 | Reimagine pt.2 (de-cosplay): drop the compiler vocabulary |
| 125 | `bc83e3d` | 06-02 | W1: archive pre-pivot docs/ to docs/_legacy/ |
| 115 | `0855b1f` | 06-04 | Rebuild the skill layer: 34 standalone SKILL.md |
| 105 | `e9ed49b` | 06-23 | rename |
| 101 | `253a670` | 05-05 | Consolidate framework docs vs scaffold artefacts; add ADRs |
| 99 | `3e32399` | 06-23 | rebrand: Swarm → Corpus |
| 97 | `b292f1f` | 06-07 | ADR-0051: complete the pivot |
| 91 | `6fd4436` | 06-07 | Phase 4: de-jargon "kernel" |
| 74 | `eb4abd1` | 07-12 | docs: align current Suspec contracts |
| 74 | `17b96ed` | 06-13 | ADR-0074: realize the repo family |
| 72 | `be42e20` | 07-13 | docs: define the lean Suspec contract |
| 71 | `b41c127` | 06-02 | W2: rename scaffold/ → kernel/ |

## 4. Skill history

| Commit | Date | Skill location and names |
|---|---|---|
| `144e8b6` | 05-05 | `scaffold/.agents/skills/`, 14 skills: `write-*`, `adversarial-review`, `empirical-proof`, `manage-task`, `personas`, … Persona docs live separately in `docs/personas/the-*.md` (13). |
| `969940f` | 05-30 | 23 skills vendored from `../skills`: 12 `write-*`, 7 `persona-*` (`persona-architect` …), 3 gates, `fix-flaky-test`. |
| `53f4118` | 06-02 | `kernel/.agents/skills/` recast to 7 (`pass-*` plus 2 fragments). The 13 personas become 6 `profiles/`. Pass guides live in `kernel/.agents/passes/`. |
| `0855b1f` | 06-04 | `kernel/.agents/skills/` holds 34 skills: `pass-*`, 13 `persona-*`, `write-*` (including `write-prd`, `write-rfc`). |
| `9efac5e` | 06-06 | Repo-local dev subset `.agents/skills/` appears (14). |
| `b292f1f` | 06-07 | `starter-kit/.agents/skills/` (20). 17 code skills move to `docs/library/code-skills/`. |
| `10c238b` | 06-11 | Kit `starter-kit/agent/` (`implement-task`, `review-output`, `write-spec`) plus `starter-kit/advanced/` (12). |
| `17b96ed` | 06-13 | Guides leave for `swarm-skills`. `.agents/skills` drops to 3 mirrors. |
| `e957b6a` | 06-13 | The kit's skills leave with `starter-kit/`. |
| `8f6553c` | 06-22 | ADR-0093 collapses the 1:1 personas. The last `persona-*` dev mirror is gone, leaving 2 mirrors (`empirical-proof`, `implement-task`). |
| `be42e20` | 07-13 | `.agents/skills` removed, so the repo has no skills. `sus-*` names introduced (ADR-0151: `sus-spec`, `sus-task`, `sus-review`, `sus-inventory`, `sus-change-plan`, `sus-audit`, `sus-research`); the skills live in `suspec-skills`. |
| `d3f14fb` | 08-26 | `skills/` returns with 7 `sus-*` (`sus-review` is absent; `sus-campaign` is added). |

Name-prefix chronology:
1. Unprefixed: `write-*`, `persona-*`, `pass-*`, gates.
2. `sus-*` since `be42e20` (07-13).

No skill ever carried a `swarm-*` or `corpus-*` prefix. Those prefixes named repos, the CLI, and agent definitions (`swarm-reviewer` → `corpus-reviewer` (`e9ed49b`) → `suspec-reviewer` (`367d995`)).

## 5. CI and scripts

- `.github/workflows/method-gates.yml` was added in `a051bf3` (06-27). Its first shape checked out 7 family repos (`jcosta33/corpus`, `-skills`, `-agents`, `-mcp`, `-starter-kit`, `-works`, `-cli`), built `corpus-cli`, ran `lint-all.sh`, and ran `corpus check` in `corpus-works`.
- It was modified in 11 later commits: `367d995`, `faf4c49`, `fad0458`, `eb4abd1`, `be42e20`, `b37f835`, `8cbbe38`, `a0abb31`, `faa3b1a`, `fcff9b0` (07-13 cluster), `ed11020`, `d3f14fb`.
- The HEAD shape has two jobs.
  - `local-gates` runs on push/PR: accepted-ADR seal, citations, count ranges, artifact-skill lint and its mutation test.
  - `method-gates` runs on dispatch only and checks out `jcosta33/suspec-mcp` and `jcosta33/suspec-cli`.
  - `ed11020` also checked out `suspec-skills`; `d3f14fb` dropped it.
- `scripts/` was added in `58d973c` (06-27) with `lint-all`, `lint-artifact-refs`, `lint-count-ranges`, `lint-product-citations`, and `check-catalog-freshness`. Later changes:
  - `lint-artifact-refs`: deleted `faf4c49`, re-added `2c22dcf`, deleted again `eb4abd1` (which also deleted `check-catalog-freshness`).
  - `lint-skill-mirrors`: `d92af0b` → `be42e20`.
  - `lint-disrespec-spine`, `lint-method-topology`, `lint-skill-catalog`: added `3cf7c4d` (07-12). `lint-skill-catalog` deleted `2a94632`.
  - `lint-skill-isolation`: `be42e20` → `d3f14fb`.
  - `lint-accepted-adrs`: added `b37f835` (07-13). `lint-released-changelog`: `ee7a0ab` → `d3f14fb`.
  - `lint-artifact-skills` and `test-lint-artifact-skills`: added `d3f14fb`.
  - HEAD has 7 scripts.
- `lint-accepted-adrs.sh` (HEAD) pins `EXPECTED_COUNT=184` and a SHA-256 digest of every accepted ADR. On PRs and pushes it fails if any accepted ADR file changed since the base. Renaming the 7 `*-suspec-*` ADR files or editing ADR bodies trips it.
- I ran `sh scripts/lint-all.sh` on 2026-11-04. Five gates passed. One failed:

```
Suspec repository suspec-cli not found under /Volumes/Development
  ^ lint-method-topology FAILED
```

`lint-method-topology.sh` requires sibling checkouts with `package.json` names `suspec-cli` and `suspec-mcp`. Neither directory exists under `/Volumes/Development`.
- Env vars: `SUSPEC_HISTORY_BASE`, `SUSPEC_FAMILY_ROOTS`, `SUSPEC_CANON`, `SUSPEC_CLI`, `SUSPEC_MCP` (27 hits at HEAD). Earlier names: `SWARM_` until `d182340`, `CORPUS_` from `d182340` to `367d995`.

## 6. Remote and repo identity

`git remote -v`: `origin https://github.com/jcosta33/suspec.git`. 31 commits change the count of `github.com/jcosta33`.

| URL | First added | Removed (last) |
|---|---|---|
| `jcosta33/swarm` | `cc1848f` 06-07 | `e9ed49b` 06-23 → `jcosta33/corpus` |
| `jcosta33/swarm-skills` | `17b96ed` 06-13 | `e9ed49b` |
| `jcosta33/swarm-starter-kit` | `e957b6a` 06-13 | `e9ed49b` |
| `jcosta33/swarm-cli` | `b0b7489` 06-15 | `e9ed49b` |
| `jcosta33/swarm-agents` | `6212977` 06-21 | `e9ed49b` |
| `jcosta33/swarm-hq` | `29a34d0` 06-22 | `e9ed49b` → `corpus-hq` → `corpus-works` (`ffe396c` 06-24) |
| `jcosta33/corpus`, `corpus-{skills,starter-kit,cli,agents}` | `e9ed49b` 06-23 | `367d995` 06-30 |
| `jcosta33/corpus-mcp` | `58d973c` 06-27 | `367d995` |
| `jcosta33/suspec` | `367d995` 06-30 | `fad0458` 07-02 (self-URL dropped) |
| `jcosta33/suspec-starter-kit` | `367d995` | `d70c3d5` 07-10 |
| `jcosta33/suspec-works` | `367d995` | `eb4abd1` 07-12 |
| `jcosta33/suspec-agents` | `367d995` | `be42e20` 07-13 |
| `jcosta33/suspec-skills` | `367d995` | still 2 refs at HEAD |
| `jcosta33/suspec-cli` / `suspec-mcp` | `367d995` | still 10 / 4 refs at HEAD (README, workflow) |
| `jcosta33/skills` | `d3f14fb` 08-26 | 8 refs at HEAD |

I did not check GitHub itself, so the brief's claim that `suspec-cli` and `suspec-mcp` were deleted on 2026-11-04 is unverified. HEAD still links to both, and the dispatch CI job checks them out.
