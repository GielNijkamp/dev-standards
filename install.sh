#!/usr/bin/env bash
# Installs the dev-standards block globally and/or into repos.
#
# Usage:
#   ./install.sh --global                          # ~/.claude/CLAUDE.md
#   ./install.sh --repos ~/repos --pr              # every repo under ~/repos, via a PR each
#   ./install.sh --repos ~/repos --only "a b" --pr # only the named repos
#   ./install.sh --repos ~/repos                   # write files in the working tree, no git
#   add --skills  to also install mattpocock/skills (working-tree mode only)
#   add --protect to also protect the default branch (needs GitHub Pro for private repos)
#
# --pr mode works in a temporary git worktree based on the remote default branch.
# Your checked-out branch and uncommitted changes are never touched.
# Re-run any time after editing standards.md. Only the managed block changes.

set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
BLOCK="$HERE/standards.md"
BRANCH="chore/dev-standards"
GITIGNORE_LINES=(".env" ".env.*" "!.env.example" ".envrc" "*.pem" "*.key" ".DS_Store" ".claude/settings.local.json")

do_global=false; repos_dir=""; only=""; do_pr=false; do_protect=false; do_skills=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --global)  do_global=true ;;
    --repos)   repos_dir="$2"; shift ;;
    --only)    only="$2"; shift ;;
    --pr)      do_pr=true ;;
    --protect) do_protect=true ;;
    --skills)  do_skills=true ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
  shift
done

PROJECT_TEMPLATE='## Project-specific
- What it is:
- Stack:
- Run locally:
- Test:
- Deploy:
'

# Replace the managed block in a file, or add it at the top.
update_block() {
  local file="$1" template="${2:-}"
  if [[ -f "$file" ]] && grep -q "BEGIN dev-standards" "$file"; then
    awk -v bf="$BLOCK" '
      BEGIN { while ((getline l < bf) > 0) b = b l "\n" }
      /BEGIN dev-standards/ { printf "%s", b; skip = 1; next }
      /END dev-standards/   { skip = 0; next }
      !skip { print }
    ' "$file" > "$file.tmp" && mv "$file.tmp" "$file"
  elif [[ -f "$file" ]]; then
    { cat "$BLOCK"; echo; cat "$file"; } > "$file.tmp" && mv "$file.tmp" "$file"
  else
    { cat "$BLOCK"; echo; if [[ -n "$template" ]]; then printf "%s" "$template"; fi; } > "$file"
  fi
}

# Turn off Claude Code's commit and PR attribution (Co-Authored-By, "Generated with").
update_settings() {
  local file="$1"
  mkdir -p "$(dirname "$file")"
  python3 - "$file" <<'PY'
import json, sys, pathlib
p = pathlib.Path(sys.argv[1])
try:
    data = json.loads(p.read_text()) if p.exists() and p.read_text().strip() else {}
except json.JSONDecodeError:
    sys.exit(f"  skip: {p} is not valid JSON")
data.pop("includeCoAuthoredBy", None)
data["attribution"] = {"commit": "", "pr": ""}
p.write_text(json.dumps(data, indent=2) + "\n")
PY
}

update_gitignore() {
  local gi="$1/.gitignore"
  touch "$gi"
  if [[ -s "$gi" && -n "$(tail -c1 "$gi")" ]]; then echo >> "$gi"; fi
  for line in "${GITIGNORE_LINES[@]}"; do
    grep -qxF -- "$line" "$gi" || echo "$line" >> "$gi"
  done
}

default_branch() {
  local dir="$1" b=""
  b="$(git -C "$dir" symbolic-ref -q --short refs/remotes/origin/HEAD 2>/dev/null | sed 's#^origin/##')" || true
  if [[ -z "$b" ]]; then
    b="$(cd "$dir" && gh repo view --json defaultBranchRef -q .defaultBranchRef.name 2>/dev/null)" || true
  fi
  if [[ -z "$b" ]]; then
    for c in main master; do
      if git -C "$dir" show-ref -q "refs/remotes/origin/$c"; then b="$c"; break; fi
    done
  fi
  echo "$b"
}

