#!/usr/bin/env bash
# Creates a new private client repo from project-template/.
#
# Usage:
#   ./new-project.sh <name> [--owner <org-or-user>] [--dir ~/repos/clients] [--skills] [--protect] [--dry-run]
#
#   --owner    GitHub owner. Default: your own account.
#   --dir      Parent folder for the clone. Default: ~/repos/clients
#   --skills   Also install mattpocock/skills, on a branch with a PR.
#   --protect  Protect main (needs GitHub Pro for private repos).
#   --dry-run  Build the scaffold locally only: no GitHub repo, no push, no labels.
#
# The scaffold is the repo's first commit and goes straight to main, because an
# empty repo has no main to open a PR against. Everything after that goes through PRs.

set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
TEMPLATE="$HERE/project-template"

name=""; owner=""; dir="$HOME/repos/clients"; do_skills=false; do_protect=false; dry=false
while [[ $# -gt 0 ]]; do
  case "$1" in
    --owner)   owner="$2"; shift ;;
    --dir)     dir="$2"; shift ;;
    --skills)  do_skills=true ;;
    --protect) do_protect=true ;;
    --dry-run) dry=true ;;
    -*) echo "Unknown option: $1"; exit 1 ;;
    *)  name="$1" ;;
  esac
  shift
done

if [[ -z "$name" ]]; then echo "Usage: $0 <name> [--owner X] [--dir DIR] [--skills] [--protect] [--dry-run]"; exit 1; fi
if [[ ! "$name" =~ ^[A-Za-z0-9._-]+$ ]]; then echo "Invalid repo name: $name"; exit 1; fi

target="$dir/$name"
if [[ -e "$target" ]]; then echo "Already exists: $target"; exit 1; fi
mkdir -p "$dir"

if $dry; then
  git init -q -b main "$target"
  echo "Dry run: local scaffold in $target"
else
  if [[ -z "$owner" ]]; then owner="$(gh api user -q .login)"; fi
  (cd "$dir" && gh repo create "$owner/$name" --private --clone >/dev/null)
  echo "Created private repo $owner/$name"
fi

# Copy the template, then let install.sh add the dev-standards block, .gitignore lines and settings.
cp -R "$TEMPLATE/." "$target/"
"$HERE/install.sh" --repos "$dir" --only "$name" >/dev/null

python3 - "$target/README.md" "$name" <<'PY'
import sys, pathlib
p = pathlib.Path(sys.argv[1])
p.write_text(p.read_text().replace("# Project name", f"# {sys.argv[2]}", 1))
PY

git -C "$target" add -A
git -C "$target" commit -q -m "chore: scaffold from project-template"
echo "Scaffold committed"

if $dry; then
  echo "Done (dry run). Nothing was pushed."
  exit 0
fi

git -C "$target" push -q -u origin main
echo "Pushed main"

python3 - "$TEMPLATE/.github/labels.json" <<'PY' | while IFS=$'\t' read -r lname color desc; do
import json, sys
for l in json.load(open(sys.argv[1])):
    print(f"{l['name']}\t{l['color']}\t{l['description']}")
PY
  gh label create "$lname" --color "$color" --description "$desc" --force -R "$owner/$name" >/dev/null
done
echo "Labels created"

if $do_protect; then
  if gh api -X PUT "repos/$owner/$name/branches/main/protection" --silent --input - >/dev/null 2>&1 <<'JSON'
{
  "required_status_checks": null,
  "enforce_admins": false,
  "required_pull_request_reviews": { "required_approving_review_count": 0 },
  "restrictions": null,
  "allow_force_pushes": false,
  "allow_deletions": false
}
JSON
  then echo "main protected"
  else echo "Protect failed (private repos need GitHub Pro)"
  fi
fi

if $do_skills; then
  git -C "$target" switch -q -c chore/mattpocock-skills
  if (cd "$target" && npx -y skills@latest add mattpocock/skills); then
    git -C "$target" add -A
    if git -C "$target" diff --cached --quiet; then
      echo "Skills installer changed nothing in the repo"
    else
      git -C "$target" commit -q -m "chore: add mattpocock skills"
      git -C "$target" push -q -u origin chore/mattpocock-skills
      (cd "$target" && gh pr create --base main --head chore/mattpocock-skills \
        --title "chore: add mattpocock skills" \
        --body "Installs mattpocock/skills into the repo so cloud and phone sessions have them. The skills config in docs/agents/ is already set by the template, so /setup-matt-pocock-skills is not needed." >/dev/null) \
        && echo "Skills PR opened"
    fi
    git -C "$target" switch -q main
  else
    echo "Skills install failed. Run later: npx skills@latest add mattpocock/skills"
    git -C "$target" switch -q main
  fi
fi

cat <<EOF

Next:
  1. Fill in .capture/project.yaml and the Project-specific section of CLAUDE.md (on a branch, via a PR).
  2. Kickoff: agree "decisions by email or recorded meeting", name the approver, check ai_processing.
  3. Take the baseline export and attach it to an issue.
  4. Start with /grill-with-docs.
EOF
