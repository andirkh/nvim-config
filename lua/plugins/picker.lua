-- Space Space also lists gitignored files (generated output like tmp/), but never the heavy
-- dependency and build folders.
return {
  "folke/snacks.nvim",
  opts = {
    picker = {
      sources = {
        files = {
          hidden = true,
          ignored = true,
          exclude = { ".git", "node_modules", ".next", ".turbo" },
        },
      },
    },
  },
}
