# Evidence receipts for RESEARCH-gate-language

Sidecar to [the research artifact](RESEARCH-gate-language.md). Every exercise ran on 2026-11-05
on host `mac-mini-1`: macOS 27.2 (build 26B123), arm64, Xcode 27.2 (27B52). Output is untouched
except where `[...]` marks elision. Mutation exercises ran in a scratch `git clone` of
`/Volumes/Development/corpus` under `$TMPDIR`, checked out at `ae6d2e8`. The source checkout was
never modified.

## E-1 Local toolchain

```
$ ls -l /bin/sh; /bin/sh --version | head -1; awk --version | head -2
-rwxr-xr-x  1 root  wheel  166576 Oct 23 01:10 /bin/sh
GNU bash, version 3.2.57(1)-release (arm64-apple-darwin26)
awk version 20200816
$ which -a awk python3 shasum sha256sum
/usr/bin/awk
/opt/homebrew/bin/python3
/usr/bin/python3
/opt/homebrew/bin/python3
/usr/bin/shasum
/sbin/sha256sum
$ /usr/bin/python3 --version
Python 3.9.6
$ xcrun --find git; xcrun --find python3
/Applications/Xcode.app/Contents/Developer/usr/bin/git
/Applications/Xcode.app/Contents/Developer/usr/bin/python3
$ ls -l /usr/bin/python3 /usr/bin/git
-rwxr-xr-x  78 root  wheel  200560 Oct 23 01:10 /usr/bin/git
-rwxr-xr-x  78 root  wheel  200560 Oct 23 01:10 /usr/bin/python3
$ head -1 /usr/bin/shasum; file /usr/bin/shasum
#!/usr/bin/perl
/usr/bin/shasum: Perl script text executable
$ perl -v | sed -n 2p
This is perl 5, version 34, subversion 1 (v5.34.1) built for darwin-thread-multi-2level
$ which dash   # present on macOS; used below to stand in for the Ubuntu /bin/sh
/bin/dash
```

## E-2 Gates on the working tree

```
$ time sh scripts/lint-all.sh
--- lint-accepted-adrs ---
accepted ADR set drift: expected 187 files, found 188
  ^ lint-accepted-adrs FAILED
--- lint-artifact-skills ---
lint-artifact-skills: OK
--- adr-ranges ---
adr-ranges: OK
lint-all: FAIL
sh scripts/lint-all.sh  0.23s user 0.46s system 104% cpu 0.655 total
```

The seal failure is the uncommitted, staged `docs/adrs/0190-tracker-first-and-shorter-authors.md`
in the shared checkout, which belongs to other in-flight work. At committed `ae6d2e8` the seal
passes (E-4).

## E-3 CI run at HEAD (`gh run view 41934540124 --log`)

```
Image: ubuntu-26.04
Version: 20261101.186.1
[...]
2026-11-04T23:33:42.2621254Z ##[group]Run sh scripts/lint-all.sh
2026-11-04T23:33:42.2771340Z --- lint-accepted-adrs ---
2026-11-04T23:33:42.5498596Z lint-accepted-adrs: OK
2026-11-04T23:33:42.5500047Z --- lint-artifact-skills ---
2026-11-04T23:33:42.8144789Z lint-artifact-skills: OK
2026-11-04T23:33:42.8145593Z --- adr-ranges ---
2026-11-04T23:33:42.8154676Z adr-ranges: OK
2026-11-04T23:33:42.8155247Z lint-all: OK
```

## E-4 CI history and replay of past failures

```
$ gh run list --limit 300 --json conclusion,createdAt --jq 'group_by(.conclusion)|map({c:.[0].conclusion,n:length,first:(map(.createdAt)|min),last:(map(.createdAt)|max)})'
[{"c":"failure","first":"2026-06-27T17:48:22Z","last":"2026-08-03T11:43:19Z","n":35},{"c":"success","first":"2026-07-01T18:39:54Z","last":"2026-11-04T23:32:39Z","n":66}]
$ gh run view 30810645331 --log-failed
failed to get run log: HTTP 410: Server Error (https://api.github.com/repos/jcosta33/corpus/actions/runs/30810645331/logs)
```

The same HTTP 410 came back for the other five failed runs sampled. The failed step names, from
`gh api .../runs/<id>/jobs`:

```
30810645331 local-gates | Accepted ADR history | ubuntu-latest
29917311048 local-gates | Accepted ADR history | ubuntu-latest
29412993601 local-gates | Accepted ADR history | ubuntu-latest
```

Replay on macOS of those three head commits in the scratch clone:

