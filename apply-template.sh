#!/usr/bin/env bash
# Brings an existing repo up to the project template, via one PR.
# Keeps the repo's own CLAUDE.md sections, docs, code and issues.
#
# Usage:
#   ./apply-template.sh <owner/repo> [--kind internal|client] [--skills] [--dry-run]
#
#   --kind     internal (default) or client.
#   --skills   Also install pipeline skills that are missing.
#   --dry-run  Show what would change. No push, no labels, no PR.

set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
TEMPLATE="$HERE/project-template"
SKILLS=($(grep -v '^#' "$TEMPLATE/skills.txt"))
BRANCH="chore/apply-template"

slug=""; kind="internal"; do_skills=false; dry=false
while [[ $# -gt 0 ]]; do
  case "$1" in
    --kind)    kind="$2"; shift ;;
    --skills)  do_skills=true ;;
    --dry-run) dry=true ;;
    -*) echo "Unknown option: $1"; exit 1 ;;
    *)  slug="$1" ;;
  esac
  shift
done

if [[ ! "$slug" =~ ^[A-Za-z0-9-]+/[A-Za-z0-9._-]+$ ]]; then echo "Usage: $0 <owner/repo> [--kind internal|client] [--skills] [--dry-run]"; exit 1; fi
if [[ "$kind" != "client" && "$kind" != "internal" ]]; then echo "--kind must be client or internal"; exit 1; fi
name="${slug#*/}"

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

git clone -q "https://github.com/$slug.git" "$tmp/$name"
base="$(git -C "$tmp/$name" symbolic-ref --short refs/remotes/origin/HEAD | sed 's#^origin/##')"
git -C "$tmp/$name" switch -q -c "$BRANCH"

# A fresh scaffold of the same kind is the source of truth for managed files.
"$HERE/new-project.sh" scaffold --kind "$kind" --dir "$tmp/scaffold" --dry-run >/dev/null
echo "Changes for $slug ($kind):"
python3 "$TEMPLATE/apply.py" "$tmp/scaffold/scaffold" "$tmp/$name" "$TEMPLATE/skills.txt" | sed 's/^/  /'

# Refresh the dev-standards block, .gitignore lines and settings.
"$HERE/install.sh" --repos "$tmp" --only "$name" >/dev/null

if $do_skills; then
  missing=()
  for s in "${SKILLS[@]}"; do [[ -d "$tmp/$name/.claude/skills/$s" ]] || missing+=("$s"); done
  if [[ ${#missing[@]} -gt 0 ]]; then
    (cd "$tmp/$name" && npx -y skills@latest add mattpocock/skills -a claude-code -s "${missing[@]}" -y --copy </dev/null >/dev/null) \
      && echo "  installed skills: ${missing[*]}"
    find "$tmp/$name/.claude/skills" -path '*/agents/openai.yaml' -delete
    find "$tmp/$name/.claude/skills" -type d -name agents -empty -delete
  fi
fi

git -C "$tmp/$name" add -A
if git -C "$tmp/$name" diff --cached --quiet; then
  echo "Already up to date."
  exit 0
fi
git -C "$tmp/$name" diff --cached --stat | tail -1 | sed 's/^/ /'

if $dry; then
  echo "Dry run: nothing pushed."
  exit 0
fi

git -C "$tmp/$name" commit -q -m "chore: apply project template ($kind)"
git -C "$tmp/$name" push -q -u origin "$BRANCH" --force-with-lease

label_files=("$TEMPLATE/labels/common.json")
if [[ "$kind" == "client" ]]; then label_files+=("$TEMPLATE/labels/client.json"); fi
python3 -c '
import json, sys
for f in sys.argv[1:]:
    for l in json.load(open(f)):
        print(l["name"], l["color"], l["description"], sep="\t")
' "${label_files[@]}" | while IFS=$'\t' read -r lname color desc; do
  gh label create "$lname" --color "$color" --description "$desc" --force -R "$slug" >/dev/null
done
for lname in documentation duplicate "good first issue" "help wanted" invalid question; do
  gh label delete "$lname" --yes -R "$slug" >/dev/null 2>&1 || true
done
echo "  labels set"

open_pr="$(gh api "repos/$slug/pulls?head=${slug%%/*}:$BRANCH&state=open" --jq '.[0].html_url // empty')"
if [[ -n "$open_pr" ]]; then
  echo "PR updated: $open_pr"
else
  body="Brings this repo up to the dev-standards project template ($kind).

- Refreshes the dev-standards block in CLAUDE.md. Replaces the Agent skills and Capture sections. Keeps Project-specific and every other section.
- Adds the capture layer: \`docs/agents/capture.md\`, \`/capture\`, \`CODING_STANDARDS.md\` and the PR template Capture section, and \`capture-checks.yml\`.
- Trims mattpocock skills to the pipeline set and removes Codex metadata.
- Sets the labels for this kind and removes GitHub's unused defaults.

Review CLAUDE.md first. That's where repo-specific text lives."
  gh api "repos/$slug/pulls" -f title="chore: apply project template ($kind)" -f head="$BRANCH" -f base="$base" -f body="$body" --jq '"PR opened: " + .html_url'
fi
