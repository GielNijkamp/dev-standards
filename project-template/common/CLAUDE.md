## Agent skills

- Issue tracker: GitHub Issues via `gh`. Details: `docs/agents/issue-tracker.md`.
- Triage labels: `needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human`, `wontfix`. Categories: `bug`, `enhancement`.
- Domain docs: `GLOSSARY.md` and `docs/adr/` at the root. `/domain-modeling` creates them when needed. Use glossary terms in code, issues and tests. Flag any conflict with an ADR.

## Capture

Facts go into the repo as they happen, not into chat. Map: `docs/agents/capture.md`.

- Terms go in `GLOSSARY.md`. Hard-to-reverse decisions go in `docs/adr/`. Everything else is a labelled issue.
- Use `/capture` when a decision, shortcut, change outside the code or hard-won fix happens. Suggest it yourself.
- Never store secret values. Store the name and where it lives.
- CI (`capture-checks.yml`): PRs link an issue and fill in Capture. TODO markers need an issue number. gitleaks runs.
- `/code-review` also checks `CODING_STANDARDS.md`.

## Project-specific

- What it is:
- Stack:
- Run locally:
- Test:
- Deploy:
