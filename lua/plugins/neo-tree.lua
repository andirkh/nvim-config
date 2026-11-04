-- Sideways scrolling in the file tree. Neo-tree normally cuts every name off at the panel's edge,
-- so scrolling right only ever shows blank space. Draw names in full instead, and stop the scroll
-- once the longest entry of the expanded tree is fully in view.

local function is_tree(win)
  return win ~= 0 and vim.api.nvim_win_is_valid(win) and vim.bo[vim.api.nvim_win_get_buf(win)].filetype == "neo-tree"
end

local function max_leftcol(win)
  local longest = 0
  for _, line in ipairs(vim.api.nvim_buf_get_lines(vim.api.nvim_win_get_buf(win), 0, -1, false)) do
    -- nvim_strwidth, not strdisplaywidth: the latter applies the current window's word wrap and
    -- overcounts when the code window has focus
    longest = math.max(longest, vim.api.nvim_strwidth((line:gsub("%s+$", ""))))
  end
  local info = vim.fn.getwininfo(win)[1]
  return math.max(0, longest - (info.width - info.textoff))
end

local function set_leftcol(win, leftcol)
  vim.api.nvim_win_call(win, function()
    if vim.fn.winsaveview().leftcol == leftcol then
      return
    end
    -- In the focused tree Neovim scrolls back to wherever the cursor is, so take the cursor along
    -- to the first visible column. It may sit past the end of a short line, hence virtualedit, and
    -- the side margin LazyVim keeps around the cursor would scroll straight back, hence no margin.
    if win == vim.api.nvim_get_current_win() and vim.fn.virtcol(".") <= leftcol then
      vim.wo[win].virtualedit = "all"
      vim.wo[win].sidescrolloff = 0
      vim.cmd("normal! " .. (leftcol + 1) .. "|")
    end
    vim.fn.winrestview({ leftcol = leftcol })
  end)
end

-- Scroll the tree under the mouse by one wheel step, never past either end. Doing the clamping
-- here, instead of letting Neovim scroll and pulling it back afterwards, keeps it from stuttering.
function _G.neo_tree_wheel(win, direction)
  local step = tonumber(vim.o.mousescroll:match("hor:(%d+)")) or 6
  local leftcol = vim.api.nvim_win_call(win, function()
    return vim.fn.winsaveview().leftcol
  end)
  set_leftcol(win, math.min(math.max(leftcol + direction * step, 0), max_leftcol(win)))
end

for key, direction in pairs({ ["<ScrollWheelRight>"] = 1, ["<ScrollWheelLeft>"] = -1 }) do
  vim.keymap.set({ "n", "i", "v" }, key, function()
    local win = vim.fn.getmousepos().winid
    if is_tree(win) then
      return ("<Cmd>lua neo_tree_wheel(%d, %d)<CR>"):format(win, direction)
    end
    return key
  end, { expr = true, desc = "Scroll sideways (stops at the file tree's longest entry)" })
end

-- Collapsing a folder can leave the tree scrolled past its new longest entry, so pull it back.
-- Set up here rather than in the spec's `init`, which would replace LazyVim's own neo-tree `init`
-- (the one that opens the tree for `nvim .` instead of netrw).
vim.api.nvim_create_autocmd({ "WinScrolled", "CursorMoved" }, {
  callback = function()
    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
      if is_tree(win) then
        local limit = max_leftcol(win)
        local leftcol = vim.api.nvim_win_call(win, function()
          return vim.fn.winsaveview().leftcol
        end)
        if leftcol > limit then
          set_leftcol(win, limit)
        end
      end
    end
  end,
})

return {
  "nvim-neo-tree/neo-tree.nvim",
  opts = {
    default_component_configs = {
      -- No fade on the last letters: that marks a name cut off at the edge, and nothing is cut now
      container = { width = "fit_content", enable_character_fade = false },
    },
  },
}
