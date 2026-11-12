-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Word wrap on by default, like VS Code ("editor.wordWrap": "on"). Space u W still toggles it.
-- Long lines break between words rather than mid-word, and each wrapped piece lines up with the
-- indentation of the line it belongs to, like VS Code's default "wrappingIndent": "same", so
-- nested JSX stays readable.
vim.opt.wrap = true
vim.opt.linebreak = true
vim.opt.breakindent = true
vim.opt.showbreak = ""

-- The project root is the folder you opened with `nvim .`, not the nearest package.json or LSP
-- root. In a monorepo that keeps Space Space, Space / and the explorer on the whole repo instead
-- of narrowing them to apps/web once a file in there is open.
vim.g.root_spec = { "cwd" }
