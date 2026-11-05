#!/bin/sh
# differential-check.sh: prove a split skill gate rejects and accepts exactly what the baseline does.
#
# Usage: sh differential-check.sh OLD CATALOG CONTENT SOURCE_ROOT [LINT_ALL]
#
#   OLD          baseline gate script (extract it with `git show BASE:scripts/lint-artifact-skills.sh`)
#   CATALOG      new catalog, manifest, and payload gate
#   CONTENT      new per-skill content gate
#   SOURCE_ROOT  tree whose skills/ and README.md seed every fixture (use a `git archive BASE` snapshot)
#   LINT_ALL     optional lint-all.sh to prove it runs both gates and fails when either fails
#
# Set GATE_SH=dash to run every gate under dash, the /bin/sh of the ubuntu-latest CI runner.
#
# Phase 1 builds one fixture per mutation. When OLD rejects a fixture, the owner script MUST also
# reject it and print every stdout and stderr line OLD printed. When OLD accepts it, both new scripts
# MUST accept it. Every error label in OLD must be triggered by at least one mutation.
# Self-test before implementation: pass OLD as OLD, CATALOG, and CONTENT.
set -eu
export LC_ALL=C

OLD=$1 CATALOG=$2 CONTENT=$3 SOURCE=$4 LINT_ALL=${5:-}
GATE_SH=${GATE_SH:-sh}
WORK=$(mktemp -d)
echo "fixtures: $WORK"
failures=0
: > "$WORK/old-stderr-all"

note_fail() { echo "FAIL $1" >&2; failures=$((failures + 1)); }

fixture() {
  dir="$WORK/fx-$1"
  mkdir -p "$dir"
  cp -R "$SOURCE/." "$dir/"
  printf '%s\n' "$dir"
}

run_gate() { # script root prefix -> prints exit status
  set +e
  $GATE_SH "$1" "$2" > "$3.out" 2> "$3.err"
  status=$?
  set -e
  printf '%s\n' "$status"
}

contains_all() { # needle-file haystack-file
  while IFS= read -r line; do
    grep -Fxq -- "$line" "$2" || return 1
  done < "$1"
}

