-- Point markdownlint-cli2 at a global config so MD013 (line length) stays off in every project.
return {
  "mfussenegger/nvim-lint",
  opts = {
    linters = {
      ["markdownlint-cli2"] = {
        args = { "--config", vim.fn.expand("~/.markdownlint-cli2.yaml"), "--" },
      },
    },
  },
}
