# dev-standards

One set of rules for every project, on laptop and phone.

- `standards.md`: the rules. The only file you edit.
- `install.sh`: writes the rules into `~/.claude/CLAUDE.md` and each repo's `CLAUDE.md`, and turns off Claude's commit/PR attribution in `~/.claude/settings.json` and each repo's `.claude/settings.json`.
- `publish-repos.sh`: pushes local-only repos to GitHub as private repos.
- `post-move.sh`: fixes dotfiles links, Claude Code history, virtualenvs and direnv after the ~/repos reorganisation.
- `apply-repos.sh`: one-time run for `~/repos`. Publishes your own projects privately, makes public ones private, opens a standards PR in each, installs the global file.

## First run

```bash
cd ~/repos/tooling/dev-standards
chmod +x *.sh
./post-move.sh     # once, after the folder reorganisation
./apply-repos.sh
```

Then merge the PRs and run `git pull` in each repo.

The standards PRs are made in a temporary worktree. Your current branch and uncommitted work stay as they are.

## Changing a rule

1. Edit `standards.md` on a branch, open a PR in this repo, merge.
2. Run `./install.sh --global --repos ~/repos --only "<repos>" --pr`.

## Matt Pocock's skills (per repo, once)

```bash
cd ~/repos/<repo> && npx skills@latest add mattpocock/skills
```

Then run `/setup-matt-pocock-skills` in Claude Code and pick GitHub Issues as the tracker.

Only the block between the `dev-standards` markers changes. Your project-specific notes stay.

## Daily workflow (from Matt Pocock's skills)

- Small task: `/grill-me`, then build.
- Feature: `/grill-with-docs` → `/to-spec` → `/to-tickets` → `/implement` → `/code-review`.
- Big or unclear project: `/wayfinder` first.
- Specs and tickets live in GitHub Issues, so you can start a ticket from your phone.

## Notes

- Cloud sessions on your phone only read the repo's `CLAUDE.md`, not your global file. That's why every repo gets the block.
- Branch protection on private repos needs GitHub Pro. Without it, `--protect` warns and moves on; the rule still lives in `CLAUDE.md`.
- Check that the skills installer writes into the repo (for example `.claude/skills/`), so phone sessions get the skills too.
- Install `gitleaks` (`brew install gitleaks`) for a deeper secret scan before publishing.
- Fill in the "Project-specific" section in each repo. It makes phone sessions much better.
