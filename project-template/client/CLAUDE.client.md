
## Client capture rules

This is client work, so on top of the capture rules above, the facts for the client deliverables must land in the repo as we go. The extra mapping is in `docs/agents/capture-client.md`.

- **Read `.capture/project.yaml` at the start of a session.** It holds the client, the approver, the contract terms and `ai_processing`.
- **Every new client ask is a `change-request`.** It stays `needs-triage` until its Client approval link is filled in. CI blocks ready and done without it. Never build it before that.
- **A change to something agreed is a `direction-change`.** Supersede, never delete.
- **Every spec has numbered acceptance criteria (`AC-<spec issue>-<n>`).** Tickets and tests refer to them.
- **Log access and secrets you set up as `access-grant`, names only.** Log what we need or assume from the client as `dependency`.
- **Respect `ai_processing`.** When it is `metadata-only`, don't read client mail or transcripts.
- **Deliverables live in `docs/deliverables/`.** `/capture-review` creates and updates them weekly. The index of file names is in `docs/deliverables/README.md`.
