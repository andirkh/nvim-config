-- Side-by-side diffs and file history. <leader>gv toggles the diff of the working tree (or of a
-- range typed after :DiffviewOpen, e.g. develop...HEAD), <leader>gV shows the current file's history.
-- q closes it from any of its panels.

local function toggle()
  if require("diffview.lib").get_current_view() then
    vim.cmd("DiffviewClose")
  else
    vim.cmd("DiffviewOpen")
  end
end

local close = { "n", "q", "<cmd>DiffviewClose<cr>", { desc = "Close Diffview" } }

return {
  "sindrets/diffview.nvim",
  cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory" },
  keys = {
    { "<leader>gv", toggle, desc = "Diffview Toggle" },
    { "<leader>gV", "<cmd>DiffviewFileHistory %<cr>", desc = "Diffview File History" },
  },
  opts = {
    enhanced_diff_hl = true,
    keymaps = {
      view = { close },
      file_panel = { close },
      file_history_panel = { close },
    },
  },
}
