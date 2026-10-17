
## Client repo

This repo also has client types: `change-request`, `direction-change`, `dependency`, `access-grant` and `out-of-scope`. They are listed in `docs/agents/capture-client.md`.

- A new client ask is always a `change-request` with `needs-triage` and an empty approval link. Never mark it ready.
- A change to something already agreed is a `direction-change`, not a plain decision.