mutate() { # id dir
  S=skills/corpus-spec/SKILL.md
  R=skills/README.md
  cd "$2"
  case $1 in
    clean) ;;
    c-missing-catalog) mv skills skills.gone ;;
    c-extra-directory) mkdir skills/corpus-extra ;;
    c-missing-payload) mv "$S" skills/corpus-spec/SKILL.gone ;;
    c-missing-catalog-row) perl -ni -e 'print unless /\(\.\/corpus-spec\/SKILL\.md\)/' "$R" ;;
    c-catalog-label) perl -pi -e 's{\[`corpus-spec`\]\(\./corpus-spec/}{[`corpus-specx`](./corpus-spec/}' "$R" ;;
    c-non-markdown) : > skills/corpus-spec/notes.txt ;;
    c-symlink) ln -s SKILL.md skills/corpus-spec/alias.md ;;
    c-appendix-directory) mkdir skills/corpus-spec/references ;;
    c-unexpected-file) : > skills/corpus-spec/notes.md ;;
    c-readme-provenance) printf 'ADR-0001\n' >> README.md ;;
    c-catalog-provenance) printf 'AUDIT-1\n' >> "$R" ;;
    c-catalog-reference-link) printf '[a][b]\n' >> "$R" ;;
    c-catalog-complex-link) printf '[a](<b>)\n' >> "$R" ;;
    c-catalog-unsafe-link) printf '[a](javascript:void)\n' >> "$R" ;;
    c-catalog-fragment-link) printf '[a](./corpus-spec/SKILL.md#x)\n' >> "$R" ;;
    c-catalog-broken-link) printf '[a](./missing.md)\n' >> "$R" ;;
    c-sources-broken-link) printf '[a](./missing.md)\n' >> skills/sources.md ;;
    s-frontmatter-name) perl -pi -e 's/^name: corpus-spec$/name: corpus-other/' "$S" ;;
    s-frontmatter-key) perl -pi -e 'print "extra: value\n" if $. == 2' "$S" ;;
    s-description-self) perl -pi -e 's/^(description: .*)$/$1 See corpus-spec./' "$S" ;;
    s-line-cap) perl -e 'print "\n" x 500' >> "$S" ;;
    s-reference-link) printf '[a][b]\n' >> "$S" ;;
    s-complex-link) printf '[a](<b>)\n' >> "$S" ;;
    s-unsafe-link) printf '[a](javascript:void)\n' >> "$S" ;;
    s-fragment-link) printf '[a](./SKILL.md#x)\n' >> "$S" ;;
    s-root-relative) printf '[a](/etc/hosts)\n' >> "$S" ;;
    s-link-escape) printf '[a](../README.md)\n' >> "$S" ;;
    s-internal-vocabulary) printf 'SPINE-START\n' >> "$S" ;;
    s-thinker-vocabulary) printf 'Plato\n' >> "$S" ;;
    s-external-dependency) printf 'see ../other/SKILL.md\n' >> "$S" ;;
    s-sibling-named) printf 'corpus-audit\n' >> "$S" ;;
    s-fenced-output) perl -pi -e '$_ .= "```\n" if /^## Output$/' "$S" ;;
    s-artifact-heading) perl -pi -e 's/^## Artifact$/## Placement/' "$S" ;;
    s-close-heading) perl -pi -e 's/^## Close$/## Ending/' "$S" ;;
    s-neutral-root) perl -pi -e 's{\Q~/.agents/artifacts/<workspace>/\E}{~/elsewhere/}g' "$S" ;;
    s-word-absolute) perl -0pi -e 's/absolute//gi' "$S" ;;
    s-word-repository) perl -0pi -e 's/repository//gi' "$S" ;;
    s-word-vendor) perl -0pi -e 's/vendor//gi' "$S" ;;
    s-word-temporary) perl -0pi -e 's/temporary//gi' "$S" ;;
    s-word-collision) perl -0pi -e 's/collision//gi' "$S" ;;
    s-word-unwritable) perl -0pi -e 's/unwritable|blocked\s+write//gi' "$S" ;;
    s-word-return-only) perl -0pi -e 's/return\s+only//gi' "$S" ;;
    s-word-relative) perl -0pi -e 's/relative\s+to\s+the\s+artifact//gi' "$S" ;;
    s-source-list) printf 'sources:\n  - /abs/source.md\n' >> "$S" ;;
    s-source-inline) printf 'sources: [~/abs/source.md]\n' >> "$S" ;;
    s-lifecycle-delete) perl -0pi -e 's/delete//gi' "$S" ;;
    s-lifecycle-leave) perl -0pi -e 's/leave//gi' "$S" ;;
    s-lifecycle-promote) perl -0pi -e 's/promote//gi' "$S" ;;
    s-lifecycle-sidecar) perl -0pi -e 's/sidecar//gi' "$S" ;;
    s-lifecycle-downstream) perl -0pi -e 's/downstream\s+step//gi' "$S" ;;
    s-provenance-url) printf 'https://github.com/x\n' >> "$S" ;;
    s-provenance-doi) printf 'doi.org\n' >> "$S" ;;
    s-provenance-audit) printf 'AUDIT-1\n' >> "$S" ;;
    s-type-ownership) printf 'type: audit\n' >> "$S" ;;
    s-frontmatter-contract) perl -pi -e 's/^id: SPEC-/id: SPECX-/' "$S" ;;
    *) echo "unknown mutation: $1" >&2; exit 2 ;;
  esac
  cd - > /dev/null
}

MUTATIONS='clean
c-missing-catalog c-extra-directory c-missing-payload c-missing-catalog-row c-catalog-label
c-non-markdown c-symlink c-appendix-directory c-unexpected-file c-readme-provenance
c-catalog-provenance c-catalog-reference-link c-catalog-complex-link c-catalog-unsafe-link
c-catalog-fragment-link c-catalog-broken-link c-sources-broken-link
s-frontmatter-name s-frontmatter-key s-description-self s-line-cap s-reference-link
s-complex-link s-unsafe-link s-fragment-link s-root-relative s-link-escape
s-internal-vocabulary s-thinker-vocabulary s-external-dependency s-sibling-named
s-fenced-output s-artifact-heading s-close-heading s-neutral-root s-word-absolute
s-word-repository s-word-vendor s-word-temporary s-word-collision s-word-unwritable
s-word-return-only s-word-relative s-source-list s-source-inline s-lifecycle-delete
s-lifecycle-leave s-lifecycle-promote s-lifecycle-sidecar s-lifecycle-downstream
s-provenance-url s-provenance-doi s-provenance-audit s-type-ownership s-frontmatter-contract'

