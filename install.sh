#!/usr/bin/env bash
# Sets up this Neovim config on a Mac from nothing. Installs Homebrew if it's missing, reinstalls
# Neovim and lazygit even when they're already there, installs Ghostty and its font if they're
# missing, moves Neovim's old plugin data aside, then runs sync.sh for everything else.
# Angelly isn't on Homebrew, so it has to be installed by hand; sync.sh links its config.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STAMP="$(date +%Y%m%d-%H%M%S)"

if [[ "$DIR" != "$HOME/.config/nvim" ]]; then
  echo "This repo must be cloned to ~/.config/nvim (it's at $DIR)." >&2
  exit 1
fi

if ! command -v brew >/dev/null; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi
BREW_PREFIX="$(brew --prefix)"

# Copies of nvim or lazygit that didn't come from Homebrew would shadow the new ones,
# so move them aside rather than leave two versions on the PATH.
for bin in nvim lazygit; do
  while path="$(command -v "$bin")" && [[ "$(readlink -f "$path")" != "$BREW_PREFIX"/* ]]; do
    echo "Moving aside $path (not installed by Homebrew)"
    mv "$path" "$path.old-$STAMP" 2>/dev/null || sudo mv "$path" "$path.old-$STAMP"
    hash -r
  done
done

for formula in neovim lazygit; do
  if brew list --formula "$formula" >/dev/null 2>&1; then
    brew reinstall "$formula"
  else
    brew install "$formula"
  fi
done

if [[ ! -d /Applications/Ghostty.app ]]; then
  brew install --cask ghostty
fi
if ! compgen -G "$HOME/Library/Fonts/UbuntuMonoNerdFont-*" >/dev/null; then
  brew install --cask font-ubuntu-mono-nerd-font
fi

# Start plugins, Mason tools and caches from scratch so they match lazy-lock.json exactly
for data in "$HOME/.local/share/nvim" "$HOME/.local/state/nvim" "$HOME/.cache/nvim"; do
  if [[ -e "$data" ]]; then
    echo "Moving aside $data"
    mv "$data" "$data.bak-$STAMP"
  fi
done

exec "$DIR/sync.sh"
