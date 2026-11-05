# Artifact authors

These skills write Corpus artifacts and ship with the method that defines them. Each folder under
this directory is an independently installable Markdown skill. A skill that works only beside its
siblings is broken.

## Catalog

| Skill | Artifact |
| --- | --- |
| [`corpus-spec`](./corpus-spec/SKILL.md) | intent and verifiable requirements, optionally staged |
| [`corpus-audit`](./corpus-audit/SKILL.md) | evidenced map of present state, optionally graded for risk |
| [`corpus-research`](./corpus-research/SKILL.md) | decision-informing evidence |
| [`corpus-campaign`](./corpus-campaign/SKILL.md) | restartable multi-pull-request goal |

Only these skills create Corpus artifacts. They write `~/.agents/artifacts/<workspace>/<ID>.md`,
hand off clickable links with absolute destinations, and close exhausted sets through Delete, Leave,
or Promote. Universal working methods that create no artifact live in
[jcosta33/skills](https://github.com/jcosta33/skills).

## Edit contract

- Keep each skill complete in `skills/<name>/SKILL.md`. Ship no appendix payloads. The one other
  file is `skills/<name>/agents/openai.yaml`, exactly:

  ```yaml
  policy:
    allow_implicit_invocation: false
  ```

- Keep frontmatter `name`, a directive `description` that names the work, never the skill, and
  `disable-model-invocation: true`.
- Keep every skill manual-only. The description contains `Use only when the user explicitly asks
  for` and ends `Never invoke on your own initiative.` Frame it as a response to a failure, not a
  precaution. The [method](../docs/method.md) states each harness's control strength.
- Preserve standalone operation and Markdown-only skill content. Depend on no sibling skill,
  decision record, shared boilerplate, or repository file.
- Keep the body under 500 lines.
- Write the plain procedure. Name no philosopher, thinker, or named method in a description or
  body; credit sources in [`sources.md`](./sources.md) or the ADR ledger.
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
