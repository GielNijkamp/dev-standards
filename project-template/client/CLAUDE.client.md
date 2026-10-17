
## Client capture

- Read `.capture/project.yaml` at session start: client, approver, contract terms, `ai_processing`.
- New client ask: `change-request`. No work until it has an approval link.
- Change to something agreed: `direction-change`. Supersede, never delete.
- Specs carry `AC-<spec>-<n>` acceptance criteria. Tickets and tests reference them.
- `ai_processing: metadata-only` means don't read client mail or transcripts.
- Deliverables are written to `docs/deliverables/` by `/capture-review`. In the first session, set up a scheduled task that runs it every Friday afternoon, if none exists.