```
39a2ad3: accepted ADR set drift: expected 165 files, found 166
1ddc725: accepted ADR set drift: expected 167 files, found 168
cb4f8e1: accepted ADR set drift: expected 157 files, found 160
b872f45: lint-accepted-adrs: OK
ae6d2e8: lint-accepted-adrs: OK
```

A search of commit subjects and bodies touching `scripts/` and `.github/` for
`portab|bsd|gnu|mawk|gawk|macos|dash|posix|locale|LC_ALL|ubuntu|linux` found one hit. It was about
hard-coded `/Users/josecosta` paths, not tool dialects.

## E-5 Mutation exercises, `sh` (bash 3.2 in POSIX mode) against `dash`

| Mutation | `sh` | `dash` |
| --- | --- | --- |
| None (clean `ae6d2e8`) | rc 0 | rc 0 |
| Stray `skills/corpus-spec/extra.md` | rc 1, `unexpected skill payload file: [...]extra.md` | rc 1, same message |
| Link `../../docs/method.md` added to a skill | rc 1, `skill link escapes package: [...]` | rc 1, same message |
| Link `./nope/a.md` (missing directory) added to a skill | rc 1, `line 212: cd: [...]/./nope: No such file or directory` | rc 2, `212: cd: can't cd to [...]/./nope` |

Seal probe: the script copied with `EXPECTED_COUNT=188` and the staged file
`docs/adrs/0999-a b.md`, a copy of ADR 0001.

```
shasum: b.md: No such file or directory
lint-accepted-adrs: OK
shasum: b.md: No such file or directory
lint-accepted-adrs: OK
```

The digest still matched the 187-file seal, so the whitespace-named file was hashed nowhere.
Current ADR names: `ls docs/adrs | grep -c ' '` gives `0`. Every entry matches
`^[0-9]{4}-[a-z0-9-]+\.md$` or `README.md`.

## E-6 Python standard-library reproduction of the seal at `ae6d2e8`

```
$ python3 -I -c '
import hashlib,subprocess,re,sys
files=[f for f in subprocess.run(["git","ls-files","docs/adrs/*.md"],capture_output=True,text=True,check=True).stdout.splitlines() if re.fullmatch(r"docs/adrs/[0-9]{4}-[^/]+\.md",f)]
lines="".join(hashlib.sha256(open(f,"rb").read()).hexdigest()+"  "+f+"\n" for f in files)
print(len(files), hashlib.sha256(lines.encode()).hexdigest())'
187 d7a79f141bee818ab66d5e3c5f5779e1f89142cd15bdc24a55df0e21aa716474
$ grep -n EXPECTED_ scripts/lint-accepted-adrs.sh | head -2
5:EXPECTED_COUNT=187
6:EXPECTED_DIGEST=d7a79f141bee818ab66d5e3c5f5779e1f89142cd15bdc24a55df0e21aa716474
$ time (/usr/bin/python3 -I -c pass)
( /usr/bin/python3 -I -c pass; )  0.02s user 0.01s system 82% cpu 0.037 total
```

The one-liner ran under Homebrew Python 3.15.2. It uses only syntax and stdlib calls that Python
3.9 also provides, but it was not re-run under `/usr/bin/python3`.

## E-7 Ubuntu 26.04 package priorities (Launchpad API, `resolute/amd64`, fetched 2026-11-05)

```
python3:   3.14.3-0ubuntu2 IMPORTANT Release
mawk:      1.3.4.20260129-1 REQUIRED Release Published
gawk:      1:5.3.2-1ubuntu1.1 OPTIONAL Updates Published
dash:      0.5.12-12ubuntu3 REQUIRED Release Published
perl-base: 5.40.1-7ubuntu0.3 REQUIRED Updates Published
perl:      5.40.1-7ubuntu0.3 OPTIONAL Updates Published
```

## E-8 Script size

```
$ wc -l scripts/*
      50 scripts/lint-accepted-adrs.sh
      33 scripts/lint-all.sh
     288 scripts/lint-artifact-skills.sh
     371 total
```

`lint-artifact-skills.sh` has eight `awk` invocations (lines 32, 63, 74, 78, 120, 142, 171, 186),
and `lint-accepted-adrs.sh` has one (line 44).

These counts match committed `ae6d2e8`: `git show ae6d2e8:scripts/lint-artifact-skills.sh | wc -l`
gives `288`. While this research ran, other in-flight work added an uncommitted three-line
`grep -niwE` vocabulary check to the working-tree copy, which now has 291 lines. That check came in
after the reads above. The E-5 exercises ran on the committed version.
