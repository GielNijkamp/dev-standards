# Client capture: what client work adds

This adds to `docs/agents/capture.md`. Everything there still applies.

## Extra storage

| Fact | Stored in | Label or path | Feeds deliverable |
| --- | --- | --- | --- |
| Excluded ask | Issue | `out-of-scope` | SOW |
| New client ask | Issue form | `change-request` | SOW, Acceptance |
| Change to something agreed | Issue form | `direction-change` | All affected deliverables |
| Need or assumption on the client side (access, data, people) | Issue | `dependency`, with owner and date | SOW, Known issues |
| Access granted, secret created | Issue form | `access-grant` | Access |
| Acceptance criterion | Spec, `## Acceptance Criteria` | `AC-<spec>-<n>` | Tests, Acceptance |
| Bug severity | Issue | `sev:blocking` or `sev:minor` | Acceptance |

## Per skill, on top of the base rules

- **`/grill-with-docs`:**
    - Anything the client said is out goes in `out-of-scope`.
    - What we rely on from the client goes in `dependency`.
    - Numbers the client states go in a `decision` issue.
- **`/to-spec`:**
    - Add `## Acceptance Criteria` after `## User Stories`, numbered `AC-<spec issue>-<n>`. Each one must be testable.
    - List `out-of-scope` issues under `## Out of Scope` too.
    - If the spec implements an approved change request, its first line is `Implements #<n>`.
- **`/to-tickets`:** each ticket names the ACs it delivers, for example `Delivers: AC-12-1, AC-12-3`.
- **`/implement`, `/tdd`:**
    - Test names include the AC id they prove.
    - Access or a secret you set up becomes an `access-grant`, with the name only.
- **`/triage`:**
    - A new client ask becomes `enhancement` + `change-request`. It stays `needs-triage` until the Client approval link is filled in. CI enforces this.
    - Client bugs get `bug` plus `sev:blocking` or `sev:minor`.
    - Rejected asks go to `wontfix` + `out-of-scope`.
- **`/wayfinder`:** a direction change too big for one session gets a map. Still open a `direction-change` issue linked to it.
- **`/retro`:** at each milestone, add 3–5 lines to the Lessons section of the known-issues deliverable. Create the file if needed.

## Deliverables

`docs/deliverables/README.md` lists the 13 file names and their sources. A file is created the first time `/capture-review` has content for it, never as an empty skeleton.
