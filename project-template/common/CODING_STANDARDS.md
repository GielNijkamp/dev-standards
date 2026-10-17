# Coding standards

`/code-review` checks every diff against this file. Add project rules at the top.

## Capture

A missed capture is a finding.

- A shortcut, hard-coded value, skipped validation or disabled test without a linked `tech-debt` issue.
- A new env var or config key missing from `.env.example`.
- An IaC, CI or schedule change that no doc or linked issue explains.
- A migration without a rollback note, or a new external service or data store, without an ADR.
- A secret value anywhere. Only names and `op://` references are allowed.
- Behaviour no ticket asked for.
