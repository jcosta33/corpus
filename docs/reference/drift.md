# Drift

Drift exists when live implementation, evidence, scope, or contract no longer matches the intent under
review.

Common cases:

- requirements or verification changed after evidence;
- judged code changed after review;
- edits escaped declared scope;
- a task diverged from its spec.

Stale evidence is dead evidence. Identify the changed authority, reconcile intent or implementation,
rerun affected verification against the final state, and review again.

Suspec maintains no repository-wide spec baseline after close. Later work starts from current code,
tests, project decisions, and the new request.

Related: [lineage](lineage.md) · [review](../08-reviewing-output.md)
