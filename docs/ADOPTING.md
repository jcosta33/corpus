# Adopting Swarm

Swarm is markdown only — there's nothing to install or run. You adopt it by **handing your coding agent the
prompt below**, which tells it to pull the framework from `github.com/jcosta33/swarm` and integrate the
right pieces into your repo. It works two ways: **instantiating a fresh repo** as a Swarm spec/docs repo (the
common case — most teams don't yet keep specs separately), and **integrating into an existing repo**.

Swarm lives in a **spec / documentation repo** (where intent is authored and reviewed). **Code repos stay
pristine** — a good SOL spec is self-legible, so a developer's repo needs essentially nothing from Swarm.

## The prompt — copy this to your agent

> **Adopt the Swarm framework into this repository.**
>
> 1. **Get Swarm.** Clone or read `https://github.com/jcosta33/swarm` — a markdown-only framework, nothing to
>    build or run. Its authoritative instructions are `docs/ADOPTING.md` and `starter-kit/README.md`; read
>    both first. The pieces you'll use are under `starter-kit/` (the authoring kit) and, for a code repo,
>    `docs/library/code-skills/`.
>
> 2. **Decide this repo's role** — ask me if it isn't obvious:
>    - **Spec / docs repo** — it authors and reviews specs (intent). *This is the default for a new or empty
>      repo.*
>    - **Code repo** — it implements against specs kept elsewhere; keep it pristine.
>    - **Co-located** (a solo project) — one repo does both: do the spec-repo steps **and** drop in the
>      code-repo skill.
>
> 3. **Spec / docs repo (including a fresh repo you are instantiating as one):**
>    - Copy `starter-kit/.agents/{skills,reference,templates,memory}` into this repo's `.agents/`. Put the
>      **skills** in whatever directory my agent CLI scans — `.claude/skills/` for Claude Code, otherwise
>      `.agents/skills/` — beside any skills I already have (their `pass-*`/`persona-*`/`write-*` names won't
>      collide with mine).
>    - Put `starter-kit/AGENTS.md` at my repo **root** as `AGENTS.md`. If one already exists, **merge** by
>      heading — keep my content and stop for my approval on any conflict. Add `CLAUDE.md` and `GEMINI.md` as
>      **symlinks** to `AGENTS.md` (or one-line `@AGENTS.md` aliases where symlinks don't survive).
>    - Create a top-level **`specs/`** with **one folder per feature** — `specs/<feature>/spec.swarm.md` is
>      the contract (where the `author` step writes), and that feature's supporting docs (audit, research,
>      bug-report, PRD, RFC, …) sit beside it in the same folder. Create a top-level **`decisions/`** for ADRs
>      (numbered `0001-`, `0002-`, …); findings live in `.agents/memory/`. **`.agents/` holds only tooling.**
>      The kit ships an example `specs/001-contact-form/` and a seed `decisions/0001-adopt-swarm.md` — copy
>      their shape, then replace them.
>    - Append `starter-kit/.gitignore.additions` to my `.gitignore`.
>    - Fill the `AGENTS.md` `## Commands` table from my real test/lint/build commands (read
>      `package.json`/`Makefile`/CI and confirm with me) and `## Project facts` from my stack and conventions.
>
> 4. **Code repo:** keep it **pristine** — do *not* add SOL reference cards or copy specs in (the spec is the
>    whole interface). At most, copy the one skill `docs/library/code-skills/implement-and-verify/` into my
>    skills dir (the discipline that makes parallel-agent output trustworthy), and append
>    `starter-kit/.gitignore.additions`. When I implement an obligation I prove each `VERIFY BY` and open a PR
>    naming the obligation ids — the PR is the trace and verdict; anything durable goes back to the spec repo
>    as a linked PR.
>
> 5. **Report** what you created, copied, and merged, and anything you need me to confirm. This adoption is
>    **additive** — do not delete or overwrite my files.

## What you end up with

A **spec / docs repo:**

```text
specs/<feature>/       # one folder per feature: spec.swarm.md + its supporting docs (audit/research/…)
decisions/             # project-wide ADRs, numbered (0001-, …)
.agents/
  skills/  reference/  templates/  memory/   # Swarm tooling, nothing else
AGENTS.md  (+ CLAUDE.md, GEMINI.md symlinks)
```

A **code repo:** unchanged, plus at most `.agents/skills/implement-and-verify/` and a `.gitignore` line.
No `.swarm/` directory, no mount, no version file — to upgrade, re-run the prompt against a newer checkout
(it overwrites Swarm's `pass-*`/`persona-*`/`write-*` skills and leaves yours and your specs untouched).

## Notes

- **One spec, many code repos.** Obligation ids are namespaced and SOL has cross-spec references
  (`spec-id#AC-001`), so a code repo's PR can name an obligation that lives in a central spec repo.
- **Brownfield is non-destructive.** The only merge point is the root `AGENTS.md`/`CLAUDE.md`; existing code
  is `observed` until an audit + a spec govern it (adoption never retrofits specs). See
  [`model/workspace.md`](model/workspace.md) for the source-code surface policies.
