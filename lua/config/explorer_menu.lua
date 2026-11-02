-- VS Code-style right-click menu for the neo-tree file explorer.
-- Right-clicking anywhere else keeps Neovim's default popup menu.

local M = {}

local function state()
  return require("neo-tree.sources.manager").get_state("filesystem")
end

local function node()
  return state().tree:get_node()
end

local function node_dir()
  local n = node()
  return n.type == "directory" and n.path or vim.fn.fnamemodify(n.path, ":h")
end

-- Pickers and panels opened from the tree must start from a code window: a file opened in the
-- tree's window gets bounced elsewhere by neo-tree, losing the line it should jump to.
local function focus_code_window()
  local tree_win
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if vim.api.nvim_win_get_config(win).relative == "" then
      if vim.bo[vim.api.nvim_win_get_buf(win)].filetype == "neo-tree" then
        tree_win = win
      else
        vim.api.nvim_set_current_win(win)
        return
      end
    end
  end
  -- With only the tree open it fills the screen, so shrink it back to its usual width
  vim.cmd("botright vnew")
  if tree_win then
    vim.api.nvim_win_set_width(tree_win, require("neo-tree").config.window.width or 40)
  end
end

local function copy(text)
  vim.fn.setreg("+", text)
  vim.notify("Copied: " .. text)
end

local function cmd(name)
  return function()
    require("neo-tree.sources.filesystem.commands")[name](state())
  end
end

M.actions = {
  new_file = cmd("add"),
  new_folder = cmd("add_directory"),
  find_in_folder = function()
    local dir = node_dir()
    focus_code_window()
    LazyVim.pick("live_grep", { cwd = dir })()
  end,
  replace_in_folder = function()
    local dir = node_dir()
    focus_code_window()
    require("grug-far").open({ prefills = { paths = vim.fn.escape(dir, " ") } })
  end,
  copy = cmd("copy_to_clipboard"),
  cut = cmd("cut_to_clipboard"),
  paste = cmd("paste_from_clipboard"),
  rename = cmd("rename"),
  delete = cmd("delete"),
  copy_path = function()
    copy(node().path)
  end,
  copy_relative_path = function()
    copy(vim.fn.fnamemodify(node().path, ":."))
  end,
}

local items = {
  { "New\\ File", "new_file" },
  { "New\\ Folder", "new_folder" },
  { "-sep1-" },
  { "Find\\ in\\ Folder", "find_in_folder" },
  { "Find\\ and\\ Replace\\ in\\ Folder", "replace_in_folder" },
  { "-sep2-" },
  { "Copy", "copy" },
  { "Cut", "cut" },
  { "Paste", "paste" },
  { "-sep3-" },
  { "Copy\\ Path", "copy_path" },
  { "Copy\\ Relative\\ Path", "copy_relative_path" },
  { "-sep4-" },
  { "Rename", "rename" },
  { "Delete", "delete" },
}

for _, item in ipairs(items) do
  local rhs = item[2] and ("<Cmd>lua require('config.explorer_menu').actions." .. item[2] .. "()<CR>") or "<Nop>"
  vim.cmd("nnoremenu ExplorerPopUp." .. item[1] .. " " .. rhs)
end

vim.keymap.set("n", "<RightMouse>", function()
  local win = vim.fn.getmousepos().winid
  local buf = win ~= 0 and vim.api.nvim_win_get_buf(win)
  if buf and vim.bo[buf].filetype == "neo-tree" and vim.b[buf].neo_tree_source == "filesystem" then
    -- Left click first so the cursor lands on the clicked item.
    return "<LeftMouse><Cmd>popup ExplorerPopUp<CR>"
  end
  return "<RightMouse>"
end, { expr = true, desc = "Right-click menu" })

return M
