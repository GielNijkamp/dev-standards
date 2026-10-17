#!/usr/bin/env bash
# Run once on your Mac after the ~/repos reorganisation (17 Oct 2026).
#   1. Re-links dotfiles (~/.zshrc, ~/.aliases.zsh, Ghostty) and removes the temporary link
#   2. Moves Claude Code session history to the new folder paths
#   3. Rebuilds Python virtualenvs (their scripts contain the old path)
#   4. Re-allows direnv .envrc files
#   5. Reports cron jobs and launchd services that still use old paths
#
# Run:  ~/repos/tooling/dev-standards/post-move.sh
# Safe to re-run.

set -uo pipefail
R="$HOME/repos"

# old (relative to ~/repos) -> new
MOVES="
tovy.eu-website archive/tovy.eu-website
tovy-eu-astro tovy/site/tovy-eu-astro
website-template tovy/site/website-template
tovy-os tovy/ops/tovy-os
tax-divider tovy/ops/tax-divider
tovy-crm tovy/growth/tovy-crm
leadspipeline tovy/growth/leadspipeline
leadsys tovy/growth/leadsys
digital-consultant tovy/growth/digital-consultant
seo-geo-agent archive/seo-geo-agent
tovy-social tovy/growth/tovy-social
tovy-linkedin-posts tovy/growth/tovy-linkedin-posts
stopcontant products/stopcontant
accounting-agent products/boekpilot
fysio-epd products/fysio-epd
new-proj products/anamnesis-tool
biosuikermais clients/biosuikermais
wildeburgjoke archive/wildeburgjoke
file-manager personal/file-manager
dev-standards tooling/dev-standards
dotfiles tooling/dotfiles
auto-setup-ai-project tooling/auto-setup-ai-project
mlx-playground sandbox/mlx-playground
test-website sandbox/test-website
tnf-scaffold sandbox/tnf-scaffold
track-and-field-training-platform sandbox/track-and-field-training-platform
datalumina learning/datalumina
FinceptTerminal third-party/FinceptTerminal
JobSpy third-party/JobSpy
OmniRoute third-party/OmniRoute
marketingskills third-party/marketingskills
ponytail third-party/ponytail
skills third-party/skills
spotify-downloader third-party/spotify-downloader
"

say()  { printf '\n\033[1m%s\033[0m\n' "$*"; }
warn() { printf '  \033[33m%s\033[0m\n' "$*"; }

# ---------- 1. dotfiles ----------
say "1. Dotfiles"
bash "$R/tooling/dotfiles/install.sh" >/dev/null && echo "  symlinks now point to tooling/dotfiles"
if [[ -L "$R/dotfiles" ]]; then rm "$R/dotfiles" && echo "  temporary link ~/repos/dotfiles removed"; fi

# ---------- 2. Claude Code history ----------
say "2. Claude Code session history"
P="$HOME/.claude/projects"
enc() { printf '%s' "$1" | sed 's/[^a-zA-Z0-9]/-/g'; }
moved=0
while read -r old new; do
  [[ -z "$old" ]] && continue
  # also catch sub-folders, e.g. datalumina/genai-launchpad-main
  for src in "$P/$(enc "$R/$old")" "$P/$(enc "$R/$old")"-*; do
    [[ -d "$src" ]] || continue
    suffix="${src#"$P/$(enc "$R/$old")"}"
    dst="$P/$(enc "$R/$new")$suffix"
    if [[ -e "$dst" ]]; then warn "exists, left alone: ${dst##*/}"; continue; fi
    mv "$src" "$dst" && moved=$((moved + 1))
  done
done <<< "$MOVES"
echo "  $moved history folders moved"

# ---------- 3. virtualenvs ----------
say "3. Python virtualenvs"
command -v uv >/dev/null || { warn "uv not found, skipping (brew install uv)"; }
if command -v uv >/dev/null; then
  while read -r old new; do
    [[ -z "$old" ]] && continue
    dir="$R/$new"
    for v in .venv venv; do
      cfg="$dir/$v/pyvenv.cfg"
      [[ -f "$cfg" ]] || continue
      py="$(grep -E '^version(_info)? *=' "$cfg" | head -1 | sed -E 's/.*= *([0-9]+\.[0-9]+).*/\1/')"
      printf '  %-45s ' "$new ($v, python $py)"
      if [[ -f "$dir/uv.lock" || ( -f "$dir/pyproject.toml" && ! -f "$dir/requirements.txt" ) ]]; then
        (cd "$dir" && rm -rf "$v" && UV_PROJECT_ENVIRONMENT="$v" uv sync -q --python "$py") \
          && echo "rebuilt (uv sync)" || warn "failed, run 'uv sync' by hand"
      elif [[ -f "$dir/requirements.txt" ]]; then
        (cd "$dir" && rm -rf "$v" && uv venv -q --python "$py" "$v" \
          && VIRTUAL_ENV="$dir/$v" uv pip install -q -r requirements.txt) \
          && echo "rebuilt (requirements.txt)" || warn "failed, rebuild by hand"
      else
        echo "no lock or requirements file, left as is"
      fi
    done
  done <<< "$MOVES"
fi

# ---------- 4. direnv ----------
say "4. direnv"
if command -v direnv >/dev/null; then
  while read -r old new; do
    [[ -n "$old" && -f "$R/$new/.envrc" ]] && (cd "$R/$new" && direnv allow . && echo "  allowed: $new")
  done <<< "$MOVES"
else
  echo "  direnv not installed, nothing to do"
fi

# ---------- 5. leftovers ----------
say "5. Old paths elsewhere on this Mac"
found=0
check() {
  local label="$1" text="$2" old
  while read -r old _; do
    [[ -z "$old" ]] && continue
    if grep -Eq "repos/$old([/\"' ]|$)" <<< "$text"; then warn "$label still mentions ~/repos/$old"; found=1; fi
  done <<< "$MOVES"
}
check "crontab" "$(crontab -l 2>/dev/null)"
for f in "$HOME"/Library/LaunchAgents/*.plist; do
  [[ -f "$f" ]] && check "${f##*/}" "$(cat "$f")"
done
[[ -f "$HOME/.zshrc.local" ]] && check ".zshrc.local" "$(cat "$HOME/.zshrc.local")"
[[ "$found" == 0 ]] && echo "  none found"

say "Done."
echo "  Open a new terminal. Old tabs still sit in the old paths."
echo "  In Zed, reopen projects from their new location."
