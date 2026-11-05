# Evidence receipt: skill gate baseline

Sidecar to [SPEC-split-skill-gate](./SPEC-split-skill-gate.md). Taken 2026-11-05 in
`/Volumes/Development/corpus`, HEAD `ae6d2e8cf61c16f306772dcfc65e3b8cea80a7a6`. Read scope:
`scripts/`, `.github/`, `AGENTS.md`.

## Working tree state

`git status --short scripts` printed ` M scripts/lint-artifact-skills.sh`. The modification appeared
during this session (file mtime 10:07; the first read showed the HEAD body). `git diff -- scripts`
shows one uncommitted hunk after HEAD line 221, written by another agent:

```
+    if grep -niwE 'philosophers?|philosoph(y|ies|ical)|thinkers?|plato(nic)?|kant(ian)?|popper(ian)?|peirce|mill|hume|stoics?|stoicism|socrat(es|ic)|aristotle|disputatio|dialectics?|dialectical|pre-?mortems?|steel-?man(ning)?' "$document"; then
+      echo "thinker or named-method vocabulary in $name: write the plain procedure ($document)" >&2; exit 1
+    fi
```

The rest of the working tree also carries uncommitted foreign edits under `skills/`, `docs/`, and
`README.md`, plus a staged new ADR.

## Gate runs

| Command | Exit | Decisive output |
| --- | --- | --- |
| `sh scripts/lint-artifact-skills.sh` (working tree) | 0 | `lint-artifact-skills: OK` |
| `sh scripts/lint-all.sh` (working tree) | 1 | `accepted ADR set drift: expected 187 files, found 188` |
| `git archive HEAD \| tar -x -C "$T"; sh "$T/scripts/lint-artifact-skills.sh" "$T"` | 0 | `lint-artifact-skills: OK` |

The `lint-all` failure comes from the foreign staged ADR, not from the skill gate. It predates this
work and stays outside its scope.

## Harness self-test

[differential-check.sh](./differential-check.sh) was run with the baseline script passed as OLD,
CATALOG, and CONTENT, seeding fixtures from a `git archive HEAD` snapshot, with the HEAD
`lint-all.sh` for phase 2. Each script copy was named `lint-artifact-skills.sh` so phase 2 matches
the gate name `lint-all.sh` calls.

| Baseline script | Gate shell | Exit | PASS lines | Labels checked | Final line |
| --- | --- | --- | --- | --- | --- |
| HEAD body | `sh` | 0 | 61 | 31 | `differential-check: OK` |
| working-tree body (with thinker check) | `sh` | 0 | 61 | 32 | `differential-check: OK` |
| HEAD body | `dash` | 0 | 61 | 31 | `differential-check: OK` |

The HEAD run reported `PASS s-thinker-vocabulary (baseline accepts; new accept; check absent in
baseline)`. The working-tree run reported `PASS s-thinker-vocabulary (owner con rejects with baseline
output)`. So the harness follows whichever baseline it is given.

I checked the first stderr line of every mutation against its intended label (working-tree run).
Each mutation triggers the check it names. For example, `c-symlink` triggers
`skill payload contains a symlink`, `s-word-relative` triggers
`incomplete artifact placement or handoff in corpus-spec`, and `s-frontmatter-contract` triggers
`artifact frontmatter contract drift in corpus-spec`.

## Old call sites in read scope

`grep -n 'lint-artifact-skills' scripts/*.sh .github/workflows/*.yml AGENTS.md`:

```
scripts/lint-all.sh:5:#   lint-artifact-skills.sh  structural gate over the artifact-author skills in skills/
scripts/lint-all.sh:13:for gate in lint-accepted-adrs lint-artifact-skills; do
scripts/lint-artifact-skills.sh:2:# lint-artifact-skills.sh — structural gate over the artifact-author skills in skills/.
scripts/lint-artifact-skills.sh:4:# Usage: scripts/lint-artifact-skills.sh [REPO_ROOT]   (default: this repo)
scripts/lint-artifact-skills.sh:291:echo "lint-artifact-skills: OK"
```

`.github/workflows/method-gates.yml` calls only `sh scripts/lint-all.sh`. `AGENTS.md` says "the skill
gate" without naming the file. This session did not read `docs/`, `skills/`, `README.md`,
`CLAUDE.md`, or `GEMINI.md`, so their counts are unknown. Wave 0 takes that count. Inside
`skills/*/`, the baseline vocabulary check (HEAD line 219, pattern `lint-[a-z-]+`) already guarantees
zero references.
