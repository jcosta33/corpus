# Evidence receipt for RESEARCH-gate-language

Run date: 2026-11-05. Host: macOS 27.2 (build 26B123), arm64. Target: `jcosta33/corpus` at
`ae6d2e8` (clean clone in a temporary directory; the live checkout carried another agent's
uncommitted ADR 0190, which makes the seal report `expected 187 files, found 188`, so the
live tree was not used for probes).

## E1. Local tool versions

```
$ /bin/sh --version | head -1
GNU bash, version 3.2.57(1)-release (arm64-apple-darwin26)
$ awk --version
awk version 20200816
$ /usr/bin/python3 --version ; /opt/homebrew/bin/python3 --version
Python 3.9.6
Python 3.15.2
$ xcrun --find git ; xcrun --find python3
/Applications/Xcode.app/Contents/Developer/usr/bin/git
/Applications/Xcode.app/Contents/Developer/usr/bin/python3
$ ls -la /usr/bin/git /usr/bin/python3 /usr/bin/perl /usr/bin/shasum
-rwxr-xr-x  78 root  wheel  200560 Oct 23 01:10 /usr/bin/git
-rwxr-xr-x   1 root  wheel  167184 Oct 23 01:10 /usr/bin/perl
-rwxr-xr-x  78 root  wheel  200560 Oct 23 01:10 /usr/bin/python3
-rwxr-xr-x   2 root  wheel    9979 Oct 23 01:10 /usr/bin/shasum
$ head -1 /usr/bin/shasum
#!/usr/bin/perl
$ which sha256sum ; sha256sum --version
/sbin/sha256sum
sha256sum (Darwin) 1.0
```

No `gawk` or `mawk` is installed locally; no container runtime is available.

## E2. Clean run at HEAD

```
### /bin/sh
lint-accepted-adrs: OK
lint-artifact-skills: OK
### /bin/dash
lint-accepted-adrs: OK
lint-artifact-skills: OK
$ /usr/bin/time -p sh scripts/lint-all.sh
lint-all: OK
real 0.52
user 0.20
sys 0.37
```

## E3. Fault injection (macOS, BSD awk 20200816)

Each defect was applied to the clone, both shells ran the named gate, then `git checkout -- .`
restored the tree.

```
F1-self-named | /bin/sh | rc=1 | skill description names itself: corpus-spec
F1-self-named | /bin/dash | rc=1 | skill description names itself: corpus-spec
F3-broken-readme-link | /bin/sh | rc=1 | broken relative link: .../skills/README.md -> ./missing.md
F3-broken-readme-link | /bin/dash | rc=1 | broken relative link: .../skills/README.md -> ./missing.md
F4-link-escape | /bin/sh | rc=1 | skill link escapes package: .../skills/corpus-spec/SKILL.md -> ../../README.md
F4-link-escape | /bin/dash | rc=1 | skill link escapes package: .../skills/corpus-spec/SKILL.md -> ../../README.md
F5-adr-body | /bin/sh | rc=1 | accepted ADR body drift: e32edf0e65759a6ed6d2ebe12343a12e5aeb854ac7254ba157223dcad404873b
F5-adr-body | /bin/dash | rc=1 | accepted ADR body drift: e32edf0e65759a6ed6d2ebe12343a12e5aeb854ac7254ba157223dcad404873b
F7-sibling | /bin/sh | rc=1 | sibling skill named in corpus-spec: corpus-audit (...)
F7-sibling | /bin/dash | rc=1 | sibling skill named in corpus-spec: corpus-audit (...)
F8-desc-colon | /bin/sh | rc=1 | invalid skill frontmatter: corpus-spec
F8-desc-colon | /bin/dash | rc=1 | invalid skill frontmatter: corpus-spec
F10-abs-source | /bin/sh | rc=1 | absolute local source example in corpus-spec
F10-abs-source | /bin/dash | rc=1 | absolute local source example in corpus-spec
F11-abs-source-block | /bin/sh | rc=1 | absolute local source example in corpus-spec
F11-abs-source-block | /bin/dash | rc=1 | absolute local source example in corpus-spec
F12-fragment-link | /bin/sh | rc=1 | fragment link is unsupported: .../skills/corpus-spec/SKILL.md
F12-fragment-link | /bin/dash | rc=1 | fragment link is unsupported: .../skills/corpus-spec/SKILL.md
```

Injections: F1 description begins `corpus-spec writes`; F3 appends `[x](./missing.md)` to
`skills/README.md`; F4 appends `[x](../../README.md)` to a skill; F5 appends one space to ADR 0001;
F7 appends `See corpus-audit.`; F8 description begins `Note: write`; F10 appends
`sources: [/etc/passwd]`; F11 appends a block list item `"~/x.md"`; F12 appends `[x](./SKILL.md#a)`.
A planned extra-payload-file probe (F2) was not run because its cleanup needed a file removal.

## E4. CI history (read-only `gh`)

```
$ gh run list --limit 100 ... | Counter(conclusion)
Counter({'success': 66, 'failure': 34})
$ gh run view <failed id> --log-failed
failed to get run log: HTTP 410: Server Error (...)
```

Every failed run in that window was dated 2026-08-03 or earlier; logs returned HTTP 410. Check-run
annotations for 14 sampled failures carry only `Process completed with exit code 1.` (or
`Not Found` from the since-deleted cross-repository job), so failure causes are unrecoverable.

Runner image per run, from the run log `Runner Image` group:

```
41934540124 Image: ubuntu-26.04   (2026-11-04, ae6d2e8, success)
41934093280 Image: ubuntu-26.04   (2026-11-04, 8566001, success)
41933520923 Image: ubuntu-26.04   (2026-11-04, e8caa16, success)
33013715166 Image: ubuntu-24.04   (2026-08-26, d3f14fb, success)
32308754915 Image: ubuntu-24.04   (2026-08-19, b5a0a46, success)
```

