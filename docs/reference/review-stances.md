# Review stances

A stance is one bounded, target-derived question with a concrete failure surface and refuting
evidence. It is a procedure, not a costume.

Derive stances from the spec, diff, trust boundaries, data flow, failure modes, and verification gaps.
Payment migrations, parsers, public APIs, and documentation require different questions.

## Reviewer contract

Give each fresh reviewer:

- current target, plus the source spec by explicit path when the workflow is spec-backed;
- one stance;
- verification output as an index, not proof;
- read-only permissions;
- a return contract: evidenced actionable findings or no finding.

Reviewers never decide acceptance. Finding a defect does not confer executive power.

## Pull requests

Stances are execution units, not publishing units. Publish only deduplicated, supported, actionable
findings. Use a line thread when possible. Keep quiet stances, refutations, reviewer identity, and
review mechanics out of the pull request.

Write one terse paragraph per finding: defect, consequence, required outcome. The implementation
owner replies once with the fixing commit and decisive proof. Verify the current head, resolve the
thread, then run the next stance. A pull request is a change record, not an agent transcript.

## Revolver

Use Revolver for breadth: derive every materially distinct target-justified stance with no numeric
floor or ceiling. Run one fresh reviewer at a time and resolve every finding before the next.
Complete full rotations; repeat after a productive rotation; stop after a quiet rotation or three
cycles. It creates no artifact.

Executable procedure: [Revolver](https://github.com/jcosta33/skills/tree/main/skills/revolver).

## Triple-check

Use Triple-check for fast independent scrutiny: give exactly three fresh top-tier reviewers the same
frozen target concurrently. Each derives its own attack and reviews the whole target without peer
prose. Wait for all three, reconcile and verify their findings, apply supported fixes once, and run
final proof. It creates no artifact.

Executable procedure:
[Triple-check](https://github.com/jcosta33/skills/tree/main/skills/triple-check).

Different model names are not a scientific control. Model variety may reduce correlated framing but
proves no independence. Judge surfaced defects and rerun evidence, not model labels.

Use Bulletproof for active claim verification. Methods never replace independent review or human
authority.

Related: [review](../08-reviewing-output.md) · [native subagents](agent-guides.md)
