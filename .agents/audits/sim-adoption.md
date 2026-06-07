---
type: audit
id: sim-adoption
status: draft
created: 2026-06-07
updated: 2026-06-07
---

# Audit: simulated adoption / instantiation journey

> Stance: **observation-only**. This records the present state of the adoption path — where a
> first-time adopter (and their coding agent) following `docs/ADOPTING.md` end-to-end hits
> confusion, fragility, internal inconsistency, or a step that cannot be performed as written
> given Swarm has **no runtime**. It asserts no new intended behaviour and prescribes no fixes;
> each item carries file:line evidence and a severity by blast radius. Some items are documented
> design contracts (NO-RUNTIME) and are flagged as such, not as bugs.

## Scope

- **In scope:** the adoption journey for a fresh / co-located **spec-repo** and the **code-repo**
  branch, exactly as a human+agent would execute `docs/ADOPTING.md`: get Swarm, decide role, copy
  `starter-kit/.agents/{skills,reference,templates,memory}`, place `AGENTS.md` + CLAUDE/GEMINI
  symlinks, create the first `specs/<feature>/`, append `.gitignore.additions`, fill the Commands
  table + project facts. Files read: `docs/ADOPTING.md`, `starter-kit/README.md`,
  `starter-kit/AGENTS.md`, `starter-kit/specs/README.md`, `starter-kit/specs/001-contact-form/*`,
  `starter-kit/decisions/*`, `starter-kit/.gitignore.additions`,
  `starter-kit/.agents/{reference,memory,templates}/*`, `docs/model/workspace.md`,
  `docs/library/code-skills/`.
- **Out of scope:** the correctness of SOL grammar itself; the upstream `docs/passes/*` manuals;
  whether the framework's claims are *true* in the literature (separate evidence-discipline audit).

## Observations

### O-1 — Two divergent `INDEX.md` seeds get installed side by side, with conflicting frontmatter (MAJOR)

The prompt (`docs/ADOPTING.md:30`) tells the agent to copy **both** `templates` and `memory`.
The kit ships two different memory-index files:

- `starter-kit/.agents/memory/INDEX.md` — the live seed, **no frontmatter at all**
  (`starter-kit/.agents/memory/INDEX.md:1` is `# Memory INDEX — Tier-1 recall map (seed)`).
- `starter-kit/.agents/templates/memory/INDEX.md` — a *template* with conflicting frontmatter
  `type: memory-index / id: memory-index / status: active / updated: {{createdAt}}`
  (`starter-kit/.agents/templates/memory/INDEX.md:1-6`) and a different section skeleton
  (`## Always-relevant project facts`, `## Topic files`, `## Decisions`, `## Stale or superseded
  memory`) than the seed's (`## Durable findings`, `## Topic files`).

After a literal copy the adopter has `.agents/memory/INDEX.md` (no `type:`) **and**
`.agents/templates/memory/INDEX.md` (`type: memory-index`). The two disagree on whether the index
carries frontmatter, on its `type:` value, and on its section headings. No adoption-facing doc
(`docs/ADOPTING.md`, `starter-kit/README.md`, `starter-kit/AGENTS.md`,
`starter-kit/.agents/templates/*`) so much as mentions `templates/memory/` exists
(grep: "NOT mentioned in adoption-facing docs"). A confused newcomer cannot tell which INDEX is
authoritative, and the `promote` step has two contradictory shapes to write into.

### O-2 — The installed memory seeds carry no `type:` frontmatter, contradicting the stated discovery contract (MAJOR)

`docs/model/workspace.md:59` states the load-bearing rule: *"Swarm identifies an artifact by its
frontmatter `type:`, not its path — so a tool finds it wherever it sits."* But the two seeds an
adopter installs have **no frontmatter**:
`starter-kit/.agents/memory/INDEX.md:1` and `starter-kit/.agents/memory/glossary.md:1` both start
with an `#` heading. A future recall tool built against the stated contract would not find either
file by `type:`. (Glossary has no `type: memory-glossary`; INDEX has no `type: memory-index`,
even though the *template* version asserts that very type — see O-1.)

### O-3 — `AGENTS.md` declares a regression check the adopter is told they MUST have, but nothing ships it and there is no runtime to run it (MAJOR / NO-RUNTIME tension)

`starter-kit/AGENTS.md:8-9` (in the install-time HTML comment): *"HARD CAP: MUST stay <= 200 lines
/ 25 KB … A valid repo MUST have a regression check that fails when this file exceeds the cap."*
The kit ships no such check (`grep -rln "regression check" starter-kit/` returns only the AGENTS.md
comment that states the requirement). Swarm has no runtime to enforce it. So the adopter is handed
a `MUST` about repo validity that (a) they must build themselves and (b) the framework can never
verify. A first-timer reads "a valid repo MUST have X", finds no X, and cannot tell whether their
repo is valid. This is the general NO-RUNTIME confusion concentrated into a single normative line.

