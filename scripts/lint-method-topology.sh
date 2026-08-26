#!/bin/sh
set -eu
export LC_ALL=C

PARENT=${1:-$(CDPATH= cd -- "$(dirname -- "$0")/../.." && pwd)}

repo_with_package() {
  package=$1
  found=
  for candidate in "$PARENT"/*; do
    manifest="$candidate/package.json"
    [ -f "$manifest" ] || continue
    grep -Eq '"name"[[:space:]]*:[[:space:]]*"'"$package"'"' "$manifest" || continue
    [ -z "$found" ] || {
      echo "multiple Suspec repositories identify as $package under $PARENT" >&2
      return 1
    }
    found=$candidate
  done
  [ -n "$found" ] || { echo "Suspec repository $package not found under $PARENT" >&2; return 1; }
  printf '%s\n' "$found"
}

canon=${SUSPEC_CANON:-$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)}
cli=${SUSPEC_CLI:-$(repo_with_package suspec-cli)}
mcp=${SUSPEC_MCP:-$(repo_with_package suspec-mcp)}

dispatch_only_siblings() {
  awk '
    /^  [[:alnum:]_-]+:$/ { job = $0; dispatch = 0 }
    /^    if: github\.event_name == '\''workflow_dispatch'\''$/ { dispatch = 1 }
    /repository: jcosta33\/suspec/ && !dispatch {
      print "sibling checkout outside dispatch-only job " job ": " $0 > "/dev/stderr"
      bad = 1
    }
    END { exit bad }
  ' "$1"
}

for workflow in \
  "$canon/.github/workflows/method-gates.yml" \
  "$cli/.github/workflows/gate.yml" \
  "$mcp/.github/workflows/gate.yml"; do
  test -f "$workflow" || { echo "missing family method gate: $workflow" >&2; exit 1; }
  grep -Fq 'scripts/lint-all.sh' "$workflow" || {
    echo "workflow does not run the family method gate: $workflow" >&2
    exit 1
  }
  grep -Fq 'ref: "${{ inputs.' "$workflow" || {
    echo "workflow lacks explicit integration-snapshot sibling refs: $workflow" >&2
    exit 1
  }
  grep -Fq "if: github.event_name == 'workflow_dispatch'" "$workflow" || {
    echo "cross-family gate is not dispatch-only: $workflow" >&2
    exit 1
  }
  dispatch_only_siblings "$workflow" || {
    echo "event-local job depends on a sibling repository: $workflow" >&2
    exit 1
  }
done
if grep -RniE 'suspec-agents|agents_ref' \
  "$canon/.github/workflows" "$cli/.github/workflows" "$mcp/.github/workflows"; then
  echo "deleted agent repository survives in a current workflow" >&2
  exit 1
fi
grep -Fq 'SUSPEC_HISTORY_BASE:' "$canon/.github/workflows/method-gates.yml" || {
  echo "canon workflow lacks base-relative ADR history verification" >&2
  exit 1
}
test -x "$canon/scripts/lint-artifact-skills.sh" || {
  echo "artifact-author gate is missing or not executable" >&2
  exit 1
}
test -x "$canon/scripts/test-lint-artifact-skills.sh" || {
  echo "artifact-author mutation test is missing or not executable" >&2
  exit 1
}
grep -Fq 'sh scripts/lint-artifact-skills.sh' "$canon/.github/workflows/method-gates.yml" || {
  echo "canon event workflow omits the artifact-author gate" >&2
  exit 1
}
grep -Fq 'SUSPEC_FAMILY_ROOTS="$GITHUB_WORKSPACE" sh scripts/lint-count-ranges.sh' \
  "$canon/.github/workflows/method-gates.yml" || {
  echo "canon event workflow omits current local surfaces" >&2
  exit 1
}
grep -Fq 'SUSPEC_CANON:' "$cli/.github/workflows/gate.yml" || {
  echo "CLI integration workflow can skip an unresolved canon" >&2
  exit 1
}
grep -Fq 'SUSPEC_BIN:' "$mcp/.github/workflows/gate.yml" || {
  echo "MCP integration workflow can skip an unresolved CLI" >&2
  exit 1
}

agent_policy="$canon/policy/agent.md"
generated_policy="$cli/src/generated/agentPolicy.ts"
test -f "$agent_policy" || { echo "canonical agent policy missing" >&2; exit 1; }
test -f "$generated_policy" || { echo "CLI generated agent policy missing" >&2; exit 1; }
grep -Fq 'Route delivery through project-native controls when present.' "$agent_policy" || {
  echo "agent policy lacks native delivery routing" >&2
  exit 1
}
grep -Fq 'This routing rule is advisory;' "$agent_policy" || {
  echo "agent policy overstates instruction enforcement" >&2
  exit 1
}
grep -Fq 'systems enforce delivery transitions and harness permissions isolate worker authority.' "$agent_policy" || {
  echo "agent policy lacks native enforcement ownership" >&2
  exit 1
}
agent_digest=$(node -e '
  const { createHash } = require("node:crypto");
  const { readFileSync } = require("node:fs");
  process.stdout.write(createHash("sha256").update(readFileSync(process.argv[1])).digest("hex"));
' "$agent_policy")
grep -Fq "AGENT_POLICY_SHA256 = '$agent_digest'" "$generated_policy" || {
  echo "CLI agent policy digest drift" >&2
  exit 1
}

formats="$canon/docs/reference/artifact-formats.md"
require_writer() {
  type=$1
  writer=$2
  grep -Fq "| \`$type\` | \`$writer\` |" "$formats" || {
    echo "artifact writer ownership drift: $type -> $writer" >&2
    exit 1
  }
}
require_writer spec sus-spec
require_writer task sus-task
require_writer inventory sus-inventory
require_writer change-plan sus-change-plan
require_writer audit sus-audit
require_writer research sus-research
require_writer campaign sus-campaign
stale_methods='concise-output|revolver-review|codebase-exploration|promote-artifact|save-findings|empirical-proof|implement-task|market-research|planning-spec|write-spec|spec-check|split-work|review-output|security-review|fix-flaky-test|git-pr|write-audit|write-bug-report|write-change-plan|write-documentation|write-feature|write-fix|write-inventory|write-migration|write-performance|write-prd|write-refactor|write-research|write-rewrite|write-rfc|write-testing'
if grep -RniE --exclude-dir=adrs "(^|[^[:alnum:]-])($stale_methods)([^[:alnum:]-]|$)" \
  "$canon/README.md" "$canon/AGENTS.md" "$canon/docs" "$canon/checks" "$canon/skills" \
  "$cli/README.md" "$cli/AGENTS.md" "$cli/docs" "$cli/src" "$mcp/README.md" "$mcp/src" "$mcp/test"; then
  echo "stale current method name" >&2
  exit 1
fi

if grep -RniE --exclude-dir=adrs 'suspec-agents|canonical agents([^[:alnum:]]|$)|canonical agent (definition|catalog)|Codex projection|agents/suspec-' \
  "$canon/README.md" "$canon/AGENTS.md" "$canon/docs" \
  "$cli/README.md" "$cli/AGENTS.md" "$cli/docs" \
  "$mcp/README.md"; then
  echo "custom agent catalog survives on a current surface" >&2
  exit 1
fi

if grep -RniE --exclude-dir=adrs \
  'at least six.*stances|six distinct stances|Triple-check.*one fresh.*per pass|fixed before the next pass|Triple-check.*repairs sequentially' \
  "$canon/README.md" "$canon/AGENTS.md" "$canon/docs"; then
  echo "stale current inspection semantics" >&2
  exit 1
fi
grep -Fq 'every materially distinct target-justified stance with no numeric' \
  "$canon/docs/reference/review-stances.md" || {
  echo "adaptive Revolver reference missing" >&2
  exit 1
}
grep -Fq 'exactly three fresh top-tier reviewers the same' \
  "$canon/docs/reference/review-stances.md" || {
  echo "parallel Triple-check reference missing" >&2
  exit 1
}
grep -Fq '| **Campaign** | Large delivery governed by a campaign artifact and admitted only after project-native lane, proof, resource, review, merge, and cleanup controls are proven.' \
  "$canon/docs/reference/glossary.md" || {
  echo "campaign glossary contract missing" >&2
  exit 1
}
grep -Fq 'Stances are execution units, not publishing units.' \
  "$canon/docs/reference/review-stances.md" || {
  echo "pull-request publication boundary missing" >&2
  exit 1
}
if grep -RniE --exclude-dir=adrs \
  'review event per stance|Record a quiet stance|follow-up review event referencing' \
  "$canon/README.md" "$canon/AGENTS.md" "$canon/docs" "$canon/skills"; then
  echo "stale campaign review ceremony" >&2
  exit 1
fi

grep -q '^version: 0\.27\.0' "$canon/checks/checks.yaml" || {
  echo "checks contract version drift" >&2
  exit 1
}
actual_checks=$(sed -nE 's/^  - \{ id: (C[0-9]{3}), name: ([^,]+), severity: ([^ }]+) \}.*/\1 \2 \3/p' "$canon/checks/checks.yaml")
test -n "$actual_checks" || { echo "active checks table is empty" >&2; exit 1; }
duplicate_check_ids=$(printf '%s\n' "$actual_checks" | awk '{print $1}' | sort | uniq -d)
test -z "$duplicate_check_ids" || {
  echo "duplicate active check ids: $duplicate_check_ids" >&2
  exit 1
}
printf '%s\n' "$actual_checks" | while read -r id name severity; do
  awk -F '|' -v id="$id" -v name="\`$name\`" -v severity="$severity" '
    function trim(value) {
      sub(/^[[:space:]]+/, "", value)
      sub(/[[:space:]]+$/, "", value)
      return value
    }
    trim($2) == id && trim($3) == name {
      actual = trim($5)
      if (actual == severity || index(actual, severity " (") == 1) found = 1
    }
    END { exit !found }
  ' "$canon/docs/reference/checks.md" || {
    echo "checks reference row drift: $id $name $severity" >&2
    exit 1
  }