protect_branch() {
  local dir="$1" branch="$2" slug
  slug="$(cd "$dir" && gh repo view --json nameWithOwner -q .nameWithOwner 2>/dev/null)" || {
    echo "  skip protect: no GitHub remote"; return 0; }
  if gh api -X PUT "repos/$slug/branches/$branch/protection" --silent --input - >/dev/null 2>&1 <<'JSON'
{
  "required_status_checks": null,
  "enforce_admins": false,
  "required_pull_request_reviews": { "required_approving_review_count": 0 },
  "restrictions": null,
  "allow_force_pushes": false,
  "allow_deletions": false
}
JSON
  then echo "  $branch protected"
  else echo "  protect failed (private repos need GitHub Pro)"
  fi
}

apply_via_pr() {
  local dir="$1" base wt
  if ! git -C "$dir" remote get-url origin >/dev/null 2>&1; then
    echo "  skip: no remote (publish it first)"; return 0
  fi
  git -C "$dir" fetch -q origin
  base="$(default_branch "$dir")"
  if [[ -z "$base" ]]; then echo "  skip: no default branch found"; return 0; fi

  wt="$(mktemp -d)/wt"
  git -C "$dir" worktree add -q -B "$BRANCH" "$wt" "origin/$base"
  update_block "$wt/CLAUDE.md" "$PROJECT_TEMPLATE"
  update_gitignore "$wt"
  update_settings "$wt/.claude/settings.json"
  git -C "$wt" add CLAUDE.md .gitignore .claude/settings.json
  if git -C "$wt" diff --cached --quiet; then
    echo "  already up to date on $base"
  else
    git -C "$wt" commit -q -m "chore: apply dev-standards"
    git -C "$wt" push -q -u origin "$BRANCH" --force-with-lease
    if (cd "$wt" && gh pr view "$BRANCH" --json state -q .state 2>/dev/null | grep -q OPEN); then
      echo "  PR updated"
    else
      (cd "$wt" && gh pr create --base "$base" --head "$BRANCH" \
        --title "chore: apply dev-standards" \
        --body "Adds the shared dev-standards block to CLAUDE.md, secret patterns to .gitignore and the no-attribution setting to .claude/settings.json." \
        >/dev/null) && echo "  PR opened against $base" || echo "  pushed, PR creation failed"
    fi
  fi
  git -C "$dir" worktree remove --force "$wt"
  if $do_protect; then protect_branch "$dir" "$base"; fi
  return 0
}

apply_in_tree() {
  local dir="$1"
  update_block "$dir/CLAUDE.md" "$PROJECT_TEMPLATE"
  update_gitignore "$dir"
  update_settings "$dir/.claude/settings.json"
  echo "  files updated (not committed)"
  if $do_skills; then
    (cd "$dir" && npx -y skills@latest add mattpocock/skills) \
      && echo "  skills installed (run /setup-matt-pocock-skills once)" \
      || echo "  skills install failed"
  fi
  return 0
}

if $do_global; then
  mkdir -p "$HOME/.claude"
  update_block "$HOME/.claude/CLAUDE.md"
  update_settings "$HOME/.claude/settings.json"
  echo "Global: ~/.claude/CLAUDE.md and settings.json updated"
fi

if [[ -n "$repos_dir" ]]; then
  if [[ -n "$only" ]]; then
    targets=(); for n in $only; do targets+=("$repos_dir/$n"); done
  else
    targets=("$repos_dir"/*/)
  fi
  for dir in "${targets[@]}"; do
    dir="${dir%/}"
    if [[ ! -d "$dir/.git" ]]; then echo "Skip ${dir##*/}: not a git repo"; continue; fi
    echo "Repo: ${dir#"$repos_dir"/}"
    if $do_pr; then apply_via_pr "$dir"; else apply_in_tree "$dir"; fi
  done
fi

if ! $do_global && [[ -z "$repos_dir" ]]; then
  echo "Nothing to do. See usage at the top of this script."
fi
