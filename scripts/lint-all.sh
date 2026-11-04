#!/bin/sh
# lint-all.sh — run every repository gate. Exits zero only when every gate is clean.
#
#   lint-accepted-adrs.sh    every numbered accepted ADR matches the frozen digest
#   lint-artifact-skills.sh  structural gate over the artifact-author skills in skills/
#   ADR ranges               bootstrap files link the ledger instead of restating its bounds
set -eu
export LC_ALL=C

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
rc=0

for gate in lint-accepted-adrs lint-artifact-skills; do
  echo "--- $gate ---"
  sh "$ROOT/scripts/$gate.sh" "$ROOT" || { rc=1; echo "  ^ $gate FAILED" >&2; }
done

echo "--- adr-ranges ---"
ENDASH=$(printf '\342\200\223')
if grep -nHE "0[0-9]{3}[[:space:]]*(-|$ENDASH)[[:space:]]*0[0-9]{3}" \
  "$ROOT/AGENTS.md" "$ROOT/CLAUDE.md" "$ROOT/GEMINI.md" "$ROOT/README.md"; then
  rc=1
  echo "  ^ adr-ranges FAILED: link the ledger instead of restating ADR ranges" >&2
else
  echo "adr-ranges: OK"
fi

if [ "$rc" -eq 0 ]; then
  echo "lint-all: OK"
else
  echo "lint-all: FAIL" >&2
fi
exit "$rc"
