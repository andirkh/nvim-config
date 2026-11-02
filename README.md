# My Neovim setup

This is my [LazyVim](https://lazyvim.github.io) config, plus the terminal configs that go with it. It lives in `~/.config/nvim` on both Macs and is kept identical through this repo: `github.com/andirkh/nvim-config`.

`lazy-lock.json` pins the exact version of every plugin, so both Macs run the same code, not just the same plugin list.

## Setting up a new Mac

```sh
xcode-select --install    # gives you git
git clone https://github.com/andirkh/nvim-config.git ~/.config/nvim
~/.config/nvim/install.sh
```

`install.sh` starts from nothing. It installs Homebrew if needed, reinstalls Neovim and lazygit even if they're already there, installs Ghostty and the Ubuntu Mono Nerd Font if they're missing, and moves Neovim's old plugins, caches and state aside (renamed with a `.bak-<date>` suffix). Then it runs `sync.sh`.

After that:

1. **Install Angelly by hand.** It isn't on Homebrew, so the script can't fetch it. Its config is linked anyway.
2. **Make sure Node is installed.** The TypeScript language server and Prettier need it. It's not in the script because Node comes from pnpm.

Language servers, formatters, linters and syntax parsers are installed by the script, so Neovim is fully ready the first time you open it.

## Keeping both Macs in sync

On the Mac where you made a change:

```sh
cd ~/.config/nvim
git add -A && git commit -m "…" && git push
```

On the other Mac:

```sh
cd ~/.config/nvim
git pull && ./sync.sh
```

`sync.sh` is safe to run any time. It installs tools newly added to the `Brewfile` (without upgrading the ones you have), links the terminal and lazygit configs, puts every plugin at the version in `lazy-lock.json`, removes plugins the config no longer uses, and installs every language server, formatter, linter and parser in `mason.txt` and `treesitter.txt`. Afterwards, restart Neovim and reload the terminal's config with `Cmd+Shift+,`.

If you update plugins with `:Lazy update`, `lazy-lock.json` changes. Commit it, or the other Mac stays on the old versions.

The same goes for tools. If you install a language server or formatter by hand with `:Mason`, the next `./sync.sh` adds it to `mason.txt` (and new parsers to `treesitter.txt`). Commit those lists and the other Mac installs them on its next sync.

## What's in here

| Path | What it is |
| --- | --- |
| `lua/config/keymaps.lua` | My shortcuts (see below) |
| `lua/config/explorer_menu.lua` | The right-click menu in the file tree |
| `colors/ubuntu.lua` | The Ubuntu colour scheme; edit the hex codes to tweak it |
| `lua/plugins/ubuntu-theme.lua` | Makes Ubuntu the default theme |
| `lua/plugins/rose-pine.lua` | Rose Pine, kept installed but not the default |
| `lazy-lock.json` | Exact plugin versions; commit it whenever it changes |
| `Brewfile` | Command-line tools both Macs need |
| `ghostty/config` | Ghostty's config (linked into Ghostty's settings folder) |
| `angelly/config.ghostty` | Angelly's config (linked into Angelly's settings folder) |
| `lazygit/config.yml` | lazygit's config (linked into lazygit's settings folder) |
| `lua/plugins/statusline.lua` | Encoding, language and formatter on the right of the status bar |
| `install.sh` / `sync.sh` | The two scripts above |
| `scripts/tools.lua` | Run by `sync.sh`: installs the language servers, formatters, linters and parsers, and updates the two lists |
| `mason.txt` / `treesitter.txt` | Every Mason package and syntax parser installed; `sync.sh` installs them on both Macs |

### The two terminals

Angelly is a Ghostty fork and the terminal I actually use. Each app reads only its own config, and the two are kept separate on purpose:

- **Ghostty** (`ghostty/config`): Ubuntu theme, Ubuntu Mono font, Option as Alt, and `Cmd+F` / `Cmd+Option+F` passed through to Neovim.
- **Angelly** (`angelly/config.ghostty`): only the Ubuntu theme. `Cmd+F` opens Angelly's own search, not Neovim's find. To get Neovim's find there too, copy the two `keybind = super+...` lines from `ghostty/config` into Angelly's config.

