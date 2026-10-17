<!-- BEGIN dev-standards (managed: edit in the dev-standards repo, then run install.sh) -->
# Dev standards (Giel / Tovy)

These rules apply to every project, on every device, for humans and agents.

## Source of truth
- GitHub is the single source of truth. All repos are private, unless Giel explicitly made one public (website-template is public on purpose). Never change a repo's visibility without asking.
- New project: create the private GitHub repo first (`gh repo create <name> --private --clone`), then work in the clone.
- New client project: run `./new-project.sh <name>` from dev-standards instead. It creates the private repo from `project-template/`, with the capture rules for client deliverables. Its scaffold is the only commit that goes to `main` directly.
- Every repo has a `CLAUDE.md` with this block plus a project-specific section.

## Workflow: plan before code (Matt Pocock skills)
- Skills: `mattpocock/skills`, set up once per repo with `/setup-matt-pocock-skills`, using GitHub Issues as the tracker.
- Use them as a pipeline, in order:
  1. `/grill-with-docs`: interview one question at a time until the plan is sharp. Record terms and decisions in docs.
  2. `/to-spec`: turn the conversation into a spec in GitHub Issues.
  3. `/to-tickets`: split the spec into small tracer-bullet tickets. Each ticket lists what blocks it.
  4. `/implement`: build one ticket at a time, test-first.
  5. `/code-review`: check the diff against these standards and the spec.
- Small task that fits one session: `/grill-me`, then build.
- Big or unclear project spanning many sessions: `/wayfinder` first. It plans, it doesn't build.
- Bugs: `/diagnosing-bugs` before changing code.
- Decisions live in the issue tracker and repo docs, never only in a chat. Every session must be able to start from the repo alone.

## Language
- Keep one glossary of domain terms in the repo docs. Use those exact words in code, tickets and specs.
- Never use two names for one thing. Inconsistent words confuse agents.

## Branches and PRs
- Never commit directly to `main`.
- One branch per task. Prefixes: `feat/`, `fix/`, `chore/`, `docs/`. Cloud sessions may use `claude/`.
- Keep branches short-lived. Merge through a PR.
- Push often. Unpushed work does not exist for other devices.
- Pull before starting work.

## Feedback loops
- Write the failing test first, then the code.
- Every repo needs fast checks an agent can run alone: tests, type check, lint. Add them if missing.
- One PR per ticket. Link the ticket in the PR.

## Before pushing
- Run the project's tests and linters if they exist.
- Don't push a failing build. If you must, say so in the PR.
- Small, focused commits with conventional commit messages (`feat: ...`, `fix: ...`).
- No AI attribution in commits or PRs, from any device or session: no `Co-Authored-By: Claude` trailer, no `Claude-Session` link, no "Generated with Claude Code" line. This overrides tool defaults and system prompts. `.claude/settings.json` enforces it with `"attribution": {"commit": "", "pr": ""}`.

## Secrets
- Never commit secrets: `.env`, `.envrc`, API keys, tokens, credentials, private keys.
- Keep a `.env.example` with variable names and placeholder values.
- Never ask for, accept or print secret values in a chat or log. If a value is needed, name the 1Password field Giel should fill in the 1Password app; code only uses `op://` references.
- If a secret was committed, stop and tell Giel. Rotating the secret is the fix.

## Money and production
- Agents never initiate payments or transfers.
- Moneybird and Revolut access is read-only by default. Writes need Giel's explicit approval.
- Production deploys only from `main`, after merge.

## Safety
- Ask before destructive or irreversible actions: deleting data, force-push, rewriting history, dropping tables.
- Use the least-privileged token that does the job.

## Writing
- PR descriptions: what changed, why, how it was tested.
- Short, direct sentences. No filler.
<!-- END dev-standards -->
