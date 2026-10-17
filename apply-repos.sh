#!/usr/bin/env bash
# One-time run for ~/repos, based on the inventory and new layout of 17 Oct 2026.
# Run post-move.sh first.
#   1. Publishes this kit as a private repo (dev-standards)
#   2. Publishes own projects that aren't on GitHub yet, as private
#   3. Makes own public repos private
#   4. Opens a dev-standards PR in every own repo (worktree, your work is untouched)
#   5. Installs the global ~/.claude/CLAUDE.md
#
# Run:  cd ~/repos/tooling/dev-standards && ./apply-repos.sh
# Safe to re-run: finished steps are skipped.

set -euo pipefail

ROOT="$HOME/repos"
HERE="$(cd "$(dirname "$0")" && pwd)"

# Own repos already on GitHub
HAS_REMOTE="products/boekpilot tooling/auto-setup-ai-project tooling/dotfiles products/fysio-epd products/anamnesis-tool tovy/growth/seo-geo-agent products/stopcontant tovy/site/tovy-eu-astro tovy/ops/tovy-os tovy/site/tovy.eu-website sandbox/track-and-field-training-platform tovy/site/website-template"
# Own git repos without a remote
GIT_NO_REMOTE="personal/file-manager tovy/growth/leadsys tovy/growth/tovy-crm tovy/growth/tovy-social"
# Own folders without git
NO_GIT="clients/biosuikermais tovy/growth/digital-consultant tovy/growth/leadspipeline tovy/ops/tax-divider tovy/growth/tovy-linkedin-posts clients/wildeburgjoke"
# Left out on purpose: third-party/, learning/, and sandbox/ except track-and-field.

EXTRA_IGNORES=("node_modules/" ".venv/" "venv/" "__pycache__/" "*.pyc" ".pytest_cache/" ".ruff_cache/" ".next/" "dist/" "out/" ".firebase/" ".idx/")
SECRET_PATTERN='(^|/)\.env($|\.)|(^|/)\.envrc$|\.pem$|\.key$|id_rsa|id_ed25519|credentials|client_secret|service-account.*\.json$|(^|/)\.tokens\.json$'
SECRET_ALLOW='\.env\.(example|sample|test|demo)$'
MAX_BYTES=$((50 * 1024 * 1024))

say()  { printf '\n\033[1m%s\033[0m\n' "$*"; }
warn() { printf '  \033[33m%s\033[0m\n' "$*"; }

# ---------- preflight ----------
command -v gh >/dev/null || { echo "Install the GitHub CLI first: brew install gh"; exit 1; }
gh auth status >/dev/null 2>&1 || { echo "Log in first: gh auth login"; exit 1; }
OWNER="$(gh api user -q .login)"
git config user.email >/dev/null || { echo "Set git user.email first"; exit 1; }
chmod +x "$HERE/install.sh"

say "Plan (GitHub account: $OWNER)"
echo "  Publish kit:        dev-standards"
echo "  Publish git repos:  $GIT_NO_REMOTE"
echo "  Init + publish:     $NO_GIT"
echo "  Make private:       every own repo that is public"
echo "  Standards PR in:    $HAS_REMOTE $GIT_NO_REMOTE $NO_GIT"
echo "  Global file:        ~/.claude/CLAUDE.md"
read -r -p "Continue? [y/N] " ok; [[ "$ok" == "y" ]] || exit 0

repo_exists() { gh repo view "$OWNER/$1" >/dev/null 2>&1; }

# Fails if staged files look like secrets or are too big for GitHub.
check_staged() {
  local dir="$1" bad=0 f size
  while IFS= read -r f; do
    [[ -z "$f" ]] && continue
    if echo "$f" | grep -Eq "$SECRET_PATTERN" && ! echo "$f" | grep -Eq "$SECRET_ALLOW"; then
      warn "secret-like file staged: $f"; bad=1
    fi
    if [[ -f "$dir/$f" ]]; then
      size=$(wc -c < "$dir/$f")
      if (( size > MAX_BYTES )); then warn "file over 50 MB: $f"; bad=1; fi
    fi
  done < <(git -C "$dir" diff --cached --name-only)
  return $bad
}