### O-4 — `.gitignore.additions` ignores `.agents/tasks/`, but startup rule #1 says read "the current task file" and the kit ships no task home or task template a spec adopter would find (MAJOR)

`starter-kit/.gitignore.additions:6` ignores `.agents/tasks/`. `starter-kit/AGENTS.md:23` startup
rule #1 is *"Read the current task file first."* Nothing in the kit creates `.agents/tasks/`, ships
a `task.md` template at the documented home, or tells the adopter where a task frame lives. The
canonical `task.md` / `trace.md` templates live only under
`docs/library/code-skills/templates/task.md` — which a **spec** adopter is never told to copy
(it's code-repo reference). The only task templates inside the kit are buried as
`write-*/references/task-template.md` (e.g.
`starter-kit/.agents/skills/write-spec/references/task-template.md`), not surfaced anywhere in the
adoption flow. Net: an agent told to "read the current task file first" on a fresh repo has no task
file, no template at a discoverable path, and the one place tasks would live is gitignored and
never created. The very first startup instruction dead-ends.

### O-5 — `AGENTS.md` startup rule #5 points to "the `implement` step", which has no skill in a spec repo (MINOR/MAJOR confusion)

`starter-kit/AGENTS.md:27` startup rule #5: *"Decide isolation before editing (see the `implement`
step) …"*. A spec-repo adopter installs only the 20 authoring skills
(`ls starter-kit/.agents/skills/` → no `implement`, no `verify`, no `pass-author`). The `implement`
step lives in `docs/library/code-skills/`, which the spec-repo branch is explicitly told **not** to
copy (`docs/ADOPTING.md:44-50`). The always-loaded bootloader thus references a step the adopter
has no skill for and no pointer to. (Same gap: rule #1's task file, O-4.) Mild for an expert,
disorienting for a newcomer who tries to "see the implement step" and finds nothing installed.

### O-6 — The example feature folder ships an `audit.md` that no adoption-facing index lists, so a literal copy or a "replace the example" cleanup is ambiguous (MINOR)

`starter-kit/specs/001-contact-form/` contains `spec.swarm.md`, `research.md`, **and**
`audit.md`. But `starter-kit/specs/README.md:9-16` shows the example folder tree as only
`spec.swarm.md` + `research.md` (no `audit.md`), and `spec.swarm.md:14` narrates only "see
`research.md` beside it". The `audit.md` is real and self-describes as an example
(`starter-kit/specs/001-contact-form/audit.md:16`), but it's omitted from the folder's own README
inventory. An adopter following the README tree as ground truth doesn't know `audit.md` is part of
the example to delete, and an agent reconciling "copy their shape, then replace them"
(`docs/ADOPTING.md:40`) may leave a stray example audit behind.

### O-7 — The copy instruction `copy starter-kit/.agents/{skills,reference,templates,memory} into this repo's .agents/` collides with the very next sentence telling Claude Code users to put skills in `.claude/skills/` (MAJOR — produces a non-activating install)

`docs/ADOPTING.md:30-31`: *"Copy `starter-kit/.agents/{skills,reference,templates,memory}` into
this repo's `.agents/`. Put the **skills** in whatever directory my agent CLI scans —
`.claude/skills/` for Claude Code, otherwise `.agents/skills/` …"*. A literal-minded agent executes
the first clause (`cp -r` the brace-set into `.agents/`), landing skills at `.agents/skills/`. For a
Claude Code user that directory is **not scanned** — Claude Code scans `.claude/skills/`. The skills
silently do not activate; the adopter sees a populated `.agents/skills/` and assumes success. The
two clauses are in tension within one bullet and the "into this repo's `.agents/`" framing is the
one a copy tool follows. There is no post-install check (NO-RUNTIME) that would catch a
skills-dir mismatch.

### O-8 — Symlink/`@AGENTS.md` placement is under-specified and silently platform-fragile (MINOR/MAJOR)

`docs/ADOPTING.md:34`: *"Add `CLAUDE.md` and `GEMINI.md` as **symlinks** to `AGENTS.md` (or one-line
`@AGENTS.md` aliases where symlinks don't survive)."* The kit's own symlinks are *relative*
(`readlink starter-kit/CLAUDE.md` → `AGENTS.md`), which only resolves when the symlink sits in the
same dir as `AGENTS.md` — fine at root, but the instruction gives the adopter no rule for that, no
guidance on which platforms "don't survive" symlinks (Windows checkouts, some CI artifact stores,
zip distributions), and no way to verify the alias actually resolves (NO-RUNTIME). A `@AGENTS.md`
one-line alias is a Claude-Code-specific import convention, not something GEMINI or other CLIs honor,
yet it's offered as the fallback for `GEMINI.md` too.

### O-9 — Co-located (solo) role tells the adopter to "drop in the code-repo skill" without naming it or its non-kit path (MINOR)

`docs/ADOPTING.md:25-26` (co-located role): *"do the spec-repo steps **and** drop in the code-repo
skill."* It does not name the skill or its location *in that bullet*; the reader must infer from
step 4 (`docs/ADOPTING.md:46`) that it is `docs/library/code-skills/implement-and-verify/` — a path
*outside* the starter-kit the adopter cloned-and-copied from. A solo adopter who copied only
`starter-kit/` (the kit README's whole framing, `starter-kit/README.md:1-7`) does not have that
skill locally and isn't told it lives in `docs/`.

### O-10 — Adoption "validity is graded per role" but ships no checklist or fixture an adopter can grade against (MINOR / NO-RUNTIME)

`starter-kit/README.md:52-53`: *"validity is graded per role — a spec repo's bar is this kit + a
populated `AGENTS.md`."* There is a `conformance/` corpus in the producer repo
(`conformance/conformance.yaml`, `fixtures/`) but it is producer test data, never copied into an
adopted repo, and the adoption docs give no "you are done when…" checklist beyond prose. With no
runtime and no shipped fixture, an adopter cannot self-grade; "graded per role" has no grader.

### O-11 — The spec example binds `VERIFY BY test:cmdTest:…` proofs that a fresh spec repo can never run, with no note that this is expected (MINOR / NO-RUNTIME)

`starter-kit/specs/001-contact-form/spec.swarm.md:26-37` binds `VERIFY BY test:cmdTest:contact_form.submit_valid`
etc. The audit beside it cites `server/contact/submit.ts:42`
(`starter-kit/specs/001-contact-form/audit.md:25`) — a code path that does not exist in a spec repo.
A newcomer who tries to "run" the example to see Swarm work finds nothing to run and no code behind
the cited file:line. The example self-labels as illustrative, but the gap between a spec carrying
runnable-looking `cmdTest` bindings and a repo with no code/no runtime is exactly where a first-timer
expects a working demo and gets an inert one.

## Risks

- **Memory corruption at first `promote`** — *fires when* the adopter runs the `promote` step after
  O-1/O-2: with two divergent INDEX shapes installed and neither seed carrying the `type:` the
  contract requires, the agent either writes into the wrong file, picks the template skeleton over
  the live seed, or produces an INDEX no future tool can locate by type.
- **Silent non-activating install (Claude Code)** — *fires when* an agent executes
  `docs/ADOPTING.md:30` literally and lands skills in `.agents/skills/` on a Claude-Code host
  (O-7): every `pass-*`/`persona-*`/`write-*` skill is present-but-dormant; the adopter believes
  Swarm is installed and the authoring steps never trigger.
- **First-startup dead-end** — *fires when* a fresh-repo agent obeys `AGENTS.md` startup rule #1
  ("read the current task file") (O-4): there is no task file, no task home (it's gitignored), and
  no task template at any path the spec adopter was told to copy.
- **False sense of validity** — *fires when* the adopter takes "a valid repo MUST have a regression
  check" (O-3) or "validity is graded per role" (O-10) at face value: no check ships, no grader
  exists, so an invalid install (e.g. wrong skills dir, oversized AGENTS.md) reports as fine.
- **Stray example artifacts** — *fires when* the agent "replaces the example" using the
  `specs/README.md` tree as the inventory (O-6): `001-contact-form/audit.md` is not listed there and
  is left behind in the cleaned repo.
- **Co-located adopter missing the implement skill** — *fires when* a solo adopter copies only
  `starter-kit/` (its README's framing) and follows the co-located bullet (O-9): the named-only-later
  `implement-and-verify` skill lives in `docs/`, which they never pulled.

## Critical watch-outs for a reviewer (ranked)

1. **Skills-dir collision in the copy instruction (O-7).** The single most likely real-world
   failure: a literal copy puts skills where Claude Code never scans them, and nothing detects it.
   The prompt should not say "copy `{skills,…}` into `.agents/`" and then "put skills in
   `.claude/skills/`" in adjacent clauses.
2. **Duplicate, conflicting memory INDEX seeds (O-1) + seeds lacking the `type:` the contract
   demands (O-2).** Two INDEX files with different frontmatter and sections install together; the
   discovery contract in `workspace.md:59` can't even find the live seeds. Directly corrupts the
   first `promote`.
3. **First-startup task-file dead-end (O-4).** Startup rule #1 reads a task file that has no home
   (gitignored), no template the spec adopter copies, and no pointer — the bootloader's first
   instruction can't be satisfied on a fresh repo.
4. **Normative `MUST`s with no grader (O-3, O-10).** "A valid repo MUST have a regression check"
   and "validity is graded per role" promise enforcement Swarm has no runtime to provide and ships
   no checklist/fixture for — newcomers can't tell a broken install from a good one.
5. **Example-folder inventory drift (O-6) + spec startup rule pointing at an uninstalled `implement`
   step (O-5).** Lower blast radius but classic newcomer trip-ups: an unlisted example `audit.md`
   left behind, and an always-loaded rule that points to a skill a spec repo doesn't have.
