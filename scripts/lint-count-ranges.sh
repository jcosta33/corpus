#!/bin/sh
# lint-count-ranges.sh — the 0117-count-ranges method-gate (ADR-0117).
#
# WHY. Bootstrap/reference prose (AGENTS.md / CLAUDE.md / GEMINI.md / README.md at each repo root)
# must NOT hardcode a count-bearing ADR range like "ADRs 0001–0108". Such a range is a snapshot:
# it goes stale the moment ADR-0109 lands, and a stale "we have N ADRs / 0001–0NNN" line in the
# files agents read first is worse than no number at all. The single source of truth for the ADR
# set is the LEDGER (suspec/docs/adrs/README.md); bootstrap files should LINK to it, not restate
# its bounds. This gate fails the build when a hardcoded ADR range reappears in those prose files.
#
# It is a RECORD/CHECK, not an executor (ADR-0077): it greps and reports; it edits nothing.
#
# WHAT it flags. The 4-digit ADR-range shape only: `0NNN <dash> 0NNN` (e.g. 0001–0108), where the
# dash is an ASCII hyphen "-" or a Unicode en-dash "–". The leading-zero / 4-digit anchor is the
# low-FP guard (ADR-0063: a noisy gate gets muted) — real ADR ids are 0001..0999, all leading-zero,
# so version numbers (1.2-3.4), date ranges (2024-2025), and 2-digit path refs like `docs/01–10`
# do NOT match. Slash-joined cross-refs ("ADR-0056/0077") are not ranges and do NOT match.
#
# WHAT it scans. AGENTS.md / CLAUDE.md / GEMINI.md / README.md at each repo root in the family.
# The LEDGER (suspec/docs/adrs/README.md) is EXCLUDED: it is the source of truth and legitimately
# lists ranges.
#
# Usage: run from anywhere.  `sh scripts/lint-count-ranges.sh`  → exit 0 clean, non-zero on a hit.
#   Override the roots it scans with SUSPEC_FAMILY_ROOTS (space-separated absolute paths).
set -eu

# Force a byte-stable locale so the Unicode en-dash in the pattern and in files is matched
# consistently regardless of the caller's LC_* environment.
LC_ALL=C
export LC_ALL

# The ADR-range shape: 0NNN <opt ws> (hyphen|en-dash) <opt ws> 0NNN. The en-dash U+2013 is written
# here as its UTF-8 bytes (\342\200\223) so this stays a pure-ASCII, portable source file.
#
# The dash is an ALTERNATION "(-|<en-dash>)", not a bracket class "[-<en-dash>]", on purpose: under
# LC_ALL=C the en-dash is 3 bytes, and a bracket class would treat them as 3 separate single-byte
# members — so "0NNN[…]0NNN" would demand exactly one byte where the file has three and never match.
# As an alternation the 3-byte en-dash is matched as one literal sequence, locale-independently.
ENDASH=$(printf '\342\200\223')
RANGE_RE="0[0-9][0-9][0-9][[:space:]]*(-|${ENDASH})[[:space:]]*0[0-9][0-9][0-9]"

# The family roots to scan. Pass their parent directory or override with SUSPEC_FAMILY_ROOTS.
if [ -n "${SUSPEC_FAMILY_ROOTS:-}" ]; then
    ROOTS="$SUSPEC_FAMILY_ROOTS"
else
    # Resolve this repo from the script and current siblings by public repository name.
    SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
    SUSPEC_ROOT=$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)
    PARENT=${1:-$(CDPATH= cd -- "$SUSPEC_ROOT/.." && pwd)}
    repo_dir() {
        name=$1
        if [ -d "$PARENT/$name" ]; then
            printf '%s\n' "$PARENT/$name"
            return
        fi
        for candidate in "$PARENT"/*; do
            [ -d "$candidate" ] || continue
            url=$(git -C "$candidate" remote get-url origin 2>/dev/null || true)
            case "$url" in
                */"$name"|*/"$name".git)
                    printf '%s\n' "$candidate"
                    return
                    ;;
            esac
        done
    }
    roots="$SUSPEC_ROOT"
    for name in suspec-cli suspec-mcp; do
        dir=$(repo_dir "$name")
        [ -n "$dir" ] && roots="$roots $dir"
    done
    ROOTS="$roots"
fi

# The target bootstrap/reference prose files at each root.
TARGETS="AGENTS.md CLAUDE.md GEMINI.md README.md"

# The ledger is the source of truth and legitimately lists ranges — never flag it.
LEDGER_REL="docs/adrs/README.md"

hits=0
scanned=0
for root in $ROOTS; do
    [ -d "$root" ] || continue
    ledger=$(CDPATH= cd -- "$root" 2>/dev/null && pwd)/"$LEDGER_REL"
    for name in $TARGETS; do
        file="$root/$name"
        [ -f "$file" ] || continue
        # Defensive: never scan the ledger even if a root's target resolves onto it.
        [ "$file" = "$ledger" ] && continue
        scanned=$((scanned + 1))
        # grep -n prints file:line:match. -E for the alternation/quantifiers, -H to force the
        # filename prefix (so a single-file family still prints file:line). `command grep` bypasses
        # any grep shell function/alias so the real grep runs regardless of the caller's environment.
        if matches=$(command grep -nHE "$RANGE_RE" "$file"); then
            # Found at least one hardcoded ADR range in this prose file.
            echo "$matches"
            n=$(printf '%s\n' "$matches" | grep -c .)
            hits=$((hits + n))
        fi
    done
done

if [ "$hits" -gt 0 ]; then
    echo "" >&2
    echo "lint-count-ranges: FAIL — $hits hardcoded ADR range(s) in bootstrap/reference prose." >&2
    echo "  A count-bearing ADR range (e.g. \"0001${ENDASH}0108\") goes stale the moment the next ADR" >&2
    echo "  lands. Bootstrap files (AGENTS/CLAUDE/GEMINI/README) must LINK to the ledger" >&2
    echo "  (docs/adrs/README.md), the single source of truth, not restate its bounds." >&2
    echo "  Replace the hardcoded range above with a link to the ledger." >&2
    exit 1
fi

echo "lint-count-ranges: OK — no hardcoded ADR ranges in $scanned bootstrap/reference file(s)."
