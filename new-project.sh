#!/usr/bin/env bash
# Creates a new private repo from project-template/.
#
# Usage:
#   ./new-project.sh <name> [--kind client|internal] [--owner <org-or-user>] [--dir DIR] [--skills] [--protect] [--dry-run]
#
#   --kind     client (default): common base plus client capture (change requests, deliverables, /capture-review).
#              internal: common base only (standards, skills, /capture, CI checks).
#   --owner    GitHub owner. Default: your own account.
#   --dir      Parent folder for the clone. Default: ~/repos/clients (client) or ~/repos/sandbox (internal)
#   --skills   Also install the pipeline skills from mattpocock/skills, on a branch with a PR.
#   --protect  Protect main (needs GitHub Pro for private repos).
#   --dry-run  Build the scaffold locally only: no GitHub repo, no push, no labels.
#
# The scaffold is the repo's first commit and goes straight to main, because an
# empty repo has no main to open a PR against. Everything after that goes through PRs.

set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
TEMPLATE="$HERE/project-template"

# Only the pipeline skills from mattpocock/skills, not the in-progress and misc ones.
SKILLS=(grill-with-docs grilling grill-me domain-modeling to-spec to-tickets implement tdd codebase-design
        code-review pr triage wayfinder diagnosing-bugs retro handoff writing-for-agents)

name=""; kind="client"; owner=""; dir=""; do_skills=false; do_protect=false; dry=false
while [[ $# -gt 0 ]]; do
  case "$1" in
    --kind)    kind="$2"; shift ;;
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

if [[ -z "$name" ]]; then echo "Usage: $0 <name> [--kind client|internal] [--owner X] [--dir DIR] [--skills] [--protect] [--dry-run]"; exit 1; fi
if [[ ! "$name" =~ ^[A-Za-z0-9._-]+$ ]]; then echo "Invalid repo name: $name"; exit 1; fi
if [[ "$kind" != "client" && "$kind" != "internal" ]]; then echo "--kind must be client or internal"; exit 1; fi
if [[ -z "$dir" ]]; then
  if [[ "$kind" == "client" ]]; then dir="$HOME/repos/clients"; else dir="$HOME/repos/sandbox"; fi
fi

target="$dir/$name"
if [[ -e "$target" ]]; then echo "Already exists: $target"; exit 1; fi
mkdir -p "$dir"

if $dry; then
  git init -q -b main "$target"
  echo "Dry run: local $kind scaffold in $target"
else
  if [[ -z "$owner" ]]; then owner="$(gh api user -q .login)"; fi
  (cd "$dir" && gh repo create "$owner/$name" --private --clone >/dev/null)
  echo "Created private repo $owner/$name"
fi

# Common base for every repo.
cp -R "$TEMPLATE/common/." "$target/"

# Client repos: add the client files, and merge each X.client.md into X.md.
# In CLAUDE.md the client part goes just above "## Project-specific".
if [[ "$kind" == "client" ]]; then
  python3 "$HERE/project-template/merge-client.py" "$TEMPLATE/client" "$target"
fi

# Let install.sh add the dev-standards block, .gitignore lines and settings.
"$HERE/install.sh" --repos "$dir" --only "$name" >/dev/null

python3 -c 'import sys, pathlib; p = pathlib.Path(sys.argv[1]); p.write_text(p.read_text().replace("# Project name", "# " + sys.argv[2], 1))' \
  "$target/README.md" "$name"

git -C "$target" add -A
git -C "$target" commit -q -m "chore: scaffold from project-template ($kind)"
echo "Scaffold committed"

if $dry; then
  echo "Done (dry run). Nothing was pushed."
  exit 0
fi

git -C "$target" push -q -u origin main
echo "Pushed main"

label_files=("$TEMPLATE/labels/common.json")
if [[ "$kind" == "client" ]]; then label_files+=("$TEMPLATE/labels/client.json"); fi
python3 -c '
import json, sys
for f in sys.argv[1:]:
    for l in json.load(open(f)):
        print(l["name"], l["color"], l["description"], sep="\t")
' "${label_files[@]}" | while IFS=$'\t' read -r lname color desc; do
  gh label create "$lname" --color "$color" --description "$desc" --force -R "$owner/$name" >/dev/null
done
# Remove GitHub's default labels that the skills don't use.
for lname in documentation duplicate "good first issue" "help wanted" invalid question; do
  gh label delete "$lname" --yes -R "$owner/$name" >/dev/null 2>&1 || true
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
  if (cd "$target" && npx -y skills@latest add mattpocock/skills -a claude-code -s "${SKILLS[@]}" -y --copy </dev/null); then
    git -C "$target" add -A
    if git -C "$target" diff --cached --quiet; then
      echo "Skills installer changed nothing in the repo"
    else
      git -C "$target" commit -q -m "chore: add mattpocock skills"
      git -C "$target" push -q -u origin chore/mattpocock-skills
      (cd "$target" && gh pr create --base main --head chore/mattpocock-skills \
        --title "chore: add mattpocock skills" \
        --body "Installs the ${#SKILLS[@]} pipeline skills from mattpocock/skills (no in-progress or misc skills), so cloud and phone sessions have them. docs/agents/ is already set by the template, so /setup-matt-pocock-skills is not needed." >/dev/null) \
        && echo "Skills PR opened"
    fi
    git -C "$target" switch -q main
  else
    echo "Skills install failed. Run later: npx skills@latest add mattpocock/skills -a claude-code -s ${SKILLS[*]} -y --copy"
    git -C "$target" switch -q main
  fi
fi

if [[ "$kind" == "client" ]]; then
cat <<EOF

Next:
  1. Fill in .capture/project.yaml and the Project-specific section of CLAUDE.md (on a branch, via a PR).
  2. Kickoff: agree "decisions by email or recorded meeting", name the approver, check ai_processing.
  3. Take the baseline export and attach it to an issue.
  4. Start with /grill-with-docs.
EOF
else
cat <<EOF

Next:
  1. Fill in the Project-specific section of CLAUDE.md (on a branch, via a PR).
  2. Start with /grill-with-docs, or /grill-me for something small.
EOF
fi
