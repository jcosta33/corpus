#!/bin/sh
# differential.sh — preservation check for SPEC-split-skill-gate.
#
# Usage: sh differential.sh REPO BASE [SELECTOR]
# A fixture selector also runs the clean check first, so a dirty baseline cannot mask a fixture.
#   REPO      corpus checkout that holds the split scripts
#   BASE      git revision whose scripts/lint-artifact-skills.sh is the reference gate
#   SELECTOR  all (default), clean, strings, or a fixture-name prefix (root, manifest,
#             catalog, payload, readme, content, content-link, content-vocab, ...)
#
# Each fixture copies REPO's working tree (without .git) into a fresh temporary tree, injects one
# defect, then runs the reference gate and the split pair against that tree. A fixture passes
# when both sides exit 1 and emit the same sorted unique stderr lines and the same sorted unique
# stdout lines (per-script "NAME: OK" lines removed). Fixtures listed in SUPERSET may emit extra
# lines on the split side, because one gate no longer hides the other's findings.
# Ownership: root-* fixtures must fail both split scripts, content-* fixtures only
# lint-skill-content.sh, and every other fixture only lint-skill-catalog.sh.
# A fixture the reference gate does not fail on is INERT and fails the run: reconcile the
# check inventory with BASE before trusting the result.
#
# Self-test (before the split exists): SELFTEST=1 sh differential.sh REPO - all
# runs the working-tree reference as the catalog side and a no-op as the content side.
# Temporary trees stay under the system temporary directory; the run prints the path.
set -eu
export LC_ALL=C

REPO=$(CDPATH= cd -- "$1" && pwd)
BASE=$2
SELECTOR=${3:-all}
WORK=$(mktemp -d "${TMPDIR:-/tmp}/skill-gate-differential.XXXXXX")
echo "fixtures: $WORK"

if [ "${SELFTEST:-0}" = 1 ]; then
  OLD="$REPO/scripts/lint-artifact-skills.sh"
  CATALOG="$OLD"
  CONTENT="$WORK/stub-content.sh"
  printf '%s\n' '#!/bin/sh' 'echo "stub-content: OK"' > "$CONTENT"
else
  OLD="$WORK/lint-artifact-skills.sh"
  git -C "$REPO" show "$BASE:scripts/lint-artifact-skills.sh" > "$OLD"
  CATALOG=${CATALOG:-$REPO/scripts/lint-skill-catalog.sh}
  CONTENT=${CONTENT:-$REPO/scripts/lint-skill-content.sh}
fi
for script in "$OLD" "$CATALOG" "$CONTENT"; do
  test -f "$script" || { echo "missing gate script: $script" >&2; exit 2; }
done

SUPERSET=' manifest-payload '
SPEC_SKILL=skills/corpus-spec/SKILL.md

