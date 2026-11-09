-- The mode (NORMAL / INSERT / VISUAL) as a small colored badge floating centered just above the
-- status line, with a row of space below it, so it's in view on a wide screen without looking
-- at a corner. It uses the same colors the status line used for the mode, and sits beneath
-- other floating windows (pickers, lazygit) rather than on top of them.

local margin_bottom = 0
local buf, win

local function update()
  local mode = require("lualine.utils.mode").get_mode()
  local hl = "lualine_a" .. require("lualine.highlight").get_mode_suffix()
  if vim.fn.hlexists(hl) == 0 then
    hl = "StatusLine"
  end
  local text = " mode: " .. mode .. "  "
  local width = vim.api.nvim_strwidth(text)
  -- The status line is the row right above the command line, which noice hides (cmdheight=0)
  local config = {
    relative = "editor",
    row = vim.o.lines - vim.o.cmdheight - 2 - margin_bottom,
    col = math.floor((vim.o.columns - width) / 2),
    width = width,
    height = 1,
    style = "minimal",
    focusable = false,
    zindex = 1,
  }

  if not (buf and vim.api.nvim_buf_is_valid(buf)) then
    buf = vim.api.nvim_create_buf(false, true)
    vim.bo[buf].bufhidden = "hide"
  end
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, { text })
  if win and vim.api.nvim_win_is_valid(win) then
    vim.api.nvim_win_set_config(win, config)
  else
    config.noautocmd = true
    win = vim.api.nvim_open_win(buf, false, config)
  end
  vim.wo[win].winhighlight = "Normal:" .. hl
  -- The screen isn't redrawn on its own while typing a : command
  if vim.fn.mode():sub(1, 1) == "c" then
    vim.cmd.redraw()
  end
end

-- lualine sets up the mode colors on VeryLazy
vim.api.nvim_create_autocmd("User", {
  pattern = "VeryLazy",
  once = true,
  callback = function()
    update()
    vim.api.nvim_create_autocmd({ "ModeChanged", "VimResized", "ColorScheme" }, {
      callback = function()
        vim.schedule(update)
      end,
    })
    vim.api.nvim_create_autocmd("OptionSet", {
      pattern = "cmdheight",
      callback = function()
        vim.schedule(update)
      end,
    })
  end,
})

return {}
