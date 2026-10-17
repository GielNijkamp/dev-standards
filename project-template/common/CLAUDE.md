## Agent skills

### Issue tracker

GitHub Issues in this repo, via the `gh` CLI. See `docs/agents/issue-tracker.md`.

### Triage labels

The five default triage labels. See `docs/agents/triage-labels.md`.

### Domain docs

Single context: `GLOSSARY.md` and `docs/adr/` at the repo root, created when first needed. See `docs/agents/domain.md`.

## Capture rules

Every fact we'll need later lands in the repo while we work. Chat is not storage. Where each skill stores what is listed in `docs/agents/capture.md`. Read it before running a skill.

- **Store each fact in one place only:**
  - Terms go in `GLOSSARY.md`.
  - Hard-to-reverse decisions go in `docs/adr/`.
  - Every other fact goes in a labelled issue: `decision`, `tech-debt`, `manual-step`, `ops-learning`, `incident`, `risk` or `future`.
- **Use `/capture` the moment something worth logging happens:** a decision, a shortcut, a change outside the code, a fix you could forget. Propose it yourself when you notice one.
- **Never store secret values.** Store the secret's name and where it lives.
- **CI enforces the mechanical rules in `.github/workflows/capture-checks.yml`:**
  - PRs must link an issue and fill in the PR template's Capture section.
  - TODO, FIXME, HACK and XXX markers need an issue number.
  - gitleaks runs.
- **`/code-review` checks the judgement calls in `CODING_STANDARDS.md`.**

## Project-specific

- What it is:
- Stack:
- Run locally:
- Test:
- Deploy:
