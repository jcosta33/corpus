#!/bin/sh
# lint-product-citations.sh — the ADR-0113 product-vs-docs citation gate (method-gate 0113-product-citations).
#
# Product surfaces (what a user installs and reads) must not carry the canon's internal
# provenance markers. Those markers are how the Suspec repo records WHY a decision was made
# (ADR-NNNN), what audit surfaced a fact (AUDIT-...), and where a primary source lives
# (github / doi.org URLs). They belong in the canon docs or ADRs, NOT in
# the shipped skill guides, templates, hooks, or generated runner files — a
# user reading product prose should see the rule, not the citation trail behind it.
#
# Top-level product READMEs are the one narrower class: they may link to repos/install instructions,
# but still must not carry ADR/AUDIT/DOI provenance citations.
#
# This gate greps the PRODUCT FILES for those forbidden markers and fails on any hit.
# It is a RECORD/CHECK, not an executor (ADR-0077): it reads and reports, it edits nothing.
#
# SCOPE — deliberately file-surface based, to stay low false-positive (ADR-0063: a noisy gate gets
# muted). Markdown/TOML/hook/workflow templates are shipped prose or shipped instructions. In a code
# file (e.g. suspec-mcp/src/tools.ts) grep cannot tell a forbidden citation in emitted prose from
# the same string inside a code comment or a test fixture, so code files are OUT OF SCOPE here —
# they are reviewed by a human, not linted by this gate.
#
# The linted set, per repo (sibling repos under this repository's parent by default):
#   suspec/skills/<name>/SKILL.md                 (one complete file per skill)
#   top-level product READMEs in the family        (README carve-out: repo/install links allowed)
#
# Forbidden patterns (extended regex):
#   ADR-[0-9]            an Architecture Decision Record reference
#   AUDIT-               an audit reference
#   https?://github      a GitHub source URL  (http or https; body/template files only)
#   doi.org              a DOI source URL
#
# Usage:
#   scripts/lint-product-citations.sh [REPO_PARENT_DIR]
#     REPO_PARENT_DIR  directory holding the sibling repos (suspec, suspec-cli, …).
#                      Defaults to this repository's parent. Pass a temp dir to self-test a seed.
#
# Exit: 0 when every linted file is clean; 1 on any forbidden citation; 2 on a usage/scope error.
set -eu

# --- Resolve the parent directory that holds the sibling product repos ---------
SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
DEV_DIR="${1:-$(CDPATH= cd -- "$SCRIPT_DIR/../.." && pwd)}"
if [ ! -d "$DEV_DIR" ]; then
    echo "lint-product-citations: not a directory: $DEV_DIR" >&2
    echo "  Pass the directory that holds the sibling repos (suspec, suspec-cli, …)," >&2
    echo "  or run with no argument to use this repository's parent directory." >&2
    exit 2
fi

# Forbidden-citation patterns (extended regex). A skill body carries no sourcing at all —
# including source URLs. A product README legitimately links to the repo and install instructions, so
# a README forbids only the provenance CITATIONS (ADR-/AUDIT-/doi), never github repo/install URLs.
FORBIDDEN_BODY='ADR-[0-9]|AUDIT-[A-Za-z0-9]|https?://github|doi\.org'
FORBIDDEN_README='ADR-[0-9]|AUDIT-[A-Za-z0-9]|doi\.org'

# --- Collect the in-scope product files ---------------------------------------
# Built into a newline-delimited list so paths with unusual characters survive; the find
# expressions encode the scope exactly (markdown only; the named subtrees only).
repo_dir() {
    name=$1
    if [ -d "$DEV_DIR/$name" ]; then
        printf '%s\n' "$DEV_DIR/$name"
        return
    fi
    for candidate in "$DEV_DIR"/*; do
        [ -d "$candidate" ] || continue
        url=$(git -C "$candidate" remote get-url origin 2>/dev/null || true)
        case "$url" in
            */"$name"|*/"$name".git)
                printf '%s\n' "$candidate"
                return
                ;;
        esac
    done
    printf '%s\n' "$DEV_DIR/$name"
}

SUSPEC_MAIN_DIR=$(repo_dir suspec)
SUSPEC_MCP_DIR=$(repo_dir suspec-mcp)
SUSPEC_CLI_DIR=$(repo_dir suspec-cli)

body_files=$(
    # suspec: each artifact author's SKILL.md
    if [ -d "$SUSPEC_MAIN_DIR/skills" ]; then
        find "$SUSPEC_MAIN_DIR/skills" -type f \
            \( -name 'SKILL.md' -o -path '*/references/*.md' \)
    fi
    :
)

readme_files=$(
    # Top-level product READMEs. These may carry repo/install links, but not provenance citations.
    # NB: the final command in this $(...) must succeed, or `set -e` would fail the whole assignment.
    for r in \
        "$SUSPEC_MAIN_DIR/README.md" \
        "$SUSPEC_MAIN_DIR/skills/README.md" \
        "$SUSPEC_MCP_DIR/README.md" \
        "$SUSPEC_CLI_DIR/README.md"
    do
        if [ -f "$r" ]; then printf '%s\n' "$r"; fi
    done
    :
)

files=$(printf '%s\n%s\n' "$body_files" "$readme_files" | grep . || true)

# A scope that matched nothing means the parent dir is wrong — fail loudly, don't pass vacuously.
if [ -z "$files" ]; then
    echo "lint-product-citations: no in-scope product files found under $DEV_DIR" >&2
    echo "  Expected sibling repos like $DEV_DIR/suspec and $DEV_DIR/suspec-cli." >&2
    echo "  Check the REPO_PARENT_DIR argument." >&2
    exit 2
fi

# --- Grep each file; collect offending file:line lines ------------------------
# grep -H prints file:line:match; we keep the file:line and the matched text for the report.
# `set +e` around the grep so a clean file (grep exit 1) does not trip `set -e`.
hits=$(
    printf '%s\n' "$body_files" | while IFS= read -r f; do
        [ -n "$f" ] || continue
        grep -HnE "$FORBIDDEN_BODY" "$f" 2>/dev/null || true
    done
    printf '%s\n' "$readme_files" | while IFS= read -r f; do
        [ -n "$f" ] || continue
        grep -HnE "$FORBIDDEN_README" "$f" 2>/dev/null || true
    done
)

count=$(printf '%s\n' "$files" | grep -c . || true)

if [ -n "$hits" ]; then
    echo "lint-product-citations: FAIL — forbidden citations in product files:" >&2
    printf '%s\n' "$hits" >&2
    echo "" >&2
    echo "  Product bodies/templates must not carry internal provenance markers" >&2
    echo "  (ADR-NNNN, AUDIT-…, github/doi.org URLs). Top-level product READMEs may" >&2
    echo "  link to repos/install instructions, but not to ADR/AUDIT/DOI citations." >&2
    echo "  Move the citation to the canon docs and state only the rule in" >&2
    echo "  the product file." >&2
    exit 1
fi

echo "lint-product-citations: OK — $count product file(s) clean (README repo/install links allowed)."
