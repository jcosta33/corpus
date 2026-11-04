#!/bin/sh
# lint-artifact-skills.sh — structural gate over the artifact-author skills in skills/.
#
# Usage: scripts/lint-artifact-skills.sh [REPO_ROOT]   (default: this repo)
set -eu
export LC_ALL=C

ROOT=${1:-$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)}
ROOT=$(CDPATH= cd -- "$ROOT" && pwd)
test -d "$ROOT/skills" || { echo "artifact-author catalog not found: $ROOT/skills" >&2; exit 1; }

expected='corpus-audit
corpus-campaign
corpus-research
corpus-spec'

require_regex() {
  file=$1
  pattern=$2
  label=$3
  tr '\n' ' ' < "$file" | grep -Eqi "$pattern" || { echo "$label: $file" >&2; exit 1; }
}

require_literal() {
  file=$1
  literal=$2
  label=$3
  grep -Fq -- "$literal" "$file" || { echo "$label: $file" >&2; exit 1; }
}

reject_absolute_source_examples() {
  awk '
    function trim(value) { gsub(/^[[:space:]]+|[[:space:]]+$/, "", value); return value }
    function absolute(value, first) {
      value = trim(value)
      first = substr(value, 1, 1)
      if (first == "\"" || first == single_quote) value = substr(value, 2)
      return value ~ /^\// || value ~ /^~\//
    }
    function list_has_absolute(value, count, cursor, item) {
      gsub(/^[[:space:]]*\[[[:space:]]*|[[:space:]]*\][[:space:]]*$/, "", value)
      count = split(value, items, ",")
      for (cursor = 1; cursor <= count; cursor += 1) { item = items[cursor]; if (absolute(item)) return 1 }
      return 0
    }
    BEGIN { single_quote = sprintf("%c", 39) }
    /^[[:space:]]*sources:[[:space:]]*\[/ {
      value = $0; sub(/^[[:space:]]*sources:[[:space:]]*/, "", value)
      if (list_has_absolute(value)) exit 1
      next
    }
    /^[[:space:]]*sources:[[:space:]]*$/ { sources = 1; next }
    sources && /^[[:space:]]*-[[:space:]]+/ {
      value = $0; sub(/^[[:space:]]*-[[:space:]]+/, "", value)
      if (absolute(value)) exit 1
      next
    }
    sources { sources = 0 }
  ' "$1" || { echo "absolute local source example: $1" >&2; exit 1; }
}

section_text() {
  awk -v heading="## $2" '
    $0 == heading { inside = 1; next }
    inside && /^## / { exit }
    inside { print }
  ' "$1" | tr '\n' ' '
}

relative_links() {
  grep -oE ']\([^)]*\)' |
    sed -E 's/^]\((.*)\)$/\1/' |
    sed -E 's/[?#].*$//' |
    awk 'length > 0 && $0 !~ /^\// && $0 !~ /^[[:alpha:]][[:alnum:]+.-]*:/'
}

validate_skill_frontmatter() {
  awk -v expected_name="$2" '
    NR == 1 { if ($0 != "---") exit 1; inside = 1; next }
    inside && $0 == "---" { inside = 0; closed = 1; next }
    inside {
      if ($0 ~ /^name:[[:space:]]+/) {
        value = $0; sub(/^name:[[:space:]]+/, "", value)
        names += 1
        if (value != expected_name) exit 1
        next
      }
      if ($0 ~ /^description:[[:space:]]+/) {
        value = $0; sub(/^description:[[:space:]]+/, "", value)
        sub(/[[:space:]]+#.*/, "", value)
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", value)
        lower = tolower(value)
        if (length(value) > 1024 || value !~ /^[[:alpha:]]/ || value ~ /:[[:space:]]/ || lower ~ /^(null|true|false|yes|no|on|off)$/) exit 1
        descriptions += 1
        next
      }
      exit 1
    }
    END { if (!closed || names != 1 || descriptions != 1) exit 1 }
  ' "$1"
}

validate_link_syntax() {
  file=$1
  if grep -nE ']\[[^]]*\]|^[[:space:]]*\[[^]]+\]:' "$file"; then
    echo "reference-style link is unsupported: $file" >&2; return 1
  fi
  if grep -nE ']\(<|]\([^)]*[[:space:]][^)]*\)|]\([^)]*\(' "$file"; then
    echo "complex inline link is unsupported: $file" >&2; return 1
  fi
  if grep -niE ']\((file|data|javascript):' "$file"; then
    echo "unsafe URI link is forbidden: $file" >&2; return 1
  fi
  if grep -nE ']\([^)]*#' "$file"; then
    echo "fragment link is unsupported: $file" >&2; return 1
  fi
}

validate_artifact_frontmatter() {
  awk -v expected_type="$2" -v expected_prefix="$3" '
    { line = $0; sub(/^[[:space:]]+/, "", line) }
    NR == 1 && line == "---" { in_yaml = 1; inside = 1; next }
    line == "```yaml" { in_yaml = 1; next }
    in_yaml && line == "---" {
      if (!inside) { inside = 1; types = 0; ids = 0; type_value = ""; id_value = ""; next }
      if (types == 1 && ids == 1 && type_value == expected_type && index(id_value, expected_prefix) == 1) found += 1
      inside = 0
      next
    }
    inside && line ~ /^type:[[:space:]]+/ {
      type_value = line; sub(/^type:[[:space:]]+/, "", type_value); gsub(/^["\047]|["\047]$/, "", type_value); types += 1; next
    }
    inside && line ~ /^id:[[:space:]]+/ {
      id_value = line; sub(/^id:[[:space:]]+/, "", id_value); gsub(/^["\047]|["\047]$/, "", id_value); ids += 1; next
    }
    in_yaml && line == "```" { in_yaml = 0; inside = 0 }
    END { if (found != 1) exit 1 }
  ' "$1"
}

declaration_values() {
  find "$1" -type f -name '*.md' -exec awk -v key="$2" '
    {
      rest = $0
      pattern = "(^|[`[:space:]])" key ":[[:space:]]+"
      while (match(rest, pattern)) {
        value = substr(rest, RSTART + RLENGTH)
        first = substr(value, 1, 1)
        if (first == "\"" || first == "\047") value = substr(value, 2)
        if (match(value, /^[[:alnum:]-]+/)) print substr(value, RSTART, RLENGTH)
        rest = substr(rest, RSTART + RLENGTH)
      }
    }
  ' {} + | sort -u
}

actual_directories=$(find "$ROOT/skills" -mindepth 1 -maxdepth 1 -type d -exec basename {} \; | sort)
actual_payloads=$(
  find "$ROOT/skills" -mindepth 2 -maxdepth 2 -type f -name SKILL.md -exec dirname {} \; |
    while IFS= read -r directory; do basename "$directory"; done | sort
)
catalog=$(sed -nE 's#.*\(\./([^/]+)/SKILL\.md\).*#\1#p' "$ROOT/skills/README.md" | sort)
for manifest in "$actual_directories" "$actual_payloads" "$catalog"; do
  test "$manifest" = "$expected" || {
    echo "artifact-author manifest drift" >&2
    printf 'expected:\n%s\nactual:\n%s\n' "$expected" "$manifest" >&2
    exit 1
  }
done

expected_catalog_rows=$(printf '%s\n' "$expected" | awk '{ print $0 ":" $0 }')
catalog_rows=$(sed -nE 's#^\| \[`([^`]+)`\]\(\./([^/]+)/SKILL\.md\).*$#\1:\2#p' "$ROOT/skills/README.md" | sort)
test "$catalog_rows" = "$expected_catalog_rows" || { echo "catalog label and target drift" >&2; exit 1; }

if find "$ROOT/skills" -type f ! -name '*.md' | grep -q .; then
  echo "skill payload contains a non-Markdown file" >&2; exit 1
fi
if find "$ROOT/skills" -type l | grep -q .; then
  echo "skill payload contains a symlink" >&2; exit 1
fi

for file in "$ROOT"/skills/*/SKILL.md; do
  folder=$(CDPATH= cd -- "$(dirname "$file")" && pwd -P)
  name=$(basename "$folder")
  validate_skill_frontmatter "$file" "$name" || { echo "invalid skill frontmatter: $name" >&2; exit 1; }
  description=$(awk '/^description:[[:space:]]+/ { sub(/^description:[[:space:]]+/, ""); print; exit }' "$file")
  if printf '%s\n' "$description" | grep -Eqi "(^|[^[:alnum:]-])$name([^[:alnum:]-]|$)"; then
    echo "skill description names itself: $name" >&2; exit 1
  fi
  lines=$(wc -l < "$file" | tr -d '[:space:]')
  if [ "$lines" -gt 500 ]; then echo "skill body exceeds 500 lines: $name" >&2; exit 1; fi

  if find "$folder" -mindepth 1 -type d -print | grep -q .; then
    echo "appendix payload directory in $name" >&2; exit 1
  fi
  find "$folder" -mindepth 1 -type f -print | while IFS= read -r path; do
    relative=${path#"$folder"/}
    case "$relative" in
      SKILL.md) ;;
      *) echo "unexpected skill payload file: $path" >&2; exit 1 ;;
    esac
  done

  find "$folder" -type f -name '*.md' -print | while IFS= read -r document; do
    validate_link_syntax "$document" || exit 1
    if grep -nE ']\(/[^)]*\)' "$document"; then
      echo "root-relative link escapes package: $document" >&2; exit 1
    fi
    directory=$(dirname "$document")
    relative_links < "$document" | while IFS= read -r ref; do
      [ -z "$ref" ] && continue
      target_directory=$(CDPATH= cd -- "$directory/$(dirname "$ref")" && pwd -P)
      target="$target_directory/$(basename "$ref")"
      case "$target" in
        "$folder"|"$folder"/*) ;;
        *) echo "skill link escapes package: $document -> $ref" >&2; exit 1 ;;
      esac
    done
    if grep -nE 'SPINE-(START|END)|ADR-[0-9]+|lint-[a-z-]+|this catalog|sibling skill|if installed|catalog topology' "$document"; then
      echo "internal or dependency vocabulary in $name: $document" >&2; exit 1
    fi
    if grep -nE '\.\./[^/]+/SKILL\.md' "$document"; then
      echo "external skill dependency in $name: $document" >&2; exit 1
    fi
    for other in $expected; do
      [ "$other" = "$name" ] && continue
      if grep -nE "(^|[^[:alnum:]-])$other([^[:alnum:]-]|$)" "$document"; then
        echo "sibling skill named in $name: $other ($document)" >&2; exit 1
      fi
    done
  done

  output_text=$(section_text "$file" Output)
  if printf '%s\n' "$output_text" | grep -Fq '```'; then
    echo "fenced chat output in $name" >&2; exit 1
  fi

  for heading in '## Artifact' '## Close'; do
    require_literal "$file" "$heading" "incomplete artifact contract in $name"
  done
  require_literal "$file" '~/.agents/artifacts/<workspace>/' "neutral root missing in $name"
  for word in absolute repository vendor temporary collision '(unwritable|blocked write)' 'return only' 'relative to the artifact'; do
    require_regex "$file" "$word" "incomplete artifact placement or handoff in $name"
  done
  find "$folder" -type f -name '*.md' | while IFS= read -r payload; do
    reject_absolute_source_examples "$payload"
  done || { echo "absolute local source example in $name" >&2; exit 1; }
  for word in Delete Leave Promote sidecar 'downstream step'; do
    require_regex "$file" "$word" "lifecycle disposition missing in $name"
  done
  if grep -nE 'AUDIT-[0-9]|https?://github|doi\.org' "$file"; then
    echo "provenance citation or source URL in $name" >&2; exit 1
  fi
done

for readme in "$ROOT/README.md" "$ROOT/skills/README.md"; do
  if grep -nE 'ADR-[0-9]|AUDIT-[0-9]|doi\.org' "$readme"; then
    echo "provenance citation in product README: $readme" >&2; exit 1
  fi
done

validate_link_syntax "$ROOT/skills/README.md" || exit 1
for document in "$ROOT/skills/README.md" "$ROOT/skills/sources.md"; do
  directory=$(dirname "$document")
  relative_links < "$document" | while IFS= read -r ref; do
    [ -z "$ref" ] || test -e "$directory/$ref" || {
      echo "broken relative link: $document -> $ref" >&2; exit 1
    }
  done
done

writer_types='corpus-spec:spec:SPEC- corpus-audit:audit:AUDIT- corpus-research:research:RESEARCH- corpus-campaign:campaign:CAMPAIGN-'
for pair in $writer_types; do
  writer=${pair%%:*}
  declaration=${pair#*:}
  expected_type=${declaration%%:*}
  expected_prefix=${declaration#*:}
  actual_types=$(declaration_values "$ROOT/skills/$writer" type)
  test "$actual_types" = "$expected_type" || {
    echo "artifact type ownership drift in $writer: $actual_types" >&2; exit 1
  }
  frontmatter_source="$ROOT/skills/$writer/SKILL.md"
  validate_artifact_frontmatter "$frontmatter_source" "$expected_type" "$expected_prefix" || {
    echo "artifact frontmatter contract drift in $writer" >&2; exit 1
  }
done

echo "lint-artifact-skills: OK"
