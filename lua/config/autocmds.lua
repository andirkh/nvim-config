-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Lazygit (Space g g) runs in a terminal window that only re-enters terminal mode on BufEnter.
-- Switching to another Angelly split and back can drop it into normal mode, where the mouse
-- scrolls the window over blank space instead of reaching lazygit. Whenever its window lands in
-- normal mode, put it straight back in terminal mode, so there's no need to press i.
local function is_lazygit(buf)
  local term = vim.b[buf].snacks_terminal
  if not term then
    return false
  end
  local cmd = type(term.cmd) == "table" and table.concat(term.cmd, " ") or tostring(term.cmd or "")
  return cmd:find("lazygit", 1, true) ~= nil
end

vim.api.nvim_create_autocmd({ "FocusGained", "ModeChanged" }, {
  callback = function(ev)
    if ev.event == "ModeChanged" and vim.v.event.new_mode ~= "nt" then
      return
    end
    -- Wait for whatever caused the change (a click, a window switch) to finish first
    vim.schedule(function()
      local buf = vim.api.nvim_get_current_buf()
      if vim.fn.mode() == "n" and vim.bo[buf].buftype == "terminal" and is_lazygit(buf) then
        vim.cmd.startinsert()
      end
    end)
  end,
})