fresh() {
  tree="$WORK/$1"
  mkdir "$tree"
  for entry in "$REPO"/* "$REPO"/.[!.]*; do
    [ -e "$entry" ] || continue
    case "$(basename "$entry")" in .git) continue ;; esac
    cp -R "$entry" "$tree/"
  done
}

rewrite() { # rewrite FILE SED-EXPRESSION
  sed "$2" "$1" > "$1.rewrite" && mv "$1.rewrite" "$1"
}

append() { # append FILE TEXT  (TEXT may hold \n escapes)
  printf '\n%b\n' "$2" >> "$1"
}

# --- fixtures: one injected defect each -------------------------------------------------------
fx_root_missing()          { mv "$1/skills" "$1/skills.moved"; }
fx_manifest_dir()          { mkdir "$1/skills/zz-extra"; }
fx_manifest_catalog()      { append "$1/skills/README.md" '| [`zz-extra`](./zz-extra/SKILL.md) | fixture |'; }
fx_manifest_payload()      { mv "$1/$SPEC_SKILL" "$1/skills/corpus-spec/PAYLOAD.md"; }
fx_catalog_row()           { rewrite "$1/skills/README.md" 's#\[`corpus-spec`\](\./corpus-spec/SKILL\.md)#[`corpus-specx`](./corpus-spec/SKILL.md)#'; }
fx_payload_nonmarkdown()   { : > "$1/skills/corpus-spec/notes.txt"; }
fx_payload_symlink()       { ln -s SKILL.md "$1/skills/corpus-spec/alias.md"; }
fx_payload_subdirectory()  { mkdir "$1/skills/corpus-spec/refs"; : > "$1/skills/corpus-spec/refs/a.md"; }
fx_payload_extra_file()    { : > "$1/skills/corpus-spec/extra.md"; }
fx_readme_provenance()     { append "$1/README.md" 'ADR-1'; }
fx_readme_link_syntax()    { append "$1/skills/README.md" '[fixture][ref]'; }
fx_readme_broken_link()    { append "$1/skills/sources.md" '[fixture](./zz-missing.md)'; }
fx_content_frontmatter()   { rewrite "$1/$SPEC_SKILL" '1s/^---$/--x/'; }
fx_content_self_name()     { rewrite "$1/$SPEC_SKILL" 's/^description: /description: Corpus-spec fixture. /'; }
fx_content_length()        { i=0; while [ "$i" -le 500 ]; do echo >> "$1/$SPEC_SKILL"; i=$((i + 1)); done; }
fx_content_link_reference(){ append "$1/$SPEC_SKILL" '[fixture][ref]'; }
fx_content_link_complex()  { append "$1/$SPEC_SKILL" '[fixture](<target>)'; }
fx_content_link_unsafe()   { append "$1/$SPEC_SKILL" '[fixture](javascript:void)'; }
fx_content_link_fragment() { append "$1/$SPEC_SKILL" '[fixture](target.md#part)'; }
fx_content_link_root()     { append "$1/$SPEC_SKILL" '[fixture](/target)'; }
fx_content_link_escape()   { append "$1/$SPEC_SKILL" '[fixture](../README.md)'; }
fx_content_vocab_internal(){ append "$1/$SPEC_SKILL" 'ADR-12'; }
fx_content_vocab_thinker() { append "$1/$SPEC_SKILL" 'Plato'; }
fx_content_vocab_external(){ append "$1/$SPEC_SKILL" '../zz/SKILL.md'; }
fx_content_vocab_sibling() { append "$1/$SPEC_SKILL" 'corpus-audit'; }
fx_content_output_fence()  {
  if grep -qx '## Output' "$1/$SPEC_SKILL"; then
    rewrite "$1/$SPEC_SKILL" '/^## Output$/a\
```'
  else
    append "$1/$SPEC_SKILL" '## Output\n\n```'
  fi
}
fx_content_heading_artifact() { rewrite "$1/$SPEC_SKILL" 's/## Artifact/## Artefact/g'; }
fx_content_heading_close()    { rewrite "$1/$SPEC_SKILL" 's/## Close/## End/g'; }
fx_content_neutral_root()     { rewrite "$1/$SPEC_SKILL" 's#~/\.agents/artifacts/<workspace>/#~/.agents/elsewhere/#g'; }
fx_content_placement()        { rewrite "$1/$SPEC_SKILL" 's/[Cc][Oo][Ll][Ll][Ii][Ss][Ii][Oo][Nn]/clash/g'; }
fx_content_source_absolute()  { append "$1/$SPEC_SKILL" '## Fixture\n\nsources:\n  - /absolute/source.md'; }
fx_content_lifecycle()        { rewrite "$1/$SPEC_SKILL" 's/[Pp][Rr][Oo][Mm][Oo][Tt][Ee]/advance/g'; }
fx_content_provenance()       { append "$1/$SPEC_SKILL" 'doi.org'; }
fx_content_type_ownership()   { append "$1/$SPEC_SKILL" '## Fixture\n\ntype: audit'; }
fx_content_artifact_frontmatter() {
  append "$1/$SPEC_SKILL" '## Fixture\n\n```yaml\n---\ntype: spec\nid: SPEC-fixture\n---\n```'
}

FIXTURES='root-missing manifest-dir manifest-catalog manifest-payload catalog-row
payload-nonmarkdown payload-symlink payload-subdirectory payload-extra-file
readme-provenance readme-link-syntax readme-broken-link
content-frontmatter content-self-name content-length
content-link-reference content-link-complex content-link-unsafe content-link-fragment
content-link-root content-link-escape
content-vocab-internal content-vocab-thinker content-vocab-external content-vocab-sibling
content-output-fence content-heading-artifact content-heading-close content-neutral-root
content-placement content-source-absolute content-lifecycle content-provenance
content-type-ownership content-artifact-frontmatter'

# --- runners -----------------------------------------------------------------------------------
run_side() { # run_side TREE TAG SCRIPT... ; prints worst exit status (0, 1, or other)
  tree=$1; tag=$2; shift 2
  : > "$tree.$tag.out"; : > "$tree.$tag.err"; worst=0
  for script in "$@"; do
    status=0
    sh "$script" "$tree" >> "$tree.$tag.out" 2>> "$tree.$tag.err" || status=$?
    if [ "$status" -ne 0 ] && [ "$worst" -eq 0 -o "$status" -ne 1 ]; then worst=$status; fi
  done
  grep -vE '^[a-z-]+: OK$' "$tree.$tag.out" | sort -u > "$tree.$tag.out.cmp" || true
  sort -u "$tree.$tag.err" > "$tree.$tag.err.cmp"
  echo "$worst"
}

failures=0
report() { echo "$1"; case "$1" in PASS*) ;; *) failures=$((failures + 1)) ;; esac; }

run_fixture() {
  name=$1
  fn=fx_$(printf '%s' "$name" | tr '-' '_')
  fresh "$name"
  tree="$WORK/$name"
  "$fn" "$tree"
  old=$(run_side "$tree" old "$OLD")
  new=$(run_side "$tree" new "$CATALOG" "$CONTENT")
  if [ "$old" -eq 0 ]; then report "INERT $name: reference gate passed; reconcile inventory with BASE"; return; fi
  if [ "$old" -ne 1 ] || [ "$new" -ne 1 ]; then report "FAIL $name: exit reference=$old split=$new"; return; fi
  if [ "${SELFTEST:-0}" != 1 ]; then # ownership: only the owning script fails
    on_catalog=$(run_side "$tree" catalog "$CATALOG")
    on_content=$(run_side "$tree" content "$CONTENT")
    case "$name" in
      root-*) want="1 1" ;;
      content-*) want="0 1" ;;
      *) want="1 0" ;;
    esac
    case "$SUPERSET" in *" $name "*) want="${want% *} $on_content" ;; esac
    if [ "$on_catalog $on_content" != "$want" ]; then
      report "FAIL $name: owner exit catalog=$on_catalog content=$on_content, want $want"; return
    fi
  fi
  case "$SUPERSET" in
    *" $name "*)
      missing=$( { comm -23 "$tree.old.err.cmp" "$tree.new.err.cmp"; comm -23 "$tree.old.out.cmp" "$tree.new.out.cmp"; } | wc -l | tr -d ' ')
      if [ "$missing" -eq 0 ]; then report "PASS $name (superset)"; else report "FAIL $name: split side lost $missing reference lines"; fi
      ;;
    *)
      if cmp -s "$tree.old.err.cmp" "$tree.new.err.cmp" && cmp -s "$tree.old.out.cmp" "$tree.new.out.cmp"; then
        report "PASS $name"
      else
        report "FAIL $name: output differs (see $tree.old.* and $tree.new.*)"
      fi
      ;;
  esac
}

run_clean() {
  fresh clean
  tree="$WORK/clean"
  old=$(run_side "$tree" old "$OLD")
  for script in "$CATALOG" "$CONTENT"; do
    label=$(basename "$script" .sh)
    status=0
    out=$(sh "$script" "$tree" 2>&1) || status=$?
    if [ "$status" -eq 0 ] && printf '%s\n' "$out" | grep -qx "$label: OK"; then
      report "PASS clean $label"
    else
      report "FAIL clean $label: exit $status"
    fi
  done
  if [ "$old" -eq 0 ]; then report "PASS clean reference"; else report "FAIL clean reference: exit $old"; fi
}

run_strings() { # every quoted literal in the reference survives in scripts/*.sh
  grep -ohE "'[^']*'|\"[^\"]*\"" "$OLD" | sort -u > "$WORK/strings.old"
  # The split side is the two gates plus any sourced file in scripts/, never the reference itself.
  : > "$WORK/strings.new.raw"
  for script in "$CATALOG" "$CONTENT" "$REPO"/scripts/*.sh; do
    case "$(basename "$script")" in lint-artifact-skills.sh) [ "${SELFTEST:-0}" = 1 ] || continue ;; esac
    grep -ohE "'[^']*'|\"[^\"]*\"" "$script" >> "$WORK/strings.new.raw" || true
  done
  sort -u "$WORK/strings.new.raw" > "$WORK/strings.new"
  lost=$(comm -23 "$WORK/strings.old" "$WORK/strings.new")
  if [ -z "$lost" ]; then report "PASS strings"; else report "FAIL strings: lost literals:"; printf '%s\n' "$lost"; fi
}

case "$SELECTOR" in
  all) run_clean; run_strings; for f in $FIXTURES; do run_fixture "$f"; done ;;
  clean) run_clean ;;
  strings) run_strings ;;
  *)
    run_clean
    matched=0
    for f in $FIXTURES; do
      case "$f" in "$SELECTOR"*) matched=1; run_fixture "$f" ;; esac
    done
    [ "$matched" -eq 1 ] || { echo "no fixture matches: $SELECTOR" >&2; exit 2; }
    ;;
esac

if [ "$failures" -eq 0 ]; then echo "differential: OK"; else echo "differential: FAIL ($failures)" >&2; exit 1; fi
