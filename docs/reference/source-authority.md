# Source authority

*Advanced design note — internal rationale; not needed to use Corpus.*

When two artifacts state conflicting intent — a spec says one thing, an audit note another —
which one governs? Source authority is the answer: a fixed precedence over **intent**, and the
only sanctioned alternative to letting whichever file was written last quietly win. It also
settles the adjacent question of who may approve a change to a requirement.

This whole page is **convention level** — a procedure people follow, not something any tool
resolves. swarm-cli's `swarm check` can *flag* a contradiction it finds (toolable); no tool
ever picks the winner.

## The minimum viable model

Most teams never need the full precedence ladder below. Five rules carry the weight; adopt these
first and reach for the rest only when two reviewed artifacts genuinely conflict:

- **Specs state intent.** A requirement is the contract; nothing else outranks it on its own subject.
- **Code can falsify intent, never silently amend it.** A failing test or a divergent behavior
  produces a Fail or a Stale result that routes to a human — it never quietly becomes the new requirement.
- **Review rows judge implementation against the *current* spec text and its evidence** — not
  against what the spec used to say, and not on the implementer's say-so.
- **A changed requirement or changed exercised code makes old evidence stale until it is re-run.**
- **Findings inform future work but are not requirements** until promoted into a spec.

The rest of this page is the tie-breaker for the rarer case where two durable artifacts disagree.
**Working solo?** You are every owner, and conflicts you resolve in your own head — the five rules
above are all you need; skip the ladder entirely until a second person (or a second team) makes
"who governs?" a real question.

## Two axes

A conflict is judged on two independent axes:

- **Artifact rank** — how settled is the *container* the statement lives in?
- **Domain rank** — how much force does the statement's *subject* project?

### Artifact rank

| Rank | Artifact | Note |
|---|---|---|
| 1 (highest) | accepted ADR | A recorded decision; the strongest written intent. |
| 2 | approved spec | The behavioral contract. |
| 3 | accepted finding | A durable, evidenced project fact. |
| 4 | reviewed audit | Present-state observation that passed review. |
| 5 | reviewed research | External or exploratory evidence that passed review. |
| 6 | task notes | Execution-local; durable only once saved as a finding. |
| 7 (lowest) | chat | Conversational context; never authoritative on its own. |

A draft occupies the rank one step below its accepted tier — a proposed ADR does not outrank an
approved spec.

### Domain rank

| Rank | Domain | Examples |
|---|---|---|
| 1 (highest) | enforced-policy | Externally enforced rules: permission denies, secret redaction. |
| 2 | compliance | Regulatory and legal obligations. |
| 3 | security | Authn/authz, secret handling, attack surface. |
| 4 | architecture | Module boundaries, layering, public interfaces. |
| 5 | product | User-visible behavior, acceptance criteria. |
| 6 | team | Conventions, style, process agreements. |
| 7 | task scoping | Per-task instructions. |
| 8 (lowest) | memory | Saved findings and patterns — they inform, never weaken. |

## The conflict rule

Apply lexicographically — domain first, but only inside the **hard-policy band** (domain ranks
1–3: enforced-policy, compliance, security):

1. **If either statement is in the hard-policy band**, the higher domain wins regardless of
   artifact rank — a security constraint in a reviewed audit governs a product requirement in an
   approved spec. One condition: the in-band statement must live in a durable, reviewed artifact
   (rank 1–5). A security claim sitting only in task notes or chat must first be saved and
   reviewed before it can govern anything.
2. **Otherwise**, the higher artifact rank wins; if artifact ranks tie, the higher domain breaks
   the tie. A team-convention remark in an audit never overrides a product requirement in an
   approved spec — outside the band, the container's settledness governs.
3. **If both axes are equal, stop.** Equal-rank conflicts route to amendment — a human authoring
   act — never to auto-resolution. Resolution is a decision, not an inference.

The losing statement is not deleted; it routes to amendment so the two can be made compatible
(e.g. the product requirement's trigger gets narrowed to exclude the security case).

## Code has no authority over intent

Code and tests are **implementation reality**. They can *falsify* a requirement — producing a
Fail, a Contradicted, or a Stale result — but they never *silently amend* it. When code and a
requirement disagree, the disagreement is surfaced and resolved by the three-way reconcile in
[drift](drift.md): re-run the verification, amend the requirement, or fix the code. There is no
quiet fourth option where the code's behavior becomes the new requirement because nobody looked.

## Which edits need approval

The same ladder answers who may change the requirement set. The dividing line is semantic
effect (checklist level — review inspects it):

| Edit | Approval |
|---|---|
| Add, remove, or renumber a requirement ID | Yes |
| Change a requirement's actor, trigger, strength word, outcome, or a non-goal | Yes |
| Make a breaking change to a declared interface | Yes |
| Resolve a `[blocking]` open question | Yes |
| Add, remove, or repoint a `Verify with:` / `VERIFY BY` binding | Yes — what counts as evidence changed |
| Accept manual evidence where none or an automated method stood before | Yes |
| Approve or supersede an ADR; turn a finding into a spec requirement | Yes |
| Fix formatting, casing, or a typo; complete a link; compress redundant prose | No — meaning-preserving |

"Yes" means an authoring act by the **owner of the highest-ranked governing artifact in the
relevant domain**: the spec's `owner:` for its requirements, the ADR's owner for decisions, the
security owner for a security-domain change. Corpus fixes only that the act comes from the
resolved owner; who that person is stays a local decision. An agent applying a "Yes" edit on its
own is exactly the silent amendment this page forbids.

## The high-oversight band

Some work must not reach a merge decision on agent self-assessment alone (convention level):

- **Triggers:** the work is declared critical-risk, or it writes an irreversible or shared
  surface — a DB migration, a destructive operation, a public interface many parties consume.
- **Rule:** a named human reviews and signs the result — the review packet's manual check names
  who looked and what they saw. Any waiver of a Fail or Unverified in this band is issued by a
  human or the spec owner — never by the agent that did the work — and carries a reason and an
  expiry. There are no permanent waivers.

## Related

- [Drift](drift.md) — the three-way reconcile a code/intent divergence routes to.
- [Distillation](distillation.md) — why an observation never silently becomes intent.
- [Checks](checks.md) — the contradiction and authority checks a reviewer (or `swarm check`) can flag.
- [Reviewing output](../08-reviewing-output.md) — where results and waivers are recorded.
