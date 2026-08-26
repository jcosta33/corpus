#!/bin/sh
# test-lint-artifact-skills.sh — mutation test for the artifact-author structural gate.
set -eu
export LC_ALL=C

ROOT=${1:-$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)}
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT HUP INT TERM

copy_repo() {
  target=$1
  mkdir -p "$target"
  for path in skills scripts; do
    cp -R "$ROOT/$path" "$target/$path"
  done
}

rewrite_without() {
  pattern=$1
  file=$2
  awk -v pattern="$pattern" '$0 != pattern { print }' "$file" > "$file.tmp"
  mv "$file.tmp" "$file"
}

replace_in() {
  from=$1
  to=$2
  file=$3
  sed "s|$from|$to|" "$file" > "$file.tmp"
  mv "$file.tmp" "$file"
}

expect_failure() {
  mutation=$1
  fixture="$TMP/$mutation"
  copy_repo "$fixture"

  case "$mutation" in
    missing-skill)
      rm -rf "$fixture/skills/sus-spec"
      ;;
    non-markdown-payload)
      : > "$fixture/skills/sus-spec/payload.bin"
      ;;
    symlink)
      ln -s SKILL.md "$fixture/skills/sus-spec/duplicate.md"
      ;;
    escaping-link)
      printf '\n[escape](../sus-task/SKILL.md)\n' >> "$fixture/skills/sus-spec/SKILL.md"
      ;;
    appendix-payload)
      mkdir -p "$fixture/skills/sus-spec/references"
      printf 'hidden control\n' > "$fixture/skills/sus-spec/references/control.md"
      ;;
    sibling-dependency)
      printf '\nRun sus-task next.\n' >> "$fixture/skills/sus-spec/SKILL.md"
      ;;
    broken-catalog-link)
      printf '\n[broken](./missing.md)\n' >> "$fixture/skills/README.md"
      ;;
    missing-frontmatter)
      rewrite_without 'type: spec' "$fixture/skills/sus-spec/SKILL.md"
      ;;
    invalid-description-yaml)
      awk '
        /^description:/ { print "description: Invalid: YAML"; next }
        { print }
      ' "$fixture/skills/sus-audit/SKILL.md" > "$fixture/skills/sus-audit/SKILL.md.tmp"
      mv "$fixture/skills/sus-audit/SKILL.md.tmp" "$fixture/skills/sus-audit/SKILL.md"
      ;;
    fenced-chat)
      awk '
        { print }
        $0 == "## Output" { print ""; print "```text"; print "fenced"; print "```" }
      ' "$fixture/skills/sus-audit/SKILL.md" > "$fixture/skills/sus-audit/SKILL.md.tmp"
      mv "$fixture/skills/sus-audit/SKILL.md.tmp" "$fixture/skills/sus-audit/SKILL.md"
      ;;
    handoff-drift)
      replace_in 'clickable Markdown links' 'clickable paths' "$fixture/skills/sus-spec/SKILL.md"
      ;;
    source-reference-drift)
      rewrite_without \
        'Write local source references relative to the artifact. Use absolute paths only for runtime handoff.' \
        "$fixture/skills/sus-audit/SKILL.md"
      ;;
    source-reference-example-drift)
      replace_in '\.\./\.\./path/to/source\.md' '/absolute/path/to/source.md' \
        "$fixture/skills/sus-spec/SKILL.md"
      ;;
    source-reference-inline-drift)
      printf '\n```yaml\nsources: ["/absolute/path/to/source.md"]\n```\n' \
        >> "$fixture/skills/sus-spec/SKILL.md"
      ;;
    source-ledger-drift)
      sed '/^## Research Method$/d' "$fixture/skills/sources.md" > "$fixture/skills/sources.md.tmp"
      mv "$fixture/skills/sources.md.tmp" "$fixture/skills/sources.md"
      ;;
    campaign-local-proof-drift)
      sed '/Hosted status checks are optional;/d' \
        "$fixture/skills/sus-campaign/SKILL.md" \
        > "$fixture/skills/sus-campaign/SKILL.md.tmp"
      mv "$fixture/skills/sus-campaign/SKILL.md.tmp" \
        "$fixture/skills/sus-campaign/SKILL.md"
      ;;
    campaign-authority-drift)
      sed '/cannot accept its own work\./d' \
        "$fixture/skills/sus-campaign/SKILL.md" \
        > "$fixture/skills/sus-campaign/SKILL.md.tmp"
      mv "$fixture/skills/sus-campaign/SKILL.md.tmp" \
        "$fixture/skills/sus-campaign/SKILL.md"
      ;;
    campaign-operation-scope-drift)
      replace_in 'Map only operations the campaign will use:' 'Map every possible operation:' \
        "$fixture/skills/sus-campaign/SKILL.md"
      ;;
    campaign-capability-class-drift)
      replace_in '\*\*Deterministic local:\*\*' '**Advisory:**' \
        "$fixture/skills/sus-campaign/SKILL.md"
      ;;
    campaign-bootstrap-drift)
      sed '/trusted owner may bootstrap a missing control/d' \
        "$fixture/skills/sus-campaign/SKILL.md" \
        > "$fixture/skills/sus-campaign/SKILL.md.tmp"
      mv "$fixture/skills/sus-campaign/SKILL.md.tmp" \
        "$fixture/skills/sus-campaign/SKILL.md"
      ;;
    campaign-human-merge-drift)
      replace_in 'The owner may delegate merge execution' \
        'The owner may not delegate merge execution' \
        "$fixture/skills/sus-campaign/SKILL.md"
      ;;
    campaign-human-ownership-drift)
      replace_in 'Humans own' 'Humans review' "$fixture/skills/sus-campaign/SKILL.md"
      ;;
    *)
      echo "unknown mutation: $mutation" >&2
      exit 1
      ;;
  esac

  if sh "$fixture/scripts/lint-artifact-skills.sh" "$fixture" >/dev/null 2>&1; then
    echo "mutation survived: $mutation" >&2
    exit 1
  fi
}

sh "$ROOT/scripts/lint-artifact-skills.sh" "$ROOT" >/dev/null

for mutation in missing-skill non-markdown-payload symlink escaping-link appendix-payload \
  sibling-dependency broken-catalog-link missing-frontmatter invalid-description-yaml fenced-chat \
  handoff-drift \
  source-reference-drift source-reference-example-drift source-reference-inline-drift \
  source-ledger-drift campaign-local-proof-drift campaign-authority-drift \
  campaign-operation-scope-drift campaign-capability-class-drift campaign-bootstrap-drift \
  campaign-human-merge-drift campaign-human-ownership-drift; do
  expect_failure "$mutation"
done

echo "test-lint-artifact-skills: OK"
