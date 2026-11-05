# Run notes for SPEC-split-skill-gate

Back to the spec: [SPEC-split-skill-gate.md](SPEC-split-skill-gate.md). Harness:
[differential.sh](differential.sh).

## Tracker

The repository `jcosta33/corpus` has issues enabled. It has no spec form: `.github/` holds only
`workflows/method-gates.yml`, and the GitHub contents API confirms that. So the file is the spec and
nothing was filed. `gh issue list` returned no open issues to cite as sources.

## Harness receipts (2026-11-05)

These runs used the reference with SHA-256
`157e69822789ef388534c5a0b9bfdc8d517329075f42f375db5a53dc63bd0a5b`.

- `SELFTEST=1 sh differential.sh ../../../../../corpus - all` reported every clean, strings, and
  fixture line as `PASS`, then `differential: OK`. In this mode the reference is the catalog side
  and a no-op is the content side.
- I read the first stderr line of every fixture. Each one names the check that its Baseline row
  assigns.
- A negative control set both split sides to the working-tree reference and BASE to `HEAD`. It
  failed every catalog and content fixture on ownership, as intended. It also reported
  `INERT content-vocab-thinker`, because `HEAD` lacks that uncommitted check.
- A second negative control set both split sides to a no-op stub. The `strings` check then failed
  and listed the literals that were lost.
- The first harness draft copied only `skills/` and `README.md`. The clean tree failed with
  `broken relative link: .../skills/README.md -> ../docs/formats.md`, which masked the late
  fixtures. The harness now copies the whole working tree, minus `.git`, and every fixture selector
  runs the clean check first.

## Decisions settled without the human

No question met the bar for asking: material behavior, public contract, security, cost, or an
irreversible choice. These are the engineering calls, each with its recommendation applied:

- New script names: `lint-skill-catalog.sh` and `lint-skill-content.sh`. They are reversible and
  follow the `lint-*.sh` pattern.
- The payload-shape checks inside the per-skill loop go to the catalog gate, because they inspect
  which files exist and not what they say. The product README checks and the catalog link checks
  also go to the catalog gate.
- Shared helpers and the expected manifest move to one sourced file, so no rule has two
  definitions. The intent says two gate scripts; the sourced file is not a gate, and `lint-all.sh`
  never runs it.
- No compatibility shim for the old path. Its only caller in the readable scope is `lint-all.sh`,
  and CI calls only `lint-all.sh`.
- Losing fail-fast across the two gates is accepted as retired behavior. The `lint-all.sh` exit
  status does not change.

## Incomplete verification

- I did not inspect `docs/`, `skills/`, `README.md`, `CLAUDE.md`, or `GEMINI.md` for references to
  `lint-artifact-skills`, because the trial limited reads to `scripts/`, `.github/`, and
  `AGENTS.md`. AC-007 and Wave 2 cover that sweep at implementation time. A historical receipt
  under `docs/research/` that names the old script would trigger the Cutover abort condition.
- Another lane edited `scripts/lint-artifact-skills.sh` during authoring and has not committed the
  edit. It added the thinker-vocabulary check. The working tree's ADR seal also fails because ADR
  0190 is uncommitted. The Cutover entry conditions pin both.
- The harness has not run against a real split, because none exists yet.
