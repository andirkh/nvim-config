-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.keymap.set("n", "<leader>cf", function()
  vim.cmd(":%!prettier --stdin-filepath " .. vim.fn.expand("%:p"))
end, { desc = "Format current buffer with Prettier" })

require("config.explorer_menu")

-- Cmd+F: find in the current file (Enter, then n / N for next / previous)
vim.keymap.set("n", "<D-f>", "/", { desc = "Find in file" })
vim.keymap.set("i", "<D-f>", "<Esc>/", { desc = "Find in file" })

-- Cmd+Option+F: find and replace in the current file
vim.keymap.set({ "n", "i" }, "<M-D-f>", function()
  vim.cmd("stopinsert")
  local file = vim.bo.buftype == "" and vim.fn.expand("%:p") or nil
  require("grug-far").open({ prefills = { paths = file and vim.fn.escape(file, " ") or nil } })
end, { desc = "Find and replace in file" })

-- Clicking a result in the find and replace panel jumps to that line,
-- whatever mode you're in and whichever window has focus
function _G.grug_far_click()
  local win = vim.api.nvim_get_current_win()
  require("grug-far").get_instance(0):goto_location()
  if vim.api.nvim_get_current_win() ~= win then
    vim.cmd("stopinsert")
  end
end

vim.keymap.set({ "n", "i" }, "<LeftMouse>", function()
  local pos = vim.fn.getmousepos()
  if pos.winid ~= 0 and vim.bo[vim.api.nvim_win_get_buf(pos.winid)].filetype == "grug-far" then
    return "<LeftMouse><Cmd>lua grug_far_click()<CR>"
  end
  return "<LeftMouse>"
end, { expr = true, desc = "Click (jumps to find and replace results)" })

-- Ctrl+h / Ctrl+l move between windows and wrap around at the edges,
-- like Shift+h / Shift+l do for buffers
local function wrap_window(dir, opposite)
  return function()
    local win = vim.api.nvim_get_current_win()
    vim.cmd("wincmd " .. dir)
    if vim.api.nvim_get_current_win() == win then
      vim.cmd("999wincmd " .. opposite)
    end
  end
end
vim.keymap.set("n", "<C-h>", wrap_window("h", "l"), { desc = "Go to Left Window (wraps)" })
vim.keymap.set("n", "<C-l>", wrap_window("l", "h"), { desc = "Go to Right Window (wraps)" })

-- :end / :start jump to the last / first line of the file
vim.cmd([[cnoreabbrev <expr> end getcmdtype() ==# ':' && getcmdline() ==# 'end' ? 'normal! G' : 'end']])
vim.cmd([[cnoreabbrev <expr> start getcmdtype() ==# ':' && getcmdline() ==# 'start' ? 'normal! gg' : 'start']])
