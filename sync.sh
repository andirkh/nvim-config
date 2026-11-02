#!/usr/bin/env bash
# Brings this Mac in line with the repo, usually right after a `git pull`: installs tools added to
# the Brewfile, points Ghostty at the config in this repo, and puts every plugin at the exact
# version in lazy-lock.json, removing plugins the config no longer uses.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

brew bundle --file "$DIR/Brewfile" --no-upgrade

# A symlink, so Ghostty changes made on either Mac land in the repo
GHOSTTY="$HOME/Library/Application Support/com.mitchellh.ghostty/config"
if [[ "$(readlink "$GHOSTTY" || true)" != "$DIR/ghostty/config" ]]; then
  mkdir -p "$(dirname "$GHOSTTY")"
  if [[ -e "$GHOSTTY" ]]; then
    mv "$GHOSTTY" "$GHOSTTY.bak-$(date +%Y%m%d-%H%M%S)"
  fi
  ln -s "$DIR/ghostty/config" "$GHOSTTY"
fi

nvim --headless "+Lazy! restore" "+Lazy! clean" +qa

if ! command -v node >/dev/null; then
  echo "Note: Node isn't on your PATH. The TypeScript language server and Prettier need it."
fi
echo "Done. Restart Neovim, and reload Ghostty's config with Cmd+Shift+,"
