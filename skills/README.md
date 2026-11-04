# Artifact authors

The skills that write Suspec artifacts ship with the method that defines them. Each folder under
this directory is an independently installable Markdown skill; a skill that works only beside its
siblings is broken.

## Install

```bash
npx skills add jcosta33/suspec -g -a codex
npx skills add jcosta33/suspec -g -a claude-code
npx skills add jcosta33/suspec --skill sus-spec -g -a codex
```

## Catalog

| Skill                                            | Artifact                                   |
| ------------------------------------------------ | ------------------------------------------ |
| [`sus-spec`](./sus-spec/SKILL.md)                | intent and verifiable requirements         |
| [`sus-task`](./sus-task/SKILL.md)                | collision-safe spec slices                 |
| [`sus-inventory`](./sus-inventory/SKILL.md)      | evidenced current-state map                |
| [`sus-change-plan`](./sus-change-plan/SKILL.md)  | preservation, waves, cutover, rollback     |
| [`sus-audit`](./sus-audit/SKILL.md)              | evidenced present-state risks              |
| [`sus-research`](./sus-research/SKILL.md)        | decision-informing evidence                |
| [`sus-campaign`](./sus-campaign/SKILL.md)        | restartable multi-pull-request goal        |

Only these skills create Suspec artifacts. They write under `~/.agents/artifacts/<workspace>/`, hand
off clickable links with absolute destinations, and close exhausted sets through Delete, Leave, or
Promote. Universal working methods that create no artifact live in
[jcosta33/skills](https://github.com/jcosta33/skills).

## Edit contract

- Keep each skill complete in `skills/<name>/SKILL.md`. Ship no appendix payloads.
- Keep frontmatter `name` and a directive `description` that names the work, never the skill.
- Preserve standalone operation and Markdown-only payloads. Depend on no sibling skill, decision
  record, shared boilerplate, or repository file.
- Keep the body under 500 lines.
- Use untitled inline Markdown links with simple destinations. Reference-style, angle-wrapped,
  fragmented, and nested-parenthesis destinations are rejected.
- Own exactly one artifact type and ID prefix; keep the declared shape aligned with
  [artifact formats](../docs/reference/artifact-formats.md).
- Carry the placement, handoff, and close contract in every author: neutral root, absolute handoff
  paths, relative local source references, blocked-write handling, and one human disposition.
- Update the catalog row above with every skill addition or removal.
- Update [`sources.md`](./sources.md) in the same change whenever an externally grounded skill or
  design rule changes. Remove sources when their claims leave.

## Verify

```bash
sh ../scripts/lint-artifact-skills.sh
```
