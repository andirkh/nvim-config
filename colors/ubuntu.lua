-- Ubuntu: the aubergine terminal palette (same colors as Ghostty's "Ubuntu" theme)
vim.o.background = "dark"
require("mini.base16").setup({
  palette = {
    base00 = "#300a24", -- background (aubergine)
    base01 = "#3d1431", -- status line, line number column
    base02 = "#5e2750", -- selection
    base03 = "#888a85", -- comments
    base04 = "#babdb6", -- dark foreground
    base05 = "#eeeeec", -- foreground
    base06 = "#f3f3f1",
    base07 = "#ffffff",
    base08 = "#ef2929", -- red: variables, tags
    base09 = "#f57900", -- orange: numbers, constants
    base0A = "#fce94f", -- yellow: types, classes
    base0B = "#8ae234", -- green: strings
    base0C = "#34e2e2", -- cyan: escapes, regex
    base0D = "#729fcf", -- blue: functions
    base0E = "#ad7fa8", -- purple: keywords
    base0F = "#c17d11", -- brown: deprecated
  },
  use_cterm = false,
})
vim.g.colors_name = "ubuntu"
