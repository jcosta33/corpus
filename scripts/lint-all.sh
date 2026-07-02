#!/bin/sh
# lint-all.sh — run every shipped method-gate (ADRs 0113-0118) over the Suspec family.
#
# A single entry point for the scriptable gates. Each is a RECORD/CHECK, not an executor
# (ADR-0077): it reads and reports, edits nothing. Aggregates: exits 0 only if every gate is clean,
# else non-zero (the first failing gate's findings are printed above).
#
#   0113  lint-product-citations.sh   no ADR/AUDIT/source-URL citations in product bodies (READMEs may link)
#   0117  lint-count-ranges.sh        no hardcoded count-bearing ADR ranges in bootstrap/reference prose
#   0115  check-catalog-freshness.sh  a synced workspace catalog copy must match its source (no orphaned copy)
#
# The suspec-cli spec-side check (0116, active spec → `## Execution`) ships in `suspec check`, not here.
# Per ADR-0077, wiring these into a given repo's CI is that repo's call; this script is what CI would run.
#
# Usage: scripts/lint-all.sh [REPO_PARENT_DIR]   (default: this repo's parent directory)
# REPO_PARENT_DIR feeds lint-product-citations; the other two gates resolve their roots from
# their own script location / env vars and ignore the positional.
set -eu

HERE=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
DEV_DIR="${1:-$(CDPATH= cd -- "$HERE/../.." && pwd)}"

rc=0
for gate in lint-product-citations lint-count-ranges check-catalog-freshness lint-artifact-refs; do
    echo "--- $gate ---"
    if ! sh "$HERE/$gate.sh" "$DEV_DIR"; then
        rc=1
        echo "  ^ $gate FAILED" >&2
    fi
    echo ""
done

if [ "$rc" -eq 0 ]; then
    echo "lint-all: OK — every method-gate is clean."
else
    echo "lint-all: FAIL — at least one method-gate found a violation (see above)." >&2
fi
exit "$rc"