publish() {
  local dir="$1" name="${1##*/}"
  if repo_exists "$name"; then
    warn "$OWNER/$name already exists on GitHub. Not touching it. Add the remote by hand if it's the same project."
    return 1
  fi
  (cd "$dir" && gh repo create "$OWNER/$name" --private --source . --remote origin >/dev/null)
  git -C "$dir" push -q -u origin --all
  echo "  published: $OWNER/$name (private)"
}

# ---------- 1. the kit itself ----------
say "1. dev-standards repo"
if git -C "$HERE" remote get-url origin >/dev/null 2>&1; then
  echo "  already published"
else
  [[ -d "$HERE/.git" ]] || git -C "$HERE" init -q -b main
  git -C "$HERE" add -A
  git -C "$HERE" diff --cached --quiet || git -C "$HERE" commit -q -m "feat: initial dev standards"
  publish "$HERE" || true
fi

# ---------- 2a. git repos without remote ----------
say "2. Publish own projects"
for name in $GIT_NO_REMOTE; do
  dir="$ROOT/$name"; echo "$name"
  if git -C "$dir" remote get-url origin >/dev/null 2>&1; then echo "  has remote"; continue; fi
  hits="$(git -C "$dir" ls-files | grep -E "$SECRET_PATTERN" | grep -Ev "$SECRET_ALLOW" || true)"
  if [[ -n "$hits" ]]; then warn "skipped, secret-like files tracked:"; echo "$hits" | sed 's/^/    /'; continue; fi
  publish "$dir" || true
done

# ---------- 2b. folders without git ----------
for name in $NO_GIT; do
  dir="$ROOT/$name"; echo "$name"
  if git -C "$dir" remote get-url origin >/dev/null 2>&1; then echo "  has remote"; continue; fi
  if [[ ! -d "$dir/.git" ]]; then
    git -C "$dir" init -q -b main
    "$HERE/install.sh" --repos "$ROOT" --only "$name" >/dev/null   # CLAUDE.md + base ignores
    for line in "${EXTRA_IGNORES[@]}"; do
      grep -qxF -- "$line" "$dir/.gitignore" || echo "$line" >> "$dir/.gitignore"
    done
  fi
  git -C "$dir" add -A
  if ! check_staged "$dir"; then
    git -C "$dir" reset -q
    warn "skipped. Add the files above to .gitignore, then re-run."
    continue
  fi
  git -C "$dir" diff --cached --quiet || git -C "$dir" commit -q -m "chore: initial commit with dev-standards"
  publish "$dir" || true
done

# ---------- 3. visibility ----------
say "3. Make own repos private"
for name in $HAS_REMOTE $GIT_NO_REMOTE $NO_GIT; do
  dir="$ROOT/$name"
  slug="$(cd "$dir" && gh repo view --json nameWithOwner -q .nameWithOwner 2>/dev/null)" || continue
  vis="$(gh repo view "$slug" --json visibility -q .visibility)"
  [[ "$vis" == "PRIVATE" ]] && continue
  if gh api "repos/$slug/pages" >/dev/null 2>&1; then
    warn "$slug serves GitHub Pages. Private Pages needs a paid plan, so the site may go offline."
    read -r -p "  Make $slug private anyway? [y/N] " ok
    [[ "$ok" == "y" ]] || { echo "  kept public"; continue; }
  fi
  gh repo edit "$slug" --visibility private --accept-visibility-change-consequences >/dev/null \
    && echo "  $slug: now private" || warn "$slug: failed (org admin rights needed?)"
done

# ---------- 4. standards PRs ----------
say "4. Standards PRs"
"$HERE/install.sh" --repos "$ROOT" --only "$HAS_REMOTE $GIT_NO_REMOTE $NO_GIT" --pr

# ---------- 5. global ----------
say "5. Global rules"
"$HERE/install.sh" --global

say "Done."
echo "  Next: merge the PRs (phone or laptop), then 'git pull' in each repo."
echo "  Optional, per repo in Claude Code: install Matt Pocock's skills and run /setup-matt-pocock-skills."
