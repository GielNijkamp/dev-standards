## Agent skills

### Issue tracker

GitHub Issues in this repo, via the `gh` CLI. See `docs/agents/issue-tracker.md`.

### Triage labels

The five default triage labels. See `docs/agents/triage-labels.md`.

### Domain docs

Single context: `GLOSSARY.md` and `docs/adr/` at the repo root. See `docs/agents/domain.md`.

## Capture rules

This is client work. Every fact a deliverable needs must land in the repo while we work, not at the end. The deliverables are in `docs/deliverables/`. The full skill-by-skill mapping is in `docs/agents/capture.md`. Read it before running any skill.

- **If it isn't in an issue, a doc or a commit, it didn't happen.** Chat is not storage.
- **Store each fact in one place only:**
  - Terms go in `GLOSSARY.md`.
  - Hard-to-reverse decisions go in `docs/adr/`.
  - Every other fact goes in a labelled issue.
- **Use `/capture` the moment something worth logging happens:** a decision, a shortcut, a console change, a fix you could forget, access granted, a new client ask. Propose it yourself when you notice one. Never wait to be asked.
- **Every new client ask is a `change-request`.** It stays `needs-triage` until its approval link is filled in. Never build it before that.
- **Every spec has numbered acceptance criteria (`AC-<spec issue>-<n>`).** Tickets and tests refer to them.
- **Never store secret values.** Store the secret's name and where it lives.
- **Respect `ai_processing` in `.capture/project.yaml`.** When it is `metadata-only`, don't read client mail or transcripts.
- **Read `.capture/project.yaml` at the start of a session.** It holds the client, the approver, the contract terms and the environments.

## Project-specific

- What it is:
- Client:
- Stack:
- Run locally:
- Test:
- Deploy:
