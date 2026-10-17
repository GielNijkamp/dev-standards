# Coding standards

Project-specific coding rules go here. `/code-review` checks every diff against this file.

## Capture

These are review rules. A missed capture is a finding, like a bug. CI already checks the mechanical ones: PR links, the Capture section, TODO markers and secrets.

- **Shortcut without debt issue.** A workaround, hard-coded value, skipped validation or disabled test, with no `tech-debt` issue linked in the PR.
- **New config not documented.** A new env var, feature flag or config key missing from `.env.example`.
- **Infra change without docs.** IaC, CI, Docker or schedule changes that the README or a linked issue doesn't explain.
- **Irreversible change without ADR.** A schema migration without a rollback note, a new external service or a new data store, with no ADR linked.
- **Secret handling.** Any secret value, token or credential in code, tests, fixtures or docs. Only names and `op://` references are allowed.
- **Scope creep.** Behaviour no ticket or spec asked for.
