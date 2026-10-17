# Coding standards

Project-specific coding rules go here. `/code-review` checks every diff against this file.

## Capture

These are review rules. A missed capture is a finding, the same as a bug. CI already checks the mechanical ones (TODO markers, PR links, approval links, secrets). The reviewer checks the judgement calls below.

- **Shortcut without debt issue.** A workaround, hard-coded value, skipped validation or disabled test that has no `tech-debt` issue linked in the PR.
- **New config not documented.** A new environment variable, feature flag or config key that is missing from `.env.example` or from `docs/deliverables/04-infrastructure.md`.
- **Infra change without docs.** Changes to IaC, CI workflows, Docker files or schedules, while the matching deliverable (`04-infrastructure.md` or `06-cicd.md`) is unchanged and the PR doesn't say why.
- **Irreversible change without ADR.** A schema migration without a rollback note, a new external service, or a new data store, with no ADR linked.
- **Secret handling.** Any secret value, token or credential in code, tests, fixtures or docs. Only names and `op://` references are allowed.
- **Untraceable test.** A test for a spec'd behaviour that doesn't name its `AC-<spec>-<n>` id.
- **Scope creep.** Behaviour that no ticket or spec asked for. Flag it so it can become a `change-request` or be removed.
- **Personal data.** A new field or log line that holds personal data (name, email, phone, address, IBAN, BSN) without an update to `docs/deliverables/08-data.md`.
