# Evidence receipt for AUDIT-repository-gates

Sidecar to [AUDIT-repository-gates](./AUDIT-repository-gates.md). Every block is pasted command
output from 2026-11-05. Probe trees live in [probe/](./probe/); each was extracted with
`git archive ae6d2e8 skills README.md scripts docs | tar -x` (the `missing-readme` tree omits
nothing else; root `AGENTS.md`, `CLAUDE.md`, and `GEMINI.md` are never extracted into probes).

## E1. Frozen state and gate file identities

```
$ git rev-parse HEAD
ae6d2e8cf61c16f306772dcfc65e3b8cea80a7a6
$ git ls-tree HEAD scripts/ .github/workflows/ AGENTS.md
100644 blob a59f07d1d29b138575d59903d81435e1b030f947	.github/workflows/method-gates.yml
100644 blob 016d13be09d89e6f7a2696c18d293d110dc385c2	AGENTS.md
100644 blob 78e20a63d27d89a9511894d53123da1de40ca4eb	scripts/lint-accepted-adrs.sh
100755 blob e5f891184c9ec6dffc6b0354e4ecb6327392bc24	scripts/lint-all.sh
100755 blob 5bfce83409ca7c0d0c45ab34ff3e174c908e748a	scripts/lint-artifact-skills.sh
```

Mid-audit, another writer changed `scripts/lint-artifact-skills.sh` in the working tree:

```
$ git diff --stat HEAD -- scripts .github AGENTS.md
 scripts/lint-artifact-skills.sh | 3 +++
 1 file changed, 3 insertions(+)
```

The hunk inserts a thinker-vocabulary `grep -niwE` check after HEAD line 221. It is out of scope.

## E2. Current working tree run (not the frozen state)

```
$ sh scripts/lint-all.sh
--- lint-accepted-adrs ---
accepted ADR set drift: expected 187 files, found 188
  ^ lint-accepted-adrs FAILED
--- lint-artifact-skills ---
lint-artifact-skills: OK
--- adr-ranges ---
adr-ranges: OK
lint-all: FAIL
rc=1
$ CORPUS_HISTORY_BASE=ae6d2e8 sh scripts/lint-accepted-adrs.sh
accepted ADR set drift: expected 187 files, found 188
rc=1
```

## E3. Delivery controls on GitHub and locally

```
$ gh api repos/jcosta33/corpus/branches/main/protection
{"message":"Branch not protected",...,"status":"404"}gh: Branch not protected (HTTP 404)
$ gh api repos/jcosta33/corpus/rulesets
[]
$ git config --get core.hooksPath          # no output
$ ls .git/hooks | grep -v '\.sample$'       # no output
```

Recent CI runs (`gh run list --limit 8`): eight `push` events, all `success`, none `pull_request`.
The newest, run 41934540124 on `ae6d2e8`, logged:

```
CORPUS_HISTORY_BASE: 85660017a4680af405c9ac911582f5abc247f0d3
lint-accepted-adrs: OK
lint-artifact-skills: OK
adr-ranges: OK
lint-all: OK
```

## E4. Skill gate baseline on HEAD

```
$ sh probe/base/scripts/lint-artifact-skills.sh probe/base
lint-artifact-skills: OK
rc=0
```

## E5. Broken in-package link passes; escaping link fails (control)

Mutation: append `See [the guide](./guide.md).` to `probe/broken-link/skills/corpus-audit/SKILL.md`.
Control: append `See [the spec](../corpus-spec/SKILL.md).` to the same file in `probe/control`.

```
=== broken-link
lint-artifact-skills: OK
rc=0
=== control
skill link escapes package: .../probe/control/skills/corpus-audit/SKILL.md -> ../corpus-spec/SKILL.md
rc=1
=== target exists?
SKILL.md
```

## E6. Contract contradiction and removed section pass

Mutation in `probe/semantic`: delete the `## Output` heading line (HEAD line 52 of the audit skill)
and append `Write the artifact into the repository root when convenient.`

```
=== semantic
lint-artifact-skills: OK
rc=0
```

## E7. Missing files fail open

`probe/missing-readme` has no `README.md`, `AGENTS.md`, `CLAUDE.md`, or `GEMINI.md`.

```
$ sh probe/missing-readme/scripts/lint-all.sh
--- lint-accepted-adrs ---
fatal: not a git repository (or any parent up to mount point /Volumes)
  ^ lint-accepted-adrs FAILED
--- lint-artifact-skills ---
grep: .../probe/missing-readme/README.md: No such file or directory
lint-artifact-skills: OK
--- adr-ranges ---
grep: .../probe/missing-readme/AGENTS.md: No such file or directory
grep: .../probe/missing-readme/CLAUDE.md: No such file or directory
grep: .../probe/missing-readme/GEMINI.md: No such file or directory
grep: .../probe/missing-readme/README.md: No such file or directory
adr-ranges: OK
lint-all: FAIL
```

The ADR gate fails here only because the probe is not a git repository.

## E8. grep exit status masks a real range hit

Run in `probe/ranges` with the `lint-all.sh:20` pattern, under `/usr/bin/grep` (BSD grep 2.6.0,
which is what `sh` resolves locally):

```
--- hit only
HIT.md:1:Accepted decisions 0001-0187.
exit=0
--- hit + missing file
grep: MISSING.md: No such file or directory
HIT.md:1:Accepted decisions 0001-0187.
exit=2
--- missing only
exit=2
--- prose range
exit=1
--- lint-all branch on missing only
adr-ranges: OK
```

GNU grep, used on the `ubuntu-latest` runner, documents the same rule
(man7.org grep(1), EXIT STATUS): "2 if an error occurred", with exit 0 despite errors only under
`-q`. `lint-all.sh:20` passes `-nHE`, with no `-q`.

## E9. What the gates read

Whole-scope sweep of the HEAD gate files for `docs/`, `sources.md`, and `[[`: the only `docs/`
reads are `scripts/lint-accepted-adrs.sh:16-17` and `:31-32` (numbered ADR files). No line
matches a citation-key (`[[KEY]]`) check; the `[[` hits are all `[[:space:]]` character classes.
Root files read: `AGENTS.md`, `CLAUDE.md`, `GEMINI.md`, `README.md` (`lint-all.sh:21`),
`README.md` (`lint-artifact-skills.sh:256`), and `skills/` throughout.
`CLAUDE.md` and `GEMINI.md` are symlinks to `AGENTS.md` (`ls -la`).
