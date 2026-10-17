#!/usr/bin/env bash
# Publishes local repos without a GitHub remote as PRIVATE repos.
# Skips any repo that tracks files that look like secrets.
#
# Usage:
#   ./publish-repos.sh ~/code            # dry run: shows what would happen
#   ./publish-repos.sh ~/code --apply    # actually create and push

set -euo pipefail

repos_dir="${1:?Usage: ./publish-repos.sh <dir> [--apply]}"
apply=false; [[ "${2:-}" == "--apply" ]] && apply=true

SECRET_PATTERN='(^|/)\.env($|\.)|\.pem$|\.key$|id_rsa|id_ed25519|credentials|service-account.*\.json$'

for dir in "$repos_dir"/*/; do
  [[ -d "$dir/.git" ]] || continue
  dir="${dir%/}"; name="$(basename "$dir")"

  if git -C "$dir" remote get-url origin >/dev/null 2>&1; then
    echo "$name: has remote, skip"; continue
  fi

  hits="$(git -C "$dir" ls-files | grep -E "$SECRET_PATTERN" | grep -v '\.env\.example$' || true)"
  if [[ -n "$hits" ]]; then
    echo "$name: SKIPPED, possible secrets tracked:"; echo "$hits" | sed 's/^/    /'
    echo "    Untrack them (git rm --cached), add to .gitignore. If they are in history, clean history first."
    continue
  fi

  if command -v gitleaks >/dev/null 2>&1; then
    if ! gitleaks detect -s "$dir" --no-banner -q; then
      echo "$name: SKIPPED, gitleaks found secrets in history"; continue
    fi
  fi

  if ! git -C "$dir" rev-parse HEAD >/dev/null 2>&1; then
    echo "$name: no commits yet, skip"; continue
  fi

  if $apply; then
    (cd "$dir" && gh repo create "$name" --private --source . --push >/dev/null) \
      && echo "$name: published (private)" || echo "$name: FAILED (name taken?)"
  else
    echo "$name: would publish as private"
  fi
done

$apply || echo "Dry run. Add --apply to publish."