# Phase 1: differential over mutations.
for id in $MUTATIONS; do
  dir=$(fixture "$id")
  mutate "$id" "$dir"
  p="$WORK/$id"
  old=$(run_gate "$OLD" "$dir" "$p.old")
  cat=$(run_gate "$CATALOG" "$dir" "$p.cat")
  con=$(run_gate "$CONTENT" "$dir" "$p.con")
  case $id in c-*) owner=cat ;; *) owner=con ;; esac
  if [ "$old" -eq 0 ]; then
    if [ "$id" = clean ] || [ "$cat" -ne 0 ] || [ "$con" -ne 0 ]; then
      if [ "$id" = clean ] && [ "$cat" -eq 0 ] && [ "$con" -eq 0 ]; then
        echo "PASS $id (all accept)"
      else
        note_fail "$id: baseline accepts, new rejects (catalog=$cat content=$con)"
      fi
    else
      echo "PASS $id (baseline accepts; new accept; check absent in baseline)"
    fi
    continue
  fi
  [ "$id" = clean ] && { note_fail "clean: baseline rejects the unmutated tree"; continue; }
  cat "$p.old.err" >> "$WORK/old-stderr-all"
  if [ "$owner" = cat ]; then owned=$cat; else owned=$con; fi
  if [ "$owned" -eq 0 ]; then
    note_fail "$id: baseline rejects (exit $old), owner $owner accepts"
  elif ! contains_all "$p.old.err" "$p.$owner.err"; then
    note_fail "$id: owner $owner stderr lacks baseline lines (see $p.old.err vs $p.$owner.err)"
  elif ! contains_all "$p.old.out" "$p.$owner.out"; then
    note_fail "$id: owner $owner stdout lacks baseline lines (see $p.old.out vs $p.$owner.out)"
  else
    echo "PASS $id (owner $owner rejects with baseline output)"
  fi
done

# Clean-tree OK lines: each script names itself.
for script in "$CATALOG" "$CONTENT"; do
  name=$(basename "$script" .sh)
  case $script in "$CATALOG") p="$WORK/clean.cat" ;; *) p="$WORK/clean.con" ;; esac
  grep -Fxq "$name: OK" "$p.out" || note_fail "clean: $name does not print '$name: OK'"
done

# Both scripts refuse a root without skills/.
empty=$(mktemp -d)
for script in "$CATALOG" "$CONTENT"; do
  status=$(run_gate "$script" "$empty" "$WORK/empty-$(basename "$script" .sh)")
  if [ "$status" -ne 0 ] && grep -Fxq "artifact-author catalog not found: $(CDPATH= cd -- "$empty" && pwd)/skills" "$WORK/empty-$(basename "$script" .sh).err"; then
    echo "PASS empty-root $(basename "$script")"
  else
    note_fail "empty-root: $(basename "$script") exit $status without the catalog-not-found message"
  fi
done

# Coverage: every baseline error label is triggered by some mutation.
{
  grep -E 'echo "[^"]*".*>&2' "$OLD" | sed -E 's/.*echo "([^"$]*).*/\1/'
  grep -E '^[[:space:]]*require_(regex|literal) ' "$OLD" | sed -E 's/.*"([^"]*)"[[:space:]]*$/\1/; s/\$.*//'
} | awk 'length > 0' | sort -u > "$WORK/labels"
while IFS= read -r label; do
  grep -Fq -- "$label" "$WORK/old-stderr-all" || note_fail "coverage: no mutation triggers baseline label '$label'"
done < "$WORK/labels"
echo "baseline labels checked: $(wc -l < "$WORK/labels" | tr -d ' ')"

# Phase 2: lint-all wiring, in a fixture repository with a stub ADR seal.
if [ -n "$LINT_ALL" ]; then
  for case_id in clean c-non-markdown s-sibling-named; do
    repo="$WORK/repo-$case_id"
    mkdir -p "$repo"
    cp -R "$SOURCE/." "$repo/"
    mv "$repo/scripts" "$repo/scripts.base"
    mkdir "$repo/scripts"
    cp "$(dirname "$CATALOG")"/*.sh "$(dirname "$CONTENT")"/*.sh "$repo/scripts/"
    cp "$CATALOG" "$CONTENT" "$repo/scripts/"
    cp "$LINT_ALL" "$repo/scripts/lint-all.sh"
    printf '#!/bin/sh\necho "lint-accepted-adrs: OK"\n' > "$repo/scripts/lint-accepted-adrs.sh"
    mutate "$case_id" "$repo"
    set +e
    $GATE_SH "$repo/scripts/lint-all.sh" > "$WORK/all-$case_id.out" 2>&1
    status=$?
    set -e
    ok=1
    for script in "$CATALOG" "$CONTENT"; do
      name=$(basename "$script" .sh)
      grep -Fxq -- "--- $name ---" "$WORK/all-$case_id.out" || ok=0
    done
    case $case_id in
      clean) [ "$status" -eq 0 ] || ok=0 ;;
      c-*) [ "$status" -eq 1 ] && grep -Fq "^ $(basename "$CATALOG" .sh) FAILED" "$WORK/all-$case_id.out" || ok=0 ;;
      s-*) [ "$status" -eq 1 ] && grep -Fq "^ $(basename "$CONTENT" .sh) FAILED" "$WORK/all-$case_id.out" || ok=0 ;;
    esac
    if [ "$ok" -eq 1 ]; then echo "PASS lint-all $case_id (exit $status)"; else note_fail "lint-all $case_id: exit $status (see $WORK/all-$case_id.out)"; fi
  done
fi

if [ "$failures" -eq 0 ]; then
  echo "differential-check: OK"
else
  echo "differential-check: $failures FAILED" >&2
  exit 1
fi
