# Artifact authors

These skills write Corpus artifacts and ship with the method that defines them. Each folder under
this directory is an independently installable Markdown skill. A skill that works only beside its
siblings is broken.

## Install

```bash
npx skills add jcosta33/corpus -g -a codex
npx skills add jcosta33/corpus -g -a claude-code
npx skills add jcosta33/corpus --skill corpus-spec -g -a codex
```

Installing does not remove the earlier `sus-*` names. Remove them by name first:

```bash
npx skills remove -g sus-spec sus-task sus-inventory sus-change-plan sus-audit sus-research sus-campaign
```

## Catalog

| Skill | Artifact |
| --- | --- |
| [`corpus-spec`](./corpus-spec/SKILL.md) | intent and verifiable requirements, optionally staged or split |
| [`corpus-audit`](./corpus-audit/SKILL.md) | evidenced map of present state, optionally graded for risk |
| [`corpus-research`](./corpus-research/SKILL.md) | decision-informing evidence |
| [`corpus-campaign`](./corpus-campaign/SKILL.md) | restartable multi-pull-request goal |

Only these skills create Corpus artifacts. They write `~/.agents/artifacts/<workspace>/<ID>.md`,
hand off clickable links with absolute destinations, and close exhausted sets through Delete, Leave,
or Promote. Universal working methods that create no artifact live in
[jcosta33/skills](https://github.com/jcosta33/skills).

## Edit contract

- Keep each skill complete in `skills/<name>/SKILL.md`. Ship no appendix payloads.
- Keep frontmatter `name` and a directive `description` that names the work, never the skill.
- Preserve standalone operation and Markdown-only payloads. Depend on no sibling skill, decision
  record, shared boilerplate, or repository file.
- Keep the body under 500 lines.
- Use untitled inline Markdown links with simple destinations. Reference-style, angle-wrapped,
  fragmented, and nested-parenthesis destinations are rejected.
- Own exactly one artifact type and ID prefix. Keep the declared shape aligned with
  [formats](../docs/formats.md).
- Every author carries the full placement, handoff, and close contract:
  - the neutral root;
  - absolute handoff paths;
  - relative local source references;
  - blocked-write handling;
  - one human disposition.
- Update the catalog row above with every skill addition or removal.
- Update [`sources.md`](./sources.md) in the same change whenever an externally grounded skill or
  design rule changes. Remove sources when their claims leave.

## Verify

```bash
sh ../scripts/lint-artifact-skills.sh
```
