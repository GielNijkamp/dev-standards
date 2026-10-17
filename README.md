# dev-standards

One set of rules for every project, on laptop and phone.

- `standards.md`: the rules. The only file you edit.
- `install.sh`: writes the rules into `~/.claude/CLAUDE.md` and each repo's `CLAUDE.md`, and turns off Claude's commit/PR attribution in `~/.claude/settings.json` and each repo's `.claude/settings.json`.
- `publish-repos.sh`: pushes local-only repos to GitHub as private repos.
- `post-move.sh`: fixes dotfiles links, Claude Code history, virtualenvs and direnv after the ~/repos reorganisation.
- `new-project.sh`: creates a new private repo from `project-template/`, as `--kind client` or `--kind internal`.
- `project-template/`: the repo scaffold. `common/` goes into every repo. `client/` is added for client work. `labels/` holds the labels for each kind.
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

## New project

```bash
cd ~/repos/tooling/dev-standards
./new-project.sh bakkerij-forecast --kind client --owner tovy-eu --skills
./new-project.sh route-planner --kind internal --skills
./new-project.sh test-run --dry-run      # local only, to look at the scaffold
```

### From your phone or a cloud session

The `new-project` workflow runs the same script on GitHub. Any session that can reach this repo can start it, and it never sees a token:

```bash
gh workflow run new-project.yml -R GielNijkamp/dev-standards -f name=bakkerij-forecast -f kind=client -f owner=tovy-eu
```

You can also run it from the Actions tab in the GitHub app.

One-time setup:

1. **Create a fine-grained token.** Go to GitHub → Settings → Developer settings → Fine-grained tokens.
    - Resource owner: `tovy-eu`. Make a second token for your own account if you also create repos there.
    - Repository access: All repositories.
    - Permissions: Administration, Contents, Workflows, Issues and Pull requests all read/write. Metadata read.
    - Expiry: 90 days. Set a reminder to rotate it.
2. **Store it as a secret.** In this repo, go to Settings → Secrets and variables → Actions → New secret, and name it `NEW_PROJECT_TOKEN`. Paste it there and nowhere else.
3. **Give Claude access to new repos.** Check that the Claude GitHub App on `tovy-eu` has access to *All repositories*, so cloud sessions can open a new repo straight away.

What each kind gets on top of the standards block:

| | internal | client |
| --- | --- | --- |
| `CLAUDE.md` capture rules, pointing only to what's in the repo | yes | yes, plus client rules |
| `docs/agents/capture.md`: what each Matt Pocock skill stores, and where | yes | yes, plus `capture-client.md` |
| `docs/agents/*` preset for GitHub Issues (no `/setup-matt-pocock-skills` needed) | yes | yes |
| 17 pipeline skills (with `--skills`), via a PR | yes | yes |
| `/capture` skill | yes | yes |
| Issue forms: decision, tech debt, manual step, ops learning | yes | yes |
| Issue forms: change request, direction change, access grant | | yes |
| PR template with Capture section, `CODING_STANDARDS.md` for `/code-review` | yes | yes, plus client rules |
| CI: PR links an issue, Capture filled in, TODOs need an issue, gitleaks | yes | yes |
| CI: change requests need an approval link before ready or done | | yes |
| `.capture/project.yaml` manifest | | yes |
| `docs/deliverables/README.md` index. `/capture-review` creates the files when they have content | | yes |
| Labels | 15 | 22 |

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