Both files are symlinks into this repo, so editing a terminal's config on either Mac changes the repo, ready to commit.

## Cheat sheet

`Space` is the leader key. Press it and wait to see a menu of everything under it.

### My own additions

| Keys | What it does |
| --- | --- |
| Right-click in the file tree | New file or folder, find (and replace) in folder, copy, cut, paste, copy path, rename, delete |
| `Cmd+F` | Find in the file, then `n` / `N` for next / previous (Ghostty only, see above) |
| `Cmd+Option+F` | Find and replace in the file (Ghostty only) |
| Click a result in find and replace | Jump to that line |
| `Ctrl+h` / `Ctrl+l` | Move to the window on the left / right, wrapping around at the edges |
| `:start` / `:end` | Go to the first / last line |
| Status bar, bottom right | Encoding, language and the formatter that runs on save, like VS Code; `(off)` when format on save is off (`Space u f`) |
| `Space g g`, then `Esc` | Open lazygit; `Esc` closes menus first, then lazygit itself |
| `Space c f` | Format the file with Prettier (the project's own copy when it has one); on broken code it shows the error and leaves the file alone. Saving formats too |

### Files and search

| Keys | What it does |
| --- | --- |
| `Space e` / `Space E` | Toggle the file tree at the project root / at the working directory |
| `Space Space` | Find a file by name (`Cmd+P`) |
| `Space /` | Search text across the project (`Cmd+Shift+F`) |
| `Space s b` | Search lines in the current file |
| `Space ,` | Switch between open files |

In a picker, `Ctrl+v` opens the file side by side and `Ctrl+s` opens it below.

### In the file tree (neo-tree)

| Keys | What it does |
| --- | --- |
| `a` / `A` | New file / new folder (`a` with a trailing `/` also makes a folder) |
| `r`, `d` | Rename, delete |
| `c`, `m` | Copy to, move to |
| `y`, `x`, `p` | Copy, cut, paste |
| `s` / `S` | Open side by side / below |
| `H` | Show or hide hidden files |
| `Backspace` / `.` | Go up a folder / make this folder the root |
| `?` | List every key |

### Buffers, windows and code

| Keys | What it does |
| --- | --- |
| `Shift+h` / `Shift+l` | Previous / next open file in the top bar |
| `Space b d` / `Space b o` | Close this file / close all others |
| `Space \|` / `Space -` | Split side by side / top and bottom |
| `Space w d` / `Ctrl+w o` | Close this split / close all other splits |
| `gd` / `gr` / `K` | Go to definition / references / hover docs |
| `Ctrl+o` / `Ctrl+i` | Jump back / forward |
| `gg` / `G` | First / last line |
| `Space u C` | Preview and pick a colour scheme |

### Finding a component's props

Say `VideoCallPage.tsx` renders `<VideoPanel ... />` and you want to know what `VideoPanel` takes. It all comes from the TypeScript language server, as in VS Code.

| Keys | What it does |
| --- | --- |
| `K` on the component name | Popup with every prop and its type. Props without `?` are required. Press `K` again to scroll the popup |
| `gd` on the component name | Jump to where it's defined to read the props type and defaults. `gd` on a named type like `VideoPanelProps` opens that type. `Ctrl+o` jumps back |
| Space (or `Ctrl+Space`) inside the tag, in insert mode | Suggests the props you haven't used yet, with their types |
| `Space c d` on a red `<VideoPanel` | Shows what's wrong, such as *Property 'label' is missing* |
| `Space c a` on that error | Quick fixes, which can include *Add missing attributes* to fill in the required props |

### Markdown

Markdown files render in place: headings, tables, checkboxes and code blocks are drawn as they'd look, and the line you're editing shows the raw text.

| Keys | What it does |
| --- | --- |
| `Space c p` | Open or close a live preview in the browser (follows your scrolling) |
| `Space u m` | Turn in-place rendering off or on |
