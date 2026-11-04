-- VS Code-style details on the right of the status line: encoding, language and the formatter
-- that runs on save. Only shown for real files, not the tree, pickers or terminals.

local languages = {
  typescript = "TypeScript",
  typescriptreact = "TypeScript React",
  javascript = "JavaScript",
  javascriptreact = "JavaScript React",
  json = "JSON",
  jsonc = "JSON with Comments",
  yaml = "YAML",
  markdown = "Markdown",
  html = "HTML",
  css = "CSS",
  scss = "SCSS",
  lua = "Lua",
  sh = "Shell Script",
  zsh = "Shell Script",
  bash = "Shell Script",
  swift = "Swift",
  kotlin = "Kotlin",
  cucumber = "Gherkin",
  dockerfile = "Dockerfile",
  gitcommit = "Git Commit",
}

local formatters = {
  prettier = "Prettier",
  prettierd = "Prettier",
  ts_ls = "TS Server",
  eslint = "ESLint",
  jsonls = "JSON LSP",
  stylua = "StyLua",
  shfmt = "shfmt",
  ["markdownlint-cli2"] = "markdownlint",
  ["markdown-toc"] = "markdown-toc",
}

local function is_file()
  return vim.bo.buftype == ""
end

-- Working out the formatter asks conform and every attached LSP, so cache it per buffer and
-- recompute only when something that changes the answer happens
local cache = {}
vim.api.nvim_create_autocmd({ "LspAttach", "LspDetach", "FileType", "BufWritePost" }, {
  callback = function(ev)
    cache[ev.buf] = nil
  end,
})
vim.api.nvim_create_autocmd("BufWipeout", {
  callback = function(ev)
    cache[ev.buf] = nil
  end,
})

local function formatter()
  local buf = vim.api.nvim_get_current_buf()
  if cache[buf] == nil then
    local names = {}
    for _, f in ipairs(LazyVim.format.resolve(buf)) do
      if f.active then
        for _, source in ipairs(f.resolved) do
          local name = formatters[source] or source
          if not vim.tbl_contains(names, name) then
            table.insert(names, name)
          end
        end
      end
    end
    cache[buf] = table.concat(names, ", ")
  end
  if cache[buf] == "" then
    return ""
  end
  -- Format on save can be turned off with Space u f (all files) or Space u F (this file)
  return "󰉼 " .. cache[buf] .. (LazyVim.format.enabled(buf) and "" or " (off)")
end

return {
  "nvim-lualine/lualine.nvim",
  opts = function(_, opts)
    vim.list_extend(opts.sections.lualine_x, {
      {
        function()
          return (vim.bo.fileencoding ~= "" and vim.bo.fileencoding or vim.o.encoding):upper()
        end,
        cond = is_file,
      },
      {
        function()
          local ft = vim.bo.filetype
          return languages[ft] or (ft:sub(1, 1):upper() .. ft:sub(2))
        end,
        cond = function()
          return is_file() and vim.bo.filetype ~= ""
        end,
      },
      { formatter, cond = is_file },
    })
    -- LazyVim shows a clock here; drop it
    opts.sections.lualine_z = {}
  end,
}