Gate output in run 41934540124:

```
lint-accepted-adrs: OK
lint-artifact-skills: OK
adr-ranges: OK
lint-all: OK
```

History search: `git log --all -i -E --grep='portab|BSD|GNU|mawk|gawk|macos|ubuntu|posix|locale|LC_ALL|shasum|sha256sum|python'`
returned five commits; none changes a gate for a platform difference. `9cdcea0` fixed a BSD `cp -r`
symlink difference in documented adoption commands, not in a gate. Commit `e8caa16` deleted
`scripts/test-lint-artifact-skills.sh` (159 lines), the gate's self-test.

## E5. Construct counts in the gates

```
lint-accepted-adrs.sh: posix-classes=0 grep=2 sed=2 awk=1 find=0
lint-all.sh: posix-classes=2 grep=1 sed=0 awk=0 find=0
lint-artifact-skills.sh: posix-classes=36 grep=19 sed=4 awk=8 find=9
$ wc -l scripts/*
      50 scripts/lint-accepted-adrs.sh
      33 scripts/lint-all.sh
     288 scripts/lint-artifact-skills.sh
```

Counts are regex matches on invocation sites and `[[:class:]]` tokens; they approximate
translation surface, not complexity.

## E6. Python `re` and POSIX bracket classes

```
$ /usr/bin/python3 -I -W error -c 'import re; re.compile("[[:space:]]+")'
FutureWarning: Possible nested set at position 1
$ /usr/bin/python3 -I -c 'import re; print(bool(re.fullmatch("[[:space:]]+","  ")), bool(re.fullmatch("[[:space:]]+",":")))'
False False
```

## E7. Standard-library port of the ADR seal

```python
import hashlib, re, subprocess, sys
root = sys.argv[1]
out = subprocess.run(["git", "-C", root, "ls-files", "docs/adrs/*.md"], check=True, capture_output=True, text=True).stdout
files = [f for f in out.splitlines() if re.fullmatch(r"docs/adrs/[0-9]{4}-[^/]+\.md", f)]
lines = []
for f in files:
    with open(f"{root}/{f}", "rb") as h:
        lines.append(f"{hashlib.sha256(h.read()).hexdigest()}  {f}\n")
print(len(files), hashlib.sha256("".join(lines).encode()).hexdigest())
```

```
Python 3.9.6
187 d7a79f141bee818ab66d5e3c5f5779e1f89142cd15bdc24a55df0e21aa716474
real 0.11
Python 3.15.2
187 d7a79f141bee818ab66d5e3c5f5779e1f89142cd15bdc24a55df0e21aa716474
real 0.07
EXPECTED_COUNT=187
EXPECTED_DIGEST=d7a79f141bee818ab66d5e3c5f5779e1f89142cd15bdc24a55df0e21aa716474
```

The prototype omits the history-base check; it proves digest equivalence only.

## E8. `shasum` versus native `sha256sum` on macOS

```
$ shasum -a 256 README.md ; /sbin/sha256sum README.md
3d3fb508f66074de85c6e76381e45b2411338e4eb9385de5583125c8f9fb6d54  README.md
3d3fb508f66074de85c6e76381e45b2411338e4eb9385de5583125c8f9fb6d54  README.md
$ printf 'a\n' | /sbin/sha256sum ; printf 'a\n' | shasum -a 256
87428fc522803d31065e7bce3cf03fe475096631e5e07bbd7a0fde60c4cf25c7  -
87428fc522803d31065e7bce3cf03fe475096631e5e07bbd7a0fde60c4cf25c7  -
```

## E9. External sources (fetched 2026-11-05)

- S1 `actions/runner-images` README: `ubuntu-latest` row lists Ubuntu 24.04; "The `-latest`
  migration process is gradual and happens over 1-2 months".
  https://github.com/actions/runner-images
- S2 Ubuntu 24.04 image readme, Image Version 20261026.354.1: Python 3.12.3, Perl 5.38.2,
  Bash 5.2.21, Dash 0.5.12-6ubuntu5; no awk entry.
  https://raw.githubusercontent.com/actions/runner-images/main/images/ubuntu/Ubuntu2404-Readme.md
- S3 Ubuntu 26.04 image readme, Image Version 20261026.180.1: OS 26.04.1 LTS, Python 3.14.4,
  Perl 5.40.1, Bash 5.3.9, Dash 0.5.12-12ubuntu3; no awk entry; announcement
  "`ubuntu-latest` label will use Ubuntu 26.04 in November 2026".
  https://raw.githubusercontent.com/actions/runner-images/main/images/ubuntu/Ubuntu2604-Readme.md
- S4 Ubuntu noble `mawk` package: version 1.3.4.20240123-1build1. https://packages.ubuntu.com/noble/mawk
- S5 macOS Catalina 10.15 release notes (50911608): scripting runtimes "such as Python, Ruby,
  and Perl" are included for legacy compatibility; future versions "won't include" them by default.
  https://developer.apple.com/documentation/macos-release-notes/macos-catalina-10_15-release-notes
- S6 macOS 12.3 release notes: "Python 2.7 was removed from macOS in this update."
  https://developer.apple.com/documentation/macos-release-notes/macos-12_3-release-notes
- S7 PEP 596: "As of 2025-10-31, 3.9 has reached the end-of-life phase"; 3.9.25 final.
  https://peps.python.org/pep-0596/
- S8 POSIX.1-2024 (Issue 8) `find`: the primaries list contains `-depth` but no `-mindepth` or
  `-maxdepth`. https://pubs.opengroup.org/onlinepubs/9799919799/utilities/find.html
