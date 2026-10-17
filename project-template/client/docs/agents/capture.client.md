## Client work

| Fact | Where |
| --- | --- |
| Excluded ask | issue `out-of-scope` |
| New client ask | issue `change-request` (form) |
| Change to something agreed | issue `direction-change` |
| Need or assumption on the client side | issue `dependency`, with owner and date |
| Access or secret set up | issue `access-grant`, names only |
| Acceptance criterion | spec section `## Acceptance Criteria`, `AC-<spec>-<n>` |
| Bug severity | `sev:blocking` or `sev:minor` |

- `/grill-with-docs`: also `out-of-scope` and `dependency`. Client-stated numbers go in `decision`.
- `/to-spec`: add `## Acceptance Criteria` with testable `AC-<spec>-<n>`. First line `Implements #<n>` if it comes from a change request.
- `/to-tickets`: `Delivers: AC-<spec>-<n>, ...`.
- `/tdd`: test names include the AC id.
- `/triage`: a new ask gets `enhancement` + `change-request` and stays `needs-triage` until it has an approval link. CI enforces this. Bugs get a `sev:` label. Rejected asks get `wontfix` + `out-of-scope`.
