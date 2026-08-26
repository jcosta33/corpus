# Surface ownership

| Surface                                  | Authority                                                                                                          |
| ---------------------------------------- | ------------------------------------------------------------------------------------------------------------------ |
| Artifact authoring procedures            | each `SKILL.md` under [`skills/`](../skills/README.md)                                                             |
| Deterministic checking                   | `suspec check` in [suspec-cli](https://github.com/jcosta33/suspec-cli)                                             |
| Global agent policy                       | `policy/agent.md`; predecessor provenance in `policy/agent-policy-predecessors.txt`; installed by `suspec setup` in [suspec-cli](https://github.com/jcosta33/suspec-cli) |
| Shell-less checking                      | `suspec_check`, `suspec_get_checks`, and `suspec://checks` in [suspec-mcp](https://github.com/jcosta33/suspec-mcp) |
| Human method and format reference        | this repository's `docs/`                                                                                          |
| Machine checks contract                  | `checks/checks.yaml`                                                                                               |

[Artifact formats](reference/artifact-formats.md) define current working documents. No hidden store
does the handoff for you. Skills carry their absolute paths through each handoff. Findings are not an
artifact type: transient observations stay with live work; durable lessons move to native memory or
project-owned records.

An ADR records a decision. Reference explains it. Skills execute it. The checks contract owns only
the deterministic subset. Split ownership is not permission for split truth: change every affected
owner together.
