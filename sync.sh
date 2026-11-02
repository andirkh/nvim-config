#!/usr/bin/env bash
# Brings this Mac in line with the repo, usually right after a `git pull`: installs tools added to
# the Brewfile, points Ghostty and Angelly at their configs in this repo, and puts every plugin at
# the exact version in lazy-lock.json, removing plugins the config no longer uses.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

brew bundle --file "$DIR/Brewfile" --no-upgrade

# Each terminal reads its config through a symlink into this repo, so a change made on either
# Mac lands in git. Angelly is a Ghostty fork with its own, separate config.
link_config() {
  local repo_file="$DIR/$1" app_file="$2"
  if [[ "$(readlink "$app_file" || true)" != "$repo_file" ]]; then
    mkdir -p "$(dirname "$app_file")"
    if [[ -e "$app_file" ]]; then
      mv "$app_file" "$app_file.bak-$(date +%Y%m%d-%H%M%S)"
    fi
    ln -s "$repo_file" "$app_file"
  fi
}
link_config ghostty/config "$HOME/Library/Application Support/com.mitchellh.ghostty/config"
link_config angelly/config.ghostty "$HOME/Library/Application Support/com.adetxt.angelly/config.ghostty"

nvim --headless "+Lazy! restore" "+Lazy! clean" +qa

# markdown-preview's build only starts a background download, which a headless run cuts short
MDP="$HOME/.local/share/nvim/lazy/markdown-preview.nvim/app"
if [[ -d "$MDP" ]] && ! compgen -G "$MDP/bin/markdown-preview-*" >/dev/null; then
  (cd "$MDP" && sh ./install.sh)
fi

if ! command -v node >/dev/null; then
  echo "Note: Node isn't on your PATH. The TypeScript language server and Prettier need it."
fi
if [[ ! -d /Applications/Angelly.app ]]; then
  echo "Note: Angelly isn't installed. It isn't on Homebrew, so install it by hand; its config is already linked."
fi
echo "Done. Restart Neovim, and reload the terminal's config with Cmd+Shift+,"