done
grep -Fq '  checked: [spec, task, change-plan, campaign]' "$canon/checks/checks.yaml" || {
  echo "checked artifact matrix drift" >&2
  exit 1
}
grep -Fq '  recognized_unchecked: [inventory, audit, research]' "$canon/checks/checks.yaml" || {
  echo "unchecked artifact matrix drift" >&2
  exit 1
}
grep -Fq '  checked: [type, level, path, diagnostics]' "$canon/checks/checks.yaml" || {
  echo "checked report discriminator drift" >&2
  exit 1
}
grep -Fq '  unchecked: [type, level, path, checked]' "$canon/checks/checks.yaml" || {
  echo "unchecked report discriminator drift" >&2
  exit 1
}
grep -Fq '  file_set: [level, path, diagnostics]' "$canon/checks/checks.yaml" || {
  echo "file-set report shape drift" >&2
  exit 1
}
grep -q '^  missing_type: hard-error$' "$canon/checks/checks.yaml" || { echo "missing-type policy drift" >&2; exit 1; }
grep -q '^  unknown_type: hard-error$' "$canon/checks/checks.yaml" || { echo "unknown-type policy drift" >&2; exit 1; }
grep -Fq '  common_scalar_fields: [type, id]' "$canon/checks/checks.yaml" || {
  echo "common frontmatter field-shape drift" >&2
  exit 1
}
grep -Fq '^(all )?(tests?|checks?) (pass(ed)?|succeeded)\.?$' "$canon/checks/checks.yaml" || {
  echo "C023 claim-only predicate drift" >&2
  exit 1
}
# C012 is RESERVED. C013 is RESERVED. C016 is RESERVED. C020 is RESERVED. C026 is RESERVED. C027 is RESERVED. Never reuse.
for id in C005 C006 C012 C013 C014 C016 C017 C018 C020 C026 C027; do
  if grep -qE "^  - \{ id: $id," "$canon/checks/checks.yaml"; then
    echo "$id must not be active" >&2
    exit 1
  fi
done
echo "lint-method-topology: OK"
